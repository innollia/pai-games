extends Tofu
## 빠르면 긴 뱀 (위에서 본 방 퍼즐): 화면을 눌러 끌면 그쪽으로 긴다, 멀리 끌수록 빠르다. 방 8개(풀밭·공장·하늘 정원)를 한 화면씩 깨고 초록 출구로.
## 핵심 규칙: 마디는 머리가 0.22초 전, 0.44초 전…에 있던 자리를 따라온다. 빠르면 마디가 벌어져 몸이 길게 늘어나고, 느리면 모여 짧고 무겁다.
## 늘어난 몸: 구멍 위에 마디가 하나씩만 놓여 다리가 되고 얇은 바닥을 안 깬다. 대신 굽이에서 마디 사이 직선 줄이 벽 모서리를 가로질러 걸린다.
## 모인 몸: 1칸 굽이를 돌고 노란 발판(마디 넷)을 누른다. 대신 이웃 마디 둘이 같이 구멍 위면 떨어지고, 얇은 바닥에 셋이 올라가면 깨진다.
## 하늘 정원: 파란 칸 두 개를 머리와 꼬리로 동시에 밟아야 문이 열린다 = 몸 길이(=속도)로 거리를 잰다.
# 한 문장: 나는 상자 마디 뱀으로서 마디가 머리의 지난 자리를 시간차로 따라오는 몸으로 방을 기어가 출구에 닿지만, 빨리 기면 늘어나 굽이에 걸리고 천천히 기면 모여 구멍에 빠지는 대가를 감수한다.

const COLS := 12
const ROWS := 16
const NSEG := 8  # 머리 포함 마디 수 (먹이로 늘지 않는다)
const LAG := 0.22  # 마디 하나당 시간차
const DMIN := 0.42  # 가장 모였을 때 마디 간격
const VMAX := 12.0
const ACC := 20.0
const BRAKE := 22.0
const TURN := 8.0
const HR := 0.3  # 머리 반폭 (벽 충돌)
const W_PLATE := 4  # 노란 발판을 누르는 마디 수
const W_CRACK := 3  # 얇은 바닥이 깨지는 마디 수
const EDGE := 0.15  # 줄이 벽 속으로 이만큼은 들어가야 걸림
const DIE_T := 1.0
const CLEAR_T := 0.7
const GRAD := [Color("3b5bdb"), Color("7048e8"), Color("cc5de8"), Color("f06595"), Color("ff922b")]
const PALS := [
	{"name": "풀밭", "sky": Color("e4f8e8"), "f0": Color("b6e89c"), "f1": Color("a5de8a"), "wall": Color("63be72"), "top": Color("8fd68f"), "void": Color("cfe8ff"), "crack": Color("e6d3a8"), "deco": Color("fff3bf")},
	{"name": "공장", "sky": Color("fdebd8"), "f0": Color("f3e3c4"), "f1": Color("ebd6b0"), "wall": Color("aab7cf"), "top": Color("c9d3e6"), "void": Color("fff0e6"), "crack": Color("d8eefa"), "deco": Color("ffd8a8")},
	{"name": "하늘 정원", "sky": Color("efebff"), "f0": Color("e3dbff"), "f1": Color("d6cbff"), "wall": Color("f2a7c8"), "top": Color("ffc9de"), "void": Color("d8f0ff"), "crack": Color("f8f0ff"), "deco": Color("ffffff")},
]
# 방: # 벽, o 구멍, x 얇은 바닥, p 노란 발판(무거움), b 파란 칸(둘 동시), = 문(발판이 열면 열림), S 시작(위를 봄), E 출구
const ROOMS := [
	{"name": "늘어나는 몸", "hint": "끌수록 길어진다", "grp": 0, "map": [
		"############",
		"#####EE#####",
		"#          #",
		"#          #",
		"#oooooooooo#",
		"#oooooooooo#",
		"#          #",
		"#          #",
		"#          #",
		"#oooooooooo#",
		"#          #",
		"#          #",
		"#          #",
		"#     S    #",
		"#          #",
		"############",
	]},
	{"name": "굽이 계단", "hint": "천천히 돌기", "grp": 0, "map": [
		"############",
		"##########E#",
		"########## #",
		"########   #",
		"######## ###",
		"######   ###",
		"###### #####",
		"####   #####",
		"#### #######",
		"##   #######",
		"## #########",
		"#   ########",
		"#   ########",
		"# S ########",
		"#   ########",
		"############",
	]},
	{"name": "건너고 멈추기", "hint": "빨리 건너 천천히 돌기", "grp": 0, "map": [
		"############",
		"#E##########",
		"# ##########",
		"#   ########",
		"### ########",
		"###   ######",
		"#          #",
		"#          #",
		"#oooooooooo#",
		"#oooooooooo#",
		"#          #",
		"#          #",
		"#          #",
		"#    S     #",
		"#          #",
		"############",
	]},
	{"name": "무거운 발판", "hint": "모여서 꾹", "grp": 1, "map": [
		"############",
		"####EE######",
		"####  ######",
		"#          #",
		"#oooooooooo#",
		"#          #",
		"#          #",
		"#####==#####",
		"#          #",
		"#pp        #",
		"#pp        #",
		"#          #",
		"#          #",
		"#     S    #",
		"#          #",
		"############",
	]},
	{"name": "얇은 바닥", "hint": "무거우면 깨진다", "grp": 1, "map": [
		"############",
		"#EE#########",
		"#==#########",
		"#        pp#",
		"#        pp#",
		"#          #",
		"#          #",
		"#xxxxxxxxxx#",
		"#xxxxxxxxxx#",
		"#xxxxxxxxxx#",
		"#          #",
		"#          #",
		"#          #",
		"#     S    #",
		"#          #",
		"############",
	]},
	{"name": "공장 끝", "hint": "가볍게, 길게, 꾹", "grp": 1, "map": [
		"############",
		"########EE##",
		"########==##",
		"#pp        #",
		"#pp        #",
		"#          #",
		"#oooooooooo#",
		"#oooooooooo#",
		"#          #",
		"#          #",
		"#xxxxxxxxxx#",
		"#xxxxxxxxxx#",
		"#          #",
		"#     S    #",
		"#          #",
		"############",
	]},
	{"name": "몸으로 재기", "hint": "파란 칸 둘 동시에", "grp": 2, "map": [
		"############",
		"#####EE#####",
		"#####==#####",
		"#   bbbb   #",
		"#   bbbb   #",
		"#   bbbb   #",
		"#          #",
		"#oooooooooo#",
		"#          #",
		"#          #",
		"#   bbbb   #",
		"#   bbbb   #",
		"#   bbbb   #",
		"#     S    #",
		"#          #",
		"############",
	]},
	{"name": "구름 계단", "hint": "전부 섞기", "grp": 2, "map": [
		"############",
		"#E##########",
		"# ##########",
		"#   ########",
		"###=########",
		"###      pp#",
		"#        pp#",
		"#          #",
		"#oooooooooo#",
		"#oooooooooo#",
		"#          #",
		"#          #",
		"#          #",
		"#    S     #",
		"#          #",
		"############",
	]},
]

