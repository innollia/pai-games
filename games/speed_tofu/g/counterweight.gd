extends Tofu
## 균형추 배달부 (옆모습): 오른쪽 '던지기' = 승강기 칸에서 짐 하나를 옆으로 던진다. 2구역부터 '받기'(선반 짐), 3구역 '건너기'(엇갈리는 칸으로).
## 내 칸과 반대편 균형추는 옥상 도르래 하나로 묶여 있다. 짐이 추보다 무거우면 내 칸이 내려가며 빨라지고, 던져 가벼워지는 순간 느려지다 거꾸로 솟는다.
## 불 켜진 창 앞에서 던지면 배달(느리면 성공, 빠르면 와장창). 옥상에 닿으면 그 속도 그대로 지붕 위로 튀어나가 옆 빌딩 초록 옥상에 내려야 한다.
## 속도는 몸·화면으로 보인다: 떨어질 땐 몸이 떠오르고 모자가 날아가며, 솟을 땐 눌려 납작. 빠를수록 빨개지고 칸이 덜컹, 바람 줄·층 딸깍이 빨라지고, 옥상 발사 점선이 늘어난다.
## 바닥에 너무 빨리 닿으면 쾅, 발사가 약하면 골목, 세면 간판에 박힌다. 그 빌딩 옥상에서 다시.
# 한 문장: 나는 균형추 승강기를 탄 배달부로서 내 칸과 반대편 추가 도르래 하나로 묶인 제약 속에서 짐을 하나씩 던져(배달하며) 내 무게를 줄여 옥상에서 다음 빌딩으로 튀어 오르지만, 빠를수록 배달이 깨지고 바닥에 박히거나 간판에 처박히는 대가를 감수한다.

const G := 20.0  # 저울 가속에 쓰는 중력
const GA := 20.0  # 날아갈 때 중력
const FH := 3.0  # 한 층 높이
const CH := 2.4  # 칸 높이
const CW := 1.6  # 칸 너비
const HW := 4.5  # 빌딩 반 너비
const LX := -0.6  # 내 칸(왼쪽 승강로) 가로 위치
const RX := 1.6  # 반대편 칸(오른쪽 승강로)
const KX := 1.0  # 옥상 발사대: 위로 v 면 앞으로 v
const RW := 6.3  # 옥상 착지대 너비 (그 뒤는 간판)
const CRASH := 11.0  # 바닥에 이보다 빨리 닿으면 쾅
const BREAK := 8.0  # 이보다 빠를 때 던진 짐은 깨진다
const PICK := 6.0  # 이보다 느릴 때만 선반 짐을 받는다
const CROSSV := 8.0  # 이보다 느릴 때만 건너탈 수 있다
const NDOT := 14
const NSTREAK := 8
const TIPS := ["", "선반 짐은 느릴 때 '받기'", "칸이 스칠 때 '건너기'", "", ""]
const ZONES := ["아파트 단지", "시장 빌딩", "쌍둥이 승강기", "기운 빌딩", "물류 탑"]
# F 층수, n 내 짐, cr1 반대편 칸 짐(건너기 동), ex 반대편 추 무게, wins [층, 쪽], picks [층, 쪽], gap 다음 빌딩까지
const BLD := [
	{"zone": 0, "name": "첫 배달", "F": 8, "n": 3, "cr1": 0, "ex": 3.3, "wins": [[5, 0], [2, 0]], "picks": [], "gap": 3.0, "cross": false},
	{"zone": 0, "name": "세 집", "F": 8, "n": 4, "cr1": 0, "ex": 4.0, "wins": [[6, 0], [4, 0], [1, 0]], "picks": [], "gap": 3.0, "cross": false},
	{"zone": 1, "name": "짐 받기", "F": 9, "n": 3, "cr1": 0, "ex": 3.5, "wins": [[7, 0], [2, 0]], "picks": [[4, 0]], "gap": 3.0, "cross": false},
	{"zone": 1, "name": "두 선반", "F": 10, "n": 3, "cr1": 0, "ex": 3.6, "wins": [[8, 0], [5, 0], [1, 0]], "picks": [[3, 0], [6, 0]], "gap": 4.0, "cross": false},
	{"zone": 2, "name": "엇갈림", "F": 9, "n": 3, "cr1": 3, "ex": 0.0, "wins": [[6, 0], [2, 1], [5, 1]], "picks": [], "gap": 3.0, "cross": true},
]
const GOAL := {"zone": 4, "name": "물류센터", "F": 8, "goal": true}
# 구역마다 색: 뒷벽, 층 바닥, 승강로 뒤
const PAL := [
	[Color("f3d9b1"), Color("d9a066"), Color("fff4e0")],
	[Color("c3e6cb"), Color("6fbf8a"), Color("eefaf0")],
	[Color("dccdea"), Color("a98bc9"), Color("f6f0fb")],
	[Color("ffd8a8"), Color("e8a35a"), Color("fff3e3")],
	[Color("d0e4fb"), Color("7aa7da"), Color("f0f6fe")],
]
const BEAM := Color("8a6d4b")
const STREET := Color("ced4da")
const PADC := Color("b2f2bb")
const GREY := Color("adb5bd")
const WEIGHTC := Color("868e96")
const HOT := Color("e8590c")

