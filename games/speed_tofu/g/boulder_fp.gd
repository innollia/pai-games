extends Tofu
## 1인칭: 구르는 신전 돌 앞머리에 낮게 타고 간다. 좌우로 끌어 방향. 깔면 커지고 무거워진다(오르막에 약함). 1.5초 넘게 느리거나 길에서 떨어지면 끝. 신전 문에서 문양(관성/점프)을 골라 강 건너 마을로.

const STONE := Color("efe1c4")
const ROCK := Color("e0c896")
const GRASS := Color("8ce99a")
const WATER := Color("a5d8ff")
const GRV := 40.0     # 비탈에서 끄는 힘
const FALL := 32.0    # 공중에서 떨어지는 힘
const DRAG := 0.0014
const ROLL := 0.3
const VSTOP := 8.0    # 이 아래로 STOP_T 초면 멈춤
const STOP_T := 1.5
const VMAX := 55.0    # 게이지 끝
const SMAX := 7.0
const CHOICE_D := 640.0
const ZONE2_D := 650.0
const GOAL_D := 1000.0
# 길: [거리, 높이, 반폭]. 높이는 점 사이를 잇고, 반폭은 다음 점까지 그대로.
const K := [
	[0.0, 60.0, 7.0], [30.0, 60.0, 7.0], [130.0, 36.0, 7.0], [170.0, 34.0, 6.0],
	[225.0, 44.0, 6.0], [245.0, 44.0, 6.0], [340.0, 20.0, 5.0], [360.0, 25.0, 5.0],
	[384.0, 15.0, 5.0], [410.0, 15.0, 2.8], [480.0, 11.0, 6.0], [530.0, 2.0, 6.0],
	[600.0, 10.0, 9.0], [650.0, 10.0, 8.0], [785.0, -10.0, 5.0], [800.0, -12.0, 5.0],
	[815.0, -8.0, 5.0], [840.0, -16.0, 6.0], [900.0, -26.0, 6.0], [940.0, -20.0, 8.0],
	[1040.0, -22.0, 8.0],
]
const GAPS := [[360.0, 384.0], [815.0, 840.0]]    # 점프대 끝 ~ 착지 (계곡, 강)
const RAMPS := [[340.0, 360.0], [800.0, 815.0]]
const BRIDGE := [410.0, 480.0]
const WIND := [660.0, 800.0]    # 마을: 구불길
# 깔 것: 크기, 깔 수 있는 내 크기, 점수, 커지는 양, 무게(깔 때 속도가 줄어드는 정도), 색
const KIND := {
	"pot": {"size": Vector3(1.4, 1.4, 1.4), "need": 0.0, "pts": 1, "grow": 0.09, "mass": 0.06, "col": [A, D]},
	"statue": {"size": Vector3(1.8, 3.2, 1.8), "need": 2.5, "pts": 3, "grow": 0.25, "mass": 0.18, "col": [WHITE, C]},
	"pillar": {"size": Vector3(2.2, 10.0, 2.2), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [WHITE]},
	"fence": {"size": Vector3(3.6, 1.2, 0.4), "need": 0.0, "pts": 1, "grow": 0.04, "mass": 0.04, "col": [WHITE, B]},
	"house": {"size": Vector3(5.0, 4.0, 5.0), "need": 3.4, "pts": 8, "grow": 0.5, "mass": 0.4, "col": [A, B, C]},
}
# [종류, 거리, 길 가운데에서 옆으로]
const PUT := [
	["pot", 50, -2.5], ["pot", 58, 2.0], ["pot", 66, 0.0], ["pot", 78, -4.0], ["pot", 84, 4.0],
	["pillar", 100, 0.0], ["pot", 110, 2.0], ["pot", 118, -2.0], ["pot", 124, 4.0],
	["statue", 138, -2.5], ["pillar", 152, -3.8], ["pillar", 152, 3.8], ["statue", 162, 0.0],
	["pot", 178, 1.0], ["statue", 190, -2.5], ["pot", 200, 3.0], ["statue", 212, 2.5], ["pot", 232, 0.0],
	["pot", 258, -2.0], ["pillar", 272, 1.5], ["statue", 286, -2.0], ["pot", 296, 2.5],
	["pillar", 308, -2.0], ["pillar", 308, 2.8], ["pot", 322, 0.0], ["statue", 332, 0.0],
	["pot", 396, -2.5], ["pot", 400, 2.5], ["pot", 425, 0.0], ["pot", 445, 0.0], ["pot", 465, 0.0],
	["pot", 492, -3.0], ["statue", 500, 2.5], ["pot", 512, 0.0], ["statue", 520, -3.0],
	["pillar", 560, 0.0], ["pot", 578, -4.0], ["pot", 586, 4.0], ["statue", 600, 0.0],
	["house", 690, -2.5], ["house", 712, 2.5], ["house", 738, -2.0], ["pot", 750, 2.5],
	["house", 768, 1.5], ["pot", 790, -1.5], ["pot", 795, 1.5],
	["house", 862, -2.5], ["house", 880, 2.5], ["statue", 920, 0.0],
	["pot", 962, -3.0], ["pot", 968, 0.0], ["pot", 974, 3.0], ["house", 988, 0.0],
]
const FENCES := [92.0, 250.0, 545.0, 672.0, 700.0, 725.0, 850.0, 945.0]


