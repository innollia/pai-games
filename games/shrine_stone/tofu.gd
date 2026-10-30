class_name Tofu
extends Node3D
## 두부게임 공통 (3D). 상자만 쓴다. 판 시간·점수·최고점·다시하기·소리·입력을 맡는다.
## 게임은 이 클래스를 extends 하고 _setup / _reset / _step(dt) / _tap(p) / _drag(p) / _lift(p) 만 쓴다.
## p는 720x1280 화면 좌표. 판마다 만드는 상자는 box()로 만들면 다시 시작할 때 저절로 지워진다.
## 액션 조작 키트(선택, _setup 에서 부른다. 안 부르면 예전 그대로): 여러 손가락 동시 터치.
##   kit_stick() = 왼쪽 아래 떠다니는 조이스틱 -> kit_move (Vector2, -1..1, y 아래가 +)
##   kit_lookpad() = 오른쪽 반(버튼 밖)을 끌면 둘러보기 -> kit_look (이번 프레임 픽셀 이동, _step 뒤 0으로)
##   kit_button(이름, 글자, 가운데, 반지름, 색) -> kit_held(이름) 누르는 중, kit_just(이름) 이번 _step 에 막 눌림
##   kit_stick·kit_lookpad 는 zone(Rect2)으로 자리를 바꿀 수 있다. 플레이 방법 상자·게임 끝 화면에서는 숨고 탭은 예전처럼 동작한다.
##   키트에 닿은 손가락은 _tap/_drag/_lift 로 안 간다. 나머지 손가락 하나는 예전처럼 간다.
## 오른쪽 위 구석(_RATE_BTN)은 "평가" 버튼이 먼저 가로챈다: 게임을 멈추고 별 카드를 띄운다. 게임은 거기에 입력을 두지 않는다.

signal back

const INK := Color("3a2a1a")
const ME := Color("3b5bdb")
const GOOD := Color("37b24d")
const BAD := Color("f03e3e")
const A := Color("ff922b")
const B := Color("4dabf7")
const C := Color("cc5de8")
const D := Color("fcc419")
const SOFT := Color("efe1c4")
const WHITE := Color("ffffff")
const SAVE := "user://speed_tofu.json"

var id := "x"
var time_limit := 0.0  # 0이면 end()를 부를 때까지 계속
var howto := ""  # 게임에 처음 들어갈 때 한 번 보여 줄 플레이 방법 (_setup 에서 정한다)
var score := 0
var best := 0
var t := 0.0
var over := false
var wait := 0.0
var held := false
var cam: Camera3D
var world: Node3D
var _score_l: Label
var _time_l: Label
var _msg_l: Label
var _over_l: Label
var _bar_bg: ColorRect
var _bar: ColorRect
var _msg_t := 0.0
var _howto_box: Control  # 보이는 동안 시간·_step 멈춤, 탭하면 사라진다
var _font: Font = preload("res://fonts/Pretendard-Bold.otf")
var _unit := BoxMesh.new()
var _mats := {}
var _tones := {}
var _players: Array[AudioStreamPlayer] = []
var _np := 0
# 액션 조작 키트
const _MOUSE_ID := -100  # 마우스(PC, smoke)는 이 손가락 번호로 친다
const _STICK_R := 110.0
var kit_move := Vector2.ZERO
var kit_look := Vector2.ZERO
var _kit := false
var _pad: Control
var _stick_zone := Rect2()
var _stick_on := false
var _st_home := Vector2.ZERO
var _st_o := Vector2.ZERO
var _look_zone := Rect2()
var _btns := {}  # 이름 -> {label, pos, r, color, down}
var _justs := {}
var _own := {}  # 손가락 번호 -> "game" / "stick" / "look" / 버튼 이름
var _last := {}
# 게임 끝 화면 평가 (별 5개 + 한마디). 웹(JavaScriptBridge)에서만 보내고, 아니면 겉모습만 바뀐다.
static var VER: String = _read_ver()  # 빌드 버전 (res://ver.txt, build.ps1 이 쓴다)
const _STAR_RECT := Rect2(100, 860, 520, 120)
const _WORD_RECT := Rect2(200, 1000, 320, 90)
var _rate_box: Control
var _stars: Array[Label] = []
var _rate_status: Label
var _rated := 0  # 이번 판에 보낸 별 수 (0이면 아직)
var _rate_text := ""
var _rate_wait := false  # 보내고 window.tofuLast 를 기다리는 중
# 언제든 평가: 게임 중 오른쪽 위 "평가" -> 멈추고 같은 별 카드를 띄운다 (끝 화면이 없는 게임도 평가)
var gver := 1  # 게임 버전 (main.gd GAME_VER). 평가 ver = "v<gver> <VER>"
const _RATE_BTN := Rect2(620, 0, 100, 100)
const _CLOSE_RECT := Rect2(240, 1170, 240, 80)
var _rating := false  # 언제든 평가 카드가 떠 있는 동안 시간·_step 멈춤
var _rate_btn_l: Label
var _rate_extra: Array[Control] = []  # 어둡게·제목·닫기 (언제든 평가 때만 보임)


