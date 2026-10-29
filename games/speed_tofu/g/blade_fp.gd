extends Tofu
## 일격의 길 (등 뒤 3인칭): 내 검객 어깨 너머로 상대를 본다. 박자(똑딱)를 읽고 빨간 쪽으로 밀어 막는다. 칼이 닿기 직전에 막으면 '간파'(세상이 느려짐). 연속기를 다 막으면 열린 초록 쪽으로 밀어 벤다. 세 번 맞으면 그 도장부터. 첫 검객을 꺾으면 '두 번 베기'를 배우고, 쌍검 검객은 두 번 베기로만 뚫린다.

const SWIPE := 60.0
const OPP := [1, 0, 3, 2]
const GUARD_W := 0.36  # 칼이 닿기 이만큼 전부터 막을 수 있다 (더 이르면 헛손질)
const PERFECT := 0.11  # 이 안이면 간파
const SLOW := 0.25
const WALK_T := 4.0
const CAM_O := Vector3(1.3, 2.1, 2.9)
const LOOK_O := Vector3(-0.25, 1.2, -3.8)
const FOE_O := Vector3(0, 0, -3.6)
const HERO := [Vector3(0, 0, 0), Vector3(0, 0, -24)]
const NAMES := ["찌르기 검객", "쌍검 검객"]
const BODY := [A, C]
## 상대 칼이 닿는 곳 (내 몸 기준): 왼·오·위·아래
const HIT := [Vector3(-0.7, 1.0, -0.25), Vector3(0.7, 1.0, -0.25), Vector3(0, 2.0, -0.25), Vector3(0, 0.2, -0.25)]
## 상대가 칼을 치켜드는 곳 (상대 몸 기준)
const WIND := [Vector3(-1.4, 1.5, 0.4), Vector3(1.4, 1.5, 0.4), Vector3(0.2, 2.9, 0.2), Vector3(-0.3, -0.1, 0.7)]
## 내 칼 막기 자세 (내 몸 기준): [손잡이, 칼끝이 향하는 곳]
const GUARD := [
	[Vector3(-0.75, 0.45, -0.45), Vector3(-0.8, 2.0, -0.6)],
	[Vector3(0.75, 0.45, -0.45), Vector3(0.8, 2.0, -0.6)],
	[Vector3(-0.7, 1.75, -0.45), Vector3(0.9, 1.85, -0.6)],
	[Vector3(-0.7, 0.35, -0.5), Vector3(0.9, 0.25, -0.6)],
]
const REST := [Vector3(0.45, 0.8, -0.25), Vector3(0.15, 1.7, -2.5)]
## 벨 곳 (상대 몸 기준)
const CUT_AT := [Vector3(-0.6, 1.0, 0.4), Vector3(0.6, 1.0, 0.4), Vector3(0, 1.95, 0.4), Vector3(0, 0.25, 0.4)]
## 검객 > 단 > [빠르기(bpm), 쉼(박), 연속기 목록]. 연속기 = [쪽, 예비 박]의 줄. 0.5박은 반 박 만에 오는 기습.
const PAT := [
	[
		[96.0, 2.0, [[[0, 2.0]], [[1, 2.0]], [[2, 2.0]], [[3, 2.0]]]],
		[116.0, 2.0, [[[0, 2.0], [1, 1.0]], [[2, 2.0], [3, 1.0]], [[1, 1.0], [0, 1.0]]]],
		[134.0, 1.0, [[[2, 1.0], [0, 1.0], [1, 0.5]], [[3, 2.0], [1, 0.5], [0, 1.0]], [[0, 1.0], [0, 0.5], [2, 1.0]]]],
	],
	[
		[104.0, 2.0, [[[0, 2.0], [1, 0.5]], [[1, 2.0], [0, 0.5]], [[2, 2.0], [3, 0.5]]]],
		[120.0, 2.0, [[[0, 1.0], [1, 0.5], [2, 1.0], [3, 0.5]], [[3, 2.0], [2, 0.5], [0, 0.5]]]],
		[132.0, 1.0, [[[2, 3.0], [0, 0.5], [1, 0.5]], [[0, 1.0], [1, 0.5], [3, 1.0], [2, 0.5]], [[1, 4.0], [0, 0.5], [3, 0.5], [2, 0.5]]]],
	],
]

