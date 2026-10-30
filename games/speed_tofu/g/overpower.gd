extends Tofu
## 너무 센 몸 (옆모습 플랫포머): 왼쪽 아래 조이스틱으로 좌우(끝까지 밀면 전력 질주), 오른쪽 버튼으로 점프(늘 천장에 쾅, 달리던 중이면 옆으로 더 빨라진다).
## 핵심 규칙: 속도 = 몸의 모양. 빨라질수록 몸 상자가 옆으로 늘어나고 납작해진다(보이는 상자 = 충돌 상자).
## 낮은 복도는 빨라야 지나가고(안에서 느려지면 끼여 죽음), 좁은 세로 틈은 느려야 빠져나가며, 작은 구덩이는 긴 몸이 다리처럼 걸친다. 가시 천장 아래는 납작할 때만 안전. 방 8개.
# 한 문장: 나는 너무 센 몸으로서 속도가 곧 몸의 모양이 되는 제약 속에서 달려 문에 닿지만, 빨라질수록 길고 납작해져 틈에 걸리고 느려지면 낮은 길에 끼이는 대가를 감수한다.

const GRAV := 45.0
const JUMP_V := 24.0  # 꼭대기까지 6칸 넘게: 거의 모든 방에서 천장에 박는다
const SPRINT := 26.0  # 스틱을 0.7 넘게 밀면 이 속도 (몸이 납작해지는 유일한 달리기)
const JOG := 14.0  # 그 아래는 기울기에 비례해 최고 이 속도 (몸이 좁다)
const STICK_RUN := 0.7
const GROUND_ACC := 90.0
const AIR_ACC := 30.0
const FRICTION := 35.0  # 손을 떼면 미끄러진다: 26에서 0까지 약 10칸
const MAX_FALL := 30.0
const BONK_CAP := 34.0
const SLAM_V := 12.0
const VMAX := 30.0  # 몸 모양이 끝까지 늘어나는 속도
const W0 := 0.9  # 서 있을 때 몸: 0.9 x 1.8
const W1 := 2.7  # 최고속 몸: 2.7 x 0.72 (3배 길고 0.4배 납작)
const H0 := 1.8
const H1 := 0.72
const EPS := 0.0001
const WALLC := Color("d9c39a")
# 방: 위 줄부터. # 벽, ^ 가시, S 시작, D 문(2칸 높이). 몸은 서면 2칸 가까이 크고 질주하면 1칸보다 납작, 3칸 가까이 길다.
# 1칸 높이 복도 = 질주해야 통과. 2칸 폭 구멍 = 걸어야 빠진다(질주하면 다리처럼 걸쳐 지나감).
const ROOMS := [
	{"name": "낮은 복도", "map": [
		"##############################",
		"#          ###########       #",
		"#          ###########       #",
		"#          ###########       #",
		"#          ###########       #",
		"#          ###########       #",
		"# S                       D  #",
		"##############################",
	]},
	{"name": "좁은 틈", "map": [
		"##############",
		"#            #",
		"#            #",
		"#            #",
		"# S          #",
		"#######  #####",
		"#######  #####",
		"#######  #####",
		"#            #",
		"#          D #",
		"##############",
	]},
	{"name": "빨리, 느리게, 빨리", "map": [
		"##########################",
		"#        ########        #",
		"#        ########        #",
		"#        ########        #",
		"#        ########        #",
		"# S                      #",
		"#################  #######",
		"#################  #######",
		"#    ##########          #",
		"#    ##########          #",
		"#    ##########          #",
		"# D                      #",
		"##########################",
	]},
	{"name": "구덩이 다리", "map": [
		"######################################",
		"#                                    #",
		"#                                    #",
		"# S                                D #",
		"########  #####  ########       ######",
		"########^^#####^^########^^^^^^^######",
		"######################################",
	]},
	{"name": "가시 천장", "map": [
		"######################",
		"#                    #",
		"#                  D #",
		"#################  ###",
		"#################  ###",
		"#################  ###",
		"#      ##########    #",
		"#      ^^^^^^^^^^    #",
		"# S                  #",
		"######################",
	]},
	{"name": "급정지", "map": [
		"####################################",
		"#      #############################",
		"#      #############################",
		"#      #############################",
		"#      ####################        #",
		"#      ####################       ^#",
		"# S                               ^#",
		"#############################  #####",
		"#############################  #####",
		"#                                  #",
		"#                           D      #",
		"####################################",
	]},
	{"name": "전부 섞어", "map": [
		"######################################",
		"#     ################################",
		"#     ################################",
		"#     ################################",
		"#     ###############               ^#",
		"# S                                 ^#",
		"#######################  ###  ###  ###",
		"#######################^^###^^###  ###",
		"#################################  ###",
		"#     ^^^^^^^^^^^^^^^^^^^^^^         #",
		"# D                                  #",
		"######################################",
	]},
	{"name": "되돌아오기", "map": [
		"##############################",
		"#     ########################",
		"#     ########################",
		"#     ########################",
		"#                            #",
		"# S                          #",
		"#########  ###  ####  ########",
		"#########^^###^^####  ########",
		"####################  ########",
		"####################  ########",
		"#                            #",
		"# D                          #",
		"##############################",
	]},
]

