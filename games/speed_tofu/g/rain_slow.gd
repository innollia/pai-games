extends Tofu
## 레인월드 옆모습. 스틱 살짝 = 기어감(소리 없음, 도마뱀 시야 밖이면 안 들킴), 끝까지 = 뜀(빠르지만 소리가 나서 도마뱀이 온다).
## 점프 버튼, 던지기 버튼(바닥 돌을 주워 던지면 맞은 도마뱀은 잠깐 멈추고, 떨어진 소리로 꾈 수도 있다). 장대 옆에서 스틱 위 = 타기(높으면 안 물린다).
## 비(게이지) 오기 전에 열매 2개 먹고 오른쪽 셸터에 들어가면 사이클 끝. 물리거나 비 맞으면 끝. 사이클마다 지역이 길어지고 도마뱀·웅덩이가 는다.

const CRAWL := 1.3
const RUN := 4.3
const LWALK := 1.6
const LRUN := 5.6
const JUMP := 7.5
const GRAV := 20.0
const NEED := 2
const NRAIN := 40


class Liz:
	var root: Node3D
	var body: MeshInstance3D
	var head: MeshInstance3D
	var x := 0.0
	var dir := 1.0
	var lo := 0.0
	var hi := 0.0
	var st := 0  # 0 어슬렁, 1 소리 듣고 감, 2 쫓음, 3 기절, 4 장대 밑 대기
	var tt := 0.0
	var tgt := 0.0
	var pause := 0.0
	var roar := 0.0


var rng := RandomNumberGenerator.new()
var level: Node3D
var wd := 30.0
var cyc := 0
var rain_t := 60.0
var rain_max := 60.0
var warn := 99
var done_t := 0.0
var eaten := 0
var has_rock := false
var hungry_t := 0.0
var px := 1.5
var py := 0.0
var vx := 0.0
var vy := 0.0
var face := 1.0
var grounded := true
var crawl := false
var on_pole := false
var pole_top := 0.0
var step_t := 0.0
var cam_x := 0.0
var me_root: Node3D
var me_body: MeshInstance3D
var me_head: MeshInstance3D
var me_rock: MeshInstance3D
var door: MeshInstance3D
var lizards: Array[Liz] = []
var poles: Array[Dictionary] = []  # {x, top}
var puddles: Array[Vector2] = []  # x0, x1
var fruits: Array[Dictionary] = []  # {n, x, got}
var rocks: Array[Dictionary] = []  # {n, x, y, st(0 바닥, 1 손, 2 날아감), vx, vy}
var rain: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 50.0
	howto = "스틱을 살짝 기울이면 기어간다(소리 없음). 끝까지 기울이면 뛴다(빠르지만 도마뱀이 듣고 쫓아온다).\n도마뱀은 나보다 빠르다. 장대 옆에서 스틱 위로 타면 안 물린다. 돌을 주워 던지면 잠깐 멈춘다.\n비 게이지가 다 되기 전에 노란 열매 2개를 먹고 오른쪽 셸터로.\n물리거나 비를 맞으면 끝."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1080), 100.0, ME)
	kit_button("throw", "던지기", Vector2(600, 870), 70.0, A)


func _reset() -> void:
	rng.randomize()
	level = null
	cyc = 0
	_region()


