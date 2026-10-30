extends Tofu
## 레인월드 도주(3인칭 등뒤 3D). 왼손 조이스틱으로 복도를 달린다. 뒤에서 비 벽이 점점 빨라지며 밀려오고, 앞의 셸터에 들어가면 다음 구간.
## 점프로 틈을 넘고, 던지기로 돌을 던져 도마뱀을 잠깐 멈춘다(앞의 도마뱀을 알아서 겨눈다). 장대에 닿은 채 스틱을 위로 밀면 오른다.
## 비에 잡히거나 도마뱀에 닿으면 죽는다. 구간마다 길이 길어지고 비가 빨라지며, 3구간부터 멈춰 서서 먹어야 하는 열매가 생긴다(못 먹으면 셸터 문이 닫혀 있다).

const HALF := 3.0  # 복도 반폭
const RUN := 8.6
const SIDE := 6.5
const GRAV := 24.0
const JUMP := 8.0
const GAP := 3.2  # 틈 길이
const LEDGE := 2.6  # 턱 높이
const NDROP := 18
const NROCK := 3
const STONE := Color("ced4da")
const FLOOR := Color("e9ecef")
const RAIN := Color("74c0fc")
const LIZ := Color("b197fc")

var stage := 0
var level: Node3D
var L := 0.0  # 셸터까지 거리
var parts: Array = []  # 바닥 조각 {d0, d1, h, gap}
var poles: Array = []  # 장대 {d, top, h}
var lizards: Array = []
var fruits: Array = []
var need := 0
var ate := 0
var door: MeshInstance3D
var me: Node3D
var me_body: Node3D
var px := 0.0
var py := 0.0
var pd := 0.0  # 앞으로 간 거리 (z = -pd)
var vy := 0.0
var air := false
var pit_t := 0.0
var pit_end := 0.0
var climb := false
var pole_on: Dictionary = {}
var eat_t := 0.0
var throw_cd := 0.0
var rd := 0.0  # 비 앞면 거리
var rain_t := 0.0
var wall: MeshInstance3D
var drops: Array = []  # {n, off, x, y}
var rocks: Array = []  # {n, on, pos(x,y,d), vel, life}
var die_t := 0.0
var clear_t := 0.0
var clock := 0.0
var step_t := 0.0
var roar_t := 0.0
var tick_t := 0.0
var near_k := 0.0
var cam_base := Vector3.ZERO
var cam_ready := false


func _setup() -> void:
	howto = "비가 뒤에서 벽처럼 밀려온다. 앞의 셸터까지 달려라.\n왼손 조이스틱으로 달리고, 점프로 틈을 넘고, 던지기로 돌을 던져 도마뱀을 잠깐 멈춘다. 장대에 닿은 채 스틱을 위로 밀면 오른다.\n비에 잡히거나 도마뱀에 닿으면 죽는다. 3구간부터는 열매 앞에 멈춰 서야 먹는다. 못 먹으면 셸터 문이 안 열린다."
	time_limit = 0.0
	cam.fov = 72.0
	cam.far = 170.0
	kit_stick()
	kit_button("jump", "점프", Vector2(590, 1090), 100.0, GOOD)
	kit_button("throw", "던지기", Vector2(600, 880), 72.0, A)


func _reset() -> void:
	stage = 0
	level = null
	_build()


# ---- 바닥 ----
## 거리 d 의 바닥 높이. 틈이면 -99.
func floor_h(d: float) -> float:
	for p in parts:
		if d >= p.d0 and d < p.d1:
			return -99.0 if p.gap else p.h
	return 0.0


func _gap_end(d: float) -> float:
	for p in parts:
		if p.gap and d >= p.d0 and d < p.d1:
			return p.d1
	return d


