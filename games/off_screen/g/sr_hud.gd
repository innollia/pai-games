extends CanvasLayer
## 화면 밖 경주: 경주 화면 UI (최소판).
## 경주 중 보이는 것은 셋뿐: (1) 맨 위 얇은 진행 막대 하나 (코스 진행 + 경쟁자 핀 순서 + 결승 깃발을 한 줄에),
## (2) 땅 위에 떠 있는 조작 버튼 (스틱·점프·짐), (3) 왼쪽 찢긴 종이 끝 (screenrace 의 _fx_draw_edge).
## 짐은 배달부 등에 실린 상자와 짐 버튼 얼굴의 상자 더미가 보여 준다 (숫자 없음). 이긴 판은 머리 위 표시가 맡는다.
## v12: 핀 안의 숫자 = 이번 판 배달한 짐 (배달 1등 핀은 금 테), 막대 아래 작은 우체통 표 (빨강 = 빈 곳, 골판지 = 찬 곳).
## 쓰는 법 (screenrace.gd):
##   const SR_HUD = preload("res://g/sr_hud.gd")
##   _setup() 끝: sr_hud = SR_HUD.new(); add_child(sr_hud); sr_hud.setup(self)
##   func _kit_draw(c: Control) -> void: sr_hud.draw_kit(c, self)
## 바뀐 때만 다시 그린다 (막대는 핀이 1 px 이상 움직일 때만).

const T = preload("res://g/sr_theme.gd")

# ---------------------------------------------------------------- 조작 자리 (screenrace._setup 이 이대로 놓는다)
const STICK_ZONE := Rect2(0, 920, 360, 380)  # tofu: home = (zone 가운데 x, zone.end.y - 200) = (180, 1100)
const STICK_HOME := Vector2(180, 1100)
const JUMP_POS := Vector2(590, 1070)
const JUMP_R := 76.0   # 닿는 반지름 = r * 1.15 = 87
const BOX_POS := Vector2(440, 1150)
const BOX_R := 54.0    # 닿는 반지름 62
const JUMP_FACE := T.RED  # 경주 화면의 주 행동 = 강조색 하나 (빨강)
const RAIL_PHASES := ["race", "roundend"]
const NO_BACK_PHASES := ["title", "tutorial", "count", "countdown"]  # 처음 화면·연습·카운트다운에는 집 아이콘을 안 그린다 (출발 순간은 도장만)
const NO_RATE_PHASES := ["title", "tutorial", "count", "countdown", "race", "mode", "perk", "route", "roundend"]  # 평가는 결과 영수증에서만  # 달리는 중엔 평가 별을 안 그린다  # 진행 막대 (카운트다운은 도장만, 연습은 경쟁자 없음)

# 맨 위 진행 막대 (판 좌표). 뒤로 가기 x<180,y<100 / 평가 Rect2(620,0,100,100) 은 모서리 작은 아이콘이 차지한다.
const RAIL_X0 := 116.0
const RAIL_X1 := 556.0  # 깃발 끝 x <= 600: 평가 아이콘(RATE_C - 25) 과 떨어진다
const RAIL_Y := 48.0
const PIN_STEP := 10.0  # 몰린 경쟁자 핀이 위로 비켜 서는 폭 (2 단까지: 맨 위 핀 가운데 y >= 28)
const BACK_C := Vector2(44, 42)
const RATE_C := Vector2(676, 42)
const LINE_Y := 104.0
const LINE_T := 2.6  # 안내 한 줄이 떠 있는 시간
const T_LOST := 0.35

var game  # screenrace (untyped: 바깥 스크립트 값을 그대로 읽는다)

var _top: Control
var _line: Control

var _rail_on := false
var _lang := ""
var _rate_on := false
var _back_on := true
# 막대 상태
var _pins := PackedFloat32Array()  # 0..1, 죽으면 -1
var _pin_cols: Array[Color] = []
var _got := PackedInt32Array([0, 0, 0, 0])
var _top_i := -1  # 배달 1등 (같으면 없음)
var _mb_sig := ""
var _mbs: Array = []
var _bear := -1
var _cargo := 0
var _lost_t := 0.0
# 안내 한 줄
var _line_txt := ""
var _line_src := ""
var _line_left := 0.0
var _line_a := 0.0
# 버튼 눌림 (스프링)
var _pk := {}
var _pv := {}
var _kit_ms := 0
# 짐 더미 튀기 (얻으면 초록, 잃으면 빨강으로 한 번 부푼다)
var _last_cg := -1
var _badge_k := 0.0
var _badge_col := T.NAVY
# 짐 없이 누르면 고개 젓기 (시간 기준) + 작은 소리 한 번
var _deny_t := 0.0
var _drop_was_down := false
const T_DENY := 0.25


