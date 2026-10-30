extends Tofu
## 길 깔기 경주(등뒤 위). 핸들·브레이크 없는 차가 산을 굴러 내려가며 저절로 빨라진다. 차 앞 타일을 탭해 90° 돌려 길을 잇는다.
## 직선은 가속, 커브는 유일한 브레이크(한계 속도 넘으면 미끄러짐). 끊긴 타일로 들어가거나 뒤에서 무너지는 길에 잡히면 끝. 결승 문까지.
# 한 문장: 나는 핸들 없는 차의 길잡이로서 뒤에서 길이 무너지는 제약 속에서 앞 타일을 돌려 잇고 결승까지 가지만, 빠를수록 돌릴 시간이 없고 커브에서 미끄러지는 대가를 감수한다.

const TS := 4.0        # 타일 한 변
const VMAX := 30.0
const V0 := 8.0
const ACC0 := 3.0      # 내리막 가속 (초당)
const CLIM0 := 16.0    # 커브 한계 속도
const CURVE_K := 0.75  # 커브 통과 뒤 속도 배율
const JMIN := 12.0     # 점프 최저 속도
const CV := 6.0        # 무너지는 길 속도
const Z2 := 16         # 갈림길 시작 줄
const Z3 := 38         # 절벽(한 번만) 시작 줄
const GOAL_R := 52
const DIRV := [Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)]  # 북 동 남 서
# 길: [칸, 줄] 차례. 첫 칸은 이미 깔린 칸(이어 붙이는 자리)이거나 출발 칸.
const P0 := [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8], [1, 8], [0, 8], [0, 9], [0, 10], [0, 11], [0, 12], [1, 12], [1, 13], [1, 14], [1, 15], [1, 16]]
const PA := [[1, 16], [1, 17], [0, 17], [0, 18], [0, 19], [0, 20], [0, 21], [0, 22], [0, 24], [0, 25], [0, 26], [1, 26], [1, 27], [1, 28], [1, 29], [1, 30], [0, 30], [0, 31], [0, 32], [0, 33], [1, 33], [1, 34], [1, 35], [1, 36], [1, 37]]
const PB := [[1, 16], [1, 17], [2, 17], [2, 18], [2, 19], [2, 20], [1, 20], [1, 21], [1, 22], [2, 22], [2, 23], [2, 24], [2, 25], [2, 26], [1, 26]]
const PC := [[1, 29], [1, 30], [2, 30], [2, 31], [2, 32], [2, 33], [1, 33]]
const PD := [[1, 37], [1, 38], [1, 39], [2, 39], [2, 40], [2, 41], [1, 41], [0, 41], [0, 42], [0, 43], [0, 44], [0, 45], [1, 45], [1, 46], [1, 47], [1, 48], [2, 48], [2, 49], [2, 50], [2, 51], [2, 52]]
# 특별 타일: B 부스터, K 브레이크, J 점프(다음 칸이 빈 칸), P1 스포일러, P2 터보, G 결승
const SPECIAL := {"0_19": "B", "2_31": "B", "2_19": "K", "0_25": "K", "0_22": "J", "0_24": "P1", "2_24": "P2", "2_52": "G"}
const VOID := ["0_23"]  # 점프 틈 (타일 못 놓음)


class Tile:
	var n: Node3D
	var slab: MeshInstance3D
	var pbox: MeshInstance3D
	var kind := "S"
	var rot := 0
	var c := 0
	var r := 0
	var locked := false
	var extra := false  # 길이 아닌 미끼 타일


var tiles := {}  # "c_r" -> Tile
var car: Node3D
var cc := Vector2i(1, 0)
var hd := 0
var sp := 0.0
var turned := false
var air := false
var v := 0.0
var acc := ACC0
var climit := CLIM0
var wall: MeshInstance3D
var wall_z := 0.0
var dying := 0  # 0 아님, 1 추락, 2 미끄러짐
var die_t := 0.0
var lean := 0.0
var bonus := 0
var rows := 0
var flag := 0
var warn_t := 0.0
var clock := 0.0
var won := false
var tick: ColorRect


func _setup() -> void:
	howto = "차는 멈추지 않고 점점 빨라진다. 핸들 없음.\n앞 타일을 탭해 돌려(90°) 길을 잇는다.\n직선은 빨라지고 커브는 느려지지만 너무 빠르면 미끄러진다.\n끊긴 타일로 들어가거나 뒤에서 무너지는 길에 잡히면 끝. 결승 문까지."
	time_limit = 0.0
	tick = ColorRect.new()
	tick.color = INK
	tick.size = Vector2(6, 48)
	tick.position = Vector2(0, -10)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(tick)


