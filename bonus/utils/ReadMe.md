Tutoriel : Utilisation de votre Pipeline GitOps (GitLab + ArgoCD)

Ce guide explique comment tester le déploiement automatique de votre application une fois que l'infrastructure a été installée avec install.sh.
1. Récupération des accès

À la fin de l'installation, notez les identifiants affichés dans votre terminal :

    GitLab : http://localhost:8081 (User: root)

    ArgoCD : https://localhost:8080 (User: admin)

2. Configuration initiale de GitLab

    Connectez-vous à GitLab.

    Créez un Nouveau Projet nommé my-app.

    Allez dans Settings > Repository > Deploy Tokens.

    Créez un token nommé argocd avec le droit read_repository. Notez le Username et le Password générés.

3. Connexion d'ArgoCD à GitLab

    Connectez-vous à ArgoCD.

    Allez dans Settings > Repositories > Connect Repo.

    Utilisez l'URL interne (plus stable) :

    http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/my-app.git

    Entrez le Username et le Password du Deploy Token créé à l'étape précédente.

4. Création de l'Application ArgoCD

    Cliquez sur New App :

        App Name : iot-deployment

        Project : default

        Sync Policy : Automatic (Cochez aussi Self-Heal et Create Namespace)

        Repository URL : Sélectionnez celle de votre projet my-app.

        Path : .

        Cluster URL : https://kubernetes.default.svc

        Namespace : dev

    Cliquez sur Create.

5. Le Test du "Push" (Mise en service)

Sur votre terminal, clonez le projet et envoyez votre configuration :
6. Vérification de la preuve (Preuve de concept)

    Dans ArgoCD : L'application doit devenir Verte (Synced).

    Dans le terminal : Vérifiez que le pod est bien lancé.
    ```bash
    kubectl get svc -n dev
    ```
    Faire suivre le port
    ```bash
    kubectl port-forward svc/wil-app-service -n dev 9999:80
    ```

    Test de l'URL (Curl) :
    ```bash
    curl http://localhost:9999
    ```


7. Mise à jour automatique (Bonus démo)

Modifiez le fichier deployment.yaml (ex: changez "Version 1" par "Version 2"), faites un git push et observez ArgoCD mettre à jour le cluster sans aucune intervention manuelle.