#!/bin/bash

verticaBinDir=/opt/vertica/bin
verticaSchema=dev_gta5_11_xbox360
numNodes=3
runDir=/home/arakha/integration_test/

"$verticaBinDir"/vsql -U dbadmin -w '' -F $',' -At -P null='' -c "SELECT (SUM(used_bytes)+SUM(ROS_USED_BYTES))/1073741824 as diskspace, anchor_table_name, anchor_table_schema FROM projection_storage WHERE anchor_table_schema='$verticaSchema' group by anchor_table_name, anchor_table_schema order by diskspace DESC;" | awk -F, '{print $2}' > temp

numLines=$(wc -l < temp)
counter1=0
rm node*.txt
for ((counter=1;counter<=$numLines;counter++));do

	counter1=$((counter1+1))

	if (($counter1 < "$numNodes"));then
		
		sed -n "$counter"p temp >> node"$counter1".txt

	elif (($counter1 == "$numNodes"));then
		
		sed -n "$counter"p temp >> node"$counter1".txt

		counter1=0
	fi

done
rm temp

for ((counter2=1;counter2<="$numNodes";counter2++));do

	echo "#!/bin/bash" > dataExportNode"$counter2".sh
	echo "tablesFile=node$counter2.txt" >> dataExportNode"$counter2".sh
	echo "hostname=rewrhdw$counter2""dv" >> dataExportNode"$counter2".sh
	echo "verticaSchema=$verticaSchema" >> dataExportNode"$counter2".sh
	cat contents >> dataExportNode"$counter2".sh
	chmod +x dataExportNode"$counter2".sh
	scp node"$counter2".txt dataExportNode"$counter2".sh rsgewrvrt"$counter2"dv:"$runDir" 
done
