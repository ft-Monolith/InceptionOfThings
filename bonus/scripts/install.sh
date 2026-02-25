#!/bin/bash

export DOCKER_API_VERSION=1.44

if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script with sudo or as root."
  exit
fi

# Prerequisites
echo "=== Installing prerequisites ==="
if ! command -v helm >/dev/null 2>&1; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Create namespaces
echo "=== Creating namespaces ==="
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# Deploy GitLab
echo "=== Installing GitLab (this will take 5-10 minutes) ==="
helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=jgavairo.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

echo "Waiting for GitLab to be ready..."
kubectl rollout status deployment/gitlab-webservice-default -n gitlab --timeout=15m

# Deploy ArgoCD
echo "=== Installing ArgoCD ==="
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Get credentials
GITLAB_PWD=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)
ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo "GitLab    : http://localhost:8081"
echo "  User    : root"
echo "  Pass    : ${GITLAB_PWD}"
echo ""
echo "ArgoCD    : https://localhost:8080"
echo "  User    : admin"
echo "  Pass    : ${ARGOCD_PWD}"
echo "=========================================="

# Setup port-forwarding
kubectl port-forward svc/gitlab-webservice-default -n gitlab 8081:8181 --address 0.0.0.0 > /dev/null 2>&1 &
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 > /dev/null 2>&1 &

echo "Port-forwards started (8081 for GitLab, 8080 for ArgoCD)"
