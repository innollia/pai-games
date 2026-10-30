extends Tofu
## 레인월드 느림 1인칭. 왼쪽 스틱 살짝 = 기어감(눈높이가 풀 아래로 내려가고 소리 0, 풀밭 안이면 안 보인다), 끝까지 = 뜀(빠르지만 발소리가 나서 도마뱀이 소리 쪽으로 온다).
## 오른쪽 끌기 = 둘러보기. 도마뱀은 나보다 빠르고 앞을 보며 다닌다. 바위 뒤는 시야가 막힌다.
## 비(게이지) 오기 전에 노란 열매 2개를 먹고 저 끝 셸터 문으로 들어가면 사이클 끝. 물리거나 비를 맞으면 끝. 사이클마다 지역이 넓어지고 도마뱀·바위가 는다.

const CRAWL := 1.4
const RUN := 4.6
const LWALK := 1.7
const LRUN := 6.2
const NEED := 2
const NRAIN := 40
const EYE := 1.5
const EYE_LOW := 0.55
const GREY := Color("dfe3e8")


class Liz:
	var root: Node3D
	var body: MeshInstance3D
	var head: MeshInstance3D
	var p := Vector2.ZERO
	var dir := Vector2(1, 0)
	var home := Vector2.ZERO
	var st := 0  # 0 어슬렁, 1 소리 듣고 감, 2 쫓음
	var tgt := Vector2.ZERO
	var tt := 0.0
	var pause := 0.0
	var roar := 0.0


