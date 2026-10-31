# itch 제출용 zip (개발 도구 g/dev.gd 를 뺀 빌드): powershell -ExecutionPolicy Bypass -File tools\itch_zip.ps1
# web\ (GitHub Pages 판, 개발 버튼 있음)은 건드리지 않는다. 결과: blade_path_itch.zip (index.html 이 zip 맨 위)
param([string]$Godot = (Join-Path $env:LOCALAPPDATA 'Temp\opencode\godot\Godot_v4.7.2-stable_win64_console.exe'))
$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot
$out = Join-Path $env:TEMP 'blade_path_itch'
$zip = Join-Path $kit 'blade_path_itch.zip'
$dev = Join-Path $kit 'g\dev.gd'
$off = Join-Path $env:TEMP 'blade_path_dev.gd.off'
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null
Move-Item $dev $off -Force
try {
	& $Godot --headless --path $kit --export-release 'Web' (Join-Path $out 'index.html') | Out-Host
} finally {
	Move-Item $off $dev -Force
}
if (-not (Test-Path (Join-Path $out 'index.html'))) { Write-Host '오류: export 실패' -ForegroundColor Red; exit 1 }
Compress-Archive -Path (Join-Path $out '*') -DestinationPath $zip -Force
Write-Host "zip = $zip ($([math]::Round((Get-Item $zip).Length / 1MB, 1)) MB)"
