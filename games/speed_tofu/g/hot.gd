extends Tofu
## 슈퍼핫 1인칭이지만 규칙이 다르다: 내 속도가 세상의 시간을 정한다(세상 배율 = 1 / (1 + 내 속도)).
## 전력 질주하면 적·총알이 거의 멈춘 듯 느리고, 서 있으면 적이 정상 속도로 쏜다. 나는 시간을 멈추는 자가 아니라 너무 빨라서 세상이 느려 보이는 자.
## 왼쪽 조이스틱 = 달리기(관성 큼, 급정지·급회전 안 됨), 오른쪽 끌기 = 둘러보기, 쏘기 = 조준점으로(가까우면 주먹), 던지기 = 총 던져 무장 해제.
## 벽에 세게 부딪히면 0.6초 비틀거림(그동안 세상은 정상 속도). 쏠 때 내 속도가 탄에 얹힌다. 한 방 맞으면 그 방부터 다시.

const R := 7.0  # 방 반폭
const GREY := Color("dfe3e8")
const NB := 40
const SPEEDS: Array[float] = [8.0, 26.0, 14.0]  # 적 총알, 내 총알, 던진 총
const TOP := 8.0  # 내 최고 속도 (m/s)
const SLOW_K := 1.0  # 세상 배율 = 1 / (1 + 속도 * SLOW_K)
const CRASH := 4.5  # 이 속도 이상으로 벽에 박으면 비틀거림
const LEVELS := [
	{"start": Vector3(0, 0, 5), "gun": 3, "foes": [[Vector3(0, 0, -5), true]], "guns": [], "pillars": [], "queue": []},
	{"start": Vector3(0, 0, 5), "gun": 0, "foes": [[Vector3(-3, 0, -5), true], [Vector3(3, 0, -5), true], [Vector3(0, 0, -3), false]],
		"guns": [[Vector3(1.5, 0, 3.2), 3]], "pillars": [], "queue": []},
	{"start": Vector3(0, 0, 5.5), "gun": 2, "foes": [[Vector3(-4, 0, -6), true], [Vector3(4, 0, -5), true], [Vector3(0, 0, -6.5), true]],
		"guns": [[Vector3(-3, 0, 2), 3]], "pillars": [Vector3(-2, 0, 0), Vector3(2, 0, -2), Vector3(0, 0, -4.5)], "queue": []},
	{"start": Vector3(0, 0, 1), "gun": 3, "foes": [[Vector3(0, 0, -6), true], [Vector3(-3, 0, 6.3), true], [Vector3(6, 0, 0), false], [Vector3(-6, 0, -2), true]],
		"guns": [], "pillars": [Vector3(3, 0, 3)], "queue": []},
	{"start": Vector3(0, 0, 5), "gun": 4, "foes": [[Vector3(-2, 0, -6), true], [Vector3(2, 0, -6), true]],
		"guns": [[Vector3(4, 0, 4), 3]], "pillars": [Vector3(-3, 0, -1), Vector3(3, 0, -1)],
		"queue": [[Vector3(-6.3, 0, -6.3), true], [Vector3(6.3, 0, -6.3), false], [Vector3(0, 0, -6.6), true], [Vector3(-6.3, 0, 0), true], [Vector3(6.3, 0, 0), true]]},
]


class Foe:
	var root: Node3D
	var parts: Array[MeshInstance3D] = []
	var vel: Array[Vector3] = []
	var spin: Array[Vector3] = []
	var gun: MeshInstance3D
	var armed := false
	var cool := 0.0
	var windup := 0.0
	var dead := false
	var dead_t := 0.0


