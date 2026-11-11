function Update-EgoPath {
    # Keep process-local entries (Python/Node setup may have just added them).
    $env:Path = (@($env:Path, [Environment]::GetEnvironmentVariable('Path','User'), [Environment]::GetEnvironmentVariable('Path','Machine')) -join ';')
}

function Test-HuaxinEgo {
    Update-EgoPath
    $command = Get-Command ego-browser -ErrorAction SilentlyContinue
    if (-not $command) { return $false }
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $probe = (& $command.Source nodejs -e "console.log('HXWD_EGO_READY')" 2>&1 | Out-String)
        $code = $LASTEXITCODE
        return ($code -eq 0 -and $probe.Contains('HXWD_EGO_READY'))
    } finally { $ErrorActionPreference = $previous }
}

function Install-HuaxinEgo([switch]$NonInteractive) {
    if (-not [Environment]::Is64BitOperatingSystem -or $env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') { throw '当前安装包针对 Windows x64；此系统架构尚未验收。' }
    if (Test-HuaxinEgo) { Write-Host 'EgoLite 已就绪，复用现有安装。'; return }
    $registered = @(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match '(?i)ego[\s_-]*(?:\(\s*)?lite' })
    if (Get-Command ego-browser -ErrorAction SilentlyContinue) {
        throw '已找到 ego-browser，但运行检查失败。请打开 EgoLite 检查初始化或连接状态，再重跑安装；不会覆盖或切换浏览器。'
    }
    if ($NonInteractive) { throw 'EgoLite 尚未就绪。请双击安装.cmd 完成官方安装和首次初始化，再重试自动安装。' }
    if ($registered.Count -eq 0) {
        $config = Get-Content (Join-Path $PSScriptRoot 'ego-runtime.json') -Raw | ConvertFrom-Json
        $uri = [Uri]$config.windowsX64Installer
        if ($uri.Scheme -ne 'https' -or $uri.Host -ne 'cdn.ego.app') { throw 'EgoLite 下载地址不在官方来源内。' }
        $cache = Join-Path $env:LOCALAPPDATA 'HuaxinCreatorAssistant\install-cache'
        New-Item $cache -ItemType Directory -Force | Out-Null
        $installer = Join-Path $cache 'egoliteSetup.exe'
        Write-Host '正在下载 EgoLite 官方 Windows 安装包...'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest $uri.AbsoluteUri -OutFile $installer -UseBasicParsing -TimeoutSec 300
        $signature = Get-AuthenticodeSignature $installer
        if ($signature.Status -ne 'Valid') {
            Remove-Item $installer -Force
            throw 'EgoLite 安装包签名未通过验证，已停止执行。请从 https://lite.ego.app/download 获取官方安装包后重试。'
        }
        Write-Host ('安装包签名有效：' + $signature.SignerCertificate.Subject)
        Write-Host ('安装包 SHA-256：' + (Get-FileHash $installer -Algorithm SHA256).Hash)
        Start-Process $installer -Wait
        Remove-Item $installer -Force -ErrorAction SilentlyContinue
    } else { Write-Host '检测到已安装 EgoLite，请打开现有应用完成首次初始化。' }
    Write-Host '请在 EgoLite 中完成首次引导，启用 ego-browser 命令。账号扫码由本人操作。' -ForegroundColor Yellow
    Read-Host '完成后按回车继续检查；若暂时退出，下次可重新运行安装.cmd' | Out-Null
    if (-not (Test-HuaxinEgo)) { throw 'EgoLite 首次初始化尚未完成。请完成引导后重新打开安装.cmd；当前不会显示安装成功。' }
    Write-Host 'EgoLite 初始化与运行检查通过。'
}

function Open-HuaxinEgo {
    if (-not (Test-HuaxinEgo)) { throw 'EgoLite 未就绪，请先打开应用完成初始化，或重跑安装.cmd。' }
    # No shell interpolation inside JavaScript. Only the loopback product URL is opened.
    $script = "const t=await taskSpace('Huaxin Creator Assistant');await t.page('p1').goto('http://127.0.0.1:17860');await t.handOff();"
    & ego-browser nodejs -e $script
    if ($LASTEXITCODE -ne 0) { throw '无法在 EgoLite 打开工作台，请查看上方错误；不会改用其他浏览器。' }
}
