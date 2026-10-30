extends Tofu
## 폭탄 애벌레 v2 (옆모습): 놓기 = 등 뒤 1칸에 폭탄(놓고 바로 쾅 = 앞으로 뛰기), 가까울수록 높고 세게(점선 = 지금 쾅 하면 날 길). 주황 금 간 발판과 지뢰는 기어야(느려야) 지난다. 왼쪽 조이스틱으로 느리게 긴다(점프 없음). 오른쪽 "놓기"로 발밑에 폭탄, "쾅"으로 터뜨리면 폭탄 반대쪽으로 날아간다. 속도는 폭탄에서만 나온다.
## 땅에서 폭탄 0.7칸 안이면 직격 사망, 공중 폭탄은 안전하지만 약하다(비행당 1개, 연쇄). 방마다 속도 규칙 실험: 1 기본, 2 속도=몸 늘어남, 3 탭 워프=속도 보존, 4 블럭 설치=벽차기, 5 섞임.
# 한 문장: 나는 점프를 못 하는 폭탄 애벌레로서 속도를 폭탄 폭발로만 얻는 제약 속에서 폭탄을 놓고 떨어져 터뜨려 다음 방 문에 닿지만, 가까울수록 세게 날지만 0.7칸 안이면 터져 죽고 한번 얻은 속도는 벽·가시·틈이 그대로 받아 내는 대가를 감수한다.

const GRAV := 40.0
const MAX_FALL := 28.0
const CRAWL := 2.5  # 기는 속도. 이보다 빠르면 전부 폭탄이 준 속도(미끄러짐)
const CRAWL_ACC := 20.0
const BRAKE := 14.0  # 미끄러지는 반대쪽으로 스틱
const FRICTION := 10.0  # 땅에서 미끄러질 때
const AIR_DRAG := 0.8
const BLAST := 24.0  # 땅에서 터뜨릴 때 최대 충격
const AIR_BLAST := 14.0  # 공중에서 터뜨릴 때
const RADIUS := 3.0  # 이 밖은 안 밀린다
const KILL_R := 0.7  # 땅에서 이 안은 직격
const CRASH_V := 8.0  # 이 속도 이상으로 벽에 닿으면 꽝(기절·되튕김)
const KICK_V := 6.0  # 자기 블럭은 이 속도 이상이면 벽차기
const VMAX := 16.0  # 몸이 끝까지 늘어나는 속도 (방2·5)
const W0 := 0.8  # 느릴 때 몸: 0.8 x 1.3 (몸을 세운 애벌레)
const H0 := 1.3
const W1 := 2.6  # 빠를 때: 2.6 x 0.45
const H1 := 0.45
const WARP_RANGE := 6.5
const EPS := 0.0001
const WALLC := Color("d9c39a")
const SAFE_V := 3.2  # 이 아래(기는 속도)면 금 간 발판이 버티고 지뢰가 안 터진다
const NDOT := 10
# 방: 위 줄부터. # 벽, ^ 가시, S 시작, D 문(2칸), = 금 간 발판(빠르면 무너짐), * 지뢰(빠르면 터짐). stretch 몸 늘어남, warp 탭 워프, block 블럭 버튼.
const ROOMS := [
	{"name": "느려야 사는 길", "stretch": false, "warp": 0, "block": 0, "map": [
		"#########################################",
		"#              ############      ########",
		"#              ############      ########",
		"#              ############      ########",
		"#              ############             #",
		"#                                       #",
		"#                       * *          * D#",
		"#     #########========#######   ########",
		"# S   #########^^^^^^^^#######^^^########",
		"#########################################",
	]},
	{"name": "납작: 속도가 몸을 늘인다", "stretch": true, "warp": 0, "block": 0, "map": [
		"######################",
		"#                    #",
		"#       ######       #",
		"#       ######       #",
		"# S                  #",
		"################## ###",
		"################## ###",
		"################## ###",
		"#                    #",
		"#  D                 #",
		"######################",
	]},
	{"name": "워프: 속도는 남는다", "stretch": false, "warp": 3, "block": 0, "map": [
		"##########################",
		"#                        #",
		"#                 ##     #",
		"#                 ##     #",
		"#                 ##     #",
		"# S               ##  D  #",
		"#####          #####  ####",
		"#####^^^^^^^^^^#####^^####",
		"##########################",
	]},
	{"name": "블럭: 벽차기 발판", "stretch": false, "warp": 0, "block": 2, "map": [
		"####################",
		"#########          #",
		"#########D         #",
		"#########          #",
		"#########  #########",
		"#########  #########",
		"#          #########",
		"#          #########",
		"# S        #########",
		"####################",
	]},
	{"name": "전부 섞어", "stretch": true, "warp": 3, "block": 2, "map": [
		"##############################",
		"#                            #",
		"#                          D #",
		"#                       ######",
		"#                       ######",
		"#    #######            ######",
		"#    #######            ######",
		"#    #######            ######",
		"#    #######            ######",
		"# S          ^^^^^^     ######",
		"##############################",
	]},
]

