# Rock and Stone (단독판, 잼 제출본)

speed_tofu의 `boulder`(굴러라 신전석)를 메뉴 없이 따로 띄우는 Godot 프로젝트다.

- 플레이: `https://innollia.github.io/pai-games/games/shrine_stone/web/`
- 게임 설명, 결정 사항, 문서 안내: [../speed_tofu/submit/boulder/README.md](../speed_tofu/submit/boulder/README.md)
- 제출 순서: [SUBMIT_CHECKLIST.md](SUBMIT_CHECKLIST.md)

## 무엇이 어디서 오나

게임 강화는 speed_tofu에서 한다. 이 폴더는 `tools\sync.ps1`로 그것을 가져온 뒤 빌드만 한다.

| 이 폴더 | 출처 |
|---|---|
| `g/boulder.gd`, `art/boulder/`(그림·효과음·GPT UI·FX), `fonts/cinzel/`, `tools/tofu_fb.js` | speed_tofu에서 복사한다(`.import`는 새로 만든다) |
| `tofu.gd` | speed_tofu 것에서 "< 메뉴"만 "< 처음부터"로 바꿔 복사한다 |
| `main.gd` | **이 폴더만의 파일이다.** 아래 내용을 직접 고친다 |
| `project.godot`, `export_presets.cfg` | 이 폴더만의 파일이다 |

**`main.gd`가 하는 일**
- 타이틀 화면을 띄운다: 신전 상인방 제목판, Play 버튼, 언어 버튼.
- 주소 끝 표시를 읽는다.
  - `?zone=N`: N구역부터 시작한다.
  - `?lang=ko`: 한국어로 띄운다.
  - `?from=tofu`: SPEED 두부 목록에서 들어온 것으로 보고, "< 처음부터" 대신 "< 목록"을 띄운다.
- `GVER`는 sync.ps1이 맞춘다.

**`project.godot`·`export_presets.cfg` 설정**
- 프로젝트 이름: Rock and Stone
- 웹 오디오: Stream
- 스레드: 끔
- `tofu_fb.js`(별점·한마디 → Firestore `tofu_ratings`, id `boulder`)를 html에 넣는다.

## 빌드

```
powershell -ExecutionPolicy Bypass -File tools\sync.ps1
powershell -ExecutionPolicy Bypass -File tools\build.ps1
```

결과는 `web/`에 나오고, GitHub Pages가 그대로 서빙한다. 고친 뒤 브라우저에 예전 `index.pck`가 남아 빈 화면이 보이면, 강력 새로고침을 한다.
