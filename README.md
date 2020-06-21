# automation-setup

This is the scripts to setup Jenkins server, directly on host or running in docker container.

## Requirements
* Ubuntu 16.04 on all nodes
* At least one master and one slave nodes
* An NFS volume mounted on master and slave
* Passwordless login between nodes

## Instructions
1. Edit config.yaml 
2. Edit pv and pvc for NFS
3. Upload files to master
4. Execute `setup.sh`

