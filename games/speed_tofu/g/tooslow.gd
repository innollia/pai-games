extends Tofu
## 느린 걸음(옆모습). 탭한 방향으로 한 걸음, 나를 탭하면 제자리 걸음. 한 걸음(실제 0.6초) 동안 세상은 4초(구역마다 다름)가 흐르고, 걷는 중엔 조작 불가·세상도 나를 못 본다.
## 서 있으면 세상은 보통 속도. 걸음이 끝난 순간이나 서 있는 동안 경비의 눈줄·내려온 작두문·불 위면 죽고 그 방부터. 초록 출구에 닿으면 다음 방.
## 한 문장: 나는 한 걸음에 세상이 4초씩 흘러가 버리는 느린 자로서, 걷는 동안엔 아무것도 못 하고 서 있는 동안에도 세상이 다가오는 제약 속에서 걸음의 때와 수를 골라 출구까지 가지만, 걸음을 뗄 때마다 세상이 나를 앞질러 가 버리는 대가를 감수한다.

const GREY := Color("cfd4db")
const STEP_REAL := 0.6  # 한 걸음에 드는 실제 초
const SIGHT := 3  # 경비 눈줄 칸 수
const GUARD_V := 1.0  # 경비 칸/초
const PAUSE := 1.0  # 순찰 끝에서 멈춰 보는 초
const DOOR_T := 4.0  # 작두문 열림 4초 / 닫힘 4초
const FIRE_SPREAD := 2.0
const FIRE_BURN := 4.0
# 지도: # 벽, . 돌, w 나무, F 불 시작, S 시작, E 출구, H 사다리(위 칸으로), D/d 작두문(열림/닫힘부터), G 경비, > < 순찰 끝
const ROOMS := [
	{"name": "1-1 작두문", "ratio": 4.0, "map": ["############", "S..D...d...E"]},
	{"name": "1-2 경비", "ratio": 4.0, "map": ["####.......#", "S...H>G..<HE"]},
	{"name": "2-1 보초", "ratio": 4.0, "map": ["E..>G...<...", "S....d..>G<H"]},
	{"name": "2-2 교차", "ratio": 4.0, "map": ["E.D......>G<", "H..>G....<.H", "S.......d..H"]},
	{"name": "3-1 불 (맛보기)", "ratio": 6.0, "map": ["############", "SwwwwFwwwwwE"]},
]

var lv := 0
var level: Node3D
var rows: Array = []
var nw := 0
var nh := 0
var ratio := 4.0
var wt := 0.0  # 이 방의 세상 시간
var cx := 0
var cy := 0
var me_n: MeshInstance3D
var stepping := false
var sk := 0.0
var sfrom := Vector3.ZERO
var sto := Vector3.ZERO
var tx := 0
var ty := 0
var guards: Array[Dictionary] = []  # {root, nose, eye, r, lo, hi, x, dir, pause}
var doors := {}  # Vector2i -> {n, ph, open}
var woods := {}  # Vector2i -> {n, state(1 나무 2 불 3 재), lit, spread}
var die_t := 0.0
var clear_t := 0.0
var tick := 0.0


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 50.0
	howto = "탭한 방향으로 한 걸음(나를 탭하면 제자리 걸음). 걷는 동안 조작은 안 되고 세상은 4초가 흐른다. 서 있으면 세상은 보통 속도.\n걸음이 끝난 순간이나 서 있는 동안 경비의 붉은 눈줄·내려온 작두문·불 위에 있으면 그 방부터 다시. 걷는 중엔 안 보인다.\n보라 사다리에서는 위·아래로도 한 걸음. 초록 출구에 닿으면 다음 방."


func _reset() -> void:
	level = null
	lv = 0
	_room(0)


func _pos(c: float, r: int) -> Vector3:
	return Vector3(c - (nw - 1) * 0.5, (nh - 1 - r) * 2.0, 0)