var lv := 0
var grid: Array[String] = []
var stage: Node3D
var env: Environment
var hp := Vector2.ZERO  # 머리 (x, z)
var hdir := Vector2(0, -1)
var spd := 0.0
var real_v := 0.0
var s_head := 0.0
var clock := 0.0
var hist_t := PackedFloat32Array()
var hist_s := PackedFloat32Array()
var path_p := PackedVector2Array()
var path_s := PackedFloat32Array()
var seg_s: Array[float] = []
var seg_p: Array[Vector2] = []
var seg_d: Array[Vector2] = []  # 마디가 보는 방향 (그리기)
var die_t := 0.0
var die_kind := ""
var die_link := -1
var fall_v := 0.0
var clear_t := 0.0
var tick_s := 0.0
var shake := 0.0
var blink := 0.0
var tongue_t := 0.0
var creak_t := 0.0
var deaths := 0
# 칸 묶음 (얇은 바닥·발판·파란 칸)
var reg_of := {}  # Vector2i -> 묶음 번호
var regs: Array = []  # {k, cells, tiles, done, n, fall}
var b_done := false
var gate_open := false
var gate_k := 0.0
var gates: Array[MeshInstance3D] = []
# 그리기
var pivs: Array[Node3D] = []
var links: Array[MeshInstance3D] = []
var link_col: Array[Color] = []
var eyes: Array[MeshInstance3D] = []
var pupils: Array[MeshInstance3D] = []
var mouth: MeshInstance3D
var tongue: MeshInstance3D
var winds: Array[MeshInstance3D] = []
var wind_v: Array[Vector3] = []
var wind_l: Array[float] = []
var wind_k := 0
var wind_t := 0.0
var flag: MeshInstance3D


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 56.0
	howto = "화면을 눌러 끌면 뱀이 그쪽으로 긴다. 멀리 끌수록 빠르다.\n빠르면 마디가 벌어져 몸이 길어진다: 구멍을 다리처럼 건너고 얇은 바닥도 안 깬다. 대신 굽이에서 마디 사이 줄이 벽 모서리에 걸린다.\n느리면 마디가 모여 짧고 무겁다: 굽이를 돌고 노란 발판을 누른다.\n이웃 마디 둘이 구멍 위에 같이 놓이거나 줄이 걸리면 죽는다. 방 8개, 초록 출구로."
	kit_stick(Rect2(0, 240, 720, 1040))
	for ch in get_children():
		if ch is WorldEnvironment:
			env = ch.environment


