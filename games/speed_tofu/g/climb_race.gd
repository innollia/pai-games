extends Tofu
## 탑 오르기 경주 (세로 4인 화면 밖 경주): 왼쪽·오른쪽 버튼을 누르면 그쪽으로 뛰고(벽에선 반대쪽을 눌러 벽 차기), 누르고 있으면 그쪽으로 몸을 민다. 카메라는 1등을 따라 위로만 가고 화면 아래로 빠지면 탈락.
## 한 문장: 나는 우물·비계·무너지는 탑을 같이 오르는 등반가 넷 중 하나로서 1등을 따라 올라가는 화면 안에서 벽을 차고 남의 머리와 떨어지는 돌을 밟고 올라 꼭대기에 먼저 닿지만, 빨리 오를수록 위가 덜 보이고 밑의 사람에게는 내가 떨어뜨리는 돌이 되는 대가를 감수한다.
## 몸의 물리: 벽에 닿는 순간의 옆 속도(박는 힘)가 벽 차기 높이가 된다. 벽에 붙어 있을수록 힘이 빠진다. 오르던 속도 30%는 다음 차기로 넘어간다.
## 밟기: 사람·빨간 돌 위에 내려앉으면 크게 튀고, 밟힌 사람은 아래로 꽂힌다. 빨간 것 = 떨어지는 것(위에서 받으면 맞는다).
## 판 3번(2승이면 우승): 1 우물(벽 차기 리듬) → 2 비계(벽돌이 우물 안에도 떨어짐) → 3 무너지는 탑(밟은 발판이 무너져 돌이 되고 바닥이 쫓아옴).
## 부모 screenrace 의 1등 카메라·가장자리 탈락을 물려받고, 경주 방향을 위로 바꿨다(아래 가장자리 = 탈락). 넷 다 같은 몸.

# ---- 몸 ----
const GRAV := 30.0
const JUMP := 13.5
const JUMP_VX := 4.0
const RUN := 6.0
const GROUND_ACC := 50.0
const AIR_MAX := 10.0
const AIR_ACC := 24.0
const AIR_DRAG := 3.0  # 손을 떼면 옆 속도가 빠진다
const SLIDE := 4.5
const KICK_BASE := 9.0
const KICK_K := 0.75  # 박는 힘 → 위 속도
const KICK_CAP := 22.0
const KICK_VX := 5.5
const CARRY := 0.3
const IMP_DECAY := 5.0  # 벽에 붙어 있으면 힘이 빠지는 빠르기
const JBUF := 0.12
const STOMP_UP := 15.0
const STOMP_DOWN := 12.0
const MAX_FALL := 26.0
const HW := 0.35
const HH := 1.1
# ---- 떨어지는 것 ----
const F_GRAV := 14.0
const F_MAX := 7.0
const CRUMBLE_T := 0.45
const REGROW_T := 2.6
# ---- 화면 ----
const VW := 13.0
const VHH := 11.5556  # 13 * 1280 / 720 / 2
const CAM_MAX := 11.0
const PINK := Color("f783ac")
const ROUNDS := [
	{"name": "우물", "sky": Color("fff4e6"), "wall": Color("ffd8a8"), "band": Color("f08c00"), "plat": Color("e8b06a"),
		"bricks": 0.0, "crumble": false, "rise": 0.0,
		"segs": [["well", 0.0, 4.2, 16.0], ["room", -2.5, 8.0], ["well", -2.5, 3.4, 14.0], ["room", 2.4, 7.0],
			["well", 2.4, 4.8, 16.0], ["room", 0.0, 7.0], ["well", 0.0, 3.6, 14.0]]},
	{"name": "비계", "sky": Color("e7f5ff"), "wall": Color("a5d8ff"), "band": Color("1c7ed6"), "plat": Color("ffc078"),
		"bricks": 1.15, "crumble": false, "rise": 0.0,
		"segs": [["room", 0.0, 12.0], ["well", 0.0, 4.4, 10.0], ["room", -2.0, 11.0], ["well", -2.0, 4.0, 12.0],
			["room", 1.5, 10.0], ["well", 1.5, 4.2, 10.0]]},
	{"name": "무너지는 탑", "sky": Color("fff0f6"), "wall": Color("eebefa"), "band": Color("ae3ec9"), "plat": Color("ffe8cc"),
		"bricks": 2.4, "crumble": true, "rise": 2.3,
		"segs": [["room", 1.5, 11.0], ["well", 1.5, 4.0, 10.0], ["room", -1.5, 12.0], ["well", -1.5, 3.8, 10.0],
			["room", 0.0, 12.0], ["well", 0.0, 4.4, 9.0]]},
]


class Climber:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var prev_y := 0.0
	var grounded := false
	var alive := true
	var me := false
	var nick := ""
	var col := Color.WHITE
	var node: Node3D
	var vis: Node3D
	var poof: MeshInstance3D
	var poof_t := 0.0
	var wall := 0  # 붙은 벽 쪽 (-1 왼쪽, 1 오른쪽)
	var wall_t := 0.0
	var imp := 0.0  # 박는 힘
	var lock := 0.0
	var stun := 0.0
	var hit_cd := 0.0
	var hold := 0
	var jbuf := 0.0
	var jdir := 0
	var plat := -1
	var sq := 0.0
	var best_y := 0.0
	# AI
	var delay := 0.1
	var base_delay := 0.1
	var think := 0.0
	var ai_dir := 0
	var stuck := 0.0
	var dodge := 0.5


