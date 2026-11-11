$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Ego.ps1')
# Existing usable browser must not download or open an installer.
function Test-HuaxinEgo { return $true }
function Invoke-WebRequest { throw 'Unexpected download' }
function Start-Process { throw 'Unexpected process launch' }
Install-HuaxinEgo -NonInteractive
# Headless install cannot pretend GUI onboarding succeeded.
function Test-HuaxinEgo { return $false }
$failed = $false
try { Install-HuaxinEgo -NonInteractive } catch { $failed = $true }
if (-not $failed) { throw 'Accepted missing Ego in noninteractive installation' }
$failed = $false
try { Open-HuaxinEgo } catch { $failed = $true }
if (-not $failed) { throw 'Opened fallback browser with missing Ego' }
Write-Host 'Ego reuse / missing onboarding / no fallback checks passed.'
