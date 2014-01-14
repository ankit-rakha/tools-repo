#!/bin/bash

# Bash parsing options and arguments using getopts

# check out the ":" symbol in next line; it
# means "u" option should be provided with
# some value

while getopts "pu:x" FLAG;do

 case "$FLAG" in

 p) PFLAG=1;;

 u) UVAL=$OPTARG;;

 x) XFLAG=1;;

 *) echo "You can use p, u and x only"
 echo "USAGE: $0 [-px] [-u something]"
 exit 1;;

 esac

done >&2

# one way

if [[ "$PFLAG" ]]; then

 echo "PFLAG set";
 #your algorithm goes here

fi

# alternate way (instead of using if statement)

[[ "$UVAL" ]] && echo "u option set to $UVAL";

[[ "$XFLAG" ]] && echo "XFLAG set";
