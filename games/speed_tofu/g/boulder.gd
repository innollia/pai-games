extends Tofu
## 신전 돌이 저절로 굴러간다. 좌우로 끌어 방향. 내리막에서 속도를 모아 오르막을 넘는다. 깔면 커지고 무거워진다(내리막엔 강하고 오르막엔 약함). 1.5초 넘게 느리거나 절벽에서 떨어지면 끝. 신전 문에서 문양(관성/점프)을 골라 마을로.

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
const CHOICE_D := 650.0
const ZONE2_D := 660.0
const GOAL_D := 1000.0
# 길: [거리, 높이, 반폭]. 높이는 점 사이를 잇고, 반폭은 다음 점까지 그대로.
const K := [
	[0.0, 60.0, 7.0], [30.0, 60.0, 7.0], [130.0, 38.0, 7.0], [170.0, 36.0, 6.0],
	[230.0, 44.0, 6.0], [250.0, 44.0, 6.0], [350.0, 21.0, 4.0], [370.0, 26.0, 4.0],
	[392.0, 16.0, 5.0], [420.0, 16.0, 2.6], [490.0, 12.0, 6.0], [540.0, 2.0, 6.0],
	[620.0, 11.0, 9.0], [660.0, 11.0, 8.0], [760.0, -6.0, 5.0], [900.0, -24.0, 6.0],
	[945.0, -18.0, 8.0], [1040.0, -20.0, 8.0],
]
const GAP := [370.0, 392.0]     # 점프대 끝 ~ 착지
const RAMP := [350.0, 370.0]
const BRIDGE := [420.0, 490.0]
const WIND := [760.0, 900.0]    # 마을: 구불길
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
	["pot", 55, -2.5], ["pot", 62, 2.0], ["pot", 72, 0.0], ["pot", 84, -4.0], ["pot", 88, 4.0],
	["pillar", 100, 0.0], ["pot", 112, 1.5], ["pot", 120, -2.0], ["pot", 126, 3.5],
	["statue", 140, 2.5], ["pillar", 152, -3.8], ["pillar", 152, 3.8],
	["pot", 175, -1.0], ["statue", 185, 2.5], ["pot", 195, -3.0], ["pot", 205, 1.0], ["statue", 215, -2.5],
	["pot", 262, 0.0], ["pillar", 280, 2.0], ["pot", 288, -2.5], ["statue", 300, 1.0], ["pillar", 312, -2.0], ["pot", 320, 2.5],
	["pot", 404, 0.0], ["pot", 410, 2.5], ["pot", 414, -2.5], ["pot", 455, 0.0],
	["pot", 500, -3.0], ["pot", 505, 0.0], ["pot", 510, 3.0], ["statue", 522, -3.0],
	["pillar", 575, 0.0], ["pot", 590, -3.0], ["pot", 600, 3.0],
	["house", 700, -4.5], ["house", 718, 4.0], ["house", 745, -4.0],
	["house", 790, 2.5], ["house", 830, -2.5], ["house", 870, 2.5],
	["house", 884, -2.5], ["house", 897, 2.5], ["pot", 970, -3.0], ["pot", 975, 0.0], ["pot", 980, 3.0],
]
const FENCES := [680.0, 705.0, 730.0, 755.0, 810.0, 850.0, 950.0]


class Thing:
	var n: MeshInstance3D
	var kd: Dictionary
	var d := 0.0
	var x := 0.0
	var base := 0.0
	var flat := false


var ball: MeshInstance3D
var band: MeshInstance3D
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
var cam_y := 0.0
var tick: ColorRect


func _setup() -> void:
	time_limit = 0.0
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
	cam_y = by
	ball = box(Vector3(0, by + 1.0, 0), Vector3.ONE * s, ME)
	box(Vector3.ZERO, Vector3(1.04, 1.04, 0.22), WHITE, ball)
	band = box(Vector3.ZERO, Vector3(0.22, 1.04, 1.04), ME, ball)
	_build()
	cam.position = Vector3(0, by + 7.0, 13.0)
	cam.fov = 55.0
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


func _solid(d: float) -> bool:
	return d >= -5.0 and d < K[K.size() - 1][0] and not (d > GAP[0] and d < GAP[1])


## (d, x) 아래 땅 높이. 땅이 없으면 NAN
func _ground(d: float, x: float) -> float:
	if not _solid(d) or absf(x - _cx(d)) > _hw(d) + 0.3:
		return NAN
	return _h(d)


