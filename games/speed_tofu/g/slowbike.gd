extends Tofu
## 느린 자전거 경주: 누르고 있으면 페달(조금씩 빨라짐), 떼면 느려진다. 누른 채 좌우로 끌어 기운 자전거를 세운다. 느릴수록 더 흔들린다. 꼴찌로 들어오면 이긴다(먼저 들어오기·넘어지기·멈추기·차선 벗어나기 = 끝).

const LANE := 1.6
const HALF := 0.7
const TIP := 0.75
const MAXV := 3.0
const MINV := 0.15
const NAI := 4

var rider: Array[Node3D] = []
var r_z := PackedFloat32Array()
var r_x := PackedFloat32Array()
var r_v := PackedFloat32Array()
var r_lean := PackedFloat32Array()
var r_ph := PackedFloat32Array()
var r_fall := PackedFloat32Array()  # 이 시간에 넘어진다 (-1 안 넘어짐)
var r_state := PackedInt32Array()  # 0 달림, 1 들어감, 2 넘어짐
var finish: MeshInstance3D
var marks: Array[MeshInstance3D] = []
var track := 14.0
var rnd := 0
var waiting := true
var pause_t := 0.0
var el := 0.0
var sv := 0.8
var lean := 0.0
var lean_v := 0.0
var steer := 0.0
var sx := 0.0
var gust := 0.0
var gust_t := 0.0
var pedal_t := 0.0
var tick_t := 0.0


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 62.0


func _reset() -> void:
	box(Vector3(0, -0.1, -28), Vector3(LANE * 5 + 2, 0.2, 80), SOFT)
	for i in 6:
		box(Vector3((i - 2.5) * LANE, 0.01, -28), Vector3(0.06, 0.03, 80), WHITE)
	finish = box(Vector3(0, 0.02, 0), Vector3(LANE * 5, 0.05, 0.5), INK)
	marks.clear()
	for i in 30:
		marks.append(box(Vector3((LANE * 2.5 + 0.5) * (1 if i % 2 == 0 else -1), 0.15, -i * 2.0), Vector3(0.3, 0.3, 0.3), [A, B, C, D][i % 4]))
	rider.clear()
	var cols := [ME, A, C, D, GOOD]
	for i in NAI + 1:
		var pv := Node3D.new()
		world.add_child(pv)
		box(Vector3(0, 0.45, 0), Vector3(0.12, 0.12, 1.3), INK, pv)
		box(Vector3(0, 0.35, 0.55), Vector3(0.1, 0.7, 0.7), INK, pv)
		box(Vector3(0, 0.35, -0.55), Vector3(0.1, 0.7, 0.7), INK, pv)
		box(Vector3(0, 1.05, 0.1), Vector3(0.45, 0.75, 0.35), cols[i], pv)
		box(Vector3(0, 1.6, 0.05), Vector3(0.32, 0.32, 0.32), WHITE, pv)
		rider.append(pv)
	r_z.resize(NAI + 1)
	r_x.resize(NAI + 1)
	r_v.resize(NAI + 1)
	r_lean.resize(NAI + 1)
	r_ph.resize(NAI + 1)
	r_fall.resize(NAI + 1)
	r_state.resize(NAI + 1)
	rnd = 0
	_round()


func _round() -> void:
	track = maxf(8.0, 14.0 - rnd * 1.0)
	finish.position.z = -track
	waiting = true
	pause_t = 0.0
	el = 0.0
	sv = 0.8
	lean = 0.0
	lean_v = 0.0
	steer = 0.0
	gust = 0.0
	gust_t = 0.0
	var faller := randi() % NAI + 1 if randf() < 0.5 else -1
	var base := maxf(0.4, 0.75 - rnd * 0.05)
	for i in NAI + 1:
		r_z[i] = 0.0
		r_x[i] = [0.0, -2.0, -1.0, 1.0, 2.0][i] * LANE
		r_v[i] = base * randf_range(0.85, 1.15)
		r_lean[i] = 0.0
		r_ph[i] = randf() * TAU
		r_fall[i] = randf_range(4.0, track / base * 0.9) if i == faller else -1.0
		r_state[i] = 0
	_place()