# 여행 진행 (죽어도 남는다)
var stage := 0
var has_double := false
var bank := 0
# 장면
var piv: Array[Node3D] = []
var bodies: Array[MeshInstance3D] = []
var fblades: Array = []
var eyes: Array = []
var pips: Array = []
var floors: Array[MeshInstance3D] = []
var ind_red: MeshInstance3D
var ind_good: MeshInstance3D
var hero: Node3D
var hero_body: MeshInstance3D
var hilt: Node3D
var sw_box: MeshInstance3D
var my_col := WHITE
var hbase := Vector3.ZERO
var hero_fl := 0.0
var sw_p := Vector3.ZERO
var sw_a := Vector3.ZERO
var sw_gp := Vector3.ZERO
var sw_ga := Vector3.ZERO
# 결투
var cur := 0
var mode := "intro"
var mode_t := 0.0
var life := 3
var ph := 0
var cut := 0
var ci := 0
var mi := 0
var fs := 0  # 0 쉼, 1 예비 동작, 2 빈틈, 3 둘째 빈틈, 4 내가 맞음, 5 상대 휘청
var st := 0.0
var bp := 0.6
var bclock := 0.0
var beat_n := 0
var md := 0
var win := 1.0
var bi := 0
var blocked := false
var perf := false
var odir := 0
var owin := 0.5
var fl := Vector3.ZERO
var bob := 0.0
var slow := 0.0
var cool := 0.0
var walk_s := 0.0
var foot_t := 0.0
var sw_t := 0.0
var flash_t := 0.0
var hurt_t := 0.0
var shake_t := 0.0
var start := Vector2.ZERO
var armed := false


func _setup() -> void:
	time_limit = 0.0
	stage = 0
	has_double = false
	bank = 0
	howto = "내 등 뒤에서 본다. 상대 칼이 오는 쪽(빨간 상자)으로 밀어 막는다.\n똑딱 박자를 읽어 칼이 닿기 직전에 막으면 '간파', 세상이 느려진다.\n연속기를 다 막으면 초록 쪽이 열린다. 그쪽으로 밀어 벤다.\n세 번 맞으면 죽고 그 도장부터 다시."


func _fbase(i: int) -> Vector3:
	return HERO[i] + FOE_O


func _reset() -> void:
	piv.clear()
	bodies.clear()
	fblades.clear()
	eyes.clear()
	pips.clear()
	floors.clear()
	_scenery()
	for i in 2:
		_foe(i)
	ind_red = box(Vector3.ZERO, Vector3(0.6, 0.6, 0.6), BAD)
	ind_red.visible = false
	ind_good = box(Vector3.ZERO, Vector3(0.6, 0.6, 0.6), GOOD)
	ind_good.visible = false
	hero = Node3D.new()
	world.add_child(hero)
	hero_body = box(Vector3(0, 0.85, 0), Vector3(0.8, 1.5, 0.5), ME, hero)
	box(Vector3(0, 1.85, 0), Vector3(0.5, 0.5, 0.5), SOFT, hero)
	box(Vector3(0, 2.08, 0.05), Vector3(0.55, 0.16, 0.55), INK, hero)
	box(Vector3(0, 2.2, 0.28), Vector3(0.18, 0.2, 0.18), INK, hero)
	box(Vector3(0, 0.75, 0), Vector3(0.84, 0.14, 0.54), INK, hero)
	hilt = Node3D.new()
	hero.add_child(hilt)
	my_col = D if has_double else WHITE
	sw_box = box(Vector3(0, 0, -0.75), Vector3(0.09, 0.09, 1.5), my_col, hilt)
	box(Vector3(0, 0, -0.02), Vector3(0.32, 0.08, 0.08), INK, hilt)
	cur = stage
	if cur == 1:
		piv[0].rotation.x = -1.45
		piv[0].position = _fbase(0) + Vector3(0, 0, -0.3)
	hbase = HERO[cur]
	hero.position = hbase
	score = bank
	slow = 0.0
	cool = 0.0
	sw_t = 0.0
	flash_t = 0.0
	hurt_t = 0.0
	shake_t = 0.0
	hero_fl = 0.0
	armed = false
	sw_p = REST[0]
	sw_a = REST[1]
	cam.fov = 66.0
	_begin_duel()


func _begin_duel() -> void:
	life = 3
	ph = 0
	cut = 0
	ci = 0
	mi = 0
	fs = 0
	st = 0.0
	fl = Vector3.ZERO
	bp = 60.0 / float(_pat()[0])
	hbase = HERO[cur]
	mode = "intro"
	mode_t = 1.4
	msg(NAMES[cur], 1.4)


