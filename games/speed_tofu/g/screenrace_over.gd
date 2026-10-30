extends Tofu
## 너무 센 몸으로 화면 밖 경주 (옆모습 4인 경주): 왼쪽 아래 조이스틱 좌우, 점프(늘 천장에 쾅), 대시(벽에 꽝). 카메라는 1등을 따라가고 화면 왼쪽 밖으로 밀리면 탈락.
## 상대들은 평범하게 뛴다. 내 점프·대시는 과하게 세서 낮은 천장에 박고 벽에 꽝 부딪혀 멈추는 사이 화면이 밀어낸다. 열린 천장에서는 그 힘이 그대로 속도가 된다.
## 보라 무게추를 주우면 잠깐 힘이 평범해진다(뛰어넘으면 안 줍는다). 트랙 3개(창고 → 하수도 → 공장): 내가 먼저 결승에 닿으면 다음 트랙, 상대가 먼저거나 내가 밀리면 끝.

const GRAV := 40.0
const JUMP_ME := 24.0  # 꼭대기 7칸: 낮은 천장(4칸)에는 반드시 박는다
const JUMP_N := 13.0  # 평범한 점프 (상대, 무게추)
const RUN_ME := 12.5
const RUN_N := 10.8
const GROUND_ACC := 60.0
const AIR_ACC := 25.0
const FRICTION := 40.0
const MAX_FALL := 28.0
const DASH_ME := 40.0
const DASH_N := 17.0
const DASH_T := 0.22
const DASH_CD := 0.6
const SLAM := 20.0  # 이보다 빠르게 벽에 박으면 꽝 (어질, 튕김)
const BONK_CAP := 30.0
const HW := 0.4
const HH := 1.2
const STEP := 0.55
const COYOTE := 0.1
const JBUF := 0.12
const CAM_D := 22.0
const WIDE := 12.0
const NARROW := 7.0
const WEIGHT_T := 6.0
const CEIL_LO := 4.2
const CEIL_HI := 11.0
const WEIGHTC := Color("cc5de8")
const PINK := Color("f783ac")
const TRACKS := [
	{"name": "창고", "gnd": Color("ffd8a8"), "top": Color("ff922b"), "ceil": Color("e8590c"),
		"bld": [Color("ffc9c9"), Color("ffec99"), Color("d3f9d8")], "len": 260.0,
		"segs": ["hall", "open", "pit", "wall", "weight", "hall", "step", "openwall", "open"]},
	{"name": "하수도", "gnd": Color("a5d8ff"), "top": Color("4dabf7"), "ceil": Color("748ffc"),
		"bld": [Color("d0ebff"), Color("e5dbff"), Color("c5f6fa")], "len": 300.0,
		"segs": ["hall", "pitlow", "wall", "weight", "step", "pitlow", "hall", "wall", "open"]},
	{"name": "공장", "gnd": Color("e5dbff"), "top": Color("cc5de8"), "ceil": Color("9775fa"),
		"bld": [Color("f3d9fa"), Color("dbe4ff"), Color("ffdeeb")], "len": 340.0,
		"segs": ["open", "pitlow", "openwall", "wall", "weight", "step", "pitlow", "hall", "openwall", "pit"]},
]


class Runner:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var grounded := false
	var alive := true
	var ai := true
	var nick := ""
	var col := Color.WHITE
	var node: Node3D
	var body: MeshInstance3D
	var pack: MeshInstance3D
	var poof: MeshInstance3D
	var stars: Array[MeshInstance3D] = []
	var streaks: Array[MeshInstance3D] = []
	var stun := 0.0
	var hang := 0.0
	var dash := 0.0
	var dash_cd := 0.0
	var weight_t := 0.0
	var coyote := 0.0
	var jbuf := 0.0
	var cut := true
	var face := 1.0
	var skill := 1.0
	var err := 0.2
	var think := 0.0
	var poof_t := 0.0
	var squash := 0.0
	# 이번 프레임 입력
	var mx := 0.0
	var i_jump := false
	var i_jheld := false
	var i_dash := false


