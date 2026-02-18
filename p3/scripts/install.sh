#!/bin/bash

export DOCKER_API_VERSION=1.44

if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script with sudo or as root."
  exit
fi

# Install kubectl ------------------------------------------------------------
if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl already installed : $(kubectl version --client --short | head -n1)"
else
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi
# ------------------------------------------------------------------------------



# Install K3D ------------------------------------------------------
if command -v k3d >/dev/null 2>&1; then
	echo "k3d already installed : $(k3d version | head -n1)"
else
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.6.0 bash
fi
# ------------------------------------------------------------------------------



# Cluster creation -----------------------------------------------------------------
k3d cluster create iot-cluster --port "8888:80@loadbalancer" 

sudo mkdir -p /root/.kube
sudo cp $HOME/.kube/config /root/.kube/config

sudo kubectl create namespace argocd
sudo kubectl create namespace dev


# Install ArgoCD -----------------------------------------------------------------
sudo kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

ARGOCD_PWD=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD password : ${ARGOCD_PWD}"

sudo kubectl apply -f ../confs/application.yaml

# utils
# sudo kubectl get nodes
# sudo kubectl get pods -n argocd
# sudo kubectl get pods -n dev
# sudo kubectl get ingress -n dev