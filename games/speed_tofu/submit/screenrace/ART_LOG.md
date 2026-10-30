# ART_LOG — screenrace (화면 밖 경주)

프롬프트는 작업 폴더의 파일을 그대로 옮겼다(원문). 그림은 Codex(OpenAI 이미지 생성)가 2026-10-30 22:15~22:29에 만들었다.

## 3D 텍스처 (texture3d 파이프라인: Blender 저폴리 모델 → UV 전개도 → GPT가 칠함 → GLB)

### screenrace_courier

```text
[IMAGE]
Square 1024 by 1024 game texture atlas for a low-poly 3D model, painted onto the attached UV layout. Pocket Parcel Town: matte gouache on folded paper toys, large confident colour shapes and sparse hand-painted seams.
[LAYOUT]
The attached line image is the exact layout. Keep every polygon in exactly its original position, size and orientation. Coordinates below use pixel origin at top left. Do not move, rotate or stretch islands.
Outside the polygons use only flat middle grey #808080. Fill each polygon to its edges. The thin black guide lines are folding boundaries, not part of the final paint. All sides are flat surface paintings, image top is world up. No perspective views or miniature objects inside polygons. Box nets: FRONT in middle, LEFT to its left, RIGHT to its right, BACK beyond RIGHT, TOP above FRONT, BOTTOM below. Avoid doubled corner decorations.
[SURFACES]
jacket: x=20..351, y=749..1004 pixels. Paint coral red delivery jacket, cream zipper and shoulder straps, two broad cloth folds. Shared copies: 1.
  FRONT: x=93.1..185.9, y=821.2..930.9 pixels.
  RIGHT: x=185.9..258.5, y=821.2..930.9 pixels.
  BACK: x=258.5..351.3, y=821.2..930.9 pixels.
  LEFT: x=20.5..93.1, y=821.2..930.9 pixels.
  TOP: x=93.1..185.9, y=748.6..821.2 pixels.
  BOTTOM: x=93.1..185.9, y=930.9..1003.5 pixels.
head: x=372..726, y=749..1004 pixels. Paint peach skin, FRONT face (camera-facing) has a single dark eye near RIGHT edge and small cheek, BACK face matching eye near LEFT; other faces plain skin. Shared copies: 1.
  FRONT: x=451.1..549.0, y=828.0..924.2 pixels.
  RIGHT: x=549.0..628.4, y=828.0..924.2 pixels.
  BACK: x=628.4..726.3, y=828.0..924.2 pixels.
  LEFT: x=371.8..451.1, y=828.0..924.2 pixels.
  TOP: x=451.1..549.0, y=748.6..828.0 pixels.
  BOTTOM: x=451.1..549.0, y=924.2..1003.5 pixels.
nose: x=467..608, y=161..274 pixels. Paint warm peach small round nose, no eyes. Shared copies: 1.
  FRONT: x=510.4..537.4, y=204.4..229.8 pixels.
  RIGHT: x=537.4..581.3, y=204.4..229.8 pixels.
  BACK: x=581.3..608.3, y=204.4..229.8 pixels.
  LEFT: x=466.5..510.4, y=204.4..229.8 pixels.
  TOP: x=510.4..537.4, y=160.6..204.4 pixels.
  BOTTOM: x=510.4..537.4, y=229.8..273.7 pixels.
cap: x=20..436, y=509..728 pixels. Paint coral courier cap, cream badge on FRONT, one painted stitched seam. Shared copies: 1.
  FRONT: x=113.3..228.1, y=601.6..635.3 pixels.
  RIGHT: x=228.1..320.9, y=601.6..635.3 pixels.
  BACK: x=320.9..435.7, y=601.6..635.3 pixels.
  LEFT: x=20.5..113.3, y=601.6..635.3 pixels.
  TOP: x=113.3..228.1, y=508.7..601.6 pixels.
  BOTTOM: x=113.3..228.1, y=635.3..728.2 pixels.
brim: x=456..750, y=524..728 pixels. Paint coral cap brim with pale upper edge and dark burgundy underside. Shared copies: 1.
  FRONT: x=552.4..603.0, y=620.1..631.9 pixels.
  RIGHT: x=603.0..699.3, y=620.1..631.9 pixels.
  BACK: x=699.3..749.9, y=620.1..631.9 pixels.
  LEFT: x=456.2..552.4, y=620.1..631.9 pixels.
  TOP: x=552.4..603.0, y=523.9..620.1 pixels.
  BOTTOM: x=552.4..603.0, y=631.9..728.2 pixels.
trouser_0: x=700..838, y=343..488 pixels. Paint ink navy trousers, one broad pale blue fold. Shared copies: 1.
  FRONT: x=731.8..768.9, y=375.2..456.2 pixels.
  RIGHT: x=768.9..801.0, y=375.2..456.2 pixels.
  BACK: x=801.0..838.1, y=375.2..456.2 pixels.
  LEFT: x=699.7..731.8, y=375.2..456.2 pixels.
  TOP: x=731.8..768.9, y=343.1..375.2 pixels.
  BOTTOM: x=731.8..768.9, y=456.2..488.2 pixels.
shoe_0: x=20..223, y=157..274 pixels. Paint ink navy sneaker, cream sole and single coral patch. Shared copies: 1.
  FRONT: x=59.3..121.8, y=196.0..234.8 pixels.
  RIGHT: x=121.8..160.6, y=196.0..234.8 pixels.
  BACK: x=160.6..223.0, y=196.0..234.8 pixels.
  LEFT: x=20.5..59.3, y=196.0..234.8 pixels.
  TOP: x=59.3..121.8, y=157.2..196.0 pixels.
  BOTTOM: x=59.3..121.8, y=234.8..273.7 pixels.
sleeve_0: x=355..507, y=343..488 pixels. Paint coral jacket sleeve, cream cuff. Shared copies: 1.
  FRONT: x=392.1..430.9, y=380.2..451.1 pixels.
  RIGHT: x=430.9..468.0, y=380.2..451.1 pixels.
  BACK: x=468.0..506.8, y=380.2..451.1 pixels.
  LEFT: x=354.9..392.1, y=380.2..451.1 pixels.
  TOP: x=392.1..430.9, y=343.1..380.2 pixels.
  BOTTOM: x=392.1..430.9, y=451.1..488.2 pixels.
mitten_0: x=629..777, y=162..274 pixels. Paint peach mitten with a single thumb crease, no separated fingers. Shared copies: 1.
  FRONT: x=666.0..703.1, y=199.4..236.5 pixels.
  RIGHT: x=703.1..740.2, y=199.4..236.5 pixels.
  BACK: x=740.2..777.4, y=199.4..236.5 pixels.
  LEFT: x=628.8..666.0, y=199.4..236.5 pixels.
  TOP: x=666.0..703.1, y=162.2..199.4 pixels.
  BOTTOM: x=666.0..703.1, y=236.5..273.7 pixels.
trouser_1: x=859..997, y=343..488 pixels. Paint ink navy trousers, one broad pale blue fold. Shared copies: 1.
  FRONT: x=890.7..927.8, y=375.2..456.2 pixels.
  RIGHT: x=927.8..959.9, y=375.2..456.2 pixels.
  BACK: x=959.9..997.0, y=375.2..456.2 pixels.
  LEFT: x=858.6..890.7, y=375.2..456.2 pixels.
  TOP: x=890.7..927.8, y=343.1..375.2 pixels.
  BOTTOM: x=890.7..927.8, y=456.2..488.2 pixels.
shoe_1: x=244..446, y=157..274 pixels. Paint ink navy sneaker, cream sole and single coral patch. Shared copies: 1.
  FRONT: x=282.3..344.8, y=196.0..234.8 pixels.
  RIGHT: x=344.8..383.6, y=196.0..234.8 pixels.
  BACK: x=383.6..446.1, y=196.0..234.8 pixels.
  LEFT: x=243.5..282.3, y=196.0..234.8 pixels.
  TOP: x=282.3..344.8, y=157.2..196.0 pixels.
  BOTTOM: x=282.3..344.8, y=234.8..273.7 pixels.
sleeve_1: x=527..679, y=343..488 pixels. Paint coral jacket sleeve, cream cuff. Shared copies: 1.
  FRONT: x=564.4..603.3, y=380.2..451.1 pixels.
  RIGHT: x=603.3..640.4, y=380.2..451.1 pixels.
  BACK: x=640.4..679.2, y=380.2..451.1 pixels.
  LEFT: x=527.3..564.4, y=380.2..451.1 pixels.
  TOP: x=564.4..603.3, y=343.1..380.2 pixels.
  BOTTOM: x=564.4..603.3, y=451.1..488.2 pixels.
mitten_1: x=798..946, y=162..274 pixels. Paint peach mitten with a single thumb crease, no separated fingers. Shared copies: 1.
  FRONT: x=835.0..872.1, y=199.4..236.5 pixels.
  RIGHT: x=872.1..909.2, y=199.4..236.5 pixels.
  BACK: x=909.2..946.4, y=199.4..236.5 pixels.
  LEFT: x=797.8..835.0, y=199.4..236.5 pixels.
  TOP: x=835.0..872.1, y=162.2..199.4 pixels.
  BOTTOM: x=835.0..872.1, y=236.5..273.7 pixels.
scarf: x=20..334, y=294..488 pixels. Paint butter yellow neckerchief with one ochre fold. Shared copies: 1.
  FRONT: x=106.6..177.5, y=380.2..402.2 pixels.
  RIGHT: x=177.5..263.5, y=380.2..402.2 pixels.
  BACK: x=263.5..334.4, y=380.2..402.2 pixels.
  LEFT: x=20.5..106.6, y=380.2..402.2 pixels.
  TOP: x=106.6..177.5, y=294.1..380.2 pixels.
  BOTTOM: x=106.6..177.5, y=402.2..488.2 pixels.
[LIGHT]
Paint light from above: top faces lightest, side lower edges cooler and darker, narrow warm cream highlights at upper edges. Use stepped broad brush shapes rather than smooth gradients. Eye and clothing details must read at small mobile scale. Paint only requested faces, no extra faces on blank skin sides.
[PALETTE]
Warm paper #FFF0D5, ink navy #34334B, coral #E86758, cardboard #DDA56A, butter tape #F8D58A, peach skin #F2C098, sage #62AD91, slate blue #508CC8. Keep skin and coral clothing clearly separate.
[NEGATIVE]
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No perspective, no shading that implies a 3D view inside a face.
No text or labels.
```

