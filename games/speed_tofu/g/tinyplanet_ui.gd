extends Node
## 작은 행성 UI: 시작 화면(로고·시작 버튼·언어 전환) · 게임오버/엔딩 화면 · 점수 팝 · 디자인 시스템(DS) · 버튼 눌림.
## 본체(g/tinyplanet.gd)가 preload 해서 add_child 하고 아래 함수만 부른다. 본체 변수 이름에 기대지 않는다
## (game 에서 읽는 것: over, cam, _font, restart(), sfx(), set_lang() 뿐. 모두 get/call/has_method 로 읽는다).
##
## 약속 함수 (submit/tinyplanet/MODULES.md)
##   setup(game: Node) -> void              add_child 뒤 한 번. 본체가 _lang()으로 언어를 정한 뒤에 부른다.
##                                          저장된 언어 선택(user://tinyplanet.cfg)이 있으면 여기서 적용한다(주소에 ?lang= 이 있으면 주소가 이긴다).
##   tick(dt: float, s: Dictionary) -> void 본체 _step 끝에서 매 프레임. 걸린 시간 셈.
##   event(name: String, d := {}) -> void   일이 일어날 때. deliver/slingshot/job_done/score/finish 를 쓴다.
##   show_title(on_start: Callable) -> void 시작 화면. "시작"을 누르면 화면이 닫히고 on_start 를 부른다.
##   tutorial_active() -> bool              v6: 튜토리얼 없음. 늘 false.
## 덧붙인 공개 함수
##   title_visible() -> bool                시작 화면이 떠 있나(본체는 이 동안 점수 글자·조작 키트를 숨기고 _step 을 멈춘다).
##   tutorial_step() -> int                 v6: 늘 -1.
##   start_tutorial() / skip_tutorial()     v6: 아무것도 안 함(옛 호출이 깨지지 않게 남김).
##   reset_run() -> void                    이번 판 기록(시간·배달·새총)을 0으로. game.over 가 풀리면 저절로 부른다.
##   squash(c: Control) -> void             아무 Control 이나 0.92배로 줄었다 0.12초에 돌아오게(+ui_tap 소리).
##   make_panel(parent: Control, rect: Rect2, fill: Color) -> Control  DS 규칙(모서리 28·테두리 6·그림자 8) 패널.
##   is_korean() -> bool                    지금 글이 한국어인가.
##   refresh_text() -> void                 언어가 바뀐 뒤 내 글자를 다시 쓴다(본체 set_lang 이 불러도 된다. 몇 번 불러도 안전).
##   todo_open() -> bool                    v9: 할 일 목록 판이 떠 있나(본체는 이 동안 놀이를 멈춘다).
## 화면 층: 할 일 목록 6, 점수 팝 7, 끝 화면 8(평가 카드 9 아래), 시작 화면 12(맨 위).
## 입력: 내 버튼은 _input 에서 먼저 받고 처리했다고 표시한다(조작 키트로 안 샌다). 왼쪽 위 "< 메뉴" 자리는 건드리지 않는다.

const DS := {
	"cream": Color("fff6e6"), "ink": Color("2b2d42"), "sky": Color("9fd3ff"), "mint": Color("8fe3c2"), "lav": Color("b9a7f2"),
	"accent": Color("ffd166"), "accent_dark": Color("e6a93a"), "danger": Color("e8453c"), "go": Color("37b24d"),
	"radius": 28, "border": 6, "shadow_y": 8, "shadow_a": 0.4,
	"fs_title": 84, "fs_btn": 52, "fs_body": 34, "fs_small": 26, "outline_px": 6,
	"press": 0.92, "press_t": 0.12, "press_sink": 6.0,
}
const CFG := "user://tinyplanet.cfg"
const BACK_RECT := Rect2(0, 0, 180, 100)  # tofu "< 메뉴"
const NPOP := 8
const ROW_COLS := ["mint", "sky", "lav", "accent"]
const STAR_SPOTS := [Vector2(78, 150), Vector2(648, 128), Vector2(56, 690), Vector2(668, 650), Vector2(96, 900), Vector2(628, 880)]
const START_RECT := Rect2(140, 965, 440, 110)  # 납작하고 넓은 시작 버튼 (가운데 y 1020)
const LANG_RECT := Rect2(470, 1180, 226, 64)  # 오른쪽 아래 "EN | 한국어"
const LOGO_PIVOT := Vector2(360, 420)
const PLANET_AT := Vector2(360, 236)
const BIG_Y := 404.0  # 큰 제목 글자 칸 위
const BIG_H := 200.0
const EXTRUDE := 12.0  # 큰 제목 두께(잉크 판)
const KEY_EDGE := 10.0  # 버튼 아래 진한 노랑 두께


## DS 규칙 상자: 모서리 28, 테두리 6 잉크, 아래로 8 잉크 40% 단색 그림자. (패널·리본·뱃지)
class _Box extends Control:
	var sb := StyleBoxFlat.new()
	var sh := StyleBoxFlat.new()
	var shy := 8.0

	func paint(fill: Color, ds: Dictionary) -> void:
		var ink: Color = ds.ink
		sb.bg_color = fill
		sb.border_color = ink
		sb.set_border_width_all(int(ds.border))
		sb.set_corner_radius_all(int(ds.radius))
		sb.anti_aliasing = true
		sh.bg_color = Color(ink.r, ink.g, ink.b, float(ds.shadow_a))
		sh.set_corner_radius_all(int(ds.radius))
		sh.anti_aliasing = true
		shy = float(ds.shadow_y)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		queue_redraw()

	func _draw() -> void:
		draw_style_box(sh, Rect2(Vector2(0.0, shy), size))
		draw_style_box(sb, Rect2(Vector2.ZERO, size))


