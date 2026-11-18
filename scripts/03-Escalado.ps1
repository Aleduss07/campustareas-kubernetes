param([switch]$DetenerCarga)
. "$PSScriptRoot/Comun.ps1"
if ($DetenerCarga) {
    K delete -f k8s-escalado/05-carga.yaml --ignore-not-found
} else {
    K apply -f k8s-escalado/04-hpa.yaml
    K apply -f k8s-escalado/05-carga.yaml
}
K get hpa
K top pods
