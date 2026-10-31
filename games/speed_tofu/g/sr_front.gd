extends CanvasLayer
## 화면 밖 경주: 첫 화면(제목 + 시작 버튼) + 따라 하는 연습(튜토리얼).
## 쓰는 법 (screenrace.gd): const SrFront = preload("res://g/sr_front.gd")
##   front = SrFront.new(); add_child(front); front.setup(self)
##   _reset() 끝에서 phase = "title"; front.show_title()
## 신호: play_pressed (모드 고르기로), tutorial_pressed(first_run) (game.tutorial_begin() 후 front.start_tutorial(first_run)),
##       lang_pressed (언어 바꾸기, 바꾼 뒤 글자는 이 모듈이 다시 쓴다), tutorial_done(first_run) (연습 끝/건너뜀).
## 붙이는 법 전체: submit/screenrace/work/ui/INTEGRATE_front.md

const T = preload("res://g/sr_theme.gd")

signal play_pressed
signal tutorial_pressed(first_run: bool)
signal lang_pressed
signal tutorial_done(first_run: bool)

const LAYER := 20
const STEP_N := 5  # 점으로 세는 연습 단계 (마지막 "출발!" 은 세지 않는다). v12: 달리기·점프·배달·던지기·왼쪽 끝
const RUN_GOAL := 3.5  # 오른쪽으로 이만큼(m) 달리면 1단계 통과
const EDGE_T := 3.0  # 5단계: 짐을 먹힌 뒤 이만큼 보여 주고 넘어간다 (안 닿으면 EDGE_T + 2 초에 넘어간다)
const EDGE_V := 4.0  # 5단계: 찢긴 끝이 다가오는 가장 느린 속도 (m/s)
const EDGE_REACH := 2.0  # 5단계: 찢긴 끝이 배달부에게 닿기까지 걸리는 시간 (초)
const GO_T := 1.4  # "출발!" 카드 시간
const BETWEEN_T := 0.55  # 단계 사이 "좋아!" 도장 시간
const REC_PATH := "user://screenrace_v12.cfg"  # game.RECORDS 를 못 읽을 때만

## true = 처음 하는 사람이 PLAY 를 누르면 연습부터 (끝나면 바로 기본 경주)
var auto_tutorial_on_play := true

var game  # screenrace.gd (Tofu)
var state := ""  # "" 숨김 / "title" / "tutorial"

# ---- 제목 화면
var _root: Control
var _title: Control
var _wash: TextureRect
var _strips: _Strips
var _logo: Control
var _logo_tex: TextureRect
var _logo_draw: _Logo
var _ko_tag: Label
var _tag_panel: Panel
var _tag_l: Label
var _deck: _Deck
var _play: Control  # T.PaperButton
var _howto: Control  # T.PaperButton
var _pill: _Pill
var _blockers: Array[Control] = []
var _bob: Tween
var _sway: Tween
var _busy := false

# ---- 연습
var _tut: Control
var _guide: _Guide
var _bubble: _Bubble
var _skip: Control  # _SkipPill
var _nice: Label
var _first := false
var step := -1
var _tt := 0.0
var _between := 0.0
var _x0 := 0.0
var _cargo0 := 0
var _throws0 := 0
const STUCK_T := 15.0  # 한 단계에서 이만큼 못 넘기면 넘겨 준다 (막혀서 연습이 멈추지 않게)
var _got0 := 0
var _was_g := true
var _jumped := false
var _edge_x := 0.0  # 5단계: 찢긴 끝(화면 왼쪽 끝)의 세계 x, 초당 EDGE_V 로 다가온다
var _eaten := false
var _edge_v := EDGE_V  # 5단계: 이번 끝 속도 (EDGE_REACH 초 안에 닿게)
var _pin_x := 0.0  # 5단계: 먹히기 전까지 배달부가 이보다 앞으로 못 간다
## 헤드리스(smoke)에서는 제목·연습을 저절로 넘겨 경주까지 가게 한다
var auto_headless := true
var _auto_t := 0.0


func setup(g) -> void:
	game = g
	layer = LAYER
	_root = Control.new()
	_root.size = Vector2(720, 1280)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_build_title()
	_build_tutorial()
	_root.visible = false


# ================================================================ 공개 API
## 제목 화면을 띄운다 (_reset 끝에서). 기록 파일은 game.records 를 읽는다.
func show_title() -> void:
	state = "title"
	_busy = false
	_root.visible = true
	_tut.visible = false
	_title.visible = true
	_title.modulate.a = 1.0
	refresh_text()
	for b in _blockers:
		b.visible = true
	_logo.visible = true
	T.stamp_slam(_logo)
	_start_sway()
	var items: Array[Control] = [_play, _howto, _pill]
	if _ko_tag.text != "":
		items.insert(1, _ko_tag)
	var d := 0.18
	for n in items:
		n.visible = false
		var tw := T.pop_in(n, d)
		if n == _play:
			tw.finished.connect(_start_bob)
		d += 0.06


