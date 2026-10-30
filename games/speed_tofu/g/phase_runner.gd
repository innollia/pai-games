extends Tofu
## 흐릿이 유리공방 v2 (옆모습 메트로브레이니아 퍼즐): 왼쪽 아래 조이스틱으로 좌우(끝까지 밀면 질주), 오른쪽 버튼으로 점프. 방 8개가 이어진 지도를 오간다.
## 핵심 규칙: 빠르면(옆으로 달리거나 빨리 떨어지면) 몸이 흐려져 하늘색 유리를 지나가고, 느리면 단단해져 단추를 누른다. 유리 속에서 느려지면 굳어 죽는다.
## v2 = 퍼즐 전담이 "활용법" 깨달음 13개를 뽑아 방을 다시 짰다: 도움닫기 공간 → 유리 뒤 단추는 지나쳐서 걸어 돌아오기 → 달리면 2칸 유리를 건너버리니 제자리 점프로 뚫기 → 떨어져서 누르기 → 올라가는 속도는 안 세니 달리며 뛰기 → 바람 선반(유리 위에선 못 달림) → 종합.
## 단추는 같은 색 보라 문을 연다(단추 위 색 띠 = 열리는 문). 별 4개, 꼭대기 초록 문이 끝.
# 한 문장: 나는 안개 정령 흐릿이로서 빠를 때만 몸이 흐려지는 제약 속에서 유리 공방의 이어진 방을 달리고 떨어지며 유리를 지나 단추를 눌러 먼 문을 열어 맨 위 문에 닿지만, 빠른 몸은 아무것도 누르지 못하고 유리 속에서 느려지면 굳어 버리는 대가를 감수한다.

const GRAV := 45.0
const JUMP_V := 18.0  # 3.6칸
const SPRINT := 22.0
const JOG := 10.0
const STICK_RUN := 0.7
const GROUND_ACC := 70.0
const AIR_ACC := 30.0
const FRICTION := 40.0
const MAX_FALL := 28.0
const PH_ON := 15.0  # 이 속도 넘으면 흐려짐
const PH_OFF := 12.0  # 이 아래로 떨어지면 단단해짐
const BW := 0.8
const BH := 1.6
const STEP := 0.45  # 빠르게 2칸 구멍을 건널 때 발끝이 걸쳐 오르는 높이
const UP_BOOST := 18.0
const FAN_UP := 14.0
const EPS := 0.0001
const GLASS := Color("aee4ef")
const GLASS_ON := Color("eefcff")
const GATE := Color("9c6ade")
const GATES := [Color("9c6ade"), Color("9c6ade"), Color("e64980"), Color("7048e8"), Color("c2255c")]  # 문 숫자별 색 (단추 띠와 같다)
const PALS := [
	{"wall": Color("e2c9a0"), "trim": Color("f0a35e"), "far": Color("f3dcc4"), "sky": Color("fff3e3")},
	{"wall": Color("cfc3ec"), "trim": Color("fcc419"), "far": Color("e2dcf7"), "sky": Color("f1eeff")},
	{"wall": Color("b8dfc0"), "trim": Color("4dabf7"), "far": Color("d3efdc"), "sky": Color("e6fbf0")},
]
# 방: 위 줄부터. # 돌, | 유리, S 시작, D 끝 문, * 별, % 단추(방의 opens 문을 연다), 1~4 보라 문, F 바람(위로 기둥), 소문자 = 출구.
# 몸 0.8 x 1.6. 질주 22, 1.6칸 달리면 흐려짐(15), 손 놓으면 4.3칸·반대로 밀면 2.4칸 뒤 단단(12). 2.5칸 넘게 떨어지면 흐려짐. 점프 3.6칸.
# 방 8개 = 도입(0·1 유리벽과 도움닫기·되돌이) → 비틀기(2·3 떨어지는 속도) → 결합(4·5·6) → 종합(7).
const ROOMS := [
	{"name": "입구 공방", "pal": 0, "pos": Rect2(0, 0, 2, 1), "map": [
		"####################",
		"####################",
		"#1........|........#",
		"#1........|........#",
		"b1........|........a",
		"b1......S.|........a",
		"####################",
		"####################",
	]},
	{"name": "되돌이 단추", "pal": 0, "opens": "1", "pos": Rect2(2, 0, 2, 1), "map": [
		"########################",
		"########################",
		"#......|...............#",
		"#......|...............#",
		"a......|...............#",
		"a......|.%.............#",
		"########################",
		"########################",
	]},
	{"name": "유리 바닥", "pal": 1, "pos": Rect2(-2, 0, 2, 1), "map": [
		"######################",
		"######################",
		"c....................b",
		"c....................b",
		"####||||||||||########",
		"#....................#",
		"#....................#",
		"#.......*....F.......#",
		"######################",
	]},
	{"name": "두 칸 유리", "pal": 1, "pos": Rect2(-4, 0, 2, 1), "map": [
		"################",
		"################",
		"#..............c",
		"#..............c",
		"######||########",
		"#..............#",
		"#..............#",
		"d..............#",
		"d............*.#",
		"################",
	]},
	{"name": "떨어져서 누르기", "pal": 2, "opens": "2", "pos": Rect2(-6, -1, 2, 1), "map": [
		"#####################",
		"#####################",
		"#...................d",
		"#.*.................d",
		"#############||######",
		"###########......####",
		"###########......####",
		"e.2.....|||......####",
		"e.2.....|||..%%..####",
		"#####################",
	]},
	{"name": "유리 기둥", "pal": 2, "pos": Rect2(-8, -1, 2, 1), "map": [
		"####################",
		"####################",
		"####################",
		"#....*.............#",
		"#..................#",
		"#.........|........#",
		"#.........|........#",
		"f.........#........e",
		"f.........#........e",
		"####################",
	]},
	{"name": "바람 선반", "pal": 2, "opens": "3", "pos": Rect2(-9, -1, 1, 2), "map": [
		"##########hhh#",
		"##########333#",
		"##########333#",
		"##########...#",
		"##########...#",
		"#............#",
		"#.........#..#",
		"#............#",
		"#....%%......#",
		"#....|||||...#",
		"#............#",
		"#............#",
		"#............#",
		"#............#",
		"#............#",
		"#............#",
		"#............#",
		"#............f",
		"#.........FFFf",
		"##############",
	]},
	{"name": "꼭대기 가마", "pal": 1, "opens": "4", "pos": Rect2(-12, 1, 3, 1), "map": [
		"############################",
		"############################",
		"h.................|....4.4.#",
		"h.................|....4D4.#",
		"#####||###################.#",
		"###......#################.#",
		"###......#################.#",
		"###......|.................#",
		"###..%%..|................F#",
		"############################",
	]},
]
const LEARN_MSG := ["빠르면 유리를 지난다!", "빨리 떨어져도 흐려진다!", "단단해야 눌린다!", "흐린 몸은 바람을 탄다!"]
const NSTAR := 4