var rng := RandomNumberGenerator.new()
var level: Node3D
var hw := 9.0  # 지역 반폭 (x)
var hl := 18.0  # 지역 반길이 (z)
var cyc := 0
var rain_t := 60.0
var rain_max := 60.0
var warn := 99
var done_t := 0.0
var dead_t := 0.0
var eaten := 0
var hungry_t := 0.0
var pos := Vector3.ZERO
var vel := Vector3.ZERO
var yaw := 0.0
var pitch := 0.0
var eye := EYE
var crawl := false
var running := false
var bob := 0.0
var step_t := 0.0
var noise_t := 0.0
var door_p := Vector2.ZERO
var door: MeshInstance3D
var hands: MeshInstance3D
var lizards: Array[Liz] = []
var rocks: Array[Vector3] = []  # x, z, 반지름
var grass: Array[Rect2] = []  # 기면 숨는 풀밭 (x, z 평면)
var fruits: Array[Dictionary] = []  # {n, p, got}
var rain: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 75.0
	howto = "스틱을 살짝 밀면 기어간다. 눈이 풀 아래로 내려가고 소리가 안 나서 풀밭 안에서는 안 보인다.\n끝까지 밀면 뛴다. 빠르지만 발소리가 나서 도마뱀이 소리 쪽으로 온다. 도마뱀은 나보다 빠르다. 바위 뒤에 숨어라.\n오른쪽을 끌어 둘러본다. 비 게이지가 다 되기 전에 노란 열매 2개를 먹고 저 끝 셸터 문으로.\n물리거나 비를 맞으면 끝."
	kit_stick()
	kit_lookpad()
	hands = box(Vector3(0.0, -0.42, -0.7), Vector3(0.5, 0.1, 0.3), ME, cam)


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
	rocks.clear()
	grass.clear()
	fruits.clear()
	rain.clear()
	hw = minf(9.0 + cyc * 1.5, 15.0)
	hl = minf(18.0 + cyc * 4.0, 34.0)
	# 땅·울타리
	box(Vector3(0, -0.5, 0), Vector3(hw * 2.0 + 4.0, 1.0, hl * 2.0 + 4.0), SOFT, level)
	for sd in [-1.0, 1.0]:
		box(Vector3(sd * (hw + 0.6), 1.2, 0), Vector3(1.2, 2.4, hl * 2.0 + 2.4), GREY, level)
		box(Vector3(0, 1.2, sd * (hl + 0.6)), Vector3(hw * 2.0 + 2.4, 2.4, 1.2), GREY, level)
	# 셸터 (저 끝, -z)
	box(Vector3(0, 1.8, -hl + 1.2), Vector3(5.0, 3.6, 2.4), WHITE, level)
	door_p = Vector2(0.0, -hl + 2.5)
	door = box(Vector3(0, 1.1, -hl + 2.45), Vector3(1.6, 2.2, 0.3), GOOD, level)
	# 풀밭 (기면 숨는 곳)
	var ng := mini(5 + cyc, 9)
	for i in ng:
		var w := rng.randf_range(3.0, 5.5)
		var d := rng.randf_range(3.0, 5.5)
		var cx := rng.randf_range(-hw + w * 0.5, hw - w * 0.5)
		var cz := rng.randf_range(-hl + 6.0, hl - 5.0)
		box(Vector3(cx, 0.05, cz), Vector3(w, 0.1, d), GOOD, level)
		var nb := int(w * d * 0.5)
		for j in nb:
			box(Vector3(cx + rng.randf_range(-w, w) * 0.5, 0.45, cz + rng.randf_range(-d, d) * 0.5), Vector3(0.12, 0.9, 0.12), GOOD, level)
		grass.append(Rect2(cx - w * 0.5, cz - d * 0.5, w, d))
	# 바위 (시야를 막는다)
	var nr := mini(8 + cyc * 3, 20)
	for i in nr:
		var r := rng.randf_range(0.7, 1.4)
		var rp := Vector2(rng.randf_range(-hw + 2.0, hw - 2.0), rng.randf_range(-hl + 6.0, hl - 5.0))
		if rp.distance_to(door_p) < 4.0:
			continue
		box(Vector3(rp.x, r * 0.9, rp.y), Vector3(r * 2.0, r * 1.8, r * 2.0), WHITE, level)
		rocks.append(Vector3(rp.x, rp.y, r))
	# 열매
	for i in NEED:
		var fp := _free_spot(-hl + 5.0, hl * 0.6)
		var m := box(Vector3(fp.x, 0.5, fp.y), Vector3(0.6, 0.6, 0.6), D, level)
		fruits.append({"n": m, "p": fp, "got": false})
	# 도마뱀
	var nl: int = [1, 2, 3, 4][mini(cyc, 3)]
	for i in nl:
		var lz := Liz.new()
		lz.home = Vector2(rng.randf_range(-hw + 3.0, hw - 3.0), lerpf(-hl + 6.0, hl - 8.0, float(i + 1) / float(nl + 1)))
		lz.p = lz.home
		lz.dir = Vector2.from_angle(rng.randf() * TAU)
		lz.root = Node3D.new()
		level.add_child(lz.root)
		lz.body = box(Vector3(0.0, 0.3, 0.0), Vector3(0.6, 0.5, 1.5), BAD, lz.root)
		lz.head = box(Vector3(0.0, 0.45, -0.95), Vector3(0.5, 0.4, 0.55), BAD, lz.root)
		box(Vector3(0.0, 0.25, 1.1), Vector3(0.25, 0.2, 0.8), BAD, lz.root)
		lz.pause = rng.randf_range(0.5, 2.0)
		lizards.append(lz)
	# 비
	for i in NRAIN:
		var r := box(Vector3(0.0, -50.0, 0.0), Vector3(0.06, 0.9, 0.06), B, level)
		r.visible = false
		rain.append(r)
	# 나
	pos = Vector3(0.0, 0.0, hl - 2.5)
	vel = Vector3.ZERO
	yaw = 0.0
	pitch = -0.05
	eye = EYE
	crawl = false
	running = false
	eaten = 0
	hungry_t = 0.0
	done_t = 0.0
	dead_t = 0.0
	rain_max = maxf(36.0, 50.0 - cyc * 4.0)  # 기어서만 가면 못 미친다: 어디서 뛸지 골라야 한다
	rain_t = rain_max
	warn = 99
	hands.material_override = mat(ME)
	msg("사이클 %d" % (cyc + 1), 1.2)


## 바위·문에서 떨어진 빈 자리
func _free_spot(z0: float, z1: float) -> Vector2:
	for k in 20:
		var q := Vector2(rng.randf_range(-hw + 1.5, hw - 1.5), rng.randf_range(z0, z1))
		var ok := q.distance_to(door_p) > 3.0
		for r in rocks:
			if q.distance_to(Vector2(r.x, r.y)) < r.z + 1.0:
				ok = false
				break
		if ok:
			return q
	return Vector2(0.0, (z0 + z1) * 0.5)


