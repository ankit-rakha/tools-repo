#!/bin/bash

network="10.13.65."
key_file="~/.ssh/id_rsa.pub"
begin_node="$1"
end_node="$2"
USER="root"

# Add keys

for ((cluster_node="$begin_node"; cluster_node<="$end_node"; cluster_node++)); do
	
	echo "==> Adding keys to $network$cluster_node"
	ssh-copy-id -i ~/.ssh/id_rsa.pub "$USER"@"$network""$cluster_node"

done

# TEST passwordless ssh
# normal ips not infiniband

for ((cluster_node="$begin_node"; cluster_node<="$end_node"; cluster_node++)); do

	echo "==> Testing $network$cluster_node"
	ssh "$USER"@"$network""$cluster_node" exit && echo "$network$cluster_node --> OK" || echo "$network$cluster_node --> NOT OK"

done

# Check Vertica requirements

for ((cluster_node="$begin_node"; cluster_node<="$end_node"; cluster_node++)); do
	
	echo "==> Checking Vertica Requirements on $network$cluster_node"
	ssh "$USER"@"$network""$cluster_node" 'bash -s' < check_vertica_requirements.sh "$network""$cluster_node"

done

