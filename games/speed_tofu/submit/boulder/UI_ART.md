# 굴러라 신전석 — GPT UI 그림

## 결과

- 저장 위치: `games/speed_tofu/art/boulder/ui_gpt/`
- 생성: GPT 내장 `image_gen` 도구. 각 PNG는 개별 생성한 손그림 UI 에셋이다.
- 기준 그림: `temple.png`, `stone.png`, `valley.png`, `pillar.png`를 먼저 육안 확인했다. 로컬 참조 이미지 첨부 호출은 네트워크 오류가 나서, 그림체를 아래 텍스트 프롬프트로 전달했다.
- 밝은 구아슈 붓질, 크림 사암, 진한 갈색 외곽선, 각지게 깎은 모서리와 아래쪽 돌 두께. 모든 글자 영역은 빈 돌면이다.
- 판·버튼·메달은 게임의 modulate를 위한 밝은 크림 계열이다. `button_down.png`는 기본 버튼보다 어둡고 아래 두께가 얇다.
- PNG 7개 합계: **760,729 bytes (0.761 MB / 742.9 KiB)**. 1.5MB 이하.
- 코드 변경, Godot 실행, 커밋은 하지 않았다.

## 실제 크기와 9-slice

여백 순서는 **left / top / right / bottom**, 단위는 px이다. 문서의 제안값은 대략값이므로, 실제 생성된 아래 두께와 띠 장식을 보호하도록 일부 값을 넓혔다. 투명 안전 여백도 포함한 이미지 가장자리 기준이다.

| 파일 | 실제 크기 | left | top | right | bottom | PNG 용량(bytes) |
|---|---|---:|---:|---:|---:|---:|
| `panel.png` | 512 × 384 | 56 | 56 | 56 | 64 | 101,028 |
| `button.png` | 512 × 256 | 48 | 48 | 48 | 72 | 76,739 |
| `button_down.png` | 512 × 256 | 48 | 48 | 48 | 48 | 63,225 |
| `title.png` | 1024 × 384 | 160 | 104 | 160 | 112 | 256,217 |
| `plaque.png` | 768 × 192 | 96 | 48 | 96 | 48 | 100,058 |
| `seal.png` | 384 × 384 | — | — | — | — | 110,042 |
| `gauge.png` | 1024 × 128 | 64 | 40 | 64 | 40 | 53,420 |

`seal.png`는 9-slice를 사용하지 않고 종횡비를 유지해 표시한다. 나머지는 위 여백 안의 모서리·장식·돌 두께를 고정하고 가운데 돌면과 직선 테두리를 늘린다. 가운데 텍스트 영역은 이 여백 안쪽에 둔다.

`gauge.png`는 채움 막대가 없는 틀이다. 중앙 (512, 64)의 alpha는 0이며, 가운데 가로 홈은 실제 투명 영역이다. 막대는 틀 뒤에 배치한다. 양 끝 장식은 64px 고정 영역 안으로 맞췄다.

## 투명 처리와 크기·용량 최적화

- 모든 생성 호출에서 `transparent_background: true`를 요청했고, 최종 선택 원본에는 이미 알파 채널이 있었다.
- 제목판 미리보기에는 갈색 배경처럼 보이는 RGB가 있었지만, 실제 외부 픽셀 alpha는 0이었다. 배경색을 키잉하거나 돌면을 지우지 않고 생성된 알파를 사용했다. 배경 제거 편집 호출은 네트워크 오류로 실패했고 최종 산출물에는 사용하지 않았다.
- 원본의 alpha ≥ 128인 픽셀 경계에 2px를 더한 범위를 기준으로 불필요한 외부 투명 공간을 잘랐다. 최종 캔버스에는 약 3px의 투명 안전 여백을 남겼다.
- System.Drawing의 HighQualityBicubic 리샘플링으로 지정 크기에 맞췄다. 명패와 게이지는 좌우 끝을 각각 별도로 리샘플링하여 끝 장식이 96px / 64px 고정 여백 안에 머물도록 했다. 원본 기준 끝 구간은 명패 350px, 게이지 260px이다.
- 최종 PNG는 RGBA를 유지한다. 용량을 줄이기 위해 RGB는 8단위(채널당 약 5bit), alpha는 17단위(16단계)로 반올림했다. alpha=0인 픽셀은 투명색으로 정리했다. 작은 계단 현상 없이 보이는지 최종 크기로 육안 검수했다.
- 외부 배경과 게이지 홈의 alpha=0, 가장자리의 반투명 픽셀, 지정 크기, 파일 7개와 총용량을 확인했다. 게임 실행 검수는 하지 않았다.

## 생성 프롬프트

아래는 최종 선택본의 **실제 전체 프롬프트**이다. 입력 이미지 첨부 없이 텍스트로 생성했고 모두 `transparent_background: true`를 사용했다. 제목판·메달·눌린 버튼의 버려진 초안은 결과 폴더에 넣지 않았다.

