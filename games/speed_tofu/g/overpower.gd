extends Tofu
## 너무 센 몸 (옆모습 플랫포머): 왼쪽 아래 조이스틱으로 좌우(살짝만 기울여도 총알처럼 빠르다), 오른쪽 큰 점프(늘 천장까지 솟는다).
## 천장에 쾅 박으면 어질하고 옆으로 더 빨라진다. 빠르게 박으면 금 간 천장·벽이 부서진다. 방 2개마다 능력(대시 → 이중 뛰기 → 벽차기)을 얻는데 그것도 너무 세다.

const GRAV := 45.0
const JUMP_V := 24.0  # 꼭대기까지 6칸 넘게: 거의 모든 방에서 천장에 박는다
const RUN_LO := 16.0  # 살짝 기울여도 이 속도
const RUN_HI := 22.0
const GROUND_ACC := 90.0
const AIR_ACC := 30.0
const FRICTION := 60.0
const MAX_FALL := 30.0
const BONK_CAP := 34.0
const BREAK_SIDE := 30.0  # 이보다 빠르게 옆으로 박으면 금 간 벽이 부서진다
const BREAK_UP := 12.0
const SLAM_V := 12.0
const DASH_V := 44.0
const DASH_T := 0.22
const KICK_VX := 16.0
const KICK_VY := 20.0
const PW := 0.7
const PH := 0.9
const EPS := 0.0001
const WALLC := Color("d9c39a")
const GAIN := {2: "대시", 4: "이중 뛰기", 6: "벽차기"}
# 방: 위 줄부터. # 벽, = 금 간 블럭, ^ 가시, S 시작, D 문(2칸 높이). 아래로 뚫린 곳은 구덩이.
const ROOMS := [
	{"name": "너무 세다", "map": [
		"##############################",
		"#                            #",
		"#                            #",
		"#                            #",
		"#                            #",
		"#            ##              #",
		"# S          ##          D   #",
		"##################   #########",
		"##################^^^#########",
	]},
	{"name": "낮은 복도", "map": [
		"####################################",
		"#          #########################",
		"#          #########################",
		"#          #########################",
		"#          #########################",
		"#          #########################",
		"#                                  #",
		"# S                              D #",
		"##############^^^^^^^###############",
		"####################################",
	]},
	{"name": "금 간 벽", "map": [
		"##################################",
		"#                #################",
		"#                #################",
		"#                #################",
		"#                #################",
		"#                     =          #",
		"#                     =          #",
		"# S                   =       D  #",
		"########^^^^######################",
	]},
	{"name": "긴 구덩이", "map": [
		"############################################",
		"#                                          #",
		"# S                                     D  #",
		"#####                  #####################",
		"#####                  #####################",
		"#####                  #####################",
		"#####                  #####################",
		"#####                  #####################",
		"#####                  #####################",
		"#####                  #####################",
		"#####^^^^^^^^^^^^^^^^^^#####################",
	]},
	{"name": "두 번 쾅", "map": [
		"########################################",
		"########################################",
		"########################################",
		"#                                      #",
		"# S                                 D  #",
		"#######^^^^^^^^^^^^^^^^#################",
		"########################################",
		"########################################",
	]},
	{"name": "위층", "map": [
		"##############",
		"#            #",
		"#         D  #",
		"####==########",
		"####  ########",
		"####  ########",
		"####==########",
		"#            #",
		"#            #",
		"# S          #",
		"##############",
		"##############",
	]},
	{"name": "굴뚝", "map": [
		"############",
		"#          #",
		"#       D  #",
		"#####   ####",
		"#####   ####",
		"#####   ####",
		"#####   ####",
		"#####   ####",
		"#####   ####",
		"####^   ####",
		"####^   ####",
		"#####   ####",
		"#####   ####",
		"#####   ^###",
		"#####   ####",
		"#####   ####",
		"#####   ####",
		"#          #",
		"# S        #",
		"############",
	]},
	{"name": "끝까지", "map": [
		"##########################################",
		"#          ###############################",
		"#          ###############################",
		"#          ###############################",
		"#          =                             #",
		"# S        =                          D  #",
		"#####^^^#####^^^^^^^^^^^^^^^^#############",
		"##########################################",
		"##########################################",
	]},
]

