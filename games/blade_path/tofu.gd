class_name Tofu
extends Node3D
## 일격의 길 공용 틀 (3D, speed_tofu 두부 틀에서 이 게임이 쓰는 것만 남김).
## 게임은 이 클래스를 extends 하고 _setup / _reset / _step(dt) / _tap(p) / _drag(p) / _lift(p) 만 쓴다.
## p는 720x1280 화면 좌표. 판마다 만드는 상자는 box()로 만들면 다시 시작할 때 저절로 지워진다.
## kit_button(이름, 글자, 가운데, 반지름, 색) = 여러 손가락 동시 터치 버튼 -> _btn_down / _btn_drag / _btn_up.
## 버튼에 닿은 손가락은 _tap/_drag/_lift 로 안 간다. 나머지 손가락 하나는 예전처럼 간다.
## 왼쪽 위 구석(< 처음부터)을 누르면 back 신호.

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

var id := "x"
var score := 0
var held := false
var cam: Camera3D
var world: Node3D
var _score_l: Label
var _msg_l: Label
var _bar_bg: ColorRect
var _bar: ColorRect
var _msg_t := 0.0
var _font: Font = preload("res://fonts/Pretendard-Bold.otf")
var _unit := BoxMesh.new()
var _mats := {}

const _MOUSE_ID := -100  # 마우스(PC)는 이 손가락 번호로 친다
var _pad: Control
var _btns := {}  # 이름 -> {label, pos, r, color, down}
var _own := {}  # 손가락 번호 -> "game" / 버튼 이름


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
	_msg_l = _label(hud, 72, 520, 120)
	var back_l := _label(hud, 34, 20, 60)
	back_l.text = "< 처음부터"
	back_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	back_l.position.x = 24
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var pad := _Pad.new()
	pad.k = self
	pad.size = Vector2(720, 1280)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(pad)
	_pad = pad
	_setup()
	restart()


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


func restart() -> void:
	if world:
		world.queue_free()
	world = Node3D.new()
	add_child(world)
	score = 0
	held = false
	_bar_bg.visible = false
	_msg_t = 0.0
	_own.clear()
	_reset()


func _process(dt: float) -> void:
	_step(dt)
	_msg_t -= dt
	_msg_l.visible = _msg_t > 0.0
	_score_l.text = str(score)
	_pad.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
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


## 버튼을 누름 / 누른 채 끄는 중 / 손을 뗌
func _btn_down(_n: String, _p: Vector2) -> void:
	pass


func _btn_drag(_n: String, _p: Vector2) -> void:
	pass


func _btn_up(_n: String, _p: Vector2) -> void:
	pass


func _lift(_p: Vector2) -> void:
	pass


# ---- 여러 손가락 버튼 ----
func kit_button(name: String, label: String, pos: Vector2, radius := 80.0, color := A) -> void:
	_btns[name] = {"label": label, "pos": pos, "r": radius, "color": color, "down": false}


## kind 1 누름, 0 끌기, -1 뗌
func _finger(id: int, p: Vector2, kind: int) -> void:
	if kind == 1:
		if p.x < 180.0 and p.y < 100.0:
			back.emit()
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
		_btns[what].down = true
		_btns[what].at = p
		_btns[what].t0 = Time.get_ticks_msec()
		_btn_down(what, p)
		return
	if not _own.has(id):
		return
	var who: String = _own[id]
	if kind == 0:
		if who == "game":
			_drag(p)
		elif _btns.has(who):
			_btn_drag(who, p)
		return
	_own.erase(id)
	if who == "game":
		held = false
		_lift(p)
	elif _btns.has(who):
		_btns[who].down = false
		_btns[who].t1 = Time.get_ticks_msec()
		_btn_up(who, p)


func _kit_hit(p: Vector2) -> String:
	for n in _btns:
		var b: Dictionary = _btns[n]
		if p.distance_to(b.pos) < b.r * 1.15:
			return n
	return ""


func _kit_draw(c: Control) -> void:
	var now := Time.get_ticks_msec()
	for n in _btns:
		var b: Dictionary = _btns[n]
		# 누름 애니메이션: 눌리면 쑥 들어가고, 떼면 살짝 튀어 올랐다 제자리. 누른 순간 흰 고리가 퍼진다.
		var s := 1.0
		if b.down:
			s = lerpf(1.0, 0.84, clampf((now - int(b.get("t0", 0))) / 60.0, 0.0, 1.0))
		else:
			var u := (now - int(b.get("t1", -100000))) / 220.0
			if u < 1.0:
				s = 1.0 + sin(u * PI) * 0.1 * (1.0 - u) - 0.16 * maxf(0.0, 1.0 - u * 4.0)
		var r: float = b.r * s
		var col: Color = b.color
		var ring := (now - int(b.get("t0", -100000))) / 260.0
		if ring < 1.0:
			c.draw_arc(b.pos, b.r * (1.0 + ring * 0.45), 0.0, TAU, 48, Color(1, 1, 1, 0.8 * (1.0 - ring)), 10.0 * (1.0 - ring) + 2.0)
		c.draw_circle(b.pos, r, col.darkened(0.15) if b.down else col)
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


## 점수 아래 막대. 매 프레임 부르면 보이고, 판을 다시 시작하면 숨는다.
func gauge(frac: float, color: Color) -> void:
	_bar_bg.visible = true
	_bar.size.x = 600.0 * clampf(frac, 0.0, 1.0)
	_bar.color = color


## 화면 가운데 짧은 글자
func msg(s: String, dur := 0.6) -> void:
	_msg_l.text = s
	_msg_t = dur
