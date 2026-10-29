extends Tofu
## 퀵실버 시티 1구역 주택가: 재난 순간 세상이 거의 멈춘다. 탭한 곳으로 순간 질주해 사람(파랑)을 업고 아래 초록에 내려놓는다. 잔해(보라)는 탭해서 밀고, 차(주황)는 탭해서 틀고, 소화전(노랑)은 탭해서 터뜨린다. 질주마다 속도력(막대)이 줄고 바닥나면 세상이 제 속도로 돌아와 남은 재난이 한꺼번에 닥친다. 재난 시계 10초가 끝날 때 초록에 없는 사람은 잃는다. 붕괴 → 연쇄 추돌 → 화재, 사이마다 강화 하나 고르기, 3명 이상 잃으면 끝.

const MAXP := 10
const MAXR := 8
const MAXC := 7
const MAXT := 10
const MAXD := 14
const GN := 7
const CELL := 1.6
const FX0 := -4.8
const FZ0 := -6.4
const DASH := 60.0
const SLOW := 0.25  # 재난 중 세상 빠르기
const SNAP := 2.5  # 속도력이 바닥난 뒤 세상 빠르기(남은 재난이 몰아친다)
const CLOCK := 10.0
const SAFE_Z := 5.6
const FALL := 1.4
const ALLOW := 2
const STAGE_NAME := ["붕괴", "연쇄 추돌", "화재"]
const UP_NAME := ["업기+1", "속도력+", "절약", "손힘"]
const DC := [1, -1, 0, 0]
const DR := [0, 0, 1, -1]
const PLAY := 0
const RESULT := 1
const PICK := 2

var stage := 0
var phase := PLAY
var wt := 0.0  # 재난 시계(세상 초)
var tick_s := 0
var snapped := false
var pw := 0.0
var pw_max := 100.0
var cap := 2
var thrift := 1.0
var hand := 1.0
var n_saved := 0
var n_lost := 0
var n_ppl := 0
var phase_t := 0.0
var failed := false
var opts: Array[int] = [0, 1]
# 나
var me: MeshInstance3D
var me_p := Vector2.ZERO
var from_p := Vector2.ZERO
var goal := Vector2.ZERO
var dashing := false
var act := 0  # 도착하면: 0 그냥, 1 밀기, 2 틀기, 3 소화전
var act_i := -1
var carry: Array[int] = []
var trail_t := 0.0
var tr: Array[MeshInstance3D] = []
var tr_t := PackedFloat32Array()
var tr_i := 0
# 사람: 0 없음, 1 서 있음, 2 업힘, 3 잃음, 4 구함, 5 깔림
var ppl: Array[MeshInstance3D] = []
var p_s := PackedInt32Array()
var p_xz := PackedVector2Array()
# 잔해
var rk: Array[MeshInstance3D] = []
var rk_sh: Array[MeshInstance3D] = []
var rk_on: Array[bool] = []
var rk_down: Array[bool] = []
var rk_land := PackedFloat32Array()
var rk_pin := PackedInt32Array()
var rk_xz := PackedVector2Array()
var rk_to := PackedVector2Array()
# 차
var car: Array[MeshInstance3D] = []
var nose: Array[MeshInstance3D] = []
var c_on: Array[bool] = []
var c_p := PackedVector2Array()
var c_v := PackedVector2Array()
# 불: 0 없음, 1 불, 2 젖음
var cell: Array[MeshInstance3D] = []
var f_s := PackedInt32Array()
var f_age := PackedFloat32Array()
var f_next := 0.0
var rng := RandomNumberGenerator.new()
var hyd: Array[MeshInstance3D] = []
var h_on: Array[bool] = []
var h_cell := PackedInt32Array()
# 배경·시계·고르기
var deco: Array[MeshInstance3D] = []
var n_deco := 0
var clk: Array[MeshInstance3D] = []
var opt_box: Array[MeshInstance3D] = []
var opt_ic: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 1000.0
	cam.fov = 34.0
	cam.position = Vector3(0, 20, 7)
	cam.look_at(Vector3.ZERO)


