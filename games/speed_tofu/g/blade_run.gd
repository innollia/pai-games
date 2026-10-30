extends Tofu
## 달리는 결투 (일격의 길 × 화면 밖 경주, 옆모습): 검객과 나란히 오른쪽으로 달리며 싸운다. 카메라는 앞선 쪽을 따라간다.
## 빨간 쪽으로 밀면 막고, 초록 쪽으로 밀면 벤다. 위로 밀면 뛴다(높은 공격 막기와 같은 손짓). 맞으면 속도가 확 꺾여 뒤처진다.
## 뒤처져 화면 왼쪽 밖으로 밀리면 죽음. 끝까지 기다렸다 막으면 간파: 상대가 비틀거려 느려지고 내가 앞선다. 느리면 장애물에 걸리고 틈에 빠진다.
## 검객 3명 × 트랙 3개(들판 → 다리 → 지붕). 여섯 번 베면 다음 트랙. 내가 앞서면 화면이 나한테 쏠려 앞이 거의 안 보인다.

const SWIPE := 60.0
const PERFECT := 0.2
const RANGE := 3.4  # 이 안에서만 칼이 닿는다
const MY_TOP := 10.0
const ACC := 7.0
const HOP_V := 9.0
const GRAV := 30.0
const HURDLE_V := 7.5  # 이보다 느리면 장애물에 걸리고 틈에 빠진다
const CAM_D := 20.0
const WIDE := 12.0
const NARROW := 7.5
const TRACK_LEN := 1500.0
const OFF := [Vector2(-1.4, 0.7), Vector2(1.4, 0.7), Vector2(0, 2.3), Vector2(0, -0.25)]
const OPP := [1, 0, 3, 2]
## 내 칼 자세 (내 몸 기준): 위치, z 회전 (왼·오·위·아래)
const POSE := [Vector2(-0.9, 0.8), Vector2(0.9, 0.8), Vector2(0.15, 1.9), Vector2(0.5, -0.05)]
const TURN := [1.3, -1.3, 0.0, PI / 2]
const REST_P := Vector2(0.55, 0.35)
const REST_R := -0.6
const NAMES := ["거한 검객", "장검 검객", "쌍검 검객"]
const TRACKS := ["들판", "다리", "지붕"]
const BODY := [A, C, D]
## 검객: 뒤에서 쫓아올 때 최고 속도, 몸 크기. 앞서 달릴 땐 나보다 조금 느리게 뛰며 기다린다(붙으면 나보다 반 발 앞에서 민다).
const FOE := [[10.5, Vector3(1.3, 1.6, 0.7)], [12.0, Vector3(0.9, 1.4, 0.6)], [13.5, Vector3(0.8, 1.2, 0.6)]]
## 검객 > 단 > [쉼, 빈틈, 연속기 목록]. 연속기 = [보이는 쪽, 진짜 쪽, 예비 시간]. 보이는 쪽≠진짜 쪽이면 반쯤에 바뀌는 속임수.
const PAT := [
	[
		[0.9, 0.8, [[[2, 2, 0.9]], [[3, 3, 0.9]], [[1, 1, 0.9]]]],
		[0.7, 0.7, [[[2, 2, 0.7], [3, 3, 0.7]], [[0, 0, 0.7], [2, 2, 0.7]]]],
		[0.6, 0.6, [[[3, 3, 0.5], [2, 2, 0.5], [1, 1, 0.5]], [[0, 0, 0.5], [3, 3, 0.5]]]],
	],
	[
		[0.8, 0.6, [[[1, 1, 0.7]], [[0, 0, 0.7]], [[2, 2, 0.55], [1, 1, 0.55]]]],
		[0.7, 0.5, [[[2, 3, 1.0]], [[1, 1, 0.5], [0, 0, 0.5]], [[3, 3, 0.45]]]],
		[0.55, 0.45, [[[0, 1, 0.9], [2, 2, 0.4]], [[3, 3, 0.4], [1, 1, 0.4], [2, 2, 0.4]]]],
	],
	[
		[0.6, 0.5, [[[0, 0, 0.5], [1, 1, 0.5]], [[2, 2, 0.5], [3, 3, 0.5]]]],
		[0.5, 0.45, [[[1, 0, 0.8], [3, 3, 0.4]], [[2, 2, 0.35], [2, 2, 0.35], [3, 3, 0.35]]]],
		[0.45, 0.4, [[[3, 2, 0.8], [0, 0, 0.3], [1, 1, 0.3]], [[1, 1, 0.3], [0, 0, 0.3], [2, 3, 0.7]]]],
	],
]

