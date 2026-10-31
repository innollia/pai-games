# 어린 배달부 The Little Courier (단독판, v8)

**전체 안내는 [`../speed_tofu/submit/tinyplanet/README.md`](../speed_tofu/submit/tinyplanet/README.md)** (버전, 누가 만들었나, 손잡이, 정한 것, 제출 전 할 일).


speed_tofu 의 제출준비작 "어린 배달부"(tinyplanet) 단독판 = **잼 제출본**. 강화는 speed_tofu 의 `g/tinyplanet.gd`·`art/tinyplanet/`·`art/tinyplanet_sfx/` 에서 하고 `tools\sync.ps1` 로 가져온 뒤 빌드한다. 제출 순서는 [SUBMIT_CHECKLIST.md](SUBMIT_CHECKLIST.md). 페이지 글은 `../speed_tofu/submit/tinyplanet/ITCH_PAGE.md`, 영어 설명은 `../speed_tofu/submit/tinyplanet/HOWTO_EN.md`.
플레이: `https://innollia.github.io/pai-games/games/tiny_planet/web/`

- `g/tinyplanet.gd`: 게임 전부. `art/tinyplanet/`: 소품 모델·그림(Blender + Codex GPT 텍스처. 포스티·주민은 코드로 모델링, 작업 파일은 `../speed_tofu/submit/tinyplanet/`). `art/tinyplanet_sfx/`: 효과음(nkido 합성).
- `tofu.gd`: 공용 틀. sync.ps1 이 "< 메뉴" 를 "< 처음부터" 로 바꾼다. 영어가 기본이고 `?lang=ko` 또는 시작 화면 전환으로 한국어. 단독판에선 "< 처음부터"를 숨긴다. "평가/Rate" 버튼은 제출 바로 전에 뺀다. 별점·한마디는 speed_tofu 와 같은 Firestore `tofu_ratings` 에 id "tinyplanet", ver "v<GVER> <빌드>" 로 간다.
- `main.gd`: 메뉴 없이 바로 tinyplanet 을 연다. 주소에 `?from=tofu` 가 있으면 "<" 가 SPEED 두부 목록으로 돌아간다(JS 값은 글자로 비교 — bool 로 비교하면 웹에서 노란 빈 화면).
- 웹 빌드: `powershell -ExecutionPolicy Bypass -File tools\sync.ps1` 다음 `powershell -ExecutionPolicy Bypass -File tools\build.ps1` → `web\`
- Rosebud $100 상: 같은 `web/` 빌드를 zip 해서 양식으로 낸다(SUBMIT_CHECKLIST.md).
