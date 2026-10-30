extends Tofu
## 퀵실버 1인칭: 폭발이 멈춘 세상을 내 눈으로 뛴다. 왼쪽 조이스틱으로 달리고 오른쪽을 끌어 둘러본다.
## 달린 거리만큼 속도력(막대)이 닳고, 바닥나면 세상이 제 속도로 터진다. 사람(파랑) 곁에 가면 저절로 업고 초록 문 앞에 가면 내려 준다.
## 업은 사람 수만큼 내 발이 무거워진다. 날아오는 잔해(보라)는 쳐내기 버튼으로 떨군다.
## 건물 → 지하철 → 다리. 방마다 2명 이상 다치면 끝. 불덩이·열차·꺼지는 다리는 나도 죽인다.

const MAXP := 8
const MAXR := 12
const MAXF := 6
const MAXD := 30
const NDUST := 20
const SLOW := 0.25  # 속도력이 있는 동안 세상 빠르기
const SNAP := 3.5  # 바닥난 뒤 세상 빠르기
const SNAP_REAL := 1.4
const CLOCK := 10.0
const ALLOW := 1
const TOP := 9.0  # 내 최고 속도 m/s
const COST := 1.0  # 1m 달릴 때 닳는 속도력 (1.25였을 때는 첫 방에서 5명 구할 최단 경로 65m가 예산 80m에 안 들어가 2단계에 못 갔다)
const ROOM_NAME := ["건물 폭발", "지하철 승강장", "무너지는 다리"]
const ROOM_PW := [1.0, 1.35, 1.7]
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
var dead := false
var opts: Array[int] = [0, 1]
var sel := 0
var pick_yaw := 0.0
var rng := RandomNumberGenerator.new()
# 방
var rx0 := -6.0
var rx1 := 6.0
var rz0 := -12.0
var rz1 := 2.0
var door_p := Vector2.ZERO
var ex := Vector2.ZERO  # 폭발 한가운데
var train_z := 0.0
var crackle := 0.0
var blocks: Array[Rect2] = []  # 책상·기둥(xz)
# 나
var me_p := Vector2.ZERO
var vel := Vector2.ZERO
var yaw := 0.0
var pitch := 0.0
var stun := 0.0
var step_t := 0.0
var hot_t := 0.0
var carry: Array[int] = []
var arms: Array[MeshInstance3D] = []
# 사람: 0 없음, 1 서 있음, 2 업힘, 3 다침, 4 구함
var ppl: Array[MeshInstance3D] = []
var p_s := PackedInt32Array()
var p_xz := PackedVector2Array()
# 잔해: 0 날아오는 조각, 1 떨어지는 천장판, 2 꺼지는 다리 판
var rk: Array[MeshInstance3D] = []
var rk_sh: Array[MeshInstance3D] = []
var rk_on: Array[bool] = []
var rk_down: Array[bool] = []
var rk_kind := PackedInt32Array()
var rk_land := PackedFloat32Array()
var rk_p := PackedVector3Array()
var rk_v := PackedVector3Array()
# 불·열차, 배경, 고르기
var fb: Array[MeshInstance3D] = []
var deco: Array[MeshInstance3D] = []
var n_deco := 0
var dust: Array[MeshInstance3D] = []
var opt_box: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 1000.0
	cam.fov = 75.0
	howto = "왼쪽 조이스틱으로 달리고, 오른쪽을 끌어 둘러본다.\n달린 만큼 속도력이 닳고, 바닥나면 멈춰 있던 폭발이 제 속도로 터진다.\n사람(파랑) 곁에 가면 업고, 초록 문 앞에 가면 내려 준다. 업을수록 느려진다.\n날아오는 잔해(보라)는 쳐내기. 2명 다치거나 불·열차·구멍에 내가 당하면 끝."
	kit_stick()
	kit_lookpad()
	kit_button("hit", "쳐내기", Vector2(590, 1080), 100.0, BAD)
	for k in 4:  # 업은 사람 머리가 시야 위 모서리로 삐죽 (카메라에 붙어 판이 바뀌어도 남는다)
		arms.append(box(Vector3(-0.42 + k * 0.28, 0.36, -0.9), Vector3(0.16, 0.16, 0.16), B, cam))
		arms[k].visible = false
	var cross := CanvasLayer.new()
	cross.layer = 0
	add_child(cross)
	for k in 2:
		var r := ColorRect.new()
		r.color = WHITE if k == 0 else INK
		r.size = Vector2(16, 16) if k == 0 else Vector2(8, 8)
		r.position = Vector2(360, 640) - r.size * 0.5
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cross.add_child(r)


