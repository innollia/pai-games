extends Tofu
## 퀵실버 시티(등뒤 3인칭): 건물이 폭발한 순간 세상이 거의 멈춘다. 사람·잔해·문을 탭하면 그곳으로 순간 질주하고 카메라가 등 뒤를 따라간다. 드래그로 몸을 돌린다. 사람(파랑)을 업어 초록 문으로 내보내고, 날아오는 잔해(보라)는 탭해서 떨구거나 밀어낸다. 질주마다 속도력(막대)이 줄고 바닥나면 시간이 제 속도로 돌아와 안에 남은 사람이 모두 다친다. 사무실 폭발 → 강화 고르기 → 불타는 복도, 한 방에서 2명 이상 다치면 끝.

const MAXP := 8
const MAXR := 10
const MAXT := 10
const MAXF := 6
const MAXD := 24
const NDUST := 28
const DASH := 42.0
const SLOW := 0.25  # 재난 중 세상 빠르기
const SNAP := 3.5  # 속도력이 바닥난 뒤 세상 빠르기
const SNAP_REAL := 1.4  # 바닥난 뒤 몰아치는 실제 초
const CLOCK := 10.0
const ALLOW := 1
const ROOM_NAME := ["사무실 폭발", "불타는 복도"]
const UP_NAME := ["업기+1", "속도력+", "절약", "내열"]
const PLAY := 0
const RESULT := 1
const PICK := 2

var room := 0
var mode := PLAY
var wt := 0.0  # 재난 시계(세상 초)
var tick_s := 0
var snapped := false
var snap_t := 0.0
var pw := 0.0
var pw_max := 100.0
var cap := 2
var thrift := 1.0
var heatproof := false
var n_saved := 0
var n_hurt := 0
var n_ppl := 0
var mode_t := 0.0
var failed := false
var opts: Array[int] = [0, 1]
var rng := RandomNumberGenerator.new()
# 방
var rx0 := -6.0
var rx1 := 6.0
var rz0 := -12.0
var rz1 := 2.0
var door_p := Vector2.ZERO
var ex := Vector2.ZERO  # 폭발 한가운데
var fire_z := 0.0  # 복도 불길 앞
var crackle := 0.0
# 나
var me: MeshInstance3D
var me_p := Vector2.ZERO
var from_p := Vector2.ZERO
var goal := Vector2.ZERO
var dashing := false
var act_i := -1  # 도착하면 칠 잔해
var carry: Array[int] = []
var yaw := 0.0
var cam_p := Vector3.ZERO
var look_p := Vector3.ZERO
var trail_t := 0.0
var tr: Array[MeshInstance3D] = []
var tr_t := PackedFloat32Array()
var tr_i := 0
# 누르기·드래그
var press_p := Vector2.ZERO
var press_yaw := 0.0
var dragged := false
# 사람: 0 없음, 1 서 있음, 2 업힘, 3 다침, 4 구함
var ppl: Array[MeshInstance3D] = []
var p_s := PackedInt32Array()
var p_xz := PackedVector2Array()
# 잔해: 종류 0 날아오는 조각, 1 떨어지는 천장판
var rk: Array[MeshInstance3D] = []
var rk_sh: Array[MeshInstance3D] = []
var rk_on: Array[bool] = []
var rk_down: Array[bool] = []
var rk_kind := PackedInt32Array()
var rk_land := PackedFloat32Array()
var rk_p := PackedVector3Array()
var rk_v := PackedVector3Array()
# 불, 배경, 고르기
var fb: Array[MeshInstance3D] = []
var deco: Array[MeshInstance3D] = []
var n_deco := 0
var dust: Array[MeshInstance3D] = []
var opt_box: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 1000.0
	cam.fov = 60.0
	howto = "사람·잔해·문을 탭하면 그곳으로 순간 질주. 드래그로 몸을 돌린다.\n사람(파랑)을 업어 초록 문으로 내보내고, 날아오는 잔해(보라)는 탭해서 떨군다.\n질주마다 속도력이 준다. 바닥나거나 10초가 끝나면 안에 남은 사람이 다친다. 2명 다치면 끝."