var ri := 0
var wins := 0
var meters := 0.0
var phase := "count"
var pt := 0.0
var rt := 0.0
var rdef: Dictionary
var stage: Node3D
var solids: Array[Rect2] = []
var plats: Array = []  # {r, node, t, dead, regrow, x}
var wells: Array = []  # {y0, y1, cx, w}
var goal_y := 0.0
var gy := 0.0
var prev_cx := 0.0
var gen := RandomNumberGenerator.new()
var climbers: Array[Climber] = []
var me_c: Climber
var falls: Array = []  # {n, p, vy, w, h, on, prev_top}
var warns: Array = []  # {n, x, t}
var brick_t := 0.0
var puffs: Array = []
var puff_i := 0
var streaks: Array = []
var bgs: Array = []
var cam_y := 0.0
var shk := 0.0
var edge_band: MeshInstance3D
var rubble: Array = []
var marker: MeshInstance3D
var tick := 0.0
var kicks := 0
var strong_said := false
var last_dir := 1
var tap_dir := 0
var tap_down := false
var tap_press := false
var sky_env: Environment


func _setup() -> void:
	time_limit = 0.0
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = VW
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	howto = "넷이 같이 탑을 오른다. 화면은 1등을 따라 위로만 가고, 화면 아래로 빠지면 탈락.\n왼쪽·오른쪽 버튼: 누르면 그쪽으로 뛴다. 벽에 붙으면 반대쪽을 눌러 벽 차기 — 세게 박고 바로 찰수록 높이 튄다. 누르고 있으면 그쪽으로 몸을 민다.\n사람·빨간 돌 위에 내려앉으면 밟고 튄다. 빨간 돌을 머리로 받으면 떨어진다.\n3판 중 2번 꼭대기에 먼저 닿으면 우승."
	kit_button("L", "왼쪽", Vector2(150, 1110), 130.0, ME)
	kit_button("R", "오른쪽", Vector2(570, 1110), 130.0, ME)
	for c in get_children():
		if c is WorldEnvironment:
			sky_env = (c as WorldEnvironment).environment


func _reset() -> void:
	ri = 0
	wins = 0
	meters = 0.0
	stage = null
	climbers.clear()
	var cols := [ME, A, PINK, C]
	var nicks := ["나", "주황", "분홍", "보라"]
	for i in 4:
		var c := Climber.new()
		c.col = cols[i]
		c.nick = nicks[i]
		c.me = i == 0
		_make_body(c)
		climbers.append(c)
	me_c = climbers[0]
	marker = box(Vector3.ZERO, Vector3(0.34, 0.34, 0.34), ME)
	marker.rotation.z = PI * 0.25
	_make_pools()
	_build_round()
	_start_round()


func _make_body(c: Climber) -> void:
	c.node = Node3D.new()
	world.add_child(c.node)
	c.vis = Node3D.new()
	c.node.add_child(c.vis)
	box(Vector3(0, 0.36, 0), Vector3(HW * 2.0, 0.72, 0.7), c.col, c.vis)
	box(Vector3(0, 0.9, 0), Vector3(0.5, 0.4, 0.55), SOFT, c.vis)
	box(Vector3(0, 1.08, 0), Vector3(0.56, 0.12, 0.6), c.col.darkened(0.25), c.vis)
	box(Vector3(0.12, 0.92, 0.3), Vector3(0.1, 0.1, 0.02), INK, c.vis)  # 눈
	box(Vector3(0, 0.1, 0), Vector3(HW * 2.1, 0.16, 0.74), INK.lightened(0.3), c.vis)  # 신발
	c.poof = box(Vector3.ZERO, Vector3.ONE, WHITE)
	c.poof.visible = false


func _make_pools() -> void:
	falls.clear()
	warns.clear()
	puffs.clear()
	streaks.clear()
	bgs.clear()
	rubble.clear()
	for k in 14:
		var n := box(Vector3.ZERO, Vector3.ONE, BAD)
		n.visible = false
		box(Vector3(0, 0, 0.51), Vector3(0.7, 0.18, 0.02), WHITE, n)  # 흰 줄: 떨어지는 것 표시
		falls.append({"n": n, "p": Vector2.ZERO, "vy": 0.0, "w": 1.0, "h": 0.5, "on": false, "prev_top": 0.0})
	for k in 4:
		var n := box(Vector3.ZERO, Vector3(1.2, 0.35, 0.3), BAD)
		n.visible = false
		warns.append({"n": n, "x": 0.0, "t": 0.0})
	for k in 8:
		var n := box(Vector3.ZERO, Vector3(0.3, 0.3, 0.3), WHITE)
		n.visible = false
		puffs.append({"n": n, "life": 0.0, "s": 1.0})
	for k in 6:
		var n := box(Vector3.ZERO, Vector3(0.06, 2.0, 0.06), WHITE)
		n.visible = false
		streaks.append(n)
	for k in 10:
		var n := box(Vector3.ZERO, Vector3.ONE, WHITE)
		bgs.append({"n": n, "o": 0.0, "x": 0.0})
	edge_band = box(Vector3.ZERO, Vector3(VW + 1.0, 0.5, 0.4), BAD)
	for k in 6:
		rubble.append(box(Vector3.ZERO, Vector3(0.6, 0.6, 0.6), WHITE.darkened(0.2)))