class Thing:
	var n: MeshInstance3D
	var kd: Dictionary
	var d := 0.0
	var x := 0.0
	var base := 0.0
	var flat := false


var lip: MeshInstance3D    # 화면 아래에 보이는 돌 앞머리
var lip_line: MeshInstance3D
var lip_band: MeshInstance3D
var things: Array[Thing] = []
var dist := 0.0
var v := 0.0
var s := 2.0
var s_goal := 2.0
var bx := 0.0
var x_goal := 0.0
var by := 0.0
var vy := 0.0
var on_ground := true
var last_g := 0.0
var fallen := false
var fall_t := 0.0
var slow_t := 0.0
var warn_t := 0.0
var hurt := 0.0
var ang := 0.0
var quarter := 0
var roll_t := 0.0
var carve := 0  # 0 없음, 1 관성, 2 점프
var won := false
var bonus := 0
var flag := 0  # 지나간 안내 지점 수
var clock := 0.0
var last_x := 0.0
var press_x := 0.0
var press_at := 0.0
var shake := 0.0
var aim := Vector3.ZERO
var tick: ColorRect


func _setup() -> void:
	time_limit = 0.0
	howto = "돌 앞머리에 타고 간다. 좌우로 끌어 방향을 잡는다.\n깔면 커지고 무거워진다. 무거우면 오르막에서 느려진다.\n속도가 검은 선 아래로 1.5초 떨어지거나 길에서 떨어지면 끝.\n신전 문에서 왼쪽 관성 / 오른쪽 점프(톡 탭) 문양을 고른다."
	tick = ColorRect.new()
	tick.color = INK
	tick.position = Vector2(600.0 * VSTOP / VMAX - 3.0, -10.0)
	tick.size = Vector2(6, 48)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(tick)


func _reset() -> void:
	dist = 0.0
	v = 16.0
	s = 2.0
	s_goal = 2.0
	bx = 0.0
	x_goal = 0.0
	by = _h(0.0)
	vy = 0.0
	on_ground = true
	last_g = by
	fallen = false
	fall_t = 0.0
	slow_t = 0.0
	warn_t = 0.0
	hurt = 0.0
	ang = 0.0
	quarter = 0
	carve = 0
	won = false
	bonus = 0
	flag = 0
	clock = 0.0
	shake = 0.0
	cam.h_offset = 0.0
	cam.v_offset = 0.0
	cam.fov = 62.0
	# 돌 앞머리: 카메라에 붙인다 (world 밖이라 판마다 직접 지우고 새로 만든다)
	if lip:
		lip.queue_free()
	lip = MeshInstance3D.new()
	lip.mesh = _unit
	lip.material_override = mat(ME)
	cam.add_child(lip)
	lip_line = box(Vector3(0, 0, 0.51), Vector3(1.0, 0.12, 0.02), WHITE, lip)
	lip_band = box(Vector3(0, 0, 0.52), Vector3(0.08, 1.0, 0.02), ME, lip)
	_build()
	aim = Vector3(0, by, -20.0)
	_place(0.0)
	msg("신전 계곡", 1.5)


