1. Télécharger les charts HELM (www.artifacthub.io) en TGZ et les décompresser dans helm_base

# Génération pour application manuelle `oc apply -f helm-kustomized-all.yaml`
`
helm --namespace $ARGOCD_APP_NAME template ../../helm_base --name-template $ARGOCD_APP_NAME --values ../../helm_base/values-custom.yaml --values values-custom.yaml --include-crds > ../../helm_base/all.yaml && kustomize build > ../../helm-kustomized-all.yaml
`

# Génération pour ArgoCD (éditer CRD ArgoCD dans Openshift Gitops)
`
helm --namespace $ARGOCD_APP_NAME template ../../helm_base --name-template $ARGOCD_APP_NAME --values ../../helm_base/values-custom.yaml --values values-custom.yaml --include-crds > ../../helm_base/all.yaml && kustomize build
`