결과: **채택.** 배달부 한 모델의 전개도. 코랄 원본을 칠한 뒤 옷 색만 바꿔 파랑·민트·노랑 3벌을 만들었다(`prepare_textures.py`). 게임: courier_{coral,blue,mint,gold}.glb, 나 = 코랄.

### screenrace_props

```text
[IMAGE]
Square 1024 by 1024 game texture atlas for a low-poly 3D model, painted onto the attached UV layout. Pocket Parcel Town: matte gouache on folded paper toys, large confident colour shapes and sparse hand-painted seams.
[LAYOUT]
The attached line image is the exact layout. Keep every polygon in exactly its original position, size and orientation. Coordinates below use pixel origin at top left. Do not move, rotate or stretch islands.
Outside the polygons use only flat middle grey #808080. Fill each polygon to its edges. The thin black guide lines are folding boundaries, not part of the final paint. All sides are flat surface paintings, image top is world up. No perspective views or miniature objects inside polygons. Box nets: FRONT in middle, LEFT to its left, RIGHT to its right, BACK beyond RIGHT, TOP above FRONT, BOTTOM below. Avoid doubled corner decorations.
[SURFACES]
parcel: x=640..759, y=141..219 pixels. Paint golden cardboard, broad cream packing tape cross, small blank cream shipping label on FRONT, one coral arrow pictogram, creased corners. Shared copies: 1.
  FRONT: x=665.6..699.8, y=166.4..193.7 pixels.
  RIGHT: x=699.8..725.1, y=166.4..193.7 pixels.
  BACK: x=725.1..759.3, y=166.4..193.7 pixels.
  LEFT: x=640.4..665.6, y=166.4..193.7 pixels.
  TOP: x=665.6..699.8, y=141.1..166.4 pixels.
  BOTTOM: x=665.6..699.8, y=193.7..219.0 pixels.
crate: x=483..667, y=242..376 pixels. Paint honey wood crate: three broad planks, diagonal brace on FRONT and BACK; two dark nail heads only, no corner brackets. Shared copies: 1.
  FRONT: x=525.1..575.1, y=284.2..334.2 pixels.
  RIGHT: x=575.1..617.2, y=284.2..334.2 pixels.
  BACK: x=617.2..667.2, y=284.2..334.2 pixels.
  LEFT: x=483.0..525.1, y=284.2..334.2 pixels.
  TOP: x=525.1..575.1, y=242.1..284.2 pixels.
  BOTTOM: x=525.1..575.1, y=334.2..376.3 pixels.
board: x=415..620, y=111..219 pixels. Paint warm honey timber plank, two broad grain strokes and one knot, end grain on LEFT and RIGHT, no cracks yet. Shared copies: 1.
  FRONT: x=464.6..517.3, y=160.6..169.0 pixels.
  RIGHT: x=517.3..567.2, y=160.6..169.0 pixels.
  BACK: x=567.2..619.9, y=160.6..169.0 pixels.
  LEFT: x=414.6..464.6, y=160.6..169.0 pixels.
  TOP: x=464.6..517.3, y=110.6..160.6 pixels.
  BOTTOM: x=464.6..517.3, y=169.0..219.0 pixels.
lantern_panes: x=780..856, y=160..219 pixels. Paint warm butter amber glass, dark teal iron framing along edges only, pale central flame silhouette, no bloom. Shared copies: 1.
  FRONT: x=796.6..817.7, y=176.9..202.2 pixels.
  RIGHT: x=817.7..834.5, y=176.9..202.2 pixels.
  BACK: x=834.5..855.6, y=176.9..202.2 pixels.
  LEFT: x=779.8..796.6, y=176.9..202.2 pixels.
  TOP: x=796.6..817.7, y=160.1..176.9 pixels.
  BOTTOM: x=796.6..817.7, y=202.2..219.0 pixels.
lantern_base: x=876..968, y=172..219 pixels. Paint dark teal painted iron with cream edge highlights. Shared copies: 1.
  FRONT: x=896.6..921.8, y=192.2..198.5 pixels.
  RIGHT: x=921.8..942.4, y=192.2..198.5 pixels.
  BACK: x=942.4..967.6, y=192.2..198.5 pixels.
  LEFT: x=876.0..896.6, y=192.2..198.5 pixels.
  TOP: x=896.6..921.8, y=171.6..192.2 pixels.
  BOTTOM: x=896.6..921.8, y=198.5..219.0 pixels.
lantern_roof: x=461..523, y=69..85 pixels. Paint dark teal iron cap with warm cream edge. Shared copies: 1.
lantern_roof top: x=667..673, y=79..85 pixels. Paint dark teal iron cap with warm cream edge. Shared copies: 1.
  TOP: x=667.4..673.4, y=79.4..85.4 pixels.
lantern_handle: x=421..440, y=64..85 pixels. Paint dark teal iron handle with warm edge. Shared copies: 1.
  FRONT: x=426.7..430.9, y=69.6..80.1 pixels.
  RIGHT: x=430.9..436.2, y=69.6..80.1 pixels.
  BACK: x=436.2..440.4, y=69.6..80.1 pixels.
  LEFT: x=421.4..426.7, y=69.6..80.1 pixels.
  TOP: x=426.7..430.9, y=64.3..69.6 pixels.
  BOTTOM: x=426.7..430.9, y=80.1..85.4 pixels.
stall_post: x=878..909, y=404..547 pixels. Paint warm timber post, one grain stroke. Shared copies: 2.
  FRONT: x=886.2..893.5, y=412.1..538.4 pixels.
  RIGHT: x=893.5..902.0, y=412.1..538.4 pixels.
  BACK: x=902.0..909.3, y=412.1..538.4 pixels.
  LEFT: x=877.8..886.2, y=412.1..538.4 pixels.
  TOP: x=886.2..893.5, y=403.6..412.1 pixels.
  BOTTOM: x=886.2..893.5, y=538.4..546.8 pixels.
stall_counter: x=20..394, y=106..219 pixels. Paint sage market counter with cream wood edging and a few broad brush marks. Shared copies: 1.
  FRONT: x=60.0..207.3, y=145.3..179.5 pixels.
  RIGHT: x=207.3..246.8, y=145.3..179.5 pixels.
  BACK: x=246.8..394.1, y=145.3..179.5 pixels.
  LEFT: x=20.5..60.0, y=145.3..179.5 pixels.
  TOP: x=60.0..207.3, y=105.9..145.3 pixels.
  BOTTOM: x=60.0..207.3, y=179.5..219.0 pixels.
awning: x=20..463, y=239..376 pixels. Paint coral and cream broad striped canvas, scallop motifs only on FRONT lower edge, fold shadow under lip. Shared copies: 1.
  FRONT: x=83.6..241.5, y=302.6..313.2 pixels.
  RIGHT: x=241.5..304.7, y=302.6..313.2 pixels.
  BACK: x=304.7..462.6, y=302.6..313.2 pixels.
  LEFT: x=20.5..83.6, y=302.6..313.2 pixels.
  TOP: x=83.6..241.5, y=239.5..302.6 pixels.
  BOTTOM: x=83.6..241.5, y=313.2..376.3 pixels.
awning_lip: x=75..401, y=60..85 pixels. Paint coral and cream broad striped hanging canvas valance, curved scallop painted along bottom. Shared copies: 1.
  FRONT: x=79.9..237.8, y=65.4..80.1 pixels.
  RIGHT: x=237.8..243.1, y=65.4..80.1 pixels.
  BACK: x=243.1..400.9, y=65.4..80.1 pixels.
  LEFT: x=74.6..79.9, y=65.4..80.1 pixels.
  TOP: x=79.9..237.8, y=60.1..65.4 pixels.
  BOTTOM: x=79.9..237.8, y=80.1..85.4 pixels.
train_body: x=20..831, y=790..1004 pixels. Paint butter cream commuter train SIDE: three large slate blue windows separated by coral door, coral stripe along lower third; FRONT and BACK are side views too. Shared copies: 1.
  FRONT: x=88.9..425.7, y=858.8..935.1 pixels.
  RIGHT: x=425.7..494.1, y=858.8..935.1 pixels.
  BACK: x=494.1..831.0, y=858.8..935.1 pixels.
  LEFT: x=20.5..88.9, y=858.8..935.1 pixels.
  TOP: x=88.9..425.7, y=790.4..858.8 pixels.
  BOTTOM: x=88.9..425.7, y=935.1..1003.5 pixels.
train_nose: x=20..220, y=567..770 pixels. Paint LEFT face is arriving train front: two amber round headlamps and slate windshield; FRONT and BACK cream and coral cheek panels. Shared copies: 1.
  FRONT: x=88.9..120.5, y=635.7..701.5 pixels.
  RIGHT: x=120.5..188.9, y=635.7..701.5 pixels.
  BACK: x=188.9..220.5, y=635.7..701.5 pixels.
  LEFT: x=20.5..88.9, y=635.7..701.5 pixels.
  TOP: x=88.9..120.5, y=567.3..635.7 pixels.
  BOTTOM: x=88.9..120.5, y=701.5..769.9 pixels.
train_roof: x=20..857, y=397..547 pixels. Paint slate blue train roof, broad pale blue upper panel. Shared copies: 1.
  FRONT: x=91.5..438.9, y=467.8..475.7 pixels.
  RIGHT: x=438.9..509.9, y=467.8..475.7 pixels.
  BACK: x=509.9..857.3, y=467.8..475.7 pixels.
  LEFT: x=20.5..91.5, y=467.8..475.7 pixels.
  TOP: x=91.5..438.9, y=396.8..467.8 pixels.
  BOTTOM: x=91.5..438.9, y=475.7..546.8 pixels.
wheel_rim: x=544..647, y=77..85 pixels. Paint dark indigo rubber wheel with single slate hub on caps, no spokes. Shared copies: 2.
wheel_hub: x=20..54, y=52..85 pixels. Paint dark indigo rubber wheel with single slate hub on caps, no spokes. Shared copies: 4.
  TOP: x=20.5..54.2, y=51.7..85.4 pixels.
[LIGHT]
Paint light from above: top faces lightest, side lower edges cooler and darker, narrow warm cream highlights at upper edges. Use stepped broad brush shapes rather than smooth gradients. Eye and clothing details must read at small mobile scale. Paint only requested faces, no extra faces on blank skin sides.
[PALETTE]
Warm paper #FFF0D5, ink navy #34334B, coral #E86758, cardboard #DDA56A, butter tape #F8D58A, peach skin #F2C098, sage #62AD91, slate blue #508CC8. Keep skin and coral clothing clearly separate.
[NEGATIVE]
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No perspective, no shading that implies a 3D view inside a face.
No text or labels.
```

