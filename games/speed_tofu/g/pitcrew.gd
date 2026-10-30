extends Tofu
## 피트 크루: 왼손 조이스틱으로 피트 박스를 뛰어다니며 '작업'을 꾹 = 잭(노랑) → 바퀴 4개(주황) → 주유(보라) → 출발 깃발(초록).
## 왼쪽 차선엔 차가 전속력으로 지나가고, 우리 차도 전속력으로 들어와 선다(치이면 끝). 정지가 라이벌보다 느리면 순위가 떨어지고 20위면 탈락.
## 시즌 5개 서킷(기본 · 비 · 오버런 · 두 대 · 밤), 서킷 사이 피트 장비 하나 고르기(빠른 건, 동료, 경고등, 신발, 자동 잭).

const Z0 := -1.5  # 피트 박스에서 차가 서는 자리
const CX := 0.5  # 피트 박스 차선 가운데
const LANE := -3.2  # 지나가는 차선 가운데
const WORN := Color("8c8278")
const ASPH := Color("c6ccd5")
const WET := Color("a7b8cc")
const NAMES := ["몬자", "스파 · 비", "모나코 · 오버런", "스즈카 · 두 대", "싱가포르 · 밤"]
const PAR: Array[float] = [5.0, 4.8, 4.3, 4.0, 3.6]  # 라이벌 정지 시간
const UPS := {
	"gun": ["빠른 임팩트건", 2],
	"mate": ["동료 크루", 2],
	"light": ["차선 경고등", 1],
	"shoes": ["가벼운 신발", 1],
	"jack": ["자동 잭", 1],
}


class Car:
	var root: Node3D
	var wheels: Array[MeshInstance3D] = []
	var trail: Node3D
	var lamps: Node3D
	var x := 0.0
	var z := -80.0
	var v := 0.0
	var vmax := 0.0
	var target := 0.0
	var state := "idle"  # idle / in / wait / service / out / on(지나가는 차)
	var to_box := true
	var st := 0.0
	var jack := false
	var jprog := 0.0
	var prog: Array[float] = [0.0, 0.0, 0.0, 0.0]
	var fuel := 0.0
	var need_fuel := false
	var go_t := -1.0
	var oz := 0.0
	var whoosh := false


var env_node: WorldEnvironment
var sun_node: DirectionalLight3D
var cam_base: Transform3D
var cars: Array[Car] = []  # 우리 차 두 대
var passers: Array[Car] = []  # 지나가는 차
var pass_t := 0.0
var me: Node3D
var me_p := Vector3.ZERO
var me_v := Vector3.ZERO
var bar: MeshInstance3D
var mate: Node3D
var mate_p := Vector3.ZERO
var marks: Array[MeshInstance3D] = []  # 0 잭, 1-4 바퀴, 5 주유, 6 출발
var lights: Array[MeshInstance3D] = []
var drops: Array[MeshInstance3D] = []
var debris: Array[MeshInstance3D] = []
var deb_v: Array[Vector3] = []
var deb_t: Array[float] = []
var floors: Array[MeshInstance3D] = []
var board_me: MeshInstance3D
var pads: Array[Node3D] = []
var pad_kind: Array[String] = []
var race := 0
var arrivals := 0
var phase := ""
var phase_t := 0.0
var pos_now := 10
var ups := {}
var still_t := 0.0
var shake := 0.0
var gun_t := 0.0
var step_t := 0.0
var note_t := 0.0
var dead := false
var dead_t := 0.0
var fly := Vector3.ZERO
var pick_hold := 0.0
var wet_on := false
var night_on := false


