extends Tofu
## 폭주 열차 지붕(3인칭 등뒤). 왼손 조이스틱으로 맨 뒤 객차에서 기관차 제동기까지 달린다. 열차는 계속 빨라지고 맞바람이 나를 뒤로 민다.
## 점프로 객차 틈을 넘고, 터널 앞에선 엎드리기(누르고 있기: 바람을 안 맞지만 기지도 못한다). 연결부 바로 뒤에서 '핀'을 뽑으면 뒤 객차가 떨어져 열차가 느려진다(발 디딜 곳도 줄어듦).
## 죽음: 바람에 밀려 맨 뒤로 떨어짐, 틈에 빠짐, 선 채로 터널. 제동기에 닿으면 다음 편성(더 길고 더 빨리 가속).

const CL := 8.0  # 객차 길이
const G := 1.4  # 객차 사이 틈
const HALF := 1.1  # 지붕 반폭
const ROOF := 3.0
const RUN := 6.5  # 내 달리기 (m/s)
const W0 := 9.0  # 이 속도부터 바람이 민다
const WK := 0.5  # 바람 = (열차 속도 - W0) * WK
const TL := 16.0  # 터널 길이
const NPOLE := 14
const NSTR := 14
const NTUN := 3
const STEEL := Color("dfe3e8")
const WOOD := Color("c8a27a")
const TRAINS := [
	{"cars": 5, "v0": 9.0, "acc": 0.45, "tun": 150.0, "col": B},
	{"cars": 7, "v0": 11.0, "acc": 0.6, "tun": 120.0, "col": C},
	{"cars": 9, "v0": 13.0, "acc": 0.75, "tun": 95.0, "col": A},
]

var ti := 0
var T: Dictionary = {}
var level: Node3D
var phase := "run"  # run / fall / brake / next
var cars: Array[Node3D] = []
var car_on: Array[bool] = []
var car_dz: Array[float] = []
var pins: Array[MeshInstance3D] = []
var vents: Array[Vector2] = []  # (x, z)
var rear_i := 0  # 붙어 있는 맨 뒤 객차
var tv := 0.0  # 열차 속도
var dist := 0.0  # 달린 거리
var wind := 0.0
var me: Node3D
var body: Node3D
var mx := 0.0
var mz := 0.0
var my := 0.0  # 지붕 위 높이
var vz := 0.0
var vy := 0.0
var air := false
var prone := false
var on_car := 0
var fall_t := 0.0
var fall_v := Vector3.ZERO
var next_t := 0.0
var poles: Array[Node3D] = []
var streaks: Array[MeshInstance3D] = []
var tuns: Array[Node3D] = []
var tun_d: Array[float] = []
var tun_i := 0
var warned := -1
var clock := 0.0
var hum_t := 0.0
var step_t := 0.0
var cam_base := Vector3.ZERO
var cam_ready := false


func _setup() -> void:
	howto = "폭주 열차 지붕. 왼손 조이스틱으로 맨 뒤 객차에서 기관차 제동기까지 달린다.\n열차는 계속 빨라지고 맞바람이 나를 뒤로 민다. 객차 틈은 점프, 터널 앞에선 엎드리기를 누르고 있기(바람도 안 맞는다). 지붕 환기구는 옆으로 피하거나 뛰어넘는다.\n연결부 바로 뒤에서 '핀'을 누르면 뒤 객차가 떨어져 열차가 느려진다. 대신 발 디딜 곳이 준다.\n맨 뒤로 밀려 떨어지거나, 틈에 빠지거나, 선 채로 터널에 들어가면 죽는다."
	time_limit = 0.0
	cam.fov = 70.0
	cam.far = 260.0
	kit_stick()
	kit_button("jump", "점프", Vector2(590, 1090), 105.0, GOOD)
	kit_button("duck", "엎드리기", Vector2(600, 880), 78.0, B)
	kit_button("pin", "핀", Vector2(420, 950), 66.0, D)


func _reset() -> void:
	ti = 0
	level = null
	_build()