class _Map extends Control:
	var k

	func _draw() -> void:
		k._map_draw(self)


var lv := 0
var stage: Node3D
var grid: Array[String] = []
var rows := 0
var cols := 0
var door := Rect2()
var has_door := false
var px := 0.0  # 발 가운데
var py := 0.0
var vx := 0.0
var vy := 0.0
var phased := false
var on_floor := false
var coyote := 0.0
var jbuf := 0.0
var cut := true
var face := 1.0
var die_t := 0.0
var clear_t := 0.0
var shake := 0.0
var squash := 0.0
var step_t := 0.0
var hum_t := 0.0
var anim := 0.0
var cam_x := 0.0
var cam_y := 0.0
var trail_t := 0.0
var trail_k := 0
var gate_t := 0.0
var nopress_t := 0.0
var glass_t := 0.0
var heavy_t := 0.0
var check_pt := Vector2.ZERO
var visited := {}
var got := {}  # 먹은 별 "방:칸:줄"
var opened := {}  # 열린 문 숫자 -> true
var learned := [false, false, false, false]
var links := {}  # 출구 글자 -> 방 번호들
var fan_cols := {}  # 칸 -> Vector2(아래 y, 위 y)
var env: Environment
var mapc: _Map
var ghost: StandardMaterial3D
var ghost2: StandardMaterial3D
var me: Node3D
var body: MeshInstance3D
var eye: MeshInstance3D
var trail: Array[MeshInstance3D] = []
var glass_boxes: Array[MeshInstance3D] = []
var gate_boxes: Array[MeshInstance3D] = []
var btn_boxes: Array[MeshInstance3D] = []
var pick: Array = []  # [상자, 칸 Rect2, 열쇠]
var clouds: Array[MeshInstance3D] = []
var bits: Array[MeshInstance3D] = []
var bit_v: Array[Vector3] = []
var bit_l: Array[float] = []
var bit_k := 0
var gusts: Array[MeshInstance3D] = []
var winds: Array[MeshInstance3D] = []
var wind_t := 0.0
var wind_k := 0


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 58.0
	howto = "조이스틱으로 좌우, 끝까지 밀면 질주(1.6칸이면 흐려진다). 오른쪽 버튼은 점프.\n빠르면 몸이 흐려져 하늘색 유리를 지나가고, 느리면 단단해져 단추를 누른다. 빨리 떨어져도 흐려진다. 유리 속에서 느려지면 굳어 죽는다.\n단추는 같은 색 띠의 보라 문을 연다(다른 방일 수도). 막히면 '지금 내 몸이 흐린가 단단한가'를 먼저 본다. 방들은 이어져 있다(오른쪽 위 지도). 별 4개, 꼭대기 초록 문이 끝."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1100), 105.0, A)
	for ch in get_children():
		if ch is WorldEnvironment:
			env = ch.environment
	for i in ROOMS.size():
		for s in ROOMS[i].map:
			for c in String(s):
				if c >= "a" and c <= "z":
					if not links.has(c):
						links[c] = []
					if not (i in links[c]):
						links[c].append(i)
	ghost = StandardMaterial3D.new()
	ghost.albedo_color = Color(0.55, 0.82, 1.0, 0.38)
	ghost.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost.next_pass = OUTLINE
	ghost2 = StandardMaterial3D.new()
	ghost2.albedo_color = Color(0.7, 0.9, 1.0, 0.22)
	ghost2.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)
	mapc = _Map.new()
	mapc.k = self
	mapc.size = Vector2(720, 1280)
	mapc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(mapc)