func _reset() -> void:
	time_limit = 1000.0
	t = CLOCK
	me = box(Vector3.ZERO, Vector3(0.6, 1.2, 0.45), ME)
	tr.clear()
	tr_t.resize(MAXT)
	for i in MAXT:
		tr.append(box(Vector3.ZERO, Vector3(0.6, 1.2, 0.45), B))
		tr[i].visible = false
		tr_t[i] = 0.0
	ppl.clear()
	p_s.resize(MAXP)
	p_xz.resize(MAXP)
	for i in MAXP:
		ppl.append(box(Vector3.ZERO, Vector3(0.5, 1.1, 0.4), B))
	rk.clear()
	rk_sh.clear()
	rk_on.clear()
	rk_down.clear()
	rk_kind.resize(MAXR)
	rk_land.resize(MAXR)
	rk_p.resize(MAXR)
	rk_v.resize(MAXR)
	for i in MAXR:
		rk.append(box(Vector3.ZERO, Vector3.ONE, C))
		rk_sh.append(box(Vector3.ZERO, Vector3(1.2, 0.03, 1.2), INK))
		rk_on.append(false)
		rk_down.append(false)
	fb.clear()
	for i in MAXF:
		fb.append(box(Vector3.ZERO, Vector3.ONE, A))
	deco.clear()
	for i in MAXD:
		deco.append(box(Vector3.ZERO, Vector3.ONE, WHITE))
	dust.clear()
	for i in NDUST:
		dust.append(box(Vector3.ZERO, Vector3(0.07, 0.07, 0.07), INK))
	opt_box.clear()
	for k in 2:
		opt_box.append(box(Vector3.ZERO, Vector3(1.5, 1.5, 0.3), B if k == 0 else D))
	cap = 2
	pw_max = 100.0
	thrift = 1.0
	heatproof = false
	failed = false
	_begin(0)


# ---- 방 차리기 ----
func _begin(r: int) -> void:
	room = r
	mode = PLAY
	wt = 0.0
	tick_s = 0
	snapped = false
	pw = pw_max
	n_saved = 0
	n_hurt = 0
	n_ppl = 0
	dashing = false
	carry.clear()
	for i in MAXP:
		p_s[i] = 0
		ppl[i].visible = false
	for i in MAXR:
		rk_on[i] = false
		rk[i].visible = false
		rk_sh[i].visible = false
	for m in fb:
		m.visible = false
		m.rotation = Vector3.ZERO
	for m in deco:
		m.visible = false
	n_deco = 0
	for m in opt_box:
		m.visible = false
	rng.seed = 777 + r
	if r == 0:
		rx0 = -6.0
		rx1 = 6.0
		rz0 = -12.5
	else:
		rx0 = -3.5
		rx1 = 3.5
		rz0 = -19.0
	rz1 = 2.0
	_build_room()
	if r == 0:
		_room_office()
	else:
		_room_hall()
	for m in dust:
		m.position = Vector3(rng.randf_range(rx0, rx1), rng.randf_range(0.3, 2.6), rng.randf_range(rz0, rz1))
	me_p = Vector2(0, rz1 - 1.6)
	goal = me_p
	yaw = 0.0
	_cam_update(1.0)
	msg(ROOM_NAME[r], 1.6)
	beep(90.0, 0.7, 40.0, 0.32)
	_place()


func _build_room() -> void:
	var w := rx1 - rx0
	var d := rz1 - rz0
	var cx := (rx0 + rx1) * 0.5
	var cz := (rz0 + rz1) * 0.5
	_deco(Vector3(cx, -0.1, cz), Vector3(w, 0.2, d), SOFT)
	_deco(Vector3(rx0 - 0.15, 1.5, cz), Vector3(0.3, 3.0, d), WHITE)
	_deco(Vector3(rx1 + 0.15, 1.5, cz), Vector3(0.3, 3.0, d), WHITE)
	_deco(Vector3(cx, 1.5, rz0 - 0.15), Vector3(w + 0.6, 3.0, 0.3), WHITE)
	var side := (w - 2.6) * 0.5
	_deco(Vector3(rx0 + side * 0.5, 1.5, rz1 + 0.15), Vector3(side, 3.0, 0.3), WHITE)
	_deco(Vector3(rx1 - side * 0.5, 1.5, rz1 + 0.15), Vector3(side, 3.0, 0.3), WHITE)
	_deco(Vector3(0, 1.2, rz1 + 0.2), Vector3(2.6, 2.4, 0.2), GOOD)
	door_p = Vector2(0, rz1 - 0.7)


