param([string]$ActivationPath = '', [switch]$NoLaunch)
$ErrorActionPreference = 'Stop'
$Source = Split-Path $PSScriptRoot -Parent
$HomeDir = Join-Path $env:LOCALAPPDATA 'HuaxinCreatorAssistant'
$AppDir = Join-Path $HomeDir 'app'
try {
    if (-not $ActivationPath) { $ActivationPath = Join-Path $Source 'activation.json' }
    if (-not (Test-Path $ActivationPath)) { throw '缺少内部激活文件 activation.json。请向舒老师领取，放在安装.cmd 同目录；不要把 API Key 发给 AI 或上传 GitHub。' }
    # Validate before installing dependencies; never print the activation object.
    $activation = Get-Content $ActivationPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($activation.baseUrl -ne 'https://api.apilio.ai/v1' -or $activation.model -ne 'claude-haiku-5-5' -or $activation.apiKey.Length -lt 16 -or $activation.apiKey -match '\s') { throw '内部激活文件无效。' }
    if ((Test-Path (Join-Path $env:USERPROFILE '.openclaw-easel')) -and -not (Test-Path (Join-Path $HomeDir 'installed.json'))) { throw '发现已有 Easel Agent 配置。为保护旧工具，停止安装；请管理员先迁移或备份，不能覆盖。' }
    New-Item $AppDir -ItemType Directory -Force | Out-Null
    if ($Source -ne $AppDir) {
        & robocopy $Source $AppDir /E /NFL /NDL /NJH /NJS /XD .git .github .venv node_modules data outputs profiles /XF .env activation.json | Out-Null
        if ($LASTEXITCODE -ge 8) { throw '复制程序文件失败。' }
        foreach ($name in @('profiles','outputs')) {
            if (-not (Test-Path (Join-Path $AppDir $name))) { Copy-Item (Join-Path $Source $name) (Join-Path $AppDir $name) -Recurse }
        }
    }
    # Protect model config locally; no secret command-line arguments.
    $envFile = Join-Path $AppDir '.env'
    if (Test-Path $envFile) { Copy-Item $envFile ($envFile + '.before-hxwd') -Force }
    $keep = @()
    if (Test-Path $envFile) { $keep = @(Get-Content $envFile -Encoding UTF8 | Where-Object { $_ -notmatch '^(OPENAI_API_KEY|OPENAI_BASE_URL|OPENAI_MODEL|CLAUDE_MODEL|EASEL_CHAT_TRANSPORT)\s*=' }) }
    if ($keep.Count -eq 0) { $keep = @('EASEL_PUBLISH_MODE=automated') }
    $keep += @('OPENAI_BASE_URL=https://api.apilio.ai/v1','OPENAI_MODEL=claude-haiku-5-5','CLAUDE_MODEL=openai/claude-haiku-5-5','EASEL_CHAT_TRANSPORT=http',('OPENAI_API_KEY=' + $activation.apiKey))
    [IO.File]::WriteAllLines($envFile, $keep, (New-Object Text.UTF8Encoding($false)))
    $who = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    & icacls $envFile /inheritance:r /grant:r "${who}:(F)" 'SYSTEM:(F)' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw '无法保护本机调用配置的权限。' }
    # Set marker before upstream initialization, enabling a failed install to be retried.
    Copy-Item (Join-Path $AppDir 'distribution\version.json') (Join-Path $HomeDir 'installed.json') -Force
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $AppDir 'setup.ps1') -OpenClaw -NonInteractive
    if ($LASTEXITCODE -ne 0) { throw '运行环境安装失败；可修复网络后重跑本安装器。' }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $AppDir 'distribution\Diagnose.ps1')
    if ($LASTEXITCODE -ne 0) { throw '环境已安装，但功能检查未全部通过。请先运行诊断.cmd。' }
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) '华新创作助手.lnk'))
    $shortcut.TargetPath = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $shortcut.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $AppDir 'distribution\Start.ps1') + '"'
    $shortcut.WorkingDirectory = $AppDir
    $shortcut.IconLocation = Join-Path $AppDir 'web\static\hxwd-icon.ico'
    $shortcut.Save()
    Write-Host '华新创作助手安装及诊断通过。桌面快捷方式已创建。' -ForegroundColor Green
    if (-not $NoLaunch) { & (Join-Path $AppDir 'distribution\Start.ps1') }
    exit 0
} catch { Write-Host $_.Exception.Message -ForegroundColor Red; exit 1 }