func _setup() -> void:
	howto = "너는 피트 크루. 차가 서면 왼손 조이스틱으로 달려가 '작업'을 꾹.\n순서: 앞 잭(노랑) → 바퀴 4개(주황) → 주유(보라) → 초록 깃발에서 출발!\n왼쪽 차선엔 차가 전속력으로 지나가고 우리 차도 전속력으로 들어온다. 치이면 끝.\n정지가 느리면 순위가 떨어지고 20위면 탈락. 서킷 5개, 사이마다 장비 하나."
	time_limit = 0.0
	for ch in get_children():
		if ch is WorldEnvironment:
			env_node = ch
		elif ch is DirectionalLight3D:
			sun_node = ch
	cam.fov = 52.0
	cam.look_at_from_position(Vector3(0.3, 12.0, 0.87), Vector3(0.3, 0.0, -3.5), Vector3.UP)
	cam_base = cam.transform
	kit_stick()
	kit_button("work", "작업", Vector2(590, 1110), 100.0, A)


func _reset() -> void:
	cars.clear()
	passers.clear()
	marks.clear()
	lights.clear()
	drops.clear()
	debris.clear()
	deb_v.clear()
	deb_t.clear()
	floors.clear()
	pads.clear()
	pad_kind.clear()
	ups = {}
	pos_now = 10
	still_t = 0.0
	shake = 0.0
	note_t = 0.0
	dead = false
	pick_hold = 0.0
	cam.transform = cam_base
	# 바닥: 피트 박스 차선, 지나가는 차선, 차고
	floors.append(box(Vector3(0.5, -0.05, -10), Vector3(4.4, 0.1, 70), ASPH))
	floors.append(box(Vector3(-3.35, -0.05, -10), Vector3(3.3, 0.1, 70), Color("aeb6c2")))
	box(Vector3(4.9, -0.05, -10), Vector3(4.4, 0.1, 70), SOFT)
	box(Vector3(-5.2, 0.35, -10), Vector3(0.4, 0.7, 70), WHITE)
	box(Vector3(-5.2, 0.75, -10), Vector3(0.42, 0.1, 70), BAD)
	box(Vector3(-1.7, 0.01, -10), Vector3(0.12, 0.02, 70), WHITE)
	box(Vector3(2.7, 0.01, -10), Vector3(0.12, 0.02, 70), D)
	# 피트 박스 테두리
	box(Vector3(CX, 0.01, Z0 + 2.3), Vector3(2.8, 0.02, 0.12), D)
	box(Vector3(CX, 0.01, Z0 - 2.5), Vector3(2.8, 0.02, 0.12), D)
	box(Vector3(CX - 1.4, 0.01, Z0 - 0.1), Vector3(0.12, 0.02, 4.8), D)
	box(Vector3(CX + 1.4, 0.01, Z0 - 0.1), Vector3(0.12, 0.02, 4.8), D)
	# 차고: 타이어 더미, 주유기, 조명탑
	for k in 3:
		box(Vector3(6.0, 0.2 + k * 0.4, Z0 + 1.6), Vector3(0.8, 0.36, 0.8), INK if k % 2 == 0 else WORN)
		box(Vector3(6.0, 0.2 + k * 0.4, Z0 + 2.6), Vector3(0.8, 0.36, 0.8), D if k % 2 == 0 else INK)
	box(Vector3(6.0, 0.7, Z0 - 0.6), Vector3(0.7, 1.4, 0.7), C)
	for zz in [-14.0, -6.0, 2.0]:
		box(Vector3(6.6, 2.0, zz), Vector3(0.2, 4.0, 0.2), WHITE)
		box(Vector3(6.3, 4.0, zz), Vector3(0.8, 0.3, 0.5), D)
	# 순위판: 위가 1위
	for i in 20:
		box(Vector3(5.4, 0.08, -16.0 + i * 0.55), Vector3(0.9, 0.1, 0.42), WHITE)
	board_me = box(Vector3(5.4, 0.2, -16.0 + (pos_now - 1) * 0.55), Vector3(1.15, 0.2, 0.5), ME)
	# 차선 경고등 (장비)
	for i in 9:
		var l := box(Vector3(-1.95, 0.08, -18.0 + i * 2.5), Vector3(0.3, 0.14, 0.7), Color("9aa3ad"))
		l.visible = false
		lights.append(l)
	# 작업 자리 표시
	var mc: Array[Color] = [D, A, A, A, A, C, GOOD]
	for i in 7:
		var m := box(Vector3(0, 0.03, 0), Vector3(0.95, 0.04, 0.95), mc[i])
		m.visible = false
		marks.append(m)
	for i in 36:
		var d := box(Vector3(randf_range(-5, 6), randf_range(0, 9), randf_range(-20, 5)), Vector3(0.05, 0.6, 0.05), B)
		d.visible = false
		drops.append(d)
	for i in 6:
		var w := box(Vector3.ZERO, Vector3(0.45, 0.7, 0.8), WORN)
		w.visible = false
		debris.append(w)
		deb_v.append(Vector3.ZERO)
		deb_t.append(0.0)
	for k in 2:
		var c := _rig(A)
		box(Vector3(0, 0.69, 0.6), Vector3(0.3, 0.04, 2.6), ME, c.root)
		cars.append(c)
	var pc: Array[Color] = [C, B, GOOD, BAD, D]
	for k in 5:
		passers.append(_rig(pc[k]))
	me = _person(ME, D)
	bar = box(Vector3(0, 1.75, 0), Vector3(0.9, 0.12, 0.12), GOOD, me)
	bar.visible = false
	me_p = Vector3(3.4, 0, Z0 + 2.0)
	me_v = Vector3.ZERO
	me.position = me_p
	mate = _person(B, WHITE)
	mate_p = Vector3(3.4, 0, Z0 + 0.5)
	mate.position = mate_p
	mate.visible = false
	pass_t = 0.8
	_start_race(0)


