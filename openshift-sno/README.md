Mise à jour mot de passe kubeadmin :
  https://blog.andyserver.com/2021/07/rotating-the-openshift-kubeadmin-password/
  
  https://play.golang.org/p/D8c4P90x5du
  
  oc patch secret -n kube-system kubeadmin --type json -p '[{"op": "replace", "path": "/data/kubeadmin", "value": "SECRET_DATA"}]'

####
SNO : si pas de LOGS des conteneurs, accepter les CSR:
~~~
oc get csr -o name | xargs oc adm certificate approve
~~~

####
Après installation :
- création local registry sur noeud via MachineConfig. Copier préalablement image registry sur le noeud Master SNO dans /var/tmp.

~~~
podman image save b8604a3fe854 -o docker.io_library_registry_2.7.1.tar docker.io/library/registry:2.7.1
scp -r -p docker.io_library_registry_2.7.1.tar core@master.manager.colbert.def:/var/tmp
~~~

- TO DO :
  - PKI (https://computingforgeeks.com/how-to-install-and-configure-freeipa-server-on-rhel-centos-8/)
  - cert TLS pour local registry
  - ajout cert CA à openshift SNO
  - imagecontentsourcepolicy sur ce registry

- copier images mirror Openshift sur ce registry + images longhorn + ?
