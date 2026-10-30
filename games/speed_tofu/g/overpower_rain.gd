extends Tofu
## 너무 센 몸으로 살금살금 (옆모습 플랫포머): 스틱 살짝 = 걷기(느리고 조용), 끝까지 = 뛰기(총알처럼 빠르고 발소리가 난다). 점프는 늘 너무 세서 낮은 천장에 쾅(큰 소리).
## 도마뱀 방: 소리를 듣거나 나를 보면 쫓아와 문다(걷거나 가만히 있으면 코앞에서만 보인다, 높은 곳은 안 보인다).
## 비 방: 게이지가 다 되기 전에 문까지 전력으로 달려야 한다. 두 방이 번갈아 오다가 뒤에선 섞인다. 목숨 3개, 죽으면 그 방부터.

const GRAV := 45.0
const JUMP_V := 24.0  # 꼭대기까지 6칸 넘게: 낮은 방에선 늘 천장에 박는다
const WALK := 3.2  # 살짝 기울임
const RUN_LO := 16.0  # 끝까지 기울임
const RUN_HI := 22.0
const GROUND_ACC := 90.0
const AIR_ACC := 30.0
const FRICTION := 60.0
const MAX_FALL := 30.0
const BONK_CAP := 34.0
const SLAM_V := 12.0
const LWALK := 2.2
const LRUN := 13.0  # 뛰는 나(16~22)보다 느리고 걷는 나보다 훨씬 빠르다
const PW := 0.7
const PH := 0.9
const EPS := 0.0001
const NRAIN := 36
const LIVES := 3
const WALLC := Color("d9c39a")
# 방: 위 줄부터. # 벽, ^ 가시, S 시작, D 문(2칸 높이), L 도마뱀(그 줄의 바닥을 왔다 갔다). rain 초가 0이면 도마뱀 방.
const ROOMS := [
	{"name": "비 온다", "rain": 7.0, "map": [
		"##########################################",
		"#                                        #",
		"#                                        #",
		"#                                        #",
		"#                                        #",
		"#                                        #",
		"#                                        #",
		"# S                                   D  #",
		"#######   ##########    ########   #######",
		"#######^^^##########^^^^########^^^#######",
	]},
	{"name": "살금살금", "rain": 0.0, "map": [
		"####################################",
		"####################################",
		"#                                  #",
		"#                                  #",
		"#         ##           ##          #",
		"#         ##           ##          #",
		"# S       ##   L        ##      D  #",
		"####################################",
	]},
	{"name": "낮은 비", "rain": 9.0, "map": [
		"############################################",
		"#          #######          ##############",
		"#          #######          ##############",
		"#          #######          ##############",
		"#                                          #",
		"# S                                    D  #",
		"######   ########   #######   #############",
		"######^^^########^^^#######^^^#############",
	]},
	{"name": "둘", "rain": 0.0, "map": [
		"########################################",
		"########################################",
		"#                                      #",
		"#                                      #",
		"#      ###                             #",
		"#      ###          ###                #",
		"#      ###          ###        ###     #",
		"# S    ###   L      ###   L    ###  D  #",
		"########################################",
	]},
	{"name": "비 속의 도마뱀", "rain": 9.0, "map": [
		"##############################################",
		"#                                            #",
		"#                                            #",
		"#            ####                            #",
		"#            ####                            #",
		"#            ####                            #",
		"# S     L    ####       L                D   #",
		"#####   #####################   ##############",
		"#####^^^#####################^^^##############",
	]},
	{"name": "셋", "rain": 0.0, "map": [
		"########################################",
		"########################################",
		"#                                      #",
		"#                        L             #",
		"#      ##                ##            #",
		"#      ##                ##            #",
		"# S    ##  L             ##    L    D  #",
		"########################################",
	]},
	{"name": "끝까지", "rain": 10.0, "map": [
		"##################################################",
		"#                 ########                       #",
		"#                 ########                       #",
		"#                 ########                       #",
		"#        L                                       #",
		"# S     ###   ##           ###     ###   L    D  #",
		"#####   ###   ##########   ###     ###############",
		"#####^^^###^^^##########^^^###^^^^^###############",
	]},
]


