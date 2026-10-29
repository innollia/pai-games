extends Tofu
## 큰 상자공이 도로를 저절로 굴러간다. 좌우로 끌어 방향을 튼다. 나보다 작은 차는 깔아서 점수·커짐(커질수록 빨라짐), 큰 차에 부딪히면 튕기고 작아짐. 60초.

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


func _setup() -> void:
	time_limit = 60.0


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
	c.flat = true
	c.n.scale.y = 0.15
	c.n.position.y = 0.08
	score += int(kd.pts)
	s_goal = minf(16.0, s_goal + float(kd.grow))
	beep(520.0 - c.k * 100.0, 0.1, 120.0, 0.28)
	if tier < TIER.size() and s_goal >= TIER[tier]:
		msg(TIER_NAME[tier])
		play("good")
		tier += 1


func _bonk(c: Car, sz: Vector3) -> void:
	s_goal = maxf(2.0, s_goal - 0.8)
	kick = 30.0
	hurt = 0.8
	c.n.position.z = bz - (s + sz.z) * 0.5 - 0.5
	tier = 0
	while tier < TIER.size() and s_goal >= TIER[tier]:
		tier += 1
	play("bad")
	msg("쿵!")


func _tap(p: Vector2) -> void:
	last_x = p.x


func _drag(p: Vector2) -> void:
	x_goal += (p.x - last_x) * 0.06
	last_x = p.x