## 상자 차 한 대 (+Z 쪽이 앞)
func _rig(col: Color) -> Car:
	var c := Car.new()
	c.root = Node3D.new()
	world.add_child(c.root)
	var r := c.root
	box(Vector3(0, 0.45, 0.1), Vector3(1.1, 0.45, 3.8), col, r)
	box(Vector3(0, 0.45, -0.1), Vector3(1.7, 0.32, 1.6), col, r)
	box(Vector3(0, 0.8, -0.2), Vector3(0.55, 0.35, 0.8), INK, r)
	box(Vector3(0, 1.05, -0.15), Vector3(0.4, 0.3, 0.4), WHITE, r)
	box(Vector3(0, 0.6, -1.95), Vector3(0.15, 0.6, 0.15), INK, r)
	box(Vector3(0, 1.0, -1.95), Vector3(1.8, 0.12, 0.5), col, r)
	box(Vector3(0, 0.2, 2.1), Vector3(1.9, 0.08, 0.45), col, r)
	for i in 4:
		var w := box(Vector3(-0.8 if i % 2 == 0 else 0.8, 0.35, 1.4 if i < 2 else -1.4), Vector3(0.45, 0.7, 0.8), INK, r)
		c.wheels.append(w)
	c.trail = Node3D.new()
	r.add_child(c.trail)
	for s in [-0.7, 0.7]:
		box(Vector3(s, 0.4, -5.5), Vector3(0.07, 0.07, 6.0), WHITE, c.trail)
	c.lamps = Node3D.new()
	r.add_child(c.lamps)
	box(Vector3(0, 0.03, 6.0), Vector3(1.7, 0.02, 7.5), Color("fff3bf"), c.lamps)
	c.lamps.visible = false
	r.visible = false
	return c


func _person(suit: Color, helmet: Color) -> Node3D:
	var r := Node3D.new()
	world.add_child(r)
	box(Vector3(0, 0.15, 0), Vector3(0.5, 0.3, 0.34), INK, r)
	box(Vector3(0, 0.6, 0), Vector3(0.58, 0.65, 0.4), suit, r)
	box(Vector3(0, 1.12, 0), Vector3(0.44, 0.4, 0.44), helmet, r)
	box(Vector3(0, 1.12, 0.2), Vector3(0.34, 0.14, 0.08), INK, r)
	return r


