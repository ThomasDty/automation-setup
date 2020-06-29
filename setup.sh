#! /bin/bash
set -e -x

echo "Installing dependencies"

apt-get update
apt-get install -y python-pip
pip install yq
pip install python-jenkins
apt-get install -y jq
apt-get install -y ntp

echo "Retrieving configs"
master=`cat config.yaml | yq .master.server | sed "s/\"//g"`
slaves=`cat config.yaml | yq .slaves[] | sed "s/\"//g"`
user=`cat config.yaml | yq .master.user | sed "s/\"//g"`
script_location=`cat config.yaml | yq .scriptLocation | sed "s/\"//g"`
timezone=`cat config.yaml | yq .timeZone | sed "s/\"//g"`
nfs_ip=`cat config.yaml | yq .nfs.server | sed "s/\"//g"`
nof_path=`cat config.yaml | yq .nfs.path | sed "s/\"//g"`
jenkins_namespace=`cat config.yaml | yq .jenkins.namespace | sed "s/\"//g"`

echo "Uploading code"
for slave in $slaves
    do
    slave=`echo $slave | sed "s/\"//g"`
    ssh -t $user@$slave "mkdir -p $script_location"
    for filename in ./all-nodes/*; do
        scp $filename $user@$slave:$script_location
    done
    for filename in ./slaves-only/*; do
        scp $filename $user@slave:$script_location
    done
done
echo "scripts are uploaded onto slave nodes"

./master-only/ntp_setup.sh $timezone $script_location $user "${slaves[@]}"
wait
echo "ntp setup done"

./master-only/setup-k8s-deps.sh $script_location $user $nfs_ip "${slaves[@]}"
wait
echo "k8s package installation done"

./master-only/deploy-k8s.sh $user $master "${slaves[@]}"
wait
echo "deploy k8s service"

sed -i -e "s@<nfs-host>@nfs_ip@g" ./master-only/jenkins/pvc.yaml
kubectl create namespace $jenkins_namespace
kubectl apply --namespaces $jenkins_namespace -f ./master-only/jenkins/pvc.yaml
kubectl apply --namespaces $jenkins_namespace -f ./master-only/jenkins/pv.yaml
wait
echo "setup nfs pv and pvc"

current_dir=`pwd`
cd ./master-only/jenkins
bash InstallJenkins.sh $jenkins_namespace
cd $current_dir
wait

./master-only/pull-images.sh $user $script_location "${slaves[@]}"
echo "Pulling Jenkins image done"

echo "setup is done"

set +e