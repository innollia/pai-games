extends Tofu
## 느린 성 탐험(쯔꾸르식 위에서 보기). 가고 싶은 쪽을 탭하면 한 칸, 나를 탭하면 제자리 걸음. 한 걸음(실제 0.6초)에 세상은 4초(부엌 6초)가 흐르고, 걷는 중엔 조작 불가·아무도 나를 못 본다. 서 있으면 세상은 1배.
## 방에 들어서면 첫 걸음까지 세상이 멈춰 있다. 서 있거나 내려선 칸이 눈줄·닫힌 쇠살문·올라간 다리·밀물·불이면 그 방 입구부터. 부엌·뜰의 인장 둘로 대청 북문을 열고 수문 위 탈출구로.
## 한 문장: 나는 한 걸음에 세상이 4초씩 흘러가 버리는 느린 좀도둑으로서, 걷는 동안엔 아무것도 못 하고 서 있으면 경비의 눈이 다가오는 성 안에서 칸을 골라 한 걸음씩 옮겨 인장 둘을 모아 탑의 수문까지 가지만, 걸음을 뗄 때마다 세상이 나를 앞질러 가 버리는 대가를 감수한다.

const GREY := Color("cfd4db")
const WOOD := Color("e8b878")
const SAND := Color("f3e3b0")
const SHADE := Color("a9b8d6")
const STEP_REAL := 0.6  # 한 걸음에 드는 실제 초
const DOOR_T := 4.0  # 쇠살문 4초 열림 / 4초 닫힘
const BRIDGE_T := 6.0  # 다리 6초 내림 / 6초 올림
const TIDE_T := 12.0  # 밀물 한 주기
const TIDE_DRY := 5.0  # 그중 마른 초 (열마다 1초씩 어긋남)
const SUN_T := 24.0  # 해 한 바퀴
const FIRE_SPREAD := 2.0
const FIRE_BURN := 4.0
const NC := 9
const NR := 12
const PORTALS := ["^", "v", "[", "]"]
const SOLID := ["#", "p", "T"]
# 지도: # 벽, p 화분, . 바닥, @ 시작, ^ v [ ] 가장자리 문, D/d 쇠살문(열림/닫힘부터), ~ 물, B/b 다리(내림/올림부터),
# t 밀물, w 나무 바닥, F 화덕 불, T 해시계 탑, $ 인장, * 탈출구
# 움직이는 것 m: k g 경비 / v 마을 사람(무해, 몸이 눈줄을 가린다), p 순찰 점들, l 한 바퀴 순찰, v 칸/초, s 눈줄 칸, turn 제자리 회전 초, f 처음 방향
const ROOMS := [
	{"name": "마을길", "line": "마을길. 경비가 가운데 길을 오간다. 성은 위쪽.", "ratio": 4.0, "sun": 0.5,
		"map": ["####^####", "#p.....p#", "#.......#", "#..###..#", "#.......#", "#.......#",
			"#p.....p#", "#.......#", "#..#.#..#", "#.......#", "#...@...#", "#########"],
		"links": {"^": [1, "v"]},
		"m": [{"k": "g", "p": [[1, 4], [7, 4]], "v": 1.0, "s": 3},
			{"k": "v", "p": [[1, 7], [7, 7]], "v": 1.4},
			{"k": "v", "p": [[6, 2], [2, 2]], "v": 0.8}]},
	{"name": "성문", "line": "성문. 쇠살문이 4초마다 오르내린다. 닫힌 칸에 서면 끼인다.", "ratio": 4.0, "sun": 1.2,
		"map": ["####^####", "#.......#", "#.......#", "#.......#", "###dDd###", "#p.....p#",
			"#.......#", "#.......#", "#.......#", "#p.....p#", "#.......#", "####v####"],
		"links": {"^": [2, "v"], "v": [0, "^"]},
		"m": [{"k": "g", "p": [[1, 2], [7, 2]], "v": 1.0, "s": 3},
			{"k": "v", "p": [[1, 6], [7, 6]], "v": 1.2},
			{"k": "g", "p": [[7, 8]], "turn": 2.0, "f": [-1, 0], "s": 3}]},
	{"name": "해자", "line": "해자. 다리는 6초 내려오고 6초 올라간다. 두 칸을 건너야 한다.", "ratio": 4.0, "sun": 2.0,
		"map": ["####^####", "#.......#", "#.......#", "#p.....p#", "#.......#", "~~B~~~b~~",
			"~~B~~~b~~", "#.......#", "#.......#", "#p.....p#", "#.......#", "####v####"],
		"links": {"^": [3, "v"], "v": [1, "^"]},
		"m": [{"k": "g", "p": [[1, 2], [7, 2]], "v": 1.2, "s": 3},
			{"k": "v", "p": [[7, 4], [1, 4]], "v": 1.5},
			{"k": "g", "p": [[1, 8], [7, 8]], "v": 0.8, "s": 2}]},
	{"name": "대청", "line": "대청. 왼쪽 부엌·오른쪽 뜰의 인장 두 개면 북문이 열린다.", "ratio": 4.0, "sun": 2.8,
		"map": ["####^####", "#.......#", "#.......#", "#...#...#", "##.....##", "[.......]",
			"##.....##", "#...#...#", "#.......#", "#...#...#", "#.......#", "####v####"],
		"links": {"^": [6, "v"], "v": [2, "^"], "[": [4, "]"], "]": [5, "["]},
		"lock": {"^": 2},
		"m": [{"k": "g", "p": [[2, 5], [6, 5]], "v": 1.0, "s": 3},
			{"k": "g", "p": [[2, 2], [6, 2], [6, 8], [2, 8]], "l": true, "v": 1.2, "s": 3}]},
	{"name": "부엌", "line": "부엌. 화덕 불이 나무 바닥을 타고 번진다. 재는 밟아도 된다.", "ratio": 6.0, "sun": 3.6,
		"map": ["#########", "#$ww#...#", "#www#.p.#", "#wwww...#", "#ww.wwww#", "#wF.ww..]",
			"#ww.wwww#", "#wwww...#", "#www#...#", "#.ww#.p.#", "#ww...ww#", "#########"],
		"links": {"]": [3, "["]},
		"m": [{"k": "g", "p": [[5, 1], [7, 1], [7, 3], [5, 3]], "l": true, "v": 0.8, "s": 2},
			{"k": "v", "p": [[5, 8], [7, 8]], "v": 0.6}]},
	{"name": "해시계 뜰", "line": "해시계 뜰. 탑 그림자 안에 서 있으면 경비 눈에 안 띈다.", "ratio": 4.0, "sun": 0.0,
		"map": ["#########", "#...$...#", "#.......#", "#.p...p.#", "#.......#", "[...T...#",
			"#.......#", "#.p...p.#", "#.......#", "#.......#", "#.......#", "#########"],
		"links": {"[": [3, "]"]},
		"m": [{"k": "g", "p": [[4, 2]], "turn": 2.5, "f": [0, 1], "s": 4},
			{"k": "g", "p": [[1, 8], [7, 8]], "v": 1.0, "s": 4},
			{"k": "v", "p": [[7, 4], [7, 9]], "v": 0.7}]},
	{"name": "수문", "line": "수문. 물이 옆으로 밀려왔다 빠진다. 맨 위 초록 칸이 탈출구.", "ratio": 4.0, "sun": 4.4,
		"map": ["####*####", "#.......#", "#..#.#..#", "#ttttttt#", "#ttttttt#", "#..#.#..#",
			"#.......#", "#ttttttt#", "#ttttttt#", "#.......#", "#.......#", "####v####"],
		"links": {"v": [3, "^"]},
		"m": [{"k": "g", "p": [[1, 6], [7, 6]], "v": 1.0, "s": 3},
			{"k": "g", "p": [[7, 1], [1, 1]], "v": 1.2, "s": 3}]},
]