# ---- 편성 하나 만들기 ----
func _build() -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	T = TRAINS[ti]
	var n: int = T["cars"]
	var col: Color = T["col"]
	var rng := RandomNumberGenerator.new()
	rng.seed = ti * 31 + 5
	# 땅·선로
	box(Vector3(0, -0.5, -150), Vector3(240, 1.0, 700), Color("b2f2bb"), level)
	for s in [-0.9, 0.9]:
		box(Vector3(s, 0.1, -150), Vector3(0.2, 0.2, 700), STEEL, level)
	# 전봇대·덤불 (돌려 쓴다)
	poles.clear()
	for i in NPOLE:
		var p := Node3D.new()
		p.position = Vector3(0, 0, -200.0 + i * 18.0)
		level.add_child(p)
		box(Vector3(6.0, 2.5, 0), Vector3(0.3, 5.0, 0.3), WOOD, p)
		box(Vector3(6.0, 4.8, 0), Vector3(1.6, 0.2, 0.2), WOOD, p)
		var bs := rng.randf_range(1.2, 2.6)
		box(Vector3(-5.5 - rng.randf() * 6.0, bs * 0.5, 0), Vector3(bs, bs, bs), GOOD, p)
		poles.append(p)
	# 바람 줄기
	streaks.clear()
	for i in NSTR:
		var m := box(Vector3(rng.randf_range(-4, 4), rng.randf_range(3.6, 7.0), -rng.randf_range(0, 80)), Vector3(0.06, 0.06, 2.6), WHITE, level)
		streaks.append(m)
	# 터널 (돌려 쓴다)
	tuns.clear()
	for i in NTUN:
		var tn := Node3D.new()
		level.add_child(tn)
		for s in [-1.0, 1.0]:
			box(Vector3(s * 3.4, 2.2, 0), Vector3(1.2, 4.4, TL), STEEL, tn)
		box(Vector3(0, 4.1, 0), Vector3(8.0, 0.9, TL), INK, tn)
		tn.visible = false
		tuns.append(tn)
	tun_d.clear()
	var dd: float = 70.0
	for i in 40:
		dd += T["tun"] * rng.randf_range(0.75, 1.3)
		tun_d.append(dd)
	tun_i = 0
	warned = -1
	# 객차 (0 = 기관차, 앞이 -z)
	cars.clear()
	car_on.clear()
	car_dz.clear()
	pins.clear()
	vents.clear()
	for i in n:
		var c := Node3D.new()
		var z0 := i * (CL + G) + CL * 0.5
		c.position = Vector3(0, 0, z0)
		level.add_child(c)
		var cc := col if i > 0 else INK
		box(Vector3(0, 1.75, 0), Vector3(HALF * 2.0 + 0.2, 2.5, CL), cc, c)
		box(Vector3(0, 0.4, 0), Vector3(HALF * 2.0 - 0.2, 0.6, CL - 0.6), INK if i > 0 else STEEL, c)
		if i == 0:
			box(Vector3(0, 2.0, 2.0), Vector3(HALF * 2.0 + 0.4, 2.9, 3.0), BAD, c)  # 운전실
			box(Vector3(0, 3.9, -2.5), Vector3(0.9, 1.6, 0.9), INK, c)  # 굴뚝
			box(Vector3(0, ROOF + 0.35, -3.4), Vector3(0.5, 0.7, 0.35), BAD, c)  # 제동기
		else:
			var nv := 1 if (i < 3 or i == n - 1) else 2
			for k in nv:
				# 한 객차에 둘이면 앞뒤로 떨어뜨려 옆으로 지나갈 길(≥0.65)을 남긴다. 맨 뒤 객차는 하나, 출발점(뒤끝-1.2) 앞 2.4m 비움
				var ex := rng.randf_range(-0.45, 0.45)
				var ez := z0 + (rng.randf_range(-2.4, -0.6 if i == n - 1 else 2.4) if nv == 1 else (-1.7 if k == 0 else 1.7) + rng.randf_range(-0.6, 0.6))
				box(Vector3(ex, ROOF + 0.25, ez - z0), Vector3(0.8, 0.5, 0.8), SOFT, c)
				vents.append(Vector2(ex, ez))
		cars.append(c)
		car_on.append(true)
		car_dz.append(0.0)
		if i < n - 1:
			var pz := i * (CL + G) + CL + G * 0.5
			box(Vector3(0, 2.2, pz), Vector3(0.5, 0.4, G + 0.6), INK, level)  # 연결기
			var pn := box(Vector3(0, 2.75, pz), Vector3(0.35, 0.7, 0.35), D, level)  # 핀
			pins.append(pn)
	rear_i = n - 1
	_make_me()
	# 시작 상태
	phase = "run"
	tv = T["v0"]
	dist = 0.0
	wind = 0.0
	mx = 0.0
	mz = rear_i * (CL + G) + CL - 1.2
	my = 0.0
	vz = 0.0
	vy = 0.0
	air = false
	prone = false
	on_car = rear_i
	fall_t = 0.0
	cam_ready = false
	_place_me()
	msg("%d편성 · %d량" % [ti + 1, n], 1.6)


func _make_me() -> void:
	me = Node3D.new()
	level.add_child(me)
	body = Node3D.new()
	me.add_child(body)
	box(Vector3(0, 0.45, 0), Vector3(0.44, 0.7, 0.3), ME, body)
	box(Vector3(0, 1.05, 0), Vector3(0.56, 0.5, 0.34), A, body)
	box(Vector3(0, 1.5, 0), Vector3(0.36, 0.36, 0.36), SOFT, body)
	box(Vector3(0, 1.72, 0), Vector3(0.44, 0.1, 0.5), D, body)  # 모자


