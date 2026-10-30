extends Tofu
## 내 속도가 세상의 시간: 왼쪽/오른쪽 반을 누르고 있으면 가속. 빠를수록 적·총알이 멈추고, 서거나 벽에 박히면(0.6초 기절) 적이 정상 속도로 쏜다.
## 가속·감속이 느려 방향을 바꾸면 미끄러진다. 빠를수록 점프가 멀리 간다. 전속으로 적을 뚫고 지나가면 부서진다(기본), 적 탭 = 총 쏘기·빈 총 던지기(보조).
## 위로 쓸면 점프, 아래로 쓸면 엎드려 기기. 한 방 맞거나 떨어지면 그 방부터. 방을 비우면 SUPER HOT.

const GREY := Color("cfd4db")
const NB := 40
const RUN := 8.0  # 최고 수평 속도
const ACC := 7.0  # 가속 (바닥)
const BRAKE := 9.0  # 반대쪽을 누를 때 감속
const FRICTION := 4.0  # 손을 떼면
const ACC_AIR := 2.0
const RAM_V := 3.5  # 이 속도 이상으로 적을 지나가면 부순다
const CRASH_V := 2.5  # 이 속도 이상으로 벽에 박으면 기절
const STUN := 0.6
const K := 2.0  # 세상 시간 배율 = 1 / (1 + |vx| * K)
const CRAWL := 1.6
const JUMP := 9.0
const GRAV := 22.0
const SPEEDS: Array[float] = [5.0, 18.0, 12.0]  # 적 총알, 내 총알, 던진 총
const NAMES := ["첫 방", "계단", "창문", "두 층", "엘리베이터"]


class Foe:
	var root: Node3D
	var parts: Array[MeshInstance3D] = []
	var vel: Array[Vector3] = []
	var spin: Array[Vector3] = []
	var gun: MeshInstance3D
	var x := 0.0
	var y := 0.0
	var lo := -99.0
	var hi := 99.0
	var face := -1.0
	var armed := false
	var high := true  # 다음 총알 높이: 높으면 엎드리고, 낮으면 뛴다
	var cool := 0.0
	var windup := 0.0
	var dead := false


var lv := 0
var level: Node3D
var solids: Array[Rect2] = []  # 옆에서 본 xy 사각형 (y는 위로)
var foes: Array[Foe] = []
var guns: Array[Dictionary] = []  # {n, ammo, x, y}
var bn: Array[MeshInstance3D] = []
var bv: Array[Vector2] = []
var bk: Array[int] = []  # -1 없음, 0 적 총알, 1 내 총알, 2 던진 총
var bsrc: Array = []
var x_lo := -8.0
var x_hi := 8.0
var kill_y := -3.0
var px := 0.0
var py := 0.0
var vx := 0.0
var vy := 0.0
var grounded := false
var coyote := 0.0
var ducked := false
var face := 1.0
var has_gun := false
var ammo := 0
var mode := 0  # 0 가만(미끄러짐), 1 가속, 3 엎드려 기기
var run_dir := 1.0
var press := Vector2.ZERO
var swiped := false
var flow := 1.0  # 세상 시간 배율
var stun_t := 0.0
var die_t := 0.0
var clear_t := 0.0
var beat_i := -1
var step_t := 0.0
var hum := 0.0
var creak := 0.0
var cam_x := 0.0
var cam_y := 0.0
var punch_t := 0.0
var me_root: Node3D
var me_gun: MeshInstance3D
var me_arm: MeshInstance3D
var me_parts: Array[MeshInstance3D] = []
var elev := -1  # solids 안 엘리베이터 번호
var elev_n: MeshInstance3D
var elev_v := 0.0
var elev_on := false
var elev_floor := -4.0


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 50.0
	howto = "화면 왼쪽/오른쪽 반을 누르고 있으면 그쪽으로 가속. 내가 빠를수록 세상이 느려진다(위 막대 = 세상 시간).\n서 있거나 벽에 박히면 적이 정상 속도로 쏜다. 가속·감속이 느려 방향을 바꾸면 미끄러진다.\n전속으로 빨간 적을 뚫고 지나가면 부서진다. 적 탭 = 총 쏘기·빈 총 던지기. 위로 쓸면 점프(빠를수록 멀리), 아래로 쓸면 엎드려 긴다.\n한 방 맞거나 떨어지면 그 방부터 다시. 방의 적을 다 부수면 다음 방."


