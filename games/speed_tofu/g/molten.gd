extends Tofu
## 식는 바위 (옆모습 3D): 용암 강 위로 바위가 떠오르고, 밟고 서 있으면 식어서 가라앉는다.
## 왼쪽 조이스틱 좌우(바닥이 미끄러워 바로 못 서고, 기울인 만큼이 속도), 오른쪽 점프(빠를수록 멀리). 빨리 밟고 넘어가되 다음 바위를 지나치지 않기.
## 뒤에서 용암 파도가 밀려와 되돌아갈 수 없다. 용암·파도에 닿으면 그 구간 기슭(깃발)부터 다시. 구간 3개: 틈이 넓어지고 바위가 빨리 식고 파도가 빨라진다.

const GRAV := 30.0
const JUMP_V := 9.5
const TOP := 11.0  # 스틱 끝까지
const LOW := 3.0  # 스틱 살짝
const ACC := 9.0  # 미끄러운 바닥: 붙는 것도 서는 것도 느리다
const BRAKE := 3.0  # 스틱을 놓아도 거의 안 선다
const AIR_ACC := 5.0
const PW := 0.7
const PH := 0.9
const ROCK_H := 1.3
const SHORE_W := 6.0
const SHORE_TOP := 0.7
const COOL_IDLE := 0.12  # 한 번 식기 시작한 바위는 내려와도 천천히 가라앉는다
# 구간: sink = 서 있을 때 식는 속도, wave = 파도 속도, rocks = [틈, 너비, 윗면 높이]
const SECTIONS := [
	{"name": "첫 걸음", "sink": 0.35, "wave": 3.0, "rocks": [
		[1.5, 3.0, 0.7], [1.8, 3.0, 0.7], [2.0, 2.5, 0.7], [2.2, 2.5, 0.7], [1.8, 3.0, 0.7], [2.5, 2.5, 0.7], [2.0, 2.0, 0.7],
		[2.8, 2.5, 0.7], [2.2, 2.0, 0.7], [3.0, 2.5, 0.7], [2.0, 2.0, 0.7], [3.2, 2.5, 0.7], [2.5, 2.0, 0.7], [3.5, 3.0, 0.7]]},
	{"name": "넓은 틈", "sink": 0.55, "wave": 3.8, "rocks": [
		[3.0, 2.5, 0.7], [3.5, 2.0, 0.7], [2.0, 1.5, 0.7], [4.0, 2.5, 0.7], [3.0, 2.0, 0.7], [4.5, 2.5, 0.7], [2.5, 1.5, 0.7], [3.5, 2.0, 0.7],
		[5.0, 2.5, 0.7], [2.0, 1.5, 0.7], [4.0, 2.0, 0.7], [3.0, 1.5, 0.7], [4.5, 2.0, 0.7], [5.0, 2.5, 0.7], [2.5, 1.5, 0.7], [4.0, 2.5, 0.7]]},
	{"name": "끓는 강", "sink": 0.8, "wave": 4.6, "rocks": [
		[2.5, 2.0, 0.7], [3.0, 1.5, 1.4], [3.5, 2.0, 0.7], [2.0, 1.2, 0.7], [4.5, 2.0, 1.2], [3.0, 1.5, 0.7], [5.0, 2.5, 0.7], [2.0, 1.2, 1.5], [3.5, 1.5, 0.7],
		[4.0, 2.0, 0.7], [2.5, 1.2, 1.2], [5.5, 2.5, 0.7], [3.0, 1.5, 0.7], [4.5, 2.0, 1.6], [2.0, 1.2, 0.7], [5.0, 2.0, 0.7], [3.5, 1.5, 1.0], [6.0, 3.0, 0.7]]},
]

var sec := 0
var cp_score := 0
var rocks: Array[Dictionary] = []
var shores: Array[Dictionary] = []  # 바위와 같은 모양의 발판 사전, shore=true
var wave_x := 0.0
var wave: Node3D
var px := 0.0  # 발 가운데
var py := 0.0
var vx := 0.0
var vy := 0.0
var on_plat: Dictionary = {}  # 서 있는 발판 ({}면 공중)
var face := 1.0
var cut := true
var jbuf := 0.0
var coyote := 0.0
var die_t := 0.0
var done_t := 0.0
var shake := 0.0
var squash := 0.0
var step_t := 0.0
var rumble_t := 0.0
var anim := 0.0
var cam_x := 0.0
var cam_y := 0.0
var trail_t := 0.0
var trail_k := 0
var end_x := 0.0
var me: Node3D
var body: MeshInstance3D
var eye: MeshInstance3D
var trail: Array[MeshInstance3D] = []
var bubbles: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 58.0
	howto = "왼쪽 조이스틱으로 좌우. 기울인 만큼이 속도인데 바닥이 미끄러워 바로 못 선다.\n오른쪽 점프. 빠를수록 멀리 뛴다.\n노란 바위는 밟고 서 있으면 식어서 가라앉는다. 빨리 밟고 넘어가되, 너무 빨라 다음 바위를 지나치면 용암행.\n뒤에서 용암 파도가 밀려온다. 용암에 빠지거나 파도에 잡히면 그 구간 깃발부터 다시. 구간 3개."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1100), 105.0, A)


