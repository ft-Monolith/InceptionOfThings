# Part 1: K3s and Vagrant

This directory contains the configuration for Part 1 of the IoT project.

---

# ⚠️ **IMPORTANT - CONFLIT KVM / VIRTUALBOX** ⚠️

## 🔴 **PROBLÈME**
VirtualBox et KVM ne peuvent **PAS** fonctionner en même temps car ils utilisent tous les deux VT-x (virtualisation matérielle).

**Erreur typique :**
```
VBoxManage: error: VT-x is being used by another hypervisor (VERR_VMX_IN_VMX_ROOT_MODE).
VBoxManage: error: VirtualBox can't operate in VMX root mode.
```

## ✅ **SOLUTION AUTOMATIQUE**

Un **alias a été créé** dans votre `~/.bashrc` qui décharge automatiquement KVM avant chaque commande vagrant :

```bash
alias vagrant='sudo modprobe -r kvm_intel kvm 2>/dev/null; /usr/bin/vagrant'
```

### 📝 **Ce que fait cet alias :**
1. **Décharge les modules KVM** (`kvm_intel` et `kvm`) pour libérer VT-x
2. **Lance ensuite la vraie commande vagrant** avec tous vos arguments
3. **Ignore les erreurs** si KVM n'est pas chargé (2>/dev/null)

### 🚀 **Utilisation :**
Utilisez simplement `vagrant` comme d'habitude :
```bash
vagrant up
vagrant ssh qordouxS
vagrant halt
```

L'alias s'occupe automatiquement de désactiver KVM !

### ⚙️ **Pour activer l'alias dans votre session actuelle :**
```bash
source ~/.bashrc
```

---

## Structure
- `Vagrantfile`: Configuration for 2 VMs (Server and Worker)
- `scripts/install_k3s_server.sh`: K3s installation script for controller node
- `scripts/install_k3s_worker.sh`: K3s installation script for agent node

## Requirements
- VirtualBox
- Vagrant
- At least 2 GB RAM available
- At least 10 GB disk space

## Usage

1. Start the virtual machines:
```bash
cd p1
vagrant up
```

2. Check the cluster status:
```bash
vagrant ssh qordouxS -c "sudo kubectl get nodes"
```

3. Access the server:
```bash
vagrant ssh qordouxS
```

4. Access the worker:
```bash
vagrant ssh qordouxSW
```

5. Stop the VMs:
```bash
vagrant halt
```

6. Destroy the VMs:
```bash
vagrant destroy -f
```

## Network Configuration
- Server (qordouxS): 192.168.56.110
- Worker (qordouxSW): 192.168.56.111

## Notes
- K3s is installed automatically during provisioning
- The server runs in controller mode
- The worker runs in agent mode
- kubectl is installed on the server node
