#! /bin/bash

namespace=$1
docker login --username= --password= <docker registry>
docker pull

kubectl apply --namespace $namespace -f deployment.yaml
kubectl create --namespace $namespace -f service.yaml
kubectl create clusterrolebinding jenkins --clusterrole cluster-admin --serviceaccount-jenkins:default