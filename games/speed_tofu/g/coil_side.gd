extends Tofu
## 옆에서 본 강철코일. 꾹 누르면 힘껏 굴러 가속(힘 막대가 닳고 떼면 찬다), 톡 치거나 위로 쓸면 깡충.
## 크기×속도가 센 만큼 차를 깔아 몸에 붙여 쌓고 커진다. 언덕에서 멈춤·구덩이 추락·큰 걸 느리게 박으면 끝. 고속도로 → 공장 정문(성장 하나 고르기) → 공장 마당 → 창문 너머 그녀.

const CUT := [
	"강철코일 공장.\n떠나는 트럭 위에서\n창문 너머 그녀를 봤다.",
	"코일은 결심했다.\n뛰어내려!",
	"공장으로 돌아가자.\n길을 막는 건\n전부 깔고 간다.",
]
const NONE := -9999.0
const FLOOR := -60.0
const G := 36.0  # 공중 중력
const GS := 30.0  # 비탈 중력
const NSTUCK := 30
const NCAR := 9
# 차·장애물: 크기(길이, 높이, 폭), 깔려면 필요한 힘(크기×상대속도), 점수, 커지는 양, 색, 창문
const KIND := [
	{"size": Vector3(3.6, 1.3, 2.0), "need": 20.0, "pts": 1, "grow": 0.15, "cols": [A, B, BAD, GOOD], "roof": Vector3(0.5, 0.6, 1.02)},  # 승용차
	{"size": Vector3(4.6, 2.2, 2.2), "need": 45.0, "pts": 3, "grow": 0.3, "cols": [B, ME], "roof": Vector3(0.8, 0.25, 1.02)},  # 승합차
	{"size": Vector3(8.0, 3.2, 2.6), "need": 90.0, "pts": 6, "grow": 0.5, "cols": [C], "roof": Vector3(0.25, 0.2, 1.02)},  # 트럭
	{"size": Vector3(11.0, 3.2, 2.8), "need": 140.0, "pts": 10, "grow": 0.7, "cols": [D], "roof": Vector3(0.9, 0.25, 1.02)},  # 버스
	{"size": Vector3(2.0, 1.2, 3.0), "need": 30.0, "pts": 1, "grow": 0.1, "cols": [BAD], "roof": Vector3(1.02, 0.25, 1.02)},  # 바리케이드
	{"size": Vector3(2.6, 2.2, 1.8), "need": 25.0, "pts": 2, "grow": 0.2, "cols": [D], "roof": Vector3(0.4, 0.5, 1.02)},  # 지게차
	{"size": Vector3(3.0, 3.0, 3.0), "need": 70.0, "pts": 4, "grow": 0.4, "cols": [B], "roof": Vector3(0.4, 0.4, 1.02)},  # 쌓인 코일
	{"size": Vector3(2.6, 4.6, 3.0), "need": 150.0, "pts": 8, "grow": 0.6, "cols": [A], "roof": Vector3(1.02, 0.08, 1.02)},  # 나무상자 벽
]
# 구간 대본: f 평지, s 비탈(길이, 높이차), b 다리, g 구덩이, w 컨베이어(길이, 높이차, 방향), o 장애물(종류, 앞으로 얼마)
const Z1 := [
	["f", 80], ["o", 4, 60],
	["s", 30, 4], ["f", 25], ["s", 30, -4],
	["f", 40], ["o", 4, 20],
	["s", 35, 10], ["f", 12], ["s", 35, -10],
	["f", 30], ["b", 25], ["g", 5], ["b", 30],
	["f", 30], ["o", 4, 15],
	["s", 25, 7], ["s", 20, 8], ["f", 15], ["s", 50, -18],
	["f", 20], ["o", 3, 10],
	["f", 40], ["b", 20], ["g", 8], ["b", 15], ["g", 6], ["b", 25],
	["f", 30], ["s", 30, 12], ["s", 20, -4], ["f", 10], ["s", 40, -8],
	["f", 70],
]
const Z2 := [
	["f", 50], ["o", 5, 30],
	["w", 35, 0, 1], ["f", 8], ["o", 6, 4],
	["s", 30, 8], ["f", 6], ["g", 10], ["f", 25], ["o", 5, 15],
	["w", 40, 0, -1], ["f", 20],
	["w", 30, 0, 1], ["f", 6], ["o", 7, 3],
	["f", 30], ["w", 25, 5, -1],
	["f", 15], ["s", 35, -12],
	["w", 30, 0, 1], ["g", 12], ["f", 25], ["o", 6, 12],
	["s", 20, 6], ["g", 14], ["f", 30], ["o", 5, 20],
	["w", 35, 7, -1], ["f", 20],
	["s", 40, -10], ["w", 40, 0, 1], ["f", 4], ["o", 7, 2],
	["f", 70],
]
const PICKS := ["더 크게\n몸 +1", "힘 오래\n덜 닳음", "높이 깡충\n점프 +25%"]
const ROAD := Color("8d939c")


