# Godot 웹 export -> itch.io 용 ZIP: powershell -ExecutionPolicy Bypass -File tools\build_godot.ps1
# 결과: dist\slapjam2_godot.zip. -Godot 로 콘솔 exe 경로를 바꿀 수 있다.
param([string]$Godot = (Join-Path $env:LOCALAPPDATA 'Temp\opencode\godot\Godot_v4.7.2-stable_win64_console.exe'))
$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot
$out = Join-Path $kit 'dist\godot_web'
if (-not (Test-Path $Godot)) { throw "Godot 4.7.2 exe 가 없다: $Godot" }
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null
& $Godot --headless --path $kit --import | Out-Host
& $Godot --headless --path $kit --export-release 'Web' (Join-Path $out 'index.html') | Out-Host
if (-not (Test-Path (Join-Path $out 'index.html'))) { Write-Host '오류: export 실패 (index.html 없음). 웹 export 템플릿 4.7.2 설치 확인' -ForegroundColor Red; exit 1 }
& (Join-Path $PSScriptRoot 'zip_check.ps1') -Name 'slapjam2_godot' -Src $out
exit $LASTEXITCODE