var lv := 0
var bxs: Array[float] = []
var stages := {}  # 빌딩 번호 -> 정보
var cur: Dictionary
var S := 0.0  # 칸이 움직이는 길이 (왼쪽 칸 바닥 높이 0..S)
var s := 0.0  # 왼쪽 칸 바닥 높이 (오른쪽 칸은 S - s)
var v := 0.0
var acc := 0.0
var side := 0  # 내가 탄 칸 0 왼쪽 / 1 오른쪽
var cr: Array[int] = [0, 0]
var exm: Array[float] = [0.0, 0.0]
var phase := "ready"
var ph_t := 0.0
var score0 := 0
var floor_last := -1
var stuck_t := 0.0
var shake := 0.0
var anim := 0.0
var jolt := 0.0
var warn_t := 0.0
var fl_x0 := 0.0
var fl_y0 := 0.0
var fl_vx := 0.0
var fl_vy := 0.0
var fl_t := 0.0
var fx := 0.0
var fy := 0.0
var cam_d := 16.0
var me: Node3D
var mbody: MeshInstance3D
var mhead: MeshInstance3D
var mcap: MeshInstance3D
var streaks: Array[MeshInstance3D] = []
var dots: Array[MeshInstance3D] = []
var mark: MeshInstance3D
var flies: Array[MeshInstance3D] = []
var fly_v: Array[Vector3] = []
var fly_life: Array[float] = []
var fly_to: Array = []  # 창 위치(Vector3) 또는 null
var fly_k := 0


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 56.0
	howto = "승강기 칸에 짐이 가득. 반대편 추보다 무거우면 내려가며 점점 빨라진다.\n'던지기': 짐 하나를 옆으로 던져 가벼워진다. 불 켜진 창 앞이면 배달(느려야 안 깨짐).\n가벼워지면 칸이 거꾸로 솟아 옥상에서 튀어나간다. 점선 끝이 초록 옥상에 오게!\n바닥에 빨리 닿으면 쾅, 약하면 골목, 세면 간판."
	kit_button("throw", "던지기", Vector2(590, 1120), 112.0, A)


func _reset() -> void:
	stages.clear()
	bxs.clear()
	var x := 0.0
	for i in BLD.size() + 1:
		bxs.append(x)
		if i < BLD.size():
			x += HW * 2.0 + float(BLD[i].gap)
	box(Vector3(x * 0.5, -0.5, 0.0), Vector3(x + 60.0, 1.0, 8.0), STREET)
	for k in int(x / 4.0) + 8:  # 길 위 흰 줄 (지나가는 기준물)
		box(Vector3(-12.0 + k * 4.0, 0.02, 1.6), Vector3(1.6, 0.06, 0.25), WHITE)
	_make_me()
	streaks.clear()
	for i in NSTREAK:
		var m := box(Vector3.ZERO, Vector3(0.06, 1.0, 0.06), WHITE)
		m.visible = false
		streaks.append(m)
	dots.clear()
	for i in NDOT:
		var m := box(Vector3.ZERO, Vector3(0.22, 0.22, 0.22), INK)
		m.visible = false
		dots.append(m)
	mark = box(Vector3.ZERO, Vector3(0.9, 0.9, 0.3), GOOD)
	mark.visible = false
	flies.clear()
	fly_v.clear()
	fly_life.clear()
	fly_to.clear()
	for i in 4:
		var m := box(Vector3.ZERO, Vector3(0.42, 0.42, 0.42), A)
		m.visible = false
		flies.append(m)
		fly_v.append(Vector3.ZERO)
		fly_life.append(0.0)
		fly_to.append(null)
	lv = 0
	_enter(0, false)
	cam.position = Vector3(bxs[0] + 2.6, S * 0.6, 17.0)
	msg("불 켜진 창 앞에서 던지기!", 2.2)


