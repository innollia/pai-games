# Boulder v6 asset log — 2026-10-30

Production root: `games/speed_tofu/art/boulder/`. Exactly nine GLB/PNG asset pairs; all PNGs are 512×512. Total asset payload: **979,163 bytes** (0.979 MB). Godot creates additional `.import` metadata sidecars. No `.gdignore` exists anywhere under art/.

| Asset | Texture pipeline | GLB bytes | PNG bytes |
| --- | --- | ---: | ---: |
| stone | Existing GPT texture, preserved | 7,256 | 127,085 |
| pillar | Existing GPT texture, preserved | 5,556 | 152,096 |
| valley | Existing GPT texture, preserved | 1,752 | 140,719 |
| snow | Existing GPT texture, preserved | 1,748 | 150,086 |
| coast | 2D GPT fallback, UV aligned | 1,748 | 58,982 |
| crystal | 2D GPT fallback, UV aligned | 4,556 | 105,912 |
| plank | 2D GPT fallback, UV aligned | 1,748 | 68,789 |
| temple | 2D GPT fallback, UV aligned | 6,448 | 43,854 |
| pot | 2D GPT fallback, UV aligned | 5,980 | 94,848 |

## Sources and reproduction

For each `<name>`, source model, UV guide, layout and final source texture are in `submit/boulder/work/out/b6_<name>/{model.glb,guide.png,guide_lines.png,layout.json,texture.png}`. Existing four GPT paintings were kept. All models were already produced by `build_art.py` using the read-only hwapongstuy UV conventions.

Missing textures were attempted **one asset at a time**, in coast/crystal/plank/temple/pot order, using `python submit/boulder/texture_flow.py b6_<name> --timeout 300`, followed by exactly one `--force` retry. Each of the ten nested Codex invocations failed with `failed to initialize in-process app-server client` / access denied (`os error 5`). Retried invocation logs remain at `work/cleanroom/texture3d_b6_<name>/run.log`. Oracle was consulted; no directly applicable nested-client fix was found.

The first built-in 2D GPT coast request with reference images failed with `network error: error sending request`. Oracle records suggested omitting local reference attachments. The text-only retry succeeded, then crystal, plank, temple and pot were generated sequentially by the same built-in GPT image tool. **All five missing assets used the authorized 2D GPT fallback. No PIL hand-painted fallback was used.**

For these five, `generated.png` preserves the original GPT image and `prompt.txt` preserves the full successful prompt in the corresponding `work/out/b6_<name>/` folder. Prompts specify exact UV polygons, broad matte gouache planes, sparse chips, flat surfaces, no text/runes/perspective, and the cream/cobalt/mint/ochre/terracotta/teal palette. Material prompts: coast shell limestone and strata; crystal lavender facets and plum base; plank ochre grain and ivory ties; temple sandstone steps/columns/frieze/pediment; pot terracotta belly/cobalt shoulder/cream lip.

GPT preserved island topology but shifted/scaled it. `python submit/boulder/align_textures.py coast crystal plank temple pot` crops and resamples generated paint into the exact `layout.json` faces, masking the unused area to gray. This is UV alignment, with no procedural repainting. Final source atlases were visually inspected as image files; no game screenshots were taken.

Normalize and export meshes with Blender 5.2: `blender.exe --background --python submit/boulder/finalize_art.py`. It preserves UVs and full geometry, joins mesh nodes if needed, centers meshes to unit bounds and removes embedded materials. Godot applies the separate shared texture materials. Then `python submit/boulder/pack_art.py` resizes every PNG to 512×512 with Lanczos, quantizes to 192 colors, and writes `ASSET_MANIFEST.json` with exact byte counts. Both production payload and directory including Godot sidecars remain below 4 MB.

## Validation scope

`verify_course.py` checks eleven regions, both new mechanics and their mixing sections, persistent records, ending markers, and the charged-launch envelope for sizes 2.0/3.5/5.0/7.0. Godot import and the single required smoke result are recorded in `VERIFICATION.md`. No git commands, web build, new bots or screenshots were used.