var lv := 0
var stage: Node3D
var grid: Array[String] = []
var rows := 0
var cols := 0
var door := Rect2()
var rule_s := false
var rule_w := 0
var rule_b := 0
var px := 0.0  # 발 가운데
var py := 0.0
var vx := 0.0
var vy := 0.0
var bw := W0
var bh := H0
var flat := false
var on_floor := false
var crawling := false
var stun := 0.0
var face := 1.0
var die_t := 0.0
var clear_t := 0.0
var shake := 0.0
var squash := 0.0
var anim := 0.0
var step_t := 0.0
var cam_x := 0.0
var cam_y := 0.0
var trail_t := 0.0
var trail_k := 0
var air_used := false  # 이번 비행에 공중 폭탄을 썼다
var warps := 0
var blocks_left := 0
var blocks := {}  # Vector2i -> MeshInstance3D (내가 놓은 블럭)
var bomb := {"live": false, "x": 0.0, "y": 0.0, "vx": 0.0, "vy": 0.0, "rest": false}
var flash_t := 0.0
var me: Node3D
var body: MeshInstance3D
var head: MeshInstance3D
var eye: MeshInstance3D
var bomb_n: MeshInstance3D
var flash_n: MeshInstance3D
var block_n: Array[MeshInstance3D] = []
var trail: Array[MeshInstance3D] = []
var crumbs := {}  # Vector2i -> MeshInstance3D (금 간 발판)
var mines := {}  # Vector2i -> [몸, 등]
var dots: Array[MeshInstance3D] = []
var creak_t := 0.0
var tips := {}


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 58.0
	howto = "왼쪽 조이스틱으로 느리게 긴다. 놓기 = 등 뒤에 폭탄, 쾅 = 터뜨리기 → 폭탄 반대쪽으로 날아간다(점선이 날 길).\n가까울수록 높고 세게, 멀수록 낮고 짧게. 땅에서 0.7칸 안이면 직격 사망. 공중 폭탄은 약하고 비행당 1개.\n주황 금 간 발판·지뢰는 기어서만 지난다(위 게이지가 흰 눈금 아래 = 안전). 빠르면 무너지고 터진다.\n가시·추락·끼임이면 그 방부터. 초록 문에 닿으면 다음 방."
	kit_stick()
	kit_button("drop", "놓기", Vector2(440, 1165), 80.0, B)  # 판정 원이 '쾅'과 안 겹치게 (예전엔 겹쳐 쾅이 놓기로 잡혔다)
	kit_button("boom", "쾅", Vector2(630, 1010), 100.0, A)
	var tk := ColorRect.new()  # 게이지 = 내 속도, 흰 눈금 = 기는 속도(안전)
	tk.color = WHITE
	tk.position = Vector2(600.0 * SAFE_V / VMAX - 3.0, -10.0)
	tk.size = Vector2(6, 48)
	tk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(tk)


func _reset() -> void:
	lv = 0
	stage = null
	_room(0)


