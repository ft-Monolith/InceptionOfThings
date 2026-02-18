#!/bin/bash

sudo apt-get update -qq && sudo apt-get install -y -qq curl

set -a; source /vagrant/config.env; set +a

export INSTALL_K3S_EXEC="--bind-address=${SERVER_IP} --node-external-ip=${SERVER_IP} --flannel-iface=${FLANNEL_IFACE}"
curl -sfL https://get.k3s.io | sh -

while [ ! -f "/var/lib/rancher/k3s/server/node-token" ]; do sleep 2; done

sudo kubectl apply -f /vagrant/apps.yaml