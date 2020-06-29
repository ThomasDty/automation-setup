#! /bin/bash

script_location=$1
user=$2
nfs_ip=$3

shift;
shift;
shift;
slaves=("$@")

echo "setup k8s on master node"
bash ./all-nodes/configure_node.sh
bash ./all-nodes/install_k8s_deps.sh

for slave in $slaves
    do
    ssh -t $user@$slave "bash $script_location/configure_node.sh $nfs_ip"
    ssh -t $user@$slave "bash $script_location/install_k8s_deps.sh"
done