class _Pad extends Control:
	var k: Tofu

	func _draw() -> void:
		k._kit_draw(self)


func _ready() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("d8eeff")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.WHITE
	env.ambient_light_energy = 0.6
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_energy = 0.9
	add_child(sun)
	cam = Camera3D.new()
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	add_child(cam)
	cam.current = true
	var hud := CanvasLayer.new()
	add_child(hud)
	_bar_bg = ColorRect.new()
	_bar_bg.color = WHITE
	_bar_bg.position = Vector2(60, 200)
	_bar_bg.size = Vector2(600, 28)
	_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(_bar_bg)
	_bar = ColorRect.new()
	_bar.size = Vector2(600, 28)
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(_bar)
	_score_l = _label(hud, 88, 20, 120)
	_time_l = _label(hud, 44, 120, 70)
	_msg_l = _label(hud, 72, 520, 120)
	_over_l = _label(hud, 72, 420, 400)
	var back_l := _label(hud, 34, 20, 60)
	back_l.text = "< 처음부터"
	back_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	back_l.position.x = 24
	_rate_btn_l = _label(hud, 34, 20, 60)
	_rate_btn_l.text = "평가"
	_rate_btn_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_rate_btn_l.size.x = 696
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_rate_box = _rate_card()
	best = int(_load().get(id, 0))
	_setup()
	restart()
	if howto != "":
		_howto_box = _howto_card()


func _label(parent: Node, size: int, y: float, h: float) -> Label:
	var s := LabelSettings.new()
	s.font = _font
	s.font_size = size
	s.font_color = INK
	s.outline_size = 14
	s.outline_color = WHITE
	var l := Label.new()
	l.label_settings = s
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(0, y)
	l.size = Vector2(720, h)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


## 가운데 흰 상자에 플레이 방법 (게임마다 다른 CanvasLayer 보다 위)
func _howto_card() -> Control:
	var top := CanvasLayer.new()
	top.layer = 10
	add_child(top)
	var card := ColorRect.new()
	card.color = WHITE
	card.position = Vector2(30, 260)
	card.size = Vector2(660, 780)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(card)
	var s := LabelSettings.new()
	s.font = _font
	s.font_size = 40
	s.font_color = INK
	s.line_spacing = 8
	var l := Label.new()
	l.label_settings = s
	l.text = howto
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.position = Vector2(30, 30)
	l.size = Vector2(600, 630)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(l)
	var go := l.duplicate() as Label
	go.label_settings = s.duplicate()
	go.label_settings.font_color = ME
	go.text = "탭해서 시작"
	go.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go.position = Vector2(0, 680)
	go.size = Vector2(660, 70)
	card.add_child(go)
	return card


