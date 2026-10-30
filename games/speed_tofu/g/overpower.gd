extends Tofu
## 너무 센 몸 (옆모습 메트로브레이니아): 왼쪽 아래 조이스틱으로 좌우(끝까지 밀면 전력 질주), 오른쪽 버튼으로 점프. 방 11개가 갈래로 이어진 지도를 오간다.
## 핵심 규칙: 속도 = 몸의 모양. 빨라질수록 몸 상자가 옆으로 늘어나 납작해지고, 멈추면 가늘고 높다(보이는 상자 = 충돌 상자).
## 능력은 하나도 얻지 않는다. 처음엔 벽처럼 보이는 낮은 틈, 죽을 것 같은 가시 구덩이, 닿지 않을 것 같은 천장 구멍이 막혀 있는데, 몸의 규칙을 알아내면 그게 문이 된다.
## 지식 문 3종: ① 빠르면 납작 → 낮은 틈·가시 천장 통과 ② 길면 걸침 → 가시 구덩이 위를 달려 건넘 ③ 멈추면 가늘다 → 2칸 굴뚝 아래 멈춰 뛰면 위층. 별 3개, 맨 위 초록 문이 끝.
# 한 문장: 나는 너무 센 몸으로서 속도가 곧 몸의 모양이 되는 제약 속에서 이어진 방들을 오가며 몸의 규칙을 깨달아 막힌 길을 열지만, 빨라질수록 길고 납작해져 틈에 걸리고 느려지면 낮은 길에 끼이는 대가를 감수한다.