func _reset() -> void:
	level = null
	lv = 0
	_room(0)


func _room(i: int) -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	solids.clear()
	foes.clear()
	guns.clear()
	elev = -1
	elev_on = false
	elev_v = 0.0
	kill_y = -3.0
	var start := Vector2(-6.5, 0.0)
	var a := 0
	match i:
		0:  # 한 층, 상자 하나
			x_lo = -8.0
			x_hi = 8.0
			_back(-8, 0, 8, 4)
			_wall(-8, -2, 8, 0)
			_wall(-8.4, -2, -8, 4.4)
			_wall(8, -2, 8.4, 4.4)
			_wall(-8.4, 4, 8.4, 4.4)
			_wall(-2.5, 0, -1.5, 1.0, SOFT)
			start = Vector2(-6.5, 0)
			a = 3
			_add_foe(5.0, 0.0, true, 1.0, 7.5)
			_add_foe(1.5, 0.0, false, -7.5, 7.5)
		1:  # 계단 위에서 쏜다
			x_lo = -9.0
			x_hi = 9.0
			_back(-9, 0, 9, 8)
			_wall(-9, -2, 9, 0)
			_wall(-9.4, -2, -9, 8.4)
			_wall(9, -2, 9.4, 8.4)
			_wall(-9.4, 8, 9.4, 8.4)
			for k in range(1, 9):
				_wall(-3.0 + (k - 1) * 0.625, 0.0, -3.0 + k * 0.625, k * 0.5, SOFT)
			_wall(2, 0, 9, 4)
			start = Vector2(-8.3, 0)
			a = 0
			_drop_gun(-7.2, 0.0, 2)
			_add_foe(-5.0, 0.0, false, -8.5, -3.2)
			_add_foe(5.0, 4.0, true, 2.3, 8.5)
			_add_foe(8.0, 4.0, true, 2.3, 8.5)
		2:  # 창문으로 뛰어 옆 건물
			x_lo = -9.0
			x_hi = 14.4
			kill_y = -3.5
			_back(-9, 0, 2, 4.2)
			_back(4.2, -1, 14, 3.6)
			_wall(-9, -6, 2, 0)
			_wall(-9.4, -6, -9, 4.6)
			_wall(-9.4, 4.2, 2, 4.6)
			_wall(1.6, 0, 2, 0.8)
			_wall(1.6, 3.8, 2, 4.2)
			_wall(4.2, -6, 14, -1)
			_wall(4.2, 3.6, 14.4, 4.0)
			_wall(14, -6, 14.4, 4.0)
			start = Vector2(-8, 0)
			a = 1
			_add_foe(-3.0, 0.0, true, -8.5, 1.2)
			_add_foe(6.5, -1.0, false, 4.6, 13.5)
			_add_foe(11.0, -1.0, true, 8.0, 13.5)
			_drop_gun(8.5, -1.0, 3)
		3:  # 세 층, 구멍으로 떨어지며 두 층과 싸운다
			x_lo = -8.0
			x_hi = 8.0
			_back(-8, 0, 8, 12)
			_wall(-8, -2, 8, 0)
			_wall(-8.4, -2, -8, 12.4)
			_wall(8, -2, 8.4, 12.4)
			_wall(-8.4, 12, 8.4, 12.4)
			_wall(-8, 3.6, -4.2, 4)
			_wall(-2.6, 3.6, 8, 4)
			_wall(-8, 7.6, 4, 8)
			start = Vector2(-6.5, 8)
			a = 2
			_add_foe(1.0, 8.0, false, -7.5, 3.7)
			_add_foe(-6.5, 4.0, true, -7.5, -4.6)
			_add_foe(6.0, 4.0, true, -2.2, 7.5)
			_add_foe(5.0, 0.0, true, -7.5, 7.5)
			_add_foe(-6.0, 0.0, false, -7.5, 7.5)
			_drop_gun(-3.4, 0.0, 3)
		_:  # 떨어지는 엘리베이터: 바닥에 닿기 전에 내린다
			x_lo = -8.0
			x_hi = 8.8
			kill_y = -10.0
			_back(-8, 0, 6, 12)
			_back(6, -4, 8.4, 12, SOFT)
			_wall(-8, -6, 6, 0)
			_wall(6, -6, 8.4, -4)
			_wall(-8.4, -2, -8, 12.4)
			_wall(8.4, -6, 8.8, 12.4)
			_wall(-8.4, 12, 8.8, 12.4)
			_wall(-8, 3.6, 6, 4)
			_wall(-8, 7.6, 6, 8)
			elev_n = _wall(6.1, 7.7, 8.3, 8.0, A)
			elev = solids.size() - 1
			elev_floor = -4.0
			start = Vector2(-6.5, 8)
			a = 2
			_add_foe(-2.0, 8.0, false, -7.5, 5.5)
			_add_foe(-5.0, 4.0, true, -7.5, 5.5)
			_add_foe(2.0, 4.0, true, -7.5, 5.5)
			_add_foe(-6.0, 0.0, true, -7.5, 5.5)
			_add_foe(0.0, 0.0, false, -7.5, 5.5)
			_drop_gun(4.5, 4.0, 2)
	bn.clear()
	bv.clear()
	bk.clear()
	bsrc.clear()
	for j in NB:
		var b := box(Vector3.ZERO, Vector3(0.4, 0.09, 0.09), INK, level)
		b.visible = false
		bn.append(b)
		bv.append(Vector2.ZERO)
		bk.append(-1)
		bsrc.append(null)
	_make_me()
	px = start.x
	py = start.y
	vx = 0.0
	vy = 0.0
	grounded = false
	ducked = false
	mode = 0
	ammo = a
	has_gun = a > 0
	face = 1.0
	flow = 1.0
	stun_t = 0.0
	die_t = 0.0
	clear_t = 0.0
	punch_t = 0.0
	cam_x = _cam_tx()
	cam_y = py
	msg("%d / %d  %s" % [i + 1, NAMES.size(), NAMES[i]], 1.2)