# ---- 구간 하나 만들기 ----
func _build() -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	var rng := RandomNumberGenerator.new()
	rng.seed = stage * 31 + 5
	L = minf(100.0 + 35.0 * stage, 240.0)
	need = 0 if stage < 2 else (1 if stage < 4 else 2)
	ate = 0
	# 사건 배치 [d, 종류, 쪽]
	var evs: Array = []
	for i in need:
		evs.append([L * float(i + 1) / float(need + 1), "fruit", 0.0])
	var npole := 0
	var d := 16.0
	while d < L - 16.0:
		var skip := false
		for e in evs:
			if e[1] == "fruit" and absf(e[0] - d) < 6.0:
				skip = true
		if skip:
			d += 6.0
			continue
		var r := rng.randf()
		var kind := "gap"
		if r < 0.3:
			kind = "gap"
		elif r < 0.55:
			kind = "liz"
		elif r < 0.75 and stage >= 1:
			kind = "side"
		elif r < 0.9 and npole < 2 and d < L - 30.0:
			kind = "pole"
		else:
			kind = "liz" if r < 0.8 else "gap"
		evs.append([d, kind, -1.0 if rng.randf() < 0.5 else 1.0])
		if kind == "pole":
			npole += 1
			d += 10.0
		d += rng.randf_range(maxf(7.0, 12.0 - stage), maxf(9.0, 15.0 - stage))
	evs.sort_custom(func(a, b): return a[0] < b[0])
	# 바닥 조각
	parts.clear()
	poles.clear()
	var cur := -8.0
	for e in evs:
		var ed: float = e[0]
		if e[1] == "gap":
			parts.append({"d0": cur, "d1": ed, "h": 0.0, "gap": false})
			parts.append({"d0": ed, "d1": ed + GAP, "h": 0.0, "gap": true})
			cur = ed + GAP
		elif e[1] == "pole":
			parts.append({"d0": cur, "d1": ed, "h": 0.0, "gap": false})
			parts.append({"d0": ed, "d1": ed + 10.0, "h": LEDGE, "gap": false})
			poles.append({"d": ed - 0.7, "top": ed, "h": LEDGE})
			cur = ed + 10.0
	parts.append({"d0": cur, "d1": L + 8.0, "h": 0.0, "gap": false})
	box(Vector3(0, -1.8, -L * 0.5), Vector3(90, 1.0, L + 80.0), FLOOR, level)
	for p in parts:
		var ln: float = p.d1 - p.d0
		var mid: float = (p.d0 + p.d1) * 0.5
		if p.gap:
			box(Vector3(0, -1.1, -mid), Vector3(HALF * 2.0, 0.3, ln), B, level)  # 물
			for dd in [p.d0, p.d1]:
				box(Vector3(0, 0.03, -dd), Vector3(HALF * 2.0, 0.06, 0.3), BAD, level)
			continue
		var h: float = p.h
		box(Vector3(0, (h - 1.0) * 0.5, -mid), Vector3(HALF * 2.0, h + 1.0, ln), WHITE if h > 0.0 else SOFT, level)
		var s := ceilf(p.d0 / 6.0) * 6.0
		while s < p.d1 - 0.5:
			box(Vector3(0, h + 0.02, -s), Vector3(HALF * 2.0, 0.04, 0.3), WHITE if h == 0.0 else SOFT, level)
			s += 6.0
	# 벽 (옆 도마뱀 자리는 비워 둔다)
	var n := int(ceilf((L + 24.0) / 8.0))
	for i in n:
		var d0 := -10.0 + i * 8.0
		for sd in [-1.0, 1.0]:
			var niche := false
			for e in evs:
				if e[1] == "side" and e[2] == sd and absf(e[0] - (d0 + 4.0)) < 4.0:
					niche = true
			var hg := rng.randf_range(2.6, 4.6)
			if niche:
				box(Vector3(sd * (HALF + 2.8), 1.0, -(d0 + 4.0)), Vector3(0.6, 4.0, 8.0), STONE, level)
			else:
				box(Vector3(sd * (HALF + 0.3), (hg - 1.0) * 0.5, -(d0 + 4.0)), Vector3(0.6, hg + 1.0, 8.0), STONE, level)
	# 장대
	for p in poles:
		box(Vector3(0, (LEDGE + 0.6) * 0.5 - 0.1, -p.d), Vector3(0.22, LEDGE + 0.6, 0.22), A, level)
	# 도마뱀·열매
	lizards.clear()
	fruits.clear()
	for e in evs:
		var ed: float = e[0]
		var sd: float = e[2]
		if e[1] == "liz":
			_add_liz(sd * 1.4, ed, sd, false)
		elif e[1] == "side":
			_add_liz(sd * (HALF + 1.4), ed, sd, true)
		elif e[1] == "fruit":
			var fx := rng.randf_range(-1.5, 1.5)
			var stalk := box(Vector3(fx, 0.5, -ed), Vector3(0.14, 1.0, 0.14), GOOD, level)
			var fr := box(Vector3(fx, 1.2, -ed), Vector3(0.6, 0.6, 0.6), D, level)
			fruits.append({"stalk": stalk, "n": fr, "x": fx, "d": ed, "done": false})
	# 셸터
	for sd in [-1.0, 1.0]:
		box(Vector3(sd * 2.5, 1.8, -L), Vector3(0.6, 3.6, 0.6), GOOD, level)
	box(Vector3(0, 3.8, -L), Vector3(5.6, 0.6, 0.6), GOOD, level)
	box(Vector3(0, 1.8, -(L + 6.0)), Vector3(HALF * 2.0, 3.6, 0.6), GOOD, level)
	door = box(Vector3(0, 1.6, -L), Vector3(4.4, 3.2, 0.4), BAD, level)
	door.visible = need > 0
	# 비
	wall = box(Vector3.ZERO, Vector3(HALF * 2.0 + 10.0, 22.0, 22.0), RAIN, level)
	drops.clear()
	for i in NDROP:
		var dn := box(Vector3.ZERO, Vector3(0.1, 1.2, 0.1), WHITE, level)
		drops.append({"n": dn, "off": randf() * 7.0, "x": randf_range(-HALF, HALF), "y": randf() * 10.0})
	rocks.clear()
	for i in NROCK:
		var rn := box(Vector3.ZERO, Vector3(0.3, 0.3, 0.3), INK, level)
		rn.visible = false
		rocks.append({"n": rn, "on": false, "pos": Vector3.ZERO, "vel": Vector3.ZERO, "life": 0.0})
	_make_me()
	# 시작 상태
	px = 0.0
	py = 0.0
	pd = 0.0
	vy = 0.0
	air = false
	pit_t = 0.0
	climb = false
	eat_t = 0.0
	throw_cd = 0.0
	rd = -24.0
	rain_t = 0.0
	die_t = 0.0
	clear_t = 0.0
	near_k = 0.0
	cam_ready = false
	_place_rain()
	msg("%d구간" % (stage + 1) + ("  열매 %d" % need if need > 0 else ""), 1.6)
	beep(500.0, 0.2, 900.0, 0.2)