func _reset() -> void:
	time_limit = 1000.0
	t = CLOCK
	for m in arms:
		m.visible = false
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
		dust.append(box(Vector3.ZERO, Vector3(0.08, 0.08, 0.08), INK))
	opt_box.clear()
	for k in 2:
		opt_box.append(box(Vector3.ZERO, Vector3(1.5, 1.5, 0.3), B if k == 0 else D))
	cap = 2
	pw_max = 100.0
	thrift = 1.0
	heatproof = false
	failed = false
	dead = false
	_begin(0)


# ---- 방 차리기 ----
func _begin(r: int) -> void:
	room = r
	mode = PLAY
	wt = 0.0
	tick_s = 0
	snapped = false
	pw = pw_max * ROOM_PW[r]
	n_saved = 0
	n_hurt = 0
	n_ppl = 0
	stun = 0.0
	hot_t = 0.0
	carry.clear()
	blocks.clear()
	for i in MAXP:
		p_s[i] = 0
		ppl[i].visible = false
	for i in MAXR:
		rk_on[i] = false
		rk_down[i] = false
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
	rng.seed = 4321 + r
	match r:
		0:
			rx0 = -6.0
			rx1 = 6.0
			rz0 = -13.0
		1:
			rx0 = -3.0
			rx1 = 3.0
			rz0 = -22.0
		_:
			rx0 = -4.0
			rx1 = 4.0
			rz0 = -28.0
	rz1 = 2.0
	door_p = Vector2(0, rz1 - 0.8)
	match r:
		0: _room_office()
		1: _room_subway()
		_: _room_bridge()
	for m in dust:
		m.position = Vector3(rng.randf_range(rx0, rx1), rng.randf_range(0.4, 2.6), rng.randf_range(rz0, rz1))
		m.rotation = Vector3(rng.randf() * TAU, rng.randf() * TAU, 0)
	me_p = Vector2(0, rz1 - 1.8)
	vel = Vector2.ZERO
	yaw = 0.0
	pitch = -0.05
	_cam_update()
	msg(ROOM_NAME[r], 1.6)
	beep(90.0, 0.7, 40.0, 0.32)
	_place()


func _walls(floor_on: bool) -> void:
	var w := rx1 - rx0
	var d := rz1 - rz0
	var cx := (rx0 + rx1) * 0.5
	var cz := (rz0 + rz1) * 0.5
	if floor_on:
		_deco(Vector3(cx, -0.1, cz), Vector3(w, 0.2, d), SOFT)
	_deco(Vector3(cx, 1.5, rz0 - 0.15), Vector3(w + 0.6, 3.0, 0.3), WHITE)
	var side := (w - 2.6) * 0.5
	_deco(Vector3(rx0 + side * 0.5, 1.5, rz1 + 0.15), Vector3(side, 3.0, 0.3), WHITE)
	_deco(Vector3(rx1 - side * 0.5, 1.5, rz1 + 0.15), Vector3(side, 3.0, 0.3), WHITE)
	_deco(Vector3(0, 1.2, rz1 + 0.2), Vector3(2.6, 2.4, 0.2), GOOD)


