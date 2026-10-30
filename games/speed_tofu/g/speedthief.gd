extends Tofu
## 스피드 도둑 (3D 등뒤 추격). 왼손 조이스틱 = 핸들, 해킹(꾹) = 가까운 바이커 속도를 빨아 내 것으로, 발차기 = 바로 옆 바이커 걷어차기.
## 뒤에서 경찰이 쫓는다. 느려서 따라잡히면 체포, 차·바리케이드에 박으면 속도 반토막.
## 시장 골목 → 고가도로(무장 바이커) → 항구(바리케이드) → 터널(라이벌 도둑) → 도심 탑(경찰 드론 조명). 구역 끝 관문마다 강화 하나.

const DLEN := 1000.0  # 구역 길이
const NAMES: Array[String] = ["시장 골목", "고가도로", "항구", "터널", "도심 탑"]
const COP: Array[float] = [26.0, 29.0, 32.0, 35.0, 38.0]  # 구역별 경찰 속도
const LANES: Array[float] = [-4.5, -1.5, 1.5, 4.5]
const HALF := 5.6  # 달릴 수 있는 반폭
const ROAD := Color("b4bccf")
const SP := 12.0  # 길가 칸 간격
const NSIDE := 20
const NDASH := 20
const RANGE := 11.0  # 해킹 거리
const GAPMAX := 70.0

var dist := 0.0  # 내 진행 거리 (월드 z = -dist)
var px := 0.0
var spd := 30.0
var vmax := 64.0
var gap := 40.0  # 경찰과의 거리
var zone := 0
var picking := false
var hack_rate := 16.0
var tank := 0.0
var nitro := 0.0
var shield_max := 0
var shield := 0
var kick_cd := 0.0
var kick_anim := 0.0
var shake := 0.0
var hum_t := 0.0
var siren_t := 0.0
var siren_hi := false
var steal_t := 0.0
var bonus := 0
var hacking := false
var clock := 0.0

var me: Node3D
var leg: MeshInstance3D
var plate: MeshInstance3D
var can: MeshInstance3D
var cop: Node3D
var cop_lamp: MeshInstance3D
var chopper: Node3D
var road: MeshInstance3D
var floor_n: MeshInstance3D
var beam: MeshInstance3D
var rbeam: MeshInstance3D
var mark: MeshInstance3D
var gate: Node3D
var tower: MeshInstance3D
var sides: Array[Dictionary] = []  # {n, d, side, i}
var tops: Array[Dictionary] = []  # 터널 천장
var dashes: Array[MeshInstance3D] = []
var bikers: Array[Dictionary] = []  # {root, shell, d, x, tx, v, armor, dead, vx, fall}
var cars: Array[Dictionary] = []  # {root, body, d, x, v, on}
var blocks: Array[Dictionary] = []  # {root, lanes, go, d, gap, on}
var drones: Array[Dictionary] = []  # {root, spot, d, x, tx, on, hit}
var rival := {}
var pick_ui: CanvasLayer


func _setup() -> void:
	howto = "도둑 바이커가 되어 남의 속도를 훔쳐 도시를 빠져나간다.\n왼손 조이스틱 = 핸들. 해킹을 꾹 = 가까운 바이커 속도를 빨아 내 것으로. 발차기 = 바로 옆 바이커 걷어차기.\n뒤에서 경찰이 쫓는다. 느려서 따라잡히면 체포, 차·바리케이드에 박으면 속도 반토막.\n구역 끝 관문마다 강화 하나를 고른다."
	time_limit = 0.0
	cam.fov = 64.0
	kit_stick()
	kit_button("hack", "해킹", Vector2(590, 1075), 105.0, C)
	kit_button("kick", "발차기", Vector2(610, 855), 78.0, A)
	# 관문 강화 고르기 (조이스틱·버튼 자리 밖)
	pick_ui = CanvasLayer.new()
	pick_ui.layer = 6
	add_child(pick_ui)
	var names := ["빠른\n해킹", "니트로\n탱크", "방패"]
	var cols := [C, B, GOOD]
	for i in 3:
		var r := ColorRect.new()
		r.color = cols[i]
		r.position = Vector2(30 + i * 225, 270)
		r.size = Vector2(210, 230)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pick_ui.add_child(r)
		var s := LabelSettings.new()
		s.font = _font
		s.font_size = 44
		s.font_color = WHITE
		s.outline_size = 10
		s.outline_color = INK
		var l := Label.new()
		l.label_settings = s
		l.text = names[i]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.size = r.size
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.add_child(l)
	pick_ui.visible = false