# ---- 탑 만들기 (판마다 손으로 짠 순서) ----
func _build_round() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	rdef = ROUNDS[ri]
	if sky_env:
		sky_env.background_color = rdef.sky
	solids.clear()
	plats.clear()
	wells.clear()
	gen.seed = 4441 + ri * 7919
	gy = 0.0
	prev_cx = 0.0
	_solid(Rect2(-8.0, -8.0, 16.0, 8.0), rdef.wall)
	box(Vector3(0, -0.1, 0.05), Vector3(16.0, 0.2, 2.5), rdef.band, stage)
	for s in rdef.segs:
		if s[0] == "well":
			_well(s[1], s[2], s[3])
		else:
			_room(s[1], s[2])
	goal_y = gy + 0.3
	for x in [prev_cx - 2.6, prev_cx + 2.6]:
		box(Vector3(x, gy + 1.6, 0.3), Vector3(0.3, 3.2, 0.3), GOOD, stage)
	for k in 6:
		box(Vector3(prev_cx - 2.5 + k * 1.0, gy + 3.2, 0.3), Vector3(1.0, 0.4, 0.3), WHITE if k % 2 == 0 else INK, stage)
	for b in bgs:
		b.o = gen.randf_range(-14.0, 18.0)
		b.x = gen.randf_range(-6.0, 6.0)
		var nn: MeshInstance3D = b.n
		var w := gen.randf_range(1.5, 3.5)
		nn.scale = Vector3(w, w * 0.45, 0.5)
		nn.material_override = mat(WHITE if ri < 2 else rdef.sky.darkened(0.06))


func _well(cx: float, w: float, h: float) -> void:
	var l := cx - w * 0.5
	var r := cx + w * 0.5
	_solid(Rect2(-8.0, gy, l + 8.0, h), rdef.wall)
	_solid(Rect2(r, gy, 8.0 - r, h), rdef.wall)
	wells.append({"y0": gy, "y1": gy + h, "cx": cx, "w": w})
	# 줄눈: 3칸마다. 오를 때 아래로 흐르는 게 속도
	var y := gy + 1.5
	while y < gy + h:
		box(Vector3(l - 0.35, y, 0.05), Vector3(0.7, 0.16, 2.5), rdef.band, stage)
		box(Vector3(r + 0.35, y, 0.05), Vector3(0.7, 0.16, 2.5), rdef.band, stage)
		y += 3.0
	prev_cx = cx
	gy += h


func _room(next_cx: float, h: float) -> void:
	_solid(Rect2(-8.0, gy, 2.0, h), rdef.wall)
	_solid(Rect2(6.0, gy, 2.0, h), rdef.wall)
	var y := gy + 1.5
	while y < gy + h:
		box(Vector3(-6.25, y, 0.05), Vector3(0.5, 0.16, 2.5), rdef.band, stage)
		box(Vector3(6.25, y, 0.05), Vector3(0.5, 0.16, 2.5), rdef.band, stage)
		y += 3.0
	# 맨 위 발판은 다음 우물 입구 바로 밑. 아래로 내려가며 지그재그, 가끔 갈래 발판
	var top := gy + h - 2.2
	_plat(next_cx, top, 2.6)
	var tops: Array[float] = []
	var yy := top - 2.3
	while yy > gy + 1.0:
		tops.append(yy)
		yy -= 2.3
	var n := tops.size()
	for k in n:
		var f := float(k + 1) / float(n + 1)  # 0=위, 1=아래
		var x := lerpf(next_cx, prev_cx, f) + (2.4 if k % 2 == 0 else -2.4) * (1.0 if gen.randf() < 0.5 else -1.0)
		x = clampf(x, -4.4, 4.4)
		_plat(x, tops[k], gen.randf_range(2.2, 3.0))
		if gen.randf() < 0.5:
			var x2 := x + (4.0 if x < 0.0 else -4.0)
			_plat(clampf(x2, -4.6, 4.6), tops[k] + gen.randf_range(-0.4, 0.4), 2.0)
	gy += h


func _plat(x: float, top: float, w: float) -> void:
	var rc := Rect2(x - w * 0.5, top - 0.3, w, 0.3)
	var n := box(Vector3(x, top - 0.15, 0.1), Vector3(w, 0.3, 2.0), rdef.plat, stage)
	plats.append({"r": rc, "node": n, "t": -1.0, "dead": false, "regrow": 0.0, "x": x})


func _solid(rc: Rect2, c: Color) -> void:
	solids.append(rc)
	var m := rc.get_center()
	box(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, 2.4), c, stage)


