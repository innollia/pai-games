extends Tofu
## 굴러라 경주 (위에서 비스듬히 본 내리막): 돌 넷이 내리막 코스를 굴러 경주한다. 좌우로 끌어 방향만 튼다.
## 항아리를 깔면 커지고 무거워져 내리막에서 빠르지만 점프대에서 덜 뜬다. 화면은 1등을 따라가고 화면 뒤쪽은 산사태다.
## 뒤처져 산사태에 묻히거나 틈에 떨어지거나 절벽에 박으면 끝. 내가 1등이면 화면이 앞으로 쏠려 앞이 늦게 보인다(짧은 경고음만). 코스 3개.

const STONE := Color("efe1c4")
const ROCK := Color("e0c896")
const GRASS := Color("8ce99a")
const SNOW := Color("e9f5ff")
const MUD := Color("d9b382")
const SLIDE := Color("b08968")
const GRV := 40.0
const FALL := 32.0
const DRAG := 0.0014
const ROLL := 0.3
const VMAX := 60.0
const SMAX := 6.0
const BACK := 18.0        # 화면 초점에서 산사태까지
const LEAD_SHIFT := 30.0  # 내가 1등일 때 초점이 이만큼 뒤로 처진다
const PLACE_PTS := [300, 150, 60, 20]
const COURSES := [
	{"name": "신전 계곡", "n": 7, "sl": [0.14, 0.26], "hw": 7.0, "gap": [12.0, 17.0], "gapp": 0.45, "pots": 32, "pillars": 5, "slide": 18.0, "gnd": STONE, "side": ROCK},
	{"name": "협곡", "n": 8, "sl": [0.18, 0.3], "hw": 5.5, "gap": [15.0, 21.0], "gapp": 0.55, "pots": 34, "pillars": 10, "slide": 22.0, "gnd": GRASS, "side": MUD},
	{"name": "눈산", "n": 9, "sl": [0.22, 0.36], "hw": 5.0, "gap": [17.0, 25.0], "gapp": 0.6, "pots": 36, "pillars": 14, "slide": 26.0, "gnd": SNOW, "side": B},
]
# 깔 것: 크기, 깔 수 있는 내 크기, 점수, 커지는 양, 무게
const KIND := {
	"pot": {"size": Vector3(1.4, 1.4, 1.4), "need": 0.0, "pts": 1, "grow": 0.1, "mass": 0.06, "col": [A, D]},
	"statue": {"size": Vector3(1.8, 3.2, 1.8), "need": 2.6, "pts": 3, "grow": 0.3, "mass": 0.18, "col": [WHITE, C]},
	"pillar": {"size": Vector3(2.0, 8.0, 2.0), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [WHITE]},
}


class Thing:
	var n: MeshInstance3D
	var kd: Dictionary
	var d := 0.0
	var x := 0.0
	var base := 0.0
	var flat := false


class Stone:
	var n: MeshInstance3D
	var band: MeshInstance3D
	var d := 0.0
	var x := 0.0
	var xg := 0.0
	var y := 0.0
	var vy := 0.0
	var v := 0.0
	var s := 2.0
	var sg := 2.0
	var on := true
	var last_g := 0.0
	var alive := true
	var fallen := false
	var fall_t := 0.0
	var hurt := 0.0
	var ang := 0.0
	var quarter := 0
	var roll_t := 0.0
	var ai := true
	var skill := 1.0
	var greed := 0.5
	var think := 0.0
	var nick := ""
	var col := Color.WHITE
	var done := false
	var place := 0


var ci := 0
var cfg: Dictionary
var stage: Node3D
var K: Array = []
var gaps: Array = []
var ramps: Array = []
var goal_d := 0.0
var things: Array[Thing] = []
var stones: Array[Stone] = []
var me: Stone
var slide_n: MeshInstance3D
var slide_d := 0.0
var phase := "count"
var pt := 0.0
var clock := 0.0
var finished := 0
var lead_t := 0.0
var focus := 0.0
var cam_y := 0.0
var total := 0.0
var bonus := 0
var won := false
var last_x := 0.0
var radar_t := 0.0
var rumble_t := 0.0
var push_t := 0.0
var tick: ColorRect