func _reset() -> void:
	rocks.clear()
	shores.clear()
	trail.clear()
	bubbles.clear()
	var x := 0.0
	_shore(x)
	x += SHORE_W
	for s in SECTIONS.size():
		for r in SECTIONS[s].rocks:
			var gap: float = r[0]
			var w: float = r[1]
			var top: float = r[2]
			x += gap
			var n := box(Vector3(x + w * 0.5, -2.0, 0.0), Vector3(w, ROCK_H, 2.2), D)
			rocks.append({"x": x + w * 0.5, "w": w, "top": top, "sec": s, "node": n, "up": 0.0, "load": 0.0,
				"dead": false, "stepped": false, "hiss": false, "shore": false})
			x += w
		x += 3.0
		_shore(x)
		x += SHORE_W
	end_x = x
	# 용암 강, 뒤쪽 바위 기둥(속도감용)
	box(Vector3(end_x * 0.5, -1.0, 0.5), Vector3(end_x + 60.0, 2.0, 8.0), A)
	var k := 0
	var bx := -24.0
	while bx < end_x + 24.0:
		var hgt := 4.0 + float((k * 7) % 5) * 1.3
		box(Vector3(bx, hgt * 0.5 - 0.5, -5.0), Vector3(2.0 + float(k % 3), hgt, 2.0), SOFT)
		bx += 6.0
		k += 1
	for i in 8:
		bubbles.append(box(Vector3.ZERO, Vector3(0.35, 0.35, 0.35), D))
	# 파도: 앞면이 x=0
	wave = Node3D.new()
	world.add_child(wave)
	box(Vector3(-4.0, 1.6, 0.0), Vector3(8.0, 3.2, 3.0), BAD, wave)
	box(Vector3(-0.8, 3.3, 0.0), Vector3(2.4, 1.0, 2.6), A, wave)
	box(Vector3(0.2, 3.9, 0.0), Vector3(1.0, 0.5, 2.0), D, wave)
	# 나
	me = Node3D.new()
	world.add_child(me)
	body = box(Vector3(0, PH * 0.5, 0), Vector3(PW, PH, 0.7), ME, me)
	eye = box(Vector3(0.2, PH * 0.68, 0.36), Vector3(0.16, 0.16, 0.05), WHITE, me)
	for i in 5:
		var tb := box(Vector3.ZERO, Vector3(PW, PH, 0.4), B)
		tb.visible = false
		trail.append(tb)
	sec = 0
	cp_score = 0
	_spawn()


func _shore(x: float) -> void:
	box(Vector3(x + SHORE_W * 0.5, SHORE_TOP - 1.5, 0.0), Vector3(SHORE_W, 3.0, 2.6), WHITE)
	box(Vector3(x + 0.8, 2.0, -0.8), Vector3(0.15, 2.6, 0.15), INK)
	box(Vector3(x + 1.3, 3.0, -0.8), Vector3(0.9, 0.5, 0.1), GOOD)
	shores.append({"x": x + SHORE_W * 0.5, "w": SHORE_W, "x0": x, "top": SHORE_TOP, "idx": shores.size(),
		"up": 1.0, "load": 0.0, "dead": false, "shore": true})


## 구간 기슭에서 (다시) 시작. 이 구간 바위는 새것으로, 지난 구간 바위는 치운다
func _spawn() -> void:
	var s: Dictionary = shores[sec]
	px = float(s.x0) + 1.5
	py = SHORE_TOP
	vx = 0.0
	vy = 0.0
	on_plat = s
	face = 1.0
	die_t = 0.0
	jbuf = 0.0
	coyote = 0.0
	cut = true
	for r in rocks:
		if int(r.sec) == sec:
			r.up = 0.0
			r.load = 0.0
			r.dead = false
			r.stepped = false
			r.hiss = false
			r.node.visible = true
			r.node.position.y = -2.0
		elif int(r.sec) < sec:
			r.dead = true
			r.node.visible = false
	wave_x = float(s.x0) - 9.0
	score = cp_score
	cam_x = px + 3.0
	cam_y = 1.5
	body.material_override = mat(ME)
	msg("%d. %s" % [sec + 1, SECTIONS[sec].name], 1.2)


