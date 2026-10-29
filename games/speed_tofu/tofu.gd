class_name Tofu
extends Node3D
## 두부게임 공통 (3D). 상자만 쓴다. 판 시간·점수·최고점·다시하기·소리·입력을 맡는다.
## 게임은 이 클래스를 extends 하고 _setup / _reset / _step(dt) / _tap(p) / _drag(p) / _lift(p) 만 쓴다.
## p는 720x1280 화면 좌표. 판마다 만드는 상자는 box()로 만들면 다시 시작할 때 저절로 지워진다.

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
var _font: Font = preload("res://fonts/Pretendard-Bold.otf")
var _unit := BoxMesh.new()
var _mats := {}
var _tones := {}
var _players: Array[AudioStreamPlayer] = []
var _np := 0


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
	back_l.text = "< 메뉴"
	back_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	back_l.position.x = 24
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	best = int(_load().get(id, 0))
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
	over = false
	wait = 0.0
	held = false
	t = time_limit
	_bar_bg.visible = false
	_msg_t = 0.0
	_reset()


func end() -> void:
	if over:
		return
	over = true
	wait = 0.7
	if score > best:
		best = score
		var d := _load()
		d[id] = best
		var f := FileAccess.open(SAVE, FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify(d))
	play("win" if time_limit > 0.0 else "bad")


func _process(dt: float) -> void:
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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var p: Vector2 = event.position
		if event.pressed:
			if p.x < 180.0 and p.y < 100.0:
				back.emit()
				return
			if over:
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
		_mats[k] = s
	return _mats[k]


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