var lv := 0
var entry := ""  # 이 방에 들어온 문 (죽으면 여기로)
var level: Node3D
var rows: Array = []
var ratio := 4.0
var wt := 0.0  # 이 방의 세상 시간
var frozen := true  # 방에 들어선 뒤 첫 걸음까지 세상이 멈춰 있다
var cx := 0
var cy := 0
var me_n: Node3D
var me_body: MeshInstance3D
var me_shd: MeshInstance3D
var stepping := false
var sk := 0.0
var sfrom := Vector3.ZERO
var sto := Vector3.ZERO
var tx := 0
var ty := 0
var movers: Array[Dictionary] = []
var doors := {}  # Vector2i -> {n, ph, open}
var bridges := {}  # Vector2i -> {n, ph, down}
var tides := {}  # Vector2i -> {n, wet}
var woods := {}  # Vector2i -> {n, state(1 나무 2 불 3 재), lit, spread}
var seal_n := {}  # Vector2i -> 상자
var lock_n: MeshInstance3D
var tower := Vector2i(-1, -1)
var shade_boxes: Array[MeshInstance3D] = []
var shade_cells: Array[Vector2i] = []
var stripes: Array[MeshInstance3D] = []
var sun_n: MeshInstance3D
var sun_light: DirectionalLight3D
var sun_dir := Vector2(1, 0)
var die_t := 0.0
var go_t := 0.0
var go_to: Array = []
var tick := 0.0
var ghost_t := 0.0
var shake := 0.0
var seals := 0
var got := {}  # 주운 인장 "방_칸"
var seen_rooms := {}
var cam_base := Vector3(0, 11.5, 4.0)
var line_box: ColorRect
var line_l: Label
var line_t := 0.0


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 50.0
	cam.position = cam_base
	cam.look_at(Vector3(0, 0, -0.3))
	for n in get_children():
		if n is DirectionalLight3D:
			sun_light = n
	# 쯔꾸르식 아래 대사 창 한 줄 (방에 들어설 때 상황 설명)
	var top := CanvasLayer.new()
	add_child(top)
	line_box = ColorRect.new()
	line_box.color = WHITE
	line_box.position = Vector2(24, 1160)
	line_box.size = Vector2(672, 96)
	line_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line_box.visible = false
	top.add_child(line_box)
	var s := LabelSettings.new()
	s.font = _font
	s.font_size = 30
	s.font_color = INK
	line_l = Label.new()
	line_l.label_settings = s
	line_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line_l.position = Vector2(16, 0)
	line_l.size = Vector2(640, 96)
	line_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line_box.add_child(line_l)
	howto = "가고 싶은 쪽을 탭하면 한 칸, 나를 탭하면 제자리 걸음.\n한 걸음에 세상은 4초가 흐르고, 걷는 중엔 조작 불가·아무도 못 본다. 서 있으면 보통 속도.\n서 있거나 내려선 칸이 붉은 눈줄·닫힌 문·올라간 다리·밀물·불이면 그 방 입구부터.\n노란 인장 둘로 대청 북문을 열고 초록 탈출구로."