func _room(i: int) -> void:
	if stage:
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	var rm: Dictionary = ROOMS[i]
	rule_s = rm.stretch
	rule_w = rm.warp
	rule_b = rm.block
	var m: Array = rm.map
	rows = m.size()
	cols = 0
	for s in m:
		cols = maxi(cols, String(s).length())
	grid.clear()
	for s in m:
		grid.append(String(s).rpad(cols, "#"))
	blocks.clear()
	crumbs.clear()
	mines.clear()
	_btns.erase("block")
	if rule_b > 0:
		kit_button("block", "블럭", Vector2(620, 800), 70.0, C)
	var start := Vector2(2.5, 1.0)
	for r in rows:
		var yy := rows - 1 - r
		var line := grid[r]
		var run0 := -1
		for c in cols + 1:
			var ch := line[c] if c < cols else " "
			if ch == "#":
				if run0 < 0:
					run0 = c
				continue
			if run0 >= 0:
				box(Vector3((run0 + c) * 0.5, yy + 0.5, 0.0), Vector3(c - run0, 1.0, 2.0), WALLC, stage)
				run0 = -1
			if ch == "^":
				var sp := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.55, 0.55, 1.2), BAD, stage)
				sp.rotation.z = PI * 0.25
			elif ch == "S":
				start = Vector2(c + 0.5, yy)
			elif ch == "=":
				var cb := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.96, 1.0, 2.0), A, stage)
				box(Vector3(0.1, 0.0, 0.52), Vector3(0.08, 0.7, 0.04), WHITE, cb)
				crumbs[Vector2i(c, yy)] = cb
			elif ch == "*":
				var mb := box(Vector3(c + 0.5, yy + 0.18, 0.0), Vector3(0.8, 0.36, 1.2), INK, stage)
				var ml := box(Vector3(c + 0.5, yy + 0.45, 0.0), Vector3(0.3, 0.2, 0.3), GOOD, stage)
				mines[Vector2i(c, yy)] = [mb, ml]
			elif ch == "D":
				door = Rect2(c, yy, 1.0, 2.0)
				box(Vector3(c + 0.5, yy + 1.0, -0.6), Vector3(1.1, 2.0, 0.6), GOOD, stage)
				box(Vector3(c + 0.75, yy + 1.0, -0.2), Vector3(0.15, 0.15, 0.2), D, stage)
	# 바닥 눈금 (속도감 단서)
	for r in rows:
		var yy := rows - 1 - r
		for c in cols:
			if (c % 2 == 0) and _wall(c, yy) and not _wall(c, yy + 1) and _ch(c, yy + 1) != "^" and yy + 1 < rows:
				box(Vector3(c + 0.5, yy + 0.86, 1.02), Vector3(0.14, 0.28, 0.06), SOFT, stage)
	# 폭탄·섬광·블럭 (미리 만들어 둔다)
	bomb_n = box(Vector3.ZERO, Vector3(0.4, 0.4, 0.4), INK, stage)
	bomb_n.visible = false
	flash_n = box(Vector3.ZERO, Vector3(1, 1, 1), D, stage)
	flash_n.visible = false
	block_n.clear()
	for k in 2:
		var b := box(Vector3.ZERO, Vector3(1.0, 1.0, 2.0), C, stage)
		b.visible = false
		block_n.append(b)
	# 나
	me = Node3D.new()
	stage.add_child(me)
	body = box(Vector3(0, H0 * 0.5, 0), Vector3(W0, H0, 0.7), ME, me)
	head = box(Vector3(0, H0 * 0.6, 0), Vector3(0.5, 0.5, 0.75), B, me)
	eye = box(Vector3(0, H0 * 0.68, 0.38), Vector3(0.14, 0.14, 0.05), WHITE, me)
	trail.clear()
	for k in 6:
		var tb := box(Vector3.ZERO, Vector3(W0, H0, 0.4), B, stage)
		tb.visible = false
		trail.append(tb)
	dots.clear()
	for k in NDOT:
		var dm := box(Vector3.ZERO, Vector3(0.16, 0.16, 0.16), INK, stage)
		dm.visible = false
		dots.append(dm)
	px = start.x
	py = start.y
	vx = 0.0
	vy = 0.0
	bw = W0
	bh = H0
	flat = false
	on_floor = true
	crawling = false
	stun = 0.0
	face = 1.0
	die_t = 0.0
	clear_t = 0.0
	squash = 0.0
	air_used = false
	warps = rule_w
	blocks_left = rule_b
	bomb.live = false
	bomb.rest = false
	flash_t = 0.0
	cam_x = px
	cam_y = py
	msg("%d. %s" % [i + 1, rm.name], 1.4)


