1. Télécharger les charts HELM (www.artifacthub.io) en TGZ et les décompresser dans helm_base

`
helm --namespace $ARGOCD_APP_NAME template ../../helm_base --name-template $ARGOCD_APP_NAME --include-crds > ../../helm_base/all.yml && kustomize build
`