class Car:
	var n: MeshInstance3D
	var roof: MeshInstance3D
	var k := 0
	var vx := 0.0
	var on := false
	var traffic := true


var pivot: Node3D
var body: MeshInstance3D
var stuck_m: Array[MeshInstance3D] = []
var nst := 0
var traffic_cars: Array[Car] = []
var all_cars: Array[Car] = []
var zroot: Node3D
var sx0 := PackedFloat32Array()
var sy0 := PackedFloat32Array()
var sx1 := PackedFloat32Array()
var sy1 := PackedFloat32Array()
var skind := PackedInt32Array()
var belt_n: Array[MeshInstance3D] = []
var belt_i: Array = []  # [x0, y0, 기울기, 길이, 방향, 시작 위치]
var zone := 0
var zlen := 0.0
var spawn_x := 0.0
var ann := 0
var px := 0.0
var bot := 0.0
var v := 0.0
var vy := 0.0
var air := false
var lastg := 0.0
var s := 2.0
var s_goal := 2.0
var ang := 0.0
var quarter := 0
var hurt := 0.0
var stall := 0.0
var sta := 1.0
var drain := 0.22
var hop_v := 16.0
var buf := 0.0
var press_t := 0.0
var py0 := 0.0
var hopped := false
var clock := 0.0
var cut := 0
var cut_box: ColorRect
var cut_l: Label
var choosing := false
var opts: Array = []
var pick_box: Array[ColorRect] = []
var pick_l: Array[Label] = []


func _setup() -> void:
	time_limit = 100.0
	howto = "꾹 누르면 힘껏 굴러 빨라진다(힘 막대가 닳고, 떼면 다시 찬다).\n톡 치거나 위로 쓸면 깡충. 크기×속도가 센 만큼 차를 깔아 몸에 붙인다.\n언덕에서 멈추거나, 구덩이에 빠지거나, 큰 걸 느리게 박으면 끝.\n공장 정문에서 성장 하나 고르고, 공장 마당 끝 창문의 그녀까지."
	var layer := CanvasLayer.new()
	add_child(layer)
	cut_box = ColorRect.new()
	cut_box.color = WHITE
	cut_box.position = Vector2(60, 400)
	cut_box.size = Vector2(600, 440)
	cut_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(cut_box)
	cut_l = _label(layer, 50, 430, 380)
	cut_l.position.x = 90
	cut_l.size.x = 540
	cut_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cut_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var hint := _label(cut_box, 30, 380, 50)
	hint.size.x = 600
	hint.text = "탭 ▶"
	for i in 2:
		var r := ColorRect.new()
		r.color = WHITE
		r.position = Vector2(40 + i * 330, 680)
		r.size = Vector2(310, 320)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(r)
		var l := _label(r, 46, 0, 320)
		l.size.x = 310
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pick_box.append(r)
		pick_l.append(l)
	_show_cut()
	_show_pick(false)


