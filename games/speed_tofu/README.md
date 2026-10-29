# SPEED 두부

slap jam #2 주제 **speed**의 코어 루프 시험판. 상자만 쓰는 Godot 4.7.2 3D(GL Compatibility, 720×1280 세로 터치). 플레이: `https://innollia.github.io/pai-games/games/speed_tofu/web/`

| id | 이름 | 조작 · 루프 |
| --- | --- | --- |
| bigball | 큰 공 굴리기 | 좌우로 끌어 방향. 작은 차를 깔면 커지고 빨라진다. 큰 차에 부딪히면 작아진다. 60초 |
| sword | 빠른 검술 | 빨간 쪽으로 밀어 막고, 초록 쪽으로 밀어 벤다. 점점 빨라지고 속임수가 섞인다. 체력 3 |
| nerve | 도약 전도 | 박자 소리에 맞춰 탭하면 결절을 번쩍 뛰어 넘는다. 시간 안에 신경 끝까지. 평소 2D 옆모습, 딱 맞히면 잠깐 3D |
| superhot | 내가 움직일 때만 | 끌어서 움직일 때만 시간이 흐른다. 적에 부딪혀 부수고 총알을 피한다 |
| onlyfast | 나만 빠르다 | 느린 세상에서 사람을 탭해 순식간에 업고, 초록 칸을 탭해 내려놓는다. 3번 다치면 끝 |
| hotpack | 핫팩 몰래 넣기 | 위아래로 빨리 문질러 데우고 앞사람 목덜미에 넣는다. 돌아볼 때 들키면 하트 하나 |
| timedebt | 시간 빚 | 끌어서 이동, 손 떼면 0.2배 느려지고 적을 탭해 번개. 다시 잡으면 빚만큼 2.5배 |
| runaway | 브레이크 고장 | 계속 빨라지는 광차. 좌우 탭으로 다음 갈림길 방향만 고른다 |
| slowbike | 느린 자전거 경주 | 누르면 페달, 끌어서 균형. 꼴찌로 들어오면 이기고 넘어지거나 먼저 들어오면 진다 |
| matchspeed | 속도 맞춰 건너기 | 꾹 누르면 가속. 옆 차선과 속도를 맞추고 오른쪽으로 밀어 건넌다 |

## 구조

- `tofu.gd`: 공통(상자, 카메라, 점수·시간·최고점, 다시하기, 소리, 입력). 게임은 `g/<id>.gd` 하나로 `Tofu`를 extends 한다.
- `main.gd`: 메뉴. 새 게임은 `GAMES`와 `tools/smoke.gd`의 `ALL`에 id를 더한다.

## 명령 (이 폴더에서)

```bash
"$LOCALAPPDATA/Temp/opencode/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --fixed-fps 60 -s tools/smoke.gd
```

```bash
powershell -ExecutionPolicy Bypass -File tools/build.ps1
```

smoke는 화면 없이 40초씩 무작위 입력으로 돌려 스크립트 오류만 본다. build는 `web/`에 웹 빌드를 만든다(Pages가 그대로 연다).

폰에서 사람이 볼 것: 프레임이 끊기지 않는지, 첫 탭 뒤 소리, 터치 반응, 그리고 각 게임이 재미있는지.