var lv := 0
var stage: Node3D
var grid: Array[String] = []
var rows := 0
var cols := 0
var door := Rect2()
var px := 0.0  # 발 가운데
var py := 0.0
var vx := 0.0
var vy := 0.0
var bw := W0  # 지금 몸 크기 (보이는 상자 = 충돌 상자)
var bh := H0
var flat := false
var on_floor := false
var coyote := 0.0
var jbuf := 0.0
var cut := true
var stun := 0.0
var hang := 0.0
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
var me: Node3D
var body: MeshInstance3D
var eye: MeshInstance3D
var stars: Array[MeshInstance3D] = []
var trail: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 58.0
	howto = "왼쪽 아래 조이스틱으로 좌우. 끝까지 밀면 전력 질주. 오른쪽 버튼은 점프(늘 천장에 쾅, 달리던 중이면 더 빨라진다).\n빨라지면 몸이 옆으로 늘어나 납작해진다. 낮은 길은 빨리, 좁은 틈은 느리게. 작은 구덩이는 긴 몸으로 걸쳐 건넌다.\n낮은 길 안에서 느려지면 끼여 죽는다. 가시·구덩이 바닥도 죽음. 초록 문에 닿으면 다음 방."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1100), 105.0, A)


func _reset() -> void:
	lv = 0
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
			if ch == "^":
				var sp := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.55, 0.55, 1.2), BAD, stage)
				sp.rotation.z = PI * 0.25
			elif ch == "S":
				start = Vector2(c + 0.5, yy)
			elif ch == "D":
				door = Rect2(c, yy, 1.0, 2.0)
				box(Vector3(c + 0.5, yy + 1.0, -0.6), Vector3(1.1, 2.0, 0.6), GOOD, stage)
				box(Vector3(c + 0.75, yy + 1.0, -0.2), Vector3(0.15, 0.15, 0.2), D, stage)
	# 바닥 눈금: 위가 빈 벽 칸마다 하나씩 (속도감 단서)
	for r in rows:
		var yy := rows - 1 - r
		for c in cols:
			if (c % 2 == 0) and _solid(c, yy) and not _solid(c, yy + 1) and _ch(c, yy + 1) != "^" and yy + 1 < rows:
				box(Vector3(c + 0.5, yy + 0.86, 1.02), Vector3(0.14, 0.28, 0.06), SOFT, stage)
	# 나
	me = Node3D.new()
	stage.add_child(me)
	body = box(Vector3(0, H0 * 0.5, 0), Vector3(W0, H0, 0.7), ME, me)
	eye = box(Vector3(0.2, H0 * 0.68, 0.36), Vector3(0.16, 0.16, 0.05), WHITE, me)
	stars.clear()
	for k in 2:
		var s := box(Vector3.ZERO, Vector3(0.2, 0.2, 0.2), D, me)
		s.visible = false
		stars.append(s)
	trail.clear()
	for k in 6:
		var tb := box(Vector3.ZERO, Vector3(W0, H0, 0.4), B, stage)
		tb.visible = false
		trail.append(tb)
	px = start.x
	py = start.y
	vx = 0.0
	vy = 0.0
	bw = W0
	bh = H0
	flat = false
	on_floor = true
	coyote = 0.0
	jbuf = 0.0
	cut = true
	stun = 0.0
	hang = 0.0
	face = 1.0
	die_t = 0.0
	clear_t = 0.0
	squash = 0.0
	cam_x = px
	cam_y = py
	msg("%d. %s" % [i + 1, ROOMS[i].name], 1.2)


