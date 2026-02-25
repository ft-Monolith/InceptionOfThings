#!/bin/bash

# Crée le namespace gitlab
sudo kubectl create namespace gitlab --dry-run=client -o yaml | sudo kubectl apply -f -

# Ajoute le repo Helm GitLab
sudo helm repo add gitlab https://charts.gitlab.io/
sudo helm repo update

# Installe GitLab avec la config minimale minikube
echo "Installing GitLab (cela peut prendre 5-10 min)..."
sudo helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=iotbonus.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

echo ""