class Pane extends Control:
	var fn: Callable

	func _draw() -> void:
		if fn.is_valid():
			fn.call(self)


func _init() -> void:
	layer = 10
	_pins.resize(4)
	for i in 4:
		_pins[i] = 0.0
		_pin_cols.append(T.BLUE)


func setup(g) -> void:
	game = g
	_top = _pane(self, Rect2(0, 0, 720, 96), _draw_top)
	_line = _pane(self, Rect2(0, LINE_Y - 24.0, 720, 48), _draw_line)
	_line.modulate.a = 0.0
	# tofu 의 큰 "0" 점수는 이 게임에 뜻이 없다.
	if game._score_l != null:
		(game._score_l as Label).visible = false
	# tofu 의 뒤로 가기·평가 글자는 자리(눌리는 곳)만 남기고 그림은 모서리 작은 아이콘이 그린다.
	var rl: Label = game._rate_btn_l
	if rl != null:
		rl.self_modulate.a = 0.0
		for ch in rl.get_parent().get_children():
			if ch is Label and ch != rl and (ch as Label).text.begins_with("<"):
				(ch as Label).self_modulate.a = 0.0
				break


func _pane(parent: Node, r: Rect2, fn: Callable) -> Control:
	var p := Pane.new()
	p.fn = fn
	p.position = r.position
	p.size = r.size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(p)
	return p


# ================================================================ 공개 API
## 짧은 안내 한 줄: LINE_T 초 동안 막대 아래에 떴다가 사라진다.
func show_hint(text: String, _secs := LINE_T) -> void:
	if text == "":
		return
	_line_txt = text
	_line_left = LINE_T
	_line.queue_redraw()


## 매 프레임 불러도 된다: 글이 바뀐 순간에만 한 번 LINE_T 초 동안 보인다 ("" 은 무시).
func set_line(text: String) -> void:
	if text == _line_src:
		return
	_line_src = text
	if text != "":
		show_hint(text)


# ================================================================ 매 프레임
func _process(dt: float) -> void:
	if game == null or not is_instance_valid(game):
		return
	var frozen: bool = game.over or game._rating
	var ph: String = game.phase
	var rail: bool = not frozen and game.pl != null and RAIL_PHASES.has(ph)
	var dirty := false
	if rail != _rail_on:
		_rail_on = rail
		dirty = true
	var lg: String = game.lang
	if lg != _lang:
		_lang = lg
		dirty = true
	var rate_on := false
	if game._rate_btn_l != null:
		rate_on = (game._rate_btn_l as Label).visible and not NO_RATE_PHASES.has(ph)
	if rate_on != _rate_on:
		_rate_on = rate_on
		dirty = true
	var back_on: bool = not frozen and not NO_BACK_PHASES.has(ph)
	if back_on != _back_on:
		_back_on = back_on
		dirty = true
	if rail:
		dirty = _read_rail() or dirty
	if _lost_t > 0.0:
		_lost_t = maxf(_lost_t - dt, 0.0)
		dirty = true
	if dirty:
		_top.queue_redraw()
	# 안내 한 줄
	_line_left = maxf(_line_left - dt, 0.0)
	var show: bool = _line_left > 0.0 and not frozen and RAIL_PHASES.has(ph)
	if show:
		_line_a = minf(_line_a + dt / 0.18, 1.0)
	else:
		_line_a = maxf(_line_a - dt / 0.4, 0.0)
	_line.modulate.a = _line_a


