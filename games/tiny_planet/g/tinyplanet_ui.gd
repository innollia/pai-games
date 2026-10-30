extends Node
## 작은 행성 UI: 시작 화면 · 튜토리얼 단계 기계 · 게임오버/엔딩 화면 · 점수 팝 · 디자인 시스템(DS) · 버튼 눌림.
## 본체(g/tinyplanet.gd)가 preload 해서 add_child 하고 아래 함수만 부른다. 본체 변수 이름에 기대지 않는다
## (game 에서 읽는 것: over, cam, _font, restart(), sfx() 뿐. 모두 get/call 로 읽는다).
##
## 약속 함수 (submit/tinyplanet/MODULES.md)
##   setup(game: Node) -> void              add_child 뒤 한 번. 본체가 _lang()으로 언어를 정한 뒤에 부른다(글자를 tr 로 만든다).
##   tick(dt: float, s: Dictionary) -> void 본체 _step 끝에서 매 프레임. 튜토리얼 ①② 판정, 걸린 시간 셈.
##   event(name: String, d := {}) -> void   일이 일어날 때. liftoff/land/sail/score/deliver/slingshot/job_done/finish 등을 쓴다.
##   show_title(on_start: Callable) -> void 시작 화면. "시작"(또는 "튜토리얼 다시")을 누르면 화면이 닫히고 on_start 를 부른다.
##   tutorial_active() -> bool              튜토리얼 카드가 지금 떠 있으면 true(돛 기다리는 동안·끝난 뒤는 false).
## 덧붙인 공개 함수
##   title_visible() -> bool                시작 화면이 떠 있나(본체는 이 동안 점수 글자·조작 키트를 숨기고 _step 을 멈추면 좋다).
##   tutorial_step() -> int                 지금 단계: 0 달리기 1 막대 2 점프 3 점선 4 돛, 10 돛 받기를 기다림, -1 없음.
##   start_tutorial() -> void               튜토리얼을 처음부터.
##   skip_tutorial() -> void                튜토리얼을 끝내고 "다 봤음"을 저장.
##   reset_run() -> void                    이번 판 기록(시간·배달·새총)을 0으로. game.over 가 풀리면 저절로 부른다.
##   squash(c: Control) -> void             아무 Control 이나 0.92배로 줄었다 0.12초에 돌아오게(+ui_tap 소리).
##   make_panel(parent: Control, rect: Rect2, fill: Color) -> Control  DS 규칙(모서리 28·테두리 6·그림자 8) 패널.
## 화면 층: 점수 팝 7, 튜토리얼 6(조작 키트 5 위), 끝 화면 8(평가 카드 9 아래), 시작 화면 12(맨 위).
## 입력: 내 버튼은 _input 에서 먼저 받고 처리했다고 표시한다(조작 키트로 안 샌다). 왼쪽 위 "< 메뉴" 자리는 건드리지 않는다.

const DS := {
	"cream": Color("fff6e6"), "ink": Color("2b2d42"), "sky": Color("9fd3ff"), "mint": Color("8fe3c2"), "lav": Color("b9a7f2"),
	"accent": Color("ffd166"), "danger": Color("e8453c"), "go": Color("37b24d"),
	"radius": 28, "border": 6, "shadow_y": 8, "shadow_a": 0.4,
	"fs_title": 84, "fs_btn": 52, "fs_body": 34, "fs_small": 26, "outline_px": 6,
	"press": 0.92, "press_t": 0.12,
}
const CFG := "user://tinyplanet.cfg"
const BACK_RECT := Rect2(0, 0, 180, 100)  # tofu "< 메뉴"
const STEP_SKIP_T := 12.0  # 이만큼 지나면 "다음 단계" 버튼
const WAIT_SAIL := 10
const STICK_AT := Vector2(180, 1080)  # kit_stick() 기본 자리
const JUMP_AT := Vector2(580, 1070)  # 점프 버튼
const BAR_AT := Vector2(360, 232)  # 위 에너지 막대(tofu gauge) 바로 아래
const NPOP := 8
const DOT_COLS := [Color("ffffff"), Color("37b24d"), Color("e8453c")]  # 본체 앞길 점선 색 (돌아옴·다른 별·위험)
const ROW_COLS := ["mint", "sky", "lav", "accent"]
const STAR_SPOTS :=[Vector2(96, 170), Vector2(640, 150), Vector2(70, 380), Vector2(664, 610), Vector2(80, 720), Vector2(620, 960)]
const TUT_T := ["왼쪽 스틱으로 달려 봐", "위 막대 = 날아갈 힘", "점프! 살짝 뛰었다 내려와", "", "돛을 받았어!"]
const TUT_S := ["멀리 밀수록 빨라져", "더 빨리 달려서 막대를 채워 봐", "오른쪽 노란 버튼을 톡", "", "날다가 점프 = 스틱 쪽으로 방향 틀기"]