# ---- 길 ----
func _seg(d: float) -> int:
	for i in range(K.size() - 2, -1, -1):
		if d >= K[i][0]:
			return i
	return 0


func _h(d: float) -> float:
	var i := _seg(d)
	var a: Array = K[i]
	var b: Array = K[i + 1]
	return lerpf(a[1], b[1], clampf((d - a[0]) / (b[0] - a[0]), 0.0, 1.0))


func _slope(d: float) -> float:
	var i := _seg(d)
	return (K[i + 1][1] - K[i][1]) / (K[i + 1][0] - K[i][0])


func _hw(d: float) -> float:
	return K[_seg(d)][2]


func _cx(d: float) -> float:
	if d > WIND[0] and d < WIND[1]:
		return 5.0 * sin((d - WIND[0]) / (WIND[1] - WIND[0]) * TAU)
	return 0.0


func _in_any(d: float, rs: Array) -> bool:
	for r in rs:
		if d > r[0] and d < r[1]:
			return true
	return false


func _solid(d: float) -> bool:
	return d >= -5.0 and d < K[K.size() - 1][0] and not _in_any(d, GAPS)


## (d, x) 아래 땅 높이. 땅이 없으면 NAN
func _ground(d: float, x: float) -> float:
	if not _solid(d) or absf(x - _cx(d)) > _hw(d) + 0.3:
		return NAN
	return _h(d)