# ---- 칸 ----
func _ch(c: int, yy: int) -> String:
	if c < 0 or c >= cols or yy >= rows:
		return "#"
	if yy < 0:
		return " "
	return grid[rows - 1 - yy][c]


func _wall(c: int, yy: int) -> bool:
	return _ch(c, yy) == "#"


func _solid(c: int, yy: int) -> bool:
	var ch := _ch(c, yy)
	return ch == "#" or ch == "=" or blocks.has(Vector2i(c, yy))


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


func _free_rect(x: float, y: float, w: float, h: float) -> bool:
	if y < 0.0:
		return false
	for c in range(floori(x - w * 0.5 + EPS), floori(x + w * 0.5 - EPS) + 1):
		for yy in range(floori(y + EPS), floori(y + h - EPS) + 1):
			if _solid(c, yy):
				return false
	return true


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	anim += dt
	if die_t > 0.0:
		die_t -= dt
		_view(dt)
		if die_t <= 0.0:
			_room(lv)
		return
	if clear_t > 0.0:
		clear_t -= dt
		_view(dt)
		if clear_t <= 0.0:
			lv += 1
			score = lv
			if lv >= ROOMS.size():
				end()
			else:
				_room(lv)
		return
	_control(h)
	if die_t > 0.0:
		_view(dt)
		return
	if rule_s:
		_shape(h)
	else:
		bw = W0
		bh = H0
	if die_t > 0.0:
		_view(dt)
		return
	_physics(h)
	_bomb_step(h)
	_slow_things(h)
	_check()
	_sounds(h)
	_preview()
	var sp := Vector2(vx, vy).length()
	gauge(sp / VMAX, GOOD if sp <= SAFE_V else BAD)
	_view(dt)


func _control(h: float) -> void:
	var mx := kit_move.x
	if absf(mx) < 0.15:
		mx = 0.0
	stun -= h
	squash = maxf(0.0, squash - h * 4.0)
	crawling = false
	if mx != 0.0 and stun <= 0.0:
		face = signf(mx)
	if on_floor:
		if stun > 0.0 or mx == 0.0:
			vx = move_toward(vx, 0.0, FRICTION * h)
		elif absf(vx) > CRAWL + 0.1:
			if signf(vx) == signf(mx):
				vx = move_toward(vx, signf(mx) * CRAWL, FRICTION * h)
			else:
				vx = move_toward(vx, 0.0, BRAKE * h)
		else:
			vx = move_toward(vx, mx * CRAWL, CRAWL_ACC * h)
			crawling = true
	else:
		vx = move_toward(vx, 0.0, AIR_DRAG * h)
	if stun <= 0.0:
		if kit_just("drop"):
			_drop()
		if kit_just("boom"):
			_boom()
		if kit_just("block"):
			_place_block()


## 발밑(공중이면 몸 가운데)에 폭탄. 한 번에 하나, 공중에서는 비행당 하나.
func _drop() -> void:
	if bomb.live:
		msg("하나뿐", 0.4)
		beep(200.0, 0.06, 0.0, 0.15)
		return
	if not on_floor:
		if air_used:
			msg("공중 1개", 0.4)
			beep(200.0, 0.06, 0.0, 0.15)
			return
		air_used = true
	bomb.live = true
	bomb.rest = on_floor
	bomb.x = px
	bomb.y = py + 0.2 if on_floor else py + bh * 0.5
	if on_floor:  # 땅에서는 등 뒤 1칸: 놓고 바로 쾅 = 앞으로 뛴다 (발밑이면 늘 직격이었다)
		var bx := px - face * 1.0
		if not _solid(floori(bx), floori(py + 0.2)):
			bomb.x = bx
			bomb.rest = _solid(floori(bx), floori(py - 0.2))
	bomb.vx = 0.0 if on_floor else vx  # 공중 폭탄은 나와 같이 가서 늘 바로 밑 = 수직으로 민다
	bomb.vy = 0.0
	bomb_n.visible = true
	bomb_n.position = Vector3(bomb.x, bomb.y, 0.3)
	beep(320.0, 0.06, 0.0, 0.2)