var lv := 0
var level: Node3D
var foes: Array[Foe] = []
var guns: Array[Dictionary] = []  # {n, ammo}
var pillars: Array[Vector3] = []
var queue: Array = []
var bn: Array[MeshInstance3D] = []
var bv: Array[Vector3] = []
var bk: Array[int] = []  # -1 없음, 0 적 총알, 1 내 총알, 2 던진 총
var bsrc: Array = []
var pos := Vector3.ZERO
var vel := Vector3.ZERO  # 내 속도 (수평)
var yaw := 0.0
var pitch := 0.0
var has_gun := false
var ammo := 0
var flow := 1.0  # 세상 시간 배율
var stun := 0.0  # 벽에 박은 뒤 비틀거리는 시간
var die_t := 0.0
var clear_t := 0.0
var step_t := 0.0
var hum := 0.0
var viewgun: MeshInstance3D


func _setup() -> void:
	howto = "내가 빠를수록 세상이 느려진다. 서 있으면 적이 제 속도로 쏜다.\n왼손 조이스틱은 달리기(관성이 커서 바로 못 멈춘다), 오른쪽을 끌면 둘러보기.\n쏘기는 가운데 조준점으로(가까우면 주먹), 던지기는 총을 던져 무장 해제. 총은 밟으면 줍는다.\n벽에 세게 박으면 잠깐 비틀거린다. 한 방 맞으면 그 방부터 다시."
	time_limit = 0.0
	cam.fov = 72.0
	viewgun = box(Vector3(0.24, -0.26, -0.55), Vector3(0.08, 0.13, 0.36), INK, cam)
	kit_stick()
	kit_lookpad()
	kit_button("fire", "쏘기", Vector2(590, 1080), 100.0, BAD)
	kit_button("throw", "던지기", Vector2(600, 870), 70.0, A)
	# 가운데 조준점 (점수·글자보다 아래 층)
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
	level = null
	lv = 0
	_room(0)


func _room(i: int) -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	var L: Dictionary = LEVELS[i]
	box(Vector3(0, -0.1, 0), Vector3(R * 2.0, 0.2, R * 2.0), WHITE, level)
	for sd in [-1.0, 1.0]:
		box(Vector3(sd * (R + 0.2), 2.0, 0), Vector3(0.4, 4.0, R * 2.0 + 0.8), SOFT, level)
		box(Vector3(0, 2.0, sd * (R + 0.2)), Vector3(R * 2.0 + 0.8, 4.0, 0.4), SOFT, level)
	pillars.clear()
	for pp in L.pillars:
		pillars.append(pp)
		box(pp + Vector3(0, 1.75, 0), Vector3(1.2, 3.5, 1.2), GREY, level)
	foes.clear()
	for f in L.foes:
		_add_foe(f[0], f[1])
	guns.clear()
	for g in L.guns:
		_drop_gun(g[0], g[1])
	bn.clear()
	bv.clear()
	bk.clear()
	bsrc.clear()
	for j in NB:
		var b := box(Vector3.ZERO, Vector3(0.07, 0.07, 0.45), INK, level)
		b.visible = false
		bn.append(b)
		bv.append(Vector3.ZERO)
		bk.append(-1)
		bsrc.append(null)
	queue = L.queue.duplicate()
	pos = L.start
	vel = Vector3.ZERO
	yaw = 0.0
	pitch = -0.08
	ammo = L.gun
	has_gun = ammo > 0
	flow = 1.0
	stun = 0.0
	die_t = 0.0
	clear_t = 0.0
	msg("%d / %d" % [i + 1, LEVELS.size()], 1.0)


func _add_foe(at: Vector3, armed: bool) -> void:
	var f := Foe.new()
	f.root = Node3D.new()
	f.root.position = at
	level.add_child(f.root)
	f.parts.append(box(Vector3(0, 0.4, 0), Vector3(0.5, 0.8, 0.32), BAD, f.root))
	f.parts.append(box(Vector3(0, 1.2, 0), Vector3(0.62, 0.85, 0.36), BAD, f.root))
	f.parts.append(box(Vector3(0, 1.85, 0), Vector3(0.36, 0.36, 0.36), BAD, f.root))
	f.parts.append(box(Vector3(0.38, 1.35, -0.2), Vector3(0.14, 0.14, 0.55), BAD, f.root))
	for p in f.parts:
		f.vel.append(Vector3.ZERO)
		f.spin.append(Vector3.ZERO)
	f.gun = box(Vector3(0.38, 1.4, -0.55), Vector3(0.08, 0.13, 0.36), INK, f.root)
	f.armed = armed
	f.gun.visible = armed
	f.cool = randf_range(1.0, 1.8)
	foes.append(f)