func _build() -> void:
	var ds: Array[float] = [-6.0]
	for k in K:
		ds.append(k[0])
	var w: float = WIND[0]
	while w < WIND[1]:
		ds.append(w)
		w += 6.0
	ds.sort()
	for i in ds.size() - 1:
		var d0 := ds[i]
		var d1 := ds[i + 1]
		var mid := (d0 + d1) * 0.5
		if d1 - d0 < 0.01 or not _solid(mid):
			continue
		var h0 := _h(d0) if d0 >= 0.0 else _h(0.0)
		var p0 := Vector3(_cx(d0), h0, -d0)
		var p1 := Vector3(_cx(d1), _h(d1), -d1)
		var dir := p1 - p0
		var on_bridge := mid > BRIDGE[0] and mid < BRIDGE[1]
		var thick := 0.8 if on_bridge else 5.0
		var half := _hw(mid)
		var col := STONE if mid < ZONE2_D else GRASS
		if on_bridge:
			col = A
		elif _in_any(mid, RAMPS):
			col = D
		var bs := Basis.looking_at(dir.normalized(), Vector3.UP)
		var up := bs.y.normalized()
		var rt := bs.x.normalized()
		var m := box(Vector3.ZERO, Vector3.ONE, col)
		m.basis = bs
		m.scale = Vector3(half * 2.0, thick, dir.length() + 0.4)
		m.position = (p0 + p1) * 0.5 - up * thick * 0.5
		for sd: float in [-1.0, 1.0]:
			var e := box(Vector3.ZERO, Vector3.ONE, WHITE)
			e.basis = bs
			e.scale = Vector3(0.4, 0.1, dir.length() + 0.4)
			e.position = (p0 + p1) * 0.5 + rt * sd * (half - 0.2) + up * 0.04
		if mid >= ZONE2_D:
			var r := box(Vector3.ZERO, Vector3.ONE, STONE)
			r.basis = bs
			r.scale = Vector3(3.0, 0.1, dir.length() + 0.4)
			r.position = (p0 + p1) * 0.5 + up * 0.03
	# 길가 말뚝: 1인칭에서 스쳐 지나가며 속도가 보이게
	var pd := 4.0
	var alt := false
	while pd < GOAL_D + 30.0:
		if _solid(pd):
			var pc := (WHITE if alt else A) if pd < ZONE2_D else (WHITE if alt else B)
			for sd: float in [-1.0, 1.0]:
				box(Vector3(_cx(pd) + sd * (_hw(pd) + 0.7), _h(pd) + 0.6, -pd), Vector3(0.5, 1.2, 0.5), pc)
		alt = not alt
		pd += 7.0
	# 아래 바닥: 계곡 물, 마을 들판(강이 가로지른다)
	box(Vector3(0, -32, -ZONE2_D * 0.5), Vector3(600, 1, ZONE2_D + 200.0), WATER)
	box(Vector3(0, -50, -(ZONE2_D + GOAL_D) * 0.5 - 40.0), Vector3(600, 1, GOAL_D - ZONE2_D + 200.0), GRASS)
	box(Vector3(0, -49.4, -827.0), Vector3(600, 1, 30.0), WATER)
	# 옆 풍경 (같은 판이면 같은 모양)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var d := 0.0
	while d < GOAL_D + 40.0:
		for sd: float in [-1.0, 1.0]:
			var x := _cx(d) + sd * (_hw(d) + rng.randf_range(6.0, 30.0))
			var sw := rng.randf_range(5.0, 12.0)
			if d < ZONE2_D:
				var top := _h(d) + rng.randf_range(-10.0, 28.0)
				box(Vector3(x, (top - 32.0) * 0.5, -d), Vector3(sw, top + 32.0, sw), [ROCK, STONE, WHITE].pick_random())
			elif not (d > 812.0 and d < 842.0):
				var top := _h(d) - rng.randf_range(2.0, 9.0)
				box(Vector3(x, (top - 50.0) * 0.5, -d), Vector3(sw, top + 50.0, sw), GRASS)
				box(Vector3(x, top + 2.0, -d), Vector3(4.0, 4.0, 4.0), [A, B, C, WHITE].pick_random())
				box(Vector3(x, top + 4.3, -d), Vector3(4.6, 0.8, 4.6), BAD)
		d += rng.randf_range(14.0, 24.0)
	# 문양 문 두 개 (왼쪽 관성 파랑, 오른쪽 점프 노랑)
	var gh := _h(CHOICE_D)
	for sd: float in [-1.0, 1.0]:
		var col := B if sd < 0.0 else D
		box(Vector3(sd * 8.6, gh + 4.5, -CHOICE_D), Vector3(1.2, 9, 1.2), col)
		box(Vector3(sd * 0.8, gh + 4.5, -CHOICE_D), Vector3(0.6, 9, 0.6), col)
		box(Vector3(sd * 4.7, gh + 9.0, -CHOICE_D), Vector3(8.6, 1.6, 1.6), col)
		box(Vector3(sd * 4.7, gh + 0.05, -CHOICE_D + 10.0), Vector3(7.0, 0.12, 20.0), col)
	# 끝 문
	var eh := _h(GOAL_D)
	for sd: float in [-1.0, 1.0]:
		box(Vector3(sd * 8.5, eh + 5.0, -GOAL_D), Vector3(1.4, 10, 1.4), GOOD)
	box(Vector3(0, eh + 10.0, -GOAL_D), Vector3(18.4, 1.6, 1.6), GOOD)
	# 깔 것
	things.clear()
	for p in PUT:
		_thing(p[0], float(p[1]), float(p[2]))
	for fd in FENCES:
		var half := _hw(fd)
		var fx := -half + 1.8
		while fx < half - 1.0:
			_thing("fence", fd, fx)
			fx += 3.6