### panel.png

```text
Use case: stylized-concept. Asset type: production 2D game UI PNG, a single isolated asset, NOT a mockup or texture atlas.
Match the game temple texture style: bright opaque gouache brushwork, hand-painted faceted cream sandstone and strong dark-brown ink outlines. A carved temple stone object with angular chamfered corners, never rounded corners. Front-facing orthographic UI silhouette, perfectly straight horizontal/vertical stretchable edges. Warm bright daylight painted into surface, thicker visible stone depth along bottom. No scene, no cast shadow outside silhouette. Truly transparent background.
No letters, numbers, symbols resembling writing, logos or watermarks. Keep central stone face blank and evenly subtly textured for game-rendered text. All decoration and chamfers must stay inside the specified 9-slice borders, center must stretch cleanly. Fill the requested canvas with only a 3-6 pixel safety gap.
Requested canvas: 512x384 pixels.
Primary request: Large carved rectangular card panel. Very pale almost-white cream sandstone suitable for tint modulation. Dark brown ink rim, one thin shallow inset border line, angular cut corners. Bottom thickness around 22 pixels within bottom border. Uniform blank wide face. All 9-slice margins 56 pixels.
```

### button.png

```text
Use case: stylized-concept. Asset type: production 2D game UI PNG, a single isolated asset, NOT a mockup or texture atlas.
Match the game temple texture style: bright opaque gouache brushwork, hand-painted faceted cream sandstone and strong dark-brown ink outlines. A carved temple stone object with angular chamfered corners, never rounded corners. Front-facing orthographic UI silhouette, perfectly straight horizontal/vertical stretchable edges. Warm bright daylight painted into surface, thicker visible stone depth along bottom. No scene, no cast shadow outside silhouette. Truly transparent background.
No letters, numbers, symbols resembling writing, logos or watermarks. Keep central stone face blank and evenly subtly textured for game-rendered text. All decoration and chamfers must stay inside the specified 9-slice borders, center must stretch cleanly. Fill the requested canvas with only a 3-6 pixel safety gap.
Requested canvas: 512x256 pixels.
Primary request: Raised rectangular stone block push button, tactile prominent bevel and 24 pixel lower stone thickness. Very pale almost-white cream sandstone for tint modulation. Angular clipped corners, dark brown ink outline. Flat unadorned empty face. All 9-slice margins 48 pixels.
```

### button_down.png

```text
Use case: stylized-concept. Asset type: production 2D game UI PNG, a single isolated asset, NOT a mockup or texture atlas.
Match the game temple texture style: bright opaque gouache brushwork, hand-painted faceted cream sandstone and strong dark-brown ink outlines. A carved temple stone object with angular chamfered corners, never rounded corners. Front-facing orthographic UI silhouette, perfectly straight horizontal/vertical stretchable edges. Warm bright daylight painted into surface, thicker visible stone depth along bottom. No scene, no cast shadow outside silhouette. Truly transparent background.
No letters, numbers, symbols resembling writing, logos or watermarks. Keep central stone face blank and evenly subtly textured for game-rendered text. All decoration and chamfers must stay inside the specified 9-slice borders, center must stretch cleanly. Fill the requested canvas with only a 3-6 pixel safety gap.
Requested canvas: 512x256 pixels.
Primary request: Pressed state of the same raised rectangular stone block button: same dimensions, angular clipped silhouette, pale cream sandstone, dark brown ink outline and blank face as button. Lower stone thickness ONLY 7 pixels, face slightly darker and depressed. Still bright and suitable for tint modulation. All 9-slice margins 48 pixels.
CRITICAL: match normal button structure: one flat wide pale-cream blank top slab, angular clipped corners, slim top and side bevel, no inset frame or corner blocks. Nearly white cream face only slightly darker than normal. Bottom extrusion only 7 pixels, thin brown edge. Button silhouette fills nearly entire 2:1 canvas, transparent safety padding only 4 pixels.
```

### title.png

```text
Use case: stylized-concept. Asset type: production 2D game UI PNG, a single isolated asset, NOT a mockup or texture atlas.
Match the game temple texture style: bright opaque gouache brushwork, hand-painted faceted cream sandstone and strong dark-brown ink outlines. A carved temple stone object with angular chamfered corners, never rounded corners. Front-facing orthographic UI silhouette, perfectly straight horizontal/vertical stretchable edges. Warm bright daylight painted into surface, thicker visible stone depth along bottom. No scene, no cast shadow outside silhouette. Truly transparent background.
No letters, numbers, symbols resembling writing, logos or watermarks. Keep central stone face blank and evenly subtly textured for game-rendered text. All decoration and chamfers must stay inside the specified 9-slice borders, center must stretch cleanly. Fill the requested canvas with only a 3-6 pixel safety gap.
Requested canvas: 1024x384 pixels.
Primary request: Wide temple lintel title plate. Small carved column-capital / volute decorations ONLY at left and right ends within 160 pixels. Thin blue and gold temple bands ONLY within top and bottom 80 pixels. Bright cream sandstone, dark brown ink edging and angular chamfers, bottom stone depth. Large unbroken empty central text face. 9-slice left/right 160, top/bottom 80 pixels.
```