func _setup() -> void:
	howto = "돌 넷이 내리막을 굴러 경주한다. 좌우로 끌어 방향을 튼다.\n항아리를 깔면 커지고 무거워진다: 내리막에서 빠르지만 점프대에서 덜 뜬다.\n화면은 1등을 따라가고 화면 뒤는 산사태. 뒤처져 묻히거나 틈에 떨어지면 끝.\n내가 1등이면 화면이 앞으로 쏠려 앞이 늦게 보인다."
	time_limit = 0.0
	tick = ColorRect.new()
	tick.color = INK
	tick.position = Vector2(600.0 * 8.0 / VMAX - 3.0, -10.0)
	tick.size = Vector2(6, 48)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(tick)


func _reset() -> void:
	ci = 0
	stage = null
	total = 0.0
	bonus = 0
	won = false
	clock = 0.0
	stones.clear()
	var cols := [ME, A, C, D]
	var nicks := ["나", "주황", "보라", "노랑"]
	for i in 4:
		var st := Stone.new()
		st.ai = i > 0
		st.col = cols[i]
		st.nick = nicks[i]
		st.n = box(Vector3.ZERO, Vector3.ONE * 2.0, st.col)
		box(Vector3.ZERO, Vector3(1.04, 1.04, 0.22), WHITE, st.n)
		st.band = box(Vector3.ZERO, Vector3(0.22, 1.04, 1.04), st.col.darkened(0.25), st.n)
		if st.ai:
			st.skill = [0.96, 1.0, 1.04][i - 1]
			st.greed = [0.7, 0.45, 0.25][i - 1]
		stones.append(st)
	me = stones[0]
	slide_n = box(Vector3.ZERO, Vector3(80.0, 12.0, 10.0), SLIDE)
	box(Vector3(0, 0.5, 0.2), Vector3(0.9, 0.5, 0.7), ROCK, slide_n)
	box(Vector3(0.1, 0.9, 0.0), Vector3(0.5, 0.5, 0.5), MUD, slide_n)
	_build()
	_start()


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


func _in_gap(d: float) -> bool:
	for g in gaps:
		if d > g[0] and d < g[1]:
			return true
	return false


func _in_ramp(d: float) -> bool:
	for r in ramps:
		if d > r[0] and d < r[1]:
			return true
	return false


func _solid(d: float) -> bool:
	return d >= -12.0 and d < K[K.size() - 1][0] and not _in_gap(d)


## (d, x) 아래 땅 높이. 땅이 없으면 NAN
func _gh(d: float, x: float) -> float:
	if not _solid(d) or absf(x) > _hw(d) + 0.3:
		return NAN
	return _h(d)