func _room(i: int) -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	var rm: Dictionary = ROOMS[i]
	rows = rm.map
	nh = rows.size()
	nw = rows[0].length()
	ratio = rm.ratio
	guards.clear()
	doors.clear()
	woods.clear()
	wt = 0.0
	stepping = false
	die_t = 0.0
	clear_t = 0.0
	tick = 0.0
	box(Vector3(0, nh - 1.0 + 0.5, -1.0), Vector3(nw + 2.0, nh * 2.0 + 1.0, 0.2), WHITE, level)
	for r in nh:
		for c in nw:
			var ch: String = rows[r][c]
			var p := _pos(c, r)
			if ch == "#":
				box(p + Vector3(0, 1.0, 0), Vector3(1, 2, 1), GREY, level)
				continue
			var wood := ch == "w" or ch == "F"
			var col := SOFT if (c + r) % 2 == 0 else WHITE
			if wood:
				col = A
			var slab := box(p + Vector3(0, -0.15, 0), Vector3(1, 0.3, 1.2), col, level)
			if wood:
				woods[Vector2i(c, r)] = {"n": slab, "state": 1, "lit": 0.0, "spread": false}
			match ch:
				"S":
					cx = c
					cy = r
				"E":
					box(p + Vector3(0, 0.8, -0.3), Vector3(0.8, 1.6, 0.3), GOOD, level)
				"H":
					box(p + Vector3(0, 1.0, -0.45), Vector3(0.35, 2.0, 0.2), C, level)
				"<", ">":
					box(p + Vector3(0, 0.25, -0.3), Vector3(0.2, 0.5, 0.2), D, level)
				"D", "d":
					var dn := box(p + Vector3(0, 1.0, 0), Vector3(0.9, 2.0, 0.6), INK, level)
					doors[Vector2i(c, r)] = {"n": dn, "ph": 0.0 if ch == "D" else DOOR_T, "open": ch == "D"}
				"G":
					_add_guard(c, r)
				"F":
					_ignite(Vector2i(c, r))
	me_n = box(_pos(cx, cy) + Vector3(0, 0.6, 0.1), Vector3(0.6, 1.2, 0.5), ME, level)
	cam.position = Vector3(0, nh - 1.0 + 0.9, 14.0)
	cam.rotation = Vector3.ZERO
	msg("%s · 한 걸음=%d초" % [rm.name, int(ratio)], 1.6)


func _add_guard(c: int, r: int) -> void:
	var lo := c
	while lo > 0 and rows[r][lo - 1] != "#" and rows[r][lo] != ">":
		lo -= 1
	var hi := c
	while hi < nw - 1 and rows[r][hi + 1] != "#" and rows[r][hi] != "<":
		hi += 1
	var root := Node3D.new()
	root.position = _pos(c, r)
	level.add_child(root)
	box(Vector3(0, 0.7, 0), Vector3(0.6, 1.4, 0.5), BAD, root)
	var nose := box(Vector3(0.35, 1.15, 0), Vector3(0.3, 0.25, 0.25), INK, root)
	var eye := box(Vector3.ZERO, Vector3(1, 0.12, 0.3), BAD.lightened(0.45), level)
	guards.append({"root": root, "nose": nose, "eye": eye, "r": r, "lo": float(lo), "hi": float(hi), "x": float(c), "dir": 1.0, "pause": 0.0})


func _ignite(k: Vector2i) -> void:
	if not woods.has(k):
		return
	var w: Dictionary = woods[k]
	if w.state != 1:
		return
	w.state = 2
	w.lit = wt
	w.spread = false
	w.n.material_override = mat(BAD)
	beep(90.0, 0.1, 40.0, 0.15)


func _step(dt: float) -> void:
	if die_t > 0.0:
		die_t -= dt
		if die_t <= 0.0:
			_room(lv)
		return
	if clear_t > 0.0:
		clear_t -= dt
		if clear_t <= 0.0:
			lv += 1
			score = lv
			if lv >= ROOMS.size():
				msg("맛보기 끝", 1.5)
				end()
			else:
				_room(lv)
		return
	var gd := dt
	if stepping:
		gd = dt * ratio / STEP_REAL
		sk = minf(sk + dt / STEP_REAL, 1.0)
		var e := sk * sk * (3.0 - 2.0 * sk)
		me_n.position = sfrom.lerp(sto, e)
		var st := sin(sk * PI)
		if ty != cy:
			me_n.scale = Vector3(0.6 - st * 0.15, 1.2 + st * 0.5, 0.5)
		else:
			me_n.scale = Vector3(0.6 + st * 0.6, 1.2 - st * 0.25, 0.5)
	wt += gd
	_world(gd)
	if stepping and sk >= 1.0:
		stepping = false
		cx = tx
		cy = ty
		me_n.position = sto
		me_n.scale = Vector3(0.6, 1.2, 0.5)
		beep(140.0, 0.05, 0.0, 0.18)
		if rows[cy][cx] == "E":
			clear_t = 1.0
			play("good")
			msg("출구", 0.9)
			return
	if not stepping:
		_check()
	cam.fov = lerpf(cam.fov, 58.0 if stepping else 50.0, 1.0 - exp(-12.0 * dt))
	gauge(sk if stepping else 0.0, BAD)