## DS 규칙 상자: 모서리 28, 테두리 6 잉크, 아래로 8 잉크 40% 단색 그림자. act 가 있으면 버튼.
class _Box extends Control:
	var sb := StyleBoxFlat.new()
	var sh := StyleBoxFlat.new()
	var shy := 8.0
	var act := Callable()
	var breathe := false
	var sq := 0.0  # 눌림 남은 시간

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


## 그리기 함수를 빌려 쓰는 빈 Control
class _Canvas extends Control:
	var fn := Callable()

	func _draw() -> void:
		if fn.is_valid():
			fn.call(self)


var _game: Node
var _font: Font
var _btns: Array[_Box] = []
var _pending := Callable()
var _pending_t := 0.0
var _clock := 0.0
var _star := PackedVector2Array()
var _star_line := PackedVector2Array()
var _arrow := PackedVector2Array()
var _arrow_line := PackedVector2Array()
var _check_pts := PackedVector2Array()
var _env_v := PackedVector2Array([Vector2(-17, -12), Vector2(0, 2), Vector2(17, -12)])
var _sb_track := StyleBoxFlat.new()
var _sb_fill := StyleBoxFlat.new()
# 시작 화면
var _title_root: Control
var _title_l: Label
var _title_sub: Label
var _title_deco: _Canvas
var _start_b: _Box
var _again_b: _Box
var _title_on := false
var _title_out := -1.0
var _want_tut := false
var _on_start := Callable()
# 튜토리얼
var _tut_root: Control
var _card: _Box
var _chip_l: Label
var _card_t: Label
var _card_s: Label
var _card_fx: _Canvas
var _dots_card: _Box
var _dots_fx: _Canvas
var _ok_b: _Box
var _over_fx: _Canvas
var _cur_card: _Box
var _skip_b: _Box
var _next_b: _Box
var _tut := -1
var _tut_t := 0.0
var _tut_ok := -1.0  # 0 이상이면 이 단계 해냄(체크 표시 시간)
var _tut_delay := 0.0  # 0 넘으면 카드를 띄우기 전 기다림
var _tut_prog := 0.0
var _card_in := 0.0
var _run_t := 0.0
var _hop := false
var _have_sail := false
var _tut_done := false
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
var _again_end: _Box
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
	_build_tut()
	_build_end()
	_build_pops()
	_build_title()


func tick(dt: float, s: Dictionary) -> void:
	_paused = s.get("paused", false) == true
	if _title_on or _paused:
		return
	if not _finished:
		_time += dt
	if _tut < 0 or _tut_delay > 0.0 or _tut_ok >= 0.0:
		return
	var spd := float(s.get("speed", 0.0))
	var top := float(s.get("top", 12.5))
	var lift := float(s.get("lift", 0.0))
	if _tut == 0:
		if spd > top * 0.4:
			_run_t += dt
		else:
			_run_t = maxf(_run_t - dt * 0.5, 0.0)
		_tut_prog = clampf(_run_t, 0.0, 1.0)
		if _run_t >= 1.0:
			_tut_pass()
	elif _tut == 1:
		_tut_prog = clampf(lift / 0.6, 0.0, 1.0)
		if lift >= 0.6:
			_tut_pass()