# ---- 판 ----
func _start_round() -> void:
	var xs := [-1.5, -0.5, 0.5, 1.5]
	var order := [0, 1, 2, 3]
	if ri > 0:
		order.shuffle()
	for i in 4:
		var c := climbers[i]
		c.p = Vector2(xs[order[i]], 0.0)
		c.v = Vector2.ZERO
		c.alive = true
		c.grounded = true
		c.wall = 0
		c.imp = 0.0
		c.stun = 0.0
		c.jbuf = 0.0
		c.hold = 0
		c.plat = -1
		c.best_y = 0.0
		c.stuck = 0.0
		c.poof_t = 0.0
		c.poof.visible = false
		c.node.visible = true
		c.base_delay = [0.0, 0.13, 0.09, 0.17][i] - 0.015 * ri + (0.03 if ri == 0 else 0.0)
		c.delay = c.base_delay
		c.dodge = 0.35 + 0.15 * ri
		c.ai_dir = 1 if c.p.x < 0.0 else -1
	for f in falls:
		f.on = false
		(f.n as Node3D).visible = false
	for w in warns:
		w.t = 0.0
		(w.n as Node3D).visible = false
	brick_t = 2.5
	cam_y = VHH - 3.0
	rt = 0.0
	kicks = 0
	tap_press = false
	phase = "count"
	pt = 1.5
	msg("%d판 %s" % [ri + 1, rdef.name], 1.3)
	beep(440.0, 0.12)


func _step(dt: float) -> void:
	shk = maxf(shk - dt * 3.0, 0.0)
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.75 and pt <= 0.75:
				beep(440.0, 0.12)
			if pt <= 0.0:
				phase = "race"
				play("good")
				match ri:
					0: msg("반대쪽을 눌러 벽 차기!", 1.8)
					1: msg("빨간 벽돌: 받으면 떨어짐, 밟으면 발판", 2.2)
					2: msg("밟은 발판은 무너진다! 바닥이 쫓아온다", 2.2)
		"race":
			rt += dt
			_race(dt)
		"done":
			pt -= dt
			_falls(dt)
			if pt <= 0.0:
				_next_round()
	_camera(dt)
	_draw_all(dt)


func _race(dt: float) -> void:
	_my_input()
	for c in climbers:
		if c.alive and not c.me:
			_ai(c, dt)
	_falls(dt)
	_bricks(dt)
	for c in climbers:
		if c.alive:
			_body(c, dt)
	for c in climbers:
		if c.alive:
			_touch_falls(c)
	_crumble(dt)
	# 탈락·결승
	var bottom := cam_y - VHH
	for c in climbers:
		if not c.alive:
			continue
		c.best_y = maxf(c.best_y, c.p.y)
		if c.p.y + HH < bottom:
			_die(c)
		elif c.p.y >= goal_y:
			_finish(c)
			return
	if not me_c.alive:
		_round_over(false, "탈락!")
		return
	var others := 0
	for c in climbers:
		if c.alive and not c.me:
			others += 1
	if others == 0:
		_round_over(true, "혼자 남았다!")
		return
	score = wins * 100 + int(meters + me_c.best_y)
	if ri == 0 and kicks == 0 and rt > 3.5 and rt < 3.6:
		msg("벽에 붙으면 반대쪽 버튼!", 1.6)


func _my_input() -> void:
	var l := kit_held("L")
	var r := kit_held("R")
	if kit_just("L"):
		last_dir = -1
		_press(me_c, -1)
	if kit_just("R"):
		last_dir = 1
		_press(me_c, 1)
	if tap_press:
		tap_press = false
		last_dir = tap_dir
		_press(me_c, tap_dir)
	var h := 0
	if l and r:
		h = last_dir
	elif l:
		h = -1
	elif r:
		h = 1
	elif tap_down:
		h = tap_dir
	me_c.hold = h


func _tap(p: Vector2) -> void:
	tap_dir = -1 if p.x < 360.0 else 1
	tap_down = true
	if phase == "race":
		tap_press = true


func _lift(_p: Vector2) -> void:
	tap_down = false


func _press(c: Climber, d: int) -> void:
	c.jbuf = JBUF
	c.jdir = d
	c.hold = d