func _region() -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	lizards.clear()
	poles.clear()
	puddles.clear()
	fruits.clear()
	rocks.clear()
	rain.clear()
	wd = minf(30.0 + cyc * 4.0, 50.0)
	# 땅·배경 기둥
	box(Vector3(wd * 0.5, -1.0, 0.0), Vector3(wd + 12.0, 2.0, 6.0), WHITE, level)
	box(Vector3(wd * 0.5, 0.02, 0.0), Vector3(wd + 12.0, 0.08, 4.0), GOOD, level)
	var k := 0
	while k * 3.5 < wd:
		var h := rng.randf_range(2.5, 7.0)
		box(Vector3(k * 3.5 + rng.randf_range(0.0, 1.5), h * 0.5, -2.4 - rng.randf_range(0.0, 1.5)), Vector3(rng.randf_range(0.6, 1.4), h, 0.8), SOFT, level)
		k += 1
	# 셸터(오른쪽 끝)
	box(Vector3(wd - 0.6, 1.6, 0.0), Vector3(3.2, 3.2, 3.0), SOFT, level)
	door = box(Vector3(wd - 2.3, 0.9, 0.3), Vector3(0.3, 1.8, 1.4), GOOD, level)
	# 장대
	var np := 3 + cyc / 2
	for i in np:
		var x := wd * float(i + 1) / float(np + 1) + rng.randf_range(-2.0, 2.0)
		var top := rng.randf_range(4.0, 6.0)
		box(Vector3(x, top * 0.5, -0.3), Vector3(0.25, top, 0.25), INK, level)
		poles.append({"x": x, "top": top})
	# 웅덩이(느려짐)
	var nw := 0 if cyc < 2 else mini(1 + cyc / 2, 3)
	for i in nw:
		var cx := rng.randf_range(6.0, wd - 8.0)
		box(Vector3(cx, 0.08, 0.6), Vector3(4.0, 0.12, 2.6), B, level)
		puddles.append(Vector2(cx - 2.0, cx + 2.0))
	# 돌
	for i in 3:
		var x := rng.randf_range(3.0, wd * 0.5)
		var m := box(Vector3(x, 0.15, 0.3), Vector3(0.35, 0.3, 0.3), INK, level)
		rocks.append({"n": m, "x": x, "y": 0.15, "st": 0, "vx": 0.0, "vy": 0.0})
	# 열매
	for i in NEED:
		var x := rng.randf_range(wd * 0.3, wd * 0.85)
		var m := box(Vector3(x, 0.4, 0.0), Vector3(0.55, 0.55, 0.55), D, level)
		fruits.append({"n": m, "x": x, "got": false})
	# 도마뱀
	var nl: int = [1, 2, 2, 3][mini(cyc, 3)]
	var seg := (wd - 10.0) / nl
	for i in nl:
		var lz := Liz.new()
		lz.lo = 6.0 + seg * i
		lz.hi = minf(lz.lo + seg, wd - 4.0)
		lz.x = rng.randf_range(lz.lo, lz.hi)
		lz.dir = -1.0 if rng.randf() < 0.5 else 1.0
		lz.root = Node3D.new()
		level.add_child(lz.root)
		lz.body = box(Vector3(0.0, 0.3, 0.0), Vector3(1.3, 0.5, 0.5), BAD, lz.root)
		lz.head = box(Vector3(0.8, 0.45, 0.0), Vector3(0.5, 0.4, 0.45), BAD, lz.root)
		lizards.append(lz)
	# 비
	for i in NRAIN:
		var r := box(Vector3(0.0, -50.0, 1.0), Vector3(0.07, 0.9, 0.07), B, level)
		r.visible = false
		rain.append(r)
	# 나
	me_root = Node3D.new()
	level.add_child(me_root)
	me_body = box(Vector3(0.0, 0.45, 0.0), Vector3(0.5, 0.9, 0.4), ME, me_root)
	me_head = box(Vector3(0.1, 1.1, 0.0), Vector3(0.4, 0.4, 0.4), WHITE, me_root)
	me_rock = box(Vector3(0.4, 0.7, 0.25), Vector3(0.3, 0.26, 0.26), INK, me_root)
	me_rock.visible = false
	px = 1.5
	py = 0.0
	vx = 0.0
	vy = 0.0
	face = 1.0
	grounded = true
	crawl = false
	on_pole = false
	has_rock = false
	eaten = 0
	hungry_t = 0.0
	done_t = 0.0
	rain_max = maxf(40.0, 60.0 - cyc * 5.0)
	rain_t = rain_max
	warn = 99
	cam_x = 7.0
	msg("사이클 %d" % (cyc + 1), 1.2)


# ---- 판 ----
func _step(dt: float) -> void:
	if done_t > 0.0:
		done_t -= dt
		if done_t <= 0.0:
			cyc += 1
			_region()
		_view(dt)
		return
	rain_t -= dt
	var rf := rain_t / rain_max
	gauge(rf, B if rf > 0.25 else BAD)
	if rain_t < 10.0 and ceili(rain_t) != warn:
		warn = ceili(rain_t)
		beep(150.0, 0.15, 100.0, 0.25)
		if warn == 10:
			msg("비 온다!", 0.8)
	_rain(dt)
	if rain_t <= 0.0:
		_die("비")
		return
	hungry_t -= dt
	_me(dt)
	if over:
		return
	_rocks(dt)
	_lizards(dt)
	if over:
		return
	score = cyc * 10 + eaten
	_view(dt)