const GRAV := 45.0
const JUMP_V := 24.0  # 꼭대기까지 6칸 넘게: 거의 모든 방에서 천장에 박는다 (굴뚝만 빼고)
const SPRINT := 26.0  # 스틱을 0.7 넘게 밀면 이 속도 (몸이 납작해지는 유일한 달리기)
const JOG := 14.0
const STICK_RUN := 0.7
const GROUND_ACC := 90.0
const AIR_ACC := 30.0
const FRICTION := 35.0
const MAX_FALL := 30.0
const BONK_CAP := 34.0
const SLAM_V := 12.0
const VMAX := 30.0
const W0 := 0.9  # 서 있을 때 몸: 0.9 x 1.8
const W1 := 2.7  # 최고속 몸: 2.7 x 0.72
const H0 := 1.8
const H1 := 0.72
const EPS := 0.0001
const UP_BOOST := 18.0  # 아래 구멍으로 위 방에 들어설 때 솟는 속도
# 구역 색 (밝게): 벽, 윗면 띠, 먼 실루엣, 하늘
const PALS := [
	{"wall": Color("d9c39a"), "trim": Color("8fcf6b"), "far": Color("c4daf0"), "sky": Color("d8eeff")},
	{"wall": Color("e6bd8f"), "trim": Color("f08c5a"), "far": Color("ecd3f2"), "sky": Color("fdebd8")},
	{"wall": Color("eeb09a"), "trim": Color("ffd25e"), "far": Color("f7d3c6"), "sky": Color("fff0e6")},
	{"wall": Color("b9db92"), "trim": Color("52b96a"), "far": Color("cbead2"), "sky": Color("e4f8e8")},
	{"wall": Color("cdbdf0"), "trim": Color("fcc419"), "far": Color("ddd6f6"), "sky": Color("efebff")},
]
# 방: 위 줄부터. # 벽, ^ 가시, S 시작, D 끝 문, * 별, 소문자 = 출구(같은 글자를 가진 다른 방으로 이어진다).
# 몸은 서면 2칸 가까이 크고 질주하면 1칸보다 납작, 2칸보다 길다.
# 1칸 높이 틈 = 질주해야 통과. 2칸 구덩이 = 질주하면 걸쳐 건넘. 2칸 굴뚝 = 멈춰서 뛰어야 올라감.
const ROOMS := [
	{"name": "마당", "pal": 0, "pos": Rect2(0, 0, 3, 3), "map": [
		"############################",
		"############################",
		"#                          #",
		"#                          #",
		"k                          c",
		"k                          c",
		"############  ##############",
		"############  ##############",
		"####                       #",
		"####                       a",
		"b     S                    a",
		"############################",
	]},
	{"name": "구멍 길", "pal": 1, "pos": Rect2(3, 0, 4, 1), "map": [
		"##################################",
		"#                                #",
		"#                                #",
		"a                                e",
		"a                                e",
		"#####  ######  ######  ######  ###",
		"#####  ######^^######^^######^^###",
		"#####dd###########################",
	]},
	{"name": "아래 굴", "pal": 1, "pos": Rect2(3, -1, 4, 1), "map": [
		"###dd###########################",
		"#                     ##########",
		"#                     ##########",
		"#                     ##########",
		"#                     ##########",
		"#                     #######  f",
		"#                              f",
		"################################",
	]},
	{"name": "가시 다리", "pal": 1, "pos": Rect2(7, 0, 5, 1), "map": [
		"###########jj###########################",
		"###########  ###########################",
		"###########  ###########################",
		"e                                      #",
		"e                                      #",
		"####                                   #",
		"f                                      g",
		"f                                      g",
		"########  ######  ####  ####  ####  ####",
		"################^^####^^####^^####^^####",
	]},
	{"name": "굴뚝", "pal": 2, "pos": Rect2(12, 0, 2, 3), "map": [
		"########################",
		"#                      #",
		"#                      #",
		"i                      #",
		"i                      #",
		"#####################  #",
		"#####################  #",
		"#                      #",
		"g                      #",
		"g                      #",
		"########################",
	]},
	{"name": "지붕 길", "pal": 2, "pos": Rect2(3, 2, 9, 1), "map": [
		"####################################",
		"##################        ##########",
		"##################        ##########",
		"##################      * ##########",
		"#####################  #############",
		"#####################  #############",
		"#                                  #",
		"c                                  i",
		"c                                  i",
		"########  ####  ##########  ########",
		"########^^####^^##########^^########",
	]},
	{"name": "낮은 정원", "pal": 3, "pos": Rect2(-4, 0, 4, 1), "map": [
		"########################################",
		"#               ##########        ######",
		"#               ##########        ######",
		"#               ##########        ######",
		"h               ^^^^^^^^^^        ######",
		"h                                      b",
		"#######  ##  ###########################",
		"#######^^##^^###########################",
	]},
	{"name": "별 정원", "pal": 3, "pos": Rect2(-6, 0, 2, 1), "map": [
		"################",
		"#              #",
		"#              #",
		"#              h",
		"#     *        h",
		"################",
		"################",
	]},
	{"name": "높은 탑", "pal": 4, "pos": Rect2(-4, 1, 4, 2), "map": [
		"####################################",
		"#          ##############          #",
		"#          ##############          #",
		"#          ^^^^^^^^^^^^^^          m",
		"#                                  m",
		"#  #################################",
		"#  #################################",
		"#       ###########                #",
		"#       ###########                k",
		"#                                  k",
		"######################  ###  #######",
		"######################^^###^^#######",
	]},
	{"name": "숨은 다락", "pal": 2, "pos": Rect2(8, 1, 2, 1), "map": [
		"##############",
		"#            #",
		"#            #",
		"#            #",
		"#            #",
		"#            #",
		"#  *         #",
		"######jj######",
	]},
	{"name": "꼭대기 문", "pal": 4, "pos": Rect2(0, 3, 3, 1), "map": [
		"########################",
		"#                      #",
		"#                      #",
		"m                      #",
		"m                   D  #",
		"########  ####  ########",
		"########^^####^^########",
	]},
]
const LEARN_MSG := ["빠르면 납작!", "길면 걸친다!", "멈추면 솟는다!"]


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
var bw := W0
var bh := H0
var flat := false
var on_floor := false
var coyote := 0.0
var jbuf := 0.0
var cut := true
var stun := 0.0
var hang := 0.0
var face := 1.0
var die_t := 0.0
var clear_t := 0.0
var shake := 0.0
var squash := 0.0
var step_t := 0.0
var anim := 0.0
var cam_x := 0.0
var cam_y := 0.0
var trail_t := 0.0
var trail_k := 0
var gate_t := 0.0
var jump_y := 0.0
var check_pt := Vector2.ZERO
var visited := {}
var got := {}  # 먹은 별 "방:칸:줄"
var learned := [false, false, false]
var links := {}  # 출구 글자 -> 방 번호들
var env: Environment
var mapc: _Map
var me: Node3D
var body: MeshInstance3D
var eye: MeshInstance3D
var stars: Array[MeshInstance3D] = []
var trail: Array[MeshInstance3D] = []
var pick: Array = []  # [상자, 칸 Rect2, 열쇠]
var clouds: Array[MeshInstance3D] = []
var bits: Array[MeshInstance3D] = []
var bit_v: Array[Vector3] = []
var bit_l: Array[float] = []
var bit_k := 0
var winds: Array[MeshInstance3D] = []
var wind_t := 0.0
var wind_k := 0


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 58.0
	howto = "조이스틱으로 좌우, 끝까지 밀면 질주. 오른쪽 버튼은 점프(늘 천장에 쾅).\n빨라지면 몸이 길고 납작해지고, 멈추면 가늘고 높다. 이 몸의 규칙을 알아내면 막혀 보이던 낮은 틈·가시 구덩이·천장 구멍이 길이 된다.\n방들은 갈래로 이어져 있다(오른쪽 위 지도). 별 3개를 찾고 맨 위 초록 문으로. 가시·구덩이, 낮은 틈 안에서 느려지면 죽는다."
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
	learned = [false, false, false]
	mapc.visible = true
	_build(0)
	for r in rows:
		var k := grid[r].find("S")
		if k >= 0:
			check_pt = Vector2(k + 0.5, rows - 1 - r)
	_place(check_pt)
	msg("마당", 1.2)
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
	var rng := RandomNumberGenerator.new()
	rng.seed = i * 977 + 13
	# 먼 실루엣 (산·탑 상자) — 구역 색, 아주 밝게
	for k in 10:
		var w := rng.randf_range(3.0, 7.0)
		var hh := rng.randf_range(10.0, 26.0)
		var x := rng.randf_range(-14.0, cols + 14.0)
		box(Vector3(x, -16.0 + hh * 0.5, -26.0 - k * 0.8), Vector3(w, hh, 1.0), pal.far if k % 2 == 0 else pal.far.lightened(0.3), stage)
	# 흘러가는 구름
	clouds.clear()
	for k in 4:
		var cb := box(Vector3(rng.randf_range(-6.0, cols + 6.0), rows + rng.randf_range(1.0, 7.0), -8.0), Vector3(rng.randf_range(2.5, 4.5), 0.9, 1.0), WHITE, stage)
		clouds.append(cb)
	for r in rows:
		var yy := rows - 1 - r
		var line := grid[r]
		var run0 := -1
		var top0 := -1
		for c in cols + 1:
			var ch := line[c] if c < cols else " "
			# 윗면 띠: 위가 비어 있는 벽 칸
			var topped := ch == "#" and yy + 1 < rows and not _solid(c, yy + 1)
			if topped and top0 < 0:
				top0 = c
			elif not topped and top0 >= 0:
				box(Vector3((top0 + c) * 0.5, yy + 0.93, 0.0), Vector3(c - top0, 0.16, 2.08), pal.trim, stage)
				top0 = -1
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
	# 바닥 눈금 (속도감 단서)
	for r in rows:
		var yy := rows - 1 - r
		for c in cols:
			if (c % 2 == 0) and _solid(c, yy) and yy + 1 < rows and _ch(c, yy + 1) == " ":
				box(Vector3(c + 0.5, yy + 0.8, 1.06), Vector3(0.14, 0.26, 0.06), SOFT, stage)
	# 나
	me = Node3D.new()
	stage.add_child(me)
	body = box(Vector3(0, H0 * 0.5, 0), Vector3(W0, H0, 0.7), ME, me)
	eye = box(Vector3(0.2, H0 * 0.68, 0.36), Vector3(0.16, 0.16, 0.05), WHITE, me)
	stars.clear()
	for k in 2:
		var s := box(Vector3.ZERO, Vector3(0.2, 0.2, 0.2), D, me)
		s.visible = false
		stars.append(s)
	trail.clear()
	for k in 6:
		var tb := box(Vector3.ZERO, Vector3(W0, H0, 0.4), B, stage)
		tb.visible = false
		trail.append(tb)
	# 파편 (착지·충돌 순간, 돌려 쓴다)
	bits.clear()
	bit_v.clear()
	bit_l.clear()
	for k in 12:
		var b := box(Vector3.ZERO, Vector3(0.22, 0.22, 0.22), pal.trim, stage)
		b.visible = false
		bits.append(b)
		bit_v.append(Vector3.ZERO)
		bit_l.append(0.0)
	# 바람 줄 (빠를 때)
	winds.clear()
	for k in 7:
		var wb := box(Vector3.ZERO, Vector3(1.6, 0.07, 0.07), WHITE, stage)
		wb.visible = false
		winds.append(wb)