### plaque.png

```text
Use case: stylized-concept. Asset type: production 2D game UI PNG, a single isolated asset, NOT a mockup or texture atlas.
Match the game temple texture style: bright opaque gouache brushwork, hand-painted faceted cream sandstone and strong dark-brown ink outlines. A carved temple stone object with angular chamfered corners, never rounded corners. Front-facing orthographic UI silhouette, perfectly straight horizontal/vertical stretchable edges. Warm bright daylight painted into surface, thicker visible stone depth along bottom. No scene, no cast shadow outside silhouette. Truly transparent background.
No letters, numbers, symbols resembling writing, logos or watermarks. Keep central stone face blank and evenly subtly textured for game-rendered text. All decoration and chamfers must stay inside the specified 9-slice borders, center must stretch cleanly. Fill the requested canvas with only a 3-6 pixel safety gap.
Requested canvas: 768x192 pixels.
Primary request: Long horizontal area-name stone plaque, angular chamfers, modest carved decorations ONLY in the two end caps within 96 pixels. Bright warm cream sandstone with restrained blue and golden ochre end accents matching temple reference, dark brown ink outline, lower stone depth. Wide clean blank central face. 9-slice left/right 96, top/bottom 48 pixels.
```

### seal.png

```text
Use case: stylized-concept. Asset type: production 2D game UI PNG, a single isolated asset, NOT a mockup or texture atlas.
Match the game temple texture style: bright opaque gouache brushwork, hand-painted faceted cream sandstone and strong dark-brown ink outlines. A carved temple stone object with angular chamfered corners, never rounded corners. Front-facing orthographic UI silhouette, perfectly straight horizontal/vertical stretchable edges. Warm bright daylight painted into surface, thicker visible stone depth along bottom. No scene, no cast shadow outside silhouette. Truly transparent background.
No letters, numbers, symbols resembling writing, logos or watermarks. Keep central stone face blank and evenly subtly textured for game-rendered text. All decoration and chamfers must stay inside the specified 9-slice borders, center must stretch cleanly. Fill the requested canvas with only a 3-6 pixel safety gap.
Requested canvas: 384x384 pixels.
Primary request: A single octagonal stone medal / failure seal, eight straight edges with angular corners. Very bright almost-white cream sandstone suitable for red tint modulation. Large blank circular inset stone face, subtle carved ornamental rim, dark brown ink outline, shallow lower thickness. No text, no icon in central disc. No 9-slice required.
CRITICAL: EXACT REGULAR OCTAGON outer silhouette, flat horizontal top and bottom, flat vertical sides and four diagonal clipped corners, eight straight sides only. Rim carvings stay INSIDE this octagon; no jewels or points sticking outside. Large circular empty central face. Bright white cream stone.
```

### gauge.png

```text
Use case: stylized-concept. Asset type: production 2D game UI PNG, a single isolated asset, NOT a mockup or texture atlas.
Match the game temple texture style: bright opaque gouache brushwork, hand-painted faceted cream sandstone and strong dark-brown ink outlines. A carved temple stone object with angular chamfered corners, never rounded corners. Front-facing orthographic UI silhouette, perfectly straight horizontal/vertical stretchable edges. Warm bright daylight painted into surface, thicker visible stone depth along bottom. No scene, no cast shadow outside silhouette. Truly transparent background.
No letters, numbers, symbols resembling writing, logos or watermarks. Keep central stone face blank and evenly subtly textured for game-rendered text. All decoration and chamfers must stay inside the specified 9-slice borders, center must stretch cleanly. Fill the requested canvas with only a 3-6 pixel safety gap.
Requested canvas: 1024x128 pixels.
Primary request: Extremely long narrow horizontal speed gauge FRAME carved into cream sandstone, angular chamfered ends, dark brown ink outline and subtle ochre and muted blue edge accents. The central long horizontal opening MUST BE COMPLETELY TRANSPARENT, an actual hole showing transparency, NOT an opaque dark groove and not a filled bar. Opening should extend from x64 to x960, and y40 to y88 on the 1024x128 canvas. Solid narrow top and bottom carved rails stay within 40 pixel top/bottom margins, end caps within 64 pixels. Empty frame only, no tick marks or numbers. Outside frame also transparent. 9-slice left/right 64 top/bottom 40 pixels.
```
