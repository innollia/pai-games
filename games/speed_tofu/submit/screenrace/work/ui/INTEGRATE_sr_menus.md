# INTEGRATE sr_menus.gd (mode cards, perk/route cards, countdown, receipt, rating restyle)

File: `g/sr_menus.gd` (extends CanvasLayer, layer 15; it also makes a child CanvasLayer at layer 0 for a paper wash: above 3D, below tofu HUD (1), kit (5), rating (9) and how-to (10)).
No class_name. It uses only `g/sr_theme.gd`. The off_screen build needs `tools/sync.ps1` to copy `g/sr_*.gd`, which it already does.

## Public API
| call | when |
|---|---|
| `setup(game)` | once, in `_setup()` after `add_child`. It restyles the rating card on a deferred call, and the how-to card too if it exists. |
| `show_modes()` | phase becomes "mode" |
| `show_perks(perk_offer)` | phase becomes "perk" |
| `show_routes(route_offer, pl.cargo)` | phase becomes "route" |
| `countdown_tick(0/1/2)` | READY at pt 1.4, SET at pt 0.7, DELIVER! at pt 0. It hides itself 0.6 s after stage 2. `hide_countdown()` hides it at once. |
| `show_results(data)` | in `_finish` |
| `hide_all()` | closes the mode, choice and results screens (not the countdown); call in `_reset()` |
| `refresh()` | after a language change; re-fills the current screen and re-localizes the rating and how-to cards |
| `restyle_rating(game)` / `restyle_howto(game)` | already called by setup; public so you can call them again |
| vars | `show_lang` (default true), `show_back` (default true), `auto_headless` (default true: in a headless run, a choice screen picks for itself after 0.8 s, so the smoke still reaches the race) |

Signals: `mode_chosen(id)` with `"base"/"lantern"/"over"`, `back_pressed`, `lang_pressed`, `perk_chosen(i)`, `route_chosen(i)` (i 0 = top card, 1 = bottom card), `again_pressed`, `title_pressed`.
Keyboard is built in. Mode: Left/Right or 1-3, Enter/Space. Choice: 1/2, Up/Down then Enter. Results: Enter = again, Esc = title. These work only while that screen is up.
The module hides itself while `game._rating` is true or `_howto_box` is visible.

## Code to add to screenrace.gd
```gdscript
const SrMenus = preload("res://g/sr_menus.gd")
var menus  # sr_menus

const MODE_KIT := {"base": "jump", "lantern": "drop", "over": "mode_over"}  # _pick_mode still takes kit names
```
**_setup()** (at the end):
```gdscript
	menus = SrMenus.new()
	add_child(menus)
	menus.setup(self)
	menus.mode_chosen.connect(func(id: String) -> void: _pick_mode(MODE_KIT[id]))
	menus.perk_chosen.connect(func(i: int) -> void: _pick_perk("jump" if i == 0 else "drop"))
	menus.route_chosen.connect(func(i: int) -> void: _pick_route("jump" if i == 0 else "drop"))
	menus.lang_pressed.connect(func() -> void:
		_set_lang("en" if lang == "ko" else "ko")
		menus.refresh())
	menus.back_pressed.connect(func() -> void: back.emit())   # or show your title module
	menus.again_pressed.connect(func() -> void:
		var m := mode
		restart()                 # -> _reset -> show_modes()
		_pick_mode(MODE_KIT[m]))  # same mode straight away (_pick_mode calls hide_all through _start_round -> countdown)
	menus.title_pressed.connect(func() -> void: restart())   # lands on mode select (or your title screen)
```
Also call `menus.refresh()` at the end of `_set_lang()`. Language can then change from anywhere, including the HUD toggle.

**_reset()**: put `if menus: menus.hide_all()` near the top. At the end, after `phase = "mode"`, put `menus.show_modes()` in place of `_mode_buttons()`.

**_pick_mode(n)**: keep it as it is. You can drop the `_btns["lang"]` and `_btns["mode_over"]` lines once those kit buttons are gone. Add `menus.hide_all()`.

