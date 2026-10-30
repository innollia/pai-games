extends Tofu
## 늘어나는 돌: 신전 돌이 저절로 구른다. 빠를수록 납작한 원반(낮고 좁고 길게), 느릴수록 둥근 공. 버튼 = 세우기(급제동, 공으로 돌아감). 끌기의 뜻은 구역마다 바뀐다.
## 등뒤 신전길: 끌기=방향. 낮은 아치는 납작해야, 급커브는 둥글어야. 다리 위 옆바람은 원반을 날린다. 옆모습 수로: 끌기=몸 기울이기. 물은 원반만 튕겨 건너고 턱은 공만 넘는다. 위에서 광장: 바람 띠 사이로 문에 줄 세우기. 1.5초 느리거나 떨어지면 끝.
# 한 문장: 나는 신전에서 풀려난 돌로서 빠를수록 납작한 원반이 되는 몸으로 굴러 신전 밖 광장 문에 닿지만, 빨라질수록 꺾이지 않고 바람에 날리며 턱에 걸리는 대가를 감수한다.

const STONE := Color("efe1c4")
const ROCK := Color("e0c896")
const GRASS := Color("8ce99a")
const WATER := Color("a5d8ff")
const GRV := 40.0
const FALL := 32.0
const DRAG := 0.0016
const ROLL := 0.3
const VSTOP := 6.0
const STOP_T := 1.5
const VMAX := 45.0
const V_ROUND := 10.0  # 이 아래는 완전한 공
const V_FLAT := 28.0  # 이 위는 완전한 원반
const H0 := 2.4  # 공: 2.4 x 2.4 x 2.4
const H1 := 0.8  # 원반: 높이 0.8, 폭 1.0, 길이 4.4
const W0 := 2.4
const W1 := 1.0
const L0 := 2.4
const L1 := 4.4
const CLEAR := 1.5  # 아치·관·광장 문 높이 (몸 높이가 이보다 낮아야 지남 = 약 20 이상)
const STEP_NEED := 1.6  # 턱을 넘으려면 몸 높이가 이 이상 (= 약 19 이하)
const STEP_H := 0.9
const BRAKE := 0.5
const SKIP_F := 0.45  # 물수제비: 이만큼 납작하고
const SKIP_V := 15.0  # 이만큼 빨라야
const WIND_A := 10.0
const Z2 := -480.0  # 수로 시작
const Z3 := -860.0  # 광장 시작
const ZEND := -1060.0  # 광장 문
const GATE_X := 10.0
# 구역 1 신전길: [x, z, 높이, 다음 점까지 반폭]
const N1 := [
	[0.0, 20.0, 42.0, 6.0], [0.0, -60.0, 34.0, 6.0], [0.0, -140.0, 26.0, 6.0],
	[-45.0, -160.0, 24.0, 6.0], [-50.0, -200.0, 22.0, 6.0], [-50.0, -260.0, 10.0, 6.0],
	[0.0, -280.0, 8.0, 6.0], [5.0, -300.0, 7.0, 2.6], [5.0, -380.0, 1.0, 6.0],
	[5.0, -405.0, 2.5, 6.0], [0.0, -460.0, -4.5, 4.0], [0.0, -480.0, -5.0, 4.0],
]
const BRIDGE_SEG := 7
const ARCH_Z := [-110.0, -226.0, -238.0, -455.0]
# 구역 2 수로 (옆모습): [수로 안 거리, 높이]. 같은 거리가 두 번이면 턱.
const K2 := [
	[0.0, -5.0], [40.0, -13.0], [50.0, -13.4], [66.0, -13.8], [90.0, -16.0], [90.0, -15.1],
	[100.0, -15.3], [145.0, -22.0], [176.0, -24.0], [184.0, -24.6], [204.0, -25.2],
	[224.0, -26.5], [224.0, -25.6], [280.0, -33.0], [288.0, -33.6], [318.0, -34.4],
	[346.0, -37.0], [362.0, -38.0], [362.0, -37.1], [380.0, -37.6],
]
const POOLS := [[50.0, 66.0, -14.0], [184.0, 204.0, -25.2], [288.0, 318.0, -34.3]]  # [시작, 끝, 물 높이]
const PIPES := [[150.0, 176.0], [324.0, 346.0]]
const STEPS := [90.0, 224.0, 362.0]
const H3 := -37.6
# 구역 3 광장 (위에서): [광장 안 거리 시작, 끝, 바람 방향]
const LANES := [[40.0, 60.0, 1.0], [100.0, 125.0, -1.0], [165.0, 180.0, 1.0]]
const PILLARS3 := [
	Vector2(-6, 30), Vector2(6, 35), Vector2(0, 85), Vector2(-12, 90), Vector2(14, 95),
	Vector2(4, 135), Vector2(-8, 140), Vector2(18, 145), Vector2(2, 170), Vector2(4, 186),
]
const POTS1 := [
	Vector2(-2, -25), Vector2(2, -35), Vector2(0, -45), Vector2(-1.5, -125), Vector2(1.5, -130),
	Vector2(0, -135), Vector2(-49, -252), Vector2(-51, -255), Vector2(-50, -258),
]
const POTS3 := [
	Vector2(-5, 20), Vector2(5, 25), Vector2(0, 70), Vector2(-10, 80), Vector2(8, 90),
	Vector2(12, 150), Vector2(9, 155), Vector2(11, 160),
]


