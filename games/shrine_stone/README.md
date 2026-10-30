# 굴러라 신전석 (단독판)

speed_tofu 의 제출준비작 "굴러라 신전석"(boulder) 단독판 = **잼 제출본**. 강화는 speed_tofu 의 `g/boulder.gd`·`art/boulder/` 에서 하고 `tools\sync.ps1` 로 가져온 뒤 빌드한다. 제출 순서는 [SUBMIT_CHECKLIST.md](SUBMIT_CHECKLIST.md).
플레이: `https://innollia.github.io/pai-games/games/shrine_stone/web/`

- `g/boulder.gd`: 게임 전부(8구역 코스, 깔기·커지기, 뛰기·쪼개기·버티기·던지기). 설계는 `../speed_tofu/DESIGNS.md` 의 "굴러라 신전석" 절.
- `tofu.gd`: 공용 틀(카메라, 화면 글자, 손가락 조작 키트, 상자 만들기, 소리, 끝 화면). speed_tofu 와 같은 파일에서 "< 메뉴" 글자만 "< 처음부터" 로 바꿨다(sync.ps1). 별점·한마디는 speed_tofu 와 같은 Firestore `tofu_ratings` 에 id "boulder", ver "v<GVER> <빌드>" 로 간다.
- `main.gd`: 메뉴 없이 바로 boulder 를 연다. 다른 게임을 기반으로 삼으려면 `GAME` 만 바꾼다.
- 웹 빌드: `powershell -ExecutionPolicy Bypass -File tools\build.ps1` → `web\`