func _thing(kind: String, d: float, off: float) -> void:
	var th := Thing.new()
	th.kd = KIND[kind]
	th.d = d
	th.x = _cx(d) + off
	th.base = _h(d)
	var sz: Vector3 = th.kd.size
	th.n = box(Vector3(th.x, th.base + sz.y * 0.5, -d), sz, (th.kd.col as Array).pick_random())
	if kind == "house":
		box(Vector3(0, 0.6, 0), Vector3(1.15, 0.25, 1.15), BAD, th.n)
	elif kind == "pillar":
		box(Vector3(0, 0.46, 0), Vector3(1.4, 0.08, 1.4), D, th.n)
	things.append(th)


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	s = lerpf(s, s_goal, minf(1.0, dt * 4.0))
	var mm := s / 2.0
	hurt -= dt
	if fallen:
		fall_t += dt
		vy -= FALL * dt
		by += vy * dt
		dist += v * dt
		v *= 0.98
		_place(dt)
		if fall_t > 1.1:
			end()
		return
	bx = lerpf(bx, x_goal, minf(1.0, dt * 10.0))
	if on_ground:
		var sl := _slope(dist)
		var f := 0.5 + 0.5 * sqrt(mm)
		if sl > 0.0:
			f = (0.35 + 0.65 * sqrt(mm)) * (0.55 if carve == 1 else 1.0)
		v += (-sl * GRV * f - ROLL - DRAG * v * v / mm) * dt
		v = maxf(v, 0.0)
	else:
		v -= DRAG * 0.3 * v * v * dt
	dist += v * dt
	vy -= FALL * dt
	by += vy * dt
	var g := _ground(dist, bx)
	if is_nan(g):
		if on_ground and not _solid(dist):
			msg("점프!", 0.6)
			beep(330.0, 0.15, 660.0, 0.22)
		on_ground = false
		if by < last_g - 2.0:
			_fall("떨어짐!")
	elif by <= g:
		if by < g - 1.4:
			_fall("쾅!")
		else:
			if not on_ground and vy < -8.0:
				beep(90.0, 0.14, 50.0, 0.3)
				shake = maxf(shake, clampf(-vy * 0.03, 0.2, 0.8))
			by = g
			vy = v * _slope(dist)
			on_ground = true
			last_g = g
	else:
		on_ground = false
		last_g = g
	if fallen:
		_place(dt)
		return
	# 깔기 / 부딪힘
	for th in things:
		if th.flat:
			continue
		var dd := th.d - dist
		if absf(dd) > 12.0:
			continue
		var sz: Vector3 = th.kd.size
		if absf(dd) < (s + sz.z) * 0.5 and absf(th.x - bx) < (s + sz.x) * 0.45 and by < th.base + sz.y * 0.8:
			if s_goal >= float(th.kd.need):
				_crush(th, mm)
			elif hurt <= 0.0:
				_bonk(th)
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
	_marks()
	score = int(dist) + bonus
	var col := GOOD
	if v < VSTOP:
		col = BAD
	elif v < VSTOP * 1.8:
		col = D
	gauge(v / VMAX, col)
	_place(dt)


func _marks() -> void:
	var at := [585.0, CHOICE_D, ZONE2_D + 20.0, 790.0, GOAL_D]
	if flag >= at.size() or dist < at[flag]:
		return
	match flag:
		0:
			msg("← 관성 · 점프 →", 2.2)
		1:
			carve = 1 if bx < 0.0 else 2
			lip_band.material_override = mat(B if carve == 1 else D)
			lip_band.scale.x = 0.25
			msg("관성!" if carve == 1 else "점프! 톡 탭", 1.6)
			play("good")
		2:
			msg("마을", 1.2)
		3:
			msg("강! 빠르게", 1.2)
			beep(500.0, 0.1, 700.0, 0.2)
		4:
			won = true
			bonus += 500
			score = int(dist) + bonus
			msg("마을 도착!", 2.0)
			end()
	flag += 1


