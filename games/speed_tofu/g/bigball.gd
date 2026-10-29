extends Tofu
## 처음 한 번 글상자 컷씬(탭으로 넘김): 트럭에서 뛰어내린 강철코일이 공장으로 굴러 돌아간다.
## 코일은 도로를 저절로 굴러간다. 좌우로 끌어 방향을 튼다. 나보다 작은 차는 깔면 몸에 붙고 점수·커짐(커질수록 빨라짐), 큰 차에 부딪히면 붙은 차가 떨어지고 작아짐. 60초.

const CUT := [
	"강철코일 공장.\n갓 감긴 코일 하나가\n트럭에 실린다.",
	"떠나는 순간,\n공장 창문 너머로\n그녀를 봤다.",
	"고속도로 위 트럭.\n코일은 결심했다.",
	"뛰어내려!\n공장으로 돌아가자.\n길을 막는 건 전부 깔고 간다.",
]
const STUCK := 30

const ROAD := Color("8d939c")
const HALF := 12.0  # 도로 반폭
const LANES := [-10.0, -6.0, -2.0, 2.0, 6.0, 10.0]  # 왼쪽 셋은 마주 오는 차, 오른쪽 셋은 같은 방향
const SEG := 8.0
const AHEAD := 200.0
const NCAR := 28
# 차 종류: 크기, 깔 수 있는 내 크기, 점수, 커지는 양, 나올 확률, 지붕
const KIND := [
	{"size": Vector3(1.8, 1.3, 3.6), "need": 0.0, "pts": 1, "grow": 0.12, "w": 0.55, "roof": Vector3(0.85, 0.6, 0.5)},
	{"size": Vector3(2.2, 2.2, 4.6), "need": 3.0, "pts": 3, "grow": 0.25, "w": 0.22, "roof": Vector3(0.9, 0.25, 0.8)},
	{"size": Vector3(2.8, 3.4, 8.0), "need": 5.0, "pts": 6, "grow": 0.45, "w": 0.14, "roof": Vector3(0.95, 0.2, 0.25)},
	{"size": Vector3(3.0, 3.6, 11.0), "need": 7.5, "pts": 10, "grow": 0.7, "w": 0.09, "roof": Vector3(1.02, 0.25, 0.9)},
]
const TIER := [3.0, 5.0, 7.5, 12.0]
const TIER_NAME := ["승합차!", "트럭!", "버스!", "거대!"]


class Car:
	var n: MeshInstance3D
	var roof: MeshInstance3D
	var k := 0
	var vz := 0.0
	var flat := false


var ball: MeshInstance3D
var road: MeshInstance3D
var side: MeshInstance3D
var cars: Array[Car] = []
var dashes: Array[MeshInstance3D] = []
var blds: Array[MeshInstance3D] = []
var s := 2.0
var s_goal := 2.0
var bx := 0.0
var bz := 0.0
var x_goal := 0.0
var ang := 0.0
var kick := 0.0
var hurt := 0.0
var tier := 0
var quarter := 0
var last_x := 0.0
var stuck: Array[MeshInstance3D] = []
var nstuck := 0
var cut := 0  # 보고 있는 컷씬 장, CUT.size()면 끝
var cut_box: ColorRect
var cut_l: Label


func _setup() -> void:
	howto = "코일은 저절로 굴러간다. 좌우로 끌어 방향을 튼다.\n나보다 작은 차를 깔면 몸에 붙고 커지고 빨라진다.\n큰 차에 부딪히면 붙은 차가 떨어지고 작아진다. 60초."
	time_limit = 60.0
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
	_show_cut()


func _show_cut() -> void:
	var on := cut < CUT.size()
	cut_box.visible = on
	cut_l.visible = on
	if on:
		cut_l.text = CUT[cut]