func _reset() -> void:
	seals = 0
	got.clear()
	seen_rooms.clear()
	level = null
	stripes.clear()
	# 걷는 동안만 보이는 화면 양옆 줄무늬 (빨리감기)
	for i in 12:
		var side := -1.0 if i % 2 == 0 else 1.0
		var sb := box(Vector3(side * (4.85 + (i % 3) * 0.15), 0.3, -7.0 + i * 1.2), Vector3(0.08, 0.05, 1.3), WHITE if i % 4 < 2 else B)
		sb.visible = false
		stripes.append(sb)
	sun_n = box(Vector3.ZERO, Vector3(0.9, 0.9, 0.9), D)
	_room(0, "")


func _cell(c: float, r: float) -> Vector3:
	return Vector3(c - (NC - 1) * 0.5, 0.0, r - (NR - 1) * 0.5)


func _ch(c: int, r: int) -> String:
	if c < 0 or c >= NC or r < 0 or r >= NR:
		return "#"
	return rows[r][c]


func _inward(ch: String) -> Vector2i:
	match ch:
		"^": return Vector2i(0, 1)
		"v": return Vector2i(0, -1)
		"[": return Vector2i(1, 0)
		"]": return Vector2i(-1, 0)
	return Vector2i.ZERO


func _room(i: int, from: String) -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	var rm: Dictionary = ROOMS[i]
	lv = i
	entry = from
	rows = rm.map
	ratio = rm.ratio
	movers.clear()
	doors.clear()
	bridges.clear()
	tides.clear()
	woods.clear()
	seal_n.clear()
	shade_cells.clear()
	shade_boxes.clear()
	lock_n = null
	tower = Vector2i(-1, -1)
	wt = 0.0
	frozen = true
	stepping = false
	die_t = 0.0
	go_t = 0.0
	tick = 0.0
	ghost_t = 0.0
	var lock: Dictionary = rm.get("lock", {})
	var start := Vector2i(4, 10)
	var fires: Array[Vector2i] = []
	box(Vector3(0, -0.25, 0), Vector3(NC, 0.3, NR), SOFT, level)
	for r in NR:
		for c in NC:
			var ch := _ch(c, r)
			var p := _cell(c, r)
			var k := Vector2i(c, r)
			match ch:
				"#":
					box(p + Vector3(0, 0.6, 0), Vector3(1, 1.2, 1), GREY, level)
				"p":
					box(p + Vector3(0, 0.35, 0), Vector3(0.8, 0.7, 0.8), GOOD.lightened(0.3), level)
				"T":
					tower = k
					box(p + Vector3(0, 1.4, 0), Vector3(0.9, 2.8, 0.9), GREY, level)
					box(p + Vector3(0, 2.9, 0), Vector3(1.1, 0.3, 1.1), D, level)
				"~":
					box(p + Vector3(0, -0.12, 0), Vector3(1, 0.1, 1), B, level)
				"B", "b":
					box(p + Vector3(0, -0.12, 0), Vector3(1, 0.1, 1), B, level)
					var pl := box(p, Vector3(0.8, 0.12, 1.0), A, level)
					bridges[k] = {"n": pl, "ph": 0.0 if ch == "B" else BRIDGE_T, "down": ch == "B"}
				"t":
					var tn := box(p + Vector3(0, -0.05, 0), Vector3(1, 0.12, 1), SAND, level)
					tides[k] = {"n": tn, "wet": false}
				"w", "F":
					var wn := box(p + Vector3(0, -0.04, 0), Vector3(0.96, 0.12, 0.96), WOOD, level)
					woods[k] = {"n": wn, "state": 1, "lit": 0.0, "spread": false}
					if ch == "F":
						fires.append(k)
				"D", "d":
					var dn := box(p, Vector3.ONE, INK, level)
					doors[k] = {"n": dn, "ph": 0.0 if ch == "D" else DOOR_T, "open": ch == "D"}
				"$":
					if not got.has("%d_%s" % [i, k]):
						seal_n[k] = box(p + Vector3(0, 0.35, 0), Vector3(0.45, 0.45, 0.45), D, level)
				"*":
					box(p + Vector3(0, 0.0, 0), Vector3(0.9, 0.1, 0.9), GOOD, level)
					box(p + Vector3(0, 0.6, -0.35), Vector3(0.9, 1.2, 0.25), GOOD, level)
				"@":
					if from == "":
						start = k
				"^", "v", "[", "]":
					box(p + Vector3(0, -0.06, 0), Vector3(0.9, 0.1, 0.9), B.lightened(0.45), level)
					if from == ch:
						start = k + _inward(ch)
					if lock.has(ch):
						lock_n = box(p + Vector3(0, 0.6, 0), Vector3(0.9, 1.2, 0.4), INK, level)
						lock_n.visible = seals < int(lock[ch])
				".":
					if (c + r) % 2 == 0:
						box(p + Vector3(0, -0.095, 0), Vector3(1, 0.03, 1), WHITE, level)
	for k in fires:
		_ignite(k)
	if tower.x >= 0:
		for j in 3:
			var sb := box(Vector3.ZERO, Vector3(0.96, 0.02, 0.96), SHADE, level)
			sb.visible = false
			shade_boxes.append(sb)
	for spec in rm.get("m", []):
		_add_mover(spec)
	cx = start.x
	cy = start.y
	me_n = Node3D.new()
	me_n.position = _cell(cx, cy)
	level.add_child(me_n)
	me_body = box(Vector3(0, 0.45, 0), Vector3(0.6, 0.9, 0.6), ME, me_n)
	box(Vector3(0, 0.98, 0), Vector3(0.4, 0.16, 0.4), WHITE, me_n)
	me_shd = box(Vector3.ZERO, Vector3(0.62, 0.02, 0.62), SOFT.darkened(0.22), level)
	if not seen_rooms.has(i):
		seen_rooms[i] = true
		score += 1
	msg(rm.name, 1.2)
	line_l.text = rm.line
	line_t = 3.5
	_visual(0.0)