func _make_me() -> void:
	me = Node3D.new()
	world.add_child(me)
	mbody = box(Vector3(0, 0.55, 0), Vector3(0.5, 0.8, 0.4), ME, me)
	mhead = box(Vector3(0, 1.2, 0), Vector3(0.42, 0.4, 0.4), SOFT, me)
	mcap = box(Vector3(0, 1.48, 0), Vector3(0.52, 0.14, 0.46), A, me)


# ---- 빌딩 만들기 ----
func _bdef(i: int) -> Dictionary:
	return BLD[i] if i < BLD.size() else GOAL


func _build(i: int) -> Dictionary:
	var d := _bdef(i)
	var bx: float = bxs[i]
	var f: int = d.F
	var h := f * FH
	var pal: Array = PAL[int(d.zone)]
	var node := Node3D.new()
	world.add_child(node)
	var info := {"node": node, "bx": bx, "H": h, "F": f, "wins": [], "picks": [], "cars": [], "lines": [], "bufs": []}
	box(Vector3(bx, h * 0.5, -1.0), Vector3(HW * 2.0, h, 0.4), pal[0], node)
	box(Vector3(bx, h + 0.15, 0.0), Vector3(HW * 2.0 + 0.2, 0.3, 1.8), BEAM, node)
	# 착지대(초록)와 그 뒤 간판: 너무 세게 날아오면 간판에 박힌다
	box(Vector3(bx - HW + RW * 0.5, h + 0.33, 0.0), Vector3(RW - 0.1, 0.06, 1.6), PADC, node)
	box(Vector3(bx - HW + RW + (HW * 2.0 - RW) * 0.5, h + 1.9, -0.2), Vector3(HW * 2.0 - RW - 0.2, 3.0, 0.4), C, node)
	box(Vector3(bx - HW + RW + (HW * 2.0 - RW) * 0.5, h + 1.9, 0.02), Vector3(HW * 2.0 - RW - 0.8, 0.5, 0.06), WHITE, node)
	if d.get("goal", false):
		box(Vector3(bx, h * 0.5, 0.2), Vector3(HW * 2.0 - 1.0, h - 1.0, 0.1), pal[2], node)
		for k in range(1, f):
			box(Vector3(bx, k * FH, 0.3), Vector3(HW * 2.0, 0.25, 1.2), pal[1], node)
		return info
	box(Vector3(bx + 0.5, h * 0.5, -0.75), Vector3(4.2, h, 0.15), pal[2], node)
	for k in range(0, f):
		box(Vector3(bx - 3.05, k * FH, 0.0), Vector3(2.9, 0.25, 1.4), pal[1], node)
		box(Vector3(bx + 3.55, k * FH, 0.0), Vector3(1.9, 0.25, 1.4), pal[1], node)
		if k > 0:  # 승강로 층 눈금: 칸 뒤로 흘러가는 기준물
			box(Vector3(bx + 0.5, k * FH, -0.62), Vector3(4.0, 0.14, 0.08), WHITE, node)
	for w: Array in d.wins:
		var wx := bx - 2.3 if int(w[1]) == 0 else bx + 3.4
		var m := box(Vector3(wx, int(w[0]) * FH + 1.4, 0.35), Vector3(1.3, 1.5, 0.3), D, node)
		info.wins.append({"k": int(w[0]), "side": int(w[1]), "m": m, "done": false})
	for p: Array in d.picks:
		var k: int = p[0]
		box(Vector3(bx - 1.75, k * FH + 0.3, 0.2), Vector3(0.9, 0.15, 0.9), BEAM, node)
		var c := box(Vector3(bx - 1.75, k * FH + 0.65, 0.2), Vector3(0.55, 0.55, 0.55), A, node)
		info.picks.append({"k": k, "side": int(p[1]), "m": c, "taken": false})
	for sx: float in [LX, RX]:
		info.bufs.append(box(Vector3(bx + sx, 0.12, 0.2), Vector3(1.3, 0.24, 0.7), D, node))
	box(Vector3(bx + 0.5, h + 0.9, -0.3), Vector3(2.9, 0.22, 0.3), BEAM, node)
	box(Vector3(bx + 0.5, h + 0.9, -0.1), Vector3(0.8, 0.8, 0.3), D, node)
	var ss := f * FH - CH - 0.2
	for k in 2:
		var car := Node3D.new()
		node.add_child(car)
		var passenger: bool = k == 0 or bool(d.cross)
		box(Vector3(0, CH * 0.5, -0.35), Vector3(CW, CH, 0.1), Color("a5d8ff") if passenger else Color("e5dbff"), car)
		box(Vector3(0, 0.06, 0), Vector3(CW, 0.12, 0.8), INK, car)
		box(Vector3(0, CH - 0.06, 0), Vector3(CW, 0.12, 0.8), INK, car)
		box(Vector3(-CW * 0.5, CH * 0.5, 0.3), Vector3(0.08, CH, 0.08), INK, car)
		box(Vector3(CW * 0.5, CH * 0.5, 0.3), Vector3(0.08, CH, 0.08), INK, car)
		var crates: Array[MeshInstance3D] = []
		for j in 6:
			var cm := box(Vector3(-0.5 + (j % 2) * 0.44, 0.34 + (j / 2) * 0.44, 0.05), Vector3(0.4, 0.4, 0.4), A, car)
			cm.visible = false
			crates.append(cm)
		var exv: float = d.ex
		if exv > 0.0 and k == 1:
			box(Vector3(0, 0.12 + exv * 0.2, 0.0), Vector3(1.3, exv * 0.4, 0.6), WEIGHTC, car)
		car.position = Vector3(bx + (LX if k == 0 else RX), ss if k == 0 else 0.0, 0.0)
		info.cars.append({"n": car, "crates": crates})
		var ln := box(Vector3.ZERO, Vector3(0.07, 1.0, 0.07), INK, node)
		info.lines.append(ln)
		_rope(ln, car.position.x, car.position.y + CH, h + 0.9)
	return info


