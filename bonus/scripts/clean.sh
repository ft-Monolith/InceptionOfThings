#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script with sudo or as root."
  exit
fi

echo "Cleaning up..."
kubectl delete namespace gitlab || true
pkill -f "port-forward" || true
echo "Done."