func _make_me() -> void:
	me = Node3D.new()
	level.add_child(me)
	me_body = Node3D.new()
	me.add_child(me_body)
	box(Vector3(0, 0.4, 0), Vector3(0.5, 0.6, 0.4), ME, me_body)  # 몸
	box(Vector3(0, 0.95, -0.05), Vector3(0.46, 0.42, 0.44), SOFT, me_body)  # 머리
	box(Vector3(-0.14, 1.25, 0), Vector3(0.12, 0.2, 0.1), SOFT, me_body)
	box(Vector3(0.14, 1.25, 0), Vector3(0.12, 0.2, 0.1), SOFT, me_body)
	box(Vector3(0, 0.25, 0.45), Vector3(0.16, 0.16, 0.6), ME, me_body)  # 꼬리


func _add_liz(x: float, d: float, sd: float, from_side: bool) -> void:
	var root := Node3D.new()
	root.position = Vector3(x, 0.0, -d)
	level.add_child(root)
	var bits: Array = []
	bits.append(box(Vector3(0, 0.35, 0), Vector3(0.7, 0.5, 1.6), LIZ, root))
	bits.append(box(Vector3(0, 0.45, -1.0), Vector3(0.56, 0.46, 0.7), BAD, root))  # 머리
	bits.append(box(Vector3(0, 0.3, 1.15), Vector3(0.3, 0.25, 1.0), LIZ, root))
	bits.append(box(Vector3(0, 0.12, 0), Vector3(1.2, 0.2, 0.3), LIZ, root))
	lizards.append({"root": root, "bits": bits, "pos": Vector2(x, d), "y": 0.0, "st": "idle", "tm": 0.0,
		"vel": Vector2.ZERO, "side": sd, "from_side": from_side, "home": Vector2(x, d)})


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	clock += dt
	if die_t > 0.0:
		die_t -= dt
		me.rotation.x += dt * 6.0
		me.position.y = maxf(-0.6, me.position.y - dt * 1.5)
		_camera(dt)
		if die_t <= 0.0:
			end()
		return
	if clear_t > 0.0:
		clear_t -= dt
		pd += RUN * 0.6 * dt
		me.position = Vector3(px, py, -pd)
		_camera(dt)
		if clear_t <= 0.0:
			stage += 1
			_build()
		return
	_move(dt)
	_rain(dt)
	if die_t > 0.0:
		return
	_lizards(dt)
	if die_t > 0.0:
		return
	_rocks(dt)
	_fruit(dt)
	me.position = Vector3(px, py, -pd)
	if pd > L + 2.5:
		clear_t = 1.2
		score += 10
		play("win")
		msg("셸터!", 1.2)
	gauge(1.0 - near_k, GOOD.lerp(BAD, near_k))
	_camera(dt)
	_sound(dt)


