#!/bin/bash

if  [ $# -ne 1 ]; then

        echo "==> Usage ./unification.sh tableName > log.out 2> log.error"
        exit -1
fi

schemaPS3="prod_gta5_11_ps3"
schemaXBOX360="prod_gta5_11_xbox360"
schemaNEW="prod_gta5_11"
table="$1"
impalaApp="/usr/bin/impala-shell"
impalaEntryNode="rewrhdw10"
ext=".iql"
partitionsFile="partitions-for-"

echo "USE $schemaNEW;" > "$schemaNEW"-"$table""$ext"

echo "DROP TABLE IF EXISTS $schemaNEW.$table;" >> "$schemaNEW"-"$table""$ext"

"$impalaApp" --quiet -u arakha -B --output_delimiter="," -i "$impalaEntryNode" -q "describe "$schemaXBOX360"_"$table"pqc" | grep -iv "yearMonth" | iconv -c -f utf-8 -t ascii | strings | sed -e 's/\?1034h//g' -e 's/\[//g' -e 's/datetime,string/datetime,timestamp/g' | awk -F, '{print $1,$2}' > datatypes-"$schemaXBOX360"_"$table"

"$impalaApp" --quiet -u arakha -B --output_delimiter="," -i "$impalaEntryNode" -q "describe "$schemaPS3"_"$table"pqc" | grep -iv "yearMonth" | iconv -c -f utf-8 -t ascii | strings | sed -e 's/\?1034h//g' -e 's/\[//g' -e 's/datetime,string/datetime,timestamp/g' | awk -F, '{print $1,$2}' > datatypes-"$schemaPS3"_"$table"

COL_AND_DATATYPE_DIFF=$(diff datatypes-"$schemaXBOX360"_"$table" datatypes-"$schemaPS3"_"$table")

if [ -z "$COL_AND_DATATYPE_DIFF" ]; then

        echo "==> COLUMNS AND DATATYPES IN BOTH SCHEMAS - XBOX 360 AND PS3 LOOK GOOD"

else

        echo "==> COLUMNS AND DATATYPES IN BOTH SCHEMAS - XBOX 360 AND PS3 ARE NOT IDENTICAL. PLEASE CHECK."
        exit -1

fi

tableColsDataTypes=$(cat datatypes-"$schemaXBOX360"_"$table" | sed -e 's/\<data\>/\`data\`/g' -e 's/\<set\>/\`set\`/g' -e 's/\<show\>/\`show\`/g' -e 's/\<to\>/\`to\`/g' -e 's/\<as\>/\`as\`/g' -e 's/location/\`location\`/g' -e 's/^\<timestamp\>/\`timestamp\`/g' -e 's/datetime/\`datetime\`/g' | tr '\n' ',' | sed 's/,$//g')

tableCols=$(cat datatypes-"$schemaXBOX360"_"$table" | awk '{print $1}' | tr '\n' ',' | sed -e 's/,$//g' -e 's/\<data\>/\`data\`/g' -e 's/\<set\>/\`set\`/g' -e 's/\<show\>/\`show\`/g' -e 's/\<to\>/\`to\`/g' -e 's/\<as\>/\`as\`/g' -e 's/location/\`location\`/g' -e 's/\<timestamp\>/\`timestamp\`/g' -e 's/datetime/days_add(\`datetime\`,0) as \`datetime\`/g')

"$impalaApp" --quiet -u arakha -B --output_delimiter="," -i "$impalaEntryNode" -q "show partitions "$schemaXBOX360"_"$table"pqc" | grep -v "Total" | awk -F, '{print $1}' | iconv -c -f utf-8 -t ascii | strings | sed -e 's/\?1034h//g' -e 's/\[//g' > "$partitionsFile""$schemaXBOX360"_"$table"

"$impalaApp" --quiet -u arakha -B --output_delimiter="," -i "$impalaEntryNode" -q "show partitions "$schemaPS3"_"$table"pqc" | grep -v "Total" | awk -F, '{print $1}' | iconv -c -f utf-8 -t ascii | strings | sed -e 's/\?1034h//g' -e 's/\[//g' > "$partitionsFile""$schemaPS3"_"$table"

rm "$partitionsFile""$table"
cat "$partitionsFile""$schemaXBOX360"_"$table" "$partitionsFile""$schemaPS3"_"$table" | sort | uniq > "$partitionsFile""$table"

numPartitions=$(wc -l < "$partitionsFile""$table")

if (("$numPartitions==0")); then

        echo "==> THERE ARE NO PARTITIONS FOUND IN BOTH PS3 AND XBOX360 SCHEMAS HENCE SELECTING ALL THE CONTENTS OF TABLE $table"

        echo "CREATE TABLE $schemaNEW.$table ($tableColsDataTypes) partitioned by (platformId int) stored as parquet;" >> "$schemaNEW"-"$table""$ext"

        for platformUniqueId in {1..2}; do

                if ((platformUniqueId==1)); then

                        echo "==> PROCESSING XBOX360 SCHEMA FOR TABLE $table"

                        echo "INSERT INTO $schemaNEW.$table partition (platformId=$platformUniqueId) select $tableCols from default.""$schemaXBOX360"_"$table"pqc";" >> "$schemaNEW"-"$table""$ext"

                elif ((platformUniqueId==2)); then

                        echo "==> PROCESSING PS3 SCHEMA FOR TABLE $table"

                        echo "INSERT INTO $schemaNEW.$table partition (platformId=$platformUniqueId) select $tableCols from default.""$schemaPS3"_"$table"pqc";" >> "$schemaNEW"-"$table""$ext"

                fi

        done

        chmod +x "$schemaNEW"-"$table""$ext"

        "$impalaApp" --quiet -u arakha -B --output_delimiter="," -i "$impalaEntryNode" -f "$schemaNEW"-"$table""$ext" && "$impalaApp" --quiet -u arakha -B --output_delimiter="," -i "$impalaEntryNode" -q "SELECT COUNT(*) FROM $schemaNEW.$table;"

else

        echo "==> THERE ARE TOTAL OF $numPartitions PARTITIONS FOUND IRRESPECTIVE OF PS3 AND XBOX360 SCHEMAS HENCE SELECTING CONTENTS OF EACH PARTITION FOR TABLE $table"

        echo "CREATE TABLE $schemaNEW.$table ($tableColsDataTypes) partitioned by (platformId int, yearMonth bigint) stored as parquet;" >> "$schemaNEW"-"$table""$ext"

        for platformUniqueId in {1..2}; do

                for ((counter=1;counter<="$numPartitions";counter++)); do

                        partition=$(sed -n "$counter"p "$partitionsFile""$table")

                        echo "==> PROCESSING PARTITION No. $counter: $partition"

                        if ((platformUniqueId==1)); then

                                echo "==> PROCESSING XBOX360 SCHEMA FOR TABLE $table"

                                echo "INSERT INTO $schemaNEW.$table partition (platformId=$platformUniqueId, yearMonth=$partition) select $tableCols from default.""$schemaXBOX360"_"$table"pqc" where yearMonth=$partition;" >> "$schemaNEW"-"$table""$ext"

                        elif ((platformUniqueId==2)); then

                                echo "==> PROCESSING PS3 SCHEMA FOR TABLE $table"

                                echo "INSERT INTO $schemaNEW.$table partition (platformId=$platformUniqueId, yearMonth=$partition) select $tableCols from default.""$schemaPS3"_"$table"pqc" where yearMonth=$partition;" >> "$schemaNEW"-"$table""$ext"

                        fi
                done

        done

        chmod +x "$schemaNEW"-"$table""$ext"

        "$impalaApp" --quiet -u arakha -B --output_delimiter="," -i "$impalaEntryNode" -f "$schemaNEW"-"$table""$ext" && "$impalaApp" --quiet -u arakha -B --output_delimiter="," -i "$impalaEntryNode" -q "SELECT COUNT(*) FROM $schemaNEW.$table;"

fi