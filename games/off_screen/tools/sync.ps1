# speed_tofu 의 screenrace(원본, 강화는 거기서 한다)를 이 단독판으로 가져온다: powershell -ExecutionPolicy Bypass -File tools\sync.ps1
# 가져오는 것: g/screenrace.gd, g/sr_*.gd(UI 모듈), tofu.gd(평가 포함), tools/tofu_fb.js, art/screenrace/, main.gd GAME_VER["screenrace"] -> main.gd GVER
# 단독판에서만 다른 것: 첫 장면 main.gd(메뉴 없음), tofu.gd 공용 글자를 영어로(잼 심사가 영어)
$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot
$src = Join-Path (Split-Path -Parent $kit) 'speed_tofu'
$utf8 = New-Object Text.UTF8Encoding $false
Copy-Item (Join-Path $src 'g\screenrace.gd') (Join-Path $kit 'g\screenrace.gd') -Force
Get-ChildItem (Join-Path $src 'g') -Filter 'sr_*.gd' | ForEach-Object { Copy-Item $_.FullName (Join-Path $kit (Join-Path 'g' $_.Name)) -Force }  # 화면 밖 경주 UI 모듈
Copy-Item (Join-Path $src 'tools\tofu_fb.js') (Join-Path $kit 'tools\tofu_fb.js') -Force
$t = [IO.File]::ReadAllText((Join-Path $src 'tofu.gd'), $utf8)
$en = [ordered]@{
	'"< 메뉴"' = '"< Menu"'; '"평가"' = '"Rate"'; '"탭해서 시작"' = '"Tap to start"'; '"이 게임 어때요?"' = '"How was this game?"'
	'"닫기"' = '"Close"'; '"한마디"' = '"Comment"'; '"이 게임에 한마디 (선택)"' = '"A word about this game (optional)"'
	'"고마워요!"' = '"Thanks!"'; '"보내는 중"' = '"Sending"'; '"한마디 보냈어요"' = '"Your comment was sent"'
	'"저장 안 됨 · 별을 다시 탭"' = '"Not saved · tap a star again"'; '"%d\n최고 %d%s"' = '"%d\nBest %d%s"'; '"\n탭해서 다시"' = '"\nTap to retry"'
}
foreach ($k in $en.Keys) { $t = $t.Replace($k, $en[$k]) }
[IO.File]::WriteAllText((Join-Path $kit 'tofu.gd'), $t, $utf8)
$art = Join-Path $src 'art\screenrace'
$dst = Join-Path $kit 'art\screenrace'
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
New-Item -ItemType Directory -Force (Split-Path -Parent $dst) | Out-Null
Copy-Item $art $dst -Recurse -Force
Get-ChildItem $dst -Recurse -Filter *.import | Remove-Item -Force  # 가져오기 정보는 이 프로젝트에서 새로 만든다
Get-ChildItem $dst -Recurse -Filter *.md | Remove-Item -Force
$gver = [regex]::Match([IO.File]::ReadAllText((Join-Path $src 'main.gd'), $utf8), '"screenrace":\s*(\d+)').Groups[1].Value
$m = [IO.File]::ReadAllText((Join-Path $kit 'main.gd'), $utf8)
$m = [regex]::Replace($m, 'const GVER := \d+', "const GVER := $gver")
[IO.File]::WriteAllText((Join-Path $kit 'main.gd'), $m, $utf8)
Write-Host "synced screenrace v$gver"
