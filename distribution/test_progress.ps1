$ErrorActionPreference='Stop'
function Ok($message) { Write-Host $message }
$tokens=$null;$errors=$null
$ast=[System.Management.Automation.Language.Parser]::ParseFile((Join-Path (Split-Path $PSScriptRoot -Parent) 'setup.ps1'),[ref]$tokens,[ref]$errors)
$fn=$ast.Find({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Invoke-WithProgress'},$true)
. ([scriptblock]::Create($fn.Extent.Text))
if (-not (Invoke-WithProgress 'Expected success' 'powershell.exe' @('-NoProfile','-Command','exit 0'))) { throw 'Exit 0 reported as failed' }
if (Invoke-WithProgress 'Expected failure' 'powershell.exe' @('-NoProfile','-Command','exit 7')) { throw 'Exit 7 reported as success' }