## 제목 화면 닫기 (모드 고르기·연습으로 넘어갈 때 이 모듈이 알아서 부른다).
func hide_title() -> void:
	if _bob != null and _bob.is_valid():
		_bob.kill()
	if _sway != null and _sway.is_valid():
		_sway.kill()
	_play.position.y = 900.0
	for b in _blockers:
		b.visible = false
	var tw := _title.create_tween()
	tw.tween_property(_title, "modulate:a", 0.0, T.T_CLOSE).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void:
		_title.visible = false
		_title.modulate.a = 1.0
		if state == "":
			_root.visible = false)
	if state == "title":
		state = ""


## 처음 하는 사람인가 (기록 파일 [opt] tutorial_done 이 없으면 true).
func needs_tutorial() -> bool:
	var rec: ConfigFile = game.records
	return rec == null or not bool(rec.get_value("opt", "tutorial_done", false))


## 연습 시작. 부르기 전에 game.tutorial_begin() 으로 연습 마당을 만들어 둔다 (phase = "tutorial").
func start_tutorial(first_run: bool) -> void:
	_first = first_run
	state = "tutorial"
	_root.visible = true
	_title.visible = false
	for b in _blockers:
		b.visible = false
	_tut.visible = true
	_tut.modulate.a = 1.0
	T.pop_in(_skip, 0.3)
	_enter(0)


## 언어가 바뀌면 글자를 다시 쓴다 (lang_pressed 뒤에 이 모듈이 스스로 부른다).
func refresh_text() -> void:
	if game == null:
		return
	_play.set("text", game.L("배달 시작!", "PLAY"))
	_howto.set("text", "?")
	_ko_tag.text = ""  # 부제 없음: 한국어 시작 버튼 '배달 시작!'이 이미 화면을 한국어로 만든다
	_ko_tag.visible = false
	_pill.ko = str(game.lang) == "ko"
	_pill.queue_redraw()
	_skip.set("text", game.L("건너뛰기", "SKIP"))
	_nice.text = game.L("좋아!", "NICE!")
	if state == "tutorial" and step >= 0:
		_fill_bubble()


## 마우스·smoke 처럼 GUI 를 거치지 않은 탭 (screenrace._tap 에서). true 면 먹었다.
func tap(p: Vector2) -> bool:
	if state == "title":
		if not _busy:
			if _hit(_play, p):
				_on_play()
			elif _hit(_howto, p):
				_on_howto()
			elif _hit(_pill, p):
				_on_lang()
		return true
	if state == "tutorial" and _hit(_skip, p):
		_on_skip()
		return true
	return false


# ================================================================ 제목 화면 만들기
func _build_title() -> void:
	_title = Control.new()
	_title.size = Vector2(720, 1280)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_title)
	# 터치 막기: 왼쪽 위(< 메뉴)만 tofu 에 넘기고 나머지는 이 화면이 먹는다
	for r in [Rect2(180, 0, 540, 100), Rect2(0, 100, 720, 1180)]:
		var b := Control.new()
		b.position = r.position
		b.size = r.size
		b.mouse_filter = Control.MOUSE_FILTER_STOP
		_title.add_child(b)
		_blockers.append(b)
	# 위쪽 크림 물감 번짐 (로고가 하늘 위에서도 읽히게)
	var grad := Gradient.new()
	grad.set_color(0, Color(T.CREAM, 0.94))
	grad.set_color(1, Color(T.CREAM, 0.0))
	grad.add_point(0.55, Color(T.CREAM, 0.6))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.width = 4
	gt.height = 128
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	_wash = TextureRect.new()
	_wash.texture = gt
	_wash.stretch_mode = TextureRect.STRETCH_SCALE
	_wash.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_wash.size = Vector2(720, 640)
	_wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.add_child(_wash)
	# 속도 띠 (종이 조각이 왼쪽으로 휙휙)
	_strips = _Strips.new()
	_strips.position = Vector2(0, 120)
	_strips.size = Vector2(720, 460)
	_strips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.add_child(_strips)
	# 로고
	_logo = Control.new()
	_logo.size = Vector2(620, 272)
	_logo.position = Vector2(50, 150)
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.add_child(_logo)
	var lt := T.tex("logo")
	if lt != null:
		_logo_tex = TextureRect.new()
		_logo_tex.texture = lt
		_logo_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_logo_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_logo_tex.size = _logo.size
		_logo_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_logo.add_child(_logo_tex)
	else:
		_logo_draw = _Logo.new()
		_logo_draw.size = _logo.size
		_logo_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_logo.add_child(_logo_draw)
	# 한국어 부제 꼬리표
	# 빨강은 시작 버튼에만: 부제는 칠 없는 남색 글자 + 흰 종이 테두리
	_ko_tag = T.make_label("", T.FS_BODY, T.NAVY, 8, T.WHITE)
	_ko_tag.size = Vector2(220, 50)
	_ko_tag.position = Vector2(250, 418)
	_ko_tag.rotation = deg_to_rad(-3.0)
	_title.add_child(_ko_tag)
	# 시작 버튼 (빨강 = 주 행동)
	var pb := T.PaperButton.new()
	pb.face = T.RED
	pb.font_size = 46
	pb.radius = 22.0
	pb.size = Vector2(460, 110)
	pb.position = Vector2(130, 900)
	pb.pressed.connect(_on_play)
	_title.add_child(pb)
	_play = pb
	# 하는 법: 작은 둥근 "?" (크림 = 보조)
	var hb := T.PaperButton.new()
	hb.face = T.CREAM
	hb.text_color = T.NAVY
	hb.font_size = 40
	hb.radius = 50.0
	hb.size = Vector2(100, 100)
	hb.position = Vector2(206, 1040)
	hb.pressed.connect(_on_howto)
	_title.add_child(hb)
	_howto = hb
	# 언어 알약
	_pill = _Pill.new()
	_pill.size = Vector2(100, 100)
	_pill.position = Vector2(414, 1040)
	_pill.pressed.connect(_on_lang)
	_title.add_child(_pill)


