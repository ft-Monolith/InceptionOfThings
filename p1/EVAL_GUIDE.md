
<!-- Prerequis : Désactiver KVM (si applicable) -->

sudo modprobe -r kvm_intel
sudo modprobe -r kvm

Puis essayer `vagrant up` à nouveau


<!-- Démarrage du cluster -->

vagrant up


<!-- Phase 2 : SSH sans password -->

vagrant ssh qordouxS
--> Doit se connecter SANS demander de password
exit

vagrant ssh qordouxSW
exit

<!-- Phase 3 : Vérifier les hostnames -->

vagrant ssh qordouxS -c "hostname"
Output: qordouxS

vagrant ssh qordouxSW -c "hostname"
Output: qordouxSW 


<!-- Voir les nœuds -->

vagrant ssh qordouxS -c "sudo kubectl get nodes"

Output attendu :

NAME        STATUS   ROLES           AGE   VERSION
qordouxs    Ready    control-plane   XXm   v1.34.4+k3s1
qordouxsw   Ready    <none>          XXm   v1.34.4+k3s1


<!-- Voir les pods -->

vagrant ssh qordouxS -c "sudo kubectl get pods -A"

Pods attendus :
-  coredns (DNS)
-  traefik (Ingress)
-  local-path-provisioner (Storage)
-  metrics-server (Monitoring)


<!-- 
Concepts à expliquer -->

| Concept | What to say |
|---|---|
| **Vagrantfile** | IaC file qui décrit les VMs (configuration, resources, provisioning) |
| **K3s Server** | Nœud control-plane qui gère le cluster (API, etcd, scheduler) |
| **K3s Agent** | Nœud worker qui exécute les pods |
| **Token** | Secret pour que l'agent rejoigne le server en secure |
| **Synced folder** | Le dossier `confs` est partagé avec les VMs via `/vagrant` |

---

<!-- Arrêter le cluster -->


vagrant halt
Arrête les VMs mais les garde (rapide à relancer)

vagrant destroy -f
Supprime complètement les VMs



