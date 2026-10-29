extends Tofu
## 시냅스 특급(손): 바깥이 멈춘 0.3초 동안 전기 신호가 되어 신경을 달린다. 틱 박자에 탭 = 수초 도약(딱 맞으면 두 칸), 갈림길은 왼/오른쪽 탭(초록이 손 쪽),
## 시냅스 틈은 노란 수용체가 초록 칸 사이에 올 때 탭, 보라 손상 구간은 짧게만 뛴다. 늦으면 손이 다친다(체력 3, 0이면 끝).
## 성공하면 두꺼운 수초(박자 빨라짐) / 넓은 박자 창 중 하나를 고른다. 위급 3개를 다 돌면 더 빠른 다음 바퀴.

const SEG := 3.0
const DSEG := 1.1
const GAP := 4.5
const ARM := 3.0
const NODE := Vector3(0.8, 0.8, 0.4)
const GOAL := Vector3(2.2, 2.2, 1.0)
const SIDE_W := 11.0
const SIDE_D := 60.0
const VIEW_IN := 0.22
const VIEW_OUT := 0.3
const HP_MAX := 3
const OUT_DUR := 2.4
const RES_DUR := 1.6
const REC_T := 1.4
const OUT_O := Vector3(400, 0, 0)
const PICK_O := Vector3(-400, 0, 0)
const P_OUT := 0
const P_RUN := 1
const P_RES := 2
const P_PICK := 3
const EMS := [
	{"kind": "pot", "say": "뜨거운 냄비!", "ouch": "앗 뜨거!", "route": "nnnnnFnnnnGnnnnnE", "slack": 1.3},
	{"kind": "thorn", "say": "가시!", "ouch": "아야!", "route": "nnnnddddddnnFnnnGnnnnE", "slack": 1.2},
	{"kind": "door", "say": "문이 닫힌다!", "ouch": "꽉!", "route": "nnnFnnddddddGnnnFnnnnGnnnE", "slack": 1.1},
]

var phase := P_OUT
var ph_t := 0.0
var hb_t := 0.0
var hp := HP_MAX
var em := 0
var lap := 0
var thick := 0
var widen := 0
var won := false
# 신경
var stations: Array[Dictionary] = []
var marks: Array[MeshInstance3D] = []
var mark_s: Array[Vector3] = []
var mark_c: Array[Color] = []
var recs := {}
var route_n: Node3D
var sig: MeshInstance3D
var streak: MeshInstance3D
var flash: MeshInstance3D
var hp_n: Node3D
var hp_boxes: Array[MeshInstance3D] = []
var idx := 0
var from_p := Vector3.ZERO
var to_p := Vector3.ZERO
var cur_p := Vector3.ZERO
var leap_k := 1.0
var leap_dur := 0.09
var fx := 0.0
var hurt := 0.0
var stun := 0.0
var bounce := false
var cam_x := 0.0
var cam_z := 0.0
var view_k := 0.0
var view_hold := 0.0
var period := 0.6
var beat_t := 0.0
var used_beat := -999
var pulse := 0.0
var lit := -1
var nerve_t := 0.0
var nerve_max := 1.0
var rec_ph := 0.0
var rec_y := 0.0
var rec_in := false
# 바깥
var out_n: Node3D
var hand_n: Node3D
var threat_n: Node3D
var hand_parts: Array[MeshInstance3D] = []
var puffs: Array[MeshInstance3D] = []
var prog := 0.0
var h_from := Vector3.ZERO
var h_to := Vector3.ZERO
var h_back := Vector3.ZERO
var h_at := Vector3.ZERO
# 고르기
var pick_n: Node3D
var pick_l: MeshInstance3D
var pick_r: MeshInstance3D
var pips_n: Node3D


func _setup() -> void:
	howto = "나는 신경을 달리는 전기 신호.\n틱 박자에 탭하면 도약(딱 맞으면 두 칸), 갈림길은 초록 쪽을 탭.\n노란 수용체가 초록 칸에 오면 탭해서 건넌다.\n늦으면 손이 다친다. 3번 다치면 끝."
	time_limit = 0.0