var lv := 0
var got := -1
var stage: Node3D
var grid: Array[String] = []
var rows := 0
var cols := 0
var cracks := {}  # Vector2i(칸 x, 칸 y) -> 상자. 부서지면 지운다
var door := Rect2()
var px := 0.0  # 발 가운데
var py := 0.0
var vx := 0.0
var vy := 0.0
var on_floor := false
var coyote := 0.0
var jbuf := 0.0
var dbuf := 0.0
var cut := true
var stun := 0.0
var hang := 0.0
var dash_t := 0.0
var dash_dir := 1.0
var dash_cd := 0.0
var air_dash := 1
var air_jump := 0
var grip := 0.0
var face := 1.0
var die_t := 0.0
var clear_t := 0.0
var shake := 0.0
var squash := 0.0
var step_t := 0.0
var anim := 0.0
var cam_x := 0.0
var cam_y := 0.0
var trail_t := 0.0
var trail_k := 0
var bonks := 0
var me: Node3D
var body: MeshInstance3D
var eye: MeshInstance3D
var stars: Array[MeshInstance3D] = []
var trail: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 58.0
	howto = "왼쪽 아래 조이스틱으로 좌우. 살짝만 기울여도 엄청 빠르다. 톡톡 짧게 밀어 조절한다.\n점프는 늘 너무 세서 천장에 쾅! 달리던 중이면 옆으로 더 빨리 튕겨 나가고, 노란 금 간 블럭은 부서진다.\n초록 문에 닿으면 다음 방. 빨간 가시·구덩이에 닿으면 그 방부터 다시.\n방 2개마다 (역시 너무 센) 능력을 얻는다."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1100), 105.0, A)


func _reset() -> void:
	lv = 0
	got = -1
	_btns.erase("dash")
	stage = null
	_room(0)


func _room(i: int) -> void:
	if stage:
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	var m: Array = ROOMS[i].map
	rows = m.size()
	cols = 0
	for s in m:
		cols = maxi(cols, String(s).length())
	grid.clear()
	for s in m:
		grid.append(String(s).rpad(cols, "#"))
	cracks.clear()
	var start := Vector2(2.5, 2.0)
	for r in rows:
		var yy := rows - 1 - r
		var line := grid[r]
		var run0 := -1
		for c in cols + 1:
			var ch := line[c] if c < cols else " "
			if ch == "#":
				if run0 < 0:
					run0 = c
				continue
			if run0 >= 0:
				box(Vector3((run0 + c) * 0.5, yy + 0.5, 0.0), Vector3(c - run0, 1.0, 2.0), WALLC, stage)
				run0 = -1
			if ch == "=":
				cracks[Vector2i(c, yy)] = box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.94, 0.94, 1.8), D, stage)
			elif ch == "^":
				var sp := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.55, 0.55, 1.2), BAD, stage)
				sp.rotation.z = PI * 0.25
			elif ch == "S":
				start = Vector2(c + 0.5, yy)
			elif ch == "D":
				door = Rect2(c, yy, 1.0, 2.0)
				box(Vector3(c + 0.5, yy + 1.0, -0.6), Vector3(1.1, 2.0, 0.6), GOOD, stage)
				box(Vector3(c + 0.75, yy + 1.0, -0.2), Vector3(0.15, 0.15, 0.2), D, stage)
	# 나
	me = Node3D.new()
	stage.add_child(me)
	body = box(Vector3(0, PH * 0.5, 0), Vector3(PW, PH, 0.7), ME, me)
	eye = box(Vector3(0.2, PH * 0.68, 0.36), Vector3(0.16, 0.16, 0.05), WHITE, me)
	stars.clear()
	for k in 2:
		var s := box(Vector3.ZERO, Vector3(0.2, 0.2, 0.2), D, me)
		s.visible = false
		stars.append(s)
	trail.clear()
	for k in 6:
		var tb := box(Vector3.ZERO, Vector3(PW, PH, 0.4), B, stage)
		tb.visible = false
		trail.append(tb)
	px = start.x
	py = start.y
	vx = 0.0
	vy = 0.0
	on_floor = true
	coyote = 0.0
	jbuf = 0.0
	dbuf = 0.0
	cut = true
	stun = 0.0
	hang = 0.0
	dash_t = 0.0
	dash_cd = 0.0
	air_dash = 1
	air_jump = 1 if i >= 4 else 0
	grip = 0.0
	face = 1.0
	die_t = 0.0
	clear_t = 0.0
	squash = 0.0
	cam_x = px
	cam_y = py
	if i >= 2:
		kit_button("dash", "대시", Vector2(600, 870), 82.0, C)
	if GAIN.has(i) and got < i:
		got = i
		msg("%s 얻음" % GAIN[i], 1.8)
		play("good")
	else:
		msg("%d. %s" % [i + 1, ROOMS[i].name], 1.2)