func _add_mover(spec: Dictionary) -> void:
	var pts: Array[Vector2] = []
	for q in spec.p:
		pts.append(Vector2(q[0], q[1]))
	var guard: bool = spec.k == "g"
	var col := BAD if guard else C
	var root := Node3D.new()
	level.add_child(root)
	box(Vector3(0, 0.5, 0), Vector3(0.62, 1.0, 0.62), col, root)
	var nose := box(Vector3(0, 0.78, 0), Vector3(0.26, 0.22, 0.26), INK if guard else WHITE, root)
	var eye: MeshInstance3D = null
	if guard:
		eye = box(Vector3.ZERO, Vector3.ONE, BAD.lightened(0.5), level)
	var shd := box(Vector3.ZERO, Vector3(0.62, 0.02, 0.62), SOFT.darkened(0.22), level)
	var gh: Array[MeshInstance3D] = []
	for j in 3:
		var g := box(Vector3.ZERO, Vector3(0.5, 0.8, 0.5), col.lightened(0.3 + j * 0.15), level)
		g.visible = false
		gh.append(g)
	var lp: bool = spec.get("l", false)
	var total := 0.0
	for j in pts.size() - 1:
		total += pts[j].distance_to(pts[j + 1])
	if lp:
		total += pts[pts.size() - 1].distance_to(pts[0])
	var face := Vector2i(1, 0)
	if spec.has("f"):
		face = Vector2i(spec.f[0], spec.f[1])
	var m := {"root": root, "nose": nose, "eye": eye, "shd": shd, "gh": gh, "hist": [], "pts": pts, "len": total,
		"loop": lp, "v": float(spec.get("v", 1.0)), "u": 0.0, "dir": 1.0, "pause": 0.0,
		"turn": float(spec.get("turn", 0.0)), "tt": 0.0, "face": face, "pos": pts[0], "guard": guard,
		"sight": int(spec.get("s", 3))}
	movers.append(m)
	if m.turn <= 0.0 and total > 0.0:
		_move(m, 0.0)


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
	beep(90.0, 0.1, 40.0, 0.12)