class Liz:
	var root: Node3D
	var body: MeshInstance3D
	var head: MeshInstance3D
	var x := 0.0
	var y := 0.0
	var dir := 1.0
	var lo := 0.0
	var hi := 0.0
	var st := 0  # 0 어슬렁, 1 소리 듣고 감, 2 쫓음
	var tt := 0.0
	var tgt := 0.0
	var pause := 0.0
	var roar := 0.0


var rng := RandomNumberGenerator.new()
var lv := 0
var lives := LIVES
var stage: Node3D
var grid: Array[String] = []
var rows := 0
var cols := 0
var door := Rect2()
var rain_max := 0.0
var rain_t := 0.0
var warn := 99
var alert := 0.0
var px := 0.0  # 발 가운데
var py := 0.0
var vx := 0.0
var vy := 0.0
var on_floor := false
var sneak := false
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
var rain: Array[MeshInstance3D] = []
var lizards: Array[Liz] = []


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 58.0
	howto = "왼쪽 아래 조이스틱 살짝 = 걷기(조용). 끝까지 = 뛰기(엄청 빠르고 발소리가 난다). 점프는 늘 너무 세서 낮은 천장에 쾅, 그것도 소리.\n빨간 도마뱀은 소리를 듣거나 나를 보면 쫓아와 문다. 걷거나 가만히 있으면 코앞에서만 보인다. 높은 기둥 위는 안 보인다.\n파란 게이지가 있는 방은 비가 온다. 다 되기 전에 초록 문까지 달려라.\n가시·구덩이·도마뱀·비 = 죽음. 목숨 3개, 죽으면 그 방부터."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1100), 105.0, A)


func _reset() -> void:
	rng.randomize()
	lv = 0
	lives = LIVES
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
	lizards.clear()
	rain.clear()
	var start := Vector2(2.5, 2.0)
	var lpos: Array[Vector2i] = []
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
			elif ch == "L":
				lpos.append(Vector2i(c, yy))
	# 도마뱀: 자기 줄에서 바닥이 이어진 만큼만 왔다 갔다 한다
	for p in lpos:
		var lz := Liz.new()
		var lo := p.x
		while lo - 1 >= 0 and not _solid(lo - 1, p.y) and _solid(lo - 1, p.y - 1):
			lo -= 1
		var hi := p.x
		while hi + 1 < cols and not _solid(hi + 1, p.y) and _solid(hi + 1, p.y - 1):
			hi += 1
		lz.lo = lo + 0.7
		lz.hi = hi + 0.3
		lz.x = p.x + 0.5
		lz.y = float(p.y)
		lz.dir = -1.0 if rng.randf() < 0.5 else 1.0
		lz.pause = rng.randf_range(0.3, 1.2)
		lz.root = Node3D.new()
		stage.add_child(lz.root)
		lz.body = box(Vector3(0.0, 0.3, 0.0), Vector3(1.3, 0.5, 0.5), BAD, lz.root)
		lz.head = box(Vector3(0.8, 0.45, 0.0), Vector3(0.5, 0.4, 0.45), BAD, lz.root)
		lizards.append(lz)
	# 비
	rain_max = float(ROOMS[i].rain)
	rain_t = rain_max
	warn = 99
	if rain_max > 0.0:
		for k in NRAIN:
			var rb := box(Vector3(0.0, -50.0, 1.0), Vector3(0.07, 0.9, 0.07), B, stage)
			rb.visible = false
			rain.append(rb)
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
	sneak = true
	coyote = 0.0
	jbuf = 0.0
	cut = true
	stun = 0.0
	hang = 0.0
	face = 1.0
	die_t = 0.0
	clear_t = 0.0
	squash = 0.0
	alert = 0.0
	cam_x = px
	cam_y = py
	if rain_max > 0.0:
		msg("%d. %s — 달려!" % [i + 1, ROOMS[i].name], 1.4)
	else:
		msg("%d. %s — 조용히" % [i + 1, ROOMS[i].name], 1.4)


# ---- 칸 ----
func _ch(c: int, yy: int) -> String:
	if c < 0 or c >= cols or yy >= rows:
		return "#"
	if yy < 0:
		return " "
	return grid[rows - 1 - yy][c]


func _solid(c: int, yy: int) -> bool:
	return _ch(c, yy) == "#"