## 게임 끝 화면 아래 별 5개와 "한마디" (게임마다 다른 CanvasLayer 보다 위, 플레이 방법 상자보다 아래)
func _rate_card() -> Control:
	var top := CanvasLayer.new()
	top.layer = 9
	add_child(top)
	var card := Control.new()
	card.size = Vector2(720, 1280)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.visible = false
	top.add_child(card)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.45)
	dim.size = Vector2(720, 1280)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(dim)
	var panel := ColorRect.new()
	panel.color = Color(1, 1, 1, 0.85)
	panel.position = Vector2(60, 720)
	panel.size = Vector2(600, 550)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(panel)
	var title := _label(card, 52, 750, 80)
	title.text = "이 게임 어때요?"
	var shut := ColorRect.new()
	shut.color = SOFT
	shut.position = _CLOSE_RECT.position
	shut.size = _CLOSE_RECT.size
	shut.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(shut)
	var shut_l := _label(shut, 40, 0, _CLOSE_RECT.size.y)
	shut_l.text = "닫기"
	shut_l.size.x = _CLOSE_RECT.size.x
	shut_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_rate_extra = [dim, panel, title, shut]
	for c in _rate_extra:
		c.visible = false
	var s := LabelSettings.new()
	s.font = _font
	s.font_size = 84
	s.font_color = SOFT
	s.outline_size = 10
	s.outline_color = INK
	for i in 5:
		var l := Label.new()
		l.label_settings = s.duplicate()
		l.text = "★"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.position = Vector2(_STAR_RECT.position.x + 4 + i * 104, _STAR_RECT.position.y)
		l.size = Vector2(104, _STAR_RECT.size.y)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(l)
		_stars.append(l)
	var btn := ColorRect.new()
	btn.color = WHITE
	btn.position = _WORD_RECT.position
	btn.size = _WORD_RECT.size
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(btn)
	var bl := Label.new()
	var bs := LabelSettings.new()
	bs.font = _font
	bs.font_size = 40
	bs.font_color = ME
	bl.label_settings = bs
	bl.text = "한마디"
	bl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bl.size = _WORD_RECT.size
	bl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(bl)
	_rate_status = _label(card, 36, 1100, 60)
	return card


## 별·한마디 영역 탭이면 처리하고 true (재시작 탭으로 안 간다)
func _rate_hit(p: Vector2) -> bool:
	if _rating:
		if _STAR_RECT.has_point(p):
			if _rated == 0:
				_rated = clampi(int((p.x - _STAR_RECT.position.x) / (_STAR_RECT.size.x / 5.0)) + 1, 1, 5)
				play("tap")
				_rate_send()
				_rate_close()
		elif _WORD_RECT.has_point(p):
			play("tap")
			var w := _js_ask("이 게임에 한마디 (선택)")
			if w.strip_edges() != "":
				_rate_text = w.strip_edges().left(500)
				_rate_status.text = "별도 탭해 주세요"
		elif _CLOSE_RECT.has_point(p):
			play("tap")
			_rate_close()
		return true  # 카드가 떠 있는 동안 다른 탭은 게임으로 안 간다
	if not over or wait > 0.0:
		return false
	if _STAR_RECT.has_point(p):
		if _rated == 0:
			_rated = clampi(int((p.x - _STAR_RECT.position.x) / (_STAR_RECT.size.x / 5.0)) + 1, 1, 5)
			play("tap")
			_rate_send()
		return true
	if _WORD_RECT.has_point(p):
		play("tap")
		var s := _js_ask("이 게임에 한마디 (선택)")
		if s.strip_edges() != "":
			_rate_text = s.strip_edges().left(500)
			if _rated > 0:
				_rate_send()  # 별은 이미 보냈으니 같은 별 수로 글만 한 건 더
			else:
				_rate_status.text = "별도 탭해 주세요"
		return true
	return false


func _rate_send() -> void:
	for i in 5:
		_stars[i].label_settings.font_color = D if i < _rated else SOFT
	if not OS.has_feature("web"):
		_rate_say("고마워요!")
		return
	var js := "window.tofuRate && window.tofuRate(%s, %s, %d, %s, %d)" % [
		JSON.stringify(id), JSON.stringify(("v%d %s" % [gver, VER]).left(40)), _rated, JSON.stringify(_rate_text), score]
	JavaScriptBridge.eval(js, true)
	_rate_wait = true
	_rate_say("보내는 중")


## 카드에 쓰고, 언제든 평가로 카드를 이미 닫았으면 가운데 메시지로 잠깐 보인다
func _rate_say(s: String) -> void:
	_rate_status.text = s
	if not over and not _rating:
		_msg_l.text = s
		_msg_t = 1.2


## 언제든 평가 카드 열기: 게임을 멈추고(_step 안 돎) 별·한마디·닫기
func _rate_open() -> void:
	_rating = true
	held = false
	_kit_clear()
	_rated = 0
	_rate_text = ""
	_rate_status.text = ""
	for l in _stars:
		l.label_settings.font_color = SOFT
	for c in _rate_extra:
		c.visible = true
	_rate_box.visible = true
	play("tap")


func _rate_close() -> void:
	var was := _rating
	_rating = false
	for c in _rate_extra:
		c.visible = false
	_rate_box.visible = over
	if was and _rated > 0:
		_rate_say(_rate_status.text)