func _wall(x0: float, y0: float, x1: float, y1: float, col := GREY) -> MeshInstance3D:
	solids.append(Rect2(x0, y0, x1 - x0, y1 - y0))
	return box(Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, 0.0), Vector3(x1 - x0, y1 - y0, 3.0), col, level)


func _back(x0: float, y0: float, x1: float, y1: float, col := WHITE) -> void:
	box(Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, -1.6), Vector3(x1 - x0, y1 - y0, 0.2), col, level)


func _make_me() -> void:
	me_root = Node3D.new()
	level.add_child(me_root)
	me_parts.clear()
	me_parts.append(box(Vector3(0, 0.65, 0), Vector3(0.5, 1.3, 0.4), ME, me_root))
	me_parts.append(box(Vector3(0, 1.58, 0), Vector3(0.38, 0.38, 0.38), ME, me_root))
	me_arm = box(Vector3(0.55, 1.2, 0.25), Vector3(0.5, 0.14, 0.14), ME, me_root)
	me_gun = box(Vector3(0.45, 1.3, 0.3), Vector3(0.4, 0.14, 0.1), INK, me_root)


func _add_foe(x: float, y: float, armed: bool, lo: float, hi: float) -> void:
	var f := Foe.new()
	f.x = x
	f.y = y
	f.lo = lo
	f.hi = hi
	f.armed = armed
	f.root = Node3D.new()
	f.root.position = Vector3(x, y, 0)
	level.add_child(f.root)
	f.parts.append(box(Vector3(0, 0.4, 0), Vector3(0.45, 0.8, 0.35), BAD, f.root))
	f.parts.append(box(Vector3(0, 1.22, 0), Vector3(0.6, 0.85, 0.4), BAD, f.root))
	f.parts.append(box(Vector3(0, 1.85, 0), Vector3(0.38, 0.38, 0.38), BAD, f.root))
	for p in f.parts:
		f.vel.append(Vector3.ZERO)
		f.spin.append(Vector3.ZERO)
	f.gun = box(Vector3(0, 1.35, 0.3), Vector3(0.4, 0.14, 0.1), INK, f.root)
	f.gun.visible = armed
	f.cool = randf_range(1.2, 2.0)
	f.high = randf() < 0.5
	foes.append(f)