var ti := 0  # 트랙
var phase := "count"
var pt := 0.0
var rt := 0.0
var tdef: Dictionary
var stage: Node3D
var rects: Array[Rect2] = []
var weights: Array = []
var goal_x := 0.0
var kill_y := -20.0
var gx := 0.0
var fy := 0.0
var min_fy := 0.0
var gen := RandomNumberGenerator.new()
var game_seed := 0
var runners: Array[Runner] = []
var pl: Runner
var camx := 0.0
var camy := 0.0
var hwv := WIDE
var vhv := WIDE
var shk := 0.0
var edge_strip: MeshInstance3D
var marker: MeshInstance3D
var danger := false
var tick := 0.0
var lead_t := 0.0
var bonks := 0


func _setup() -> void:
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	howto = "4인 경주. 카메라는 1등만 따라간다. 화면 왼쪽 밖으로 밀리거나 구덩이에 빠지면 탈락.\n내 몸은 너무 세다. 점프는 낮은 천장에 쾅 박혀 어질하고, 대시는 벽에 꽝 부딪혀 멈춘다. 그 사이 화면이 밀어낸다. 열린 곳에서는 그 힘이 그대로 속도다.\n보라 무게추를 밟으면 6초간 힘이 평범해진다. 싫으면 뛰어넘는다.\n조이스틱 좌우, 점프, 대시. 내가 먼저 결승에 닿으면 다음 트랙. 트랙 3개."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1120), 100.0, A)
	kit_button("dash", "대시", Vector2(600, 890), 82.0, C)


func _reset() -> void:
	ti = 0
	stage = null
	bonks = 0
	game_seed = randi()
	runners.clear()
	var cols := [ME, A, B, PINK]
	var nicks := ["나", "주황", "하늘", "분홍"]
	for i in 4:
		var r := Runner.new()
		r.ai = i > 0
		r.col = cols[i]
		r.nick = nicks[i]
		_make_body(r)
		runners.append(r)
	pl = runners[0]
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	marker = box(Vector3.ZERO, Vector3(0.36, 0.36, 0.36), ME)
	marker.rotation.z = PI * 0.25
	_build_track()
	_start_race()


func _make_body(r: Runner) -> void:
	r.node = Node3D.new()
	world.add_child(r.node)
	r.body = box(Vector3(0, 0, 0), Vector3(HW * 2.0, HH * 0.75, 0.8), r.col, r.node)
	box(Vector3(0, 0.63, 0), Vector3(0.42, 0.36, 0.5), SOFT, r.node)
	box(Vector3(0.05, 0.88, 0), Vector3(0.6, 0.14, 0.6), WHITE if not r.ai else r.col.darkened(0.2), r.node)
	r.pack = box(Vector3(-0.5, 0.1, 0), Vector3(0.5, 0.5, 0.5), WEIGHTC, r.node)
	r.pack.visible = false
	r.poof = box(Vector3.ZERO, Vector3(1, 1, 1), WHITE)
	r.poof.visible = false
	for k in 2:
		var s := box(Vector3.ZERO, Vector3(0.2, 0.2, 0.2), D, r.node)
		s.visible = false
		r.stars.append(s)
	for k in 3:
		var s := box(Vector3.ZERO, Vector3(1, 0.07, 0.07), WHITE)
		s.visible = false
		r.streaks.append(s)


# ---- 트랙 만들기 ----
func _build_track() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	tdef = TRACKS[ti]
	rects.clear()
	weights.clear()
	gen.seed = game_seed + ti * 7919
	fy = 0.0
	min_fy = 0.0
	gx = -40.0
	_floor(gx, 44.0, CEIL_HI)
	gx = 4.0
	var goal: float = tdef.len
	var segs: Array = tdef.segs
	var last := ""
	while gx < goal:
		var s: String = segs[gen.randi() % segs.size()]
		if s == last:
			s = "hall"
		last = s
		_seg(s)
	goal_x = gx + 2.0
	_floor(gx, 60.0, CEIL_HI)
	for z in [-1.4, 1.4]:
		box(Vector3(goal_x, fy + 2.6, z), Vector3(0.3, 5.2, 0.3), GOOD, stage)
	for k in 6:
		box(Vector3(goal_x, fy + 5.2, -1.25 + k * 0.5), Vector3(0.32, 0.4, 0.5), WHITE if k % 2 == 0 else INK, stage)
	kill_y = min_fy - 6.0
	# 뒤 기둥 (원근 때문에 느리게 지나간다)
	var bx := -40.0
	var bld: Array = tdef.bld
	while bx < gx + 60.0:
		var w := gen.randf_range(2.0, 5.0)
		var h := gen.randf_range(6.0, 18.0)
		var c: Color = bld[gen.randi() % bld.size()]
		box(Vector3(bx + w * 0.5, h * 0.5 - 10.0, -9.0 - gen.randf() * 3.0), Vector3(w, h, 3.0), c, stage)
		bx += w + gen.randf_range(1.0, 3.0)
	# 앞 가로등 (빨리 지나가서 속도가 보인다)
	var px := 0.0
	while px < goal_x:
		var y := _floor_top(px, 60.0)
		if y > -100.0:
			box(Vector3(px, y + 1.5, 3.2), Vector3(0.22, 3.0, 0.22), WHITE, stage)
			box(Vector3(px + 0.35, y + 3.0, 3.2), Vector3(0.9, 0.22, 0.3), tdef.top, stage)
		px += 9.0