func _world(gd: float) -> void:
	tick += gd
	while tick >= 1.0:
		tick -= 1.0
		beep(440.0 if stepping else 260.0, 0.03, 0.0, 0.1)
	for g in guards:
		var pause: float = g.pause
		var gx: float = g.x
		var dir: float = g.dir
		if pause > 0.0:
			pause -= gd
			if pause <= 0.0:
				dir = -dir
				beep(330.0, 0.05, 0.0, 0.1)
		else:
			gx += dir * GUARD_V * gd
			if gx >= g.hi:
				gx = g.hi
				pause = PAUSE
			elif gx <= g.lo:
				gx = g.lo
				pause = PAUSE
		g.pause = pause
		g.x = gx
		g.dir = dir
		var root: Node3D = g.root
		root.position = _pos(gx, g.r)
		var nose: MeshInstance3D = g.nose
		nose.position.x = 0.35 * dir
		var cells := _sight(g)
		var eye: MeshInstance3D = g.eye
		eye.visible = cells.size() > 0
		if eye.visible:
			var n := cells.size()
			eye.scale.x = float(n)
			eye.position = _pos(roundi(gx) + dir * (n + 1) * 0.5, g.r) + Vector3(0, 1.15, 0.3)
	for k in doors:
		var d: Dictionary = doors[k]
		var o := _open(d)
		if o != d.open:
			d.open = o
			beep(500.0 if o else 110.0, 0.08, 0.0, 0.16)
		var dn: MeshInstance3D = d.n
		dn.scale.y = 0.3 if o else 2.0
		dn.position.y = _pos(0, k.y).y + (1.85 if o else 1.0)
	var lit_now: Array[Vector2i] = []
	for k in woods:
		var w: Dictionary = woods[k]
		if w.state != 2:
			continue
		if wt - w.lit >= FIRE_BURN:
			w.state = 3
			w.n.material_override = mat(GREY)
		elif wt - w.lit >= FIRE_SPREAD and not w.spread:
			w.spread = true
			lit_now.append(k + Vector2i(1, 0))
			lit_now.append(k + Vector2i(-1, 0))
	for k in lit_now:
		_ignite(k)


func _open(d: Dictionary) -> bool:
	return fmod(wt + float(d.ph), DOOR_T * 2.0) < DOOR_T


## 경비 앞 눈줄이 닿는 칸들 (벽·닫힌 문에 막힌다)
func _sight(g: Dictionary) -> Array[int]:
	var out: Array[int] = []
	var gc := roundi(g.x)
	var r: int = g.r
	for k in range(1, SIGHT + 1):
		var c: int = gc + int(g.dir) * k
		if c < 0 or c >= nw or rows[r][c] == "#":
			break
		var key := Vector2i(c, r)
		if doors.has(key) and not doors[key].open:
			break
		out.append(c)
	return out


## 서 있는 순간의 죽음 검사
func _check() -> void:
	var here := Vector2i(cx, cy)
	if doors.has(here) and not doors[here].open:
		_die("끼였다")
		return
	if woods.has(here) and woods[here].state == 2:
		_die("탔다")
		return
	for g in guards:
		if g.r != cy:
			continue
		if roundi(g.x) == cx:
			_die("잡혔다")
			return
		if cx in _sight(g):
			_die("들켰다")
			return


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 1.3
	stepping = false
	me_n.material_override = mat(BAD)
	play("bad")
	msg(why, 1.2)


func _go(dx: int, dy: int) -> void:
	var nx := cx + dx
	var ny := cy + dy
	if dy < 0 and rows[cy][cx] != "H":
		msg("사다리 없음", 0.5)
		beep(120.0, 0.1, 0.0, 0.15)
		return
	if dy > 0 and (ny >= nh or rows[ny][cx] != "H"):
		msg("사다리 없음", 0.5)
		beep(120.0, 0.1, 0.0, 0.15)
		return
	if nx < 0 or nx >= nw or ny < 0 or ny >= nh or rows[ny][nx] == "#":
		msg("벽", 0.5)
		beep(120.0, 0.1, 0.0, 0.15)
		return
	tx = nx
	ty = ny
	stepping = true
	sk = 0.0
	sfrom = me_n.position
	sto = _pos(nx, ny) + Vector3(0, 0.6, 0.1)
	play("tap")


func _tap(p: Vector2) -> void:
	if stepping or die_t > 0.0 or clear_t > 0.0:
		return
	var d := p - cam.unproject_position(me_n.position)
	var dx := 0
	var dy := 0
	if d.length() > 110.0:
		if absf(d.x) > absf(d.y):
			dx = 1 if d.x > 0.0 else -1
		else:
			dy = 1 if d.y > 0.0 else -1
	_go(dx, dy)