# ---- 몸의 물리 ----
func _body(c: Climber, dt: float) -> void:
	c.stun = maxf(c.stun - dt, 0.0)
	c.hit_cd = maxf(c.hit_cd - dt, 0.0)
	c.lock = maxf(c.lock - dt, 0.0)
	c.sq = maxf(c.sq - dt * 2.5, 0.0)
	var hold := c.hold if c.stun <= 0.0 else 0
	if c.stun > 0.0:
		c.jbuf = 0.0
	# 옆
	if c.grounded:
		c.v.x = move_toward(c.v.x, hold * RUN, GROUND_ACC * dt)
	elif hold != 0:
		c.v.x = move_toward(c.v.x, hold * AIR_MAX, AIR_ACC * dt)
	else:
		c.v.x *= exp(-AIR_DRAG * dt)
	# 위아래
	c.v.y = maxf(c.v.y - GRAV * dt, -MAX_FALL)
	if c.wall != 0 and c.stun <= 0.0 and c.v.y < -SLIDE:
		c.v.y = -SLIDE
	if c.wall != 0:
		c.imp *= exp(-IMP_DECAY * dt)
		c.wall_t += dt
	else:
		c.wall_t = 0.0
	# 뛰기·벽 차기
	if c.jbuf > 0.0:
		if c.grounded:
			c.v.y = JUMP
			c.v.x = c.jdir * JUMP_VX
			c.grounded = false
			c.jbuf = 0.0
			c.sq = 0.2
			if _seen(c):
				beep(480.0, 0.06, 700.0, 0.14)
		elif c.wall != 0 and c.jdir == -c.wall:
			_kick(c)
		c.jbuf -= dt
	# 옆으로 움직이고 벽에 막힘
	var vx_pre := c.v.x
	c.p.x += c.v.x * dt
	var hit := 0
	for s in solids:
		var br := Rect2(c.p.x - HW, c.p.y + 0.02, HW * 2.0, HH - 0.04)
		if s.intersects(br):
			if vx_pre > 0.0:
				c.p.x = s.position.x - HW - 0.001
				hit = 1
			elif vx_pre < 0.0:
				c.p.x = s.end.x + HW + 0.001
				hit = -1
			c.v.x = 0.0
	# 위아래로 움직임
	c.prev_y = c.p.y
	c.p.y += c.v.y * dt
	c.grounded = false
	var landed_plat := -1
	# 남의 머리 밟기
	if c.v.y < 0.0:
		for o in climbers:
			if o == c or not o.alive:
				continue
			var head := o.p.y + HH
			if c.prev_y >= head - 0.05 and c.p.y <= head and absf(c.p.x - o.p.x) < HW * 1.8:
				_stomp(c, o)
				break
	for s in solids:
		var br := Rect2(c.p.x - HW + 0.02, c.p.y, HW * 2.0 - 0.04, HH)
		if s.intersects(br):
			if c.v.y <= 0.0:
				c.p.y = s.end.y
				c.grounded = true
			else:
				c.p.y = s.position.y - HH
			c.v.y = 0.0
	if c.v.y <= 0.0 and not c.grounded:
		for i in plats.size():
			var pl: Dictionary = plats[i]
			if pl.dead:
				continue
			var rc: Rect2 = pl.r
			var top := rc.end.y
			if c.prev_y >= top - 0.02 and c.p.y <= top and c.p.x + HW * 0.6 > rc.position.x and c.p.x - HW * 0.6 < rc.end.x:
				c.p.y = top
				c.v.y = 0.0
				c.grounded = true
				landed_plat = i
				break
	c.plat = landed_plat
	if landed_plat >= 0 and rdef.crumble and float(plats[landed_plat].t) < 0.0:
		plats[landed_plat].t = CRUMBLE_T
		(plats[landed_plat].node as MeshInstance3D).material_override = mat(D)
		if _seen(c):
			beep(200.0, 0.1, 150.0, 0.18)
	# 벽에 붙었나
	var nw := 0
	if not c.grounded and c.lock <= 0.0:
		var probe_r := Rect2(c.p.x + HW, c.p.y + 0.25, 0.08, HH - 0.5)
		var probe_l := Rect2(c.p.x - HW - 0.08, c.p.y + 0.25, 0.08, HH - 0.5)
		if _solid_in(probe_r):
			nw = 1
		elif _solid_in(probe_l):
			nw = -1
	if nw != 0 and nw != c.wall:
		c.imp = absf(vx_pre) if hit == nw else 0.0
		c.wall_t = 0.0
		if c.imp > 2.0 and _seen(c):
			beep(160.0 + c.imp * 30.0, 0.04, 0.0, 0.12)
	elif nw == 0:
		c.imp = 0.0
	c.wall = nw


func _kick(c: Climber) -> void:
	var pw := c.imp
	c.v.y = minf(maxf(c.v.y, 0.0) * CARRY + KICK_BASE + KICK_K * pw, KICK_CAP)
	c.v.x = c.jdir * (KICK_VX + 0.45 * pw)
	c.wall = 0
	c.imp = 0.0
	c.lock = 0.1
	c.jbuf = 0.0
	c.sq = 0.15 + pw * 0.025
	_puff(Vector2(c.p.x - c.jdir * HW, c.p.y + 0.5), 0.3 + pw * 0.08)
	if c.me:
		kicks += 1
		beep(300.0 + pw * 60.0, 0.07, 500.0 + pw * 80.0, 0.22)
		if pw > 8.0:
			shk = maxf(shk, 0.12)
			if not strong_said:
				strong_said = true
				msg("세게 박을수록 높이!", 1.2)
	elif _seen(c):
		beep(260.0 + pw * 40.0, 0.05, 0.0, 0.1)
	if not c.me:
		c.delay = c.base_delay + randf() * 0.08