func _build() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	cfg = COURSES[ci]
	var rng := RandomNumberGenerator.new()
	rng.seed = 101 + ci * 17
	var hw: float = cfg.hw
	K.clear()
	gaps.clear()
	ramps.clear()
	var d := 0.0
	var h := 80.0
	# 출발 구간도 내리막: 평지면 출발 속도(12)가 산사태(18~26)보다 느려 첫 비탈 전에 모두 묻힌다
	K.append([-12.0, h + 36.0 * 0.16, hw])
	K.append([24.0, h, hw])
	d = 24.0
	for i in int(cfg.n):
		var L := rng.randf_range(42.0, 70.0)
		var sl := rng.randf_range(cfg.sl[0], cfg.sl[1])
		d += L
		h -= L * sl
		K.append([d, h, hw * rng.randf_range(0.75, 1.0)])
		if i > 0 and i < int(cfg.n) - 1 and rng.randf() < float(cfg.gapp):
			ramps.append([d, d + 12.0])
			d += 12.0
			h += 3.6
			K.append([d, h, hw])
			var g := rng.randf_range(cfg.gap[0], cfg.gap[1])
			gaps.append([d, d + g])
			d += g
			h -= g * 0.3 + 3.0
			K.append([d, h, hw])
	goal_d = d + 50.0
	h -= 50.0 * 0.15
	K.append([goal_d, h, hw])
	K.append([goal_d + 60.0, h - 6.0, hw])
	# 바닥 상자
	for i in K.size() - 1:
		var d0: float = K[i][0]
		var d1: float = K[i + 1][0]
		var mid := (d0 + d1) * 0.5
		if d1 - d0 < 0.01 or not _solid(mid):
			continue
		var p0 := Vector3(0, _h(d0), -d0)
		var p1 := Vector3(0, _h(d1), -d1)
		var dir := p1 - p0
		var half := _hw(mid)
		var col: Color = D if _in_ramp(mid) else cfg.gnd
		var bs := Basis.looking_at(dir.normalized(), Vector3.UP)
		var up := bs.y.normalized()
		var rt := bs.x.normalized()
		var m := box(Vector3.ZERO, Vector3.ONE, col, stage)
		m.basis = bs
		m.scale = Vector3(half * 2.0, 6.0, dir.length() + 0.4)
		m.position = (p0 + p1) * 0.5 - up * 3.0
		for sd: float in [-1.0, 1.0]:
			var e := box(Vector3.ZERO, Vector3.ONE, WHITE, stage)
			e.basis = bs
			e.scale = Vector3(0.4, 0.12, dir.length() + 0.4)
			e.position = (p0 + p1) * 0.5 + rt * sd * (half - 0.2) + up * 0.05
	# 아래 바닥
	box(Vector3(0, -60, -goal_d * 0.5), Vector3(400, 1, goal_d + 300.0), Color("a5d8ff"), stage)
	# 옆 풍경
	var sd2 := -20.0
	while sd2 < goal_d + 40.0:
		for sd: float in [-1.0, 1.0]:
			var x := sd * (_hw(sd2) + rng.randf_range(6.0, 22.0))
			var sw := rng.randf_range(5.0, 11.0)
			var top := _h(sd2) + rng.randf_range(-6.0, 14.0)
			box(Vector3(x, (top - 60.0) * 0.5, -sd2), Vector3(sw, top + 60.0, sw), [cfg.side, STONE, WHITE].pick_random(), stage)
		sd2 += rng.randf_range(22.0, 34.0)
	# 끝 문
	var eh := _h(goal_d)
	for sd: float in [-1.0, 1.0]:
		box(Vector3(sd * (hw + 1.5), eh + 5.0, -goal_d), Vector3(1.4, 10, 1.4), GOOD, stage)
	box(Vector3(0, eh + 10.0, -goal_d), Vector3(hw * 2.0 + 4.4, 1.6, 1.6), GOOD, stage)
	# 깔 것
	things.clear()
	var tries := 0
	var np := 0
	while np < int(cfg.pots) and tries < 400:
		tries += 1
		var td := rng.randf_range(34.0, goal_d - 20.0)
		if not _open(td):
			continue
		_thing("statue" if rng.randf() < 0.18 else "pot", td, rng.randf_range(-_hw(td) + 1.2, _hw(td) - 1.2))
		np += 1
	np = 0
	while np < int(cfg.pillars) and tries < 800:
		tries += 1
		var td := rng.randf_range(60.0, goal_d - 30.0)
		if not _open(td):
			continue
		_thing("pillar", td, rng.randf_range(-_hw(td) + 1.6, _hw(td) - 1.6))
		np += 1


## 점프대·틈·착지 근처가 아닌 곳
func _open(d: float) -> bool:
	for r in ramps:
		if d > r[0] - 6.0 and d < r[1] + 2.0:
			return false
	for g in gaps:
		if d > g[0] - 2.0 and d < g[1] + 14.0:
			return false
	return true


func _thing(kind: String, d: float, off: float) -> void:
	var th := Thing.new()
	th.kd = KIND[kind]
	th.d = d
	th.x = off
	th.base = _h(d)
	var sz: Vector3 = th.kd.size
	th.n = box(Vector3(th.x, th.base + sz.y * 0.5, -d), sz, (th.kd.col as Array).pick_random(), stage)
	if kind == "pillar":
		box(Vector3(0, 0.46, 0), Vector3(1.4, 0.08, 1.4), D, th.n)
	things.append(th)