func _start_race(i: int) -> void:
	race = i
	wet_on = i == 1
	night_on = i == 4
	_weather()
	arrivals = 3
	phase = "gap"
	phase_t = 2.4
	msg("R%d %s" % [i + 1, NAMES[i]], 1.8)
	note_t = 1.8


func _weather() -> void:
	floors[0].material_override = mat(WET if wet_on else ASPH)
	floors[1].material_override = mat(Color("93a6bc") if wet_on else Color("aeb6c2"))
	for d in drops:
		d.visible = wet_on
	for c in passers:
		c.lamps.visible = night_on
	for c in cars:
		c.lamps.visible = night_on
	if env_node and env_node.environment:
		env_node.environment.background_color = Color("1d2c52") if night_on else (Color("c4d3e2") if wet_on else Color("d8eeff"))
		env_node.environment.ambient_light_energy = 0.9 if night_on else 0.6
	if sun_node:
		sun_node.light_energy = 0.35 if night_on else 0.9


func _lv(k: String) -> int:
	return int(ups.get(k, 0))


func _step(dt: float) -> void:
	still_t -= dt
	note_t -= dt
	var tdt := dt * (0.1 if still_t > 0.0 else 1.0)  # 차가 서는 순간 세상이 멈춘다
	_sequence(dt)
	if dead:
		dead_t -= dt
		fly.y -= 28.0 * dt
		me_p += fly * dt
		if me_p.y < 0.0:
			me_p.y = 0.0
			fly *= 0.4
		me.position = me_p
		me.rotation += Vector3(9.0, 4.0, 6.0) * dt
		if dead_t <= 0.0:
			end()
	else:
		_move_me(dt)
		_work(dt)
	_mate_step(dt)
	for c in cars:
		_car_step(c, dt)
	_pass_step(tdt)
	if not dead:
		_hits()
	_fx(dt, tdt)


func _sequence(dt: float) -> void:
	match phase:
		"gap":
			phase_t -= dt
			if phase_t <= 0.0:
				_arrive()
		"live":
			for c in cars:
				if c.state != "idle":
					return
			if arrivals > 0:
				phase = "gap"
				phase_t = randf_range(1.3, 2.3)
			else:
				_race_done()
		"pick":
			_pick_step(dt)
		"next":
			phase_t -= dt
			if phase_t <= 0.0:
				_start_race(race + 1)
		"end":
			phase_t -= dt
			if phase_t <= 0.0:
				end()


func _arrive() -> void:
	arrivals -= 1
	phase = "live"
	var dbl := race == 3 or (race == 4 and arrivals % 2 == 0)
	var overrun := (race == 2 or race == 4) and randf() < 0.65
	_send(cars[0], Z0 + (randf_range(0.9, 1.8) if overrun else 0.0), -75.0, true)
	if dbl:
		_send(cars[1], Z0 - 5.6, -110.0, false)
	beep(520.0, 0.18, 0.0, 0.25)
	beep(390.0, 0.3, 0.0, 0.2)
	msg("두 대!" if dbl else ("오버런!" if overrun else "들어온다!"), 0.8)
	note_t = 0.8


func _send(c: Car, target: float, from_z: float, to_box: bool) -> void:
	c.state = "in"
	c.x = CX
	c.z = from_z
	c.vmax = 55.0 + race * 3.0
	c.v = c.vmax
	c.target = target
	c.to_box = to_box
	c.st = 0.0
	c.jack = false
	c.jprog = 0.0
	c.prog.fill(0.0)
	c.fuel = 0.0
	c.need_fuel = race > 0
	c.go_t = -1.0
	c.root.visible = true
	c.root.rotation = Vector3.ZERO
	for w in c.wheels:
		w.visible = true
		w.material_override = mat(WORN)


