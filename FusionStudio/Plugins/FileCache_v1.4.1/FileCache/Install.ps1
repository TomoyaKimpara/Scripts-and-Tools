param([string]$MacroPath = '')
$ErrorActionPreference = 'Stop'
$target = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts'
New-Item -ItemType Directory -Force (Join-Path $target 'Comp'), (Join-Path $target 'Support') | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scripts\Comp\FileCache Create.lua') -Destination (Join-Path $target 'Comp\FileCache Create.lua')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scripts\Support\FileCache_v13.lua') -Destination (Join-Path $target 'Support\FileCache_v13.lua')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Scripts\Support\FileCache_placeholder.png') -Destination (Join-Path $target 'Support\FileCache_placeholder.png')
$macroTarget = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion\Macros'
New-Item -ItemType Directory -Force $macroTarget | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Macros\FileCache.setting') -Destination (Join-Path $macroTarget 'FileCache.setting')
if ($MacroPath) {
    New-Item -ItemType Directory -Force $MacroPath | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Macros\FileCache.setting') -Destination (Join-Path $MacroPath 'FileCache.setting')
}
$fuseTarget = Join-Path $env:APPDATA 'Blackmagic Design\DaVinci Resolve\Support\Fusion\Fuses'
New-Item -ItemType Directory -Force $fuseTarget | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'Fuses\FileCacheGate.fuse') -Destination (Join-Path $fuseTarget 'FileCacheGate.fuse')
Write-Host 'FileCache installed. Restart Resolve, open Select Tool, then search FileCache.'