func _place_me() -> void:
	me.position = Vector3(mx, ROOF + my, mz)
	if prone:
		body.rotation.x = -PI * 0.5
		body.position = Vector3(0, 0.2, 0.3)
	else:
		body.rotation.x = 0.0
		body.position = Vector3(0, absf(sin(clock * 16.0)) * 0.1 if (vz < -1.0 and not air) else 0.0, 0)


func _rear_end() -> float:
	return rear_i * (CL + G) + CL


func _coupling(i: int) -> float:
	return i * (CL + G) + CL + G * 0.5


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	clock += dt
	if phase == "run":
		tv += T["acc"] * dt
		_move(dt)
		if phase == "run":
			_tunnels(dt)
		if phase == "run":
			_pin()
		if phase == "run" and mz < 1.4 and on_car == 0:
			_brake_on()
	elif phase == "fall":
		fall_t += dt
		fall_v.y -= 20.0 * dt
		me.position += fall_v * dt
		me.rotate_x(dt * 7.0)
		if fall_t > 1.3:
			end()
	elif phase == "brake":
		tv = move_toward(tv, 0.0, 7.0 * dt)
		_tunnels(dt)
		if tv <= 0.0:
			phase = "next"
			next_t = 1.0
			ti += 1
			if ti >= TRAINS.size():
				play("win")
				end()
				return
	elif phase == "next":
		next_t -= dt
		if next_t <= 0.0:
			_build()
			return
	dist += tv * dt
	wind = maxf(0.0, tv - W0) * WK
	gauge(clampf(wind / RUN, 0.0, 1.0), GOOD.lerp(BAD, clampf(wind / RUN, 0.0, 1.0)))
	_scroll(dt)
	_detached(dt)
	_camera(dt)
	_sound(dt)


func _move(dt: float) -> void:
	var push := wind
	if air:
		vy -= 20.0 * dt
		my += vy * dt
		vz += push * 1.6 * dt
		mz += vz * dt
		mx = clampf(mx + kit_move.x * 1.5 * dt, -HALF, HALF)
		if my <= 0.0:
			my = 0.0
			air = false
			vy = 0.0
			if _in_gap():
				_fall("틈!")
				return
			beep(150.0, 0.06, 0.0, 0.2)
	else:
		prone = kit_held("duck")
		var want := kit_move.y * (1.2 if prone else RUN)
		if prone:
			push *= 0.12
		vz = move_toward(vz, want + push, 36.0 * dt)
		mz += vz * dt
		mx = clampf(mx + kit_move.x * (1.0 if prone else 4.0) * dt, -HALF, HALF)
		if not prone and kit_just("jump"):
			air = true
			vy = 7.0
			beep(420.0, 0.1, 700.0, 0.25)
		if not air:
			step_t -= dt * absf(vz) / RUN
			if vz < -0.8 and step_t <= 0.0:
				step_t = 0.26
				beep(230.0, 0.03, 0.0, 0.12)
			if _in_gap():
				_fall("틈!")
				return
		# 환기구에 막힌다
		if my < 0.4:
			for v in vents:
				var dx := mx - v.x
				var dz := mz - v.y
				if absf(dx) < 0.65 and absf(dz) < 0.65:
					if absf(dx) > absf(dz):
						mx = v.x + signf(dx) * 0.65
					else:
						mz = v.y + signf(dz) * 0.65
						if (dz > 0.0 and vz < 0.0) or (dz < 0.0 and vz > 0.0):
							vz = 0.0
	if mz > _rear_end() + 0.25:
		_fall("떨어졌다")
		return
	mz = maxf(mz, 0.4)
	var ci := clampi(int(mz / (CL + G)), 0, cars.size() - 1)
	if ci < on_car:
		on_car = ci
		score += 1
		beep(600.0, 0.06, 900.0, 0.15)
	elif ci > on_car:
		on_car = ci
	_place_me()


func _in_gap() -> bool:
	for i in rear_i:
		if absf(mz - _coupling(i)) < G * 0.5 - 0.1:
			return true
	return false


func _fall(why: String) -> void:
	phase = "fall"
	fall_t = 0.0
	fall_v = Vector3(0, 1.0, tv * 0.4)
	prone = false
	_place_me()
	msg(why, 1.3)
	play("bad")


