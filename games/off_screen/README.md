# 화면 밖 경주 Off the Screen! (단독판)

speed_tofu 의 제출준비작 "화면 밖 경주"(screenrace) 단독판 = **잼 제출본**. 강화는 speed_tofu 의 `g/screenrace.gd`·`art/screenrace/` 에서 하고 `tools\sync.ps1` 로 가져온 뒤 빌드한다. 제출 순서는 [SUBMIT_CHECKLIST.md](SUBMIT_CHECKLIST.md). 페이지 글은 `../speed_tofu/submit/screenrace/ITCH_PAGE.md`.
플레이: `https://innollia.github.io/pai-games/games/off_screen/web/`

- `g/screenrace.gd`: 게임 전부. `art/screenrace/`: 모델·배경·효과음(nkido, `../speed_tofu/submit/screenrace/work/build_sfx.py`).
- `tofu.gd`: 공용 틀. sync.ps1 이 공용 글자를 영어로 바꾼다("< 메뉴" -> "< Restart", "평가" -> "Rate" 등). 별점·한마디는 speed_tofu 와 같은 Firestore `tofu_ratings` 에 id "screenrace", ver "v<GVER> <빌드>" 로 간다.
- `main.gd`: 메뉴 없이 바로 screenrace 를 연다.
- 웹 빌드: `powershell -ExecutionPolicy Bypass -File tools\sync.ps1` 다음 `powershell -ExecutionPolicy Bypass -File tools\build.ps1` → `web\`
