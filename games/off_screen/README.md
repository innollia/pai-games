# 화면 밖 경주 Off the Screen! (단독판)

speed_tofu 의 제출준비작 "화면 밖 경주"(screenrace) 단독판 = **잼 제출본**.
- 강화는 speed_tofu 쪽(`g/screenrace.gd`, `g/sr_*.gd`, `art/screenrace/`)에서 하고, `tools\sync.ps1` 로 가져온 뒤 빌드한다.
- 제출 순서는 [SUBMIT_CHECKLIST.md](SUBMIT_CHECKLIST.md)에 있다.
- 게임 설명·규칙·문서 안내는 `../speed_tofu/submit/screenrace/README.md`, 페이지 글은 같은 폴더의 `ITCH_PAGE.md`에 있다.

플레이: `https://innollia.github.io/pai-games/games/off_screen/web/`

- `g/screenrace.gd`: 게임 전부.
- `g/sr_theme.gd`·`sr_front.gd`·`sr_hud.gd`·`sr_menus.gd`: UI(디자인 시스템, 타이틀·연습, 진행 줄·조작·짐 벽, 카드·결과).
- `art/screenrace/`: 모델·배경·UI 그림·효과음.
- `tofu.gd`: 공용 틀이다. sync.ps1 이 공용 글자를 영어로 바꾼다("< 메뉴" -> "< Restart", "평가" -> "Rate" 등). 별점·한마디는 speed_tofu 와 같은 Firestore `tofu_ratings` 에 id "screenrace", ver "v<GVER> <빌드>" 로 간다.
- `main.gd`: 메뉴 없이 바로 screenrace 를 연다. `?from=tofu` 로 들어오면 "<" 가 SPEED 두부 목록으로 돌아간다. JS 값은 글자로 비교한다: `== true` 로 비교하면 웹에서 노란 빈 화면이 된다.
- 웹 빌드 순서:
  1. `powershell -ExecutionPolicy Bypass -File tools\sync.ps1`
  2. `powershell -ExecutionPolicy Bypass -File tools\build.ps1`
  3. 결과는 `web\` 에 생긴다.
  sync 는 `.import` 를 지우므로, 캡처 전에는 `--import` 를 한 번 돌린다.
- 화면 캡처는 창을 띄워서 해야 한다(headless 불가): `godot --path . --resolution 720x1280 -s tools/capture.gd -- <폴더>`. 타이틀부터 평가 카드까지 PNG로 저장한다.
