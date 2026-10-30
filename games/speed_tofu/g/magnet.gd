extends Tofu
## 자석의 망명 (등뒤 3인칭). [자석]을 누르는 동안 닿는 기계에 붙어 그 속도를 받고, 떼면 그 속도로 날아간다. 스틱 위/아래 = 붙을 면(윗면/아랫면, 도금실 팔에선 바깥/안쪽). [철판] = 무거워져 흔들려도 안 떨어지지만 덜 난다, 공중에서 누르면 던져 가속. 운반장 → 철판 창고 → 회전 도금실.
# 한 문장: 나는 버려진 전자석으로서 혼자서는 한 걸음도 못 움직이는 공장 속에서 움직이는 기계에 붙었다 떼어 그 속도를 갈아타며 탈출하지만, 빠른 기계일수록 붙는 순간·박는 순간 부서지고 늦게 떼면 분쇄기로 간다.

const VB := 22.0        # 이 상대 속도를 넘겨 붙거나 박으면 부서짐
const REACH := 4.0      # 자력이 닿는 거리
const POP := 5.0        # 뗄 때 붙어 있던 면에서 튕겨 나가는 속도
const G_L := 16.0
const G_H := 24.0       # 철판을 붙이면 더 빨리 떨어진다
const GRIP_L := 14.0    # 맨몸: 이 가속을 넘는 기계에선 떨어져 나감
const GRIP_H := 34.0    # 철판
const AIR := 8.0
const FRIC := 30.0
const HEAT_MAX := 3.5   # 가만히 있으면 녹는 시간
const BOOST := 9.0
const PEND_L := 17.0
const PEND_W := 1.3
const PEND_A := 0.9
const PIV_Y := 24.5
const ROT_C := Vector3(0, 8, -313)
const ROT_W := 1.5
const ROT_R := 12.0
const Z2 := -140.0
const Z3 := -284.0
const ZWIN := -336.0
const STEEL := Color("dee2e6")
# 운반대 레일: [x, 높이, 시작 z, 끝 z(분쇄기), 속도, 간격, 색]
const RAILS := [
	[0.0, 9.0, 0.0, -62.0, 9.0, 15.0, B],
	[3.5, 10.0, -45.0, -112.0, 16.0, 17.0, C],
	[-3.5, 10.0, -95.0, -150.0, 24.0, 18.0, D],
	[0.0, 10.0, -142.0, -190.0, 8.0, 15.0, B],
	[-4.5, 10.0, -286.0, -298.0, 5.0, 6.0, B],
]
# 운반대 길의 기둥: [x, z, 솟음(true: 아래에 매달리면 걸림) / 매달림(false: 위에 타면 걸림), 레일 높이]
const POSTS := [
	[0.0, -22.0, true, 9.0], [0.0, -40.0, false, 9.0], [0.0, -54.0, true, 9.0],
	[3.5, -80.0, false, 10.0], [3.5, -100.0, true, 10.0],
	[-3.5, -120.0, true, 10.0], [-3.5, -135.0, false, 10.0],
]
const PENDS := [[-185.0, 0.0], [-218.0, 2.2], [-251.0, 4.4]]
const PLATES := [
	Vector3(-1.5, 6.15, -148), Vector3(1.5, 6.15, -148), Vector3(0, 6.15, -153),
	Vector3(-1.5, 6.15, -289), Vector3(1.5, 6.15, -289), Vector3(0, 6.15, -294),
]


class Mach:
	var kind := ""  # cart / pend / rot
	var node: Node3D
	var hook: MeshInstance3D
	var x := 0.0
	var y := 0.0
	var z0 := 0.0
	var span := 0.0
	var sp := 0.0
	var off := 0.0
	var ph := 0.0


var machs: Array[Mach] = []
var solids: Array[AABB] = []
var grinders: Array[AABB] = []
var plates: Array[MeshInstance3D] = []
var me: MeshInstance3D
var me_face: MeshInstance3D
var me_plate: MeshInstance3D
var aim: MeshInstance3D
var fly_plate: MeshInstance3D
var fly_v := Vector3.ZERO
var fly_t := 0.0
var pp := Vector3.ZERO
var pv := Vector3.ZERO
var mt := 0.0
var am: Mach = null
var face := 1
var arm_r := 0.0
var stuck := false
var stuck_n := Vector3.UP
var last_v := Vector3.ZERO
var fresh := false
var acc_s := 0.0
var swap_cd := 0.0
var resting := false
var heat := 0.0
var heat_warn := 0.0
var heavy := false
var dead := false
var dead_t := 0.0
var won := false
var bonus := 0
var maxd := 0.0
var chk := 0  # 다시 시작할 구역 (판을 다시 해도 남는다)
var zone_seen := 0
var tick_n := 0
var cand: Mach = null
var cand_face := 1
var cand_r := 0.0
var tick: ColorRect