func _show_cut() -> void:
	var on := cut < CUT.size()
	cut_box.visible = on
	cut_l.visible = on
	if on:
		cut_l.text = CUT[cut]


func _show_pick(on: bool) -> void:
	choosing = on
	for i in 2:
		pick_box[i].visible = on
		if on:
			pick_l[i].text = PICKS[opts[i]]


func _reset() -> void:
	time_limit = 100.0
	t = time_limit
	_show_pick(false)
	zone = 0
	px = 0.0
	bot = 0.0
	v = 6.0
	vy = 0.0
	air = false
	lastg = 0.0
	s = 2.0
	s_goal = 2.0
	ang = 0.0
	quarter = 0
	hurt = 0.0
	stall = 0.0
	sta = 1.0
	drain = 0.22
	hop_v = 16.0
	buf = 0.0
	pivot = Node3D.new()
	world.add_child(pivot)
	body = box(Vector3.ZERO, Vector3.ONE * s, ME, pivot)
	box(Vector3.ZERO, Vector3(0.42, 0.42, 1.03), WHITE, body)
	box(Vector3.ZERO, Vector3(0.2, 0.2, 1.06), D, body)
	stuck_m.clear()
	nst = 0
	for i in NSTUCK:
		var m := box(Vector3.ZERO, Vector3.ONE, A, pivot)
		m.visible = false
		stuck_m.append(m)
	traffic_cars.clear()
	for i in NCAR:
		traffic_cars.append(_new_car(true))
	zroot = null
	_build(0)
	cam.rotation = Vector3.ZERO
	cam.fov = 60.0
	cam.position = Vector3(6.0, 4.0, 28.0)


func _new_car(tr: bool) -> Car:
	var c := Car.new()
	c.n = box(Vector3.ZERO, Vector3.ONE, A, world if tr else zroot)
	c.roof = box(Vector3(0, 0.3, 0), Vector3.ONE, WHITE, c.n)
	c.traffic = tr
	c.n.visible = false
	return c


func _set_kind(c: Car, k: int) -> void:
	c.k = k
	var kd: Dictionary = KIND[k]
	c.n.scale = kd.size
	c.roof.scale = kd.roof
	c.n.material_override = mat(kd.cols.pick_random())


