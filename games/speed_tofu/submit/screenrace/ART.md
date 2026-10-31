# 화면 밖 경주 — ART direction

Written before asset production, 2026-10-30. Style: **Pocket Parcel Town**.

> Update 2026-10-31: the couriers, parcel, train and bridge board were remodeled to match the cover (`cover.png`, side-by-side check `work/cover_match.png`): big-head paper-toy couriers with a `run_loop` animation, parcels stacked in one tall column on the back. UI art (logo, icons, mode art, seals, tutorial panels, paper grain) lives in `art/screenrace/ui/` (`LIST.md`); UI rules in `DESIGN_SYSTEM.md`. Backdrops are unchanged (user: "배경은 아직은 괜찮아").

Chunky folded-paper toys with hand-painted gouache surfaces. A courier has a large cap, peach face, small forward nose, short jacket, mitten hands and oversized running shoes. Boxes belong on the back, behind the head silhouette; never bake a cargo stack into the courier. Rounded/chamfered silhouettes, broad wedges and a few confident brush marks; no outlined placeholder cubes, photographic texture or random fine noise.

## Palette and light

Common ink/shadow #34334B, warm paper #FFF0D5, cardboard #DDA56A, tape #F8D58A. Foreground saturation and value contrast exceed the backdrops. Painted top light, warm upper bevels, cool lower folds, matte surfaces; use unlit materials for predictable Compatibility/web rendering. Painted seam strokes replace a costly mesh outline. Face/eyes remain dark at small scale. Courier player accents: coral #E86758, blue #508CC8, mint #62AD91, gold #E8B34B; recolour clothing only, retain skin and shoes.

| Course | Backdrop palette | Motifs |
| --- | --- | --- |
| 시장 | cream, muted apricot, sage, dusty coral | striped awnings, tile roofs, baskets, village shop fronts |
| 강변 | pale aqua, powder blue, soft jade | slow broad river bands, reeds, distant arched bridge |
| 건널목 | butter sky, ochre, slate blue | small station, telegraph poles, distant rails |
| 야시장 | dusty mauve, muted rose, warm amber | hanging paper lamps, closed stall roofs, evening town |
| 흔들다리 | pale mint, moss, blue-green | layered wooded gorge, distant suspension ropes |
| 지붕 | lavender, peach, desaturated indigo | overlapping ceramic rooftops, chimneys, water tanks |
| 밤 등불 | deep indigo, slate violet, muted teal | quiet town silhouettes and broad empty night sky |

No fake glow on texture atlas. Lantern amber panes are painted; its actual gameplay light/fog is supplied by the game. No baked fog obscuring collision geometry. Night backdrop is scenery, not the gameplay visibility mask.

## Asset split

3D GLB: courier, parcel, train, lantern, crate, market stall/awning, bridge board. Their silhouettes, jumping/squash, cargo stacking and changing camera scale benefit from geometry. Courier is one shared silhouette with four clothing variants and named limb pivots. Train nose points **-X**, toward incoming runners. Props use actual modeled profiles; material details are GPT-painted UV textures, not code-drawn surface decoration.

2D: seven separately painted wide backdrops. Distant scenery needs no collision or mesh depth and is cheaper as one image per course. Landscape images preserve open sky and a quiet lower band; do not treat painted bridges/roofs as platforms. No optional title/HUD images are required for this delivery.

## Portrait framing / HUD

720×1280 portrait. Orthographic side view, +X forward, +Y up, camera on +Z. Runner visual envelope 0.8×2.4 world units; root at feet. Parcels must remain individually countable at the smallest camera scale. Allow clear sky above cargo stacks and keep the race band behind runners quiet. Backdrop recommended starting plane 64×32 units behind gameplay, parallax 0.12–0.2, cropped rather than stretched; images are not assumed seamless.

HUD uses existing Korean-capable system/game font; semibold numbers, dark ink on cream panels, 28px minimum secondary copy, 36px parcel counts. Player identities use number/name as well as colour. Keep top 150px for status, lower ~240px for touch controls. Bright obstacle tops and the left elimination warning must remain more prominent than scenery.

## Production and limits

Follow texture3d's axis-aligned UV guides, explicit per-face coordinates, grey unused atlas area and complete anti-slop block. Paint first, inspect atlas and textured model preview, then export GLB. Textures 512–1024px; backdrops resized/compressed for web. Deliverables under `art/screenrace/` total at most 6,000,000 bytes. Do not modify gameplay or exports. Exact dimensions, roots, animation hooks, loading and limitations are recorded in MANIFEST.md.
