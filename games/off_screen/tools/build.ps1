# 화면 밖 경주 웹 빌드 -> web\ (GitHub Pages 로 바로 열린다): powershell -ExecutionPolicy Bypass -File tools\build.ps1
# 엔진 파일 index.wasm 은 Godot 버전이 같으면 매번 똑같아서 저장소에는 한 번만 쌓인다.
param([string]$Godot = (Join-Path $env:LOCALAPPDATA 'Temp\opencode\godot\Godot_v4.7.2-stable_win64_console.exe'))
$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot
$out = Join-Path $kit 'web'
# 빌드 버전: 평가마다 같이 저장돼 나중에 버전별로 본다
$sha = ''
try { $sha = (git -C $kit rev-parse --short HEAD 2>$null | Out-String).Trim() } catch {}
if (-not $sha) { $sha = 'nogit' }
$ver = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd'), $sha
[IO.File]::WriteAllText((Join-Path $kit 'ver.txt'), $ver, (New-Object Text.UTF8Encoding $false))
Write-Host "ver.txt = $ver"
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null
& $Godot --headless --path $kit --import | Out-Host
& $Godot --headless --path $kit --export-release 'Web' (Join-Path $out 'index.html') | Out-Host
if (-not (Test-Path (Join-Path $out 'index.html'))) { Write-Host '오류: export 실패 (index.html 없음)' -ForegroundColor Red; exit 1 }
Copy-Item (Join-Path $PSScriptRoot 'tofu_fb.js') (Join-Path $out 'tofu_fb.js') -Force  # 평가·한마디 -> Firestore tofu_ratings (speed_tofu 와 같은 id screenrace)
Get-ChildItem $out | ForEach-Object { '{0,-40} {1,8} KB' -f $_.Name, [math]::Round($_.Length / 1KB) }
