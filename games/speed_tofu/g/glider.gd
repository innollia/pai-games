extends Tofu
## 활공 1인칭. 화면 어디든 끌어 기수를 움직인다(아래로 끌면 기수 올림, 옆으로 끌면 선회). 버튼 없음.
## 속도가 양력이다: 내려꽂으면 빨라지고 올리면 느려지다 실속해 떨어진다. 빠를수록 선회가 둔하고 날개가 떨리며, 한계를 넘으면 부러진다.
## 협곡 3개: 바위 틈·상승기류·돌풍을 지나 끝의 착륙장에 천천히 내려앉으면 다음 협곡. 죽음 = 실속 추락, 충돌, 과속 파손, 과속 착지.

const SEG := 12.0  # 협곡 한 토막 길이
const H := 28.0  # 협곡 벽 높이
const STALL := 7.0  # 이 아래면 실속
const SHAKE := 22.0  # 이 위면 날개가 떨린다
const BREAK := 30.0  # 이 위면 날개가 부러진다
const LAND_MAX := 13.0  # 착지 허용 속도
const G := 11.0  # 내려꽂을 때 가속
const DRAG := 0.012
const GREY := Color("dfe3e8")
const LEVELS := [
	{"n": 22, "w": 9.0, "h": 40.0, "curve": 2.0, "seed": 11, "gates": 3, "thermals": 3, "gusts": 0},
	{"n": 26, "w": 7.0, "h": 42.0, "curve": 3.0, "seed": 23, "gates": 6, "thermals": 4, "gusts": 0},
	{"n": 30, "w": 6.0, "h": 44.0, "curve": 3.5, "seed": 37, "gates": 7, "thermals": 4, "gusts": 4},
]


var lv := 0
var level: Node3D
var n_seg := 0
var half_w := 0.0
var cx: Array[float] = []
var gates: Array[Dictionary] = []  # {z, kind, a}  kind 0 세로 틈(x), 1 낮은 바위(위로), 2 처마(아래로)
var thermals: Array[Vector2] = []  # x, z
var gusts: Dictionary = {}  # 토막 번호 -> 방향(-1/1)
var pad_z := 0.0
var pos := Vector3.ZERO
var prev_z := 0.0
var spd := 10.0
var yaw := 0.0
var pitch := 0.0
var bank := 0.0
var roll := 0.0
var stalling := false
var in_gust := false
var die_t := 0.0
var clear_t := 0.0
var hum_t := 0.0
var lift_t := 0.0
var dist := 0.0
var wings: Array[MeshInstance3D] = []


func _setup() -> void:
	howto = "절벽에서 뛰어내린 활공. 화면 어디든 끌어서 기수를 움직인다. 아래로 끌면 기수가 올라가고, 옆으로 끌면 선회한다.\n내려꽂으면 빨라지고 들면 느려진다. 너무 느리면 실속해서 떨어지고, 너무 빠르면 날개가 떨리다 부러진다.\n노란 기둥은 상승기류. 협곡 끝 초록 착륙장에 천천히 내려앉으면 다음 협곡."
	time_limit = 0.0
	cam.fov = 75.0
	kit_lookpad(Rect2(0, 100, 720, 1180))
	wings.append(box(Vector3(-1.5, -0.45, -0.7), Vector3(2.4, 0.06, 0.8), B, cam))
	wings.append(box(Vector3(1.5, -0.45, -0.7), Vector3(2.4, 0.06, 0.8), B, cam))
	wings.append(box(Vector3(0, -0.5, -0.9), Vector3(0.5, 0.12, 1.4), ME, cam))


func _reset() -> void:
	level = null
	lv = 0
	dist = 0.0
	_canyon(0)


