$ErrorActionPreference='Stop'
function Ok($message) { Write-Host $message }
$tokens=$null;$errors=$null
$ast=[System.Management.Automation.Language.Parser]::ParseFile((Join-Path (Split-Path $PSScriptRoot -Parent) 'setup.ps1'),[ref]$tokens,[ref]$errors)
$fn=$ast.Find({param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Invoke-WithProgress'},$true)
. ([scriptblock]::Create($fn.Extent.Text))
if (-not (Invoke-WithProgress 'Expected success' 'powershell.exe' @('-NoProfile','-Command','exit 0'))) { throw 'Exit 0 reported as failed' }
if (Invoke-WithProgress 'Expected failure' 'powershell.exe' @('-NoProfile','-Command','exit 7')) { throw 'Exit 7 reported as success' }

# Execute the actual gateway JSON assignment in PS 5.1. Wrapping pipeline
# ConvertFrom-Json in @() creates a nested array here and breaks Count/indexing.
$gateway = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/gateway.ps1'
$errors=$null; $tokens=$null
$ast=[System.Management.Automation.Language.Parser]::ParseFile($gateway,[ref]$tokens,[ref]$errors)
$assignment=$ast.Find({ param($node) $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and $node.Left.Extent.Text -eq '$cli' },$true)
if (-not $assignment) { throw 'Gateway command assignment missing' }
$resolved='["C:\\Program Files\\nodejs\\node.exe", "C:\\npm\\prefix\\node_modules\\openclaw\\openclaw.mjs"]'
Invoke-Expression $assignment.Extent.Text
if ($cli.Count -ne 2 -or $cli[0] -isnot [string] -or $cli[1] -isnot [string]) { throw 'Gateway CLI JSON array nesting regression' }
Write-Host 'Gateway native argv JSON parsing passed.'