func _room_office() -> void:
	# 안쪽 회의실에서 터졌다. 불덩이가 아주 천천히 부풀고, 조각이 사람 쪽으로 떠 온다.
	_walls(true)
	var cz := (rz0 + rz1) * 0.5
	_deco(Vector3(rx0 - 0.15, 1.5, cz), Vector3(0.3, 3.0, rz1 - rz0), WHITE)
	_deco(Vector3(rx1 + 0.15, 1.5, cz), Vector3(0.3, 3.0, rz1 - rz0), WHITE)
	ex = Vector2(1.0, -10.5)
	for q in [Vector2(-3.5, -7.5), Vector2(3.5, -7.0), Vector2(-3.5, -3.5), Vector2(3.0, -3.0), Vector2(0.0, -5.5)]:
		_deco(Vector3(q.x, 0.38, q.y), Vector3(1.8, 0.75, 0.9), WHITE)
		blocks.append(Rect2(q.x - 0.9, q.y - 0.45, 1.8, 0.9))
	_deco(Vector3(rx0 + 0.05, 1.6, -6.0), Vector3(0.1, 1.2, 3.0), B)
	_deco(Vector3(rx1 - 0.05, 1.6, -6.0), Vector3(0.1, 1.2, 3.0), B)
	for q in [Vector2(2.6, -12.0), Vector2(4.6, -10.2), Vector2(-4.2, -9.6), Vector2(-1.4, -6.6), Vector2(4.0, -5.0), Vector2(-4.6, -2.4)]:
		_person(q.x, q.y)
	for k in 8:
		var aim: Vector2
		if k < n_ppl:
			aim = p_xz[k] + Vector2(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.3, 0.3))
		else:
			aim = ex + Vector2.from_angle(rng.randf_range(0.0, PI)) * 5.0
		var dir := (aim - ex).normalized()
		# 사람을 노리는 조각은 폭심에서 느리게 출발한다: 불이 먼저 닿는 순서가 곧 구출 순서가 되고,
		# 조각은 보고 쳐낼 수 있는 위협으로 남는다 (전에는 가장 가까운 사람이 0.5초 만에 맞아 손쓸 수 없었다)
		var s := rng.randf_range(0.55, 0.75) if k < n_ppl else rng.randf_range(0.9, 1.4)
		var off := 0.0 if k < n_ppl else 1.3
		_chunk(Vector3(ex.x + dir.x * off, rng.randf_range(0.8, 1.7), ex.y + dir.y * off), Vector3(dir.x * s, 0, dir.y * s))
	fb[0].material_override = mat(D)
	fb[1].material_override = mat(A)
	fb[2].material_override = mat(A)
	fb[3].material_override = mat(BAD)
	for k in 4:
		fb[k].visible = true


func _room_subway() -> void:
	# 좁은 승강장. 오른쪽 선로로 열차가 들어오고 천장판이 떨어진다. 선로 가까이 선 사람부터.
	_walls(true)
	var cz := (rz0 + rz1) * 0.5
	var d := rz1 - rz0
	_deco(Vector3(rx0 - 0.15, 1.5, cz), Vector3(0.3, 3.0, d), WHITE)
	_deco(Vector3(rx1 + 1.6, -0.8, cz - 10.0), Vector3(3.2, 0.2, d + 20.0), INK)  # 선로 바닥
	_deco(Vector3(rx1 + 3.3, 1.5, cz - 10.0), Vector3(0.3, 3.0, d + 20.0), WHITE)  # 선로 건너 벽
	_deco(Vector3(rx1 + 0.05, -0.4, cz), Vector3(0.1, 0.8, d), D)  # 승강장 가장자리 노란 선
	for k in 5:
		var z := rz0 + 3.0 + k * 4.5
		_deco(Vector3(-1.5, 1.5, z), Vector3(0.7, 3.0, 0.7), SOFT)
		blocks.append(Rect2(-1.85, z - 0.35, 0.7, 0.7))
	for q in [Vector2(2.3, -20.0), Vector2(0.5, -17.0), Vector2(2.4, -13.5), Vector2(-2.2, -11.0), Vector2(2.2, -8.0), Vector2(0.4, -4.5), Vector2(2.3, -2.0)]:
		_person(q.x, q.y)
	var lands := [3.5, 5.0, 6.5, 8.0]
	var who := [1, 3, 5, 0]
	for k in 4:
		var q: Vector2 = p_xz[who[k]]
		_slab(Vector2(q.x * 0.5, q.y + rng.randf_range(-0.3, 0.3)), lands[k])
	for k in 3:
		var sz := rz0 + 2.0 + k * 7.0
		_chunk(Vector3(rx1 + 1.0, 2.2, sz), Vector3(-0.9, 0.1, 0.3))
	train_z = rz0 - 18.0
	fb[0].material_override = mat(BAD)
	fb[0].visible = true
	fb[0].scale = Vector3(2.6, 3.0, 14.0)
	fb[1].material_override = mat(D)
	fb[1].visible = true
	fb[1].scale = Vector3(1.8, 0.6, 0.3)
	crackle = 0.5