func _begin_service(c: Car) -> void:
	c.state = "service"
	c.st = 0.0
	if _lv("jack") > 0:
		c.jack = true
	still_t = 0.3
	shake = 0.4
	beep(130.0, 0.16, 60.0, 0.35)
	beep(1600.0, 0.05, 0.0, 0.15)


func _car_step(c: Car, dt: float) -> void:
	match c.state:
		"in":
			var d := c.target - c.z
			c.v = minf(c.vmax, sqrt(maxf(0.0, 2.0 * 110.0 * d)))
			c.z = minf(c.z + c.v * dt, c.target)
			if c.z >= c.target - 0.02:
				c.z = c.target
				c.v = 0.0
				if c.to_box:
					_begin_service(c)
				else:
					c.state = "wait"
		"wait":
			var o := cars[0]
			if o.state == "idle" or (o.state == "out" and o.z > Z0 + 5.0):
				c.target = Z0
				c.vmax = 9.0
				c.v = 0.0
				c.to_box = true
				c.state = "in"
		"service":
			c.st += dt
			if c.go_t >= 0.0:
				c.go_t -= dt
				if c.go_t < 0.0:
					c.state = "out"
					c.oz = c.z
					c.v = 6.0
					c.jack = false
					beep(170.0, 0.7, 900.0, 0.3)
		"out":
			c.v = minf(c.v + 45.0 * dt, 62.0)
			c.z += c.v * dt
			var dz := c.z - c.oz
			c.x = lerpf(CX, LANE, smoothstep(0.0, 14.0, dz))
			var ahead := lerpf(CX, LANE, smoothstep(0.0, 14.0, dz + 0.5))
			c.root.rotation.y = atan2(ahead - c.x, 0.5)
			if c.z > 40.0:
				c.state = "idle"
				c.root.visible = false
	var lift := 0.22 if c.jack and c.state == "service" else 0.0
	c.root.position = Vector3(c.x, lift, c.z)
	c.trail.visible = c.v > 15.0


func _move_me(dt: float) -> void:
	var spd := 8.5 * (1.25 if _lv("shoes") > 0 else 1.0)
	var want := Vector3(kit_move.x, 0, kit_move.y) * spd
	var acc := 60.0
	if wet_on:
		acc = 30.0 if _lv("shoes") > 0 else 18.0  # 젖은 바닥은 미끄럽다
	me_v = me_v.move_toward(want, acc * dt)
	me_p += me_v * dt
	me_p.x = clampf(me_p.x, -4.8, 6.3)
	me_p.z = clampf(me_p.z, -12.0, 4.5)
	# 서 있는 차는 밀어낸다
	for c in cars:
		if c.state == "service" or c.state == "wait":
			var dx := me_p.x - c.x
			var dz := me_p.z - c.z
			var px := 1.3 - absf(dx)
			var pz := 2.35 - absf(dz)
			if px > 0.0 and pz > 0.0:
				if px < pz:
					me_p.x += px * signf(dx if dx != 0.0 else 1.0)
				else:
					me_p.z += pz * signf(dz if dz != 0.0 else 1.0)
	me.position = me_p
	if me_v.length() > 0.5:
		me.rotation.y = atan2(me_v.x, me_v.z)
		step_t -= dt
		if step_t <= 0.0:
			step_t = 0.16
			beep(200.0, 0.03, 0.0, 0.07)


func _svc() -> Car:
	for c in cars:
		if c.state == "service" and c.go_t < 0.0:
			return c
	return null


func _spot(c: Car, j: int) -> Vector3:
	match j:
		0:
			return Vector3(c.x, 0, c.z + 2.7)
		5:
			return Vector3(c.x + 1.5, 0, c.z)
		6:
			return Vector3(c.x + 2.1, 0, c.z + 2.6)
	var w := j - 1
	return Vector3(c.x + (-1.4 if w % 2 == 0 else 1.4), 0, c.z + (1.4 if w < 2 else -1.4))