## 발판의 지금 윗면 높이: 떠오르는 중이면 낮고, 식은 만큼 가라앉는다
func _top(p: Dictionary) -> float:
	if p.shore:
		return float(p.top)
	return lerpf(-1.2, float(p.top), float(p.up)) - float(p.load) * (float(p.top) + 0.5)


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	anim += dt
	var S: Dictionary = SECTIONS[sec]
	if done_t > 0.0:
		done_t -= dt
		_view(dt)
		if done_t <= 0.0:
			end()
		return
	if die_t > 0.0:
		die_t -= dt
		_view(dt)
		if die_t <= 0.0:
			_spawn()
		return
	_control(h)
	_physics(h, S)
	_rocks(h)
	_wave(h, S)
	_check()
	_view(dt)
	var dist := px - wave_x
	gauge(clampf(dist / 16.0, 0.0, 1.0), BAD if dist < 5.0 else A)


func _control(h: float) -> void:
	var mx := kit_move.x
	if absf(mx) < 0.12:
		mx = 0.0
	if kit_just("jump"):
		jbuf = 0.12
	jbuf -= h
	coyote -= h
	squash = maxf(0.0, squash - h * 4.0)
	if mx != 0.0:
		face = signf(mx)
	var grounded := not on_plat.is_empty()
	if mx != 0.0:
		var target := signf(mx) * lerpf(LOW, TOP, absf(mx))
		var too_fast := signf(vx) == signf(target) and absf(vx) > absf(target)
		if grounded:
			vx = move_toward(vx, target, (ACC * 0.5 if too_fast else ACC) * h)
		else:
			vx = move_toward(vx, target, AIR_ACC * h)
	elif grounded:
		vx = move_toward(vx, 0.0, BRAKE * h)
	if jbuf > 0.0 and (grounded or coyote > 0.0):
		vy = JUMP_V
		on_plat = {}
		coyote = 0.0
		jbuf = 0.0
		cut = false
		beep(420.0, 0.1, 900.0, 0.22)
	# 일찍 떼면 낮게 뛴다
	if not cut and vy > 0.0 and not kit_held("jump"):
		vy *= 0.55
		cut = true
	step_t -= h
	if grounded and absf(vx) > 2.0 and step_t <= 0.0:
		step_t = clampf(1.6 / absf(vx), 0.08, 0.3)
		beep(120.0 + absf(vx) * 9.0, 0.03, 0.0, 0.1)


func _physics(h: float, S: Dictionary) -> void:
	if on_plat.is_empty():
		vy = maxf(vy - GRAV * h, -25.0)
	var ox := px
	var oy := py
	px += vx * h
	py += vy * h
	if not on_plat.is_empty():
		var p := on_plat
		var hw: float = float(p.w) * 0.5 + PW * 0.3
		if bool(p.dead) or px < float(p.x) - hw or px > float(p.x) + hw:
			on_plat = {}
			coyote = 0.1
			vy = 0.0
		else:
			py = _top(p)
			if not p.shore:
				p.load = float(p.load) + float(S.sink) * h
	# 발판: 떨어지며 윗면을 지나면 서고, 옆면에 박으면 선다(미끄러운 몸엔 치명적)
	for p in _plats():
		if bool(p.dead) or float(p.up) < 0.6:
			continue
		var top := _top(p)
		var l: float = float(p.x) - float(p.w) * 0.5
		var r: float = float(p.x) + float(p.w) * 0.5
		var inside := px + PW * 0.5 > l + 0.02 and px - PW * 0.5 < r - 0.02
		if not inside:
			continue
		if on_plat.is_empty() and vy <= 0.0 and oy >= top - 0.05 and py <= top:
			py = top
			vy = 0.0
			on_plat = p
			_land(p)
		elif py < top - 0.08 and py + PH > top - ROCK_H and not is_same(on_plat, p):
			px = l - PW * 0.5 - 0.01 if ox < float(p.x) else r + PW * 0.5 + 0.01
			if absf(vx) > 4.0:
				shake = maxf(shake, 0.2)
				msg("쿵", 0.3)
				beep(110.0, 0.12, 50.0, 0.3)
			vx = 0.0


## 가까운 발판만 (바위 + 기슭)
func _plats() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for r in rocks:
		if absf(float(r.x) - px) < float(r.w) + 3.0:
			out.append(r)
	for s in shores:
		if absf(float(s.x) - px) < float(s.w) + 3.0:
			out.append(s)
	return out


