# Finish the v6 upgrade of boulder (굴러라 신전석)

Folder: C:\projects\pai-games\games\speed_tofu (Godot 4.7.2, web, portrait 720x1280). An earlier run stopped partway with exit code 1.

## Already done (keep it, don't redo it)
- g/boulder.gd: about 600 new lines. `_load_art()` (ART_ROOT "res://art/boulder/", ART_NAMES stone, pillar, valley, snow, coast, crystal, plank, temple, pot; it loads <name>.glb + <name>.png), new zones (current/flow, drum), ending (`_finish`/`_ending_tick`), records (GOLD_TIME/SILVER_TIME, user://boulder_v6.cfg), journey UI.
- submit/boulder/build_art.py made 9 low-poly models: submit/boulder/work/out/b6_*/model.glb.
- GPT textures exist ONLY for stone, pillar, snow, valley (work/out/b6_<name>/texture.png). They look good. Keep that style.
- Helper scripts already there: finalize_art.py, pack_art.py, preview_art.py, verify_course.py, texture_flow.py.

## Still missing. The game is broken now: art/boulder/ does not exist.
1. Make GPT textures for coast, crystal, plank, temple and pot with submit/boulder/texture_flow.py, one at a time. If a nested codex call fails (for example "failed to initialize in-process app-server client: os error 5"), retry once. If it fails again, make that texture with a 2D GPT image instead. If that is also impossible, hand-paint it with PIL following guide.png / layout.json in the same gouache style. Record which assets used a fallback.
2. Create games/speed_tofu/art/boulder/ with exactly the 9 pairs <name>.glb + <name>.png. Downscale every png to 512x512 so the folder is 4 MB or less. No .gdignore in art/.
3. Make sure no other Godot_v4.7.2 process is running (another session builds in this folder; if one is running, wait). Then import once: `"$LOCALAPPDATA/Temp/opencode/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --import`, and run ONE smoke: `... --headless --path . --fixed-fps 60 -s tools/smoke.gd -- boulder > "$TEMP/smoke_boulder.txt" 2>&1`. Fix any SCRIPT ERROR in g/boulder.gd.
4. Content check: 2 or more NEW zones that change HOW you play, each followed by a mixing section that combines the new verb with earlier verbs; a real ending (reaching the sea) with time and grade; a replay reason (gold/silver times, best record shown). Finish anything that is stubbed. Update the Korean `howto` text for the new zones.
5. Write submit/boulder/ART_LOG.md (assets, pipeline path for each, sizes). Update ART.md, HOWTO_EN.md and ITCH_PAGE.md for the new zones, ending and art. The ITCH_PAGE tools line must say the textures are GPT-generated images.

## Rules
Only edit g/boulder.gd, art/boulder/ and submit/boulder/. Never touch main.gd, tofu.gd, GA.md, other g/*.gd or web/. No git commands at all. C:\projects\hwapongstuy is read-only. Don't run tools/build.ps1. No bots, no screenshots. Bright, readable visuals.