func _reset() -> void:
	hp = HP_MAX
	em = 0
	lap = 0
	thick = 0
	widen = 0
	route_n = null
	out_n = null
	pips_n = null
	sig = box(Vector3.ZERO, Vector3.ONE * 0.7, ME)
	streak = box(Vector3.ZERO, Vector3.ONE, WHITE)
	flash = box(Vector3.ZERO, Vector3.ONE, D)
	streak.visible = false
	flash.visible = false
	hp_n = Node3D.new()
	world.add_child(hp_n)
	hp_boxes.clear()
	for i in HP_MAX:
		hp_boxes.append(box(Vector3((i - 1) * 0.5, 0, (i - 1) * 0.5), Vector3.ONE * 0.36, BAD, hp_n))
	_build_pick()
	_start_em()


func _ok_win() -> float:
	return 0.13 + widen * 0.035


func _perf_win() -> float:
	return 0.05 + widen * 0.012


func _open_w() -> float:
	return 0.45 + widen * 0.2


func _cur() -> String:
	return stations[idx]["k"]


# ---- 위급 하나: 바깥(느린 0.3초) → 신경 달리기 → 결과 ----
func _start_em() -> void:
	var e: Dictionary = EMS[em]
	_build_out(e["kind"])
	_build_route(e["route"])
	phase = P_OUT
	ph_t = OUT_DUR
	prog = 0.0
	_show(true, false, false)
	var head := "손 %d바퀴\n" % (lap + 1) if lap > 0 and em == 0 else ""
	msg(head + String(e["say"]), 1.8)
	beep(260.0, 0.6, 110.0, 0.25)  # 시간이 느려지는 소리
	hb_t = 0.3


func _show(o: bool, r: bool, p: bool) -> void:
	out_n.visible = o
	route_n.visible = r
	sig.visible = r
	hp_n.visible = r
	pick_n.visible = p
	if not r:
		streak.visible = false
		flash.visible = false


func _build_out(kind: String) -> void:
	if out_n:
		out_n.queue_free()
	out_n = Node3D.new()
	out_n.position = OUT_O
	world.add_child(out_n)
	puffs.clear()
	threat_n = Node3D.new()
	out_n.add_child(threat_n)
	box(Vector3(0, -0.6, 0), Vector3(14, 0.2, 14), WHITE, out_n)
	var rot := 0.0
	match kind:
		"pot":
			box(Vector3(0, -0.25, 0), Vector3(3.4, 0.5, 3.4), C, out_n)
			for i in 4:
				var a := i * TAU / 4.0
				box(Vector3(cos(a) * 0.9, 0.1, sin(a) * 0.9), Vector3(0.5, 0.3, 0.5), A if i % 2 == 0 else BAD, out_n)
			box(Vector3(0, 0.85, 0), Vector3(2.4, 1.3, 2.4), B, out_n)
			box(Vector3(0, 1.52, 0), Vector3(2.6, 0.14, 2.6), WHITE, out_n)
			box(Vector3(1.7, 1.2, 0), Vector3(0.9, 0.2, 0.3), INK, out_n)
			for i in 6:
				puffs.append(box(Vector3(randf_range(-0.7, 0.7), randf_range(1.8, 3.4), randf_range(-0.7, 0.7)), Vector3.ONE * 0.45, WHITE, out_n))
			h_from = Vector3(0.3, 3.6, 2.0)
			h_to = Vector3(0.3, 1.78, 0.9)
			h_back = Vector3(1.4, 4.8, 3.4)
		"thorn":
			box(Vector3(0, -0.3, 0), Vector3(6, 0.3, 1.8), A, out_n)
			var th := box(Vector3(-0.2, 0.15, 0), Vector3(0.14, 0.8, 0.14), INK, out_n)
			th.rotation_degrees = Vector3(0, 0, 20)
			h_from = Vector3(2.8, 0.38, 0.2)
			h_to = Vector3(-0.1, 0.38, 0.2)
			h_back = Vector3(1.6, 2.6, 1.4)
		"door":
			box(Vector3(0, 1.5, 0), Vector3(0.5, 4.2, 0.8), D, out_n)
			threat_n.position = Vector3(3.3, 0, 0)
			box(Vector3(-1.5, 1.5, 0), Vector3(2.9, 4.0, 0.25), B, threat_n)
			box(Vector3(-2.6, 1.5, 0.2), Vector3(0.2, 0.5, 0.2), INK, threat_n)
			h_from = Vector3(-0.75, 1.6, 0.1)
			h_to = h_from
			h_back = Vector3(-2.8, 1.6, 1.2)
			rot = -PI / 2.0
	_build_hand(rot)
	_out_pose()