func _setup() -> void:
	howto = "자석은 혼자 못 움직인다. [자석]을 누르는 동안 닿는 기계에 붙어 그 속도를 받고, 떼면 그 속도로 날아간다.\n스틱 위/아래 = 윗면/아랫면(도금실 팔에선 바깥/안쪽). 노란 표시=붙을 곳, 빨강=붙으면 박살.\n[철판] 붙이면 흔들려도 안 떨어지지만 덜 난다. 공중에서 누르면 던져 가속.\n세게 붙거나 박으면 박살, 분쇄기·용광로·오래 쉬면(녹음) 끝."
	time_limit = 0.0
	kit_stick(Rect2(0, 700, 400, 580))
	kit_button("mag", "자석", Vector2(590, 1080), 105.0, A)
	kit_button("plate", "철판", Vector2(600, 830), 72.0, B)
	tick = ColorRect.new()
	tick.color = INK
	tick.position = Vector2(600.0 / 1.4 - 3.0, -10.0)
	tick.size = Vector2(6, 48)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(tick)


func _reset() -> void:
	mt = 0.0
	am = null
	stuck = false
	fresh = false
	acc_s = 0.0
	swap_cd = 0.0
	heat = 0.0
	heat_warn = 0.0
	heavy = false
	dead = false
	dead_t = 0.0
	won = false
	bonus = 0
	fly_t = 0.0
	cand = null
	_build()
	var at: Array[Vector3] = [Vector3(0, 6.5, -3), Vector3(0, 6.5, -147), Vector3(-3, 6.5, -288)]
	pp = at[chk]
	pv = Vector3.ZERO
	maxd = -pp.z
	tick_n = floori(-pp.z / 10.0)
	zone_seen = chk + 1
	me = box(pp, Vector3.ONE, ME)
	me_face = box(Vector3(0, -0.45, 0), Vector3(1.06, 0.14, 1.06), D, me)
	me_plate = box(Vector3(0, 0.62, 0), Vector3(1.5, 0.22, 1.5), STEEL, me)
	me_plate.visible = false
	aim = box(Vector3.ZERO, Vector3.ONE * 0.6, D)
	aim.visible = false
	fly_plate = box(Vector3.ZERO, Vector3(1.5, 0.22, 1.5), STEEL)
	fly_plate.visible = false
	cam.position = pp + Vector3(0, 3.6, 9.5)
	cam.look_at(pp + Vector3(0, 0.8, -12.0))
	cam.fov = 58.0
	msg(["운반장", "철판 창고", "회전 도금실"][chk], 1.5)


# ---- 공장 ----
func _block(lo: Vector3, hi: Vector3, col: Color, show := true) -> void:
	solids.append(AABB(lo, hi - lo))
	if show:
		box((lo + hi) * 0.5, hi - lo, col)


