extends Tofu
## 속도 맞춰 건너기: 꾹 누르면 가속, 떼면 감속. 오른쪽으로 밀면 옆 차선으로 건너간다. 옆 차선과 속도가 맞고(초록) 빈자리면 성공, 아니면 쾅. 가장 빠른 오른쪽 끝 차선까지 가면 판이 더 빨라지고 허용 폭이 좁아진다.

const LANES := 6
const LW := 2.2
const K := 4
const LOOP := 64.0
const FAR := -50.0
const CAR_L := 2.4
const ME_L := 1.6
const HIT := (CAR_L + ME_L) * 0.5
const ACC := 9.0
const DEC := 6.0
const DASH_N := 11

var cols: Array[Color] = []
var me_box: MeshInstance3D
var mark: MeshInstance3D
var cars: Array[MeshInstance3D] = []
var c_z := PackedFloat32Array()
var lane_v := PackedFloat32Array()
var dash: Array[MeshInstance3D] = []
var dash_z := PackedFloat32Array()
var spd := 0.0
var lane := 0
var rnd := 0
var win_w := 2.0
var px := 0.0
var stun := 0.0
var eng_t := 0.0
var matched := false
var sx := 0.0


func _setup() -> void:
	time_limit = 60.0
	cam.fov = 55.0
	cam.position = Vector3(0, 13, 11)
	cam.look_at(Vector3(0, 0, -8))
	cols = [GOOD, B, D, A, C, BAD]


func _lx(i: int) -> float:
	return (i - (LANES - 1) * 0.5) * LW


func _reset() -> void:
	box(Vector3(0, -0.1, -18), Vector3(LANES * LW + 0.6, 0.2, 80), SOFT)
	box(Vector3(_lx(LANES - 1) + LW * 0.5 + 0.9, -0.05, -18), Vector3(1.2, 0.2, 80), GOOD)
	dash.clear()
	dash_z.clear()
	for b in LANES + 1:
		var x := _lx(0) - LW * 0.5 + b * LW
		var edge := b == 0 or b == LANES
		for k in DASH_N:
			if edge:
				dash.append(box(Vector3(x, 0.3, 0), Vector3(0.3, 0.6, 0.3), INK))
			else:
				dash.append(box(Vector3(x, 0.02, 0), Vector3(0.15, 0.06, 2.0), WHITE))
			dash_z.append(FAR + k * LOOP / DASH_N)
	cars.clear()
	c_z.clear()
	for i in LANES:
		for k in K:
			cars.append(box(Vector3(_lx(i), 0.45, 0), Vector3(1.5, 0.9, CAR_L), cols[i]))
			c_z.append(FAR + (k + randf_range(0.1, 0.6)) * LOOP / K)
	lane_v.resize(LANES)
	me_box = box(Vector3.ZERO, Vector3(1.1, 0.8, ME_L), ME)
	mark = box(Vector3(0, 0.03, 0), Vector3(LW * 0.85, 0.04, 2.2), WHITE)
	stun = 0.0
	eng_t = 0.0
	sx = 0.0
	rnd = 0
	_round()
	msg("꾹 = 가속\n→ = 건너기", 2.5)


## 새 판: 차선 속도와 허용 폭을 정하고 왼쪽 끝으로
func _round() -> void:
	for i in LANES:
		lane_v[i] = 5.0 + i * (5.0 + rnd * 1.5)
	win_w = maxf(0.8, 2.2 - rnd * 0.35)
	_to_start()


func _to_start() -> void:
	lane = 0
	px = _lx(0)
	spd = lane_v[0]
	matched = false
	for k in K:
		if absf(c_z[k]) < HIT + 2.5:
			c_z[k] = 6.0 if c_z[k] >= 0.0 else -6.0


func _step(dt: float) -> void:
	if stun > 0.0:
		stun -= dt
		spd = move_toward(spd, lane_v[0], 40.0 * dt)
		if stun <= 0.0:
			me_box.material_override = mat(ME)
			_to_start()
	else:
		spd = clampf(spd + (ACC if held else -DEC) * dt, 0.0, lane_v[LANES - 1] + 10.0)
	# 내 속도 기준으로 세상이 흐른다
	for i in LANES:
		var rel := (lane_v[i] - spd) * dt
		for k in K:
			var j := i * K + k
			c_z[j] = _wrap(c_z[j] - rel)
			cars[j].position.z = c_z[j]
	for j in dash.size():
		dash_z[j] = _wrap(dash_z[j] + spd * dt)
		dash[j].position.z = dash_z[j]
	px = move_toward(px, _lx(lane), 25.0 * dt)
	me_box.position = Vector3(px, 0.45, 0)
	eng_t -= dt
	if eng_t <= 0.0:
		eng_t = clampf(0.22 - spd * 0.003, 0.07, 0.22)
		beep(90.0 + roundi(spd) * 10.0, 0.06, 0.0, 0.07)
	if stun > 0.0:
		return
	if _occupied(lane):
		_crash("쾅")
		return
	var nx := lane + 1
	var dv := spd - lane_v[nx]
	var ok := absf(dv) <= win_w
	if ok and not matched:
		beep(1046.0, 0.06, 1568.0, 0.25)
	matched = ok
	var free := not _occupied(nx)
	mark.position = Vector3(_lx(nx), 0.03, 0)
	mark.material_override = mat(GOOD if ok and free else (A if free else BAD))
	gauge(1.0 - absf(dv) / 12.0, GOOD if ok else (A if absf(dv) <= win_w * 3.0 else BAD))


func _tap(p: Vector2) -> void:
	sx = p.x


func _drag(p: Vector2) -> void:
	if p.x - sx > 70.0:
		sx = p.x
		_hop()


func _hop() -> void:
	if stun > 0.0:
		return
	var nx := lane + 1
	var dv := spd - lane_v[nx]
	if _occupied(nx):
		lane = nx
		_crash("쾅")
		return
	if absf(dv) > win_w:
		lane = nx
		_crash("너무 빨라" if dv > 0.0 else "너무 느려")
		return
	lane = nx
	spd = lane_v[lane]
	matched = false
	score += 1
	play("good")
	if lane == LANES - 1:
		score += 5
		rnd += 1
		msg("통과!", 1.0)
		play("win")
		_round()
	else:
		msg("딱", 0.4)


func _crash(s: String) -> void:
	stun = 0.8
	me_box.material_override = mat(BAD)
	play("bad")
	msg(s, 0.8)
	t -= 3.0


func _occupied(i: int) -> bool:
	for k in K:
		if absf(c_z[i * K + k]) < HIT:
			return true
	return false


func _wrap(z: float) -> float:
	while z < FAR:
		z += LOOP
	while z > FAR + LOOP:
		z -= LOOP
	return z