# ---- 판 ----
func _step(dt: float) -> void:
	if dead_t > 0.0:
		dead_t -= dt
		eye = lerpf(eye, 0.25, 1.0 - exp(-6.0 * dt))
		_view(dt)
		return
	if done_t > 0.0:
		done_t -= dt
		pos.z -= 1.5 * dt
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
	if rain_t <= 0.0:
		_die("비")
		return
	hungry_t -= dt
	_me(dt)
	if over or dead_t > 0.0 or done_t > 0.0:
		return
	_lizards(dt)
	if over or dead_t > 0.0:
		return
	score = cyc * 10 + eaten
	_view(dt)


func _me(dt: float) -> void:
	yaw -= kit_look.x * 0.007
	pitch = clampf(pitch - kit_look.y * 0.004, -0.8, 0.5)
	var amt := kit_move.length()
	var want := Vector3.ZERO
	running = amt >= 0.65
	crawl = amt > 0.12 and not running
	if amt > 0.12:
		var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
		var right := Vector3(cos(yaw), 0, -sin(yaw))
		var m := kit_move / amt
		want = (right * m.x - fwd * m.y) * (RUN if running else CRAWL)
	vel = vel.move_toward(want, (22.0 if running else 12.0) * dt)
	pos += vel * dt
	_push_out()
	# 뛰면 발소리. 기면 조용하다.
	var spd := vel.length()
	if spd > 2.5:
		noise_t -= dt
		if noise_t <= 0.0:
			noise_t = 0.25
			_noise(Vector2(pos.x, pos.z), 9.0)
		step_t -= dt * spd / RUN
		if step_t <= 0.0:
			step_t = 0.3
			beep(110.0, 0.04, 0.0, 0.14)
		bob += dt * 12.0
	# 열매
	for f in fruits:
		if not f.got and Vector2(pos.x, pos.z).distance_to(f.p) < 0.9:
			f.got = true
			(f.n as MeshInstance3D).visible = false
			eaten += 1
			play("good")
			msg("%d / %d" % [eaten, NEED], 0.7)
	# 셸터 문
	if Vector2(pos.x, pos.z).distance_to(door_p) < 1.3:
		if eaten >= NEED:
			done_t = 1.2
			score = (cyc + 1) * 10
			play("win")
			msg("셸터!", 1.2)
		elif hungry_t <= 0.0:
			hungry_t = 1.0
			msg("배고파", 0.6)
			beep(200.0, 0.1, 0.0, 0.2)


## 울타리·바위·셸터 밖으로 밀어낸다 (2D 원)
func _push_out() -> void:
	pos.x = clampf(pos.x, -hw + 0.4, hw - 0.4)
	pos.z = clampf(pos.z, -hl + 2.9, hl - 0.4)
	for r in rocks:
		var d := Vector2(pos.x - r.x, pos.z - r.y)
		var rr: float = r.z + 0.4
		if d.length() < rr:
			var n := d.normalized() if d.length() > 0.001 else Vector2(1, 0)
			pos.x = r.x + n.x * rr
			pos.z = r.y + n.y * rr
			var into := Vector2(vel.x, vel.z).dot(n)
			if into < 0.0:
				vel -= Vector3(n.x, 0, n.y) * into


func _in_grass(q: Vector2) -> bool:
	for g in grass:
		if g.has_point(q):
			return true
	return false


## a에서 b로 가는 시선이 바위에 막히나
func _blocked(a: Vector2, b: Vector2) -> bool:
	var ab := b - a
	var len2 := ab.length_squared()
	for r in rocks:
		var c := Vector2(r.x, r.y)
		var tt := 0.0 if len2 < 0.0001 else clampf((c - a).dot(ab) / len2, 0.0, 1.0)
		if c.distance_to(a + ab * tt) < r.z:
			return true
	return false


## 소리: 반지름 안의 도마뱀이 그쪽으로 온다
func _noise(at: Vector2, r: float) -> void:
	for lz in lizards:
		if lz.st != 2 and lz.p.distance_to(at) < r:
			if lz.st == 0:
				beep(240.0, 0.15, 160.0, 0.2)
				msg("들었다", 0.4)
			lz.st = 1
			lz.tgt = at
			lz.tt = 0.0