func _build() -> void:
	machs.clear()
	solids.clear()
	grinders.clear()
	plates.clear()
	# 용광로 바닥과 눈금, 옆 기둥
	box(Vector3(0, -2.5, -180), Vector3(40, 1, 400), A)
	for i in 37:
		var z := -float(i) * 10.0
		box(Vector3(0, -1.95, z), Vector3(28, 0.1, 1.2), D)
		for sd: float in [-1.0, 1.0]:
			box(Vector3(sd * 14.5, 9, z), Vector3(1, 22, 1), WHITE)
	_block(Vector3(-17, -3, -380), Vector3(-14, 30, 20), WHITE, false)
	_block(Vector3(14, -3, -380), Vector3(17, 30, 20), WHITE, false)
	# 쉬는 발판 (뜨겁다)
	_block(Vector3(-4, -2, -8), Vector3(4, 6, 2), SOFT)
	_block(Vector3(-6, -2, -158), Vector3(6, 6, -138), SOFT)
	_block(Vector3(-14, -2, -159.5), Vector3(14, 8, -158.5), STEEL)  # 가슴벽: 미끄러져 박으면 부서짐
	_block(Vector3(-6, -2, -300), Vector3(6, 6, -284), SOFT)
	# 운반대 길의 기둥 (솟음: 매달리면 걸림, 매달림: 타면 걸림)
	for p in POSTS:
		var px: float = p[0]
		var pz: float = p[1]
		var ry: float = p[3]
		if p[2]:
			_block(Vector3(px - 1.2, -2, pz - 0.6), Vector3(px + 1.2, ry - 0.6, pz + 0.6), WHITE)
			box(Vector3(px, ry - 0.7, pz), Vector3(2.5, 0.2, 1.3), BAD)
		else:
			_block(Vector3(px - 1.2, ry + 0.6, pz - 0.6), Vector3(px + 1.2, 22, pz + 0.6), WHITE)
			box(Vector3(px, ry + 0.7, pz), Vector3(2.5, 0.2, 1.3), BAD)
	# 운반대
	for r in RAILS:
		var x: float = r[0]
		var y: float = r[1]
		var z0: float = r[2]
		var z1: float = r[3]
		var col: Color = r[6]
		var span := z0 - z1
		box(Vector3(x, -1.88, (z0 + z1) * 0.5), Vector3(0.5, 0.1, span), col)
		box(Vector3(x, y, z0 + 1.6), Vector3(3, 2.6, 0.8), WHITE)
		box(Vector3(x, y, z1 - 1.5), Vector3(3.4, 3.4, 2.0), BAD)
		for k in 3:
			box(Vector3(x - 1.0 + k * 1.0, y, z1 - 0.4), Vector3(0.3, 3.0, 0.3), WHITE)
		grinders.append(AABB(Vector3(x - 1.7, y - 1.7, z1 - 2.5), Vector3(3.4, 3.4, 2.0)))
		var n := ceili(span / float(r[5]))
		for i in n:
			var m := Mach.new()
			m.kind = "cart"
			m.x = x
			m.y = y
			m.z0 = z0
			m.span = span
			m.sp = r[4]
			m.off = span * float(i) / float(n)
			m.node = box(Vector3(x, y, z0), Vector3(2.2, 1, 3), col)
			box(Vector3(0, 0, 0.36), Vector3(1.04, 1.04, 0.12), WHITE, m.node)
			machs.append(m)
	# 크레인 (진자)
	for pd in PENDS:
		var zc: float = pd[0]
		box(Vector3(0, PIV_Y + 1.4, zc), Vector3(28, 0.8, 0.8), STEEL)
		box(Vector3(0, PIV_Y + 0.4, zc), Vector3(2.4, 1.4, 2.4), WHITE)
		var m := Mach.new()
		m.kind = "pend"
		m.z0 = zc
		m.ph = pd[1]
		var piv := Node3D.new()
		piv.position = Vector3(0, PIV_Y, zc)
		world.add_child(piv)
		box(Vector3(0, -PEND_L * 0.5, 0), Vector3(0.25, PEND_L, 0.25), INK, piv)
		m.node = piv
		m.hook = box(Vector3.ZERO, Vector3(2.2, 1, 2.2), C)
		box(Vector3(0, 0.56, 0), Vector3(1.04, 0.12, 1.04), WHITE, m.hook)
		machs.append(m)
	# 회전 도금실: 축과 팔
	_block(Vector3(-1, -2, ROT_C.z - 1), Vector3(1, ROT_C.y - 1.0, ROT_C.z + 1), STEEL)
	var rm := Mach.new()
	rm.kind = "rot"
	var hub := Node3D.new()
	hub.position = ROT_C
	world.add_child(hub)
	box(Vector3.ZERO, Vector3(ROT_R * 2.0, 1, 1.4), GOOD, hub)
	for sd: float in [-1.0, 1.0]:
		box(Vector3(sd * (ROT_R - 0.6), 0, 0), Vector3(1.2, 1.1, 1.5), D, hub)
		box(Vector3(sd * 6.2, 0, 0), Vector3(0.3, 1.1, 1.5), WHITE, hub)  # 맨몸이 버티는 끝
	rm.node = hub
	machs.append(rm)
	# 출구 벽 (구멍 x -6..6, y 0.5..11) 과 착지대
	var wz := ZWIN + 2.0
	_block(Vector3(-14, -2, wz - 0.5), Vector3(-6, 22, wz + 0.5), STEEL)
	_block(Vector3(6, -2, wz - 0.5), Vector3(14, 22, wz + 0.5), STEEL)
	_block(Vector3(-6, 11, wz - 0.5), Vector3(6, 22, wz + 0.5), STEEL)
	_block(Vector3(-6, -2, wz - 0.5), Vector3(6, 0.5, wz + 0.5), STEEL)
	_block(Vector3(-8, -2, ZWIN - 25.0), Vector3(8, 0, ZWIN - 1.0), GOOD)
	_block(Vector3(-14, -2, ZWIN - 28.0), Vector3(14, 20, ZWIN - 26.0), STEEL)
	# 철판
	for p in PLATES:
		var pl := box(p, Vector3(1.5, 0.22, 1.5), STEEL)
		box(Vector3(0, 0.6, 0), Vector3(0.5, 0.6, 0.5), B, pl)
		plates.append(pl)
	_nodes()