func _gcell(m: Dictionary) -> Vector2i:
	var p: Vector2 = m.pos
	return Vector2i(roundi(p.x), roundi(p.y))


## 순찰 길 위 거리 u 의 점과 그 구간 방향
func _along(m: Dictionary) -> Array:
	var pts: Array[Vector2] = m.pts
	var u: float = m.u
	var n := pts.size()
	var segs := n if m.loop else n - 1
	for j in segs:
		var a := pts[j]
		var b := pts[(j + 1) % n]
		var l := a.distance_to(b)
		if u <= l or j == segs - 1:
			return [a.lerp(b, clampf(u / maxf(l, 0.001), 0.0, 1.0)), (b - a).normalized()]
		u -= l
	return [pts[0], Vector2.RIGHT]


func _move(m: Dictionary, gd: float) -> void:
	if m.turn > 0.0:
		m.tt += gd
		while m.tt >= m.turn:
			m.tt -= m.turn
			var f: Vector2i = m.face
			m.face = Vector2i(-f.y, f.x)
			beep(330.0, 0.04, 0.0, 0.08)
		return
	if m.len <= 0.0:
		return
	var u: float = m.u
	var dir: float = m.dir
	var pause: float = m.pause
	if m.loop:
		u = fposmod(u + m.v * gd, m.len)
	elif pause > 0.0:
		pause -= gd
		if pause <= 0.0:
			pause = 0.0
			dir = -dir
	else:
		u += dir * m.v * gd
		if u >= m.len:
			u = m.len
			pause = 1.0
		elif u <= 0.0:
			u = 0.0
			pause = 1.0
	m.u = u
	m.dir = dir
	m.pause = pause
	var a := _along(m)
	m.pos = a[0]
	var sd: Vector2 = a[1] * dir
	if sd.length() > 0.1:
		m.face = Vector2i(roundi(sd.x), roundi(sd.y))


