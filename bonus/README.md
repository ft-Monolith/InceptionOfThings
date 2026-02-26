# Bonus: GitLab + ArgoCD

Local GitLab instance connected to ArgoCD for GitOps-based deployments.

## Prerequisites
- Docker installed

## Install
```bash
cd bonus/
sudo bash scripts/install.sh
```
Installs: kubectl, k3d, helm, GitLab, ArgoCD. Creates namespaces: `gitlab`, `argocd`, `dev`.

Credentials at the end of the script:
- **GitLab** : http://localhost:8081 — user: `root` / pass: `GITLAB_ROOT_PASSWORD` from `confs/config.env`
- **ArgoCD** : https://localhost:8080 — user: `admin` / pass: displayed in terminal output

## Cleanup
```bash
sudo bash scripts/clean.sh
```

---

## Demo (soutenance)

### 1. Create the GitLab project
- Go to http://localhost:8081, login as `root` (pass: see `confs/config.env`)
- `New project` → `Create blank project`
- Name: `jgavairo-app`, Visibility: **Public**, uncheck "Initialize with README" → `Create project`

### 2. Push the deployment config
```bash
cd /tmp
git clone http://root:jgavairo42@localhost:8081/root/jgavairo-app.git
cd jgavairo-app && mkdir app
cp /home/iotbonus/Documents/iot/iot/bonus/confs/deployment.yaml app/
git config user.email "root@localhost" && git config user.name "root"
git add . && git commit -m "v1" && git push
```

### 3. Sync ArgoCD
On https://localhost:8080 → click the app **jgavairo-app** → **Refresh** → **Sync**

Or wait ~3 min for automatic sync.

```bash
sudo kubectl get applications -n argocd   # → Synced / Healthy
sudo kubectl get pods -n dev              # → jgavairo-app Running
```

### 4. Test the app
```bash
curl http://localhost:8888
# {"status":"ok", "message": "v1"}
```

### 5. Update v1 → v2
```bash
cd /tmp/jgavairo-app
sed -i 's/playground:v1/playground:v2/g' app/deployment.yaml
git add . && git commit -m "v2" && git push
```
On ArgoCD UI → **Refresh** → **Sync**, then:
```bash
curl http://localhost:8888
# {"status":"ok", "message": "v2"}
```