func _reset() -> void:
	lv = 0
	stage = null
	visited = {0: true}
	got = {}
	opened = {}
	learned = [false, false, false, false]
	phased = false
	mapc.visible = true
	_build(0)
	for r in rows:
		var k := grid[r].find("S")
		if k >= 0:
			check_pt = Vector2(k + 0.5, rows - 1 - r)
	_place(check_pt)
	msg("입구 공방", 1.2)
	_score()


func _score() -> void:
	score = visited.size() + got.size() * 5


# ---- 방 짓기 ----
func _build(i: int) -> void:
	if stage:
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	var pal: Dictionary = PALS[ROOMS[i].pal]
	if env:
		env.background_color = pal.sky
	var m: Array = ROOMS[i].map
	rows = m.size()
	cols = 0
	for s in m:
		cols = maxi(cols, String(s).length())
	grid.clear()
	for s in m:
		grid.append(String(s).rpad(cols, "#"))
	has_door = false
	pick.clear()
	glass_boxes.clear()
	gate_boxes.clear()
	btn_boxes.clear()
	fan_cols.clear()
	var opens: String = ROOMS[i].get("opens", "")
	var rng := RandomNumberGenerator.new()
	rng.seed = i * 977 + 31
	# 먼 실루엣: 공방 굴뚝과 유리 지붕
	for k in 9:
		var w := rng.randf_range(2.5, 6.0)
		var hh := rng.randf_range(10.0, 24.0)
		var x := rng.randf_range(-14.0, cols + 14.0)
		box(Vector3(x, -16.0 + hh * 0.5, -26.0 - k * 0.8), Vector3(w, hh, 1.0), pal.far if k % 2 == 0 else pal.far.lightened(0.3), stage)
		if k % 3 == 0:
			box(Vector3(x, -16.0 + hh + 1.0, -26.0 - k * 0.8), Vector3(w * 0.9, 2.0, 1.0), GLASS.lightened(0.3), stage)
	clouds.clear()
	for k in 3:
		var cb := box(Vector3(rng.randf_range(-6.0, cols + 6.0), rows + rng.randf_range(1.0, 6.0), -8.0), Vector3(rng.randf_range(2.5, 4.5), 0.9, 1.0), WHITE, stage)
		clouds.append(cb)
	for r in rows:
		var yy := rows - 1 - r
		var line := grid[r]
		var run0 := -1
		var top0 := -1
		var gl0 := -1
		for c in cols + 1:
			var ch := line[c] if c < cols else " "
			# 윗면 띠: 위가 비어 있는 돌 칸
			var topped := ch == "#" and yy + 1 < rows and _ch(c, yy + 1) != "#"
			if topped and top0 < 0:
				top0 = c
			elif not topped and top0 >= 0:
				box(Vector3((top0 + c) * 0.5, yy + 0.93, 0.0), Vector3(c - top0, 0.16, 2.08), pal.trim, stage)
				top0 = -1
			# 유리 줄
			if ch == "|":
				if gl0 < 0:
					gl0 = c
			elif gl0 >= 0:
				var g := box(Vector3((gl0 + c) * 0.5, yy + 0.5, 0.0), Vector3(c - gl0, 1.0, 1.6), GLASS_ON if phased else GLASS, stage)
				glass_boxes.append(g)
				box(Vector3(gl0 + 0.3, yy + 0.6, 0.82), Vector3(0.1, 0.5, 0.04), WHITE, stage)
				gl0 = -1
			if ch == "#":
				if run0 < 0:
					run0 = c
				continue
			if run0 >= 0:
				box(Vector3((run0 + c) * 0.5, yy + 0.5, 0.0), Vector3(c - run0, 1.0, 2.0), pal.wall, stage)
				run0 = -1
			if ch == "^":
				var sp := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.55, 0.55, 1.2), BAD, stage)
				sp.rotation.z = PI * 0.25
			elif ch == "D":
				door = Rect2(c, yy, 1.0, 2.0)
				has_door = true
				box(Vector3(c + 0.5, yy + 1.0, -0.6), Vector3(1.1, 2.0, 0.6), GOOD, stage)
				box(Vector3(c + 0.75, yy + 1.0, -0.2), Vector3(0.15, 0.15, 0.2), D, stage)
			elif ch == "*":
				var key := "%d:%d:%d" % [i, c, yy]
				if not got.has(key):
					var st := box(Vector3(c + 0.5, yy + 0.6, 0.0), Vector3(0.5, 0.5, 0.5), D, stage)
					st.rotation.z = PI * 0.25
					pick.append([st, Rect2(c + 0.1, yy, 0.8, 1.2), key])
			elif ch == "%":
				var on := opened.has(opens)
				var bb := box(Vector3(c + 0.5, yy + (0.06 if on else 0.14), 0.0), Vector3(0.9, 0.12 if on else 0.28, 1.2), GOOD if on else A, stage)
				btn_boxes.append(bb)
				# 단추 위 색 띠 = 열리는 문의 색
				box(Vector3(c + 0.5, yy + (0.13 if on else 0.3), 0.0), Vector3(0.5, 0.05, 1.24), GATES[mini(int(opens), 4)] if opens != "" else GATE, stage)
			elif ch >= "0" and ch <= "9":
				if not opened.has(ch):
					var gb := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.7, 1.0, 1.5), GATES[mini(int(ch), 4)], stage)
					gate_boxes.append(gb)
					box(Vector3(0.0, 0.0, 0.52), Vector3(0.18, 0.7, 0.02), WHITE, gb)
			elif ch == "F":
				box(Vector3(c + 0.5, yy + 0.1, 0.0), Vector3(1.0, 0.2, 1.6), Color("8aa6bf"), stage)
				var top := yy
				while top + 1 < rows and _ch(c, top + 1) != "#":
					top += 1
				fan_cols[c] = Vector2(yy, top + 1)
	# 바닥 눈금 (속도감 단서)
	for r in rows:
		var yy := rows - 1 - r
		for c in cols:
			if (c % 2 == 0) and _ch(c, yy) == "#" and yy + 1 < rows and _ch(c, yy + 1) == " ":
				box(Vector3(c + 0.5, yy + 0.8, 1.06), Vector3(0.14, 0.26, 0.06), SOFT, stage)
	# 바람 줄기 (바람 기둥 안을 올라가는 흰 선, 돌려 쓴다)
	gusts.clear()
	if not fan_cols.is_empty():
		var ks: Array = fan_cols.keys()
		for k in 9:
			var fc: int = ks[k % ks.size()]
			var fr: Vector2 = fan_cols[fc]
			var gb := box(Vector3(fc + rng.randf_range(0.2, 0.8), rng.randf_range(fr.x, fr.y), 0.9), Vector3(0.06, 0.9, 0.06), WHITE, stage)
			gusts.append(gb)
	# 나
	me = Node3D.new()
	stage.add_child(me)
	body = box(Vector3(0, BH * 0.5, 0), Vector3(BW, BH, 0.7), ME, me)
	eye = box(Vector3(0.18, BH * 0.7, 0.36), Vector3(0.16, 0.16, 0.05), WHITE, me)
	trail.clear()
	for k in 6:
		var tb := box(Vector3.ZERO, Vector3(BW, BH, 0.4), B, stage)
		tb.material_override = ghost2
		tb.visible = false
		trail.append(tb)
	bits.clear()
	bit_v.clear()
	bit_l.clear()
	for k in 12:
		var b := box(Vector3.ZERO, Vector3(0.22, 0.22, 0.22), GLASS, stage)
		b.visible = false
		bits.append(b)
		bit_v.append(Vector3.ZERO)
		bit_l.append(0.0)
	winds.clear()
	for k in 7:
		var wb := box(Vector3.ZERO, Vector3(1.6, 0.07, 0.07), WHITE, stage)
		wb.visible = false
		winds.append(wb)
	_body_look()


