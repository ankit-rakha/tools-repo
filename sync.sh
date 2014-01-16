#!/bin/bash

# set up passwordless ssh and
# sync your local working copy with the directory on the remote server

# usage:
# 1) download the script or copy the contents
# of the script and save it as sync.sh
# 2) make it executable: chmod 755 sync.sh
# 3) run the script: ./sync.sh

user='ankit.rakha'

# put the ip address of remote machine here
ip='10.20.x.x'

rsync -r -a -v -e "ssh -l $user" --delete "$ip":~/NASA_robotics_project .