func _reset() -> void:
	time_limit = 1000.0
	t = CLOCK
	box(Vector3(0, -0.1, -2), Vector3(14, 0.2, 26), SOFT)
	box(Vector3(0, 0.01, 7.6), Vector3(12, 0.05, 3.8), GOOD)
	me = box(Vector3.ZERO, Vector3(0.8, 1.2, 0.8), ME)
	tr.clear()
	tr_t.resize(MAXT)
	for i in MAXT:
		tr.append(box(Vector3.ZERO, Vector3(0.8, 1.2, 0.8), B))
		tr[i].visible = false
		tr_t[i] = 0.0
	ppl.clear()
	p_s.resize(MAXP)
	p_xz.resize(MAXP)
	for i in MAXP:
		ppl.append(box(Vector3.ZERO, Vector3(0.6, 1.0, 0.6), B))
	rk.clear()
	rk_sh.clear()
	rk_on.clear()
	rk_down.clear()
	rk_land.resize(MAXR)
	rk_pin.resize(MAXR)
	rk_xz.resize(MAXR)
	rk_to.resize(MAXR)
	for i in MAXR:
		rk.append(box(Vector3.ZERO, Vector3.ONE, C))
		rk_sh.append(box(Vector3.ZERO, Vector3(1.2, 0.04, 1.2), INK))
		rk_on.append(false)
		rk_down.append(false)
	car.clear()
	nose.clear()
	c_on.clear()
	c_p.resize(MAXC)
	c_v.resize(MAXC)
	for i in MAXC:
		car.append(box(Vector3.ZERO, Vector3(1.8, 0.9, 1.0), A))
		nose.append(box(Vector3.ZERO, Vector3(0.4, 0.4, 0.7), WHITE))
		c_on.append(false)
	cell.clear()
	f_s.resize(GN * GN)
	f_age.resize(GN * GN)
	for i in GN * GN:
		cell.append(box(Vector3.ZERO, Vector3(1.5, 1, 1.5), A))
	hyd.clear()
	h_on.clear()
	h_cell.resize(3)
	for i in 3:
		hyd.append(box(Vector3.ZERO, Vector3(0.7, 1.0, 0.7), D))
		h_on.append(false)
	deco.clear()
	for i in MAXD:
		deco.append(box(Vector3.ZERO, Vector3.ONE, WHITE))
	clk.clear()
	for i in 10:
		clk.append(box(Vector3(-4.5 + i * 1.0, 0.15, -8.4), Vector3(0.8, 0.3, 0.5), D))
	opt_box.clear()
	opt_ic.clear()
	for k in 2:
		opt_box.append(box(Vector3(-3.0 + k * 6.0, 2.5, 0.5), Vector3(5.4, 0.4, 8.0), WHITE))
		for n in 3:
			opt_ic.append(box(Vector3.ZERO, Vector3.ONE, B))
	stage = 0
	cap = 2
	pw_max = 100.0
	thrift = 1.0
	hand = 1.0
	failed = false
	_begin(0)


# ---- 재난 차리기 ----
func _begin(s: int) -> void:
	stage = s
	phase = PLAY
	wt = 0.0
	tick_s = 0
	snapped = false
	pw = pw_max
	n_saved = 0
	n_lost = 0
	n_ppl = 0
	me_p = Vector2(0, 7.0)
	goal = me_p
	dashing = false
	carry.clear()
	for i in MAXP:
		p_s[i] = 0
		ppl[i].visible = false
	for i in MAXR:
		rk_on[i] = false
		rk[i].visible = false
		rk_sh[i].visible = false
	for i in MAXC:
		c_on[i] = false
		car[i].visible = false
		nose[i].visible = false
	for i in GN * GN:
		f_s[i] = 0
		cell[i].visible = false
	for i in 3:
		h_on[i] = false
		hyd[i].visible = false
	for m in deco:
		m.visible = false
	n_deco = 0
	for m in opt_box:
		m.visible = false
	for m in opt_ic:
		m.visible = false
	for m in clk:
		m.material_override = mat(D)
	rng.seed = 4321 + s
	match s:
		0: _stage_collapse()
		1: _stage_crash()
		2: _stage_fire()
	msg(STAGE_NAME[s], 1.6)
	beep(110.0, 0.6, 50.0, 0.3)
	_place()