func _place(p: Vector2) -> void:
	px = p.x
	py = p.y
	vx = 0.0
	vy = 0.0
	phased = false
	on_floor = true
	coyote = 0.0
	jbuf = 0.0
	cut = true
	die_t = 0.0
	clear_t = 0.0
	squash = 0.0
	gate_t = 0.3
	cam_x = px
	cam_y = py
	_glass_look()
	_body_look()


## 출구 글자로 다음 방에 들어간다 (속도·흐림은 그대로)
func _go(letter: String) -> void:
	var to := -1
	for j in links.get(letter, []):
		if j != lv:
			to = j
	if to < 0:
		return
	var kvx := vx
	var kvy := vy
	lv = to
	_build(to)
	var c0 := 999
	var c1 := -1
	var y0 := 999
	var y1 := -1
	for r in rows:
		for c in cols:
			if grid[r][c] == letter:
				var yy := rows - 1 - r
				c0 = mini(c0, c)
				c1 = maxi(c1, c)
				y0 = mini(y0, yy)
				y1 = maxi(y1, yy)
	if c0 == 0:
		px = 1.0 + BW * 0.5 + 0.02
		py = y0
	elif c1 == cols - 1:
		px = cols - 1.0 - BW * 0.5 - 0.02
		py = y0
	elif y1 == rows - 1:
		px = (c0 + c1 + 1) * 0.5
		py = rows - 1.0 - BH - 0.02
	else:
		px = (c0 + c1 + 1) * 0.5
		py = 1.0
		kvy = maxf(kvy, UP_BOOST)
	vx = kvx
	vy = kvy
	gate_t = 0.3
	cam_x = px
	cam_y = py
	check_pt = _safe_near(px, py)
	if not visited.has(to):
		visited[to] = true
		beep(660.0, 0.12, 990.0, 0.2)
	_score()
	beep(500.0, 0.06, 800.0, 0.14)
	msg(ROOMS[to].name, 1.0)