func _reset() -> void:
	tiles.clear()
	cc = Vector2i(1, 0)
	hd = 0
	sp = TS * 0.5
	turned = true
	air = false
	v = V0
	acc = ACC0
	climit = CLIM0
	dying = 0
	die_t = 0.0
	lean = 0.0
	bonus = 0
	rows = 0
	flag = 0
	warn_t = 0.0
	clock = 0.0
	won = false
	wall_z = 6.0 * TS
	_build()
	car = Node3D.new()
	world.add_child(car)
	box(Vector3(0, 0.55, 0), Vector3(1.6, 0.7, 2.4), ME, car)
	box(Vector3(0, 1.05, 0.2), Vector3(1.2, 0.5, 1.1), WHITE, car)
	wall = box(Vector3(0, 3.0, wall_z), Vector3(TS * 3.0 + 10.0, 7.0, 1.2), INK)
	_place(0.0)
	cam.position = Vector3(0, 10.0, 9.5)
	cam.look_at(Vector3(0, 0, -7.0))
	cam.fov = 60.0
	msg("산길", 1.5)


# ---- 길 만들기 ----
func _key(c: int, r: int) -> String:
	return "%d_%d" % [c, r]


func _lay(path: Array, first_entry: int) -> void:
	for i in path.size():
		var c: int = path[i][0]
		var r: int = path[i][1]
		var ent := first_entry
		if i > 0:
			var d := Vector2i(c - path[i - 1][0], r - path[i - 1][1])
			ent = (_edge(d) + 2) % 4
		var ex := (ent + 2) % 4
		if i < path.size() - 1:
			ex = _edge(Vector2i(path[i + 1][0] - c, path[i + 1][1] - r))
		var k := _key(c, r)
		if tiles.has(k):
			continue
		var tl := Tile.new()
		tl.c = c
		tl.r = r
		if ex == (ent + 2) % 4:
			tl.kind = "S"
			tl.rot = ent % 2
		else:
			tl.kind = "C"
			for q in 4:
				if (q == ent and (q + 1) % 4 == ex) or (q == ex and (q + 1) % 4 == ent):
					tl.rot = q
		tiles[k] = tl


## 칸 차이 -> 방향 번호 (줄이 커지면 북쪽)
func _edge(d: Vector2i) -> int:
	if d.y > 0:
		return 0
	if d.x > 0:
		return 1
	if d.y < 0:
		return 2
	return 3


func _open(tl: Tile) -> Array:
	if tl.kind == "C":
		return [tl.rot, (tl.rot + 1) % 4]
	return [tl.rot % 2, tl.rot % 2 + 2]


func _build() -> void:
	_lay(P0, 2)
	_lay(PA, 2)
	_lay(PB, 2)
	_lay(PC, 2)
	_lay(PD, 2)
	for k in SPECIAL:
		if tiles.has(k):
			tiles[k].kind = SPECIAL[k]
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	# 미끼 타일 (갈림길·절벽 구역)
	for r in range(Z2, GOAL_R):
		for c in 3:
			var k := _key(c, r)
			if tiles.has(k) or k in VOID:
				continue
			if rng.randf() < (0.45 if r < Z3 else 0.3):
				var tl := Tile.new()
				tl.c = c
				tl.r = r
				tl.kind = "C" if rng.randf() < 0.5 else "S"
				tl.rot = rng.randi_range(0, 3)
				tl.extra = true
				tiles[k] = tl
	# 뒤틀기: 처음 3칸은 그대로, 절벽은 한 번 탭이면 맞게
	for k in tiles:
		var tl: Tile = tiles[k]
		if tl.r < 3 or tl.kind == "G" or tl.extra:
			continue
		if tl.r >= Z3:
			if rng.randf() < 0.5:
				tl.rot = (tl.rot + 3) % 4
		elif tl.kind == "C":
			tl.rot = rng.randi_range(0, 3)
		elif rng.randf() < 0.5:
			tl.rot = (tl.rot + 1) % 4
	# 상자
	for k in tiles:
		_tile_boxes(tiles[k])
	# 바닥(물), 말뚝, 결승 문
	box(Vector3(0, -7.0, -GOAL_R * TS * 0.5), Vector3(240.0, 1.0, GOAL_R * TS + 120.0), Color("a5d8ff"))
	for r in range(0, GOAL_R, 3):
		var sd := -1.0 if (r / 3) % 2 == 0 else 1.0
		box(Vector3(sd * (TS * 1.5 + 1.6), 0.9, -r * TS), Vector3(0.6, 2.2, 0.6), D if r < Z2 else (B if r < Z3 else C))
	var gz := -GOAL_R * TS
	for sd: float in [-1.0, 1.0]:
		box(Vector3(TS + sd * 2.6, 2.5, gz), Vector3(0.8, 5.0, 0.8), GOOD)
	box(Vector3(TS, 5.2, gz), Vector3(6.0, 0.8, 0.8), GOOD)