# ---- 칸 ----
func _ch(c: int, yy: int) -> String:
	if c < 0 or c >= cols or yy >= rows:
		return "#"
	if yy < 0:
		return " "
	return grid[rows - 1 - yy][c]


func _solid(c: int, yy: int) -> bool:
	return _ch(c, yy) == "#"


func _x0() -> int:
	return floori(px - bw * 0.5 + EPS)


func _x1() -> int:
	return floori(px + bw * 0.5 - EPS)


func _y0() -> int:
	return floori(py + EPS)


func _y1() -> int:
	return floori(py + bh - EPS)


## 몸 폭 아래 어딘가 바닥이 있으면 서 있다 (긴 몸은 작은 구덩이에 걸친다)
func _ground() -> bool:
	var yy := floori(py - 0.02)
	for c in range(_x0(), _x1() + 1):
		if _solid(c, yy):
			return true
	return false


func _col_solid(c: int, y0: int, y1: int) -> bool:
	for yy in range(y0, y1 + 1):
		if _solid(c, yy):
			return true
	return false


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
	_shape(h)
	if die_t > 0.0:
		_view(dt)
		return
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
	jbuf -= h
	coyote -= h
	stun -= h
	squash = maxf(0.0, squash - h * 4.0)
	if mx != 0.0 and stun <= 0.0:
		face = signf(mx)
	if stun <= 0.0:
		var target := 0.0
		if mx != 0.0:
			target = signf(mx) * (SPRINT if absf(mx) >= STICK_RUN else JOG * absf(mx) / STICK_RUN)
		var too_fast := mx != 0.0 and signf(vx) == signf(target) and absf(vx) > absf(target)
		if on_floor:
			if mx == 0.0:
				vx = move_toward(vx, 0.0, FRICTION * h)
			elif too_fast:
				vx = move_toward(vx, target, FRICTION * h)
			else:
				vx = move_toward(vx, target, GROUND_ACC * h)
		elif mx != 0.0 and not too_fast:
			vx = move_toward(vx, target, AIR_ACC * h)
	elif on_floor:
		vx = move_toward(vx, 0.0, FRICTION * h)
	if jbuf > 0.0 and stun <= 0.0 and (on_floor or coyote > 0.0):
		_jump()
	# 일찍 떼도 아주 조금만 낮아진다
	if not cut and vy > 0.0 and not kit_held("jump"):
		vy *= 0.93
		cut = true


func _jump() -> void:
	vy = JUMP_V
	on_floor = false
	coyote = 0.0
	jbuf = 0.0
	cut = false
	beep(420.0, 0.1, 1000.0, 0.24)


## 속도 = 몸의 모양. 빠를수록 옆으로 길고 납작. 새 모양이 벽에 겹치면 옆은 밀려나고 머리가 박히면 끼인다.
func _shape(h: float) -> void:
	var s := clampf(absf(vx) / VMAX, 0.0, 1.0)
	var tw := lerpf(W0, W1, pow(s, 1.5))  # 폭은 질주(~22 이상)부터 2칸을 넘는다
	var th := lerpf(H0, H1, s)  # 높이는 22 넘으면 1칸 아래로
	var k := 1.0 - exp(-30.0 * h)
	bw = lerpf(bw, tw, k)
	bh = lerpf(bh, th, k)
	var now := bh < 1.0
	if now != flat:
		flat = now
		if flat:
			beep(500.0, 0.1, 1100.0, 0.22)
		else:
			beep(1100.0, 0.1, 500.0, 0.18)
	# 옆이 벽에 겹치면 밀려난다
	var y0 := _y0()
	var y1 := _y1()
	if _col_solid(_x0(), y0, y1):
		px = _x0() + 1.0 + bw * 0.5 + 0.001
		if _col_solid(_x1(), y0, y1):
			_die("끼임")
			return
	elif _col_solid(_x1(), y0, y1):
		px = _x1() - bw * 0.5 - 0.001
		if _col_solid(_x0(), y0, y1):
			_die("끼임")
			return
	# 머리가 천장에 박히면 끼인다 (낮은 복도 안에서 느려졌을 때)
	for c in range(_x0(), _x1() + 1):
		if _solid(c, y1):
			_die("끼임")
			return