func _read_rail() -> bool:
	var changed := false
	var gx: float = game.goal_x
	var x0 := -2.0
	var span := maxf(gx - x0, 1.0)
	var md: String = game.mode
	var bear = game.get("bearer") if md == "lantern" else null
	var bi := -1
	var i := 0
	for r in game.runners:
		if i >= 4:
			break
		var f := -1.0
		if r.alive or float(r.back_t) > 0.0:
			f = clampf((float(r.p.x) - x0) / span, 0.0, 1.0)
		if int(r.got) != _got[i]:
			_got[i] = int(r.got)
			changed = true
		if absf(f - _pins[i]) * (RAIL_X1 - RAIL_X0) >= 1.0:
			_pins[i] = f
			changed = true
		var c: Color = T.BLUE if not r.ai else r.col
		if c != _pin_cols[i]:
			_pin_cols[i] = c
			changed = true
		if bear != null and r == bear:
			bi = i
		i += 1
	# 배달 1등 (혼자일 때만 금 테)
	var ti := -1
	var best := 0
	for k in 4:
		if _got[k] > best:
			best = _got[k]
			ti = k
		elif _got[k] == best and best > 0:
			ti = -2
	ti = maxi(ti, -1)
	if ti != _top_i:
		_top_i = ti
		changed = true
	if game.has_method("mailbox_marks"):
		var mk: Array = game.mailbox_marks()
		var sig := ""
		for m in mk:
			sig += "%d%d," % [int(m.x * 1000.0), int(m.y)]
		if sig != _mb_sig:
			_mb_sig = sig
			_mbs = mk
			changed = true
	if bi != _bear:
		_bear = bi
		changed = true
	var pl = game.pl
	var cg: int = maxi(int(pl.cargo), 0)
	if cg != _cargo:
		if cg < _cargo:
			_lost_t = T_LOST
		_cargo = cg
		changed = true
	return changed


# ================================================================ 그리기: 맨 위
func _draw_top(c: Control) -> void:
	if _back_on:
		_corner_icon(c, BACK_C, "back")
	if _rate_on:
		_corner_icon(c, RATE_C, "rate")
	if _rail_on:
		_draw_rail(c)


## 모서리 작은 종이 아이콘 (tofu 의 뒤로 가기·평가 칸을 그대로 쓴다).
func _corner_icon(c: Control, at: Vector2, kind: String) -> void:
	c.draw_circle(at + Vector2(0, 4), 25.0, T.SHADOW, true, -1.0, true)
	c.draw_circle(at, 25.0, Color(T.WHITE, 0.92), true, -1.0, true)
	c.draw_circle(at, 21.0, Color(T.CREAM, 0.92), true, -1.0, true)
	if kind == "back":
		# 집 모양 (처음으로)
		var roof := PackedVector2Array([at + Vector2(-12, -1), at + Vector2(0, -12), at + Vector2(12, -1)])
		c.draw_polyline(roof, T.NAVY, 4.0, true)
		c.draw_rect(Rect2(at + Vector2(-8, -1), Vector2(16, 12)), T.NAVY)
		c.draw_rect(Rect2(at + Vector2(-3, 4), Vector2(6, 7)), T.CREAM)
	else:
		var st := T.tex("icon_star")
		if st != null:
			c.draw_texture_rect(st, Rect2(at - Vector2(17, 17), Vector2(34, 34)), false)
		else:
			_star(c, at, 14.0, T.GOLD, true)