## 손바닥·손가락·팔. 다친 만큼 빨간 화상 자국.
func _build_hand(rot: float) -> void:
	hand_n = Node3D.new()
	hand_n.rotation.y = rot
	out_n.add_child(hand_n)
	hand_parts.clear()
	hand_parts.append(box(Vector3.ZERO, Vector3(1.3, 0.35, 1.2), SOFT, hand_n))
	for i in 4:
		hand_parts.append(box(Vector3(-0.45 + 0.3 * i, 0, -0.95), Vector3(0.24, 0.3, 0.8 if i % 3 == 0 else 0.95), SOFT, hand_n))
	hand_parts.append(box(Vector3(0.78, 0, -0.15), Vector3(0.26, 0.28, 0.6), SOFT, hand_n))
	hand_parts.append(box(Vector3(0, 0, 1.7), Vector3(0.9, 0.4, 2.3), SOFT, hand_n))
	for i in HP_MAX - hp:
		_burn(i)


func _burn(i: int) -> void:
	box(Vector3(-0.35 + 0.35 * i, 0.03, 0.1 - 0.2 * (i % 2)), Vector3(0.34, 0.38, 0.34), BAD, hand_n)


func _out_pose() -> void:
	hand_n.position = h_from.lerp(h_to, prog)
	if EMS[em]["kind"] == "door":
		threat_n.rotation.y = deg_to_rad(75.0) * (1.0 - prog)


func _out_cam(k: float) -> void:
	cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	cam.fov = 58.0
	cam.position = OUT_O + Vector3(1.4, 5.0, 8.2) - Vector3(0.2, 0.6, 1.4) * k
	cam.look_at(OUT_O + Vector3(0, 1.2, 0))


func _heart(dt: float) -> void:
	hb_t -= dt
	if hb_t <= 0.0:
		hb_t = 0.85
		beep(110.0, 0.12, 70.0, 0.3)


func _step(dt: float) -> void:
	match phase:
		P_OUT:
			_step_out(dt)
		P_RUN:
			_step_run(dt)
		P_RES:
			_step_res(dt)
		P_PICK:
			_step_pick(dt)
	if phase != P_RUN:
		gauge(float(hp) / HP_MAX, BAD)


## 바깥: 거의 멈춘 시간. 손이 아주 천천히 위험으로 다가간다.
func _step_out(dt: float) -> void:
	_heart(dt)
	ph_t -= dt
	var k := 1.0 - ph_t / OUT_DUR
	prog = 0.35 * k
	_out_pose()
	for pf in puffs:
		pf.position.y += dt * 0.04
	_out_cam(k)
	if ph_t <= 0.0:
		_start_run()