func _tile_boxes(tl: Tile) -> void:
	tl.n = Node3D.new()
	tl.n.position = _ctr(tl.c, tl.r)
	tl.n.rotation.y = -tl.rot * PI * 0.5
	world.add_child(tl.n)
	tl.slab = box(Vector3(0, -0.15, 0), Vector3(TS - 0.3, 0.3, TS - 0.3), WHITE if tl.r >= Z3 else SOFT, tl.n)
	var col := INK
	match tl.kind:
		"B": col = A
		"K": col = B
		"J": col = D
		"G": col = GOOD
	if tl.kind == "C":
		box(Vector3(0, 0.08, -0.525), Vector3(1.6, 0.16, 2.65), col, tl.n)
		box(Vector3(0.525, 0.08, 0), Vector3(2.65, 0.16, 1.6), col, tl.n)
	else:
		var arm := box(Vector3(0, 0.08, 0), Vector3(1.6, 0.16, TS - 0.3), col, tl.n)
		if tl.kind == "J":
			arm.rotation_degrees.x = 9.0
			arm.position.y = 0.35
	if tl.kind == "P1":
		tl.pbox = box(Vector3(0, 1.2, 0), Vector3(2.0, 0.3, 0.6), D, tl.n)
	elif tl.kind == "P2":
		tl.pbox = box(Vector3(0, 1.2, 0), Vector3(0.7, 0.7, 1.2), A, tl.n)


func _ctr(c: int, r: int) -> Vector3:
	return Vector3((c - 1) * TS, 0, -r * TS)


func _at(c: int, r: int) -> Tile:
	return tiles.get(_key(c, r))


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	if dying > 0:
		die_t += dt
		if dying == 1:
			car.position.y -= 14.0 * dt * die_t
			car.rotation.x += 2.0 * dt
		else:
			car.position += DIRV[(hd + 1) % 4] * v * 0.5 * dt
			car.rotation.y += 5.0 * dt
		if die_t > 0.9:
			end()
		return
	v = minf(v + acc * dt, VMAX)
	sp += v * dt
	var cur := _at(cc.x, cc.y)
	if not turned and not air and sp >= TS * 0.5:
		turned = true
		_center(cur)
		if dying > 0:
			return
	if sp >= TS:
		sp -= TS
		var nxt := cc + Vector2i(int(DIRV[hd].x), int(-DIRV[hd].z))
		if air:
			air = false
		elif cur and cur.kind == "J" and hd == 0:
			if v < JMIN:
				_die(1, "느려서 추락")
				return
			air = true
			msg("점프!", 0.5)
			beep(330.0, 0.15, 660.0, 0.22)
		if not air:
			var tl := _at(nxt.x, nxt.y)
			if tl == null or not ((hd + 2) % 4 in _open(tl)):
				cc = nxt
				_die(1, "추락!")
				return
			if tl.kind == "G":
				won = true
				bonus += 500
				cc = nxt
				msg("결승!", 2.0)
				end()
				return
			beep(clampf(240.0 + v * 18.0, 200.0, 800.0), 0.04, 0.0, 0.12)
		cc = nxt
		turned = false
		if cc.y > rows:
			rows = cc.y
		_marks()
	# 무너지는 길
	wall_z -= CV * dt
	wall.position.z = wall_z
	for k in tiles:
		var tl: Tile = tiles[k]
		if tl.n.visible and tl.n.position.z > wall_z:
			tl.n.visible = false
	var carz := car.position.z
	if carz > wall_z - 1.0:
		msg("무너졌다", 2.0)
		play("bad")
		end()
		return
	warn_t -= dt
	if wall_z - carz < 10.0 and warn_t <= 0.0:
		warn_t = 0.35
		beep(80.0, 0.12, 60.0, 0.25)
	score = rows * 10 + bonus
	var col := GOOD
	if v > climit:
		col = BAD
	elif v > climit * 0.85:
		col = D
	gauge(v / VMAX, col)
	tick.position.x = 600.0 * climit / VMAX - 3.0
	_place(dt)


