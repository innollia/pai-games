# itch.io 업로드용 ZIP을 한 번에 만든다: powershell -ExecutionPolicy Bypass -File tools\build.ps1
# 결과: dist\slapjam2.zip (최상위에 index.html). 만든 뒤 itch.io 한도와 경로 대소문자를 검사한다.
# -Name 으로 파일명을 바꿀 수 있다. 검사에 실패하면 종료코드 1이고 ZIP은 지운다.
param([string]$Name = 'slapjam2')

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$kit = Split-Path -Parent $PSScriptRoot
$src = Join-Path $kit 'game'
$dist = Join-Path $kit 'dist'
$zipPath = Join-Path $dist "$Name.zip"

if (-not (Test-Path (Join-Path $src 'index.html'))) { throw "game\index.html 이 없다" }
New-Item -ItemType Directory -Force $dist | Out-Null
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

# Compress-Archive 는 5.1 에서 경로를 역슬래시로 넣어 itch.io 에서 깨진다. 직접 슬래시 경로로 쓴다.
$srcFull = (Resolve-Path $src).Path.TrimEnd('\')
$files = Get-ChildItem -Path $srcFull -Recurse -File | Where-Object { $_.Name -ne '.gitkeep' -and $_.Name -ne 'Thumbs.db' -and $_.Name -ne '.DS_Store' }
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
try {
  foreach ($f in $files) {
    $rel = $f.FullName.Substring($srcFull.Length + 1).Replace('\', '/')
    [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $f.FullName, $rel, 'Optimal')
  }
} finally { $zip.Dispose() }

# ---- 검사 ----
$errors = New-Object System.Collections.Generic.List[string]
$warns = New-Object System.Collections.Generic.List[string]
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
  $entries = @($zip.Entries | Where-Object { $_.FullName -notmatch '/$' })
  $names = @($entries | ForEach-Object { $_.FullName })
  if ($names -cnotcontains 'index.html') { $errors.Add('ZIP 최상위에 index.html 이 없다') }
  if ($entries.Count -gt 1000) { $errors.Add("파일 수 $($entries.Count) > 1000") }
  $total = ($entries | Measure-Object -Property Length -Sum).Sum
  if ($total -gt 500MB) { $errors.Add("압축 해제 합계 $([int]($total/1MB))MB > 500MB") }
  if ($total -gt 30MB) { $warns.Add("합계 $([int]($total/1MB))MB: 모바일 로딩이 느려진다 (30MB 아래 권장)") }
  foreach ($e in $entries) {
    if ($e.Length -gt 200MB) { $errors.Add("$($e.FullName) 이 200MB 초과") }
    if ($e.Length -gt 5MB) { $warns.Add("$($e.FullName) $([math]::Round($e.Length/1MB,1))MB: 큰 파일") }
    if ($e.FullName.Length -gt 240) { $errors.Add("경로 240자 초과: $($e.FullName)") }
    if ($e.FullName.Contains('\')) { $errors.Add("역슬래시 경로: $($e.FullName)") }
    if ($e.FullName -match '[^\x21-\x7E]') { $errors.Add("파일명에 ASCII 외 문자나 공백: $($e.FullName)") }
  }
  # 대소문자만 다른 중복 이름
  $dup = $names | Group-Object { $_.ToLowerInvariant() } | Where-Object { $_.Count -gt 1 }
  foreach ($d in $dup) { $errors.Add("대소문자만 다른 중복: $($d.Group -join ', ')") }

  # index.html 과 js 안의 상대경로가 ZIP 안 파일과 대소문자까지 일치하는지
  function Read-Entry($zipArchive, $entryName) {
    $en = $zipArchive.GetEntry($entryName)
    if (-not $en) { return '' }
    $sr = New-Object System.IO.StreamReader($en.Open(), [System.Text.Encoding]::UTF8)
    try { return $sr.ReadToEnd() } finally { $sr.Dispose() }
  }
  $refs = New-Object System.Collections.Generic.List[string]
  foreach ($n in ($names | Where-Object { $_ -match '\.(html|js|css)$' })) {
    $text = Read-Entry $zip $n
    foreach ($m in [regex]::Matches($text, '(?:src|href)\s*=\s*"([^"#?]+)"')) { $refs.Add($m.Groups[1].Value) }
    foreach ($m in [regex]::Matches($text, "['""]((?:\./)?assets/[^'""?#]+)['""]")) { $refs.Add($m.Groups[1].Value) }
    foreach ($m in [regex]::Matches($text, 'url\(\s*["'']?([^"'')?#]+)')) { $refs.Add($m.Groups[1].Value) }
  }
  foreach ($r in ($refs | Sort-Object -Unique)) {
    if ($r -match '^(https?:)?//') { $errors.Add("외부 주소는 쓰지 않는다 (오프라인·iframe 위험): $r"); continue }
    if ($r.StartsWith('/')) { $errors.Add("절대경로는 itch.io 에서 깨진다: $r"); continue }
    if ($r -match '^(data|blob):' -or $r -match '[\$\{\}]') { continue }
    $p = $r; if ($p.StartsWith('./')) { $p = $p.Substring(2) }
    if ($names -cnotcontains $p) {
      $ci = $names | Where-Object { $_ -ieq $p }
      if ($ci) { $errors.Add("대소문자 불일치: 코드 '$r' / 실제 '$ci'") } else { $errors.Add("참조한 파일이 ZIP에 없다: $r") }
    }
  }
} finally { $zip.Dispose() }

Write-Host "ZIP: $zipPath"
Write-Host ("파일 {0}개, 합계 {1} KB, ZIP {2} KB" -f $entries.Count, [int]($total/1KB), [int]((Get-Item $zipPath).Length/1KB))
foreach ($w in $warns) { Write-Host "경고: $w" -ForegroundColor Yellow }
if ($errors.Count -gt 0) {
  foreach ($e in $errors) { Write-Host "오류: $e" -ForegroundColor Red }
  Remove-Item $zipPath -Force
  exit 1
}
Write-Host '검사 통과: itch.io 에 이 ZIP 을 올리면 된다 (Kind of project = HTML, "This file will be played in the browser" 체크).' -ForegroundColor Green
exit 0