## 협곡 i를 짓는다 (같은 씨앗이라 죽어도 같은 협곡)
func _canyon(i: int) -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	var L: Dictionary = LEVELS[i]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(L.seed)
	n_seg = int(L.n)
	half_w = float(L.w)
	var curve: float = L.curve
	cx.clear()
	var x := 0.0
	var dx := 0.0
	for k in n_seg:
		cx.append(x)
		dx = clampf(dx + rng.randf_range(-curve, curve), -curve * 1.5, curve * 1.5)
		if k < 2 or k >= n_seg - 3:
			dx = 0.0
		x += dx
	# 절벽(출발점)
	var start_h: float = L.h
	box(Vector3(cx[0], start_h * 0.5 - 1.0, 9.0), Vector3(half_w * 2.0 + 8.0, start_h - 2.0, 12.0), SOFT, level)
	# 벽·바닥·돌
	for k in n_seg:
		var zc := -(k + 0.5) * SEG
		for sd in [-1.0, 1.0]:
			box(Vector3(cx[k] + sd * (half_w + 2.0), H * 0.5, zc), Vector3(4.0, H, SEG + 0.6), SOFT if k % 2 == 0 else GREY, level)
		box(Vector3(cx[k], -0.25, zc), Vector3(half_w * 2.0 + 8.0, 0.5, SEG + 0.6), WHITE if k % 2 == 0 else SOFT, level)
		for j in 2:
			var s := rng.randf_range(0.4, 1.1)
			box(Vector3(cx[k] + rng.randf_range(-half_w, half_w), s * 0.5, zc + rng.randf_range(-5.0, 5.0)), Vector3(s, s, s), A, level)
	# 끝 벽
	var end_z := -n_seg * SEG
	box(Vector3(cx[n_seg - 1], H * 0.5, end_z - 2.0), Vector3(half_w * 2.0 + 8.0, H, 4.0), GREY, level)
	# 착륙장 (마지막 두 토막)
	pad_z = end_z + SEG * 1.0
	box(Vector3(cx[n_seg - 1], 0.15, pad_z), Vector3(half_w * 2.0 - 1.0, 0.3, SEG * 1.8), GOOD, level)
	# 바위 틈 (3~n-4 토막에 고르게)
	gates.clear()
	var ng := int(L.gates)
	for g in ng:
		var k := 3 + int(float(g) * float(n_seg - 7) / float(maxi(ng, 1))) + rng.randi_range(0, 1)
		k = mini(k, n_seg - 4)
		var gz := -(k + 0.5) * SEG
		var kind := rng.randi_range(0, 2)
		var c := cx[k]
		var a := 0.0
		if kind == 0:
			a = c + rng.randf_range(-(half_w - 3.0), half_w - 3.0)
			var lx := c - half_w
			var rx := c + half_w
			box(Vector3((lx + a - 1.8) * 0.5, H * 0.5, gz), Vector3(maxf(a - 1.8 - lx, 0.2), H, 1.2), C, level)
			box(Vector3((rx + a + 1.8) * 0.5, H * 0.5, gz), Vector3(maxf(rx - a - 1.8, 0.2), H, 1.2), C, level)
		elif kind == 1:
			a = rng.randf_range(5.0, 9.0)
			box(Vector3(c, a * 0.5, gz), Vector3(half_w * 2.0, a, 1.2), C, level)
		else:
			a = rng.randf_range(7.0, 12.0)
			box(Vector3(c, (a + H) * 0.5, gz), Vector3(half_w * 2.0, H - a, 1.2), C, level)
		gates.append({"z": gz, "kind": kind, "a": a})
	# 상승기류 기둥 (틈 사이사이)
	thermals.clear()
	var nt := int(L.thermals)
	for q in nt:
		var k := 2 + int((float(q) + 0.5) * float(n_seg - 6) / float(nt))
		var tz := -(k + 0.5) * SEG + rng.randf_range(-3.0, 3.0)
		var tx := cx[k] + rng.randf_range(-(half_w - 2.5), half_w - 2.5)
		box(Vector3(tx, H * 0.5, tz), Vector3(2.4, H, 2.4), D, level)
		thermals.append(Vector2(tx, tz))
	# 돌풍 토막 (떠다니는 보라 조각으로 표시)
	gusts.clear()
	var ngu := int(L.gusts)
	for q in ngu:
		var k := 4 + int((float(q) + 0.5) * float(n_seg - 8) / float(ngu))
		var dir := -1.0 if q % 2 == 0 else 1.0
		gusts[k] = dir
		for j in 4:
			box(Vector3(cx[k] + rng.randf_range(-half_w, half_w), rng.randf_range(4.0, 22.0), -(k + 0.5) * SEG + rng.randf_range(-5.0, 5.0)), Vector3(1.6, 0.3, 0.3), C, level)
	pos = Vector3(cx[0], start_h, 2.0)
	prev_z = pos.z
	spd = 10.0
	yaw = 0.0
	pitch = -0.12
	bank = 0.0
	roll = 0.0
	stalling = false
	in_gust = false
	die_t = 0.0
	clear_t = 0.0
	msg("협곡 %d / %d" % [i + 1, LEVELS.size()], 1.2)


