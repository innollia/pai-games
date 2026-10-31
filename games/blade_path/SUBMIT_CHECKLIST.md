# 잼 제출 체크리스트 — 일격의 길 (Blade Path)

돌굴리기(Rock and Stone) 체크리스트를 본떠 만들었다(10/31 인계).
마감: **2026-11-01(일) 00:00 KST**. 마감 뒤에는 못 고치니 **10/31(토) 20~21시에 미리 제출**한다.
itch 글은 `ITCH_PAGE.md`, "How to play"는 `HOWTO_EN.md`.

## 언어 (영어 기본)
- 영어가 본 게임. 로비 [설정] → "한국어로 바꾸기" / "Switch to English" (저장됨).
- 번역표: `g/blade.gd` 의 `const EN := {"한국어 원문": "English"}`. **새 글을 넣으면 EN 에도 넣는다**(없으면 영어판에 한국어가 뜬다). 같은 키 두 번 = 파싱 오류.
- 서식 글(%d)은 `tr("...%d...") % 값`. Label 에 그대로 넣는 글은 저절로 번역된다.
- 개발 도구 [대사 편집]은 지금 언어판의 글만 고친다(영어판 → `BAKED_TEXT_EN`, 한국어판 → `BAKED_TEXT`). 비워 두면 빈 글이 된다.

## 올릴 파일
1. 고친 뒤: `powershell -ExecutionPolicy Bypass -File tools\build.ps1` → commit·push → 폰 링크로 한 판 확인
   (`https://innollia.github.io/pai-games/games/blade_path/web/`, Ctrl+F5).
2. itch zip: `powershell -ExecutionPolicy Bypass -File tools\itch_zip.ps1` → `blade_path_itch.zip`.
   **개발 도구(g/dev.gd)를 뺀 빌드**라서 [개발] 버튼이 없다. web/ (Pages 판)은 개발 버튼이 그대로 남는다. zip 은 git 에 안 넣는다.
3. 그 전에 파이가 [내보내기]한 글·UI 자리가 있으면 `BAKED_TEXT` / `BAKED_TEXT_EN` / `BAKED_UI` 에 넣고 빌드.

## 제출 전 확인 (게임)
- [ ] 영어판 첫 화면·튜토리얼·전투·능력 카드·로비 3탭·설정에 한국어가 안 남았는지
- [ ] 한국어로 바꾸면 전부 한국어로 돌아오는지
- [ ] zip 판에 [개발] 버튼이 없는지
- [ ] ITCH_PAGE.md 가 지금 게임 내용과 맞는지(바뀐 기능이 있으면 글도 고친다)
- [ ] ITCH_PAGE.md 의 [파이 확인] 칸(배경 그림·효과음 출처) 채우기

## itch.io에서 사람이 할 일 (계정이 필요해서 에이전트가 대신 못 함)
1. [ ] itch.io → Upload new project
2. [ ] Title: `Blade Path`. Short description은 ITCH_PAGE.md 것
3. [ ] Kind of project: **HTML**. zip 업로드 후 **"This file will be played in the browser"** 체크
4. [ ] Embed: **360 × 640**(세로), **Mobile friendly**, Orientation **Portrait**, Fullscreen button 켬
5. [ ] Classification: Games. Genre: Action. Tags: ITCH_PAGE.md 것
6. [ ] Description: Long description + HOWTO_EN.md + Controls + Tools used
7. [ ] 표지(630×500) + 스크린샷 3장 이상: **폰에서 직접 캡처**(간파 금빛 충격파, 능력 카드, 끝판왕)
8. [ ] Comments 켜기. Visibility **Public**으로 Save
9. [ ] 잼 페이지 → **Submit your project** → 이 프로젝트
10. [ ] 사용 도구 체크: Claude, Godot 4.7, 그 밖에 배경·소리에 쓴 도구(없는 칸은 Other). 설명란 Tools used와 같게
11. [ ] 상금 연락처 이메일은 비공개 칸에 본인이 직접(설명란에 쓰지 않는다)
12. [ ] 제출 후 잼 목록에 보이는지, 폰에서 itch 페이지로 한 판 확인
