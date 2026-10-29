extends Tofu
## 나만 빠르다: 느린 거리에서 사람(파랑)을 탭하면 순식간에 달려가 업는다(최대 3명), 초록 구역을 탭하면 내려놓아 점수(한 번에 많이 = 더 많이). 사람이 잔해·차에 맞으면 실점, 3번이면 끝.

const MAXP := 12
const MAXD := 12
const MAXC := 6
const MAXT := 10
const DASH := 70.0
const FALL_H := 10.0
const SAFE_Z := 5.8

var pl: MeshInstance3D
var pos := Vector3.ZERO
var goal := Vector3.ZERO
var dashing := false
var goal_safe := false
var carry: Array[int] = []
var strikes := 0
var el := 0.0
var next := 0.0
var trail_t := 0.0
# 사람: 0 없음, 1 서 있음, 2 업힘, 3 다침(잠깐 보였다 사라짐)
var ppl: Array[MeshInstance3D] = []
var p_s := PackedInt32Array()
var p_t := PackedFloat32Array()
var deb: Array[MeshInstance3D] = []
var sh: Array[MeshInstance3D] = []
var d_on: Array[bool] = []
var d_v := PackedFloat32Array()
var car: Array[MeshInstance3D] = []
var c_on: Array[bool] = []
var c_v := PackedFloat32Array()
var tr: Array[MeshInstance3D] = []
var tr_t := PackedFloat32Array()
var tr_i := 0


func _setup() -> void:
	howto = "사람(파랑)을 탭하면 순식간에 달려가 업는다(최대 3명).\n초록 구역을 탭하면 내려놓아 점수. 한 번에 많이 = 더 많이.\n사람이 잔해·차에 맞으면 실점, 3번이면 끝."
	time_limit = 0.0
	cam.fov = 34.0
	cam.position = Vector3(0, 20, 7)
	cam.look_at(Vector3.ZERO)


func _reset() -> void:
	box(Vector3(0, -0.1, -1), Vector3(14, 0.2, 24), SOFT)
	box(Vector3(0, 0.01, 7.6), Vector3(12, 0.05, 3.6), GOOD)
	for z in [-6.0, -2.0, 2.0]:
		for x in [-4.5, -1.5, 1.5, 4.5]:
			box(Vector3(x, 0.01, z), Vector3(1.4, 0.03, 0.15), WHITE)
	pl = box(Vector3.ZERO, Vector3(0.8, 1.2, 0.8), ME)
	pos = Vector3(0, 0, 7.2)
	goal = pos
	dashing = false
	goal_safe = false
	carry.clear()
	strikes = 0
	el = 0.0
	next = 1.0
	ppl.clear()
	p_s.resize(MAXP)
	p_t.resize(MAXP)
	for i in MAXP:
		ppl.append(box(Vector3.ZERO, Vector3(0.6, 1.0, 0.6), B))
		ppl[i].visible = false
		p_s[i] = 0
	deb.clear()
	sh.clear()
	d_on.clear()
	d_v.resize(MAXD)
	for i in MAXD:
		deb.append(box(Vector3.ZERO, Vector3(1.1, 0.8, 1.1), [C, D, A][i % 3]))
		sh.append(box(Vector3.ZERO, Vector3(1.2, 0.04, 1.2), INK))
		deb[i].visible = false
		sh[i].visible = false
		d_on.append(false)
	car.clear()
	c_on.clear()
	c_v.resize(MAXC)
	for i in MAXC:
		car.append(box(Vector3.ZERO, Vector3(1.8, 0.9, 1.0), A))
		car[i].visible = false
		c_on.append(false)
	tr.clear()
	tr_t.resize(MAXT)
	for i in MAXT:
		tr.append(box(Vector3.ZERO, Vector3(0.8, 1.2, 0.8), B))
		tr[i].visible = false
		tr_t[i] = 0.0
	_spawn()
	_spawn()
	_place()


func _step(dt: float) -> void:
	el += dt
	# 나: 빠르다
	if dashing:
		pos = pos.move_toward(goal, DASH * dt)
		trail_t -= dt
		if trail_t <= 0.0:
			trail_t = 0.016
			var m := tr[tr_i]
			m.visible = true
			m.position = pos + Vector3(0, 0.6, 0)
			tr_t[tr_i] = 0.22
			tr_i = (tr_i + 1) % MAXT
		if pos.distance_to(goal) < 0.01:
			dashing = false
			_arrive()
	for i in MAXT:
		if tr_t[i] > 0.0:
			tr_t[i] -= dt
			var k := maxf(tr_t[i], 0.0) / 0.22
			tr[i].scale = Vector3(0.8 * k, 1.2 * k, 0.8 * k)
			tr[i].visible = tr_t[i] > 0.0
	_place()
	# 세상: 느리다
	next -= dt
	if next <= 0.0:
		next = maxf(0.9, 3.2 - el * 0.03)
		if randf() < 0.6 or not _spawn():
			_threat(_rand_person())
	for i in MAXD:
		if not d_on[i]:
			continue
		var d := deb[i]
		d.position.y -= d_v[i] * dt
		d.rotation.x += dt * 0.5
		d.rotation.y += dt * 0.3
		var k := 1.0 - clampf(d.position.y / FALL_H, 0.0, 1.0)
		sh[i].scale = Vector3(0.4 + k, 0.04, 0.4 + k)
		if d.position.y <= 0.4:
			d_on[i] = false
			d.visible = false
			sh[i].visible = false
			var hit := false
			for j in MAXP:
				if p_s[j] == 1 and _flat(ppl[j].position, sh[i].position) < 1.0:
					_hurt(j)
					hit = true
			if not hit:
				beep(130.0, 0.12, 60.0, 0.12)
	for i in MAXC:
		if not c_on[i]:
			continue
		var c := car[i]
		c.position.x += c_v[i] * dt
		if absf(c.position.x) > 8.0:
			c_on[i] = false
			c.visible = false
			continue
		for j in MAXP:
			if p_s[j] == 1:
				var q := ppl[j].position
				if absf(q.x - c.position.x) < 1.1 and absf(q.z - c.position.z) < 0.8:
					_hurt(j)
	for j in MAXP:
		if p_s[j] == 3:
			p_t[j] -= dt
			if p_t[j] <= 0.0:
				p_s[j] = 0
				ppl[j].visible = false
	var left := 3 - strikes
	gauge(left / 3.0, GOOD if left == 3 else (A if left == 2 else BAD))