func event(name: String, d := {}) -> void:
	match name:
		"liftoff", "escape":
			if _tut == 2:
				_hop = true
		"land", "orbit_land":
			if _tut == 2 and _hop:
				_tut_pass()
		"deliver":
			if not _finished:
				_delivered += 1
		"slingshot":
			if not _finished:
				_slings += 1
		"job_done":
			_jobs += 1
			if int(d.get("job", -1)) == 0:
				_got_sail()
		"windmill_wake":
			_got_sail()
		"sail":
			_have_sail = true
			if _tut == 4:
				_tut_pass()
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
	_title_root.visible = true
	_title_root.modulate.a = 1.0
	_title_root.position = Vector2.ZERO
	_again_b.visible = _tut_done
	_start_b.breathe = true


func tutorial_active() -> bool:
	return _tut >= 0 and _tut != WAIT_SAIL and not _title_on


# ---- 덧붙인 공개 함수 ----
func title_visible() -> bool:
	return _title_on


func tutorial_step() -> int:
	return _tut


func start_tutorial() -> void:
	_tut = 0
	_tut_delay = 0.9
	_tut_ok = -1.0
	_hop = false
	_run_t = 0.0


func skip_tutorial() -> void:
	_tut = -1
	_tut_ok = -1.0
	_tut_done = true
	_save_cfg()


func reset_run() -> void:
	_time = 0.0
	_delivered = 0
	_slings = 0
	_jobs = 0
	_finished = false
	_have_sail = false
	if _tut == 4:
		_tut = WAIT_SAIL


