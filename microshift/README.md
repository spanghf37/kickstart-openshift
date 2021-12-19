Pré-configuration pour pull image sur RH registries :

Editer /etc/containers/policy.json pour :
~~~
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports": {
        "docker-daemon": {
            "": [
                {
                    "type": "insecureAcceptAnything"
                }
            ]
        }
    }
}
~~~

Télécharger pull-secret de Red Hat dans "/root/pull-secret.json" 

Editer /etc/crio/crio.conf et préciser le global pull-secret dans la section [crio.image] du fichier :
~~~
[crio.image]
global_auth_file = "/root/pull-secret.json"
~~~

Web console :
~~~
oc create serviceaccount console -n kube-system
oc create clusterrolebinding console --clusterrole=cluster-admin --serviceaccount=kube-system:console -n kube-system
sa=\$(oc get serviceaccount console --namespace=kube-system -o jsonpath='{.imagePullSecrets[0].name}' -n kube-system)
tokenname=\$(oc get secret \$sa -n kube-system -o jsonpath='{.metadata.ownerReferences[0].name}')
sed -i "s/name: .* # console serviceaccount token/name: \$tokenname # console serviceaccount token/" 003-console-deployment.yaml
~~~

curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.19.1/install.sh | bash -s v0.19.1

Mirror registry:

podman run -d --restart=always -p 5000:5000 --name registry -v /home/user/Téléchargements/skopeo-sync/registry:/var/lib/registry:z registry
skopeo sync --dest-tls-verify=false --authfile pull-secret.json --all --src yaml --dest docker images-sync.yaml localhost:5000



JETSON NANO Microshift :

https://community.ibm.com/community/user/publiccloud/blogs/alexei-karve/2021/11/23/microshift-2
https://community.ibm.com/community/user/publiccloud/blogs/alexei-karve/2021/11/23/microshift-3

URL image console quay pour ARM64:
https://mirror.openshift.com/pub/openshift-v4/aarch64/clients/ocp/latest-4.9/release.txt


NFD :
kubectl apply -k https://github.com/kubernetes-sigs/node-feature-discovery/deployment/overlays/default?ref=v0.9.0
et editer image pour pointer vers ARM64: image: docker.io/raspbernetes/node-feature-discovery:v0.9.0

