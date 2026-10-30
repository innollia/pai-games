# MANIFEST — art/screenrace

스타일: submit/screenrace/ART.md (Pocket Parcel Town). 로딩: g/screenrace.gd `_art_model()`(GLB를 지정 높이로 맞춰 발밑 기준으로 붙임, 없으면 상자), `_build_backdrop()`(bg_<코스>.webp를 Sprite3D로 z=-18, 카메라의 0.94배로 따라감).

| 파일 | 바이트 | 무엇 / 게임에서 |
| --- | --- | --- |
| bg_crossing.webp | 41120 | 코스 배경 1024×512 그림, 폭 65 단위 |
| bg_market.webp | 37046 | 코스 배경 1024×512 그림, 폭 65 단위 |
| bg_night_market.webp | 20936 | 코스 배경 1024×512 그림, 폭 65 단위 |
| bg_riverside.webp | 30218 | 코스 배경 1024×512 그림, 폭 65 단위 |
| bridge_board.glb | 152128 | 만들었지만 아직 안 붙임(코스 상자 풀 교체 필요) |
| bridge_board_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| courier_blue.glb | 247332 | 배달부(경쟁자 파랑·민트·노랑). 위와 같음 |
| courier_blue_courier_blue.jpg | 134914 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| courier_coral.glb | 241680 | 배달부(나). 높이 1.5, +X 앞, 발 기준, 뒤돌면 y축 180° |
| courier_coral_courier_coral.jpg | 129264 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| courier_gold.glb | 243292 | 배달부(경쟁자 파랑·민트·노랑). 위와 같음 |
| courier_gold_courier_gold.jpg | 130875 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| courier_mint.glb | 245296 | 배달부(경쟁자 파랑·민트·노랑). 위와 같음 |
| courier_mint_courier_mint.jpg | 132878 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| crate.glb | 152136 | 만들었지만 아직 안 붙임(코스 상자 풀 교체 필요) |
| crate_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| lantern.glb | 171892 | 밤 등불 모드 등불 |
| lantern_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| market_stall.glb | 182348 | 만들었지만 아직 안 붙임(코스 상자 풀 교체 필요) |
| market_stall_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| parcel.glb | 152144 | 짐. 등 뒤 짐 칸·땅의 짐에 상자 모양으로 맞춤 |
| parcel_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |
| train.glb | 197552 | 건널목 기차. 코가 -X(달려오는 쪽) |
| train_props_atlas.jpg | 143114 | GLB가 쓰는 텍스처(가져오기 때 풀려 나옴) |

없는 것: bg_bridge.webp, bg_rooftops.webp, bg_night.webp (생성 실패 — ART_LOG.md). 파일이 생기면 코드 수정 없이 바로 쓰인다.
