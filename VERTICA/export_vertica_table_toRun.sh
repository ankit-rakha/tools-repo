#!/bin/bash

#this is vertica bin directory
verticaBinDir=/opt/vertica/bin/

#this is the schema under which all the tables will be dumped to hadoop -- cla
verticaSchema=dev_gta5_11_ps3

# this is staging schema for moving partitions -- cla
stagingSchema=Backup

#list of tables for a particular node -- cla
tablesFile=node1.txt

#this user must be present on both vertica and hadoop cluster -- cla
user=arakha

#this is the node name where we are dumping data
hostname=rewrhdw1dv

adminNode=rewrhda1dv

#remote path on the hadoop node
remotePath=/datastore/DATA/

#remote HDFS path on hadoop node
remoteHDFSPath=/user/hdfs/input-data/local-input/

#remote path on admin node
remoteAdminPath=/tmp/

#dump extension
ext=.csv

#list of partitions generated by this program
partitions_list='partitions_list.txt'

#vertica database credentials, pleasee use cli arguments
username=""
password=""

#call vsql for dumping the data to remote host
vsql_call ()
{
	"$verticaBinDir"vsql -U "$username" -w "$password" -F $',' -At -P null='' -c "$1" "$2"
}

namenodeUrl=http://namenode:50070/webhdfs/v1
hdfsUrl=hdfs://nameservice1"$remoteHDFSPath""$verticaSchema"

#call vsql for dumping the data to remote host
vsql_call1 ()
{
        "$verticaBinDir"vsql -U "$username" -w "$password" -F $' ' -At -P null='' -c "$1" "$2"
}

#calculate the number of tables in the tables file
numTables=$(wc -l < "$tablesFile")

#loop over all the tables in the table list one by one
for ((counter1=1;counter1<="$numTables";counter1++));do

	printf "\n==> Processing table no. $counter1 out of $numTables tables\n"
	#name of the vertica database table being processed
	verticaTable=$(sed -n "$counter1"p "$tablesFile")

	command1="SELECT column_name, data_type FROM columns WHERE table_schema='$verticaSchema' AND table_name='$verticaTable';"
	
	echo "DROP TABLE IF EXISTS $verticaSchema""_""$verticaTable"";" > external_table.hql
	echo "CREATE EXTERNAL TABLE IF NOT EXISTS $verticaSchema""_""$verticaTable"" (" >> external_table.hql
	
	echo "DROP TABLE IF EXISTS hdfs.$verticaSchema""_""$verticaTable"";" > external_table.vsql
	echo "CREATE EXTERNAL TABLE hdfs.$verticaSchema""_""$verticaTable"" (" >> external_table.vsql
	
	vsql_call1 "$command1" | sed -e "$ ! s/$/,/" >> external_table.vsql
	vsql_call1 "$command1" | sed -e "$ ! s/$/,/" -e 's/int/bigint/g' -e 's/varchar.*/string/g' >> external_table.hql
	
	printf ") AS COPY SOURCE Hdfs(url='" >> external_table.vsql
	echo ") PARTITIONED BY (yearMonth BIGINT) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' NULL DEFINED AS '' STORED AS TEXTFILE;" >> external_table.hql

	printf "\n==> GENERATING PARTITIONS FOR table: $verticaTable\n"
	#create the partitions list
	command="SELECT DISTINCT pt.partition_key FROM projections pj INNER JOIN partitions pt ON pt.projection_id=pj.projection_id WHERE pt.table_schema='$verticaSchema' AND pj.anchor_table_name='$verticaTable' ORDER BY 1;"

	date_utc=$(date -u "+%Y%m")
	echo "Partitions only before this date should be considered: $date_utc"
	vsql_call "$command" | grep -v "$date_utc" > "$partitions_list"

	#calculate number of partitions
	num_partitions=$(wc -l < "$partitions_list")

	#loop over each partition one at a time
	for ((counter=1;counter<="$num_partitions";counter++));do

		printf "\n==> Processing partition no. $counter out of total $num_partitions for table: $verticaTable\n"

		#get the partition name
		partition=$(sed -n "$counter"p "$partitions_list")

		#move partition to staging area
		command="SELECT MOVE_PARTITIONS_TO_TABLE('$verticaSchema.$verticaTable','$partition','$partition','$stagingSchema.$verticaSchema"_"$verticaTable');"
		"$verticaBinDir"vsql -U "$username" -w "$password" -c "$command"

		printf "\n==> CREATE REMOTE DUMP FOR SCHEMA: $verticaSchema, TABLE: $verticaTable AND PARTITION: $partition\n"
		#select all the "records" from the partition
		command="SELECT * FROM $stagingSchema.$verticaSchema"_"$verticaTable"
		echo "$command"
		vsql_call "$command" | ssh "$user"@"$hostname" "cat > $remotePath$verticaSchema$verticaTable$partition$ext" && printf "\n==> DONE .. \n"

		#move partitions back to original table
		command="SELECT MOVE_PARTITIONS_TO_TABLE('$stagingSchema.$verticaSchema"_"$verticaTable','$partition','$partition','$verticaSchema.$verticaTable');"
		"$verticaBinDir"vsql -U "$username" -w "$password" -c "$command"

		printf "\n==> CLEAN LOADING AFTER REMOVING OLD FILES FROM REMOTE HADOOP CLUSTER HDFS\n\n"
		#create a partition directory on HDFS
		ssh -t -t -t "$user"@"$hostname" "echo \"\" | sudo -S -u hdfs hadoop fs -mkdir -p $remoteHDFSPath$verticaSchema/$verticaTable/$partition"

		#copy data from local filesystem to hadoop filesystem
		ssh -t -t -t "$user"@"$hostname" "echo \"\" | sudo -S -u hdfs hadoop fs -copyFromLocal -f $remotePath$verticaSchema$verticaTable$partition$ext $remoteHDFSPath$verticaSchema/$verticaTable/$partition/$verticaSchema"_"$verticaTable"_"$partition$ext"

		printf "\n==> CLEANUP ..\n\n"
		#remove temp data from local filesystem
		ssh -t -t -t "$user"@"$hostname" "rm -rf $remotePath$verticaSchema$verticaTable$partition$ext"

		printf "$namenodeUrl$remoteHDFSPath$verticaSchema/$verticaTable/$partition/$verticaSchema""_""$verticaTable""_""$partition""$ext""," >> external_table.vsql
		printf "ALTER TABLE $verticaSchema""_""$verticaTable"" ADD IF NOT EXISTS PARTITION (yearMonth = '""$partition""') LOCATION ""'$hdfsUrl/$verticaTable/$partition/';" >> external_table.hql

	done

done

printf "',username='hdfs')DELIMITER ',';"  >> external_table.vsql
chmod +x external_table.*ql
"$verticaBinDir"vsql -U "$username" -w "$password" -f external_table.vsql

scp external_table.hql "$user"@"$adminNode":$remoteAdminPath
ssh -t -t -t "$user"@"$adminNode" "echo \"\" | sudo -S -u hdfs hive -f ""$remoteAdminPath""external_table.hql" 
ssh -t -t -t "$user"@"$adminNode" "rm -rf $remoteAdminPath""external_table.hql"