func _start_bob() -> void:
	if state != "title":
		return
	if _bob != null and _bob.is_valid():
		_bob.kill()
	_play.position.y = 900.0
	_bob = _play.create_tween().set_loops()
	_bob.tween_property(_play, "position:y", 892.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bob.tween_property(_play, "position:y", 900.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _start_sway() -> void:
	if _sway != null and _sway.is_valid():
		_sway.kill()
	var inner: Control = _logo_draw
	if _logo_tex != null:
		inner = _logo_tex
	inner.pivot_offset = inner.size * 0.5
	inner.rotation = 0.0
	_sway = inner.create_tween().set_loops()
	_sway.tween_property(inner, "rotation", deg_to_rad(-1.6), 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_sway.tween_property(inner, "rotation", deg_to_rad(1.2), 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _hit(n: Control, p: Vector2) -> bool:
	return n.visible and n.is_visible_in_tree() and n.get_global_rect().grow(8.0).has_point(p)


func _on_play() -> void:
	if state != "title" or _busy:
		return
	_busy = true
	game.play("tap")
	var tut := auto_tutorial_on_play and needs_tutorial()
	hide_title()
	if tut:
		tutorial_pressed.emit(true)
	else:
		play_pressed.emit()


func _on_howto() -> void:
	if state != "title" or _busy:
		return
	_busy = true
	game.play("tap")
	hide_title()
	tutorial_pressed.emit(false)


func _on_lang() -> void:
	if state != "title" or _busy:
		return
	lang_pressed.emit()
	game.play("tap")
	refresh_text()
	T.bump(_pill, 1.08)


# ================================================================ 연습 만들기
func _build_tutorial() -> void:
	_tut = Control.new()
	_tut.size = Vector2(720, 1280)
	_tut.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tut.visible = false
	_root.add_child(_tut)
	_guide = _Guide.new()
	_guide.size = Vector2(720, 1280)
	_guide.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tut.add_child(_guide)
	_bubble = _Bubble.new()
	_bubble.position = Vector2(70, 852)
	_bubble.size = Vector2(580, 84)
	_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tut.add_child(_bubble)
	# 건너뛰기: 집·별 모서리 아이콘과 같은 흰 종이 알약 (y 42 중심, 높이 50).
	# 누르는 칸은 손가락 크기(168x96)이고 tofu 별점 칸(x 620..720)과 겹치지 않는다.
	var sb := _SkipPill.new()
	sb.size = Vector2(168, 96)
	sb.position = Vector2(452, 0)
	sb.pressed.connect(_on_skip)
	_tut.add_child(sb)
	_skip = sb
	_nice = T.make_label("", 52, T.GREEN, 14, T.WHITE)
	_nice.size = Vector2(320, 80)
	_nice.position = Vector2(200, 560)
	_nice.rotation = deg_to_rad(-6.0)
	_nice.visible = false
	_tut.add_child(_nice)


func _enter(i: int) -> void:
	step = i
	_tt = 0.0
	_between = 0.0
	var pl = game.pl
	# 배달·던지기 단계 전에 짐이 모자라면 다시 채운다 (연습 마당: 상대·점수 없음) — 안 그러면 못 넘긴다
	if (i == 2 or i == 3) and int(pl.cargo) < 2:
		pl.cargo = 3
	_x0 = float(pl.p.x)
	_cargo0 = int(pl.cargo)
	_got0 = int(pl.got)
	_throws0 = int(pl.throws)
	_edge_x = float(game.camx) - float(game.hwv)
	_eaten = false
	_pin_x = float(pl.p.x)
	_edge_v = maxf(EDGE_V, (_pin_x - 0.6 - _edge_x) / EDGE_REACH)
	_was_g = bool(pl.grounded)
	_jumped = false
	_nice.visible = false
	_fill_bubble()
	_bubble.visible = true
	T.pop_in(_bubble)
	if i == STEP_N:
		_skip.visible = false
		game.play("bell")


func _fill_bubble() -> void:
	var ko := str(game.lang) == "ko"
	_bubble.dots = STEP_N
	_bubble.at = mini(step, STEP_N)
	match step:
		0:
			_bubble.text = "오른쪽으로 밀어 달려!" if ko else "Push right to run!"
			_bubble.icon = "icon_shoe"
		1:
			_bubble.text = "점프로 상자를 넘어!" if ko else "Jump the crate!"
			_bubble.icon = "icon_jump"
		2:
			_bubble.text = "우체통 가까이 [짐]이 초록 = 배달! 달리면서 눌러" if ko else "BOX turns green near a mailbox: tap to post on the run!"
			_bubble.icon = "icon_parcel"
		3:
			_bubble.text = "다른 곳에서 [짐] = 던지고 대시!" if ko else "Tap BOX elsewhere: throw one and DASH!"
			_bubble.icon = "icon_drop"
		4:
			_bubble.text = "왼쪽 끝에 밀리면 짐 하나를 잃어!" if ko else "Fall off the left edge = lose a box!"
			_bubble.icon = "icon_parcel"
		_:
			_bubble.text = "배달 많이 한 사람이 이긴다!" if ko else "Most deliveries wins!"
			_bubble.icon = "icon_flag"
	_bubble.queue_redraw()


func _process(dt: float) -> void:
	if game == null or state == "":
		return
	# 별점 카드(tofu, layer 9)가 떠 있으면 비켜 준다
	var rating := bool(game.get("_rating"))
	_root.visible = not rating
	if state == "title":
		_strips.queue_redraw()
		if auto_headless and not _busy and DisplayServer.get_name() == "headless":
			_auto_t += dt
			if _auto_t > 0.5:
				_auto_t = 0.0
				_on_play()
		return
	if state != "tutorial" or rating:
		return
	if auto_headless and DisplayServer.get_name() == "headless":
		_auto_t += dt
		if _auto_t > 2.0:
			_auto_t = 0.0
			_on_skip()
			return
	_tut_tick(dt)
	var kinds: Array[String] = ["stick", "jump", "drop", "drop", "edge", ""]
	_guide.kind = kinds[mini(step, STEP_N)]
	if _between > 0.0:
		_guide.kind = ""
	_guide.t += dt
	_guide.target = _target_pos()
	_guide.target_r = _target_r()
	_guide.queue_redraw()
	# 말풍선 꼬리는 가리키는 곳으로
	_bubble.tail_x = clampf(_guide.target.x - _bubble.position.x, 60.0, _bubble.size.x - 60.0)
	_bubble.tail_down = step >= 0 and step <= 3
	_bubble.tail_left = step == 4


func _tut_tick(dt: float) -> void:
	_tt += dt
	if _between > 0.0:
		_between -= dt
		if _between <= 0.0:
			_enter(step + 1)
		return
	var pl = game.pl
	var g := bool(pl.grounded)
	if step >= 0 and step < 4 and _tt > STUCK_T:
		_ok()
		return
	match step:
		0:
			if float(pl.p.x) - _x0 > RUN_GOAL:
				_ok()
		1:
			if _was_g and not g and float(pl.v.y) > 3.0:
				_jumped = true
			var cx := -1.0
			var cv = game.get("tut_crate_x")
			if cv != null:
				cx = float(cv)
			if _jumped and (cx < 0.0 or float(pl.p.x) > cx + 1.3):
				_ok()
		2:
			if int(pl.got) > _got0:
				_ok()
			else:
				if int(pl.cargo) <= 0:
					pl.cargo = 2  # 우체통 밖에서 다 던졌다: 다시 채워 준다
				if game.has_method("tut_mailbox_ahead"):
					game.tut_mailbox_ahead()  # 지나쳤으면 앞으로 옮긴다 (끝 벽에 막혀 멈추지 않게)
		3:
			if int(pl.throws) > _throws0:
				_ok()  # 던졌다 (벽에 막혀 대시가 안 나가도 던진 것으로 친다)
		4:
			_edge_tick(dt)
		_:
			if _tt > GO_T:
				_finish(false)
	_was_g = g


## 5단계: 화면이 앞으로 밀려 찢긴 끝(왼쪽 끝)이 배달부에게 다가오고, 닿으면 짐 하나를 먹는다.
## 경주와 같은 규칙: 끝 = camx - hwv, 먹힐 때는 screenrace._shove 를 쓴다.
func _edge_tick(dt: float) -> void:
	var pl = game.pl
	if _eaten:
		if _tt > EDGE_T:
			_ok()
		return
	# 배달부를 세워 둔다 (계속 밀어도 끝이 EDGE_REACH 초 안에 따라잡게)
	game.kit_move = Vector2.ZERO
	pl.mx = 0.0
	if float(pl.p.x) > _pin_x:
		pl.p.x = _pin_x
	if float(pl.v.x) > 0.0:
		pl.v.x = 0.0
	_edge_x += _edge_v * dt
	if game.has_method("tut_edge_push"):
		game.call("tut_edge_push", dt)
	else:
		# 화면을 끝 쪽으로 붙잡아 둔다 (카메라는 배달부 쪽으로 돌아가려 하므로 매 프레임)
		game.camx = maxf(float(game.camx), _edge_x + float(game.hwv))
	var left := float(game.camx) - float(game.hwv)
	if left >= float(pl.p.x) - 0.4 - 0.2:
		_eaten = true
		_tt = 0.0
		game._sfx("lost")
		if int(pl.cargo) > 0:
			game._shove(pl, left)
		else:
			game.shk = 0.4
	elif _tt > EDGE_T + 2.0:
		_ok()


func _ok() -> void:
	_between = BETWEEN_T
	T.pop_out(_bubble)
	if step == 4:
		return  # 짐을 잃은 걸 '좋아!'로 칭찬하지 않는다
	_nice.visible = true
	T.stamp_slam(_nice)
	game.play("good")


func _target_pos() -> Vector2:
	var btns: Dictionary = game._btns
	match step:
		0:
			var zone: Rect2 = game._stick_zone
			if zone.has_area():
				return game._st_home
			return Vector2(180, 1100)
		1:
			if btns.has("jump"):
				return btns["jump"].pos
			return Vector2(590, 1070)
		2, 3:
			if btns.has("drop"):
				return btns["drop"].pos
			return Vector2(440, 1150)
		4:
			return Vector2(0, 560)
	return Vector2(360, 640)


func _target_r() -> float:
	var btns: Dictionary = game._btns
	match step:
		0:
			return 100.0
		1:
			if btns.has("jump"):
				return maxf(float(btns["jump"].r), 40.0)
			return 76.0
		2, 3:
			if btns.has("drop"):
				return maxf(float(btns["drop"].r), 36.0)
			return 54.0
	return 60.0


func _on_skip() -> void:
	if state != "tutorial":
		return
	game.play("tap")
	_finish(true)


func _finish(_skipped: bool) -> void:
	if state != "tutorial":
		return
	_mark_done()
	state = ""
	step = -1
	var tw := _tut.create_tween()
	tw.tween_property(_tut, "modulate:a", 0.0, T.T_CLOSE)
	tw.tween_callback(func() -> void:
		_tut.visible = false
		_tut.modulate.a = 1.0
		if state == "":
			_root.visible = false)
	tutorial_done.emit(_first)


func _mark_done() -> void:
	var rec: ConfigFile = game.records
	if rec == null:
		return
	rec.set_value("opt", "tutorial_done", true)
	var path := REC_PATH
	var rp = game.get("RECORDS")
	if rp != null:
		path = str(rp)
	rec.save(path)


func _unhandled_input(e: InputEvent) -> void:
	if state != "title" or _busy:
		return
	if e is InputEventKey:
		var k := e as InputEventKey
		if k.pressed and not k.echo and (k.keycode == KEY_ENTER or k.keycode == KEY_SPACE or k.keycode == KEY_KP_ENTER):
			get_viewport().set_input_as_handled()
			_on_play()


# ================================================================ 그리는 조각들
## 속도 띠: 종이 조각이 오른쪽에서 왼쪽으로 휙 지나간다 (고정 8개, 할당 없음).
class _Strips extends Control:
	const TH = preload("res://g/sr_theme.gd")
	var _xs := PackedFloat32Array([80, 520, 300, 660, 180, 430, 610, 30])
	var _ys := PackedFloat32Array([20, 60, 120, 170, 250, 300, 370, 420])
	var _ls := PackedFloat32Array([120, 180, 90, 150, 200, 110, 160, 130])
	var _sp := PackedFloat32Array([520, 760, 600, 880, 680, 940, 560, 820])
	var _last := -1.0

	func _draw() -> void:
		var now := Time.get_ticks_msec() * 0.001
		var dt := 0.016 if _last < 0.0 else clampf(now - _last, 0.0, 0.05)
		_last = now
		for i in _xs.size():
			_xs[i] -= _sp[i] * dt
			if _xs[i] < -_ls[i]:
				_xs[i] = size.x + 40.0 + float(i) * 23.0
			var r := Rect2(_xs[i], _ys[i], _ls[i], 7.0 if i % 2 == 0 else 5.0)
			var c := TH.WHITE if i % 3 != 0 else TH.GOLD
			c.a = 0.75
			draw_rect(Rect2(r.position + Vector2(0, 3), r.size), Color(TH.NAVY, 0.10))
			draw_rect(r, c)


## 그림이 없을 때 그리는 종이 로고: 남색 글자, 흰 굵은 외곽선, 빨간 어긋난 그림자, 작은 소포.
class _Logo extends Control:
	const TH = preload("res://g/sr_theme.gd")

	func _draw() -> void:
		var f := TH.FONT
		var lines := ["Off the", "Screen!"]
		var sizes := [86, 104]
		var ys := [100.0, 214.0]
		for i in 2:
			var s: int = sizes[i]
			var w := f.get_string_size(lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, s).x
			var p := Vector2((size.x - w) * 0.5 - (30.0 if i == 0 else -10.0), ys[i])
			draw_string_outline(f, p + Vector2(7, 8), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, s, 22, TH.RED)
			draw_string(f, p + Vector2(7, 8), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, s, TH.RED)
			draw_string_outline(f, p, lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, s, 22, TH.WHITE)
			draw_string(f, p, lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, s, TH.NAVY)
		# 날아가는 소포 + 속도 줄
		var c := Vector2(size.x - 92.0, 58.0)
		for k in 3:
			var y := c.y - 14.0 + float(k) * 14.0
			draw_line(Vector2(c.x - 120.0 + float(k) * 16.0, y), Vector2(c.x - 46.0, y), TH.RED, 6.0, true)
		TH.draw_parcel_icon(self, c, 70.0, true)


## 골판지 받침: 위쪽은 찢긴 흰 종이 가장자리.
class _Deck extends Control:
	const TH = preload("res://g/sr_theme.gd")

	func _draw() -> void:
		var w := size.x
		TH.draw_torn_edge(self, Vector2(0, 12), Vector2(w, 12), TH.WHITE, 14.0, 7)
		draw_rect(Rect2(0, 12, w, size.y - 12), TH.WHITE)
		TH.draw_torn_edge(self, Vector2(0, 22), Vector2(w, 22), TH.KRAFT, 8.0, 11)
		draw_rect(Rect2(0, 22, w, size.y - 22), TH.KRAFT)
		TH.draw_grain(self, Rect2(0, 22, w, size.y - 22), 0.14)
		# 골판지 결 (가는 그늘 줄 몇 개)
		for i in 5:
			var y := 60.0 + float(i) * 72.0
			draw_line(Vector2(0, y), Vector2(w, y), Color(TH.KRAFT_SH, 0.25), 2.0)


## 언어 바꾸기 둥근 단추 ('?' 와 같은 크기): 바꿀 언어 하나만 쓴다.
class _Pill extends Control:
	signal pressed
	const TH = preload("res://g/sr_theme.gd")
	var ko := false
	var _down := false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_NONE
		resized.connect(func() -> void: pivot_offset = size * 0.5)

	func _gui_input(e: InputEvent) -> void:
		var is_press := false
		var is_release := false
		var pos := Vector2.ZERO
		if e is InputEventScreenTouch:
			var t := e as InputEventScreenTouch
			is_press = t.pressed
			is_release = not t.pressed
			pos = t.position
		elif e is InputEventMouseButton:
			var m := e as InputEventMouseButton
			if m.button_index != MOUSE_BUTTON_LEFT:
				return
			is_press = m.pressed
			is_release = not m.pressed
			pos = m.position
		else:
			return
		accept_event()
		if is_press and not _down:
			_down = true
			queue_redraw()
		elif is_release and _down:
			_down = false
			queue_redraw()
			if Rect2(Vector2.ZERO, size).grow(16.0).has_point(pos):
				pressed.emit()

	func _draw() -> void:
		var dy := 4.0 if _down else 0.0
		var h := size.y - 6.0
		var rad := h * 0.5
		var r := Rect2(Vector2(0, dy), Vector2(size.x, h))
		draw_style_box(_box(TH.KRAFT_SH, rad, TH.KRAFT_SH, 0), Rect2(Vector2(0, 6), Vector2(size.x, h)))
		draw_style_box(_box(TH.CREAM, rad, TH.WHITE, 4), r)
		# '?' 와 같은 크림 둥근 종이 단추: 바꿀 언어만 쓴다 (영어일 때 '한', 한국어일 때 'EN')
		TH.draw_text_center(self, "EN" if ko else "한", r.get_center(), 34 if ko else 40, TH.NAVY)

	var _cache := {}

	func _box(face: Color, radius: float, border: Color, bw: int) -> StyleBoxFlat:
		var key := "%s|%d|%s|%d" % [face.to_html(), int(radius), border.to_html(), bw]
		if _cache.has(key):
			return _cache[key]
		var sb := StyleBoxFlat.new()
		sb.bg_color = face
		sb.border_color = border
		sb.set_border_width_all(bw)
		sb.set_corner_radius_all(int(radius))
		sb.corner_detail = 8
		sb.anti_aliasing = true
		_cache[key] = sb
		return sb


## 건너뛰기 알약: 모서리 아이콘(흰 원 + 크림 속)과 같은 모양, 남색 글자. 오른쪽 끝에 붙어 그린다.
class _SkipPill extends Control:
	signal pressed
	const TH = preload("res://g/sr_theme.gd")
	const CY := 42.0
	const H := 50.0
	var text := "":
		set(v):
			text = v
			queue_redraw()
	var _down := false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_NONE
		resized.connect(func() -> void: pivot_offset = Vector2(size.x - 60.0, CY))

	func _gui_input(e: InputEvent) -> void:
		var is_press := false
		var is_release := false
		var pos := Vector2.ZERO
		if e is InputEventScreenTouch:
			var t := e as InputEventScreenTouch
			is_press = t.pressed
			is_release = not t.pressed
			pos = t.position
		elif e is InputEventMouseButton:
			var m := e as InputEventMouseButton
			if m.button_index != MOUSE_BUTTON_LEFT:
				return
			is_press = m.pressed
			is_release = not m.pressed
			pos = m.position
		else:
			return
		accept_event()
		if is_press and not _down:
			_down = true
			queue_redraw()
		elif is_release and _down:
			_down = false
			queue_redraw()
			if Rect2(Vector2.ZERO, size).grow(16.0).has_point(pos):
				pressed.emit()

	func _draw() -> void:
		var fs := 24
		var tw := TH.FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var w := clampf(tw + 40.0, H, size.x - 8.0)
		var dy := 3.0 if _down else 0.0
		var r := Rect2(Vector2(size.x - 8.0 - w, CY - H * 0.5 + dy), Vector2(w, H))
		var rad := H * 0.5
		var sh := Rect2(Vector2(r.position.x, CY - H * 0.5 + 4.0), r.size)
		draw_style_box(_box(TH.SHADOW, rad), sh)
		draw_style_box(_box(Color(TH.WHITE, 0.92), rad), r)
		draw_style_box(_box(Color(TH.CREAM, 0.92), rad - 4.0), r.grow(-4.0))
		TH.draw_text_center(self, text, r.get_center(), fs, TH.NAVY, w - 12.0)

	var _cache := {}

	func _box(face: Color, radius: float) -> StyleBoxFlat:
		var key := "%s|%d" % [face.to_html(), int(radius)]
		if _cache.has(key):
			return _cache[key]
		var sb := StyleBoxFlat.new()
		sb.bg_color = face
		sb.set_corner_radius_all(int(radius))
		sb.corner_detail = 8
		sb.anti_aliasing = true
		_cache[key] = sb
		return sb


## 연습 말풍선: 크림 종이 카드 + 꼬리 + 아이콘 + 글 두 줄 + 단계 점.
class _Bubble extends Control:
	const TH = preload("res://g/sr_theme.gd")
	var text := ""
	var icon := ""
	var dots := 4
	var at := 0
	var tail_x := 120.0
	var tail_down := true
	var tail_left := false

	## 얇은 크림 종이 띠: 작은 아이콘 + 한 줄 (단계 수는 없다: 저절로 넘어가고 건너뛰기가 있다).
	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size - Vector2(0, 8))
		TH.draw_paper_rect(self, r, Color(TH.CREAM, 0.96), TH.WHITE, 6.0, r.size.y * 0.5)
		var ic := Vector2(r.position.x + r.size.y * 0.5 + 4.0, r.get_center().y)
		var t := TH.tex(icon)
		if t != null:
			draw_texture_rect(t, Rect2(ic - Vector2(28, 28), Vector2(56, 56)), false)
		else:
			TH.draw_parcel_icon(self, ic, 34.0, true)
		var left := ic.x + 36.0
		var right := r.end.x - 24.0
		var w := right - left
		var fs := 30
		while fs > 18 and TH.FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > w:
			fs -= 1
		TH.draw_text_center(self, text, Vector2(left + w * 0.5, r.get_center().y), fs, TH.NAVY, w)


## 연습 안내: 맥박 치는 금색 고리, 종이 손가락, 화면 끝 빨간 화살표.
class _Guide extends Control:
	const TH = preload("res://g/sr_theme.gd")
	var kind := ""  # "stick" / "jump" / "drop" / "edge" / ""
	var t := 0.0
	var target := Vector2.ZERO
	var target_r := 60.0
	var _arrow := PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])

	func _draw() -> void:
		match kind:
			"stick":
				_rings(target, target_r)
				var k := fmod(t, 1.2) / 1.2
				var push := clampf(k / 0.6, 0.0, 1.0)
				var hp := target + Vector2(lerpf(0.0, 80.0, ease(push, 0.5)), 0)
				# 오른쪽 화살표 자국
				_arrow_at(target + Vector2(target_r + 30.0, 0), 1.0, TH.GOLD, 0.8 + 0.2 * sin(t * 8.0))
				_hand(hp + Vector2(6, 10), 1.0 if push > 0.0 and k < 0.85 else 0.0)
			"jump", "drop":
				_rings(target, target_r)
				var k2 := fmod(t, 0.9) / 0.9
				var press := 1.0 if k2 > 0.35 and k2 < 0.6 else 0.0
				# 짐 던지기: 손을 아래 왼쪽으로 비켜서 버튼 오른쪽 위 짐 수 배지가 보이게
				var off := Vector2(-10, 30) if kind == "drop" else Vector2(10, 14)
				_hand(target + off, press)
			"edge":
				# 왼쪽 끝 빨간 맥박 띠 + 왼쪽을 가리키는 화살표 (경기의 진짜 빨간 끝 위에)
				var a := 0.35 + 0.3 * (0.5 + 0.5 * sin(t * TAU * 2.0))
				draw_rect(Rect2(0, 80, 26, 1200), Color(TH.RED, a))
				var bx := 70.0 + 14.0 * sin(t * 7.0)
				_arrow_at(Vector2(bx, target.y), -1.0, TH.RED, 1.0)

	func _rings(c: Vector2, r: float) -> void:
		var k := fmod(t, 1.0)
		draw_arc(c, r + 8.0, 0.0, TAU, 48, TH.WHITE, 8.0, true)
		draw_arc(c, r + 8.0, 0.0, TAU, 48, TH.GOLD, 5.0, true)
		draw_arc(c, r + 10.0 + k * 34.0, 0.0, TAU, 48, Color(TH.GOLD, 1.0 - k), 5.0, true)

	## 종이 손가락 (흰 종이 + 남색 외곽선). press 1 = 눌러서 살짝 작아짐
	func _hand(tip: Vector2, press: float) -> void:
		var s := 1.0 - 0.1 * press
		var palm := tip + Vector2(30, 70) * s
		var sh := Vector2(0, 6)
		# 그림자
		_capsule(tip + sh, tip + Vector2(14, 52) * s + sh, 15.0 * s, TH.SHADOW)
		draw_circle(palm + sh, 34.0 * s, TH.SHADOW)
		# 외곽선
		_capsule(tip, tip + Vector2(14, 52) * s, 15.0 * s + 3.0, TH.NAVY)
		draw_circle(palm, 34.0 * s + 3.0, TH.NAVY)
		# 면
		_capsule(tip, tip + Vector2(14, 52) * s, 15.0 * s, TH.WHITE)
		draw_circle(palm, 34.0 * s, TH.WHITE)
		draw_circle(tip + Vector2(1, 3), 6.0 * s, TH.KRAFT.lerp(TH.WHITE, 0.5))
		if press > 0.0:
			draw_arc(tip, 22.0, 0.0, TAU, 24, Color(TH.WHITE, 0.9), 4.0, true)

	func _capsule(a: Vector2, b: Vector2, r: float, c: Color) -> void:
		draw_line(a, b, c, r * 2.0)
		draw_circle(a, r, c)
		draw_circle(b, r, c)

	## 두꺼운 화살표 (dir 1 = 오른쪽, -1 = 왼쪽), 흰 테두리
	func _arrow_at(p: Vector2, dir: float, c: Color, alpha: float) -> void:
		var pts := [Vector2(-34, -12), Vector2(4, -12), Vector2(4, -30), Vector2(40, 0), Vector2(4, 30), Vector2(4, 12), Vector2(-34, 12)]
		for i in 7:
			var v: Vector2 = pts[i]
			_arrow[i] = p + Vector2(v.x * dir * 1.18, v.y * 1.18) + Vector2(0, 5)
		draw_colored_polygon(_arrow, TH.SHADOW)
		for i in 7:
			var v: Vector2 = pts[i]
			_arrow[i] = p + Vector2(v.x * dir * 1.18, v.y * 1.18)
		draw_colored_polygon(_arrow, Color(TH.WHITE, alpha))
		for i in 7:
			var v: Vector2 = pts[i]
			_arrow[i] = p + Vector2(v.x * dir, v.y)
		draw_colored_polygon(_arrow, Color(c, alpha))