func _reset() -> void:
	lv = 0
	deaths = 0
	score = 0
	_build(lv)


# ---- 방 짓기 ----
func _build(i: int) -> void:
	if stage:
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	var room: Dictionary = ROOMS[i]
	var pal: Dictionary = PALS[room.grp]
	if env:
		env.background_color = pal.sky
	grid.clear()
	for s in room.map:
		grid.append(String(s))
	gate_open = false
	gate_k = 0.0
	b_done = false
	gates.clear()
	reg_of.clear()
	regs.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = i * 733 + 5
	var start := Vector2(6.5, 13.5)
	# 바닥·벽·구멍: 줄마다 같은 칸을 이어 한 상자로
	for r in ROWS:
		var line := grid[r]
		var c := 0
		while c < COLS:
			var ch := line[c]
			var kind := _kind(ch)
			var c1 := c + 1
			while c1 < COLS and _kind(line[c1]) == kind:
				c1 += 1
			var cx := (c + c1) * 0.5
			var w := float(c1 - c)
			if kind == "wall":
				box(Vector3(cx, 0.4, r + 0.5), Vector3(w, 0.8, 1.0), pal.wall, stage)
				box(Vector3(cx, 0.82, r + 0.5), Vector3(w - 0.12, 0.06, 0.86), pal.top, stage)
			elif kind == "hole":
				box(Vector3(cx, -5.0, r + 0.5), Vector3(w, 0.4, 1.0), pal.void, stage)
			else:
				box(Vector3(cx, -0.15, r + 0.5), Vector3(w, 0.3, 1.0), pal.f0 if r % 2 == 0 else pal.f1, stage)
			c = c1
	for r in ROWS:
		for c in COLS:
			var ch := grid[r][c]
			if ch == "S":
				start = Vector2(c + 0.5, r + 0.5)
			elif ch == "E":
				box(Vector3(c + 0.5, 0.02, r + 0.5), Vector3(0.96, 0.08, 0.96), GOOD, stage)
			elif ch == "=":
				var g := box(Vector3(c + 0.5, 0.45, r + 0.5), Vector3(0.96, 0.9, 0.34), A, stage)
				gates.append(g)
	# 출구 깃발
	for r in ROWS:
		var k := grid[r].find("E")
		if k >= 0:
			box(Vector3(k + 0.15, 0.7, r + 0.5), Vector3(0.08, 1.4, 0.08), INK, stage)
			flag = box(Vector3(k + 0.45, 1.25, r + 0.5), Vector3(0.55, 0.3, 0.06), D, stage)
			break
	# 얇은 바닥·발판·파란 칸 묶음
	for r in ROWS:
		for c in COLS:
			var ch := grid[r][c]
			if (ch == "x" or ch == "p" or ch == "b") and not reg_of.has(Vector2i(c, r)):
				_flood(c, r, ch)
	for k in regs.size():
		var rg: Dictionary = regs[k]
		for cell in rg.cells:
			var holder := Node3D.new()
			holder.position = Vector3(cell.x + 0.5, 0.0, cell.y + 0.5)
			stage.add_child(holder)
			if rg.k == "x":
				box(Vector3(0, -0.13, 0), Vector3(0.94, 0.26, 0.94), pal.crack, holder)
				var ln := box(Vector3(0, 0.005, 0), Vector3(0.7, 0.03, 0.05), INK.lightened(0.45), holder)
				ln.rotation.y = 0.7 if (cell.x + cell.y) % 2 == 0 else -0.5
			elif rg.k == "p":
				box(Vector3(0, -0.05, 0), Vector3(0.94, 0.2, 0.94), D, holder)
			else:
				box(Vector3(0, -0.07, 0), Vector3(0.94, 0.16, 0.94), B.lightened(0.35), holder)
			rg.tiles.append(holder)
	# 바닥 꾸밈 (꽃·나사): 속도 기준물
	var made := 0
	for tries in 60:
		if made >= 9:
			break
		var c := rng.randi_range(1, COLS - 2)
		var r := rng.randi_range(1, ROWS - 2)
		if grid[r][c] != " ":
			continue
		var fx := c + rng.randf_range(0.25, 0.75)
		var fz := r + rng.randf_range(0.25, 0.75)
		box(Vector3(fx, 0.04, fz), Vector3(0.22, 0.08, 0.22), pal.deco, stage)
		box(Vector3(fx, 0.09, fz), Vector3(0.08, 0.04, 0.08), A if made % 2 == 0 else C, stage)
		made += 1
	_make_snake()
	_make_winds()
	# 시작: 똬리 튼 몸
	hp = start
	hdir = Vector2(0, -1)
	spd = 0.0
	real_v = 0.0
	s_head = 0.0
	clock = 0.0
	tick_s = 0.0
	die_t = 0.0
	die_kind = ""
	die_link = -1
	clear_t = 0.0
	hist_t = PackedFloat32Array([0.0])
	hist_s = PackedFloat32Array([0.0])
	path_p = PackedVector2Array()
	path_s = PackedFloat32Array()
	var rad := 0.55
	var ctr := hp - hdir * rad
	var a0 := (hp - ctr).angle()
	var k := 36
	while k > 0:
		var s := -k * 0.1
		path_p.append(ctr + Vector2.from_angle(a0 + s / rad) * rad)
		path_s.append(s)
		k -= 1
	path_p.append(hp)
	path_s.append(0.0)
	seg_s.clear()
	seg_p.clear()
	seg_d.clear()
	for j in NSEG:
		seg_s.append(-j * DMIN)
		seg_p.append(_pos_at(-j * DMIN))
		seg_d.append(hdir)
	_draw_snake(0.0)
	msg("%s\n%s" % [room.name, room.hint], 2.0)


