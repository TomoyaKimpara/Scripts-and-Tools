param([string]$MacroPath = '')
$ErrorActionPreference = 'Stop'
$target = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts'
New-Item -ItemType Directory -Force (Join-Path $target 'Comp'), (Join-Path $target 'Support') | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scripts\Comp\PreRender Create.lua') -Destination (Join-Path $target 'Comp\PreRender Create.lua')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scripts\Support\PreRender_v13.lua') -Destination (Join-Path $target 'Support\PreRender_v13.lua')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scripts\Support\PreRender_placeholder.png') -Destination (Join-Path $target 'Support\PreRender_placeholder.png')
$macroTarget = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion\Macros'
New-Item -ItemType Directory -Force $macroTarget | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Macros\PreRender.setting') -Destination (Join-Path $macroTarget 'PreRender.setting')
if ($MacroPath) {
    New-Item -ItemType Directory -Force $MacroPath | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Macros\PreRender.setting') -Destination (Join-Path $MacroPath 'PreRender.setting')
}
Write-Host 'PreRender installed. Restart Resolve, open Select Tool, then search PreRender.'