func squash(c: Control) -> void:
	c.pivot_offset = c.size * 0.5
	c.scale = Vector2.ONE * float(DS.press)
	var tw := c.create_tween()
	tw.tween_property(c, "scale", Vector2.ONE, float(DS.press_t)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sfx("ui_tap")


func make_panel(parent: Control, rect: Rect2, fill: Color) -> Control:
	return _box(parent, rect, fill)


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
	if BACK_RECT.has_point(p):
		return  # "< 메뉴"는 본체(tofu)가 받는다
	# 터치가 흉내 낸 마우스는 받기만 하고 또 누르지 않는다
	var fire := ev.is_pressed() and (touch or ev.device != InputEvent.DEVICE_ID_EMULATION)
	var b := _hit(p)
	if b == null and _tut_root.visible and _dots_card.visible and _rect_of(_dots_card).has_point(p):
		b = _ok_b  # 점선 카드는 아무 데나 탭해도 "알았어"
	if b != null:
		if fire:
			_press(b)
		get_viewport().set_input_as_handled()
	elif _title_on or (_tut_root.visible and _cur_card != null and _rect_of(_cur_card).has_point(p)):
		get_viewport().set_input_as_handled()


func _rect_of(c: Control) -> Rect2:
	return Rect2(c.global_position, c.size * c.scale)


func _hit(p: Vector2) -> _Box:
	for i in range(_btns.size() - 1, -1, -1):
		var b := _btns[i]
		if b.act.is_valid() and b.is_visible_in_tree() and _rect_of(b).grow(10.0).has_point(p):
			return b
	return null


func _press(b: _Box) -> void:
	if _pending.is_valid():
		return
	b.sq = float(DS.press_t)
	_sfx("ui_tap")
	_pending = b.act
	_pending_t = float(DS.press_t)


# ---- 매 프레임 (게임이 끝나 _step 이 멈춰도 돈다) ----
func _process(dt: float) -> void:
	if _game == null:
		return
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
	_tut_anim(rdt, ov)
	if _end_root.visible:
		_end_anim(rdt)
	_pops_anim(rdt)


func _buttons_anim(dt: float) -> void:
	for b in _btns:
		if not b.is_visible_in_tree():
			continue
		var s := 1.0
		if b.breathe:
			s += 0.035 * sin(_clock * 3.2)
		if b.sq > 0.0:
			b.sq = maxf(b.sq - dt, 0.0)
			var k := b.sq / float(DS.press_t)
			s *= lerpf(1.0, float(DS.press), k * k)
		b.scale = Vector2(s, s)


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


func _box(parent: Control, rect: Rect2, fill: Color) -> _Box:
	var b := _Box.new()
	b.position = rect.position
	b.size = rect.size
	b.pivot_offset = rect.size * 0.5
	b.paint(fill, DS)
	parent.add_child(b)
	return b


## 버튼: 큰 글자(52)는 크림 글자 + 잉크 외곽선, 작은 글자는 잉크 글자
func _button(parent: Control, rect: Rect2, fill: Color, text: String, fs: int, act: Callable) -> _Box:
	var b := _box(parent, rect, fill)
	b.act = act
	var big := fs >= int(DS.fs_btn)
	var col: Color = DS.cream if big else DS.ink
	_lab(b, text, Rect2(Vector2(0, -3), rect.size), _ls(fs, col, big))
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
	_arrow = PackedVector2Array([Vector2(0, 0), Vector2(-42, 52), Vector2(-17, 52), Vector2(-17, 116),
		Vector2(17, 116), Vector2(17, 52), Vector2(42, 52)])
	_arrow_line = _arrow.duplicate()
	_arrow_line.append(_arrow[0])
	_check_pts = PackedVector2Array([Vector2(-19, 1), Vector2(-5, 15), Vector2(20, -13)])
	var ink: Color = DS.ink
	_sb_track.bg_color = Color(ink.r, ink.g, ink.b, 0.15)
	_sb_track.set_corner_radius_all(8)
	_sb_fill.bg_color = DS.mint
	_sb_fill.border_color = ink
	_sb_fill.set_border_width_all(3)
	_sb_fill.set_corner_radius_all(8)


# ---- 저장 (user://tinyplanet.cfg) ----
func _load_cfg() -> void:
	var cf := ConfigFile.new()
	if cf.load(CFG) != OK:
		return
	_tut_done = cf.get_value("tut", "done", false) == true
	_best_time = float(cf.get_value("best", "time", 0.0))
	_best_deliv = int(cf.get_value("best", "delivered", 0))


func _save_cfg() -> void:
	var cf := ConfigFile.new()
	var _e := cf.load(CFG)  # 다른 값을 지키려고 먼저 읽는다 (없으면 빈 채로)
	cf.set_value("tut", "done", _tut_done)
	cf.set_value("best", "time", _best_time)
	cf.set_value("best", "delivered", _best_deliv)
	var _s := cf.save(CFG)


# ---- 시작 화면 ----
func _build_title() -> void:
	_title_root = _root(12)
	_title_deco = _canvas(_title_root, Rect2(0, 0, 720, 1280), _draw_title_deco)
	var name_ko := tr("작은 행성")
	_title_l = _lab(_title_root, name_ko, Rect2(0, 200, 720, 120), _ls(int(DS.fs_title), DS.cream, true, true))
	var other := "Tiny Planets" if name_ko == "작은 행성" else "작은 행성"
	_title_sub = _lab(_title_root, other, Rect2(0, 318, 720, 54), _ls(int(DS.fs_body), DS.lav, true))
	var tag := _box(_title_root, Rect2(60, 420, 600, 170), DS.cream)
	_lab(tag, tr("달려서 날아올라 별에서 별로!\n다섯 별 주민의 부탁을 들어줘"), Rect2(20, 10, 560, 150),
		_ls(int(DS.fs_body), DS.ink, false))
	_lab(_title_root, tr("왼쪽 스틱 = 달리기 · 노란 버튼 = 점프"), Rect2(30, 626, 660, 60),
		_ls(int(DS.fs_small), DS.cream, true))
	_start_b = _button(_title_root, Rect2(160, 770, 400, 140), DS.accent, tr("시작"), int(DS.fs_btn), _title_go.bind(false))
	_again_b = _button(_title_root, Rect2(210, 960, 300, 84), DS.cream, tr("튜토리얼 다시"), int(DS.fs_small), _title_go.bind(true))
	_title_root.visible = false


func _title_go(tut: bool) -> void:
	if _title_out >= 0.0:
		return
	_want_tut = tut or not _tut_done
	_title_out = 0.0
	_start_b.breathe = false


func _title_anim(dt: float) -> void:
	var t := _clock
	_title_l.position.y = 200.0 + sin(t * 1.6) * 8.0
	_title_l.rotation = sin(t * 1.1) * 0.02
	_title_sub.position.y = 318.0 + sin(t * 1.6 - 0.7) * 6.0
	_title_deco.queue_redraw()
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
		if _want_tut:
			start_tutorial()


## 반짝이는 별 몇 개 + 편지를 안고 도는 작은 행성
func _draw_title_deco(c: Control) -> void:
	var ink: Color = DS.ink
	var sh := Color(ink.r, ink.g, ink.b, float(DS.shadow_a))
	for i in STAR_SPOTS.size():
		var at: Vector2 = STAR_SPOTS[i]
		var r := (22.0 + 6.0 * float(i % 3)) * (1.0 + 0.22 * sin(_clock * 2.3 + float(i) * 1.7))
		var col: Color = DS.accent if i % 2 == 0 else DS.cream
		_draw_star(c, at + Vector2(0, 6), r, sh, Color(0, 0, 0, 0), sin(_clock * 0.6 + float(i)) * 0.3)
		_draw_star(c, at, r, col, ink, sin(_clock * 0.6 + float(i)) * 0.3)
	# 작은 행성 + 도는 편지
	var pc := Vector2(600, 262 + sin(_clock * 1.3) * 6.0)
	c.draw_circle(pc + Vector2(0, 8), 34.0, sh)
	c.draw_circle(pc, 34.0, ink)
	c.draw_circle(pc, 28.0, DS.mint)
	c.draw_circle(pc + Vector2(-9, -9), 8.0, DS.cream)
	var a := _clock * 1.4
	var lp := pc + Vector2(cos(a) * 62.0, sin(a) * 24.0)
	c.draw_set_transform(lp, sin(a) * 0.3, Vector2.ONE)
	c.draw_rect(Rect2(-17, -12 + 6, 34, 24), sh)
	c.draw_rect(Rect2(-17, -12, 34, 24), DS.accent)
	c.draw_rect(Rect2(-17, -12, 34, 24), ink, false, 4.0)
	c.draw_polyline(_env_v, ink, 4.0)
	c.draw_set_transform(Vector2.ZERO)


func _draw_star(c: Control, at: Vector2, r: float, fill: Color, line: Color, rot: float) -> void:
	c.draw_set_transform(at, rot, Vector2(r, r))
	c.draw_colored_polygon(_star, fill)
	if line.a > 0.0:
		c.draw_polyline(_star_line, line, 5.0 / r, true)
	c.draw_set_transform(Vector2.ZERO)


# ---- 튜토리얼 ----
func _build_tut() -> void:
	_tut_root = _root(6)
	# 보통 카드: 번호 칩 + 할 일 + 작은 설명 + 진행 막대
	_card = _box(_tut_root, Rect2(40, 466, 640, 156), DS.cream)
	var chip := _box(_card, Rect2(22, 46, 64, 64), DS.mint)
	_chip_l = _lab(chip, "1", Rect2(0, -3, 64, 64), _ls(int(DS.fs_body), DS.ink, false))
	_card_t = _lab(_card, "", Rect2(104, 16, 450, 56), _ls(int(DS.fs_body), DS.ink, false), HORIZONTAL_ALIGNMENT_LEFT)
	var ink: Color = DS.ink
	_card_s = _lab(_card, "", Rect2(104, 70, 450, 50), _ls(int(DS.fs_small), Color(ink.r, ink.g, ink.b, 0.75), false), HORIZONTAL_ALIGNMENT_LEFT)
	_card_fx = _canvas(_card, Rect2(0, 0, 640, 156), _draw_card_fx)
	# 점선 색 카드: 탭해서 넘김
	_dots_card = _box(_tut_root, Rect2(40, 450, 640, 440), DS.cream)
	_lab(_dots_card, tr("발 앞 점선 = 지금 뛰면 갈 길"), Rect2(24, 16, 592, 92), _ls(int(DS.fs_body), DS.ink, false))
	var rows := ["흰색: 이 별로 돌아와", "초록: 다른 별에 닿아", "빨강: 위험해!"]
	for i in 3:
		_lab(_dots_card, tr(str(rows[i])), Rect2(214, 112 + i * 70, 400, 60), _ls(int(DS.fs_body), DS.ink, false), HORIZONTAL_ALIGNMENT_LEFT)
	_dots_fx = _canvas(_dots_card, Rect2(0, 0, 640, 440), _draw_dots_fx)
	_ok_b = _button(_dots_card, Rect2(190, 330, 260, 92), DS.accent, tr("알았어"), int(DS.fs_btn), _tut_pass)
	_dots_card.visible = false
	# 카드 아래에 걸친 작은 버튼 둘
	_next_b = _button(_tut_root, Rect2(268, 598, 190, 62), DS.cream, tr("다음 단계"), int(DS.fs_small), _tut_next)
	_skip_b = _button(_tut_root, Rect2(474, 598, 190, 62), DS.lav, tr("튜토리얼 끝"), int(DS.fs_small), skip_tutorial)
	# 손가락·화살표·체크 표시 (카드 위)
	_over_fx = _canvas(_tut_root, Rect2(0, 0, 720, 1280), _draw_tut_fx)
	_cur_card = _card
	_tut_root.visible = false


## 단계를 해냄: 체크 표시가 튀어 오르고 배달 소리, 1초 뒤 다음
func _tut_pass() -> void:
	if _tut < 0 or _tut == WAIT_SAIL or _tut_ok >= 0.0 or _tut_delay > 0.0:
		return
	_tut_ok = 0.0
	_tut_prog = 1.0
	_sfx("deliver", -3.0, 1.2)


func _tut_next() -> void:
	match _tut:
		0, 1, 2:
			_tut += 1
			_tut_delay = 0.35
		3:
			if _have_sail:
				_tut = 4
				_tut_delay = 0.35
			else:
				_tut = WAIT_SAIL
		4:
			skip_tutorial()
	_tut_ok = -1.0


func _got_sail() -> void:
	_have_sail = true
	if _tut == WAIT_SAIL:
		_tut = 4
		_tut_delay = 3.0  # 풍차지기 고마움 말을 먼저 듣게


func _show_step() -> void:
	_tut_t = 0.0
	_tut_ok = -1.0
	_card_in = 0.0
	_run_t = 0.0
	_hop = false
	_tut_prog = 0.0
	var dots := _tut == 3
	_card.visible = not dots
	_dots_card.visible = dots
	_cur_card = _dots_card if dots else _card
	if not dots and _tut >= 0 and _tut < TUT_T.size():
		_chip_l.text = str(_tut + 1)
		_card_t.text = tr(str(TUT_T[_tut]))
		_card_s.text = tr(str(TUT_S[_tut]))
	_sfx("talk", -6.0, 1.25)


func _tut_anim(dt: float, ov: bool) -> void:
	var on := _tut >= 0 and _tut != WAIT_SAIL and not ov and not _title_on
	if on and _tut_delay > 0.0:
		_tut_delay -= dt
		if _tut_delay <= 0.0:
			_tut_delay = 0.0
			_show_step()
		else:
			on = false
	_tut_root.visible = on
	if not on:
		return
	if not _paused:
		_tut_t += dt
	if _tut_ok >= 0.0:
		_tut_ok += dt
		if _tut_ok >= 1.0:
			_tut_next()
			if _tut < 0 or _tut == WAIT_SAIL:
				_tut_root.visible = false
				return
	_card_in = minf(_card_in + dt / 0.4, 1.0)
	var cs := maxf(_back_out(_card_in), 0.01)
	_cur_card.scale = Vector2(cs, cs)
	var pills := _tut != 3
	_skip_b.visible = pills
	_next_b.visible = pills and _tut_t > STEP_SKIP_T and _tut_ok < 0.0
	_skip_b.modulate.a = _card_in
	_card_fx.queue_redraw()
	_over_fx.queue_redraw()
	if _dots_card.visible:
		_dots_fx.queue_redraw()


func _draw_card_fx(c: Control) -> void:
	if _tut > 1:
		return
	var r := Rect2(104, 124, 440, 16)
	c.draw_style_box(_sb_track, r)
	if _tut_prog > 0.02:
		c.draw_style_box(_sb_fill, Rect2(r.position, Vector2(maxf(r.size.x * _tut_prog, 16.0), r.size.y)))


## 점선 견본: 흰·초록·빨강 점이 앞으로 흘러간다
func _draw_dots_fx(c: Control) -> void:
	var ink: Color = DS.ink
	for row in 3:
		var y := 142.0 + float(row) * 70.0
		var col: Color = DOT_COLS[row]
		for i in 5:
			var ph := fmod(_clock * 1.6 + float(i) * 0.2, 1.0)
			var x := 44.0 + float(i) * 34.0
			var r := 9.0 + 3.0 * sin(ph * TAU)
			c.draw_circle(Vector2(x, y), r + 3.0, ink)
			c.draw_circle(Vector2(x, y), r, col)


## 단계 그림: 손가락·화살표, 해냈으면 체크 표시
func _draw_tut_fx(c: Control) -> void:
	if _tut_ok >= 0.0:
		var k := clampf(_tut_ok / 0.35, 0.0, 1.0)
		var at := Vector2(_cur_card.position.x + _cur_card.size.x - 24.0, _cur_card.position.y + 14.0 - 18.0 * _tut_ok)
		_draw_check(c, at, _back_out(k) * 1.1, sin(_tut_ok * 9.0) * 0.12 * (1.0 - k))
		return
	var cyc := fmod(_clock, 1.6) / 1.6
	match _tut:
		0:
			var push := smoothstep(0.1, 0.55, cyc) * (1.0 - smoothstep(0.85, 1.0, cyc))
			_draw_finger(c, STICK_AT + Vector2(120, -50) * push, 0.0)
		1:
			var bob := sin(_clock * 6.0) * 10.0
			_draw_arrow(c, BAR_AT + Vector2(0, 8.0 + bob))
			_draw_finger(c, STICK_AT + Vector2(150, -60), 0.0)
		2:
			_draw_tap(c, JUMP_AT, cyc)
		4:
			_draw_tap(c, JUMP_AT, cyc)
			var sw := sin(_clock * 2.5)
			_draw_finger(c, STICK_AT + Vector2(110.0 * sw, -40), 0.0)


## 톡 누르는 손가락: 눌릴 때 살짝 내려가고 노란 고리가 퍼진다
func _draw_tap(c: Control, at: Vector2, cyc: float) -> void:
	var down := 1.0 - smoothstep(0.0, 0.25, absf(cyc - 0.3))
	var ring := clampf((cyc - 0.3) / 0.6, 0.0, 1.0) if cyc >= 0.3 else 0.0
	_draw_finger(c, at + Vector2(0, 10.0 * down), ring)


func _draw_finger(c: Control, tip: Vector2, ring: float) -> void:
	var ink: Color = DS.ink
	var sh := Color(ink.r, ink.g, ink.b, float(DS.shadow_a))
	if ring > 0.0 and ring < 1.0:
		var ac: Color = DS.accent
		c.draw_arc(tip, 34.0 + 56.0 * ring, 0.0, TAU, 40, Color(ink.r, ink.g, ink.b, 1.0 - ring), 12.0, true)
		c.draw_arc(tip, 34.0 + 56.0 * ring, 0.0, TAU, 40, Color(ac.r, ac.g, ac.b, 1.0 - ring), 6.0, true)
	var tail := tip + Vector2(44, 124)
	var o := Vector2(0.0, float(DS.shadow_y))
	_capsule(c, tip + o, tail + o, 36.0, sh)
	_capsule(c, tip, tail, 36.0, ink)
	_capsule(c, tip, tail, 30.0, DS.cream)
	c.draw_circle(tip + Vector2(4, 8), 13.0, Color("ffd9cc"))


func _capsule(c: Control, a: Vector2, b: Vector2, r: float, col: Color) -> void:
	c.draw_line(a, b, col, r * 2.0)
	c.draw_circle(a, r, col)
	c.draw_circle(b, r, col)


## 위를 가리키는 노란 화살표 (tip = 끝점)
func _draw_arrow(c: Control, tip: Vector2) -> void:
	var ink: Color = DS.ink
	c.draw_set_transform(tip + Vector2(0.0, float(DS.shadow_y)))
	c.draw_colored_polygon(_arrow, Color(ink.r, ink.g, ink.b, float(DS.shadow_a)))
	c.draw_set_transform(tip)
	c.draw_colored_polygon(_arrow, DS.accent)
	c.draw_polyline(_arrow_line, ink, 6.0, true)
	c.draw_set_transform(Vector2.ZERO)


func _draw_check(c: Control, at: Vector2, sc: float, rot: float) -> void:
	if sc <= 0.01:
		return
	var ink: Color = DS.ink
	c.draw_set_transform(at, rot, Vector2(sc, sc))
	c.draw_circle(Vector2(0.0, float(DS.shadow_y)), 46.0, Color(ink.r, ink.g, ink.b, float(DS.shadow_a)))
	c.draw_circle(Vector2.ZERO, 46.0, ink)
	c.draw_circle(Vector2.ZERO, 40.0, DS.mint)
	c.draw_polyline(_check_pts, ink, 12.0, true)
	c.draw_set_transform(Vector2.ZERO)


# ---- 게임오버 · 엔딩 ----
func _build_end() -> void:
	_end_root = _root(8)
	var ink: Color = DS.ink
	_end_dim = ColorRect.new()
	_end_dim.color = Color(ink.r, ink.g, ink.b, 0.0)
	_end_dim.size = Vector2(720, 1280)
	_end_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_end_root.add_child(_end_dim)
	_end_panel = _box(_end_root, Rect2(60, 214, 600, 620), DS.cream)
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
	_lab(_new_b, tr("새 기록"), Rect2(0, -2, 160, 50), _ls(int(DS.fs_small), ink, false))
	_again_end = _button(_end_panel, Rect2(100, 490, 400, 110), DS.accent, tr("다시"), int(DS.fs_btn), _again)
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
	_again_end.breathe = false
	_end_t = 0.0
	_end_panel.position.y = 1000.0
	_end_root.visible = true
	_tut_root.visible = false


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
	_again_end.breathe = _end_t > 1.4


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


# 본체가 번역 서버에 합친다 (한국어 -> English)
const EN := {
	"작은 행성": "Tiny Planets",
	"달려서 날아올라 별에서 별로!\n다섯 별 주민의 부탁을 들어줘": "Run, leap, fly planet to planet!\nHelp the five planet folks",
	"왼쪽 스틱 = 달리기 · 노란 버튼 = 점프": "Left stick = run · Yellow button = jump",
	"시작": "Start",
	"튜토리얼 다시": "Replay tutorial",
	"왼쪽 스틱으로 달려 봐": "Run with the left stick",
	"멀리 밀수록 빨라져": "Push farther to go faster",
	"위 막대 = 날아갈 힘": "Top bar = flying power",
	"더 빨리 달려서 막대를 채워 봐": "Run faster to fill the bar",
	"점프! 살짝 뛰었다 내려와": "Jump! Hop up and land",
	"오른쪽 노란 버튼을 톡": "Tap the yellow button",
	"돛을 받았어!": "You got the sail!",
	"날다가 점프 = 스틱 쪽으로 방향 틀기": "Jump mid-air = turn toward the stick",
	"발 앞 점선 = 지금 뛰면 갈 길": "Dots ahead = where a jump takes you",
	"흰색: 이 별로 돌아와": "White: back to this planet",
	"초록: 다른 별에 닿아": "Green: reaches another planet",
	"빨강: 위험해!": "Red: danger!",
	"알았어": "Got it",
	"다음 단계": "Next step",
	"튜토리얼 끝": "End tutorial",
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
	"다시": "Again",
}