func _drop_gun(at: Vector3, n_ammo: int) -> void:
	var m := box(Vector3(at.x, 0.08, at.z), Vector3(0.14, 0.16, 0.48), INK, level)
	m.rotation.y = randf() * TAU
	guns.append({"n": m, "ammo": n_ammo})


func _step(dt: float) -> void:
	cam.position = pos + Vector3(0, 1.6, 0)
	cam.rotation = Vector3(pitch, yaw, sin(stun * 40.0) * 0.1 if stun > 0.0 else 0.0)
	viewgun.visible = has_gun
	if die_t > 0.0:
		die_t -= dt
		if die_t <= 0.0:
			_room(lv)
		return
	if clear_t > 0.0:
		var was := clear_t > 1.0
		clear_t -= dt
		msg("SUPER" if clear_t > 1.0 else "HOT", 0.2)
		if was and clear_t <= 1.0:
			beep(330.0, 0.35, 0.0, 0.3)
		if clear_t <= 0.0:
			lv += 1
			score = lv
			if lv >= LEVELS.size():
				end()
			else:
				_room(lv)
		return
	# 둘러보기 (조준은 자유)
	yaw -= kit_look.x * 0.007
	pitch = clampf(pitch - kit_look.y * 0.004, -0.7, 0.4)
	# 달리기: 관성. 빠를수록 가속·감속이 둔해서 급정지·급회전이 안 된다
	var spd := vel.length()
	if stun > 0.0:
		stun -= dt
		vel = Vector3.ZERO
	else:
		var want := Vector3.ZERO
		if kit_move.length() > 0.05:
			var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
			var right := Vector3(cos(yaw), 0, -sin(yaw))
			want = (right * kit_move.x - fwd * kit_move.y) * TOP
		var acc := 40.0 / (1.0 + spd * 0.6)
		vel = vel.move_toward(want, acc * dt)
		pos += vel * dt
		_push_out()
		spd = vel.length()
		step_t -= dt * spd / TOP
		if spd > 0.5 and step_t <= 0.0:
			step_t = 0.3
			beep(110.0, 0.04, 0.0, 0.12)
		if kit_just("fire"):
			_shoot()
		if kit_just("throw"):
			_throw()
	# 총 위를 지나가면 줍는다
	for g in guns:
		var gn: MeshInstance3D = g.n
		if Vector2(gn.position.x - pos.x, gn.position.z - pos.z).length() < 0.8 and (not has_gun or ammo == 0):
			_pick(g)
			break
	# 세상의 시간 배율 = 내 속도가 정한다
	var aim := 1.0 / (1.0 + spd * SLOW_K)
	if stun > 0.0:
		flow = 1.0
	else:
		flow = move_toward(flow, aim, dt * 6.0)
	gauge(1.0 - flow, BAD if stun > 0.0 else B)
	var gd := dt * flow
	hum += gd
	if hum > 0.4:
		hum = 0.0
		beep(70.0, 0.06, 0.0, 0.1)
	_foes(gd)
	_bullets(gd)
	if die_t > 0.0:
		return
	var alive := 0
	for f in foes:
		if not f.dead:
			alive += 1
	if alive < 2 and not queue.is_empty():
		var q: Array = queue.pop_front()
		_add_foe(q[0], q[1])
		alive += 1
	if alive == 0:
		clear_t = 2.0
		play("win")