## 납작한 stadium 버튼: 잉크 테두리, 위쪽 밝은 띠, 아래 진한 노랑 두께(눌리는 키), 글자 옆 작은 그림, 숨쉬는 빛 고리.
## seg >= 0 이면 언어 전환 알약(왼쪽 EN / 오른쪽 한국어, 켜진 쪽이 노랑).
class _Btn extends Control:
	var key := ""
	var text := ""
	var font: Font
	var fs := 52
	var fill := Color("ffd166")
	var dark := Color("e6a93a")
	var ink := Color("2b2d42")
	var cream := Color("fff6e6")
	var glyph := 0  # 0 없음, 1 재생 세모, 2 편지
	var glow := false
	var t := 0.0
	var sink := 0.0
	var sq := 0.0  # 눌림 남은 시간
	var edge := 10.0
	var seg := -1
	var act := Callable()
	var sb := StyleBoxFlat.new()
	var glow_c: _Glow  # v8: 숨쉬는 빛 고리만 따로 (매 프레임 다시 그리는 건 이것뿐, 버튼 몸통은 눌릴 때만)
	var glow_was := false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		sb.anti_aliasing = true
		sb.corner_detail = 16
		glow_c = _Glow.new()
		glow_c.b = self
		glow_c.show_behind_parent = true
		glow_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(glow_c)

	func _stadium(r: Rect2, col: Color, border: int, bcol: Color, center := true, rad := -1.0) -> void:
		sb.bg_color = col
		sb.draw_center = center
		sb.border_color = bcol
		sb.set_border_width_all(border)
		sb.set_corner_radius_all(int(r.size.y * 0.5 if rad < 0.0 else rad))
		draw_style_box(sb, r)

	func draw_glow(c: Control) -> void:
		var w := size.x
		var h := size.y
		for i in 2:
			var p := fmod(t * 0.8 + 0.5 * float(i), 1.0)
			var g := 6.0 + 22.0 * p
			var a := 0.6 * (1.0 - p) * (1.0 - p)
			sb.bg_color = Color(0, 0, 0, 0)
			sb.draw_center = false
			sb.border_color = Color(fill.r, fill.g, fill.b, a)
			sb.set_border_width_all(6)
			var r := Rect2(-g, -g + edge * 0.5, w + g * 2.0, h + g * 2.0)
			sb.set_corner_radius_all(int(r.size.y * 0.5))
			c.draw_style_box(sb, r)

	func _draw() -> void:
		var w := size.x
		var h := size.y
		# (빛 고리는 glow_c 가 몸통 뒤에 그린다)
		# 그림자 → 아래 두께 → 몸통 (몸통이 sink 만큼 내려가 두께를 덮는다)
		_stadium(Rect2(0.0, edge + 8.0, w, h), Color(ink.r, ink.g, ink.b, 0.4), 0, ink)
		_stadium(Rect2(0.0, edge, w, h), dark if seg < 0 else Color("e9dcc4"), 6, ink)
		var top := Rect2(0.0, sink, w, h)
		if seg >= 0:
			_draw_seg(top)
			return
		_stadium(top, fill, 6, ink)
		# 위쪽 밝은 띠
		_stadium(Rect2(20.0, sink + 11.0, w - 40.0, h * 0.27), Color(1, 1, 1, 0.5), 0, ink)
		# 글자 + 그림
		var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var gs := float(fs) * 0.82 if glyph > 0 else 0.0
		var gap := 20.0 if glyph > 0 else 0.0
		var x0 := (w - (gs + gap + tw)) * 0.5
		var cy := sink + h * 0.5
		if glyph > 0:
			_draw_glyph(Vector2(x0 + gs * 0.5, cy), gs * 0.5)
		var base := cy + (font.get_ascent(fs) - font.get_descent(fs)) * 0.5
		var tp := Vector2(x0 + gs + gap, base)
		draw_string_outline(font, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 12, ink)
		draw_string(font, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, cream)

	func _draw_glyph(c: Vector2, r: float) -> void:
		draw_circle(c, r, ink)
		if glyph == 1:
			var k := r * 0.5
			var tri := PackedVector2Array([c + Vector2(-k * 0.7, -k), c + Vector2(k * 1.05, 0.0), c + Vector2(-k * 0.7, k)])
			draw_colored_polygon(tri, cream)
		else:
			var e := Rect2(c - Vector2(r * 0.62, r * 0.42), Vector2(r * 1.24, r * 0.84))
			draw_rect(e, cream)
			draw_polyline(PackedVector2Array([e.position, c + Vector2(0.0, r * 0.08), e.position + Vector2(e.size.x, 0.0)]), ink, 3.0, true)

	func _draw_seg(r: Rect2) -> void:
		var half := r.size.x * 0.42
		_stadium(r, cream, 6, ink)
		var on := Rect2(r.position + Vector2(7, 7), Vector2(half - 7.0, r.size.y - 14.0)) if seg == 0 \
			else Rect2(r.position + Vector2(half, 7), Vector2(r.size.x - half - 7.0, r.size.y - 14.0))
		_stadium(on, fill, 3, ink)
		var fsz := fs
		var labels := ["EN", "한국어"]
		var cx := [r.position.x + half * 0.5 + 3.0, r.position.x + half + (r.size.x - half) * 0.5 - 3.0]
		for i in 2:
			var s: String = labels[i]
			var sw := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz).x
			var base := r.position.y + r.size.y * 0.5 + (font.get_ascent(fsz) - font.get_descent(fsz)) * 0.5
			var col := ink if i == seg else Color(ink.r, ink.g, ink.b, 0.55)
			draw_string(font, Vector2(float(cx[i]) - sw * 0.5, base), s, HORIZONTAL_ALIGNMENT_LEFT, -1, fsz, col)


## 버튼 뒤 빛 고리 (버튼이 glow 일 때만 그린다)
class _Glow extends Control:
	var b: _Btn

	func _draw() -> void:
		if b and b.glow:
			b.draw_glow(self)


## 그리기 함수를 빌려 쓰는 빈 Control
class _Canvas extends Control:
	var fn := Callable()

	func _draw() -> void:
		if fn.is_valid():
			fn.call(self)


var _game: Node
var _font: Font
var _btns: Array[_Btn] = []
var _keyed: Array = []  # [Label, 한국어 키] — 언어가 바뀌면 다시 쓴다
var _pending := Callable()
var _pending_t := 0.0
var _clock := 0.0
var _star := PackedVector2Array()
var _star_line := PackedVector2Array()
var _seal := PackedVector2Array()
var _ring_back := PackedVector2Array()
var _ring_front := PackedVector2Array()
var _env_v := PackedVector2Array([Vector2(-22, -15), Vector2(0, 3), Vector2(22, -15)])
# 언어
var _ko := false
var _lang_pick := -1  # 저장된 선택: -1 없음, 0 영어, 1 한국어
var _my_tl: Translation
# 시작 화면
var _title_root: Control
var _title_deco: _Canvas
var _logo: Control
var _logo_fx: _Canvas
var _ribbon: _Box
var _ribbon_l: Label
var _big: Label
var _big_back: Label
var _start_b: _Btn
var _lang_b: _Btn
var _title_on := false
var _title_in := 1.0
var _title_out := -1.0
var _on_start := Callable()
# 이번 판
var _paused := false
var _time := 0.0
var _delivered := 0
var _slings := 0
var _jobs := 0
var _finished := false
var _was_over := false
# 끝 화면
var _end_root: Control
var _end_dim: ColorRect
var _end_panel: _Box
var _end_ribbon: _Box
var _end_head: Label
var _end_msg: Label
var _row_k: Array[Label] = []
var _row_v: Array[Label] = []
var _row_c: Array[_Box] = []
var _row_target := PackedFloat32Array([0, 0, 0, 0])
var _row_kind := PackedInt32Array([0, 1, 0, 1])
var _rows_shown := 0
var _new_b: _Box
var _again_end: _Btn
var _end_t := 0.0
var _end_win := false
var _new_rec := false
var _best_time := 0.0
var _best_deliv := 0
# 점수 팝
var _pops: Array[Label] = []
var _pop_t := PackedFloat32Array()
var _pop_p := PackedVector2Array()
var _pop_i := 0


# ---- 약속 함수 ----
func setup(game: Node) -> void:
	_game = game
	process_mode = Node.PROCESS_MODE_ALWAYS
	_font = game.get("_font") as Font
	if _font == null:
		_font = ThemeDB.fallback_font
	_shapes()
	_load_cfg()
	_init_lang()
	_build_end()
	_build_pops()
	_build_todo()
	_build_title()


func tick(dt: float, s: Dictionary) -> void:
	_todo_tick(s.get("todo_ok", false) == true, int(s.get("jobs_done", 0)))
	_paused = s.get("paused", false) == true
	if _title_on or _paused:
		return
	if not _finished:
		_time += dt


func event(name: String, d := {}) -> void:
	match name:
		"deliver":
			if not _finished:
				_delivered += 1
		"slingshot":
			if not _finished:
				_slings += 1
		"job_done":
			_jobs += 1
		"score":
			_pop(int(d.get("n", 0)), d.get("pos"))
		"finish":
			if not _finished:
				_finished = true
				_time = float(d.get("time", _time))
				_delivered = int(d.get("delivered", _delivered))
				_slings = int(d.get("slings", _slings))
			if _game.get("over") == true and _end_root.visible and not _end_win:
				_on_over()