func _draw_rail(c: Control) -> void:
	var y := RAIL_Y
	# 홈: 흰 종이 띠 + 그림자 (패널 없이 얇게)
	var tr := Rect2(Vector2(RAIL_X0 - 8.0, y - 6.0), Vector2(RAIL_X1 - RAIL_X0 + 16.0, 12.0))
	c.draw_style_box(_rail_sb(T.SHADOW, Color(0, 0, 0, 0), 0), Rect2(tr.position + Vector2(0, 3), tr.size))
	c.draw_style_box(_rail_sb(T.TROUGH, T.WHITE, 3), tr)
	# 내 진행 = 빨간 테이프
	var me := maxf(_pins[0], 0.0)
	if me > 0.0:
		c.draw_rect(Rect2(tr.position + Vector2(4, 3), Vector2((tr.size.x - 8.0) * me, tr.size.y - 6.0)), Color(T.RED, 0.85))
	# 우체통 표: 막대 아래에 매달린 작은 우체통 (빨강 = 빈 곳, 골판지 = 찬 곳) — 뒤에서 보고 계획한다
	for m in _mbs:
		var mx := RAIL_X0 + (RAIL_X1 - RAIL_X0) * float(m.x)
		var full := float(m.y) > 0.5
		var mr := Rect2(Vector2(mx - 5.0, y + 9.0), Vector2(10.0, 9.0))
		c.draw_rect(mr.grow(1.5), T.WHITE)
		c.draw_rect(mr, T.KRAFT_SH if full else T.RED)
		c.draw_line(Vector2(mx, y + 18.0), Vector2(mx, y + 23.0), T.NAVY, 2.0)
	# 결승 깃발 (이긴 판은 머리 위 표시와 판 끝 도장이 맡는다: 막대는 진행·순서만)
	var fx := RAIL_X1 + 22.0
	var fl := T.tex("icon_flag")
	if fl != null:
		c.draw_texture_rect(fl, Rect2(Vector2(fx - 18.0, y - 26.0), Vector2(40, 40)), false)
	else:
		c.draw_line(Vector2(fx, y + 10.0), Vector2(fx, y - 20.0), T.NAVY, 3.0)
		c.draw_colored_polygon(PackedVector2Array([Vector2(fx + 1, y - 20), Vector2(fx + 20, y - 13), Vector2(fx + 1, y - 6)]), T.GREEN)
	# 경쟁자 핀 (작게) 먼저, 내 핀 (크게) 은 맨 위에: 몰려 있으면 경쟁자만 위로 비켜 서서 순서가 보인다
	var drawn := PackedFloat32Array()
	if _pins[0] >= 0.0:
		drawn.append(RAIL_X0 + (RAIL_X1 - RAIL_X0) * _pins[0])
	for k in range(1, 4):
		var f := _pins[k]
		if f < 0.0:
			continue
		var px := RAIL_X0 + (RAIL_X1 - RAIL_X0) * f
		var lv := 0
		for q in drawn:
			if absf(q - px) < 12.0:
				lv += 1
		drawn.append(px)
		var at := Vector2(px, y - PIN_STEP * float(mini(lv, 2)))
		if _bear == k:
			c.draw_circle(at, 15.0, Color(T.AMBER, 0.6), true, -1.0, true)
		c.draw_circle(at + Vector2(0, 2), 11.0, T.SHADOW, true, -1.0, true)
		c.draw_circle(at, 11.0, T.GOLD if _top_i == k else T.WHITE, true, -1.0, true)
		c.draw_circle(at, 8.5, _pin_cols[k], true, -1.0, true)
		_pin_num(c, at, _got[k], 15)
	_draw_me(c, y)


func _draw_me(c: Control, y: float) -> void:
	var f := _pins[0]
	var dead := f < 0.0
	var px := RAIL_X0 + (RAIL_X1 - RAIL_X0) * maxf(f, 0.0)
	var at := Vector2(px, y)
	if _lost_t > 0.0:
		at.x += sin(_lost_t * 70.0) * 5.0 * (_lost_t / T_LOST)
	if _bear == 0:
		c.draw_circle(at, 21.0, Color(T.AMBER, 0.6), true, -1.0, true)
	var rim := T.RED if _lost_t > 0.0 else T.WHITE
	c.draw_circle(at + Vector2(0, 3), 14.0, T.SHADOW, true, -1.0, true)
	c.draw_circle(at, 14.0, rim, true, -1.0, true)
	var face := T.EMPTY_SLOT if dead else T.BLUE
	if _top_i == 0 and _lost_t <= 0.0:
		c.draw_circle(at, 14.0, T.GOLD, true, -1.0, true)  # 내가 배달 1등
	c.draw_circle(at, 11.0, face, true, -1.0, true)
	_pin_num(c, at, _got[0], 18)
	# 짐 수는 짐 버튼의 상자 더미와 등의 상자가 맡는다 (마지막 한 개는 빨간 더미 + LAST PARCEL 도장).


var _rail_cache := {}


## 핀 안의 배달 수 (흰 글 + 남색 테)
func _pin_num(c: Control, at: Vector2, n: int, fs: int) -> void:
	var s := str(n)
	var w := T.FONT.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := Vector2(at.x - w * 0.5, at.y + T.FONT.get_ascent(fs) * 0.5 - 2.0)
	c.draw_string_outline(T.FONT, base, s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, T.NAVY)
	c.draw_string(T.FONT, base, s, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, T.WHITE)


func _rail_sb(face: Color, border: Color, bw: int) -> StyleBoxFlat:
	var key := "%s|%s|%d" % [face.to_html(), border.to_html(), bw]
	if _rail_cache.has(key):
		return _rail_cache[key]
	var sb := StyleBoxFlat.new()
	sb.bg_color = face
	sb.border_color = border
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(6)
	sb.anti_aliasing = true
	_rail_cache[key] = sb
	return sb