## 터뜨리기: 폭탄 반대쪽으로 날아간다. 가까울수록 세다. 땅에서 0.7 안은 직격.
func _boom() -> void:
	if not bomb.live:
		return
	bomb.live = false
	bomb_n.visible = false
	flash_t = 0.18
	flash_n.visible = true
	flash_n.position = Vector3(bomb.x, bomb.y, 0.4)
	shake = maxf(shake, 0.35)
	beep(90.0, 0.25, 30.0, 0.5)
	beep(900.0, 0.06, 300.0, 0.2)
	var bv := _blast()
	if bv.z == 2.0:
		msg("멀다", 0.5)
		return
	if bv.z == 1.0:
		_die("직격")
		return
	vx = bv.x
	vy = bv.y
	if on_floor:
		on_floor = false
		py += 0.03
	stun = 0.0
	squash = 0.5
	msg("쾅!", 0.3)


## 지금 터뜨리면 내 속도 (x, y, 결과: 0 날아감, 1 직격, 2 멀다)
## 땅: 거리가 각도를 정한다(가까우면 68도 높게, 멀면 22도 낮게). 공중: 예전처럼 폭탄 반대쪽.
func _blast() -> Vector3:
	var c := Vector2(px, py + bh * 0.5)
	var d := c - Vector2(bomb.x, bomb.y)
	var dist := d.length()
	if dist > RADIUS:
		return Vector3(vx, vy, 2.0)
	if on_floor and dist < KILL_R:
		return Vector3(vx, vy, 1.0)
	var dir := Vector2(0.0, 1.0)
	if on_floor:
		var sx := signf(d.x) if absf(d.x) > 0.05 else face
		var ang := deg_to_rad(lerpf(68.0, 22.0, clampf((dist - KILL_R) / (RADIUS - KILL_R), 0.0, 1.0)))
		dir = Vector2(sx * cos(ang), sin(ang))
	elif dist > 0.05:
		dir = (d + Vector2(0.0, 0.1)).normalized()
	var k := clampf(1.2 - dist / RADIUS, 0.25, 1.0)
	var imp := (BLAST if on_floor else AIR_BLAST) * k
	return Vector3(vx + dir.x * imp, maxf(vy, 0.0) + dir.y * imp, 0.0)


## 점선: 지금 쾅 하면 날아갈 길 (벽에 닿는 데서 끊김). 빨강 = 직격
func _preview() -> void:
	var vis: bool = bomb.live and die_t <= 0.0 and clear_t <= 0.0
	var bv := _blast() if vis else Vector3(0, 0, 2)
	if bv.z == 2.0:
		for dm in dots:
			dm.visible = false
		return
	var col := BAD if bv.z == 1.0 else INK
	var hit := false
	for j in NDOT:
		var tt := 0.07 * (j + 1)
		var x := px + bv.x * tt
		var y := py + bh * 0.5 + bv.y * tt - GRAV * 0.5 * tt * tt
		if bv.z == 1.0:
			x = px
			y = py + bh + 0.3 + j * 0.12
		if _solid(floori(x), floori(y)):
			hit = true
		dots[j].visible = not hit
		dots[j].position = Vector3(x, y, 0.6)
		dots[j].material_override = mat(col)