func _step_res(dt: float) -> void:
	_heart(dt)
	ph_t -= dt
	var el := RES_DUR - ph_t
	if won:
		var k := minf(el / 0.15, 1.0)
		hand_n.position = h_at.lerp(h_back, 1.0 - pow(1.0 - k, 3.0))
	else:
		prog = minf(prog + dt / 0.12, 1.0)
		_out_pose()
		if el < 0.7:
			hand_n.position.x += sin(el * 80.0) * 0.12
	for pf in puffs:  # 시간이 다시 흐른다
		pf.position.y += dt * 2.5
		if pf.position.y > 3.8:
			pf.position.y = 1.8
	_out_cam(1.0)
	if ph_t > 0.0:
		return
	if won:
		_open_pick()
	elif hp <= 0:
		msg("손 실패", 2.0)
		end()
	else:
		_start_em()


# ---- 신경 ----
func _build_route(code: String) -> void:
	if route_n:
		route_n.queue_free()
	route_n = Node3D.new()
	world.add_child(route_n)
	stations.clear()
	marks.clear()
	mark_s.clear()
	mark_c.clear()
	recs.clear()
	var p := Vector3.ZERO
	for i in code.length():
		var k := code[i]
		var s := {"p": p, "k": k}
		var nx := p
		match k:
			"n":
				nx = p + Vector3(0, 0, -SEG)
			"d":
				nx = p + Vector3(0, 0, -DSEG)
			"F":
				var side := 1.0 if randf() < 0.5 else -1.0
				s["side"] = side
				s["dead"] = p + Vector3(-side * ARM, 0, -ARM)
				nx = p + Vector3(side * ARM, 0, -ARM)
			"G":
				nx = p + Vector3(0, 0, -GAP)
		stations.append(s)
		p = nx
	var sw := 1.2 + 0.3 * thick  # 두꺼워진 수초가 보인다
	var ow := _open_w()
	for i in stations.size():
		var s := stations[i]
		var a: Vector3 = s["p"]
		var k: String = s["k"]
		var sz := NODE
		var c := B
		match k:
			"d":
				sz = NODE * 0.7
				c = C
			"F":
				sz = NODE * 1.4
				c = D
			"G":
				sz = Vector3(1.8, 1.8, 0.9)
			"E":
				sz = GOAL
				c = GOOD
		marks.append(box(a, sz, c, route_n))
		mark_s.append(sz)
		mark_c.append(c)
		if k == "E":
			break
		var b: Vector3 = stations[i + 1]["p"]
		match k:
			"n":
				_seg(a, b, 0.3, A)
				box((a + b) * 0.5, Vector3(sw, sw, SEG - 0.7), SOFT, route_n)
			"d":
				_seg(a, b, 0.3, A)
				box((a + b) * 0.5 + Vector3(0, 0.45 if i % 2 == 0 else -0.45, 0), Vector3(0.35, 0.25, 0.35), SOFT, route_n)
			"F":
				var dead: Vector3 = s["dead"]
				_seg(a, b, 0.4, GOOD)
				_seg(a, dead, 0.4, C)
				box(dead, Vector3.ONE * 1.4, BAD, route_n)
			"G":
				var m := (a + b) * 0.5
				for sy in [-1.0, 1.0]:
					box(m + Vector3(0, sy * (ow + 0.5), 0), Vector3(0.3, 0.2, 1.8), GOOD, route_n)
				recs[i] = box(m + Vector3(0, 2.4, 0), Vector3(0.6, 0.8, 1.2), D, route_n)


func _seg(a: Vector3, b: Vector3, w: float, color: Color) -> MeshInstance3D:
	var m := box(Vector3.ZERO, Vector3.ONE, color, route_n)
	_place(m, a, b, w)
	return m


## 상자를 a→b 막대로 눕힌다
func _place(m: MeshInstance3D, a: Vector3, b: Vector3, w: float) -> void:
	var d := b - a
	var ln := d.length()
	if ln < 0.01:
		m.transform = Transform3D(Basis.from_scale(Vector3(w, w, 0.01)), a)
		return
	var bas := Basis.looking_at(d / ln, Vector3.UP)
	m.transform = Transform3D(bas * Basis.from_scale(Vector3(w, w, ln)), (a + b) * 0.5)


