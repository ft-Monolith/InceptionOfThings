#!/bin/bash

# Installe Helm (nécessaire pour déployer GitLab)
if command -v helm >/dev/null 2>&1; then
    echo "Helm already installed : $(helm version --short)"
else
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Ajoute l'entrée hosts pour GitLab
HOST_ENTRY="127.0.0.1 gitlab.jgavairo.com"
if ! grep -q "$HOST_ENTRY" /etc/hosts; then
    echo "$HOST_ENTRY" | sudo tee -a /etc/hosts
    echo "Host entry added."
else
    echo "Host entry already exists."
fi
