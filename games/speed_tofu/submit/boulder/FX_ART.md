# Boulder 바람·흙먼지 FX 아트

2026-10-31. GPT 내장 `image_gen`으로 개별 생성한 투명 PNG 8장입니다. CLI/API 폴백은 사용하지 않았습니다.

저장 위치: `games/speed_tofu/art/boulder/fx_gpt/`

참고 그림: `temple.png`, `valley.png`, `ui_gpt/panel.png`. 밝은 구아슈 붓질과 따뜻한 크림·연황토 색감을 기준으로 작업했습니다.

| 파일 | 해상도 | 파일 크기 |
|---|---|---:|
| `wind_0.png` | 256×64 px | 9,205 bytes |
| `wind_1.png` | 256×64 px | 12,407 bytes |
| `wind_2.png` | 256×64 px | 11,773 bytes |
| `wind_3.png` | 256×64 px | 10,875 bytes |
| `dust_0.png` | 128×128 px | 18,953 bytes |
| `dust_1.png` | 128×128 px | 15,824 bytes |
| `dust_2.png` | 128×128 px | 17,182 bytes |
| `grit.png` | 64×64 px | 1,601 bytes |

합계 **97,820 bytes (97.82 KB / 95.53 KiB)**. 400KB 이하입니다.

최종 파일은 RGBA PNG입니다. 생성된 알파를 보존하며 Lanczos로 지정 해상도로 축소하고, 알파에 0.7을 곱해 최댓값을 178/255(약 0.698)로 맞췄습니다. 바람은 왼쪽이 짙고 오른쪽으로 흩어지며, `wind_0`는 오른쪽 꼬리를 GPT 편집으로 한 번 더 보정했습니다. 배경·문자·테두리·만화 속도선은 없습니다.

코드 수정, Godot 실행, 커밋은 하지 않았습니다.

## 프롬프트

각 최초 생성 호출은 아래 공통 프롬프트 뒤에 해당 파일의 개별 프롬프트를 이어 붙였고, `transparent_background=true`로 실행했습니다. 참고 그림은 생성 전에 육안으로 확인했습니다.

### 공통 프롬프트

```text
Use case: stylized-concept. Asset type: isolated transparent PNG game FX sprite for a bright hand-painted gouache desert canyon 3D game. Match the reference art seen in the conversation: broad broken gouache brush texture, warm softly lit cream sandstone and light ochre. Palette restricted to cream #efe1c4 through light ochre #d9b27a. Real transparent background, no painted backdrop, no checkerboard, no text, outline, border, shadow, terrain or objects. Soft semitransparent pigment with airy feathered edges and strongest alpha about 0.7. Keep the entire effect inside the canvas with transparent padding.
```

### wind_0.png

```text
A SINGLE horizontally elongated wind trail, final aspect ratio 4:1. One broad low shallow upward-curving dry gouache brush sweep of airborne sand. Densest rounded pigment on LEFT, gradually breaking into dusty wisps and vanishing toward RIGHT. Keep it a low flat ribbon. No thin white lines, comic speed lines, outlines, spiral curls, or multiple effects.
```

### wind_1.png

```text
A SINGLE horizontally elongated wind trail, final aspect ratio 4:1. One broad low gently downward-bowed dry gouache brush sweep of airborne sand with ragged bristle gaps. Densest pigment on LEFT, dispersing into faint grainy wisps and vanishing toward RIGHT. Keep it a low flat ribbon. No thin white lines, comic speed lines, outlines, spiral curls, or multiple effects.
```

### wind_2.png

```text
A SINGLE horizontally elongated wind trail, final aspect ratio 4:1. One broad low gently undulating dry gouache brush sweep of airborne sand, slightly forked wispy tail. Densest pigment on LEFT, breaking into delicate dusty speckles and vanishing toward RIGHT. Keep it a low flat ribbon. No thin white lines, comic speed lines, outlines, spiral curls, or multiple effects.
```

### wind_3.png

```text
A SINGLE horizontally elongated wind trail, final aspect ratio 4:1. One broad low nearly level dry gouache brush sweep of airborne sand, irregular thicker leading left shoulder and light bristle texture. Densest pigment on LEFT, dispersing unevenly into a long faint dusty tail and vanishing toward RIGHT. Keep it a low flat ribbon. No thin white lines, comic speed lines, outlines, spiral curls, or multiple effects.
```

### dust_0.png

```text
A SINGLE rounded rising dust puff from a landing, isolated on square canvas, broad overlapping irregular gouache pigment dabs, a low dense base rising into a soft round dome. Airy broken translucent feathered edges, subtle grain. Soft volume without outlines, no comic cloud scallops, no speed lines.
```

### dust_1.png

```text
A SINGLE rounded rising dust puff from running, isolated on square canvas, asymmetrical gently left-leaning round cloud of broad dry gouache pigment dabs, two softly merging lobes. Airy broken translucent feathered edges, subtle sand grain. Soft volume without outlines, no comic cloud scallops, no speed lines.
```

### dust_2.png

```text
A SINGLE rounded rising dust puff from a landing, isolated on square canvas, loose slightly taller rounded plume with three irregular softly merging broad gouache pigment masses and a diffuse lifted crown. Airy broken translucent feathered edges, subtle sand grain. Soft volume without outlines, no comic cloud scallops, no speed lines.
```

### grit.png

```text
A sparse cluster of just seven small scattered individual sand grains on square transparent canvas. Irregular tiny rounded ochre and cream dry gouache flecks of varied sizes, each separated by plenty of empty transparent space. A few faint grains, a few stronger grains. Soft edges, no rocks, no large cloud, no lines or motion streaks.
```

### wind_0.png 최종 편집 프롬프트

편집 입력: 최초 생성본을 256×64로 축소한 `wind_0.png`. `transparent_background=true`.

```text
Use case: stylized-concept. Asset type: isolated transparent PNG game FX sprite for a bright hand-painted gouache desert canyon 3D game. Match the reference art seen in the conversation: broad broken gouache brush texture, warm softly lit cream sandstone and light ochre. Palette restricted to cream #efe1c4 through light ochre #d9b27a. Real transparent background, no painted backdrop, no checkerboard, no text, outline, border, shadow, terrain or objects. Soft semitransparent pigment with airy feathered edges and strongest alpha about 0.7. Keep the entire effect inside the canvas with transparent padding. Edit this wind sprite only: preserve its single warm gouache sandy brush sweep and its overall shallow curved silhouette. Keep left end dense, but make the entire RIGHT HALF progressively more transparent as it moves right, with the last quarter dissolving into a few soft sparse faint sand flecks and then completely disappearing before the right canvas edge. Remove the solid right tip. No new objects. Wide low flat 4:1 composition. Actual transparent background. No yellow or red outline pixels. Most of the visible pigment concentrated on the left third.
```