func _ground() -> bool:
	var yy := floori(py - 0.02)
	for c in range(floori(px - PW * 0.5 + EPS), floori(px + PW * 0.5 - EPS) + 1):
		if _solid(c, yy):
			return true
	return false


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	anim += dt
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
				msg("끝!", 2.0)
				end()
			else:
				_room(lv)
		return
	_control(h)
	_physics(h)
	_check()
	if die_t > 0.0 or clear_t > 0.0:
		_view(dt)
		return
	_lizards(dt)
	_weather(dt)
	_sounds(h)
	_view(dt)


func _control(h: float) -> void:
	var mx := kit_move.x
	var amt := absf(mx)
	if amt < 0.12:
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
			target = signf(mx) * (WALK if amt < 0.65 else lerpf(RUN_LO, RUN_HI, (amt - 0.65) / 0.35))
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
	elif on_floor:
		vx = move_toward(vx, 0.0, FRICTION * h)
	if jbuf > 0.0 and stun <= 0.0 and (on_floor or coyote > 0.0):
		vy = JUMP_V
		on_floor = false
		coyote = 0.0
		jbuf = 0.0
		cut = false
		_noise(px, py, 3.0)
		beep(420.0, 0.1, 1000.0, 0.24)
	# 일찍 떼도 아주 조금만 낮아진다
	if not cut and vy > 0.0 and not kit_held("jump"):
		vy *= 0.93
		cut = true


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
			_noise(px, py, 6.0 if absf(vx) > 8.0 else 2.0)
	sneak = on_floor and absf(vx) < WALK + 1.0


func _move_x(d: float) -> void:
	if d == 0.0:
		return
	px += d
	var c := floori(px + PW * 0.5 - EPS) if d > 0.0 else floori(px - PW * 0.5 + EPS)
	var hit := false
	for yy in range(floori(py + EPS), floori(py + PH - EPS) + 1):
		if _solid(c, yy):
			hit = true
	if not hit:
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
	for c in range(x0, x1 + 1):
		if _solid(c, r):
			hit = true
	if not hit:
		return
	if d > 0.0:
		py = r - PH - 0.001
		_bonk()
	else:
		py = r + 1.0
		vy = 0.0


## 천장에 박기: 어질, 잠깐 붙었다가 떨어진다. 달리던 중이면 옆으로 더 빨라진다. 소리가 크다
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
	_noise(px, py, 10.0)


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
		_noise(px, py, 10.0)
	else:
		vx = 0.0


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
	if die_t > 0.0 or clear_t > 0.0:
		return
	lives -= 1
	die_t = 0.9
	body.material_override = mat(BAD)
	shake = maxf(shake, 0.4)
	play("bad")
	if lives <= 0:
		msg("%s… 끝" % why, 1.5)
		end()
	else:
		msg("%s (남은 목숨 %d)" % [why, lives], 0.9)


# ---- 도마뱀 ----
## 소리: 반지름 안의 (같은 층 근처) 도마뱀이 그쪽으로 온다
func _noise(x: float, y: float, r: float) -> void:
	for lz in lizards:
		if lz.st <= 1 and absf(lz.x - x) < r and absf(lz.y - y) < 5.0:
			if lz.st == 0:
				beep(240.0, 0.15, 160.0, 0.2)
				msg("?", 0.4)
			lz.st = 1
			lz.tgt = clampf(x, lz.lo, lz.hi)
			lz.tt = 0.0