func _drop_gun(x: float, y: float, n_ammo: int) -> void:
	var m := box(Vector3(x, y + 0.08, 0.3), Vector3(0.45, 0.16, 0.14), INK, level)
	guns.append({"n": m, "ammo": n_ammo, "x": x, "y": y})


func _step(dt: float) -> void:
	var ft := minf(dt, 1.0 / 40.0)
	_view(dt)
	if die_t > 0.0:
		die_t -= dt
		if die_t <= 0.0:
			_room(lv)
		return
	if clear_t > 0.0:
		var bi := int((2.4 - clear_t) / 0.6)
		if bi != beat_i and bi < 4:
			beat_i = bi
			msg("SUPER" if bi % 2 == 0 else "HOT", 0.55)
			beep(440.0 if bi % 2 == 0 else 330.0, 0.3, 0.0, 0.35)
		clear_t -= dt
		if clear_t <= 0.0:
			lv += 1
			score = lv
			if lv >= NAMES.size():
				end()
			else:
				_room(lv)
		return
	punch_t -= dt
	coyote -= ft
	stun_t -= ft
	var oldx := px
	# 내 움직임 (실제 시간): 가속·감속이 느려 미끄러진다
	if mode != 3 and ducked and _free(px, py, 1.8):
		ducked = false
	if stun_t > 0.0:
		vx = 0.0
	elif mode == 3:
		vx = run_dir * CRAWL
	elif mode == 1:
		var a := ACC if grounded else ACC_AIR
		if grounded and vx * run_dir < 0.0:
			a = BRAKE
		vx = move_toward(vx, run_dir * RUN, a * ft)
	elif grounded:
		vx = move_toward(vx, 0.0, FRICTION * ft)
	if vx != 0.0:
		face = signf(vx)
	px += vx * ft
	if vx != 0.0:
		for r in solids:
			if r.intersects(_me_rect()):
				var top := r.end.y
				if grounded and top - py <= 0.55 and _free(px, top, _ph()):
					py = top
				else:
					px = r.position.x - 0.301 if vx > 0.0 else r.end.x + 0.301
					if absf(vx) >= CRASH_V:
						_crash()
					vx = 0.0
	vy = maxf(vy - GRAV * ft, -15.0)
	py += vy * ft
	var was := grounded
	var fall_v := vy
	grounded = false
	for r in solids:
		if r.intersects(_me_rect()):
			if vy <= 0.0:
				py = r.end.y
				grounded = true
			else:
				py = r.position.y - _ph() - 0.001
			vy = 0.0
	if grounded:
		coyote = 0.1
		if not was and fall_v < -6.0:
			beep(90.0, 0.08, 0.0, 0.2)
	var moved := absf(px - oldx) > 0.0005
	if moved and grounded:
		step_t -= dt
		if step_t <= 0.0:
			step_t = 0.45 if ducked else clampf(1.6 / maxf(absf(vx), 0.5), 0.12, 0.5)
			beep(100.0 + absf(vx) * 14.0, 0.04, 0.0, 0.12)
	# 시간: 내 수평 속도가 세상의 시간 배율을 정한다 (공중에서도 수평 속도만 센다)
	var aim := 1.0 / (1.0 + absf(vx) * K)
	flow = move_toward(flow, aim, dt * 10.0)
	gauge(flow, BAD if flow > 0.5 else B)
	var gd := ft * flow
	# 전속으로 적을 뚫고 지나가면 부서진다
	if absf(vx) >= RAM_V and die_t <= 0.0:
		for f in foes:
			if not f.dead and Rect2(f.x - 0.35, f.y, 0.7, 2.05).intersects(_me_rect()):
				_ram(f)
	hum += gd
	if hum > 0.4:
		hum = 0.0
		beep(70.0, 0.06, 0.0, 0.1)
	# 총 위를 지나가면 줍는다
	if not has_gun or ammo == 0:
		for g in guns:
			var gy: float = g.y
			if absf(float(g.x) - px) < 0.6 and gy > py - 0.5 and gy < py + 1.2:
				_pick(g)
				break
	if py < kill_y:
		_die("떨어졌다")
		return
	_elevator(gd)
	if die_t > 0.0:
		return
	_foes(gd)
	if die_t > 0.0:
		return
	_bullets(gd)
	if die_t > 0.0:
		return
	var alive := 0
	for f in foes:
		if not f.dead:
			alive += 1
	if alive == 0:
		clear_t = 2.4
		beat_i = -1
		mode = 0
		play("win")


