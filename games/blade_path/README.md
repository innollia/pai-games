# 일격의 길 (단독판)

speed_tofu 의 합격작 "★ 일격의 길"(blade)을 떼어 낸 독립 Godot 4.7.2 프로젝트. 파이 요청(10/30)으로 반복 성장 구조를 넣었다.
플레이: `https://innollia.github.io/pai-games/games/blade_path/web/`

- 켜면 튜토리얼: 막기 → 베기 → 간파 → 간파 뒤 베기. 단계마다 맞는 쪽으로 밀 때까지 멈춘다. "건너뛰기 >" 로 넘길 수 있다.
- 검객이 끝없이 나온다(찌르기/속임수 번갈아). n번째(0부터): 체력 6+4n, 공격 2+n, 예비 시간 ×max(0.55, 1-0.05n). 이기면 체력 전부 회복.
- 막으면 돈(기본 1냥, 간파 3배), 검객을 쓰러뜨리면 5+3n냥. 쓰러지면 상점: 최대 체력, 베기 힘, 간파 넓게, 막기 돈, 간파 반격. "플레이"로 첫 검객부터 다시.
- 돈·업그레이드·최고 기록은 `user://blade_path.json` 에 저장.
- `g/blade.gd`: 게임 전부. `tofu.gd`: 공용 틀(shrine_stone 과 같은 파일). 웹 빌드: `powershell -ExecutionPolicy Bypass -File tools\build.ps1` → `web\`