# ---- 칸 ----
func _ch(c: int, yy: int) -> String:
	if c < 0 or c >= cols or yy >= rows:
		return "#"
	if yy < 0:
		return " "
	var ch := grid[rows - 1 - yy][c]
	if ch == "=" and not cracks.has(Vector2i(c, yy)):
		return " "
	return ch


func _solid(c: int, yy: int) -> bool:
	var ch := _ch(c, yy)
	return ch == "#" or ch == "="


func _ground() -> bool:
	var yy := floori(py - 0.02)
	for c in range(floori(px - PW * 0.5 + EPS), floori(px + PW * 0.5 - EPS) + 1):
		if _solid(c, yy):
			return true
	return false


## 몸 옆에 붙은 벽: 1 오른쪽, -1 왼쪽, 0 없음
func _wall_side() -> int:
	var y0 := floori(py + EPS)
	var y1 := floori(py + PH - EPS)
	for yy in range(y0, y1 + 1):
		if _solid(floori(px + PW * 0.5 + 0.05), yy):
			return 1
		if _solid(floori(px - PW * 0.5 - 0.05), yy):
			return -1
	return 0


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	anim += dt
	gauge(float(lv) / ROOMS.size(), GOOD)
	if die_t > 0.0:
		die_t -= dt
		_view(dt)
		if die_t <= 0.0:
			_room(lv)
		return
	if clear_t > 0.0:
		clear_t -= dt
		_view(dt)
		if clear_t <= 0.0:
			lv += 1
			score = lv
			if lv >= ROOMS.size():
				end()
			else:
				_room(lv)
		return
	_control(h)
	_physics(h)
	_check()
	_sounds(h)
	_view(dt)


func _control(h: float) -> void:
	var mx := kit_move.x
	if absf(mx) < 0.12:
		mx = 0.0
	if kit_just("jump"):
		jbuf = 0.12
	if lv >= 2 and kit_just("dash"):
		dbuf = 0.1
	jbuf -= h
	dbuf -= h
	coyote -= h
	dash_cd -= h
	stun -= h
	squash = maxf(0.0, squash - h * 4.0)
	if mx != 0.0 and stun <= 0.0 and dash_t <= 0.0:
		face = signf(mx)
	if stun <= 0.0 and dash_t <= 0.0:
		var target := signf(mx) * lerpf(RUN_LO, RUN_HI, absf(mx)) if mx != 0.0 else 0.0
		var too_fast := mx != 0.0 and signf(vx) == signf(target) and absf(vx) > absf(target)
		if on_floor:
			if mx == 0.0:
				vx = move_toward(vx, 0.0, FRICTION * h)
			elif too_fast:
				vx = move_toward(vx, target, 40.0 * h)
			else:
				vx = move_toward(vx, target, GROUND_ACC * h)
		elif mx != 0.0 and not too_fast:
			vx = move_toward(vx, target, AIR_ACC * h)
	elif on_floor and dash_t <= 0.0:
		vx = move_toward(vx, 0.0, FRICTION * h)
	# 점프: 땅 → 벽차기 → 공중 한 번 더
	if jbuf > 0.0 and stun <= 0.0:
		var wall := _wall_side()
		if on_floor or coyote > 0.0:
			_jump(false)
		elif lv >= 6 and wall != 0:
			_kick(wall)
		elif lv >= 4 and air_jump > 0:
			air_jump -= 1
			_jump(true)
	# 일찍 떼도 아주 조금만 낮아진다
	if not cut and vy > 0.0 and not kit_held("jump"):
		vy *= 0.93
		cut = true
	if dbuf > 0.0 and stun <= 0.0 and dash_cd <= 0.0 and (on_floor or air_dash > 0):
		if not on_floor:
			air_dash -= 1
		dbuf = 0.0
		dash_t = DASH_T
		dash_dir = face
		dash_cd = 0.35
		hang = 0.0
		shake = maxf(shake, 0.12)
		beep(260.0, 0.16, 1500.0, 0.3)