func _rope(ln: MeshInstance3D, x: float, y0: float, y1: float) -> void:
	var rl := maxf(y1 - y0, 0.05)
	ln.position = Vector3(x, y0 + rl * 0.5, 0.0)
	ln.scale = Vector3(0.07, rl, 0.07)


## 빌딩 i 옥상에서 시작 (retry 면 점수를 빌딩 시작 때로)
func _enter(i: int, retry: bool) -> void:
	lv = i
	if retry:
		score = score0
	score0 = score
	if not stages.has(i):
		stages[i] = _build(i)
	if not stages.has(i + 1):
		stages[i + 1] = _build(i + 1)
	for k in stages.keys():
		if int(k) < i:
			(stages[k].node as Node3D).queue_free()
			stages.erase(k)
	cur = stages[i]
	var d := _bdef(i)
	var f: int = d.F
	S = f * FH - CH - 0.2
	s = S
	v = 0.0
	side = 0
	cr = [int(d.n), int(d.cr1)]
	exm = [0.0, float(d.ex)]
	for w: Dictionary in cur.wins:
		w.done = false
		(w.m as MeshInstance3D).material_override = mat(D)
	for p: Dictionary in cur.picks:
		p.taken = false
		(p.m as MeshInstance3D).visible = true
	phase = "ready"
	ph_t = 1.0 if not retry else 0.6
	floor_last = -1
	stuck_t = 0.0
	me.rotation = Vector3.ZERO
	_btns.erase("pick")
	_btns.erase("cross")
	if int(d.zone) >= 1 and not d.cross:
		kit_button("pick", "받기", Vector2(130, 1120), 100.0, GOOD)
	if d.cross:
		kit_button("cross", "건너기", Vector2(130, 1120), 100.0, C)
	_place_cars()


# ---- 물리 ----
func _mass(k: int) -> float:
	return 1.0 + cr[k] + exm[k] + (1.0 if side == k else 0.0)


## 내 칸 기준: 높이, 속도, 가속 (위가 +)
func _mine() -> Vector3:
	if side == 0:
		return Vector3(s, v, acc)
	return Vector3(S - s, -v, -acc)


func _step(dt: float) -> void:
	anim += dt
	shake = maxf(shake - dt * 2.5, 0.0)
	jolt = maxf(jolt - dt * 4.0, 0.0)
	_update_flies(dt)
	match phase:
		"ready":
			ph_t -= dt
			acc = 0.0
			if ph_t <= 0.0:
				phase = "ride"
				beep(180.0, 0.12, 120.0, 0.25)  # 브레이크 풀림
			_place_cars()
			_ride_visuals(dt)
		"ride":
			_ride(dt)
		"fly":
			_fly(dt)
		"walk":
			_walk(dt)
		"dead":
			ph_t -= dt
			_cam_to(Vector3(me.position.x, me.position.y, 16.0), dt)
			if ph_t <= 0.0:
				_enter(lv, true)