func _me(dt: float) -> void:
	var mx := kit_move.x
	var amt := absf(mx)
	var want := 0.0
	if amt > 0.12:
		want = signf(mx) * (RUN if amt >= 0.65 else CRAWL)
		face = signf(mx)
	if _in_puddle(px):
		want *= 0.45
	crawl = amt > 0.12 and amt < 0.65 and grounded and not on_pole
	if on_pole:
		py = clampf(py - kit_move.y * 2.6 * dt, 0.0, pole_top - 1.0)
		if kit_move.y > 0.5 and py <= 0.0:
			on_pole = false
		if amt > 0.8:
			on_pole = false
			vx = want
		if kit_just("jump"):
			on_pole = false
			vy = JUMP * 0.85
			vx = face * 2.0
			beep(400.0, 0.1, 700.0, 0.22)
		if on_pole and absf(kit_move.y) > 0.5:
			step_t -= dt
			if step_t <= 0.0:
				step_t = 0.3
				beep(330.0, 0.03, 0.0, 0.08)
		return
	vx = want
	px = clampf(px + vx * dt, 0.5, wd - 0.5)
	vy -= GRAV * dt
	py += vy * dt
	if py <= 0.0:
		py = 0.0
		if not grounded:
			if vy < -7.0:
				_noise(px, 4.0)
			beep(90.0, 0.06, 0.0, 0.15)
		grounded = true
		vy = 0.0
	else:
		grounded = false
	if kit_just("jump") and grounded:
		vy = JUMP
		grounded = false
		_noise(px, 5.0)
		beep(400.0, 0.1, 700.0, 0.22)
	if kit_move.y < -0.5:
		for p in poles:
			if absf(px - float(p.x)) < 0.5 and py < float(p.top) - 1.0:
				on_pole = true
				pole_top = float(p.top)
				px = float(p.x)
				vx = 0.0
				vy = 0.0
				grounded = false
				beep(500.0, 0.06, 0.0, 0.15)
				break
	# 뛰면 소리가 난다. 기면 조용하다.
	if grounded and amt >= 0.65:
		_noise(px, 8.0)
		step_t -= dt
		if step_t <= 0.0:
			step_t = 0.22
			beep(110.0, 0.04, 0.0, 0.14)
	# 열매·돌 줍기
	for f in fruits:
		if not f.got and absf(px - float(f.x)) < 0.6 and py < 0.8:
			f.got = true
			(f.n as MeshInstance3D).visible = false
			eaten += 1
			play("good")
			msg("%d / %d" % [eaten, NEED], 0.7)
	if not has_rock:
		for r in rocks:
			if r.st == 0 and absf(px - float(r.x)) < 0.6 and py < 0.8:
				has_rock = true
				r.st = 1
				(r.n as MeshInstance3D).visible = false
				beep(700.0, 0.06, 900.0, 0.18)
				msg("돌", 0.4)
				break
	if kit_just("throw") and has_rock:
		for r in rocks:
			if r.st == 1:
				r.st = 2
				r.x = px + face * 0.4
				r.y = py + 0.9
				r.vx = face * 9.0 + vx * 0.5
				r.vy = 4.5
				(r.n as MeshInstance3D).visible = true
				has_rock = false
				beep(600.0, 0.08, 300.0, 0.2)
				break
	# 셸터
	if px > wd - 2.8 and py < 0.5:
		if eaten >= NEED:
			done_t = 1.2
			score = (cyc + 1) * 10
			play("win")
			msg("셸터!", 1.2)
		else:
			px = wd - 2.8
			if hungry_t <= 0.0:
				hungry_t = 1.0
				msg("배고파", 0.6)
				beep(200.0, 0.1, 0.0, 0.2)


func _in_puddle(x: float) -> bool:
	for w in puddles:
		if x > w.x and x < w.y:
			return true
	return false


## 소리: 반지름 안의 도마뱀이 그쪽으로 온다
func _noise(x: float, r: float) -> void:
	for lz in lizards:
		if lz.st in [0, 1, 4] and absf(lz.x - x) < r:
			if lz.st == 0:
				beep(240.0, 0.15, 160.0, 0.2)
			lz.st = 1
			lz.tgt = x
			lz.tt = 0.0


func _rocks(dt: float) -> void:
	for r in rocks:
		if r.st != 2:
			continue
		r.vy -= GRAV * dt
		r.x += r.vx * dt
		r.y += r.vy * dt
		var hit := false
		for lz in lizards:
			if lz.st != 3 and absf(float(r.x) - lz.x) < 0.9 and float(r.y) < 1.0:
				lz.st = 3
				lz.tt = 3.0
				lz.body.material_override = mat(SOFT)
				lz.head.material_override = mat(SOFT)
				beep(900.0, 0.12, 300.0, 0.3)
				msg("맞았다!", 0.5)
				hit = true
				break
		if hit or float(r.y) <= 0.15 or float(r.x) < 0.3 or float(r.x) > wd - 0.3:
			r.st = 0
			r.y = 0.15
			r.x = clampf(float(r.x), 0.5, wd - 3.5)
			_noise(float(r.x), 4.5)
			beep(140.0, 0.06, 0.0, 0.18)
		(r.n as MeshInstance3D).position = Vector3(float(r.x), float(r.y), 0.3)