func _jump(air: bool) -> void:
	dash_t = 0.0
	vy = JUMP_V
	on_floor = false
	coyote = 0.0
	jbuf = 0.0
	cut = false
	grip = 0.0
	if air:
		beep(700.0, 0.1, 1400.0, 0.24)
	else:
		beep(420.0, 0.1, 1000.0, 0.24)


func _kick(wall: int) -> void:
	vx = -wall * KICK_VX
	vy = KICK_VY
	face = -wall
	jbuf = 0.0
	cut = false
	grip = 0.0
	air_dash = 1
	beep(520.0, 0.08, 1200.0, 0.26)


func _physics(h: float) -> void:
	if dash_t > 0.0:
		dash_t -= h
		vy = 0.0
		vx = dash_dir * DASH_V
		if dash_t <= 0.0:
			vx = dash_dir * RUN_HI
	elif hang > 0.0:
		hang -= h
		vy = 0.0
	else:
		vy = maxf(vy - GRAV * h, -MAX_FALL)
		if grip > 0.0:
			grip -= h
			if _wall_side() == 0:
				grip = 0.0
			elif vy < -2.5:
				vy = -2.5
	for i in 4:
		_move_x(vx * h * 0.25)
		_move_y(vy * h * 0.25)
	var was := on_floor
	on_floor = vy <= 0.0 and _ground()
	if on_floor:
		coyote = 0.08
		air_dash = 1
		air_jump = 1 if lv >= 4 else 0
		grip = 0.0
		if not was:
			squash = maxf(squash, 0.35)
			beep(90.0, 0.06, 0.0, 0.2)


func _move_x(d: float) -> void:
	if d == 0.0:
		return
	px += d
	var c := floori(px + PW * 0.5 - EPS) if d > 0.0 else floori(px - PW * 0.5 + EPS)
	var hit := false
	var hard := false
	var cr: Array[Vector2i] = []
	for yy in range(floori(py + EPS), floori(py + PH - EPS) + 1):
		var ch := _ch(c, yy)
		if ch == "#":
			hit = true
			hard = true
		elif ch == "=":
			hit = true
			cr.append(Vector2i(c, yy))
	if not hit:
		return
	if not hard and absf(vx) >= BREAK_SIDE:
		_break(cr)
		vx *= 0.6
		return
	px = c - PW * 0.5 - 0.001 if d > 0.0 else c + 1.0 + PW * 0.5 + 0.001
	_wall_hit(signf(d))


func _move_y(d: float) -> void:
	if d == 0.0:
		return
	py += d
	var x0 := floori(px - PW * 0.5 + EPS)
	var x1 := floori(px + PW * 0.5 - EPS)
	var r := floori(py + PH - EPS) if d > 0.0 else floori(py)
	var hit := false
	var hard := false
	var cr: Array[Vector2i] = []
	for c in range(x0, x1 + 1):
		var ch := _ch(c, r)
		if ch == "#":
			hit = true
			hard = true
		elif ch == "=":
			hit = true
			cr.append(Vector2i(c, r))
	if not hit:
		return
	if d > 0.0:
		if not hard and vy >= BREAK_UP:
			_break(cr)
			vy *= 0.7
			return
		py = r - PH - 0.001
		_bonk()
	else:
		py = r + 1.0
		vy = 0.0