## 타일 가운데: 커브면 꺾고 느려진다, 특별 타일 효과
func _center(tl: Tile) -> void:
	if tl == null:
		return
	var ent := (hd + 2) % 4
	var op := _open(tl)
	var ex: int = op[1] if op[0] == ent else op[0]
	if ex != hd:
		if v > climit:
			_die(2, "미끄러짐!")
			return
		lean = 1.0 if (ex - hd + 4) % 4 == 1 else -1.0
		v *= CURVE_K
		hd = ex
		beep(220.0, 0.12, 120.0, 0.2)
	match tl.kind:
		"B":
			v = minf(v + 6.0, VMAX)
			bonus += 20
			msg("부스터!", 0.4)
			beep(600.0, 0.15, 1200.0, 0.25)
		"K":
			v *= 0.6
			msg("브레이크", 0.4)
			beep(400.0, 0.15, 200.0, 0.2)
		"P1":
			tl.kind = "S"
			tl.pbox.visible = false
			climit += 5.0
			box(Vector3(0, 1.1, 1.0), Vector3(2.0, 0.2, 0.5), D, car)
			msg("스포일러!", 0.8)
			play("good")
		"P2":
			tl.kind = "S"
			tl.pbox.visible = false
			acc *= 1.4
			box(Vector3(0, 0.4, 1.4), Vector3(0.6, 0.5, 0.6), A, car)
			msg("터보!", 0.8)
			play("good")


func _marks() -> void:
	var at := [Z2, Z3]
	if flag >= at.size() or cc.y < at[flag]:
		return
	msg(["갈림길", "한 번만!"][flag], 1.4)
	beep(440.0, 0.25, 880.0, 0.25)
	flag += 1


func _die(how: int, text: String) -> void:
	dying = how
	die_t = 0.0
	msg(text, 2.0)
	if how == 1:
		beep(400.0, 0.6, 60.0, 0.3)
	else:
		beep(500.0, 0.5, 100.0, 0.3)


func _place(dt: float) -> void:
	var pos: Vector3 = _ctr(cc.x, cc.y) + DIRV[hd] * (sp - TS * 0.5)
	if air:
		pos.y = sin(clampf(sp / TS, 0.0, 1.0) * PI) * 1.6
	car.position = pos
	var yaw := atan2(-DIRV[hd].x, -DIRV[hd].z)
	car.rotation.y = lerp_angle(car.rotation.y, yaw, minf(1.0, dt * 9.0))
	lean = lerpf(lean, 0.0, minf(1.0, dt * 5.0))
	car.rotation.z = lean * 0.3
	car.rotation.x = 0.0
	# 타일 회전은 부드럽게
	for k in tiles:
		var tl: Tile = tiles[k]
		var want := -tl.rot * PI * 0.5
		if absf(angle_difference(tl.n.rotation.y, want)) > 0.002:
			tl.n.rotation.y = lerp_angle(tl.n.rotation.y, want, minf(1.0, dt * 14.0))
	# 카메라: 북쪽만 보며 뒤 위에서 따라온다, 빠를수록 넓게
	var wantc := Vector3(pos.x * 0.4, 10.0, pos.z + 9.5)
	cam.position = cam.position.lerp(wantc, minf(1.0, dt * 5.0))
	cam.look_at(Vector3(cam.position.x, 0, cam.position.z - 16.5))
	cam.fov = lerpf(cam.fov, clampf(56.0 + v * 0.9, 56.0, 84.0), minf(1.0, dt * 3.0))


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	if dying > 0:
		return
	var g := ground(p, 0.0)
	var c := roundi(g.x / TS) + 1
	var r := roundi(-g.z / TS)
	var tl := _at(c, r)
	if tl == null or tl.kind == "G" or not tl.n.visible:
		return
	if c == cc.x and r == cc.y:
		beep(150.0, 0.08, 0.0, 0.15)
		msg("밟는 중", 0.4)
		return
	if tl.locked:
		beep(150.0, 0.1, 0.0, 0.15)
		msg("잠김", 0.4)
		return
	tl.rot = (tl.rot + 1) % 4
	if r >= Z3:
		tl.locked = true
		tl.slab.material_override = mat(C)
	beep(620.0, 0.05, 0.0, 0.18)


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)