func _place(p: Vector2) -> void:
	px = p.x
	py = p.y
	vx = 0.0
	vy = 0.0
	bw = W0
	bh = H0
	flat = false
	on_floor = true
	coyote = 0.0
	jbuf = 0.0
	cut = true
	stun = 0.0
	hang = 0.0
	die_t = 0.0
	clear_t = 0.0
	squash = 0.0
	gate_t = 0.3
	jump_y = py
	cam_x = px
	cam_y = py


## 출구 글자로 다음 방에 들어간다 (속도·몸 모양은 그대로)
func _go(letter: String) -> void:
	var to := -1
	for j in links.get(letter, []):
		if j != lv:
			to = j
	if to < 0:
		return
	var kvx := vx
	var kvy := vy
	var kw := bw
	var kh := bh
	var rose := false
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
		px = 1.0 + kw * 0.5 + 0.02
		py = y0
	elif c1 == cols - 1:
		px = cols - 1.0 - kw * 0.5 - 0.02
		py = y0
	elif y1 == rows - 1:
		px = (c0 + c1 + 1) * 0.5
		py = rows - 1.0 - kh - 0.02
	else:
		px = (c0 + c1 + 1) * 0.5
		py = 1.0
		kvy = maxf(kvy, UP_BOOST)
		rose = true
	vx = kvx
	vy = kvy
	bw = kw
	bh = kh
	gate_t = 0.3
	jump_y = py
	cam_x = px
	cam_y = py
	check_pt = _safe_near(px, py)
	if not visited.has(to):
		visited[to] = true
		beep(660.0, 0.12, 990.0, 0.2)
	_score()
	beep(500.0, 0.06, 800.0, 0.14)
	msg(ROOMS[to].name, 1.0)
	if rose:
		_learn(2)  # 아래 구멍으로 솟아 올라왔다 = 멈춰서 뛰면 가늘게 솟는다


