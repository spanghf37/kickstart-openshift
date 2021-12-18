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
