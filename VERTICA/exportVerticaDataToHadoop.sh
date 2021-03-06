#!/bin/bash

if  [ $# -ne 1 ]; then

        echo "==> Usage ./exportVerticaDataToHadoop.sh tableName > log.out 2> log.error"
        exit -1

fi

impalaApp="/usr/bin/impala-shell"
impalaEntryNode="rewrhdw10"

inputPATH="/home/dbadmin/LATEST_EXPORT_PROGRAM/"
outputPATH="/home/dbadmin/LATEST_EXPORT_PROGRAM/"

gzipApp=$(which gzip)

masterSheet="masterSheet.txt"

#list of partitions generated by this program
partitionsList='partitionsList.txt'

stagingSchema="arakha"

verticaSchema="prod_gta5_11"
verticaTable="$1"
fileName=vertica-"$verticaSchema"-"$verticaTable"

#this is vertica bin directory
verticaBinDir=/opt/vertica/bin/

#vertica database credentials, pleasee use cli arguments
username=""
password=""
database=""

#dump extension
extCSV=".csv"
extGZ=".gz"
extIQL=".iql"

timeStamp ()
{
        date | tr [:space:] '-' | sed 's/-$//g'
}

#call vsql for dumping the data to remote host
vsql_call ()
{
        "$verticaBinDir"vsql -U "$username" -w "$password" -F $',' -At -P null='' -c "$1" "$2"
}

#List all the partitions in a given table
command="SELECT DISTINCT pt.partition_key FROM projections pj INNER JOIN partitions pt ON pt.projection_id=pj.projection_id WHERE pt.table_schema='$verticaSchema' AND pj.anchor_table_name='$verticaTable' ORDER BY 1;"

date_utc=$(date -u "+%Y%m")
echo "Partitions only before this yearMonth should be considered: $date_utc"

vsql_call "$command" | grep -v "$date_utc" > "$verticaSchema"-"$verticaTable"-"$partitionsList"

cat "$verticaSchema"-"$verticaTable"-"$partitionsList" | awk '{ print substr( $0, 0, length($0)-6)}' > platformIdList.txt
cat "$verticaSchema"-"$verticaTable"-"$partitionsList" | awk '{ print substr($0, length($0)-5, 4)}' > yearList.txt
cat "$verticaSchema"-"$verticaTable"-"$partitionsList" | awk '{ print substr($0, length($0)-1)}' > monthList.txt

paste -d, platformIdList.txt yearList.txt monthList.txt > "$verticaSchema"-"$verticaTable"-"$masterSheet"

rm platformIdList.txt yearList.txt monthList.txt

masterSheetEntries=$(wc -l < "$verticaSchema"-"$verticaTable"-"$masterSheet")

echo "DROP TABLE IF EXISTS $stagingSchema.$verticaTable;" > "$verticaSchema"-"$verticaTable""$extIQL"

ssh arakha@rewrhdn3 "$impalaApp --quiet -u arakha -B --output_delimiter=\",\" -i $impalaEntryNode -q \"describe $verticaSchema.$verticaTable\" | grep -iv platformId | grep -iv yearMonth | iconv -c -f utf-8 -t ascii | strings | sed -e \"s/\?1034h//g\" -e \"s/\[//g\" -e \"s/datetime,string/datetime,timestamp/g\" -e \"s/boolean/string/g\"" | awk -F, '{print $1,$2}' > datatypes-"$verticaSchema"_"$verticaTable"

tableColsDataTypes=$(cat datatypes-"$verticaSchema"_"$verticaTable" | sed -e 's/\<data\>/\`data\`/g' -e 's/\<set\>/\`set\`/g' -e 's/\<show\>/\`show\`/g' -e 's/\<to\>/\`to\`/g' -e 's/\<as\>/\`as\`/g' -e 's/location/\`location\`/g' -e 's/^\<timestamp\>/\`timestamp\`/g' -e 's/datetime/\`datetime\`/g' | tr '\n' ',' | sed 's/,$//g')

tableCols=$(cat datatypes-"$verticaSchema"_"$verticaTable" | awk '{print $1}' | tr '\n' ',' | sed -e 's/,$//g' -e 's/\<data\>/\`data\`/g' -e 's/\<set\>/\`set\`/g' -e 's/\<show\>/\`show\`/g' -e 's/\<to\>/\`to\`/g' -e 's/\<as\>/\`as\`/g' -e 's/location/\`location\`/g' -e 's/\<timestamp\>/\`timestamp\`/g' -e 's/datetime/days_add(\`datetime\`,0) as \`datetime\`/g')

echo "CREATE TABLE IF NOT EXISTS $stagingSchema.$verticaTable ($tableColsDataTypes) partitioned by (platformId int, yearMonth bigint) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' STORED AS TEXTFILE;" >> "$verticaSchema"-"$verticaTable""$extIQL"

for ((counter=1;counter<="$masterSheetEntries";counter++));do

        echo "==> Processing entry no. $counter"

        platformId=$(sed -n "$counter"p "$verticaSchema"-"$verticaTable"-"$masterSheet" | awk -F, '{print $1}')
        yearNo=$(sed -n "$counter"p "$verticaSchema"-"$verticaTable"-"$masterSheet" | awk -F, '{print $2}')
        monthNo=$(sed -n "$counter"p "$verticaSchema"-"$verticaTable"-"$masterSheet" | awk -F, '{print $3}')

        #Select data from particular partition and write to gzip file
        command="SELECT * FROM $verticaSchema.$verticaTable WHERE PlatformId="$platformId" AND DATE_PART('year', DateTime)="$yearNo" AND DATE_PART('month', DateTime)="$monthNo";"
        ssh arakha@rewrhdn3 "hdfs dfs -rm -r -skipTrash hdfs://rewrhdn2/user/arakha/""$verticaSchema""/""$verticaTable""/""$platformId""/""/""$yearNo""$monthNo""/""$fileName""-""$platformId""-""$yearNo""$monthNo""$extCSV"
        vsql_call "$command" | ssh arakha@rewrhdn3 "hdfs dfs -put - hdfs://rewrhdn2/user/arakha/""$verticaSchema""/""$verticaTable""/""$platformId""/""/""$yearNo""$monthNo""/""$fileName""-""$platformId""-""$yearNo""$monthNo""$extCSV"

        echo "ALTER TABLE $stagingSchema.$verticaTable ADD IF NOT EXISTS PARTITION (platformId=$platformId, yearMonth=$yearNo$monthNo) LOCATION '/user/arakha/$verticaSchema/$verticaTable/$platformId/$yearNo$monthNo/';" >> "$verticaSchema"-"$verticaTable""$extIQL"

        echo "INSERT INTO $verticaSchema.$verticaTable partition (platformId=$platformId, yearMonth=$yearNo$monthNo) select $tableCols from $stagingSchema.$verticaTable where platformId=$platformId and yearMonth=$yearNo$monthNo;" >> "$verticaSchema"-"$verticaTable""$extIQL"

done

echo "DROP TABLE IF EXISTS $stagingSchema.$verticaTable;" >> "$verticaSchema"-"$verticaTable""$extIQL"

chmod +x "$verticaSchema"-"$verticaTable""$extIQL"
scp "$verticaSchema"-"$verticaTable""$extIQL" arakha@rewrhdn3:/tmp/
ssh arakha@rewrhdn3 "$impalaApp --quiet -u arakha -B --output_delimiter=\",\" -i $impalaEntryNode -f /tmp/"$verticaSchema"-"$verticaTable"$extIQL"