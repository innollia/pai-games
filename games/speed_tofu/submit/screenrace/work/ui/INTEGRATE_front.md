# Integrating g/sr_front.gd (title screen + interactive tutorial)

`g/sr_front.gd` is a CanvasLayer on layer 20. It draws the title screen over the live course-1 diorama and runs the 5-step practice: run → jump the crate → throw a box → the red edge → "Ready? Deliver!". Every string goes through `game.L()`. The module calls only the things listed under "What the module reads/calls" below.

Tested in a scratch subclass of screenrace.gd that contained exactly the hooks below. Title → HOW TO PLAY → all 5 steps → `tutorial_done` → race works. The language toggle works. A random-tap smoke run reached PLAY, then the tutorial, a race and the results screen with no script errors.

## Public API
```gdscript
const SrFront = preload("res://g/sr_front.gd")
var front  # SrFront

signal play_pressed                    # PLAY when the tutorial is already done -> open mode select
signal tutorial_pressed(first_run: bool)  # PLAY on first run (true) or HOW TO PLAY (false)
signal lang_pressed                    # language pill; the module redraws its own text right after
signal tutorial_done(first_run: bool)  # tutorial finished or SKIP; tutorial_done is already saved

front.setup(game)            # once, in _setup
front.show_title()           # sets front.state = "title"; staggered pop-in, PLAY bobs
front.hide_title()           # the module calls this itself on PLAY / HOW TO PLAY
front.start_tutorial(first)  # after game.tutorial_begin()
front.refresh_text()         # call if lang changes from somewhere else
front.needs_tutorial() -> bool   # records [opt] tutorial_done missing
front.tap(p) -> bool         # mouse/smoke taps that bypass the GUI; true = consumed
front.state                  # "" | "title" | "tutorial"
front.auto_tutorial_on_play  # default true: first-run PLAY runs the tutorial, then a Classic race
```

## Required hooks in g/screenrace.gd

### 1. Members (near the other `var`s)
```gdscript
const SrFront = preload("res://g/sr_front.gd")
var front
var tut_crate_x := -1.0  # > 0: the opening flat gets one practice crate at this x (tutorial only)
```

### 2. `_setup()`: create the module and kill tofu's text how-to card
Replace `howto = _howto_text()` with `howto = ""`. With this, tofu never builds `_howto_box`, which is the white card with the blob behind it. Then add at the end of `_setup()`:
```gdscript
	front = SrFront.new()
	add_child(front)
	front.setup(self)
	front.play_pressed.connect(func() -> void:
		_open_mode_select())   # cards module: phase = "mode" + show the 3 postal cards
	front.tutorial_pressed.connect(func(first: bool) -> void:
		tutorial_begin()
		front.start_tutorial(first))
	front.lang_pressed.connect(func() -> void:
		_set_lang("en" if lang == "ko" else "ko"))
	front.tutorial_done.connect(func(first: bool) -> void:
		tut_crate_x = -1.0
		if first:
			_pick_mode("jump")      # first run: straight into a Classic race
		else:
			_open_mode_select())
```
`_open_mode_select()` stands for whatever the cards module exposes. Before the cards module exists, use `phase = "mode"; _mode_buttons()`.
In `_set_lang()` the line `howto = _howto_text()` is harmless and can stay.

### 3. `_reset()`: open on the title, not the mode screen
At the very end of `_reset()`, replace
```gdscript
	phase = "mode"
	_mode_buttons()
```
with
```gdscript
	phase = "title"
	tell_t = 0.0
	front.show_title()
```
`_reset` has already built course 1 and placed the 4 couriers, so the diorama sits behind the title. In phase "title", `_step` runs no match arm; only parcels, camera and drawing update. The couriers stand still.

### 4. New function `tutorial_begin()`
```gdscript
## sr_front: course 1 opening flat as an empty practice yard (no rivals, one crate).
func tutorial_begin() -> void:
	ci = 0
	rnd = 0
	finale = false
	mode = "base"
	fresh = true
	twist = ""
	tut_crate_x = 16.0
	_build_course()
	_start_round()
	for r in runners:
		if r.ai:
			r.alive = false        # _start_round() of the next real race sets them back
			r.node.visible = false
	phase = "tutorial"
	tell_t = 0.0
```

### 5. `_build_course()`: the practice crate
Inside the `if ci == 0 and rnd == 0 and not finale:` branch, after `_floor(gx, 90.0)`:
```gdscript
		if tut_crate_x > 0.0:
			_bump(tut_crate_x, fy, 1.0, 1.0, cdef.wall, 0.0, 0.0)  # 1 m wall-faced crate: must jump
```
This runs before the buckets are rebuilt, so collision works. `_pick_mode()` rebuilds the course after `tut_crate_x` is reset, so real races have no crate.