# ---- 길 만들기 ----
func _build(z: int) -> void:
	zone = z
	if zroot:
		zroot.queue_free()
	zroot = Node3D.new()
	world.add_child(zroot)
	sx0.clear()
	sy0.clear()
	sx1.clear()
	sy1.clear()
	skind.clear()
	belt_n.clear()
	belt_i.clear()
	var x := -30.0
	var y := 0.0
	var obs: Array = []
	for op in (Z1 if z == 0 else Z2):
		match op[0]:
			"f":
				_road(x, y, x + op[1], y, 0)
				x += op[1]
			"s":
				_road(x, y, x + op[1], y + op[2], 0)
				x += op[1]
				y += op[2]
			"b":
				_road(x, y, x + op[1], y, 1)
				_water(x, x + op[1], y)
				x += op[1]
			"w":
				_road(x, y, x + op[1], y + op[2], 2 if op[3] > 0 else 3)
				x += op[1]
				y += op[2]
			"g":
				_water(x, x + op[1], y)
				x += op[1]
			"o":
				obs.append([op[1], x + op[2]])
	zlen = x - 30.0
	all_cars.clear()
	all_cars.append_array(traffic_cars)
	for o in obs:
		var c := _new_car(false)
		_set_kind(c, o[0])
		c.vx = 0.0
		c.on = true
		c.n.visible = true
		_place(c, o[1], _h(o[1]))
		all_cars.append(c)
	# 뒤 건물, 앞 가로등
	var bx := -40.0
	while bx < x + 40.0:
		var gy := _h(bx)
		if gy <= NONE:
			gy = 0.0
		var w := randf_range(8.0, 14.0)
		var hh := randf_range(8.0, 30.0) if z == 0 else randf_range(5.0, 14.0)
		var cols := [A, B, C, D, WHITE, GOOD] if z == 0 else [A, D, WHITE, B]
		var top := gy + hh
		box(Vector3(bx, (top + FLOOR) * 0.5, -18.0), Vector3(w, top - FLOOR, 10.0), cols.pick_random(), zroot)
		if z == 1 and randf() < 0.35:
			box(Vector3(bx + w * 0.3, top + 5.0, -16.0), Vector3(1.6, 10.0, 1.6), BAD, zroot)
		bx += w + randf_range(2.0, 8.0)
	var lx := -20.0
	while lx < x:
		var gy := _h(lx)
		if gy > NONE:
			box(Vector3(lx, gy + 1.6, 4.8), Vector3(0.35, 3.2, 0.35), D if z == 0 else WHITE, zroot)
		lx += 15.0
	var ey := _h(zlen)
	if z == 0:
		# 공장 정문
		box(Vector3(zlen + 12.0, ey + 8.0, -9.0), Vector3(26.0, 16.0, 6.0), A, zroot)
		box(Vector3(zlen, ey + 13.0, 0.0), Vector3(12.0, 2.5, 1.0), D, zroot)
		box(Vector3(zlen - 6.5, ey + 6.5, -3.0), Vector3(1.0, 13.0, 1.0), WHITE, zroot)
		box(Vector3(zlen + 6.5, ey + 6.5, -3.0), Vector3(1.0, 13.0, 1.0), WHITE, zroot)
	else:
		# 공장 건물, 창문, 그녀
		box(Vector3(zlen + 14.0, ey + 10.0, -8.0), Vector3(28.0, 20.0, 8.0), WHITE, zroot)
		box(Vector3(zlen + 4.0, ey + 6.5, -3.9), Vector3(6.0, 5.0, 0.3), B, zroot)
		box(Vector3(zlen + 4.0, ey + 5.6, -3.7), Vector3(1.2, 2.4, 0.3), BAD, zroot)
		box(Vector3(zlen + 4.0, ey + 7.4, -3.7), Vector3(0.9, 0.9, 0.3), SOFT, zroot)
	spawn_x = 10.0
	ann = 0
	for c in traffic_cars:
		_spawn_car(c)


func _road(x0: float, y0: float, x1: float, y1: float, kind: int) -> void:
	sx0.append(x0)
	sy0.append(y0)
	sx1.append(x1)
	sy1.append(y1)
	skind.append(kind)
	var dx := x1 - x0
	var dy := y1 - y0
	var th := atan2(dy, dx)
	var mid := Vector2((x0 + x1) * 0.5, (y0 + y1) * 0.5) - Vector2(-sin(th), cos(th)) * 0.4
	var col := ROAD
	if kind == 2:
		col = D
	elif kind == 3:
		col = C
	var sl := box(Vector3(mid.x, mid.y, 0.0), Vector3(sqrt(dx * dx + dy * dy) + 0.1, 0.8, 8.0), col, zroot)
	sl.rotation.z = th
	if kind == 1:
		box(Vector3(mid.x, mid.y + 1.4, 3.7), Vector3(dx, 0.3, 0.3), WHITE, zroot)
		var p := x0 + 4.0
		while p < x1:
			box(Vector3(p, y0 - 4.0, 0.0), Vector3(1.2, 7.2, 4.0), WHITE, zroot)
			p += 12.0
		return
	if kind >= 2:
		# 컨베이어 줄무늬 (움직여서 방향을 보여 준다)
		var u := 0.0
		while u < dx - 0.5:
			belt_n.append(box(Vector3.ZERO, Vector3(1.0, 0.45, 0.1), WHITE, zroot))
			belt_i.append([x0, y0, dy / dx, dx, 1.0 if kind == 2 else -1.0, u])
			u += 3.0
	if absf(dy) < 0.01:
		box(Vector3((x0 + x1) * 0.5, (y0 - 0.4 + FLOOR) * 0.5, 0.0), Vector3(dx, y0 - 0.4 - FLOOR, 7.9), SOFT, zroot)
		return
	var n := ceili(dx / 4.0)
	var w := dx / n
	for i in n:
		var top := minf(y0 + dy * (i * w) / dx, y0 + dy * ((i + 1) * w) / dx) - 0.4
		box(Vector3(x0 + (i + 0.5) * w, (top + FLOOR) * 0.5, 0.0), Vector3(w + 0.05, top - FLOOR, 7.9), SOFT, zroot)