# 여행 진행 (죽어도 남는다)
var stage := 0
var bank := 0
# 장면
var mnode: Node3D
var mlegs: Array[MeshInstance3D] = []
var sw: MeshInstance3D
var fnode: Node3D
var fbody: MeshInstance3D
var flegs: Array[MeshInstance3D] = []
var fsword: MeshInstance3D
var feyes: Array[MeshInstance3D] = []
var fpips: Array[MeshInstance3D] = []
var ind: Array[MeshInstance3D] = []
var hurdles := PackedFloat32Array()
var gaps: Array[Vector2] = []
var edge_strip: MeshInstance3D
var floor_boxes: Array[MeshInstance3D] = []
var floor_col := SOFT
# 달리기
var my_x := 0.0
var my_y := 0.0
var my_v := 0.0
var my_vy := 0.0
var my_ph := 0.0
var my_h := 0
var my_g := 0
var fx := 0.0
var fy := 0.0
var fv := 0.0
var fvy := 0.0
var f_ph := 0.0
var f_h := 0
var f_g := 0
var slow_t := 0.0  # 간파로 비틀거리는 시간
var lean := 0.0
var camx := 0.0
var hwv := WIDE
var lead_t := 0.0
var rt := 0.0
var shk := 0.0
var tick := 0.0
# 결투
var mode := "intro"
var mode_t := 0.0
var ph := 0
var cut := 0
var ci := 0
var mi := 0
var fs := 0  # 0 쉼, 1 예비 동작, 2 빈틈, 3 내가 맞음, 4 상대 휘청
var fs_t := 0.0
var gap_t := 0.5
var win := 0.5
var rdir := 0
var sdir := 0
var odir := 0
var feint_at := -1.0
var sw_t := 0.0
var flash_t := 0.0
var hurt_t := 0.0
var start := Vector2.ZERO
var armed := false


func _setup() -> void:
	howto = "검객과 나란히 달리며 싸운다. 카메라는 앞선 쪽을 따라간다.\n빨간 쪽으로 밀면 막고, 초록 쪽으로 밀면 벤다. 위로 밀면 뛴다.\n맞으면 속도가 꺾여 뒤처지고, 화면 왼쪽 밖으로 밀리면 죽음.\n끝까지 기다렸다 막으면 간파: 상대가 느려져 내가 앞선다."
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	stage = 0
	bank = 0


func _reset() -> void:
	score = bank
	_build_track()
	_make_me()
	_make_foe()
	ind.clear()
	for i in 4:
		var m := box(Vector3(OFF[i].x, OFF[i].y, 0.6), Vector3(0.55, 0.55, 0.55), BAD, fnode)
		m.visible = false
		ind.append(m)
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	my_x = 0.0
	my_y = 0.0
	my_v = 4.0
	my_vy = 0.0
	my_h = 0
	my_g = 0
	fx = 1.5
	fy = 0.0
	fv = 4.0
	fvy = 0.0
	f_h = 0
	f_g = 0
	slow_t = 0.0
	lean = 0.0
	camx = 0.0
	hwv = WIDE
	lead_t = 0.0
	rt = 0.0
	shk = 0.0
	sw_t = 0.0
	flash_t = 0.0
	hurt_t = 0.0
	armed = false
	ph = 0
	cut = 0
	ci = 0
	mi = 0
	fs = 0
	fs_t = 0.0
	mode = "intro"
	mode_t = 1.3
	msg("%s · %s" % [TRACKS[stage], NAMES[stage]], 1.3)
	beep(440.0, 0.12)