func _open(c: Car, j: int) -> bool:
	match j:
		0:
			return not c.jack
		5:
			return c.need_fuel and c.fuel < 1.0
		6:
			return _all_done(c)
	return c.prog[j - 1] < 1.0


func _all_done(c: Car) -> bool:
	if not c.jack or (c.need_fuel and c.fuel < 1.0):
		return false
	for p in c.prog:
		if p < 1.0:
			return false
	return true


## 발밑에서 가장 가까운 남은 일 (-1 없음)
func _spot_at(c: Car, p: Vector3, js: Array) -> int:
	var best_j := -1
	var best_d := 0.85
	for j in js:
		if not _open(c, j):
			continue
		var s := _spot(c, j)
		var d := Vector2(s.x - p.x, s.z - p.z).length()
		if d < best_d:
			best_d = d
			best_j = j
	return best_j


func _wheel_time() -> float:
	return 0.42 * pow(0.6, _lv("gun"))


## 일 j를 dt만큼 한다. 했으면 그 일의 진행도(0~1), 못 했으면 -1
func _job(c: Car, j: int, dt: float) -> float:
	match j:
		0:
			c.jprog += dt / 0.18
			if c.jprog >= 1.0:
				c.jack = true
				beep(200.0, 0.12, 520.0, 0.3)
			return c.jprog
		5:
			c.fuel = minf(1.0, c.fuel + dt / 0.75)
			if c.fuel >= 1.0:
				beep(1100.0, 0.08, 1400.0, 0.2)
			return c.fuel
	var w := j - 1
	if not c.jack:
		return -1.0
	var was := c.prog[w]
	c.prog[w] = minf(1.0, was + dt / _wheel_time())
	if was < 0.5 and c.prog[w] >= 0.5:
		c.wheels[w].visible = false
		_fling(c.wheels[w].global_position, -1.0 if w % 2 == 0 else 1.0)
		beep(320.0, 0.1, 140.0, 0.25)
	if was < 1.0 and c.prog[w] >= 1.0:
		c.wheels[w].visible = true
		c.wheels[w].material_override = mat(B if wet_on else D)
		beep(1300.0, 0.05, 0.0, 0.2)
	return c.prog[w]


func _fling(p: Vector3, side: float) -> void:
	for k in debris.size():
		if deb_t[k] <= 0.0:
			debris[k].position = p
			debris[k].visible = true
			deb_v[k] = Vector3(side * randf_range(4.0, 7.0), randf_range(4.0, 6.0), randf_range(-2.0, 2.0))
			deb_t[k] = 0.9
			return


func _work(dt: float) -> void:
	var c := _svc()
	for i in marks.size():
		marks[i].visible = c != null and _open(c, i)
		if marks[i].visible:
			var s := _spot(c, i)
			marks[i].position = Vector3(s.x, 0.03, s.z)
			if i >= 1 and i <= 4:
				marks[i].scale.y = 0.04 if c.jack else 0.015
	if c and _all_done(c):
		marks[6].scale = Vector3.ONE * (0.95 + 0.25 * absf(sin(c.st * 12.0))) * Vector3(1, 0.04, 1)
	var prog := -1.0
	if c and kit_held("work"):
		var j := _spot_at(c, me_p, [0, 1, 2, 3, 4, 5, 6])
		if j == 6:
			_release(c)
		elif j >= 0:
			prog = _job(c, j, dt)
			if prog < 0.0 and note_t <= 0.0:
				msg("잭 먼저!", 0.5)
				note_t = 0.5
				beep(160.0, 0.08, 0.0, 0.15)
	bar.visible = prog >= 0.0
	if prog >= 0.0:
		bar.scale.x = 0.9 * clampf(prog, 0.05, 1.0)
		gun_t -= dt
		if gun_t <= 0.0:
			gun_t = 0.045
			beep(700.0 + prog * 700.0, 0.04, 0.0, 0.12)