func _scenery() -> void:
	# 땅, 냇물, 다리
	box(Vector3(0, -1.1, -14), Vector3(30, 2, 50), GOOD)
	box(Vector3(0, -0.3, -13), Vector3(30, 0.5, 5), B)
	for k in 8:
		box(Vector3(1.4, 0.02, -9.8 - k * 1.05), Vector3(2.2, 0.15, 0.9), WHITE)
	for s in [-1.0, 1.0]:
		box(Vector3(1.4 + s * 1.15, 0.45, -13.5), Vector3(0.12, 0.12, 8.4), INK)
	for i in 2:
		var h: Vector3 = HERO[i]
		floors.append(box(h + Vector3(0, -0.15, -2.0), Vector3(6, 0.3, 8), SOFT))
		# 상대 뒤의 문
		for s in [-1.0, 1.0]:
			box(h + FOE_O + Vector3(s * 2.4, 1.6, -1.6), Vector3(0.3, 3.6, 0.3), BAD)
		box(h + FOE_O + Vector3(0, 3.4, -1.6), Vector3(6, 0.3, 0.45), BAD)
		box(h + FOE_O + Vector3(0, 2.9, -1.6), Vector3(5, 0.18, 0.3), INK)
		# 등불
		for s in [-1.0, 1.0]:
			box(h + Vector3(s * 3.2, 0.5, -1.0), Vector3(0.2, 1.0, 0.2), SOFT)
			box(h + Vector3(s * 3.2, 1.15, -1.0), Vector3(0.45, 0.35, 0.45), D)
	# 나무
	for p: Vector3 in [Vector3(-5, 0, -2), Vector3(5.5, 0, -6), Vector3(-6, 0, 3), Vector3(-4, 0, -17), Vector3(6, 0, -19), Vector3(-5, 0, -30), Vector3(5, 0, -31)]:
		box(p + Vector3(0, 0.8, 0), Vector3(0.35, 1.6, 0.35), INK)
		box(p + Vector3(0, 2.3, 0), Vector3(1.4, 1.8, 1.4), GOOD)
	# 먼 산
	for m: Vector3 in [Vector3(-12, 6, -50), Vector3(6, 10, -56), Vector3(20, 4, -46)]:
		box(m, Vector3(16, m.y * 2.0 + 6.0, 4), B)
		box(m + Vector3(0, m.y + 3.0, 0.2), Vector3(6, 2, 4), WHITE)


func _foe(i: int) -> void:
	var p := Node3D.new()
	world.add_child(p)
	p.position = _fbase(i)
	piv.append(p)
	if i == 0:
		bodies.append(box(Vector3(0, 0.85, 0), Vector3(0.9, 1.6, 0.6), BODY[0], p))
		box(Vector3(0, 2.3, -0.05), Vector3(0.2, 0.25, 0.2), INK, p)
		box(Vector3(0, 2.02, 0), Vector3(0.56, 0.12, 0.56), BAD, p)
	else:
		bodies.append(box(Vector3(0, 0.8, 0), Vector3(1.25, 1.5, 0.7), BODY[1], p))
		box(Vector3(0, 2.2, 0), Vector3(1.5, 0.12, 1.5), D, p)
		box(Vector3(0, 2.36, 0), Vector3(0.5, 0.2, 0.5), D, p)
	box(Vector3(0, 1.85, 0), Vector3(0.5, 0.5, 0.5), SOFT, p)
	var e: Array[MeshInstance3D] = []
	for s in [-1.0, 1.0]:
		e.append(box(Vector3(s * 0.12, 1.9, 0.26), Vector3(0.1, 0.1, 0.04), INK, p))
	eyes.append(e)
	var bl: Array[Node3D] = []
	for j in (1 if i == 0 else 2):
		var h := Node3D.new()
		world.add_child(h)
		box(Vector3(0, 0, -0.7), Vector3(0.08, 0.08, 1.4), WHITE, h)
		h.position = p.to_global(_frest(j)[0])
		bl.append(h)
	fblades.append(bl)
	var pp: Array[MeshInstance3D] = []
	for k in 6:
		var x := (k - 2.5) * 0.24 + (floori(k / 2.0) - 1) * 0.14
		pp.append(box(Vector3(x, 2.75, 0), Vector3(0.18, 0.18, 0.18), BAD, p))
	pips.append(pp)