func _lizards(dt: float) -> void:
	var want := 0.0
	for lz in lizards:
		var dx := px - lz.x
		var dy := py - lz.y
		var near := absf(dy) < 1.5
		match lz.st:
			0:
				if lz.pause > 0.0:
					lz.pause -= dt
				else:
					lz.x += lz.dir * LWALK * dt
					if lz.x >= lz.hi:
						lz.x = lz.hi
						lz.dir = -1.0
						lz.pause = rng.randf_range(0.6, 1.6)
					elif lz.x <= lz.lo:
						lz.x = lz.lo
						lz.dir = 1.0
						lz.pause = rng.randf_range(0.6, 1.6)
			1:
				want = maxf(want, 0.5)
				if absf(lz.x - lz.tgt) > 0.3:
					lz.dir = signf(lz.tgt - lz.x)
					lz.x = clampf(lz.x + lz.dir * LWALK * 2.0 * dt, lz.lo, lz.hi)
				else:
					lz.tt += dt
					lz.dir = 1.0 if fmod(lz.tt, 1.4) < 0.7 else -1.0  # 두리번
					if lz.tt > 2.4:
						lz.st = 0
			2:
				want = 1.0
				if dx != 0.0:
					lz.dir = signf(dx)
				lz.x = clampf(lz.x + lz.dir * LRUN * dt, lz.lo, lz.hi)
				lz.roar -= dt
				if lz.roar <= 0.0:
					lz.roar = 0.45
					beep(180.0, 0.12, 120.0, 0.22)
				if absf(dx) < 0.8 and absf(dy) < 1.2:
					_die("물렸다")
					return
				if absf(dx) > 14.0:
					lz.st = 0
				elif not near or ((lz.x == lz.lo or lz.x == lz.hi) and absf(dx) > 1.0):
					lz.tt += dt  # 못 닿는 곳: 잠깐 노려보다 포기
					if lz.tt > 2.5:
						lz.st = 1
						lz.tgt = lz.x
						lz.tt = 0.0
				else:
					lz.tt = 0.0
		# 눈: 앞쪽. 걷거나 서 있으면 코앞에서만, 바로 옆은 어디든. 다른 층은 안 보인다
		if lz.st <= 1 and near:
			var see := absf(dx) < 1.2 or (dx * lz.dir > 0.0 and absf(dx) < (3.0 if sneak else 9.0))
			if see:
				lz.st = 2
				lz.tt = 0.0
				lz.roar = 0.0
				msg("들켰다!", 0.5)
				beep(320.0, 0.2, 200.0, 0.3)
		lz.root.position = Vector3(lz.x, lz.y, 0.0)
		lz.head.position = Vector3(lz.dir * 0.8, 0.7 if lz.st >= 1 else 0.45, 0.0)
		lz.body.scale = Vector3(1.6 if lz.st == 2 else 1.3, 0.5, 0.5)
	alert = lerpf(alert, want, 1.0 - exp(-6.0 * dt))


# ---- 비 ----
func _weather(dt: float) -> void:
	if rain_max <= 0.0:
		gauge(alert, BAD)
		return
	rain_t -= dt
	var rf := rain_t / rain_max
	gauge(rf, B if rf > 0.3 else BAD)
	if rain_t < 5.0 and ceili(rain_t) != warn:
		warn = ceili(rain_t)
		beep(150.0, 0.15, 100.0, 0.25)
		if warn == 5:
			msg("비 온다!", 0.8)
	var n := 0 if rain_t > 3.0 else int(NRAIN * (1.0 - rain_t / 3.0))
	for i in NRAIN:
		var rb := rain[i]
		if i >= n:
			rb.visible = false
			continue
		if not rb.visible:
			rb.visible = true
			rb.position = Vector3(cam_x + rng.randf_range(-9.0, 9.0), cam_y + rng.randf_range(2.0, 12.0), 1.0)
		rb.position.y -= 18.0 * dt
		if rb.position.y < cam_y - 4.0:
			rb.position = Vector3(cam_x + rng.randf_range(-9.0, 9.0), cam_y + 10.0 + rng.randf_range(0.0, 3.0), 1.0)
	if rain_t <= 0.0:
		_die("비")


func _sounds(h: float) -> void:
	step_t -= h
	if on_floor and absf(vx) > 8.0:
		_noise(px, py, 7.0)  # 뛰면 발소리가 퍼진다
		if step_t <= 0.0:
			step_t = 0.06
			beep(120.0 + absf(vx) * 8.0, 0.03, 0.0, 0.1)
	elif on_floor and absf(vx) > 0.5 and step_t <= 0.0:
		step_t = 0.3
		beep(100.0, 0.02, 0.0, 0.04)


func _view(dt: float) -> void:
	me.position = Vector3(px, py, 0.0)
	var stretch := clampf(absf(vx) / 50.0, 0.0, 0.8)
	var low := 0.4 if sneak and absf(vx) > 0.5 and die_t <= 0.0 else 0.0
	me.scale = Vector3(1.0 + stretch * 0.6 + squash * 0.4 + low * 0.5, 1.0 - squash * 0.45 - stretch * 0.2 - low, 1.0)
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