결과: **채택.** 짐·기차·등불·상자·시장 가판대·다리 판이 한 장의 아틀라스를 나눠 쓴다(`props_atlas.jpg`). 게임: parcel/train/lantern.glb 사용, crate/market_stall/bridge_board.glb는 만들었지만 아직 안 붙임.

## 2D 코스 배경 (GPT 이미지 → webp 압축)

### market

```text
Use case: illustration-story. Asset type: wide 2:1 landscape parallax backdrop, 1536x768, for a cute side-view parcel delivery race. Pocket Parcel Town style: hand-painted matte gouache on warm paper, chunky folded-paper architectural silhouettes, broad confident color shapes, sparse brush marks, simple irregular contours. Eye-level distant side view, no strong foreground perspective. Upper half is open flat sky with two or three simple cloud shapes. Scenery mainly around middle band. Lower quarter is quiet low-contrast flat color, no playable-looking platforms or strong edges; runners will be overlaid in front. Keep entire backdrop muted and low contrast, cheerful and legible at tiny size. No characters, no UI, no lettering, no logos, no black outlines, no photorealism, no glossy CGI, no bloom, no lens flare, no smooth airbrush gradients, no dense even texture, no tiny repetitive details. Cream sky, muted apricot walls, sage shutters and dusty coral roof tiles. A charming Korean village market street with a few striped cloth awnings, baskets and staggered shopfront silhouettes. Flat daylight.
```