func _release(c: Car) -> void:
	c.go_t = 0.25
	var st := c.st
	var par := PAR[race]
	var gain := clampi(roundi((par - st) / 0.5), -3, 4)
	pos_now = clampi(pos_now - gain, 1, 20)
	score += int(maxf(0.0, 8.0 - st) * 25.0)
	msg("%.2f초  P%d" % [st, pos_now], 1.4)
	note_t = 1.4
	play("good")
	if st < 2.0:
		beep(1320.0, 0.3, 1760.0, 0.25)
	if pos_now >= 20:
		msg("20위 탈락", 2.0)
		note_t = 2.0
		phase = "end"
		phase_t = 1.2


func _mate_step(dt: float) -> void:
	mate.visible = _lv("mate") > 0
	if not mate.visible:
		return
	var home := Vector3(3.4, 0, Z0 + 0.5)
	var goal := home
	var c := _svc()
	var j := -1
	if c and c.jack:
		var jobs: Array = [2, 4]
		if _lv("mate") >= 2:
			jobs.append(5)
		for k in jobs:
			if _open(c, k):
				j = k
				break
		if j >= 0:
			goal = _spot(c, j)
	var d := goal - mate_p
	d.y = 0.0
	if d.length() > 0.2:
		mate_p += d.limit_length(6.0 * dt)
		mate.rotation.y = atan2(d.x, d.z)
	elif j >= 0:
		_job(c, j, dt)
	mate.position = mate_p


func _pass_step(tdt: float) -> void:
	pass_t -= tdt
	if pass_t <= 0.0 and phase != "end":
		pass_t = randf_range(1.3, 3.2) * (1.0 - race * 0.09)
		for c in passers:
			if c.state == "idle":
				c.state = "on"
				c.x = LANE
				c.z = -85.0
				c.v = randf_range(55.0, 70.0) + race * 4.0
				c.whoosh = false
				c.root.visible = true
				beep(240.0, 0.45, 600.0, 0.07)
				break
	var lit := false
	for c in passers:
		if c.state != "on":
			continue
		c.z += c.v * tdt
		c.root.position = Vector3(c.x, 0, c.z)
		if c.z < me_p.z + 1.0:
			lit = true
		if not c.whoosh and c.z > me_p.z - 4.0:
			c.whoosh = true
			beep(1000.0, 0.28, 160.0, 0.26)
			if absf(me_p.x - LANE) < 3.6:
				shake = maxf(shake, 0.25)
		if c.z > 40.0:
			c.state = "idle"
			c.root.visible = false
	var on := _lv("light") > 0
	var blink := lit and fmod(Time.get_ticks_msec() / 1000.0, 0.2) < 0.12
	for l in lights:
		l.visible = on
		l.material_override = mat(BAD if blink else Color("9aa3ad"))


func _hits() -> void:
	for c in cars:
		if (c.state == "in" or c.state == "out") and c.v > 2.0:
			if absf(me_p.x - c.x) < 1.3 and absf(me_p.z - c.z) < 2.5:
				_die(Vector3(me_p.x - c.x, 0, 1.0))
				return
	for c in passers:
		if c.state == "on" and absf(me_p.x - c.x) < 1.3 and absf(me_p.z - c.z) < 2.5:
			_die(Vector3(-0.3, 0, 1.0))
			return


func _die(push: Vector3) -> void:
	dead = true
	dead_t = 0.9
	fly = push.normalized() * 14.0 + Vector3(0, 9.0, 0)
	bar.visible = false
	msg("치였다!", 1.5)
	note_t = 1.5
	play("bad")
	beep(90.0, 0.4, 40.0, 0.35)
	shake = 0.7
	still_t = 0.25


