. "$PSScriptRoot/Comun.ps1"
Docker build -t campus-web:1.0.0 ./web
Kind load docker-image campus-web:1.0.0 --name campus
K apply -f k8s-retos/08-web.yaml
K rollout status deployment/campus-web --timeout=180s
Write-Output 'Cliente web: http://localhost:8081'
