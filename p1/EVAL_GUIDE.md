# 📋 Part 1 - Quick Eval Guide

## 🚀 Démarrage du cluster

```bash
cd ~/IOT/p1
vagrant up
```
**⏱️ Attendre 5-7 minutes que K3s s'installe**

---

## ✅ Phase 1 : Vérifier la structure

```bash
ls -la
# Doit voir : Vagrantfile, scripts/, confs/
```

---

## ✅ Phase 2 : SSH sans password

```bash
vagrant ssh qordouxS
# Doit se connecter SANS demander de password
exit

vagrant ssh qordouxSW
# Idem
exit
```

---

## ✅ Phase 3 : Vérifier les hostnames

```bash
vagrant ssh qordouxS -c "hostname"
# Output: qordouxS ✅

vagrant ssh qordouxSW -c "hostname"
# Output: qordouxSW ✅
```

---

## ✅ Phase 4 : Vérifier les IPs

```bash
vagrant ssh qordouxS -c "ip a show eth1 | grep 'inet '"
# Output: inet 192.168.56.110/24 ✅

vagrant ssh qordouxSW -c "ip a show eth1 | grep 'inet '"
# Output: inet 192.168.56.111/24 ✅
```

---

## ✅ Phase 5 : Vérifier Kubernetes

### Voir les nœuds

```bash
vagrant ssh qordouxS -c "sudo kubectl get nodes"
```

**Output attendu :**
```
NAME        STATUS   ROLES           AGE   VERSION
qordouxs    Ready    control-plane   XXm   v1.34.4+k3s1
qordouxsw   Ready    <none>          XXm   v1.34.4+k3s1
```

### Voir les pods système

```bash
vagrant ssh qordouxS -c "sudo kubectl get pods -A"
```

**Pods à voir :**
- ✅ coredns (DNS)
- ✅ traefik (Ingress)
- ✅ local-path-provisioner (Storage)
- ✅ metrics-server (Monitoring)

### Voir les services

```bash
vagrant ssh qordouxS -c "sudo kubectl get svc -A"
```

### Vérifier la santé du cluster

```bash
vagrant ssh qordouxS -c "sudo kubectl cluster-info"
```

---

## 🎯 Concepts à expliquer

| Concept | What to say |
|---|---|
| **Vagrantfile** | IaC file qui décrit les VMs (configuration, resources, provisioning) |
| **K3s Server** | Nœud control-plane qui gère le cluster (API, etcd, scheduler) |
| **K3s Agent** | Nœud worker qui exécute les pods |
| **Token** | Secret pour que l'agent rejoigne le server en secure |
| **Flannel** | Plugin réseau pour la communication entre nœuds |
| **Traefik** | Ingress controller inclus dans K3s |
| **Synced folder** | Le dossier `confs` est partagé avec les VMs via `/vagrant` |

---

## 🛑 Arrêter le cluster

```bash
vagrant halt
# Arrête les VMs mais les garde (rapide à relancer)

vagrant destroy -f
# Supprime complètement les VMs
```

---

## ⚠️ Pièges à éviter

| Problème | Solution |
|---|---|
| VMs ne boot (KVM error) | Décharger KVM : `sudo modprobe -r kvm_intel kvm` |
| SSH demande password | Le Vagrantfile doit générer les clés SSH (déjà fait) |
| Worker ne rejoint pas cluster | Vérifier `confs/config.env` (SERVER_IP, WORKER_IP) |
| Pods en erreur | `sudo kubectl logs <pod> -n <namespace>` |
| Traefik ne voit pas les apps | Vérifier les Ingress avec `sudo kubectl get ingress -A` |

---

## 📸 Screenshots à montrer

```bash
# 1. Les 2 nœuds prêts
vagrant ssh qordouxS -c "sudo kubectl get nodes"

# 2. Les pods système running
vagrant ssh qordouxS -c "sudo kubectl get pods -A"

# 3. Les IPs correctes
vagrant ssh qordouxS -c "ip a show eth1"
vagrant ssh qordouxSW -c "ip a show eth1"

# 4. SSH sans password
vagrant ssh qordouxS
hostname
exit
```

---

## 💡 Bonus : Commandes utiles

```bash
# Voir les détails d'un nœud
vagrant ssh qordouxS -c "sudo kubectl describe node qordouxs"

# Voir les événements du cluster
vagrant ssh qordouxS -c "sudo kubectl get events -A"

# Voir les déploiements
vagrant ssh qordouxS -c "sudo kubectl get deployments -A"

# Entrer dans un pod
vagrant ssh qordouxS -c "sudo kubectl exec -it <pod> -n <namespace> -- bash"

# Voir les logs d'un pod
vagrant ssh qordouxS -c "sudo kubectl logs <pod> -n <namespace>"

# Voir les volumes persistants
vagrant ssh qordouxS -c "sudo kubectl get pv,pvc -A"
```

---

Generated: 18 février 2026
