#!/bin/bash

echo "Cleaning GitLab namespace..."
sudo kubectl delete namespace gitlab || true
sudo fuser -k 8080/tcp 2>/dev/null || true
echo "Done."