func _crush(th: Thing, mm: float) -> void:
	th.flat = true
	th.n.scale.y = 0.15
	th.n.position.y = th.base + 0.08
	v *= mm / (mm + float(th.kd.mass))
	var before := floori(s_goal)
	s_goal = minf(SMAX, s_goal + float(th.kd.grow))
	bonus += int(th.kd.pts) * 5
	shake = maxf(shake, 0.12 + float(th.kd.mass) * 1.2)
	beep(maxf(120.0, 560.0 - float(th.kd.mass) * 900.0), 0.1, 110.0, 0.28)
	if floori(s_goal) > before:
		msg("커졌다!", 0.6)
		play("good")


func _bonk(th: Thing) -> void:
	var sz: Vector3 = th.kd.size
	v *= 0.3
	dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
	hurt = 0.5
	shake = 1.0
	play("bad")
	msg("쿵!", 0.6)


func _fall(text: String) -> void:
	fallen = true
	fall_t = 0.0
	v = minf(v, 6.0)
	shake = 0.5
	msg(text, 2.0)
	beep(400.0, 0.6, 60.0, 0.3)


func _place(dt: float) -> void:
	ang += v * dt * PI / (2.0 * s)
	var m := fposmod(ang, PI * 0.5)
	var bob := s * 0.5 * (cos(m) + sin(m) - 1.0)  # 모난 돌이 굴러 위아래로 덜컹
	var q := floori(ang / (PI * 0.5))
	roll_t -= dt
	if q != quarter:
		quarter = q
		if roll_t <= 0.0 and on_ground:
			roll_t = 0.07
			beep(clampf(60.0 + v * 2.0 - s * 4.0, 50.0, 200.0), 0.05, 45.0, 0.12)
	# 눈: 돌 앞면 낮은 곳. 커지면 눈도 높아진다
	cam.position = Vector3(bx, by + 0.5 + s * 0.3 + bob * 0.5, -dist - s * 0.5 - 0.15)
	var ahead := dist + 12.0 + v * 0.25
	var want := Vector3(lerpf(_cx(ahead), bx, 0.6), _h(ahead) + 0.4 + s * 0.2, -ahead)
	if fallen:
		want = Vector3(bx, by - 6.0, -dist - 10.0)
	aim = aim.lerp(want, minf(1.0, dt * 7.0)) if dt > 0.0 else want
	cam.look_at(aim)
	cam.fov = lerpf(cam.fov, clampf(58.0 + v * 0.9, 58.0, 108.0), minf(1.0, dt * 2.5))
	# 흔들림 (깔 때·착지·부딪힘)
	shake *= exp(-dt * 7.0)
	cam.h_offset = randf_range(-1.0, 1.0) * shake * 0.35
	cam.v_offset = randf_range(-1.0, 1.0) * shake * 0.35
	# 화면 아래 돌 앞머리: 화각이 바뀌어도 화면 아래쪽에 붙어 있게
	var depth := 1.2
	var hw := depth * tan(deg_to_rad(cam.fov * 0.5))
	var hh := hw * 1280.0 / 720.0
	var tall := hh * (0.1 + 0.02 * s)
	lip.position = Vector3(0, -hh + tall * 0.5 - bob * 0.15, -depth)
	lip.scale = Vector3(hw * 2.2, tall, 0.2)
	lip_line.position.y = 0.5 - m / (PI * 0.5)  # 굴러가는 줄
	lip.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else ME)


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	last_x = p.x
	press_x = p.x
	press_at = clock


func _drag(p: Vector2) -> void:
	x_goal += (p.x - last_x) * 0.045
	last_x = p.x


func _lift(p: Vector2) -> void:
	# 점프 문양: 짧게 톡 치면 뛴다
	if carve == 2 and on_ground and not fallen and absf(p.x - press_x) < 24.0 and clock - press_at < 0.3:
		vy = 13.0
		by += 0.05
		on_ground = false
		beep(440.0, 0.12, 880.0, 0.25)


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)