## 천장에 박기: 어질, 잠깐 붙었다가 떨어진다. 달리던 중이면 옆으로 더 빨라진다
func _bonk() -> void:
	var sp := vy
	vy = 0.0
	if sp < 3.0:
		return
	bonks += 1
	hang = 0.08
	stun = 0.18
	dash_t = 0.0
	shake = maxf(shake, 0.3)
	squash = 0.7
	if absf(vx) > 8.0:
		vx = signf(vx) * maxf(absf(vx), minf(absf(vx) * 1.35 + 4.0, BONK_CAP))
	msg("쾅!", 0.35)
	beep(200.0, 0.14, 60.0, 0.45)
	beep(1300.0, 0.05, 700.0, 0.2)


func _wall_hit(dir: float) -> void:
	var sp := absf(vx)
	dash_t = 0.0
	if not on_floor and lv >= 6:
		vx = 0.0
		if grip <= 0.0:
			beep(330.0, 0.05, 0.0, 0.2)
			if sp > SLAM_V:
				shake = maxf(shake, 0.15)
		grip = 0.3
		return
	if sp > SLAM_V:
		stun = 0.3
		shake = maxf(shake, 0.3 + sp / 120.0)
		squash = 0.6
		vx = -dir * sp * 0.25
		msg("꽝!", 0.35)
		beep(110.0, 0.2, 45.0, 0.45)
		beep(800.0, 0.04, 0.0, 0.2)
	else:
		vx = 0.0


func _break(list: Array[Vector2i]) -> void:
	for k in list:
		if cracks.has(k):
			(cracks[k] as Node).queue_free()
			cracks.erase(k)
	shake = maxf(shake, 0.25)
	msg("와장창", 0.4)
	beep(900.0, 0.2, 150.0, 0.35)
	beep(300.0, 0.12, 80.0, 0.3)


func _check() -> void:
	var r := Rect2(px - PW * 0.5, py, PW, PH)
	if py < -2.0:
		_die("떨어짐")
		return
	for c in range(floori(r.position.x), floori(r.end.x) + 1):
		for yy in range(floori(py), floori(py + PH) + 1):
			if _ch(c, yy) == "^" and Rect2(c + 0.15, yy + 0.15, 0.7, 0.7).intersects(r):
				_die("가시")
				return
	if door.intersects(r):
		clear_t = 1.0
		vx = 0.0
		vy = 0.0
		play("win")
		msg("문!", 0.8)


func _die(why: String) -> void:
	die_t = 0.9
	body.material_override = mat(BAD)
	shake = maxf(shake, 0.4)
	play("bad")
	msg(why, 0.9)


func _sounds(h: float) -> void:
	step_t -= h
	if on_floor and absf(vx) > 3.0 and step_t <= 0.0:
		step_t = 0.06
		beep(120.0 + absf(vx) * 8.0, 0.03, 0.0, 0.1)


func _view(dt: float) -> void:
	me.position = Vector3(px, py, 0.0)
	var stretch := clampf(absf(vx) / 50.0, 0.0, 0.8)
	me.scale = Vector3(1.0 + stretch * 0.6 + squash * 0.4, 1.0 - squash * 0.45 - stretch * 0.2, 1.0)
	eye.position.x = face * 0.2
	for k in stars.size():
		stars[k].visible = stun > 0.0 and die_t <= 0.0
		var a := anim * 14.0 + k * PI
		stars[k].position = Vector3(cos(a) * 0.45, PH + 0.3, sin(a) * 0.45)
	# 빠를 때 남는 잔상
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.03
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = Vector2(vx, vy).length() > 14.0 and die_t <= 0.0
		tb.position = Vector3(px, py + PH * 0.5, -0.3)
		tb.scale = Vector3(PW, PH, 0.4)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	var k := 1.0 - exp(-9.0 * dt)
	cam_x = lerpf(cam_x, px + vx * 0.08, k)
	cam_y = lerpf(cam_y, py, k)
	shake = maxf(0.0, shake - dt * 1.5)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.8
	cam.position = Vector3(cam_x + off.x, cam_y - 2.2 + off.y, 17.0)
	cam.rotation = Vector3.ZERO
	cam.fov = lerpf(cam.fov, 56.0 + minf(Vector2(vx, vy).length(), 44.0) * 0.25, k)