func _ride(dt: float) -> void:
	var ml := _mass(0)
	var mr := _mass(1)
	acc = G * (mr - ml) / (ml + mr)
	if kit_just("throw"):
		_throw()
	if kit_just("pick"):
		_pick()
	if kit_just("cross"):
		_cross()
	ml = _mass(0)
	mr = _mass(1)
	acc = G * (mr - ml) / (ml + mr)
	v += acc * dt
	s += v * dt
	var hit_speed := 0.0
	var launch := false
	if s <= 0.0:
		if side == 0:
			hit_speed = -v
			s = 0.0
			v = maxf(v, 0.0)
		else:
			launch = true
			s = 0.0
	elif s >= S:
		if side == 0:
			if v > 0.0:
				launch = true
			s = S
		else:
			hit_speed = v
			s = S
			v = minf(v, 0.0)
	if hit_speed > 0.0:
		if hit_speed > CRASH:
			_die("쾅! 너무 빨랐다")
			_place_cars()
			return
		elif hit_speed > 2.0:
			beep(140.0, 0.12, 80.0, 0.3)
			shake += 0.25
	if launch:
		_launch()
		return
	# 갇힘: 바닥에 멈췄는데 내 칸이 무겁고 던질 짐이 없다
	var mm := _mine()
	if mm.x <= 0.001 and absf(v) < 0.001 and mm.z <= 0.0 and cr[side] == 0 and not bool(_bdef(lv).cross):
		stuck_t += dt
		if stuck_t > 1.5:
			_die("갇혔다")
			return
	else:
		stuck_t = 0.0
	# 층마다 딸깍 (빨라질수록 촘촘하고 높게)
	var flo := floori((mm.x + 1.2) / FH)
	if flo != floor_last:
		if floor_last >= 0:
			beep(260.0 + absf(v) * 45.0, 0.04, 0.0, 0.12)
		floor_last = flo
	_place_cars()
	_ride_visuals(dt)


func _place_cars() -> void:
	var f := clampf(absf(v) / CRASH, 0.0, 1.3)
	var rat := sin(anim * 55.0) * 0.06 * f
	var bx: float = cur.bx
	var hgt: float = cur.H
	var c0: Node3D = cur.cars[0].n
	var c1: Node3D = cur.cars[1].n
	c0.position = Vector3(bx + LX + (rat if side == 0 else 0.0), s - (jolt * 0.15 if side == 0 else 0.0), 0.0)
	c1.position = Vector3(bx + RX + (rat if side == 1 else 0.0), S - s - (jolt * 0.15 if side == 1 else 0.0), 0.0)
	_rope(cur.lines[0], c0.position.x, c0.position.y + CH, hgt + 0.9)
	_rope(cur.lines[1], c1.position.x, c1.position.y + CH, hgt + 0.9)
	for k in 2:
		var crates: Array[MeshInstance3D] = cur.cars[k].crates
		for j in crates.size():
			crates[j].visible = j < cr[k]
	var mine: Node3D = cur.cars[side].n
	me.position = mine.position + Vector3(0.32, 0.12, 0.15)