func _physics(h: float) -> void:
	if hang > 0.0:
		hang -= h
		vy = 0.0
	else:
		vy = maxf(vy - GRAV * h, -MAX_FALL)
	for i in 4:
		_move_x(vx * h * 0.25)
		_move_y(vy * h * 0.25)
	var was := on_floor
	on_floor = vy <= 0.0 and _ground()
	if on_floor:
		coyote = 0.08
		if not was:
			squash = maxf(squash, 0.35)
			beep(90.0, 0.06, 0.0, 0.2)


func _move_x(d: float) -> void:
	if d == 0.0:
		return
	px += d
	var c := _x1() if d > 0.0 else _x0()
	if not _col_solid(c, _y0(), _y1()):
		return
	px = c - bw * 0.5 - 0.001 if d > 0.0 else c + 1.0 + bw * 0.5 + 0.001
	_wall_hit(signf(d))


func _move_y(d: float) -> void:
	if d == 0.0:
		return
	py += d
	var r := _y1() if d > 0.0 else floori(py)
	var hit := false
	for c in range(_x0(), _x1() + 1):
		if _solid(c, r):
			hit = true
			break
	if not hit:
		return
	if d > 0.0:
		py = r - bh - 0.001
		_bonk()
	else:
		py = r + 1.0
		vy = 0.0


## 천장에 박기: 어질, 잠깐 붙었다가 떨어진다. 달리던 중이면 옆으로 더 빨라진다 (= 더 길고 납작해진다)
func _bonk() -> void:
	var sp := vy
	vy = 0.0
	if sp < 3.0:
		return
	hang = 0.08
	stun = 0.18
	shake = maxf(shake, 0.3)
	squash = 0.7
	if absf(vx) > 8.0:
		vx = signf(vx) * maxf(absf(vx), minf(absf(vx) * 1.35 + 4.0, BONK_CAP))
	msg("쾅!", 0.35)
	beep(200.0, 0.14, 60.0, 0.45)
	beep(1300.0, 0.05, 700.0, 0.2)


## 옆으로 박기: 빠르면 꽝 하고 기절해 튕겨 나온다 (긴 몸이 틈에 걸릴 때, 키 큰 몸이 낮은 복도 입구를 들이받을 때)
func _wall_hit(dir: float) -> void:
	var sp := absf(vx)
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


func _check() -> void:
	if die_t > 0.0:
		return
	var r := Rect2(px - bw * 0.5, py, bw, bh)
	if py < -2.0:
		_die("떨어짐")
		return
	for c in range(floori(r.position.x), floori(r.end.x) + 1):
		for yy in range(floori(py), floori(py + bh) + 1):
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
	if die_t > 0.0:
		return
	die_t = 0.9
	body.material_override = mat(BAD)
	shake = maxf(shake, 0.4)
	play("bad")
	msg(why, 0.9)


## 발소리: 빠를수록 박자가 빨라지고 높아진다
func _sounds(h: float) -> void:
	step_t -= h
	if on_floor and absf(vx) > 3.0 and step_t <= 0.0:
		step_t = clampf(2.2 / absf(vx), 0.05, 0.3)
		beep(120.0 + absf(vx) * 8.0, 0.03, 0.0, 0.1)


func _view(dt: float) -> void:
	me.position = Vector3(px, py, 0.0)
	me.scale = Vector3(1.0 + squash * 0.3, 1.0 - squash * 0.3, 1.0)
	body.scale = Vector3(bw, bh, 0.7)
	body.position.y = bh * 0.5
	eye.position = Vector3(face * bw * 0.3, bh * 0.68, 0.36)
	eye.scale = Vector3(0.16, minf(0.16, bh * 0.2), 0.05)
	for k in stars.size():
		stars[k].visible = stun > 0.0 and die_t <= 0.0
		var a := anim * 14.0 + k * PI
		stars[k].position = Vector3(cos(a) * 0.45, bh + 0.3, sin(a) * 0.45)
	# 빠를 때 남는 잔상 (늘어난 몸 모양 그대로)
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.03
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = Vector2(vx, vy).length() > 14.0 and die_t <= 0.0
		tb.position = Vector3(px, py + bh * 0.5, -0.3)
		tb.scale = Vector3(bw, bh, 0.4)
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
