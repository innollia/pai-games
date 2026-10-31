# 잼 제출 체크리스트 — 화면 밖 경주 (Off the Screen!)

마감: **2026-11-01(일) 00:00 KST**(10/31 15:00 UTC). 마감 뒤에는 빌드를 못 고친다. 글은 마감 전까지 잼 페이지 → Edit submission에서 고칠 수 있다.
글(제목·설명·하는 법·조작·도구·태그)은 `../speed_tofu/submit/screenrace/ITCH_PAGE.md`, `HOWTO_EN.md`에 있다. 복사해서 붙인다.

## 준비된 것 (v43)

| 무엇 | 어디 |
| --- | --- |
| 올릴 zip (web/ 안 파일 전부, index.html이 맨 위) | `games/off_screen/off_screen_itch.zip` (저장소에는 안 넣음, 약 20MB) |
| 표지 630×500 | `../speed_tofu/submit/screenrace/cover.png` |
| 16:9 표지 1920×1080 | `../speed_tofu/submit/screenrace/cover_16x9.png` |
| 세로 스크린샷 5장 (720×1280) | `../speed_tofu/submit/screenrace/shots/` |

zip을 다시 만들려면 (빌드한 뒤):

```powershell
Compress-Archive -Path C:\projects\pai-games\games\off_screen\web\* -DestinationPath C:\projects\pai-games\games\off_screen\off_screen_itch.zip -Force
```

## itch.io에서 사람이 할 일 (계정이 필요해서 에이전트가 대신 못 함)

1. [ ] itch.io → Upload new project. Title `Off the Screen!`, Short description은 ITCH_PAGE.md의 것
2. [ ] Kind of project: **HTML** → zip 업로드 → **"This file will be played in the browser"** 체크
3. [ ] Embed options: 크기 **360 × 640**(세로! 가로로 두면 양옆이 검게 나온다), **Mobile friendly** 체크, Orientation **Portrait**, Fullscreen button 켬
4. [ ] Description 순서: Long description → "How to play"(HOWTO_EN.md) → Controls → Tools used
5. [ ] Genre: Action. Tags: ITCH_PAGE.md의 Tags. Cover: cover.png. Screenshots: shots/ 5장
6. [ ] Comments 켜기, Visibility **Public**으로 Save
7. [ ] 잼 페이지 → **Submit your project** → 이 프로젝트 선택
8. [ ] 상금 연락처 이메일은 비공개 칸에 직접 입력(설명란에 쓰지 않는다)
9. [ ] 도구 체크리스트(Convai, Rosebud, Jamboree, Ziva, AutoSprite, PixelLab, None of these): 이 목록 도구는 안 썼으니 **None of these** 하나만(또는 비움). Rosebud는 Rosebud 플레이 주소가 실제로 생긴 뒤에만 체크. 잘못 눌렀으면 다시 눌러 해제
10. [ ] 제출 뒤 `https://<계정>.itch.io/<게임>`을 열어 Run game으로 한 판 돌아가는지, 세로 창인지, 소리가 나는지 확인

## Rosebud $100 상 (Best Game Hosted on Rosebud, 본상과 중복 가능)

1. [ ] 같은 zip(`off_screen_itch.zip`, 안의 파일 이름을 바꾸지 말 것)을 Rosebud 신청서 https://forms.gle/BhVwP4vpVKjP13j88 에 직접 제출(개인정보 양식). 처리 시간이 공개되지 않았으니 지금 바로 낸다. 문의 support@rosebudai.com
2. [ ] Rosebud 주소가 나오면 itch 설명 맨 아래에 `Also playable on Rosebud: <주소>` 한 줄, 잼 도구 체크리스트에 Rosebud 체크
