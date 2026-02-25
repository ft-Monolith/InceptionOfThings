#!/bin/bash

export DOCKER_API_VERSION=1.44

if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script with sudo or as root."
  exit
fi

# Load config
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/../confs/config.env"

# Install kubectl
if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl already installed : $(kubectl version --client | head -n1)"
else
    echo "=== Installing kubectl ==="
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# Install K3D
if command -v k3d >/dev/null 2>&1; then
    echo "k3d already installed : $(k3d version | head -n1)"
else
    echo "=== Installing K3D ==="
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.6.0 bash
fi

# Prerequisites
echo "=== Installing prerequisites ==="
if ! command -v helm >/dev/null 2>&1; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Create K3D cluster
echo "=== Creating K3D cluster ==="
k3d cluster create iot-cluster --port "8888:80@loadbalancer"

# Create namespaces
echo "=== Creating namespaces ==="
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

# Deploy ArgoCD
echo "=== Installing ArgoCD ==="
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Deploy GitLab
echo "=== Installing GitLab (this will take 5-10 minutes) ==="
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Create root password secret before helm install
kubectl create secret generic gitlab-root-password \
  -n gitlab \
  --from-literal=password="${GITLAB_ROOT_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=jgavairo.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --set global.initialRootPassword.secret=gitlab-root-password \
  --set global.initialRootPassword.key=password \
  --timeout 600s

echo "Waiting for GitLab to be ready..."
kubectl rollout status deployment/gitlab-webservice-default -n gitlab --timeout=15m

# Get credentials
GITLAB_PWD="${GITLAB_ROOT_PASSWORD}"
ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Register GitLab repo credentials in ArgoCD (so it can sync once project is created)
echo "=== Registering GitLab repo credentials in ArgoCD ==="
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: argocd-gitlab-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/jgavairo-app.git
  username: root
  password: "${GITLAB_PWD}"
EOF

# Deploy ArgoCD app pointing to local GitLab
echo "=== Deploying ArgoCD application ==="
kubectl apply -f "${SCRIPT_DIR}/../confs/argocd/app.yaml"

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