func _kind(ch: String) -> String:
	if ch == "#":
		return "wall"
	if ch == "o" or ch == "x":
		return "hole"  # 얇은 바닥 밑도 비어 있다 (깨지면 보인다)
	if ch == " " or ch == "S" or ch == "=" or ch == "E":
		return "floor"
	return "tile"  # 발판·파란 칸은 제 타일이 있다


func _flood(c0: int, r0: int, ch: String) -> void:
	var idx := regs.size()
	var cells: Array = []
	var todo: Array = [Vector2i(c0, r0)]
	reg_of[Vector2i(c0, r0)] = idx
	while not todo.is_empty():
		var q: Vector2i = todo.pop_back()
		cells.append(q)
		for dd in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = q + dd
			if n.x < 0 or n.y < 0 or n.x >= COLS or n.y >= ROWS:
				continue
			if grid[n.y][n.x] == ch and not reg_of.has(n):
				reg_of[n] = idx
				todo.append(n)
	regs.append({"k": ch, "cells": cells, "tiles": [], "done": false, "n": 0, "fall": 0.0})


func _make_snake() -> void:
	pivs.clear()
	links.clear()
	link_col.clear()
	eyes.clear()
	pupils.clear()
	for i in NSEG:
		var f := float(i) / float(NSEG - 1)
		var col := _grad(f)
		var piv := Node3D.new()
		stage.add_child(piv)
		if i == 0:
			box(Vector3(0, 0.29, 0), Vector3(0.84, 0.58, 0.76), col, piv)
			for side in [-1.0, 1.0]:
				eyes.append(box(Vector3(0.12, 0.6, side * 0.2), Vector3(0.24, 0.06, 0.22), WHITE, piv))
				pupils.append(box(Vector3(0.18, 0.64, side * 0.2), Vector3(0.1, 0.04, 0.1), INK, piv))
				box(Vector3(0.425, 0.24, side * 0.27), Vector3(0.02, 0.08, 0.1), Color("ffa8c5"), piv)
			mouth = box(Vector3(0.43, 0.13, 0), Vector3(0.03, 0.06, 0.26), Color("c92a2a"), piv)
			tongue = box(Vector3(0.62, 0.1, 0), Vector3(0.36, 0.03, 0.08), BAD, piv)
			tongue.visible = false
		else:
			var sz := lerpf(0.68, 0.42, f)
			var h := lerpf(0.48, 0.32, f)
			box(Vector3(0, h * 0.5, 0), Vector3(sz, h, sz), col, piv)
			box(Vector3(0, h + 0.015, 0), Vector3(sz * 0.62, 0.03, sz * 0.26), col.lightened(0.55), piv)
		pivs.append(piv)
	for i in NSEG - 1:
		var c := _grad((i + 0.5) / float(NSEG - 1)).lightened(0.35)
		link_col.append(c)
		var l := box(Vector3.ZERO, Vector3(1, 0.1, 0.1), c, stage)
		l.visible = false
		links.append(l)