func _step(dt: float) -> void:
	if waiting:
		msg("눌러서 출발" if rnd == 0 else "%d판" % (rnd + 1), 0.2)
		_place()
		return
	if pause_t > 0.0:
		pause_t -= dt
		if pause_t <= 0.0:
			rnd += 1
			_round()
		_place()
		return
	el += dt
	# 나: 누르면 페달, 떼면 느려짐
	if held:
		sv = minf(MAXV, sv + 0.45 * dt)
		pedal_t -= dt
		if pedal_t <= 0.0:
			pedal_t = 0.5
			beep(300.0, 0.04, 0.0, 0.08)
	else:
		sv -= 0.3 * dt
	r_z[0] -= sv * dt
	# 균형: 느릴수록 불안정
	var inst := clampf(1.2 / (sv + 0.3), 0.5, 4.0)
	gust_t -= dt
	if gust_t <= 0.0:
		gust_t = randf_range(0.3, 0.7)
		gust = randf_range(-1.0, 1.0) * 0.35 * (1.0 + rnd * 0.25)
	lean_v += (lean * 2.0 * inst + gust * inst - steer * 3.2) * dt
	lean_v *= exp(-2.0 * dt)
	lean += lean_v * dt
	r_lean[0] = lean
	r_x[0] -= lean * 0.9 * dt
	var k := absf(lean) / TIP
	gauge(1.0 - k, GOOD if k < 0.45 else (A if k < 0.7 else BAD))
	if k > 0.45:
		tick_t -= dt
		if tick_t <= 0.0:
			tick_t = lerpf(0.35, 0.07, (k - 0.45) / 0.55)
			beep(500.0 + 900.0 * k, 0.05, 0.0, 0.22)
	# 다른 선수들
	for i in range(1, NAI + 1):
		if r_state[i] != 0:
			continue
		var v := r_v[i] * (1.0 + 0.3 * sin(el * 1.3 + r_ph[i]))
		if rnd >= 1 and r_z[i] < -track + 2.0:
			v = maxf(0.25, v * (0.45 if rnd >= 3 else 0.7))  # 결승선 앞에서 버팀
		r_z[i] -= v * dt
		r_lean[i] = sin(el * 2.1 + r_ph[i]) * 0.15 / (v + 0.3)
		if r_fall[i] > 0.0 and el >= r_fall[i]:
			r_state[i] = 2
			r_lean[i] = 1.45 * signf(r_lean[i] + 0.01)
			beep(160.0, 0.25, 70.0, 0.22)
			msg("꽈당")
		elif r_z[i] <= -track:
			r_state[i] = 1
			beep(700.0, 0.1, 500.0, 0.18)
			msg("%d 들어옴" % _count(1))
	_place()
	# 판정
	if absf(lean) >= TIP:
		_lose(2, "넘어짐")
	elif sv <= MINV:
		_lose(2, "발 닿음")
	elif absf(r_x[0]) > HALF:
		_lose(2, "선 넘음")
	elif r_z[0] <= -track:
		if _count(0) > 0:
			_lose(1, "너무 빨라")
		else:
			_win()
	elif _count(0) == 0:
		_win()


func _count(s: int) -> int:
	var n := 0
	for i in range(1, NAI + 1):
		if r_state[i] == s:
			n += 1
	return n


func _win() -> void:
	score += 1
	pause_t = 1.4
	msg("꼴찌 우승!", 1.4)
	play("win")


func _lose(s: int, why: String) -> void:
	r_state[0] = s
	if s == 2:
		r_lean[0] = 1.45 * signf(lean + 0.01)
	_place()
	msg(why, 2.0)
	end()


func _place() -> void:
	for i in NAI + 1:
		rider[i].position = Vector3(r_x[i], 0, r_z[i])
		rider[i].rotation.z = r_lean[i]
	var z := r_z[0]
	cam.position = Vector3(0, 4.2, z + 6.5)
	cam.look_at(Vector3(0, 0.6, z - 4.0))


func _tap(p: Vector2) -> void:
	sx = p.x
	steer = 0.0
	pedal_t = 0.0
	if waiting:
		waiting = false
		play("tap")


func _drag(p: Vector2) -> void:
	steer = clampf((p.x - sx) / 150.0, -1.0, 1.0)


func _lift(_p: Vector2) -> void:
	steer = 0.0
