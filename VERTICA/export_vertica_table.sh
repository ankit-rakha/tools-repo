#!/bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Export data from vertica cluster to hadoop cluster - export_vertica_table.sh
#
# Usage:
# 1) Download the script or copy the contents
# of the script and save it as export_vertica_table.sh
# 2) Make it executable: chmod +x export_vertica_table.sh
# reads from standard input or command line
# 3) Run the script: ./export_vertica_table.sh verticaSchema staginSchema tablesFile user username password > log.out 2> log_error.out
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

if [ $# -ne 6 ]; then
	
	echo "==> Usage: ./export_vertica_table.sh verticaSchema staginSchema tablesFile user username password > log.out 2> log_error.out"
	exit -1
	
fi

#this is vertica bin directory
verticaBinDir=/opt/vertica/bin/

#this is the schema under which all the tables will be dumped to hadoop -- cla
#verticaSchema=dev_gta5_11_ps3
verticaSchema="$1"

# this is staging schema for moving partitions -- cla
#stagingSchema=Backup
stagingSchema="$2"

#list of tables for a particular node -- cla
#tablesFile=node1.txt
tablesFile="$3"

#this user must be present on both vertica and hadoop cluster -- cla
#user=arakha
user="$4"

#this is the node name where we are dumping data
hostname=rewrhdw1dv

#remote path on the hadoop node
remotePath=/datastore/DATA/

#remote HDFS path on hadoop node
remoteHDFSPath=/user/hdfs/input-data/local-input/

#dump extension
ext=.csv

#list of partitions generated by this program
partitions_list='partitions_list.txt'

#vertica database credentials, pleasee use cli arguments
username="$5"
password="$6"

#call vsql for dumping the data to remote host
vsql_call ()
{
	"$verticaBinDir"vsql -U "$username" -w "$password" -F $',' -At -P null='' -c "$1" "$2"
}

#calculate the number of tables in the tables file
numTables=$(wc -l < "$tablesFile")

#loop over all the tables in the table list one by one
for ((counter1=1;counter1<="$numTables";counter1++));do

	printf "\n==> Processing table no. $counter1 out of $numTables tables\n"
	#name of the vertica database table being processed
	verticaTable=$(sed -n "$counter1"p "$tablesFile")

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
		ssh -t -t -t "$user"@"$hostname" "echo \"yourHostPassword\" | sudo -S -u hdfs hadoop fs -mkdir -p $remoteHDFSPath$verticaSchema/$verticaTable/$partition"

		#copy data from local filesystem to hadoop filesystem
		ssh -t -t -t "$user"@"$hostname" "echo \"yourHostPassword\" | sudo -S -u hdfs hadoop fs -copyFromLocal -f $remotePath$verticaSchema$verticaTable$partition$ext $remoteHDFSPath$verticaSchema/$verticaTable/$partition/$verticaSchema"_"$verticaTable"_"$partition$ext"

		printf "\n==> CLEANUP ..\n\n"
		#remove temp data from local filesystem
		ssh -t -t -t "$user"@"$hostname" "rm -rf $remotePath$verticaSchema$verticaTable$partition$ext"

	done

done