## 매 프레임: 보낸 결과(window.tofuLast)를 읽는다
func _rate_poll() -> void:
	if not _rate_wait:
		return
	var r: Variant = JavaScriptBridge.eval("window.tofuLast", true)
	if r == "ok":
		_rate_wait = false
		_rate_say("고마워요!")
	elif r == "fail":
		_rate_wait = false
		_rate_say("저장 안 됨")


## 웹이면 window.prompt, 아니면 ""
func _js_ask(msg: String) -> String:
	if not OS.has_feature("web"):
		return ""
	var r: Variant = JavaScriptBridge.eval("window.tofuAsk ? window.tofuAsk(%s) : ''" % JSON.stringify(msg), true)
	return str(r) if r != null else ""


static func _read_ver() -> String:
	if FileAccess.file_exists("res://ver.txt"):
		var f := FileAccess.open("res://ver.txt", FileAccess.READ)
		if f:
			var v := f.get_as_text().strip_edges()
			if v != "":
				return v.left(40)
	return "dev"


func restart() -> void:
	if world:
		world.queue_free()
	world = Node3D.new()
	add_child(world)
	score = 0
	over = false
	wait = 0.0
	held = false
	t = time_limit
	_bar_bg.visible = false
	_msg_t = 0.0
	_rating = false
	for c in _rate_extra:
		c.visible = false
	_rate_box.visible = false
	_kit_clear()
	_reset()


func end() -> void:
	if over:
		return
	over = true
	wait = 0.7
	_rating = false
	for c in _rate_extra:
		c.visible = false
	_rated = 0
	_rate_text = ""
	_rate_wait = false
	_rate_status.text = ""
	for l in _stars:
		l.label_settings.font_color = SOFT
	_rate_box.visible = true
	_kit_clear()
	if score > best:
		best = score
		var d := _load()
		d[id] = best
		var f := FileAccess.open(SAVE, FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify(d))
	play("win" if time_limit > 0.0 else "bad")


func _process(dt: float) -> void:
	if _howto_box and _howto_box.visible:
		_score_l.text = str(score)
		_time_l.visible = time_limit > 0.0
		_time_l.text = str(ceili(t))
		_rate_btn_l.visible = false
		_kit_frame()
		return
	_rate_btn_l.visible = not over and not _rating
	if _rating:  # 언제든 평가 카드: 시간·_step 멈춤
		_msg_l.visible = false
		_rate_poll()
		_kit_frame()
		return
	if over:
		wait -= dt
	else:
		if time_limit > 0.0:
			t -= dt
			if t <= 0.0:
				t = 0.0
				end()
		if not over:
			_step(dt)
	_msg_t -= dt
	_msg_l.visible = _msg_t > 0.0
	_score_l.text = str(score)
	_time_l.visible = time_limit > 0.0
	_time_l.text = str(ceili(t))
	_over_l.visible = over
	if over:
		_over_l.text = "%d\n최고 %d%s" % [score, best, "\n탭해서 다시" if wait <= 0.0 else ""]
	_rate_poll()
	_kit_frame()


func _unhandled_input(event: InputEvent) -> void:
	if _kit:
		_kit_input(event)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var p: Vector2 = event.position
		if event.pressed:
			if p.x < 180.0 and p.y < 100.0:
				back.emit()
				return
			if _howto_box and _howto_box.visible:
				_howto_box.visible = false
				play("tap")
				return
			if _rating:
				_rate_hit(p)
				return
			if not over and _RATE_BTN.has_point(p):
				_rate_open()
				return
			if over:
				if _rate_hit(p):
					return
				if wait <= 0.0:
					restart()
					play("tap")
				return
			held = true
			_tap(p)
		elif held:
			held = false
			if not over:
				_lift(p)
	elif event is InputEventMouseMotion and held and not over:
		_drag(event.position)


# ---- 게임이 덮어쓰는 함수 ----
func _setup() -> void:
	pass


func _reset() -> void:
	pass


func _step(_dt: float) -> void:
	pass


func _tap(_p: Vector2) -> void:
	pass


func _drag(_p: Vector2) -> void:
	pass


func _lift(_p: Vector2) -> void:
	pass


# ---- 액션 조작 키트 (선택) ----
## 떠다니는 조이스틱. zone 안 아무 데나 누르면 거기가 가운데가 된다.
func kit_stick(zone := Rect2(0, 640, 360, 640)) -> void:
	_kit_on()
	_stick_zone = zone
	_st_home = Vector2(zone.get_center().x, zone.end.y - 200.0)