func _seg(s: String) -> void:
	var wallc: Color = tdef.ceil
	match s:
		"hall":
			var w := gen.randf_range(8.0, 12.0)
			_floor(gx, w, CEIL_LO)
			gx += w
		"open":
			var w := gen.randf_range(8.0, 12.0)
			_floor(gx, w, CEIL_HI)
			gx += w
		"pit", "pitlow":
			var ch := CEIL_HI if s == "pit" else CEIL_LO
			_floor(gx, 3.0, ch)
			gx += 3.0
			var g := gen.randf_range(3.0, 4.5)
			_ceil(gx, g, ch)
			gx += g
			_floor(gx, 4.0, ch)
			gx += 4.0
		"wall":
			_floor(gx, 9.0, CEIL_LO)
			_solid(Rect2(gx + 4.5, fy, 0.9, gen.randf_range(1.3, 2.0)), wallc)
			gx += 9.0
		"openwall":
			_floor(gx, 13.0, CEIL_HI)
			_solid(Rect2(gx + 4.0, fy, 0.9, 1.8), wallc)
			_solid(Rect2(gx + 9.0, fy, 0.9, 1.5), wallc)
			gx += 13.0
		"weight":
			_floor(gx, 8.0, CEIL_LO)
			_weight(gx + 4.0, fy + 0.35)
			gx += 8.0
		"step":
			var up := fy < -1.0 or (fy < 3.0 and gen.randf() < 0.5)
			for k in 4:
				_floor(gx, 1.3, CEIL_LO)
				gx += 1.3
				fy += 0.5 if up else -0.5
			_floor(gx, 3.0, CEIL_LO)
			gx += 3.0
	min_fy = minf(min_fy, fy)


func _floor(x: float, w: float, ch: float) -> void:
	_solid(Rect2(x, fy - 14.0, w, 14.0), tdef.gnd)
	box(Vector3(x + w * 0.5, fy - 0.1, 0), Vector3(w, 0.2, 2.5), tdef.top, stage)
	_ceil(x, w, ch)


func _ceil(x: float, w: float, ch: float) -> void:
	_solid(Rect2(x, fy + ch, w, 3.0), tdef.ceil)


func _solid(rc: Rect2, c: Color) -> void:
	rects.append(rc)
	var m := rc.get_center()
	box(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, 2.4), c, stage)


func _weight(x: float, y: float) -> void:
	var n := box(Vector3(x, y, 0), Vector3(0.9, 0.7, 0.9), WEIGHTC, stage)
	box(Vector3(0, 0.6, 0), Vector3(0.5, 0.25, 0.3), INK, n)
	weights.append({"p": Vector2(x, y), "node": n, "on": true})


