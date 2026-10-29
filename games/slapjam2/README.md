# Slapjam #2 단독 게임 키트

itch.io 브라우저에서 도는 720×1280 세로 터치 게임을 AI가 바로 만들 수 있게 한 최소 뼈대. 엔진·빌드 도구·npm 없음. 순수 HTML+JS(캔버스 2D).
TIN의 Godot 앱·GameModule과 무관하다(AppRoot, `NORMAL_IDS`를 건드리지 않음). 이 폴더만 복사해 가도 된다.

## 폴더

```text
game/            ← ZIP에 들어가는 전부
  index.html     고치지 않음 (캔버스 + "탭해서 시작")
  kit.js         고치지 않음 (스케일·터치·소리 잠금 해제·저장·루프)
  game.js        ★ 게임은 여기에만 쓴다 (예제: 30초 동그라미 터뜨리기)
  assets/        그림·소리 파일 (영문 소문자·숫자·_ 파일명만)
tools/build.ps1  ZIP 한 번에 만들기 + 검사
tools/smoke_test.js  브라우저 없이 돌려 보는 자동 확인
docs/SUBMISSION_REHEARSAL.md  0시 전 제출 리허설 절차
docs/SUBMISSION_PAGE.md       제출 페이지 글·AI 도구 공개·표지/스크린샷 자리
submission/      표지·스크린샷 이미지 둘 곳 (ZIP에 안 들어감)
```

## 명령 (이 폴더에서)

```bash
node tools/smoke_test.js
```

```bash
powershell -ExecutionPolicy Bypass -File tools/build.ps1
```

결과는 `dist/slapjam2.zip`. 검사에 실패하면 ZIP을 지우고 이유를 출력한다. 로컬 확인은 `game/` 안에서 `python -m http.server`로 열고 `?debug`를 붙이면 fps가 나온다(file:// 로는 소리·에셋이 막힐 수 있다).

## AI에게 주는 규칙 (game.js 작성자용)

`game.js`는 `window.Game = { assets, init, update(dt), draw(ctx), down(x,y), move(x,y), up(x,y) }` 하나다. 전부 선택. 좌표는 720×1280, 왼쪽 위 (0,0).

- 쓸 수 있는 것: `Kit.W/H`, `Kit.sfx('tap'|'good'|'bad'|'win')`, `Kit.beep(freq,dur,type,vol,slide)`, `Kit.play(소리이름)`, `Kit.music(url)`, `Kit.stopMusic()`, `Kit.vibrate(ms)`, `Kit.save(key,val)`/`Kit.load(key,def)`, `Kit.img.이름`, `Kit.cfg.bg`(배경색), `Kit.time`.
- 파일: `Game.assets = { images: { star: 'assets/star.png' }, sounds: { hit: 'assets/hit.mp3' } }`. 상대경로, 대소문자 정확히. 없거나 실패하면 `null`이니 `if (Kit.img.star)` 로 감싼다.
- 조작: 탭·드래그만. 터치 대상은 지름 96px 이상, 손가락 여유를 둔다. 키보드·호버·더블클릭·롱프레스 금지.
- 소리: 반드시 넣는다(심사평에 "소리 없음"). 효과음은 `Kit.sfx`로 파일 없이도 난다. 배경음악은 `Kit.music`(스트리밍) 한 곡, 파일은 2MB 이하 권장. 짧은 효과음 파일만 `assets.sounds`(디코딩되어 메모리에 올라감)에 둔다.
- 밝게: 배경은 밝은 색, 대비 크게. 어두운 화면은 감점 이력이 있다. 글자는 40px 이상.
- 가볍게: 매 프레임 객체·배열·문자열 새로 만들지 않기, `shadowBlur`·`filter`·전체화면 반투명 덮기 금지, 동시에 그리는 스프라이트 수백 개 이하, 큰 이미지는 실제 표시 크기에 맞춰 줄여서 올리기(이미지 1장 1024px 이하).
- UI는 점수·남은 시간 같은 꼭 필요한 것만. 설명문·튜토리얼 긴 글·메뉴·버튼 더미 금지. 조작은 보면 알게.
- 저장: 반드시 `Kit.save/load`. itch.io는 iframe이라 `localStorage`가 막힐 수 있고, 막히면 새로고침 때 사라진다. 저장이 없어도 게임이 성립해야 한다.
- 금지: 외부 주소(CDN·폰트·이미지), `/` 로 시작하는 절대경로, `alert/prompt`, 전체화면 강제, 새 창, 서버 통신, npm 패키지.
- 오류가 나면 해당 호출만 건너뛰고 게임은 계속 돈다(콘솔 5건까지만 기록). 몰래 삼켜지니 `node tools/smoke_test.js`와 폰 실기로 확인한다.

## itch.io 설정 (프로젝트 페이지)

Kind of project: HTML → ZIP 업로드 → "This file will be played in the browser" 체크. Viewport 720×1280. Mobile friendly 켜기, Orientation: Portrait, Visibility: Public(마감 전). 한도: 압축 해제 500MB, 파일당 200MB, 파일 1000개, 경로 240자. 이 키트는 빌드 때 모두 검사한다(모바일 성능은 별개라 합계 30MB 넘으면 경고).
절차는 [docs/SUBMISSION_REHEARSAL.md](docs/SUBMISSION_REHEARSAL.md).