## 몸·바람·카메라·점선: 속도를 눈으로
func _ride_visuals(dt: float) -> void:
	var mm := _mine()
	var u := mm.y
	var f := clampf(absf(u) / CRASH, 0.0, 1.3)
	# 몸: 떨어지면 떠오르고 모자가 날아간다, 솟으면 눌린다
	var up_k := clampf(-u / CRASH, 0.0, 1.2)
	var dn_k := clampf(u / CRASH, 0.0, 1.2)
	var sy := 0.8 * (1.0 + up_k * 0.45 - dn_k * 0.4)
	var sx := 0.5 * (1.0 + dn_k * 0.35)
	var lift := up_k * 0.32 + sin(anim * 30.0) * 0.03 * up_k
	mbody.scale = Vector3(sx, sy, 0.4)
	mbody.position = Vector3(0, 0.15 + lift + sy * 0.5, 0)
	mhead.position = Vector3(0, 0.15 + lift + sy + 0.2, 0)
	mcap.position = Vector3(sin(anim * 23.0) * 0.08 * up_k, mhead.position.y + 0.27 + up_k * up_k * 0.9, 0)
	mcap.rotation.z = sin(anim * 17.0) * 0.6 * up_k
	var col := ME if f < 0.6 else (HOT if f < 0.85 else BAD)
	mbody.material_override = mat(col)
	# 바람 줄: 움직임 반대쪽으로 길게
	var car: Node3D = cur.cars[side].n
	var cy := car.position.y + CH * 0.5
	for i in NSTREAK:
		var st := streaks[i]
		if absf(u) < 2.0 or phase != "ride":
			st.visible = false
			continue
		st.visible = true
		var off := fmod(anim * absf(u) * 0.35 + i * 0.37, 1.0)
		var xx := car.position.x + (-1.05 if i % 2 == 0 else 1.05) + (i / 2) * 0.05
		var ln := absf(u) * 0.16
		st.position = Vector3(xx, cy - signf(u) * (0.6 + off * 3.2), 0.4)
		st.scale = Vector3(0.06, ln, 0.06)
	# 카메라: 따라가고, 빠를수록 물러나며 가는 쪽을 먼저 보여 준다
	var near_top := clampf((mm.x - (S - 12.0)) / 10.0, 0.0, 1.0)
	var bx: float = cur.bx
	var hgt: float = cur.H
	var ty := clampf(cy + u * 0.4 + near_top * 3.0, 9.0, hgt + 2.0)
	var target := Vector3(bx + 2.6 + near_top * 2.2, ty, 16.0 + absf(u) * 0.35)
	_cam_to(target, dt)
	cam.fov = 56.0 + f * 6.0
	gauge(absf(u) / CRASH, GOOD if f < 0.6 else (A if f < 0.85 else BAD))
	_preview(mm)


func _cam_to(target: Vector3, dt: float) -> void:
	var p := cam.position.lerp(target, 1.0 - exp(-dt * 4.0))
	cam.position = p + Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * shake * 0.4


## 지금 이대로면: 옥상에 닿을 속도(점선) 또는 바닥 충돌(빨간 X)
func _preview(mm: Vector3) -> void:
	var h := mm.x
	var u := mm.y
	var au := mm.z
	var kind := "rest"
	var vt := 0.0
	var vb := 0.0
	var top := S
	if au > 0.0:
		if u >= 0.0:
			kind = "top"
			vt = sqrt(u * u + 2.0 * au * (top - h))
		elif u * u / (2.0 * au) > h:
			vb = sqrt(maxf(u * u - 2.0 * au * h, 0.0))
			if vb > CRASH:
				kind = "crash"
			else:
				kind = "top"
				vt = sqrt(2.0 * au * top)
		else:
			kind = "top"
			vt = sqrt(u * u + 2.0 * au * (top - h))
	else:
		var r := u * u + 2.0 * au * (top - h)
		if u > 0.0 and r > 0.0:
			kind = "top"
			vt = sqrt(r)
		else:
			vb = sqrt(maxf(u * u - 2.0 * au * h, 0.0))
			kind = "crash" if vb > CRASH else "rest"
	var bufm: MeshInstance3D = cur.bufs[side]
	warn_t -= get_process_delta_time()
	if kind == "crash":
		var blink := fmod(anim, 0.3) < 0.15
		bufm.material_override = mat(BAD if blink else D)
		mark.visible = true
		mark.material_override = mat(BAD)
		mark.scale = Vector3(1.1, 1.1, 0.3)
		mark.rotation.z = PI * 0.25
		mark.position = bufm.position + Vector3(0, 0.8, 0.4)
		if warn_t <= 0.0:
			beep(900.0, 0.05, 0.0, 0.12)
			warn_t = 0.3
		for dm in dots:
			dm.visible = false
		return
	bufm.material_override = mat(D)
	mark.rotation.z = 0.0
	if kind != "top" or vt < 0.5:
		mark.visible = false
		for dm in dots:
			dm.visible = false
		return
	var car: Node3D = cur.cars[side].n
	var x0 := car.position.x
	var y0: float = float(cur.H) + 0.3
	var res := _arc(x0, y0, vt)
	var tend: float = res[0]
	var ok: bool = res[1]
	for j in NDOT:
		var tj := tend * float(j + 1) / float(NDOT)
		dots[j].visible = true
		dots[j].position = Vector3(x0 + KX * vt * tj, y0 + vt * tj - GA * tj * tj * 0.5, 0.5)
		dots[j].material_override = mat(INK)
	mark.visible = true
	mark.scale = Vector3(0.9, 0.9, 0.3)
	mark.material_override = mat(GOOD if ok else BAD)
	mark.position = dots[NDOT - 1].position + Vector3(0, 0.3, 0)