func _water(x0: float, x1: float, y: float) -> void:
	box(Vector3((x0 + x1) * 0.5, y - 7.5, 0.0), Vector3(x1 - x0 + 0.2, 1.0, 7.9), B, zroot)
	box(Vector3((x0 + x1) * 0.5, (y - 8.0 + FLOOR) * 0.5, 0.0), Vector3(x1 - x0 + 0.2, y - 8.0 - FLOOR, 7.8), SOFT, zroot)


func _sec_at(x: float) -> int:
	for i in sx0.size():
		if x >= sx0[i] and x <= sx1[i]:
			return i
	return -1


func _h(x: float) -> float:
	var i := _sec_at(x)
	if i < 0:
		return NONE
	return lerpf(sy0[i], sy1[i], (x - sx0[i]) / (sx1[i] - sx0[i]))


func _slope(i: int) -> float:
	return (sy1[i] - sy0[i]) / (sx1[i] - sx0[i]) if i >= 0 else 0.0


## 코일 밑 받침 높이. 클수록 넓게 걸쳐서 작은 구덩이는 그냥 넘는다.
func _support(x: float) -> float:
	var m := s * 0.3
	return maxf(_h(x - m), maxf(_h(x), _h(x + m)))


# ---- 차 ----
func _spawn_car(c: Car) -> void:
	var x := maxf(px + 45.0, spawn_x + randf_range(14.0, 34.0))
	var hy := NONE
	for i in 6:
		hy = _h(x)
		if hy > NONE:
			break
		x += 10.0
	if hy <= NONE or x > zlen - 25.0:
		c.on = false
		c.n.visible = false
		return
	spawn_x = x
	var r := randf()
	var k := 0
	if zone == 0:
		k = 0 if r < 0.6 else (1 if r < 0.85 else 2)
	else:
		k = 5 if r < 0.55 else (0 if r < 0.8 else 1)
	_set_kind(c, k)
	# 트럭은 마주 오는 쪽만 (뒤에서 박으면 못 지나가니까)
	c.vx = -9.0 if (k == 2 or randf() < 0.55) else 5.0
	c.on = true
	c.n.visible = true
	_place(c, x, hy)


