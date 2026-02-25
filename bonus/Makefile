.PHONY: all install gitlab describe migrate clean

# Étape 1 : Installe Helm + config hosts
install:
	bash scripts/install.sh

# Étape 2 : Installe GitLab dans le cluster
all:
	bash scripts/config_gitlab.sh

# Surveille les pods GitLab
describe:
	sudo watch kubectl get pods -n gitlab

# Étape 3 : Accède à GitLab (port-forward)
gitlab:
	bash scripts/access_gitlab.sh

# Étape 4 : Déploie l'app ArgoCD (après avoir push dans GitLab)
migrate:
	sudo kubectl apply -f confs/argocd/app.yaml

# Nettoyage
clean:
	bash scripts/clean.sh
