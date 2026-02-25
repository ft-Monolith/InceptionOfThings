#!/bin/bash

# Script d'installation pour la VM hôte - Part 1 IoT Project
# Ce script installe tout ce dont vous avez besoin pour lancer le projet

set -e  # Arrêter en cas d'erreur

echo "=========================================="
echo "Installation des prérequis pour IoT Part 1"
echo "=========================================="

# Mise à jour du système
echo "[1/5] Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

# Outils de base
if ! command -v curl &> /dev/null; then
    echo "  - Installation de curl..."
    sudo apt install -y curl
fi

# Installation de VirtualBox
echo "[2/5] Installation de VirtualBox..."
if ! command -v VBoxManage &> /dev/null; then
    echo "  - Installation de gnupg..."
    sudo apt install -y gnupg wget lsb-release
    
    echo "  - Ajout de la clé GPG Oracle VirtualBox..."
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo gpg --dearmor -o /usr/share/keyrings/virtualbox-archive-keyring.gpg
    
    echo "  - Ajout du dépôt VirtualBox..."
    echo "deb [signed-by=/usr/share/keyrings/virtualbox-archive-keyring.gpg arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    
    echo "  - Nettoyage et rafraîchissement des dépôts..."
    sudo rm -rf /var/lib/apt/lists/*
    sudo apt clean
    sudo apt update
    
    echo "  - Installation des headers Linux..."
    KERNEL_VERSION=$(uname -r)
    sudo apt install -y linux-headers-amd64 linux-headers-${KERNEL_VERSION} || sudo apt install -y linux-headers-$(uname -r)
    
    echo "  - Installation de VirtualBox 7.2..."
    sudo apt install -y virtualbox-7.2
    
    echo "✓ VirtualBox installé"
else
    echo "✓ VirtualBox déjà installé"
fi

# Ajout de l'utilisateur au groupe vboxusers
echo "[3/5] Configuration des permissions..."
sudo usermod -aG vboxusers $USER
echo "✓ Utilisateur ajouté au groupe vboxusers"

# Installation de Vagrant
echo "[4/5] Installation de Vagrant..."
if ! command -v vagrant &> /dev/null; then
    echo "  - Ajout de la clé GPG HashiCorp..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    
    echo "  - Ajout du dépôt HashiCorp..."
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    
    echo "  - Installation de Vagrant..."
    sudo apt update
    sudo apt install -y vagrant
    echo "✓ Vagrant installé"
else
    echo "✓ Vagrant déjà installé"
fi

# Installation de kubectl
echo "[5/5] Installation de kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "✓ kubectl installé"
else
    echo "✓ kubectl déjà installé"
fi

# Gestion du conflit KVM/VirtualBox
echo ""
echo "=========================================="
echo "Configuration du conflit KVM/VirtualBox"
echo "=========================================="

if lsmod | grep -q kvm; then
    echo "⚠ KVM détecté sur votre système"
    echo "VirtualBox et KVM ne peuvent pas fonctionner ensemble"
    echo ""
    echo "Déchargement des modules KVM..."
    sudo modprobe -r kvm_intel 2>/dev/null || true
    sudo modprobe -r kvm 2>/dev/null || true
    echo "✓ Modules KVM déchargés"
    
    # Ajouter l'alias s'il n'existe pas déjà
    if ! grep -q "alias vagrant=" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Alias pour décharger KVM avant vagrant" >> ~/.bashrc
        echo "alias vagrant='sudo modprobe -r kvm_intel kvm 2>/dev/null; /usr/bin/vagrant'" >> ~/.bashrc
        echo "✓ Alias ajouté à ~/.bashrc"
        echo ""
        echo "⚠ IMPORTANT: Exécutez 'source ~/.bashrc' ou ouvrez un nouveau terminal"
    else
        echo "✓ Alias déjà configuré"
    fi
else
    echo "✓ Pas de conflit KVM détecté"
fi

echo ""
echo "=========================================="
echo "Installation terminée !"
echo "=========================================="
echo ""
echo "Versions installées:"
VBoxManage --version | head -1
vagrant --version
kubectl version --client --short 2>/dev/null || kubectl version --client

echo ""
echo "Prochaines étapes:"
echo "1. Si KVM était actif: source ~/.bashrc"
echo "2. cd /home/iot/Documents/IOT/IOT/p1"
echo "3. vagrant up"
echo "4. Attendre que les 2 VMs démarrent et s'installent"
echo "5. Vérifier avec: vagrant ssh qordouxS -c 'sudo kubectl get nodes'"