func _stomp(c: Climber, o: Climber) -> void:
	c.p.y = o.p.y + HH
	c.v.y = STOMP_UP
	c.sq = 0.3
	o.v.y = minf(o.v.y, -STOMP_DOWN)
	o.stun = 0.35
	o.wall = 0
	o.imp = 0.0
	o.sq = 0.0
	_puff(Vector2(o.p.x, o.p.y + HH), 0.6)
	if c.me or o.me:
		beep(180.0, 0.12, 520.0 if c.me else 90.0, 0.28)
		shk = maxf(shk, 0.25)
		msg("밟았다!" if c.me else "밟혔다!", 0.6)
	elif _seen(c):
		beep(180.0, 0.1, 400.0, 0.14)


func _solid_in(r: Rect2) -> bool:
	for s in solids:
		if s.intersects(r):
			return true
	return false


func _seen(c: Climber) -> bool:
	return absf(c.p.y - cam_y) < VHH + 1.0


func _die(c: Climber) -> void:
	c.alive = false
	c.node.visible = false
	c.poof.visible = true
	c.poof_t = 0.5
	c.poof.position = Vector3(c.p.x, cam_y - VHH + 0.6, 0.6)
	if c.me:
		play("bad")
		shk = 0.4
	else:
		beep(300.0, 0.2, 120.0, 0.22)
		msg("%s 탈락" % c.nick, 0.8)


func _finish(c: Climber) -> void:
	if c.me:
		_round_over(true, "1등!")
	else:
		_round_over(false, "%s 1등" % c.nick)


func _round_over(won: bool, s: String) -> void:
	phase = "done"
	pt = 2.0
	meters += me_c.best_y
	if won:
		wins += 1
		play("win")
	else:
		beep(260.0, 0.3, 130.0, 0.25)
	score = wins * 100 + int(meters)
	msg("%s  %d승 %d패" % [s, wins, ri + 1 - wins], 1.9)


func _next_round() -> void:
	if ri >= ROUNDS.size() - 1:
		score = wins * 100 + int(meters)
		msg("우승!" if wins >= 2 else "우승 못 함", 3.0)
		end()
		return
	ri += 1
	_build_round()
	_start_round()


# ---- AI: 사람과 같은 몸, 같은 버튼 ----
func _ai(c: Climber, dt: float) -> void:
	c.think -= dt
	if c.stun > 0.0:
		return
	# 오래 못 오르면 아무 쪽으로나
	if c.p.y > c.best_y + 0.5:
		c.stuck = 0.0
	else:
		c.stuck += dt
	if c.stuck > 2.5:
		c.stuck = 1.2
		_press(c, 1 if randf() < 0.5 else -1)
		return
	var wl := _well_at(c.p.y + 0.6)
	if not wl.is_empty() and c.p.y < float(wl.y1) - 0.4:
		var cx: float = wl.cx
		if c.grounded:
			if c.think <= 0.0:
				c.think = 0.2
				var d := 1 if c.p.x < cx else -1
				c.ai_dir = d
				_press(c, d)
		elif c.wall != 0:
			c.hold = c.wall
			if c.wall_t >= c.delay:
				c.ai_dir = -c.wall
				_press(c, -c.wall)
		else:
			if c.ai_dir == 0:
				c.ai_dir = 1 if c.p.x < cx else -1
			c.hold = c.ai_dir
		return
	# 방: 위쪽 가장 가까운 발판, 없으면 다음 우물 입구
	var tx := _ai_target(c)
	var dx := tx - c.p.x
	var d := 1 if dx > 0.0 else -1
	if c.grounded:
		if c.think <= 0.0:
			c.think = 0.18 + randf() * 0.2
			c.ai_dir = d
			_press(c, d)
			if absf(dx) < 0.6:
				c.hold = 0
	elif c.wall != 0 and c.v.y < 0.0:
		_press(c, -c.wall)
	else:
		c.hold = d if absf(dx) > 0.35 else 0
	# 떨어지는 것 피하기 / 아래 사람 밟기
	for f in falls:
		if not f.on:
			continue
		var fp: Vector2 = f.p
		if fp.y > c.p.y + HH and fp.y - c.p.y < 6.0 and absf(fp.x - c.p.x) < float(f.w) * 0.5 + 0.7 and randf() < c.dodge:
			c.hold = 1 if c.p.x > fp.x else -1
			return
	if c.v.y < 0.0 and not c.grounded:
		for o in climbers:
			if o != c and o.alive and o.p.y < c.p.y - HH and c.p.y - o.p.y < 3.0 and absf(o.p.x - c.p.x) < 2.0:
				c.hold = 1 if o.p.x > c.p.x else -1


func _well_at(y: float) -> Dictionary:
	for w in wells:
		if y >= float(w.y0) and y < float(w.y1):
			return w
	return {}


func _ai_target(c: Climber) -> float:
	var best := 999.0
	var tx := 0.0
	for pl in plats:
		if pl.dead:
			continue
		var top: float = (pl.r as Rect2).end.y
		if top > c.p.y + 0.4 and top < c.p.y + 3.1:
			var dd := absf(float(pl.x) - c.p.x)
			if dd < best:
				best = dd
				tx = pl.x
	if best < 999.0:
		return tx
	var low := 1e9
	for w in wells:
		var y0: float = w.y0
		if y0 > c.p.y - 0.5 and y0 < low:
			low = y0
			tx = w.cx
	return tx if low < 1e9 else 0.0


