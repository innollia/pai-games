extends Node2D
## 여기가 게임이다. AI는 이 파일(과 새 씬/에셋)만 고친다. 좌표는 720x1280, 왼쪽 위가 (0,0).
## 예제: 30초 동안 떠오르는 동그라미 터뜨리기. 통째로 바꿔도 된다.
## 입력은 마우스 왼쪽 클릭 이벤트만 쓴다(터치는 엔진이 마우스로 바꿔 준다. 터치 이벤트까지 받으면 두 번 처리된다).

const W := 720.0
const H := 1280.0
const BG := Color(1.0, 0.956863, 0.839216)
const INK := Color(0.227451, 0.164706, 0.101961)
const COLORS: Array[Color] = [Color("ff6b6b"), Color("4dabf7"), Color("51cf66"), Color("ffa94d"), Color("b197fc")]
const SAVE_PATH := "user://save.json"

var font: Font = preload("res://fonts/Pretendard-Bold.otf")
var started := false
var over := false
var t_left := 30.0
var score := 0
var best := 0
var gap := 0.0
var dots: Array[Dictionary] = []
var sfx: Dictionary = {}
var players: Array[AudioStreamPlayer] = []
var next_player := 0


func _ready() -> void:
	randomize()
	for i in 4:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)
	sfx["tap"] = _tone(520.0, 0.08, 0.0, 0.18)
	sfx["good"] = _tone(880.0, 0.12, 0.0, 0.3)
	sfx["bad"] = _tone(220.0, 0.25, 90.0, 0.25)
	sfx["win"] = _tone(784.0, 0.4, 1047.0, 0.3)
	best = int(_load().get("best", 0))


func _notification(what: int) -> void:
	# 탭이 가려지면 멈추고 소리를 끈다
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		get_tree().paused = true
		AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		get_tree().paused = false
		AudioServer.set_bus_mute(0, false)


func _process(delta: float) -> void:
	if started and not over:
		t_left -= delta
		if t_left <= 0.0:
			t_left = 0.0
			over = true
			if score > best:
				best = score
				_save({"best": best})
			_play("win")
		gap -= delta
		if gap <= 0.0 and dots.size() < 8:
			gap = 0.55
			dots.append({"x": randf_range(120.0, 600.0), "y": H + 90.0, "r": randf_range(70.0, 100.0), "v": randf_range(150.0, 270.0), "c": COLORS[randi() % COLORS.size()]})
		for i in range(dots.size() - 1, -1, -1):
			dots[i]["y"] = float(dots[i]["y"]) - float(dots[i]["v"]) * delta
			if float(dots[i]["y"]) < -120.0:
				dots.remove_at(i)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_tap(event.position)


func _tap(pos: Vector2) -> void:
	if not started:
		started = true
		_play("tap")
		return
	if over:
		over = false
		t_left = 30.0
		score = 0
		gap = 0.0
		dots.clear()
		_play("tap")
		return
	for i in range(dots.size() - 1, -1, -1):
		var d := dots[i]
		var r := float(d["r"]) + 24.0  # 손가락 여유
		if pos.distance_squared_to(Vector2(float(d["x"]), float(d["y"]))) <= r * r:
			dots.remove_at(i)
			score += 1
			_play("good")
			return
	_play("bad")


func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), BG)
	if not started:
		_text("탭해서 시작", Vector2(W / 2.0, H / 2.0), 72)
		return
	for d in dots:
		draw_circle(Vector2(float(d["x"]), float(d["y"])), float(d["r"]), d["c"])
	_text(str(score), Vector2(W / 2.0, 110.0), 96)
	_text(str(ceili(t_left)), Vector2(W / 2.0, 190.0), 48)
	if over:
		_text(str(score), Vector2(W / 2.0, 560.0), 120)
		_text("최고 %d" % best, Vector2(W / 2.0, 680.0), 56)
		_text("탭해서 다시", Vector2(W / 2.0, 800.0), 56)


func _text(s: String, center: Vector2, size: int) -> void:
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, Vector2(center.x - w / 2.0, center.y + size * 0.35), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, INK)


## 효과음: 파일 없이 코드로 만든 짧은 톤. freq_to 가 0 이면 높이 고정, 아니면 그 주파수로 미끄러진다.
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


func _play(name: String) -> void:
	var p := players[next_player]
	next_player = (next_player + 1) % players.size()
	p.stream = sfx[name]
	p.play()


func _save(d: Dictionary) -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))


func _load() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed if parsed is Dictionary else {}