## 발사 궤적이 끝나는 시간과 착지 성공 여부
func _arc(x0: float, y0: float, vt: float) -> Array:
	var nb: Dictionary = stages[lv + 1]
	var hn: float = nb.H
	var nl: float = float(nb.bx) - HW
	var own_r: float = float(cur.bx) + HW
	var hown: float = cur.H
	var dd := vt * vt + 2.0 * GA * (y0 - hn)
	if dd >= 0.0:
		var t1 := (vt + sqrt(dd)) / GA
		var xl := x0 + KX * vt * t1
		if xl >= nl and xl <= nl + RW:
			return [t1, true]
		if xl > nl + RW:  # 간판까지
			var tb := (nl + RW - x0) / (KX * vt)
			return [tb, false]
	# 모자람: 자기 옥상 또는 다음 빌딩 벽·골목
	var dd2 := vt * vt + 2.0 * GA * (y0 - hown)
	var t2 := (vt + sqrt(maxf(dd2, 0.0))) / GA
	if x0 + KX * vt * t2 <= own_r:
		return [t2, false]
	var tw := (nl - x0) / (KX * vt)
	var ty := y0 + vt * tw - GA * tw * tw * 0.5
	if ty < hn:
		return [tw, false]
	var t3 := (vt + sqrt(vt * vt + 2.0 * GA * y0)) / GA
	return [t3, false]


# ---- 동사 ----
func _throw() -> void:
	if cr[side] <= 0:
		msg("짐 없음", 0.5)
		beep(200.0, 0.06, 0.0, 0.15)
		return
	cr[side] -= 1
	jolt = 1.0
	shake += 0.12
	var mm := _mine()
	var cc := mm.x + 1.2
	var car: Node3D = cur.cars[side].n
	var dir := -1.0 if side == 0 else 1.0
	var hit: Dictionary = {}
	for w: Dictionary in cur.wins:
		if int(w.side) == side and not w.done and absf(cc - (int(w.k) * FH + 1.4)) < 1.1:
			hit = w
			break
	var from := car.position + Vector3(dir * 0.6, 1.0, 0.4)
	var m := flies[fly_k]
	m.visible = true
	m.position = from
	fly_v[fly_k] = Vector3(dir * 7.0, mm.y, 0.0)
	fly_life[fly_k] = 1.4
	fly_to[fly_k] = null
	if not hit.is_empty():
		hit.done = true
		fly_to[fly_k] = (hit.m as MeshInstance3D).position
		fly_life[fly_k] = 0.3
		if absf(v) < BREAK:
			score += 10
			msg("배달!", 0.7)
			play("good")
			(hit.m as MeshInstance3D).material_override = mat(GOOD)
		else:
			score += 3
			msg("와장창!", 0.8)
			beep(160.0, 0.2, 60.0, 0.3)
			shake += 0.2
			(hit.m as MeshInstance3D).material_override = mat(GREY)
	else:
		msg("버림", 0.4)
		beep(330.0, 0.07, 200.0, 0.18)
	fly_k = (fly_k + 1) % flies.size()


func _pick() -> void:
	var cc := _mine().x + 1.2
	for p: Dictionary in cur.picks:
		if int(p.side) == side and not p.taken and absf(cc - (int(p.k) * FH + 0.65)) < 1.2:
			if absf(v) < PICK:
				p.taken = true
				(p.m as MeshInstance3D).visible = false
				cr[side] += 1
				jolt = 1.0
				msg("받음!", 0.6)
				play("good")
			else:
				msg("너무 빨라!", 0.6)
				beep(180.0, 0.1, 0.0, 0.2)
			return
	msg("선반 앞에서", 0.5)
	beep(240.0, 0.05, 0.0, 0.12)


func _cross() -> void:
	if absf(s - (S - s)) < 1.4:
		if absf(v) < CROSSV:
			side = 1 - side
			jolt = 1.0
			msg("건너기!", 0.6)
			play("good")
		else:
			msg("너무 빨라!", 0.6)
			beep(180.0, 0.1, 0.0, 0.2)
	else:
		msg("칸이 스칠 때", 0.5)
		beep(240.0, 0.05, 0.0, 0.12)