# ---- 경주 ----
func _start_race() -> void:
	var xs := [-2.2, -1.0, -3.4, -4.6]
	for i in 4:
		var r := runners[i]
		r.p = Vector2(xs[i], 0.0)
		r.v = Vector2.ZERO
		r.alive = true
		r.stun = 0.0
		r.hang = 0.0
		r.dash = 0.0
		r.dash_cd = 0.0
		r.weight_t = 0.0
		r.cut = true
		r.face = 1.0
		r.poof_t = 0.0
		r.squash = 0.0
		r.node.visible = true
		r.node.rotation = Vector3.ZERO
		r.poof.visible = false
		if r.ai:
			r.skill = 0.95 + 0.03 * ti + (i - 2) * 0.02
			r.err = 0.2 - 0.05 * ti
		_probe(r)
	for w in weights:
		w.on = true
		(w.node as Node3D).visible = true
	rt = 0.0
	lead_t = 0.0
	hwv = WIDE
	camx = 0.0
	camy = 2.0
	phase = "count"
	pt = 1.4
	danger = false
	msg("%s" % tdef.name, 1.2)
	beep(440.0, 0.12)


func _step(dt: float) -> void:
	shk = maxf(shk - dt * 2.5, 0.0)
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.7 and pt <= 0.7:
				beep(440.0, 0.12)
			if pt <= 0.0:
				phase = "race"
				msg("달려!", 0.6)
				play("good")
		"race":
			rt += dt
			_race(dt)
		"done":
			pt -= dt
			_tick_runners(dt, false)
			if pt <= 0.0:
				_next_track()
	_camera(dt)
	_draw_all(dt)


func _race(dt: float) -> void:
	pl.mx = kit_move.x
	pl.i_jump = kit_just("jump")
	pl.i_jheld = kit_held("jump")
	pl.i_dash = kit_just("dash")
	for r in runners:
		if r.alive and r.ai:
			_ai(r, dt)
	_tick_runners(dt, true)
	_pickups()
	# 탈락
	var left := camx - hwv
	for r in runners:
		if not r.alive:
			continue
		if r.p.x + HW < left or r.p.y < kill_y or r.p.y < camy - vhv - 1.0:
			_out(r)
	if not pl.alive:
		msg("밀려났다", 1.6)
		end()
		return
	for r in runners:
		if r.alive and r.p.x > goal_x:
			_race_over(r)
			return
	var n := 0
	for r in runners:
		if r.alive:
			n += 1
	if n <= 1:
		_race_over(pl)
		return
	if _leader() == pl:
		if lead_t == 0.0:
			msg("선두!", 0.6)
			beep(900.0, 0.1, 1400.0, 0.2)
		lead_t += dt
	else:
		lead_t = 0.0
	# 화면 끝 압박
	var ed := pl.p.x - left
	gauge(ed / (hwv * 2.0), GOOD if ed > hwv * 0.6 else (A if ed > 2.5 else BAD))
	if ed < 1.6:
		danger = true
	elif danger and ed > 4.0:
		danger = false
		beep(1000.0, 0.1, 1600.0, 0.22)
		msg("아슬!", 0.5)
	tick -= dt
	if ed < 3.5 and tick <= 0.0:
		tick = 0.08 + ed * 0.07
		beep(1200.0 - ed * 150.0, 0.04, 0.0, 0.14)


func _tick_runners(dt: float, live: bool) -> void:
	for r in runners:
		if r.alive:
			if live:
				_runner(r, dt)
		elif r.poof_t > 0.0:
			r.poof_t -= dt


func _out(r: Runner) -> void:
	r.alive = false
	r.node.visible = false
	r.poof.visible = true
	r.poof_t = 0.5
	r.poof.position = Vector3(clampf(r.p.x, camx - hwv + 0.6, camx + hwv), maxf(r.p.y, camy - vhv + 2.0), 0.5)
	if r == pl:
		play("bad")
		shk = 0.6
	else:
		score += 5
		beep(300.0, 0.2, 120.0, 0.25)
		shk = maxf(shk, 0.25)
		msg("%s 탈락" % r.nick, 0.6)


func _race_over(w: Runner) -> void:
	phase = "done"
	pt = 1.6
	if w == pl:
		score += 50
		play("win")
		msg("1등!", 1.6)
	else:
		beep(330.0, 0.3, 200.0, 0.25)
		msg("%s 먼저 도착" % w.nick, 1.6)


func _next_track() -> void:
	var w := _leader()
	if w != pl and pl.p.x <= goal_x:
		end()
		return
	ti += 1
	if ti >= TRACKS.size():
		msg("완주!", 3.0)
		end()
		return
	play("good")
	_build_track()
	_start_race()