func _view(dt: float) -> void:
	me_root.position = Vector3(px, py, 0)
	me_root.scale = Vector3(1, 0.5 if ducked else 1.0, 1)
	me_gun.visible = has_gun
	me_gun.position.x = face * 0.45
	me_arm.visible = punch_t > 0.0
	me_arm.position.x = face * 0.6
	var k := 1.0 - exp(-6.0 * dt)
	cam_x = lerpf(cam_x, _cam_tx(), k)
	cam_y = lerpf(cam_y, py, k)
	cam.position = Vector3(cam_x, cam_y + 4.6, 15.0)
	cam.rotation = Vector3(-0.12, 0, 0)


func _cam_tx() -> float:
	if x_hi - x_lo <= 14.0:
		return (x_lo + x_hi) * 0.5
	return clampf(px, x_lo + 7.0, x_hi - 7.0)


func _elevator(gd: float) -> void:
	if elev < 0:
		return
	var r := solids[elev]
	var on := grounded and absf(py - r.end.y) < 0.03 and px + 0.3 > r.position.x and px - 0.3 < r.end.x
	if not elev_on:
		if on:
			elev_on = true
			beep(90.0, 0.4, 50.0, 0.35)
			msg("떨어진다!", 0.8)
		return
	if r.position.y <= elev_floor:
		return
	elev_v = minf(elev_v + 7.0 * gd, 10.0)
	var dy := -elev_v * gd
	var crash := false
	if r.position.y + dy <= elev_floor:
		dy = elev_floor - r.position.y
		crash = true
	r.position.y += dy
	solids[elev] = r
	elev_n.position.y += dy
	if on:
		py += dy
	creak += gd
	if creak > 0.3:
		creak = 0.0
		beep(140.0, 0.05, 100.0, 0.12)
	if crash:
		beep(60.0, 0.5, 30.0, 0.45)
		if on:
			_die("쾅")


func _foes(gd: float) -> void:
	for f in foes:
		if f.dead:
			for k in f.parts.size():
				var pt := f.parts[k]
				f.vel[k].y -= 9.8 * gd
				pt.position += f.vel[k] * gd
				pt.rotation += f.spin[k] * gd
				if pt.position.y < 0.15:
					pt.position.y = 0.15
					f.vel[k] *= 0.3
					f.spin[k] *= 0.3
			continue
		var dx := px - f.x
		var dy := py - f.y
		f.face = 1.0 if dx > 0.0 else -1.0
		var same := absf(dy) < 0.6
		if f.armed:
			if same and absf(dx) > 6.0:
				f.x = clampf(f.x + f.face * 1.0 * gd, f.lo, f.hi)
			var gh := 1.35 if f.high else 0.55
			var from := Vector2(f.x + f.face * 0.6, f.y + gh)
			var tgt := Vector2(px, py + _ph() * 0.7)
			if same:
				tgt = Vector2(px, from.y)  # 같은 층이면 수평으로 쏜다
			if absf(dx) < 14.0 and _clear(from, tgt):
				f.cool -= gd
			else:
				f.cool = maxf(f.cool, 0.5)
			# 쏘기 직전 총이 커진다
			var k := 1.0 + maxf(0.0, 0.45 - f.cool) * 1.6
			f.gun.position = Vector3(f.face * 0.45, gh, 0.3)
			f.gun.scale = Vector3(0.4 * k, 0.14 * k, 0.1)
			if f.cool <= 0.0:
				f.cool = randf_range(1.8, 2.6)
				_fire(0, from, (tgt - from).normalized(), f)
				f.high = randf() < 0.5
		else:
			if same and absf(dx) > 0.8:
				f.x = clampf(f.x + f.face * 2.4 * gd, f.lo, f.hi)
				f.windup = 0.0
			elif same:
				f.windup += gd
				if f.windup > 0.45:
					_die("맞았다")
					return
			else:
				f.windup = 0.0
			f.parts[1].position.x = f.face * minf(f.windup, 0.45) * 0.6
		f.root.position = Vector3(f.x, f.y, 0)