## 느림이 답인 것: 금 간 발판(빠르면 무너짐)과 지뢰(빠르면 터짐). 색이 내 속도를 따라 바뀐다.
func _slow_things(h: float) -> void:
	var sp := Vector2(vx, vy).length()
	var fast := sp > SAFE_V
	var blink := fmod(anim, 0.2) < 0.1
	for key: Vector2i in mines:
		var ml: MeshInstance3D = mines[key][1]
		var near := absf(key.x + 0.5 - px) < 4.0 and absf(key.y - py) < 3.0
		ml.material_override = mat(BAD if fast and near and blink else (D if fast and near else GOOD))
		if near:
			_tip("mine", "지뢰: 빠르면 터진다\n기어서 넘어")
	for key: Vector2i in crumbs:
		var cb: MeshInstance3D = crumbs[key]
		var near := absf(key.x + 0.5 - px) < 3.0 and absf(key.y + 1.0 - py) < 2.0
		cb.material_override = mat(BAD if fast and near else A)
		if near:
			_tip("crumb", "금 간 발판: 기어서만 버틴다")
	creak_t -= h
	if not on_floor:
		return
	var yy := floori(py - 0.02)
	var under: Array[Vector2i] = []
	for c in range(_x0(), _x1() + 1):
		if crumbs.has(Vector2i(c, yy)):
			under.append(Vector2i(c, yy))
	if under.is_empty():
		return
	if absf(vx) > SAFE_V:
		for key in under:
			(crumbs[key] as MeshInstance3D).visible = false
			crumbs.erase(key)
			var r := rows - 1 - key.y
			grid[r] = grid[r].substr(0, key.x) + " " + grid[r].substr(key.x + 1)
		vx *= 0.4
		on_floor = false
		shake = maxf(shake, 0.3)
		beep(120.0, 0.25, 50.0, 0.4)
		msg("와르르! 빨랐다", 0.8)
	elif creak_t <= 0.0 and absf(vx) > 0.3:
		creak_t = 0.4
		beep(380.0, 0.05, 300.0, 0.1)  # 삐걱: 버티는 중
		for key in under:
			(crumbs[key] as MeshInstance3D).position.y = key.y + 0.5 - 0.06


func _tip(key: String, text: String) -> void:
	if tips.has(key):
		return
	tips[key] = true
	msg(text, 1.6)


## 블럭: 바라보는 쪽 한 칸 앞에 2칸 기둥 (방4·5, 일회용 2개). 빠르게 박으면 벽차기.
func _place_block() -> void:
	if rule_b <= 0:
		return
	if blocks_left <= 0:
		msg("블럭 없음", 0.4)
		beep(200.0, 0.06, 0.0, 0.15)
		return
	var cx := floori(px + face * (bw * 0.5 + 0.8))
	var cy := floori(py + 0.1) if on_floor else floori(py + bh * 0.5 - 0.5)
	var ok := cy >= 0
	for yy in range(cy, cy + 2):
		if _ch(cx, yy) != " " or blocks.has(Vector2i(cx, yy)) or door.intersects(Rect2(cx, yy, 1, 1)):
			ok = false
	if ok and Rect2(cx, cy, 1.0, 2.0).intersects(Rect2(px - bw * 0.5, py, bw, bh)):
		ok = false
	if not ok:
		msg("막힘", 0.4)
		beep(200.0, 0.06, 0.0, 0.15)
		return
	blocks_left -= 1
	var n := block_n[blocks_left]
	n.visible = true
	n.position = Vector3(cx + 0.5, cy + 1.0, 0.0)
	blocks[Vector2i(cx, cy)] = n
	blocks[Vector2i(cx, cy + 1)] = n
	beep(500.0, 0.08, 700.0, 0.2)
	msg("블럭 %d" % blocks_left, 0.5)


## 속도 = 몸의 모양 (방2·5). 빠를수록 길고 납작. 새 모양이 벽에 겹치면 밀려나고 양쪽이 막히면 끼인다.
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
			beep(500.0, 0.1, 1100.0, 0.2)
		else:
			beep(1100.0, 0.1, 500.0, 0.16)
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
	vy = maxf(vy - GRAV * h, -MAX_FALL)
	var vy_in := vy
	for i in 4:
		_move_x(vx * h * 0.25)
		_move_y(vy * h * 0.25)
	var was := on_floor
	on_floor = vy <= 0.0 and _ground()
	if on_floor:
		air_used = false
		if not was:
			squash = maxf(squash, 0.35)
			beep(90.0, 0.06, 0.0, 0.2)
			vx *= 0.55  # 착지하면 배로 붙어 미끄러짐이 줄어든다
			if vy_in < -6.0:  # 금 간 발판에 떨어지면 무너진다
				var yy := floori(py - 0.02)
				for c in range(_x0(), _x1() + 1):
					if crumbs.has(Vector2i(c, yy)):
						vx = maxf(absf(vx), SAFE_V + 0.5) * signf(vx if vx != 0.0 else 1.0)