func _room_bridge() -> void:
	# 다리 판 하나하나가 꺼진다. 흔들리는 판은 곧 떨어진다. 떨어진 자리는 구멍 — 나도 빠진다.
	_walls(false)
	var d := rz1 - rz0
	var cz := (rz0 + rz1) * 0.5
	_deco(Vector3(0, -9.0, cz), Vector3(60.0, 0.2, 80.0), B)  # 강물
	_deco(Vector3(rx0 - 0.15, 0.45, cz), Vector3(0.3, 0.9, d), WHITE)  # 난간
	_deco(Vector3(rx1 + 0.15, 0.45, cz), Vector3(0.3, 0.9, d), WHITE)
	for k in 4:
		var z := rz0 + 4.0 + k * 7.0
		_deco(Vector3(rx0 - 0.5, 5.0, z), Vector3(0.4, 10.0, 0.4), SOFT)  # 케이블 기둥
		_deco(Vector3(rx1 + 0.5, 5.0, z), Vector3(0.4, 10.0, 0.4), SOFT)
	for k in [Vector2(-1.5, -24.0), Vector2(1.5, -15.0), Vector2(-1.5, -6.0)]:
		_deco(Vector3(k.x, 0.6, k.y), Vector3(1.6, 1.2, 3.4), D)  # 버려진 차
		blocks.append(Rect2(k.x - 0.8, k.y - 1.7, 1.6, 3.4))
	var n_panel := 10
	var pd := d / n_panel
	var falls := {2: 4.0, 4: 6.5, 6: 8.0, 8: 9.0}
	for k in n_panel:
		var z := rz0 + pd * (k + 0.5)
		if falls.has(k):
			_panel(z, pd, falls[k])
		else:
			_deco(Vector3(0, -0.15, z), Vector3(rx1 - rx0, 0.3, pd - 0.08), SOFT)
	for q in [Vector2(2.6, -26.0), Vector2(-2.4, -20.0), Vector2(0.6, -17.5), Vector2(2.8, -12.0), Vector2(-2.6, -9.0), Vector2(-0.4, -3.5)]:
		_person(q.x, q.y)
	for k in 4:
		var sx := rx0 if k % 2 == 0 else rx1
		var sz := rz0 + 5.0 + k * 6.0
		_chunk(Vector3(sx, 2.4, sz), Vector3(-signf(sx) * 1.2, -0.15, 0.4))


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
	rk[i].material_override = mat(C)
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
	rk[i].material_override = mat(C)
	rk[i].scale = Vector3(1.8, 0.25, 1.4)
	rk[i].rotation = Vector3(0, rng.randf_range(-0.3, 0.3), 0)
	rk_sh[i].visible = true


func _panel(z: float, depth: float, land: float) -> void:
	var i := _free_rock()
	rk_on[i] = true
	rk_down[i] = false
	rk_kind[i] = 2
	rk_land[i] = land
	rk_p[i] = Vector3(0, -0.15, z)
	rk_v[i] = Vector3(rx1 - rx0, 0.3, depth - 0.08)  # 크기를 여기 넣어 둔다
	rk[i].visible = true
	rk[i].material_override = mat(SOFT)
	rk[i].scale = rk_v[i]
	rk[i].rotation = Vector3.ZERO
	rk[i].position = rk_p[i]
	rk_sh[i].visible = false


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
	if mode == PLAY:
		_move(dt)
		_world(dt * (SNAP if snapped else SLOW), dt)
	elif mode == RESULT:
		t = CLOCK
		mode_t -= dt
		if mode_t <= 0.0:
			_after()
	else:
		t = CLOCK
		_pick_step()
	_place()
	_cam_update()
	var frac: float = pw / (pw_max * ROOM_PW[room])
	gauge(frac, B if frac > 0.3 else BAD)


