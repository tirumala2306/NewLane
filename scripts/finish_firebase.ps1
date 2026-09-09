#Requires -Version 5.1
<#
.SYNOPSIS
  Finish FlutterFire after you complete browser login.

.EXAMPLE
  .\scripts\finish_firebase.ps1 -AuthCode "1/xxxx" -ProjectId "newlane-app"
#>
param(
  [Parameter(Mandatory = $true)][string]$AuthCode,
  [Parameter(Mandatory = $true)][string]$ProjectId
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$ProjectId = $ProjectId.Trim().ToLowerInvariant()

Write-Host "Completing firebase login..."
firebase login $AuthCode
if ($LASTEXITCODE -ne 0) { throw 'firebase login with code failed' }

$firebaseRc = @{ projects = @{ default = $ProjectId } } | ConvertTo-Json
Set-Content -Path (Join-Path $Root '.firebaserc') -Value $firebaseRc -Encoding UTF8

$flutterfire = Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin\flutterfire.bat'
if (-not (Test-Path $flutterfire)) { $flutterfire = 'flutterfire' }

Write-Host "Running flutterfire configure for $ProjectId ..."
& $flutterfire configure `
  --project=$ProjectId `
  --platforms=android,ios `
  --android-package-name=com.marsbluellc.newlane `
  --ios-bundle-id=com.marsbluellc.newlane `
  --yes
if ($LASTEXITCODE -ne 0) { throw 'flutterfire configure failed' }

Write-Host 'Deploying Firestore rules + indexes...'
firebase deploy --only firestore --project $ProjectId

Write-Host ''
Write-Host 'Flutter side done. Next on VPS:' -ForegroundColor Green
Write-Host '  1. Download service account JSON → config/firebase-service-account.json'
Write-Host '  2. Copy backend-chat modules + bash install_on_vps.sh'
Write-Host '  3. curl POST /api/chat/seed-demo'
Write-Host '  4. flutter run — expect [FIREBASE] ready'