## zone 을 끌면 look 에 픽셀 이동이 쌓인다 (버튼·조이스틱이 먼저)
func kit_lookpad(zone := Rect2(360, 100, 360, 1180)) -> void:
	_kit_on()
	_look_zone = zone


func kit_button(name: String, label: String, pos: Vector2, radius := 80.0, color := A) -> void:
	_kit_on()
	_btns[name] = {"label": label, "pos": pos, "r": radius, "color": color, "down": false}


func kit_held(name: String) -> bool:
	return _btns.has(name) and _btns[name].down


func kit_just(name: String) -> bool:
	return _justs.has(name)


func _kit_on() -> void:
	if _kit:
		return
	_kit = true
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var pad := _Pad.new()
	pad.k = self
	pad.size = Vector2(720, 1280)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(pad)
	_pad = pad


func _kit_clear() -> void:
	_own.clear()
	_last.clear()
	_justs.clear()
	_stick_on = false
	kit_move = Vector2.ZERO
	kit_look = Vector2.ZERO
	for n in _btns:
		_btns[n].down = false


## 프레임 끝: look·just 비우고 다시 그린다
func _kit_frame() -> void:
	if not _kit:
		return
	kit_look = Vector2.ZERO
	_justs.clear()
	_pad.visible = not over and not _rating and not (_howto_box and _howto_box.visible)
	_pad.queue_redraw()


func _kit_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_finger(event.index, event.position, 1 if event.pressed and not event.canceled else -1)
	elif event is InputEventScreenDrag:
		_finger(event.index, event.position, 0)
	elif event.device == InputEvent.DEVICE_ID_EMULATION:
		return  # 터치가 흉내 낸 마우스는 위에서 이미 받았다
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_finger(_MOUSE_ID, event.position, 1 if event.pressed else -1)
	elif event is InputEventMouseMotion:
		_finger(_MOUSE_ID, event.position, 0)


## kind 1 누름, 0 끌기, -1 뗌
func _finger(id: int, p: Vector2, kind: int) -> void:
	if kind == 1:
		if p.x < 180.0 and p.y < 100.0:
			back.emit()
			return
		if _howto_box and _howto_box.visible:
			_howto_box.visible = false
			play("tap")
			return
		if _rating:
			_rate_hit(p)
			return
		if not over and _RATE_BTN.has_point(p):
			_rate_open()
			return
		if over:
			if _rate_hit(p):
				return
			if wait <= 0.0:
				restart()
				play("tap")
			return
		var what := _kit_hit(p)
		if what == "":
			if held:
				return
			held = true
			_own[id] = "game"
			_tap(p)
			return
		_own[id] = what
		_last[id] = p
		if what == "stick":
			_stick_on = true
			_st_o = p
			kit_move = Vector2.ZERO
		elif what.begins_with("b:"):
			var n := what.substr(2)
			_btns[n].down = true
			_justs[n] = true
		return
	if not _own.has(id):
		return
	var who: String = _own[id]
	if kind == 0:
		if who == "game":
			if not over:
				_drag(p)
		elif who == "stick":
			kit_move = (p - _st_o).limit_length(_STICK_R) / _STICK_R
		elif who == "look":
			kit_look += p - _last[id]
		_last[id] = p
		return
	_own.erase(id)
	_last.erase(id)
	if who == "game":
		held = false
		if not over:
			_lift(p)
	elif who == "stick":
		_stick_on = false
		kit_move = Vector2.ZERO
	elif who.begins_with("b:"):
		_btns[who.substr(2)].down = false


func _kit_hit(p: Vector2) -> String:
	for n in _btns:
		var b: Dictionary = _btns[n]
		if p.distance_to(b.pos) < b.r * 1.15:
			return "b:" + n
	if _stick_zone.has_area() and _stick_zone.has_point(p) and not _stick_on:
		return "stick"
	if _look_zone.has_area() and _look_zone.has_point(p):
		return "look"
	return ""