# ---- 코스 시작 ----
func _start() -> void:
	var xs := [0.0, -3.2, 3.2, -1.2]
	for i in 4:
		var st := stones[i]
		st.d = -2.0 - i * 1.5
		st.x = xs[i] * minf(1.0, cfg.hw / 7.0)
		st.xg = st.x
		st.y = _h(st.d)
		st.vy = 0.0
		st.v = 16.0
		st.on = true
		st.last_g = st.y
		st.alive = true
		st.fallen = false
		st.fall_t = 0.0
		st.hurt = 0.0
		st.done = false
		st.place = 0
		st.think = randf() * 0.2
		st.n.visible = true
		st.n.scale = Vector3.ONE * st.s
	slide_d = -40.0
	focus = me.d
	cam_y = me.y
	finished = 0
	lead_t = 0.0
	phase = "count"
	pt = 1.3
	radar_t = 0.0
	rumble_t = 0.0
	cam.fov = 40.0
	cam.position = Vector3(0, cam_y + 38.0, -(focus - 10.0))
	cam.look_at(Vector3(0, cam_y, -(focus + 4.0)))
	msg("%s" % cfg.name, 1.4)
	beep(440.0, 0.12)


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.6 and pt <= 0.6:
				beep(440.0, 0.12)
			if pt <= 0.0:
				phase = "race"
				msg("굴러!", 0.6)
				play("good")
		"race":
			_race(dt)
		"done":
			pt -= dt
			_tick_all(dt)
			_slide(dt)
			if pt <= 0.0:
				_next()
	_camera(dt)
	for st in stones:
		_place(st, dt)


func _race(dt: float) -> void:
	_tick_all(dt)
	_slide(dt)
	if over:
		return
	for st in stones:
		if st.alive and not st.done and st.d >= goal_d:
			st.done = true
			finished += 1
			st.place = finished
			if st == me:
				bonus += PLACE_PTS[finished - 1]
				msg("%d등!" % finished, 1.8)
				if finished == 1:
					play("win")
				else:
					play("good")
				phase = "done"
				pt = 1.8
			else:
				beep(330.0, 0.2, 440.0, 0.2)
				msg("%s 골인" % st.nick, 0.7)
	# 내가 1등이면 화면이 앞으로 쏠린다: 앞의 기둥·틈은 소리로만
	var ld := _leader()
	radar_t -= dt
	if ld == me and not me.done:
		if lead_t == 0.0:
			msg("선두! 앞이 안 보인다", 0.9)
			beep(900.0, 0.1, 1400.0, 0.2)
		lead_t += dt
		if lead_t > 0.5 and me.on:
			var ahead := me.d + 6.0 + me.v * 0.6
			var hit := _in_gap(ahead) or _in_ramp(ahead)
			for th in things:
				if not th.flat and th.kd.need > 50.0 and th.d > me.d and th.d < ahead and absf(th.x - me.x) < (me.s + 2.0) * 0.6:
					hit = true
			if hit and radar_t <= 0.0:
				radar_t = 0.22
				beep(420.0, 0.05, 0.0, 0.18)
	else:
		lead_t = maxf(lead_t - dt * 2.0, 0.0)
	# 산사태 가까움
	var gap_b := me.d - slide_d
	rumble_t -= dt
	if gap_b < 10.0 and rumble_t <= 0.0:
		rumble_t = 0.1 + gap_b * 0.04
		beep(70.0 + gap_b * 10.0, 0.08, 50.0, 0.22)
	score = int(total + maxf(me.d, 0.0)) + bonus
	var col := GOOD
	if gap_b < 6.0:
		col = BAD
	elif gap_b < 12.0:
		col = D
	gauge(me.v / VMAX, col)


func _leader() -> Stone:
	var w: Stone = null
	for st in stones:
		if st.alive and not st.done and not st.fallen and (w == null or st.d > w.d):
			w = st
	return w


func _tick_all(dt: float) -> void:
	for st in stones:
		if not st.alive:
			continue
		if st.ai and not st.fallen:
			_ai(st, dt)
		_move(st, dt)
	_push(dt)


## 산사태: 혼자서도 밀려오고, 화면 초점 뒤에는 늘 붙어 있다
func _slide(dt: float) -> void:
	slide_d = maxf(slide_d + float(cfg.slide) * dt, focus - BACK)
	for st in stones:
		if st.alive and not st.done and st.d < slide_d:
			_out(st, "묻혔다!")