func _blocks(q: Vector2i) -> bool:
	if _ch(q.x, q.y) in SOLID:
		return true
	return doors.has(q) and not doors[q].open


func _villager_at(q: Vector2i) -> bool:
	for m in movers:
		if not m.guard and _gcell(m) == q:
			return true
	return false


## 경비 앞 눈줄이 닿는 칸들 (벽·닫힌 문에서 멈추고, 마을 사람 몸에서 멈춘다)
func _sight(m: Dictionary) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var gc := _gcell(m)
	var f: Vector2i = m.face
	for k in range(1, int(m.sight) + 1):
		var q := gc + f * k
		if _blocks(q):
			break
		out.append(q)
		if _villager_at(q):
			break
	return out


func _step(dt: float) -> void:
	line_t -= dt
	line_box.visible = line_t > 0.0
	if die_t > 0.0:
		die_t -= dt
		if die_t <= 0.0:
			_room(lv, entry)
		return
	if go_t > 0.0:
		go_t -= dt
		if go_t <= 0.0:
			_room(int(go_to[0]), str(go_to[1]))
		return
	var gd := 0.0 if frozen else dt
	if stepping:
		gd = dt * ratio / STEP_REAL
		sk = minf(sk + dt / STEP_REAL, 1.0)
		var e := sk * sk * (3.0 - 2.0 * sk)
		var st := sin(sk * PI)
		var p := sfrom.lerp(sto, e)
		p.y = st * 0.35
		me_n.position = p
		if tx != cx:
			me_body.scale = Vector3(0.6 + st * 0.5, 0.9 - st * 0.25, 0.6)
		elif ty != cy:
			me_body.scale = Vector3(0.6, 0.9 - st * 0.25, 0.6 + st * 0.5)
		else:
			me_body.scale = Vector3(0.6 - st * 0.1, 0.9 + st * 0.3, 0.6 - st * 0.1)
	if gd > 0.0:
		wt += gd
		_world(gd)
	_visual(dt)
	if stepping and sk >= 1.0:
		_land()
	elif not stepping and not frozen:
		_check()
	cam.fov = lerpf(cam.fov, 55.0 if stepping else 50.0, 1.0 - exp(-10.0 * dt))
	shake = maxf(shake - dt * 0.6, 0.0)
	cam.position = cam_base + Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)) * shake
	gauge(sk if stepping else 0.0, BAD)


func _land() -> void:
	stepping = false
	cx = tx
	cy = ty
	me_n.position = sto
	me_body.scale = Vector3(0.6, 0.9, 0.6)
	shake = 0.12
	ghost_t = 0.3
	beep(140.0, 0.05, 0.0, 0.2)
	var ch := _ch(cx, cy)
	var k := Vector2i(cx, cy)
	if ch in PORTALS:
		var links: Dictionary = ROOMS[lv].links
		if links.has(ch):
			go_to = links[ch]
			go_t = 0.3
			beep(600.0, 0.12, 900.0, 0.18)
			return
	if ch == "$" and seal_n.has(k):
		var sn: MeshInstance3D = seal_n[k]
		sn.visible = false
		seal_n.erase(k)
		got["%d_%s" % [lv, k]] = true
		seals += 1
		score += 5
		play("good")
		msg("인장 %d/2" % seals, 1.2)
	if ch == "*":
		score += 20
		msg("탈출!", 2.0)
		end()
		return
	_check()


