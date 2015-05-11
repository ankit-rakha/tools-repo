#!/bin/bash

hdfsApp="/usr/bin/hdfs"
userName="arakha"

if  [ $# -ne 2 ]; then

	echo "==> Usage ./checkCopyingStatus.sh schemaName tableName > log.out 2> log.error"
	exit -1

fi

schemaName="$1"
tableName="$2"

"$hdfsApp" dfs -du -h /user/"$userName"/$schemaName/$tableName/*/*

