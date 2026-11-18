$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function K {
    & kubectl --context kind-campus -n campustareas @args
    if ($LASTEXITCODE -ne 0) { throw 'Fallo de kubectl; revisar la salida anterior.' }
}
function Kind {
    $bin = Get-Command kind -ErrorAction SilentlyContinue
    if ($bin) { $ruta = $bin.Source } else { $ruta = Join-Path $env:LOCALAPPDATA 'CampusTareas/bin/kind.exe' }
    & $ruta @args
    if ($LASTEXITCODE -ne 0) { throw 'Fallo de kind; revisar la salida anterior.' }
}
function Docker {
    & docker.exe @args
    if ($LASTEXITCODE -ne 0) { throw 'Fallo de Docker; revisar la salida anterior.' }
}
function Parche($Tipo, $Nombre, $Datos) {
    $archivo = Join-Path ([IO.Path]::GetTempPath()) (([Guid]::NewGuid().ToString('N')) + '.json')
    try {
        [IO.File]::WriteAllText($archivo, ($Datos | ConvertTo-Json -Depth 12), (New-Object Text.UTF8Encoding($false)))
        K patch $Tipo $Nombre --type=json --patch-file $archivo
    } finally { if (Test-Path -LiteralPath $archivo) { Remove-Item -LiteralPath $archivo -Force } }
}