# ---- 트랙 ----
func _build_track() -> void:
	hurdles = PackedFloat32Array()
	gaps.clear()
	floor_boxes.clear()
	var gen := RandomNumberGenerator.new()
	gen.seed = 1234 + stage * 77
	match stage:
		0:
			floor_col = Color("c3fae8")
			_floor(-60.0, TRACK_LEN + 400.0)
			var x := 30.0
			while x < TRACK_LEN:
				hurdles.append(x)
				box(Vector3(x, 0.3, 0), Vector3(0.6, 0.6, 1.6), INK)
				x += gen.randf_range(16.0, 26.0)
			# 나무와 먼 언덕
			x = -40.0
			while x < TRACK_LEN + 40.0:
				var h := gen.randf_range(2.5, 4.5)
				var z := -4.0 - gen.randf() * 4.0
				box(Vector3(x, h * 0.3, z), Vector3(0.4, h * 0.6, 0.4), INK)
				box(Vector3(x, h, z), Vector3(2.0 + gen.randf(), 2.2, 2.0), GOOD)
				x += gen.randf_range(7.0, 13.0)
			for i in 12:
				var mx := -30.0 + i * 150.0
				box(Vector3(mx, 6.0, -40.0), Vector3(60.0, 18.0, 6.0), B)
				box(Vector3(mx, 15.5, -39.8), Vector3(14.0, 3.0, 6.0), WHITE)
		1:
			floor_col = Color("ffe8cc")
			_floor(-60.0, TRACK_LEN + 400.0)
			var x := 24.0
			while x < TRACK_LEN:
				hurdles.append(x)
				box(Vector3(x, 0.4, 0), Vector3(0.8, 0.8, 0.8), Color("e599f7"))
				x += gen.randf_range(11.0, 18.0)
			# 난간과 물
			box(Vector3(TRACK_LEN * 0.5, -10.0, -6.0), Vector3(TRACK_LEN + 600.0, 12.0, 60.0), B)
			x = -40.0
			while x < TRACK_LEN + 40.0:
				box(Vector3(x, 1.0, -1.3), Vector3(0.25, 2.0, 0.25), A)
				box(Vector3(x, 1.95, -1.3), Vector3(8.0, 0.18, 0.18), A)
				box(Vector3(x, -3.5, -1.0), Vector3(1.4, 7.0, 1.4), SOFT)
				x += 8.0
			for i in 10:
				box(Vector3(i * 160.0, 10.0, -30.0), Vector3(50.0, 24.0, 6.0), Color("d0ebff"))
		_:
			floor_col = Color("e5dbff")
			var x := -60.0
			var first := true
			while x < TRACK_LEN:
				var w := 80.0 if first else gen.randf_range(22.0, 40.0)
				first = false
				_floor(x, w)
				# 굴뚝은 지붕 안쪽, 장애물도 하나
				box(Vector3(x + w * 0.5, 1.0, -1.1), Vector3(1.0, 2.0, 1.0), BAD)
				if w > 26.0:
					hurdles.append(x + w * 0.3)
					box(Vector3(x + w * 0.3, 0.3, 0), Vector3(0.6, 0.6, 1.2), INK)
				x += w
				var g := gen.randf_range(2.2, 3.4)
				gaps.append(Vector2(x, x + g))
				x += g
			_floor(x, 500.0)
			for i in 10:
				box(Vector3(i * 160.0 + 40.0, 12.0, -40.0), Vector3(40.0, 40.0, 8.0), Color("dbe4ff"))
				box(Vector3(i * 160.0 - 40.0, 6.0, -25.0), Vector3(20.0, 24.0, 6.0), Color("ffdeeb"))