func _stage_collapse() -> void:
	# 위쪽 집들이 무너지는 중. 잔해가 공중에 멈춰 있고 두 사람은 들보에 깔려 있다.
	var cols := [A, D, B, C]
	for k in 4:
		var m := _deco(Vector3(-4.5 + k * 3.0, 1.5, -10.6), Vector3(2.4, 3.0, 1.8), cols[k])
		m.rotation.z = 0.25 if k == 1 else 0.0
	_person(-4.2, -5.6)
	_person(-3.3, -5.0)
	_person(1.4, -6.2)
	_person(2.3, -5.6)
	_person(4.4, -2.2)
	_beam(_person(-2.0, -1.0))
	_beam(_person(2.6, 0.8))
	_rock(-3.75, -5.3, 1.8)
	_rock(0.0, -3.2, 2.4)
	_rock(4.4, -2.2, 2.8)
	_rock(1.85, -5.9, 3.6)
	_rock(-2.0, -1.0, 5.0)
	_rock(2.6, 0.8, 6.5)


func _stage_crash() -> void:
	# 큰길에서 차들이 미끄러져 온다. 차끼리 부딪치면 맞은 차가 튕겨 나간다(연쇄).
	_deco(Vector3(0, 0.02, -2.0), Vector3(14, 0.04, 4.4), WHITE)
	for k in 5:
		_deco(Vector3(-5.0 + k * 2.5, 0.05, -2.0), Vector3(1.2, 0.04, 0.15), D)
	for k in 4:
		_deco(Vector3(-0.9 + k * 0.6, 0.05, -2.0), Vector3(0.3, 0.05, 4.0), SOFT)
	_deco(Vector3(3.6, 0.02, -6.5), Vector3(2.0, 0.04, 4.6), WHITE)
	_person(-0.3, -2.4)
	_person(0.6, -1.8)
	_person(-1.2, -3.2)
	_person(-3.8, -5.2)
	_person(3.6, -5.6)
	_person(-4.2, 1.6)
	_person(4.0, 2.0)
	_car(-6.0, -1.8, 1.5, 0.0)
	_car(6.2, -3.0, -1.3, 0.0)
	_car(3.6, -7.6, 0.0, 1.0)
	_car(-6.2, -3.6, 1.0, 0.0)
	_car(-6.0, -7.4, 0.8, 0.8)
	_car(6.2, -0.6, -1.1, 0.0)


func _stage_fire() -> void:
	# 불이 칸에서 칸으로 번진다. 불길을 지나 달리면 속도력이 크게 줄고, 소화전은 주변 3x3을 적신다.
	_ignite(1 * GN + 1)
	_ignite(1 * GN + 5)
	_ignite(3 * GN + 3)
	for cr in [Vector2i(0, 0), Vector2i(2, 2), Vector2i(6, 0), Vector2i(4, 2), Vector2i(1, 4), Vector2i(5, 4), Vector2i(3, 5), Vector2i(0, 6)]:
		var q := _cell_xz(cr.x, cr.y)
		_person(q.x + 0.3, q.y - 0.25)
	_hydrant(0, 1, 2)
	_hydrant(1, 4, 3)
	f_next = 0.8


func _person(x: float, z: float) -> int:
	var j := n_ppl
	n_ppl += 1
	p_s[j] = 1
	p_xz[j] = Vector2(x, z)
	var m := ppl[j]
	m.visible = true
	m.material_override = mat(B)
	m.scale = Vector3(0.6, 1.0, 0.6)
	m.position = Vector3(x, 0.5, z)
	return j


func _free_rock() -> int:
	for i in MAXR:
		if not rk_on[i]:
			return i
	return -1


