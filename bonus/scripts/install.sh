#!/bin/bash

export DOCKER_API_VERSION=1.44

if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script with sudo or as root."
  exit
fi

# Install kubectl ------------------------------------------------------------
if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl already installed : $(kubectl version --client | head -n1)"
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


# Install Helm --------------------------------------------------------------------
if command -v helm >/dev/null 2>&1; then
    echo "helm already installed : $(helm version | head -n1)"
else
	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi


# Cluster creation -----------------------------------------------------------------
k3d cluster create iot-cluster \
    -p "8888:80@loadbalancer" \
    -p "8081:8081@loadbalancer"

sudo mkdir -p /root/.kube
sudo cp $HOME/.kube/config /root/.kube/config

sudo kubectl create namespace argocd
sudo kubectl create namespace dev
sudo kubectl create namespace gitlab


# # Install ArgoCD -----------------------------------------------------------------
sudo kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sudo kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

ARGOCD_PWD=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Install GitLab -----------------------------------------------------------------
echo "Installing GitLab with Helm"
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set global.hosts.domain=localhost \
  --set global.edition=ce \
  --set global.ingress.configureCertmanager=false \
  --set certmanager.enabled=false \
  --set gitlab-runner.install=false \
  --set prometheus.install=false \
  --set gitlab.webservice.replicaCount=1 \
  --set gitlab.sidekiq.replicaCount=1 \
  --set postgresql.image.tag=16.4.0 \
  --timeout 600s

# -------------------------------------------------------------------------------

echo "Waiting for GitLab secret to be generated..."
while ! kubectl get secret -n gitlab gitlab-gitlab-initial-root-password > /dev/null 2>&1; do
  sleep 2
done

GITLAB_PWD=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

echo "Installation complete!"
echo "------------------------------------------------------"
echo "ArgoCD password : ${ARGOCD_PWD}"
echo "GitLab root password : ${GITLAB_PWD}"
echo "------------------------------------------------------"
echo "ArgoCD : https://localhost:8080"
echo "GitLab : http://localhost:8081"
echo "------------------------------------------------------"

# # utils
# # sudo kubectl get nodes
# # sudo kubectl get pods -n argocd
# # sudo kubectl get pods -n dev
# # sudo kubectl get ingress -n dev