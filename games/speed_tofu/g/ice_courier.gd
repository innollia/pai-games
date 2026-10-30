extends Tofu
## 빙판 배달(위에서 보는 3D, 가까운 카메라). 왼손 조이스틱은 밀기뿐 — 빙판이라 가속만 되고 안 멈춘다.
## 멈추려면 벽에 붙어 "차기": 스틱 없이 차면 멈추고, 스틱 방향으로 차면 그쪽으로 튄다. 상자를 들면 무거워져 밀기·멈추기가 반쯤만 된다.
## 주황 칸의 상자를 들고 초록 칸에 놓는다. 흰 얇은 얼음은 빨라야(6 m/s) 건너고 느리면 빠져 죽는다. 세 번 건너면 구멍이 된다.
## 보라 사람과 부딪히면 상자가 미끄러져 나간다. 막대(시간) 안에 n건 배달하면 다음 구역. 구역 3개(골목이 좁아지고 얇은 얼음·사람이 는다).

const TS := 2.0  # 칸 크기 (m)
const RME := 0.45
const TOPV := 14.0
const ACC := 11.0
const KICK := 11.0
const ICE_MIN := 6.0  # 얇은 얼음을 건너는 최소 속도
const BUMP := 7.0  # 이 속도 이상으로 벽에 박으면 비틀거림(상자 놓침)
const MAPS := [
	{"need": 4, "time": 50.0, "peds": [[1, 8, 12, 8], [12, 1, 12, 13], [1, 13, 12, 13]], "rows": [
		"##############",
		"#S...........#",
		"#....##......#",
		"#.P..##..D...#",
		"#............#",
		"#..~~........#",
		"#..~~..###...#",
		"#......###...#",
		"#............#",
		"#.##.....~~..#",
		"#.##.....~~..#",
		"#D......#....#",
		"#.......#..D.#",
		"#............#",
		"##############"]},
	{"need": 5, "time": 55.0, "peds": [[7, 5, 14, 5], [14, 5, 14, 13], [2, 13, 12, 13], [7, 2, 14, 2]], "rows": [
		"################",
		"#S....#........#",
		"#.....#..D.....#",
		"#..#..#........#",
		"#..#..####~~####",
		"#..#...........#",
		"#P.#..###..###.#",
		"#.....#......#.#",
		"#######~~....#.#",
		"#D....#......#.#",
		"#.....#..##..#.#",
		"#..####..##..#.#",
		"#..~~........#.#",
		"#............D.#",
		"################"]},
	{"need": 6, "time": 60.0, "peds": [[8, 1, 14, 1], [8, 9, 13, 9], [1, 15, 14, 15], [1, 9, 6, 9], [13, 2, 13, 14]], "rows": [
		"################",
		"#S.....#.......#",
		"#......#..D....#",
		"#..##..#.......#",
		"#..##..~~..##..#",
		"#......~~..##..#",
		"#..P...#.......#",
		"#......#..~~~..#",
		"####~~##..~~~..#",
		"#......#.......#",
		"#..D...#..##..~#",
		"#......~~.##..~#",
		"#..##..~~.....~#",
		"#..##..#...D..~#",
		"#......#......~#",
		"#..............#",
		"################"]},
]

var zone := 0
var lvl: Node3D
var rows: PackedStringArray
var cols := 0
var nrow := 0
var ox := 0.0
var oz := 0.0
var me_root: Node3D
var me_body: MeshInstance3D
var pos := Vector3.ZERO
var vel := Vector3.ZERO
var carrying := false
var pack: MeshInstance3D
var pack_home := Vector3.ZERO
var pack_pos := Vector3.ZERO
var pack_vel := Vector3.ZERO
var pack_free := false  # 바닥에 떨어져 미끄러지는 중
var pads: Array[Vector3] = []
var pad_n: Array[MeshInstance3D] = []
var target := -1
var arrow: MeshInstance3D
var thin := {}  # "c,r" -> {n: 상자, cross: 건넌 횟수}
var holes := {}
var on_thin := ""
var peds: Array[Dictionary] = []  # {root, a, b, goal, p, v, knock}
var clock := 0.0
var clock_max := 1.0
var done := 0
var touch_t := 0.0
var touch_n := Vector3.ZERO
var stun := 0.0
var die_t := 0.0
var zone_t := 0.0
var scrape := 0.0
var focus := Vector3.ZERO
var ice_c := B.lightened(0.72)
var pad_off := GOOD.lightened(0.6)