func _kit_draw(c: Control) -> void:
	if _stick_zone.has_area():
		var o := _st_o if _stick_on else _st_home
		c.draw_circle(o, _STICK_R, Color(1, 1, 1, 0.45))
		c.draw_arc(o, _STICK_R, 0.0, TAU, 48, ME, 6.0)
		c.draw_circle(o + kit_move * _STICK_R, 48.0, ME)
	for n in _btns:
		var b: Dictionary = _btns[n]
		var r: float = b.r * (0.92 if b.down else 1.0)
		var col: Color = b.color
		c.draw_circle(b.pos, r, col.lightened(0.35) if b.down else col)
		c.draw_arc(b.pos, r, 0.0, TAU, 48, WHITE, 6.0)
		var fs := int(clampf(b.r * 0.42, 22.0, 44.0))
		c.draw_string(_font, b.pos + Vector2(-r, fs * 0.35), b.label, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, WHITE)


# ---- 도구 ----
## 가운데가 pos, 크기 size 인 상자. parent 를 안 주면 판(world)에 붙는다.
func box(pos: Vector3, size: Vector3, color: Color, parent: Node3D = null) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.mesh = _unit
	m.material_override = mat(color)
	m.position = pos
	m.scale = size
	(parent if parent else world).add_child(m)
	return m


func mat(color: Color) -> StandardMaterial3D:
	var k := color.to_html()
	if not _mats.has(k):
		var s := StandardMaterial3D.new()
		s.albedo_color = color
		s.next_pass = OUTLINE
		_mats[k] = s
	return _mats[k]


## 모든 상자에 붙는 진한 외곽선: 상자를 모서리 방향으로 조금 키운 뒷면만 그린다.
## 축마다 크기로 나눠 늘어난 상자도 두께가 같고, 멀수록 두꺼워져 화면에서 굵기가 비슷하다.
static var OUTLINE := _outline()


static func _outline() -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;
uniform vec4 ink : source_color = vec4(0.227, 0.165, 0.102, 1.0);
void vertex() {
	vec3 sc = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float d = distance(wp, (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz);
	float th = clamp(d * 0.006, 0.015, 0.6);
	VERTEX += sign(VERTEX) * th / max(sc, vec3(0.0001));
}
void fragment() {
	ALBEDO = ink.rgb;
}
"""
	var m := ShaderMaterial.new()
	m.shader = sh
	return m


## 화면 점 p 아래의 높이 y 평면 위 점
func ground(p: Vector2, y := 0.0) -> Vector3:
	var o := cam.project_ray_origin(p)
	var n := cam.project_ray_normal(p)
	if absf(n.y) < 0.0001:
		return o
	return o + n * ((y - o.y) / n.y)


## 화면 점 p 아래의 깊이 z 평면 위 점 (정면 카메라용)
func on_z(p: Vector2, z := 0.0) -> Vector3:
	var o := cam.project_ray_origin(p)
	var n := cam.project_ray_normal(p)
	if absf(n.z) < 0.0001:
		return o
	return o + n * ((z - o.z) / n.z)


## 점수 아래 막대. 매 프레임 부르면 보이고, 판을 다시 시작하면 숨는다.
func gauge(frac: float, color: Color) -> void:
	_bar_bg.visible = true
	_bar.size.x = 600.0 * clampf(frac, 0.0, 1.0)
	_bar.color = color


## 화면 가운데 짧은 글자
func msg(s: String, dur := 0.6) -> void:
	_msg_l.text = s
	_msg_t = dur


func beep(freq: float, dur := 0.08, to := 0.0, vol := 0.2) -> void:
	var k := "%d_%d_%d_%d" % [int(freq), int(dur * 1000.0), int(to), int(vol * 100.0)]
	if not _tones.has(k):
		_tones[k] = _tone(freq, dur, to, vol)
	var p := _players[_np]
	_np = (_np + 1) % _players.size()
	p.stream = _tones[k]
	p.play()


func play(name: String) -> void:
	match name:
		"tap": beep(520.0, 0.08, 0.0, 0.18)
		"good": beep(880.0, 0.12, 1320.0, 0.3)
		"bad": beep(220.0, 0.3, 90.0, 0.3)
		"win": beep(660.0, 0.45, 1320.0, 0.3)


func _tone(freq: float, dur: float, freq_to: float, vol: float) -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase := 0.0
	for i in n:
		var k := float(i) / float(n)
		var f := freq if freq_to <= 0.0 else lerpf(freq, freq_to, k)
		phase += TAU * f / rate
		var v := signf(sin(phase)) * 0.5 + sin(phase) * 0.5
		v *= vol * (1.0 - k)
		data.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 32767.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = data
	return w


func _load() -> Dictionary:
	if not FileAccess.file_exists(SAVE):
		return {}
	var f := FileAccess.open(SAVE, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Dictionary else {}
