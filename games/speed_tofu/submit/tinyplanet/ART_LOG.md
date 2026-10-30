# Tinyplanet art log

## Previous 15 assets — original Postcard Planets pass

Historical sizes and asset list: `ASSET_MANIFEST.json`; original descriptions and full ANTI-SLOP prompts: `work/out/tp_*/prompt.txt`. Low-poly meshes with separate 512×512 generated-paint atlases, matte cream/navy/pastel palette; red reserved for danger.

- `chimney_house`: Round cream cottage, pink coral roof, tall dark chimney. Original pair 83,184 bytes.
- `glass_dome`: Clear-blue glass bell with white rim. Original pair 72,592 bytes.
- `glass_flower`: pale mint glass flower, cream edges, broad flat sky blue shadow, matte. Original pair 77,194 bytes.
- `meteor`: DANGER dark navy rock with crimson #e8453c broad angular cracks. Original pair 119,330 bytes.
- `parcel`: Kraft brown parcel with cream string cross. Original pair 73,946 bytes.
- `red_rock`: DANGER crimson #e8453c rock; dark red shadows, sharp scarlet upper edges. Original pair 108,838 bytes.
- `rock`: grey lilac boulder, broad cream upper facet and lavender underside. Original pair 51,022 bytes.
- `rose`: warm pink coral #ff8a80 rose bloom; a few broad overlapping petal arcs; NO danger red. Original pair 81,209 bytes.
- `tower`: Short stone lookout tower, yellow flat top. Original pair 77,965 bytes.
- `traveler`: Chubby three-head-tall traveler, facing Blender -Y / exported -Z. Original pair 81,326 bytes.
- `tree`: Lollipop tree with round low-poly mint crown and brown trunk. Original pair 79,176 bytes.
- `villager`: Chubby three-head-tall villager, facing Blender -Y / exported -Z. Original pair 93,012 bytes.
- `wall`: Cream stone garden wall unit, lavender shadows. Original pair 55,362 bytes.
- `windmill_blades`: Four canvas blades in Blender XZ plane, exported XY plane, origin hub. Original pair 66,411 bytes.
- `windmill_tower`: Tall tapered cream windmill tower with cap and small front door. Original pair 93,912 bytes.

## 2026-10-31 — round mascot remake

Replaced only `traveler.glb/.png` and `villager.glb/.png`. Both use a continuous 10-sided egg/bean body with merged head, two high navy dot eyes, short rounded feet and nub arms. Traveler: cream, wrapped yellow scarf with bent rear tail, closed triangular folded sail. Villager: cream overalls with broad straps and mesh-built flat-brim hat; compatible with runtime tint.

Traveler **350 triangles**, villager **378 triangles**; each **1.6 m**, base footprint centered at origin, +Y up, front −Z. External **512×512 PNG**, no embedded images or materials. Reused `build_art.py`, `prepare_textures.py`, `align_textures.py`, `finalize_art.py`, and `pack_art.py` through scoped wrappers; original generated paint crops were remapped without new painting. TEXTURE_META ANTI-SLOP retained verbatim. hwapongstuy remained read-only.

Reproduction: `work/remake_characters.py` (Blender: build/finalize/preview), `work/remake_textures.py` (Python), `work/round_remake/pack_selected.py` (Python). New layouts, prompts, crop provenance, manifest, previews and passing binary checks live in `work/round_remake/`. The original ASSET_MANIFEST remains historical; current four-file sizes are in the revision manifest. Other 26 production art files match their pre-edit SHA-256 hashes. No Godot or git commands used; gameplay files and web untouched.

## 2026-10-31 - The Little Courier: separate chibi kids

Replaced only production `art/tinyplanet/traveler.glb`, `traveler.png`, `villager.glb`, and `villager.png`. Traveler is now a sky-blue little mail courier with a separate 12-sided round head (0.72 m, 45% of 1.6 m height), short coat, separate arms and legs, rounded boots, small flat cap, long backward-flowing yellow scarf and brown chamfered mail satchel. Both characters have two dark oval eyes with cream-white glints and rosy cheeks; no mouth. Villager uses the same kit with neutral cream overalls/apron and a round brim hat.

- Traveler: 680 triangles; GLB 52,808 bytes; PNG 82,188 bytes. Mesh nodes: `head`, `body`, `arm_l`, `arm_r`, `leg_l`, `leg_r`, `scarf`, `cap`, `satchel`.
- Villager: 602 triangles; GLB 46,208 bytes; PNG 77,786 bytes. Mesh nodes: `head`, `body`, `arm_l`, `arm_r`, `leg_l`, `leg_r`, `hat`.
- Both: 1.6 m tall, scene origin at base center between feet, +Y up, front -Z. Shoulder/hip pivots retained for swinging limbs. External RGB 512x512 PNG; no embedded images, textures or materials. Total four-file size 258,990 bytes. RGB packing preserves tiny pink cheeks that median-cut quantization otherwise merged into brown.

Pipeline: scoped `work/courier_characters.py` reuses the helpers/exporter loaded by `build_art.py`, original `prepare_textures.py` and `align_textures.py`, the physical-metres/external-texture convention of `finalize_art.py` adapted for multiple nodes, and a scoped `pack_art.py` wrapper. Preserved GPT-generated paint crops from the original traveler, glass dome, rose and tree were remapped; no new image generation or hand painting. Full source crop provenance, UV layouts, prompts with TEXTURE_META ANTI-SLOP verbatim, mesh checks, four-file manifest and binary verification live in `work/courier_remake/`. Original pipeline scripts and historical manifest remain unchanged. hwapongstuy was read-only.

Previews: `work/traveler_front.png`, `work/traveler_threequarter.png`, `work/villager_front.png`, `work/villager_threequarter.png` (all 512x512). `work/courier_small_size_check.png` compares them at 128, 96 and 64 px. Visual QA: separate head/coat/limbs, glint eyes, pink cheeks and distinctive hats read as chibi children, with courier scarf and bag visible from 3/4. Verification: `python submit/tinyplanet/work/verify_courier.py` checks GLB data, exact part names, geometry bounds, base alignment, front eye positions, finite normals/UVs, texture dimensions and rosy color, full ANTI-SLOP, previews and hashes of all 56 non-target art files. PASS. No git or Godot commands; gameplay, web and other games untouched.

Reproduce from speed_tofu: Blender 5.2 `--background --python submit/tinyplanet/work/courier_characters.py -- build`; Python same script with `textures`; Blender same script with `finalize`; Python `submit/tinyplanet/work/courier_remake/pack_selected.py`; Blender same script with `preview`; Python `submit/tinyplanet/work/verify_courier.py`.