func _reset() -> void:
	dist = 0.0
	px = 0.0
	spd = 30.0
	gap = 40.0
	zone = 0
	picking = false
	hack_rate = 16.0
	tank = 0.0
	nitro = 0.0
	shield_max = 0
	shield = 0
	kick_cd = 0.0
	kick_anim = 0.0
	shake = 0.0
	bonus = 0
	hacking = false
	clock = 0.0
	time_limit = 0.0
	pick_ui.visible = false
	sides.clear()
	tops.clear()
	dashes.clear()
	bikers.clear()
	cars.clear()
	blocks.clear()
	drones.clear()
	# 땅·길·길가
	floor_n = box(Vector3(0, -1, 0), Vector3(500, 0.4, 700), SOFT)
	road = box(Vector3(0, -0.25, 0), Vector3(13, 0.5, 700), ROAD)
	for i in NSIDE:
		for sd in [-1, 1]:
			var s := {"n": box(Vector3.ZERO, Vector3.ONE, WHITE), "d": i * SP - 10.0, "side": sd, "i": i}
			_dress(s)
			sides.append(s)
		var tp := {"n": box(Vector3.ZERO, Vector3(15.4, 0.6, SP - 0.4), WHITE), "d": i * SP - 10.0, "i": i}
		_dress_top(tp)
		tops.append(tp)
	for k in 3:
		for i in NDASH:
			dashes.append(box(Vector3((k - 1) * 3.0, 0.03, 10.0 - i * 10.0), Vector3(0.18, 0.06, 3.5), WHITE))
	# 나
	me = _bike(ME, D)
	leg = box(Vector3(0.9, 0.9, 0), Vector3(1.3, 0.24, 0.26), INK, me)
	leg.visible = false
	plate = box(Vector3(0, 0.05, 0), Vector3(1.6, 0.08, 2.6), GOOD, me)
	can = box(Vector3(0, 0.95, 1.0), Vector3(0.5, 0.6, 0.35), B, me)
	# 경찰차 + 경찰 드론
	cop = Node3D.new()
	world.add_child(cop)
	box(Vector3(0, 0.6, 0), Vector3(2.0, 0.9, 4.0), B, cop)
	box(Vector3(0, 1.35, 0.3), Vector3(1.7, 0.6, 2.0), WHITE, cop)
	cop_lamp = box(Vector3(0, 1.8, 0.3), Vector3(1.3, 0.25, 0.4), BAD, cop)
	chopper = _drone()
	# 해킹 줄기, 표적 표시
	beam = box(Vector3.ZERO, Vector3.ONE, C)
	beam.visible = false
	rbeam = box(Vector3.ZERO, Vector3.ONE, BAD)
	rbeam.visible = false
	mark = box(Vector3.ZERO, Vector3(0.5, 0.5, 0.5), C)
	mark.visible = false
	# 바이커
	var bcols := [A, GOOD, B, C]
	for i in 7:
		var r := _bike(bcols[i % 4], WHITE)
		var sh := box(Vector3(0, 0.95, 0), Vector3(1.1, 1.5, 2.3), D, r)
		var b := {"root": r, "shell": sh, "d": 0.0, "x": 0.0, "tx": 0.0, "v": 0.0, "armor": false, "dead": false, "vx": 0.0, "fall": 1.0}
		bikers.append(b)
		_spawn_biker(b, 22.0 + i * 20.0)
	# 차
	for i in 9:
		var r := Node3D.new()
		world.add_child(r)
		var body := box(Vector3(0, 0.7, 0), Vector3(2.0, 1.1, 3.9), A, r)
		box(Vector3(0, 1.55, 0.2), Vector3(1.7, 0.6, 2.0), WHITE, r)
		var c := {"root": r, "body": body, "d": 0.0, "x": 0.0, "v": 0.0, "on": false}
		cars.append(c)
		_spawn_car(c, i, 60.0 + i * 25.0)
	# 바리케이드 (항구부터)
	for i in 2:
		var r := Node3D.new()
		world.add_child(r)
		var ln: Array[Node3D] = []
		for k in 4:
			var n := Node3D.new()
			r.add_child(n)
			n.position.x = LANES[k]
			box(Vector3(0, 0.7, 0), Vector3(2.8, 1.4, 1.0), BAD, n)
			box(Vector3(0, 1.0, -0.02), Vector3(2.9, 0.3, 1.02), WHITE, n)
			ln.append(n)
		var go := box(Vector3(0, 0.04, -3.0), Vector3(1.4, 0.06, 4.0), GOOD, r)
		r.visible = false
		blocks.append({"root": r, "lanes": ln, "go": go, "d": 0.0, "gap": 0, "on": false})
	# 경찰 드론 조명 (도심 탑)
	for i in 2:
		var r := _drone()
		var spot := box(Vector3.ZERO, Vector3(3.2, 0.06, 4.0), BAD)
		r.visible = false
		spot.visible = false
		drones.append({"root": r, "spot": spot, "d": 0.0, "x": 0.0, "tx": 0.0, "on": false, "hit": false})
	# 라이벌 도둑 (터널부터)
	var rr := _bike(BAD, INK)
	rr.visible = false
	rival = {"root": rr, "d": 0.0, "x": 0.0, "v": 0.0, "on": false, "t": 3.0, "armor": false, "is_rival": true}
	# 관문, 마지막 탑
	gate = Node3D.new()
	world.add_child(gate)
	box(Vector3(-7.2, 4.5, 0), Vector3(1.2, 9, 1.2), D, gate)
	box(Vector3(7.2, 4.5, 0), Vector3(1.2, 9, 1.2), D, gate)
	box(Vector3(0, 9.2, 0), Vector3(15.6, 1.4, 1.2), C, gate)
	box(Vector3(0, 0.04, 0), Vector3(13, 0.07, 1.6), WHITE, gate)
	gate.position.z = -DLEN
	tower = box(Vector3(0, 60, -(5.0 * DLEN + 80.0)), Vector3(34, 120, 34), D)
	tower.visible = false
	msg(NAMES[0], 1.5)
	_camera(1.0)