func _move_x(d: float) -> void:
	if d == 0.0:
		return
	px += d
	var c := _x1() if d > 0.0 else _x0()
	var y0 := _y0()
	var y1 := _y1()
	if not _col_solid(c, y0, y1):
		return
	px = c - bw * 0.5 - 0.001 if d > 0.0 else c + 1.0 + bw * 0.5 + 0.001
	var sp := absf(vx)
	# 내가 놓은 블럭에 빠르게 박으면 벽차기: 수평 속도가 수직이 되고 블럭은 부서진다
	for yy in range(y0, y1 + 1):
		var key := Vector2i(c, yy)
		if blocks.has(key):
			if sp >= KICK_V:
				_kick(key, signf(d), sp)
			else:
				vx = 0.0
			return
	_wall_hit(signf(d), sp)


## 벽차기: 수평 속도가 그대로 수직이 된다. 기둥은 부서진다.
func _kick(key: Vector2i, _dir: float, sp: float) -> void:
	var n: MeshInstance3D = blocks[key]
	n.visible = false
	for k in blocks.keys():
		if blocks[k] == n:
			blocks.erase(k)
	vy = maxf(vy, 0.0) + sp
	vx = 0.0
	on_floor = false
	shake = maxf(shake, 0.3)
	squash = 0.6
	msg("차기!", 0.4)
	beep(300.0, 0.1, 900.0, 0.3)
	beep(1200.0, 0.05, 600.0, 0.2)


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
		if vy > 6.0:
			beep(200.0, 0.08, 80.0, 0.3)
			squash = maxf(squash, 0.4)
		vy = 0.0
	else:
		py = r + 1.0
		vy = 0.0


## 벽에 박기: 빠르면 꽝 하고 기절해 되튕긴다 (속도는 내 것이 아니다)
func _wall_hit(dir: float, sp: float) -> void:
	if sp > CRASH_V:
		stun = 0.3
		shake = maxf(shake, 0.3 + sp / 120.0)
		squash = 0.6
		vx = -dir * sp * 0.25
		msg("꽝!", 0.35)
		beep(110.0, 0.2, 45.0, 0.45)
		beep(800.0, 0.04, 0.0, 0.2)
	else:
		vx = 0.0


func _bomb_step(h: float) -> void:
	flash_t -= h
	if flash_t <= 0.0:
		flash_n.visible = false
	else:
		var s := lerpf(RADIUS * 2.0, 0.6, flash_t / 0.18)
		flash_n.scale = Vector3(s, s, 0.3)
	if not bomb.live or bomb.rest:
		return
	bomb.vy = maxf(bomb.vy - GRAV * h, -MAX_FALL)
	var nx: float = bomb.x + bomb.vx * h
	if _solid(floori(nx), floori(bomb.y)):
		bomb.vx = 0.0
	else:
		bomb.x = nx
	bomb.y += bomb.vy * h
	var under := floori(bomb.y - 0.2)
	if _solid(floori(bomb.x), under):
		bomb.y = under + 1.2
		bomb.vy = 0.0
		bomb.vx = 0.0
		bomb.rest = true
		beep(160.0, 0.04, 0.0, 0.12)
	elif bomb.y < -3.0:
		bomb.live = false
		bomb_n.visible = false
	bomb_n.position = Vector3(bomb.x, bomb.y, 0.3)


func _check() -> void:
	if die_t > 0.0:
		return
	var r := Rect2(px - bw * 0.5, py, bw, bh)
	if py < -2.0:
		_die("떨어짐")
		return
	for c in range(floori(r.position.x), floori(r.end.x) + 1):
		for yy in range(floori(py), floori(py + bh) + 1):
			if _ch(c, yy) == "^" and Rect2(c + 0.15, yy + 0.15, 0.7, 0.7).intersects(r):
				_die("가시")
				return
	var sp := Vector2(vx, vy).length()
	for key: Vector2i in mines:
		if Rect2(key.x + 0.1, key.y, 0.8, 0.4).intersects(r):
			if sp > SAFE_V:
				var mb: MeshInstance3D = mines[key][0]
				flash_t = 0.18
				flash_n.visible = true
				flash_n.position = mb.position + Vector3(0, 0.3, 0.4)
				beep(90.0, 0.25, 30.0, 0.5)
				_die("지뢰! 빨랐다")
				return
			elif creak_t <= 0.0:
				creak_t = 0.5
				beep(1200.0, 0.03, 0.0, 0.08)  # 딸깍: 느려서 안 터짐
	if door.intersects(r):
		clear_t = 1.0
		vx = 0.0
		vy = 0.0
		play("win")
		msg("문!", 0.8)


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 0.9
	body.material_override = mat(BAD)
	head.material_override = mat(BAD)
	shake = maxf(shake, 0.4)
	play("bad")
	msg(why, 0.9)