func _setup() -> void:
	howto = "빙판 마을 배달부. 왼손 조이스틱은 밀기뿐 — 빙판이라 멈추지 못한다.\n멈추려면 벽에 붙어 차기. 스틱 없이 차면 멈추고, 스틱 방향으로 차면 그쪽으로 튄다.\n주황 칸의 상자를 들고 초록 칸에 놓는다. 상자를 들면 무거워 반밖에 못 멈춘다.\n흰 얇은 얼음은 빨라야 건넌다. 느리면 빠져 죽는다. 사람과 부딪히면 상자를 놓친다. 막대는 남은 시간."
	time_limit = 0.0
	cam.fov = 70.0
	kit_stick()
	kit_button("kick", "차기", Vector2(590, 1080), 100.0, A)


func _reset() -> void:
	lvl = null
	zone = 0
	done = 0
	zone_t = 0.0
	die_t = 0.0
	_build(0)


func _tw(c: int, r: int) -> Vector3:
	return Vector3(ox + (c + 0.5) * TS, 0.0, oz + (r + 0.5) * TS)


func _at(c: int, r: int) -> String:
	if c < 0 or r < 0 or c >= cols or r >= nrow:
		return "#"
	return rows[r][c]


func _cr(p: Vector3) -> Vector2i:
	return Vector2i(int(floor((p.x - ox) / TS)), int(floor((p.z - oz) / TS)))


func _build(z: int) -> void:
	if lvl:
		lvl.queue_free()
	lvl = Node3D.new()
	world.add_child(lvl)
	var M: Dictionary = MAPS[z]
	rows = PackedStringArray(M.rows)
	nrow = rows.size()
	cols = rows[0].length()
	ox = -cols * TS * 0.5
	oz = -nrow * TS * 0.5
	box(Vector3(0, -0.1, 0), Vector3(cols * TS, 0.2, nrow * TS), ice_c, lvl)
	thin.clear()
	holes.clear()
	on_thin = ""
	pads.clear()
	pad_n.clear()
	var start := Vector3.ZERO
	var open: Array[Vector3] = []
	for r in nrow:
		var run := 0
		for c in cols + 1:
			var ch := _at(c, r)
			if ch == "#":
				run += 1
				continue
			if run > 0:
				var x0 := ox + (c - run) * TS
				box(Vector3(x0 + run * TS * 0.5, 1.2, oz + (r + 0.5) * TS), Vector3(run * TS, 2.4, TS), SOFT, lvl)
				run = 0
			if c >= cols:
				continue
			var w := _tw(c, r)
			match ch:
				"~":
					var n := box(w + Vector3(0, 0.02, 0), Vector3(TS - 0.1, 0.04, TS - 0.1), WHITE, lvl)
					thin["%d,%d" % [c, r]] = {"n": n, "cross": 0}
				"S":
					start = w
				"P":
					pack_home = w
					box(w + Vector3(0, 0.03, 0), Vector3(1.6, 0.06, 1.6), A, lvl)
				"D":
					pads.append(w)
					pad_n.append(box(w + Vector3(0, 0.03, 0), Vector3(1.6, 0.06, 1.6), pad_off, lvl))
				".":
					open.append(w)
	# 눈더미 (움직임을 느끼게 하는 바닥 표식)
	for i in 14:
		var w: Vector3 = open[randi() % open.size()]
		box(w + Vector3(randf_range(-0.6, 0.6), 0.1, randf_range(-0.6, 0.6)), Vector3(0.5, 0.22, 0.5), WHITE, lvl)
	peds.clear()
	for pd in M.peds:
		var root := Node3D.new()
		lvl.add_child(root)
		box(Vector3(0, 0.55, 0), Vector3(0.55, 1.1, 0.4), C, root)
		box(Vector3(0, 1.3, 0), Vector3(0.36, 0.36, 0.36), SOFT, root)
		var a := _tw(pd[0], pd[1])
		var b := _tw(pd[2], pd[3])
		var k := randf()
		peds.append({"root": root, "a": a, "b": b, "goal": b, "p": a.lerp(b, k), "v": Vector3.ZERO, "knock": 0.0})
	me_root = Node3D.new()
	lvl.add_child(me_root)
	me_body = box(Vector3(0, 0.35, 0), Vector3(0.7, 0.7, 0.7), ME, me_root)
	box(Vector3(0, 0.85, 0), Vector3(0.3, 0.3, 0.3), SOFT, me_root)
	pack = box(Vector3.ZERO, Vector3(0.6, 0.55, 0.6), D, lvl)
	arrow = box(Vector3.ZERO, Vector3(0.8, 0.14, 0.26), A, lvl)
	pos = start
	vel = Vector3.ZERO
	focus = pos
	carrying = false
	pack_free = false
	stun = 0.0
	touch_t = 0.0
	done = 0
	clock_max = float(M.time)
	clock = clock_max
	target = -1
	_next_target()
	msg("구역 %d  %d건" % [z + 1, int(M.need)], 1.3)