func _bullets(gd: float) -> void:
	for j in NB:
		if bk[j] < 0:
			continue
		var b := bn[j]
		for sub in 2:
			var bp := Vector2(b.position.x, b.position.y) + bv[j] * gd * 0.5
			b.position = Vector3(bp.x, bp.y, 0.3)
			if bk[j] == 2:
				b.rotation.z += 7.0 * gd
			if bp.x < x_lo - 1.0 or bp.x > x_hi + 1.0 or bp.y < kill_y - 3.0 or bp.y > 14.0 or _solid_at(bp):
				_off(j)
				break
			if bk[j] == 0 and _me_rect().has_point(bp):
				_off(j)
				_die("맞았다")
				return
			var hit := false
			for f in foes:
				if f.dead or f == bsrc[j]:
					continue
				if Rect2(f.x - 0.35, f.y, 0.7, 2.05).has_point(bp):
					if bk[j] == 2:
						_disarm(f)
					else:
						_kill(f, bv[j].normalized())
					_off(j)
					hit = true
					break
			if hit:
				break


func _fire(kind: int, from: Vector2, dir: Vector2, src: Foe) -> void:
	for j in NB:
		if bk[j] >= 0:
			continue
		bk[j] = kind
		bsrc[j] = src
		bv[j] = dir * SPEEDS[kind]
		var b := bn[j]
		b.position = Vector3(from.x, from.y, 0.3)
		b.rotation = Vector3(0, 0, atan2(dir.y, dir.x))
		b.scale = Vector3(0.45, 0.16, 0.14) if kind == 2 else Vector3(0.4, 0.09, 0.09)
		b.material_override = mat(B if kind == 1 else INK)
		b.visible = true
		if kind == 0:
			beep(300.0, 0.12, 120.0, 0.25)
		elif kind == 1:
			beep(180.0, 0.1, 60.0, 0.35)
		else:
			beep(600.0, 0.08, 300.0, 0.2)
		return


func _off(j: int) -> void:
	bk[j] = -1
	bsrc[j] = null
	bn[j].visible = false


func _solid_at(p: Vector2) -> bool:
	for r in solids:
		if r.has_point(p):
			return true
	return false


func _clear(a: Vector2, b: Vector2) -> bool:
	var n := int(a.distance_to(b) / 0.2) + 1
	for i in range(1, n):
		if _solid_at(a.lerp(b, float(i) / n)):
			return false
	return true


func _ph() -> float:
	return 0.9 if ducked else 1.8


func _me_rect() -> Rect2:
	return Rect2(px - 0.3, py, 0.6, _ph())


func _free(x: float, y: float, h: float) -> bool:
	var rr := Rect2(x - 0.3, y, 0.6, h)
	for r in solids:
		if r.intersects(rr):
			return false
	return true


func _kill(f: Foe, dir: Vector2) -> void:
	f.dead = true
	f.gun.visible = false
	if f.armed:
		_drop_gun(f.x, f.y, 2)
	for k in f.parts.size():
		f.vel[k] = Vector3(dir.x * randf_range(2, 5) + randf_range(-1.5, 1.5), randf_range(1, 4) + dir.y * 2.0, randf_range(-2, 2))
		f.spin[k] = Vector3(randf_range(-8, 8), randf_range(-8, 8), randf_range(-8, 8))
	beep(1100.0, 0.15, 200.0, 0.3)
	play("good")