class Pot:
	var n: MeshInstance3D
	var x := 0.0
	var z := 0.0
	var base := 0.0
	var flat := false


var pivot: Node3D
var body: MeshInstance3D
var stripes: Array[MeshInstance3D] = []
var streaks: Array[MeshInstance3D] = []
var lane_marks: Array[MeshInstance3D] = []
var lane_info: Array[Vector3] = []  # (기준 x, 바람 방향, 높이 오프셋 없음)
var pots: Array[Pot] = []
var pillars: Array[Vector2] = []
var px := 0.0
var pz := 0.0
var by := 0.0
var vy := 0.0
var v := 0.0
var hd := 0.0  # 진행 방향 (0 = -z, + = 왼쪽)
var hd_goal := 0.0
var cam_hd := 0.0
var lat_v := 0.0
var fl := 0.0  # 납작함 0 공 ~ 1 원반
var bh := H0
var bw := W0
var bl := L0
var on_ground := true
var last_g := 0.0
var fallen := false
var fall_mode := 0  # 0 그 자리, 1 추락, 2 가라앉음
var fall_t := 0.0
var slow_t := 0.0
var warn_t := 0.0
var hurt := 0.0
var shake := 0.0
var brake_cd := 0.0
var brake_t := 0.0
var zone := 1
var travel := 0.0
var bonus := 0
var won := false
var clock := 0.0
var drag_x := 0.0
var press_x := 0.0
var roll_ph := 0.0
var roll_acc := 0.0
var was_flat := false
var gust_warned := -1
var wind_now := 0.0
var cam_base := Vector3.ZERO
var cam_look := Vector3.ZERO


func _setup() -> void:
	howto = "돌은 저절로 구른다. 빠를수록 납작한 원반, 느릴수록 둥근 공.\n낮은 아치·관은 납작해야, 급커브·턱은 둥글어야 지난다. 원반은 물을 튕겨 건너지만 옆바람에 날린다.\n끌기: 방향 (옆모습 수로에선 앞뒤로 몸 기울이기). 세우기 버튼: 급제동.\n1.5초 넘게 느리거나 떨어지면 끝."
	time_limit = 0.0
	kit_button("brake", "세우기", Vector2(600, 1110), 100.0, A)
	for k in 2:
		var tk := ColorRect.new()
		var sp := VSTOP if k == 0 else (V_ROUND + 0.53 * (V_FLAT - V_ROUND))
		tk.color = INK if k == 0 else B
		tk.position = Vector2(600.0 * sp / VMAX - 3.0, -10.0)
		tk.size = Vector2(6, 48)
		tk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_bar_bg.add_child(tk)