결과: 채택 → bg_market.webp (37 KB)

### riverside

```text
Use case: illustration-story. Asset type: wide 2:1 landscape parallax backdrop, 1536x768, for a cute side-view parcel delivery race. Pocket Parcel Town style: hand-painted matte gouache on warm paper, chunky folded-paper architectural silhouettes, broad confident color shapes, sparse brush marks, simple irregular contours. Eye-level distant side view, no strong foreground perspective. Upper half is open flat sky with two or three simple cloud shapes. Scenery mainly around middle band. Lower quarter is quiet low-contrast flat color, no playable-looking platforms or strong edges; runners will be overlaid in front. Keep entire backdrop muted and low contrast, cheerful and legible at tiny size. No characters, no UI, no lettering, no logos, no black outlines, no photorealism, no glossy CGI, no bloom, no lens flare, no smooth airbrush gradients, no dense even texture, no tiny repetitive details. Pale aqua sky, powder blue water and soft jade reeds. Broad horizontal bands of gently flowing river, a distant small arched stone bridge, low green hills and clusters of riverbank trees. Flat daylight.
```

결과: 채택 → bg_riverside.webp (30 KB)

### crossing

```text
Use case: illustration-story. Asset type: wide 2:1 landscape parallax backdrop, 1536x768, for a cute side-view parcel delivery race. Pocket Parcel Town style: hand-painted matte gouache on warm paper, chunky folded-paper architectural silhouettes, broad confident color shapes, sparse brush marks, simple irregular contours. Eye-level distant side view, no strong foreground perspective. Upper half is open flat sky with two or three simple cloud shapes. Scenery mainly around middle band. Lower quarter is quiet low-contrast flat color, no playable-looking platforms or strong edges; runners will be overlaid in front. Keep entire backdrop muted and low contrast, cheerful and legible at tiny size. No characters, no UI, no lettering, no logos, no black outlines, no photorealism, no glossy CGI, no bloom, no lens flare, no smooth airbrush gradients, no dense even texture, no tiny repetitive details. Butter-yellow sky, muted ochre station walls and slate blue roof. A tiny countryside railway station, telegraph poles and far railway tracks, crossing signal silhouettes in the distance, open quiet landscape. Flat daylight.
```

결과: 채택 → bg_crossing.webp (41 KB)

### night_market

```text
Use case: illustration-story. Asset type: wide 2:1 landscape parallax backdrop, 1536x768, for a cute side-view parcel delivery race. Pocket Parcel Town style: hand-painted matte gouache on warm paper, chunky folded-paper architectural silhouettes, broad confident color shapes, sparse brush marks, simple irregular contours. Eye-level distant side view, no strong foreground perspective. Upper half is open flat sky with two or three simple cloud shapes. Scenery mainly around middle band. Lower quarter is quiet low-contrast flat color, no playable-looking platforms or strong edges; runners will be overlaid in front. Keep entire backdrop muted and low contrast, cheerful and legible at tiny size. No characters, no UI, no lettering, no logos, no black outlines, no photorealism, no glossy CGI, no bloom, no lens flare, no smooth airbrush gradients, no dense even texture, no tiny repetitive details. Dusty mauve dusk sky, muted rose roofs and warm amber paper lanterns. Night market street with staggered closed stall roofs and hanging strings of paper lamps. Lamps are small flat amber shapes, no glow halos. Cheerful evening.
```

결과: 채택 → bg_night_market.webp (21 KB). 밤 등불 모드 배경도 당분간 이것을 쓴다

### bridge

```text
Use case: illustration-story. Asset type: wide 2:1 landscape parallax backdrop, 1536x768, for a cute side-view parcel delivery race. Pocket Parcel Town style: hand-painted matte gouache on warm paper, chunky folded-paper architectural silhouettes, broad confident color shapes, sparse brush marks, simple irregular contours. Eye-level distant side view, no strong foreground perspective. Upper half is open flat sky with two or three simple cloud shapes. Scenery mainly around middle band. Lower quarter is quiet low-contrast flat color, no playable-looking platforms or strong edges; runners will be overlaid in front. Keep entire backdrop muted and low contrast, cheerful and legible at tiny size. No characters, no UI, no lettering, no logos, no black outlines, no photorealism, no glossy CGI, no bloom, no lens flare, no smooth airbrush gradients, no dense even texture, no tiny repetitive details. Pale mint sky, moss green and blue-green wooded gorge. Layered distant forested hills and a slender suspension footbridge with ropes far across the valley, broad simple foliage clusters. Airy daylight.
```

결과: **미생성** — 이미지 생성 연결 실패(22:28 'image generation failed: connection failed'), 이후 Codex 재시도 3번 모두 시작 직후 OpenAI 403으로 실패. 게임은 기존 하늘색 배경을 쓴다

### rooftops

```text
Use case: illustration-story. Asset type: wide 2:1 landscape parallax backdrop, 1536x768, for a cute side-view parcel delivery race. Pocket Parcel Town style: hand-painted matte gouache on warm paper, chunky folded-paper architectural silhouettes, broad confident color shapes, sparse brush marks, simple irregular contours. Eye-level distant side view, no strong foreground perspective. Upper half is open flat sky with two or three simple cloud shapes. Scenery mainly around middle band. Lower quarter is quiet low-contrast flat color, no playable-looking platforms or strong edges; runners will be overlaid in front. Keep entire backdrop muted and low contrast, cheerful and legible at tiny size. No characters, no UI, no lettering, no logos, no black outlines, no photorealism, no glossy CGI, no bloom, no lens flare, no smooth airbrush gradients, no dense even texture, no tiny repetitive details. Lavender sky, peach ceramic rooftops and desaturated indigo shadows. Overlapping village rooflines at different heights, a few squat chimneys and cylindrical rooftop water tanks; distant hills. Soft flat daylight.
```

