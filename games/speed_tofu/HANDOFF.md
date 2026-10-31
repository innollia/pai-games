# 인계 (2026-10-30 밤 기준)

새 세션이 이 파일 하나로 이어받는다. 마감: **2026-11-01 00:00 KST** (slap jam #2, 주제 speed). 마감 뒤에는 빌드 수정 불가.

## 지금 상태

- 플레이: `https://innollia.github.io/pai-games/games/speed_tofu/web/` (GitHub Pages, push 후 1~2분)
- 메뉴: 본 목록 34개 · "1차 폐기 (판정 탈락)" 32개 · "2차 폐기 (평가 낮음)" 10개 · 맨 아래 "아이디어 제출하기". 이름 옆 `vN`은 게임 버전(`main.gd`의 `GAME_VER`).
- 세대: 1세대(첫 판) → 2세대(유전자 표) → 메모 판 → 3세대(평가 적합도 + Codex 아이디어) → 4세대(별 4+ 강화·번식, 2 이하 폐기, 별 3 한마디 수정). 기록은 [GA.md](GA.md).
- 평가 파이프라인: 게임 끝 화면 별점 + 게임 중 오른쪽 위 "평가" 버튼 + 별 없는 한마디 → Firestore(`innollia-blog`, 컬렉션 `tofu_ratings`·`tofu_ideas`) → `python tools/feedback.py` → [FEEDBACK.md](FEEDBACK.md). 규칙은 이미 콘솔에 붙어 있다.
- 모든 피드백은 사용자·팀이 **폰으로 플레이하고** 준 것이다.

## 문서 지도

| 파일 | 내용 |
| --- | --- |
| [README.md](README.md) | 게임 목록(세대별 표), 구조, 명령, 평가·아이디어 |
| [GA.md](GA.md) | 적합도 계산, 유전자 가중치, 강화·번식·폐기·별 3 규칙, 교배 절차, 세대별 선발 |
| [DESIGNS.md](DESIGNS.md) | 게임별 설계서(한 문장, 속도의 인과, 구역 5개, 약점, 자체 점수). 아이디어는 코드가 아니라 여기서 읽는다 |
| [FEEDBACK.md](FEEDBACK.md) | 최신 별점·한마디·아이디어(스크립트가 만듦) |
| [REVIEW_G2.md](REVIEW_G2.md) | 2세대 제작자 검사 기록(지금은 검증 최소화로 이 방식은 안 씀) |
| [PLANS.md](PLANS.md) | 초기 완성형 기획 4개 |
| `../slapjam2/docs/JAM_ANALYSIS.md` | 대회 규칙·팁·FAQ, 수상작 분석, 팀 기준, 사용자 판정 기록, 유전자 표 |
| `../slapjam2/docs/METHODS.md` | 발상·검증·코어 루프 설계 방법론(Codex 조사), kill criteria, 브리프 양식 |

## 한 세대 돌리는 법 ("유전알고리즘 작동")

1. `python tools/feedback.py --json` → FEEDBACK.md 읽기.
2. [GA.md](GA.md)에 적합도 표 추가: 별 4+ → 콘텐츠·비주얼 강화(같은 id, `GAME_VER` +1) **그리고** 자식 하나(이긴 유전자 유지, 소재·두 번째 규칙 변경, 시점만 바꾼 건 자식 아님). 별 3 + 한마디 → 한마디만 수정(사용자가 재미없다 하면 폐기). 별 2 이하 → `DROPPED2`로 이동. 한마디는 유전자 ±로.
3. 외부 아이디어: 안티그래비티(`mcp__antigravity__antigravity_prompt`, 10/30 할당량 소진·약 41시간 뒤 재개) 또는 Codex(`mcp__all-tomorrow__dispatch_task`, project `pai-games`, worker `codex`; bash에 `codex` 명령은 없음). 제출 아이디어(`tofu_ideas`)도 반영. 속도·규칙에 안 맞으면 대회에 맞게 고쳐 구현해도 된다.
4. 서브에이전트 하나 = 게임 하나, **설계서 먼저**(스크래치 `designs/<id>.md`) → `g/<id>.gd` 첫 조각. 교배는 "A의 결과가 B의 조건이 되는 인과"를 먼저 적고, 없으면 만들지 않는다.
5. 오케스트레이터만: `main.gd`(GAMES/`GAME_VER`) · `tools/smoke.gd` ALL 등록 → smoke **한 번** → 빌드 → DESIGNS.md에 설계서 붙이기 → 커밋·푸시.

## 명령 (모두 timeout 필수, 출력은 파일로)

> 10/31: `%LOCALAPPDATA%\Temp\opencode\godot\` Godot이 사라진 적 있다. 없으면 `C:\Users\fixme\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`를 쓴다. `tools/build.ps1`은 둘 중 있는 것을 고르고, 둘 다 없으면 web\을 지우기 전에 멈춘다. 커밋 전에 `web/index.pck`가 있는지 본다.

```bash
cd /c/projects/pai-games/games/speed_tofu
timeout 590 "$LOCALAPPDATA/Temp/opencode/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --fixed-fps 60 -s tools/smoke.gd -- <id들> > "$TEMP/smoke.txt" 2>&1; grep -E "ERROR|끝남|smoke done" "$TEMP/smoke.txt"
```

```powershell
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*http.server*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -Confirm:$false }; Set-Location C:\projects\pai-games\games\speed_tofu; powershell -NoProfile -ExecutionPolicy Bypass -File tools/build.ps1 > "$env:TEMP\build.txt"
```

```bash
cd /c/projects/pai-games && git add -A games/speed_tofu && git commit -m "<요약>

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" && GIT_TERMINAL_PROMPT=0 timeout 300 git -c credential.helper= -c 'credential.helper=!gh auth git-credential' push
```

- 빌드 전에 로컬 `http.server`를 꼭 끈다(`web/`를 잡고 있으면 빌드가 실패하거나 멈춘다).
- 메뉴에 등록했는데 파일이 아직 없는 게임이 있으면 메뉴에서 열 때 터진다. 미완성 자식은 주석 처리하고 빌드.
- 서브에이전트에게 git 금지를 꼭 적는다(10/30 한 에이전트가 `git stash`를 돌려 복구 소동).
- 메뉴 기호는 Pretendard에 있는 것만: ★ ☆ ◇ ◆ ▲ ● ▶ ◀ (◎ ✕ 없음).

## 사용자 규칙 (요약, 자세한 건 메모리·JAM_ANALYSIS 5절)

- 한국어로 답한다. 오케스트레이션만, 직접 작업은 등록·빌드·푸시 정도.
- 매 작업 push. 질문 최소, 자율 진행.
- **설계 깊이가 먼저**: 작동 안 해도 아이디어가 읽히면 좋은 게임. 탈락작은 "루프부터 대충, 확장 가능성 없음".
- **검증 최소**: smoke 한 번. 봇·밸런스 측정·스크린샷·브라우저 확인 안 함.
- 미니게임·표절(레퍼런스 + 우리 요소 없음)·뻔함·술래잡기·제한시간 퍼즐·읽히지 않음·속도가 왜인지 모름 = 탈락 유전자.
- 속도가 주인공, 몸의 물리 결과. 구역마다 플레이 방식 자체가 바뀐다. 죽음이 실제로 일어난다. 3D 선호, 세로 720×1280, 밝은 화면, 소리, 외곽선 상자.

## 결정은 오케스트레이터가 한다 (사용자, 10/30 20:10)

"그걸 왜 내가 답을 해. 너가 다 하는 거지." 열린 결정을 사용자에게 묻지 말고 정해서 GA.md에 기록한다.
- **제출작은 고르지 않는다**: 강화가 쌓여 v5를 넘기면(v5 → v6 차례) 제출준비작 — 아트 스타일 확정 + Codex가 이후 강화를 맡음 + 메뉴 맨 위 "● 제출준비작". 자세한 건 GA.md "제출준비작 규칙". itch.io 업로드는 사용자 계정 일이라 초안까지.
- screenrace 원작 뼈대는 유지(장르 문법). deepsword는 별 3 규칙으로 수정.
- **일격의 길(blade)과 파생작(blade_1p·blade_fp·blade_run)은 파이가 직접 한다** → speed_tofu 메뉴·smoke에서 뺐다. 다시 넣지 않는다. `games/blade_path`도 손대지 않는다.

## 현재 상태 (6세대 끝, 10/31 새벽)

- 제출준비작(● 묶음, 각자 전담 세션 — 사용자가 직접 대화, 오케스트레이터는 손대지 않음): boulder v6(`ready-boulder`, 단독판 `games/shrine_stone`, 메뉴는 STANDALONE으로 넘김), screenrace v6(`ready-screenrace`).
- 6세대 결과는 GA.md "6세대 적합도"·"유전 알고리즘 자체 수정". 다음 세대는 이들의 새 별점부터: overpower v5(다음 제출준비작 후보), phase_runner v2, tinyplanet v3, compress v2, quicksilver_fp v3, stretch_roll v3, counterweight v2, bombcrawl v2, deepsword v2, speed_snake v1, climb_race v1.
- 퍼즐 방은 퍼즐 전담(Agent model fable, effort high)이 `PUZZLE_DESIGN.md`를 읽고 짠다. 큰 파일을 한 번에 쓰면 64k 출력 한도에 걸리니 "Edit 여러 번, 한 번에 300줄 이하"를 브리프에 넣는다.
- smoke가 Godot 머리말만 찍고 멈추는 일이 두 번 있었다(다른 Godot 프로세스와 겹칠 때로 보임). 다시 돌리면 된다. 빌드 전 `Get-CimInstance Win32_Process`로 Godot이 안 도는지 본다(제출준비작 세션도 같은 web/을 빌드).

## 현재 상태 (7세대 대멸종 끝, 10/31)

- 메뉴 본 목록은 ● 2 + 생존 8개뿐(overpower, overpower_edit, quicksilver_fp, screenrace_over, tinyplanet, scale_prison, compress, stretch_roll). 멸종 10개는 2차 폐기, speed_snake·climb_race는 보류. 자세한 건 GA.md "7세대 = 대멸종".
- 다음 세대는 생존작의 새 별점부터. 새 게임을 다시 만들지는 사용자가 정한다(7세대에 "새로운 거 만들지 말자").
- 퍼즐 방 설계·수리는 프로젝트 서브에이전트 `puzzle-designer`(`.claude/agents/puzzle-designer.md`, fable/high)에게 맡긴다. 넘기기 전에 headless로 정답 CLEAR, 단순 입력 불가를 확인한다(견본 `tools/room_check_overpower.gd`).
- quicksilver_fp 메뉴 이름은 "찰나 구조대 (1인칭)"(사용자: 영화 장면에서 온 것이라 "퀵실버"는 이상함). id는 평가 때문에 그대로.
- 7세대 공통 브리프: 5세대 스크래치 폴더의 `ga7_common.md`.

## 저장소 메모

- `games/blade_path/`는 이 세션이 만든 것이 아니다(10/30 저녁에 생김, 미추적). 손대지 않았다.
- 스크래치(서브에이전트 브리프·설계서 원본): `C:\Users\fixme\AppData\Local\Temp\claude\C--projects-pai-games\a6f2a317-a6bc-4c33-a6c9-144d0650cabb\scratchpad\` — `tofu_rules.md`(공통 규칙), `design_brief.md`(설계서 양식), `ga4_upgrade.md`·`ga4_kids.md`(4세대 브리프 예시), `designs/`. 새 세션은 이 폴더를 읽을 수 있지만 지워질 수 있으니, 필요한 규칙은 위에 옮겨 두었다.
- 5세대 스크래치: `C:\Users\fixme\AppData\Local\Temp\claude\C--projects-pai-games\ff10ac5a-973a-47b8-a23c-b997192e747b\scratchpad\` — `ga5_common.md`(5세대 공통 브리프), `tofu_rules.md`, `design_brief.md`, `designs/`(이전 설계서 복사본 + 5세대분).
- **스테이지 제작 툴**(10/30 밤, 사용자 요청 "에이전트가 일하는 동안 내가 할 게 없어"): 메뉴 "▶ 스테이지 제작 (과속 플랫포머, PC 마우스)" = `g/overpower_edit.gd`(overpower.gd를 이어받음). 사용자는 **PC 웹**에서 쓴다(기능키 안 됨 → 모두 화면 버튼). 제출은 `tofu_ideas`에 `game: "overpower_stage"`로 가고, `tools/feedback.py`가 `stages/overpower/<시각>_<이름>.json`으로 꺼내 FEEDBACK.md "제출된 스테이지"에 적는다. 다음 세대에 이 방들을 overpower `ROOMS`에 넣는다(사용자가 만든 방 = 그대로 존중, 풀리는지만 확인).
