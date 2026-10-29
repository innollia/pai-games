extends Tofu
## 일격의 길: 빨간 쪽으로 밀어 막고, 초록 쪽으로 밀어 벤다. 끝까지 기다렸다 막으면 '간파'(세상이 느려짐). 검객마다 체력 3단, 단마다 패턴이 바뀐다. 세 번 맞으면 그 도장 처음부터. 첫 검객을 꺾으면 반격을 배우고 산길을 올라 둘째 도장으로.

const SWIPE := 60.0
const OFF := [Vector3(-1.5, 0, 0.7), Vector3(1.5, 0, 0.7), Vector3(0, 1.75, 0.7), Vector3(0, -1.75, 0.7)]
const LEAN := [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, -1, 0)]
const OPP := [1, 0, 3, 2]
## 내 칼 자세 (카메라 기준): 위치, z 회전 (왼·오·위·아래)
const POSE := [Vector3(-0.8, -0.1, 2.5), Vector3(0.8, -0.1, 2.5), Vector3(0, 0.55, 2.5), Vector3(0, -0.85, 2.5)]
const TURN := [0.25, -0.25, PI / 2, PI / 2]
const REST_P := Vector3(0.55, -1.25, 2.5)
const REST_R := -0.6
const CAM_O := Vector3(0, 0.3, 5)
const BASE := [Vector3(0, 0, 0), Vector3(2.5, 5.0, -16)]
const NAMES := ["찌르기 검객", "속임수 검객"]
const BODY := [A, C]
const PERFECT := 0.2  # 칼이 닿기 이만큼 전 안에 막으면 간파
const SLOW := 0.3
const WALK_T := 3.4
## 검객 > 단 > [쉼, 빈틈, 연속기 목록]. 연속기 = [보이는 쪽, 진짜 쪽, 예비 시간]의 줄. 보이는 쪽≠진짜 쪽이면 반쯤에 바뀌는 속임수.
const PAT := [
	[
		[0.7, 0.7, [[[0, 0, 0.8]], [[1, 1, 0.8]], [[2, 2, 0.8]], [[3, 3, 0.8]]]],
		[0.6, 0.6, [[[0, 0, 0.6], [1, 1, 0.6]], [[2, 2, 0.6], [3, 3, 0.6]]]],
		[0.5, 0.55, [[[0, 0, 0.45], [2, 2, 0.45], [1, 1, 0.45]], [[3, 3, 0.45], [1, 1, 0.45], [0, 0, 0.45]]]],
	],
	[
		[0.8, 0.4, [[[2, 2, 1.2], [0, 0, 0.35]], [[3, 3, 1.2], [1, 1, 0.35]]]],
		[0.7, 0.35, [[[0, 1, 1.0]], [[2, 3, 1.0]], [[1, 1, 0.5]]]],
		[0.6, 0.3, [[[3, 2, 1.0], [0, 0, 0.3]], [[1, 1, 1.2], [2, 3, 0.7]]]],
	],
]

# 여행 진행 (죽어도 남는다)
var stage := 0
var has_counter := false
var bank := 0
# 장면
var piv: Array[Node3D] = []
var bodies: Array[MeshInstance3D] = []
var blades: Array[MeshInstance3D] = []
var eyes: Array = []
var pips: Array = []
var floors: Array[MeshInstance3D] = []
var mark: Node3D
var ind: Array[MeshInstance3D] = []
var rig: Node3D
var sword: MeshInstance3D
var my_col := WHITE
var cam_base := Vector3.ZERO
# 결투
var cur := 0
var mode := "intro"
var mode_t := 0.0
var life := 3
var ph := 0
var cut := 0
var ci := 0
var mi := 0
var fs := 0  # 0 쉼, 1 예비 동작, 2 빈틈, 3 내가 맞음, 4 상대 휘청
var fs_t := 0.0
var gap := 0.5
var win := 0.5
var rdir := 0
var sdir := 0
var odir := 0
var feint_at := -1.0
var fl := Vector3.ZERO
var slow := 0.0
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
	has_counter = false
	bank = 0


func _reset() -> void:
	piv.clear()
	bodies.clear()
	blades.clear()
	eyes.clear()
	pips.clear()
	floors.clear()
	_scenery()
	for i in 2:
		_foe(i)
	mark = Node3D.new()
	world.add_child(mark)
	ind.clear()
	for i in 4:
		var m := box(OFF[i], Vector3(0.6, 0.6, 0.6), BAD, mark)
		m.visible = false
		ind.append(m)
	rig = Node3D.new()
	world.add_child(rig)
	my_col = D if has_counter else WHITE
	sword = box(REST_P, Vector3(0.12, 1.7, 0.12), my_col, rig)
	sword.rotation.z = REST_R
	cur = stage
	if cur == 1:
		piv[0].rotation.x = -1.45
		piv[0].position = BASE[0] + Vector3(-1.6, -1.3, -1.5)
	score = bank
	slow = 0.0
	sw_t = 0.0
	flash_t = 0.0
	hurt_t = 0.0
	shake_t = 0.0
	armed = false
	_begin_duel()


