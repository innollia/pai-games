# 잼 제출 체크리스트 — 화면 밖 경주 (Off the Screen!)

마감: 2026-11-01(일) 00:00 KST (10/31 15:00 UTC). 마감 뒤에는 빌드를 못 고친다. 글은 마감 전까지 잼 페이지 → Edit submission에서 고칠 수 있다.
이 파일 하나에 올릴 파일 위치와 붙여 넣을 글이 모두 있다. 위에서부터 차례로 하면 된다.

## 1. 올릴 파일 위치

- 게임 zip (itch와 Rosebud 둘 다 이것):
  C:\projects\pai-games\games\off_screen\off_screen_itch.zip
- 표지 630×500 (itch Cover image):
  C:\projects\pai-games\games\speed_tofu\submit\screenrace\cover.png
- 16:9 표지 1920×1080:
  C:\projects\pai-games\games\speed_tofu\submit\screenrace\cover_16x9.png
- 세로 스크린샷 5장 (720×1280):
  C:\projects\pai-games\games\speed_tofu\submit\screenrace\shots\01_01_title.png
  C:\projects\pai-games\games\speed_tofu\submit\screenrace\shots\02_06_race.png
  C:\projects\pai-games\games\speed_tofu\submit\screenrace\shots\03_07b_deliver.png
  C:\projects\pai-games\games\speed_tofu\submit\screenrace\shots\04_08_edge_moment.png
  C:\projects\pai-games\games\speed_tofu\submit\screenrace\shots\05_08b_last_call.png

## 2. itch.io 새 프로젝트 (itch.io → Upload new project)

- [ ] Title (복사):

```
Off the Screen!
```

- [ ] Short description (복사, 120자 이내):

```
Race 3 rival couriers and post the most parcels. Lead too fast and you overshoot the mailboxes.
```

- [ ] Kind of project: HTML → 위 zip 업로드 → "This file will be played in the browser" 체크
- [ ] Embed options: 크기 360 × 640 (세로! 가로면 양옆이 검게 나온다), Mobile friendly 체크, Orientation Portrait, Fullscreen button 켬
- [ ] Description (아래 통째로 복사. 긴 설명 → How to play → Controls → Tools used 순서가 이미 맞춰져 있다):