func _beam(j: int) -> void:
	var i := _free_rock()
	rk_on[i] = true
	rk_down[i] = true
	rk_pin[i] = j
	rk_xz[i] = p_xz[j]
	rk_to[i] = p_xz[j]
	rk[i].visible = true
	rk[i].scale = Vector3(2.2, 0.5, 0.7)
	rk[i].rotation = Vector3(0, 0.5, 0)
	rk[i].position = _v3(p_xz[j], 0.75)
	p_s[j] = 5
	ppl[j].scale = Vector3(0.7, 0.5, 0.7)
	ppl[j].position.y = 0.25


func _rock(x: float, z: float, land: float) -> void:
	var i := _free_rock()
	rk_on[i] = true
	rk_down[i] = false
	rk_pin[i] = -1
	rk_land[i] = land
	rk_xz[i] = Vector2(x, z)
	rk_to[i] = Vector2(x, z)
	rk[i].visible = true
	rk[i].scale = Vector3(1.2, 0.9, 1.2)
	rk[i].rotation = Vector3(0, randf() * TAU, 0)
	rk_sh[i].visible = true


func _car(x: float, z: float, vx: float, vz: float) -> void:
	for i in MAXC:
		if not c_on[i]:
			c_on[i] = true
			c_p[i] = Vector2(x, z)
			c_v[i] = Vector2(vx, vz)
			car[i].visible = true
			car[i].material_override = mat(A)
			nose[i].visible = true
			_place_car(i)
			return


func _hydrant(k: int, c: int, r: int) -> void:
	h_on[k] = true
	h_cell[k] = r * GN + c
	hyd[k].visible = true
	hyd[k].position = _v3(_cell_xz(c, r), 0.5)


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
		me_p = me_p.move_toward(goal, DASH * dt)
		trail_t -= dt
		if trail_t <= 0.0:
			trail_t = 0.016
			var m := tr[tr_i]
			m.visible = true
			m.position = _v3(me_p, 0.6)
			tr_t[tr_i] = 0.22
			tr_i = (tr_i + 1) % MAXT
		if me_p.distance_to(goal) < 0.01:
			dashing = false
			_arrive()
	for i in MAXT:
		if tr_t[i] > 0.0:
			tr_t[i] -= dt
			var k := maxf(tr_t[i], 0.0) / 0.22
			tr[i].scale = Vector3(0.8 * k, 1.2 * k, 0.8 * k)
			tr[i].visible = tr_t[i] > 0.0
	if phase == PLAY:
		_world(dt * (SNAP if snapped else SLOW), dt)
	elif phase == RESULT:
		t = CLOCK
		phase_t -= dt
		if phase_t <= 0.0:
			_after()
	else:
		t = CLOCK
	_place()
	gauge(pw / pw_max, B if pw > pw_max * 0.3 else BAD)


func _world(wd: float, dt: float) -> void:
	wt += wd
	if int(wt) > tick_s and wt < CLOCK:
		tick_s = int(wt)
		beep(900.0 if snapped else 1600.0, 0.03, 0.0, 0.16)
	_rocks(dt)
	_cars(wd)
	if stage == 2:
		_fire(wd)
	for i in 10:
		var left := clampf(float(i + 1) - wt, 0.0, 1.0)
		clk[i].visible = left > 0.0
		clk[i].scale.x = 0.8 * left
		if snapped:
			clk[i].material_override = mat(BAD)
	t = maxf(CLOCK - wt, 0.2)
	if wt >= CLOCK:
		_finish()


func _rocks(dt: float) -> void:
	for i in MAXR:
		if not rk_on[i]:
			continue
		rk_xz[i] = rk_xz[i].move_toward(rk_to[i], 22.0 * dt)
		if rk_down[i]:
			rk[i].position = _v3(rk_xz[i], 0.75 if rk_pin[i] >= 0 else 0.25)
			continue
		var y := (rk_land[i] - wt) * FALL
		if y <= 0.0:
			_land(i)
			continue
		rk[i].position = _v3(rk_xz[i], minf(y, 9.0) + 0.45)
		rk[i].rotation.x = wt * 0.8 + i
		rk_sh[i].position = _v3(rk_xz[i], 0.03)
		var k := 1.0 - clampf(y / 10.0, 0.0, 1.0)
		rk_sh[i].scale = Vector3(0.5 + k, 0.04, 0.5 + k)