func _land(p: Dictionary) -> void:
	squash = maxf(squash, 0.35)
	cut = true
	beep(90.0, 0.06, 0.0, 0.2)
	if not p.shore:
		beep(1700.0, 0.08, 900.0, 0.12)  # 지글
		if not p.stepped:
			p.stepped = true
			score += 1


func _rocks(h: float) -> void:
	for r in rocks:
		if bool(r.dead):
			continue
		if float(r.up) < 1.0 and px > float(r.x) - 12.0:
			r.up = minf(1.0, float(r.up) + h * 1.6)
			if float(r.up) >= 1.0:
				beep(300.0, 0.06, 700.0, 0.1)
		if float(r.load) > 0.0 and not is_same(r, on_plat):
			r.load = float(r.load) + COOL_IDLE * h
		if float(r.load) >= 0.6 and not bool(r.hiss):
			r.hiss = true
			beep(2000.0, 0.15, 400.0, 0.15)
		var top := _top(r)
		if wave_x > float(r.x) + float(r.w) * 0.5 + 0.5 or (float(r.load) > 0.0 and top < 0.05):
			r.dead = true
			r.node.visible = false
			continue
		r.node.position.y = top - ROCK_H * 0.5
		var ld: float = r.load
		r.node.material_override = mat(D if ld < 0.3 else (SOFT if ld < 0.65 else WHITE))


func _wave(h: float, S: Dictionary) -> void:
	wave_x += float(S.wave) * h
	wave_x = maxf(wave_x, px - 22.0)  # 아무리 빨라도 파도는 시야 끝에서 따라온다
	wave.position = Vector3(wave_x, sin(anim * 6.0) * 0.15, 0.0)
	var dist := px - wave_x
	rumble_t -= h
	if dist < 12.0 and rumble_t <= 0.0:
		rumble_t = 0.45
		beep(55.0, 0.3, 35.0, 0.12 + (1.0 - dist / 12.0) * 0.2)
	if dist < 7.0:
		shake = maxf(shake, (7.0 - dist) / 7.0 * 0.25)


func _check() -> void:
	if py < -0.15:
		_die("용암!")
	elif wave_x >= px - 0.2:
		_die("파도!")
	elif not on_plat.is_empty() and bool(on_plat.shore) and int(on_plat.idx) == sec + 1:
		if sec + 1 >= SECTIONS.size():
			done_t = 1.3
			vx = 0.0
			msg("건넜다!", 1.3)
			play("win")
		else:
			sec += 1
			cp_score = score
			wave_x = minf(wave_x, float(shores[sec].x0) - 9.0)
			msg("%d. %s" % [sec + 1, SECTIONS[sec].name], 1.4)
			play("good")


func _die(why: String) -> void:
	die_t = 1.1
	vx = 0.0
	vy = 0.0
	body.material_override = mat(BAD)
	shake = maxf(shake, 0.4)
	play("bad")
	msg(why, 1.0)


func _view(dt: float) -> void:
	me.position = Vector3(px, py, 0.0)
	var stretch := clampf(absf(vx) / 30.0, 0.0, 0.5)
	me.scale = Vector3(1.0 + stretch * 0.5 + squash * 0.4, 1.0 - squash * 0.45 - stretch * 0.2, 1.0)
	eye.position.x = face * 0.2
	# 빠를 때 잔상
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.04
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = absf(vx) > 7.0 and die_t <= 0.0
		tb.position = Vector3(px, py + PH * 0.5, -0.3)
		tb.scale = Vector3(PW, PH, 0.4)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	# 용암 거품: 카메라 근처를 돌려 쓴다
	for i in bubbles.size():
		var b := bubbles[i]
		var ph := fposmod(anim * 2.0 + i * 1.7, 2.0)
		var bx := cam_x - 10.0 + fposmod(i * 2.9 + anim * 0.7, 20.0)
		b.position = Vector3(bx, -0.2 + ph * 0.5, 0.8)
		b.visible = ph < 1.4
	# 카메라: 앞을 보고, 빠르면 더 앞·더 넓게
	var k := 1.0 - exp(-8.0 * dt)
	cam_x = lerpf(cam_x, px + 2.5 + vx * 0.12, k)
	cam_y = lerpf(cam_y, 1.5 + py * 0.4, k)
	shake = maxf(0.0, shake - dt * 1.5)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.8
	cam.position = Vector3(cam_x + off.x, cam_y + off.y, 18.0)
	cam.rotation = Vector3.ZERO
	cam.fov = lerpf(cam.fov, 56.0 + minf(absf(vx), 14.0) * 0.5, k)