func _inside(d: float, r: Array) -> bool:
	return d > r[0] and d < r[1]


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
		var thick := 0.8 if _inside(mid, BRIDGE) else 5.0
		var half := _hw(mid)
		var col := STONE if mid < ZONE2_D else GRASS
		if _inside(mid, BRIDGE):
			col = A
		elif _inside(mid, RAMP):
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
	# 아래 바닥: 계곡 물, 마을 들판
	box(Vector3(0, -32, -ZONE2_D * 0.5), Vector3(600, 1, ZONE2_D + 200.0), WATER)
	box(Vector3(0, -50, -(ZONE2_D + GOAL_D) * 0.5 - 40.0), Vector3(600, 1, GOAL_D - ZONE2_D + 200.0), GRASS)
	# 옆 풍경 (같은 판이면 같은 모양)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var d := 0.0
	while d < GOAL_D + 40.0:
		for sd: float in [-1.0, 1.0]:
			var x := _cx(d) + sd * (_hw(d) + rng.randf_range(9.0, 34.0))
			var sw := rng.randf_range(6.0, 13.0)
			if d < ZONE2_D:
				var top := _h(d) + rng.randf_range(-12.0, 26.0)
				box(Vector3(x, (top - 32.0) * 0.5, -d), Vector3(sw, top + 32.0, sw), [ROCK, STONE, WHITE].pick_random())
			else:
				var top := _h(d) - rng.randf_range(2.0, 9.0)
				box(Vector3(x, (top - 50.0) * 0.5, -d), Vector3(sw, top + 50.0, sw), GRASS)
				box(Vector3(x, top + 2.0, -d), Vector3(4.0, 4.0, 4.0), [A, B, C, WHITE].pick_random())
				box(Vector3(x, top + 4.3, -d), Vector3(4.6, 0.8, 4.6), BAD)
		d += rng.randf_range(16.0, 28.0)
	# 신전 (출발 뒤)
	box(Vector3(0, 66, 10), Vector3(20, 12, 6), WHITE)
	box(Vector3(0, 72.6, 10), Vector3(22, 1.4, 7), D)
	for z in [4.0, -8.0, -20.0]:
		for sd: float in [-1.0, 1.0]:
			box(Vector3(sd * 7.8, 64, z), Vector3(1.4, 8, 1.4), WHITE)
	# 문양 문 두 개 (왼쪽 관성 파랑, 오른쪽 점프 노랑)
	var gh := _h(CHOICE_D)
	for sd: float in [-1.0, 1.0]:
		var col := B if sd < 0.0 else D
		box(Vector3(sd * 8.6, gh + 4.5, -CHOICE_D), Vector3(1.2, 9, 1.2), col)
		box(Vector3(sd * 0.8, gh + 4.5, -CHOICE_D), Vector3(0.6, 9, 0.6), col)
		box(Vector3(sd * 4.7, gh + 9.0, -CHOICE_D), Vector3(8.6, 1.6, 1.6), col)
		box(Vector3(sd * 4.7, gh + 0.05, -CHOICE_D + 8.0), Vector3(7.0, 0.12, 16.0), col)
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
	ball.scale = Vector3.ONE * s
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
	var at := [600.0, CHOICE_D, ZONE2_D + 40.0, GOAL_D]
	if flag >= at.size() or dist < at[flag]:
		return
	match flag:
		0:
			msg("← 관성 · 점프 →", 2.2)
		1:
			carve = 1 if bx < 0.0 else 2
			band.material_override = mat(B if carve == 1 else D)
			msg("관성!" if carve == 1 else "점프! 톡 탭", 1.6)
			play("good")
		2:
			msg("마을", 1.2)
		3:
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
	beep(maxf(120.0, 560.0 - float(th.kd.mass) * 900.0), 0.1, 110.0, 0.28)
	if floori(s_goal) > before:
		msg("커졌다!", 0.6)
		play("good")


func _bonk(th: Thing) -> void:
	var sz: Vector3 = th.kd.size
	v *= 0.3
	dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
	hurt = 0.5
	play("bad")
	msg("쿵!", 0.6)


func _fall(text: String) -> void:
	fallen = true
	fall_t = 0.0
	v = minf(v, 6.0)
	msg(text, 2.0)
	beep(400.0, 0.6, 60.0, 0.3)


func _place(dt: float) -> void:
	ang += v * dt * PI / (2.0 * s)
	var m := fposmod(ang, PI * 0.5)
	ball.position = Vector3(bx, by + s * 0.5 * (cos(m) + sin(m)), -dist)
	ball.rotation.x = -ang
	ball.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else ME)
	var q := floori(ang / (PI * 0.5))
	roll_t -= dt
	if q != quarter:
		quarter = q
		if roll_t <= 0.0 and on_ground:
			roll_t = 0.07
			beep(clampf(60.0 + v * 2.0 - s * 4.0, 50.0, 200.0), 0.05, 45.0, 0.12)
	# 카메라: 뒤 위, 빠를수록 넓게
	if not fallen:
		cam_y = lerpf(cam_y, by, minf(1.0, dt * 6.0))
	var ahead := dist + 14.0 + v * 0.15
	var lx := lerpf(_cx(ahead), bx, 0.5)
	var want := Vector3(lerpf(_cx(dist), bx, 0.6), cam_y + 3.2 + s * 1.3, -dist + 8.0 + s * 2.0)
	cam.position = cam.position.lerp(want, minf(1.0, dt * 6.0))
	cam.look_at(Vector3(lx, cam_y + s * 0.4 - 1.5, -ahead))
	cam.fov = lerpf(cam.fov, clampf(52.0 + v * 0.55, 52.0, 90.0), minf(1.0, dt * 2.5))


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	last_x = p.x
	press_x = p.x
	press_at = clock


func _drag(p: Vector2) -> void:
	x_goal += (p.x - last_x) * 0.05
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
