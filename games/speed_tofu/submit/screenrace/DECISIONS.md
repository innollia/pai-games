# screenrace 제출준비 — 결정 기록 (전담 세션 ready-screenrace)

- 2026-10-30: v6 강화를 Codex 두 갈래로 나눴다. (1) 그림: 에셋·ART.md·ART_LOG.md만 만들고 코드는 안 건드림. (2) 콘텐츠: `g/screenrace.gd`만 고침. 같은 파일을 둘이 동시에 고치지 않게 하려고. 둘 다 끝나면 (3) 그림 붙이기 작업을 따로 맡긴다.
- 그림 방식: 주자·짐·기차·등불 같은 움직이는 것은 3D 저폴리(texture3d, 장면이 이미 3D 옆모습이라), 코스 뒷배경은 2D 그림(코스 6개 + 밤 등불). 크기 6MB 이하.
- `submit/screenrace/`에는 `.gdignore`를 둔다(작업용 그림이 웹 빌드에 섞이지 않게).
- 2026-10-30: 지금은 speed_tofu 안에 둔다(따로 떼지 않음). 떼게 되면: main.gd `STANDALONE`에 한 줄, 루트 index.html 링크, 평가 파이프라인(tofu_fb.js, id "screenrace", ver) 유지 — 오케스트레이터 안내.
