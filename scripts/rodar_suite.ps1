$ErrorActionPreference = "Stop"
$flutterBin = Join-Path $env:USERPROFILE "develop\flutter\bin"
$env:Path = "$flutterBin;" + $env:Path
if (Test-Path (Join-Path $env:USERPROFILE "develop\pub-cache")) {
  $env:PUB_CACHE = Join-Path $env:USERPROFILE "develop\pub-cache"
}
Set-Location (Split-Path -Parent $PSScriptRoot)

Write-Host "==> flutter test (domínio + repositório + widgets + E2E)"
& (Join-Path $flutterBin "flutter.bat") test --no-pub --concurrency=1 --timeout 60s
exit $LASTEXITCODE
