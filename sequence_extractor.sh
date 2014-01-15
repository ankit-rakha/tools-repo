#!/bin/bash

# The 1 based sequence extractor - sequence_extractor.sh
# No guarantees offered.

# usage:
 # 1) download the script or copy the contents
 # of the script and save it as sequence_extractor.sh
 # 2) make it executable: chmod 755 sequence_extractor.sh
 # reads from standard input or command line
 # 3) run the script: ./sequence_extractor.sh pa101.fasta 4 6

# create a backup copy of the input fasta file
# and delete the header
 sed -i.tmp -e '1d' $1 || exit $?


# merge the lines
 temp_var1=`awk '{printf $0;}' $1` || exit $?


# select the region
 temp_var2=$(((($3-1)-($2-1))+1)) || exit $?


# display the extracted sequence
 echo ${temp_var1:$(($2-1)):$temp_var2} && mv $1.tmp $1 || exit $?