```
Off the Screen! — race three rival couriers across six bright paper-craft towns. The winner is not the last one standing but whoever DELIVERS the most parcels. When a red mailbox is on screen, the BOX button turns green: tap it and your parcel flies in. Each mailbox takes one parcel, first come first served — and the gold mailbox before the finish takes up to 3 parcels at once. Reach the finish line first for +1 more.

The camera follows the leader and leans ahead as they speed up, and a dash shoves the view even further — so a reckless front-runner overshoots mailboxes while the couriers tucked in behind grab them. When to lead and when to follow is the whole race. Fall off the torn left edge of the page and you're "returned to sender": you drop a parcel and climb back in. Fall too far behind and a catch-up boost brings you back into the fight.

The screen's side walls are built from every parcel being carried, taped in each courier's color. Deliver, throw or lose a parcel and a brick pops out of the wall — the screen gets narrower and the race gets tighter. Parcels are also weight: carry more and you run slower and jump lower. Tap BOX away from a mailbox to throw one backward for a burst of speed — but every thrown parcel lands on the road for a rival to pick up and deliver.

Each course plays differently: flowing riverbanks, a railway crossing with a train coming at you, blackouts in the night market, a rope bridge that cracks under heavy runners, rooftops with no walls. Crates and walls have ramps: walk up and you slow down (more with heavy parcels), jump over and you keep your speed. Every round mixes in a new road — a low gate that only lets 4 parcels through and knocks the rest off your back, an ice slide, or a headwind — announced at the start line.

New spots flip the answer: scales launch heavy runners up, updrafts lift light ones, trapdoors break under heavy feet, shutters slam on whoever leads. Right after you learn one, it is mixed with an older one.

Each town is won by taking 2 rounds; a round is a short ~30-second dash. Finish all six towns and the final delivery, earn gold/silver/bronze per town, and beat your best delivery record.

Theme: Speed — speed costs you: the leader can't see the mailboxes ahead, and the fastest way to go faster is to throw away the parcels you're supposed to deliver.

How to play

Your courier wears a blue marker with your parcel count. Push the stick right to run, tap JUMP to hop. Win a round by DELIVERING the most parcels: when a red mailbox is on screen the BOX button turns green — tap it and your parcel flies in (each mailbox takes one parcel). The gold mailbox before the finish takes up to 3 parcels at once, and the first courier across the finish line gets +1. Tap BOX anywhere else to throw a parcel backward for a speed dash (0.9 s cooldown); thrown parcels land on the road for rivals to grab.

The camera follows the leader. Run fast in front and you see less ahead — easy to overshoot mailboxes. Following close behind shows you the mailboxes coming.

You start each round with 8 parcels stacked on your back; each one slows you a little. Fall off the torn LEFT edge and you drop a parcel and climb back in (with an empty back you get one parcel back). The side walls of the screen are made of every parcel being carried; as parcels are delivered, thrown or lost, the screen gets narrower. Falling behind gives you a catch-up boost; if you stop playing, a "Give up?" button appears.

When the first courier crosses the finish, 3 seconds of LAST CALL, then the round ends and a board shows who won. A low gate only lets 4 parcels through: push into it and extra parcels get knocked off. Keyboard: arrows/A-D run, Up/W/Space jump, Down/S/Shift BOX. Six towns, 2 round wins each, then the final delivery. Earn gold/silver/bronze per town and beat your best delivery count.

Controls

Stick left/right to run, JUMP to hop, BOX to deliver (green near a mailbox) or throw a parcel for a dash. A short hands-on tutorial teaches it in 30 seconds. Portrait, touch. On a computer: arrow keys or A/D to run, Up/W/Space to jump, Down/S/Shift for BOX, Enter to start. Sound on!

Tools used / AI disclosure

Made by 핸섬가이즈 with AI tools.
Tools used: Godot, Claude (Anthropic), Codex (OpenAI), GPT image generation (OpenAI), Gemini (Google), Blender, nkido.
Code, planning and text were developed with Claude and Codex; Gemini (Google, via Antigravity) wrote the UI design spec and reviewed screenshots. Character and prop textures were painted with OpenAI image generation onto low-poly models built in Blender (texture3d pipeline); course backdrops are OpenAI-generated paintings. The cover image was made with OpenAI image generation. Sound effects were built from raw oscillators and noise rendered with nkido (MIT, no samples) and shaped in Python (numpy/scipy); no AI-generated audio. UI font: Pretendard. English is the default language; Korean is one tap away.
```

- [ ] Classification: Games. Genre: Action
- [ ] Tags (복사):

```
ai, mobile, portrait, touch, slapjam, speed, racing, party, side-scroller, low-poly
```

- [ ] Cover image: cover.png. Screenshots: 위 5장
- [ ] Comments 켜기, Visibility Public → Save

## 3. 잼 제출 (잼 페이지 → Submit your project)

- [ ] 방금 만든 프로젝트 선택
- [ ] 상금 연락처 이메일: 비공개 칸에 직접 입력 (설명란에 쓰지 않는다)
- [ ] 도구 체크리스트 (Convai, Rosebud, Jamboree, Ziva, AutoSprite, PixelLab, None of these): None of these 하나만 체크(또는 비움). Rosebud는 Rosebud 플레이 주소가 실제로 생긴 뒤에만 체크. 잘못 눌렀으면 다시 눌러 해제
- [ ] 제출 뒤 itch 게임 페이지를 열어 Run game으로 한 판: 세로 창인지, 소리가 나는지 확인

## 4. Rosebud $100 상 (Best Game Hosted on Rosebud, 본상과 중복 가능)

- [ ] 같은 zip(안의 파일 이름을 바꾸지 말 것)을 신청서에 직접 제출. 처리 시간이 공개되지 않았으니 지금 바로 낸다:
  https://forms.gle/BhVwP4vpVKjP13j88
  문의: support@rosebudai.com
- [ ] Rosebud 주소가 나오면 itch 설명 맨 아래에 한 줄 추가하고, 잼 도구 체크리스트에서 Rosebud 체크 (None of these는 해제):

```
Also playable on Rosebud: <주소>
```

## 참고

- 폰에서 먼저 해 볼 곳: https://innollia.github.io/pai-games/games/off_screen/web/
- zip을 다시 만들 때 (PowerShell, 빌드 뒤):

```
Compress-Archive -Path C:\projects\pai-games\games\off_screen\web\* -DestinationPath C:\projects\pai-games\games\off_screen\off_screen_itch.zip -Force
```