func _next_target() -> void:
	var i := randi() % pads.size()
	if pads.size() > 1 and i == target:
		i = (i + 1) % pads.size()
	target = i
	for k in pad_n.size():
		pad_n[k].material_override = mat(GOOD if k == target else pad_off)


## 원(p, 반지름 r)을 벽 칸 밖으로 밀어낸다. v의 벽 쪽 성분은 튕긴다. n은 밀려난 방향의 합.
func _slide(p: Vector3, v: Vector3, r: float, bounce: float) -> Dictionary:
	var nsum := Vector3.ZERO
	for it in 2:
		var c0 := int(floor((p.x - r - ox) / TS))
		var c1 := int(floor((p.x + r - ox) / TS))
		var r0 := int(floor((p.z - r - oz) / TS))
		var r1 := int(floor((p.z + r - oz) / TS))
		for c in range(c0, c1 + 1):
			for rr in range(r0, r1 + 1):
				if _at(c, rr) != "#":
					continue
				var minx := ox + c * TS
				var minz := oz + rr * TS
				var cx := clampf(p.x, minx, minx + TS)
				var cz := clampf(p.z, minz, minz + TS)
				var d := Vector3(p.x - cx, 0, p.z - cz)
				var L := d.length()
				if L >= r:
					continue
				var n: Vector3
				if L < 0.0001:
					# 가운데가 칸 안: 제일 가까운 면으로
					var ex := minf(p.x - minx, minx + TS - p.x)
					var ez := minf(p.z - minz, minz + TS - p.z)
					if ex < ez:
						n = Vector3(-1 if p.x - minx < TS * 0.5 else 1, 0, 0)
						p.x = minx - r if n.x < 0 else minx + TS + r
					else:
						n = Vector3(0, 0, -1 if p.z - minz < TS * 0.5 else 1)
						p.z = minz - r if n.z < 0 else minz + TS + r
				else:
					n = d / L
					p += n * (r - L)
				var into := -v.dot(n)
				if into > 0.0:
					v += n * into * (1.0 + bounce)
				nsum += n
	return {"p": p, "v": v, "n": nsum}


