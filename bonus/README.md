# Bonus: GitLab + ArgoCD

This bonus sets up a local GitLab instance with ArgoCD for GitOps-based deployments.

## Prerequisites

- Docker installed
- k3d cluster running (from p3)
- kubectl configured

## Installation

```bash
sudo bash scripts/install.sh
```

This will:
1. Install Helm
2. Deploy GitLab in the `gitlab` namespace
3. Deploy ArgoCD in the `argocd` namespace
4. Create a `dev` namespace for applications
5. Set up port-forwards for web access

## Access

After installation, you'll see credentials for:
- **GitLab**: http://localhost:8081 (user: root)
- **ArgoCD**: https://localhost:8080 (user: admin)

## Cleanup

```bash
sudo bash scripts/clean.sh
```

## Manual Steps (if needed)

### 1. Create a GitLab project

- Go to http://localhost:8081 and login as root
- Create a new project called `jgavairo-app`
- In project Settings > Repository > Deploy tokens, create a read-only token for ArgoCD

### 2. Push deployment config to GitLab

```bash
git clone http://root@127.0.0.1:8081/root/jgavairo-app.git
cd jgavairo-app
mkdir app
cp ../utils/deployment.yaml app/
git add .
git commit -m "initial deployment"
git push
```

### 3. Configure ArgoCD

- Go to https://localhost:8080
- Settings > Repositories > Connect Repo
- URL: `http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/jgavairo-app.git`
- Click "Connect"

### 4. Create the ArgoCD application

```bash
kubectl apply -f confs/argocd/app.yaml
```

## Test GitOps

Update the app version in GitLab and watch ArgoCD automatically sync:

```bash
# In your jgavairo-app repo
sed -i 's/v1/v2/g' app/deployment.yaml
git add . && git commit -m "upgrade to v2" && git push

# Check the update
curl http://localhost:9999  # (with port-forward: kubectl port-forward svc/jgavairo-app-service -n dev 9999:80)
```
