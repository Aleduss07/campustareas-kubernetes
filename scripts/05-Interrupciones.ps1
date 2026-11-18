param([switch]$RestaurarNodo)
. "$PSScriptRoot/Comun.ps1"
if ($RestaurarNodo) {
    K uncordon campus-worker
} else {
    K delete hpa campus-api --ignore-not-found
    K scale deployment/campus-api --replicas=3
    K rollout status deployment/campus-api --timeout=180s
    K apply -f k8s-retos/06-pdb.yaml
    K drain campus-worker --ignore-daemonsets --timeout=180s
}
K get pdb,pods -o wide