func _world(gd: float) -> void:
	tick += gd
	while tick >= 1.0:
		tick -= 1.0
		beep(440.0 if stepping else 260.0, 0.03, 0.0, 0.1)
	for m in movers:
		_move(m, gd)
	for k: Vector2i in doors:
		var d: Dictionary = doors[k]
		var o := fmod(wt + float(d.ph), DOOR_T * 2.0) < DOOR_T
		if o != d.open:
			d.open = o
			beep(500.0 if o else 110.0, 0.08, 0.0, 0.14)
	for k: Vector2i in bridges:
		var b: Dictionary = bridges[k]
		var dn := fmod(wt + float(b.ph), BRIDGE_T * 2.0) < BRIDGE_T
		if dn != b.down:
			b.down = dn
			beep(180.0 if dn else 300.0, 0.12, 0.0, 0.14)
	var flip := false
	for k: Vector2i in tides:
		var td: Dictionary = tides[k]
		var wet := fmod(wt + k.x * 1.0, TIDE_T) >= TIDE_DRY
		if wet != td.wet:
			td.wet = wet
			flip = true
			var tn: MeshInstance3D = td.n
			tn.material_override = mat(B if wet else SAND)
	if flip:
		beep(150.0, 0.06, 90.0, 0.08)
	var lit_now: Array[Vector2i] = []
	for k: Vector2i in woods:
		var w: Dictionary = woods[k]
		if w.state != 2:
			continue
		if wt - w.lit >= FIRE_BURN:
			w.state = 3
			w.n.material_override = mat(GREY)
		elif wt - w.lit >= FIRE_SPREAD and not w.spread:
			w.spread = true
			for dk in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				lit_now.append(k + dk)
	for k: Vector2i in lit_now:
		_ignite(k)


## 보이는 것 맞추기: 해·그림자, 경비·눈줄·잔상, 문·다리, 줄무늬
func _visual(dt: float) -> void:
	var sa: float = wt * TAU / SUN_T + float(ROOMS[lv].sun)
	sun_dir = Vector2(cos(sa), sin(sa))
	sun_n.position = Vector3(sun_dir.x * 5.0, 2.5, sun_dir.y * 6.2)
	if sun_light:
		sun_light.rotation = Vector3(deg_to_rad(-55.0), atan2(sun_dir.x, sun_dir.y), 0.0)
	var so := Vector3(-sun_dir.x * 0.3, 0.03, -sun_dir.y * 0.3)
	me_shd.position = Vector3(me_n.position.x, 0.0, me_n.position.z) + so
	# 해시계 탑 그림자 (세 칸)
	shade_cells.clear()
	if tower.x >= 0:
		var d := Vector2i(roundi(-sun_dir.x), roundi(-sun_dir.y))
		for j in 3:
			var q := tower + d * (j + 1)
			if d != Vector2i.ZERO and not _blocks(q):
				shade_cells.append(q)
			else:
				break
		for j in shade_boxes.size():
			var sb := shade_boxes[j]
			sb.visible = j < shade_cells.size()
			if sb.visible:
				sb.position = _cell(shade_cells[j].x, shade_cells[j].y) + Vector3(0, 0.0, 0)
	for m in movers:
		var root: Node3D = m.root
		var mp: Vector2 = m.pos
		root.position = _cell(mp.x, mp.y)
		var f: Vector2i = m.face
		var nose: MeshInstance3D = m.nose
		nose.position = Vector3(f.x * 0.38, 0.78, f.y * 0.38)
		var shd: MeshInstance3D = m.shd
		shd.position = root.position + so
		if m.guard:
			var eye: MeshInstance3D = m.eye
			var cells := _sight(m)
			eye.visible = cells.size() > 0
			if eye.visible:
				var n := cells.size()
				var gc := _gcell(m)
				var mid := Vector2(gc) + Vector2(f) * (n + 1) * 0.5
				eye.position = _cell(mid.x, mid.y) + Vector3(0, 0.07, 0)
				eye.scale = Vector3(float(n) if f.x != 0 else 0.3, 0.04, float(n) if f.y != 0 else 0.3)
		# 잔상: 걷는 동안 지나온 자리를 남긴다
		var hist: Array = m.hist
		var gh: Array[MeshInstance3D] = m.gh
		if stepping:
			hist.append(root.position)
			if hist.size() > 14:
				hist.pop_front()
			for j in 3:
				var idx := hist.size() - 1 - (j + 1) * 4
				gh[j].visible = idx >= 0
				if idx >= 0:
					gh[j].position = hist[idx] + Vector3(0, 0.4, 0)
					gh[j].scale = Vector3(0.5, 0.8, 0.5)
		elif ghost_t > 0.0:
			for j in 3:
				gh[j].scale *= 0.85
		else:
			hist.clear()
			for j in 3:
				gh[j].visible = false
	if not stepping and ghost_t > 0.0:
		ghost_t -= dt
	for k: Vector2i in doors:
		var d: Dictionary = doors[k]
		var dn: MeshInstance3D = d.n
		var p := _cell(k.x, k.y)
		if d.open:
			dn.position = p + Vector3(0, 1.4, 0)
			dn.scale = Vector3(0.92, 0.12, 0.2)
			dn.material_override = mat(GREY)
		else:
			dn.position = p + Vector3(0, 0.7, 0)
			dn.scale = Vector3(0.92, 1.4, 0.35)
			dn.material_override = mat(INK)
	for k: Vector2i in bridges:
		var b: Dictionary = bridges[k]
		var pl: MeshInstance3D = b.n
		var p := _cell(k.x, k.y)
		if b.down:
			pl.position = p + Vector3(0, 0.0, 0)
			pl.rotation_degrees.x = 0.0
		else:
			pl.position = p + Vector3(0, 0.5, -0.3)
			pl.rotation_degrees.x = 75.0
	for sb in stripes:
		sb.visible = stepping
		if stepping:
			sb.position.z += dt * 30.0
			if sb.position.z > 7.5:
				sb.position.z -= 15.0
	if lock_n:
		lock_n.visible = seals < 2