func _move(dt: float) -> void:
	var mv := kit_move
	throw_cd -= dt
	if pit_t > 0.0:
		pit_t -= dt
		py = lerpf(-1.0, 0.0, clampf(1.0 - pit_t / 1.3, 0.0, 1.0)) if pit_t < 0.65 else -1.0
		if pit_t <= 0.0:
			pit_t = 0.0
			py = 0.0
			pd = pit_end
		return
	if climb:
		var p := pole_on
		py = clampf(py + (-mv.y) * 3.0 * dt, 0.0, p.h + 0.1)
		px = move_toward(px, 0.0, dt * 4.0)
		me.rotation.y = lerp_angle(me.rotation.y, 0.0, minf(1.0, dt * 10.0))
		if -mv.y > 0.3:
			tick_t -= dt
			if tick_t <= 0.0:
				tick_t = 0.22
				beep(330.0, 0.04, 0.0, 0.12)
		if py >= p.h:
			climb = false
			py = p.h
			pd = p.top + 0.5
			beep(600.0, 0.08, 900.0, 0.2)
		elif absf(mv.x) > 0.75:
			climb = false
			air = true
			vy = 0.0
		me_body.position.y = 0.0
		return
	# 장대 잡기
	if not air:
		for p in poles:
			if absf(px) < 1.3 and absf(pd - p.d) < 0.9 and py < p.h - 0.2 and -mv.y > 0.3:
				climb = true
				pole_on = p
				pd = p.d
				beep(440.0, 0.06, 0.0, 0.15)
				msg("오르기", 0.5)
				return
	# 달리기
	var fwd := -mv.y
	var sp := RUN if fwd > 0.0 else 4.0
	var nd := pd + fwd * sp * dt
	var nx := clampf(px + mv.x * SIDE * dt, -HALF + 0.4, HALF - 0.4)
	var hn := floor_h(nd)
	if hn > -50.0 and hn > py + 0.6:
		nd = pd  # 턱에 막힘
	if door.visible and nd > L - 1.0:
		nd = L - 1.0
		if fwd > 0.0:
			msg("열매 %d/%d" % [ate, need], 0.4)
	pd = nd
	px = nx
	if kit_just("jump") and not air:
		air = true
		vy = JUMP
		beep(380.0, 0.1, 760.0, 0.2)
	var h := floor_h(pd)
	if air:
		vy -= GRAV * dt
		py += vy * dt
		if h > -50.0:
			if py <= h and vy <= 0.0:
				py = h
				air = false
				vy = 0.0
				beep(160.0, 0.05, 0.0, 0.15)
		elif py <= 0.0:
			_pit()
	else:
		if h < -50.0:
			_pit()
		elif py > h + 0.3:
			air = true
			vy = 0.0
		else:
			py = h
	# 몸 흔들기·발소리
	if mv.length() > 0.15 and not air:
		me.rotation.y = lerp_angle(me.rotation.y, atan2(-mv.x, -mv.y), minf(1.0, dt * 14.0))
		me_body.position.y = absf(sin(clock * 18.0)) * 0.12
		step_t -= dt * mv.length()
		if step_t <= 0.0:
			step_t = 0.24
			beep(230.0, 0.03, 0.0, 0.1)
	else:
		me_body.position.y = 0.0
	if kit_just("throw"):
		_throw()


