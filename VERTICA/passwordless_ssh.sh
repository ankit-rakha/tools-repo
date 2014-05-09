#!/bin/bash

#ssh-keygen -t rsa

for server in {21,22,23,24,25,26,27,28,29,30,31,32,33};do

	ssh "$USER"@10.2.72."$server" 'bash -s' < addkeys.sh
	cat ~/.ssh/id_rsa.pub | ssh "$USER"@10.2.72."$server" 'cat >> ~/.ssh/authorized_keys' 

done

#TEST passwordless ssh
#normal ips
for server in {21,22,23,24,25,26,27,28,29,30,31,32,33};do

	ssh "$USER"@10.2.72."$server" exit && echo "10.2.72.$server --> OK" || echo "10.2.72.$server --> NOT OK"

done

#infiniband ips
for server in {21,22,23,24,25,26,27,28,29,30,31,32,33};do

	ssh "$USER"@10.20.72."$server" exit && echo "10.20.72.$server --> OK" || echo "10.20.72.$server --> NOT OK"

done