func _land(i: int) -> void:
	rk_down[i] = true
	rk_sh[i].visible = false
	rk[i].scale = Vector3(1.4, 0.5, 1.4)
	rk[i].rotation = Vector3(0, rk[i].rotation.y, 0)
	rk[i].position = _v3(rk_xz[i], 0.25)
	var hit := false
	for j in MAXP:
		if (p_s[j] == 1 or p_s[j] == 5) and p_xz[j].distance_to(rk_xz[i]) < 1.1:
			_lose(j, true)
			hit = true
	if not hit:
		beep(130.0, 0.14, 60.0, 0.2)


func _cars(wd: float) -> void:
	for i in MAXC:
		if not c_on[i] or c_v[i] == Vector2.ZERO:
			continue
		c_p[i] += c_v[i] * wd
		var q := c_p[i]
		if absf(q.x) > 6.3 or q.y < -8.0 or q.y > SAFE_Z - 0.7:
			c_p[i] = Vector2(clampf(q.x, -6.3, 6.3), clampf(q.y, -8.0, SAFE_Z - 0.7))
			_stop_car(i)
			continue
		for j in MAXP:
			if (p_s[j] == 1 or p_s[j] == 5) and p_xz[j].distance_to(c_p[i]) < 1.05:
				_lose(j, true)
		for k in MAXC:
			if k == i or not c_on[k]:
				continue
			var rel := c_p[k] - c_p[i]
			if rel.length() < 1.35 and rel.dot(c_v[i] - c_v[k]) > 0.0:
				# 맞은 차가 힘을 받아 튕겨 나간다
				c_v[k] = c_v[k] * 0.3 + c_v[i] * 0.85
				_stop_car(i)
				break
	for i in MAXC:
		if c_on[i]:
			_place_car(i)


func _stop_car(i: int) -> void:
	c_v[i] = Vector2.ZERO
	nose[i].visible = false
	car[i].material_override = mat(INK)
	beep(150.0, 0.16, 70.0, 0.22)


func _place_car(i: int) -> void:
	car[i].position = _v3(c_p[i], 0.45)
	var v := c_v[i]
	if v != Vector2.ZERO:
		var ang := atan2(-v.y, v.x)
		car[i].rotation.y = ang
		nose[i].rotation.y = ang
		nose[i].position = _v3(c_p[i] + v.normalized() * 1.0, 0.75)


func _fire(wd: float) -> void:
	for i in GN * GN:
		if f_s[i] == 1:
			f_age[i] += wd
			var h := 0.3 + minf(f_age[i], 2.0) * 0.6
			cell[i].scale = Vector3(1.5, h, 1.5)
			cell[i].position.y = h * 0.5
			if f_age[i] > 1.2:
				cell[i].material_override = mat(BAD)
	f_next -= wd
	if f_next > 0.0:
		return
	f_next = 0.8
	var add: Array[int] = []
	for r in GN:
		for c in GN:
			if f_s[r * GN + c] != 1:
				continue
			for d in 4:
				var nc: int = c + DC[d]
				var nr: int = r + DR[d]
				if nc < 0 or nc >= GN or nr < 0 or nr >= GN:
					continue
				var n := nr * GN + nc
				if f_s[n] == 0 and not add.has(n) and rng.randf() < 0.42:
					add.append(n)
	for n in add:
		_ignite(n)
	if not add.is_empty():
		beep(240.0, 0.1, 160.0, 0.12)