func _move(dt: float) -> void:
	yaw -= kit_look.x * 0.007
	pitch = clampf(pitch - kit_look.y * 0.004, -0.6, 0.4)
	var top := (TOP if not snapped else 3.0) / (1.0 + 0.45 * carry.size())
	if stun > 0.0:
		stun -= dt
		vel = Vector2.ZERO
		return
	var want := Vector2.ZERO
	if kit_move.length() > 0.05:
		var fwd := Vector2(-sin(yaw), -cos(yaw))
		var right := Vector2(cos(yaw), -sin(yaw))
		want = (right * kit_move.x - fwd * kit_move.y) * top
	var acc := 36.0 / (1.0 + carry.size() * 0.5)
	vel = vel.move_toward(want, acc * dt)
	var before := me_p
	me_p += vel * dt
	_push_out()
	var moved := me_p.distance_to(before)
	if not snapped and moved > 0.0:
		pw -= moved * COST * thrift
	step_t -= dt * vel.length() / TOP
	if vel.length() > 0.5 and step_t <= 0.0:
		step_t = 0.28
		beep(110.0 + carry.size() * 20.0, 0.04, 0.0, 0.12)
	if kit_just("hit"):
		_knock()
	_touch()
	if not snapped and pw <= 0.0:
		pw = 0.0
		_snap()


func _push_out() -> void:
	var raw := me_p
	me_p.x = clampf(me_p.x, rx0 + 0.4, rx1 - 0.4)
	me_p.y = clampf(me_p.y, rz0 + 0.5, rz1 - 0.5)
	for b in blocks:
		var g := b.grow(0.4)
		if g.has_point(me_p):
			var c := g.get_center()
			var d := me_p - c
			var hx := g.size.x * 0.5
			var hz := g.size.y * 0.5
			if absf(d.x) / hx > absf(d.y) / hz:
				me_p.x = c.x + signf(d.x) * hx
			else:
				me_p.y = c.y + signf(d.y) * hz
	var corr := me_p - raw
	if corr.length() < 0.0001:
		return
	var n := corr.normalized()
	var into := -vel.dot(n)
	if into > 5.0:
		vel = Vector2.ZERO
		stun = 0.4
		beep(90.0, 0.2, 40.0, 0.4)
		msg("쿵!", 0.5)
	elif into > 0.0:
		vel += n * into


## 사람을 업고, 문 앞에서 내려 주고, 위험에 닿았는지 본다
func _touch() -> void:
	for j in MAXP:
		if carry.size() >= cap:
			break
		if p_s[j] == 1 and p_xz[j].distance_to(me_p) < 1.2:
			p_s[j] = 2
			carry.append(j)
			ppl[j].visible = false
			beep(600.0 + carry.size() * 150.0, 0.07, 0.0, 0.22)
			msg("업음 %d" % carry.size(), 0.5)
	if me_p.distance_to(door_p) < 2.0 and not carry.is_empty():
		for j in carry:
			p_s[j] = 4
			n_saved += 1
			score += 1
		msg("%d명 구함" % carry.size())
		play("good")
		carry.clear()
	for k in 4:
		arms[k].visible = k < carry.size()
	if room == 0 and me_p.distance_to(ex) < _fire_r():
		if snapped:
			_die("불에 탔다")
			return
		hot_t -= get_process_delta_time()
		pw -= get_process_delta_time() * (8.0 if heatproof else 30.0)
		if hot_t <= 0.0:
			hot_t = 0.5
			msg("앗 뜨거")
			beep(240.0, 0.08, 150.0, 0.2)
	elif room == 1 and me_p.x > rx1 - 0.9 and absf(me_p.y - train_z) < 7.2:
		_die("열차에 치였다")
	elif room == 2:
		for i in MAXR:
			if rk_on[i] and rk_kind[i] == 2 and rk_down[i] and absf(me_p.y - rk_p[i].z) < rk_v[i].z * 0.5:
				_die("다리가 꺼졌다")
				return


func _cam_update() -> void:
	cam.position = Vector3(me_p.x, 1.6, me_p.y)
	cam.rotation = Vector3(pitch, yaw, sin(stun * 40.0) * 0.08 if stun > 0.0 else 0.0)
	var spd := vel.length() / TOP
	cam.fov = lerpf(cam.fov, 75.0 + spd * 18.0, minf(1.0, 8.0 * get_process_delta_time()))


