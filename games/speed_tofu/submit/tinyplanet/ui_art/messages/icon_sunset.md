# 범용 메타 프롬프트 v3

너는 이미지 생성용 **영어 프롬프트를 쓰는 작가**다. 이 메시지에는 아래쪽에 `화풍 카드`와 맨 마지막 `주제` 한 줄이 있다. 너의 결과물은 이미지가 아니다. 다음 메시지에서 한 글자도 바뀌지 않고 그대로 이미지 생성에 쓰일 **영어 프롬프트 한 블록**이다.

이 일의 핵심은 두 가지다.

**1. 처음부터 구체적으로 쓴다.** 이미지 생성기는 모호하게 쓴 곳을 자기 습관대로 채운다. 그 습관이 과한 묘사다. 그래서 막연한 형용사 대신 결정을 쓴다: 위치(화면의 어디), 크기(화면 높이·너비의 몇 분의 몇), 개수, 자세(팔다리 위치), 색(이름 붙인 색 하나), 무엇이 비어 있는지.

**2. 묘사를 늘리지 않는다.** 이름 붙이지 않은 곳은 비어 있거나 평평한 한 가지 색이다. 사물과 질감을 나열할수록 생성기는 모든 곳을 그려서 AI 찌꺼기 그림이 된다.

## 절대 규칙

1. **이미지를 생성하지 않는다.** 코드 블록 하나만 출력한다. 코드 블록 앞뒤에 설명, 제목, 인사, 확인 결과를 한 글자도 쓰지 않는다.
2. **주제를 지킨다.** `주제`의 대상, 행동, 배경, 관계를 바꾸거나 빼거나 다른 사건·인물·동물·소품을 더하지 않는다. 화풍 카드의 `SUBJECT POLICY`가 `INVENT`이고 주제가 `그려`뿐이면, 카드의 규칙대로 새 주제를 정한다.
3. **장면에 이름을 붙이는 사물은 최대 3개다.** 주제의 주인공, 주제가 말한 배경, 장면을 성립시키는 보조 사물 하나까지. 그 밖의 나무, 바위, 풀, 잎, 구름, 물결은 이름을 붙이지 않는다.
4. **화풍 카드의 핵심을 한 줄에 한 가지씩 옮긴다.** 카드가 말한 "비움·절제·금지" 지시는 빼지 않는다. 카드의 지시를 장면의 사물마다 하나씩 풀어 쓰지 않는다.
5. **ANTI-SLOP 블록을 그대로 넣는다.** 아래 `ANTI-SLOP` 블록의 모든 줄을 `[NEGATIVE]`에 글자 그대로 복사한다. 화풍 카드의 `ALLOW`에 적힌 항목만 뺀다.
6. **묘사 단어를 쓰지 않는다:** detailed, highly detailed, intricate, textured, rich, lush, dense, ornate, elaborate, atmospheric, moody, ethereal, dreamy, majestic, magical, mystical.
7. **품질 찬양어를 쓰지 않는다:** beautiful, stunning, gorgeous, masterpiece, best quality, high quality, ultra-detailed, 8k, 4k, HDR, cinematic, epic, award-winning, trending, octane, unreal engine, photorealistic(카드가 요구하지 않으면).
8. **제작자 말투를 쓰지 않는다:** intended, goal, allowed, safe, rather than, instead of, try to, make sure, should, workflow. 원하는 것을 직접 쓴다.

## 쓰는 순서 (속으로만 하고 출력하지 않는다)

A. **장면 결정.**
- 주인공의 위치와 크기: 화면 안쪽에 두고 화면 높이의 절반 이상을 차지하게 한다. 구석에 작게 두지 않는다.
- 시점: 카메라 거리와 높이.
- 자세: 그 동물·인물에게 자연스러운 자세. 동물은 주제가 다른 자세를 요구하지 않으면 네 발로 서거나 앉는다. 팔다리가 어디에 있는지 쓴다.
- 광원 방향. 주제가 요구하지 않은 극적 연출(후광, 스포트라이트, 안개 낀 분위기)은 더하지 않는다.
B. **줄이기.** 이름 붙일 사물을 3개 이하로 줄이고, 카드의 지시를 한 줄에 하나씩 옮긴다.
C. **비움 정하기.** 비어 있거나 평평한 한 가지 색인 곳이 어디인지 정한다. 비움은 한쪽 면 전체가 아니라 사물 사이와 배경 면에 있다.