func _lizards(dt: float) -> void:
	var me := Vector2(pos.x, pos.z)
	var hidden := crawl and _in_grass(me) and vel.length() < 2.5
	for lz in lizards:
		var to := me - lz.p
		var dist := to.length()
		match lz.st:
			0:
				if lz.pause > 0.0:
					lz.pause -= dt
					if lz.pause <= 0.0:
						lz.tgt = lz.home + Vector2(rng.randf_range(-6.0, 6.0), rng.randf_range(-6.0, 6.0))
						lz.tgt.x = clampf(lz.tgt.x, -hw + 1.5, hw - 1.5)
						lz.tgt.y = clampf(lz.tgt.y, -hl + 5.0, hl - 4.0)
				else:
					_walk(lz, lz.tgt, LWALK, dt)
					if lz.p.distance_to(lz.tgt) < 0.4:
						lz.pause = rng.randf_range(0.8, 2.2)
			1:
				if lz.p.distance_to(lz.tgt) > 0.5:
					_walk(lz, lz.tgt, LWALK * 1.7, dt)
				else:
					lz.tt += dt
					lz.dir = lz.dir.rotated(1.6 * dt)  # 두리번
					if lz.tt > 2.5:
						lz.st = 0
						lz.pause = 0.3
			2:
				_walk(lz, me, LRUN, dt)
				lz.roar -= dt
				if lz.roar <= 0.0:
					lz.roar = 0.45
					beep(180.0, 0.12, 120.0, 0.22)
				if dist < 0.95:
					_die("물렸다")
					return
				# 풀 속에 엎드려 3m 밖이면 놓친다: 들킨 뒤에도 '풀로 뛰어들기'가 남는다
				if dist > 18.0 or (hidden and dist > 3.0):
					lz.st = 1
					lz.tgt = me
					lz.tt = 0.0
					msg("놓쳤다", 0.5)
		# 눈: 앞쪽 부채꼴, 기면 가까이서만, 바로 옆은 어디든. 바위 뒤·풀 속은 안 보임
		if lz.st != 2 and dist > 0.01:
			var ahead := lz.dir.dot(to / dist) > 0.45
			var reach := 3.5 if crawl else 11.0
			var see := dist < 1.3 or (ahead and dist < reach and not (hidden and dist > 1.3))
			if see and not _blocked(lz.p, me):
				lz.st = 2
				lz.roar = 0.0
				msg("들켰다!", 0.5)
				beep(320.0, 0.2, 200.0, 0.3)
		lz.root.position = Vector3(lz.p.x, 0.0, lz.p.y)
		lz.root.rotation.y = atan2(-lz.dir.x, -lz.dir.y)
		lz.body.scale = Vector3(0.6, 0.5, 1.9 if lz.st == 2 else 1.5)
		lz.head.position.y = 0.7 if lz.st != 0 else 0.45


func _walk(lz: Liz, to: Vector2, spd: float, dt: float) -> void:
	var d := to - lz.p
	if d.length() < 0.01:
		return
	lz.dir = lz.dir.slerp(d.normalized(), minf(1.0, 6.0 * dt)).normalized()
	lz.p += lz.dir * spd * dt
	lz.p.x = clampf(lz.p.x, -hw + 0.8, hw - 0.8)
	lz.p.y = clampf(lz.p.y, -hl + 3.5, hl - 0.8)
	for r in rocks:
		var q := lz.p - Vector2(r.x, r.y)
		var rr: float = r.z + 0.5
		if q.length() < rr and q.length() > 0.001:
			lz.p = Vector2(r.x, r.y) + q.normalized() * rr


func _die(why: String) -> void:
	dead_t = 1.3
	vel = Vector3.ZERO
	hands.material_override = mat(BAD)
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
			r.position = Vector3(pos.x + rng.randf_range(-8.0, 8.0), rng.randf_range(2.0, 12.0), pos.z + rng.randf_range(-8.0, 8.0))
		r.position.y -= 16.0 * dt
		if r.position.y < 0.0:
			r.position = Vector3(pos.x + rng.randf_range(-8.0, 8.0), 10.0 + rng.randf_range(0.0, 4.0), pos.z + rng.randf_range(-8.0, 8.0))


func _view(dt: float) -> void:
	_rain(dt)
	if dead_t <= 0.0:
		eye = lerpf(eye, EYE_LOW if crawl else EYE, 1.0 - exp(-7.0 * dt))
	var bb := sin(bob) * 0.05 if running else 0.0
	cam.position = pos + Vector3(0, eye + bb, 0)
	cam.rotation = Vector3(pitch, yaw, 0)
	hands.position = Vector3(0.0, -0.42 + (0.12 if crawl else 0.0), -0.7)
	door.material_override = mat(GOOD if eaten >= NEED else SOFT)