func _place(c: Car, x: float, hy: float) -> void:
	var sz: Vector3 = KIND[c.k].size
	c.n.position = Vector3(x, hy + sz.y * 0.5, 0.0)
	c.n.rotation.z = atan(_slope(_sec_at(x)))


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	if cut < CUT.size():
		t = time_limit
		gauge(sta, GOOD)
		return
	if choosing:
		t += dt
		return
	clock += dt
	press_t += dt
	hurt -= dt
	buf -= dt
	s = lerpf(s, s_goal, minf(1.0, dt * 4.0))
	body.scale = Vector3.ONE * s
	var pushing := held and sta > 0.0 and not air
	if pushing:
		sta = maxf(0.0, sta - drain * dt)
	elif not held:
		sta = minf(1.0, sta + 0.3 * dt)
	gauge(sta, GOOD if sta > 0.3 else BAD)
	var si := _sec_at(px)
	var k := _slope(si)
	var gh := _support(px)
	if not air:
		if gh < bot - 0.35:
			air = true
			vy = v * k if k > 0.0 else 0.0
		else:
			bot = gh
			lastg = gh
			var sn := k / sqrt(1.0 + k * k)
			var a := -GS * sn * (0.85 + 0.04 * s)
			if pushing:
				a += 11.0 / (0.8 + 0.1 * s)
			if si >= 0 and skind[si] == 2:
				a += 10.0
			elif si >= 0 and skind[si] == 3:
				a -= 10.0
			var vmax := 14.0 + s * 2.5
			if v > vmax:
				a -= (v - vmax) * 1.5
			v = move_toward(v + a * dt, 0.0, 1.5 * dt)
			if buf > 0.0:
				_hop()
			# 오르막이나 거꾸로 도는 컨베이어에서 멈추면 끝
			var back_belt := si >= 0 and skind[si] == 3
			if not air and (k > 0.05 or back_belt) and v < 0.6 and hurt <= 0.0:
				stall += dt
				if stall > 0.6:
					_fail("멈췄다…")
					return
			else:
				stall = 0.0
	if air:
		vy -= G * dt
		bot += vy * dt
		if gh > NONE and bot <= gh:
			if bot >= gh - 1.2:
				bot = gh
				air = false
				vy = 0.0
				lastg = gh
				beep(110.0, 0.1, 60.0, 0.3)
			else:
				v = minf(v, 0.0)  # 구덩이 벽에 막혔다
		if bot < lastg - 6.0:
			_fail("풍덩!")
			return
	px += v * dt
	# 구르기: 한 면(s)만큼 가면 90도
	ang += v * dt * PI / (2.0 * s)
	var m := fposmod(ang, PI * 0.5)
	pivot.position = Vector3(px, bot + s * 0.5 * (cos(m) + sin(m)), 0.0)
	pivot.rotation.z = -ang
	var q := floori(ang / (PI * 0.5))
	if q != quarter:
		quarter = q
		beep(maxf(50.0, 120.0 - s * 5.0 + v), 0.06, 50.0, 0.12)
	body.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else ME)
	for i in belt_n.size():
		var bi: Array = belt_i[i]
		var u := fposmod(bi[5] + clock * 6.0 * bi[4], bi[3])
		belt_n[i].position = Vector3(bi[0] + u, bi[1] + bi[2] * u - 0.4, 4.05)
	if _cars(dt):
		return
	var left := zlen - px
	if ann == 0 and left < 300.0:
		ann = 1
		msg("300m!")
	elif ann == 1 and left < 100.0:
		ann = 2
		msg("100m!")
	if px >= zlen:
		if zone == 0:
			opts = [0, 1, 2]
			opts.shuffle()
			_show_pick(true)
			msg("공장 정문!", 1.0)
			play("good")
		else:
			score += ceili(t) * 3
			msg("그녀다!", 2.0)
			end()
		return
	var dist := 22.0 + s * 1.8 + absf(v) * 0.3
	var want := Vector3(px + dist * 0.2, maxf(bot, lastg - 2.0) + 2.0 + s * 0.6, dist)
	cam.position = cam.position.lerp(want, minf(1.0, dt * 4.0))