func _bike(col: Color, helmet: Color) -> Node3D:
	var r := Node3D.new()
	world.add_child(r)
	box(Vector3(0, 0.6, 0), Vector3(0.45, 0.4, 1.8), col, r)
	box(Vector3(0, 0.36, -0.85), Vector3(0.18, 0.72, 0.72), INK, r)
	box(Vector3(0, 0.36, 0.85), Vector3(0.2, 0.72, 0.72), INK, r)
	box(Vector3(0, 1.2, 0.2), Vector3(0.55, 0.75, 0.45), col, r)
	box(Vector3(0, 1.75, 0.05), Vector3(0.44, 0.44, 0.48), helmet, r)
	return r


func _drone() -> Node3D:
	var r := Node3D.new()
	world.add_child(r)
	box(Vector3.ZERO, Vector3(1.4, 0.5, 1.4), WHITE, r)
	box(Vector3(0, 0.2, 0), Vector3(3.2, 0.1, 0.25), INK, r)
	box(Vector3(0, 0.2, 0), Vector3(0.25, 0.1, 3.2), INK, r)
	box(Vector3(0, -0.4, 0), Vector3(0.5, 0.3, 0.5), BAD, r)
	return r


func _zone_of(d: float) -> int:
	return clampi(int(d / DLEN), 0, 4)