# ---- 달리기 한 명 ----
func _runner(r: Runner, dt: float) -> void:
	r.squash = maxf(r.squash - dt * 4.0, 0.0)
	r.dash_cd = maxf(r.dash_cd - dt, 0.0)
	var heavy := r.weight_t > 0.0
	if heavy:
		r.weight_t -= dt
		if r.weight_t <= 0.0 and r == pl:
			msg("무게추 떨어짐", 0.8)
			beep(500.0, 0.12, 900.0, 0.2)
	var normal := r.ai or heavy
	var top := RUN_N * r.skill if r.ai else (RUN_N if heavy else RUN_ME)
	var mx := r.mx
	if r.stun > 0.0:
		r.stun -= dt
		mx = 0.0
		r.i_jump = false
		r.i_dash = false
	r.coyote = COYOTE if r.grounded else maxf(r.coyote - dt, 0.0)
	r.jbuf = JBUF if r.i_jump else maxf(r.jbuf - dt, 0.0)
	if r.jbuf > 0.0 and r.coyote > 0.0 and r.hang <= 0.0:
		r.v.y = JUMP_N if normal else JUMP_ME
		r.coyote = 0.0
		r.jbuf = 0.0
		r.grounded = false
		r.cut = false
		r.dash = 0.0
		_snd(r, 420.0 if normal else 300.0, 0.1, 1000.0 if normal else 1300.0, 0.24)
	if not r.cut and r.v.y > 0.0 and not r.i_jheld:
		r.v.y *= 0.7 if normal else 0.93
		r.cut = true
	if r.i_dash and r.dash_cd <= 0.0 and r.hang <= 0.0:
		r.dash = DASH_T
		r.dash_cd = DASH_CD
		r.v.x = (DASH_N if normal else DASH_ME) * (r.face if r.face != 0.0 else 1.0)
		_snd(r, 260.0, 0.16, 1500.0, 0.3)
		if r == pl and not normal:
			shk = maxf(shk, 0.12)
	if r.hang > 0.0:
		r.hang -= dt
		r.v.y = 0.0
	elif r.dash > 0.0:
		r.dash -= dt
		r.v.y = 0.0
		if r.dash <= 0.0:
			r.v.x = signf(r.v.x) * top
	else:
		var acc := GROUND_ACC if r.grounded else AIR_ACC
		if absf(mx) > 0.15:
			var want := signf(mx) * top
			if signf(r.v.x) != signf(mx) or absf(r.v.x) < top:
				r.v.x = move_toward(r.v.x, want, acc * dt)
			else:
				r.v.x = move_toward(r.v.x, want, (8.0 if r.grounded else 1.5) * dt)
			r.face = signf(mx)
		else:
			r.v.x = move_toward(r.v.x, 0.0, (FRICTION if r.grounded else 4.0) * dt)
		r.v.y = maxf(r.v.y - GRAV * dt, -MAX_FALL)
	for s in 2:
		_mx(r, r.v.x * dt * 0.5)
		_my(r, r.v.y * dt * 0.5)
	var was := r.grounded
	_probe(r)
	if r.grounded and not was:
		r.squash = maxf(r.squash, 0.35)
		_snd(r, 90.0, 0.06, 0.0, 0.18)


func _box(r: Runner) -> Rect2:
	return Rect2(r.p.x - HW, r.p.y, HW * 2.0, HH)


func _mx(r: Runner, dx: float) -> void:
	if dx == 0.0:
		return
	r.p.x += dx
	var a := _box(r)
	for q in rects:
		if q.end.x < a.position.x - 1.0 or q.position.x > a.end.x + 1.0:
			continue
		if not q.intersects(a):
			continue
		if r.grounded and q.end.y - r.p.y <= STEP and q.end.y > r.p.y:
			r.p.y = q.end.y
			a = _box(r)
			continue
		_bump_x(r, q, dx)
		a = _box(r)


