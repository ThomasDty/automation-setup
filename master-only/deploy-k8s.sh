#! /bin/bash

function join_to_cluster() {
    slave_ip=$1
    cmd=$2

    ssh -t root@$slave_ip "kubeadm reset -f"
    ssh -t root@$slave_ip $cmd

    echo "$slave_ip joined to cluster"
    return 0
}

function install_pod_network() {
    kubectl apply -f "https://cloud.weave.work/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
}

set -e
echo "Start k8s deployment"
user=$1
master_ip=$2
shift;
shift;
slave_ips=($@)

echo "kubeadm initiating"
kubeadm reset -f 
join_cmd=$(kubeadm init | grep "kubeadm join" | sed 's/.$//')
sleep 20s
echo "Initialization done"

if [ -z "$join_cmd" ];
then
    echo "Initialization error"
    echo "$join_cmd --discovery-token-unsafe-skip-ca-verification"
    exit 1
fi

echo "$join_cmd --discovery-token-unsafe-skip-ca-verification"

for slave in "${slave_ips[@]}";
do 
    echo "Joining $slave to cluster"
    join_to_cluster "$slave" "$join_cmd --discovery-token-unsafe-skip-ca-verification"
done

cp /etc/kubernetes/admin.conf $HOME
chown $USER:$USER $HOME/admin.conf
export KUBECONFIG="$HOME/admin.conf"

echo "Installing pod network addon"
kubectl get nodes
install_pod_network
kubectl get nodes

set +e
kubectl taint nodes --all node-role.kubernetes.io/master~
set -e

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "End k8s Deployment"
set +e

