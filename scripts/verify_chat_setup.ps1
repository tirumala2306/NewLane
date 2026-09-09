#Requires -Version 5.1
<#
.SYNOPSIS
  Verifies Firebase + chat setup readiness for New Lane.
#>

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$failed = @()

function Ok($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Bad($msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red; $script:failed += $msg }

# 1) Project files
@(
  'firebase.json',
  'firestore.rules',
  'firestore.indexes.json',
  'lib/firebase_options.dart',
  'backend-chat/config/firebase.js',
  'backend-chat/controllers/chatController.js',
  'backend-chat/routes/chatRoutes.js',
  'backend-chat/scripts/seed_demo.js',
  'backend-chat/install_on_vps.sh'
) | ForEach-Object {
  if (Test-Path (Join-Path $Root $_)) { Ok $_ } else { Bad "missing $_" }
}

# 2) firebase_options not placeholder
$opts = Get-Content (Join-Path $Root 'lib/firebase_options.dart') -Raw
if ($opts -match "apiKey: 'REPLACE_ME'") {
  Bad 'lib/firebase_options.dart still has REPLACE_ME — run scripts/setup_firebase.ps1'
} else {
  Ok 'firebase_options.dart has real keys'
}

# 3) Firebase CLI auth
firebase projects:list 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) { Ok 'firebase CLI authenticated' }
else { Bad 'firebase CLI not logged in — firebase login' }

# 4) Service account for seed (optional locally)
$key = Join-Path $Root 'backend-chat/config/firebase-service-account.json'
if (Test-Path $key) { Ok 'service account present for seed' }
else { Write-Host '[SKIP] no local service account (ok if seeding only on VPS)' -ForegroundColor Yellow }

Write-Host ''
if ($failed.Count -eq 0) {
  Write-Host 'VERIFY PASS — rebuild app and look for [FIREBASE] ready' -ForegroundColor Green
  exit 0
} else {
  Write-Host "VERIFY FAIL ($($failed.Count))" -ForegroundColor Red
  $failed | ForEach-Object { Write-Host " - $_" }
  exit 1
}
