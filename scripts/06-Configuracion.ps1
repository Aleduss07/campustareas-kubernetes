. "$PSScriptRoot/Comun.ps1"
K apply -f k8s-retos/07-configmap.yaml
K rollout restart deployment/campus-api
K rollout status deployment/campus-api --timeout=180s
K exec deployment/campus-api -- printenv DB_POOL_MAX
