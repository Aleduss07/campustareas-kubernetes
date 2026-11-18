. "$PSScriptRoot/Comun.ps1"
K apply -n kube-system -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.1/components.yaml
$configuracion = @(
    @{ op = 'add'; path = '/spec/template/spec/containers/0/args/-'; value = '--kubelet-insecure-tls' },
    @{ op = 'add'; path = '/spec/template/spec/nodeSelector/kubernetes.io~1hostname'; value = 'campus-worker2' }
)
$archivo = Join-Path ([IO.Path]::GetTempPath()) (([Guid]::NewGuid().ToString('N')) + '.json')
try {
    [IO.File]::WriteAllText($archivo, (ConvertTo-Json -InputObject $configuracion -Depth 5))
    & kubectl --context kind-campus -n kube-system patch deployment metrics-server --type=json --patch-file $archivo
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo configurar metrics-server.' }
} finally { Remove-Item -LiteralPath $archivo -Force }
& kubectl --context kind-campus -n kube-system rollout status deployment/metrics-server --timeout=180s
K top pods