## 벽에 옆으로 박기: 내가 빠르면 꽝 (어질, 튕김). 평범한 몸은 그냥 멈춘다
func _bump_x(r: Runner, q: Rect2, dx: float) -> void:
	var sp := absf(r.v.x)
	if dx > 0.0:
		r.p.x = q.position.x - HW - 0.001
	else:
		r.p.x = q.end.x + HW + 0.001
	r.dash = 0.0
	if sp > SLAM and not (r.ai or r.weight_t > 0.0):
		r.stun = 0.4
		r.squash = 0.6
		r.v.x = -signf(dx) * sp * 0.25
		if r == pl:
			shk = maxf(shk, 0.3 + sp / 120.0)
			msg("꽝!", 0.35)
		_snd(r, 110.0, 0.2, 45.0, 0.45)
		_snd(r, 800.0, 0.04, 0.0, 0.2)
	else:
		if sp > 8.0:
			_snd(r, 160.0, 0.08, 80.0, 0.2)
		r.v.x = 0.0


func _my(r: Runner, dy: float) -> void:
	if dy == 0.0:
		return
	r.p.y += dy
	var a := _box(r)
	for q in rects:
		if q.end.x < a.position.x - 1.0 or q.position.x > a.end.x + 1.0:
			continue
		if q.intersects(a):
			_bump_y(r, q, dy)
			a = _box(r)


func _bump_y(r: Runner, q: Rect2, dy: float) -> void:
	if dy < 0.0:
		r.p.y = q.end.y
		r.v.y = 0.0
	else:
		r.p.y = q.position.y - HH - 0.001
		_bonk(r)


## 천장에 박기: 내가 빠르면 어질, 잠깐 붙었다가 떨어진다. 달리던 중이면 옆으로 더 빨라진다
func _bonk(r: Runner) -> void:
	var sp := r.v.y
	r.v.y = 0.0
	if sp < 3.0 or r.ai or r.weight_t > 0.0:
		return
	bonks += 1
	r.hang = 0.1
	r.stun = 0.25
	r.dash = 0.0
	r.squash = 0.7
	if absf(r.v.x) > 6.0:
		r.v.x = signf(r.v.x) * minf(absf(r.v.x) * 1.3 + 3.0, BONK_CAP)
	if r == pl:
		shk = maxf(shk, 0.3)
		msg("쾅!", 0.35)
	_snd(r, 200.0, 0.14, 60.0, 0.45)
	_snd(r, 1300.0, 0.05, 700.0, 0.2)


func _probe(r: Runner) -> void:
	var f := Rect2(r.p.x - HW + 0.05, r.p.y - 0.06, HW * 2.0 - 0.1, 0.07)
	r.grounded = false
	for q in rects:
		if q.end.x < f.position.x or q.position.x > f.end.x:
			continue
		if q.intersects(f) and q.end.y <= r.p.y + 0.02:
			r.grounded = true
			return


## x 위에서 높이 ymax 아래 가장 높은 바닥 윗면 (없으면 아주 낮은 수)
func _floor_top(x: float, ymax: float) -> float:
	var best_y := -1.0e9
	for q in rects:
		if x > q.position.x and x < q.end.x and q.end.y <= ymax:
			best_y = maxf(best_y, q.end.y)
	return best_y


func _solid_in(a: Rect2) -> bool:
	for q in rects:
		if q.intersects(a):
			return true
	return false


func _snd(r: Runner, f: float, d: float, to := 0.0, vol := 0.18) -> void:
	if r == pl:
		beep(f, d, to, vol)
	elif r.alive and absf(r.p.x - camx) < hwv:
		beep(f, d, to, vol * 0.45)


func _pickups() -> void:
	if pl.weight_t > 0.0:
		return
	for w in weights:
		if not w.on:
			continue
		var wp: Vector2 = w.p
		if absf(pl.p.x - wp.x) < 0.8 and wp.y - pl.p.y > -0.6 and wp.y - pl.p.y < HH:
			w.on = false
			(w.node as Node3D).visible = false
			pl.weight_t = WEIGHT_T
			pl.dash = 0.0
			msg("무게추: 힘이 평범", 1.0)
			beep(700.0, 0.12, 400.0, 0.22)
			shk = maxf(shk, 0.1)
			break


func _leader() -> Runner:
	var w: Runner = null
	for r in runners:
		if r.alive and (w == null or r.p.x > w.p.x):
			w = r
	return w


