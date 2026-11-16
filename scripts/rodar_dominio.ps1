$ErrorActionPreference = "Stop"
$flutterBin = Join-Path $env:USERPROFILE "develop\flutter\bin"
$env:Path = "$flutterBin;" + $env:Path

Set-Location (Split-Path -Parent $PSScriptRoot)
& (Join-Path $flutterBin "flutter.bat") test test/dominio
exit $LASTEXITCODE