func _start_run() -> void:
	phase = P_RUN
	_show(false, true, false)
	idx = 0
	cur_p = stations[0]["p"]
	from_p = cur_p
	to_p = cur_p
	leap_k = 1.0
	fx = 0.0
	hurt = 0.0
	stun = 0.0
	bounce = false
	cam_x = 0.0
	cam_z = 0.0
	view_k = 0.0
	view_hold = 0.0
	lit = -1
	period = 60.0 / (100.0 + thick * 12.0 + lap * 6.0)
	beat_t = -period * 2.0
	used_beat = -999
	var est := 0.6 * 2.0
	for s in stations:
		match s["k"]:
			"n", "d":
				est += 0.6
			"F":
				est += 0.9
			"G":
				est += 1.2
	nerve_max = est * float(EMS[em]["slack"]) * pow(0.88, lap) + 0.6
	nerve_t = nerve_max
	for i in HP_MAX:
		hp_boxes[i].material_override = mat(BAD if i < hp else WHITE)
	msg("떼라!", 0.6)


func _step_run(dt: float) -> void:
	nerve_t -= dt
	if nerve_t <= 0.0:
		nerve_t = 0.0
		_result(false)
		return
	var before := floori(beat_t / period)
	beat_t += dt
	var n := floori(beat_t / period)
	if n > before:
		pulse = 1.0
		beep(1500.0 if n % 4 == 0 else 1000.0, 0.03, 0.0, 0.25)
	pulse = maxf(pulse - dt * 5.0, 0.0)
	hurt = maxf(hurt - dt, 0.0)
	fx = maxf(fx - dt * 4.0, 0.0)
	stun = maxf(stun - dt, 0.0)
	if bounce and stun <= 0.0:
		bounce = false
		_move(stations[idx]["p"], 0.15)
		beep(400.0, 0.08, 700.0, 0.15)
	leap_k = minf(leap_k + dt / leap_dur, 1.0)
	cur_p = from_p.lerp(to_p, 1.0 - pow(1.0 - leap_k, 3.0))
	var shake := sin(beat_t * 90.0) * 0.5 * hurt
	var k := _cur()
	sig.position = cur_p + Vector3(shake, shake, 0)
	sig.scale = Vector3.ONE * (0.7 + 0.5 * pulse)
	sig.material_override = mat(BAD if hurt > 0.0 else (C if k == "d" else ME))
	hp_n.position = cur_p + Vector3(0, 1.4, 0)
	# 다음 마디가 박자에 맞춰 깜빡인다
	var want := idx + 1 if k == "n" or k == "d" else -1
	if want != lit:
		if lit >= 0:
			marks[lit].material_override = mat(mark_c[lit])
			marks[lit].scale = mark_s[lit]
		lit = want
	if lit >= 0:
		marks[lit].scale = mark_s[lit] * (1.0 + 0.6 * pulse)
		if stations[lit]["k"] != "E":
			marks[lit].material_override = mat(WHITE if pulse > 0.5 else D)
	# 시냅스 수용체가 오르내린다
	if k == "G" and recs.has(idx):
		var r: MeshInstance3D = recs[idx]
		rec_ph += dt * TAU / REC_T
		rec_y = sin(rec_ph) * 2.4
		var inside := absf(rec_y) < _open_w()
		if inside and not rec_in:
			beep(700.0, 0.04, 0.0, 0.12)
		rec_in = inside
		var m: Vector3 = (stations[idx]["p"] + stations[idx + 1]["p"]) * 0.5
		r.position = m + Vector3(0, rec_y, 0)
		r.material_override = mat(GOOD if inside else D)
	flash.visible = fx > 0.0
	streak.visible = fx > 0.0
	if fx > 0.0:
		flash.position = to_p
		flash.scale = Vector3.ONE * (3.2 * fx)
		flash.material_override = mat(WHITE if fx > 0.6 else D)
		_place(streak, from_p, to_p, 0.5 * fx)
	cam_x = lerpf(cam_x, cur_p.x, 1.0 - exp(-dt * 9.0))
	cam_z = lerpf(cam_z, cur_p.z, 1.0 - exp(-dt * 9.0))
	_view(dt)
	var frac := nerve_t / nerve_max
	gauge(frac, GOOD if frac > 0.3 else BAD)