func _step(dt: float) -> void:
	if picking:
		_camera(dt)
		return
	clock += dt
	var prev := dist
	var steer := kit_move.x
	px = clampf(px + steer * 10.0 * dt, -HALF, HALF)
	# 가만히 있으면 속도가 샌다. 니트로가 있으면 채워 준다
	spd -= (1.2 + spd * 0.02) * dt
	if nitro > 0.0 and spd < vmax - 8.0:
		var n := minf(nitro, 14.0 * dt)
		nitro -= n
		spd += n
	spd = maxf(spd, 8.0)
	dist += spd * dt
	kick_cd -= dt
	kick_anim -= dt
	shake = maxf(shake - dt, 0.0)
	_hack(dt)
	_kick()
	_move_bikers(dt)
	_move_cars(dt)
	_move_blocks(prev)
	_move_drones(dt)
	_move_rival(dt)
	_scenery()
	if spd > vmax:
		nitro = minf(nitro + spd - vmax, tank)
		spd = vmax
	# 경찰: 내가 느리면 다가온다
	gap = minf(gap + (spd - COP[zone]) * dt, GAPMAX)
	if gap <= 0.0:
		gap = 0.0
		msg("체포!", 2.0)
		end()
		return
	gauge(gap / GAPMAX, GOOD if gap > 25.0 else (A if gap > 12.0 else BAD))
	if gap < 30.0:
		siren_t -= dt
		if siren_t <= 0.0:
			siren_t = clampf(gap / 30.0 * 0.6, 0.12, 0.6)
			siren_hi = not siren_hi
			beep(950.0 if siren_hi else 700.0, 0.1, 0.0, 0.1)
			cop_lamp.material_override = mat(BAD if siren_hi else B)
	# 내 모습
	me.position = Vector3(px, 0, -dist)
	me.rotation.z = -steer * 0.35
	leg.visible = kick_anim > 0.0
	plate.visible = shield > 0
	can.visible = tank > 0.0
	if tank > 0.0:
		can.scale.y = 0.1 + 0.8 * nitro / tank
	cop.position = Vector3(lerpf(cop.position.x, px, minf(1.0, 2.0 * dt)), 0, -(dist - gap - 2.0))
	chopper.position = Vector3(px * 0.5, 6.0 + sin(clock * 3.0) * 0.3, -(dist - gap + 9.0))
	score = int(dist / 10.0) + bonus
	# 구역 끝 관문
	var gd := (zone + 1) * DLEN
	if prev < gd and dist >= gd:
		_checkpoint()
	_camera(dt)


func _camera(dt: float) -> void:
	var f := 64.0 + (spd - 30.0) * 0.45 + (10.0 if hacking else 0.0)
	cam.fov = lerpf(cam.fov, clampf(f, 58.0, 94.0), minf(1.0, 5.0 * dt))
	var j := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * shake * 0.6
	var behind := 6.5 + clampf((spd - 30.0) * 0.03, -0.5, 1.2)
	cam.position = Vector3(px * 0.7, 3.4, -dist + behind) + j
	cam.look_at(Vector3(px * 0.85, 1.0, -dist - 14.0), Vector3.UP)


# ---- 훔치기 ----
func _target() -> Dictionary:
	var near := RANGE
	var pick := {}
	for b in bikers:
		if b.dead:
			continue
		var dd: float = b.d - dist
		if dd < -3.0:
			continue
		var l := Vector2(float(b.x) - px, dd).length()
		if l < near:
			near = l
			pick = b
	if rival.on:
		var rd: float = rival.d - dist
		var l := Vector2(float(rival.x) - px, rd).length()
		if rd > -3.0 and l < near:
			pick = rival
	return pick


func _hack(dt: float) -> void:
	hacking = false
	beam.visible = false
	var tgt := _target()
	mark.visible = not tgt.is_empty()
	if tgt.is_empty():
		return
	mark.position = Vector3(tgt.x, 2.6 + sin(clock * 8.0) * 0.15, -float(tgt.d))
	if not kit_held("hack"):
		return
	hacking = true
	var rate := hack_rate * (0.4 if tgt.armor else 1.0)
	var take := minf(rate * dt, float(tgt.v))
	tgt.v -= take
	spd += take * 0.9
	_beam(beam, Vector3(px, 1.4, -dist), Vector3(tgt.x, 1.4, -float(tgt.d)))
	hum_t -= dt
	if hum_t <= 0.0:
		hum_t = 0.07
		beep(300.0 + spd * 9.0, 0.06, 0.0, 0.12)
	if tgt.has("is_rival"):
		if tgt.v < spd - 10.0:
			_rival_out()
			bonus += 40
			msg("역해킹!")
			play("good")
	elif tgt.v < 5.0:
		tgt.dead = true
		tgt.fall = 1.0 if randf() < 0.5 else -1.0
		bonus += 30 if tgt.armor else 15
		msg("탈취!")
		play("good")


func _beam(m: MeshInstance3D, a: Vector3, b: Vector3) -> void:
	var dir := b - a
	var l := dir.length()
	if l < 0.2:
		return
	m.visible = true
	m.transform = Transform3D(Basis.looking_at(dir / l) * Basis.from_scale(Vector3(0.14, 0.14, l)), (a + b) * 0.5)