## 상대 칼 쉬는 자세 (상대 몸 기준): [손잡이, 칼끝]
func _frest(j: int) -> Array:
	var s := 1.0 if j == 0 else -1.0
	return [Vector3(0.55 * s, 0.9, 0.35), Vector3(0.35 * s, 1.7, 2.5)]


func _pat() -> Array:
	return PAT[cur][ph]


func _aim(n: Node3D, at: Vector3) -> void:
	var v := at - n.global_position
	if v.length() < 0.01:
		return
	n.look_at(at, Vector3.UP if absf(v.normalized().y) < 0.95 else Vector3.BACK)


func _step(dt: float) -> void:
	var fdt := dt
	if slow > 0.0:
		slow -= dt
		fdt = dt * SLOW
		if slow <= 0.0:
			floors[cur].material_override = mat(SOFT)
	if cool > 0.0:
		cool -= dt
	mode_t -= dt
	match mode:
		"intro", "shift":
			fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 8.0))
			if mode_t <= 0.0:
				mode = "fight"
				_rest()
		"fight":
			_fight(fdt)
		"fall":
			piv[cur].rotation.x = lerpf(piv[cur].rotation.x, -1.45, minf(1.0, dt * 5.0))
			fl = fl.lerp(Vector3(0, 0, -0.3), minf(1.0, dt * 5.0))
			if mode_t <= 0.0:
				_after_fall()
		"learn":
			if mode_t <= 0.0:
				mode = "walk"
				walk_s = 0.0
				foot_t = 0.0
				msg("베고 되돌려 베기", 1.8)
		"walk":
			_walk(dt)
	_pose_foes(dt)
	_pose_hero(dt)
	cam.position = hbase + CAM_O
	cam.look_at(hbase + LOOK_O)
	if shake_t > 0.0:
		shake_t -= dt
		cam.position += Vector3(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), 0)
	cam.fov = lerpf(cam.fov, 54.0 if slow > 0.0 else 66.0, minf(1.0, dt * 8.0))
	if flash_t > 0.0:
		flash_t -= dt
		if flash_t <= 0.0:
			bodies[cur].material_override = mat(BODY[cur])
	if hurt_t > 0.0:
		hurt_t -= dt
		if hurt_t <= 0.0:
			hero_body.material_override = mat(ME)
	gauge(life / 3.0, GOOD if life > 1 else BAD)


func _pose_foes(dt: float) -> void:
	bob = maxf(0.0, bob - dt * 0.6)
	if mode != "walk" and mode != "learn":
		piv[cur].position = _fbase(cur) + fl + Vector3(0, bob, 0)
	for i in piv.size():
		var pv := piv[i]
		var bl: Array = fblades[i]
		for j in bl.size():
			var h: Node3D = bl[j]
			var r := _frest(j)
			var gp: Vector3 = pv.to_global(r[0])
			var ga: Vector3 = pv.to_global(r[1])
			var rate := 14.0
			if i == cur and mode == "fight" and j == bi:
				if fs == 1:
					var wnd: Vector3 = pv.position + WIND[md]
					var tgt: Vector3 = hero.position + HIT[md]
					ga = tgt
					var k := clampf(st / win, 0.0, 1.0)
					if blocked:
						gp = wnd + Vector3(0, 0.3, -0.3)
						rate = 20.0
					elif k < 0.65:
						gp = wnd
					else:
						# 마지막 한순간에 몰아친다
						var kk := (k - 0.65) / 0.35
						gp = wnd.lerp(tgt + (wnd - tgt).normalized() * 1.4, kk * kk)
						rate = 0.0
				elif fs == 4:
					gp = h.global_position
					ga = hero.position + HIT[md]
			if rate <= 0.0:
				h.global_position = gp
			else:
				h.global_position = h.global_position.lerp(gp, minf(1.0, dt * rate))
			_aim(h, ga)


func _pose_hero(dt: float) -> void:
	hero_fl = lerpf(hero_fl, 0.0, minf(1.0, dt * 8.0))
	hero.position = hbase + Vector3(0, 0, hero_fl)
	var gp: Vector3 = REST[0]
	var ga: Vector3 = REST[1]
	if sw_t > 0.0:
		sw_t -= dt
		gp = sw_gp
		ga = sw_ga
	sw_p = sw_p.lerp(gp, minf(1.0, dt * 30.0))
	sw_a = sw_a.lerp(ga, minf(1.0, dt * 30.0))
	hilt.position = sw_p
	_aim(hilt, hero.to_global(sw_a))


func _tick() -> void:
	beat_n += 1
	beep(1250.0 if beat_n % 4 == 0 else 950.0, 0.025, 0.0, 0.07)
	bob = 0.09