## 서서 다시 시작해도 안전한 가장 가까운 자리 (낮은 틈 안이면 밖으로)
func _safe_near(x: float, y: float) -> Vector2:
	var best := Vector2(x, y)
	var bd := INF
	for yy in range(1, rows - 1):
		for c in range(1, cols - 1):
			if not _solid(c, yy - 1):
				continue
			var ok := true
			for k in 2:
				var ch := _ch(c, yy + k)
				if ch != " " and ch != "S" and ch != "*":
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


func _solid(c: int, yy: int) -> bool:
	return _ch(c, yy) == "#"


func _x0() -> int:
	return floori(px - bw * 0.5 + EPS)


func _x1() -> int:
	return floori(px + bw * 0.5 - EPS)


func _y0() -> int:
	return floori(py + EPS)


func _y1() -> int:
	return floori(py + bh - EPS)


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
	_control(h)
	_shape(h)
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
	stun -= h
	squash = maxf(0.0, squash - h * 4.0)
	if mx != 0.0 and stun <= 0.0:
		face = signf(mx)
	if stun <= 0.0:
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
				vx = move_toward(vx, target, GROUND_ACC * h)
		elif mx != 0.0 and not too_fast:
			vx = move_toward(vx, target, AIR_ACC * h)
	elif on_floor:
		vx = move_toward(vx, 0.0, FRICTION * h)
	if jbuf > 0.0 and stun <= 0.0 and (on_floor or coyote > 0.0):
		_jump()
	if not cut and vy > 0.0 and not kit_held("jump"):
		vy *= 0.93
		cut = true


func _jump() -> void:
	vy = JUMP_V
	on_floor = false
	coyote = 0.0
	jbuf = 0.0
	cut = false
	jump_y = py
	beep(420.0, 0.1, 1000.0, 0.24)


