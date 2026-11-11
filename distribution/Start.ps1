$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Ego.ps1')
$env:EASEL_BROWSER_PROVIDER = 'egolite'
$AppDir = Join-Path $env:LOCALAPPDATA 'HuaxinCreatorAssistant\app'
$Python = Join-Path $AppDir '.venv\Scripts\python.exe'
$Base = 'http://127.0.0.1:17860'
function Ready {
    try { return ((Invoke-RestMethod ($Base + '/api/hxwd/version') -TimeoutSec 2).product -eq 'hxwd-creator-assistant') } catch { return $false }
}
try {
    if (-not (Test-HuaxinEgo)) { throw 'EgoLite 未就绪，请重跑安装.cmd 完成初始化。' }
    if (-not (Test-Path $Python)) { throw '尚未安装，请先运行安装.cmd。' }
    if (Ready) { Open-HuaxinEgo; exit 0 }
    if (Get-NetTCPConnection -LocalPort 17860 -State Listen -ErrorAction SilentlyContinue) { throw '17860 端口被其他程序占用，请运行诊断；不要结束未知进程。' }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $AppDir 'scripts\gateway.ps1') start
    if ($LASTEXITCODE -ne 0) { throw 'Agent 启动失败，请运行诊断.cmd。' }
    $logs = Join-Path $env:LOCALAPPDATA 'HuaxinCreatorAssistant\logs'
    New-Item $logs -ItemType Directory -Force | Out-Null
    $env:PYTHONUTF8='1'
    $process = Start-Process $Python -ArgumentList @('-m','easel','web','--port','17860') -WorkingDirectory $AppDir -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $logs 'web.log') -RedirectStandardError (Join-Path $logs 'web-error.log')
    for ($i=0; $i -lt 60; $i++) {
        if (Ready) { Open-HuaxinEgo; exit 0 }
        if ($process.HasExited) { throw '本机服务启动失败，请运行诊断.cmd。' }
        Start-Sleep -Seconds 1
    }
    throw '启动超时，请运行诊断.cmd 查看环境状态。'
} catch { Write-Host $_.Exception.Message -ForegroundColor Red; exit 1 }