func _step(dt: float) -> void:
	if die_t > 0.0:
		die_t -= dt
		me_root.position.y -= dt * 1.6
		me_root.scale = me_root.scale.move_toward(Vector3(0.3, 0.3, 0.3), dt)
		_camera(dt)
		if die_t <= 0.0:
			end()
		return
	if zone_t > 0.0:
		zone_t -= dt
		if zone_t <= 0.0:
			_build(zone)
		_camera(dt)
		return
	clock -= dt
	gauge(clock / clock_max, BAD if clock < 10.0 else B)
	if clock <= 0.0:
		msg("시간 끝", 1.2)
		play("bad")
		end()
		return
	# 밀기: 가속만. 상자를 들면 두 배 무겁다
	var mass := 2.0 if carrying else 1.0
	if stun > 0.0:
		stun -= dt
	elif kit_move.length() > 0.05:
		vel += Vector3(kit_move.x, 0, kit_move.y) * (ACC / mass) * dt
	vel -= vel * 0.05 * dt
	if vel.length() > TOPV:
		vel = vel.normalized() * TOPV
	touch_t -= dt
	if kit_just("kick"):
		_kick()
	var prev := vel
	pos += vel * dt
	var hit := _slide(pos, vel, RME, 0.3)
	pos = hit.p
	vel = hit.v
	var nn: Vector3 = hit.n
	if nn.length() > 0.01:
		touch_t = 0.2
		touch_n = nn.normalized()
		var impact := (prev - vel).length() / 1.3
		if impact > BUMP:
			stun = 0.35
			beep(80.0, 0.2, 40.0, 0.4)
			msg("쿵!", 0.5)
			if carrying:
				_drop(touch_n * 3.0)
		elif impact > 1.5:
			beep(140.0, 0.05, 0.0, 0.15)
	var spd := vel.length()
	# 얇은 얼음·구멍
	var cr := _cr(pos)
	var key := "%d,%d" % [cr.x, cr.y]
	if holes.has(key):
		_die("구멍")
		return
	if _at(cr.x, cr.y) == "~":
		if spd < ICE_MIN:
			_die("빠졌다")
			return
		if key != on_thin:
			on_thin = key
			var tb: Dictionary = thin[key]
			tb.cross += 1
			beep(1400.0, 0.06, 600.0, 0.2)
			var n: MeshInstance3D = tb.n
			if tb.cross >= 3:
				holes[key] = true
				n.material_override = mat(ME)
				n.position.y = -0.08
				msg("구멍!", 0.5)
			else:
				n.material_override = mat(SOFT)
	else:
		on_thin = ""
	# 상자 줍기·배달
	if not carrying:
		var where := pack_pos if pack_free else pack_home
		if Vector2(pos.x - where.x, pos.z - where.z).length() < 0.95:
			carrying = true
			pack_free = false
			beep(600.0, 0.08, 900.0, 0.25)
			msg("들었다", 0.4)
	elif Vector2(pos.x - pads[target].x, pos.z - pads[target].z).length() < 1.1:
		_deliver()
		if over or zone_t > 0.0:
			return
	_peds(dt)
	if die_t > 0.0:
		return
	# 떨어진 상자는 저 혼자 미끄러진다
	if pack_free:
		pack_pos += pack_vel * dt
		pack_vel -= pack_vel * 0.9 * dt
		var ph := _slide(pack_pos, pack_vel, 0.3, 0.6)
		pack_pos = ph.p
		pack_vel = ph.v
		var pc := _cr(pack_pos)
		if holes.has("%d,%d" % [pc.x, pc.y]):
			pack_free = false
			beep(500.0, 0.2, 150.0, 0.25)
			msg("상자 빠짐", 0.8)
	# 그림
	me_root.position = pos
	var lean := spd / TOPV
	if spd > 0.5:
		me_root.rotation.y = atan2(-vel.z, vel.x)
	me_body.scale = Vector3(0.7 + lean * 0.25, 0.7 - lean * 0.15, 0.7 - lean * 0.1)
	if carrying:
		pack.position = pos + Vector3(0, 1.05, 0)
		pack.rotation.y = me_root.rotation.y
	elif pack_free:
		pack.position = pack_pos + Vector3(0, 0.28, 0)
	else:
		pack.position = pack_home + Vector3(0, 0.28, 0)
	var goal: Vector3 = pads[target] if carrying else (pack_pos if pack_free else pack_home)
	var to := goal - pos
	to.y = 0.0
	if to.length() > 0.1:
		var dirn := to.normalized()
		arrow.position = pos + dirn * 1.4 + Vector3(0, 0.5, 0)
		arrow.rotation.y = atan2(-dirn.z, dirn.x)
	arrow.visible = to.length() > 2.5
	arrow.material_override = mat(GOOD if carrying else A)
	# 얼음 긁는 소리는 빠를수록 잦다
	scrape -= dt * spd / TOPV
	if spd > 1.0 and scrape <= 0.0:
		scrape = 0.16
		beep(90.0 + spd * 14.0, 0.04, 0.0, 0.1)
	_camera(dt)


func _camera(dt: float) -> void:
	var lead := pos + vel * 0.28
	focus = focus.lerp(lead, 1.0 - exp(-10.0 * dt))
	var h := 8.0 + vel.length() * 0.14
	cam.position = focus + Vector3(0, h, h * 0.5)
	cam.look_at(focus, Vector3.UP)