func _make_winds() -> void:
	winds.clear()
	wind_v.clear()
	wind_l.clear()
	for k in 8:
		var w := box(Vector3.ZERO, Vector3(1.0, 0.05, 0.05), WHITE, stage)
		w.visible = false
		winds.append(w)
		wind_v.append(Vector3.ZERO)
		wind_l.append(0.0)


func _grad(f: float) -> Color:
	var x := clampf(f, 0.0, 1.0) * (GRAD.size() - 1)
	var k := mini(int(x), GRAD.size() - 2)
	return (GRAD[k] as Color).lerp(GRAD[k + 1], x - k)


# ---- 칸 ----
func _cell(p: Vector2) -> String:
	var c := floori(p.x)
	var r := floori(p.y)
	if c < 0 or r < 0 or c >= COLS or r >= ROWS:
		return "#"
	return grid[r][c]


func _solid_at(x: float, z: float) -> bool:
	var ch := _cell(Vector2(x, z))
	return ch == "#" or (ch == "=" and not gate_open)


func _blocked(x: float, z: float) -> bool:
	return _solid_at(x - HR, z - HR) or _solid_at(x + HR, z - HR) or _solid_at(x - HR, z + HR) or _solid_at(x + HR, z + HR)


func _pit(p: Vector2) -> bool:
	return _cell(p) == "o"


func _set_cell(c: int, r: int, ch: String) -> void:
	grid[r] = grid[r].substr(0, c) + ch + grid[r].substr(c + 1)


## 벽 속 깊이 (가장자리 EDGE 안쪽)
func _deep(q: Vector2) -> bool:
	return _solid_at(q.x, q.y) and _solid_at(q.x + EDGE, q.y) and _solid_at(q.x - EDGE, q.y) and _solid_at(q.x, q.y + EDGE) and _solid_at(q.x, q.y - EDGE)


func _chord_hits(a: Vector2, b: Vector2) -> bool:
	var ln := a.distance_to(b)
	if ln < 0.3:
		return false
	var n := int(ceil(ln / 0.1))
	for j in range(1, n):
		if _deep(a.lerp(b, float(j) / n)):
			return true
	return false


# ---- 몸: 시간차로 머리 길을 따라온다 ----
func _s_at_time(tq: float) -> float:
	var n := hist_t.size()
	if tq <= hist_t[0]:
		return hist_s[0]
	var k := n - 1
	while k > 0 and hist_t[k] > tq:
		k -= 1
	if k >= n - 1:
		return hist_s[n - 1]
	var t0 := hist_t[k]
	var t1 := hist_t[k + 1]
	var f := 0.0 if t1 <= t0 else (tq - t0) / (t1 - t0)
	return lerpf(hist_s[k], hist_s[k + 1], f)


func _pos_at(s: float) -> Vector2:
	var n := path_s.size()
	if s <= path_s[0]:
		return path_p[0]
	if s >= path_s[n - 1]:
		return path_p[n - 1]
	var lo := 0
	var hi := n - 1
	while hi - lo > 1:
		var mid := (lo + hi) >> 1
		if path_s[mid] <= s:
			lo = mid
		else:
			hi = mid
	var d := path_s[hi] - path_s[lo]
	var f := 0.0 if d <= 0.0 else (s - path_s[lo]) / d
	return path_p[lo].lerp(path_p[hi], f)