func _update_flies(dt: float) -> void:
	for i in flies.size():
		if fly_life[i] <= 0.0:
			continue
		fly_life[i] -= dt
		var m := flies[i]
		if fly_to[i] != null:
			var to: Vector3 = fly_to[i]
			m.position = m.position.lerp(to, 1.0 - exp(-dt * 18.0))
		else:
			fly_v[i].y -= GA * dt
			m.position += fly_v[i] * dt
			fly_v[i].x *= 0.97
		if fly_life[i] <= 0.0:
			m.visible = false


# ---- 옥상 발사 ----
func _launch() -> void:
	var mm := _mine()
	var vt := absf(mm.y)
	var car: Node3D = cur.cars[side].n
	fl_x0 = car.position.x
	fl_y0 = float(cur.H) + 0.3
	fl_vx = KX * vt
	fl_vy = vt
	fl_t = 0.0
	fx = fl_x0
	fy = fl_y0
	phase = "fly"
	v = 0.0
	shake += 0.3
	beep(300.0, 0.25, 900.0, 0.3)
	for st in streaks:
		st.visible = false
	for dm in dots:
		dm.visible = false
	mark.visible = false
	_place_cars()
	me.position = Vector3(fx, fy, 0.3)


func _fly(dt: float) -> void:
	var px := fx
	fl_t += dt
	fx = fl_x0 + fl_vx * fl_t
	fy = fl_y0 + fl_vy * fl_t - GA * fl_t * fl_t * 0.5
	var vy := fl_vy - GA * fl_t
	me.position = Vector3(fx, fy, 0.3)
	me.rotation.z -= dt * (2.0 + fl_vx * 0.5)
	var spd := Vector2(fl_vx, vy).length()
	var f := clampf(spd / 16.0, 0.0, 1.2)
	mbody.material_override = mat(ME if f < 0.6 else (HOT if f < 0.85 else BAD))
	gauge(spd / 16.0, GOOD if f < 0.6 else (A if f < 0.85 else BAD))
	_cam_to(Vector3(fx + 2.0, fy, 17.0 + spd * 0.2), dt)
	var nb: Dictionary = stages[lv + 1]
	var hn: float = nb.H
	var nl: float = float(nb.bx) - HW
	var own_r: float = float(cur.bx) + HW
	var hown: float = cur.H
	if vy < 0.0 and fx <= own_r and fy <= hown + 0.3:
		_die("약했다… 다시")
		return
	if fx >= nl + RW and px < nl + RW and fy < hn + 3.4:
		_die("간판에 쾅!")
		return
	if vy < 0.0 and fx >= nl and fx < nl + RW and fy <= hn + 0.3:
		fy = hn + 0.3
		me.position = Vector3(fx, fy, 0.3)
		me.rotation = Vector3.ZERO
		score += 5
		msg("착지!", 0.7)
		play("good")
		shake += 0.15
		if lv + 1 >= BLD.size():
			score += 20
			msg("배달 끝!", 2.0)
			phase = "done"
			end()
			return
		phase = "walk"
		return
	if fx >= nl - 0.15 and px < nl - 0.15 and fy < hn:
		_die("벽에 쾅!")
		return
	if fy < 0.3 or fx > nl + HW * 2.0 + 1.0:
		_die("골목으로 추락")
		return


func _walk(dt: float) -> void:
	var nb: Dictionary = stages[lv + 1]
	var tx: float = float(nb.bx) + LX + 0.32
	var dx := tx - me.position.x
	me.position.x += clampf(dx, -6.0 * dt, 6.0 * dt)
	mbody.material_override = mat(ME)
	_cam_to(Vector3(float(nb.bx) + 2.6, float(nb.H) - 4.0, 16.0), dt)
	if absf(dx) < 0.05:
		var nxt := lv + 1
		var d := _bdef(nxt)
		var zone_new := int(d.zone) != int(_bdef(lv).zone)
		_enter(nxt, false)
		if zone_new:
			msg("%d구역 %s
%s" % [int(d.zone) + 1, ZONES[int(d.zone)], TIPS[int(d.zone)]], 2.2)
		else:
			msg(str(d.name), 1.0)


func _die(why: String) -> void:
	phase = "dead"
	ph_t = 1.5
	shake += 0.6
	play("bad")
	msg(why, 1.4)
	mbody.material_override = mat(BAD)
	mbody.scale = Vector3(0.8, 0.35, 0.4)
	for st in streaks:
		st.visible = false
	for dm in dots:
		dm.visible = false
	mark.visible = false