## 탭 = 워프 (방3·5). 속도는 그대로 남는다.
func _tap(p: Vector2) -> void:
	if rule_w <= 0 or die_t > 0.0 or clear_t > 0.0:
		return
	if warps <= 0:
		msg("워프 없음", 0.4)
		beep(200.0, 0.06, 0.0, 0.15)
		return
	var w := on_z(p, 0.0)
	var nx := w.x
	var ny := w.y - bh * 0.5
	if Vector2(nx - px, ny - py).length() > WARP_RANGE:
		msg("멀다", 0.4)
		beep(200.0, 0.06, 0.0, 0.15)
		return
	if not _free_rect(nx, ny, bw, bh):
		msg("막힘", 0.4)
		beep(200.0, 0.06, 0.0, 0.15)
		return
	warps -= 1
	var tb := trail[trail_k]
	trail_k = (trail_k + 1) % trail.size()
	tb.visible = true
	tb.position = Vector3(px, py + bh * 0.5, -0.3)
	tb.scale = Vector3(bw, bh, 0.4)
	px = nx
	py = ny
	on_floor = false
	shake = maxf(shake, 0.15)
	beep(700.0, 0.08, 1400.0, 0.25)
	msg("워프 %d" % warps, 0.5)


## 기는 소리는 느린 박자, 미끄러지는 소리는 속도에 비례
func _sounds(h: float) -> void:
	step_t -= h
	if step_t > 0.0 or not on_floor:
		return
	if crawling and absf(vx) > 0.3:
		step_t = 0.35
		beep(140.0, 0.04, 0.0, 0.1)
	elif absf(vx) > 3.0:
		step_t = clampf(2.2 / absf(vx), 0.05, 0.3)
		beep(100.0 + absf(vx) * 6.0, 0.03, 0.0, 0.08)


func _view(dt: float) -> void:
	me.position = Vector3(px, py, 0.0)
	var wig := sin(anim * 9.0) * 0.08 if crawling else 0.0
	me.scale = Vector3(1.0 + squash * 0.3 + wig, 1.0 - squash * 0.3 - wig, 1.0)
	body.scale = Vector3(bw, bh, 0.7)
	body.position.y = bh * 0.5
	var hs := minf(0.5, bh * 0.45)
	head.scale = Vector3(hs, hs, 0.75)
	head.position = Vector3(face * (bw * 0.5 - hs * 0.4), bh - hs * 0.5, 0.0)
	eye.position = Vector3(head.position.x + face * 0.1, head.position.y + hs * 0.15, 0.38)
	eye.scale = Vector3(0.14, minf(0.14, hs * 0.3), 0.05)
	# 빠를 때 잔상
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.03
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = Vector2(vx, vy).length() > 10.0 and die_t <= 0.0
		tb.position = Vector3(px, py + bh * 0.5, -0.3)
		tb.scale = Vector3(bw, bh, 0.4)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	var k := 1.0 - exp(-9.0 * dt)
	cam_x = lerpf(cam_x, px + vx * 0.08, k)
	cam_y = lerpf(cam_y, py, k)
	shake = maxf(0.0, shake - dt * 1.5)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.8
	cam.position = Vector3(cam_x + off.x, cam_y - 1.6 + off.y, 18.0)
	cam.rotation = Vector3.ZERO
	cam.fov = lerpf(cam.fov, 56.0 + minf(Vector2(vx, vy).length(), 40.0) * 0.25, k)