func _ignite(n: int) -> void:
	f_s[n] = 1
	f_age[n] = 0.0
	var m := cell[n]
	m.visible = true
	m.material_override = mat(A)
	m.position = _v3(_cell_xz(n % GN, n / GN), 0.15)
	m.scale = Vector3(1.5, 0.3, 1.5)
	for j in MAXP:
		if (p_s[j] == 1 or p_s[j] == 5) and _cell_of(p_xz[j]) == n:
			_lose(j, true)


func _wet(n: int) -> void:
	f_s[n] = 2
	var m := cell[n]
	m.visible = true
	m.material_override = mat(B)
	m.position = _v3(_cell_xz(n % GN, n / GN), 0.03)
	m.scale = Vector3(1.5, 0.06, 1.5)


func _place() -> void:
	me.position = _v3(me_p, 0.6)
	for k in carry.size():
		ppl[carry[k]].position = _v3(me_p, 1.45 + k * 0.55)


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	if phase == PICK:
		if p.y > 260.0:
			_choose(0 if p.x < 360.0 else 1)
		return
	if phase != PLAY or dashing:
		return
	if snapped:
		msg("속도 끝")
		beep(160.0, 0.1, 0.0, 0.2)
		return
	# 손가락 크기만큼 넉넉하게: 사람, 잔해, 차, 소화전 중 가장 가까운 것
	var bd := 115.0
	var ba := -1
	var bi := -1
	var bto := Vector2.ZERO
	for i in MAXP:
		if p_s[i] == 1:
			var d := cam.unproject_position(_v3(p_xz[i], 0.5)).distance_to(p)
			if d < bd:
				bd = d
				ba = 0
				bi = i
				bto = p_xz[i]
	for i in MAXR:
		if rk_on[i] and (not rk_down[i] or rk_pin[i] >= 0):
			var d := minf(cam.unproject_position(_v3(rk_xz[i], 0.0)).distance_to(p), cam.unproject_position(rk[i].position).distance_to(p))
			if d < bd:
				bd = d
				ba = 1
				bi = i
				bto = rk_xz[i]
	for i in MAXC:
		if c_on[i] and c_v[i] != Vector2.ZERO:
			var d := cam.unproject_position(_v3(c_p[i], 0.45)).distance_to(p)
			if d < bd:
				bd = d
				ba = 2
				bi = i
				bto = c_p[i]
	for i in 3:
		if h_on[i]:
			var d := cam.unproject_position(hyd[i].position).distance_to(p)
			if d < bd:
				bd = d
				ba = 3
				bi = i
				bto = _cell_xz(h_cell[i] % GN, h_cell[i] / GN)
	if ba == 0 and carry.size() >= cap:
		msg("가득")
		beep(200.0, 0.1, 0.0, 0.2)
		return
	if ba >= 0:
		_dash(bto, ba, bi)
		return
	var g := ground(p)
	_dash(Vector2(clampf(g.x, -5.6, 5.6), clampf(g.z, -8.0, 8.8)), 0, -1)


func _dash(to: Vector2, a: int, i: int) -> void:
	var dist := me_p.distance_to(to)
	var cost := (4.0 + dist * 0.4) * thrift
	if a > 0:
		cost *= hand
	var burn := _burn_cross(me_p, to)
	if burn > 0:
		cost += burn * 6.0
		msg("앗 뜨거")
	pw -= cost
	from_p = me_p
	goal = to
	act = a
	act_i = i
	dashing = true
	trail_t = 0.0
	beep(300.0, 0.07, 1800.0, 0.15)


func _arrive() -> void:
	if phase != PLAY:
		return
	match act:
		1: _push(act_i)
		2: _turn(act_i)
		3: _burst(act_i)
	for j in MAXP:
		if carry.size() >= cap:
			break
		if p_s[j] == 1 and p_xz[j].distance_to(me_p) < 1.4:
			p_s[j] = 2
			carry.append(j)
			ppl[j].scale = Vector3(0.9, 0.5, 0.6)
			beep(600.0 + carry.size() * 150.0, 0.07, 0.0, 0.22)
	if me_p.y > SAFE_Z and not carry.is_empty():
		for j in carry:
			p_s[j] = 4
			var k := n_saved
			n_saved += 1
			score += 1
			p_xz[j] = Vector2(-5.2 + (k % 9) * 1.3, 8.6 - (k / 9) * 1.0)
			ppl[j].scale = Vector3(0.5, 0.8, 0.5)
			ppl[j].position = _v3(p_xz[j], 0.4)
		msg("%d명" % carry.size())
		play("good")
		carry.clear()
	if pw <= 0.0:
		_snap()


