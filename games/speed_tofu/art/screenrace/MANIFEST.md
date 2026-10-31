# MANIFEST — art/screenrace

스타일: submit/screenrace/ART.md (Pocket Parcel Town). 로딩: g/screenrace.gd `_art_model()`(GLB를 지정 높이로 맞춰 발밑 기준으로 붙임, 없으면 상자), `_build_backdrop()`(bg_<코스>.webp를 Sprite3D로 z=-18, 카메라의 0.94배로 따라감).

| 파일 | 바이트 | 무엇 / 게임에서 |
| --- | --- | --- |
| bg_crossing.webp | 41120 | 코스 배경 1024×512 그림, 폭 65 단위 |
| bg_market.webp | 37046 | 코스 배경 1024×512 그림, 폭 65 단위 |
| bg_night_market.webp | 20936 | 코스 배경 1024×512 그림, 폭 65 단위 |
| bg_riverside.webp | 30218 | 코스 배경 1024×512 그림, 폭 65 단위 |
| bridge_board.glb | 175220 | 1,188 tris. 나뭇결이 보이는 넓은 목판, 양 끝 세 겹 로프와 매듭. 흔들다리·꺼지는 바닥 판(_board_art, 메시 하나로 합쳐 씀) |
| bridge_board_props_atlas.jpg | 143114 | 이전 GLB에서 추출된 보존 파일. 새 GLB는 내장 atlas 사용 |
| courier_blue.glb | 212496 | 1,480 tris. 커버형 큰 머리 종이 배달부, 파랑 모자·셔츠, 아래 공통 규격 |
| courier_blue_courier_blue.jpg | 134914 | 이전 GLB에서 추출된 보존 파일. 새 GLB는 내장 atlas 사용 |
| courier_coral.glb | 212496 | 1,480 tris. 플레이어, 산호 빨강 모자·셔츠. 원본 높이 1.0, 게임이 지정 높이로 조절 |
| courier_coral_courier_coral.jpg | 129264 | 이전 GLB에서 추출된 보존 파일. 새 GLB는 내장 atlas 사용 |
| courier_gold.glb | 212496 | 1,480 tris. 커버형 큰 머리 종이 배달부, 금빛 노랑 모자·셔츠 |
| courier_gold_courier_gold.jpg | 130875 | 이전 GLB에서 추출된 보존 파일. 새 GLB는 내장 atlas 사용 |
| courier_mint.glb | 212496 | 1,480 tris. 커버형 큰 머리 종이 배달부, 민트 초록 모자·셔츠 |
| courier_mint_courier_mint.jpg | 132878 | 이전 GLB에서 추출된 보존 파일. 새 GLB는 내장 atlas 사용 |
| crate.glb | 152136 | 장애물 상자(_bump) 쌓기, crates 구간 장식 |
| crate_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| lantern.glb | 171892 | 밤 등불 모드 등불 |
| lantern_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| market_stall.glb | 182348 | 평지 뒤 장식(_decor) |
| market_stall_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| parcel.glb | 92164 | 324 tris. 크라프트 상자, 날카로운 빨강 테이프 십자와 크림색 배송 라벨. 등짐·바닥 짐에 사용 |
| parcel_props_atlas.jpg | 143114 | 이전 GLB에서 추출된 보존 파일. 새 GLB는 내장 atlas 사용 |
| train.glb | 365696 | 3,364 tris. 원통 보일러·굴뚝·큰 구동륜·연결봉·기관실·앞 배장기를 가진 종이 기관차. 코 -X |
| train_props_atlas.jpg | 143114 | 이전 GLB에서 추출된 보존 파일. 새 GLB는 내장 atlas 사용 |

배경 추가 제작분도 존재함: bg_bridge.webp (39,344 bytes), bg_rooftops.webp (30,224 bytes), bg_night.webp (45,614 bytes). 이번 리모델링에서 배경 파일은 변경하지 않음.

## 2026-10-31 커버 매치 리모델링

위 7개 GLB 모두 단일 머티리얼, 내장 512×512 JPEG painted atlas, KHR_materials_unlit. 면별 vertex color에 부드러운 명암을 넣어 게임의 unlit 렌더에서도 종이 접힌 면을 구분한다. 외부 JPG에 대한 참조는 없다.

배달부 공통: +X 진행, Y up, 기본 프레임 발밑 y=0, X/Z 중앙 정렬, 원본 높이 1.0, 폭 약 0.745·깊이 약 0.472. 머리와 모자가 전체 높이의 약 36%를 차지한다. 두 측면의 눈과 작은 미소, 큰 모자와 챙, 앞으로 기운 짧은 셔츠, 굵은 남색 바지와 갈색 신발, 앞뒤로 벌어진 팔·다리. arm_0/1, leg_0/1 피벗과 run_loop 애니메이션을 유지한다. 등짐은 기존 게임이 수량별로 별도 조립하므로 모델에는 운반 끈만 포함한다.

검증: submit/screenrace/work/check_remodel.py (최종 GLB의 인덱스·UV·색상·머티리얼·내장 텍스처·노드 변환 후 실제 범위·애니메이션·기차 방향·총 용량 검사). 같은 폴더의 *_preview.png 및 cover_match.png를 직접 육안 검토했다. art/screenrace 전체는 ui/와 sfx/를 제외하고 기존 JPG 및 import 메타데이터를 포함해 3.7 MB 미만이며 5,000,000 bytes 제한 이내.

재제작: Blender 5.2에서 submit/screenrace/work/remodel_art.py 실행 → Python finish_glb.py --remodel → Python check_remodel.py. texture3d/tools/build_models.py의 Model/box/lathe 및 기존 GLB 마무리 파이프라인을 사용한다. OpenAI imagegen atlas는 pipeline/out/remodel/atlas.jpg에 보관. Godot 전체 import는 이번 작업에서 실행하지 않음.