func _room_office() -> void:
	# 안쪽 회의실에서 터졌다. 불덩이가 아주 천천히 부풀고, 조각이 사람 쪽으로 떠 온다.
	ex = Vector2(1.0, -10.0)
	for q in [Vector2(-3.5, -7.5), Vector2(3.5, -7.0), Vector2(-3.5, -3.5), Vector2(3.0, -3.0), Vector2(0.0, -5.5)]:
		_deco(Vector3(q.x, 0.38, q.y), Vector3(1.8, 0.75, 0.9), WHITE)
	_deco(Vector3(rx0 + 0.05, 1.6, -6.0), Vector3(0.1, 1.2, 3.0), B)
	_deco(Vector3(rx1 - 0.05, 1.6, -6.0), Vector3(0.1, 1.2, 3.0), B)
	for q in [Vector2(2.6, -11.6), Vector2(4.6, -9.8), Vector2(-4.2, -9.4), Vector2(-1.4, -6.6), Vector2(3.4, -5.0), Vector2(-4.6, -2.4)]:
		_person(q.x, q.y)
	for k in 8:
		var aim: Vector2
		if k < n_ppl:
			aim = p_xz[k] + Vector2(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.3, 0.3))
		else:
			aim = ex + Vector2.from_angle(rng.randf_range(0.0, PI)) * 5.0
		var dir := (aim - ex).normalized()
		var s := rng.randf_range(0.9, 1.4)
		_chunk(Vector3(ex.x + dir.x * 1.3, rng.randf_range(0.8, 1.7), ex.y + dir.y * 1.3), Vector3(dir.x * s, 0, dir.y * s))
	fb[0].material_override = mat(D)
	fb[1].material_override = mat(A)
	fb[2].material_override = mat(A)
	fb[3].material_override = mat(BAD)
	for k in 4:
		fb[k].visible = true


func _room_hall() -> void:
	# 2층 복도. 끝에서 불길이 밀려오고 천장판이 하나씩 떨어진다.
	for k in 4:
		var z := -16.0 + k * 4.0
		_deco(Vector3(rx0 + 0.05, 1.1, z), Vector3(0.1, 2.2, 1.2), D)
		_deco(Vector3(rx1 - 0.05, 1.1, z + 2.0), Vector3(0.1, 2.2, 1.2), D)
	var spots := [Vector2(-2.2, -16.5), Vector2(2.0, -14.0), Vector2(-1.8, -11.5), Vector2(1.6, -9.0), Vector2(-2.4, -6.5), Vector2(2.4, -4.5), Vector2(0.0, -13.0)]
	for q in spots:
		_person(q.x, q.y)
	var lands := [3.0, 4.0, 5.5, 6.5, 7.5, 8.5]
	var who := [1, 2, 3, 4, 5, 6]
	for k in 6:
		var q: Vector2 = p_xz[who[k]]
		_slab(Vector2(q.x * 0.6, q.y + rng.randf_range(-0.3, 0.3)), lands[k])
	fb[0].material_override = mat(A)
	for k in MAXF:
		fb[k].visible = true
		if k > 0:
			fb[k].material_override = mat([BAD, A, D][k % 3])
	crackle = 0.5


func _person(x: float, z: float) -> int:
	var j := n_ppl
	n_ppl += 1
	p_s[j] = 1
	p_xz[j] = Vector2(x, z)
	var m := ppl[j]
	m.visible = true
	m.material_override = mat(B)
	m.scale = Vector3(0.5, 1.1, 0.4)
	m.rotation = Vector3(0, rng.randf_range(-0.5, 0.5), 0)
	m.position = Vector3(x, 0.55, z)
	return j