func _world(wd: float, dt: float) -> void:
	wt += wd
	if int(wt) > tick_s and wt < CLOCK:
		tick_s = int(wt)
		beep(900.0 if snapped else 1600.0, 0.03, 0.0, 0.16)
	_rocks(wd)
	match room:
		0: _fireball()
		1: _train(wd)
		_: _panels(wd)
	for m in dust:
		m.rotation.y += wd * 0.6
	t = maxf(CLOCK - wt, 0.2)
	if dead:
		return
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
			if Vector2(p.x, p.z).distance_to(me_p) < 0.7 and p.y < 2.0:
				_drop(i)
				pw -= 12.0
				stun = 0.35
				beep(120.0, 0.15, 60.0, 0.3)
				msg("퍽")
				continue
			for j in MAXP:
				if p_s[j] == 1 and p_xz[j].distance_to(Vector2(p.x, p.z)) < 0.75:
					_hurt(j, true)
					_drop(i)
					break
		elif rk_kind[i] == 1:
			var y := minf((rk_land[i] - wt) * 1.1, 2.45) + 0.25
			var q := Vector2(rk_p[i].x, rk_p[i].z)
			rk[i].position = Vector3(q.x, maxf(y, 0.13), q.y)
			rk_sh[i].position = Vector3(q.x, 0.02, q.y)
			var k := 1.0 - clampf((y - 0.25) / 2.45, 0.0, 1.0)
			rk_sh[i].scale = Vector3(0.6 + k * 1.2, 0.03, 0.5 + k * 0.9)
			if y <= 0.25:
				_drop(i)
				var hit := false
				for j in MAXP:
					if p_s[j] == 1 and p_xz[j].distance_to(q) < 1.0:
						_hurt(j, true)
						hit = true
				if q.distance_to(me_p) < 1.0:
					pw -= 20.0
					stun = 0.5
					msg("쾅!")
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
		rk[i].position = Vector3(q.x, 0.15, q.y)
	elif rk_kind[i] == 1:
		rk[i].position = Vector3(q.x, 0.13, q.y)


func _fireball() -> void:
	var r := _fire_r()
	var h := minf(r * 0.9, 2.9)
	fb[1].scale = Vector3(r * 2.0, h, r * 2.0)
	fb[1].position = Vector3(ex.x, h * 0.5, ex.y)
	fb[2].scale = Vector3(r * 2.0, h * 0.9, r * 2.0)
	fb[2].position = Vector3(ex.x, h * 0.45, ex.y)
	fb[2].rotation.y = PI * 0.25 + wt * 0.05
	fb[0].scale = Vector3(r * 1.2, h * 1.05, r * 1.2)
	fb[0].position = Vector3(ex.x, h * 0.52, ex.y)
	fb[3].scale = Vector3(r * 1.7, h * 0.7, r * 1.7)
	fb[3].position = Vector3(ex.x, h * 0.35, ex.y)
	fb[3].rotation.y = wt * 0.1
	for j in MAXP:
		if p_s[j] == 1 and p_xz[j].distance_to(ex) < r:
			_hurt(j, true)


func _fire_r() -> float:
	return 0.8 + wt * 0.8


func _train(wd: float) -> void:
	# 열차가 선로를 따라 들어온다. 승강장 가장자리(노란 선 안쪽)에 선 사람은 치인다.
	train_z += wd * 5.5
	fb[0].position = Vector3(rx1 + 1.6, 0.8, train_z)
	fb[1].position = Vector3(rx1 + 1.6, 2.0, train_z + 7.0)
	fb[1].rotation.y = 0.0
	for j in MAXP:
		if p_s[j] == 1 and p_xz[j].x > rx1 - 0.9 and absf(p_xz[j].y - train_z) < 7.2:
			_hurt(j, true)
	crackle -= wd
	if crackle <= 0.0:
		crackle = 0.5
		beep(70.0, 0.1, 50.0, 0.12)


func _panels(wd: float) -> void:
	for i in MAXR:
		if not rk_on[i] or rk_kind[i] != 2:
			continue
		var left := rk_land[i] - wt
		if rk_down[i]:
			rk_p[i].y -= wd * 6.0
			rk[i].position = rk_p[i]
			rk[i].rotation.x += wd * 0.4
			rk[i].visible = rk_p[i].y > -9.5
			continue
		if left < 2.5:
			var k := 1.0 - left / 2.5
			rk[i].position = rk_p[i] + Vector3(0, sin(wt * 25.0) * 0.04 * k, 0)
			rk[i].rotation.z = sin(wt * 19.0) * 0.02 * k
		if left <= 0.0:
			rk_down[i] = true
			rk[i].material_override = mat(INK)
			beep(100.0, 0.3, 40.0, 0.3)
			for j in MAXP:
				if p_s[j] == 1 and absf(p_xz[j].y - rk_p[i].z) < rk_v[i].z * 0.5:
					_hurt(j, true)