결과: **미생성** — 위와 같은 이유

### lantern_night

```text
Use case: illustration-story. Asset type: wide 2:1 landscape parallax backdrop, 1536x768, for a cute side-view parcel delivery race. Pocket Parcel Town style: hand-painted matte gouache on warm paper, chunky folded-paper architectural silhouettes, broad confident color shapes, sparse brush marks, simple irregular contours. Eye-level distant side view, no strong foreground perspective. Upper half is open flat sky with two or three simple cloud shapes. Scenery mainly around middle band. Lower quarter is quiet low-contrast flat color, no playable-looking platforms or strong edges; runners will be overlaid in front. Keep entire backdrop muted and low contrast, cheerful and legible at tiny size. No characters, no UI, no lettering, no logos, no black outlines, no photorealism, no glossy CGI, no bloom, no lens flare, no smooth airbrush gradients, no dense even texture, no tiny repetitive details. Deep indigo flat night sky, slate violet roofs and muted teal quiet town silhouettes. Sparse simple stars and one small pale moon. Peaceful sleeping village with unlit windows, broad empty sky; no fog, no lantern halo, no light beams. This is scenery behind a separate gameplay lantern light.
```

결과: **미생성** — 위와 같은 이유. 대신 bg_night_market 사용

## 2026-10-31 paper-craft delivery — cover attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Status: submitted; result recorded below.

```text
[IMAGE] Illustrated game cover, landscape 1.26:1, final crop 630x500. Pocket Parcel Town pushed toward PAPER-CRAFT DIORAMA.
[SCENE] Four paper-toy delivery couriers race RIGHT across a layered paper market street with two cardboard ramps and crates. Exactly four couriers: coral player largest in front at lower right, blue and mint rivals running behind, gold rival tumbling backward off the LEFT edge of a cream paper screen frame, partially clipped at left. Each carries a stack of two or three taped cardboard parcels on their back, behind their head. Low side view, dynamic running legs and swinging mitten hands. Match reference 1 market palette and reference 2 courier identity: rectangular folded-paper cap and peach head, one dark dot eye in profile, little forward nose, short jacket, navy trousers, chunky brown running shoes. Reinterpret as lively cut-paper illustration; no grey studio background. Coral cap/jacket #E86758, blue #508CC8, mint #62AD91, gold #E8B34B. Warm top-left daylight.
[RENDERING] Cut colored paper and cardboard layers, visible thin white paper edges, shallow soft contact shadows, matte watercolor washes and a few broad gouache brush marks. Handmade folded silhouettes with readable overlaps.
[EMPTY] Upper third is uncluttered warm cream sky reserved for title; market shapes simplified behind the runners.
[PALETTE] Warm paper #FFF0D5, dusty coral, sage, muted apricot, cardboard #DDA56A, dark ink #34334B. Bright cheerful daylight.
[TEXT] Only text: "Off the Screen!" in very large bold dark ink cut-paper lettering across the upper third, readable at thumbnail size. Keep all title letters inside margins.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No other text, letters, captions, signature, monogram, watermark or logo.
```
Result: REJECTED / no image. Attempt 1 failed: image generation failed: connection failed: error sending request. Attempts 2 and 3 will use the identical prompt above verbatim.

### Cover attempts 2–3: attachment-free recovery
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed. Oracle recommended omitting attachments after connection failure. Revised prompt below used verbatim for retry.
```text
[IMAGE] Illustrated game cover, landscape 1.26:1, final crop 630x500. Pocket Parcel Town pushed toward PAPER-CRAFT DIORAMA.
[SCENE] Four paper-toy delivery couriers race RIGHT across a layered paper market street with two cardboard ramps and crates. Exactly four couriers: coral player largest in front at lower right, blue and mint rivals running behind, gold rival tumbling backward off the LEFT edge of a cream paper screen frame, partially clipped at left. Each carries a stack of two or three taped cardboard parcels on their back, behind their head. Low side view, dynamic running legs and swinging mitten hands. Market palette: cream sky, apricot shopfronts, sage striped awnings, dusty coral tiled roofs. Courier identity: rectangular folded-paper cap and peach head, one dark dot eye in profile, little forward nose, short jacket, navy trousers, chunky brown running shoes. Reinterpret as lively cut-paper illustration; no grey studio background. Coral cap/jacket #E86758, blue #508CC8, mint #62AD91, gold #E8B34B. Warm top-left daylight.
[RENDERING] Cut colored paper and cardboard layers, visible thin white paper edges, shallow soft contact shadows, matte watercolor washes and a few broad gouache brush marks. Handmade folded silhouettes with readable overlaps.
[EMPTY] Upper third is uncluttered warm cream sky reserved for title; market shapes simplified behind the runners.
[PALETTE] Warm paper #FFF0D5, dusty coral, sage, muted apricot, cardboard #DDA56A, dark ink #34334B. Bright cheerful daylight.
[TEXT] Only text: "Off the Screen!" in very large bold dark ink cut-paper lettering across the upper third, readable at thumbnail size. Keep all title letters inside margins.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No other text, letters, captions, signature, monogram, watermark or logo.
```
Result: KEPT, attempt 2. Four correctly colored couriers, gold tumbling at left, legible exact title. Resized with Pillow LANCZOS to 630x500; title retained from generation. Attempt 3 not needed.

### Bridge attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed. Text-only generation after successful cover recovery.
```text
[IMAGE] Wide 2:1 landscape game backdrop, final 1024x512, Pocket Parcel Town PAPER-CRAFT DIORAMA.
[SCENE] Eye-level distant side view of two slender rope suspension bridges across a wooded valley, scenery concentrated in middle third. Layered wooded gorge in pale mint, moss and blue-green. Bridge boards and ropes are small distant scenery, with no strong foreground platform edges. Warm top-left daylight.
[RENDERING] Cut colored paper and cardboard landscape layers, thin white paper edges, subtle shallow contact shadows, soft watercolor washes, a few broad matte gouache marks. Broad simple silhouettes. Bright, muted and low contrast throughout for runners overlaid in front.
[EMPTY] Upper half is open pale mint sky with two plain paper cloud cutouts. Lower quarter is a quiet nearly flat pale sage band. Large uncluttered spaces between scenery.
[PALETTE] Pale mint, soft moss green, blue-green, warm cream paper, muted cardboard. Light phone-readable values.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No characters, no UI, no lettering. No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```
Result: KEPT, bridge attempt 1. Pillow LANCZOS resize to 1024x512, saturation x0.82, 15% warm-paper veil to lower contrast, WebP quality 85 method 6.