func _reset() -> void:
	px = 0.0
	pz = 10.0
	v = 14.0
	vy = 0.0
	hd = 0.0
	hd_goal = 0.0
	cam_hd = 0.0
	lat_v = 0.0
	fl = 0.0
	bh = H0
	bw = W0
	bl = L0
	on_ground = true
	fallen = false
	fall_mode = 0
	fall_t = 0.0
	slow_t = 0.0
	warn_t = 0.0
	hurt = 0.0
	shake = 0.0
	brake_cd = 0.0
	brake_t = 0.0
	zone = 1
	travel = 0.0
	bonus = 0
	won = false
	clock = 0.0
	roll_ph = 0.0
	roll_acc = 0.0
	was_flat = false
	gust_warned = -1
	wind_now = 0.0
	by = _g(px, pz)
	last_g = by
	_build()
	pivot = Node3D.new()
	world.add_child(pivot)
	body = box(Vector3(0, H0 * 0.5, 0), Vector3(W0, H0, L0), ME, pivot)
	stripes.clear()
	for k in 2:
		stripes.append(box(Vector3.ZERO, Vector3.ONE, WHITE, pivot))
	streaks.clear()
	for k in 8:
		var s := box(Vector3.ZERO, Vector3(3.0, 0.12, 0.12), WHITE)
		s.visible = false
		streaks.append(s)
	cam_base = Vector3(0, by + 6.0, pz + 10.0)
	cam_look = Vector3(0, by, pz - 14.0)
	cam.position = cam_base
	cam.fov = 55.0
	msg("등뒤: 신전길", 1.5)


