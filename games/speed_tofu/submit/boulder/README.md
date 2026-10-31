# Rock and Stone (굴러라 신전석) — 문서 안내

슬랩잼 제출작. 게임 id는 `boulder`이고, 지금 버전은 **v14**이다.

**어디서 하나**
- 고치는 곳: `games/speed_tofu/g/boulder.gd`, `art/boulder/`
- 제출본(단독판): `games/shrine_stone/`
- 플레이: https://innollia.github.io/pai-games/games/shrine_stone/web/
- 확인용 주소: `?zone=N`(N구역부터), `?lang=ko`(한국어 검수)

## 게임 한 줄

깔수록 커지고, 커질수록 느려진다. 몸을 떼어 내(쪼개기·던지기) 빠르게 바다 신전까지 굴러간다. **주제는 speed다.**

## 지금 들어 있는 것 (v11)

**코스**
- 11구역이고, 구역마다 시점과 동작이 바뀐다.
- 동작은 끌어 조향, 뛰기, 쪼개기(1.3초 돌진), 버티기(땅에서는 제동, 공중에서는 내려찍기), 던지기다.

**구역별**
- **2구역 수로:** 밑에 90m 협곡이 있다. 떨어지면 공간이 이어진 채 잠든 지하 신전까지 떨어진다. 구역 끝까지 지하 길을 달리고, 물기둥을 타고 위로 돌아온다.
- **4구역 절벽:**
  - 버티기로 착지하는 자리에 탑이 있다.
  - 탑 무리 광장이 있다.
  - 두 단 절벽 아래에 황금 신상이 있다.
- **흔들다리:** v14에서 뺐다(표지판이 직관적이지 않았다). 그 자리는 보통 길이다.
- **절벽 착지:** v14부터 착지 자리를 파란 지붕 탑이 통째로 덮는다. 떨어지며 버티기로 깨야만 지나간다.
- **2구역 지하(v13):** 바위 아치 동굴, 순풍 길(금빛 바람 줄)로 지상 복귀.

**길 고르기**
- **숨은 지름길 7개:** 모두 속도와 이어져 있다. 바람 줄, 끊긴 경계 줄, 버튼 색 봉인, 42m/s 눈금으로 알려 준다.
- **갈림길:**
  - 입구 바닥 화살표가 고를 쪽을 금빛으로 보여 준다.
  - 고르지 않은 갈래는 지운다.
  - 갈림길을 지난 뒤 35m는 길 가장자리가 난간이다.

**화면**
- **타이틀:** GPT가 그린 신전 상인방에 ROCK AND STONE을 새겼다. Play 버튼과 언어 버튼이 있다.
- **UI:**
  - GPT가 그린 구아슈 돌 UI다(판, 버튼, 명패, 메달, 게이지 틀).
  - 영어 글꼴은 Cinzel이다.
  - 모서리는 깎은 각이다.
  - 화면 위에는 큰 속도 숫자와 짧은 바만 둔다.
- **효과:**
  - 돌판 도장(의성어)이 찍힌다.
  - 부서진 물건 그림을 입은 조각이 튄다.
  - 바람은 GPT가 그린 모래 바람결이다.
  - 효과음은 nkido로 만든 22개다.
- **실패:** 의성어 한 단어로 보여 준다. 실패해도 최고 점수는 남는다.

## 사용자가 정한 것 (다시 묻지 말 것)

- **언어:** 영어가 기본이다. 한국어는 검수용(`?lang=ko`)이고 글꼴은 Pretendard 그대로다.
- **효과 글:** 흔한 "쾅!·+40" 팝업은 쓰지 않는다. 신전 돌에 새긴 모양처럼 이 게임다운 모양만 쓴다.
- **유물·수집 시스템:** 쓰지 않는다. 숨은 길의 보상은 시간과 속도뿐이다.
- **튜토리얼:** 따로 두지 않는다. 길 위 안내가 맡는다.
- **UI:** 덜어 낸다. 둥근 모서리와 둥근 글꼴은 쓰지 않는다. 기본 도형도 쓰지 않는다.
- **지하:** 보라 배경을 바꿔 끼우는 식으로 하지 않는다. 공간이 이어져야 한다.

## 파일 안내

| 파일 | 무엇 |
|---|---|
| `ITCH_PAGE.md` | itch.io에 붙일 글: 제목, 설명, 조작, 태그, 사용 도구 |
| `HOWTO_EN.md` | itch 설명의 "How to play" 부분 |
| `ART_LOG.md` · `ASSET_MANIFEST.json` · `VERIFICATION.md` | 3D 모델 9개(GPT 텍스처) 만든 기록. v6 때 기록이다 |
| `UI_ART.md` | GPT UI 그림 7장의 크기, 9-slice 여백, 프롬프트 (`art/boulder/ui_gpt/`) |
| `FX_ART.md` | GPT 바람·흙먼지 그림 8장 (`art/boulder/fx_gpt/`) |
| `SFX_MANIFEST.json` · `build_sfx.py` | 효과음 22개. nkido로 만들고 numpy·scipy로 다듬었다 (`art/boulder/sfx/`) |
| `build_art.py` 등 `*.py` | 3D 모델·텍스처 파이프라인(v6). 작은 행성 세션이 참고하므로 자리를 옮기지 않는다 |
| `archive/` | 끝난 작업 지시서와 v6 아트 방향 문서 |
| `work/` | 작업 파일. git에 넣지 않는다 |

제출 순서는 `games/shrine_stone/SUBMIT_CHECKLIST.md`에 있다.

## 고친 뒤 올리는 순서

1. `games/speed_tofu`에서 smoke를 한 번 돌린다.
   ```
   "$LOCALAPPDATA/Temp/opencode/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --fixed-fps 60 -s tools/smoke.gd -- boulder
   ```
2. `games/shrine_stone/tools/sync.ps1`을 실행한 뒤 `build.ps1`을 실행한다.
3. boulder·shrine_stone 파일만 commit하고 push한다.
   - main.gd에서는 `GAME_VER["boulder"]` 숫자만 바꾼다.
   - push 명령: `git -c credential.helper= -c 'credential.helper=!gh auth git-credential' push`