func _begin_duel() -> void:
	life = 3
	ph = 0
	cut = 0
	ci = 0
	mi = 0
	fs = 0
	fs_t = 0.0
	fl = Vector3.ZERO
	mode = "intro"
	mode_t = 1.4
	msg(NAMES[cur], 1.4)
	cam_base = BASE[cur] + CAM_O
	cam.position = cam_base
	cam.look_at(BASE[cur])


func _scenery() -> void:
	for b: Vector3 in BASE:
		floors.append(box(b + Vector3(0, -1.9, -1), Vector3(8, 0.3, 8), SOFT))
		for s in [-1.0, 1.0]:
			box(b + Vector3(s * 2.8, 0.2, -3.5), Vector3(0.35, 4.2, 0.35), BAD)
		box(b + Vector3(0, 2.4, -3.5), Vector3(7.0, 0.35, 0.5), BAD)
		box(b + Vector3(0, 1.8, -3.5), Vector3(6.0, 0.2, 0.3), INK)
	# 산: 아래 언덕, 위 절벽 위 도장
	box(Vector3(0, -5.1, 0), Vector3(24, 6, 24), GOOD)
	box(Vector3(2.5, -1.1, -20), Vector3(24, 8, 16), GOOD)
	# 돌계단과 등불
	for i in 8:
		var f := (i + 0.5) / 8.0
		var top := lerpf(-1.75, 3.25, (i + 1) / 9.0)
		var x := lerpf(0.0, 2.5, f)
		box(Vector3(x, top - 2.0, -5.5 - i), Vector3(2.2, 4.0, 1.0), WHITE)
		if i % 2 == 1:
			for s in [-1.0, 1.0]:
				box(Vector3(x + s * 1.5, top + 0.4, -5.5 - i), Vector3(0.2, 0.8, 0.2), SOFT)
				box(Vector3(x + s * 1.5, top + 0.95, -5.5 - i), Vector3(0.45, 0.35, 0.45), D)
	# 나무
	for p: Vector3 in [Vector3(-5, 0, -2), Vector3(5.5, 0, -3), Vector3(-6, 0, 2), Vector3(-3.5, 5, -14), Vector3(7, 5, -15), Vector3(-2, 5, -22)]:
		box(p + Vector3(0, -1.3, 0), Vector3(0.35, 1.6, 0.35), INK)
		box(p + Vector3(0, 0.3, 0), Vector3(1.4, 1.8, 1.4), GOOD)
	# 먼 산
	for m: Vector3 in [Vector3(-12, 6, -45), Vector3(6, 10, -52), Vector3(20, 4, -42)]:
		box(m, Vector3(16, m.y * 2.0 + 6.0, 4), B)
		box(m + Vector3(0, m.y + 3.0, 0.2), Vector3(6, 2, 4), WHITE)


func _foe(i: int) -> void:
	var p := Node3D.new()
	world.add_child(p)
	p.position = BASE[i]
	piv.append(p)
	var e: Array[MeshInstance3D] = []
	if i == 0:
		bodies.append(box(Vector3.ZERO, Vector3(1.4, 2.8, 0.9), BODY[0], p))
		box(Vector3(0, 0.95, 0), Vector3(1.45, 0.18, 0.95), BAD, p)
	else:
		bodies.append(box(Vector3(0, -0.25, 0), Vector3(2.0, 2.3, 1.0), BODY[1], p))
		box(Vector3(0, 1.0, 0), Vector3(2.8, 0.18, 1.8), D, p)
		box(Vector3(0, 1.2, 0), Vector3(1.0, 0.25, 0.8), D, p)
	for s in [-1.0, 1.0]:
		e.append(box(Vector3(s * 0.33, 0.6, 0.5), Vector3(0.24, 0.24, 0.06), INK, p))
	eyes.append(e)
	var bl := box(Vector3(0.95, -0.3, 0.6), Vector3(0.12, 0.12, 1.6), WHITE, p)
	blades.append(bl)
	var pp: Array[MeshInstance3D] = []
	for k in 6:
		var x := (k - 2.5) * 0.3 + (floori(k / 2.0) - 1) * 0.18
		pp.append(box(Vector3(x, 1.85, 0), Vector3(0.24, 0.24, 0.24), BAD, p))
	pips.append(pp)