func _race_done() -> void:
	score += (21 - pos_now) * 20
	if race >= NAMES.size() - 1:
		msg("시즌 완주 P%d" % pos_now, 2.5)
		note_t = 2.5
		play("win")
		phase = "end"
		phase_t = 1.8
		return
	msg("P%d 완주!" % pos_now, 1.5)
	note_t = 1.5
	play("win")
	phase = "pick"
	pick_hold = 0.0
	var opts: Array = []
	for k in UPS:
		if _lv(k) < int(UPS[k][1]):
			opts.append(k)
	opts.shuffle()
	for i in mini(3, opts.size()):
		_make_pad(opts[i], Vector3(3.95, 0, -6.4 + i * 2.6))


func _make_pad(kind: String, at: Vector3) -> void:
	var r := Node3D.new()
	r.position = at
	world.add_child(r)
	box(Vector3(0, 0.04, 0), Vector3(1.5, 0.08, 1.5), WHITE, r)
	match kind:
		"gun":
			box(Vector3(0, 0.45, 0), Vector3(0.8, 0.3, 0.3), INK, r)
			box(Vector3(-0.2, 0.2, 0), Vector3(0.2, 0.4, 0.22), A, r)
		"mate":
			box(Vector3(0, 0.45, 0), Vector3(0.5, 0.75, 0.35), B, r)
			box(Vector3(0, 1.0, 0), Vector3(0.4, 0.36, 0.4), WHITE, r)
		"light":
			box(Vector3(0, 0.6, 0), Vector3(0.15, 1.2, 0.15), WHITE, r)
			box(Vector3(0, 1.25, 0), Vector3(0.4, 0.3, 0.4), BAD, r)
		"shoes":
			box(Vector3(-0.22, 0.15, 0), Vector3(0.3, 0.2, 0.6), GOOD, r)
			box(Vector3(0.22, 0.15, 0.1), Vector3(0.3, 0.2, 0.6), GOOD, r)
		"jack":
			box(Vector3(0, 0.15, 0), Vector3(0.9, 0.2, 0.45), D, r)
			box(Vector3(0, 0.5, -0.3), Vector3(0.12, 0.6, 0.12), INK, r)
	pads.append(r)
	pad_kind.append(kind)


func _pick_step(dt: float) -> void:
	var on := -1
	for i in pads.size():
		if Vector2(pads[i].position.x - me_p.x, pads[i].position.z - me_p.z).length() < 0.85:
			on = i
	if on < 0:
		pick_hold = 0.0
		if note_t <= 0.0:
			msg("장비 고르기", 0.2)
		return
	var kind := pad_kind[on]
	msg(String(UPS[kind][0]), 0.2)
	note_t = 0.2
	if not kit_held("work"):
		pick_hold = 0.0
		return
	pick_hold += dt
	if pick_hold < 0.35:
		return
	ups[kind] = _lv(kind) + 1
	for p in pads:
		p.queue_free()
	pads.clear()
	pad_kind.clear()
	play("good")
	msg(String(UPS[kind][0]) + "!", 1.0)
	note_t = 1.0
	phase = "next"
	phase_t = 1.0


func _fx(dt: float, tdt: float) -> void:
	shake = maxf(0.0, shake - dt * 1.5)
	var tr := cam_base
	tr.origin += Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * shake * 0.35
	cam.transform = tr
	if wet_on:
		for d in drops:
			d.position.y -= 20.0 * tdt
			if d.position.y < 0.0:
				d.position = Vector3(randf_range(-5, 6), randf_range(7, 9), randf_range(-20, 5))
	for k in debris.size():
		if deb_t[k] > 0.0:
			deb_t[k] -= dt
			deb_v[k].y -= 22.0 * dt
			debris[k].position += deb_v[k] * dt
			debris[k].rotation.z += 10.0 * dt
			if deb_t[k] <= 0.0:
				debris[k].visible = false
	board_me.position.z = lerpf(board_me.position.z, -16.0 + (pos_now - 1) * 0.55, minf(1.0, dt * 6.0))
	# 스톱워치
	var c := _svc()
	if c:
		var par := PAR[race]
		gauge(c.st / par, GOOD if c.st < par else BAD)
		if note_t <= 0.0:
			msg("%.2f" % c.st, 0.12)
