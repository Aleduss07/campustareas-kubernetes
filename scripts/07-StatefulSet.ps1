. "$PSScriptRoot/Comun.ps1"
New-Item -ItemType Directory -Force resultados | Out-Null
$pod = (& kubectl --context kind-campus -n campustareas get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}')
if (!$pod) { throw 'No existe el PostgreSQL inicial para obtener la copia de datos.' }
K exec $pod -- pg_dump -U app -d campus -Fc -f /tmp/campus.dump
K cp "${pod}:/tmp/campus.dump" resultados/campus.dump
K apply -f k8s-retos/09-postgres-stateful.yaml
K rollout status statefulset/postgres --timeout=180s
K cp resultados/campus.dump postgres-0:/tmp/campus.dump
K exec postgres-0 -- pg_restore -U app -d campus --no-owner --clean --if-exists /tmp/campus.dump
K apply -f k8s-retos/10-postgres-service.yaml
K delete deployment postgres
K get statefulsets,pvc,pods -o wide
