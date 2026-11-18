. "$PSScriptRoot/Comun.ps1"
Kind create cluster --config kind-config.yaml --wait 180s
Docker build -t campus-api:1.0.0 ./api
Docker build -t campus-api:1.1.0 --build-arg APP_VERSION=1.1.0 ./api
Kind load docker-image campus-api:1.0.0 campus-api:1.1.0 --name campus
K apply -f k8s/00-namespace.yaml -f k8s/01-secret.yaml -f k8s/02-postgres.yaml
K rollout status deployment/postgres --timeout=180s
K apply -f k8s/03-api.yaml
K rollout status deployment/campus-api --timeout=180s
K get nodes
K get pvc,pods,services -o wide