func _pit() -> void:
	air = false
	vy = 0.0
	pit_t = 1.3
	pit_end = _gap_end(pd) + 0.5
	py = -1.0
	msg("풍덩", 0.8)
	beep(200.0, 0.2, 80.0, 0.3)


func _throw() -> void:
	if throw_cd > 0.0:
		beep(200.0, 0.04, 0.0, 0.1)
		return
	var rk: Dictionary = {}
	for r in rocks:
		if not r.on:
			rk = r
			break
	if rk.is_empty():
		return
	throw_cd = 1.1
	var from := Vector3(px, py + 1.0, pd)
	var vel := Vector3(0.0, 2.5, 20.0)
	var bd := 16.0
	for lz in lizards:
		var p: Vector2 = lz.pos
		if lz.st != "stun" and p.y > pd - 1.0 and p.y - pd < bd and absf(p.x) < HALF + 0.5:
			bd = p.y - pd
			vel = (Vector3(p.x, lz.y + 0.4, p.y) - from).normalized() * 20.0
			vel.y += 1.0
	rk.on = true
	rk.pos = from
	rk.vel = vel
	rk.life = 0.0
	(rk.n as MeshInstance3D).visible = true
	beep(700.0, 0.08, 300.0, 0.2)


func _rocks(dt: float) -> void:
	for r in rocks:
		if not r.on:
			continue
		var p: Vector3 = r.pos
		var v: Vector3 = r.vel
		v.y -= 10.0 * dt
		p += v * dt
		r.pos = p
		r.vel = v
		r.life += dt
		var n: MeshInstance3D = r.n
		n.position = Vector3(p.x, p.y, -p.z)
		n.rotation.x += dt * 12.0
		var hit := false
		for lz in lizards:
			if lz.st == "stun":
				continue
			var lp: Vector2 = lz.pos
			if Vector2(p.x - lp.x, p.z - lp.y).length() < 1.1 and p.y - lz.y < 1.4:
				_stun(lz)
				hit = true
				break
		var fh := floor_h(p.z)
		if hit or r.life > 1.3 or p.y < maxf(fh, -1.0) or absf(p.x) > HALF + 2.0:
			r.on = false
			n.visible = false


func _stun(lz: Dictionary) -> void:
	lz.st = "stun"
	lz.tm = 3.0
	lz.vel = Vector2.ZERO
	for b in lz.bits:
		(b as MeshInstance3D).material_override = mat(WHITE)
	score += 1
	msg("멈춤!", 0.6)
	beep(130.0, 0.15, 60.0, 0.3)
	play("good")