func _floor(x: float, w: float) -> void:
	floor_boxes.append(box(Vector3(x + w * 0.5, -0.15, 0), Vector3(w, 0.3, 3.0), floor_col))
	box(Vector3(x + w * 0.5, -6.3, -0.3), Vector3(w, 12.0, 2.6), WHITE)


func _make_me() -> void:
	mnode = Node3D.new()
	world.add_child(mnode)
	box(Vector3(0, 0.95, 0), Vector3(0.7, 1.0, 0.55), ME, mnode)
	box(Vector3(0, 1.7, 0), Vector3(0.45, 0.45, 0.45), SOFT, mnode)
	box(Vector3(0.05, 1.98, 0), Vector3(0.6, 0.14, 0.6), WHITE, mnode)
	mlegs.clear()
	for s in [-1.0, 1.0]:
		mlegs.append(box(Vector3(0, 0.25, s * 0.15), Vector3(0.22, 0.5, 0.22), INK, mnode))
	sw = box(Vector3(REST_P.x, REST_P.y, 0.4), Vector3(0.1, 1.5, 0.1), WHITE, mnode)
	sw.rotation.z = REST_R


func _make_foe() -> void:
	var sz: Vector3 = FOE[stage][1]
	fnode = Node3D.new()
	world.add_child(fnode)
	fbody = box(Vector3(0, 0.45 + sz.y * 0.5, 0), sz, BODY[stage], fnode)
	box(Vector3(0, 0.75 + sz.y, 0), Vector3(0.45, 0.45, 0.45), SOFT, fnode)
	feyes.clear()
	for s in [-1.0, 1.0]:
		feyes.append(box(Vector3(-0.1 + s * 0.08, 0.78 + sz.y, 0.24), Vector3(0.08, 0.1, 0.04), INK, fnode))
	flegs.clear()
	for s in [-1.0, 1.0]:
		flegs.append(box(Vector3(0, 0.25, s * 0.16), Vector3(0.24, 0.5, 0.24), INK, fnode))
	fsword = box(Vector3(-0.6, 0.6 + sz.y * 0.5, 0.45), Vector3(0.1, 1.6 if stage == 1 else 1.2, 0.1), WHITE, fnode)
	fsword.rotation.z = -0.5
	if stage == 2:
		var sw2 := box(Vector3(0.6, 0.6 + sz.y * 0.5, 0.45), Vector3(0.1, 1.1, 0.1), WHITE, fnode)
		sw2.rotation.z = 0.5
	fpips.clear()
	for k in 6:
		var px := (k - 2.5) * 0.3 + (floori(k / 2.0) - 1) * 0.16
		fpips.append(box(Vector3(px, 1.25 + sz.y, 0), Vector3(0.22, 0.22, 0.22), BAD, fnode))


func _pat() -> Array:
	return PAT[stage][ph]


func _show(d: int, color: Color) -> void:
	for i in 4:
		ind[i].visible = i == d
	if d >= 0:
		ind[d].material_override = mat(color)
		ind[d].scale = Vector3.ONE * 0.75


func _rest(g: float) -> void:
	fs = 0
	fs_t = 0.0
	gap_t = g
	_show(-1, BAD)


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	shk = maxf(shk - dt * 2.5, 0.0)
	mode_t -= dt
	match mode:
		"intro":
			if mode_t <= 0.0:
				mode = "run"
				msg("달려!", 0.6)
				play("good")
				_rest(1.0)
		"run":
			rt += dt
			_run(dt)
			if mode != "run":
				return
		"fall":
			my_v = move_toward(my_v, MY_TOP, ACC * dt)
			my_x += my_v * dt
			fv = move_toward(fv, 0.0, 12.0 * dt)
			fx += fv * dt
			fnode.rotation.z = lerpf(fnode.rotation.z, 1.3, minf(1.0, dt * 5.0))
			if mode_t <= 0.0:
				_next_track()
				return
	_camera(dt)
	_draw(dt)


