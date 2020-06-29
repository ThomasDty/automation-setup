#! /bin/bash

docker login

arch=`uname -m`

docker pull 

if [ "$arch" == "x86" ]; then
    docker pull <x86 image>
fi