func _push(i: int) -> void:
	var dir := rk_xz[i] - from_p
	dir = dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT
	var to := rk_xz[i] + dir * 2.6
	rk_to[i] = Vector2(clampf(to.x, -5.8, 5.8), clampf(to.y, -8.0, SAFE_Z - 0.8))
	if rk_pin[i] >= 0:
		var j := rk_pin[i]
		p_s[j] = 1
		ppl[j].scale = Vector3(0.6, 1.0, 0.6)
		ppl[j].position.y = 0.5
		rk_pin[i] = -1
		rk[i].scale = Vector3(1.4, 0.5, 1.4)
	beep(160.0, 0.12, 320.0, 0.25)


func _turn(i: int) -> void:
	var v := c_v[i]
	if v == Vector2.ZERO:
		return
	# 왼쪽·오른쪽 90도 중 사람과 덜 가까워지는 쪽으로 튼다
	var best := v
	var bs := -1.0
	for s in 2:
		var d := Vector2(-v.y, v.x) * (1.0 if s == 0 else -1.0)
		var sc := _path_clear(c_p[i], d.normalized())
		if sc > bs:
			bs = sc
			best = d
	c_v[i] = best
	beep(420.0, 0.1, 900.0, 0.22)
	msg("휙")


func _path_clear(o: Vector2, dir: Vector2) -> float:
	var m := 99.0
	for k in range(1, 15):
		var q := o + dir * (k * 0.5)
		for j in MAXP:
			if p_s[j] == 1 or p_s[j] == 5:
				m = minf(m, p_xz[j].distance_to(q))
	return m


func _burst(h: int) -> void:
	h_on[h] = false
	hyd[h].visible = false
	var c0 := h_cell[h] % GN
	var r0 := h_cell[h] / GN
	for r in range(r0 - 1, r0 + 2):
		for c in range(c0 - 1, c0 + 2):
			if c >= 0 and c < GN and r >= 0 and r < GN:
				_wet(r * GN + c)
	beep(1400.0, 0.25, 300.0, 0.25)
	msg("촤악")


func _burn_cross(a: Vector2, b: Vector2) -> int:
	if stage != 2:
		return 0
	var seen: Array[int] = []
	var n := ceili(a.distance_to(b) / 0.4)
	for k in n + 1:
		var c := _cell_of(a.lerp(b, float(k) / maxf(n, 1)))
		if c >= 0 and f_s[c] == 1 and not seen.has(c):
			seen.append(c)
	return seen.size()


# ---- 속도력 바닥, 재난 끝, 다음 재난 ----
func _snap() -> void:
	snapped = true
	msg("속도 끝!", 2.0)
	beep(90.0, 0.6, 40.0, 0.32)


func _lose(j: int, loud: bool) -> void:
	if p_s[j] == 2:
		p_xz[j] = me_p + Vector2(randf_range(-0.6, 0.6), randf_range(-0.6, 0.6))
	p_s[j] = 3
	n_lost += 1
	var m := ppl[j]
	m.material_override = mat(BAD)
	m.scale = Vector3(0.9, 0.15, 0.9)
	m.position = _v3(p_xz[j], 0.08)
	if loud:
		play("bad")


