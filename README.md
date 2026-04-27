# Inception of Things (IoT) — Kubernetes, Vagrant, K3s, ArgoCD

> Projet d’infrastructure orienté DevOps/GitOps réalisé en plusieurs phases, avec montée en complexité : cluster local, déploiements applicatifs, automatisation continue avec ArgoCD, puis intégration GitLab.

## 🎯 Objectif du projet

Concevoir et automatiser un environnement Kubernetes reproductible, de la création du cluster jusqu’au déploiement continu d’applications, en utilisant :

- **Vagrant + VirtualBox** pour l’Infrastructure as Code locale
- **K3s / K3d** pour Kubernetes léger
- **Manifestes Kubernetes** (Deployment, Service, Ingress)
- **ArgoCD** pour le GitOps
- **GitLab local** (bonus) comme source Git interne

---

## 🧱 Architecture du repository

```text
bonus/
  README.md
  confs/
  scripts/
p1/
  Vagrantfile
  confs/
  scripts/
p2/
  Vagrantfile
  confs/
  scripts/
p3/
  confs/
  scripts/
```

---

## 🚀 Phases du projet

## 1) P1 — Cluster K3s multi-nœuds avec Vagrant

**But :** créer un cluster K3s avec :
- 1 nœud **server/control-plane**
- 1 nœud **worker/agent**

### Ce qui est mis en place
- Provisioning automatique via [p1/Vagrantfile](p1/Vagrantfile)
- Installation de K3s via [p1/scripts/setup.sh](p1/scripts/setup.sh)
- IPs privées configurées via [p1/confs/config.env](p1/confs/config.env)

### Lancer la phase
Depuis le dossier `p1/` :
- `vagrant up`

### Vérifications utiles
- `vagrant ssh qordouxS -c "sudo kubectl get nodes"`
- `vagrant ssh qordouxS -c "sudo kubectl get pods -A"`

---

## 2) P2 — Déploiement de 3 applications via Ingress

**But :** déployer 3 applications Nginx distinctes et les exposer via routage HTTP.

### Ce qui est mis en place
- Cluster K3s mono-VM via [p2/Vagrantfile](p2/Vagrantfile)
- Déploiements + services + ingress dans [p2/confs/apps.yaml](p2/confs/apps.yaml)
- Provisioning automatique dans [p2/scripts/setup.sh](p2/scripts/setup.sh)

### Résultat attendu
- `app1.com` → app1
- `app2.com` → app2
- route par défaut → app3

### Lancer la phase
Depuis `p2/` :
- `vagrant up`

Puis ajouter dans `/etc/hosts` (machine hôte) l’IP serveur vers les domaines de test.

---

## 3) P3 — GitOps avec ArgoCD sur K3d

**But :** automatiser le déploiement applicatif avec ArgoCD depuis un dépôt Git.

### Ce qui est mis en place
- Installation `kubectl` + `k3d` + cluster local via [p3/scripts/install.sh](p3/scripts/install.sh)
- Déploiement d’ArgoCD
- Déclaration d’une application ArgoCD via [p3/confs/application.yaml](p3/confs/application.yaml)

### Lancer la phase
Depuis `p3/` :
- `sudo bash scripts/install.sh`

### Nettoyage
- `sudo bash scripts/clean.sh`

---

## 4) Bonus — GitLab local + ArgoCD

**But :** brancher ArgoCD sur un GitLab auto-hébergé dans le cluster pour une boucle GitOps complète en local.

### Ce qui est mis en place
- Installation GitLab + ArgoCD + Helm + K3d via [bonus/scripts/install.sh](bonus/scripts/install.sh)
- Application ArgoCD pointant vers GitLab local : [bonus/confs/argocd/app.yaml](bonus/confs/argocd/app.yaml)
- Exemple de déploiement applicatif : [bonus/confs/deployment.yaml](bonus/confs/deployment.yaml)

### Lancer la phase
Depuis `bonus/` :
- `sudo bash scripts/install.sh`

### Nettoyage
- `sudo bash scripts/clean.sh`

Le guide de démonstration détaillé est disponible dans [bonus/README.md](bonus/README.md).

---

## 🛠️ Stack technique

- **IaC / Virtualisation :** Vagrant, VirtualBox
- **Container orchestration :** Kubernetes (K3s, K3d)
- **Déploiement :** YAML manifests, Ingress
- **GitOps :** ArgoCD
- **Registry/SCM local :** GitLab (bonus)
- **Scripting :** Bash

---

## ✅ Compétences démontrées

- Automatisation d’environnements Kubernetes reproductibles
- Architecture multi-nœuds et réseau privé de VMs
- Déploiement applicatif Kubernetes (Deployment/Service/Ingress)
- Mise en place d’un workflow GitOps avec synchronisation automatique
- Intégration d’outils DevOps (ArgoCD + GitLab + Helm)
- Scripting shell orienté provisionnement et exploitation

---

## ⚠️ Notes importantes

- Les scripts sont principalement testés sur **Linux**.
- Certains scripts nécessitent les droits `sudo`.
- Le mot de passe GitLab du bonus est défini dans [bonus/confs/config.env](bonus/confs/config.env)