func _move(st: Stone, dt: float) -> void:
	st.s = lerpf(st.s, st.sg, minf(1.0, dt * 4.0))
	st.n.scale = Vector3.ONE * st.s
	var mm := st.s / 2.0
	st.hurt -= dt
	if st.fallen:
		st.fall_t += dt
		st.vy -= FALL * dt
		st.y += st.vy * dt
		st.d += st.v * dt
		st.v *= 0.98
		if st.fall_t > 1.0:
			_out(st, "")
		return
	st.x = lerpf(st.x, st.xg, minf(1.0, dt * (10.0 if st == me else 6.0)))
	if st.on:
		var sl := _slope(st.d)
		var f := 0.5 + 0.5 * sqrt(mm)
		if sl > 0.0:
			f = 0.35 + 0.65 * sqrt(mm)
		st.v += (-sl * GRV * f * st.skill - ROLL - DRAG * st.v * st.v / mm) * dt
		st.v = maxf(st.v, 0.0)
	else:
		st.v -= DRAG * 0.3 * st.v * st.v * dt
	st.d += st.v * dt
	st.vy -= FALL * dt
	st.y += st.vy * dt
	var g := _gh(st.d, st.x)
	if is_nan(g):
		if st.on:
			if not _solid(st.d) and st.vy > 0.0:
				# 점프대에서 뜬다: 무거울수록 덜 뜬다
				st.vy *= 1.3 / (0.3 + mm)
				if st == me:
					msg("점프!", 0.5)
					beep(330.0, 0.15, 660.0, 0.22)
			elif st == me:
				beep(330.0, 0.1, 200.0, 0.15)
		st.on = false
		if st.y < st.last_g - 2.5:
			_fall(st, "떨어짐!")
	elif st.y <= g:
		if st.y < g - 1.4:
			_fall(st, "쾅!")
		else:
			if not st.on and st.vy < -8.0 and st == me:
				beep(90.0, 0.14, 50.0, 0.3)
			st.y = g
			st.vy = st.v * _slope(st.d)
			st.on = true
			st.last_g = g
	else:
		st.on = false
		st.last_g = g
	if st.fallen:
		return
	# 깔기 / 부딪힘
	for th in things:
		if th.flat:
			continue
		var dd := th.d - st.d
		if absf(dd) > 12.0:
			continue
		var sz: Vector3 = th.kd.size
		if absf(dd) < (st.s + sz.z) * 0.5 and absf(th.x - st.x) < (st.s + sz.x) * 0.45 and st.y < th.base + sz.y * 0.8:
			if st.sg >= float(th.kd.need):
				_crush(st, th, mm)
			elif st.hurt <= 0.0:
				_bonk(st, th)


## 돌끼리 밀기: 무거운 쪽이 가벼운 쪽을 옆으로 민다
func _push(dt: float) -> void:
	push_t -= dt
	for i in stones.size():
		var a := stones[i]
		if not a.alive or a.fallen:
			continue
		for j in range(i + 1, stones.size()):
			var b := stones[j]
			if not b.alive or b.fallen:
				continue
			var r := (a.s + b.s) * 0.5
			var dx := b.x - a.x
			if absf(b.d - a.d) < r and absf(dx) < r * 0.9:
				var ov := r * 0.9 - absf(dx)
				var sg := 1.0 if dx >= 0.0 else -1.0
				var wa := a.s / (a.s + b.s)
				b.x += sg * ov * wa
				a.x -= sg * ov * (1.0 - wa)
				b.xg += sg * ov * wa
				a.xg -= sg * ov * (1.0 - wa)
				if (a == me or b == me) and push_t <= 0.0:
					push_t = 0.3
					beep(150.0, 0.08, 100.0, 0.2)


func _crush(st: Stone, th: Thing, mm: float) -> void:
	th.flat = true
	th.n.scale.y = 0.15
	th.n.position.y = th.base + 0.08
	st.v *= mm / (mm + float(th.kd.mass))
	var before := floori(st.sg)
	st.sg = minf(SMAX, st.sg + float(th.kd.grow))
	if st == me:
		bonus += int(th.kd.pts) * 5
		beep(maxf(120.0, 560.0 - float(th.kd.mass) * 900.0), 0.1, 110.0, 0.28)
		if floori(st.sg) > before:
			msg("무거워졌다", 0.7)
			play("good")
	elif absf(th.d - focus) < 60.0:
		beep(400.0, 0.08, 110.0, 0.1)


func _bonk(st: Stone, th: Thing) -> void:
	var sz: Vector3 = th.kd.size
	st.v *= 0.3
	st.d = minf(st.d, th.d - (st.s + sz.z) * 0.5 - 0.2)
	st.hurt = 0.5
	if st == me:
		play("bad")
		msg("쿵!", 0.6)


