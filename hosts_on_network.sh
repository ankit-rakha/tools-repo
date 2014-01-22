#!/bin/bash

network=192.168.1

for host in {1..254}; do

	ping -c 1 $network.$host > /dev/null;

if [ $? -eq 0 ]; then

	echo $network.$host is UP

fi

done