## 단단한 몸으로 서서 다시 시작해도 안전한 가장 가까운 자리
func _safe_near(x: float, y: float) -> Vector2:
	var best := Vector2(x, y)
	var bd := INF
	for yy in range(1, rows - 1):
		for c in range(1, cols - 1):
			var fl := _ch(c, yy - 1)
			if fl != "#" and fl != "|":
				continue
			var ok := true
			for k in 2:
				var ch := _ch(c, yy + k)
				if ch != " " and ch != "S" and ch != "*" and ch != "%":
					ok = false
			if not ok:
				continue
			var d := Vector2(c + 0.5 - x, (yy - y) * 1.5).length_squared()
			if d < bd:
				bd = d
				best = Vector2(c + 0.5, yy)
	return best


# ---- 칸 ----
func _ch(c: int, yy: int) -> String:
	if c < 0 or c >= cols or yy >= rows:
		return "#"
	if yy < 0:
		return " "
	return grid[rows - 1 - yy][c]


## 지금 몸에게 막힌 칸인가 (유리는 흐릴 때 비어 있다, 문은 열리면 비어 있다)
func _solid(c: int, yy: int) -> bool:
	var ch := _ch(c, yy)
	if ch == "#":
		return true
	if ch == "|":
		return not phased
	if ch >= "0" and ch <= "9":
		return not opened.has(ch)
	return false


func _x0() -> int:
	return floori(px - BW * 0.5 + EPS)


func _x1() -> int:
	return floori(px + BW * 0.5 - EPS)


func _y0() -> int:
	return floori(py + EPS)


func _y1() -> int:
	return floori(py + BH - EPS)


func _ground() -> bool:
	var yy := floori(py - 0.02)
	for c in range(_x0(), _x1() + 1):
		if _solid(c, yy):
			return true
	return false


func _col_solid(c: int, y0: int, y1: int) -> bool:
	for yy in range(y0, y1 + 1):
		if _solid(c, yy):
			return true
	return false


func _in_glass() -> bool:
	for c in range(_x0(), _x1() + 1):
		for yy in range(_y0(), _y1() + 1):
			if _ch(c, yy) == "|":
				return true
	return false


func _in_fan() -> bool:
	var c := floori(px)
	if not fan_cols.has(c):
		return false
	var fr: Vector2 = fan_cols[c]
	return py >= fr.x - 0.3 and py < fr.y


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	anim += dt
	gauge(float(visited.size()) / ROOMS.size(), GOOD)
	mapc.queue_redraw()
	if die_t > 0.0:
		die_t -= dt
		_view(dt)
		if die_t <= 0.0:
			_build(lv)
			_place(check_pt)
		return
	if clear_t > 0.0:
		clear_t -= dt
		_view(dt)
		if clear_t <= 0.0:
			mapc.visible = false
			end()
		return
	gate_t -= h
	nopress_t -= h
	heavy_t -= h
	_control(h)
	_phase()
	if die_t > 0.0:
		_view(dt)
		return
	_physics(h)
	_check()
	_sounds(h)
	_view(dt)


