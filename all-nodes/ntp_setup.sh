#! /bin/bash
set -e

timezone=$1
apt-get update -y
timedatectl set-timezone $timezone
timedatectl set-ntp no
apt-get install -y ntp

set +e