func show_title(on_start: Callable) -> void:
	_on_start = on_start
	_title_on = true
	_title_out = -1.0
	_title_in = 0.0
	_title_root.visible = true
	_title_root.modulate.a = 1.0
	_title_root.position = Vector2.ZERO
	_start_b.glow = true
	_lang_b.seg = 1 if _ko else 0
	_lang_b.queue_redraw()


func tutorial_active() -> bool:
	return false


# ---- 덧붙인 공개 함수 ----
func title_visible() -> bool:
	return _title_on


## v9: 할 일 목록이 떠 있나 (본체는 이 동안 _play 를 멈춘다)
func todo_open() -> bool:
	return _todo_on


func tutorial_step() -> int:
	return -1


func start_tutorial() -> void:
	pass


func skip_tutorial() -> void:
	pass


func reset_run() -> void:
	_time = 0.0
	_delivered = 0
	_slings = 0
	_jobs = 0
	_finished = false


func squash(c: Control) -> void:
	c.pivot_offset = c.size * 0.5
	c.scale = Vector2.ONE * float(DS.press)
	var tw := c.create_tween()
	tw.tween_property(c, "scale", Vector2.ONE, float(DS.press_t)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sfx("ui_tap")


func make_panel(parent: Control, rect: Rect2, fill: Color) -> Control:
	return _box(parent, rect, fill)


func is_korean() -> bool:
	return _ko


func refresh_text() -> void:
	if _title_root == null:
		return
	for pr: Array in _keyed:
		var l := pr[0] as Label
		if is_instance_valid(l):
			l.text = tr(str(pr[1]))
	for b in _btns:
		if b.key != "":
			b.text = tr(b.key)
			b.queue_redraw()
	_lang_b.seg = 1 if _ko else 0
	_lang_b.queue_redraw()
	_set_title_text()
	if _todo_on:
		_todo_fill()


# ---- 언어 ----
## 지금 언어를 읽고, 저장된 선택이 있으면 적용 (주소에 lang= 이 있으면 주소가 이긴다).
func _init_lang() -> void:
	_ko = TranslationServer.get_locale().begins_with("ko")
	if _lang_pick < 0:
		return
	if OS.has_feature("web"):
		if str(JavaScriptBridge.eval("location.search.indexOf('lang=')>=0?'y':'n'", true)) == "y":
			return
	var want := _lang_pick == 1
	if want != _ko:
		_apply_lang(want)


func _toggle_lang() -> void:
	var ko := not _ko
	_lang_pick = 1 if ko else 0
	_save_cfg()
	_apply_lang(ko)


func _apply_lang(ko: bool) -> void:
	_ko = ko
	if _game != null and _game.has_method("set_lang"):
		_game.call("set_lang", ko)
	else:
		_own_lang(ko)
	_ko = ko
	refresh_text()


## 본체에 set_lang 이 없을 때: 내 글만이라도 바꾼다 (영어 번역이 서버에 없으면 내 EN 을 넣는다)
func _own_lang(ko: bool) -> void:
	if ko:
		TranslationServer.set_locale("ko")
		return
	TranslationServer.set_locale("en")
	if _my_tl == null and tr("어린 배달부") == "어린 배달부":
		_my_tl = Translation.new()
		_my_tl.locale = "en"
		for k: String in EN:
			_my_tl.add_message(k, str(EN[k]))
		TranslationServer.add_translation(_my_tl)


func _exit_tree() -> void:
	if _my_tl != null:
		TranslationServer.remove_translation(_my_tl)
		_my_tl = null


# ---- 입력: 내 버튼이 먼저 ----
func _input(ev: InputEvent) -> void:
	if _game == null:
		return
	var touch := ev is InputEventScreenTouch
	var mouse := ev is InputEventMouseButton and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if not touch and not mouse:
		if _title_on and (ev is InputEventScreenDrag or ev is InputEventMouseMotion):
			get_viewport().set_input_as_handled()
		return
	var p: Vector2 = (ev as InputEventScreenTouch).position if touch else (ev as InputEventMouseButton).position
	# 터치가 흉내 낸 마우스는 받기만 하고 또 누르지 않는다
	var fire := ev.is_pressed() and (touch or ev.device != InputEvent.DEVICE_ID_EMULATION)
	# v9 할 일 목록: 떠 있으면 어디를 눌러도 닫힌다 (누름만 먹는다 — 뗌·끌기는 조작 키트로 보내 스틱이 붙지 않게)
	if _todo_on:
		if fire:
			_todo_close()
		if ev.is_pressed():
			get_viewport().set_input_as_handled()
		return
	if _todo_btn.visible and TODO_RECT.grow(10.0).has_point(p):
		if fire:
			_todo_show()
		if ev.is_pressed():
			get_viewport().set_input_as_handled()
		return
	if BACK_RECT.has_point(p):
		return  # "< 메뉴"는 본체(tofu)가 받는다
	var b := _hit(p)
	if b != null:
		if fire:
			_press(b)
		get_viewport().set_input_as_handled()
	elif _title_on:
		get_viewport().set_input_as_handled()


func _rect_of(c: Control) -> Rect2:
	return Rect2(c.global_position, c.size * c.scale)


func _hit(p: Vector2) -> _Btn:
	for i in range(_btns.size() - 1, -1, -1):
		var b := _btns[i]
		if b.act.is_valid() and b.is_visible_in_tree() and Rect2(b.global_position, b.size + Vector2(0.0, b.edge)).grow(12.0).has_point(p):
			return b
	return null


func _press(b: _Btn) -> void:
	if _pending.is_valid():
		return
	b.sq = float(DS.press_t)
	_sfx("ui_tap")
	_pending = b.act
	_pending_t = float(DS.press_t)


# ---- 매 프레임 (게임이 끝나 _step 이 멈춰도 돈다) ----
var dbg := false  # ?debug=1: _process 시간(usec)을 본체 성능 표에 남긴다
var dbg_us := 0


func _process(dt: float) -> void:
	if _game == null:
		return
	if dbg:
		var t0 := Time.get_ticks_usec()
		_process_body(dt)
		dbg_us += Time.get_ticks_usec() - t0
	else:
		_process_body(dt)


func _process_body(dt: float) -> void:
	var rdt := dt / maxf(Engine.time_scale, 0.05)  # 슬로모션 중에도 UI 는 제 속도
	_clock += rdt
	_buttons_anim(rdt)
	if _pending_t > 0.0:
		_pending_t -= rdt
		if _pending_t <= 0.0 and _pending.is_valid():
			var f := _pending
			_pending = Callable()
			f.call()
	var ov: bool = _game.get("over") == true
	if ov and not _was_over:
		_on_over()
	elif _was_over and not ov:
		_on_restart()
	_was_over = ov
	if _title_root.visible:
		_title_anim(rdt)
	if _end_root.visible:
		_end_anim(rdt)
	if _todo_on:
		_todo_anim(rdt)
	_pops_anim(rdt)


## 눌림: 0.92배로 줄고 6px 가라앉았다 0.12초에 돌아옴. 빛 고리는 매 프레임 다시 그림.
func _buttons_anim(dt: float) -> void:
	for b in _btns:
		if not b.is_visible_in_tree():
			continue
		var k := 0.0
		if b.sq > 0.0:
			b.sq = maxf(b.sq - dt, 0.0)
			k = b.sq / float(DS.press_t)
			k *= k
		var s := lerpf(1.0, float(DS.press), k)
		b.scale = Vector2(s, s)
		var sink := float(DS.press_sink) * k
		if b.glow or b.glow_was:
			b.t = _clock
			b.glow_c.queue_redraw()
			b.glow_was = b.glow
		if sink != b.sink:
			b.sink = sink
			b.queue_redraw()


# ---- 만들기 도구 ----
func _root(layer: int) -> Control:
	var cl := CanvasLayer.new()
	cl.layer = layer
	add_child(cl)
	var r := Control.new()
	r.size = Vector2(720, 1280)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(r)
	return r


## 글자 모양: outline 이면 잉크 외곽선(화면에서 약 6px), shadow 면 아래로 8 잉크 40%
func _ls(fs: int, fill: Color, outline: bool, shadow := false) -> LabelSettings:
	var s := LabelSettings.new()
	var ink: Color = DS.ink
	s.font = _font
	s.font_size = fs
	s.font_color = fill
	if outline:
		s.outline_size = int(DS.outline_px) * 2
		s.outline_color = ink
	if shadow:
		s.shadow_color = Color(ink.r, ink.g, ink.b, float(DS.shadow_a))
		s.shadow_offset = Vector2(0.0, float(DS.shadow_y))
		s.shadow_size = s.outline_size
	return s


func _lab(parent: Control, text: String, rect: Rect2, ls: LabelSettings, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED  # 글은 내가 tr() 로 넣는다
	l.label_settings = ls
	l.text = text
	l.position = rect.position
	l.size = rect.size
	l.pivot_offset = rect.size * 0.5
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


## 한국어 키로 만든 글자: 언어가 바뀌면 refresh_text 가 다시 쓴다
func _klab(parent: Control, key: String, rect: Rect2, ls: LabelSettings, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := _lab(parent, tr(key), rect, ls, align)
	_keyed.append([l, key])
	return l


func _box(parent: Control, rect: Rect2, fill: Color) -> _Box:
	var b := _Box.new()
	b.position = rect.position
	b.size = rect.size
	b.pivot_offset = rect.size * 0.5
	b.paint(fill, DS)
	parent.add_child(b)
	return b


## 납작한 stadium 버튼. key 는 한국어(tr 로 바꿔 그린다), glyph 1 재생 세모 / 2 편지
func _btn(parent: Control, rect: Rect2, key: String, glyph: int, act: Callable) -> _Btn:
	var b := _Btn.new()
	b.font = _font
	b.fs = int(DS.fs_btn)
	b.fill = DS.accent
	b.dark = DS.accent_dark
	b.ink = DS.ink
	b.cream = DS.cream
	b.edge = KEY_EDGE
	b.key = key
	b.text = tr(key) if key != "" else ""
	b.glyph = glyph
	b.act = act
	b.position = rect.position
	b.size = rect.size
	b.pivot_offset = rect.size * 0.5
	parent.add_child(b)
	_btns.append(b)
	return b


func _canvas(parent: Control, rect: Rect2, fn: Callable) -> _Canvas:
	var c := _Canvas.new()
	c.fn = fn
	c.position = rect.position
	c.size = rect.size
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c


func _sfx(nm: String, db := 0.0, pitch := 1.0) -> void:
	if _game != null and _game.has_method("sfx"):
		_game.call("sfx", nm, db, pitch)


func _back_out(t: float) -> float:
	var c1 := 1.70158
	var u := clampf(t, 0.0, 1.0) - 1.0
	return 1.0 + (c1 + 1.0) * u * u * u + c1 * u * u


func _fmt_time(sec: float) -> String:
	var s := maxi(int(sec), 0)
	return "%d:%02d" % [s / 60, s % 60]


## 모양을 한 번만 만든다 (그릴 때 매 프레임 새로 만들지 않게)
func _shapes() -> void:
	for i in 8:
		var a := float(i) * TAU / 8.0 - PI * 0.5
		var r := 1.0 if i % 2 == 0 else 0.42
		_star.append(Vector2(cos(a), sin(a)) * r)
	_star_line = _star.duplicate()
	_star_line.append(_star[0])
	for v in _star:
		_seal.append(v * 9.0 + Vector2(0, 3))  # 편지 봉인 작은 별
	# 행성 고리(납작한 타원): 뒤쪽 반(위)과 앞쪽 반(아래)
	for i in 25:
		var a := PI + PI * float(i) / 24.0
		_ring_back.append(Vector2(cos(a) * 104.0, sin(a) * 104.0 * 0.32))
		_ring_front.append(Vector2(cos(a - PI) * 104.0, sin(a - PI) * 104.0 * 0.32))


# ---- 저장 (user://tinyplanet.cfg) ----
func _load_cfg() -> void:
	var cf := ConfigFile.new()
	if cf.load(CFG) != OK:
		return
	_best_time = float(cf.get_value("best", "time", 0.0))
	_best_deliv = int(cf.get_value("best", "delivered", 0))
	var lg := str(cf.get_value("ui", "lang", ""))
	_lang_pick = 1 if lg == "ko" else (0 if lg == "en" else -1)


func _save_cfg() -> void:
	var cf := ConfigFile.new()
	var _e := cf.load(CFG)  # 다른 값을 지키려고 먼저 읽는다 (없으면 빈 채로)
	cf.set_value("best", "time", _best_time)
	cf.set_value("best", "delivered", _best_deliv)
	if _lang_pick >= 0:
		cf.set_value("ui", "lang", "ko" if _lang_pick == 1 else "en")
	var _s := cf.save(CFG)


# ---- 시작 화면 ----
## 로고(작은 행성 + 도는 편지 + 리본 "The Little" + 두꺼운 "Courier"), 아래쪽 납작한 시작 버튼, 오른쪽 아래 언어 알약
func _build_title() -> void:
	_title_root = _root(12)
	_title_deco = _canvas(_title_root, Rect2(0, 0, 720, 1280), Callable())
	_build_title_deco()
	_logo = Control.new()
	_logo.size = Vector2(720, 640)
	_logo.pivot_offset = LOGO_PIVOT
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_root.add_child(_logo)
	_logo_fx = _canvas(_logo, Rect2(0, 0, 720, 640), Callable())
	_build_logo_fx()
	var ink: Color = DS.ink
	# 큰 글자: 뒤에 잉크 두께판(+부드러운 그림자), 앞에 노랑 + 굵은 잉크 외곽선
	var back := LabelSettings.new()
	back.font = _font
	back.font_color = ink
	back.outline_size = 18
	back.outline_color = ink
	back.shadow_color = Color(ink.r, ink.g, ink.b, 0.22)
	back.shadow_offset = Vector2(0, 12)
	back.shadow_size = 30
	_big_back = _lab(_logo, "", Rect2(0, BIG_Y + EXTRUDE, 720, BIG_H), back)
	_big_back.autowrap_mode = TextServer.AUTOWRAP_OFF
	var front := LabelSettings.new()
	front.font = _font
	front.font_color = DS.accent
	front.outline_size = 18
	front.outline_color = ink
	_big = _lab(_logo, "", Rect2(0, BIG_Y, 720, BIG_H), front)
	_big.autowrap_mode = TextServer.AUTOWRAP_OFF
	# 리본: 라벤더 띠 위 크림 글자
	_ribbon = _box(_logo, Rect2(220, 352, 280, 76), DS.lav)
	_ribbon.rotation = -0.04
	_ribbon_l = _lab(_ribbon, "", Rect2(0, -3, 280, 76), _ls(46, DS.cream, true))
	_ribbon_l.autowrap_mode = TextServer.AUTOWRAP_OFF
	_set_title_text()
	_start_b = _btn(_title_root, START_RECT, "시작", 1, _title_go.bind(false))
	_lang_b = _btn(_title_root, LANG_RECT, "", 0, _toggle_lang)
	_lang_b.fs = int(DS.fs_small)
	_lang_b.edge = 6.0
	_lang_b.seg = 1 if _ko else 0
	_title_root.visible = false


## 제목 "어린 배달부" / "The Little Courier": 마지막 낱말은 큰 글자, 앞부분은 리본
func _set_title_text() -> void:
	var full := tr("어린 배달부")
	var cut := full.rfind(" ")
	var small := full.substr(0, cut) if cut > 0 else ""
	var big := full.substr(cut + 1) if cut > 0 else full
	var fs := 156
	var w := _font.get_string_size(big, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 40.0
	if w > 640.0:
		fs = int(float(fs) * 640.0 / w)
	_big.label_settings.font_size = fs
	_big_back.label_settings.font_size = fs
	_big.text = big
	_big_back.text = big
	_ribbon.visible = small != ""
	var rw := _font.get_string_size(small, HORIZONTAL_ALIGNMENT_LEFT, -1, 46).x + 96.0
	rw = clampf(rw, 200.0, 560.0)
	_ribbon.size = Vector2(rw, 76)
	_ribbon.position = Vector2(360.0 - rw * 0.5, 352)
	_ribbon.pivot_offset = _ribbon.size * 0.5
	_ribbon_l.size = Vector2(rw, 76)
	_ribbon_l.text = small


func _title_go(_tut: bool) -> void:
	if _title_out >= 0.0 or not _title_on:
		return
	_title_out = 0.0
	_start_b.glow = false


func _title_anim(dt: float) -> void:
	var t := _clock
	# 들어오기: 로고가 통 튀며 커지고, 버튼이 아래에서 올라온다
	if _title_in < 1.0:
		_title_in = minf(_title_in + dt / 0.6, 1.0)
	var lk := maxf(_back_out(clampf(_title_in / 0.75, 0.0, 1.0)), 0.01)
	var bk := _back_out(clampf((_title_in - 0.25) / 0.75, 0.0, 1.0))
	_logo.scale = Vector2(lk, lk)
	_logo.position.y = sin(t * 1.6) * 9.0
	_logo.rotation = sin(t * 1.1) * 0.015
	_ribbon.rotation = -0.04 + sin(t * 2.0) * 0.012
	_start_b.position.y = START_RECT.position.y + (1.0 - bk) * 320.0
	_lang_b.modulate.a = clampf(_title_in * 2.0 - 1.0, 0.0, 1.0)
	_title_deco_anim()
	_logo_fx_anim()
	if _title_out < 0.0:
		return
	_title_out += dt
	var k := clampf(_title_out / 0.35, 0.0, 1.0)
	_title_root.modulate.a = 1.0 - k
	_title_root.position.y = -80.0 * k * k
	if k >= 1.0:
		_title_root.visible = false
		_title_on = false
		_title_out = -1.0
		reset_run()
		if _on_start.is_valid():
			_on_start.call()


## v8 성능: 시작 화면 그림은 매 프레임 다시 그리지 않는다 (웹 호환 렌더러는 다각형·안티에일리어스 선·원을 그릴 때마다
## GPU 버퍼를 새로 만들어 이 화면 하나가 한 프레임에 15ms 넘게 먹었다). 모양은 한 번 만든 Polygon2D·Line2D 노드로 두고
## 매 프레임 위치·회전·크기·투명도만 바꾼다 (모양·색·움직임은 예전 그리기와 같다).
var _deco_sh: Array[Node2D] = []  # 반짝 별 그림자
var _deco_st: Array[Node2D] = []  # 반짝 별
var _deco_ell: Node2D  # 로고 아래 옅은 그림자 (타원 넷)
var _lf_root: Node2D  # 로고 행성 (가운데 = 행성)
var _lf_env_back: Node2D
var _lf_env_front: Node2D
var _lf_star_a: Node2D
var _lf_star_b: Node2D
var _circ := PackedVector2Array()  # 단위 원 (draw_circle 과 같은 64 조각)


func _unit_circle() -> PackedVector2Array:
	if _circ.is_empty():
		for i in 64:
			var a := TAU * float(i) / 64.0
			_circ.append(Vector2(cos(a), sin(a)))
	return _circ


func _poly(parent: Node, pts: PackedVector2Array, col: Color, at := Vector2.ZERO, sc := 1.0) -> Polygon2D:
	var pg := Polygon2D.new()
	var q := PackedVector2Array()
	q.resize(pts.size())
	for i in pts.size():
		q[i] = at + pts[i] * sc
	pg.polygon = q
	pg.color = col
	parent.add_child(pg)
	return pg


func _line(parent: Node, pts: PackedVector2Array, col: Color, w: float, aa: bool, closed := false) -> Line2D:
	var ln := Line2D.new()
	ln.points = pts
	ln.default_color = col
	ln.width = w
	ln.antialiased = aa
	ln.closed = closed
	ln.joint_mode = Line2D.LINE_JOINT_SHARP
	ln.sharp_limit = 8.0
	parent.add_child(ln)
	return ln


## 단위 별 (가운데 원점, 반지름 1). line.a > 0 이면 잉크 외곽선 (화면에서 5px 가 되게 r0 기준 두께)
func _star_node(parent: Node, fill: Color, line: Color, r0: float) -> Node2D:
	var n := Node2D.new()
	parent.add_child(n)
	_poly(n, _star, fill)
	if line.a > 0.0:
		_line(n, _star_line, line, 5.0 / r0, true)
	return n


func _build_title_deco() -> void:
	var ink: Color = DS.ink
	var sh := Color(ink.r, ink.g, ink.b, float(DS.shadow_a))
	for i in STAR_SPOTS.size():
		var col: Color = DS.accent if i % 2 == 0 else DS.cream
		var r0 := 20.0 + 6.0 * float(i % 3)
		_deco_sh.append(_star_node(_title_deco, sh, Color(0, 0, 0, 0), r0))
		_deco_st.append(_star_node(_title_deco, col, ink, r0))
	_deco_ell = Node2D.new()
	_deco_ell.position = Vector2(360, 636)
	_title_deco.add_child(_deco_ell)
	for i in 4:
		_poly(_deco_ell, _unit_circle(), Color(ink.r, ink.g, ink.b, 0.05), Vector2.ZERO, 250.0 - 45.0 * float(i))
	_title_deco_anim()


## 뒤 배경: 반짝이는 별 몇 개 + 떠 있는 로고 아래 옅은 그림자
func _title_deco_anim() -> void:
	for i in STAR_SPOTS.size():
		var at: Vector2 = STAR_SPOTS[i]
		var r := (20.0 + 6.0 * float(i % 3)) * (1.0 + 0.22 * sin(_clock * 2.3 + float(i) * 1.7))
		var rot := sin(_clock * 0.6 + float(i)) * 0.3
		var a := _deco_sh[i]
		a.position = at + Vector2(0, 6)
		a.rotation = rot
		a.scale = Vector2(r, r)
		var b := _deco_st[i]
		b.position = at
		b.rotation = rot
		b.scale = Vector2(r, r)
	# 로고가 위로 뜨면 그림자가 작고 옅어진다
	var up := 0.5 - 0.5 * sin(_clock * 1.6)
	var sk := 1.0 - 0.12 * up
	_deco_ell.scale = Vector2(sk, 0.16 * sk)
	_deco_ell.modulate.a = 1.0 - 0.4 * up


func _envelope_node(parent: Node) -> Node2D:
	var ink: Color = DS.ink
	var n := Node2D.new()
	parent.add_child(n)
	var rc := PackedVector2Array([Vector2(-22, -15), Vector2(22, -15), Vector2(22, 15), Vector2(-22, 15)])
	_poly(n, rc, Color(ink.r, ink.g, ink.b, float(DS.shadow_a)), Vector2(0, 6))
	_poly(n, rc, DS.cream)
	_line(n, rc, ink, 4.0, false, true)
	_line(n, _env_v, ink, 4.0, false)
	_poly(n, _seal, DS.accent)
	return n


func _ring_node(parent: Node, pts: PackedVector2Array, tilt: float) -> void:
	var n := Node2D.new()
	n.rotation = tilt
	parent.add_child(n)
	_line(n, pts, DS.ink, 24.0, true)
	_line(n, pts, DS.lav, 12.0, true)


func _build_logo_fx() -> void:
	var ink: Color = DS.ink
	var sh := Color(ink.r, ink.g, ink.b, float(DS.shadow_a))
	var tilt := -0.28
	_lf_root = Node2D.new()
	_logo_fx.add_child(_lf_root)
	# 고리 뒤쪽 + 뒤로 간 편지
	_ring_node(_lf_root, _ring_back, tilt)
	_lf_env_back = _envelope_node(_lf_root)
	# 행성
	var uc := _unit_circle()
	_poly(_lf_root, uc, sh, Vector2(0, 8), 62.0)
	_poly(_lf_root, uc, ink, Vector2.ZERO, 62.0)
	_poly(_lf_root, uc, DS.mint, Vector2.ZERO, 55.0)
	_poly(_lf_root, uc, Color("6fcfab"), Vector2(14, 16), 15.0)
	_poly(_lf_root, uc, Color("6fcfab"), Vector2(-24, 22), 8.0)
	_poly(_lf_root, uc, DS.cream, Vector2(-20, -22), 13.0)
	# 고리 앞쪽 + 앞으로 온 편지
	_ring_node(_lf_root, _ring_front, tilt)
	_lf_env_front = _envelope_node(_lf_root)
	# 반짝 별
	_lf_star_a = _star_node(_lf_root, DS.accent, ink, 22.0)
	_lf_star_a.position = Vector2(96, -70)
	_lf_star_b = _star_node(_lf_root, DS.cream, ink, 12.0)
	_lf_star_b.position = Vector2(-110, -38)
	_logo_fx_anim()


## 로고 그림: 고리 두른 작은 행성, 고리를 따라 도는 편지(별 봉인), 반짝이는 작은 별
func _logo_fx_anim() -> void:
	var pc := PLANET_AT + Vector2(0, sin(_clock * 1.3) * 5.0)
	var tilt := -0.28
	var ang := _clock * 1.1
	var env_front := sin(ang) > 0.0
	_lf_root.position = pc
	var ep := Vector2(cos(ang) * 104.0, sin(ang) * 104.0 * 0.32).rotated(tilt)
	var esc := 0.8 + 0.2 * (1.0 + sin(ang))
	var env := _lf_env_front if env_front else _lf_env_back
	_lf_env_front.visible = env_front
	_lf_env_back.visible = not env_front
	env.position = ep
	env.rotation = sin(ang * 2.0) * 0.25
	env.scale = Vector2(esc, esc)
	var tw := 0.75 + 0.35 * maxf(sin(_clock * 3.1), 0.0)
	var ra := 22.0 * tw
	_lf_star_a.scale = Vector2(ra, ra)
	_lf_star_a.rotation = _clock * 0.8
	var rb := 12.0 * (1.6 - tw)
	_lf_star_b.scale = Vector2(rb, rb)
	_lf_star_b.rotation = -_clock * 0.6


# ---- 게임오버 · 엔딩 ----
func _build_end() -> void:
	_end_root = _root(8)
	var ink: Color = DS.ink
	_end_dim = ColorRect.new()
	_end_dim.color = Color(ink.r, ink.g, ink.b, 0.0)
	_end_dim.size = Vector2(720, 1280)
	_end_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_root.add_child(_end_dim)
	_end_panel = _box(_end_root, Rect2(60, 214, 600, 640), DS.cream)
	_end_ribbon = _box(_end_panel, Rect2(80, -46, 440, 104), DS.accent)
	_end_head = _lab(_end_ribbon, "", Rect2(0, -3, 440, 104), _ls(int(DS.fs_btn), DS.cream, true))
	_end_msg = _lab(_end_panel, "", Rect2(30, 70, 540, 56), _ls(int(DS.fs_small), Color(ink.r, ink.g, ink.b, 0.75), false))
	for i in 4:
		var y := 136.0 + float(i) * 80.0
		var chip := _box(_end_panel, Rect2(34, y + 8.0, 52, 52), DS[str(ROW_COLS[i])])
		_row_c.append(chip)
		_row_k.append(_lab(_end_panel, "", Rect2(104, y, 250, 68), _ls(int(DS.fs_body), ink, false), HORIZONTAL_ALIGNMENT_LEFT))
		_row_v.append(_lab(_end_panel, "", Rect2(330, y, 240, 68), _ls(int(DS.fs_btn), ink, false), HORIZONTAL_ALIGNMENT_RIGHT))
	_new_b = _box(_end_panel, Rect2(272, 136.0 + 3.0 * 80.0 + 10.0, 160, 50), DS.accent)
	_klab(_new_b, "새 기록", Rect2(0, -2, 160, 50), _ls(int(DS.fs_small), ink, false))
	_again_end = _btn(_end_panel, Rect2(80, 492, 440, 110), "다시", 1, _again)
	_end_root.visible = false


func _again() -> void:
	if _game != null and _game.has_method("restart"):
		_game.call("restart")


func _on_over() -> void:
	_end_win = _finished
	var deliv := _delivered
	_new_rec = false
	if _end_win and (_best_time <= 0.0 or _time < _best_time):
		_best_time = _time
		_new_rec = true
	if deliv > _best_deliv:
		_best_deliv = deliv
		if not _end_win:
			_new_rec = true
	_save_cfg()
	_end_ribbon.paint(DS.accent if _end_win else DS.lav, DS)
	_end_head.text = tr("모든 부탁 완료!") if _end_win else tr("목숨을 다 썼어")
	_end_msg.text = tr("다섯 별이 모두 웃고 있어") if _end_win else tr("다시 하면 첫 별부터 새로 시작해")
	var keys := ["배달한 수", "걸린 시간" if _end_win else "버틴 시간", "새총", "최고 기록" if _end_win else "최고 배달"]
	_row_target[0] = float(deliv)
	_row_target[1] = _time
	_row_target[2] = float(_slings)
	_row_target[3] = _best_time if _end_win else float(_best_deliv)
	_row_kind[3] = 1 if _end_win else 0
	for i in 4:
		_row_k[i].text = tr(str(keys[i]))
		_row_v[i].text = ""
		_row_k[i].visible = false
		_row_v[i].visible = false
		_row_c[i].visible = false
	_rows_shown = 0
	_new_b.visible = false
	_again_end.glow = false
	_again_end.text = tr("다시")
	_end_t = 0.0
	_end_panel.position.y = 1000.0
	_end_root.visible = true


func _on_restart() -> void:
	_end_root.visible = false
	for l in _pops:
		l.visible = false
	for i in NPOP:
		_pop_t[i] = 9.0
	reset_run()


func _end_anim(dt: float) -> void:
	_end_t += dt
	var k := clampf(_end_t / 0.5, 0.0, 1.0)
	_end_panel.position.y = 214.0 + (1.0 - _back_out(k)) * 760.0
	var ink: Color = DS.ink
	_end_dim.color = Color(ink.r, ink.g, ink.b, 0.28 * k)
	_end_ribbon.rotation = sin(_clock * 1.8) * 0.025
	for i in 4:
		var t0 := 0.5 + float(i) * 0.22
		if _end_t < t0:
			continue
		if i >= _rows_shown:
			_rows_shown = i + 1
			_row_k[i].visible = true
			_row_v[i].visible = true
			_row_c[i].visible = true
			_sfx("ui_tap", -4.0, 1.0 + 0.15 * float(i))
		if _end_t - t0 > 0.6:
			continue
		var rk := clampf((_end_t - t0) / 0.45, 0.0, 1.0)
		var v := _row_target[i] * (1.0 - pow(1.0 - rk, 3.0))
		_row_v[i].text = _fmt_time(v) if _row_kind[i] == 1 else str(int(round(v)))
		var ps := maxf(_back_out(clampf((_end_t - t0) / 0.3, 0.0, 1.0)), 0.01)
		_row_c[i].scale = Vector2(ps, ps)
	var t_new := 0.5 + 4.0 * 0.22 + 0.2
	if _new_rec and _end_t >= t_new:
		if not _new_b.visible:
			_new_b.visible = true
			_sfx("pickup", -2.0, 1.3)
		var nk := maxf(_back_out(clampf((_end_t - t_new) / 0.3, 0.0, 1.0)), 0.01)
		_new_b.scale = Vector2(nk, nk)
		_new_b.rotation = sin(_clock * 5.0) * 0.06
	_again_end.glow = _end_t > 1.4


# ---- v9 할 일 목록: 왼쪽 위 작은 버튼(목록 그림 + "2/5") → 누르면 판이 떠서 놀이가 멈춘다. 아무 데나 누르면 닫힘 ----
## 본체에서 읽는 것: todo_rows() · todo_held() · todo_icon() (has_method 로 확인), 상태 사전의 todo_ok · jobs_done
const TODO_RECT := Rect2(18, 108, 136, 66)  # "< 메뉴"(y 100 위) 밑, 막대(y 190) 위
const TODO_PANEL := Rect2(40, 196, 640, 800)
const TODO_ROW_Y := 70.0
const TODO_ROW_H := 112.0
var _todo_root: Control
var _todo_btn: _Box
var _todo_btn_l: Label
var _todo_dim: ColorRect
var _todo_panel: _Box
var _todo_head: Label
var _todo_canvas: _Canvas
var _todo_who: Array[Label] = []
var _todo_task: Array[Label] = []
var _todo_stl: Array[Label] = []
var _todo_held_l: Label
var _todo_hint: Label
var _todo_ok := false
var _todo_on := false
var _todo_n := -1
var _todo_t := 0.0
var _todo_ic: Array[String] = ["", "", "", "", ""]
var _todo_st := PackedInt32Array([0, 0, 0, 0, 0])
var _todo_hk := ""  # 든 물건 그림 이름


func _build_todo() -> void:
	_todo_root = _root(6)  # 본체 HUD(4)·조작 키트(5) 위, 끝 화면(8) 아래
	var ink: Color = DS.ink
	# 버튼: 크림 판 + 목록 그림 + 끝낸 수
	_todo_btn = _box(_todo_root, TODO_RECT, DS.cream)
	_canvas(_todo_btn, Rect2(12, 9, 48, 48), _todo_btn_draw)
	_todo_btn_l = _lab(_todo_btn, "0/5", Rect2(60, 0, 68, 66), _ls(30, ink, false), HORIZONTAL_ALIGNMENT_LEFT)
	_todo_btn_l.autowrap_mode = TextServer.AUTOWRAP_OFF
	_todo_btn.visible = false
	# 판
	_todo_dim = ColorRect.new()
	_todo_dim.color = Color(ink.r, ink.g, ink.b, 0.35)
	_todo_dim.size = Vector2(720, 1280)
	_todo_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_todo_dim.visible = false
	_todo_root.add_child(_todo_dim)
	_todo_panel = _box(_todo_root, TODO_PANEL, DS.cream)
	_todo_panel.visible = false
	var rib := _box(_todo_panel, Rect2(150, -42, 340, 90), DS.accent)
	_todo_head = _lab(rib, "", Rect2(0, -3, 340, 90), _ls(int(DS.fs_body) + 6, DS.cream, true))
	_todo_head.autowrap_mode = TextServer.AUTOWRAP_OFF
	_todo_canvas = _canvas(_todo_panel, Rect2(0, 0, TODO_PANEL.size.x, TODO_PANEL.size.y), _todo_draw)
	for i in 5:
		var y := TODO_ROW_Y + float(i) * TODO_ROW_H
		var wl := _lab(_todo_panel, "", Rect2(104, y + 8, 390, 30), _ls(22, Color(ink.r, ink.g, ink.b, 0.6), false), HORIZONTAL_ALIGNMENT_LEFT)
		wl.autowrap_mode = TextServer.AUTOWRAP_OFF
		wl.clip_text = true
		_todo_who.append(wl)
		var tl := _lab(_todo_panel, "", Rect2(104, y + 38, 390, 70), _ls(int(DS.fs_small), ink, false), HORIZONTAL_ALIGNMENT_LEFT)
		tl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		_todo_task.append(tl)
		var sl := _lab(_todo_panel, "", Rect2(500, y + 64, 130, 30), _ls(20, ink, false))
		sl.autowrap_mode = TextServer.AUTOWRAP_OFF
		_todo_stl.append(sl)
	var hy := TODO_ROW_Y + 5.0 * TODO_ROW_H
	_todo_held_l = _lab(_todo_panel, "", Rect2(104, hy + 14, 510, 64), _ls(30, ink, false), HORIZONTAL_ALIGNMENT_LEFT)
	_todo_hint = _klab(_todo_panel, "탭하면 닫혀요", Rect2(0, hy + 92, 640, 40), _ls(22, Color(ink.r, ink.g, ink.b, 0.55), false))


## 버튼 그림: 목록 (점 + 줄 셋)
func _todo_btn_draw(c: Control) -> void:
	var ink: Color = DS.ink
	for i in 3:
		var y := 12.0 + 12.0 * float(i)
		c.draw_circle(Vector2(9, y), 4.5, ink)
		c.draw_line(Vector2(19, y), Vector2(42, y), ink, 5.0)


## 판 그림: 줄마다 노란 동그라미 그림 + 상태 표시(끝 = 민트 동그라미에 체크, 하는 중 = 노랑, 안 만남 = 빈 고리), 든 물건 줄
func _todo_draw(c: Control) -> void:
	var ink: Color = DS.ink
	var line := Color(ink.r, ink.g, ink.b, 0.15)
	for i in 5:
		var y := TODO_ROW_Y + float(i) * TODO_ROW_H
		if i > 0:
			c.draw_line(Vector2(30, y), Vector2(610, y), line, 2.0)
		_todo_badge(c, Vector2(58, y + 56), _todo_ic[i], _todo_st[i] == 2)
		var g := Vector2(565, y + 38)
		match _todo_st[i]:
			2:
				c.draw_circle(g, 18.0, DS.mint)
				c.draw_arc(g, 18.0, 0.0, TAU, 24, ink, 3.0)
				c.draw_polyline(PackedVector2Array([g + Vector2(-9, 0), g + Vector2(-2, 7), g + Vector2(10, -7)]), ink, 4.0)
			1:
				c.draw_circle(g, 18.0, DS.accent)
				c.draw_arc(g, 18.0, 0.0, TAU, 24, ink, 3.0)
				c.draw_circle(g, 5.0, ink)
			_:
				c.draw_arc(g, 16.0, 0.0, TAU, 24, Color(ink.r, ink.g, ink.b, 0.4), 3.0)
	var hy := TODO_ROW_Y + 5.0 * TODO_ROW_H
	c.draw_line(Vector2(30, hy), Vector2(610, hy), Color(ink.r, ink.g, ink.b, 0.3), 3.0)
	if _todo_hk != "":
		_todo_badge(c, Vector2(58, hy + 46), _todo_hk, false)
	else:
		c.draw_arc(Vector2(58, hy + 46), 28.0, 0.0, TAU, 28, Color(ink.r, ink.g, ink.b, 0.3), 3.0)


func _todo_badge(c: Control, o: Vector2, kind: String, dim: bool) -> void:
	var ink: Color = DS.ink
	c.draw_circle(o + Vector2(0, 4), 32.0, Color(ink.r, ink.g, ink.b, 0.4))
	c.draw_circle(o, 32.0, ink)
	c.draw_circle(o, 28.0, DS.accent)
	if kind != "" and _game.has_method("todo_icon"):
		_game.call("todo_icon", c, o, 0.85, kind)
	if dim:
		c.draw_circle(o, 28.0, Color(1, 1, 1, 0.45))


## 판 글자를 본체의 지금 상태로 다시 쓴다
func _todo_fill() -> void:
	var rows: Array = _game.call("todo_rows") if _game.has_method("todo_rows") else []
	var ink: Color = DS.ink
	var n := 0
	for i in 5:
		if i >= rows.size():
			continue
		var r: Dictionary = rows[i]
		var st := int(r.get("st", 0))
		_todo_st[i] = st
		_todo_ic[i] = str(r.get("icon", ""))
		if st == 2:
			n += 1
		_todo_who[i].text = "%s · %s" % [str(r.get("who", "")), str(r.get("planet", ""))]
		_todo_task[i].text = str(r.get("task", ""))
		_todo_task[i].label_settings.font_color = Color(ink.r, ink.g, ink.b, 0.5 if st == 2 else 1.0)
		_todo_stl[i].text = tr("끝" if st == 2 else ("하는 중" if st == 1 else "아직 안 만남"))
	_todo_head.text = "%s  %d/5" % [tr("할 일"), n]
	var held: Array = _game.call("todo_held") if _game.has_method("todo_held") else ["", ""]
	_todo_hk = str(held[0]) if held.size() > 0 else ""
	var hn := str(held[1]) if held.size() > 1 else ""
	_todo_held_l.text = "%s: %s" % [tr("들고 있는 것"), hn if hn != "" else tr("빈손")]
	_todo_canvas.queue_redraw()


func _todo_show() -> void:
	if _todo_on:
		return
	_todo_on = true
	_todo_fill()
	_todo_t = 0.0
	_todo_dim.visible = true
	_todo_panel.visible = true
	_todo_panel.scale = Vector2(0.01, 0.01)
	squash(_todo_btn)


func _todo_close() -> void:
	if not _todo_on:
		return
	_todo_on = false
	_todo_dim.visible = false
	_todo_panel.visible = false
	_sfx("ui_tap")


func _todo_anim(dt: float) -> void:
	_todo_t += dt
	var k := maxf(_back_out(clampf(_todo_t / 0.25, 0.0, 1.0)), 0.01)
	_todo_panel.scale = Vector2(k, k)


## 매 프레임 (본체 상태): 버튼 보이기, 끝낸 수 글자
func _todo_tick(ok: bool, n: int) -> void:
	if _todo_btn == null:
		return
	if ok != _todo_ok:
		_todo_ok = ok
		_todo_btn.visible = ok
		if not ok:
			_todo_close()
	if n != _todo_n:
		_todo_n = n
		_todo_btn_l.text = "%d/5" % n
		if n > 0:
			squash(_todo_btn)


# ---- 점수 팝: 숫자가 위로 튀어 올라 0.8초에 사라짐 ----
func _build_pops() -> void:
	var r := _root(7)
	for i in NPOP:
		var l := _lab(r, "", Rect2(0, 0, 240, 90), _ls(int(DS.fs_btn), DS.accent, true, true))
		l.autowrap_mode = TextServer.AUTOWRAP_OFF
		l.visible = false
		_pops.append(l)
		_pop_t.append(9.0)
		_pop_p.append(Vector2.ZERO)


func _pop(n: int, wpos: Variant) -> void:
	if n == 0:
		return
	var sp := Vector2(360, 560)
	var cam := _game.get("cam") as Camera3D
	if cam != null and wpos is Vector3:
		var w: Vector3 = wpos
		if not cam.is_position_behind(w):
			sp = cam.unproject_position(w)
	sp = sp.clamp(Vector2(120, 300), Vector2(600, 1100))
	var i := _pop_i
	_pop_i = (_pop_i + 1) % NPOP
	_pops[i].text = ("+%d" % n) if n > 0 else str(n)
	_pop_p[i] = sp
	_pop_t[i] = 0.0
	_pops[i].visible = true


func _pops_anim(dt: float) -> void:
	for i in NPOP:
		if _pop_t[i] >= 0.8:
			continue
		_pop_t[i] += dt
		var t := _pop_t[i]
		var l := _pops[i]
		if t >= 0.8:
			l.visible = false
			continue
		var k := t / 0.8
		var rise := 120.0 * (1.0 - pow(1.0 - k, 3.0))
		l.position = _pop_p[i] - l.size * 0.5 - Vector2(0.0, rise)
		var s := lerpf(0.4, 1.3, t / 0.12) if t < 0.12 else lerpf(1.3, 1.0, minf((t - 0.12) / 0.12, 1.0))
		l.scale = Vector2(s, s)
		l.modulate.a = 1.0 if k < 0.6 else 1.0 - (k - 0.6) / 0.4


# 본체가 번역 서버에 합친다 (한국어 -> English). 본체에 set_lang 이 없으면 _own_lang 이 직접 넣는다.
const EN := {
	"어린 배달부": "The Little Courier",
	"시작": "START",
	"모든 부탁 완료!": "All done!",
	"목숨을 다 썼어": "Out of lives",
	"다섯 별이 모두 웃고 있어": "All five planets are smiling",
	"다시 하면 첫 별부터 새로 시작해": "Try again from the first planet",
	"배달한 수": "Delivered",
	"걸린 시간": "Time",
	"버틴 시간": "Time survived",
	"새총": "Slingshots",
	"최고 기록": "Best time",
	"최고 배달": "Best delivered",
	"새 기록": "New best",
	"다시": "AGAIN",
	# v9 할 일 목록
	"할 일": "To-do",
	"아직 안 만남": "Not met",
	"하는 중": "In progress",
	"끝": "Done",
	"들고 있는 것": "Carrying",
	"빈손": "Nothing",
	"탭하면 닫혀요": "Tap anywhere to close",
}