# ---- 경쟁자 ----
func _ai(r: Runner, dt: float) -> void:
	r.mx = 1.0
	r.i_jump = false
	r.i_dash = false
	r.i_jheld = true
	r.think -= dt
	if r.think > 0.0:
		return
	r.think = randf_range(0.04, 0.1) / r.skill
	var look := 0.8 + absf(r.v.x) * 0.12
	var ax := r.p.x + HW + 0.25 + absf(r.v.x) * 0.035
	var pit := _floor_top(ax, r.p.y + 0.6) < r.p.y - 2.0
	var wall := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, look, 1.5))
	if r.grounded and (pit or wall) and randf() > r.err:
		r.i_jump = true
	elif r.grounded and not wall and not pit and randf() < 0.04:
		var far := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, 6.0, 1.5))
		if not far:
			r.i_dash = true


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	var asp := vs.y / maxf(vs.x, 1.0)
	if phase == "race":
		hwv = lerpf(WIDE, NARROW, clampf((rt - 8.0) / 25.0, 0.0, 1.0))
	vhv = hwv * asp
	var lead := _leader()
	if lead:
		var k := 1.0 - exp(-9.0 * dt)
		# 내가 1등이면 화면이 앞으로 쏠려 나는 오른쪽에 붙는다 (앞이 덜 보인다)
		var off := 0.16
		if lead == pl:
			off = lerpf(0.16, 0.55, clampf(lead_t / 1.5, 0.0, 1.0))
		camx = lerpf(camx, lead.p.x - hwv * off, k)
		camy = lerpf(camy, lead.p.y + 2.5, 1.0 - exp(-4.0 * dt))
	cam.fov = rad_to_deg(2.0 * atan(hwv / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


func _draw_all(dt: float) -> void:
	var tm := Time.get_ticks_msec() * 0.001
	for r in runners:
		r.poof.visible = r.poof_t > 0.0
		if r.poof.visible:
			var s := 1.0 + (0.5 - r.poof_t) * 6.0
			r.poof.scale = Vector3(s, s, s)
		if not r.alive:
			for s2 in r.streaks:
				s2.visible = false
			continue
		var spd := absf(r.v.x)
		var bob := sin(tm * (8.0 + spd)) * 0.06 if r.grounded and spd > 1.0 else 0.0
		r.node.position = Vector3(r.p.x, r.p.y + HH * 0.375 + bob, 0)
		var stretch := clampf(spd / 50.0, 0.0, 0.8)
		r.node.scale = Vector3(1.0 + stretch * 0.5 + r.squash * 0.4, 1.0 - r.squash * 0.45 - stretch * 0.2, 1.0)
		r.node.rotation.z = (tm * 14.0 if r.stun > 0.0 else -clampf(r.v.x * 0.012, -0.25, 0.25))
		r.pack.visible = r.weight_t > 0.0
		r.pack.position.x = -0.5 * r.face
		for k in 2:
			var st := r.stars[k]
			st.visible = r.stun > 0.0
			var a := tm * 14.0 + k * PI
			st.position = Vector3(cos(a) * 0.45, 1.2, sin(a) * 0.45)
		var ln := clampf((spd - 12.0) * 0.4, 0.0, 4.0)
		for k in 3:
			var s3 := r.streaks[k]
			s3.visible = ln > 0.1
			if s3.visible:
				s3.scale = Vector3(ln * (1.0 - k * 0.2), 0.07, 0.07)
				s3.position = Vector3(r.p.x - r.face * (HW + 0.3 + ln * 0.5 + k * 0.2), r.p.y + 0.25 + k * 0.35, 0.5)
	for w in weights:
		(w.node as Node3D).rotation.y += dt * 1.5
	marker.visible = pl.alive
	marker.position = Vector3(pl.p.x, pl.p.y + HH + 1.1 + sin(tm * 5.0) * 0.12, 0)
	# 왼쪽 화면 끝 경고 띠
	var ed := pl.p.x - (camx - hwv)
	var k2 := (CAM_D - 1.6) / CAM_D
	edge_strip.visible = phase == "race" and pl.alive and ed < 4.0 and (ed > 2.0 or fmod(tm, 0.16) < 0.1)
	edge_strip.position = Vector3(camx - hwv * k2 + 0.18, camy, 1.6)
	edge_strip.scale = Vector3(0.35 + maxf(0.0, 4.0 - ed) * 0.1, vhv * 2.0, 0.2)