### Rooftops attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
```text
[IMAGE] Wide 2:1 landscape game backdrop, final 1024x512, Pocket Parcel Town PAPER-CRAFT DIORAMA.
[SCENE] Eye-level distant side view across a small town's overlapping ceramic rooftops. Three broad roof groups at different heights in the middle third, a few squat chimneys and two laundry lines with a few simple folded-paper clothes between roof groups. Warm top-left daylight. All roofs are distant scenery.
[RENDERING] Cut colored paper and cardboard architectural layers, thin white paper edges, subtle shallow contact shadows, soft watercolor washes, a few broad matte gouache marks. Broad simple silhouettes. Bright, muted and low contrast throughout for runners overlaid in front.
[EMPTY] Upper half is open pale lavender sky with two plain paper cloud cutouts. Lower quarter is a quiet nearly flat pale peach band without edges or platforms. Large uncluttered spaces between scenery.
[PALETTE] Light lavender sky, peach roofs, desaturated indigo shadows, warm cream paper. Light phone-readable values.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No characters, no UI, no lettering. No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```
Result: KEPT, rooftops attempt 1. Pillow LANCZOS resize to 1024x512, saturation x0.82, 15% warm-paper veil to lower contrast, WebP quality 85 method 6.

### Night attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed. User's light lantern-night request supersedes old deep-indigo/unlit prompt.
```text
[IMAGE] Wide 2:1 landscape game backdrop, final 1024x512, Pocket Parcel Town PAPER-CRAFT DIORAMA.
[SCENE] Eye-level distant side view of a quiet village street at early night, lit by two hanging strings of warm amber paper lanterns over closed market shopfronts. Roofs and lanterns sit in the middle third. A small pale paper moon high above. Keep this night scene FAIRLY LIGHT, welcoming and phone-readable, with broad pale lavender sky and light mauve pavement.
[RENDERING] Cut colored paper and cardboard architectural layers, thin white paper edges, subtle shallow contact shadows, soft watercolor washes, a few broad matte gouache marks. Broad simple silhouettes. Low contrast throughout for runners overlaid in front. Lanterns are flat painted cream and amber shapes with no bloom halos; broad warm washes on nearby walls.
[EMPTY] Upper half is open light slate-lavender sky. Lower quarter is a quiet nearly flat light dusty mauve street band without platform edges. Large uncluttered spaces between scenery.
[PALETTE] Light slate violet and dusty mauve, muted teal silhouettes, warm cream paper, pale amber lanterns. The picture is mostly light midtones with very few dark accents. No black sky.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No characters, no UI, no lettering. No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```
Result: KEPT, night attempt 1. Pillow LANCZOS resize to 1024x512, saturation x0.82, 20% warm-paper veil to brighten night and lower contrast, WebP quality 85 method 6.

Delivery result: cover and all three backdrops kept. Only image-generation failure: cover attempt 1 connection failed; attachment-free attempt 2 succeeded. No skipped items. No prompt was submitted for cover attempt 3. Logging transport initially failed with JSONDecodeError before writing; native Add-Content succeeded. All generation prompts actually submitted are preserved verbatim above, including the rejected attempt.

## Cover-match remodel 2026-10-31 — atlas attempt 1
Tool: built-in OpenAI imagegen. Prompt verbatim:
```text
[IMAGE]
Square 1024 by 1024 game texture atlas for low-poly folded-paper toy couriers and props. Pocket Parcel Town: matte painted cardstock, like chunky friendly paper-toy delivery runners. This is a flat UV material sheet, not a picture of any object.
[LAYOUT]
Sixteen axis-aligned square UV islands in a 4 by 4 grid. Origin top left. Each cell is 256 pixels square. Each painted square extends from cell offset (8,8) to (248,248); the 16-pixel gaps between painted squares remain flat middle grey #808080. Keep every island exactly in position, square, unrotated. Fill each square edge to edge, do not draw guide lines or outlines. Image top is world up.
[SURFACES]
Row 1, y=8..248: x=8..248 coral red #E86758 painted cap and shirt paper, a single broad darker seam near lower edge; x=264..504 warm peach #F2C098 plain face paper with NO facial features; x=520..760 navy #34334B trousers with two broad subdued blue folds near lower edge; x=776..1016 warm brown #79543B shoe leather paper, one broad tan upper edge.
Row 2, y=264..504: x=8..248 kraft cardboard #DDA56A with one broad subtle fold; x=264..504 warm cream #FFF0D5 plain paper; x=520..760 very dark ink #282B3E plain paper; x=776..1016 crisp vermilion red #C84235 tape paper, nearly solid.
Row 3, y=520..760: x=8..248 honey brown timber #B9814C with three long HORIZONTAL confident darker grain strokes and one small knot, clean readable broad grain; x=264..504 tan rope #CDB17E with sparse diagonal ochre binding marks; x=520..760 deep teal #426C71 painted locomotive paper with a pale upper edge; x=776..1016 butter amber #F3CB73 plain paper.
Row 4, y=776..1016: x=8..248 blue #508CC8 painted cap and shirt paper with one darker seam near lower edge; x=264..504 mint green #62AD91 painted cap and shirt paper with one darker seam near lower edge; x=520..760 golden yellow #E8B34B painted cap and shirt paper with one darker seam near lower edge; x=776..1016 slate blue #658A9F locomotive window paper, a single diagonal cream reflection stroke.
[LIGHT]
Broad stepped warm upper edge and cooler lower edge only. Keep center 60 percent of each square almost flat in the specified base color. Minimal paper grain, matte dry gouache, no random noise. These painted surfaces wrap actual mesh geometry.
[NEGATIVE]
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No perspective, no shading that implies a 3D view inside a face.
No text or labels. No objects, no characters, no eyes, no mouth, no face drawing, no little pictures inside the squares.

```



## UI art task 191b5dc5-b2af-4dda-b9fd-c01536e5ef0a — 2026-10-31

Inspected existing cover and all bg_*.webp references before generation. Built-in image_gen.imagegen; model tool-managed, undisclosed. One tool call per asset per attempt. Palette and paper-cut rendering locked across the set. Native reference files were inspected, not attached. All prompts below are the exact submitted strings.

### logo.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 640x280 final game UI raster asset, landscape composition.
[SCENE] Wide paper cut-out title logo. Exact text "Off the Screen!" in very big chunky hand-cut navy letters with red accents, thin cream-white cut edges and offset paper shadow. Two readable stacked lines: "Off the" above "Screen!". A small kraft parcel with red tape and three red speed streaks complete the logo. Actual transparent background. No other words.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text other than the exact title Off the Screen! No signature or watermark.
```

### icon_parcel.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one kraft parcel box with a bold red tape cross, three-quarter view. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_shoe.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one Courier Blue running shoe pointing right, small cream paper wing on its heel, red sole. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_strap.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one navy looped carry strap supporting TWO small kraft boxes with red tape, clearly one integrated carry-more icon. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```