func _foes(gd: float) -> void:
	for f in foes:
		if f.dead:
			f.dead_t += gd
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
		var to := pos - f.root.position
		to.y = 0.0
		var dist := to.length()
		if dist > 0.1:
			f.root.look_at(Vector3(pos.x, 0.0, pos.z), Vector3.UP)
		if f.armed:
			if dist > 5.0:
				f.root.position += to.normalized() * 1.2 * gd
			f.cool -= gd
			# 쏘기 직전 총이 살짝 커진다
			f.gun.scale = Vector3(0.08, 0.13, 0.36) * (1.0 + maxf(0.0, 0.4 - f.cool) * 1.5)
			if f.cool <= 0.0:
				f.cool = randf_range(1.6, 2.6)
				var from := f.gun.global_position
				_fire(0, from, (cam.position + Vector3(0, -0.25, 0) - from).normalized(), f)
		else:
			if dist > 0.9:
				f.root.position += to.normalized() * 2.4 * gd
				f.windup = 0.0
			else:
				f.windup += gd
				f.parts[3].position.z = -0.2 - f.windup
				if f.windup > 0.45:
					_die()
					return


func _bullets(gd: float) -> void:
	for j in NB:
		if bk[j] < 0:
			continue
		var b := bn[j]
		b.position += bv[j] * gd
		if bk[j] == 2:
			b.rotation.x += 15.0 * gd
		var bp := b.position
		if absf(bp.x) > R or absf(bp.z) > R or bp.y < 0.0 or bp.y > 4.0 or _in_pillar(bp, 0.6):
			_off(j)
			continue
		if bk[j] == 0:
			var me := cam.position - bp
			if Vector2(me.x, me.z).length() < 0.35 and absf(me.y + 0.3) < 0.7:
				_off(j)
				_die()
				return
		for f in foes:
			if f.dead or f == bsrc[j]:
				continue
			var d := bp - f.root.position
			if Vector2(d.x, d.z).length() < 0.4 and bp.y > 0.1 and bp.y < 2.05:
				if bk[j] == 2:
					_disarm(f)
				else:
					_kill(f, bv[j].normalized())
				_off(j)
				break


## kind 1·2(내가 쏘거나 던진 것)는 내 속도가 날아가는 방향으로 얹힌다
func _fire(kind: int, from: Vector3, dir: Vector3, src: Foe) -> void:
	for j in NB:
		if bk[j] >= 0:
			continue
		var b := bn[j]
		bk[j] = kind
		bsrc[j] = src
		var s := SPEEDS[kind]
		if kind > 0:
			s += maxf(0.0, vel.dot(dir)) * 2.0
		bv[j] = dir * s
		b.position = from
		b.scale = Vector3(0.14, 0.16, 0.48) if kind == 2 else Vector3(0.07, 0.07, 0.45)
		if absf(dir.y) < 0.98:
			b.look_at(from + dir, Vector3.UP)
		b.visible = true
		if kind == 0:
			beep(300.0, 0.12, 120.0, 0.25)
		elif kind == 1:
			beep(180.0, 0.1, 60.0 + s * 4.0, 0.35)
		else:
			beep(600.0, 0.08, 300.0, 0.2)
		return


func _off(j: int) -> void:
	bk[j] = -1
	bsrc[j] = null
	bn[j].visible = false


func _in_pillar(p: Vector3, half: float) -> bool:
	if p.y > 3.5:
		return false
	for c in pillars:
		if absf(p.x - c.x) < half and absf(p.z - c.z) < half:
			return true
	return false


## 벽·기둥 밖으로 밀어낸다. 세게 박으면 비틀거림, 살살이면 그 방향 속도만 죽는다
func _push_out() -> void:
	var raw := pos
	pos.x = clampf(pos.x, -R + 0.4, R - 0.4)
	pos.z = clampf(pos.z, -R + 0.4, R - 0.4)
	for c in pillars:
		var d := pos - c
		if absf(d.x) < 0.95 and absf(d.z) < 0.95:
			if absf(d.x) > absf(d.z):
				pos.x = c.x + signf(d.x) * 0.95
			else:
				pos.z = c.z + signf(d.z) * 0.95
	var corr := pos - raw
	if corr.length() < 0.0001:
		return
	var n := corr.normalized()
	var into := -vel.dot(n)
	if into > CRASH:
		_crash()
	elif into > 0.0:
		vel += n * into


