#!/bin/bash

PATH="/home/dbadmin/OPT/"
vsql="/opt/vertica/bin/vsql -U userName -w yourPassword -d yourDatabaseName"
vsqlFile=opt.vsql

$vsql -f "$PATH""$vsqlFile"