func _run(dt: float) -> void:
	# 내 몸: 최고 속도로 돌아가려 한다 (맞고 비틀거리는 동안은 못 밟는다)
	if fs != 3:
		my_v = move_toward(my_v, MY_TOP, ACC * dt)
	# 검객: 뒤에 있으면 전력으로 쫓고, 앞에 있으면 나보다 조금 느리게 뛰며 기다린다. 칼 거리 안에선 반 발 앞에서 민다.
	var ftop: float = FOE[stage][0]
	var jog := minf(ftop * 0.85, MY_TOP - 1.5)
	var dx := fx - my_x
	if dx > RANGE:
		ftop = jog
	elif dx > -RANGE:
		ftop = maxf(my_v + 0.4, jog)
	if slow_t > 0.0:
		slow_t -= dt
		ftop *= 0.25
	fv = move_toward(fv, ftop, (ACC + 2.0) * dt)
	# 장애물·틈 (둘 다)
	_obstacles(dt)
	if mode != "run":
		return
	my_x += my_v * dt
	fx += fv * dt
	# 결투 (칼이 닿는 거리 안에서만 흐른다)
	_fight(dt)
	if mode != "run":
		return
	# 화면 폭은 시간이 갈수록 좁아진다
	hwv = lerpf(WIDE, NARROW, clampf((rt - 8.0) / 30.0, 0.0, 1.0))
	# 뒤처져 화면 밖
	var left := camx - hwv
	var ed := my_x + 0.35 - left
	gauge(clampf(ed / (hwv * 2.0), 0.0, 1.0), GOOD if ed > hwv * 0.6 else (A if ed > 2.5 else BAD))
	tick -= dt
	if ed < 3.5 and tick <= 0.0:
		tick = 0.08 + ed * 0.07
		beep(1200.0 - ed * 150.0, 0.04, 0.0, 0.14)
	if ed < 0.0:
		_die("밀려났다")
	if my_x > fx:
		if lead_t == 0.0:
			msg("앞섰다! 앞이 안 보인다", 0.8)
			beep(900.0, 0.1, 1400.0, 0.2)
		lead_t += dt
	else:
		lead_t = 0.0


func _obstacles(dt: float) -> void:
	# 나
	my_vy -= GRAV * dt
	my_y = maxf(my_y + my_vy * dt, 0.0)
	if my_y == 0.0:
		my_vy = maxf(my_vy, 0.0)
	while my_h < hurdles.size() and my_x + my_v * dt >= hurdles[my_h]:
		my_h += 1
		if my_y > 0.25:
			continue
		if my_v >= HURDLE_V:
			my_vy = HOP_V * 0.6
			beep(700.0, 0.05, 1000.0, 0.1)
		else:
			my_v *= 0.35
			shk = 0.4
			beep(180.0, 0.15, 80.0, 0.25)
			msg("걸림", 0.4)
	while my_g < gaps.size() and my_x + my_v * dt >= gaps[my_g].x:
		if my_y > 0.25 or my_v >= HURDLE_V:
			my_g += 1
			if my_y <= 0.25:
				my_vy = HOP_V * 0.8
				beep(700.0, 0.05, 1000.0, 0.1)
		else:
			_die("떨어짐")
			return
	# 검객
	fvy -= GRAV * dt
	fy = maxf(fy + fvy * dt, 0.0)
	if fy == 0.0:
		fvy = maxf(fvy, 0.0)
	while f_h < hurdles.size() and fx + fv * dt >= hurdles[f_h]:
		f_h += 1
		if fy > 0.25:
			continue
		if fv >= HURDLE_V:
			fvy = HOP_V * 0.6
		else:
			fv *= 0.35
			beep(180.0, 0.15, 80.0, 0.18)
	while f_g < gaps.size() and fx + fv * dt >= gaps[f_g].x:
		f_g += 1
		if fy > 0.25:
			continue
		if fv >= HURDLE_V:
			fvy = HOP_V * 0.8
		else:
			# 가장자리를 붙잡고 기어오른다: 크게 느려진다
			fv = 1.0
			fx = gaps[f_g - 1].y + 0.5
			beep(180.0, 0.15, 80.0, 0.18)