func _lizards(dt: float) -> void:
	var low := on_pole and py >= 1.2  # 장대 위: 못 문다
	for lz in lizards:
		var dx := px - lz.x
		match lz.st:
			0:
				if lz.pause > 0.0:
					lz.pause -= dt
				else:
					lz.x += lz.dir * LWALK * dt
					if lz.x > lz.hi:
						lz.x = lz.hi
						lz.dir = -1.0
						lz.pause = rng.randf_range(0.5, 1.6)
					elif lz.x < lz.lo:
						lz.x = lz.lo
						lz.dir = 1.0
						lz.pause = rng.randf_range(0.5, 1.6)
			1:
				if absf(lz.x - lz.tgt) > 0.3:
					lz.dir = signf(lz.tgt - lz.x)
					lz.x += lz.dir * LWALK * 1.6 * dt
				else:
					lz.tt += dt
					lz.dir = 1.0 if fmod(lz.tt, 1.4) < 0.7 else -1.0  # 두리번
					if lz.tt > 2.2:
						lz.st = 0
			2:
				lz.dir = signf(dx) if dx != 0.0 else lz.dir
				lz.x += lz.dir * LRUN * dt
				lz.roar -= dt
				if lz.roar <= 0.0:
					lz.roar = 0.45
					beep(180.0, 0.12, 120.0, 0.22)
				if absf(dx) < 0.75 and py < 1.1:
					_die("물렸다")
					return
				if low and absf(dx) < 1.2:
					lz.st = 4
					lz.tt = 0.0
				elif absf(dx) > 14.0:
					lz.st = 0
			3:
				lz.tt -= dt
				if lz.tt <= 0.0:
					lz.st = 1
					lz.tgt = px
					lz.tt = 0.0
					lz.body.material_override = mat(BAD)
					lz.head.material_override = mat(BAD)
			4:
				lz.dir = signf(dx) if dx != 0.0 else lz.dir
				lz.tt += dt
				if lz.tt > 5.0:
					lz.st = 0
					lz.pause = 0.0
		# 눈: 앞쪽, 기면 가까이서만, 바로 옆은 어디든
		if lz.st in [0, 1, 4] and not low:
			var see := absf(dx) < 1.2 or (dx * lz.dir > 0.0 and absf(dx) < (3.5 if crawl else 9.0) and py < 1.5)
			if see:
				lz.st = 2
				lz.roar = 0.0
				msg("들켰다!", 0.5)
				beep(320.0, 0.2, 200.0, 0.3)
		lz.x = clampf(lz.x, 0.5, wd - 3.5)
		lz.root.position = Vector3(lz.x, 0.0, 0.0)
		lz.head.position = Vector3(lz.dir * 0.8, 0.7 if lz.st in [1, 2, 4] else 0.45, 0.0)
		lz.body.scale = Vector3(1.6 if lz.st == 2 else 1.3, 0.5, 0.5)


func _die(why: String) -> void:
	me_body.material_override = mat(BAD)
	me_head.material_override = mat(BAD)
	msg(why, 1.5)
	end()


# ---- 그리기 ----
func _rain(dt: float) -> void:
	var n := 0 if rain_t > 10.0 else int(NRAIN * (1.0 - rain_t / 10.0))
	for i in NRAIN:
		var r := rain[i]
		if i >= n:
			r.visible = false
			continue
		if not r.visible:
			r.visible = true
			r.position = Vector3(cam_x + rng.randf_range(-10.0, 10.0), rng.randf_range(2.0, 14.0), 1.0)
		r.position.y -= 16.0 * dt
		if r.position.y < 0.0:
			r.position = Vector3(cam_x + rng.randf_range(-10.0, 10.0), 12.0 + rng.randf_range(0.0, 4.0), 1.0)


func _view(dt: float) -> void:
	me_root.position = Vector3(px, py, 0.0)
	me_root.scale = Vector3(1.0, 0.5 if crawl else 1.0, 1.0)
	me_head.position.x = face * 0.1
	me_rock.visible = has_rock
	me_rock.position.x = face * 0.4
	door.material_override = mat(GOOD if eaten >= NEED else SOFT)
	var k := 1.0 - exp(-5.0 * dt)
	cam_x = lerpf(cam_x, clampf(px, 7.0, wd - 7.0), k)
	cam.position = Vector3(cam_x, 3.0, 16.0)
	cam.rotation = Vector3(-0.08, 0.0, 0.0)
