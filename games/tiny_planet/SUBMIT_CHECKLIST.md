# 잼 제출 체크리스트 — 작은 행성 (Tiny Planets)

마감: **2026-11-01(일) 00:00 KST**. 마감 뒤에는 고칠 수 없으니 **10/31(토) 20~21시에 미리 제출**한다.
글(제목·설명·태그·도구)은 `../speed_tofu/submit/tinyplanet/ITCH_PAGE.md`에 있다. 복사해서 붙인다.
Rosebud 상금용 판은 이것과 따로, 잼 제출 뒤에 만든다(여기서는 itch 제출만).

## 올리기 전에 (에이전트)

- [ ] `tools\sync.ps1` → `tools\build.ps1` 로 최신 빌드를 `web\`에 만들고 커밋·push
- [ ] 폰에서 `https://innollia.github.io/pai-games/games/tiny_planet/web/` 한 판 확인(Pages 반영 1~2분)

## 올릴 파일

- 이 폴더의 `web/` 안 파일 전부를 zip 하나로 묶는다(`index.html`이 zip 맨 위에 와야 한다. 폴더째 묶지 않는다).
  아래 한 줄을 PowerShell에서 실행하면 `C:\projects\pai-games\games\tiny_planet\tiny_planet_itch.zip`이 생긴다.

```powershell
Compress-Archive -Path C:\projects\pai-games\games\tiny_planet\web\* -DestinationPath C:\projects\pai-games\games\tiny_planet\tiny_planet_itch.zip -Force
```

## itch.io에서 사람이 할 일 (계정이 필요해서 에이전트가 대신 못 함)

1. [ ] itch.io → Upload new project
2. [ ] Title: `Tiny Planets`. Short description은 ITCH_PAGE.md의 Short description을 쓴다
3. [ ] Kind of project: **HTML**. zip 업로드 후 **"This file will be played in the browser"** 체크
4. [ ] Embed options: 크기 **360 × 640**(세로), **Mobile friendly** 체크, Orientation **Portrait**, Fullscreen button 켬
5. [ ] Classification: Games. Genre: Action. Tags: ITCH_PAGE.md의 Tags
6. [ ] Description: ITCH_PAGE.md의 Long description + Controls + Tools used 붙이기
7. [ ] 표지(630×500)와 스크린샷 3장 이상: **폰에서 직접 캡처**한 밝은 장면(별 위에서 달리기, 다른 별로 날아가는 점선, 의뢰 주민과 대화)
8. [ ] Comments 켜기. Visibility는 **Public**으로 Save
9. [ ] 잼 페이지 → **Submit your project** → 이 프로젝트 선택
10. [ ] 사용 도구 체크리스트: **Claude**, **Codex/ChatGPT(OpenAI)**(GPT 그림), **Gemini(Google Antigravity)**(대사), Godot(+Blender, nkido). 설명란의 Tools used와 같게
11. [ ] 상금 연락처 이메일은 비공개 칸에 본인이 직접 입력(설명란에 쓰지 않는다)
12. [ ] 제출 후 잼 제출 목록에 보이는지, 폰에서 itch 페이지로 한 판 돌아가는지 확인
