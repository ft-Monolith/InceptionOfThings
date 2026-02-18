#!/bin/bash

echo "Cleaning up"
sudo DOCKER_API_VERSION=1.44 k3d cluster delete iot-cluster

