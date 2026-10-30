extends Tofu
## 늘어나는 돌 v3: 신전 돌이 저절로 구른다. 파랑=빨라야(납작) 지남, 주황=느려야(둥글게) 지남, 꼭대기 등이 초록이면 지금 몸으로 지난다. 둥근 채 파랑에 박히면 뒤로 튕겨 도움닫기부터 다시. 빠를수록 납작한 원반(낮고 좁고 길게), 느릴수록 둥근 공. 버튼 = 세우기(급제동). 끌기의 뜻·시점이 구역마다 바뀐다. 깃발을 지나면 죽어도 거기서 다시.
## 1 등뒤 신전길: 끌기=방향(손 떼면 길을 따라감). 아치는 납작해야, 커브는 둥글어야, 다리 바람은 원반을 날린다. 2 옆모습 수로: 끌기=기울이기, 물은 원반만 튕기고 턱은 공만 넘는다. 3 위에서 광장: 바람 띠 사이로 낮은 문에. 4 추락: 원반은 멀리 활강, 세우면 공이 되어 뚝(너무 높으면 깨짐). 5 1인칭 성문 터널: 오르내리는 창살 밑을 몸 높이로 통과.
# 한 문장: 나는 신전에서 풀려난 돌로서 빠를수록 납작한 원반이 되는 몸으로 굴러 신전 밖으로 탈출하지만, 빨라질수록 꺾이지 않고 바람에 날리며 턱에 걸리는 대가를 감수한다.

const STONE := Color("efe1c4")
const ROCK := Color("e0c896")
const GRASS := Color("8ce99a")
const WATER := Color("a5d8ff")
const HILL := Color("b2f2bb")
const LILAC := Color("d0bfff")
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
const BR_WIND := 6.0  # 다리 바람 (너그럽게)
const TURN0 := 2.6  # 공의 회전 속도
const TURN1 := 0.45  # 원반의 회전 속도
const ASSIST := 1.6  # 손 떼면 길 쪽으로 도는 속도
const STEER := 0.007  # 끌기 1px 당 방향
const BREAK_V := 27.0  # 이보다 빨리 떨어져 닿으면 깨짐
const Z2 := -480.0  # 수로 시작
const Z3 := -860.0  # 광장 시작
const ZEND := -1060.0  # 광장 문 = 추락 구간 시작
const Z5 := -1290.0  # 성문 터널 시작
const L5 := 300.0  # 터널 길이
const E4 := -53.0  # 광장 문 높이 (= _h3(200))
const GATE_X := 10.0
# 구역 1 신전길: [x, z, 높이, 다음 점까지 반폭]. z는 계속 줄어든다.
const N1 := [
	[0.0, 20.0, 42.0, 7.5], [0.0, -60.0, 32.5, 7.5], [0.0, -128.0, 31.0, 7.5],
	[-40.0, -156.0, 28.0, 7.5], [-50.0, -200.0, 25.0, 7.5], [-50.0, -250.0, 15.0, 7.5],
	[-12.0, -288.0, 10.0, 7.5], [0.0, -305.0, 8.5, 3.8], [0.0, -385.0, 2.0, 7.5],
	[0.0, -410.0, 2.5, 7.5], [0.0, -460.0, -4.5, 5.0], [0.0, -480.0, -5.0, 5.0],
]
const BRIDGE_SEG := 7
const ARCH_Z := [-75.0, -212.0, -224.0, -455.0]
const CORNER_Z := [-128.0, -250.0]  # 노란 띠(둥글게) 표시
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
	Vector2(4.5, -110), Vector2(4.5, -116), Vector2(4.5, -122),
	Vector2(-45.5, -236), Vector2(-45.5, -241), Vector2(-45.5, -246),
]
const POTS3 := [
	Vector2(-5, 20), Vector2(5, 25), Vector2(0, 70), Vector2(-10, 80), Vector2(8, 90),
	Vector2(12, 150), Vector2(9, 155), Vector2(11, 160),
]
# 구역 4 추락 (정면 아래로): 떠 있는 섬 [문에서 거리 시작, 끝, x, 시작 높이, 반폭, 내리막, 꽂기(1=가깝고 낮음)]
const ISL := [
	[10.0, 40.0, 10.0, E4 - 4.0, 6.0, 0.10, 0],
	[56.0, 82.0, 6.0, E4 - 15.0, 5.5, 0.12, 0],
	[88.0, 104.0, 4.0, E4 - 24.0, 5.0, 0.40, 1],
	[112.0, 150.0, 0.0, E4 - 34.5, 5.5, 0.15, 0],
	[157.0, 171.0, 0.0, E4 - 47.0, 5.0, 0.40, 1],
	[173.0, 230.0, 0.0, E4 - 54.0, 5.0, 0.08, 0],
]
# 구역 5 성문 터널 (1인칭): 창살 [거리, 주기, 위상], 턱 거리
const GATES5 := [[35.0, 2.6, 0.0], [75.0, 3.0, 1.5], [112.0, 2.4, 3.0], [155.0, 2.8, 0.7], [198.0, 3.2, 2.2], [240.0, 2.5, 4.0], [278.0, 2.2, 1.0]]
const STEPS5 := [50.0, 132.0, 218.0, 258.0]
const GAP0 := 0.95  # 창살 밑 틈: 가장 낮을 때 (완전한 원반만)
const GAP1 := 3.0  # 가장 높을 때 (공도 지남)
# 깃발(체크포인트): [구역, x, z, 시작 속도]. 지나면 죽어도 여기서 다시.
const CPS := [
	[1, 0.0, 10.0, 14.0], [1, 0.0, -88.0, 18.0], [1, -50.0, -190.0, 20.0], [1, -9.0, -291.0, 11.0],
	[2, 0.0, Z2 - 2.0, 20.0], [3, 0.0, Z3 - 2.0, 16.0], [4, GATE_X, ZEND - 1.0, 23.0], [5, 0.0, Z5 - 2.0, 18.0], [5, 0.0, Z5 - 140.0, 18.0],
]
const SKY := ["d8eeff", "d8eeff", "c5f6fa", "fff3bf", "d0ebff", "e5dbff"]
const ZNAME := ["", "등뒤: 신전길", "옆모습: 수로", "위에서: 광장", "추락: 떠 있는 섬", "1인칭: 성문 터널"]


class Pot:
	var n: MeshInstance3D
	var x := 0.0
	var z := 0.0
	var base := 0.0
	var flat := false
	var zn := 1