# ---- 떨어지는 것 (벽돌·무너진 발판) ----
func _bricks(dt: float) -> void:
	var iv: float = rdef.bricks
	var top := cam_y + VHH
	for w in warns:
		if w.t <= 0.0:
			continue
		w.t -= dt
		var wn: MeshInstance3D = w.n
		wn.position = Vector3(w.x, top - 4.6, 1.0)
		wn.visible = fmod(w.t, 0.16) > 0.07
		if w.t <= 0.0:
			wn.visible = false
			_spawn_fall(Vector2(w.x, top + 0.5), 1.2, 0.7, -2.0)
	if iv <= 0.0 or rt < 1.5:
		return
	brick_t -= dt
	if brick_t > 0.0:
		return
	brick_t = iv * randf_range(0.8, 1.2)
	var alive: Array[Climber] = []
	for c in climbers:
		if c.alive:
			alive.append(c)
	if alive.is_empty():
		return
	var tgt: Climber = alive[randi() % alive.size()]
	var x := clampf(tgt.p.x + randf_range(-1.3, 1.3), -5.2, 5.2)
	var wl := _well_at(top - 1.0)
	if not wl.is_empty():
		var hw: float = float(wl.w) * 0.5 - 0.7
		x = clampf(x, float(wl.cx) - hw, float(wl.cx) + hw)
	for w in warns:
		if w.t <= 0.0:
			w.t = 0.7
			w.x = x
			if _seen(me_c):
				beep(1200.0, 0.05, 0.0, 0.1)
			break


func _spawn_fall(p: Vector2, w: float, h: float, vy: float) -> void:
	for f in falls:
		if f.on:
			continue
		f.on = true
		f.p = p
		f.w = w
		f.h = h
		f.vy = vy
		f.prev_top = p.y + h * 0.5
		var n: MeshInstance3D = f.n
		n.scale = Vector3(w, h, 1.0)
		n.position = Vector3(p.x, p.y, 0.4)
		n.visible = true
		return


func _falls(dt: float) -> void:
	var bottom := cam_y - VHH
	for f in falls:
		if not f.on:
			continue
		f.prev_top = float(f.p.y) + float(f.h) * 0.5
		if f.vy > -F_MAX:
			f.vy = maxf(f.vy - F_GRAV * dt, -F_MAX)
		var np: Vector2 = f.p
		np.y += float(f.vy) * dt
		f.p = np
		var fr := Rect2(float(f.p.x) - float(f.w) * 0.5, float(f.p.y) - float(f.h) * 0.5, f.w, f.h)
		var n: MeshInstance3D = f.n
		n.position = Vector3(f.p.x, f.p.y, 0.4)
		if f.p.y < bottom - 3.0:
			f.on = false
			n.visible = false
		elif _solid_in(fr):  # 벽·바닥에 맞으면 부서진다
			f.on = false
			n.visible = false
			if absf(float(f.p.y) - cam_y) < VHH:
				_puff(f.p, 0.5)
				beep(140.0, 0.08, 90.0, 0.12)


func _touch_falls(c: Climber) -> void:
	for f in falls:
		if not f.on:
			continue
		var fp: Vector2 = f.p
		var hw: float = float(f.w) * 0.5 + HW * 0.8
		if absf(c.p.x - fp.x) > hw:
			continue
		var ftop: float = fp.y + float(f.h) * 0.5
		var fbot: float = fp.y - float(f.h) * 0.5
		if c.prev_y >= float(f.prev_top) - 0.08 and c.p.y < ftop and c.stun <= 0.0:
			# 위에 내려앉음: 떨어지는 속도까지 받아 튄다
			c.p.y = ftop
			c.v.y = minf(STOMP_UP + absf(float(f.vy)) * 0.4, KICK_CAP)
			c.sq = 0.3
			f.vy = float(f.vy) - 5.0
			_puff(Vector2(c.p.x, ftop), 0.4)
			if c.me:
				beep(240.0, 0.1, 640.0, 0.26)
				msg("돌 밟기!", 0.5)
			return
		if c.p.y < fp.y + float(f.h) * 0.5 and c.p.y + HH > fbot and c.hit_cd <= 0.0:
			# 머리로 받음: 아래로 꽂힌다
			c.v.y = minf(c.v.y, float(f.vy) - 5.0)
			c.v.x *= 0.3
			c.stun = 0.45
			c.hit_cd = 0.6
			c.wall = 0
			c.imp = 0.0
			if c.me:
				beep(150.0, 0.2, 80.0, 0.3)
				shk = maxf(shk, 0.35)
				msg("맞았다!", 0.6)
			return


func _crumble(dt: float) -> void:
	if not rdef.crumble:
		return
	for pl in plats:
		var n: MeshInstance3D = pl.node
		if pl.dead:
			pl.regrow -= dt
			if pl.regrow <= 0.0:
				pl.dead = false
				pl.t = -1.0
				n.visible = true
				n.material_override = mat(rdef.plat)
				n.position.x = pl.x
			continue
		if pl.t < 0.0:
			continue
		pl.t -= dt
		n.position.x = float(pl.x) + sin(rt * 70.0) * 0.06
		if pl.t <= 0.0:
			pl.dead = true
			pl.regrow = REGROW_T
			n.visible = false
			var rc: Rect2 = pl.r
			_spawn_fall(rc.get_center(), rc.size.x, 0.4, -1.0)
			if absf(rc.position.y - cam_y) < VHH:
				beep(170.0, 0.12, 100.0, 0.16)


