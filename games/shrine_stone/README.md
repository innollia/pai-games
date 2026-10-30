# 굴러라 신전석 (단독판)

speed_tofu 의 합격작 "굴러라 신전석"(boulder, v4)을 떼어 낸 독립 Godot 4.7.2 프로젝트. 나중에 만들 게임의 기반으로 쓴다.
플레이: `https://innollia.github.io/pai-games/games/shrine_stone/web/`

- `g/boulder.gd`: 게임 전부(8구역 코스, 깔기·커지기, 뛰기·쪼개기·버티기·던지기). 설계는 `../speed_tofu/DESIGNS.md` 의 "굴러라 신전석" 절.
- `tofu.gd`: 공용 틀(카메라, 화면 글자, 손가락 조작 키트, 상자 만들기, 소리, 끝 화면). speed_tofu 와 같은 파일에서 "< 메뉴" 글자만 "< 처음부터" 로 바꿨다. 별점은 저장되지 않는다(Firestore 연결 뺌).
- `main.gd`: 메뉴 없이 바로 boulder 를 연다. 다른 게임을 기반으로 삼으려면 `GAME` 만 바꾼다.
- 웹 빌드: `powershell -ExecutionPolicy Bypass -File tools\build.ps1` → `web\`