func _control(h: float) -> void:
	var mx := kit_move.x
	if absf(mx) < 0.12:
		mx = 0.0
	if kit_just("jump"):
		jbuf = 0.12
	jbuf -= h
	coyote -= h
	squash = maxf(0.0, squash - h * 4.0)
	if mx != 0.0:
		face = signf(mx)
	var target := 0.0
	if mx != 0.0:
		target = signf(mx) * (SPRINT if absf(mx) >= STICK_RUN else JOG * absf(mx) / STICK_RUN)
	var too_fast := mx != 0.0 and signf(vx) == signf(target) and absf(vx) > absf(target)
	if on_floor:
		if mx == 0.0:
			vx = move_toward(vx, 0.0, FRICTION * h)
		elif too_fast:
			vx = move_toward(vx, target, FRICTION * h)
		else:
			vx = move_toward(vx, target, GROUND_ACC * h)  # 반대로 밀면 브레이크
	elif mx != 0.0 and not too_fast:
		vx = move_toward(vx, target, AIR_ACC * h)
	if jbuf > 0.0 and (on_floor or coyote > 0.0):
		vy = JUMP_V
		on_floor = false
		coyote = 0.0
		jbuf = 0.0
		cut = false
		beep(420.0, 0.1, 900.0, 0.22)
	if not cut and vy > 0.0 and not kit_held("jump"):
		vy *= 0.9
		cut = true


## 속도 = 몸의 재질. 옆으로 빠르거나 빨리 떨어지면 흐림, 느려지면 단단 (바람 속에선 흐림 유지)
func _phase() -> void:
	var s := maxf(absf(vx), -vy)
	if phased:
		if s < PH_OFF and not _in_fan():
			phased = false
			_glass_look()
			_body_look()
			beep(1100.0, 0.08, 520.0, 0.18)
			if _in_glass():
				_die("굳었다!")
	elif s >= PH_ON:
		phased = true
		_glass_look()
		_body_look()
		beep(520.0, 0.1, 1250.0, 0.2)


func _glass_look() -> void:
	for g in glass_boxes:
		g.material_override = mat(GLASS_ON if phased else GLASS)


func _body_look() -> void:
	if body == null:
		return
	body.material_override = ghost if phased else mat(ME)


func _physics(h: float) -> void:
	var fall := vy
	vy = maxf(vy - GRAV * h, -MAX_FALL)
	if _in_fan():
		if phased:
			vy = move_toward(vy, FAN_UP, 120.0 * h)
			var mx := kit_move.x if absf(kit_move.x) >= 0.12 else 0.0
			vx = move_toward(vx, mx * 6.0, 60.0 * h)
			_learn(3)
		elif on_floor and heavy_t <= 0.0:
			heavy_t = 3.0
			msg("무거워서 안 뜬다", 0.8)
			beep(160.0, 0.12, 120.0, 0.15)
	for i in 4:
		_move_x(vx * h * 0.25)
		_move_y(vy * h * 0.25)
	var was := on_floor
	on_floor = vy <= 0.0 and _ground()
	if on_floor:
		coyote = 0.08
		if not was:
			squash = maxf(squash, clampf(-fall / 40.0, 0.2, 0.6))
			beep(90.0, 0.06, 0.0, 0.2)
			if fall < -14.0:
				_burst(Vector3(px, py, 0.6), 4, 1.0)


func _move_x(d: float) -> void:
	if d == 0.0:
		return
	px += d
	var c := _x1() if d > 0.0 else _x0()
	if not _col_solid(c, _y0(), _y1()):
		return
	# 발끝만 걸렸으면(빠르게 구멍을 건너는 중) 위로 올라선다
	var top := float(_y0() + 1)
	if vy <= 0.5 and top - py <= STEP and not _col_solid(c, _y0() + 1, floori(top + BH - EPS)):
		var ok := true
		for cc in range(_x0(), _x1() + 1):
			if _col_solid(cc, _y0() + 1, floori(top + BH - EPS)):
				ok = false
		if ok:
			py = top
			if vy < 0.0:
				vy = 0.0
			return
	px = c - BW * 0.5 - 0.001 if d > 0.0 else c + 1.0 + BW * 0.5 + 0.001
	var sp := absf(vx)
	if sp > PH_OFF:
		shake = maxf(shake, 0.15 + sp / 160.0)
		squash = 0.4
		_burst(Vector3(px + signf(d) * BW * 0.5, py + BH * 0.5, 0.6), 3, 0.0)
		beep(130.0, 0.12, 60.0, 0.32)
	vx = 0.0


func _move_y(d: float) -> void:
	if d == 0.0:
		return
	py += d
	var r := _y1() if d > 0.0 else floori(py)
	var hit := false
	for c in range(_x0(), _x1() + 1):
		if _solid(c, r):
			hit = true
			break
	if not hit:
		return
	if d > 0.0:
		py = r - BH - 0.001
		if vy > 4.0:
			beep(240.0, 0.06, 140.0, 0.16)
		vy = 0.0
	else:
		py = r + 1.0
		vy = 0.0