func _near() -> bool:
	return absf(fx - my_x) < RANGE


func _fight(dt: float) -> void:
	fs_t += dt
	var k := 0.0
	match fs:
		0:
			lean = lerpf(lean, 0.0, minf(1.0, dt * 10.0))
			if slow_t <= 0.0 and _near() and fs_t >= gap_t:
				_attack()
		1:
			if feint_at >= 0.0 and fs_t >= feint_at and sdir != rdir:
				sdir = rdir
				_show(rdir, BAD)
				beep(880.0, 0.06, 500.0, 0.2)
			k = clampf(fs_t / win, 0.0, 1.0)
			lean = -signf(fx - my_x) * 0.45 * k * k
			ind[sdir].scale = Vector3.ONE * (0.75 - 0.45 * k)
			if fs_t >= win:
				if _near():
					_hurt()
				else:
					beep(260.0, 0.1, 200.0, 0.12)
					_rest(_pat()[0])
		2:
			k = clampf(fs_t / win, 0.0, 1.0)
			lean = lerpf(lean, 0.3, minf(1.0, dt * 8.0))
			ind[odir].scale = Vector3.ONE * (0.75 - 0.45 * k)
			if fs_t >= win:
				beep(260.0, 0.1, 200.0, 0.15)
				_rest(_pat()[0])
		3:
			if fs_t >= 0.5:
				_rest(_pat()[0])
		4:
			lean = lerpf(lean, 0.5, minf(1.0, dt * 8.0))
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
	beep(lerpf(760.0, 300.0, clampf((win - 0.3) / 0.9, 0.0, 1.0)), 0.06, 0.0, 0.17)


## 맞음: 목숨이 아니라 속도를 잃는다. 느려지면 화면 끝으로 밀린다.
func _hurt() -> void:
	play("bad")
	msg("맞음", 0.4)
	my_v *= 0.25
	my_x -= 0.8
	sw.material_override = mat(BAD)
	hurt_t = 0.3
	shk = 0.5
	fs = 3
	fs_t = 0.0
	_show(-1, BAD)
	ci = (ci + 1) % _pat()[2].size()
	mi = 0


func _swing(d: int) -> void:
	sw.position = Vector3(POSE[d].x, POSE[d].y, 0.4)
	sw.rotation.z = TURN[d]
	sw_t = 0.16
	if d == 2 and my_y <= 0.01:
		my_vy = HOP_V
		beep(600.0, 0.07, 900.0, 0.12)
	if mode != "run":
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
			if d == odir and _near():
				_cut()
				msg("베기!", 0.35)
			else:
				beep(260.0, 0.1, 200.0, 0.15)
				_rest(_pat()[0])
		_:
			if d != 2:
				beep(300.0, 0.05, 150.0, 0.1)


func _parry(perfect: bool) -> void:
	beep(1500.0, 0.05, 0.0, 0.25)
	beep(2100.0, 0.09, 1600.0, 0.15)
	fbody.material_override = mat(WHITE)
	flash_t = 0.1
	my_v = minf(my_v + 1.5, MY_TOP + 2.0)  # 받아친 힘이 발을 민다
	var combos: Array = _pat()[2]
	mi += 1
	if perfect:
		slow_t = 1.1
		fv *= 0.4
		for fb in floor_boxes:
			fb.material_override = mat(B)
		beep(200.0, 0.4, 90.0, 0.22)
		msg("간파", 0.6)
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
	fpips[ph * 2 + cut].visible = false
	score += 1
	cut += 1
	play("good")
	fbody.material_override = mat(GOOD)
	flash_t = 0.15
	fv *= 0.3
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
		msg("%d단" % (ph + 1), 1.0)
		beep(440.0, 0.25, 220.0, 0.25)
		if ph == 2:
			for e in feyes:
				e.material_override = mat(BAD)
	else:
		mode = "fall"
		mode_t = 1.6
		_show(-1, BAD)
		score += 10
		msg("승리", 1.2)
		play("win")
		bank = score