func _finish() -> void:
	# 시계가 다 됐다: 남은 재난이 한꺼번에 닥치고, 초록에 없는 사람은 모두 잃는다
	for j in MAXP:
		if p_s[j] == 1 or p_s[j] == 2 or p_s[j] == 5:
			_lose(j, false)
	carry.clear()
	dashing = false
	for i in MAXR:
		if rk_on[i] and not rk_down[i]:
			rk_down[i] = true
			rk_sh[i].visible = false
			rk[i].scale = Vector3(1.4, 0.5, 1.4)
			rk[i].position = _v3(rk_xz[i], 0.25)
	for m in clk:
		m.visible = false
	beep(80.0, 0.7, 40.0, 0.35)
	phase = RESULT
	phase_t = 2.4
	failed = n_lost > ALLOW
	msg("구함 %d\n잃음 %d" % [n_saved, n_lost], 2.4)


func _after() -> void:
	if failed:
		time_limit = 0.0  # 실패 소리가 나게
		end()
		return
	if stage >= 2:
		end()
		return
	phase = PICK
	var pool: Array[int] = [0, 1, 2, 3]
	pool.shuffle()
	opts = [pool[0], pool[1]]
	for k in 2:
		opt_box[k].visible = true
		_icon(k, opts[k])
	msg("%s    %s" % [UP_NAME[opts[0]], UP_NAME[opts[1]]], 999.0)
	beep(700.0, 0.15, 1000.0, 0.2)


func _icon(k: int, u: int) -> void:
	var cx := -3.0 + k * 6.0
	var ic: Array[MeshInstance3D] = [opt_ic[k * 3], opt_ic[k * 3 + 1], opt_ic[k * 3 + 2]]
	for m in ic:
		m.visible = true
		m.rotation = Vector3.ZERO
	match u:
		0:  # 업기+1: 사람 셋을 쌓은 모양, 맨 위가 새 자리
			for n in 3:
				ic[n].material_override = mat(GOOD if n == 2 else B)
				ic[n].scale = Vector3(1.4, 0.8, 1.0)
				ic[n].position = Vector3(cx, 3.1 + n * 0.9, 2.2 - n * 1.6)
		1:  # 속도력+: 긴 막대 + 늘어난 조각
			ic[0].material_override = mat(B)
			ic[0].scale = Vector3(3.0, 0.5, 1.0)
			ic[0].position = Vector3(cx - 0.6, 3.0, 0.5)
			ic[1].material_override = mat(GOOD)
			ic[1].scale = Vector3(1.2, 0.5, 1.0)
			ic[1].position = Vector3(cx + 1.6, 3.0, 0.5)
			ic[2].visible = false
		2:  # 절약: 나 하나와 짧아진 꼬리
			ic[0].material_override = mat(ME)
			ic[0].scale = Vector3(1.0, 1.4, 1.0)
			ic[0].position = Vector3(cx + 1.2, 3.4, 0.5)
			ic[1].material_override = mat(GOOD)
			ic[1].scale = Vector3(0.7, 1.0, 0.7)
			ic[1].position = Vector3(cx, 3.2, 0.5)
			ic[2].visible = false
		3:  # 손힘: 큰 잔해와 미는 나 (밀기·틀기·소화전 반값)
			ic[0].material_override = mat(C)
			ic[0].scale = Vector3(2.2, 1.6, 2.2)
			ic[0].position = Vector3(cx + 0.6, 3.5, 0.0)
			ic[1].material_override = mat(ME)
			ic[1].scale = Vector3(0.9, 1.3, 0.9)
			ic[1].position = Vector3(cx - 1.4, 3.4, 0.0)
			ic[2].visible = false


func _choose(k: int) -> void:
	match opts[k]:
		0: cap += 1
		1: pw_max += 30.0
		2: thrift *= 0.75
		3: hand *= 0.5
	play("good")
	_begin(stage + 1)


# ---- 도구 ----
func _v3(v: Vector2, y: float) -> Vector3:
	return Vector3(v.x, y, v.y)


func _cell_xz(c: int, r: int) -> Vector2:
	return Vector2(FX0 + c * CELL, FZ0 + r * CELL)


func _cell_of(v: Vector2) -> int:
	var c := roundi((v.x - FX0) / CELL)
	var r := roundi((v.y - FZ0) / CELL)
	if c < 0 or c >= GN or r < 0 or r >= GN:
		return -1
	return r * GN + c
