# speed_tofu 의 boulder(원본, 강화는 거기서 한다)를 이 단독판으로 가져온다: powershell -ExecutionPolicy Bypass -File tools\sync.ps1
# 가져오는 것: g/boulder.gd, tofu.gd(평가 포함), tools/tofu_fb.js, art/boulder/, main.gd GAME_VER["boulder"] -> main.gd GVER
# 단독판에서만 다른 것: 첫 장면 main.gd(메뉴 없음), "< 메뉴" -> "< 처음부터"
$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot
$src = Join-Path (Split-Path -Parent $kit) 'speed_tofu'
$utf8 = New-Object Text.UTF8Encoding $false
Copy-Item (Join-Path $src 'g\boulder.gd') (Join-Path $kit 'g\boulder.gd') -Force
Copy-Item (Join-Path $src 'tools\tofu_fb.js') (Join-Path $kit 'tools\tofu_fb.js') -Force
$t = [IO.File]::ReadAllText((Join-Path $src 'tofu.gd'), $utf8).Replace('"< 메뉴"', '"< 처음부터"').Replace('const _RATE_BTN := Rect2(620, 0, 100, 100)', "var _RATE_BTN := Rect2(620, 0, 100, 100)`nvar back_on := true  # 단독판: 목록에서 왔을 때만 왼쪽 위 '<' 가 돈다").Replace('if p.x < 180.0 and p.y < 100.0:', 'if back_on and p.x < 180.0 and p.y < 100.0:').Replace('_rate_btn_l.visible = not over and not _rating', '_rate_btn_l.visible = not over and not _rating and _RATE_BTN.size.x > 0.0')
[IO.File]::WriteAllText((Join-Path $kit 'tofu.gd'), $t, $utf8)
$art = Join-Path $src 'art\boulder'
$dst = Join-Path $kit 'art\boulder'
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
if (Test-Path $art) {
	New-Item -ItemType Directory -Force (Split-Path -Parent $dst) | Out-Null
	Copy-Item $art $dst -Recurse -Force
	Get-ChildItem $dst -Recurse -Filter *.import | Remove-Item -Force  # 가져오기 정보는 이 프로젝트에서 새로 만든다
}
# 영어 글꼴(Cinzel, OFL): 가져오기 정보는 이 프로젝트에서 새로 만든다
$fsrc = Join-Path $src 'fonts\cinzel'
$fdst = Join-Path $kit 'fonts\cinzel'
if (Test-Path $fsrc) {
	New-Item -ItemType Directory -Force $fdst | Out-Null
	Copy-Item (Join-Path $fsrc '*') $fdst -Force
	Get-ChildItem $fdst -Filter *.import | Remove-Item -Force
}
$gver = [regex]::Match([IO.File]::ReadAllText((Join-Path $src 'main.gd'), $utf8), '"boulder":\s*(\d+)').Groups[1].Value
$m = [IO.File]::ReadAllText((Join-Path $kit 'main.gd'), $utf8)
$m = [regex]::Replace($m, 'const GVER := \d+', "const GVER := $gver")
[IO.File]::WriteAllText((Join-Path $kit 'main.gd'), $m, $utf8)
Write-Host "synced boulder v$gver"