**_after_round()**: in the perk branch, remove the two `_btns[...].label = _perk(...)` lines and add `menus.show_perks(perk_offer)` after `phase = "perk"`. In the route branch, remove the two label lines and add `menus.show_routes(route_offer, pl.cargo)` after `phase = "route"`.

**_start_round()**: right after `phase = "count"` / `pt = 1.4`, add `menus.countdown_tick(0)`.

**_step() "count"**:
```gdscript
		"count":
			var before := pt
			pt -= dt
			if before > 0.7 and pt <= 0.7:
				_sfx("go")
				menus.countdown_tick(1)
			if pt <= 0.0:
				phase = "race"
				menus.countdown_tick(2)
				play("good")
```
Remove the old `_stamp("배송 출발", "OUT FOR DELIVERY", ...)`. The DELIVER! stamp replaces it.

**_step() "perk" / "mode" / "route"**: remove the `kit_just` loops. The cards emit signals now, and the smoke is covered by `auto_headless`. Keep the `kit_just("lang")` branch only if the lang kit button stays.

**_finish(won)**: keep all the record logic. Replace the `result_l.text = ...` block (and `result_l.visible = true`) with:
```gdscript
	var medals := [0, 0, 0, 0, 0, 0]
	for row in course_results:
		medals[row.ci] = maxi(medals[row.ci], int(row.medal))   # 3 gold, 2 silver, 1 bronze, 0 not reached
	var names := []
	for i in COURSES.size():
		names.append(_cname(i))
	menus.show_results({
		"won": won,
		"placement": placement,
		"delivered": delivered,
		"time": journey_time,
		"best_course": strongest,
		"best_delivery": best_delivery,
		"new_record": delivered > previous,
		"best_time": best_time,              # 0 = no finish yet
		"medals": medals,
		"courses": names,
		"hint": hint,
		"saved": saved,
		"mode": _mode_name(mode),
		"headline": L("여섯 동네 배달 완료!", "All six towns delivered!") if won else L("오늘 배달은 여기까지", "That's it for today"),
	})
```
`phase = "results"` and `end()` stay. Tofu still owns the stars, the comment button and tap-to-restart.

The receipt sits at y 96..846, clear of the star rows (`_STAR_RECT` y 860..980, `_WORD_RECT` y 1000..1090). A tap on the receipt is eaten. A tap outside it (below the stars) still restarts as before. The receipt buttons turn on after 0.8 s, like tofu's 0.7 s `wait`.

**_process()**: `result_l` is no longer used. Set `result_l.visible = false` or delete the lines.

**_update_content_hud()**: in phases "mode", "perk" and "route", set `route_l.text = ""` and return. The cards now show that text. Also blank `mode_l` in "mode" (it says "tap one" in `_step`).

## Old UI this replaces (remove or hide)
- The kit buttons used as menu buttons: `mode_over` and `lang` (`kit_button` in `_setup`, plus `_mode_buttons()`). Delete them. Keep `jump`/`drop` for the race only, and don't relabel them with perk or route names.
- The `route_l` mode, perk and route text, and `result_l`.
- The OUT FOR DELIVERY stamp at race start.
- Optional: the kit pad (layer 5) still draws the stick over the wash during menus. If the HUD module overrides `_kit_draw`, skip drawing when `phase in ["mode", "perk", "route", "results"]`.
- `_score_l` and `_over_l` are hidden by other modules or screenrace already, so nothing to do here.

## Art used (all optional, drawn fallback when missing)
`mode_classic/lantern/rush`, `icon_parcel/lantern/flag`, perk icons, `icon_gate/ice/headwind`, `seal_gold/silver/bronze`, `paper_grain`, all in `res://art/screenrace/ui/`. Drawn fallbacks: parcel, lantern, rush chevrons, gate, snowflake, headwind arrows, and wax seals with a star.

## Sounds (via game._sfx)
`stamp` on card taps and stamp slams, `bell` on DELIVER (mode start). The countdown's `go` sound stays where it is in `_step`.
