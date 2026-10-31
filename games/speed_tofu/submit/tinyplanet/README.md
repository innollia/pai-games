# 어린 배달부 / The Little Courier (id: tinyplanet) — 처음 읽는 곳

이 게임에 대해 알아야 할 것은 여기서 시작한다. 자세한 내용은 아래 "파일 지도"의 문서로 간다.

## 어떤 게임인가

우체통 모양 꼬마 **포스티(Posty)**가 작은 별을 빙빙 달려 속도를 모으고, 점프해서 별의 중력을 벗어나 다른 별로 날아간다.
**달린 빠르기와 점프한 순간이 곧 날아가는 길**이 되고, 다른 별 근처에서는 빙 돌다 내려앉는다(궤도 착지).
별 다섯·달 둘·불 별 하나가 한 하늘에 떠 있고, 주민 다섯의 부탁(소포·유리꽃·유리 덮개 같은 깨지는 짐)을 별과 별 사이로 나른다.

- **지금 버전: v11** (speed_tofu `main.gd`의 `GAME_VER["tinyplanet"] = 11`, 단독판 `GVER`는 sync가 맞춤)
- 마지막 코드 커밋: `d065d2b` (2026-10-31, PC 키보드 조작)
- v9~v11: 부탁 순서 자유 + 왼쪽 위 할 일 목록(N/5), 도움 힌트 10가지(`HELP_HINTS.md`), 대사 일상개그물(`DIALOGUE_FINAL.md`, 돛→구식 날다리·노을 아이→형님), 별마다 색·큰 상징물·이름표, 끌어주기는 지금 할 일 별만, 굴뚝 놓기 쉽게.

## PC 키보드 조작 (플레이테스트용)

| 키 | 하는 일 |
|---|---|
| WASD · 화살표 | 조이스틱 |
| 스페이스 | 점프 (날 땐 날다리) |
| F · E | 놓기 |
| Tab · Q | 할 일 목록 |
| Enter | 시작 화면에서 시작 |

## 플레이 링크

- 기본(영어): https://innollia.github.io/pai-games/games/tiny_planet/web/
- 한국어: https://innollia.github.io/pai-games/games/tiny_planet/web/?lang=ko (시작 화면 오른쪽 아래 `EN | 한국어` 버튼으로도 바꿈. 고른 언어는 기기에 저장됨)
- 성능 표 보기: `?debug=1` (왼쪽 위에 FPS·그리기 수·삼각형 수·무거운 부분 시간. 브라우저 콘솔에서 `tpcmd("...")`로 실험 가능)
- 고해상도 그대로: `?hires=1` (보통은 폰 화면 가로를 약 800px로 줄여서 그린다. 이걸 붙이면 줄이지 않음)
- 여러 개 같이 쓰기: `?lang=ko&debug=1`
- SPEED 두부 목록에서 들어오면 `?from=tofu`가 붙고, 왼쪽 위 `<`가 목록으로 돌아간다.
- GitHub Pages 반영에는 push 뒤 1~2분 걸린다.

## 누가 무엇을 만들었나

| 부분 | 만든 것 | 어디에 |
|---|---|---|
| 게임 코드 전부(물리·비행·부탁·화면·연출) | Claude (Anthropic) | `g/tinyplanet.gd`, `g/tinyplanet_ui.gd`, `g/tinyplanet_fx.gd` |
| 주인공 포스티·주민 다섯 | Claude가 **코드로 직접 모델링**(도형 부품 + 납작한 색 + 외곽선). 다리·눈·깃발이 움직임 | `g/tinyplanet.gd`의 `_build_posty`, `_posty_anim`, `_shape_vil` |
| 대사(한국어·영어 86줄 + 뒤에 더한 안내 글) | Gemini 3.8 Flash High (Google), Antigravity로 | `dialogue.json`이 처음 원본. 지금 모든 글은 `g/tinyplanet_text.gd` 한 곳 |
| 소품 그림(텍스처) | Codex가 GPT 이미지로 그림. hwapongstuy 범용 규칙(ANTI-SLOP) 그대로 따름 | `art/tinyplanet/*.png` |
| 소품 모양(로우폴리 GLB) | Codex가 Blender 스크립트로 만듦 | `art/tinyplanet/*.glb` |
| 별(행성) | 코드가 만든 각진 공(icosphere), 그림 없음 | `g/tinyplanet.gd` |
| 효과음 22개 | nkido(MIT)로 원재료를 만들고 numpy로 다듬음. 외부 샘플 없음 | `art/tinyplanet_sfx/*.wav`, `build_sfx.py` |
| 글꼴 | Pretendard Bold (OFL) | `fonts/` |

