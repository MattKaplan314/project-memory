[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $ScratchPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$initializer = Join-Path $PSScriptRoot 'Initialize-ProjectMemory.ps1'
$testRoot = Join-Path $ScratchPath ('project-memory-test-' + [Guid]::NewGuid().ToString('N'))
[System.IO.Directory]::CreateDirectory($testRoot) | Out-Null

function Assert-True([bool] $Condition, [string] $Message) {
    if (-not $Condition) { throw $Message }
}

$preview = Join-Path $testRoot 'preview'
& $initializer -Path $preview -WhatIf | Out-Null
Assert-True (-not (Test-Path -LiteralPath $preview)) 'Preview wrote files.'
Write-Output 'PASS: -WhatIf creates no project directory.'

$fresh = Join-Path $testRoot 'game with spaces'
& $initializer -Path $fresh -Name 'Test Game' | Out-Null
$newFiles = @(Get-ChildItem -LiteralPath $fresh -File -Recurse)
Assert-True ($newFiles.Count -eq 8) 'Unexpected scaffold file count.'
$statePath = Join-Path $fresh 'project-memory/STATE.md'
$state = [System.IO.File]::ReadAllText($statePath)
Assert-True ($state.Contains('Test Game')) 'Project name missing.'
Assert-True ($state.Contains('not inspected')) 'Scaffold invents verified project state.'
Assert-True (-not $state.Contains('{{')) 'Template token unresolved.'
foreach ($entry in @('AGENTS.md', 'CLAUDE.md')) {
    $content = [System.IO.File]::ReadAllText((Join-Path $fresh $entry))
    Assert-True ($content.Contains('project-memory/README.md')) "Missing memory entry point: $entry"
}
Write-Output 'PASS: new project with spaces gets eight files and honest initial state.'

[System.IO.File]::AppendAllText($statePath, "`nUser's saved decision: keep the blue world.`n")
$before = @{}
foreach ($file in $newFiles) { $before[$file.FullName] = (Get-FileHash -LiteralPath $file.FullName).Hash }
& $initializer -Path $fresh -Name 'Different Name' | Out-Null
foreach ($file in $newFiles) {
    Assert-True ((Get-FileHash -LiteralPath $file.FullName).Hash -eq $before[$file.FullName]) "Rerun changed $($file.Name)."
}
Write-Output 'PASS: rerun preserves all existing files byte for byte, including edited memory.'

$existing = Join-Path $testRoot 'existing'
[System.IO.Directory]::CreateDirectory($existing) | Out-Null
$existingAgents = Join-Path $existing 'AGENTS.md'
[System.IO.File]::WriteAllText($existingAgents, 'Existing project instructions must survive.')
& $initializer -Path $existing -WarningVariable integrationWarnings -WarningAction SilentlyContinue | Out-Null
Assert-True ([System.IO.File]::ReadAllText($existingAgents) -eq 'Existing project instructions must survive.') 'Existing instructions overwritten.'
Assert-True ((@($integrationWarnings) -join ' ').Contains('Integrate')) 'Existing instructions need an explicit integration warning.'
Assert-True ((Get-Content -LiteralPath (Join-Path $existing 'project-memory/PROJECT.md') -Raw).Contains('existing')) 'Default folder name missing.'
Write-Output 'PASS: existing instructions survive and missing integration is reported.'

$collision = Join-Path $testRoot 'collision'
[System.IO.Directory]::CreateDirectory($collision) | Out-Null
[System.IO.File]::WriteAllText((Join-Path $collision 'project-memory'), 'Unrelated file.')
$failed = $false
try { & $initializer -Path $collision | Out-Null } catch { $failed = $true }
Assert-True $failed 'File/directory collision should fail.'
Assert-True (-not (Test-Path -LiteralPath (Join-Path $collision 'AGENTS.md'))) 'Collision caused partial initialization before preflight.'
Write-Output 'PASS: path collision fails before any scaffold file is created.'

$badName = Join-Path $testRoot 'invalid-name'
$failed = $false
try { & $initializer -Path $badName -Name "Invalid`nName" | Out-Null } catch { $failed = $true }
Assert-True $failed 'Multiline name should be rejected.'
Assert-True (-not (Test-Path -LiteralPath $badName)) 'Invalid name wrote files.'
Write-Output 'PASS: invalid project name is rejected without writing.'
Write-Output "All checks passed. Disposable fixtures: $testRoot"