func _rest() -> void:
	bp = 60.0 / float(_pat()[0])
	fs = 0
	st = 0.0
	bclock = 0.0
	beat_n = -1
	_tick()
	ind_red.visible = false
	ind_good.visible = false


func _fight(dt: float) -> void:
	bclock += dt
	if bclock >= bp:
		bclock -= bp
		_tick()
	st += dt
	match fs:
		0:
			fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 8.0))
			piv[cur].rotation.z = lerpf(piv[cur].rotation.z, 0.0, minf(1.0, dt * 8.0))
			if st >= float(_pat()[1]) * bp:
				mi = 0
				_start_move()
		1:
			var k := clampf(st / win, 0.0, 1.0)
			var lunge := 0.0 if k < 0.65 else 1.1 * (k - 0.65) / 0.35
			if not blocked:
				fl = fl.lerp(Vector3(WIND[md].x * 0.12, 0, lunge), minf(1.0, dt * 20.0))
				ind_red.scale = Vector3.ONE * (0.7 - 0.45 * k)
				ind_red.material_override = mat(D if win - st <= PERFECT else BAD)
			if st >= win:
				if blocked:
					_next_move()
				else:
					_hurt()
		2, 3:
			var k := clampf(st / owin, 0.0, 1.0)
			fl = fl.lerp(Vector3(0, 0, -0.5), minf(1.0, dt * 10.0))
			piv[cur].rotation.z = lerpf(piv[cur].rotation.z, 0.2, minf(1.0, dt * 6.0))
			ind_good.scale = Vector3.ONE * (0.7 - 0.45 * k)
			if st >= owin:
				if fs == 3:
					_clank()
				else:
					beep(260.0, 0.1, 200.0, 0.15)
				_rest()
		4:
			if st >= bp:
				_rest()
		5:
			fl = fl.lerp(Vector3(0, 0, -1.0), minf(1.0, dt * 8.0))
			if st >= bp:
				_rest()


func _start_move() -> void:
	var mv: Array = _pat()[2][ci][mi]
	md = int(mv[0])
	win = float(mv[1]) * bp
	bi = mi % fblades[cur].size()
	st = 0.0
	blocked = false
	perf = false
	fs = 1
	ind_red.visible = true
	ind_red.position = hero.position + HIT[md]
	ind_red.material_override = mat(BAD)
	# 느린 예비 동작은 낮은 소리, 기습은 높은 소리
	beep(lerpf(780.0, 320.0, clampf((win - 0.2) / 1.0, 0.0, 1.0)), 0.06, 0.0, 0.17)


func _next_move() -> void:
	var combos: Array = _pat()[2]
	mi += 1
	if mi < combos[ci].size():
		_start_move()
		return
	# 연속기를 다 막았다: 빈틈
	ci = (ci + 1) % combos.size()
	mi = 0
	fs = 2
	st = 0.0
	owin = bp * (1.6 if perf else 1.0)
	odir = OPP[md]
	ind_red.visible = false
	_open(odir)
	beep(660.0, 0.08, 990.0, 0.18)


func _open(d: int) -> void:
	ind_good.visible = true
	ind_good.position = piv[cur].position + CUT_AT[d]
	ind_good.scale = Vector3.ONE * 0.7


func _hurt() -> void:
	life -= 1
	play("bad")
	msg("맞음", 0.4)
	hero_body.material_override = mat(BAD)
	hurt_t = 0.3
	shake_t = 0.22
	hero_fl = 0.5
	fs = 4
	st = 0.0
	ind_red.visible = false
	ci = (ci + 1) % _pat()[2].size()
	mi = 0
	if life <= 0:
		mode = "dead"
		msg("쓰러짐", 2.0)
		end()


func _clank() -> void:
	beep(1100.0, 0.05, 700.0, 0.2)
	msg("막힘", 0.4)