### icon_spring.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one chunky silver-blue coil spring standing upright, gold lower mounting foot, visible open coils. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_wind.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one pale Courier Blue wind swirl, three broad curled paper ribbons flowing right. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_feather_box.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one kraft parcel with red tape and one large cream feather attached, lighter-boxes emblem. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_shield.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one sturdy navy shield with a blue face, cream layered rim and one kraft parcel emblem. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```


### icon_gate.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one low kraft gate arch, red overhead bar, TWO small parcels fitting tightly beneath it to communicate a two-box limit. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_ice.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one light blue ice slope wedge with a bold cream snowflake attached above its face. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_headwind.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one big curled blue wind gust pointing LEFT against one tiny courier running RIGHT in a red cap and blue shirt. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_jump.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one bold WHITE upward arrow paper cutout with a thin cream edge and soft navy-gray offset shadow; opaque white paper arrow inside transparent canvas. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```


### icon_drop.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one kraft parcel with red tape flying LEFT and broad red dash streaks trailing to its RIGHT, visibly backward motion. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_lantern.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: REJECTED: no image returned; image generation failed: network error: error sending request.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one hanging amber paper lantern with navy handle and cream lit center, simple red tassel. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_flag.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one finish checkered navy-and-cream paper flag on a short kraft pole, broad readable checks. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_star.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one chunky five-point gold paper star, one folded amber facet. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```


### mode_classic.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 300x360 final game UI raster asset, portrait composition.
[SCENE] Portrait isolated mini paper market street diorama, no outer rectangular backdrop. A courier running RIGHT, red cap, blue shirt, navy trousers and brown shoes, carrying exactly THREE kraft parcels stacked on their back. Two simple cream market facades and a muted green striped awning behind, bright daytime. Full silhouette fits in frame. Transparent surrounding canvas. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### mode_lantern.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 300x360 final game UI raster asset, portrait composition.
[SCENE] Portrait isolated mini paper night street diorama, no outer rectangular backdrop. A courier running RIGHT, red cap, blue shirt, navy trousers and brown shoes, holding one glowing amber paper lantern in their forward hand. Simple light lavender street facades behind, a small navy night-sky cutout behind roofs. FAIRLY LIGHT welcoming midtones, flat amber lantern center and warm paper wash, no bloom. Transparent surrounding canvas. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### mode_rush.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 300x360 final game UI raster asset, portrait composition.
[SCENE] Portrait isolated paper diorama: a courier dashing RIGHT in a deep forward lean, red cap, blue shirt, navy trousers and brown shoes, carrying exactly TWO kraft parcels on their back. Three big red speed chevrons behind, small cream paper street slab beneath. Keep character fully visible. Transparent surrounding canvas. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### seal_gold.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 140x140 final game UI raster asset, square composition.
[SCENE] One centered gold #F7B336 paper medal / matte wax-style seal, scalloped cardstock rim, shallow embossed kraft parcel emblem with a red tape cross. No ribbon, no rank numbers. Actual transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```


### seal_silver.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 140x140 final game UI raster asset, square composition.
[SCENE] One centered silver gray #BAC4C8 paper medal / matte wax-style seal, scalloped cardstock rim, shallow embossed kraft parcel emblem with a red tape cross. No ribbon, no rank numbers. Actual transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### seal_bronze.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 140x140 final game UI raster asset, square composition.
[SCENE] One centered bronze #CD7F32 paper medal / matte wax-style seal, scalloped cardstock rim, shallow embossed kraft parcel emblem with a red tape cross. No ribbon, no rank numbers. Actual transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### howto_run.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 420x260 final game UI raster asset, landscape composition.
[SCENE] Landscape comic-style paper cut-out tutorial illustration. One courier in red cap, blue shirt, navy trousers and brown shoes running and hopping RIGHT over one low kraft crate, airborne bent knees, arms balanced, small cream paper ground strip. Full body visible, strong readable action. Transparent surrounding canvas, no panel frame, no text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### howto_weight.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 420x260 final game UI raster asset, landscape composition.
[SCENE] Landscape comic-style paper cut-out tutorial illustration. One courier in red cap, blue shirt, navy trousers and brown shoes walking slowly RIGHT with a very tall stack of FIVE kraft boxes on their back, back bowed, knees bent, one arm bracing stack, two oversized blue sweat drops near head. Small cream paper ground strip. Full stack and feet visible. Transparent surrounding canvas, no panel frame, no text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```


### howto_drop.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: subject/style and small-size readability verified in contact sheet.

```text
[IMAGE] 420x260 final game UI raster asset, landscape composition.
[SCENE] Landscape comic-style paper cut-out tutorial illustration. One courier in red cap, blue shirt, navy trousers and brown shoes bursting rapidly RIGHT with ONE box remaining on back, tossing one separate kraft parcel backward LEFT with extended rear arm. Three red speed lines behind the runner and forward stretched legs. Small cream paper ground strip. All anatomy and flying parcel visible. Transparent surrounding canvas, no panel frame, no text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### howto_edge.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: REJECTED: depicted an earthen cliff with grass/fence rather than a torn paper page.

```text
[IMAGE] 420x260 final game UI raster asset, landscape composition.
[SCENE] Landscape comic-style paper cut-out tutorial illustration. A torn cream paper PAGE occupies the RIGHT half, its ragged LEFT edge is a vertical cliff at center. One courier in red cap, blue shirt, navy trousers and brown shoes has fallen OFF the LEFT edge into empty space at the lower LEFT, arms lifted, feet dangling, one kraft parcel tipping with them. Clear readable falling-off-left-edge action, full body visible. Transparent surrounding canvas, no frame, no text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### paper_grain.png — attempt 1
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: REJECTED: generated a post office building instead of a blank seamless paper texture.

```text
[IMAGE] 256x256 final game UI raster asset, square composition.
[SCENE] Square seamless TILEABLE light Manila Cream #FFFDF5 paper fiber texture. Fully opaque. Very subtle sparse warm cream paper fibers and faint grain, almost flat at small size. Matching edges, uniform illumination, no gradient, no directional shadows, no folds, no objects, no text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```

### icon_lantern.png — attempt 2
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: text-only retry succeeded; amber paper lantern with transparent surround.

```text
[IMAGE] 160x160 final game UI raster asset, square composition.
[SCENE] Single centered paper cut-out object: one hanging amber paper lantern with navy handle and cream lit center, simple red tassel. Transparent background. No text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
```


### howto_edge.png — attempt 2
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: courier visibly falls left from the torn left margin of a flat paper page; no terrain.