func _free_rock() -> int:
	for i in MAXR:
		if not rk_on[i]:
			return i
	return MAXR - 1


func _chunk(p: Vector3, v: Vector3) -> void:
	var i := _free_rock()
	rk_on[i] = true
	rk_down[i] = false
	rk_kind[i] = 0
	rk_p[i] = p
	rk_v[i] = v
	rk[i].visible = true
	rk[i].scale = Vector3(0.7, 0.55, 0.6)
	rk[i].rotation = Vector3(rng.randf() * TAU, rng.randf() * TAU, 0)
	rk_sh[i].visible = true
	rk_sh[i].scale = Vector3(0.6, 0.03, 0.6)


func _slab(q: Vector2, land: float) -> void:
	var i := _free_rock()
	rk_on[i] = true
	rk_down[i] = false
	rk_kind[i] = 1
	rk_land[i] = land
	rk_p[i] = Vector3(q.x, 2.7, q.y)
	rk_v[i] = Vector3.ZERO
	rk[i].visible = true
	rk[i].scale = Vector3(1.8, 0.25, 1.4)
	rk[i].rotation = Vector3(0, rng.randf_range(-0.3, 0.3), 0)
	rk_sh[i].visible = true


func _deco(pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var m := deco[n_deco]
	n_deco += 1
	m.visible = true
	m.position = pos
	m.scale = size
	m.rotation = Vector3.ZERO
	m.material_override = mat(color)
	return m


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	if dashing:
		var dir := goal - me_p
		if dir.length() > 0.05:
			yaw = lerp_angle(yaw, atan2(-dir.x, -dir.y), 1.0 - exp(-14.0 * dt))
		me_p = me_p.move_toward(goal, DASH * dt)
		trail_t -= dt
		if trail_t <= 0.0:
			trail_t = 0.02
			var m := tr[tr_i]
			m.visible = true
			m.position = _v3(me_p, 0.6)
			m.rotation.y = yaw
			tr_t[tr_i] = 0.25
			tr_i = (tr_i + 1) % MAXT
		if me_p.distance_to(goal) < 0.01:
			dashing = false
			_arrive()
	for i in MAXT:
		if tr_t[i] > 0.0:
			tr_t[i] -= dt
			var k := maxf(tr_t[i], 0.0) / 0.25
			tr[i].scale = Vector3(0.6 * k, 1.2 * k, 0.45)
			tr[i].visible = tr_t[i] > 0.0
	if mode == PLAY:
		_world(dt * (SNAP if snapped else SLOW), dt)
	elif mode == RESULT:
		t = CLOCK
		mode_t -= dt
		if mode_t <= 0.0:
			_after()
	else:
		t = CLOCK
	_place()
	_cam_update(dt)
	gauge(pw / pw_max, B if pw > pw_max * 0.3 else BAD)


func _cam_update(dt: float) -> void:
	var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
	var me3 := _v3(me_p, 0.0)
	var want := me3 - fwd * 3.0 + Vector3(0, 1.45, 0)
	want.x = clampf(want.x, rx0 + 0.25, rx1 - 0.25)
	want.z = clampf(want.z, rz0 + 0.25, rz1 - 0.25)
	var aim := me3 + fwd * 5.0 + Vector3(0, 0.75, 0)
	if dt >= 1.0:
		cam_p = want
		look_p = aim
	else:
		cam_p = cam_p.lerp(want, 1.0 - exp(-9.0 * dt))
		look_p = look_p.lerp(aim, 1.0 - exp(-16.0 * dt))
	cam.position = cam_p
	cam.look_at(look_p)
	cam.fov = lerpf(cam.fov, 78.0 if dashing else 60.0, minf(1.0, 10.0 * dt))


func _world(wd: float, dt: float) -> void:
	wt += wd
	if int(wt) > tick_s and wt < CLOCK:
		tick_s = int(wt)
		beep(900.0 if snapped else 1600.0, 0.03, 0.0, 0.16)
	_rocks(wd)
	if room == 0:
		_fireball()
	else:
		_hall_fire(wd)
	for m in dust:
		m.rotation.y = wt * 0.6
	t = maxf(CLOCK - wt, 0.2)
	if snapped:
		snap_t -= dt
		if snap_t <= 0.0:
			_finish()
			return
	if wt >= CLOCK:
		_finish()


func _rocks(wd: float) -> void:
	for i in MAXR:
		if not rk_on[i] or rk_down[i]:
			continue
		if rk_kind[i] == 0:
			var p := rk_p[i] + rk_v[i] * wd
			rk_p[i] = p
			rk[i].position = p
			rk[i].rotation.x += wd * 1.5
			rk[i].rotation.z += wd * 0.9
			rk_sh[i].position = Vector3(p.x, 0.02, p.z)
			if p.x < rx0 + 0.3 or p.x > rx1 - 0.3 or p.z < rz0 + 0.3 or p.z > rz1 - 0.3:
				_drop(i)
				beep(150.0, 0.1, 70.0, 0.18)
				continue
			for j in MAXP:
				if p_s[j] == 1 and p_xz[j].distance_to(Vector2(p.x, p.z)) < 0.75:
					_hurt(j, true)
					_drop(i)
					break
		else:
			var y := minf((rk_land[i] - wt) * 1.1, 2.45) + 0.25
			var q := Vector2(rk_p[i].x, rk_p[i].z)
			rk[i].position = _v3(q, maxf(y, 0.13))
			rk_sh[i].position = _v3(q, 0.02)
			var k := 1.0 - clampf((y - 0.25) / 2.45, 0.0, 1.0)
			rk_sh[i].scale = Vector3(0.6 + k * 1.2, 0.03, 0.5 + k * 0.9)
			if y <= 0.25:
				_drop(i)
				var hit := false
				for j in MAXP:
					if p_s[j] == 1 and p_xz[j].distance_to(q) < 1.0:
						_hurt(j, true)
						hit = true
				if not hit:
					beep(120.0, 0.16, 50.0, 0.22)


func _drop(i: int) -> void:
	rk_down[i] = true
	rk_sh[i].visible = false
	var q := Vector2(rk_p[i].x, rk_p[i].z)
	if rk_kind[i] == 0:
		rk[i].rotation = Vector3(0, rk[i].rotation.y, 0)
		rk[i].scale = Vector3(0.8, 0.3, 0.7)
		rk[i].position = _v3(q, 0.15)
	else:
		rk[i].position = _v3(q, 0.13)


func _fireball() -> void:
	var r := _fire_r()
	var h := minf(r * 0.9, 2.9)
	fb[1].scale = Vector3(r * 2.0, h, r * 2.0)
	fb[1].position = _v3(ex, h * 0.5)
	fb[2].scale = Vector3(r * 2.0, h * 0.9, r * 2.0)
	fb[2].position = _v3(ex, h * 0.45)
	fb[2].rotation.y = PI * 0.25 + wt * 0.05
	fb[0].scale = Vector3(r * 1.2, h * 1.05, r * 1.2)
	fb[0].position = _v3(ex, h * 0.52)
	fb[3].scale = Vector3(r * 1.7, h * 0.7, r * 1.7)
	fb[3].position = _v3(ex, h * 0.35)
	fb[3].rotation.y = wt * 0.1
	for j in MAXP:
		if p_s[j] == 1 and p_xz[j].distance_to(ex) < r:
			_hurt(j, true)


func _fire_r() -> float:
	return 0.8 + wt * 0.8


func _hall_fire(wd: float) -> void:
	fire_z = rz0 + 1.0 + wt * 1.7
	var w := rx1 - rx0
	var burnt := fire_z - rz0
	fb[0].scale = Vector3(w, 0.06, maxf(burnt, 0.01))
	fb[0].position = Vector3((rx0 + rx1) * 0.5, 0.03, rz0 + burnt * 0.5)
	for k in range(1, MAXF):
		var x := rx0 + w * (k - 0.5) / (MAXF - 1)
		var h := 1.6 + sin(wt * 2.0 + k * 1.7) * 0.5
		fb[k].scale = Vector3(w / (MAXF - 1) * 1.05, h, 0.9)
		fb[k].position = Vector3(x, h * 0.5, fire_z)
	for j in MAXP:
		if p_s[j] == 1 and p_xz[j].y < fire_z:
			_hurt(j, true)
	crackle -= wd
	if crackle <= 0.0:
		crackle = 0.5
		beep(240.0, 0.08, 150.0, 0.1)


func _place() -> void:
	me.position = _v3(me_p, 0.6)
	me.rotation.y = yaw
	for k in carry.size():
		var m := ppl[carry[k]]
		m.position = _v3(me_p, 1.45 + k * 0.45)
		m.rotation = Vector3(0, yaw + PI * 0.5, 0)


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	if mode == PICK:
		if p.y > 260.0:
			_choose(0 if p.x < 360.0 else 1)
		return
	press_p = p
	press_yaw = yaw
	dragged = false


func _drag(p: Vector2) -> void:
	if mode != PLAY:
		return
	if not dragged and p.distance_to(press_p) > 28.0:
		dragged = true
	if dragged and not dashing:
		yaw = press_yaw - (p.x - press_p.x) * 0.006


func _lift(_p: Vector2) -> void:
	if mode == PLAY and not dragged:
		_pick(press_p)


func _pick(p: Vector2) -> void:
	if dashing:
		return
	if snapped:
		msg("속도 끝")
		beep(160.0, 0.1, 0.0, 0.2)
		return
	# 손가락 크기만큼 넉넉하게: 사람, 잔해, 문 중 가장 가까운 것
	var bd := 120.0
	var kind := -1
	var bi := -1
	var bto := Vector2.ZERO
	for i in MAXP:
		if p_s[i] == 1:
			var d := _screen_d(_v3(p_xz[i], 0.6), p)
			if d < bd:
				bd = d
				kind = 0
				bi = i
				bto = p_xz[i]
	for i in MAXR:
		if rk_on[i] and not rk_down[i]:
			var q := Vector2(rk_p[i].x, rk_p[i].z)
			var d := minf(_screen_d(rk[i].position, p), _screen_d(_v3(q, 0.0), p))
			if d < bd:
				bd = d
				kind = 1
				bi = i
				bto = q
	var dd := _screen_d(Vector3(door_p.x, 1.2, rz1), p)
	if dd < bd:
		kind = 2
		bto = door_p
	if kind == 0 and carry.size() >= cap:
		msg("가득")
		beep(200.0, 0.1, 0.0, 0.2)
		return
	if kind >= 0:
		_dash(bto, bi if kind == 1 else -1)
		return
	if cam.project_ray_normal(p).y < -0.05:
		var g := ground(p)
		_dash(Vector2(clampf(g.x, rx0 + 0.4, rx1 - 0.4), clampf(g.z, rz0 + 0.4, rz1 - 0.4)), -1)


func _screen_d(pos: Vector3, p: Vector2) -> float:
	if cam.is_position_behind(pos):
		return 9999.0
	return cam.unproject_position(pos).distance_to(p)


func _dash(to: Vector2, rock: int) -> void:
	var dist := me_p.distance_to(to)
	if dist < 0.3 and rock < 0:
		return
	var cost := (4.0 + dist * 0.45) * thrift
	if _burns(me_p, to):
		if not heatproof:
			cost += 14.0
		msg("앗 뜨거")
	pw -= cost
	from_p = me_p
	goal = to
	act_i = rock
	dashing = true
	trail_t = 0.0
	beep(300.0, 0.07, 1800.0, 0.15)


func _burns(a: Vector2, b: Vector2) -> bool:
	if room == 0:
		var ab := b - a
		var k := 0.0
		if ab.length_squared() > 0.0001:
			k = clampf((ex - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
		return (a + ab * k).distance_to(ex) < _fire_r()
	return minf(a.y, b.y) < fire_z


func _arrive() -> void:
	if mode != PLAY:
		return
	if act_i >= 0 and rk_on[act_i] and not rk_down[act_i]:
		_knock(act_i)
	for j in MAXP:
		if carry.size() >= cap:
			break
		if p_s[j] == 1 and p_xz[j].distance_to(me_p) < 1.4:
			p_s[j] = 2
			carry.append(j)
			ppl[j].scale = Vector3(0.45, 0.4, 1.0)
			beep(600.0 + carry.size() * 150.0, 0.07, 0.0, 0.22)
	if me_p.distance_to(door_p) < 2.0 and not carry.is_empty():
		for j in carry:
			p_s[j] = 4
			ppl[j].visible = false
			n_saved += 1
			score += 1
		msg("%d명" % carry.size())
		play("good")
		carry.clear()
	if pw <= 0.0:
		_snap()


func _knock(i: int) -> void:
	if rk_kind[i] == 0:
		# 공중의 조각을 쳐서 바닥에 떨군다
		_drop(i)
		beep(180.0, 0.1, 400.0, 0.25)
		msg("탁")
	else:
		# 천장판을 가까운 벽 쪽으로 밀어 둔다
		var x := rx0 + 0.9 if rk_p[i].x < (rx0 + rx1) * 0.5 else rx1 - 0.9
		rk_p[i].x = x
		beep(160.0, 0.12, 320.0, 0.25)
		msg("휙")


# ---- 속도력 바닥, 방 끝, 다음 방 ----
func _snap() -> void:
	snapped = true
	snap_t = SNAP_REAL
	msg("속도 끝!", 2.0)
	beep(90.0, 0.6, 40.0, 0.32)


func _hurt(j: int, loud: bool) -> void:
	if p_s[j] == 2:
		carry.erase(j)
		p_xz[j] = me_p + Vector2(randf_range(-0.6, 0.6), randf_range(-0.6, 0.6))
	p_s[j] = 3
	n_hurt += 1
	var m := ppl[j]
	m.material_override = mat(BAD)
	m.rotation = Vector3(0, m.rotation.y, 0)
	m.scale = Vector3(0.9, 0.2, 0.5)
	m.position = _v3(p_xz[j], 0.1)
	if loud:
		play("bad")


func _finish() -> void:
	# 시간이 제 속도로 돌아왔다: 안에 남은 사람은 모두 다친다
	for j in MAXP:
		if p_s[j] == 1 or p_s[j] == 2:
			_hurt(j, false)
	carry.clear()
	dashing = false
	beep(80.0, 0.7, 40.0, 0.35)
	mode = RESULT
	mode_t = 2.4
	failed = n_hurt > ALLOW
	msg("구함 %d\n다침 %d" % [n_saved, n_hurt], 2.4)


func _after() -> void:
	if failed:
		time_limit = 0.0  # 실패 소리가 나게
		end()
		return
	if room >= 1:
		end()
		return
	mode = PICK
	var pool: Array[int] = [0, 1, 2, 3]
	pool.shuffle()
	opts = [pool[0], pool[1]]
	var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
	var right := Vector3(cos(yaw), 0, -sin(yaw))
	for k in 2:
		var m := opt_box[k]
		m.visible = true
		m.position = cam_p + fwd * 3.2 + right * (-0.9 if k == 0 else 0.9) + Vector3(0, -0.4, 0)
		m.rotation = Vector3(0, yaw, 0)
	msg("%s    %s" % [UP_NAME[opts[0]], UP_NAME[opts[1]]], 999.0)
	beep(700.0, 0.15, 1000.0, 0.2)


func _choose(k: int) -> void:
	match opts[k]:
		0: cap += 1
		1: pw_max += 30.0
		2: thrift *= 0.75
		3: heatproof = true
	play("good")
	_begin(room + 1)


# ---- 도구 ----
func _v3(v: Vector2, y: float) -> Vector3:
	return Vector3(v.x, y, v.y)