## 2D 옆모습(직교)과 3D 추격(원근) 사이. 갈림길에서는 3D로 들어가 좌우가 보인다.
func _view(dt: float) -> void:
	view_hold -= dt
	if view_hold > 0.0:
		view_k = minf(view_k + dt / VIEW_IN, 1.0)
	else:
		view_k = maxf(view_k - dt / VIEW_OUT, 0.0)
	var k := view_k * view_k * (3.0 - 2.0 * view_k)
	var w := SIDE_W * (1.0 - 0.1 * fx)
	var side_c := cam_z - 2.5
	var side_pos := Vector3(cam_x + SIDE_D, 0, side_c)
	var chase_pos := Vector3(cam_x, 3.2, cam_z + 5.5)
	cam.position = side_pos.lerp(chase_pos, k)
	cam.look_at(Vector3(cam_x, 0, lerpf(side_c, cam_z - 6.0, k)))
	if view_k <= 0.0:
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = w
	else:
		cam.projection = Camera3D.PROJECTION_PERSPECTIVE
		var side_fov := rad_to_deg(2.0 * atan(w * 0.5 / SIDE_D))
		cam.fov = lerpf(side_fov, 70.0 + 18.0 * fx, k)


func _burst(hold: float) -> void:
	if view_hold <= 0.0 and view_k < 0.5:
		beep(300.0, 0.12, 900.0, 0.12)
	view_hold = maxf(view_hold, hold)


func _move(p: Vector3, dur: float) -> void:
	from_p = cur_p
	to_p = p
	leap_k = 0.0
	leap_dur = dur


## 다음 정거장으로 뛴다. 도착한 곳에 따라 안내.
func _go(ni: int, perfect: bool) -> void:
	var was := _cur()
	score += maxi(ni - idx, 0) + (1 if perfect else 0)
	_move(stations[ni]["p"], 0.28 if was == "d" else 0.09)
	idx = ni
	fx = 1.0
	var f := 440.0 * pow(2.0, float(ni) / float(stations.size()))
	beep(f, 0.1, f * 1.5, 0.28)
	if was == "F":
		view_hold = 0.35
	if perfect:
		msg("번쩍!", 0.35)
		_burst(0.45)
	match _cur():
		"F":
			msg("◀ 갈림 ▶", 1.0)
			_burst(99.0)
		"G":
			msg("시냅스!", 0.7)
			rec_ph = PI * 0.5
			rec_in = false
		"d":
			if was != "d":
				msg("손상 구간", 0.8)
				beep(180.0, 0.2, 120.0, 0.2)
		"E":
			_result(true)


func _tap(p: Vector2) -> void:
	match phase:
		P_OUT:
			if ph_t < OUT_DUR - 0.6:
				play("tap")
				_start_run()
		P_RUN:
			_tap_run(p)
		P_PICK:
			_tap_pick(p)