## 서 있는 순간의 죽음 검사
func _check() -> void:
	var here := Vector2i(cx, cy)
	if doors.has(here) and not doors[here].open:
		_die("끼였다")
		return
	if bridges.has(here) and not bridges[here].down:
		_die("빠졌다")
		return
	if tides.has(here) and tides[here].wet:
		_die("빠졌다")
		return
	if woods.has(here) and woods[here].state == 2:
		_die("탔다")
		return
	var hidden := here in shade_cells
	for m in movers:
		if not m.guard:
			continue
		if _gcell(m) == here:
			_die("잡혔다")
			return
		if not hidden and here in _sight(m):
			_die("들켰다")
			return


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 1.3
	stepping = false
	me_body.material_override = mat(BAD)
	shake = 0.3
	play("bad")
	msg(why, 1.2)


func _go(dx: int, dy: int) -> void:
	var nx := cx + dx
	var ny := cy + dy
	if dx != 0 or dy != 0:
		var ch := _ch(nx, ny)
		if ch in SOLID:
			msg("벽", 0.5)
			beep(120.0, 0.1, 0.0, 0.15)
			return
		if ch == "~":
			msg("물", 0.5)
			beep(120.0, 0.1, 0.0, 0.15)
			return
		var lock: Dictionary = ROOMS[lv].get("lock", {})
		if lock.has(ch) and seals < int(lock[ch]):
			msg("인장 %d/%d" % [seals, int(lock[ch])], 1.0)
			beep(120.0, 0.15, 0.0, 0.15)
			return
	tx = nx
	ty = ny
	stepping = true
	frozen = false
	sk = 0.0
	sfrom = _cell(cx, cy)
	sto = _cell(nx, ny)
	play("tap")


func _tap(p: Vector2) -> void:
	if stepping or die_t > 0.0 or go_t > 0.0:
		return
	var d := p - cam.unproject_position(me_n.position + Vector3(0, 0.5, 0))
	var dx := 0
	var dy := 0
	if d.length() > 80.0:
		if absf(d.x) > absf(d.y):
			dx = 1 if d.x > 0.0 else -1
		else:
			dy = 1 if d.y > 0.0 else -1
	_go(dx, dy)
