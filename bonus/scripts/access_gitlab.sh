#!/bin/bash

echo "=========================================="
echo "  GitLab : http://127.0.0.1:8081"
echo "  USER   : root"
echo -n "  PASSWORD: "
sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode
echo ""
echo "=========================================="

sudo kubectl port-forward svc/gitlab-webservice-default -n gitlab 8081:8181