func _lizards(dt: float) -> void:
	for lz in lizards:
		var p: Vector2 = lz.pos
		var to := Vector2(px - p.x, pd - p.y)
		var dist := to.length()
		var face := Vector2(0.0, -1.0)
		match lz.st:
			"stun":
				lz.tm -= dt
				if lz.tm <= 0.0:
					lz.st = "rest"
					lz.tm = 0.4
					(lz.bits[0] as MeshInstance3D).material_override = mat(LIZ)
					(lz.bits[1] as MeshInstance3D).material_override = mat(BAD)
					(lz.bits[2] as MeshInstance3D).material_override = mat(LIZ)
					(lz.bits[3] as MeshInstance3D).material_override = mat(LIZ)
			"idle":
				face = to
				var go := false
				if lz.from_side:
					go = pd > p.y - 5.0 and pd < p.y + 1.5
				else:
					go = dist < 7.5
				if go and pit_t <= 0.0:
					lz.st = "lunge"
					lz.tm = 0.45
					lz.vel = to.normalized() * 14.0
					beep(900.0, 0.12, 400.0, 0.22)
			"lunge":
				lz.tm -= dt
				var v: Vector2 = lz.vel
				face = v
				p += v * dt
				p.x = clampf(p.x, -HALF + 0.35, HALF - 0.35)
				var hm: Vector2 = lz.home
				p.y = clampf(p.y, hm.y - 8.0, hm.y + 8.0)
				lz.pos = p
				if lz.tm <= 0.0:
					lz.st = "rest"
					lz.tm = 1.1
			"rest":
				face = to
				lz.tm -= dt
				if lz.tm <= 0.0:
					lz.st = "idle"
		var fh := floor_h(p.y)
		if fh > -50.0:
			lz.y = fh
		var root: Node3D = lz.root
		root.position = Vector3(p.x, lz.y, -p.y)
		if face.length() > 0.05:
			root.look_at(root.position + Vector3(face.x, 0.0, -face.y), Vector3.UP)
		if lz.st != "stun" and absf(p.x - px) < 0.85 and absf(p.y - pd) < 1.05 and absf(py - lz.y) < 1.3:
			_die("물렸다")
			return


func _fruit(dt: float) -> void:
	var eating := false
	for f in fruits:
		if f.done:
			continue
		if Vector2(px - f.x, pd - f.d).length() < 1.2 and not air and kit_move.length() < 0.25:
			eating = true
			eat_t += dt
			msg("냠…", 0.2)
			tick_t -= dt
			if tick_t <= 0.0:
				tick_t = 0.18
				beep(600.0 + eat_t * 300.0, 0.04, 0.0, 0.15)
			if eat_t >= 1.1:
				f.done = true
				(f.n as MeshInstance3D).visible = false
				ate += 1
				score += 2
				play("good")
				msg("열매 %d/%d" % [ate, need], 0.9)
				if ate >= need and door.visible:
					door.visible = false
					beep(500.0, 0.25, 1000.0, 0.25)
		else:
			(f.n as MeshInstance3D).rotation.y = clock * 2.0
	if not eating:
		eat_t = 0.0


func _rain(dt: float) -> void:
	rain_t += dt
	var rv := 5.8 + 0.45 * stage + (0.17 + 0.02 * stage) * rain_t
	rd += rv * dt
	near_k = clampf(1.0 - (pd - rd) / 20.0, 0.0, 1.0)
	_place_rain()
	for dr in drops:
		dr.y -= 16.0 * dt
		if dr.y < 0.0:
			dr.y = 9.0 + randf() * 2.0
			dr.x = randf_range(-HALF, HALF)
			dr.off = randf() * 7.0
		(dr.n as MeshInstance3D).position = Vector3(dr.x, dr.y, -(rd + dr.off))
	if rd >= pd - 0.3:
		_die("비")


func _place_rain() -> void:
	wall.position = Vector3(0, 9.0, -(rd - 11.0))


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 1.3
	play("bad")
	msg(why, 1.2)


func _camera(dt: float) -> void:
	var tgt := me.position + Vector3(0, 4.6 + near_k * 1.6, 6.2 - near_k * 1.4)
	if not cam_ready:
		cam_base = tgt
		cam_ready = true
	else:
		cam_base = cam_base.lerp(tgt, minf(1.0, dt * 6.0))
	var shake := near_k * near_k * 0.15
	cam.position = cam_base + Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * shake
	cam.look_at(me.position + Vector3(0, 1.0, -6.0 + near_k * 2.0))
	cam.fov = lerpf(cam.fov, 72.0 + near_k * 10.0, minf(1.0, dt * 4.0))


func _sound(dt: float) -> void:
	roar_t -= dt
	if roar_t <= 0.0:
		roar_t = lerpf(0.6, 0.07, near_k)
		beep(70.0 + snappedf(near_k * 50.0, 10.0), 0.1, 0.0, snappedf(0.04 + 0.26 * near_k, 0.02))
	if near_k > 0.5 and randf() < dt * 4.0:
		beep(1500.0, 0.03, 0.0, 0.06)
