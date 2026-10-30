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
