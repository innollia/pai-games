# Integrate g/sr_hud.gd (race HUD ribbon + control deck + hint chip)

Module: `res://g/sr_hud.gd` (extends CanvasLayer, layer 10; makes its own child CanvasLayer layer 4 for the deck, under tofu's kit pad at layer 5).
It runs its own `_process`, reads game state every frame and redraws only when something changes.
Parse check, a headless runtime test (through mode, count, race, roundend and route, with draw_kit running 3000 frames) and the smoke all pass with no SCRIPT errors.
The off_screen sync script copies `g/sr_*.gd`, so no extra step is needed there.

## 1. Create it (screenrace.gd)

At the top, near the other consts:
```gdscript
const SR_HUD = preload("res://g/sr_hud.gd")
```
Member var:
```gdscript
var sr_hud: CanvasLayer
```
At the END of `_setup()`, after the kit_button calls:
```gdscript
	sr_hud = SR_HUD.new()
	add_child(sr_hud)
	sr_hud.setup(self)
```
`setup()` also hides tofu's big "0" (`_score_l.visible = false`). It makes tofu's back label ("< 메뉴" / "< Restart" / "< List") and `_rate_btn_l` invisible with `self_modulate.a = 0`, then draws paper tags in their place. The hit areas stay tofu's (back: x<180,y<100; rate: Rect2(620,0,100,100)). The rate tag mirrors `_rate_btn_l.visible`. Nothing else is needed for these.

## 2. Control deck positions (in `_setup()`)

Replace:
```gdscript
	kit_stick()
	kit_button("jump", L("점프", "Jump"), Vector2(600, 1120), 100.0, A)
	kit_button("drop", L("짐", "Box"), Vector2(600, 890), 82.0, PARCEL)
```
with:
```gdscript
	kit_stick(SR_HUD.STICK_ZONE)            # Rect2(0,920,360,380) -> tofu home = (180,1100)
	kit_button("jump", L("점프", "Jump"), SR_HUD.JUMP_POS, SR_HUD.JUMP_R, SR_HUD.JUMP_FACE)   # (590,1070) r76
	kit_button("drop", L("짐", "Box"), SR_HUD.BOX_POS, SR_HUD.BOX_R, PARCEL)                  # (440,1150) r54
```
Touch radius is r*1.15: jump 87 (175 px across), box 62 (124 px across). They do not overlap each other or the stick zone (x<360).
If the mode, perk or route screens still reuse the "jump"/"drop" buttons, they move with them. `draw_kit` draws them as generic paper discs with their label outside count/race/roundend. Better: replace those screens with cards and set the buttons' `r = 0` there. Any button with `r == 0` is not drawn.

## 3. Override tofu's kit drawing (new func in screenrace.gd)

```gdscript
func _kit_draw(c: Control) -> void:
	if sr_hud:
		sr_hud.draw_kit(c, self)
	else:
		super._kit_draw(c)
```
`draw_kit` draws the following:
- **Stick:** cream plate r90 with a KRAFT_SH ring r100 and 4 arrow notches. The blue knob (r44, white rim, navy shadow) sits at `_st_o` or `_st_home` plus `kit_move`, and scales to 0.94 while held.
- **JUMP:** orange r72 face, white edge and darker plate. It uses `icon_jump`, or a drawn arrow if that is missing, plus "JUMP"/"점프".
- **BOX:** parcel r50 face. It uses `icon_drop`, then `icon_parcel`, then a drawn parcel, plus a live "x3" count, red at 1 or fewer. A navy pill below it reads "-1 = DASH"/"-1 = 대시".
- **Press feel:** 0.06 s down, 6 px drop, shadow 8 to 2, darken 8%. Release springs back elastically, using `_btns[name].down`.

The race styles apply only in phases count, race and roundend.

## 4. Replace route_l / mode_l during the race (screenrace `_process`, after `super._process(dt)`)

```gdscript
	if sr_hud:
		var racing := phase == "count" or phase == "race" or phase == "roundend"
		sr_hud.set_line(route_l.text if racing else "")
		if racing:
			route_l.visible = false
			mode_l.visible = false
		else:
			mode_l.visible = true   # or hide it too if the mode/perk/route cards replace it
```
`mode_l` ("Classic · Market · R1 · Box 3") is fully covered by the course tag, cargo stack and rank shield.
The `route_l` opening lessons, `tell_s` and signposts now show as the paper hint chip at y≈176. It pops in when the text changes and fades out when the text is "".

The game also gets a timed one-off hint. Use it for new rules, for example where `seen_rules[...] = true` is set, or for `gate_said` / `bridge_said`:
```gdscript
	sr_hud.show_hint(L("짐 3개 이상이면 판자가 떨어진다", "3+ boxes: planks fall"), 2.5)
```

## 5. What the ribbon shows (all automatic, no hooks needed)

| Piece | Rect | Source |
|---|---|---|
| Back tag (kraft) | (12,20,156,60) | tofu back label text, localized |
| Course tag | (186,18,190,66) | mode word + `_cname(ci)` + `rnd` ("MARKET · R1" / "시장 · 1판"; finale "FINAL DELIVERY") with a mode colour stripe |
| Cargo stamp card | (388,18,226,66) | `pl.cargo` filled out of `LOAD_MAX + load_bonus` slots. Gains bounce in (0.30 s, squash). Losses scale 1 to 1.4 to 0, spin 25° and fade red (0.24 s), with a card shake. The border pulses red at 1 box. Speed badge `x0.82` = `1 - LOAD_SLOW*_weight(pl)` |
| Rate tag | (630,20,78,60) | star + "Rate"/"평가", only while `_rate_btn_l.visible` |
| Rank shield | (12,104,116,64) | 1 + alive rivals ahead (x). Gold, silver, bronze, red. Bumps on change: gold flash when rank goes up, wobble when it goes down |
| Distance rail | (140,104,436,62) | pins = (x+2)/(goal_x+2), red tape for the player. The player pin is BLUE, larger and labelled "ME"/"나". Rivals use `r.col`; a dead runner's pin is grey at the start. In lantern mode the bearer pin has an amber glow. Finish flag (`icon_flag` or drawn) and "123m" left |
| Wins card | (588,104,120,62) | WINS stars, gold when below `pl.wins` |

The ribbon, rail and deck show only when phase is count, race or roundend and the game is not over, not rating and not on the how-to card. Back and rate tags always show.
The ribbon positions differ from UI_SPEC's (24,46)-style coordinates on purpose: there the course tag sat inside tofu's back hit zone (x<180,y<100) and the cargo card inside the rate hit rect.

## 6. Not covered by this module

- The left-edge danger strip, the countdown stamps and the camera shift (ground to y≈760, spec 2.2) belong to other workers. The deck covers y 920..1280, so the camera framing change matters.
- Optional palette tweak: rival pins use `Courier.col` (orange, sky, pink), which matches the 3D win pips. To match the GLB skins instead (coral, blue, mint, gold, with the player on coral), change `r.col` in `_reset()`.
