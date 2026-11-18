. "$PSScriptRoot/Comun.ps1"
K apply -n ingress-system -f k8s-retos/11-ingress-controller.yaml
& kubectl --context kind-campus -n ingress-system rollout status deployment/campus-ingress --timeout=180s
if ($LASTEXITCODE -ne 0) { throw 'El controlador Ingress no esta disponible.' }
K apply -f k8s-retos/12-ingress.yaml
$tipo = & kubectl --context kind-campus -n campustareas get service campus-api -o jsonpath='{.spec.type}'
if ($tipo -eq 'NodePort') {
    Parche service campus-api @(@{op='remove';path='/spec/ports/0/nodePort'},@{op='replace';path='/spec/type';value='ClusterIP'})
}
& curl.exe --resolve campustareas.localhost:80:127.0.0.1 http://campustareas.localhost/v1/info
Write-Output 'Cliente web e Ingress: http://campustareas.localhost'