func _cart_s(m: Mach, tm: float) -> float:
	return fposmod(tm * m.sp + m.off, m.span)


func _pend_th(m: Mach, tm: float) -> float:
	return PEND_A * sin(PEND_W * tm + m.ph)


## 기계 가운데
func _mc(m: Mach, tm: float) -> Vector3:
	if m.kind == "cart":
		return Vector3(m.x, m.y, m.z0 - _cart_s(m, tm))
	if m.kind == "pend":
		var th := _pend_th(m, tm)
		return Vector3(0, PIV_Y - PEND_L * cos(th), m.z0 - PEND_L * sin(th))
	return ROT_C


## 기계의 f 면(1 윗면, -1 아랫면)에 붙은 내 자리. 도금실 팔은 r 만큼 축에서 떨어진 곳.
func _mp(m: Mach, f: int, r: float, tm: float) -> Vector3:
	if m.kind == "rot":
		var a := ROT_W * tm
		return ROT_C + Vector3(cos(a), 0, sin(a)) * r + Vector3(0, f, 0)
	return _mc(m, tm) + Vector3(0, f, 0)


func _nodes() -> void:
	for m in machs:
		match m.kind:
			"cart":
				m.node.position = _mc(m, mt)
			"pend":
				m.node.rotation.x = _pend_th(m, mt)
				m.hook.position = _mc(m, mt)
			"rot":
				m.node.rotation.y = -ROT_W * mt


# ---- 판 ----
func _step(dt: float) -> void:
	if dead:
		dead_t += dt
		me.material_override = mat(BAD if fmod(dead_t, 0.2) < 0.1 else WHITE)
		if dead_t > 1.0:
			end()
		return
	var mag := kit_held("mag")
	var stick := kit_move
	swap_cd -= dt
	if kit_just("plate"):
		_plate_act()
	_pickup(mag)  # 철판은 기계에 붙기 전에 먼저 줍는다
	# 붙어 있으면 기계가 움직이기 전 자리를 기억
	var p_old := Vector3.ZERO
	var s_old := 0.0
	if am:
		p_old = _mp(am, face, arm_r, mt)
		if am.kind == "cart":
			s_old = _cart_s(am, mt)
	mt += dt
	_nodes()
	if am:
		if am.kind == "cart" and _cart_s(am, mt) < s_old:
			_die("분쇄기!")
			return
		var vel := (_mp(am, face, arm_r, mt) - p_old) / dt
		var acc := 0.0 if fresh else (vel - last_v).length() / dt
		fresh = false
		last_v = vel
		acc_s = lerpf(acc_s, acc, minf(1.0, dt * 12.0))
		pv = vel
		if am.kind == "rot":
			var ar := clampf(absf(arm_r) - stick.y * 6.0 * dt, 2.0, ROT_R)
			arm_r = ar * (1.0 if arm_r >= 0.0 else -1.0)
		elif swap_cd <= 0.0 and absf(stick.y) > 0.5:
			var nf := -1 if stick.y > 0.0 else 1
			if nf != face:
				face = nf
				swap_cd = 0.3
				beep(620.0 if nf > 0 else 420.0, 0.05, 0.0, 0.18)
		pp = _mp(am, face, arm_r, mt)
		if acc_s > (GRIP_H if heavy else GRIP_L):
			_detach(false)
			msg("떨어져 나감!", 0.8)
			play("bad")
		elif not mag:
			_detach(true)
		elif _overlap():
			if pv.length() > VB:
				_die("부서짐!")
				return
			_detach(false)
			pv *= -0.25
			msg("쿵!", 0.6)
			play("bad")
	elif stuck:
		pv = Vector3.ZERO
		_find_cand()
		if not mag:
			_detach(true)
		elif cand:
			_attach(cand, cand_face, cand_r, dt)
	else:
		pv.y -= (G_H if heavy else G_L) * dt
		pv.x += stick.x * AIR * dt
		pv.z += stick.y * AIR * dt
		pp += pv * dt
		_find_cand()
		if mag and cand:
			_attach(cand, cand_face, cand_r, dt)
		else:
			_hit_solids(mag)
			if resting:
				var h := Vector2(pv.x, pv.z)
				h = h.move_toward(Vector2.ZERO, FRIC * dt)
				pv.x = h.x
				pv.z = h.y
	if dead:
		return
	if am == null and not stuck:
		_find_cand()
	# 용광로 · 분쇄기
	if pp.y < -1.0:
		_die("용광로!")
		return
	for g in grinders:
		if g.has_point(pp):
			_die("분쇄기!")
			return
	# 가만히 있으면 녹는다
	if stuck or (resting and pv.length() < 2.0):
		heat += dt
		heat_warn -= dt
		if heat > 1.8 and heat_warn <= 0.0:
			heat_warn = 0.4
			beep(300.0, 0.08, 240.0, 0.22)
			msg("뜨거워!", 0.35)
		if heat > HEAT_MAX:
			_die("녹았다")
			return
	else:
		heat = maxf(0.0, heat - dt * 2.0)
	_fly(dt)
	_zones()
	if won:
		return
	maxd = maxf(maxd, -pp.z)
	score = int(maxd) + bonus
	# 통과음: 10m마다, 빠를수록 높게
	var sp := pv.length()
	var tn := floori(-pp.z / 10.0)
	if tn != tick_n:
		tick_n = tn
		if sp > 5.0:
			beep(clampf(200.0 + sp * 18.0, 200.0, 900.0), 0.04, 0.0, 0.12)
	var col := GOOD
	if sp > VB:
		col = BAD
	elif sp > VB * 0.7:
		col = D
	gauge(sp / (VB * 1.4), col)
	_place(dt)


