# speed_tofu 의 tinyplanet(원본, 강화는 거기서 한다)를 이 단독판으로 가져온다: powershell -ExecutionPolicy Bypass -File tools\sync.ps1
# 가져오는 것: g/tinyplanet.gd, g/tinyplanet_ui.gd·tinyplanet_fx.gd(v5 도우미), tofu.gd(평가 포함), tools/tofu_fb.js, art/tinyplanet/(모델·그림), art/tinyplanet_sfx/(효과음), fonts/, main.gd GAME_VER["tinyplanet"] -> main.gd GVER
# 단독판에서만 다른 것: 첫 장면 main.gd(메뉴 없음), "< 메뉴" -> "< 처음부터" (영어는 g/tinyplanet.gd 의 번역 사전이 기기 언어로 바꾼다)
$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot
$src = Join-Path (Split-Path -Parent $kit) 'speed_tofu'
$utf8 = New-Object Text.UTF8Encoding $false
New-Item -ItemType Directory -Force (Join-Path $kit 'g') | Out-Null
Copy-Item (Join-Path $src 'g\tinyplanet.gd') (Join-Path $kit 'g\tinyplanet.gd') -Force
Copy-Item (Join-Path $src 'g\tinyplanet_ui.gd') (Join-Path $kit 'g\tinyplanet_ui.gd') -Force
Copy-Item (Join-Path $src 'g\tinyplanet_fx.gd') (Join-Path $kit 'g\tinyplanet_fx.gd') -Force
Copy-Item (Join-Path $src 'tools\tofu_fb.js') (Join-Path $kit 'tools\tofu_fb.js') -Force
$t = [IO.File]::ReadAllText((Join-Path $src 'tofu.gd'), $utf8).Replace('"< 메뉴"', '"< 처음부터"')
[IO.File]::WriteAllText((Join-Path $kit 'tofu.gd'), $t, $utf8)
# 폰트: tofu.gd 가 res://fonts/Pretendard-Bold.otf 를 쓴다 (.import 는 이 프로젝트 것을 둔다)
New-Item -ItemType Directory -Force (Join-Path $kit 'fonts') | Out-Null
Get-ChildItem (Join-Path $src 'fonts') -File | Where-Object { $_.Extension -ne '.import' } | ForEach-Object { Copy-Item $_.FullName (Join-Path $kit ('fonts\' + $_.Name)) -Force }
foreach ($name in @('tinyplanet', 'tinyplanet_sfx')) {
	$art = Join-Path $src ('art\' + $name)
	$dst = Join-Path $kit ('art\' + $name)
	if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
	if (Test-Path $art) {
		New-Item -ItemType Directory -Force (Split-Path -Parent $dst) | Out-Null
		Copy-Item $art $dst -Recurse -Force
		Get-ChildItem $dst -Recurse -Filter *.import | Remove-Item -Force  # 가져오기 정보는 이 프로젝트에서 새로 만든다
		Get-ChildItem $dst -Recurse -Filter *.md | Remove-Item -Force
		Write-Host "art: $name"
	} else {
		Write-Host "art 없음(건너뜀): $art"
	}
}
$gver = [regex]::Match([IO.File]::ReadAllText((Join-Path $src 'main.gd'), $utf8), '"tinyplanet":\s*(\d+)').Groups[1].Value
if (-not $gver) { Write-Host '오류: speed_tofu main.gd 에서 GAME_VER["tinyplanet"] 를 못 찾음' -ForegroundColor Red; exit 1 }
$m = [IO.File]::ReadAllText((Join-Path $kit 'main.gd'), $utf8)
$m = [regex]::Replace($m, 'const GVER := \d+', "const GVER := $gver")
[IO.File]::WriteAllText((Join-Path $kit 'main.gd'), $m, $utf8)
Write-Host "synced tinyplanet v$gver"