func _follow() -> void:
	seg_s[0] = s_head
	seg_p[0] = hp
	for i in range(1, NSEG):
		seg_s[i] = minf(_s_at_time(clock - i * LAG), seg_s[i - 1] - DMIN)
		seg_p[i] = _pos_at(seg_s[i])
	# 오래된 기록 버리기
	var keep := clock - NSEG * LAG - 0.4
	if hist_t.size() > 120 and hist_t[60] < keep:
		hist_t = hist_t.slice(59)
		hist_s = hist_s.slice(59)
	if path_s.size() > 3000:
		var cut := 0
		while cut < path_s.size() - 2 and path_s[cut + 1] < seg_s[NSEG - 1] - 1.0:
			cut += 1
		if cut > 0:
			path_s = path_s.slice(cut)
			path_p = path_p.slice(cut)


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	clock += dt
	shake = maxf(0.0, shake - dt)
	_camera()
	_wind_step(dt)
	if flag:
		flag.rotation.y = sin(clock * 5.0) * 0.25
	if gate_open and gate_k < 1.0:
		gate_k = minf(1.0, gate_k + dt * 2.5)
		for g in gates:
			g.position.y = lerpf(0.45, -0.6, gate_k)
	for rg in regs:
		if rg.k == "x" and rg.done:
			rg.fall += dt
			for h in rg.tiles:
				(h as Node3D).position.y = -6.0 * rg.fall * rg.fall
	if die_t > 0.0:
		die_t -= dt
		_die_anim(dt)
		if die_t <= 0.0:
			_build(lv)
		return
	if clear_t > 0.0:
		clear_t -= dt
		var k := clampf(clear_t / CLEAR_T, 0.0, 1.0)
		for p in pivs:
			p.scale = Vector3.ONE * k
		for l in links:
			l.visible = false
		if clear_t <= 0.0:
			_next()
		return
	# 조종: 끈 방향으로 머리를 돌리고, 끈 거리만큼 빨라진다 (관성 있음)
	var mv := kit_move
	var want := 0.0
	if mv.length() > 0.12:
		want = VMAX * clampf((mv.length() - 0.12) / 0.75, 0.0, 1.0)
		var da := wrapf(mv.angle() - hdir.angle(), -PI, PI)
		hdir = Vector2.from_angle(hdir.angle() + clampf(da, -TURN * dt, TURN * dt))
	spd = move_toward(spd, want, (ACC if want > spd else BRAKE) * dt)
	var old := hp
	var hit := _move(hdir * spd * dt)
	var moved := hp.distance_to(old)
	if dt > 0.0:
		real_v = lerpf(real_v, moved / dt, 0.25)
		if hit / dt > 6.5:
			spd *= 0.4
			shake = 0.15
			beep(140.0, 0.08, 90.0, 0.22)
	s_head += moved
	if moved > 0.0005:
		path_p.append(hp)
		path_s.append(s_head)
	hist_t.append(clock)
	hist_s.append(s_head)
	_follow()
	tick_s += moved
	if tick_s >= 1.0:
		tick_s -= 1.0
		beep(260.0 + 32.0 * real_v, 0.03, 0.0, 0.07)
	var d := real_v * LAG
	gauge(real_v / VMAX, A if d < DMIN + 0.1 else (D if d < 1.0 else (B if d < 2.0 else C)))
	if _cell(hp) == "E":
		clear_t = CLEAR_T
		score += 1
		play("good")
		beep(990.0, 0.2, 1480.0, 0.2)
		msg("통과!", 0.8)
		return
	_tiles(dt)
	_hazards()
	_draw_snake(dt)


## 머리 움직이기: 축마다 따로, 벽이면 미끄러지고 모서리면 칸 가운데로 밀어 준다. 막힌 거리를 돌려준다
func _move(st: Vector2) -> float:
	var hit := 0.0
	var nx := hp.x + st.x
	if st.x != 0.0 and _blocked(nx, hp.y):
		hit += absf(st.x)
		nx = hp.x
		var cz := floorf(hp.y) + 0.5
		if absf(cz - hp.y) > 0.01 and not _blocked(hp.x + st.x, cz):
			hp.y = move_toward(hp.y, cz, absf(st.x))
	hp.x = nx
	var nz := hp.y + st.y
	if st.y != 0.0 and _blocked(hp.x, nz):
		hit += absf(st.y)
		nz = hp.y
		var cx := floorf(hp.x) + 0.5
		if absf(cx - hp.x) > 0.01 and not _blocked(cx, hp.y + st.y):
			hp.x = move_toward(hp.x, cx, absf(st.y))
	hp.y = nz
	return hit


