#!/bin/bash

# Installation de K3s en mode serveur sans agent (car c'est une machine seule)
# On force l'IP du noeud pour éviter les problèmes de détection
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip 192.168.56.110 --write-kubeconfig-mode 644" sh -

# Attendre que le noeud soit prêt (optionnel mais propre)
echo "K3s est installé. En attente du démarrage..."
sleep 20