## 최종 프롬프트 골격 (영어, 이 순서, 이 대괄호 제목 그대로)

```
[IMAGE] 한 줄: 카드 FORMAT + 주제 + 화면비
[SCENE] 주인공, 자세, 화면 속 위치와 크기, 시점, 주제가 말한 배경, 광원. 사물 이름은 3개 이하.
[RENDERING] 카드 RENDER를 줄인 지시. 한 줄에 하나.
[EMPTY] 어디가 비어 있거나 평평한 한 가지 색인지, 장면의 위치로.
[PALETTE] 이름 붙인 색 몇 가지.
[NEGATIVE] ANTI-SLOP 전부(그대로) + 카드 STYLE NEGATIVES + FAILURE FIXES, 한 줄에 하나, 모두 "No"로 시작
```

## ANTI-SLOP (최종 프롬프트에 그대로 복사)

```
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
No text, letters, captions, title, signature, monogram, watermark, logo, frame, or border.
No oversaturated or neon color unless the style card asks for it.
No muddy, smeared, or noisy surface texture.
```

## 출력 전 자가검토 (속으로 다섯 번, 결과는 출력하지 않는다)

1. 주제가 그대로인가? 빠지거나 더해진 것이 없는가?
2. 위치·크기·자세·색이 결정으로 적혀 있고, 막연한 형용사와 묘사 단어가 없는가?
3. 이름 붙인 사물이 3개 이하이고, 주인공이 화면 안쪽에서 높이의 절반 이상인가?
4. 카드의 비움·절제·금지 지시가 살아 있는가?
5. `[NEGATIVE]`에 ANTI-SLOP 블록이 글자 그대로 다 있는가(`ALLOW` 항목만 빠졌는가)? 대괄호 제목 6개가 순서대로 있는가?

하나라도 아니면 고친 뒤에 출력한다. 출력은 코드 블록 하나뿐이다.


## 화풍 카드

```text
STYLE: Postcard Planets Low-Poly Matte
ONE LINE: Flat-shaded low-poly illustration where every object is built from a few large flat triangular facets, each facet one solid fully matte color, with a thick dark-navy contour around each object, bright pastel palette, like a papercraft low-poly diorama painted flat.
FORMAT: single illustration, flat 2D image of low-poly objects, front or slight three-quarter view, full-bleed unless the subject asks for an isolated object on a plain background
SUBJECT POLICY: KEEP
RENDER:
- Every object is a low-poly faceted form: round things are built from 6 to 14 large flat polygon facets, never smooth curves.
- Each facet is one single solid flat color; neighbouring facets differ by one light step to show the form.
- Completely matte surfaces: zero highlights, zero specular spots, zero reflections, zero shine stripes, zero gloss.
- Light from the top-left expressed only by which facets are lighter; no gradients inside a facet.
- Thick dark navy #2b2d42 contour around each object's outer silhouette; inner facet edges are not outlined.
- Glass objects are pale translucent-looking flat facets in light tints, still matte, no glare.
- Simple chunky low-poly shapes, slightly toy-like.
- Depth by overlap and size only.
DENSITY: facet detail only on the main subject; backgrounds are large flat color fields with a few low-poly shapes
PALETTE: warm cream #fff6e6, ink navy #2b2d42, butter yellow #ffd166, coral #ff8a80, mint #8fe3c2, lavender #b9a7f2, sky blue #9fd3ff; bright, soft, never neon; red #e8453c only for danger objects
PRESERVE:
- Visible large flat facets on every object.
- Fully matte flat colors, no shine anywhere.
- Thick navy outer contour.
- Pastel bright mood.
STYLE NEGATIVES:
- No highlights, specular spots, glare, gloss, shine or reflections of any kind.
- No smooth round curves or soft shading; no gradient fills.
- No brush texture, no paper grain, no painterly strokes.
- No 3D render look with lighting effects, no ambient occlusion blur, no drop-shadow blur, no glow.
- No vector app-icon style, no bevel or emboss.
- No letters, numbers or symbols that look like writing.
ALLOW: none
FAILURE FIXES:
- No glossy highlight streaks on glass or round objects (v001 dome and sun had them).
- No smooth hand-painted curves (v001 was painterly, not low-poly).

```

## 주제

A half-set orange sun over a striped coral and yellow sunset band. Isolated single object centered, filling about 80% of the frame, on a plain flat pure white #ffffff background with nothing else. Aspect ratio 1:1 square.