## 얇은 바닥·발판·파란 칸: 그 위 마디 수
func _tiles(dt: float) -> void:
	for rg in regs:
		rg.n = 0
	for i in NSEG:
		if seg_s[i] < 0.0:
			continue
		var cell := Vector2i(floori(seg_p[i].x), floori(seg_p[i].y))
		if reg_of.has(cell):
			regs[reg_of[cell]].n += 1
	var all_b := true
	var any_b := false
	var plates_ok := true
	creak_t -= dt
	for rg in regs:
		var n: int = rg.n
		if rg.k == "x" and not rg.done:
			if n >= W_CRACK:
				rg.done = true
				for cell in rg.cells:
					_set_cell(cell.x, cell.y, "o")
				beep(160.0, 0.4, 50.0, 0.32)
				shake = 0.3
			else:
				for h in rg.tiles:
					(h as Node3D).position.y = sin(clock * 60.0) * 0.03 if n == W_CRACK - 1 else 0.0
				if n == W_CRACK - 1 and creak_t <= 0.0:
					creak_t = 0.18
					beep(230.0, 0.05, 180.0, 0.12)
		elif rg.k == "p":
			if not rg.done and n >= W_PLATE:
				rg.done = true
				beep(200.0, 0.25, 110.0, 0.3)
				msg("꾹!", 0.6)
			var col: Color = GOOD if rg.done else D.lerp(A, clampf(n / float(W_PLATE), 0.0, 1.0))
			var dy := -0.06 if rg.done else -0.015 * n
			for h in rg.tiles:
				var hh := h as Node3D
				hh.position.y = dy
				(hh.get_child(0) as MeshInstance3D).material_override = mat(col)
			if not rg.done:
				plates_ok = false
		elif rg.k == "b":
			any_b = true
			if n == 0:
				all_b = false
	if any_b:
		if not b_done and all_b:
			b_done = true
			beep(880.0, 0.3, 1320.0, 0.25)
			msg("딱 맞다!", 0.8)
		for rg in regs:
			if rg.k == "b":
				var col: Color = GOOD if b_done else (WHITE if rg.n > 0 else B.lightened(0.35))
				for h in rg.tiles:
					((h as Node3D).get_child(0) as MeshInstance3D).material_override = mat(col)
		if not b_done:
			plates_ok = false
	if not gate_open and plates_ok and not gates.is_empty():
		gate_open = true
		for r in ROWS:
			for c in COLS:
				if grid[r][c] == "=":
					_set_cell(c, r, " ")
		beep(400.0, 0.3, 800.0, 0.25)
		msg("문 열림", 0.8)


func _hazards() -> void:
	for i in NSEG - 1:
		if seg_s[i + 1] < 0.0:
			break
		if _pit(seg_p[i]) and _pit(seg_p[i + 1]):
			_die("fall", i)
			return
	for i in NSEG - 1:
		if seg_s[i + 1] < 0.0:
			break
		if _chord_hits(seg_p[i], seg_p[i + 1]):
			_die("snag", i)
			return


func _die(kind: String, link: int) -> void:
	die_kind = kind
	die_link = link
	die_t = DIE_T
	fall_v = 0.0
	deaths += 1
	shake = 0.35
	if kind == "fall":
		beep(520.0, 0.6, 70.0, 0.3)
		msg("떨어졌다", 1.0)
	else:
		beep(1100.0, 0.25, 180.0, 0.3)
		msg("줄이 걸렸다", 1.0)
	for e in eyes:
		e.scale = Vector3(0.3, 0.06, 0.3)
	for p in pupils:
		p.visible = false
	mouth.scale = Vector3(0.03, 0.14, 0.32)


func _die_anim(dt: float) -> void:
	if die_kind == "fall":
		fall_v += 22.0 * dt
		for i in NSEG:
			var p := pivs[i]
			if _pit(seg_p[i]) or absf(i - die_link) <= 1 or p.position.y < -0.05:
				p.position.y -= fall_v * dt
				p.rotation.z += dt * 3.0
		for l in links:
			l.visible = false
	else:
		var flash := int(die_t * 12.0) % 2 == 0
		if die_link >= 0 and die_link < links.size():
			links[die_link].visible = true
			links[die_link].material_override = mat(BAD if flash else WHITE)
		for i in NSEG:
			var p := pivs[i]
			p.position.x = seg_p[i].x + randf_range(-0.05, 0.05)
			p.position.z = seg_p[i].y + randf_range(-0.05, 0.05)


func _next() -> void:
	lv += 1
	if lv >= ROOMS.size():
		lv = ROOMS.size() - 1
		msg("완주!", 2.0)
		end()
		beep(660.0, 0.5, 1320.0, 0.3)
		return
	if ROOMS[lv].grp != ROOMS[lv - 1].grp:
		beep(523.0, 0.3, 1046.0, 0.25)
	_build(lv)