func _check() -> void:
	if die_t > 0.0:
		return
	var r := Rect2(px - BW * 0.5, py, BW, BH)
	if py < -2.0:
		_die("떨어짐")
		return
	# 출구
	if gate_t <= 0.0:
		for c in range(_x0(), _x1() + 1):
			for yy in range(_y0(), _y1() + 1):
				var ch := _ch(c, yy)
				if ch >= "a" and ch <= "z" and ch.length() == 1:
					_go(ch)
					return
	for c in range(floori(r.position.x), floori(r.end.x) + 1):
		for yy in range(floori(py), floori(py + BH) + 1):
			if _ch(c, yy) == "^" and Rect2(c + 0.15, yy + 0.15, 0.7, 0.7).intersects(r):
				_die("가시")
				return
	for k in range(pick.size() - 1, -1, -1):
		var it: Array = pick[k]
		if (it[1] as Rect2).intersects(r):
			got[it[2]] = true
			(it[0] as MeshInstance3D).visible = false
			pick.remove_at(k)
			_burst(Vector3(px, py + BH, 0.6), 6, 1.0)
			play("good")
			msg("별 %d/%d" % [got.size(), NSTAR], 1.0)
			_score()
	# 지식 ①②: 흐린 몸으로 유리 속을 지나는 중 (유리 가루가 튄다)
	if phased and _in_glass():
		if absf(vx) >= PH_OFF:
			_learn(0)
		elif vy < -PH_OFF:
			_learn(1)
		glass_t -= 1.0 / 60.0
		if glass_t <= 0.0:
			glass_t = 0.07
			_burst(Vector3(px, py + BH * 0.5, 0.7), 1, 0.0)
	# 단추: 단단한 몸이 서 있어야 눌린다
	var opens: String = ROOMS[lv].get("opens", "")
	if opens != "" and not opened.has(opens):
		var on_btn := false
		for c in range(_x0(), _x1() + 1):
			if _ch(c, _y0()) == "%":
				on_btn = true
		if on_btn:
			if not phased and on_floor:
				_press(opens)
			elif phased and nopress_t <= 0.0:
				nopress_t = 1.2
				msg("흐려서 안 눌림!", 0.8)
				beep(300.0, 0.08, 0.0, 0.18)
				beep(300.0, 0.08, 0.0, 0.18)
	if has_door and door.intersects(r):
		clear_t = 1.2
		vx = 0.0
		vy = 0.0
		play("win")
		msg("탈출!", 1.2)
		score += 10


func _press(gate: String) -> void:
	opened[gate] = true
	for bb in btn_boxes:
		bb.material_override = mat(GOOD)
		bb.scale.y = 0.12
		bb.position.y = floorf(bb.position.y) + 0.06
	var here := not gate_boxes.is_empty()
	for gb in gate_boxes:
		gb.visible = false
	shake = maxf(shake, 0.25)
	beep(700.0, 0.05, 0.0, 0.25)
	beep(330.0, 0.3, 660.0, 0.25)
	_learn(2)
	msg("문이 열렸다!" if here else "어딘가 문이 열렸다!", 1.4)


func _learn(k: int) -> void:
	if learned[k]:
		return
	learned[k] = true
	msg(LEARN_MSG[k], 1.4)
	beep(880.0, 0.12, 1320.0, 0.25)
	beep(1320.0, 0.18, 1760.0, 0.18)


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 0.9
	body.material_override = mat(BAD)
	shake = maxf(shake, 0.4)
	_burst(Vector3(px, py + BH * 0.5, 0.6), 8, 1.0)
	play("bad")
	msg(why, 0.9)


func _sounds(h: float) -> void:
	step_t -= h
	if on_floor and absf(vx) > 3.0 and step_t <= 0.0:
		step_t = clampf(2.2 / absf(vx), 0.05, 0.3)
		beep(120.0 + absf(vx) * 8.0, 0.03, 0.0, 0.1)
	hum_t -= h
	if phased and hum_t <= 0.0:
		hum_t = 0.14
		beep(1500.0 + minf(Vector2(vx, vy).length(), 30.0) * 20.0, 0.05, 0.0, 0.05)


## 작은 상자 파편 n개 (up: 1 위로, -1 아래로, 0 옆으로)
func _burst(at: Vector3, n: int, up: float) -> void:
	for i in n:
		var b := bits[bit_k]
		bit_v[bit_k] = Vector3(randf_range(-5.0, 5.0), randf_range(2.0, 8.0) * (up if up != 0.0 else 0.6), randf_range(-1.0, 3.0))
		bit_l[bit_k] = randf_range(0.35, 0.6)
		b.position = at
		b.visible = true
		bit_k = (bit_k + 1) % bits.size()