# ---- 땅 ----
## 구역 1 길에서 가장 가까운 곳: [거리, 높이, 반폭, 구간 번호]
func _near1(x: float, z: float) -> Array:
	var best := INF
	var bht := 0.0
	var bwd := 0.0
	var bi := 0
	var q := Vector2(x, z)
	for i in N1.size() - 1:
		var a := Vector2(float(N1[i][0]), float(N1[i][1]))
		var b := Vector2(float(N1[i + 1][0]), float(N1[i + 1][1]))
		var ab := b - a
		var tt := clampf((q - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
		var dd := q.distance_to(a + ab * tt)
		if dd < best:
			best = dd
			bht = lerpf(float(N1[i][2]), float(N1[i + 1][2]), tt)
			bwd = float(N1[i][3])
			bi = i
	return [best, bht, bwd, bi]


func _pool(d: float) -> int:
	for i in POOLS.size():
		if d > float(POOLS[i][0]) and d < float(POOLS[i][1]):
			return i
	return -1


func _p2(d: float) -> float:
	for i in range(K2.size() - 2, -1, -1):
		var a: Array = K2[i]
		var b: Array = K2[i + 1]
		if d >= float(a[0]):
			var span := float(b[0]) - float(a[0])
			if span <= 0.001:
				return float(b[1])
			return lerpf(float(a[1]), float(b[1]), clampf((d - float(a[0])) / span, 0.0, 1.0))
	return float(K2[0][1])


func _h3(d3: float) -> float:
	if d3 < 140.0:
		return H3 - d3 * 0.05
	return H3 - 7.0 - (d3 - 140.0) * 0.14


## (x, z) 아래 땅 높이. 없으면 NAN
func _g(x: float, z: float) -> float:
	if z > Z2:
		var r := _near1(x, z)
		return float(r[1]) if float(r[0]) <= float(r[2]) else NAN
	if z > Z3:
		var d := Z2 - z
		if absf(x) > 3.5 or _pool(d) >= 0:
			return NAN
		return _p2(d)
	if z < ZEND or absf(x) > 25.0:
		return NAN
	return _h3(Z3 - z)


# ---- 만들기 ----
func _slab(p0: Vector3, p1: Vector3, width: float, thick: float, col: Color, ext: float, above := false) -> MeshInstance3D:
	var dir := p1 - p0
	var bs := Basis.looking_at(dir.normalized(), Vector3.UP)
	var m := box(Vector3.ZERO, Vector3.ONE, col)
	m.basis = bs
	m.scale = Vector3(width, thick, dir.length() + ext)
	m.position = (p0 + p1) * 0.5 + bs.y.normalized() * thick * (0.5 if above else -0.5)
	return m


func _build() -> void:
	# 구역 1: 신전길
	for i in N1.size() - 1:
		var a: Array = N1[i]
		var b: Array = N1[i + 1]
		var p0 := Vector3(float(a[0]), float(a[2]), float(a[1]))
		var p1 := Vector3(float(b[0]), float(b[2]), float(b[1]))
		var hw := float(a[3])
		var br := i == BRIDGE_SEG
		var ext := 0.4 if br else hw * 1.2
		var m := _slab(p0, p1, hw * 2.0, 0.6 if br else 3.0, A if br else STONE, ext)
		var up := m.basis.y.normalized()
		var rt := m.basis.x.normalized()
		for sd: float in [-1.0, 1.0]:
			var e := box(Vector3.ZERO, Vector3.ONE, WHITE)
			e.basis = m.basis.orthonormalized()
			e.scale = Vector3(0.4, 0.1, (p1 - p0).length() + ext)
			e.position = (p0 + p1) * 0.5 + rt * sd * (hw - 0.2) + up * 0.04
	for az: float in ARCH_Z:
		var ax := 0.0
		var ahw := 6.0
		for i in N1.size() - 1:
			var z0 := float(N1[i][1])
			var z1 := float(N1[i + 1][1])
			if az <= z0 and az >= z1:
				ax = lerpf(float(N1[i][0]), float(N1[i + 1][0]), (az - z0) / (z1 - z0))
				ahw = float(N1[i][3])
				break
		var ah := _g(ax, az)
		for sd: float in [-1.0, 1.0]:
			box(Vector3(ax + sd * (ahw + 0.6), ah + (CLEAR + 1.2) * 0.5, az), Vector3(0.8, CLEAR + 1.2, 0.8), D)
		box(Vector3(ax, ah + CLEAR + 0.5, az), Vector3(ahw * 2.0 + 2.0, 1.0, 0.8), D)
	box(Vector3(-20, -30, -240), Vector3(320, 1, 560), WATER)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var made := 0
	for k in 120:
		if made >= 40:
			break
		var x := rng.randf_range(-100.0, 60.0)
		var z := rng.randf_range(-470.0, 20.0)
		var r := _near1(x, z)
		if float(r[0]) < float(r[2]) + 6.0:
			continue
		var top := float(r[1]) + rng.randf_range(-8.0, 16.0)
		var sw := rng.randf_range(5.0, 11.0)
		box(Vector3(x, (top - 30.0) * 0.5, z), Vector3(sw, top + 30.0, sw), [ROCK, STONE, WHITE][made % 3])
		made += 1
	# 구역 2: 수로 (옆모습)
	for i in K2.size() - 1:
		var d0 := float(K2[i][0])
		var d1 := float(K2[i + 1][0])
		if d1 - d0 < 0.01 or _pool((d0 + d1) * 0.5) >= 0:
			continue
		var p0 := Vector3(0, float(K2[i][1]), Z2 - d0)
		var p1 := Vector3(0, float(K2[i + 1][1]), Z2 - d1)
		_slab(p0, p1, 7.0, 8.0, ROCK, 0.0)
		_slab(p0 + Vector3(2.9, 0.03, 0), p1 + Vector3(2.9, 0.03, 0), 0.4, 0.08, WHITE, 0.0, true)
	for pl: Array in POOLS:
		var a := float(pl[0])
		var b := float(pl[1])
		box(Vector3(0, float(pl[2]) - 3.0, Z2 - (a + b) * 0.5), Vector3(7.0, 6.0, b - a), WATER)
	for pp: Array in PIPES:
		var a := float(pp[0])
		var b := float(pp[1])
		_slab(Vector3(0, _p2(a) + CLEAR, Z2 - a), Vector3(0, _p2(b) + CLEAR, Z2 - b), 7.0, 3.0, C, 0.0, true)
	for st: float in STEPS:
		box(Vector3(0, _p2(st) - STEP_H * 0.5, Z2 - st + 0.15), Vector3(7.2, STEP_H, 0.3), D)
	var dd := 0.0
	while dd < 380.0:
		if _pool(dd) < 0:
			box(Vector3(-4.5, _p2(dd) + 2.0, Z2 - dd), Vector3(0.6, 4.0, 0.6), WHITE)
		dd += 12.0
	# 구역 3: 광장 (위에서)
	var q0 := Vector3(0, H3, Z3)
	var q1 := Vector3(0, _h3(140.0), Z3 - 140.0)
	var q2 := Vector3(0, _h3(200.0), ZEND)
	_slab(q0, q1, 50.0, 3.0, SOFT, 0.0)
	_slab(q1, q2, 50.0, 3.0, SOFT, 0.0)
	var ld := 10.0
	while ld < 200.0:
		box(Vector3(0, _h3(ld) + 0.03, Z3 - ld), Vector3(50.0, 0.06, 0.3), ROCK)
		ld += 10.0
	for sd: float in [-1.0, 1.0]:
		_slab(q0 + Vector3(sd * 24.8, 0.03, 0), q1 + Vector3(sd * 24.8, 0.03, 0), 0.4, 0.08, WHITE, 0.0, true)
		_slab(q1 + Vector3(sd * 24.8, 0.03, 0), q2 + Vector3(sd * 24.8, 0.03, 0), 0.4, 0.08, WHITE, 0.0, true)
	lane_marks.clear()
	lane_info.clear()
	for ln: Array in LANES:
		var a := float(ln[0])
		var b := float(ln[1])
		_slab(Vector3(0, _h3(a) + 0.02, Z3 - a), Vector3(0, _h3(b) + 0.02, Z3 - b), 50.0, 0.05, B, 0.0, true)
		for k in 5:
			var mz := Z3 - lerpf(a + 3.0, b - 3.0, k / 4.0)
			var mk := box(Vector3(0, _h3(Z3 - mz) + 0.2, mz), Vector3(2.4, 0.15, 0.6), WHITE)
			lane_marks.append(mk)
			lane_info.append(Vector3(k * 10.0, float(ln[2]), 0.0))
	pillars.clear()
	for p: Vector2 in PILLARS3:
		var z := Z3 - p.y
		var h := _h3(p.y)
		box(Vector3(p.x, h + 3.0, z), Vector3(2.4, 6.0, 2.4), WHITE)
		box(Vector3(p.x, h + 6.2, z), Vector3(2.8, 0.4, 2.8), D)
		pillars.append(Vector2(p.x, z))
	var eh := _h3(200.0)
	box(Vector3((-25.0 + GATE_X - 3.6) * 0.5, eh + 1.5, ZEND), Vector3(GATE_X - 3.6 + 25.0, 3.0, 1.0), ROCK)
	box(Vector3((25.0 + GATE_X + 3.6) * 0.5, eh + 1.5, ZEND), Vector3(25.0 - GATE_X - 3.6, 3.0, 1.0), ROCK)
	for sd: float in [-1.0, 1.0]:
		box(Vector3(GATE_X + sd * 4.0, eh + (CLEAR + 1.2) * 0.5, ZEND), Vector3(0.8, CLEAR + 1.2, 0.8), D)
	box(Vector3(GATE_X, eh + CLEAR + 0.5, ZEND), Vector3(8.8, 1.0, 0.8), D)
	box(Vector3(0, -150, ZEND - 110.0), Vector3(220, 1, 160), GRASS)  # 문 너머: 다음 추락 구간
	# 항아리
	pots.clear()
	for p: Vector2 in POTS1:
		_pot(p.x, p.y)
	for p: Vector2 in POTS3:
		_pot(p.x, Z3 - p.y)


func _pot(x: float, z: float) -> void:
	var pt := Pot.new()
	pt.x = x
	pt.z = z
	pt.base = _g(x, z)
	if is_nan(pt.base):
		pt.base = 0.0
	pt.n = box(Vector3(x, pt.base + 0.7, z), Vector3(1.4, 1.4, 1.4), [A, C, B][pots.size() % 3])
	pots.append(pt)


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	hurt -= dt
	brake_cd -= dt
	brake_t -= dt
	shake = maxf(0.0, shake - dt * 1.5)
	if fallen:
		fall_t += dt
		if fall_mode == 1:
			vy -= FALL * dt
			by += vy * dt
			px += -sin(hd) * v * dt
			pz += -cos(hd) * v * dt
			v *= 0.98
		elif fall_mode == 2:
			by -= 1.5 * dt
			v *= 0.9
		_place(dt)
		if fall_t > 1.1:
			end()
		return
	if kit_just("brake") and brake_cd <= 0.0:
		v *= BRAKE
		brake_cd = 0.45
		brake_t = 0.3
		beep(300.0, 0.12, 120.0, 0.28)
		msg("세움!", 0.4)
	var zn := 1 if pz > Z2 else (2 if pz > Z3 else 3)
	if zn != zone:
		zone = zn
		hd_goal = 0.0
		bonus += 100
		play("good")
		msg("옆모습: 수로" if zone == 2 else "위에서: 광장", 1.6)
	# 몸 모양 = 속도
	var ft := clampf((v - V_ROUND) / (V_FLAT - V_ROUND), 0.0, 1.0)
	fl = lerpf(fl, ft, minf(1.0, dt * (14.0 if brake_t > 0.0 else 6.0)))
	bh = lerpf(H0, H1, fl)
	bw = lerpf(W0, W1, fl)
	bl = lerpf(L0, L1, fl)
	var now_flat := bh < CLEAR
	if now_flat != was_flat:
		was_flat = now_flat
		if now_flat:
			beep(500.0, 0.1, 1100.0, 0.2)
		else:
			beep(1100.0, 0.1, 500.0, 0.16)
	# 방향: 원반일수록 안 돈다. 수로에서는 곧게.
	var lean_acc := 0.0
	if zone == 2:
		hd = lerpf(hd, 0.0, minf(1.0, dt * 5.0))
		hd_goal = hd
		px = lerpf(px, 0.0, minf(1.0, dt * 5.0))
		lat_v = 0.0
		if held:
			var ln := clampf((drag_x - press_x) / 160.0, -1.0, 1.0)
			lean_acc = ln * (3.0 if ln > 0.0 else 5.0)
	else:
		hd_goal = clampf(hd_goal, hd - 1.4, hd + 1.4)
		hd = move_toward(hd, hd_goal, lerpf(2.6, 0.35, fl) * dt)
	var fx := -sin(hd)
	var fz := -cos(hd)
	# 속도
	if on_ground:
		var g0 := _g(px, pz)
		var ga := _g(px + fx * 0.6, pz + fz * 0.6)
		var sl := 0.0 if is_nan(g0) or is_nan(ga) else (ga - g0) / 0.6
		v += (-sl * GRV - ROLL - DRAG * v * v + lean_acc) * dt
		v = maxf(v, 0.0)
	else:
		v -= DRAG * 0.3 * v * v * dt
	# 옆바람: 원반일수록 크게 밀린다
	wind_now = _wind()
	lat_v += wind_now * lerpf(0.12, 1.3, fl) * dt
	lat_v *= exp(-2.0 * dt)
	var ox := px
	var oz := pz
	px += fx * v * dt + lat_v * dt
	pz += fz * v * dt
	travel += v * dt
	_features(ox, oz, fx, fz)
	if fallen or over:
		_place(dt)
		return
	# 위아래
	vy -= FALL * dt
	by += vy * dt
	var g := _g(px, pz)
	var pi := _pool(Z2 - pz) if zone == 2 else -1
	if pi >= 0:
		var wh := float(POOLS[pi][2])
		last_g = wh
		on_ground = false
		if by <= wh:
			if fl >= SKIP_F and v >= SKIP_V:
				by = wh
				vy = 2.2 + v * 0.06
				v *= 0.95
				bonus += 3
				beep(700.0 + v * 10.0, 0.06, 1200.0, 0.22)
				msg("통!", 0.3)
			else:
				_die("가라앉음", 2)
	elif is_nan(g):
		on_ground = false
		if by < last_g - 2.0:
			_die("떨어짐!", 1)
	elif by <= g:
		if by < g - 1.4:
			_die("쾅!", 1)
		else:
			if not on_ground and vy < -8.0:
				beep(90.0, 0.14, 50.0, 0.3)
				shake = maxf(shake, 0.2)
			var ga2 := _g(px + fx * 0.6, pz + fz * 0.6)
			by = g
			vy = 0.0 if is_nan(ga2) else v * (ga2 - g) / 0.6
			on_ground = true
			last_g = g
	else:
		on_ground = false
		last_g = g
	if fallen:
		_place(dt)
		return
	# 멈춤 검사
	if on_ground and v < VSTOP:
		slow_t += dt
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = 0.3
			beep(260.0, 0.1, 200.0, 0.25)
			msg("느려!", 0.35)
		if slow_t > STOP_T:
			msg("멈췄다", 2.0)
			end()
			return
	else:
		slow_t = 0.0
		warn_t = 0.0
	score = int(travel) + bonus
	var col := GOOD
	if v < VSTOP:
		col = BAD
	elif now_flat:
		col = B
	gauge(v / VMAX, col)
	_place(dt)


func _wind() -> float:
	if zone == 1:
		if pz < float(N1[BRIDGE_SEG][1]) + 4.0 and pz > float(N1[BRIDGE_SEG + 1][1]):
			var cyc := int(clock / 3.2)
			var ph := fmod(clock, 3.2)
			var sd := 1.0 if cyc % 2 == 0 else -1.0
			if ph > 2.4 and gust_warned != cyc:
				gust_warned = cyc
				beep(180.0, 0.4, 260.0, 0.2)
				msg("← 바람" if sd > 0.0 else "바람 →", 0.7)
			if ph < 1.3:
				return WIND_A * sd
		return 0.0
	if zone == 3:
		var d3 := Z3 - pz
		for ln: Array in LANES:
			if d3 > float(ln[0]) and d3 < float(ln[1]):
				return WIND_A * float(ln[2])
	return 0.0


## 아치·관·턱·문·기둥·항아리
func _features(ox: float, oz: float, fx: float, fz: float) -> void:
	if zone == 1:
		for az: float in ARCH_Z:
			if oz > az and pz <= az:
				if bh >= CLEAR:
					_bonk(ox - fx * 0.6, oz - fz * 0.6, 0.25, "아치에 쿵!")
					return
				bonus += 10
				beep(1000.0, 0.08, 1500.0, 0.22)
				msg("슉!", 0.3)
	elif zone == 2:
		var od := Z2 - oz
		var d := Z2 - pz
		for st: float in STEPS:
			if od < st and d >= st:
				if bh >= STEP_NEED:
					v *= 0.72
					by = _p2(d)
					vy = 0.0
					bonus += 10
					beep(160.0, 0.12, 300.0, 0.3)
					msg("턱!", 0.4)
				else:
					_bonk(0.0, Z2 - (st - 0.8), 0.15, "턱에 걸림")
					return
		for pp: Array in PIPES:
			var a := float(pp[0])
			var b := float(pp[1])
			if od < a and d >= a and bh >= CLEAR:
				_bonk(0.0, Z2 - (a - 1.0), 0.2, "관에 쿵!")
				return
			if d > a and d < b and bh > CLEAR + 0.08:
				_die("끼임!", 0)
				return
	else:
		if oz > ZEND and pz <= ZEND:
			if absf(px - GATE_X) < 3.6:
				if bh < CLEAR:
					won = true
					bonus += 500
					score = int(travel) + bonus
					msg("광장 통과! 다음: 추락", 2.5)
					end()
					return
				_bonk(ox, oz + 0.8, 0.25, "문에 쿵!")
			else:
				_bonk(ox, oz + 0.8, 0.25, "벽!")
			return
		for p in pillars:
			var me2 := Vector2(px, pz)
			var r := 1.2 + bw * 0.5
			if me2.distance_to(p) < r:
				var n := (me2 - p).normalized()
				px = p.x + n.x * (r + 0.05)
				pz = p.y + n.y * (r + 0.05)
				if hurt <= 0.0:
					v *= 0.35
					hurt = 0.5
					shake = 0.4
					play("bad")
					msg("쿵!", 0.5)
	for pt in pots:
		if pt.flat:
			continue
		if absf(pt.z - pz) < bl * 0.5 + 0.7 and absf(pt.x - px) < bw * 0.5 + 0.7 and by < pt.base + 1.2:
			pt.flat = true
			pt.n.scale.y = 0.15
			pt.n.position.y = pt.base + 0.08
			v *= 0.86
			bonus += 5
			beep(480.0, 0.1, 110.0, 0.26)


func _bonk(bx: float, bz: float, keep: float, text: String) -> void:
	px = bx
	pz = bz
	v *= keep
	hurt = 0.5
	shake = 0.45
	play("bad")
	msg(text, 0.6)


func _die(text: String, mode: int) -> void:
	fallen = true
	fall_mode = mode
	fall_t = 0.0
	if mode == 0:
		v = 0.0
	else:
		v = minf(v, 8.0)
	msg(text, 2.0)
	beep(400.0, 0.6, 60.0, 0.3)


func _place(dt: float) -> void:
	pivot.position = Vector3(px, by, pz)
	pivot.rotation.y = hd
	body.scale = Vector3(bw, bh, bl)
	body.position = Vector3(0, bh * 0.5, 0)
	body.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else ME)
	roll_ph += v * dt * 0.5
	for k in stripes.size():
		var s := stripes[k]
		s.scale = Vector3(bw * 1.04, bh * 1.04, 0.25)
		s.position = Vector3(0, bh * 0.5, fposmod(roll_ph + k * bl * 0.5, bl) - bl * 0.5)
	# 구르는 소리: 빠를수록 촘촘하고, 원반이면 높다
	roll_acc += v * dt
	if roll_acc > 3.5 and on_ground and not fallen:
		roll_acc = 0.0
		beep(clampf(60.0 + v * 2.0 + fl * 60.0, 50.0, 260.0), 0.04, 45.0, 0.1)
	# 바람 줄
	var sd := signf(wind_now)
	for k in streaks.size():
		var st := streaks[k]
		st.visible = sd != 0.0 and not fallen
		if st.visible:
			st.position = Vector3(px + fposmod(k * 7.3 + clock * 30.0 * sd, 24.0) - 12.0, by + 0.5 + (k % 3) * 0.9, pz + 6.0 - k * 2.5)
	for k in lane_marks.size():
		var info := lane_info[k]
		lane_marks[k].position.x = fposmod(info.x + clock * 9.0 * info.y, 50.0) - 25.0
	# 카메라: 구역마다 시점이 바뀐다
	cam_hd = lerp_angle(cam_hd, hd, minf(1.0, dt * 3.0))
	var P := Vector3(px, by, pz)
	var f3 := Vector3(-sin(cam_hd), 0, -cos(cam_hd))
	var want: Vector3
	var look: Vector3
	var fov := 55.0
	match zone:
		1:
			want = P - f3 * (8.0 + v * 0.12) + Vector3(0, 3.5 + bh, 0)
			look = P + f3 * 14.0 + Vector3(0, -0.5, 0)
			fov = clampf(55.0 + v * 0.6, 55.0, 88.0)
		2:
			want = P + Vector3(15.0 + v * 0.18, 2.5, -7.0)
			look = P + Vector3(0, 0.6, -7.0)
			fov = 50.0 + v * 0.3
		_:
			want = P + Vector3(0, 28.0 + v * 0.35, 9.0)
			look = P + Vector3(0, 0, -6.0)
			fov = 50.0
	var k2 := minf(1.0, dt * 4.0)
	if not (fallen and fall_mode == 1):
		cam_base = cam_base.lerp(want, k2)
	cam_look = cam_look.lerp(look, k2)
	var off := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * shake * 0.6
	cam.position = cam_base + off
	if cam.position.distance_to(cam_look) > 0.1:
		cam.look_at(cam_look)
	cam.fov = lerpf(cam.fov, fov, minf(1.0, dt * 2.5))


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	drag_x = p.x
	press_x = p.x


func _drag(p: Vector2) -> void:
	if zone != 2:
		hd_goal -= (p.x - drag_x) * 0.008
	drag_x = p.x


func _lift(p: Vector2) -> void:
	drag_x = p.x
	press_x = p.x


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)