func _pat() -> Array:
	return PAT[cur][ph]


func _show(d: int, color: Color) -> void:
	for i in 4:
		ind[i].visible = i == d
	if d >= 0:
		ind[d].material_override = mat(color)


func _rest(g: float) -> void:
	fs = 0
	fs_t = 0.0
	gap = g
	_show(-1, BAD)


func _relax(dt: float) -> void:
	fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 10.0))
	piv[cur].rotation.z = lerpf(piv[cur].rotation.z, 0.0, minf(1.0, dt * 10.0))
	blades[cur].position = blades[cur].position.lerp(Vector3(0.95, -0.3, 0.6), minf(1.0, dt * 10.0))


func _step(dt: float) -> void:
	var fdt := dt
	if slow > 0.0:
		slow -= dt
		fdt = dt * SLOW
		if slow <= 0.0:
			floors[cur].material_override = mat(SOFT)
	mode_t -= dt
	match mode:
		"intro", "shift":
			_relax(dt)
			if mode_t <= 0.0:
				mode = "fight"
				_rest(0.5)
		"fight":
			_fight(fdt)
		"fall":
			var pv := piv[cur]
			pv.rotation.x = lerpf(pv.rotation.x, -1.45, minf(1.0, dt * 5.0))
			fl = fl.lerp(Vector3(-1.6, -1.3, -1.5), minf(1.0, dt * 5.0))
			if mode_t <= 0.0:
				_after_fall()
		"learn":
			if mode_t <= 0.0:
				mode = "walk"
				walk_s = 0.0
				foot_t = 0.0
				msg("간파하면 반격", 1.8)
		"walk":
			_walk(dt)
			if mode == "intro":
				return
	if mode != "walk":
		piv[cur].position = BASE[cur] + fl
	mark.position = piv[cur].position
	mark.rotation.z = piv[cur].rotation.z
	# 내 칼은 카메라를 따라간다
	rig.transform = Transform3D(cam.basis, cam_base) * Transform3D(Basis(), -CAM_O)
	if sw_t > 0.0:
		sw_t -= dt
	else:
		sword.position = sword.position.lerp(REST_P, minf(1.0, dt * 12.0))
		sword.rotation.z = lerpf(sword.rotation.z, REST_R, minf(1.0, dt * 12.0))
	if flash_t > 0.0:
		flash_t -= dt
		if flash_t <= 0.0:
			bodies[cur].material_override = mat(BODY[cur])
	if hurt_t > 0.0:
		hurt_t -= dt
		if hurt_t <= 0.0:
			sword.material_override = mat(my_col)
	cam.position = cam_base
	if shake_t > 0.0:
		shake_t -= dt
		cam.position += Vector3(randf_range(-0.12, 0.12), randf_range(-0.12, 0.12), 0)
	gauge(life / 3.0, GOOD if life > 1 else BAD)


func _fight(dt: float) -> void:
	fs_t += dt
	var k := 0.0
	match fs:
		0:
			_relax(dt)
			if fs_t >= gap:
				_attack()
		1:
			if feint_at >= 0.0 and fs_t >= feint_at and sdir != rdir:
				sdir = rdir
				_show(rdir, BAD)
				beep(880.0, 0.06, 500.0, 0.2)
			k = clampf(fs_t / win, 0.0, 1.0)
			var l: Vector3 = LEAN[sdir]
			fl = Vector3(l.x * 0.35 * k, l.y * 0.25 * k, 1.8 * k * k)
			piv[cur].rotation.z = -l.x * 0.25 * k
			var o: Vector3 = OFF[sdir]
			blades[cur].position = blades[cur].position.lerp(Vector3(o.x * 0.6, o.y * 0.6, 0.9), minf(1.0, dt * 14.0))
			ind[sdir].scale = Vector3.ONE * (0.75 - 0.45 * k)
			if fs_t >= win:
				_hurt()
		2:
			k = clampf(fs_t / win, 0.0, 1.0)
			fl = fl.lerp(Vector3(0, 0, -0.7), minf(1.0, dt * 14.0))
			ind[odir].scale = Vector3.ONE * (0.75 - 0.45 * k)
			if fs_t >= win:
				beep(260.0, 0.1, 200.0, 0.15)
				_rest(_pat()[0])
		3:
			if fs_t >= 0.5:
				_rest(_pat()[0])
		4:
			fl = fl.lerp(Vector3(0, 0, -0.9), minf(1.0, dt * 8.0))
			if fs_t >= 0.45:
				_rest(_pat()[0])