## 속도 = 몸의 모양. 빠를수록 옆으로 길고 납작. 새 모양이 벽에 겹치면 옆은 밀려나고 머리가 박히면 끼인다.
func _shape(h: float) -> void:
	var s := clampf(absf(vx) / VMAX, 0.0, 1.0)
	var tw := lerpf(W0, W1, pow(s, 1.5))
	var th := lerpf(H0, H1, s)
	var k := 1.0 - exp(-30.0 * h)
	bw = lerpf(bw, tw, k)
	bh = lerpf(bh, th, k)
	var now := bh < 1.0
	if now != flat:
		flat = now
		if flat:
			beep(500.0, 0.1, 1100.0, 0.22)
		else:
			beep(1100.0, 0.1, 500.0, 0.18)
	var y0 := _y0()
	var y1 := _y1()
	if _col_solid(_x0(), y0, y1):
		px = _x0() + 1.0 + bw * 0.5 + 0.001
		if _col_solid(_x1(), y0, y1):
			_die("끼임")
			return
	elif _col_solid(_x1(), y0, y1):
		px = _x1() - bw * 0.5 - 0.001
		if _col_solid(_x0(), y0, y1):
			_die("끼임")
			return
	for c in range(_x0(), _x1() + 1):
		if _solid(c, y1):
			_die("끼임")
			return


func _physics(h: float) -> void:
	var fall := vy
	if hang > 0.0:
		hang -= h
		vy = 0.0
	else:
		vy = maxf(vy - GRAV * h, -MAX_FALL)
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
			if fall < -12.0:
				_burst(Vector3(px, py, 0.6), 4, 1.0)
			# 지식 ③: 멈춰서 뛰어 굴뚝 위층에 섰다
			if py - jump_y >= 3.5:
				_learn(2)
			jump_y = py


func _move_x(d: float) -> void:
	if d == 0.0:
		return
	px += d
	var c := _x1() if d > 0.0 else _x0()
	if not _col_solid(c, _y0(), _y1()):
		return
	px = c - bw * 0.5 - 0.001 if d > 0.0 else c + 1.0 + bw * 0.5 + 0.001
	_wall_hit(signf(d))


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
		py = r - bh - 0.001
		_bonk()
	else:
		py = r + 1.0
		vy = 0.0


func _bonk() -> void:
	var sp := vy
	vy = 0.0
	if sp < 3.0:
		return
	hang = 0.08
	stun = 0.18
	shake = maxf(shake, 0.3)
	squash = 0.7
	if absf(vx) > 8.0:
		vx = signf(vx) * maxf(absf(vx), minf(absf(vx) * 1.35 + 4.0, BONK_CAP))
	_burst(Vector3(px, py + bh, 0.6), 3, -1.0)
	msg("쾅!", 0.35)
	beep(200.0, 0.14, 60.0, 0.45)
	beep(1300.0, 0.05, 700.0, 0.2)


func _wall_hit(dir: float) -> void:
	var sp := absf(vx)
	if sp > SLAM_V:
		stun = 0.3
		shake = maxf(shake, 0.3 + sp / 120.0)
		squash = 0.6
		vx = -dir * sp * 0.25
		_burst(Vector3(px + dir * bw * 0.5, py + bh * 0.5, 0.6), 5, 0.0)
		msg("꽝!", 0.35)
		beep(110.0, 0.2, 45.0, 0.45)
		beep(800.0, 0.04, 0.0, 0.2)
	else:
		vx = 0.0


func _check() -> void:
	if die_t > 0.0:
		return
	var r := Rect2(px - bw * 0.5, py, bw, bh)
	if py < -2.0:
		_die("떨어짐")
		return
	# 출구: 몸이 출구 글자 칸에 닿으면 이어진 방으로
	if gate_t <= 0.0:
		for c in range(_x0(), _x1() + 1):
			for yy in range(_y0(), _y1() + 1):
				var ch := _ch(c, yy)
				if ch >= "a" and ch <= "z" and ch.length() == 1:
					_go(ch)
					return
	for c in range(floori(r.position.x), floori(r.end.x) + 1):
		for yy in range(floori(py), floori(py + bh) + 1):
			if _ch(c, yy) == "^" and Rect2(c + 0.15, yy + 0.15, 0.7, 0.7).intersects(r):
				_die("가시")
				return
	for k in range(pick.size() - 1, -1, -1):
		var it: Array = pick[k]
		if (it[1] as Rect2).intersects(r):
			got[it[2]] = true
			(it[0] as MeshInstance3D).visible = false
			pick.remove_at(k)
			_burst(Vector3(px, py + bh, 0.6), 6, 1.0)
			play("good")
			msg("별 %d/3" % got.size(), 1.0)
			_score()
	# 지식 ①: 납작해서 낮은 틈·가시 천장 아래를 지나는 중
	var cc := floori(px)
	var above := _ch(cc, _y0() + 1)
	if bh < 1.0 and (above == "#" or above == "^") and not _solid(cc, _y0()):
		_learn(0)
	# 지식 ②: 긴 몸이 구덩이 위에 걸쳐 서 있다
	if on_floor and not _solid(cc, floori(py - 0.02)) and _solid(_x0(), floori(py - 0.02)) and _solid(_x1(), floori(py - 0.02)) and absf(vx) > 15.0:
		_learn(1)
	if has_door and door.intersects(r):
		clear_t = 1.2
		vx = 0.0
		vy = 0.0
		play("win")
		msg("탈출!", 1.2)
		score += 10


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
	_burst(Vector3(px, py + bh * 0.5, 0.6), 8, 1.0)
	play("bad")
	msg(why, 0.9)