## 차 움직이고 부딪힘. 끝났으면 true
func _cars(dt: float) -> bool:
	var r := s * 0.5
	var cy := bot + r
	var can_spawn := px + 45.0 < zlen - 25.0
	for c in all_cars:
		if not c.on:
			if c.traffic and can_spawn and randf() < 0.02:
				_spawn_car(c)
			continue
		if c.traffic:
			var nx := c.n.position.x + c.vx * dt
			var hy := _h(nx)
			if hy <= NONE or nx < px - 40.0:
				_spawn_car(c)
				continue
			_place(c, nx, hy)
		elif c.n.position.x < px - 40.0:
			c.on = false
			c.n.visible = false
			continue
		var kd: Dictionary = KIND[c.k]
		var sz: Vector3 = kd.size
		var p := c.n.position
		if absf(p.x - px) < r + sz.x * 0.5 - 0.2 and absf(p.y - cy) < r + sz.y * 0.5 - 0.1:
			var need: float = kd.need
			var pw := s * (v - c.vx)
			if pw >= need:
				_crush(c, kd)
			elif hurt > 0.0:
				continue
			elif pw >= need * 0.35:
				_bonk(c)
			else:
				_fail("쾅!")
				return true
	return false


func _crush(c: Car, kd: Dictionary) -> void:
	# 깐 차는 코일 겉에 붙는다. 새로 붙을수록 바깥, 커지면 옛것은 파묻힌다.
	var m := stuck_m[nst % NSTUCK]
	nst += 1
	var sz: Vector3 = kd.size
	var th := randf() * TAU
	var rad := s_goal * 0.5 + sz.y * 0.2
	m.position = Vector3(cos(th) * rad, sin(th) * rad, randf_range(-0.3, 0.3) * s_goal)
	m.rotation = Vector3(0.0, 0.0, th + PI * 0.5)
	m.scale = Vector3(sz.x * 0.5, sz.y * 0.5, 1.2)
	m.material_override = c.n.material_override
	m.visible = true
	if c.traffic:
		_spawn_car(c)
	else:
		c.on = false
		c.n.visible = false
	score += int(kd.pts)
	var before := floori(s_goal)
	s_goal = minf(12.0, s_goal + float(kd.grow))
	v *= 0.96
	beep(520.0 - c.k * 40.0, 0.1, 120.0, 0.28)
	if floori(s_goal) > before:
		msg("커졌다!")
		play("good")


func _bonk(c: Car) -> void:
	# 부수고 지나가지만 붙은 차가 떨어지고 작아진다
	for i in 3:
		if nst > 0:
			nst -= 1
			stuck_m[nst % NSTUCK].visible = false
	s_goal = maxf(2.0, s_goal - 0.4)
	v = -3.0
	hurt = 0.8
	if c.traffic:
		_spawn_car(c)
	else:
		c.on = false
		c.n.visible = false
	play("bad")
	msg("쿵!")


func _hop() -> void:
	if air:
		buf = 0.15
		return
	buf = 0.0
	air = true
	vy = hop_v
	beep(300.0, 0.1, 620.0, 0.22)


func _fail(w: String) -> void:
	msg(w, 1.5)
	time_limit = 0.0  # 실패 소리로 끝낸다
	end()


func _pick(i: int) -> void:
	match opts[i]:
		0: s_goal += 1.0
		1: drain *= 0.6
		2: hop_v *= 1.25
	_show_pick(false)
	play("good")
	_build(1)
	px = 0.0
	bot = 0.0
	lastg = 0.0
	air = false
	vy = 0.0
	v = 8.0
	sta = 1.0
	cam.position = Vector3(6.0, 4.0 + s, 26.0 + s * 1.8)
	msg("공장 마당", 1.0)


func _tap(p: Vector2) -> void:
	hopped = true  # 컷씬·고르기 탭은 떼도 깡충하지 않게
	if cut < CUT.size():
		cut += 1
		_show_cut()
		play("good" if cut == CUT.size() else "tap")
		return
	if choosing:
		_pick(0 if p.x < 360.0 else 1)
		return
	press_t = 0.0
	py0 = p.y
	hopped = false


func _drag(p: Vector2) -> void:
	if cut < CUT.size() or choosing or hopped:
		return
	if py0 - p.y > 70.0:
		hopped = true
		_hop()


func _lift(_p: Vector2) -> void:
	if cut < CUT.size() or choosing:
		return
	if not hopped and press_t < 0.2:
		_hop()