# ---- 그리기 ----
func _draw_snake(dt: float) -> void:
	var vis: Array[Vector2] = []
	var gaps: Array[float] = []
	for i in NSEG:
		var p := seg_p[i]
		var dv: Vector2 = hdir if i == 0 else seg_p[i - 1] - p
		if dv.length() > 0.02:
			seg_d[i] = dv.normalized()
		var gap := 0.0
		if i > 0:
			gap = seg_p[i - 1].distance_to(p)
		elif NSEG > 1:
			gap = p.distance_to(seg_p[1])
		gaps.append(gap)
		var dir := seg_d[i]
		var side := Vector2(-dir.y, dir.x)
		var amp := 0.0 if i == 0 else 0.17 * clampf(1.0 - gap / 0.9, 0.0, 1.0)
		vis.append(p + side * sin(seg_s[i] * 3.2) * amp)
	for i in NSEG:
		var pv := pivs[i]
		var dir := seg_d[i]
		var y := 0.0
		if real_v > 0.5:
			y = absf(sin(clock * 14.0 + i * 0.9)) * 0.04
		if i > 0 and _pit(seg_p[i]):
			y = -0.1  # 구멍 위에서 줄에 매달려 살짝 처진다
		pv.position = Vector3(vis[i].x, y, vis[i].y)
		pv.rotation = Vector3(0.0, atan2(-dir.y, dir.x), 0.0)
		var st := 1.0 + clampf((gaps[i] - 0.6) * 0.3, 0.0, 0.45)
		pv.scale = Vector3(st, 1.0, 1.0 / sqrt(st))
	# 마디 사이 줄: 느슨하면 마디 색, 1칸 넘게 벌어지면 흰 팽팽 줄 (가늘어진다)
	for i in NSEG - 1:
		var l := links[i]
		var a := vis[i]
		var b := vis[i + 1]
		var dist := a.distance_to(b)
		var ln := dist - 0.45
		if ln < 0.06:
			l.visible = false
			continue
		l.visible = true
		var th := lerpf(0.16, 0.06, clampf((dist - 0.6) / 1.8, 0.0, 1.0))
		var mid := (a + b) * 0.5
		var dd := b - a
		var y := 0.22
		if _pit(mid):
			y = 0.12
		l.position = Vector3(mid.x, y, mid.y)
		l.rotation = Vector3(0.0, atan2(-dd.y, dd.x), 0.0)
		l.scale = Vector3(ln, th, th)
		l.material_override = mat(WHITE if dist > 1.0 else link_col[i])
	# 얼굴: 빠르면 실눈·벌린 입, 서 있으면 깜빡이고 혀 날름
	blink -= dt
	if blink < -3.0:
		blink = 0.12
	var fast := real_v > 7.0
	for e in eyes:
		if fast:
			e.scale = Vector3(0.08, 0.06, 0.24)
		elif blink > 0.0:
			e.scale = Vector3(0.24, 0.06, 0.05)
		else:
			e.scale = Vector3(0.24, 0.06, 0.22)
	var look := kit_move.normalized() if kit_move.length() > 0.12 else hdir
	var rel := look.rotated(-hdir.angle())
	for k in pupils.size():
		var p := pupils[k]
		p.visible = not fast and blink <= 0.0
		var side := -1.0 if k == 0 else 1.0
		p.position = Vector3(0.12 + rel.x * 0.06, 0.64, side * 0.2 + rel.y * 0.06)
	mouth.scale = Vector3(0.03, 0.12, 0.34) if fast else Vector3(0.03, 0.06, 0.26)
	tongue_t += dt
	tongue.visible = real_v < 0.5 and fmod(tongue_t, 1.6) < 0.18


func _camera() -> void:
	var sk := Vector3.ZERO
	if shake > 0.0:
		sk = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * shake * 0.5
	cam.position = Vector3(6.0, 13.0, 10.8) + sk
	cam.look_at(Vector3(6.0, 0.0, 7.9) + sk, Vector3.UP)
	cam.fov = 56.0 + 4.0 * clampf(real_v / VMAX, 0.0, 1.0)


## 빠를 때 몸 옆으로 흘러가는 바람 줄
func _wind_step(dt: float) -> void:
	wind_t -= dt
	if die_t <= 0.0 and clear_t <= 0.0 and real_v > 6.0 and wind_t <= 0.0 and not winds.is_empty():
		wind_t = 0.05
		var i := randi_range(0, NSEG - 1)
		var dir := seg_d[i]
		var side := Vector2(-dir.y, dir.x) * randf_range(-0.6, 0.6)
		var w := winds[wind_k]
		wind_k = (wind_k + 1) % winds.size()
		w.visible = true
		w.position = Vector3(seg_p[i].x + side.x, 0.5, seg_p[i].y + side.y)
		w.rotation = Vector3(0.0, atan2(-dir.y, dir.x), 0.0)
		w.scale = Vector3(0.5 + real_v * 0.08, 0.05, 0.05)
		var idx := winds.find(w)
		wind_v[idx] = Vector3(-dir.x, 0.0, -dir.y) * real_v * 0.6
		wind_l[idx] = 0.3
	for k in winds.size():
		if wind_l[k] <= 0.0:
			continue
		wind_l[k] -= dt
		var w := winds[k]
		w.position += wind_v[k] * dt
		w.scale.x *= 0.92
		if wind_l[k] <= 0.0:
			w.visible = false