func _tap_run(p: Vector2) -> void:
	if beat_t < -_ok_win():  # 시작 전 두 박은 듣기만
		play("tap")
		return
	if stun > 0.0:
		beep(160.0, 0.04, 0.0, 0.12)
		return
	var k := _cur()
	match k:
		"F":
			var side := -1.0 if p.x < 360.0 else 1.0
			if side == float(stations[idx]["side"]):
				play("good")
				_go(idx + 1, false)
			else:
				_move(stations[idx]["dead"], 0.12)
				bounce = true
				stun = 0.7
				hurt = 0.5
				play("bad")
				msg("막힘!", 0.6)
		"G":
			if absf(rec_y) < _open_w():
				var r: MeshInstance3D = recs[idx]
				r.material_override = mat(GOOD)
				_go(idx + 1, false)
				beep(600.0, 0.18, 1800.0, 0.3)
				msg("건넜다!", 0.5)
				_burst(0.7)
			else:
				stun = 0.4
				hurt = 0.4
				play("bad")
				msg("닫힘", 0.4)
		_:
			var n := roundi(beat_t / period)
			var err := absf(beat_t - n * period)
			if err <= _ok_win() and n != used_beat and n >= 0:
				used_beat = n
				var perfect := err <= _perf_win()
				var step := 2 if perfect and k == "n" and stations[idx + 1]["k"] == "n" else 1
				_go(idx + step, perfect)
				return
			hurt = 0.3
			play("bad")
			msg("엇박", 0.4)
			if idx > 0 and (stations[idx - 1]["k"] == "n" or stations[idx - 1]["k"] == "d"):
				idx -= 1
				_move(stations[idx]["p"], 0.09)


## 배달 성공이면 손이 휙 빠지고, 늦으면 손이 다친다.
func _result(ok: bool) -> void:
	phase = P_RES
	ph_t = RES_DUR
	won = ok
	_show(true, false, false)
	h_at = hand_n.position
	view_hold = 0.0
	if ok:
		score += ceili(nerve_t) * 2
		play("win")
		msg("휙!", 0.8)
	else:
		hp -= 1
		play("bad")
		beep(140.0, 0.5, 60.0, 0.3)
		msg(String(EMS[em]["ouch"]), 1.2)
		for m in hand_parts:
			m.material_override = mat(BAD)
		_burn(HP_MAX - hp - 1)


# ---- 성장 고르기 ----
func _build_pick() -> void:
	pick_n = Node3D.new()
	pick_n.position = PICK_O
	world.add_child(pick_n)
	pick_l = box(Vector3(-1.75, -2.5, 0), Vector3(3.1, 4.6, 0.4), B, pick_n)
	box(Vector3(-1.75, -2.2, 0.3), Vector3(2.8, 0.25, 0.7), A, pick_n)
	box(Vector3(-1.75, -2.2, 0.35), Vector3(2.3, 1.6, 0.6), SOFT, pick_n)
	pick_r = box(Vector3(1.75, -2.5, 0), Vector3(3.1, 4.6, 0.4), D, pick_n)
	box(Vector3(1.75, -2.2, 0.3), Vector3(2.7, 0.9, 0.6), GOOD, pick_n)
	box(Vector3(1.75, -2.2, 0.4), Vector3(0.14, 1.4, 0.6), INK, pick_n)


func _open_pick() -> void:
	phase = P_PICK
	ph_t = 0.0
	_show(false, false, true)
	if pips_n:
		pips_n.queue_free()
	pips_n = Node3D.new()
	pick_n.add_child(pips_n)
	for i in thick:
		box(Vector3(-2.8 + 0.5 * i, -4.2, 0.3), Vector3.ONE * 0.36, WHITE, pips_n)
	for i in widen:
		box(Vector3(0.7 + 0.5 * i, -4.2, 0.3), Vector3.ONE * 0.36, WHITE, pips_n)
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 8.0
	cam.position = PICK_O + Vector3(0, 0, 10)
	cam.look_at(PICK_O)
	msg("◀빠르게  넓게▶", 99.0)


func _step_pick(dt: float) -> void:
	_heart(dt)
	ph_t += dt
	var s := 1.0 + 0.04 * sin(ph_t * 6.0)
	pick_l.scale = Vector3(3.1, 4.6, 0.4) * s
	pick_r.scale = Vector3(3.1, 4.6, 0.4) * (2.0 - s)


func _tap_pick(p: Vector2) -> void:
	if ph_t < 0.4:
		return
	if p.x < 360.0:
		thick += 1
	else:
		widen += 1
	play("good")
	em += 1
	if em >= EMS.size():
		em = 0
		lap += 1
		play("win")
	_start_em()