func _find_cand() -> void:
	cand = null
	var best_s := 99.0
	for m in machs:
		var r := 0.0
		if m.kind == "rot":
			if pp.distance_to(ROT_C) > ROT_R + REACH + 1.0:
				continue
			var a := ROT_W * mt
			r = clampf((pp - ROT_C).dot(Vector3(cos(a), 0, sin(a))), -ROT_R, ROT_R)
			if absf(r) < 2.0:
				r = -2.0 if r < 0.0 else 2.0
		elif absf(_mc(m, mt).z - pp.z) > REACH + 3.0:
			continue
		for f: int in [1, -1]:
			var d := pp.distance_to(_mp(m, f, r, mt))
			if d > REACH:
				continue
			var s := d
			if (kit_move.y < -0.3 and f == -1) or (kit_move.y > 0.3 and f == 1):
				s += 1.5
			if s < best_s:
				best_s = s
				cand = m
				cand_face = f
				cand_r = r


func _point_v(m: Mach, f: int, r: float, dt: float) -> Vector3:
	return (_mp(m, f, r, mt) - _mp(m, f, r, mt - dt)) / dt


func _attach(m: Mach, f: int, r: float, dt: float) -> void:
	var v := _point_v(m, f, r, dt)
	if (pv - v).length() > VB:
		pp = _mp(m, f, r, mt)
		_die("쾅! 너무 빨라")
		return
	am = m
	face = f
	arm_r = r
	stuck = false
	fresh = true
	acc_s = 0.0
	last_v = v
	pv = v
	pp = _mp(m, f, r, mt)
	beep(700.0, 0.06, 1000.0, 0.22)


func _detach(pop: bool) -> void:
	var n := Vector3(0, face, 0) if am else stuck_n
	am = null
	stuck = false
	if pop:
		pv += n * POP
	beep(500.0, 0.12, 250.0, 0.2)


func _me_box() -> AABB:
	return AABB(pp - Vector3.ONE * 0.5, Vector3.ONE)


func _overlap() -> bool:
	var b := _me_box()
	for s in solids:
		if s.intersects(b):
			return true
	return false


