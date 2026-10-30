# Codex task: low-poly painted art for 작은 행성 (tinyplanet)

Folder: C:\projects\pai-games\games\speed_tofu (Godot 4.7.2 web game, portrait 720x1280). The game is currently drawn with plain cubes. Replace them with low-poly models that carry painted textures.

Read first, completely:
- `submit/tinyplanet/ART_DIRECTION.md` (style, palette, model sizes/origins — follow it exactly).
- `C:\projects\hwapongstuy\CLAUDE.md`, `README.md`, `PROCESS.md`, `core/UNIVERSAL_META.md` (the universal rules: ANTI-SLOP), `texture3d/README.md`, `texture3d/FINDINGS.md`, `texture3d/TEXTURE_META.md`, `texture3d/tools/*.py`. hwapongstuy is READ ONLY.
- The proven pipeline from the sibling game: `submit/boulder/build_art.py`, `texture_flow.py`, `align_textures.py`, `finalize_art.py`, `pack_art.py`, `verify_art.py`, `ART_LOG.md`, `VERIFICATION.md`. Copy and adapt them into `submit/tinyplanet/` (never edit the boulder files).

## Models (15)
traveler, villager, windmill_tower, windmill_blades, chimney_house, rock, red_rock, tower, rose, glass_flower, glass_dome, parcel, meteor, tree, wall.
Descriptions:
- traveler: small chubby 3-head-tall wanderer, round head, two dot eyes, cream cape, yellow scarf, folded sail on the back.
- villager: same body plan, plain cream overalls and a simple hat (the game tints it per villager), two dot eyes.
- windmill_tower: tall tapered white-cream tower with a small door and a cap; windmill_blades: 4 blades (yellow/cream canvas on wooden spars) around a hub, in the XY plane, origin at hub.
- chimney_house: small round cottage, coral roof, tall dark chimney.
- rock: grey-lilac faceted boulder. red_rock: tall jagged crimson danger rock (#e8453c family, dark red shadows), reads as DANGER from far.
- tower: short stone lookout tower with a yellow flat top. rose: single rose with a few leaves, coral-red bloom (NOT danger red — use warm pink-coral).
- glass_flower: pale mint glass flower. glass_dome: clear-blue glass bell with a white rim. parcel: kraft-brown parcel with cream string.
- meteor: lumpy dark rock with crimson cracks (danger). tree: round lollipop low-poly tree, mint/green crown, brown trunk. wall: one stone wall block (garden wall), cream stone with lavender shadow.

## Steps
1. `submit/tinyplanet/build_art.py` (Blender 5.2: `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe --background --python ...`) builds the 15 models with the hwapongstuy UV conventions into `submit/tinyplanet/work/out/tp_<name>/` (model.glb, layout.json, guide.png, guide_lines.png). Faceted/low-poly, 40–300 triangles each. Respect the sizes and origins in ART_DIRECTION.md.
2. Textures, ONE asset at a time, built from `texture3d/TEXTURE_META.md` (ANTI-SLOP copied verbatim) + the model's face list + the style line from ART_DIRECTION.md. Try `texture_flow.py tp_<name>` once; nested codex is known to fail with `os error 5` — then use your built-in GPT image generation directly (text-only prompt describing the exact UV polygons, as boulder did), then `align_textures.py` to fit the paint into layout.json faces. Never hand-paint with PIL. Keep each generated original and prompt in work/out/tp_<name>/.
3. `finalize_art.py` (Blender) → unit/size-correct GLBs without embedded images; `pack_art.py` → `art/tinyplanet/<name>.glb` + `<name>.png`, PNG 512x512 quantized, whole folder <= 4 MB. Write `submit/tinyplanet/ASSET_MANIFEST.json`.
4. Put an empty `submit/tinyplanet/.gdignore` and `submit/tinyplanet/.gitignore` containing `work/`. No `.gdignore` inside art/.
5. If no other `Godot_v4.7.2` process is running, import once: `"$LOCALAPPDATA/Temp/opencode/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --import` (a Segmentation fault at exit is harmless if .import files appear).
6. Write `submit/tinyplanet/ART_LOG.md`: per asset the pipeline path (texture_flow / 2D GPT fallback), byte sizes, triangle count, origin/size check.

## Rules
Only write under `submit/tinyplanet/` and `art/tinyplanet/`. Do NOT touch `g/*.gd`, `main.gd`, `tofu.gd`, `web/`, other games' files. No git commands at all. No web build, no screenshots of the game. Bright, readable, matte; red only for danger assets (red_rock, meteor).