func _reset() -> void:
	s = 2.0
	s_goal = 2.0
	bx = 0.0
	bz = 0.0
	x_goal = 0.0
	ang = 0.0
	kick = 0.0
	hurt = 0.0
	tier = 0
	quarter = 0
	ball = box(Vector3(0, 1, 0), Vector3.ONE * s, ME)
	box(Vector3.ZERO, Vector3(1.04, 1.04, 0.22), WHITE, ball)
	box(Vector3.ZERO, Vector3(1.04, 0.22, 1.04), D, ball)
	# 깐 차가 붙을 자리 (판 시작 때 만들어 돌려 쓴다)
	stuck.clear()
	nstuck = 0
	for i in STUCK:
		var m := box(Vector3.ZERO, Vector3.ONE, A, ball)
		m.visible = false
		stuck.append(m)
	road = box(Vector3(0, -0.1, 0), Vector3(HALF * 2.0, 0.2, AHEAD * 2.0 + 100.0), ROAD)
	side = box(Vector3(0, -0.3, 0), Vector3(400, 0.2, AHEAD * 2.0 + 100.0), SOFT)
	dashes.clear()
	for lx in [-8.0, -4.0, 0.0, 4.0, 8.0]:
		for i in 25:
			dashes.append(box(Vector3(lx, 0.02, -i * SEG), Vector3(0.3, 0.05, 3.5), D if lx == 0.0 else WHITE))
	blds.clear()
	for i in 18:
		for sd in [-1.0, 1.0]:
			var b := box(Vector3.ZERO, Vector3.ONE, A)
			_building(b, sd, 20.0 - i * 12.0)
			blds.append(b)
	cars.clear()
	for i in NCAR:
		var c := Car.new()
		c.n = box(Vector3.ZERO, Vector3.ONE, A)
		c.roof = box(Vector3(0, 0.75, 0), Vector3.ONE, WHITE, c.n)
		_spawn(c, -30.0 - randf() * AHEAD)
		cars.append(c)
	cam.position = Vector3(0, 3.0 + s * 1.5, 7.0 + s * 2.0)
	cam.fov = 55.0


func _building(b: MeshInstance3D, sd: float, z: float) -> void:
	var w := randf_range(6.0, 11.0)
	var h := randf_range(6.0, 34.0)
	b.scale = Vector3(w, h, randf_range(7.0, 11.0))
	b.position = Vector3(sd * (HALF + 3.0 + w * 0.5), h * 0.5, z)
	b.material_override = mat([A, B, C, D, SOFT, WHITE, GOOD].pick_random())


func _spawn(c: Car, z: float) -> void:
	var r := randf()
	c.k = 0
	for i in KIND.size():
		var w: float = KIND[i].w
		if r < w:
			c.k = i
			break
		r -= w
	var kd: Dictionary = KIND[c.k]
	var sz: Vector3 = kd.size
	var lane: float = LANES.pick_random()
	c.flat = false
	c.vz = 12.0 if lane < 0.0 else -7.0
	c.n.scale = sz
	c.n.position = Vector3(lane, sz.y * 0.5, z)
	c.roof.scale = kd.roof
	var cols := [[A, B, BAD, GOOD], [B, SOFT], [C], [D]]
	c.n.material_override = mat(cols[c.k].pick_random())


