#! /bin/bash

user=$1
script_location=$2
shift;
shift;
slaves=("$@")

for slave in $slaves
    do
    echo "pulling docker images on $slave"
    ssh -t $user@$slave $script_location/pull-images.sh
done