func _step(dt: float) -> void:
	if die_t > 0.0:
		die_t -= dt
		roll += 4.0 * dt
		pitch = maxf(pitch - 1.5 * dt, -1.4)
		pos.y = maxf(pos.y - 6.0 * dt, 0.6)
		_camera()
		if die_t <= 0.0:
			_canyon(lv)
		return
	if clear_t > 0.0:
		clear_t -= dt
		spd = move_toward(spd, 0.0, 10.0 * dt)
		pos += Vector3(-sin(yaw), 0, -cos(yaw)) * spd * dt
		_camera()
		if clear_t <= 0.0:
			lv += 1
			if lv >= LEVELS.size():
				play("win")
				end()
			else:
				_canyon(lv)
		return
	# 기수: 아래로 끌면 올리고, 옆으로 끌면 기울여 선회. 빠를수록 둔하다
	var slug := 1.0 / (1.0 + spd * 0.04)
	pitch = clampf(pitch + kit_look.y * 0.0035 * slug, -1.3, 0.7)
	bank = clampf(bank - kit_look.x * 0.004, -1.0, 1.0)
	bank = move_toward(bank, 0.0, 1.2 * dt)
	yaw += bank * 1.6 / (1.0 + spd * 0.07) * dt
	roll = lerpf(roll, bank * 0.7, 6.0 * dt)
	# 속도 = 몸의 물리: 내려꽂으면 붙고, 들면 빠진다
	var fwd := Vector3(-sin(yaw) * cos(pitch), sin(pitch), -cos(yaw) * cos(pitch))
	spd += (G * (-fwd.y) - DRAG * spd * spd) * dt
	spd = maxf(spd, 0.0)
	var sink := 1.0 * clampf(pow(STALL * 1.4 / maxf(spd, 0.1), 2.0), 0.2, 3.0)
	if spd < STALL:
		if not stalling:
			stalling = true
			msg("실속!", 0.8)
			beep(160.0, 0.4, 60.0, 0.3)
		pitch = move_toward(pitch, -1.0, 1.3 * dt)
		sink = 6.0
	elif stalling and spd > STALL + 1.5:
		stalling = false
	prev_z = pos.z
	pos += fwd * spd * dt
	pos.y -= sink * dt
	dist += spd * dt
	score = int(dist)
	# 상승기류
	var lifted := false
	for th in thermals:
		if Vector2(pos.x - th.x, pos.z - th.y).length() < 2.8:
			lifted = true
			pos.y += 9.0 * dt
			spd += 1.5 * dt
	if lifted:
		lift_t -= dt
		if lift_t <= 0.0:
			lift_t = 0.18
			beep(600.0 + pos.y * 10.0, 0.1, 900.0 + pos.y * 10.0, 0.15)
		msg("상승", 0.2)
	# 돌풍 토막
	var k := int(floorf(-pos.z / SEG))
	if gusts.has(k):
		var gdir: float = gusts[k]
		pos.x += gdir * 4.0 * dt
		yaw += gdir * 0.35 * dt
		roll += gdir * sin(dist * 0.8) * 0.02
		if not in_gust:
			in_gust = true
			msg("돌풍!", 0.7)
			beep(240.0, 0.3, 420.0, 0.25)
	else:
		in_gust = false
	# 바람 소리: 빠를수록 높고 크다
	hum_t -= dt
	if hum_t <= 0.0:
		hum_t = clampf(0.3 - spd * 0.007, 0.07, 0.3)
		beep(50.0 + spd * 6.0, 0.11, 0.0, 0.05 + spd * 0.004)
	_camera()
	gauge(spd / BREAK, BAD if spd > SHAKE else (C if spd < STALL + 2.0 else B))
	# 죽음·착지
	if spd > BREAK:
		_die("날개가 부러졌다")
		return
	if k >= 0 and k < n_seg and absf(pos.x - cx[k]) > half_w:
		_die("벽")
		return
	if pos.z < -n_seg * SEG:
		_die("절벽")
		return
	for gt in gates:
		var gz: float = gt.z
		if prev_z >= gz and pos.z < gz:
			var kind: int = gt.kind
			var a: float = gt.a
			var hit := false
			if kind == 0:
				hit = absf(pos.x - a) > 1.5
			elif kind == 1:
				hit = pos.y < a + 0.4
			else:
				hit = pos.y > a - 0.4
			if hit:
				_die("바위")
				return
			beep(900.0, 0.06, 1400.0, 0.2)
			msg("휙", 0.3)
	if pos.y <= 0.9:
		var on_pad := absf(pos.z - pad_z) < SEG * 0.9 and absf(pos.x - cx[n_seg - 1]) < half_w - 0.5
		if on_pad and spd <= LAND_MAX:
			clear_t = 1.6
			score += 500
			msg("착륙", 1.5)
			play("good")
		elif on_pad:
			_die("너무 빨리 내렸다")
		else:
			_die("추락")


## 카메라 = 내 눈. 과속이면 흔들리고 날개가 떨린다. 빠를수록 시야가 넓어진다
func _camera() -> void:
	cam.position = pos
	var shake := clampf((spd - SHAKE) / (BREAK - SHAKE), 0.0, 1.0)
	var jit := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * shake * 0.06
	cam.rotation = Vector3(pitch, yaw, roll) + jit
	cam.fov = clampf(70.0 + spd * 0.9, 70.0, 100.0)
	for w in 2:
		wings[w].rotation.z = randf_range(-1, 1) * shake * 0.25 + (-0.08 if w == 0 else 0.08) * roll
	wings[2].rotation.z = 0.0


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 1.5
	play("bad")
	beep(90.0, 0.4, 30.0, 0.35)
	msg(why, 1.4)