func _sounds(h: float) -> void:
	step_t -= h
	if on_floor and absf(vx) > 3.0 and step_t <= 0.0:
		step_t = clampf(2.2 / absf(vx), 0.05, 0.3)
		beep(120.0 + absf(vx) * 8.0, 0.03, 0.0, 0.1)


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
	body.scale = Vector3(bw, bh, 0.7)
	body.position.y = bh * 0.5
	eye.position = Vector3(face * bw * 0.3, bh * 0.68, 0.36)
	eye.scale = Vector3(0.16, minf(0.16, bh * 0.2), 0.05)
	for k in stars.size():
		stars[k].visible = stun > 0.0 and die_t <= 0.0
		var a := anim * 14.0 + k * PI
		stars[k].position = Vector3(cos(a) * 0.45, bh + 0.3, sin(a) * 0.45)
	for it in pick:
		var st: MeshInstance3D = it[0]
		st.rotation.y = anim * 2.5
		st.position.y = (it[1] as Rect2).position.y + 0.6 + sin(anim * 3.0) * 0.12
	for cb in clouds:
		cb.position.x += dt * 0.8
		if cb.position.x > cols + 10.0:
			cb.position.x = -10.0
	for i in bits.size():
		if bit_l[i] > 0.0:
			bit_l[i] -= dt
			bit_v[i].y -= 30.0 * dt
			bits[i].position += bit_v[i] * dt
			bits[i].rotation.z += dt * 9.0
			if bit_l[i] <= 0.0:
				bits[i].visible = false
	# 빠를 때 남는 잔상 (늘어난 몸 모양 그대로)
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.03
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = Vector2(vx, vy).length() > 14.0 and die_t <= 0.0
		tb.position = Vector3(px, py + bh * 0.5, -0.3)
		tb.scale = Vector3(bw, bh, 0.4)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	# 바람 줄: 몸 앞뒤로 멈춰 있는 가는 상자, 빠를수록 많이
	wind_t -= dt
	if wind_t <= 0.0 and absf(vx) > 16.0 and die_t <= 0.0:
		wind_t = 0.045
		var wb := winds[wind_k]
		wind_k = (wind_k + 1) % winds.size()
		wb.visible = true
		wb.position = Vector3(px + signf(vx) * randf_range(0.5, 3.5), py + randf_range(0.1, 1.6), 0.9)
		wb.scale = Vector3(1.0 + absf(vx) * 0.06, 0.07, 0.07)
	for wb in winds:
		if wb.visible:
			wb.scale.x -= dt * 7.0
			if wb.scale.x <= 0.05:
				wb.visible = false
	var k := 1.0 - exp(-9.0 * dt)
	cam_x = lerpf(cam_x, px + vx * 0.08, k)
	cam_y = lerpf(cam_y, py, k)
	shake = maxf(0.0, shake - dt * 1.5)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.8
	cam.position = Vector3(cam_x + off.x, cam_y + 3.6 + off.y, 17.0)  # 몸이 화면 가운데 아래, 위쪽 굴뚝·틈이 보이게
	cam.rotation = Vector3.ZERO
	cam.fov = lerpf(cam.fov, 56.0 + minf(Vector2(vx, vy).length(), 44.0) * 0.25, k)


## 오른쪽 위 작은 지도: 가 본 방은 채우고, 이어진 안 가 본 방은 점선 테두리만
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
				col = ME.lerp(WHITE, 0.25 + 0.2 * sin(anim * 6.0))
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
	c.draw_string(_font, Vector2(ox - 4, oy + span.y * sc + 34), "알아낸 것 %d/3  별 %d/3" % [nl, got.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 26, INK)