func _fall(st: Stone, text: String) -> void:
	st.fallen = true
	st.fall_t = 0.0
	st.v = minf(st.v, 6.0)
	if st == me:
		msg(text, 2.0)
		beep(400.0, 0.6, 60.0, 0.3)


func _out(st: Stone, text: String) -> void:
	if not st.alive:
		return
	st.alive = false
	st.n.visible = false
	if st == me:
		if text != "":
			msg(text, 2.0)
			beep(80.0, 0.5, 40.0, 0.35)
		end()
	else:
		beep(300.0, 0.2, 120.0, 0.2)
		msg("%s 탈락" % st.nick, 0.7)


func _next() -> void:
	total += goal_d
	ci += 1
	if ci >= COURSES.size():
		won = true
		bonus += 500
		score = int(total) + bonus
		msg("완주!", 3.0)
		end()
		return
	play("good")
	_build()
	_start()


# ---- 상대 ----
func _ai(st: Stone, dt: float) -> void:
	st.think -= dt
	if st.think > 0.0:
		return
	st.think = 0.12
	var hw := _hw(st.d) - 1.2
	var want := clampf(st.xg, -hw, hw)
	var best := 1.0e9
	var look := 8.0 + st.v * 0.55
	for th in things:
		if th.flat:
			continue
		var dd := th.d - st.d
		if dd < 1.0 or dd > look:
			continue
		var dx := th.x - st.x
		var sz: Vector3 = th.kd.size
		if st.sg < float(th.kd.need):
			if absf(dx) < (st.s + sz.x) * 0.6 + 0.6:
				var sg := -1.0 if dx > 0.0 else 1.0
				if absf(th.x + sg * 3.5) > hw:
					sg = -sg
				want = th.x + sg * 3.5
				best = -1.0
				break
		elif dd < best and absf(dx) < 5.0 and randf() < st.greed:
			best = dd
			want = th.x
	st.xg = clampf(want, -hw, hw)


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var ld := _leader()
	var fd := me.d
	if ld:
		fd = ld.d
	if ld == me:
		fd -= LEAD_SHIFT * clampf(lead_t / 1.5, 0.0, 1.0)
	focus = lerpf(focus, fd, 1.0 - exp(-6.0 * dt))
	var gy := _h(clampf(focus, K[0][0], K[K.size() - 1][0]))
	cam_y = lerpf(cam_y, gy, 1.0 - exp(-5.0 * dt))
	var cx := me.x * 0.35
	cam.position = cam.position.lerp(Vector3(cx, cam_y + 38.0, -(focus - 10.0)), 1.0 - exp(-8.0 * dt))
	cam.look_at(Vector3(cx, cam_y, -(focus + 4.0)))
	cam.fov = lerpf(cam.fov, clampf(38.0 + me.v * 0.1, 38.0, 46.0), minf(1.0, dt * 2.5))
	var sy := _h(clampf(slide_d, K[0][0], K[K.size() - 1][0]))
	slide_n.position = Vector3(0, sy + 4.0 + sin(clock * 9.0) * 0.3, -slide_d + 4.0)
	slide_n.rotation.z = sin(clock * 5.0) * 0.02


func _place(st: Stone, dt: float) -> void:
	if not st.alive:
		return
	st.ang += st.v * dt * PI / (2.0 * st.s)
	var m := fposmod(st.ang, PI * 0.5)
	st.n.position = Vector3(st.x, st.y + st.s * 0.5 * (cos(m) + sin(m)), -st.d)
	st.n.rotation.x = -st.ang
	st.n.material_override = mat(BAD if st.hurt > 0.0 and fmod(st.hurt, 0.2) < 0.1 else st.col)
	var q := floori(st.ang / (PI * 0.5))
	st.roll_t -= dt
	if q != st.quarter:
		st.quarter = q
		if st == me and st.roll_t <= 0.0 and st.on:
			st.roll_t = 0.07
			beep(clampf(60.0 + st.v * 2.0 - st.s * 4.0, 50.0, 200.0), 0.05, 45.0, 0.12)


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	last_x = p.x


func _drag(p: Vector2) -> void:
	if phase == "race" and me.alive and not me.done:
		var hw := _hw(me.d) + 0.6
		me.xg = clampf(me.xg + (p.x - last_x) * 0.05, -hw, hw)
	last_x = p.x


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)
