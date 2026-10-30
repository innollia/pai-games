# screenrace 제출준비 — 결정 기록 (전담 세션 ready-screenrace)

- 2026-10-30: v6 강화를 Codex 두 갈래로 나눴다. (1) 그림: 에셋·ART.md·ART_LOG.md만 만들고 코드는 안 건드림. (2) 콘텐츠: `g/screenrace.gd`만 고침. 같은 파일을 둘이 동시에 고치지 않게 하려고. 둘 다 끝나면 (3) 그림 붙이기 작업을 따로 맡긴다.
- 그림 방식: 주자·짐·기차·등불 같은 움직이는 것은 3D 저폴리(texture3d, 장면이 이미 3D 옆모습이라), 코스 뒷배경은 2D 그림(코스 6개 + 밤 등불). 크기 6MB 이하.
- `submit/screenrace/`에는 `.gdignore`를 둔다(작업용 그림이 웹 빌드에 섞이지 않게).
- 2026-10-30: 지금은 speed_tofu 안에 둔다(따로 떼지 않음). 떼게 되면: main.gd `STANDALONE`에 한 줄, 루트 index.html 링크, 평가 파이프라인(tofu_fb.js, id "screenrace", ver) 유지 — 오케스트레이터 안내.
- 2026-10-30 22:40: Codex가 OpenAI 접속 오류(403)로 연달아 죽어서, 그림 붙이기는 전담 세션(Claude)이 직접 했다(마감 우선). 배달부 4색(나=코랄), 짐, 등불, 기차, 코스 배경 4장을 붙였다. 상자·시장 가판대·다리 판 모델은 코스 상자 풀(vpool)을 바꿔야 해서 이번엔 안 붙였다 — 다음 강화 후보.
- 밤 등불 모드 배경은 bg_night가 없으면 bg_night_market을 쓴다.
- submit/screenrace/work/의 미리보기 그림(16MB)은 커밋하지 않는다. 프롬프트·스크립트만 올린다.
