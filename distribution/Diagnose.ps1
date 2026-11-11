$ErrorActionPreference = 'Stop'
$AppDir = Join-Path $env:LOCALAPPDATA 'HuaxinCreatorAssistant\app'
$Python = Join-Path $AppDir '.venv\Scripts\python.exe'
if (-not (Test-Path $Python)) { Write-Host 'Python 环境尚未安装'; exit 1 }
Set-Location $AppDir
$env:PYTHONUTF8='1'
$failed = $false
& $Python -m easel doctor
if ($LASTEXITCODE -ne 0) { $failed = $true }
& $Python (Join-Path $PSScriptRoot 'verify_runtime.py')
if ($LASTEXITCODE -ne 0) { $failed = $true }
& $Python -m easel ping
if ($LASTEXITCODE -ne 0) { $failed = $true }
if ($failed) { Write-Host '部分功能未就绪，请将脱敏后的错误信息交给管理员。'; exit 1 }
Write-Host '核心环境、浏览器、模型及 Agent 连通检查通过。'; exit 0