func _star(c: Control, ctr: Vector2, rad: float, col: Color, filled: bool) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI * 0.5 + PI * 0.2 * float(i)
		var rr := rad if i % 2 == 0 else rad * 0.45
		pts.append(ctr + Vector2(cos(a), sin(a)) * rr)
	if filled:
		var sh := PackedVector2Array()
		for p in pts:
			sh.append(p + Vector2(0, 2))
		c.draw_colored_polygon(sh, T.KRAFT_SH)
		c.draw_colored_polygon(pts, col)
	else:
		pts.append(pts[0])
		c.draw_polyline(pts, col, 2.0, true)


# ================================================================ 안내 한 줄 (카드 없이 외곽선 글)
func _draw_line(c: Control) -> void:
	if _line_txt == "":
		return
	var fs := 24
	while fs > 16 and T.FONT.get_string_size(_line_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > 640.0:
		fs -= 1
	T.draw_text_center(c, _line_txt, Vector2(360, 24), fs, T.NAVY, 660.0, 8, T.WHITE)


# ================================================================ 떠 있는 조작 버튼 (tofu _kit_draw 대신)
## screenrace 가 _kit_draw(c) 를 덮어 이걸 부른다. c = tofu 조작판 (layer 5, 매 프레임 다시 그림).
func draw_kit(c: Control, g) -> void:
	var now := Time.get_ticks_msec()
	var dt := clampf(float(now - _kit_ms) / 1000.0, 0.0, 0.1)
	_kit_ms = now
	if g.pl != null:
		var cg: int = maxi(int(g.pl.cargo), 0)
		if _last_cg >= 0 and cg != _last_cg:
			_badge_k = 1.0
			_badge_col = T.GREEN if cg > _last_cg else T.RED
		_last_cg = cg
	_badge_k = maxf(_badge_k - dt * 5.0, 0.0)
	# 짐 없이 짐 버튼을 누른 순간: 0.25 초 고개 젓기 + 작은 '퉁' 한 번
	var btns0: Dictionary = g._btns
	var drop_down := false
	if btns0.has("drop"):
		drop_down = bool(btns0["drop"].down) and float(btns0["drop"].r) > 0.0
	if drop_down and not _drop_was_down and g.pl != null and int(g.pl.cargo) <= 0 and g.phase == "race":
		_deny_t = T_DENY
		g._sfx("bump", null, -12.0)
	_drop_was_down = drop_down
	_deny_t = maxf(_deny_t - dt, 0.0)
	var zone: Rect2 = g._stick_zone
	if zone.has_area():
		var on: bool = g._stick_on
		var o: Vector2 = g._st_o if on else g._st_home
		var mv: Vector2 = g.kit_move
		_draw_stick(c, o, mv, on)
	var btns: Dictionary = g._btns
	for n in btns:
		var b: Dictionary = btns[n]
		var r: float = b.r
		if r <= 0.0:
			continue
		var k := _press(n, bool(b.down), dt)
		var pos: Vector2 = b.pos
		if n == "jump":
			_draw_jump(c, pos, r, k)
		elif n == "drop":
			_draw_box(c, pos, r, k, g)


func _press(n: String, down: bool, dt: float) -> float:
	var k: float = _pk.get(n, 0.0)
	var v: float = _pv.get(n, 0.0)
	if down:
		k = minf(k + dt / T.T_DOWN, 1.0)
		v = 0.0
	else:
		# 느린 폰·멈칫한 프레임에도 튀지 않게: 1/60 초 이하로 쪼개서 적분
		var steps := maxi(ceili(dt * 60.0), 1)
		var h := dt / float(steps)
		for _i in steps:
			var a := -k * 900.0 - v * 26.0
			v += a * h
			k += v * h
		k = clampf(k, -0.4, 1.0)
		if absf(k) < 0.002 and absf(v) < 0.05:
			k = 0.0
			v = 0.0
	_pk[n] = k
	_pv[n] = v
	return k


## 스틱: 반투명 종이 고리 (장면이 비친다) + 파란 손잡이.
func _draw_stick(c: Control, o: Vector2, mv: Vector2, on: bool) -> void:
	var s := 0.94 if on else 1.0
	c.draw_circle(o + Vector2(0, 6), 96.0 * s, Color(T.NAVY, 0.12), true, -1.0, true)
	c.draw_circle(o, 96.0 * s, Color(T.CREAM, 0.38), true, -1.0, true)
	c.draw_arc(o, 94.0 * s, 0.0, TAU, 48, Color(T.WHITE, 0.9), 4.0, true)
	for i in [0, 2]:  # 왼쪽·오른쪽 화살 (달리기 방향)
		var d := Vector2(cos(PI * float(i) * 0.5), 0.0)
		var tip := o + d * 80.0 * s
		var base := o + d * 64.0 * s
		c.draw_colored_polygon(PackedVector2Array([tip, base + Vector2(0, 10), base - Vector2(0, 10)]), Color(T.WHITE, 0.85))
	var kp := o + mv * 64.0
	c.draw_circle(kp + Vector2(0, 7), 42.0, Color(T.NAVY, 0.3), true, -1.0, true)
	c.draw_circle(kp, 42.0, T.WHITE, true, -1.0, true)
	c.draw_circle(kp, 37.0, T.BLUE, true, -1.0, true)
	c.draw_arc(kp + Vector2(-5, -7), 22.0, PI * 1.05, PI * 1.55, 10, Color(1, 1, 1, 0.45), 4.0, true)


func _draw_jump(c: Control, pos: Vector2, r: float, k: float) -> void:
	var dy := T.PRESS_Y * k
	var p := pos + Vector2(0, dy)
	c.draw_circle(pos + Vector2(0, 8), r, Color(T.NAVY, 0.2), true, -1.0, true)
	c.draw_circle(p, r, Color(T.WHITE, 0.95), true, -1.0, true)
	c.draw_circle(p, r - 5.0, Color(JUMP_FACE.darkened(0.08 * k), 0.88), true, -1.0, true)
	var ic := T.tex("icon_jump")
	if ic != null:
		c.draw_texture_rect(ic, Rect2(p - Vector2(40, 40), Vector2(80, 80)), false)
	else:
		var a := PackedVector2Array([p + Vector2(0, -34), p + Vector2(28, -2), p + Vector2(11, -2), p + Vector2(11, 26), p + Vector2(-11, 26), p + Vector2(-11, -2), p + Vector2(-28, -2)])
		c.draw_colored_polygon(a, T.WHITE)


func _draw_box(c: Control, pos: Vector2, r: float, k: float, g) -> void:
	var dy := T.PRESS_Y * k
	var cg := 0
	if g.pl != null:
		cg = maxi(int(g.pl.cargo), 0)
	var face := T.KRAFT.darkened(0.08 * k)
	if cg <= 0:
		face = face.lerp(T.EMPTY_SLOT, 0.6)
	var p := pos + Vector2(0, dy)
	if _deny_t > 0.0:
		p.x += sin(_deny_t * 70.0) * 7.0 * (_deny_t / T_DENY)  # 짐이 없으면 눌러도 고개를 젓는다
	c.draw_circle(pos + Vector2(0, 7), r, Color(T.NAVY, 0.2), true, -1.0, true)
	c.draw_circle(p, r, Color(T.WHITE, 0.95), true, -1.0, true)
	c.draw_circle(p, r - 4.0, Color(face, 0.9), true, -1.0, true)
	if cg > 0:
		# 버튼 얼굴 = 남은 짐 더미 (아래부터 쌓인 작은 상자, 마지막 하나는 빨강). 숫자는 없다: 더미가 곧 짐 수.
		# 짐이 바뀌면 더미가 한 번 부풀고 (얻으면 초록, 잃으면 빨강 빛) 돌아온다.
		var sc := 1.0 + 0.25 * _badge_k
		var ph := minf(16.0, (r * 1.25) / float(cg) - 2.0) * sc
		var bw := 22.0 * sc
		var y0 := p.y + r * 0.62
		for i in cg:
			var off := (3.0 if i % 2 == 1 else -3.0) * sc
			var br := Rect2(Vector2(p.x - bw * 0.5 + off, y0 - float(i + 1) * (ph + 2.0)), Vector2(bw, ph))
			var col := T.RED if cg <= 1 else T.PARCEL
			if _badge_k > 0.0:
				col = col.lerp(_badge_col, 0.6 * _badge_k)
			c.draw_rect(Rect2(br.position + Vector2(2, 2), br.size), T.SHADOW)
			c.draw_rect(br.grow(1.5), T.WHITE)
			c.draw_rect(br, col)
			c.draw_rect(Rect2(Vector2(br.position.x + bw * 0.5 - 2.0, br.position.y), Vector2(4, ph)), col.darkened(0.25))
	else:
		var ic := T.tex("icon_drop")
		if ic == null:
			ic = T.tex("icon_parcel")
		if ic != null:
			c.draw_texture_rect(ic, Rect2(p - Vector2(28, 28), Vector2(56, 56)), false, Color(1, 1, 1, 0.45))
		else:
			T.draw_parcel_icon(c, p, 34.0, false)
