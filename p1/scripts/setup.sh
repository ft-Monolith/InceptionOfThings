#!/bin/bash

source /vagrant/config.env

# Install curl if not present
if ! command -v curl &> /dev/null; then
	apt-get update -qq
	apt-get install -y curl
fi
#$1 represente le premier argument passe a un script
if [ "$1" = "server" ]; then
	curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=$SERVER_IP --flannel-iface=eth1" sh -
	cp /var/lib/rancher/k3s/server/node-token /vagrant/token
else
	while [ ! -f /vagrant/token ]; do sleep 2; done
	K3S_TOKEN=$(cat /vagrant/token)
	curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$K3S_TOKEN" INSTALL_K3S_EXEC="agent --node-ip=$WORKER_IP --flannel-iface=eth1" sh -
fi