func _swing(d: int) -> void:
	if cool > 0.0:
		return
	sw_t = 0.18
	var g: Array = GUARD[d]
	sw_gp = g[0]
	sw_ga = g[1]
	if mode != "fight":
		beep(300.0, 0.05, 150.0, 0.1)
		return
	match fs:
		1:
			var rem := win - st
			if blocked:
				beep(300.0, 0.05, 150.0, 0.1)
			elif d == md and rem <= GUARD_W:
				_parry(rem <= PERFECT)
			else:
				# 너무 이르거나 틀린 쪽: 칼이 묶인다
				cool = 0.28
				beep(300.0, 0.05, 150.0, 0.1)
				if d == md:
					msg("이르다", 0.35)
		2:
			_strike(d)
			if d != odir:
				beep(260.0, 0.1, 200.0, 0.15)
				_rest()
			elif cur == 1 and has_double:
				# 쌍검은 한 번 베면 다른 칼로 막는다. 되돌려 한 번 더.
				beep(1300.0, 0.04, 900.0, 0.18)
				fs = 3
				st = 0.0
				owin = bp * 0.8
				odir = OPP[odir]
				_open(odir)
			else:
				_cut()
				msg("베기!", 0.35)
		3:
			_strike(d)
			if d == odir:
				_cut()
				msg("두 번 베기!", 0.5)
			else:
				_clank()
				_rest()
		_:
			beep(300.0, 0.05, 150.0, 0.1)


func _strike(d: int) -> void:
	var c: Vector3 = CUT_AT[d]
	sw_gp = Vector3(c.x * 0.4, 1.2, -1.1)
	sw_ga = hero.to_local(piv[cur].position + c + Vector3(-c.x * 0.6, 0, -0.6))
	hero_fl = -0.9
	beep(500.0, 0.06, 1400.0, 0.16)


func _parry(perfect: bool) -> void:
	blocked = true
	perf = perfect
	beep(1500.0, 0.05, 0.0, 0.25)
	beep(2100.0, 0.09, 1600.0, 0.15)
	bodies[cur].material_override = mat(WHITE)
	flash_t = 0.1
	fl.z -= 0.35
	ind_red.visible = false
	if perfect:
		slow = 0.8
		floors[cur].material_override = mat(B)
		beep(200.0, 0.4, 90.0, 0.22)
		msg("간파", 0.6)


func _cut() -> void:
	pips[cur][ph * 2 + cut].visible = false
	score += 1
	cut += 1
	play("good")
	bodies[cur].material_override = mat(GOOD)
	flash_t = 0.15
	fl = Vector3(0, 0, -1.0)
	fs = 5
	st = 0.0
	ind_good.visible = false
	if cut < 2:
		return
	cut = 0
	if ph < 2:
		ph += 1
		ci = 0
		mi = 0
		mode = "shift"
		mode_t = 1.2
		msg("%d단 · 더 빠르게" % (ph + 1), 1.0)
		beep(440.0, 0.25, 880.0, 0.25)
		if ph == 2:
			for e: MeshInstance3D in eyes[cur]:
				e.material_override = mat(BAD)
	else:
		mode = "fall"
		mode_t = 1.4
		msg("승리", 1.2)
		play("win")
		bank = score


func _after_fall() -> void:
	if cur == 0:
		stage = 1
		has_double = true
		my_col = D
		sw_box.material_override = mat(D)
		mode = "learn"
		mode_t = 1.6
		msg("두 번 베기 습득", 1.6)
		beep(990.0, 0.3, 1480.0, 0.25)
	else:
		# 이 조각은 도장 둘까지. 다음 판은 처음부터.
		msg("두 도장 돌파", 2.5)
		mode = "done"
		stage = 0
		has_double = false
		bank = 0
		time_limit = 0.001  # end()가 승리 소리를 내게
		end()
		time_limit = 0.0


func _walk(dt: float) -> void:
	walk_s = minf(1.0, walk_s + dt / WALK_T)
	var s := smoothstep(0.0, 1.0, walk_s)
	var h0: Vector3 = HERO[0]
	var h1: Vector3 = HERO[1]
	hbase = h0.lerp(h1, s) + Vector3(sin(PI * s) * 1.4, absf(sin(walk_s * WALK_T * 8.0)) * 0.08, 0)
	foot_t -= dt
	if foot_t <= 0.0 and walk_s < 1.0:
		foot_t = 0.28
		beep(170.0 if int(walk_s * 40.0) % 2 == 0 else 210.0, 0.05, 120.0, 0.14)
	if walk_s >= 1.0:
		cur = 1
		_begin_duel()


func _tap(p: Vector2) -> void:
	start = p
	armed = true


func _drag(p: Vector2) -> void:
	if not armed:
		return
	var v := p - start
	if v.length() < SWIPE:
		return
	armed = false
	if absf(v.x) > absf(v.y):
		_swing(0 if v.x < 0.0 else 1)
	else:
		_swing(2 if v.y < 0.0 else 3)


func _lift(_p: Vector2) -> void:
	armed = false