var pivot: Node3D
var body: MeshInstance3D
var stripes: Array[MeshInstance3D] = []
var streaks: Array[MeshInstance3D] = []
var speedl: Array[MeshInstance3D] = []
var debris: Array[MeshInstance3D] = []
var deb_v: Array[Vector3] = []
var deb_t: Array[float] = []
var deb_i := 0
var lane_marks: Array[MeshInstance3D] = []
var lane_info: Array[Vector3] = []
var clouds: Array[MeshInstance3D] = []
var cloud_x: Array[float] = []
var bars: Array[MeshInstance3D] = []  # 터널 창살 판
var pots: Array[Pot] = []
var lamp_n: Array[MeshInstance3D] = []  # 장애물 등: 지금 몸이면 지나는지 (초록/빨강)
var lamp_k: Array[int] = []  # 0 납작해야, 1 둥글어야
var lamp_zn: Array[int] = []
var build_zn := 1
var pillars: Array[Vector2] = []
var zroots := {}
var zroot: Node3D
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
var squash := 0.0
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
var tips := {}
var bar_gate := -1  # 같은 창살에 세 번 박히면 끼임
var bar_hits := 0
var free_t := 0.0
# 깃발: 판을 다시 시작해도 남는다
var cp_i := 0
var cp_travel := 0.0
var cp_bonus := 0


func _setup() -> void:
	howto = "돌은 저절로 구른다. 빠를수록 납작한 원반, 느릴수록 둥근 공.\n파랑(아치·관·문)은 빨라야(납작), 주황(커브·턱)은 느려야(둥글게) 지난다. 꼭대기 등이 초록이면 지금 몸으로 지난다.\n끌기: 방향(손 떼면 길을 따라감, 옆모습·터널에선 앞뒤 기울이기). 세우기: 급제동.\n1.5초 넘게 느리거나 떨어지면 끝. 깃발부터 다시."
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
	if won:
		cp_i = 0
		cp_travel = 0.0
		cp_bonus = 0
	var cp: Array = CPS[cp_i]
	zone = int(cp[0])
	px = float(cp[1])
	pz = float(cp[2])
	v = float(cp[3])
	hd = _dir1(pz) if zone == 1 else 0.0
	hd_goal = hd
	cam_hd = hd
	vy = 0.0
	lat_v = 0.0
	fl = clampf((v - V_ROUND) / (V_FLAT - V_ROUND), 0.0, 1.0)
	bh = lerpf(H0, H1, fl)
	bw = lerpf(W0, W1, fl)
	bl = lerpf(L0, L1, fl)
	was_flat = bh < CLEAR
	squash = 0.0
	fallen = false
	fall_mode = 0
	fall_t = 0.0
	slow_t = 0.0
	warn_t = 0.0
	hurt = 0.0
	shake = 0.0
	brake_cd = 0.0
	brake_t = 0.0
	travel = cp_travel
	bonus = cp_bonus
	won = false
	clock = 0.0
	roll_ph = 0.0
	roll_acc = 0.0
	gust_warned = -1
	wind_now = 0.0
	tips.clear()
	bar_gate = -1
	bar_hits = 0
	free_t = 0.0
	zroots.clear()
	pots.clear()
	lamp_n.clear()
	lamp_k.clear()
	lamp_zn.clear()
	pillars.clear()
	lane_marks.clear()
	lane_info.clear()
	clouds.clear()
	cloud_x.clear()
	bars.clear()
	_ensure(zone)
	_ensure(zone + 1)
	if zone == 4:
		by = E4
		on_ground = false
	else:
		by = _g(px, pz)
		on_ground = true
	last_g = by
	pivot = Node3D.new()
	world.add_child(pivot)
	pivot.visible = zone != 5
	body = box(Vector3(0, H0 * 0.5, 0), Vector3(W0, H0, L0), ME, pivot)
	stripes.clear()
	for k in 2:
		stripes.append(box(Vector3.ZERO, Vector3.ONE, WHITE, pivot))
	streaks.clear()
	for k in 8:
		var s := box(Vector3.ZERO, Vector3(3.0, 0.12, 0.12), WHITE)
		s.visible = false
		streaks.append(s)
	speedl.clear()
	for k in 6:
		var s := box(Vector3.ZERO, Vector3(0.1, 0.1, 3.0), WHITE)
		s.visible = false
		speedl.append(s)
	debris.clear()
	deb_v.clear()
	deb_t.clear()
	for k in 12:
		var d := box(Vector3.ZERO, Vector3(0.45, 0.45, 0.45), STONE)
		d.visible = false
		debris.append(d)
		deb_v.append(Vector3.ZERO)
		deb_t.append(0.0)
	_sky()
	var f3 := Vector3(-sin(hd), 0, -cos(hd))
	cam_base = Vector3(px, by, pz) - f3 * 10.0 + Vector3(0, 6.0, 0)
	cam_look = Vector3(px, by, pz) + f3 * 14.0
	cam.position = cam_base
	cam.fov = 60.0
	if cp_i == 0:
		msg("끌기 = 방향\n빠를수록 납작!", 2.2)
	else:
		msg("깃발부터 다시", 1.4)


func _sky() -> void:
	for c in get_children():
		if c is WorldEnvironment:
			(c as WorldEnvironment).environment.background_color = Color(SKY[zone])


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


## 구역 1에서 z 위치의 길 가운데 x
func _x1(z: float) -> float:
	for i in N1.size() - 1:
		var z0 := float(N1[i][1])
		var z1 := float(N1[i + 1][1])
		if z <= z0 and z >= z1:
			return lerpf(float(N1[i][0]), float(N1[i + 1][0]), (z - z0) / (z1 - z0))
	return 0.0


## 구역 1에서 z 위치의 길 방향
func _dir1(z: float) -> float:
	for i in N1.size() - 1:
		if z <= float(N1[i][1]) and z >= float(N1[i + 1][1]):
			return atan2(-(float(N1[i + 1][0]) - float(N1[i][0])), -(float(N1[i + 1][1]) - float(N1[i][1])))
	return 0.0