```text
[IMAGE] 420x260 final game UI raster asset, landscape composition.
[SCENE] This is a PAPER PAGE, NOT a landscape or cliff. A FLAT cream sheet with a torn vertical margin, visible thin layered white edges. No earth, no soil, no rock, no grass, no fence. Landscape comic-style paper cut-out tutorial illustration. A torn cream paper PAGE occupies the RIGHT half, its ragged LEFT edge is a thin vertical ripped sheet edge at center. One courier in red cap, blue shirt, navy trousers and brown shoes has fallen OFF the LEFT edge into empty space at the lower LEFT, arms lifted, feet dangling, one kraft parcel tipping with them. Clear readable falling-off-left-edge action, full body visible. Transparent surrounding canvas, no frame, no text.
[RENDERING] Pocket Parcel Town PAPER-CRAFT DIORAMA matching the inspected Off the Screen cover: chunky cut colored cardstock and kraft cardboard layers, thin white cut-paper edges, soft shallow contact shadows, slight paper grain. Broad simple phone-readable silhouettes. Flat matte paper with a few folded facets, bright soft light from upper left.
[EMPTY] Center the entire object including shadow within approximately 6% empty padding on all sides; uncluttered flat paper surfaces and empty space between shapes.
[PALETTE] Ink Navy #2A2C44, Kraft #E3BA88, Kraft Shadow #BA8E5C, Manila Cream #FFFDF5, Postal Red #E85244, Delivery Gold #F7B336, Parcel Brown #D99B5B, Post Green #2B9348, Courier Blue #3D78B5, Lantern Night #1B1F38, Lantern Amber #FFD166.
[NEGATIVE]
No over-rendering: no painted texture on every surface, no object-by-object drawing of foliage, rocks, water, sky or background.
No hyper-detailed fur, bark, stone, or leaf rendering; a few confident marks stand for each.
No sky gradients, no cloud detail, no glow around the sun, moon, or lights.
No glossy digital painting, no airbrushed smooth gradients, no plastic or waxy skin.
No bloom, lens flare, god rays, or haze unless the subject asks for them.
No shallow depth of field, bokeh, or photographic blur.
No 3D render look, no subsurface skin sheen, no CGI lighting.
No evenly spread detail; detail sits in one or two places only.
No perfectly symmetrical faces, poses, or compositions.
No generic fantasy decoration: floating particles, sparkles, magic circles, random runes or glyphs.
No extra eyes, mouths, faces, limbs, or tentacles; no melted or fused anatomy; hands have the correct number of fingers.
No characters, animals, or props that the subject did not ask for.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
The ONLY environment is a flat torn paper PAGE occupying the right half of the composition, lying face-on like a book page. The courier falls off its left margin; transparent space beneath the page. No terrain.
```

### paper_grain.png — attempt 2
Tool: image_gen.imagegen (built-in); model: tool-managed, undisclosed.
Result: KEPT: blank light cream fiber texture; repeated-tile visual review passed. Fully opaque.

```text
[IMAGE] 256x256 seamless tileable material texture, opaque light cream paper surface, flat orthographic macro scan.
[SCENE] ONLY a blank sheet of light cream paper, uniformly filling the ENTIRE square from edge to edge. Sparse almost invisible cream fibers. Nothing printed or drawn on it. No objects whatsoever.
[RENDERING] Flat 2D material scan, uniform illumination, no shading, extremely low contrast. Base Manila Cream #FFFDF5 with tiny fibers only 2-4 RGB values darker. Opposite edges match for seamless repeating tiling.
[EMPTY] The entire image is blank cream paper. No composition, no subject, no landscape, no props.
[PALETTE] ONLY near-white cream #FFFDF5 and #F9F5EB.
[NEGATIVE]
No buildings, house, town, street, courier, parcel, icons, illustration, diorama, cardboard structures, scenery, or objects.
No border, edges of sheet, folds, stains, creases, gradient, shadows, vignette, lighting variation.
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
No muddy, smeared, or noisy surface texture.
```

Production: Pillow LANCZOS resize, alpha-bounds crop for transparent cutouts, centered within an 88% maximum content area (approximately 6% padding), PNG optimize=True / compress_level=9. All final PNG files remain true RGBA, including opaque paper_grain.png. Palette quantization was unnecessary because lossless outputs fit the 1,500,000-byte cap. No game code changed; no git or Godot run.

Attempt totals: 30 image_gen.imagegen calls, 27 KEPT, 2 REJECTED visual mismatches, 1 REJECTED network failure. The lantern network retry and both visual replacements succeeded on attempt 2. No skipped items. All submitted prompts, including failures/rejections, are recorded above.


### Cover-match remodel — final result (2026-10-31)
Atlas attempt 1: KEPT. Built-in OpenAI imagegen succeeded on the first call; no retry or procedural fallback was needed. The verbatim prompt is under "Cover-match remodel 2026-10-31 — atlas attempt 1" above. Generated output: C:/Users/fixme/.codex/generated_images/01a18e6f-e72c-7a10-af02-dba84a6cbd5e/exec-311a3f18-d145-40a9-bba8-8ab066b47987.png. Inspected all sixteen swatches. Saved with Pillow LANCZOS at 512x512, JPEG quality 90, subsampling 0, optimize=True, to work/pipeline/out/remodel/atlas.jpg. Colors for all teams come from this one generated atlas; skin and shoe colors are shared. Crisp red tape and shipping label edges are modeled thin surfaces using the corresponding painted swatches.

Geometry rebuilt with texture3d Model/box/lathe helpers in work/remodel_art.py; existing finish_glb.py now has --remodel to touch only the seven requested GLBs. The four couriers have a large head/cap silhouette (~36% of total height), generous cap brim, two profile eyes, small smile, short leaning shirt, running arms, chunky navy legs, sturdy brown shoes with cream soles, and cargo straps. No boxes are baked into couriers: ART.md and the existing game assemble countable parcels separately. Preserved arm_0/1 and leg_0/1 pivots plus run_loop. Train rebuilt as a steam locomotive, nose -X, with boiler, chimney, cab, driving wheels, rods and cowcatcher. Board has painted grain and three rope wraps plus a knot at each end.

Final GLB output (bytes / triangles): courier_coral 212496 / 1480; courier_blue 212496 / 1480; courier_mint 212496 / 1480; courier_gold 212496 / 1480; parcel 92164 / 324; train 365696 / 3364; bridge_board 175220 / 1188. Every GLB has one material, one embedded 512x512 JPEG atlas, unlit extension and baked vertex lighting. Each courier is natively height 1, feet y=0, X/Z centered. Final Blender subprocess exit code 0. Final finish_glb --remodel and check_remodel.py passed. Seven side-view previews and cover_match.png were rendered and visually inspected; large head/cap, chunky running silhouette, face, navy trousers and brown shoes now belong to the cover's paper-toy style.

Failures and recovery: rg unavailable (CommandNotFoundException), oracle consulted, used PowerShell Select-String. One redirected PowerShell render wrapper returned 1 despite seven successful exports and previews; oracle consulted; final subprocess capture confirmed BLENDER_EXIT 0. Initial checker compared normalized byte vertex colors as raw integers; corrected normalization and checked actual transformed mesh bounds, then all checks passed. Get-CimInstance process inspection was denied (0x80041003), oracle consulted; Get-Process fallback found no Godot process. Optional global Godot import was not run, keeping this delivery within the named art files and avoiding concurrent UI import side effects. No image generation failures and no skipped requested assets. No .gd edits, git commands, or writes to art/screenrace/ui/. hwapongstuy was read only.