func _tap(p: Vector2) -> void:
	# 손가락 크기만큼 넉넉하게 사람 고르기
	var bi := -1
	var bd := 110.0
	for i in MAXP:
		if p_s[i] != 1:
			continue
		var s := cam.unproject_position(ppl[i].position)
		var dd := s.distance_to(p)
		if dd < bd:
			bd = dd
			bi = i
	if bi >= 0:
		if carry.size() >= 3:
			msg("가득")
			beep(200.0, 0.1, 0.0, 0.2)
			return
		_dash(Vector3(ppl[bi].position.x, 0, ppl[bi].position.z), false)
		return
	var g := ground(p)
	if g.z > SAFE_Z - 0.5:
		_dash(Vector3(clampf(g.x, -5.5, 5.5), 0, clampf(g.z, SAFE_Z + 0.5, 9.0)), true)
	else:
		_dash(Vector3(clampf(g.x, -5.5, 5.5), 0, clampf(g.z, -8.0, 9.0)), false)


func _dash(to: Vector3, safe: bool) -> void:
	goal = to
	goal_safe = safe
	dashing = true
	trail_t = 0.0
	beep(300.0, 0.07, 1800.0, 0.15)


func _arrive() -> void:
	for j in MAXP:
		if carry.size() >= 3:
			break
		if p_s[j] == 1 and _flat(ppl[j].position, pos) < 1.1:
			p_s[j] = 2
			carry.append(j)
			ppl[j].scale = Vector3(0.9, 0.5, 0.6)
			beep(600.0 + carry.size() * 150.0, 0.07, 0.0, 0.22)
	if goal_safe and not carry.is_empty():
		var n := carry.size()
		score += [0, 1, 3, 6][n]
		for j in carry:
			p_s[j] = 0
			ppl[j].visible = false
		carry.clear()
		msg("%d명!" % n if n > 1 else "구출")
		play("good")


func _place() -> void:
	pl.position = pos + Vector3(0, 0.6, 0)
	for k in carry.size():
		ppl[carry[k]].position = pos + Vector3(0, 1.45 + k * 0.55, 0)


func _spawn() -> bool:
	var live := 0
	var free := -1
	for i in MAXP:
		if p_s[i] != 0:
			live += 1
		elif free < 0:
			free = i
	if free < 0 or live >= mini(3 + int(el / 15.0), MAXP):
		return false
	var at := Vector3.ZERO
	for tries in 12:
		at = Vector3(randf_range(-4.5, 4.5), 0.5, randf_range(-7.5, 4.0))
		var ok := _flat(at, pos) > 1.5
		for j in MAXP:
			if p_s[j] == 1 and _flat(ppl[j].position, at) < 1.6:
				ok = false
		if ok:
			break
	var m := ppl[free]
	m.position = at
	m.scale = Vector3(0.6, 1.0, 0.6)
	m.material_override = mat(B)
	m.visible = true
	p_s[free] = 1
	_threat(free)
	return true


func _rand_person() -> int:
	var c: Array[int] = []
	for i in MAXP:
		if p_s[i] == 1:
			c.append(i)
	if c.is_empty():
		return -1
	return c.pick_random()


func _threat(j: int) -> void:
	if j < 0:
		return
	var q := ppl[j].position
	if randf() < 0.65:
		for i in MAXD:
			if not d_on[i]:
				d_on[i] = true
				var x := q.x + randf_range(-0.3, 0.3)
				var z := q.z + randf_range(-0.3, 0.3)
				deb[i].position = Vector3(x, FALL_H, z)
				deb[i].visible = true
				sh[i].position = Vector3(x, 0.03, z)
				sh[i].scale = Vector3(0.4, 0.04, 0.4)
				sh[i].visible = true
				d_v[i] = FALL_H / randf_range(maxf(3.5, 7.0 - el * 0.03), 8.5)
				beep(900.0, 0.05, 700.0, 0.08)
				return
	for i in MAXC:
		if not c_on[i]:
			c_on[i] = true
			var side := -1.0 if randf() < 0.5 else 1.0
			car[i].position = Vector3(7.5 * side, 0.45, q.z)
			car[i].visible = true
			c_v[i] = -side * randf_range(0.9, 1.5 + el * 0.01)
			beep(180.0, 0.15, 240.0, 0.1)
			return


func _hurt(j: int) -> void:
	p_s[j] = 3
	p_t[j] = 1.0
	ppl[j].material_override = mat(BAD)
	ppl[j].scale = Vector3(0.9, 0.15, 0.9)
	ppl[j].position.y = 0.08
	strikes += 1
	play("bad")
	msg("아야")
	if strikes >= 3:
		end()


func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