## 길을 따라 ahead 만큼 앞 점 (손 뗐을 때 따라가는 곳)
func _aim1(ahead: float) -> Vector2:
	var r := _near1(px, pz)
	var i := int(r[3])
	var a := Vector2(float(N1[i][0]), float(N1[i][1]))
	var b := Vector2(float(N1[i + 1][0]), float(N1[i + 1][1]))
	var ab := b - a
	var p := a + ab * clampf((Vector2(px, pz) - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	var left := ahead
	while i < N1.size() - 1:
		b = Vector2(float(N1[i + 1][0]), float(N1[i + 1][1]))
		var seg := p.distance_to(b)
		if seg >= left:
			return p + (b - p).normalized() * left
		left -= seg
		p = b
		i += 1
	return p + Vector2(0, -left)


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


## 섬 i 위 d4 지점 높이
func _ih(i: int, d4: float) -> float:
	var s: Array = ISL[i]
	return float(s[3]) - (d4 - float(s[0])) * float(s[5])


## 터널 바닥 (턱을 지날 때마다 0.9 높아짐)
func _p5(d5: float) -> float:
	var last: Array = ISL[ISL.size() - 1]
	var y := _ih(ISL.size() - 1, float(last[1])) - d5 * 0.10
	for st: float in STEPS5:
		if d5 >= st:
			y += STEP_H
	return y


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
	if z >= ZEND:
		return NAN if absf(x) > 25.0 else _h3(Z3 - z)
	if z > Z5:
		var d4 := ZEND - z
		for i in ISL.size():
			var s: Array = ISL[i]
			if d4 >= float(s[0]) and d4 <= float(s[1]) and absf(x - float(s[2])) <= float(s[4]):
				return _ih(i, d4)
		return NAN
	return NAN if absf(x) > 3.5 or z < Z5 - L5 - 30.0 else _p5(Z5 - z)


func _zone_at(z: float) -> int:
	if z > Z2:
		return 1
	if z > Z3:
		return 2
	if z > ZEND:
		return 3
	if z > Z5:
		return 4
	return 5


# ---- 만들기 (구역마다 짓고, 지나면 해제) ----
func bx(p: Vector3, s: Vector3, col: Color) -> MeshInstance3D:
	return box(p, s, col, zroot)


## 장애물 위 등. kind 0 = 납작해야 지남, 1 = 둥글어야 지남. 매 프레임 지금 몸으로 지나면 초록.
func _lamp(p: Vector3, s: Vector3, kind: int) -> void:
	lamp_n.append(bx(p, s, GOOD))
	lamp_k.append(kind)
	lamp_zn.append(build_zn)


func _slab(p0: Vector3, p1: Vector3, width: float, thick: float, col: Color, ext: float, above := false) -> MeshInstance3D:
	var dir := p1 - p0
	var bs := Basis.looking_at(dir.normalized(), Vector3.UP)
	var m := bx(Vector3.ZERO, Vector3.ONE, col)
	m.basis = bs
	m.scale = Vector3(width, thick, dir.length() + ext)
	m.position = (p0 + p1) * 0.5 + bs.y.normalized() * thick * (0.5 if above else -0.5)
	return m


func _ensure(n: int) -> void:
	if n < 1 or n > 5 or zroots.has(n):
		return
	zroot = Node3D.new()
	world.add_child(zroot)
	zroots[n] = zroot
	build_zn = n
	match n:
		1: _build1()
		2: _build2()
		3: _build3()
		4: _build4()
		5: _build5()


func _free(n: int) -> void:
	if not zroots.has(n):
		return
	(zroots[n] as Node3D).queue_free()
	zroots.erase(n)
	var keep: Array[Pot] = []
	for pt in pots:
		if pt.zn != n:
			keep.append(pt)
	pots = keep
	for i in range(lamp_n.size() - 1, -1, -1):
		if lamp_zn[i] == n:
			lamp_n.remove_at(i)
			lamp_k.remove_at(i)
			lamp_zn.remove_at(i)
	if n == 3:
		pillars.clear()
		lane_marks.clear()
		lane_info.clear()
	elif n == 4:
		clouds.clear()
		cloud_x.clear()


func _build1() -> void:
	for i in N1.size() - 1:
		var a: Array = N1[i]
		var b: Array = N1[i + 1]
		var p0 := Vector3(float(a[0]), float(a[2]), float(a[1]))
		var p1 := Vector3(float(b[0]), float(b[2]), float(b[1]))
		var hw := float(a[3])
		var br := i == BRIDGE_SEG
		var ext := 0.4 if br else hw * 1.2
		var m := _slab(p0, p1, hw * 2.0, 0.6 if br else 3.0, A if br else STONE, ext)  # 다리 = 주황(둥글게 버텨)
		var up := m.basis.y.normalized()
		var rt := m.basis.x.normalized()
		for sd: float in [-1.0, 1.0]:
			var e := bx(Vector3.ZERO, Vector3.ONE, WHITE)
			e.basis = m.basis.orthonormalized()
			e.scale = Vector3(0.4, 0.1, (p1 - p0).length() + ext)
			e.position = (p0 + p1) * 0.5 + rt * sd * (hw - 0.2) + up * 0.04
		if br:  # 다리 판자 줄무늬 = 속도 눈금
			var zz := float(a[1]) - 5.0
			while zz > float(b[1]):
				bx(Vector3(0, _g(0, zz) + 0.04, zz), Vector3(hw * 2.0, 0.08, 0.5), WHITE)
				zz -= 10.0
	for az: float in ARCH_Z:
		var ax := _x1(az)
		var ahw := float(_near1(ax, az)[2])
		var ah := _g(ax, az)
		for sd: float in [-1.0, 1.0]:
			bx(Vector3(ax + sd * (ahw + 0.6), ah + (CLEAR + 1.2) * 0.5, az), Vector3(0.8, CLEAR + 1.2, 0.8), B)
		bx(Vector3(ax, ah + CLEAR + 0.5, az), Vector3(ahw * 2.0 + 2.0, 1.0, 0.8), B)  # 파랑 = 빨라야(납작해야)
		_lamp(Vector3(ax, ah + CLEAR + 1.6, az), Vector3(ahw * 2.0 + 3.0, 1.2, 1.2), 0)
	# 커브 앞 노란·흰 띠 (둥글게)
	for cz: float in CORNER_Z:
		for k in 3:
			var zz := cz + 26.0 - k * 4.0
			var xx := _x1(zz)
			bx(Vector3(xx, _g(xx, zz) + 0.05, zz), Vector3(13.0, 0.1, 1.2), A if k % 2 == 0 else WHITE)  # 주황 = 둥글어야
		var lz := cz + 26.0
		var lx := _x1(lz)
		for sd: float in [-1.0, 1.0]:
			bx(Vector3(lx + sd * 7.6, _g(lx, lz) + 1.6, lz), Vector3(0.6, 3.2, 0.6), A)
		_lamp(Vector3(lx, _g(lx, lz) + 3.6, lz), Vector3(16.0, 0.8, 0.8), 1)
	# 깃발 (구역 안 체크포인트)
	for i in range(1, CPS.size()):
		var cp: Array = CPS[i]
		if int(cp[0]) != 1:
			continue
		var cz := float(cp[2])
		var cx := _x1(cz) + 8.5
		var gy := _g(_x1(cz), cz)
		bx(Vector3(cx, gy + 2.5, cz), Vector3(0.3, 5.0, 0.3), WHITE)
		bx(Vector3(cx - 1.0, gy + 4.3, cz), Vector3(1.8, 1.1, 0.15), GOOD if cp_i >= i else BAD)
	# 시작 뒤 신전 기둥
	for sd: float in [-1.0, 1.0]:
		bx(Vector3(sd * 9.0, 47.0, 34.0), Vector3(2.4, 14.0, 2.4), WHITE)
	bx(Vector3(0, 55.0, 34.0), Vector3(23.0, 2.0, 4.0), D)
	# 바다와 먼 산
	bx(Vector3(-20, -30, -240), Vector3(320, 1, 560), WATER)
	var hills := [[-170.0, -150.0, 70.0, HILL], [150.0, -230.0, 90.0, LILAC], [-160.0, -380.0, 60.0, LILAC], [140.0, -470.0, 75.0, HILL], [-60.0, -620.0, 110.0, WHITE]]
	for h: Array in hills:
		bx(Vector3(float(h[0]), -30.0 + float(h[2]) * 0.5, float(h[1])), Vector3(60, float(h[2]), 60), h[3])
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var made := 0
	for k in 120:
		if made >= 30:
			break
		var x := rng.randf_range(-100.0, 60.0)
		var z := rng.randf_range(-470.0, 20.0)
		var r := _near1(x, z)
		if float(r[0]) < float(r[2]) + 6.0:
			continue
		var top := float(r[1]) + rng.randf_range(-8.0, 16.0)
		var sw := rng.randf_range(5.0, 11.0)
		bx(Vector3(x, (top - 30.0) * 0.5, z), Vector3(sw, top + 30.0, sw), [ROCK, STONE, WHITE][made % 3])
		made += 1
	for p: Vector2 in POTS1:
		_pot(p.x, p.y, 1)


func _build2() -> void:
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
		bx(Vector3(0, float(pl[2]) - 3.0, Z2 - (a + b) * 0.5), Vector3(7.0, 6.0, b - a), WATER)
	for pp: Array in PIPES:
		var a := float(pp[0])
		var b := float(pp[1])
		_slab(Vector3(0, _p2(a) + CLEAR, Z2 - a), Vector3(0, _p2(b) + CLEAR, Z2 - b), 7.0, 3.0, B, 0.0, true)
		_lamp(Vector3(0, _p2(a) + CLEAR + 3.6, Z2 - a), Vector3(7.2, 1.2, 1.2), 0)
	for st: float in STEPS:
		bx(Vector3(0, _p2(st) - STEP_H * 0.5, Z2 - st + 0.15), Vector3(7.2, STEP_H, 0.3), A)
		_lamp(Vector3(-4.5, _p2(st) + 4.6, Z2 - st), Vector3(1.4, 1.4, 1.4), 1)
	var dd := 0.0
	while dd < 380.0:
		if _pool(dd) < 0:
			bx(Vector3(-4.5, _p2(dd) + 2.0, Z2 - dd), Vector3(0.6, 4.0, 0.6), WHITE)
		dd += 12.0
	# 먼 수도교 실루엣 (옆모습 배경)
	var ad := 0.0
	while ad < 400.0:
		var hy := _p2(minf(ad, 379.0))
		bx(Vector3(-45.0, hy + 4.0, Z2 - ad), Vector3(4.0, 30.0, 4.0), Color("99e9f2"))
		bx(Vector3(-45.0, hy + 19.0, Z2 - ad - 15.0), Vector3(3.0, 2.0, 34.0), Color("99e9f2"))
		ad += 34.0


func _build3() -> void:
	var q0 := Vector3(0, H3, Z3)
	var q1 := Vector3(0, _h3(140.0), Z3 - 140.0)
	var q2 := Vector3(0, _h3(200.0), ZEND)
	_slab(q0, q1, 50.0, 3.0, SOFT, 0.0)
	_slab(q1, q2, 50.0, 3.0, SOFT, 0.0)
	var ld := 10.0
	while ld < 200.0:
		bx(Vector3(0, _h3(ld) + 0.03, Z3 - ld), Vector3(50.0, 0.06, 0.3), ROCK)
		ld += 10.0
	for sd: float in [-1.0, 1.0]:
		_slab(q0 + Vector3(sd * 24.8, 0.03, 0), q1 + Vector3(sd * 24.8, 0.03, 0), 0.4, 0.08, WHITE, 0.0, true)
		_slab(q1 + Vector3(sd * 24.8, 0.03, 0), q2 + Vector3(sd * 24.8, 0.03, 0), 0.4, 0.08, WHITE, 0.0, true)
	for ln: Array in LANES:
		var a := float(ln[0])
		var b := float(ln[1])
		_slab(Vector3(0, _h3(a) + 0.02, Z3 - a), Vector3(0, _h3(b) + 0.02, Z3 - b), 50.0, 0.05, LILAC, 0.0, true)  # 바람 띠
		for k in 5:
			var mz := Z3 - lerpf(a + 3.0, b - 3.0, k / 4.0)
			var mk := bx(Vector3(0, _h3(Z3 - mz) + 0.2, mz), Vector3(2.4, 0.15, 0.6), WHITE)
			lane_marks.append(mk)
			lane_info.append(Vector3(k * 10.0, float(ln[2]), 0.0))
	for p: Vector2 in PILLARS3:
		var z := Z3 - p.y
		var h := _h3(p.y)
		bx(Vector3(p.x, h + 3.0, z), Vector3(2.4, 6.0, 2.4), WHITE)
		bx(Vector3(p.x, h + 6.2, z), Vector3(2.8, 0.4, 2.8), ROCK)
		pillars.append(Vector2(p.x, z))
	var eh := _h3(200.0)
	bx(Vector3((-25.0 + GATE_X - 3.6) * 0.5, eh + 1.5, ZEND), Vector3(GATE_X - 3.6 + 25.0, 3.0, 1.0), ROCK)
	bx(Vector3((25.0 + GATE_X + 3.6) * 0.5, eh + 1.5, ZEND), Vector3(25.0 - GATE_X - 3.6, 3.0, 1.0), ROCK)
	for sd: float in [-1.0, 1.0]:
		bx(Vector3(GATE_X + sd * 4.0, eh + (CLEAR + 1.2) * 0.5, ZEND), Vector3(0.8, CLEAR + 1.2, 0.8), B)
	bx(Vector3(GATE_X, eh + CLEAR + 0.5, ZEND), Vector3(8.8, 1.0, 0.8), B)
	_lamp(Vector3(GATE_X, eh + CLEAR + 1.6, ZEND), Vector3(10.0, 1.2, 1.2), 0)
	# 광장 가장자리 기둥 줄 (위에서 볼 때 흐르는 기준물)
	var bd := 5.0
	while bd < 200.0:
		for sd: float in [-1.0, 1.0]:
			bx(Vector3(sd * 27.0, _h3(bd) + 1.0, Z3 - bd), Vector3(1.6, 2.0, 1.6), [WHITE, ROCK][int(bd / 20.0) % 2])
		bd += 20.0
	for p: Vector2 in POTS3:
		_pot(p.x, Z3 - p.y, 3)


func _build4() -> void:
	for i in ISL.size():
		var s: Array = ISL[i]
		var d0 := float(s[0])
		var d1 := float(s[1])
		var x := float(s[2])
		var hw := float(s[4])
		var p0 := Vector3(x, _ih(i, d0), ZEND - d0)
		var p1 := Vector3(x, _ih(i, d1), ZEND - d1)
		var drop := int(s[6]) == 1
		_slab(p0, p1, hw * 2.0, 1.2, A if drop else GRASS, 0.0)  # 주황 = 둥글게(세워서) 꽂아라
		var mid := (p0 + p1) * 0.5
		bx(mid + Vector3(0, -4.0, 0), Vector3(hw * 1.5, 6.0, (d1 - d0) * 0.8), ROCK)
		bx(mid + Vector3(0, -9.0, 0), Vector3(hw * 0.8, 5.0, (d1 - d0) * 0.4), STONE)
		if drop:  # 꽂기 섬: 과녁
			bx(Vector3(x, _ih(i, (d0 + d1) * 0.5) + 0.05, ZEND - (d0 + d1) * 0.5), Vector3(hw, 0.1, hw), WHITE)
		else:  # 활강 섬: 끝에 흰 줄
			_slab(p0 + Vector3(-hw + 0.2, 0.03, 0), p1 + Vector3(-hw + 0.2, 0.03, 0), 0.4, 0.08, WHITE, 0.0, true)
			_slab(p0 + Vector3(hw - 0.2, 0.03, 0), p1 + Vector3(hw - 0.2, 0.03, 0), 0.4, 0.08, WHITE, 0.0, true)
	# 구름 (천천히 흐름)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for k in 14:
		var c := bx(Vector3(0, E4 - rng.randf_range(10.0, 70.0), ZEND - rng.randf_range(-10.0, 280.0)), Vector3(rng.randf_range(8, 18), 2.5, rng.randf_range(5, 10)), WHITE)
		clouds.append(c)
		cloud_x.append(rng.randf_range(-60.0, 60.0))
	# 먼 성벽 (터널 입구가 있는 절벽)
	var ty := _p5(0.0)
	bx(Vector3(0, ty + 20.0, Z5 - 3.0), Vector3(120, 40, 4), LILAC)


func _build5() -> void:
	var d := 0.0
	var seg := 0
	while d < L5 + 20.0:
		var y := _p5(d + 5.0)
		bx(Vector3(0, y - 1.0, Z5 - d - 5.0), Vector3(7.0, 2.0, 10.2), SOFT if seg % 2 == 0 else ROCK)
		if seg % 2 == 0:  # 테 (왼벽·오른벽·천장) 20m마다
			for sd: float in [-1.0, 1.0]:
				bx(Vector3(sd * 4.0, y + 3.5, Z5 - d), Vector3(1.0, 7.0, 1.2), C if seg % 4 == 0 else LILAC)
			bx(Vector3(0, y + 7.2, Z5 - d), Vector3(9.0, 0.8, 1.2), C if seg % 4 == 0 else LILAC)
			for sd: float in [-1.0, 1.0]:  # 등불
				bx(Vector3(sd * 3.4, y + 4.5, Z5 - d - 10.0), Vector3(0.3, 0.6, 0.6), D)
		d += 10.0
		seg += 1
	for sd: float in [-1.0, 1.0]:  # 긴 벽
		bx(Vector3(sd * 4.6, _p5(L5 * 0.5) + 3.5, Z5 - L5 * 0.5), Vector3(0.4, 9.0, L5 + 20.0), Color("eebefa"))
	for st: float in STEPS5:
		bx(Vector3(0, _p5(st) - STEP_H * 0.5, Z5 - st + 0.15), Vector3(7.2, STEP_H, 0.3), A)
	for g: Array in GATES5:
		var gz := Z5 - float(g[0])
		var gy := _p5(float(g[0]))
		for sd: float in [-1.0, 1.0]:
			bx(Vector3(sd * 3.7, gy + 3.5, gz), Vector3(0.6, 7.0, 0.8), INK)
		var bar := bx(Vector3(0, gy + 4.0, gz), Vector3(6.8, 4.0, 0.4), BAD)
		bars.append(bar)
	# 출구 빛
	bx(Vector3(0, _p5(L5) + 3.0, Z5 - L5 - 25.0), Vector3(12, 10, 1), WHITE)


func _pot(x: float, z: float, zn: int) -> void:
	var pt := Pot.new()
	pt.x = x
	pt.z = z
	pt.zn = zn
	pt.base = _g(x, z)
	if is_nan(pt.base):
		pt.base = 0.0
	pt.n = bx(Vector3(x, pt.base + 0.7, z), Vector3(1.4, 1.4, 1.4), C)
	pots.append(pt)


func _gap(i: int) -> float:
	var g: Array = GATES5[i]
	return lerpf(GAP0, GAP1, 0.5 + 0.5 * sin(TAU * clock / float(g[1]) + float(g[2])))


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	hurt -= dt
	brake_cd -= dt
	brake_t -= dt
	squash = maxf(0.0, squash - dt * 3.0)
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
	var zn := _zone_at(pz)
	if zn != zone:
		_enter(zn)
	_tips()
	if free_t > 0.0:
		free_t -= dt
		if free_t <= 0.0:
			_free(zone - 1)
			_ensure(zone + 1)
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
	# 방향: 원반일수록 안 돈다. 수로·터널에서는 곧게, 끌기 = 기울이기.
	var lean_acc := 0.0
	if zone == 2 or zone == 5:
		hd = lerpf(hd, 0.0, minf(1.0, dt * 5.0))
		hd_goal = hd
		px = lerpf(px, 0.0, minf(1.0, dt * 5.0))
		lat_v = 0.0
		if held:
			var ln := clampf((drag_x - press_x) / 160.0, -1.0, 1.0)
			lean_acc = ln * (3.0 if ln > 0.0 else 5.0)
	else:
		if not held:  # 손 떼면 길(섬) 쪽으로 천천히 돈다
			var aim := Vector2.ZERO
			var has_aim := true
			if zone == 1:
				aim = _aim1(12.0)
			elif zone == 4:
				var ni := _next_isl()
				aim = Vector2(float(ISL[ni][2]) if ni >= 0 else 0.0, pz - 14.0)
			else:
				has_aim = false
			if has_aim:
				var want := atan2(-(aim.x - px), -(aim.y - pz))
				hd_goal = move_toward(hd_goal, hd_goal + wrapf(want - hd_goal, -PI, PI), ASSIST * dt)
		hd_goal = clampf(hd_goal, hd - 1.4, hd + 1.4)
		hd = move_toward(hd, hd_goal, lerpf(TURN0, TURN1, fl) * dt)
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
		if zone == 4:
			v -= (1.0 - fl) * 2.5 * dt  # 공은 공기에 빨리 느려진다
			v = maxf(v, 0.0)
	# 옆바람: 원반일수록 크게 밀린다
	wind_now = _wind()
	lat_v += wind_now * lerpf(0.08, 1.3, fl) * dt
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
	_checkpoint()
	# 위아래
	vy -= FALL * dt
	if zone == 4 and not on_ground:
		vy = maxf(vy, lerpf(-34.0, -4.5, fl))  # 원반은 공기를 타고 천천히 내려간다
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
				squash = 0.25
				_burst(Vector3(px, wh, pz), 4, WATER, 5.0)
				beep(700.0 + v * 10.0, 0.06, 1200.0, 0.22)
				msg("통!", 0.3)
			else:
				_die("가라앉음", 2)
	elif is_nan(g):
		on_ground = false
		if zone == 4:
			var ni := _next_isl()
			var floor_y := _ih(ni, float(ISL[ni][1])) if ni >= 0 else _p5(0.0)
			if by < floor_y - 6.0:
				_die("떨어짐!", 1)
		elif by < last_g - 2.0:
			_die("떨어짐!", 1)
	elif by <= g:
		if by < g - 1.4:
			_die("쾅!", 1)
		elif zone == 4 and not on_ground and vy < -BREAK_V:
			_burst(Vector3(px, g, pz), 12, STONE, 12.0)
			body.visible = false
			for s in stripes:
				s.visible = false
			_die("깨짐! 너무 높았다", 0)
		else:
			if not on_ground and vy < -8.0:
				beep(90.0, 0.14, 50.0, 0.3)
				shake = maxf(shake, 0.2)
				squash = clampf(-vy / 40.0, 0.15, 0.45)
				_burst(Vector3(px, g, pz), 5, GRASS if zone == 4 else STONE, 6.0)
				if zone == 4:
					bonus += 20
					msg("착지!", 0.4)
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
			msg("멈췄다\n탭: 깃발부터" if cp_i > 0 else "멈췄다\n탭: 다시", 2.5)
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


func _enter(zn: int) -> void:
	zone = zn
	hd_goal = hd if zn == 1 or zn == 3 or zn == 4 else 0.0
	bonus += 100
	play("good")
	msg(ZNAME[zn], 1.6)
	for k in range(1, zn - 1):
		_free(k)
	free_t = 1.0  # 1초 뒤 지난 구역을 해제하고 다음 구역을 짓는다 (상자 300개 아래)
	_sky()
	if zn == 5:
		pivot.visible = false


## 처음 만나는 것마다 한 번 짧게 알려 준다 (첫 10초에 무엇을 하는지 보이게)
func _tip(key: String, text: String) -> void:
	if tips.has(key):
		return
	tips[key] = true
	msg(text, 1.3)


func _tips() -> void:
	if zone == 1:
		if pz < float(ARCH_Z[0]) + 30.0 and pz > float(ARCH_Z[0]):
			_tip("arch", "파랑 = 빨라야 통과\n등 초록 = 지금 지남")
		elif pz < float(CORNER_Z[0]) + 30.0 and pz > float(CORNER_Z[0]):
			_tip("corner", "주황 커브! 세워서 둥글게")
		elif pz < float(N1[BRIDGE_SEG][1]) + 6.0 and pz > float(N1[BRIDGE_SEG][1]) - 10.0:
			_tip("bridge", "바람 다리: 둥글게 버텨")
	elif zone == 2 and Z2 - pz > 30.0:
		_tip("lean", "끌기 = 앞뒤 기울이기")
	elif zone == 4 and ZEND - pz > 3.0:
		_tip("fall", "원반=멀리, 세우면 뚝\n노란 섬엔 꽂아라")
	elif zone == 5 and Z5 - pz > 8.0:
		_tip("bars", "창살 밑: 초록일 때 지남")


func _checkpoint() -> void:
	while cp_i + 1 < CPS.size() and pz < float(CPS[cp_i + 1][2]):
		cp_i += 1
		cp_travel = travel
		cp_bonus = bonus
		if int(CPS[cp_i][0]) == int(CPS[cp_i - 1][0]):
			bonus += 20
			msg("깃발!", 0.6)
			beep(880.0, 0.1, 1760.0, 0.25)


## 지금 앞에 있는(또는 위에 있는) 섬 번호
func _next_isl() -> int:
	var d4 := ZEND - pz
	for i in ISL.size():
		if float(ISL[i][1]) > d4:
			return i
	return -1


func _wind() -> float:
	if zone == 1:
		if pz < float(N1[BRIDGE_SEG][1]) + 4.0 and pz > float(N1[BRIDGE_SEG + 1][1]):
			var cyc := int(clock / 3.6)
			var ph := fmod(clock, 3.6)
			var sd := 1.0 if cyc % 2 == 0 else -1.0
			if ph > 2.6 and gust_warned != cyc:
				gust_warned = cyc
				beep(180.0, 0.4, 260.0, 0.2)
				msg("← 바람" if sd > 0.0 else "바람 →", 0.7)
			if ph < 1.0:
				return BR_WIND * sd
		return 0.0
	if zone == 3:
		var d3 := Z3 - pz
		for ln: Array in LANES:
			if d3 > float(ln[0]) and d3 < float(ln[1]):
				return WIND_A * float(ln[2])
	return 0.0


## 아치·관·턱·문·기둥·항아리·창살
func _features(ox: float, oz: float, fx: float, fz: float) -> void:
	if zone == 1:
		for az: float in ARCH_Z:
			if oz > az and pz <= az:
				if bh >= CLEAR:
					_runup(20.0, 22.0, "아치에 쿵! 뒤로 튕김")
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
				_runup(18.0, 22.0, "관에 쿵! 뒤로 튕김")
				return
			if d > a and d < b and bh > CLEAR + 0.08:
				_die("끼임!", 0)
				return
	elif zone == 3:
		if oz > ZEND and pz <= ZEND:
			if absf(px - GATE_X) < 3.6:
				if bh < CLEAR:
					bonus += 300
					beep(1000.0, 0.1, 1800.0, 0.25)
					return
				_runup(30.0, 14.0, "문에 쿵! 뒤로 튕김")
			else:
				_runup(30.0, 14.0, "벽! 뒤로 튕김")
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
					_burst(Vector3(px, by + 1.0, pz), 4, WHITE, 6.0)
					play("bad")
					msg("쿵!", 0.5)
	elif zone == 5:
		var od := Z5 - oz
		var d := Z5 - pz
		for st: float in STEPS5:
			if od < st and d >= st:
				if bh >= STEP_NEED:
					v *= 0.72
					by = _p5(d)
					vy = 0.0
					bonus += 10
					shake = 0.15
					beep(160.0, 0.12, 300.0, 0.3)
					msg("턱!", 0.4)
				else:
					_bonk(0.0, Z5 - (st - 0.8), 0.15, "턱에 걸림")
					return
		for i in GATES5.size():
			var gd := float(GATES5[i][0])
			if od < gd and d >= gd:
				if bh < _gap(i) - 0.05:
					bonus += 25
					beep(1000.0, 0.08, 1600.0, 0.22)
					msg("슉!", 0.3)
				else:
					_burst(Vector3(px, by + 1.0, Z5 - gd + 1.0), 5, D, 6.0)
					bar_hits = bar_hits + 1 if bar_gate == i else 1
					bar_gate = i
					if bar_hits >= 3:
						_die("창살에 끼임!", 0)
						return
					_bonk(0.0, Z5 - (gd - 6.0), 0.3, "창살에 쿵! (%d/3)" % bar_hits)
					v = maxf(v, 7.0)
					slow_t = -1.0  # 튕긴 뒤 1초는 멈춤으로 안 친다
					return
		if d >= L5:
			won = true
			cp_i = 0
			bonus += 1000
			score = int(travel) + bonus
			msg("신전 탈출!", 3.0)
			end()
			return
	for pt in pots:
		if pt.flat:
			continue
		if absf(pt.z - pz) < bl * 0.5 + 0.7 and absf(pt.x - px) < bw * 0.5 + 0.7 and by < pt.base + 1.2:
			pt.flat = true
			pt.n.scale.y = 0.15
			pt.n.position.y = pt.base + 0.08
			v *= 0.86
			bonus += 5
			_burst(Vector3(pt.x, pt.base + 0.7, pt.z), 4, A, 5.0)
			beep(480.0, 0.1, 110.0, 0.26)


## 빨라야 지나는 것(파랑)에 둥근 채 박히면: 그 자리에 갇히지 않고 뒤로 튕겨 도움닫기 거리부터 다시 굴러온다
func _runup(back: float, vnew: float, text: String) -> void:
	_burst(Vector3(px, by + bh * 0.5, pz), 5, STONE, 7.0)
	match zone:
		1:
			pz = minf(pz + back, float(N1[0][1]) - 2.0)
			px = _x1(pz)
			hd = _dir1(pz)
			hd_goal = hd
		2:
			var nd := maxf(Z2 - pz - back, 1.0)
			while _pool(nd) >= 0:
				nd += 1.0
			pz = Z2 - nd
			px = 0.0
		3:
			pz = minf(pz + back, Z3 - 2.0)
			px = clampf(px, -20.0, 20.0)
			hd = 0.0
			hd_goal = 0.0
		_:
			pz += back
	var g := _g(px, pz)
	if not is_nan(g):
		by = g
		last_g = g
	vy = 0.0
	lat_v = 0.0
	on_ground = true
	v = vnew
	fl = clampf((v - V_ROUND) / (V_FLAT - V_ROUND), 0.0, 1.0)
	bh = lerpf(H0, H1, fl)
	bw = lerpf(W0, W1, fl)
	bl = lerpf(L0, L1, fl)
	was_flat = bh < CLEAR
	slow_t = 0.0
	hurt = 0.6
	shake = 0.5
	squash = 0.3
	bonus = maxi(0, bonus - 20)
	play("bad")
	msg(text + "\n도움닫기!", 1.1)


func _bonk(bx2: float, bz: float, keep: float, text: String) -> void:
	_burst(Vector3(px, by + bh * 0.5, pz), 5, STONE, 7.0)
	px = bx2
	pz = bz
	v *= keep
	hurt = 0.5
	shake = 0.45
	squash = 0.35
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
	msg(text + ("\n탭: 깃발부터" if cp_i > 0 else ""), 2.5)
	beep(400.0, 0.6, 60.0, 0.3)


## 작은 상자 파편 (미리 만든 12개를 돌려 쓴다)
func _burst(at: Vector3, n: int, col: Color, sp: float) -> void:
	for k in n:
		var i := deb_i
		deb_i = (deb_i + 1) % debris.size()
		var d := debris[i]
		d.visible = true
		d.material_override = mat(col)
		d.position = at
		deb_v[i] = Vector3(randf_range(-1.0, 1.0) * sp, randf_range(0.5, 1.2) * sp, randf_range(-1.0, 1.0) * sp)
		deb_t[i] = 0.7


func _place(dt: float) -> void:
	pivot.position = Vector3(px, by, pz)
	pivot.rotation.y = hd
	var sq := squash
	body.scale = Vector3(bw * (1.0 + sq * 0.5), bh * (1.0 - sq), bl * (1.0 + sq * 0.3))
	body.position = Vector3(0, body.scale.y * 0.5, 0)
	body.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else ME)
	roll_ph += v * dt * 0.5
	for k in stripes.size():
		var s := stripes[k]
		s.scale = Vector3(body.scale.x * 1.04, body.scale.y * 1.04, 0.25)
		s.position = Vector3(0, body.scale.y * 0.5, fposmod(roll_ph + k * bl * 0.5, bl) - bl * 0.5)
	# 구르는 소리: 빠를수록 촘촘하고, 원반이면 높다
	roll_acc += v * dt
	if roll_acc > 3.5 and on_ground and not fallen:
		roll_acc = 0.0
		beep(clampf(60.0 + v * 2.0 + fl * 60.0, 50.0, 260.0), 0.04, 45.0, 0.1)
	# 파편
	for k in debris.size():
		if deb_t[k] > 0.0:
			deb_t[k] -= dt
			deb_v[k].y -= 30.0 * dt
			debris[k].position += deb_v[k] * dt
			debris[k].scale = Vector3.ONE * 0.45 * clampf(deb_t[k] / 0.4, 0.2, 1.0)
			if deb_t[k] <= 0.0:
				debris[k].visible = false
	# 바람 줄
	var sd := signf(wind_now)
	for k in streaks.size():
		var st := streaks[k]
		st.visible = sd != 0.0 and not fallen
		if st.visible:
			st.position = Vector3(px + fposmod(k * 7.3 + clock * 30.0 * sd, 24.0) - 12.0, by + 0.5 + (k % 3) * 0.9, pz + 6.0 - k * 2.5)
	# 속도 줄: 빠를수록 길고 많다
	var f3h := Vector3(-sin(hd), 0, -cos(hd))
	var r3 := Vector3(cos(hd), 0, -sin(hd))
	for k in speedl.size():
		var s2 := speedl[k]
		s2.visible = v > 20.0 and not fallen and k < int((v - 20.0) / 3.0) + 2
		if s2.visible:
			var side := (2.2 + (k % 3) * 1.1) * (1.0 if k % 2 == 0 else -1.0)
			var along := 14.0 - fposmod(clock * v * 1.3 + k * 6.1, 28.0)
			s2.position = Vector3(px, by + 0.4 + (k % 3) * 0.8, pz) + r3 * side + f3h * along
			s2.rotation.y = hd
			s2.scale = Vector3(0.1, 0.1, 2.0 + v * 0.1)
	for k in lane_marks.size():
		var info := lane_info[k]
		lane_marks[k].position.x = fposmod(info.x + clock * 9.0 * info.y, 50.0) - 25.0
	for k in clouds.size():
		clouds[k].position.x = fposmod(cloud_x[k] + clock * 2.5 + 80.0, 160.0) - 80.0
	# 터널 창살: 지금 몸이 지나면 초록, 아니면 빨강
	for i in bars.size():
		var gy := _p5(float(GATES5[i][0]))
		var gp := _gap(i)
		bars[i].position.y = gy + (gp + 7.0) * 0.5
		bars[i].scale.y = 7.0 - gp
		bars[i].material_override = mat(GOOD if bh < gp - 0.05 else BAD)
	# 장애물 등: 지금 몸이면 지나는지
	for i in lamp_n.size():
		var ok := bh < CLEAR if lamp_k[i] == 0 else bh >= STEP_NEED
		lamp_n[i].material_override = mat(GOOD if ok else BAD)
	# 카메라: 구역마다 시점이 바뀐다
	cam_hd = lerp_angle(cam_hd, hd, minf(1.0, dt * 3.0))
	var P := Vector3(px, by, pz)
	var f3 := Vector3(-sin(cam_hd), 0, -cos(cam_hd))
	var want: Vector3
	var look: Vector3
	var fov := 55.0
	var k2 := minf(1.0, dt * 4.0)
	match zone:
		1:
			# 길을 따라 앞(속도에 비례)을 본다: 커브 너머가 먼저 보이고, 빠를수록 물러나 넓게
			var la := 18.0 + v * 0.8
			var ap := _aim1(la)
			var ay := _g(ap.x, ap.y)
			if is_nan(ay):
				ay = by
			want = P - f3 * (9.0 + v * 0.22) + Vector3(0, 4.5 + bh + v * 0.1, 0)
			look = Vector3(ap.x, ay, ap.y).lerp(P + f3 * la, 0.3)
			fov = clampf(58.0 + v * 0.6, 58.0, 90.0)
		2:
			# 옆모습: 빠를수록 물러나고, 돌은 화면 왼쪽에 두어 앞(오른쪽)을 넓게
			var dist2 := 18.0 + v * 0.35
			fov = 50.0 + v * 0.3
			var ah2 := 0.3 * 2.0 * dist2 * tan(deg_to_rad(fov * 0.5))
			want = P + Vector3(dist2, 3.5, -ah2)
			look = P + Vector3(0, 0.6, -ah2)
		3:
			want = P + Vector3(0, 30.0 + v * 0.45, 6.0)
			look = P + Vector3(0, 0, -(8.0 + v * 0.5))
			fov = 50.0
		4:
			want = P + Vector3(0, 13.0, 13.0)
			look = P + Vector3(0, -7.0, -18.0)
			fov = 62.0 + v * 0.3
		_:
			# 1인칭 돌 눈: 눈높이 = 몸 높이
			want = P + Vector3(0, bh * (1.0 - squash) * 0.85 + 0.1, -bl * 0.5)
			look = want + Vector3(0, -0.15, -20.0)
			fov = clampf(70.0 + v * 0.5, 70.0, 95.0)
			k2 = minf(1.0, dt * 14.0)
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
	if zone != 2 and zone != 5:
		hd_goal -= (p.x - drag_x) * STEER
	drag_x = p.x


func _lift(p: Vector2) -> void:
	drag_x = p.x
	press_x = p.x


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)