func _place() -> void:
	for j in MAXP:
		if p_s[j] == 1:
			ppl[j].position = Vector3(p_xz[j].x, 0.55, p_xz[j].y)


# ---- 입력 ----
func _knock() -> void:
	if mode == PICK:
		_choose(sel)
		return
	if mode != PLAY or snapped:
		return
	var fwd := Vector2(-sin(yaw), -cos(yaw))
	var bi := -1
	var bd := 2.4
	for i in MAXR:
		if not rk_on[i] or rk_down[i] or rk_kind[i] == 2:
			continue
		var q := Vector2(rk_p[i].x, rk_p[i].z)
		var to := q - me_p
		var d := to.length()
		if d < bd and (d < 0.6 or to.normalized().dot(fwd) > 0.3):
			bd = d
			bi = i
	if bi < 0:
		beep(140.0, 0.05, 0.0, 0.2)
		return
	pw -= 3.0 * thrift
	if rk_kind[bi] == 0:
		_drop(bi)
		beep(180.0, 0.1, 400.0, 0.25)
		msg("탁")
	else:
		var x := rx0 + 0.9 if rk_p[bi].x < (rx0 + rx1) * 0.5 else rx1 - 0.9
		rk_p[bi].x = x
		beep(160.0, 0.12, 320.0, 0.25)
		msg("휙")


func _pick_step() -> void:
	yaw -= kit_look.x * 0.007
	var turned := wrapf(yaw - pick_yaw, -PI, PI)
	sel = 0 if turned > 0.0 else 1
	if absf(kit_move.x) > 0.3:
		sel = 0 if kit_move.x < 0.0 else 1
	for k in 2:
		var m := opt_box[k]
		m.scale = Vector3(1.9, 1.9, 0.3) if k == sel else Vector3(1.3, 1.3, 0.3)
	msg("%s%s   %s%s" % ["▶" if sel == 0 else "", UP_NAME[opts[0]], UP_NAME[opts[1]], "◀" if sel == 1 else ""], 999.0)
	if kit_just("hit"):
		_choose(sel)


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
	m.visible = true
	m.material_override = mat(BAD)
	m.rotation = Vector3(0, m.rotation.y, 0)
	m.scale = Vector3(0.9, 0.2, 0.5)
	m.position = Vector3(p_xz[j].x, 0.1, p_xz[j].y)
	if loud:
		play("bad")


func _die(why: String) -> void:
	if dead:
		return
	dead = true
	vel = Vector2.ZERO
	stun = 9.0
	msg(why, 2.0)
	time_limit = 0.0
	end()


func _finish() -> void:
	# 시간이 제 속도로 돌아왔다: 안에 남은 사람은 모두 다친다
	for j in MAXP:
		if p_s[j] == 1 or p_s[j] == 2:
			_hurt(j, false)
	carry.clear()
	for k in 4:
		arms[k].visible = false
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
	if room >= 2:
		end()
		return
	mode = PICK
	var pool: Array[int] = [0, 1, 2, 3]
	pool.shuffle()
	opts = [pool[0], pool[1]]
	pick_yaw = yaw
	sel = 0
	var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
	var right := Vector3(cos(yaw), 0, -sin(yaw))
	for k in 2:
		var m := opt_box[k]
		m.visible = true
		m.position = cam.position + fwd * 3.2 + right * (-1.1 if k == 0 else 1.1) + Vector3(0, -0.3, 0)
		m.rotation = Vector3(0, yaw, 0)
	beep(700.0, 0.15, 1000.0, 0.2)


func _choose(k: int) -> void:
	match opts[k]:
		0: cap += 1
		1: pw_max += 30.0
		2: thrift *= 0.75
		3: heatproof = true
	play("good")
	_begin(room + 1)