func _hit_solids(mag: bool) -> void:
	resting = false
	var ns: Array[Vector3] = [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.BACK, Vector3.FORWARD]
	for s in solids:
		var b := _me_box()
		if not s.intersects(b):
			continue
		var pens: Array[float] = [s.end.x - b.position.x, b.end.x - s.position.x, s.end.y - b.position.y,
			b.end.y - s.position.y, s.end.z - b.position.z, b.end.z - s.position.z]
		var k := 0
		for i in 6:
			if pens[i] < pens[k]:
				k = i
		var n := ns[k]
		pp += n * pens[k]
		var into := -pv.dot(n)
		if mag:
			if pv.length() > VB:
				_die("박살!")
				return
			stuck = true
			stuck_n = n
			pv = Vector3.ZERO
			beep(160.0, 0.08, 120.0, 0.25)
			return
		if into > VB:
			_die("부서짐!")
			return
		if into > 0.0:
			pv += n * into * 1.15
			if into > 4.0:
				beep(110.0, 0.1, 70.0, 0.25)
		if n.y > 0.5:
			resting = true


func _plate_act() -> void:
	if not heavy:
		msg("철판 없음", 0.6)
		beep(200.0, 0.06, 0.0, 0.15)
		return
	heavy = false
	fly_plate.visible = true
	fly_plate.position = pp
	fly_t = 2.0
	if am == null and not stuck:
		# 공중에서 던지면 반대로 밀린다
		var h := Vector3(pv.x, 0, pv.z)
		var dir := h.normalized() if h.length() > 1.0 else Vector3.FORWARD
		pv += dir * BOOST + Vector3.UP * 3.0
		fly_v = -dir * 12.0
		msg("던졌다!", 0.6)
		beep(900.0, 0.15, 300.0, 0.28)
	else:
		fly_v = pv
		msg("내려놓음", 0.6)
		beep(300.0, 0.1, 0.0, 0.2)


func _pickup(mag: bool) -> void:
	if heavy:
		return
	for pl in plates:
		if pl.visible and pp.distance_to(pl.position) < (2.4 if mag else 1.4):
			pl.visible = false
			heavy = true
			msg("철판!", 0.7)
			play("good")
			return


func _fly(dt: float) -> void:
	if fly_t <= 0.0:
		return
	fly_t -= dt
	fly_v.y -= G_H * dt
	fly_plate.position += fly_v * dt
	fly_plate.rotation.x += dt * 8.0
	if fly_t <= 0.0:
		fly_plate.visible = false


func _zones() -> void:
	if zone_seen == 1 and pp.z < Z2 - 2.0:
		zone_seen = 2
		chk = maxi(chk, 1)
		msg("철판 창고", 1.5)
		play("good")
	elif zone_seen == 2 and pp.z < Z3 - 2.0:
		zone_seen = 3
		chk = maxi(chk, 2)
		msg("회전 도금실", 1.5)
		play("good")
	elif zone_seen == 3 and pp.z < ZWIN - 1.5 and (resting or stuck):
		won = true
		bonus += 300
		score = int(maxf(maxd, -pp.z)) + bonus
		msg("탈출!\n다음: 끊어진 운반선", 2.5)
		end()


func _die(text: String) -> void:
	dead = true
	dead_t = 0.0
	am = null
	stuck = false
	aim.visible = false
	msg(text, 2.0)
	beep(400.0, 0.6, 60.0, 0.3)


func _place(dt: float) -> void:
	me.position = pp
	me_plate.visible = heavy
	# 자력 면: 붙은 쪽
	var down := true
	if am:
		down = face > 0
	elif stuck:
		down = stuck_n.y > 0.5
	me_face.position.y = -0.45 if down else 0.45
	var hot := heat > 1.8 and fmod(heat, 0.25) < 0.12
	me.material_override = mat(BAD if hot else ME)
	me_face.material_override = mat(WHITE if kit_held("mag") else D)
	# 붙을 곳 표시: 노랑 안전, 빨강 박살
	if cand and am == null:
		aim.visible = true
		aim.position = _mp(cand, cand_face, cand_r, mt)
		var safe := (pv - _point_v(cand, cand_face, cand_r, dt)).length() <= VB
		aim.material_override = mat(D if safe else BAD)
	else:
		aim.visible = false
	var want := pp + Vector3(0, 3.6, 9.5)
	cam.position = cam.position.lerp(want, minf(1.0, dt * 5.0))
	cam.look_at(pp + Vector3(0, 0.8, -12.0))
	cam.fov = lerpf(cam.fov, clampf(58.0 + pv.length() * 1.1, 58.0, 92.0), minf(1.0, dt * 3.0))


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)