func _step(dt: float) -> void:
	if cut < CUT.size():
		t = time_limit
		return
	s = lerpf(s, s_goal, minf(1.0, dt * 4.0))
	ball.scale = Vector3.ONE * s
	var v := 12.0 + s * 2.6
	kick = move_toward(kick, 0.0, 40.0 * dt)
	var dz := (-v + kick) * dt
	bz += dz
	var lim := maxf(0.0, HALF + 1.0 - s * 0.5)
	x_goal = clampf(x_goal, -lim, lim)
	bx = lerpf(bx, x_goal, minf(1.0, dt * 10.0))
	# 굴러가기: 한 면(s)만큼 가면 90도. 모서리로 서면 가운데가 올라간다.
	ang += -dz * PI / (2.0 * s)
	var m := fposmod(ang, PI * 0.5)
	ball.position = Vector3(bx, s * 0.5 * (cos(m) + sin(m)), bz)
	ball.rotation.x = -ang
	var q := floori(ang / (PI * 0.5))
	if q != quarter:
		quarter = q
		beep(maxf(50.0, 120.0 - s * 5.0), 0.06, 50.0, 0.12)
	hurt -= dt
	ball.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else ME)
	road.position.z = bz - AHEAD * 0.5
	side.position.z = bz - AHEAD * 0.5
	for d in dashes:
		if d.position.z > bz + 20.0:
			d.position.z -= 25.0 * SEG
	for b in blds:
		if b.position.z > bz + 30.0:
			_building(b, signf(b.position.x), b.position.z - 18.0 * 12.0)
	for c in cars:
		var n := c.n
		if not c.flat:
			n.position.z += c.vz * dt
		if n.position.z > bz + 25.0:
			_spawn(c, bz - AHEAD + randf_range(-40.0, 0.0))
			continue
		if c.flat:
			continue
		var kd: Dictionary = KIND[c.k]
		var sz: Vector3 = kd.size
		var can: bool = s_goal >= kd.need
		if hurt > 0.0 and not can:
			continue
		if absf(n.position.x - bx) < (s + sz.x) * 0.45 and absf(n.position.z - bz) < (s + sz.z) * 0.5:
			if can:
				_crush(c, kd)
			else:
				_bonk(c, sz)
	var prev: float = 2.0 if tier == 0 else TIER[tier - 1]
	if tier >= TIER.size():
		gauge(1.0, GOOD)
	else:
		gauge((s_goal - prev) / (TIER[tier] - prev), GOOD)
	var want := Vector3(bx * 0.6, 3.0 + s * 1.5, bz + 7.0 + s * 2.0)
	cam.position = cam.position.lerp(want, minf(1.0, dt * 5.0))
	cam.look_at(Vector3(bx * 0.6, s * 0.4, bz - 8.0 - s * 1.5))
	cam.fov = lerpf(cam.fov, minf(75.0, 50.0 + v * 0.4), minf(1.0, dt * 2.0))


func _crush(c: Car, kd: Dictionary) -> void:
	# 깐 차는 길에서 사라지고 코일 겉면 아무 데나 붙는다
	var m := stuck[nstuck % STUCK]
	nstuck += 1
	var ax := randi() % 3
	var lp := Vector3(randf_range(-0.4, 0.4), randf_range(-0.4, 0.4), randf_range(-0.4, 0.4))
	lp[ax] = 0.5 * (1.0 if randf() < 0.5 else -1.0)
	m.position = lp
	m.rotation = Vector3(0, randf() * TAU, randf() * 0.6)
	m.scale = kd.size * 0.5 / s
	m.material_override = c.n.material_override
	m.visible = true
	_spawn(c, bz - AHEAD + randf_range(-40.0, 0.0))
	score += int(kd.pts)
	s_goal = minf(16.0, s_goal + float(kd.grow))
	beep(520.0 - c.k * 100.0, 0.1, 120.0, 0.28)
	if tier < TIER.size() and s_goal >= TIER[tier]:
		msg(TIER_NAME[tier])
		play("good")
		tier += 1


func _bonk(c: Car, sz: Vector3) -> void:
	s_goal = maxf(2.0, s_goal - 0.8)
	# 붙어 있던 차가 몇 대 떨어져 나간다
	for i in 4:
		if nstuck > 0:
			nstuck -= 1
			stuck[nstuck % STUCK].visible = false
	kick = 30.0
	hurt = 0.8
	c.n.position.z = bz - (s + sz.z) * 0.5 - 0.5
	tier = 0
	while tier < TIER.size() and s_goal >= TIER[tier]:
		tier += 1
	play("bad")
	msg("쿵!")


func _tap(p: Vector2) -> void:
	if cut < CUT.size():
		cut += 1
		_show_cut()
		play("good" if cut == CUT.size() else "tap")
		return
	last_x = p.x


func _drag(p: Vector2) -> void:
	if cut < CUT.size():
		return
	x_goal += (p.x - last_x) * 0.06
	last_x = p.x