func _view(dt: float) -> void:
	me.position = Vector3(px, py, 0.0)
	me.scale = Vector3(1.0 + squash * 0.3, 1.0 - squash * 0.3, 1.0)
	# 흐릴 땐 살짝 일렁인다
	var wob := sin(anim * 30.0) * 0.06 if phased else 0.0
	body.scale = Vector3(BW + wob, BH - wob, 0.7)
	eye.position = Vector3(face * BW * 0.25, BH * 0.7, 0.36)
	for it in pick:
		var st: MeshInstance3D = it[0]
		st.rotation.y = anim * 2.5
		st.position.y = (it[1] as Rect2).position.y + 0.6 + sin(anim * 3.0) * 0.12
	for cb in clouds:
		cb.position.x += dt * 0.8
		if cb.position.x > cols + 10.0:
			cb.position.x = -10.0
	for gb in gusts:
		var fc := floori(gb.position.x)
		if fan_cols.has(fc):
			var fr: Vector2 = fan_cols[fc]
			gb.position.y += dt * 9.0
			if gb.position.y > fr.y:
				gb.position.y = fr.x
	for i in bits.size():
		if bit_l[i] > 0.0:
			bit_l[i] -= dt
			bit_v[i].y -= 30.0 * dt
			bits[i].position += bit_v[i] * dt
			bits[i].rotation.z += dt * 9.0
			if bit_l[i] <= 0.0:
				bits[i].visible = false
	# 흐린 동안 남는 잔상
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.035
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = phased and die_t <= 0.0
		tb.position = Vector3(px, py + BH * 0.5, -0.3)
		tb.scale = Vector3(BW, BH, 0.4)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	wind_t -= dt
	if wind_t <= 0.0 and absf(vx) > 14.0 and die_t <= 0.0:
		wind_t = 0.045
		var wb := winds[wind_k]
		wind_k = (wind_k + 1) % winds.size()
		wb.visible = true
		wb.position = Vector3(px + signf(vx) * randf_range(0.5, 3.5), py + randf_range(0.1, 1.5), 0.9)
		wb.scale = Vector3(1.0 + absf(vx) * 0.06, 0.07, 0.07)
	for wb in winds:
		if wb.visible:
			wb.scale.x -= dt * 7.0
			if wb.scale.x <= 0.05:
				wb.visible = false
	var k := 1.0 - exp(-9.0 * dt)
	# 앞이 보이게: 달리는 쪽으로 더 앞서 보고, 조금 멀리서 본다 (유리·단추·제동 공간이 한 화면에)
	cam_x = lerpf(cam_x, px + vx * 0.14, k)
	cam_y = lerpf(cam_y, py + minf(vy, 0.0) * 0.06, k)
	shake = maxf(0.0, shake - dt * 1.5)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.8
	cam.position = Vector3(cam_x + off.x, cam_y + 3.2 + off.y, 19.0)
	cam.rotation = Vector3.ZERO
	cam.fov = lerpf(cam.fov, 58.0 + minf(Vector2(vx, vy).length(), 40.0) * 0.28, k)


## 오른쪽 위 작은 지도: 가 본 방은 채우고, 이어진 안 가 본 방은 테두리만
func _map_draw(c: Control) -> void:
	var mn := Vector2(INF, INF)
	var mxv := Vector2(-INF, -INF)
	for rm in ROOMS:
		var p: Rect2 = rm.pos
		mn = mn.min(p.position)
		mxv = mxv.max(p.end)
	var span := mxv - mn
	var sc := minf(250.0 / span.x, 110.0 / span.y)
	var ox := 700.0 - span.x * sc
	var oy := 246.0
	c.draw_rect(Rect2(ox - 10, oy - 8, span.x * sc + 18, span.y * sc + 52), Color(1, 1, 1, 0.78))
	var known := {}
	for i in visited:
		for l in links:
			if i in links[l]:
				for j in links[l]:
					known[j] = true
	for i in ROOMS.size():
		var p: Rect2 = ROOMS[i].pos
		var rr := Rect2(ox + (p.position.x - mn.x) * sc + 1, oy + (mxv.y - p.end.y) * sc + 1, p.size.x * sc - 2, p.size.y * sc - 2)
		if visited.has(i):
			var col: Color = PALS[ROOMS[i].pal].wall
			if i == lv:
				col = (GLASS if phased else ME).lerp(WHITE, 0.25 + 0.2 * sin(anim * 6.0))
			c.draw_rect(rr, col)
			c.draw_rect(rr, INK, false, 2.0)
		elif known.has(i):
			c.draw_rect(rr, Color(INK, 0.35), false, 2.0)
	for key in got:
		var parts: PackedStringArray = String(key).split(":")
		var p: Rect2 = ROOMS[int(parts[0])].pos
		c.draw_circle(Vector2(ox + (p.get_center().x - mn.x) * sc, oy + (mxv.y - p.get_center().y) * sc), 5.0, D)
	var nl := 0
	for b in learned:
		if b:
			nl += 1
	c.draw_string(_font, Vector2(ox - 4, oy + span.y * sc + 34), "알아낸 것 %d/4  별 %d/%d" % [nl, got.size(), NSTAR], HORIZONTAL_ALIGNMENT_LEFT, -1, 26, INK)
