#! /bin/bash

timezone=$1
script_location=$2
user=$3

shift;
shift;
shift;
slaves=("$@")

echo "executing ntp setup on master"
bash ./all-nodes/ntp_setup.sh $timezone

for slave in $slaves
    do
    echo "executing ntp setup script"
    ssh -t $user@$slave "bash $script_location/ntp_setup.sh $timezone"
done


