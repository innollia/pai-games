# 어린 배달부 — 지금(v8) 모듈 약속

본체·ui·fx 사이의 지금 약속을 적는다. v5에 병렬 작업용으로 만들었고 v8 코드에 맞춰 고쳤다.

`g/tinyplanet.gd`(게임 본체)는 아래 두 도우미를 `preload`해서 자식 Node로 붙이고, 훅만 부른다. 도우미는 본체 변수 이름에 기대지 않는다 — 필요한 건 전부 `s`(상태 사전)와 이벤트 인자로 받는다.

## 공통
- 두 파일 모두 `extends Node`, `class_name` 없음(웹·smoke에서 전역 이름 충돌 방지).
- `func setup(game: Node) -> void` — game은 Tofu 서브클래스. 쓸 수 있는 것: `game.cam: Camera3D`, `game.world: Node3D`, `game._font: Font`(Pretendard-Bold), `game.over: bool`, `game.restart()`, `game.add_child()`, 상수 색 `game.A/B/C/D/GOOD/BAD/INK/WHITE`(tofu.gd). 그 밖의 본체 변수는 건드리지 않는다.
- `func tick(dt: float, s: Dictionary) -> void` — 매 프레임 본체의 `_step` 끝에서 부른다. `s` 키(모두 있음):
  - `speed: float`(접선/비행 속도 크기), `top: float`(땅 최고 속도 12.5), `lift: float`(이륙선 대비 0..1+, 1 넘으면 뜸), `esc: float`(탈출선 대비 에너지 0..1+), `grounded: bool`, `flying: bool`(어느 별 영향권도 아닌 곳 포함, 발이 떠 있음), `pos: Vector3`(나 전역 위치), `vel: Vector3`(전역 속도), `up: Vector3`(발밑 별에서 바깥 방향), `fwd: Vector3`, `me: Node3D`(내 몸 노드), `sky: Color`(지금 하늘색), `planet: int`(발밑 별 번호), `paused: bool`(말풍선·카드로 멈춤).
- `func event(name: String, d := {}) -> void` — 일이 일어날 때 본체가 부른다. 이름 목록:
  `step, liftoff, escape(d.from), atmo(d.k), slingshot, land(d.hard: bool, d.speed), orbit_land, sail, drift_warn, die(d.why), respawn, meteor_warn(d.pos), meteor_hit(d.pos), pickup(d.item), drop, deliver(d.job, d.pos), crack, shatter, job_start(d.job), job_done(d.job), windmill_wake, new_planet(d.k), score(d.n, d.pos), finish`.
- 화면: 720×1280 세로 기준 좌표. 글꼴은 `game._font` 하나. 색은 아래 디자인 시스템만.

## 디자인 시스템 (두 파일이 같은 값을 쓴다 — `tinyplanet_ui.gd`에 `const DS := {...}`로 두고 fx도 같은 숫자를 복사)
- 주요 색: 크림 `#fff6e6`(패널 바탕), 잉크 남색 `#2b2d42`(글자·테두리), 하늘 `#9fd3ff`, 민트 `#8fe3c2`, 라벤더 `#b9a7f2`. **강조색 하나: 노랑 `#ffd166`**(시작 버튼, 목표, 좋은 순간). **빨강 `#e8453c`은 위험에만.**
- 패널·버튼·말풍선: 모서리 반지름 28, 테두리 6px 잉크, 그림자 = 아래로 8px 잉크 40% 단색(흐림 없음). 버튼 누르면 0.92배로 줄었다 0.12초에 돌아옴(+탭 소리 `ui_tap`).
- 글자 크기: 제목 84, 큰 버튼 52, 본문 34, 작은 안내 26. 글자에 잉크 외곽선 6.
- 소리: 본체의 `sfx(nm, db, pitch)`가 있으면 `game.call("sfx", ...)`로 부른다(`has_method`로 확인).

## tinyplanet_ui.gd (시작 화면·언어 전환·끝 화면)
- `show_title(on_start: Callable)`: 시작 화면. 제목 로고(한/영), 납작한 노란 시작 버튼, 오른쪽 아래 "EN | 한국어" 전환(`game.set_lang(ko)`를 부름, `user://tinyplanet.cfg`에 저장). `title_visible()`, `is_korean()`, `refresh_text()`도 있다.
- 튜토리얼: **없음(v6에서 뺌).** `tutorial_active()`는 늘 false, `tutorial_step()`은 -1, `start_tutorial/skip_tutorial`은 빈 함수(옛 호출용).
- v10 도움 힌트: `todo_nudge(on)`(할 일 버튼이 숨쉼, 목록을 열면 멈춤), `todo_seen`(목록을 연 수). 힌트 글·셈은 본체 `_help_*`.
- 게임오버(목숨 0)·엔딩(finish) 화면: 같은 패널 규칙. 엔딩은 배달한 수, 걸린 시간, 새총 수, 최고 기록, "다시" 버튼.
- 점수 팝: `event("score")`에서 숫자가 위로 튀어 올라 0.8초에 사라짐(화면 좌표는 `game.cam.unproject_position(d.pos)`).
- 모든 한국어 글자는 `tr()`로 감싸고, 파일 아래에 `const EN := {"한국어": "English", ...}`를 둔다(본체가 번역 서버에 합친다).

## tinyplanet_fx.gd (속도감·연출)
- 본체는 `setup` 뒤 `set_bodies(centers, radii)`를 한 번 부른다(구름 둘 자리).
- `drift_warn`(우주 미아·떠내려감 경고) → 화면 가장자리가 1.4초에 걸쳐 천천히 어둑해졌다 1.2초에 돌아옴(v8, 빨간 번쩍 대신).
- 속도선: 화면 가장자리에서 가운데로 모이는 흰 선(CanvasLayer, 2D 선 40개 정도), 세기 = 속도 비율. 날 때 더 길게.
- FOV: 기본 + lift에 따라 최대 +18도, 부드럽게.
- 발 먼지: 땅에서 빠를 때 발뒤로 작은 크림색 로우폴리 조각이 튐(CPUParticles3D, 웹 호환).
- 꼬리 잔상: 날 때 몸 뒤로 노란 리본/점 꼬리(ImmediateMesh 또는 점 MeshInstance 20개 재사용).
- 별 줄무늬: 영향권 밖을 날 때 멀리 작은 별이 속도 방향 반대로 길게 늘어남.
- 구름: 각 별 둘레에 큰 흰 로우폴리 구름 덩어리 3~5개가 천천히 돈다(분위기 레퍼런스: 큰 흰 구름).
- 부딪힘: `land(hard)`/`meteor_hit`/`die` → 작고 부드러운 흔들림 0.45초(v7: 흰 번쩍 없음)(카메라 h_offset/v_offset만 건드려 본체 카메라 계산과 안 싸운다).
- 성공: `deliver`/`job_done` → 노랑·민트 로우폴리 조각 파티클 터짐 + 화면 가장자리 노란 빛 0.4초.
- 대표 장면 (C): `escape` 이벤트 → 0.9초 동안 `Engine.time_scale` 0.35로 늦추고, 카메라를 뒤로 크게 빼서(h/v offset이 아니라 `cam.fov`를 넓히고 화면 가장자리 비네트) 하늘의 별들이 한눈에 보이게 한 뒤, 속도선 폭발과 함께 원래로. time_scale은 반드시 원래 1로 되돌린다(죽음·재시작에서도).
- 대기 진입 `atmo`: 화면 가장자리에 그 별 하늘색 테가 0.5초 번짐.
- 성능: 폰 웹. 노드 수 적게, 매 프레임 new 금지(풀 재사용).
