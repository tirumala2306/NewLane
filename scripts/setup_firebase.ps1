#Requires -Version 5.1
<#
.SYNOPSIS
  Firebase Console checklist + FlutterFire configure for New Lane.

.DESCRIPTION
  1) Create project in browser (if needed)
  2) firebase login
  3) flutterfire configure for Android + iOS
  4) deploy Firestore rules + indexes
#>

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host ''
Write-Host '=== NEW LANE FIREBASE SETUP ===' -ForegroundColor Cyan
Write-Host ''
Write-Host 'PHASE A — Firebase Console (browser)' -ForegroundColor Yellow
Write-Host '  1. Open https://console.firebase.google.com'
Write-Host '  2. Add project  (suggested id: newlane-app)'
Write-Host '  3. Build > Firestore Database > Create database > Start in test mode'
Write-Host '  4. Copy the Project ID'
Write-Host ''

$projectId = Read-Host 'Enter Firebase Project ID (exact)'
if ([string]::IsNullOrWhiteSpace($projectId)) {
  throw 'Project ID is required'
}
$projectId = $projectId.Trim().ToLowerInvariant()

$firebaseRc = @{ projects = @{ default = $projectId } } | ConvertTo-Json
Set-Content -Path (Join-Path $Root '.firebaserc') -Value $firebaseRc -Encoding UTF8
Write-Host "Wrote .firebaserc default -> $projectId"

Write-Host ''
Write-Host 'PHASE B — CLI login + FlutterFire' -ForegroundColor Yellow
firebase login
if ($LASTEXITCODE -ne 0) { throw 'firebase login failed' }

$flutterfire = Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin\flutterfire.bat'
if (-not (Test-Path $flutterfire)) {
  $flutterfire = 'flutterfire'
}

& $flutterfire configure `
  --project=$projectId `
  --platforms=android,ios `
  --android-package-name=com.marsbluellc.newlane `
  --ios-bundle-id=com.marsbluellc.newlane `
  --yes

if ($LASTEXITCODE -ne 0) { throw 'flutterfire configure failed' }

Write-Host ''
Write-Host 'PHASE C — Deploy Firestore rules + composite index' -ForegroundColor Yellow
firebase deploy --only firestore --project $projectId
if ($LASTEXITCODE -ne 0) {
  Write-Host 'Deploy failed — you can retry: firebase deploy --only firestore' -ForegroundColor Red
}

Write-Host ''
Write-Host 'Done. Rebuild the Flutter app. Look for: [FIREBASE] ready' -ForegroundColor Green
Write-Host 'Next: copy backend-chat/ to the VPS and run backend-chat/install_on_vps.sh'
Write-Host ''
