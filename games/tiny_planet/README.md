# 작은 행성 Tiny Planets (단독판)

speed_tofu 의 제출준비작 "작은 행성"(tinyplanet) 단독판 = **잼 제출본**. 강화는 speed_tofu 의 `g/tinyplanet.gd`·`art/tinyplanet/`·`art/tinyplanet_sfx/` 에서 하고 `tools\sync.ps1` 로 가져온 뒤 빌드한다. 제출 순서는 [SUBMIT_CHECKLIST.md](SUBMIT_CHECKLIST.md). 페이지 글은 `../speed_tofu/submit/tinyplanet/ITCH_PAGE.md`, 영어 설명은 `../speed_tofu/submit/tinyplanet/HOWTO_EN.md`.
플레이: `https://innollia.github.io/pai-games/games/tiny_planet/web/`

- `g/tinyplanet.gd`: 게임 전부. `art/tinyplanet/`: 로우폴리 모델·그림(Blender + Codex GPT 텍스처, 작업 파일은 `../speed_tofu/submit/tinyplanet/`). `art/tinyplanet_sfx/`: 효과음(nkido 합성).
- `tofu.gd`: 공용 틀. sync.ps1 이 "< 메뉴" 를 "< 처음부터" 로 바꾼다. 한국어가 기본이고, 기기 언어가 한국어가 아니면 게임의 번역 사전이 영어로 바꾼다(`?lang=en`/`?lang=ko` 로 강제). 별점·한마디는 speed_tofu 와 같은 Firestore `tofu_ratings` 에 id "tinyplanet", ver "v<GVER> <빌드>" 로 간다.
- `main.gd`: 메뉴 없이 바로 tinyplanet 을 연다. 주소에 `?from=tofu` 가 있으면 "<" 가 SPEED 두부 목록으로 돌아간다(JS 값은 글자로 비교 — bool 로 비교하면 웹에서 노란 빈 화면).
- 웹 빌드: `powershell -ExecutionPolicy Bypass -File tools\sync.ps1` 다음 `powershell -ExecutionPolicy Bypass -File tools\build.ps1` → `web\`
- Rosebud 상금용 판은 따로, 나중에 만든다(이 폴더는 itch 잼 제출본).