func _attack() -> void:
	var mv: Array = _pat()[2][ci][mi]
	sdir = mv[0]
	rdir = mv[1]
	win = mv[2]
	feint_at = win * 0.5 if sdir != rdir else -1.0
	fs = 1
	fs_t = 0.0
	_show(sdir, BAD)
	# 느린 예비 동작은 낮은 소리, 갑작스러운 건 높은 소리
	beep(lerpf(760.0, 300.0, clampf((win - 0.3) / 0.9, 0.0, 1.0)), 0.06, 0.0, 0.17)


func _hurt() -> void:
	life -= 1
	play("bad")
	msg("맞음", 0.4)
	sword.material_override = mat(BAD)
	hurt_t = 0.3
	shake_t = 0.22
	fs = 3
	fs_t = 0.0
	_show(-1, BAD)
	ci = (ci + 1) % _pat()[2].size()
	mi = 0
	if life <= 0:
		mode = "dead"
		msg("쓰러짐", 2.0)
		end()


func _swing(d: int) -> void:
	sword.position = POSE[d]
	sword.rotation.z = TURN[d]
	sw_t = 0.16
	if mode != "fight":
		beep(300.0, 0.05, 150.0, 0.1)
		return
	match fs:
		1:
			var fooled := feint_at >= 0.0 and fs_t < feint_at
			if d == rdir and not fooled:
				_parry(win - fs_t <= PERFECT)
			else:
				_hurt()
		2:
			if d == odir:
				_cut()
				msg("베기!", 0.35)
			else:
				beep(260.0, 0.1, 200.0, 0.15)
				_rest(_pat()[0])
		_:
			beep(300.0, 0.05, 150.0, 0.1)


func _parry(perfect: bool) -> void:
	beep(1500.0, 0.05, 0.0, 0.25)
	beep(2100.0, 0.09, 1600.0, 0.15)
	bodies[cur].material_override = mat(WHITE)
	flash_t = 0.1
	fl = Vector3(0, 0, -0.4)
	var combos: Array = _pat()[2]
	mi += 1
	if perfect:
		slow = 0.7
		floors[cur].material_override = mat(B)
		beep(200.0, 0.4, 90.0, 0.22)
		msg("간파", 0.6)
		if has_counter:
			ci = (ci + 1) % combos.size()
			mi = 0
			msg("간파 반격", 0.6)
			_cut()
			return
	if mi < combos[ci].size():
		_rest(0.12)
		return
	ci = (ci + 1) % combos.size()
	mi = 0
	fs = 2
	fs_t = 0.0
	win = _pat()[1] * (1.8 if perfect else 1.0)
	odir = OPP[rdir]
	_show(odir, GOOD)


func _cut() -> void:
	pips[cur][ph * 2 + cut].visible = false
	score += 1
	cut += 1
	play("good")
	bodies[cur].material_override = mat(GOOD)
	flash_t = 0.15
	fl = Vector3(0, 0, -1.2)
	fs = 4
	fs_t = 0.0
	_show(-1, BAD)
	if cut < 2:
		return
	cut = 0
	if ph < 2:
		ph += 1
		ci = 0
		mi = 0
		mode = "shift"
		mode_t = 1.2
		msg("%d단" % (ph + 1), 1.0)
		beep(440.0, 0.25, 220.0, 0.25)
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
		has_counter = true
		my_col = D
		sword.material_override = mat(D)
		mode = "learn"
		mode_t = 1.6
		msg("반격 습득", 1.6)
		beep(990.0, 0.3, 1480.0, 0.25)
	else:
		# 여행 한 바퀴 끝 (이 조각은 도장 둘까지). 다음 판은 처음부터.
		msg("두 도장 돌파", 2.5)
		mode = "done"
		stage = 0
		has_counter = false
		bank = 0
		time_limit = 0.001  # end()가 승리 소리를 내게
		end()
		time_limit = 0.0


func _walk(dt: float) -> void:
	walk_s = minf(1.0, walk_s + dt / WALK_T)
	var s := smoothstep(0.0, 1.0, walk_s)
	var b0: Vector3 = BASE[0]
	var b1: Vector3 = BASE[1]
	cam_base = (b0 + CAM_O).lerp(b1 + CAM_O, s) + Vector3(0, absf(sin(walk_s * WALK_T * 7.0)) * 0.12, 0)
	cam.position = cam_base
	cam.look_at(b0.lerp(b1, s))
	foot_t -= dt
	if foot_t <= 0.0 and walk_s < 1.0:
		foot_t = 0.32
		beep(170.0 if int(walk_s * 30.0) % 2 == 0 else 210.0, 0.05, 120.0, 0.14)
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
