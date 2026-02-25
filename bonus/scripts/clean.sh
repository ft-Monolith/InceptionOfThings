#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script with sudo or as root."
  exit
fi

echo "Cleaning up..."
pkill -f "port-forward" || true
kubectl delete namespace gitlab --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true
kubectl delete namespace dev --ignore-not-found=true
export DOCKER_API_VERSION=1.44
k3d cluster delete iot-cluster || true
echo "Done."