func _disarm(f: Foe) -> void:
	if not f.armed:
		_kill(f, Vector2(-f.face, 0.3))
		return
	f.armed = false
	f.gun.visible = false
	_drop_gun(clampf(f.x - f.face * 0.8, f.lo, f.hi), f.y, 2)
	beep(250.0, 0.1, 0.0, 0.3)
	msg("빈손!", 0.5)


## 달리는 몸으로 적을 치고 지나간다 (속도는 그대로)
func _ram(f: Foe) -> void:
	punch_t = 0.15
	beep(160.0, 0.08, 0.0, 0.35)
	_kill(f, Vector2(face, 0.3))


## 달리다 벽에 박힘: 잠깐 기절, 세상이 정상 속도로 돌아온다
func _crash() -> void:
	stun_t = STUN
	mode = 0
	beep(80.0, 0.25, 40.0, 0.4)
	msg("쾅", 0.5)


func _pick(g: Dictionary) -> void:
	var gn: MeshInstance3D = g.n
	gn.visible = false
	guns.erase(g)
	has_gun = true
	ammo = int(g.ammo)
	beep(700.0, 0.06, 900.0, 0.2)
	msg("탄 %d" % ammo, 0.5)


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 1.3
	mode = 0
	for p in me_parts:
		p.material_override = mat(BAD)
	play("bad")
	msg(why, 1.2)


func _jump() -> void:
	if not (grounded or coyote > 0.0):
		return
	if ducked and not _free(px, py, 1.8):
		return
	ducked = false
	grounded = false
	coyote = 0.0
	vy = JUMP + minf(absf(vx), RUN) * 0.15  # 빠를수록 조금 더 높이, 수평 속도는 그대로라 더 멀리
	beep(400.0 + absf(vx) * 20.0, 0.1, 700.0, 0.22)


## 적 탭: 총이 있으면 쏘고, 빈 총이면 던지고, 빈손이면 그쪽으로 가속 (뚫고 지나가 치기)
func _act(f: Foe) -> void:
	var to := signf(f.x - px) if f.x != px else face
	var from := Vector2(px + to * 0.5, py + _ph() * 0.72)
	var dir := (Vector2(f.x, f.y + 1.2) - from).normalized()
	if has_gun and ammo > 0:
		face = to
		ammo -= 1
		_fire(1, from, dir, null)
		if ammo == 0:
			msg("빈 총", 0.5)
	elif has_gun:
		face = to
		has_gun = false
		_fire(2, from, dir, null)
	else:
		run_dir = to
		mode = 1
		step_t = 0.0


func _foe_at(p: Vector2) -> Foe:
	var found: Foe = null
	var bd := 1e9
	for f in foes:
		if f.dead:
			continue
		var d := p - cam.unproject_position(Vector3(f.x, f.y + 1.0, 0))
		if absf(d.x) < 75.0 and absf(d.y) < 110.0 and d.length() < bd:
			bd = d.length()
			found = f
	return found


func _tap(p: Vector2) -> void:
	press = p
	swiped = false
	run_dir = -1.0 if p.x < 360.0 else 1.0
	if die_t > 0.0 or clear_t > 0.0:
		mode = 0
		return
	var f := _foe_at(p)
	if f:
		_act(f)
	else:
		mode = 1
		step_t = 0.0


func _drag(p: Vector2) -> void:
	if die_t > 0.0 or clear_t > 0.0:
		return
	if swiped:
		if mode == 3:
			run_dir = -1.0 if p.x < 360.0 else 1.0
		return
	var d := p - press
	if absf(d.y) > 70.0 and absf(d.y) > absf(d.x):
		swiped = true
		if d.y < 0.0:
			_jump()
		elif grounded:
			ducked = true
			mode = 3
			run_dir = -1.0 if p.x < 360.0 else 1.0
			beep(200.0, 0.08, 120.0, 0.2)


func _lift(_p: Vector2) -> void:
	mode = 0