func _kick() -> void:
	if not kit_just("kick") or kick_cd > 0.0:
		return
	kick_cd = 0.45
	kick_anim = 0.2
	var hit := {}
	var near := 3.6
	for b in bikers:
		if b.dead:
			continue
		var dx: float = absf(b.x - px)
		if absf(b.d - dist) < 3.2 and dx < near:
			near = dx
			hit = b
	if rival.on and absf(rival.d - dist) < 3.2 and absf(rival.x - px) < near:
		hit = rival
	if hit.is_empty():
		leg.position.x = 0.9 if steer_sign() >= 0.0 else -0.9
		beep(300.0, 0.06, 200.0, 0.15)
		return
	var sd := 1.0 if float(hit.x) >= px else -1.0
	leg.position.x = 0.9 * sd
	beep(140.0, 0.15, 60.0, 0.35)
	if hit.has("is_rival"):
		_rival_out()
		bonus += 40
		msg("뻥!")
		play("good")
		return
	if hit.armor:
		msg("팅!")
		beep(1200.0, 0.08, 900.0, 0.2)
		return
	hit.dead = true
	hit.vx = sd * 14.0
	hit.fall = sd
	hit.v *= 0.5
	spd += 4.0
	bonus += 10
	msg("뻥!")


func steer_sign() -> float:
	return signf(kit_move.x) if kit_move.x != 0.0 else 1.0


# ---- 움직이는 것들 ----
func _spawn_biker(b: Dictionary, ahead: float) -> void:
	b.d = dist + ahead
	b.x = LANES[randi() % 4] + randf_range(-0.6, 0.6)
	b.tx = b.x
	b.v = COP[zone] + randf_range(-5.0, 2.0)
	b.armor = (zone == 1 and randf() < 0.55) or (zone >= 2 and randf() < 0.35)
	b.dead = false
	b.vx = 0.0
	var r: Node3D = b.root
	r.rotation = Vector3.ZERO
	var sh: MeshInstance3D = b.shell
	sh.visible = b.armor


func _move_bikers(dt: float) -> void:
	for b in bikers:
		var r: Node3D = b.root
		if b.dead:
			b.v = move_toward(b.v, 0.0, 12.0 * dt)
			b.x += b.vx * dt
			b.vx = move_toward(b.vx, 0.0, 10.0 * dt)
			r.rotation.z = move_toward(r.rotation.z, -float(b.fall) * 1.4, 3.0 * dt)
		else:
			if randf() < dt * 0.4:
				b.tx = clampf(b.x + randf_range(-3.0, 3.0), -HALF, HALF)
			b.x = move_toward(b.x, b.tx, 2.0 * dt)
		b.d += b.v * dt
		if b.d < dist - 14.0 or b.d > dist + 260.0:
			_spawn_biker(b, randf_range(90.0, 170.0))
		r.position = Vector3(b.x, 0, -float(b.d))


func _spawn_car(c: Dictionary, i: int, ahead: float) -> void:
	c.on = i < 4 + zone
	var r: Node3D = c.root
	r.visible = c.on
	c.d = dist + ahead
	c.x = LANES[randi() % 4]
	c.v = randf_range(9.0, 15.0)
	var body: MeshInstance3D = c.body
	body.material_override = mat([A, GOOD, D, C, B][randi() % 5])


func _move_cars(dt: float) -> void:
	for i in cars.size():
		var c := cars[i]
		if not c.on:
			if i < 4 + zone:
				_spawn_car(c, i, randf_range(150.0, 220.0))
			continue
		c.d += c.v * dt
		if c.d < dist - 15.0:
			_spawn_car(c, i, randf_range(110.0, 200.0))
		elif absf(c.d - dist) < 2.6 and absf(c.x - px) < 1.6:
			_crash()
			_spawn_car(c, i, randf_range(130.0, 200.0))
		var r: Node3D = c.root
		r.position = Vector3(c.x, 0, -float(c.d))