func _pin() -> void:
	if not kit_just("pin"):
		return
	if air:
		msg("공중에선 못 뽑는다", 0.5)
		return
	for i in rear_i:
		var c := _coupling(i)
		# 틈 위(점프 중 착지 직전)가 아니라 객차 위에 서 있을 때만: 잘린 뒤 내 발밑이 남는다
		if c > mz and c - mz < 2.4 and c - mz >= G * 0.5:
			var cut := rear_i - i
			for j in range(i + 1, rear_i + 1):
				car_on[j] = false
				car_dz[j] = 0.0
			for j in range(i, rear_i):
				pins[j].visible = false
			rear_i = i
			tv = maxf(4.0, tv - 3.0 * cut)
			score += 2 * cut
			msg("%d량 분리!" % cut, 0.9)
			beep(900.0, 0.08, 300.0, 0.3)
			beep(120.0, 0.25, 60.0, 0.3)
			return
	beep(200.0, 0.05, 0.0, 0.12)
	msg("연결부 뒤에서", 0.5)


func _brake_on() -> void:
	phase = "brake"
	score += 20
	prone = false
	_place_me()
	msg("제동!", 1.4)
	play("win")
	beep(1500.0, 0.6, 400.0, 0.25)


func _detached(dt: float) -> void:
	for j in cars.size():
		if car_on[j]:
			continue
		var c := cars[j]
		if not c.visible:
			continue
		car_dz[j] += (T["acc"] + 1.2) * dt
		c.position.z += car_dz[j] * dt
		if c.position.z > 90.0:
			c.visible = false


func _tunnels(dt: float) -> void:
	# 지나간 터널 넘기기
	while tun_i < tun_d.size() and dist - tun_d[tun_i] - TL * 0.5 > _rear_end() + 30.0:
		tun_i += 1
	for j in NTUN:
		var k := tun_i + j
		var tn := tuns[j]
		if k >= tun_d.size():
			tn.visible = false
			continue
		var zc := dist - tun_d[k]
		tn.visible = zc > -220.0
		tn.position.z = zc
	if tun_i >= tun_d.size():
		return
	var zc0 := dist - tun_d[tun_i]
	# 다가올 때 경고
	if warned < tun_i and zc0 > mz - TL * 0.5 - maxf(tv, 6.0) * 1.6:
		warned = tun_i
		msg("터널!", 0.8)
		beep(1200.0, 0.15, 1600.0, 0.3)
	if phase != "run":
		return
	for j in NTUN:
		var k := tun_i + j
		if k >= tun_d.size():
			break
		var zc := dist - tun_d[k]
		if absf(mz - zc) < TL * 0.5 + 0.2:
			if air or not prone:
				_fall("터널에 쾅")
				return
			if fmod(clock * 8.0, 1.0) < dt * 8.0:
				beep(90.0, 0.08, 0.0, 0.2)


func _scroll(dt: float) -> void:
	for p in poles:
		p.position.z += tv * dt
		if p.position.z > 52.0:
			p.position.z -= NPOLE * 18.0
	var show := tv > 6.0
	for s in streaks:
		s.visible = show
		s.position.z += (tv * 1.4 + 4.0) * dt
		if s.position.z > mz + 12.0:
			s.position.z -= 92.0
			s.position.x = randf_range(-4.0, 4.0)
			s.position.y = randf_range(3.6, 7.0)


func _camera(dt: float) -> void:
	var k := clampf(tv / 28.0, 0.0, 1.0)
	var tgt := me.position + Vector3(0, 3.0 + k * 0.6, 6.2 + k * 1.2)
	if phase == "fall":
		tgt = Vector3(mx, ROOF + 3.0, mz + 6.2)
	if not cam_ready:
		cam_base = tgt
		cam_ready = true
	else:
		cam_base = cam_base.lerp(tgt, minf(1.0, dt * 6.0))
	var sway := sin(clock * 1.7) * 0.12 * k + sin(clock * 11.0) * 0.03 * k
	cam.position = cam_base + Vector3(sway, 0, 0)
	cam.look_at(Vector3(mx * 0.5, ROOF + 1.0, mz - 7.0))
	cam.rotation.z = sway * 0.4
	cam.fov = lerpf(cam.fov, 68.0 + k * 24.0, minf(1.0, dt * 4.0))


func _sound(dt: float) -> void:
	if tv < 0.5:
		return
	hum_t -= dt
	if hum_t <= 0.0:
		hum_t = clampf(0.5 - tv / 70.0, 0.08, 0.5)
		var w := clampf(wind / RUN, 0.0, 1.0)
		beep(50.0 + snappedf(tv * 3.0, 10.0), 0.09, 0.0, snappedf(0.05 + 0.2 * w, 0.02))
	if wind > 1.0 and not prone and randf() < dt * (1.0 + wind):
		beep(1100.0 + snappedf(wind * 80.0, 50.0), 0.2, 1500.0, 0.05)