## 벽에 붙어 있으면 그 벽의 바깥 방향, 아니면 0
func _wall_normal() -> Vector3:
	var hit := _slide(pos, Vector3.ZERO, RME + 0.3, 0.0)
	var n: Vector3 = hit.n
	if n.length() > 0.01:
		return n.normalized()
	if touch_t > 0.0:
		return touch_n
	return Vector3.ZERO


func _kick() -> void:
	var n := _wall_normal()
	if n == Vector3.ZERO:
		beep(300.0, 0.04, 0.0, 0.12)
		msg("벽 없음", 0.4)
		return
	if kit_move.length() > 0.3:
		var d := Vector3(kit_move.x, 0, kit_move.y).normalized()
		if d.dot(n) < 0.1:
			var along := d - n * d.dot(n)
			d = along.normalized() if along.length() > 0.1 else n
		vel = d * (KICK * (0.75 if carrying else 1.0))
		beep(240.0, 0.1, 520.0, 0.3)
		msg("차기!", 0.3)
	elif carrying:
		vel *= 0.45
		beep(160.0, 0.12, 80.0, 0.3)
		msg("무겁다", 0.4)
	else:
		vel = Vector3.ZERO
		beep(200.0, 0.08, 0.0, 0.3)
		msg("멈춤", 0.3)
	pos += n * 0.05


func _drop(extra: Vector3) -> void:
	carrying = false
	pack_free = true
	pack_pos = pos + Vector3(0, 0, 0)
	pack_vel = vel * 0.9 + extra + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	beep(400.0, 0.15, 120.0, 0.3)
	msg("상자!", 0.6)


func _deliver() -> void:
	carrying = false
	score += 1
	done += 1
	clock = minf(clock + 5.0, clock_max)
	play("good")
	var need := int(MAPS[zone].need)
	if done >= need:
		zone += 1
		if zone >= MAPS.size():
			msg("완주!", 1.5)
			play("win")
			end()
			return
		zone_t = 1.3
		vel = Vector3.ZERO
		msg("구역 %d" % (zone + 1), 1.3)
		return
	msg("배달 %d/%d" % [done, need], 0.7)
	_next_target()


func _peds(dt: float) -> void:
	for pd in peds:
		var p: Vector3 = pd.p
		if pd.knock > 0.0:
			pd.knock -= dt
			p += pd.v * dt
			pd.v -= pd.v * 2.5 * dt
			var h := _slide(p, pd.v, 0.3, 0.5)
			p = h.p
			pd.v = h.v
			if pd.knock <= 0.0:
				pd.goal = pd.a if p.distance_to(pd.a) < p.distance_to(pd.b) else pd.b
		else:
			var g: Vector3 = pd.goal
			var to := g - p
			if to.length() < 0.15:
				pd.goal = pd.a if g == pd.b else pd.b
			else:
				p += to.normalized() * 1.9 * dt
		pd.p = p
		var root: Node3D = pd.root
		root.position = p
		var face: Vector3 = (pd.v if pd.knock > 0.0 else pd.goal - p)
		if face.length() > 0.1:
			root.rotation.y = atan2(-face.z, face.x) - PI * 0.5
		root.rotation.z = sin(pd.knock * 20.0) * 0.4 if pd.knock > 0.0 else 0.0
		# 나와 부딪힘
		var d := pos - p
		d.y = 0.0
		var L := d.length()
		if L < RME + 0.35 and L > 0.001:
			var n := d / L
			var spd := vel.length()
			pos += n * (RME + 0.35 - L)
			if spd > 2.5:
				pd.v = -n * spd * 0.7
				pd.knock = 1.2
				vel = n * maxf(spd * 0.45, 2.0)
				beep(120.0, 0.15, 60.0, 0.35)
				if carrying:
					_drop(n * 2.0)
				else:
					msg("쿵", 0.4)
			else:
				vel += n * 1.5
				beep(260.0, 0.05, 0.0, 0.15)


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 0.9
	vel = Vector3.ZERO
	carrying = false
	play("bad")
	beep(300.0, 0.4, 60.0, 0.3)
	msg(why, 1.0)