func _spawn_block(bl: Dictionary, ahead: float) -> void:
	var d := dist + ahead
	for o in blocks:
		if o != bl and o.on:
			d = maxf(d, float(o.d) + 80.0)
	var gd := (zone + 1) * DLEN
	if d > gd - 60.0 and d < gd + 40.0:
		d = gd + 60.0
	bl.d = d
	bl.on = zone >= 2
	bl.gap = randi() % 4
	var r: Node3D = bl.root
	r.visible = bl.on
	r.position.z = -d
	var ln: Array[Node3D] = bl.lanes
	for k in 4:
		ln[k].visible = k != bl.gap
	var go: MeshInstance3D = bl.go
	go.position.x = LANES[bl.gap]


func _move_blocks(prev: float) -> void:
	for i in blocks.size():
		var bl := blocks[i]
		if not bl.on:
			if zone >= 2:
				_spawn_block(bl, 160.0 + 110.0 * i)
			continue
		if prev < bl.d and dist >= bl.d:
			if absf(px - LANES[bl.gap]) > 1.3:
				_crash()
				msg("바리케이드!")
			else:
				beep(1100.0, 0.08, 1500.0, 0.15)
		if bl.d < dist - 8.0:
			_spawn_block(bl, randf_range(170.0, 250.0))


func _spawn_drone(dr: Dictionary, ahead: float) -> void:
	dr.on = zone >= 4
	dr.d = dist + ahead
	dr.x = LANES[randi() % 4]
	dr.tx = dr.x
	dr.hit = false
	var r: Node3D = dr.root
	var spot: MeshInstance3D = dr.spot
	r.visible = dr.on
	spot.visible = dr.on
	spot.material_override = mat(BAD)


func _move_drones(dt: float) -> void:
	for i in drones.size():
		var dr := drones[i]
		if not dr.on:
			if zone >= 4:
				_spawn_drone(dr, 120.0 + 80.0 * i)
			continue
		dr.d += 6.0 * dt
		if randf() < dt * 0.6:
			dr.tx = LANES[randi() % 4]
		dr.x = move_toward(dr.x, dr.tx, 3.0 * dt)
		var spot: MeshInstance3D = dr.spot
		if not dr.hit and absf(dr.d - dist) < 2.5 and absf(dr.x - px) < 1.7:
			dr.hit = true
			gap -= 12.0
			shake = 0.25
			msg("포착!")
			beep(900.0, 0.3, 1400.0, 0.3)
			spot.material_override = mat(D)
		if dr.d < dist - 10.0:
			_spawn_drone(dr, randf_range(150.0, 230.0))
		var r: Node3D = dr.root
		r.position = Vector3(dr.x, 6.5 + sin(clock * 3.0 + i) * 0.3, -float(dr.d))
		spot.position = Vector3(dr.x, 0.04, -float(dr.d))


func _move_rival(dt: float) -> void:
	rbeam.visible = false
	var r: Node3D = rival.root
	if not rival.on:
		if zone < 3:
			return
		rival.t -= dt
		if rival.t <= 0.0:
			rival.on = true
			rival.d = dist - 30.0
			rival.x = clampf(px + (3.0 if px < 0.0 else -3.0), -HALF, HALF)
			rival.v = spd + 10.0
			r.visible = true
			msg("라이벌 도둑!", 1.2)
			beep(500.0, 0.2, 250.0, 0.3)
		return
	var dd: float = rival.d - dist
	var side := 2.4 if rival.x >= px else -2.4
	rival.x = move_toward(rival.x, clampf(px + side, -HALF, HALF), 4.5 * dt)
	rival.v = move_toward(rival.v, spd + (9.0 if dd < 0.0 else 0.5), 6.0 * dt)
	rival.d += rival.v * dt
	# 옆에 붙으면 내 속도를 빨아 간다
	if absf(dd) < 6.0 and absf(rival.x - px) < 4.5:
		spd -= 10.0 * dt
		_beam(rbeam, Vector3(rival.x, 1.4, -float(rival.d)), Vector3(px, 1.4, -dist))
		steal_t -= dt
		if steal_t <= 0.0:
			steal_t = 0.12
			beep(240.0, 0.08, 160.0, 0.14)
			msg("털린다!", 0.3)
	if dd < -45.0 or dd > 120.0:
		_rival_out()
	r.position = Vector3(rival.x, 0, -float(rival.d))


func _rival_out() -> void:
	rival.on = false
	rival.t = 9.0
	var r: Node3D = rival.root
	r.visible = false