func _crash() -> void:
	vel = Vector3.ZERO
	stun = 0.6
	flow = 1.0
	beep(90.0, 0.2, 40.0, 0.4)
	msg("쿵!", 0.6)


func _kill(f: Foe, dir: Vector3) -> void:
	f.dead = true
	if f.armed:
		_drop_gun(f.root.position + Vector3(0.4, 0, 0), 2)
		f.gun.visible = false
	var local := f.root.global_transform.basis.inverse() * dir
	for k in f.parts.size():
		f.vel[k] = local * randf_range(2.0, 5.0) + Vector3(randf_range(-2, 2), randf_range(1, 4), randf_range(-2, 2))
		f.spin[k] = Vector3(randf_range(-8, 8), randf_range(-8, 8), randf_range(-8, 8))
	beep(1100.0, 0.15, 200.0, 0.3)
	play("good")


func _disarm(f: Foe) -> void:
	if not f.armed:
		return
	f.armed = false
	f.gun.visible = false
	_drop_gun(f.root.position + Vector3(0, 0, 0.6), 2)
	beep(250.0, 0.1, 0.0, 0.3)
	msg("빈손!", 0.5)


func _pick(g: Dictionary) -> void:
	var gn: MeshInstance3D = g.n
	gn.visible = false
	guns.erase(g)
	has_gun = true
	ammo = int(g.ammo)
	beep(700.0, 0.06, 900.0, 0.2)
	msg("탄 %d" % ammo, 0.5)


func _die() -> void:
	if die_t > 0.0:
		return
	die_t = 1.4
	vel = Vector3.ZERO
	play("bad")
	msg("죽었다", 1.3)


## 조준점(화면 가운데)이 가리키는 방향
func _aim_dir() -> Vector3:
	cam.position = pos + Vector3(0, 1.6, 0)
	cam.rotation = Vector3(pitch, yaw, 0)
	return -cam.global_transform.basis.z


## 조준점 위의 가장 가까운 적 (없으면 null)
func _aimed(n: Vector3) -> Foe:
	var hit: Foe = null
	var hit_t := 1e9
	for f in foes:
		if f.dead:
			continue
		var v := f.root.position + Vector3(0, 1.1, 0) - cam.position
		var tp := v.dot(n)
		if tp > 0.0 and (v - n * tp).length() < 0.55 + tp * 0.04 and tp < hit_t:
			hit = f
			hit_t = tp
	return hit


## 쏘기 버튼: 앞에 가까운 적이 있으면 주먹, 아니면 조준점으로 한 발
func _shoot() -> void:
	var n := _aim_dir()
	var flat := Vector2(n.x, n.z).normalized()
	for f in foes:
		if f.dead:
			continue
		var to := Vector2(f.root.position.x - pos.x, f.root.position.z - pos.z)
		if to.length() < 1.8 and to.normalized().dot(flat) > 0.5:
			beep(160.0, 0.08, 0.0, 0.35)
			_kill(f, (f.root.position + Vector3(0, 1.2, 0) - cam.position).normalized())
			return
	if has_gun and ammo > 0:
		ammo -= 1
		var hit := _aimed(n)
		var dir := n if hit == null else (hit.root.position + Vector3(0, 1.2, 0) - cam.position).normalized()
		_fire(1, cam.position + n * 0.6, dir, null)
	elif has_gun:
		beep(900.0, 0.03, 0.0, 0.15)  # 빈 총 딸깍
		msg("빈 총", 0.5)
	else:
		beep(140.0, 0.05, 0.0, 0.2)  # 허공에 주먹


## 던지기 버튼: 든 총을 조준점으로 던진다 (맞은 적은 총을 놓친다)
func _throw() -> void:
	if not has_gun:
		return
	var n := _aim_dir()
	has_gun = false
	ammo = 0
	var hit := _aimed(n)
	var dir := n if hit == null else (hit.root.position + Vector3(0, 1.2, 0) - cam.position).normalized()
	_fire(2, cam.position + n * 0.6, dir, null)