지금 코드가 쓰는 GLB: windmill_tower, windmill_blades, tower, chimney_house, wall, tree, rose, parcel, glass_flower, glass_dome, meteor (11개).
안 쓰는 GLB: traveler, villager(포스티·주민은 코드 모델), rock(첫 별 바위 제거), red_rock(지뢰 울타리로 바뀜). 파일은 아직 폴더에 있고 단독판에도 복사된다.

## 파일 지도

**speed_tofu 쪽 (원본. 고치는 건 늘 여기서)** — `C:\projects\pai-games\games\speed_tofu\`
- `g/tinyplanet.gd` — 게임 본체. 별·비행·부탁·주민·포스티·위 HUD(막대·할 일 칩·화살표·말풍선·알림판)·날다리 버튼·우주 미아·성능 표·대사(`DL`).
- `g/tinyplanet_ui.gd` — 시작 화면(로고·시작 버튼·언어 전환), 게임오버·엔딩 화면, 점수 팝, 디자인 시스템(`DS`).
- `g/tinyplanet_text.gd` — 화면에 나오는 모든 글(한국어·영어 한 표 `TEXT`, 노는 순서대로). 본체·ui가 키로 `tr()` 한다. 영어·한국어 번역 둘 다 이 표에서 만든다.
- `g/tinyplanet_fx.gd` — 속도감·연출(속도선, 시야 넓히기, 발 먼지, 꼬리, 별 줄무늬, 구름, 탈출 장면, 화면 가장자리 빛·어둑해짐).
- `art/tinyplanet/` — 로우폴리 모델 GLB + 512×512 그림 PNG (15쌍).
- `art/tinyplanet_sfx/` — 효과음 WAV 22개.
- `designs/tinyplanet.md` — 설계 기록. 맨 위에 "현재(v8) 규칙 한눈에"와 버전 표, 아래는 버전별 기록.
- `submit/tinyplanet/` — 이 폴더(Godot이 안 읽게 `.gdignore`, `work/`는 `.gitignore`).
  - `README.md` — 지금 이 파일.
  - `FEEDBACK_LOG.md` — 사용자 피드백 → 한 일 → 상태 (날짜순).
  - `ART_DIRECTION.md` — 그림 스타일·팔레트·모델 크기 약속.
  - `CHARACTER.md` — 포스티와 주민 생김새.
  - `MODULES.md` — 본체와 ui·fx 사이의 약속(함수·이벤트 이름).
  - `DIALOGUE_BRIEF.md` — Gemini에게 준 대사 요청서(v5 때 것).
  - `ART_LOG.md` — 그림 작업 기록(Codex).
  - `ITCH_PAGE.md` — itch 페이지 글(제목·설명·조작·도구·태그).
  - `HOWTO_EN.md` — 영어 조작 설명.
  - `TEXT_KO.tsv` — 글 표를 엑셀·구글 시트로 여는 파일(아래 "한국어 고치는 법"). `TEXT_CHANGED.tsv` — 한국어를 바꿔서 영어를 다시 옮겨야 할 키 목록(가져오기가 만든다).
  - `tools/text_export.py`·`tools/text_import.py` — 글 표 → TSV 내보내기, 고친 TSV → 글 표 가져오기.
  - `TEXT_REVIEW.md` — 글 검토(옛 v9 기준 표와 이상한 점 목록).
  - `dialogue.json` — Gemini가 쓴 대사 원본. `SFX_MANIFEST.json` — 소리 목록. `ASSET_MANIFEST.json` — 처음 15개 그림의 크기 기록.
  - 스크립트: `build_sfx.py`(소리 만들기), `build_art.py`·`texture_flow.py`·`prepare_textures.py`·`align_textures.py`·`finalize_art.py`·`pack_art.py`·`verify_art.py`·`import_art.py`·`preview_art.py`·`contact_sheet.py`(그림 파이프라인, Codex가 씀).
  - `work/` — 그림 작업 중간 파일(저장소에 안 올라감).

**단독판 (잼 제출본)** — `C:\projects\pai-games\games\tiny_planet\`
- `main.gd` — 메뉴 없이 바로 tinyplanet을 연다. `GVER`.
- `g/`, `art/`, `tofu.gd`, `fonts/` — `tools/sync.ps1`이 speed_tofu에서 복사해 온 것(여기서 직접 고치지 않는다).
- `tools/sync.ps1` — speed_tofu에서 코드·그림·소리·글꼴·평가 스크립트를 가져오고, `GVER`를 맞춘다. `"< 메뉴"`는 `"< 처음부터"`로 바꾼다(게임이 그 버튼을 숨김).
- `tools/build.ps1` — `ver.txt` 쓰고, Godot import + Web export → `web/`, `tofu_fb.js` 복사.
- `web/` — GitHub Pages가 그대로 보여 주는 웹 빌드.
- `README.md`, `SUBMIT_CHECKLIST.md` — 단독판 설명과 제출 순서.

## 한국어 고치는 법

1. `submit/tinyplanet/TEXT_KO.tsv`를 엑셀이나 구글 시트로 연다. 한 줄이 글 하나다: 키 · 언제 나오나 · 누가 · 한국어 · English · **한국어(수정)**.
2. 고치고 싶은 줄만 **한국어(수정)** 칸에 새 한국어를 쓴다. 빈 칸은 그대로 둔다. 다른 칸은 건드리지 않는다.
   - `{planet}` `{who}` `{item}` `{target}` `{src}`는 게임이 이름을 넣는 자리라 그대로 둔다(빠지면 그 줄은 안 들어간다).
   - `tofu.`로 시작하는 줄은 공통 글이라 한국어는 바꿔도 안 바뀐다(영어만 고칠 수 있다).
   - 말풍선은 폰 화면에서 두세 줄이면 꽉 찬다. 한국어 40자 안쪽이 좋다.
3. **탭으로 구분된 텍스트(.tsv / .txt)**로 저장한다. 엑셀: 다른 이름으로 저장 → "텍스트(탭으로 분리)" 또는 "유니코드 텍스트". 구글 시트: 파일 → 다운로드 → 탭으로 구분된 값(.tsv).
4. 저장한 파일을 Claude에게 주고 "한국어 고쳤어"라고 말한다.

Claude가 하는 일: `python submit/tinyplanet/tools/text_import.py <파일>` (먼저 `--dry`로 확인) → 한국어가 `g/tinyplanet_text.gd`에 들어가고, 바뀐 키가 `TEXT_CHANGED.tsv`에 쌓인다 → 그 키들의 영어를 새 한국어에 맞게 다시 옮긴다 → `python submit/tinyplanet/tools/text_export.py`로 TSV를 새로 뽑는다 → smoke → 단독판 sync·빌드.

## 빌드·확인 명령 (그대로 복사)

**1) smoke (스크립트 오류만 확인, 한 번만)** — Git Bash:
```bash
cd /c/projects/pai-games/games/speed_tofu
timeout 590 "$LOCALAPPDATA/Temp/opencode/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --fixed-fps 60 -s tools/smoke.gd -- tinyplanet > "$TEMP/smoke.txt" 2>&1; grep -E "ERROR|끝남|smoke done" "$TEMP/smoke.txt"
```
`SCRIPT ERROR`가 없고 `smoke done`이 나오면 통과.

**2) 단독판 웹 빌드** — PowerShell:
```powershell
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*http.server*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -Confirm:$false }
powershell -ExecutionPolicy Bypass -File C:\projects\pai-games\games\tiny_planet\tools\sync.ps1
powershell -ExecutionPolicy Bypass -File C:\projects\pai-games\games\tiny_planet\tools\build.ps1
```

주의:
- **빌드 전에 로컬 `python http.server`를 꼭 끈다** (첫 줄). `web/`를 잡고 있으면 빌드가 실패하거나 멈춘다.
- 다른 Godot 프로세스(다른 세션 작업)가 돌고 있어도 export는 된다. 다만 **smoke는 다른 smoke와 겹치게 돌리지 않는다** (겹치면 Godot 머리말만 찍고 멈춘다).
- `godot --import`가 끝날 때 Segmentation fault를 내도 `.import` 파일이 생겼으면 괜찮다.
- 버전을 올릴 때는 speed_tofu `main.gd`의 `GAME_VER["tinyplanet"]`를 올린다(오케스트레이터 몫). sync가 단독판 `GVER`를 맞춘다.
- speed_tofu 메뉴의 "작은 행성" 칸은 단독판(`../../tiny_planet/web/?from=tofu`)으로 넘어가므로, 이 게임만 고쳤으면 speed_tofu 웹 빌드는 안 해도 된다.

## 손잡이 숫자 (`g/tinyplanet.gd` 맨 위 const, 지금 값)

| 이름 | 값 | 하는 일 |
|---|---|---|
| `TOP` | 12.5 | 땅에서 낼 수 있는 최고 속도 |
| `ACC` | 7.0 | 달리기 가속 |
| `JUMP` | 5.0 | 점프 세기(위로) |
| `AIRJUMP` | 4.5 | 날다리가 없을 때 공중 점프 세기 |
| `LAND_K` | 0.55 | 착지 때 남는 옆 속도 비율 |
| `NM` | 4 | 운석 칸 수 |
| `ND` | 24 | 앞길 점선 점 수(5.5초 앞까지) |
| `CRUISE` | 9.5 | 높이 날 때 이 빠르기 밑으로는 안 느려짐 |
| `HOME_A` | 2.8 | 끌어주기: 가장 가까이 지나갈 별 쪽으로 방향만 트는 힘 (v7 4.5 → v8 2.8) |
| `CAP_T` | 0.5 | 잡기: 다른 별 둘레 안에서 옆 속도를 깎는 정도 (v7 0.9 → v8 0.5) |
| `CAP_R` | 1.7 | 잡기: 그 별 쪽으로 더 끄는 힘 (v7 3.0 → v8 1.7) |
| `LAND_VMAX` | 5.5 | 다른 별 대기 안에서 내려가는 빠르기 한도. 유리는 3 넘으면 금, 7이면 깨짐이라 세게 꽂으면 금이 간다 (v7 4.0 → v8 5.5) |
| `SAIL_ADD` | 2.5 | 날다리를 쓰면 이만큼 빨라짐 |
| `SAIL_TURN` | 0.62 | 스틱 없이 날다리를 쓰면 갈 곳 쪽으로 이만큼(라디안, 약 35°)까지 틈 |
| `TOW_T` | 2.4 | 우주 미아 때 마지막 별로 끌려 돌아오는 시간(초) (v7 1.5 → v8 2.4) |
| `DOT_SC` | 0.78 | 점선 점 크기 |
| `GHOST_SC` | 0.5 | 연한 점선(날다리를 쓰면 갈 길) 점 크기 |
| `SAIL_POS` | (400, 1165) | 날다리 버튼 자리(날 때만 보임) |
| `HUD_TOP`/`HUD_BOT` | 320 / 880 | 갈 곳 화살표가 다니는 화면 칸 |
| `HEART_T` | 2.0 | 하트가 보이는 시간(목숨 잃을 때만) |
| `BUB_BOTTOM` | 940 | 말풍선 아래 끝(조작 버튼 바로 위) |
| `BOUND` | 78 | 어느 별에도 안 끌린 채 하늘 가운데에서 이보다 멀면 경고, +10이면 죽음 |

맨 위 블록 밖에 있는 숫자:
- `DECO_FAR` 80 — 카메라에서 이보다 먼 별은 풀·꽃·나무 장식을 숨김.
- `VIL_NEAR` 55 — 주민은 카메라에서 55m 안일 때만 보임. 단, 지금 부탁의 별(부탁한 별·받을 별·전할 별) 주민은 늘 보임. 시작 화면에서는 주민 숨김.
- `SIM_SECS` 5.5 / `SIM_H` 1/30 — 점선 계산 길이와 간격. 땅에선 매 프레임, 날 땐 4프레임에 한 번 계산하고 점은 매 프레임 그 길을 따라 움직임.
- `_esc_need()` 0.70 / 0.80 — 탈출 도움 문턱(풍차·우편 부탁 때 70%, 그 뒤 80%).
- `_lost_check()` 2.6초 / 4.5초 — 우주 미아 판정(고칠 방법이 없으면 2.6초, 날다리로 고칠 수 있는데 안 쓰면 4.5초, 하늘 끝 4m 안이면 바로).
- 빈 하늘 빨리 감기 2.2배, 끄는 둘레 `max(2.2R, 13.5)`(불 별 18), 대기 `max(1.75R, R+4.5)`.
- `_dpr_cap()` 800 — 웹 화면 가로 픽셀 상한.
- `tinyplanet_fx.gd` `"drift_warn"` → `_dusk_hold = 2.6` — 우주 미아 때 화면 가장자리가 천천히(1.4초) 어둑해졌다가 1.2초에 돌아옴.

## 정해진 것 (다시 묻지 않는다)

- **영어가 기본.** 한국어는 `?lang=ko` 또는 시작 화면 전환 버튼.
- **Codex는 그림만 그린다.** 코드·게임 규칙·캐릭터 모델은 Claude가 한다.
- **포스티와 주민은 코드로 만든다.** 알 모양 여행자(GLB)는 "기괴하다"는 말을 듣고 버렸다.
- **"평가"(영어 화면에선 Rate) 버튼은 제출 바로 전까지 둔다.** 폰 플레이 평가를 계속 받기 위해서다. 제출 직전에 뺀다.
- **우주 미아로 끌려 돌아올 때 목숨은 안 깎인다.** 든 물건도 그대로. 잃는 건 시간뿐.
- **날다리를 조이스틱 없이 쓰면 갈 곳(노란 빛기둥) 쪽으로 튼다.** 스틱을 밀면 그쪽으로.
- **먼 주민은 아예 안 보인다(55m 밖).** 단 지금 부탁 별의 주민은 늘 보인다.
- 시작할 때 글은 **위 할 일 칩 + 풍차지기 말풍선** 둘뿐. 별 이름 글과 소개 알림판은 뺐다.
- 튜토리얼 없음. 첫 판에만 말풍선 한 줄 "Hold the stick to run · Jump when the bar fills".
- 빨강은 위험에만(불 별, 지뢰 울타리, 운석). 하늘은 늘 밝은 파스텔. 효과 글("쾅!" 같은 것) 없음.
- 단독판 왼쪽 위 "< 처음부터"는 숨김(실수로 눌려 판이 날아가서).

## 제출 전 할 일

마감 **2026-11-01(일) 00:00 KST**. 마감 뒤에는 못 고치니 **10/31 20~21시에 미리 낸다.**

에이전트가 할 일:
- [x] "평가/Rate" 버튼·끝 별점 카드: 단독판 `tools/sync.ps1`이 복사본 `tofu.gd`에서만 끈다(speed_tofu 메뉴판은 평가 그대로).
- [ ] sync → build → 커밋·push → 폰에서 플레이 링크로 한 판.
- [ ] itch용 zip 만들기 (`web/` 안의 파일만, `index.html`이 zip 맨 위):
  ```powershell
  Compress-Archive -Path C:\projects\pai-games\games\tiny_planet\web\* -DestinationPath C:\projects\pai-games\games\tiny_planet\little_courier_itch.zip -Force
  ```

사용자가 할 일 (계정·개인 정보가 필요해서):
- [ ] itch.io 올리기: 순서는 `games/tiny_planet/SUBMIT_CHECKLIST.md`. 글은 `ITCH_PAGE.md`에서 복사.
- [ ] 표지(630×500)와 스크린샷 3장 이상은 **폰에서 직접 캡처**(별 위 달리기, 점선 보이며 날기, 주민과 말풍선).
- [ ] **Rosebud $100 상(Best Game Hosted on Rosebud)**: 어떤 도구로 만든 게임도 되고 **Godot 빌드도 된다.** `web/` 폴더를 zip(파일 이름 그대로)해서 양식 https://forms.gle/BhVwP4vpVKjP13j88 으로 내면 Rosebud 팀이 올려 주고 링크를 준다. 언제 올려 주는지, 나중에 고칠 수 있는지 모르니 **최종본을 일찍** 낸다. 단독판은 단일 스레드(`thread_support=false`)라 헤더 문제 없음.
- [ ] 상금 연락용 **이메일은 비공개 칸에만** 직접 넣는다(설명란에 쓰지 않는다).
- [ ] 잼 사용 도구 체크: Claude, Codex/ChatGPT(GPT 그림), Gemini(Antigravity, 대사), Godot(+Blender, nkido).

## 남은 일 · 아이디어

- v8~v11 변경(순서 자유, 할 일 목록, 도움 힌트, 별 이름표·상징물, 의도한 비행, 굴뚝 쉽게, 키보드)은 **실제 플레이 확인 안 됨.**
- 사용자가 `TEXT_KO.tsv`를 고쳐 보내면 `tools/text_import.py`로 넣고 바뀐 줄을 영어로 번역.
- 대표 장면 하나 더: 불 별 새총으로 장미 별에 가는 순간을 탈출 장면처럼 느리게 보여 주기.
- 엔딩 뒤 다시 할 이유: 배달 시간 기록·새총 수를 별(★)로 보여 주기.
