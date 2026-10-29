# Slapjam #2 Godot 키트

TINProject 흐름(Godot 4.7.2, GL Compatibility, 웹 export)을 따르는 단독 키트. 본 프로젝트(`project.godot`, AppRoot, `NORMAL_IDS`)와 별개의 Godot 프로젝트라서 이 폴더만 열면 된다. 같은 요건의 순수 HTML 키트(`../slapjam2/`)는 비상용 대안으로 남겨 둔다.

TIN에서 가져온 것: 웹 설정 값(thread/extensions 끔, `audio/general/default_playback_type.web=0` = 오디오 Stream, GL Compatibility), Pretendard Bold 폰트(OFL), export 템플릿 위치, 콘솔 Godot 경로(`%LOCALAPPDATA%\Temp\opencode\godot\Godot_v4.7.2-stable_win64_console.exe`).

## 폴더

```text
project.godot        720x1280, 세로, stretch canvas_items/keep, 밝은 배경
main.tscn / main.gd  ★ 게임은 main.gd 에 쓴다 (예제: 30초 동그라미 터뜨리기)
fonts/               한글 폰트 (웹에는 시스템 폰트가 없어 필수)
export_presets.cfg   Web 프리셋 (스레드 끔)
tools/build_godot.ps1  export + ZIP + 검사를 한 번에
tools/zip_check.ps1    ZIP 만들기·itch.io 한도 검사 (build_godot.ps1 이 호출)
```

## 명령 (이 폴더에서)

```bash
powershell -ExecutionPolicy Bypass -File tools/build_godot.ps1
```

결과 `dist/slapjam2_godot.zip`. 검사 실패 시 ZIP을 지운다. 현재 크기: wasm 약 38MB(압축 ZIP 약 11MB), 합계 경고가 뜨는 것은 정상이다(엔진 크기. 로딩이 느린지는 실기 확인).

## AI에게 주는 규칙 (main.gd 작성자용)

- 좌표 720×1280, 왼쪽 위 (0,0). 입력은 `InputEventMouseButton` 왼쪽 클릭만 쓴다(터치는 엔진이 마우스로 변환. `InputEventScreenTouch`까지 받으면 두 번 처리된다). 키보드·호버 금지.
- 첫 탭 전에는 소리를 내지 않는다(예제의 "탭해서 시작"). 웹은 첫 입력 뒤에야 오디오가 켜진다.
- 효과음은 예제의 `_tone()`처럼 코드로 만들거나 `.ogg/.wav`를 `AudioStreamPlayer`로 재생한다. **웹 오디오는 Stream 방식**(설정됨, 바꾸지 않는다). 긴 음악은 `.ogg` 한 곡만.
- 한글 글자는 `fonts/Pretendard-Bold.otf` 폰트로 직접 그린다. 기본 폰트에는 한글이 없다.
- 가볍게: `_process`에서 노드를 만들지 않는다(예제는 `_draw`로 도형만 그림). `Shader`·`GPUParticles`·광원·그림자·`CanvasItem` 반투명 전체 덮기 금지. 텍스처는 표시 크기에 맞춰 줄여서 넣는다. 최대 FPS 60 고정.
- 저장은 `user://`(웹에서는 브라우저 저장소). itch.io iframe에서 막히면 사라지므로 저장이 없어도 게임이 성립해야 한다.
- 금지: 스레드, GDExtension, C#, 외부 주소, `OS.shell_open`, 새 autoload, 3D.
- UI는 점수·남은 시간처럼 꼭 필요한 것만. 긴 글과 메뉴 금지. 배경은 밝게.
- 창 포커스가 사라지면 멈추고 음소거한다(예제 `_notification`).

## 검증 상태 (이 PC)

- 헤드리스 import·export 성공, 120프레임 실행에서 스크립트 오류 없음, ZIP 검사 통과.
- 실제 폰·브라우저에서의 터치, 소리, 로딩 시간은 **미확인**이다. 리허설(`../slapjam2/docs/SUBMISSION_REHEARSAL.md`)에서 반드시 확인한다. 특히 iPhone 11급에서 wasm 로딩 시간과 첫 탭 소리를 본다. 느리거나 소리가 없으면 HTML 키트로 갈아탄다.

itch.io 설정과 제출 절차는 `../slapjam2/docs/`의 SUBMISSION_REHEARSAL.md, SUBMISSION_PAGE.md를 그대로 쓴다.
