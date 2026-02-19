#!/bin/bash

export DOCKER_API_VERSION=1.44

if [ "$EUID" -ne 0 ]; then 
  echo "Please run this script with sudo or as root."
  exit
fi

# 1. Nettoyage
k3d cluster delete iot-cluster 2>/dev/null

# 2. Création du Cluster (On garde tes ports habituels)
k3d cluster create iot-cluster \
    -p "8888:80@loadbalancer" \
    -p "8080:30080@loadbalancer"

# Configuration Kubeconfig
mkdir -p /root/.kube
k3d kubeconfig get iot-cluster > /root/.kube/config
USER_HOME=$(eval echo ~${SUDO_USER})
mkdir -p "${USER_HOME}/.kube"
k3d kubeconfig get iot-cluster > "${USER_HOME}/.kube/config"
chown -R ${SUDO_USER}:${SUDO_USER} "${USER_HOME}/.kube"

kubectl create namespace argocd
kubectl create namespace gitlab

# 3. Installation GitLab (LA CORRECTION EST ICI)
echo "Installing GitLab avec la config 'Minikube'..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --timeout 600s \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=localhost \
  --set global.hosts.externalURL=http://localhost:8181 \
  --set global.hosts.https=false \
  --set certmanager-issuer.enabled=false \
  --set gitlab.webservice.replicaCount=1 \
  --set postgresql.image.tag=16.4.0

# 4. Installation ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 5. Attente des services
echo "Attente de GitLab (cela peut prendre 5-8 min)..."
kubectl rollout status deployment/gitlab-webservice-default -n gitlab --timeout=15m

# 6. Automatisation des accès
sudo fuser -k 8081/tcp 8080/tcp 2>/dev/null

# On lance les tunnels en tâche de fond
# NOTE: Le tunnel GitLab mappe le 8081 vers le 8181 interne (match avec externalURL)
kubectl port-forward svc/gitlab-webservice-default -n gitlab 8081:8181 --address 0.0.0.0 > /dev/null 2>&1 &
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 > /dev/null 2>&1 &

# 7. Récupération des mots de passe
GITLAB_PWD=$(kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)
ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "-------------------------------------------------------"
echo "GitLab Root Password : ${GITLAB_PWD}"
echo "ArgoCD Admin Password : ${ARGOCD_PWD}"
echo "-------------------------------------------------------"
echo "GitLab : http://localhost:8081"
echo "ArgoCD : https://localhost:8080"
echo "-------------------------------------------------------"
# # utils
# # sudo kubectl get nodes
# # sudo kubectl get pods -n argocd
# # sudo kubectl get pods -n dev
# # sudo kubectl get ingress -n dev


gitlab+deploy-token-1
gldt-sudKEpEvgtR5z6BVnj8t