func _next_track() -> void:
	stage += 1
	if stage >= 3:
		msg("세 길 돌파", 2.5)
		mode = "done"
		stage = 0
		bank = 0
		time_limit = 0.001  # end()가 승리 소리를 내게
		end()
		time_limit = 0.0
		return
	restart()


func _die(why: String) -> void:
	mode = "dead"
	msg(why, 2.0)
	shk = 0.6
	end()


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	var asp := vs.y / maxf(vs.x, 1.0)
	var lead_x := maxf(my_x, fx)
	var off := 0.16
	if my_x > fx:
		off = lerpf(0.16, 0.74, clampf(lead_t / 1.5, 0.0, 1.0))
	if mode == "fall":
		lead_x = my_x
		off = 0.3
	var k := 1.0 - exp(-9.0 * dt)
	camx = lerpf(camx, lead_x - hwv * off, k)
	cam.fov = rad_to_deg(2.0 * atan(hwv / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, hwv * asp * 0.45 + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


func _draw(dt: float) -> void:
	# 나
	my_ph += my_v * dt * 1.6
	var bob := absf(sin(my_ph)) * 0.08 if my_y <= 0.01 else 0.0
	mnode.position = Vector3(my_x, my_y + bob, 0)
	mnode.rotation.z = -clampf(my_v * 0.015, 0.0, 0.2)
	for i in 2:
		mlegs[i].rotation.z = sin(my_ph + i * PI) * 0.8 if my_y <= 0.01 else 0.3
	if sw_t > 0.0:
		sw_t -= dt
	else:
		sw.position = sw.position.lerp(Vector3(REST_P.x, REST_P.y, 0.4), minf(1.0, dt * 12.0))
		sw.rotation.z = lerpf(sw.rotation.z, REST_R, minf(1.0, dt * 12.0))
	if hurt_t > 0.0:
		hurt_t -= dt
		if hurt_t <= 0.0:
			sw.material_override = mat(WHITE)
	# 검객
	f_ph += fv * dt * 1.6
	var fbob := absf(sin(f_ph)) * 0.08 if fy <= 0.01 else 0.0
	fnode.position = Vector3(fx + lean, fy + fbob, 0)
	if mode != "fall":
		fnode.rotation.z = -clampf(fv * 0.015, 0.0, 0.2) + (sin(rt * 30.0) * 0.15 if slow_t > 0.0 else 0.0)
	for i in 2:
		flegs[i].rotation.z = sin(f_ph + i * PI) * 0.8 if fy <= 0.01 else 0.3
	if flash_t > 0.0:
		flash_t -= dt
		if flash_t <= 0.0:
			fbody.material_override = mat(BODY[stage])
	if slow_t <= 0.0 and floor_boxes.size() > 0 and floor_boxes[0].material_override != mat(floor_col):
		for fb in floor_boxes:
			fb.material_override = mat(floor_col)
	# 왼쪽 화면 끝 경고 띠
	var ed := my_x - (camx - hwv)
	var k2 := (CAM_D - 1.6) / CAM_D
	edge_strip.visible = mode == "run" and ed < 4.0 and (ed > 2.0 or fmod(rt, 0.16) < 0.1)
	edge_strip.position = Vector3(camx - hwv * k2 + 0.18, cam.position.y, 1.6)
	edge_strip.scale = Vector3(0.35 + maxf(0.0, 4.0 - ed) * 0.1, hwv * 2.0, 0.2)


# ---- 입력 ----
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