### 6. `_step()`: two new match arms
```gdscript
		"title":
			pass
		"tutorial":
			pl.mx = kit_move.x
			pl.i_jump = kit_just("jump")
			pl.i_jheld = kit_held("jump")
			pl.i_drop = kit_just("drop")
			_runner(pl, dt)
			pl.p.x = minf(pl.p.x, 80.0)       # stay on the opening flat
			if pl.p.y < kill_y:
				pl.p = Vector2(camx, 2.0)
				pl.v = Vector2.ZERO
```
No edge elimination, pickups, AI or timers run in the tutorial. The real `kit_just` and `kit_held` feed the player. The module detects each step from physics: `pl.p.x` distance, leaving the ground with `pl.v.y > 3`, and `pl.cargo` dropping. It cannot read `kit_just` itself, because `_justs` is cleared before its own `_process` runs.

### 7. `_tap()` (screenrace.gd has none today)
```gdscript
func _tap(p: Vector2) -> void:
	if front and front.tap(p):
		return
```
On a phone, PaperButtons take touches through the GUI, so `_unhandled_input` never sees them. This hook covers the mouse/smoke path: tofu `_finger` → `_tap`. Without it the smoke run sits on the title forever. Both paths debounce, so a press fires only once.

### 8. Hide old UI during "title" and "tutorial"
- `_step` end: `mode_l.text = ...` → set `mode_l.visible = phase != "title" and phase != "tutorial"`. Do the same for `route_l`. `_start_round` calls `_tell()`, so `tell_t = 0.0` is already set in `tutorial_begin`.
- If the HUD agent has not already removed `_score_l` (the big "0"), `_bar_bg` (gauge) and the HUD ribbon: hide them while `phase == "title"`.
- Kit drawing: the title's kraft deck (y 856–1280, opaque) already covers the stick and buttons. Still, skip drawing in the `_kit_draw` override: `if phase == "title": return`. In "tutorial" the kit must draw and work normally, because the module puts its rings on `_btns["jump"]`, `_btns["drop"]` and `_st_home`.
- Kit hits on the title: the title's blocker Controls swallow GUI touches. Only the top-left "< Restart/< 메뉴" corner (x < 180, y < 100) falls through to tofu, on purpose. The kit's `_unhandled_input` therefore never sees title touches on a phone. Nothing to do.
- `_mode_buttons()` / the `lang` kit button: no longer needed for the front door. The pill handles language.
- tofu's rate button: the module hides itself while `game._rating` is true, so the star card (layer 9) is not covered.

### 9. Optional
- Title life: couriers idle in phase "title". To make the AI jog in place, add to the "title" arm: `for r in runners: r.sq = 0.06 * sin(Time.get_ticks_msec() * 0.012 + r.col.r * 9.0)`.
- After results, tofu's tap-to-restart calls `restart()` → `_reset()` → title again. That is intended: PLAY then goes to mode select, because the tutorial is done.

## What the module reads/calls on the game
`game.L(ko, en)`, `game.lang`, `game.records` (ConfigFile; reads `base/lantern/over` `delivered`, writes `[opt] tutorial_done` and saves to `game.RECORDS`, fallback `user://screenrace_v7.cfg`), `game.play("tap"|"good"|"bell")`, `game.pl` (`.p`, `.v`, `.grounded`, `.cargo`), `game._btns["jump"/"drop"].pos/.r`, `game._stick_zone`, `game._st_home`, `game._rating`, `game.tut_crate_x` (read with `get`; missing is fine).

## Layout (720×1280)
Title: logo 620×272 at (50,150) (`logo.png`, or a drawn cut-paper logo); KO subtitle tag at (250,418) in Korean only; tagline paper strip 600×84 at (60,478); speed strips y 120–580; kraft deck with torn white edge y 856–1280; PLAY 460×110 RED at (130,900), bobbing ±8 px; HOW TO PLAY 300×84 CREAM at (50,1046); EN|한국어 pill 300×76 at (370,1050); best-record line at y 1166. Pop-ins are staggered 0.06 s apart; the logo stamp-slams in and sways ±1.5°.
Tutorial: speech card 648×136 at (36,770) with its tail pointing at the target control; SKIP 150×60 KRAFT at (534,696); "NICE!" green stamp at (200,670) between steps; gold pulse rings and a paper finger on the stick, Jump or Box; red pulse strip and arrow at the left edge for step 4. Enter/Space on the title = PLAY (desktop).