func _crash() -> void:
	if shield > 0:
		shield -= 1
		shake = 0.3
		msg("방패!")
		beep(600.0, 0.15, 300.0, 0.3)
		return
	spd *= 0.5
	shake = 0.6
	msg("쾅!")
	play("bad")


# ---- 구역·관문 ----
func _checkpoint() -> void:
	if zone >= 4:
		bonus += 500
		score = int(dist / 10.0) + bonus
		msg("탈출!", 3.0)
		time_limit = 0.01  # 이긴 소리로 끝내기 (다음 판 _reset 에서 0)
		t = 0.0
		end()
		return
	picking = true
	pick_ui.visible = true
	msg("강화 하나!", 60.0)
	play("win")


func _tap(p: Vector2) -> void:
	if not picking:
		return
	for i in 3:
		if Rect2(30 + i * 225, 270, 210, 230).has_point(p):
			_pick(i)
			return


func _pick(i: int) -> void:
	match i:
		0:
			hack_rate *= 1.5
		1:
			tank += 30.0
		2:
			shield_max += 1
	picking = false
	pick_ui.visible = false
	zone += 1
	shield = shield_max
	gap = maxf(gap, 30.0)
	gate.position.z = -(zone + 1) * DLEN
	tower.visible = zone == 4
	msg(NAMES[zone], 1.5)
	play("good")


# ---- 풍경 ----
func _scenery() -> void:
	var z := _zone_of(dist)
	road.position = Vector3(0, -0.25, -dist - 250.0)
	var fy := -1.0
	var fc := SOFT
	match z:
		1:
			fy = -14.0
			fc = GOOD
		2:
			fy = -1.5
			fc = B
		4:
			fc = WHITE
	floor_n.position = Vector3(0, fy, -dist - 250.0)
	floor_n.material_override = mat(fc)
	for s in sides:
		if s.d < dist - 10.0:
			s.d += NSIDE * SP
			_dress(s)
	for tp in tops:
		if tp.d < dist - 10.0:
			tp.d += NSIDE * SP
			_dress_top(tp)
	for m in dashes:
		if -m.position.z < dist - 8.0:
			m.position.z -= NDASH * 10.0


func _dress(s: Dictionary) -> void:
	var m: MeshInstance3D = s.n
	var sd: float = s.side
	var odd := int(s.i) % 2 == 1
	var sz := Vector3.ONE
	var x := 0.0
	var y0 := 0.0
	var col := WHITE
	match _zone_of(s.d):
		0:  # 시장 골목: 낮은 가게들
			sz = Vector3(3.5, randf_range(2.5, 5.5), SP - 2.0)
			x = sd * (8.2 + randf())
			col = [A, D, C, GOOD, B][randi() % 5]
		1:  # 고가도로: 난간, 저 아래 빌딩
			if odd:
				sz = Vector3(9, randf_range(18.0, 40.0), 9)
				x = sd * randf_range(26.0, 40.0)
				y0 = -14.0
				col = [B, C, WHITE][randi() % 3]
			else:
				sz = Vector3(0.5, 1.1, SP - 0.3)
				x = sd * 6.8
				col = D
		2:  # 항구: 컨테이너, 크레인
			if odd:
				sz = Vector3(1.2, 16, 1.2)
				x = sd * 15.0
				col = D
			else:
				sz = Vector3(3, 2.6 * randi_range(1, 3), 7.5)
				x = sd * (8.5 + randf() * 2.0)
				col = [BAD, B, GOOD, A][randi() % 4]
		3:  # 터널: 번갈아 빛나는 벽
			sz = Vector3(1, 7.8, SP)
			x = sd * 7.2
			col = WHITE if odd else B
		_:  # 도심 탑: 높은 빌딩
			sz = Vector3(8, randf_range(20.0, 48.0), 9)
			x = sd * randf_range(11.0, 15.0)
			col = [B, C, WHITE, D][randi() % 4]
	m.scale = sz
	m.position = Vector3(x, y0 + sz.y * 0.5, -float(s.d))
	m.material_override = mat(col)


func _dress_top(tp: Dictionary) -> void:
	var m: MeshInstance3D = tp.n
	m.visible = _zone_of(tp.d) == 3
	m.position = Vector3(0, 8.0, -float(tp.d))
	m.material_override = mat(C if int(tp.i) % 2 == 0 else WHITE)