func _puff(p: Vector2, s: float) -> void:
	var pf: Dictionary = puffs[puff_i]
	puff_i = (puff_i + 1) % puffs.size()
	pf.life = 0.25
	pf.s = s
	var n: MeshInstance3D = pf.n
	n.position = Vector3(p.x, p.y, 0.8)
	n.visible = true


# ---- 카메라·그리기 ----
func _camera(dt: float) -> void:
	if phase == "race":
		var lead := -1e9
		for c in climbers:
			if c.alive:
				lead = maxf(lead, c.p.y)
		if lead > -1e8:
			var target := lead + HH * 0.5 + VHH * 0.1  # 1등이 화면 아래에서 45% 자리
			if target > cam_y:
				cam_y = move_toward(cam_y, target, CAM_MAX * dt)
		var rise: float = rdef.rise
		if rise > 0.0 and rt > 3.0:
			cam_y += rise * dt
		cam_y = minf(cam_y, goal_y + 4.0)
	cam.position = Vector3(randf_range(-1.0, 1.0) * shk * 0.4, cam_y + randf_range(-1.0, 1.0) * shk * 0.4, 20.0)


func _draw_all(dt: float) -> void:
	var bottom := cam_y - VHH
	for c in climbers:
		if c.alive:
			c.node.position = Vector3(c.p.x, c.p.y, 0.3)
			var st := c.sq
			c.vis.scale = Vector3(1.0 - st * 0.4, 1.0 + st, 1.0)
			var face := c.v.x if absf(c.v.x) > 0.3 else float(c.hold)
			c.vis.rotation.y = 0.0 if face >= 0.0 else PI
			if c.stun > 0.0:
				c.vis.rotation.z = sin(c.stun * 30.0) * 0.5
			elif c.wall != 0:
				c.vis.rotation.z = -c.wall * 0.22
			else:
				c.vis.rotation.z = -clampf(c.v.x * 0.02, -0.2, 0.2)
		if c.poof_t > 0.0:
			c.poof_t -= dt
			var k := 1.0 - c.poof_t / 0.5
			c.poof.scale = Vector3.ONE * (0.5 + k * 2.0)
			c.poof.material_override = mat(c.col.lightened(0.5))
			if c.poof_t <= 0.0:
				c.poof.visible = false
	marker.visible = me_c.alive
	marker.position = Vector3(me_c.p.x, me_c.p.y + HH + 0.5 + sin(Time.get_ticks_msec() * 0.008) * 0.1, 0.6)
	marker.rotation.y += dt * 3.0
	# 아래 가장자리: 빨간 띠, 내 거리 게이지, 가까울수록 빠른 삐
	edge_band.position = Vector3(0, bottom + 0.25, 1.2)
	var rising: bool = float(rdef.rise) > 0.0 and phase == "race" and rt > 3.0
	for k in rubble.size():
		var rb: MeshInstance3D = rubble[k]
		rb.visible = rising
		if rising:
			rb.position = Vector3(-6.0 + k * 2.4 + randf_range(-0.2, 0.2), bottom + 0.4 + absf(sin(rt * 9.0 + k)) * 0.5, 1.3)
	if me_c.alive and phase == "race":
		var frac := clampf((me_c.p.y - bottom) / (VHH * 1.2), 0.0, 1.0)
		gauge(frac, BAD if frac < 0.25 else GOOD)
		if frac < 0.25:
			tick -= dt
			if tick <= 0.0:
				tick = 0.08 + frac * 1.2
				beep(900.0, 0.04, 0.0, 0.12)
	# 떨어지는 것 흔들기, 흰 조각
	for pf in puffs:
		if pf.life <= 0.0:
			continue
		pf.life -= dt
		var n: MeshInstance3D = pf.n
		n.scale = Vector3.ONE * float(pf.s) * (1.0 + (0.25 - float(pf.life)) * 4.0)
		if pf.life <= 0.0:
			n.visible = false
	# 빠르게 오를 때 바람 줄
	var fast := me_c.alive and me_c.v.y > 12.0
	for k in streaks.size():
		var sn: MeshInstance3D = streaks[k]
		sn.visible = fast
		if fast:
			sn.position = Vector3(me_c.p.x + (k - 2.5) * 0.35 + randf_range(-0.1, 0.1), me_c.p.y - 1.2 - randf() * 1.5, 0.5)
	# 뒤 구름: 카메라의 40% 빠르기로 흐른다
	for b in bgs:
		var y: float = cam_y + float(b.o) - cam_y * 0.4
		if y < cam_y - VHH - 3.0:
			b.o = float(b.o) + 34.0
			y += 34.0
		(b.n as MeshInstance3D).position = Vector3(b.x, y, -6.0)
