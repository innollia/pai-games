extends Tofu
## 등불 경주 (옆모습 4인 밤길 경주, 코스 3개): 조이스틱 좌우(조금 밀면 천천히), 점프. 맨 앞 주자가 등불을 든다. 길은 등불 빛 안에서만 보이고 빛 밖 안개에 1.5초 넘게 있으면 길을 잃고 탈락. 등불을 든 1등은 빠를수록 등불이 뒤로 젖고 크게 흔들려 자기 앞은 어둡고 뒷사람 길만 밝다. 앞지르면 등불이 넘어온다. 결승선을 1등으로 넘으면 다음 코스(들길 → 가로등 마을 → 바람 고개).
# 한 문장: 나는 밤길 배달부로서 "길은 1등이 든 등불 빛 안에서만 보인다"는 제약 속에서 달려 결승선을 1등으로 넘지만, 등불을 들고 빨리 달릴수록 등불이 흔들려 내 앞은 어둡고 뒷사람 길만 밝혀 주는 대가를 감수한다.
# 부모 screenrace 에서 물려받은 것: 옆모습 4인 경주, 빠른 1등은 앞을 못 본다(속도 비례 시야), 보이는 범위 밖 = 탈락.
# 바꾼 것: 시야를 쥔 것은 카메라가 아니라 1등이 든 등불(눈에 보이는 빛). 1등의 속도가 뒷사람 길을 밝혀 준다. 짐·갈고리·아이템 없음.

const GRAV := 38.0
const JUMP_V := 15.0
const RUN_MAX := 10.5
const GROUND_ACC := 40.0
const AIR_ACC := 20.0
const FRICTION := 30.0
const MAX_FALL := 26.0
const HW := 0.4
const HH := 1.2
const STEP := 0.55
const COYOTE := 0.1
const JBUF := 0.12
const CAM_D := 22.0
const HWV := 9.5  # 화면 반폭
const BX0 := -60.0
const BK := 6.0
const ZR := 2.2  # 주자·등불·가로등 머리는 안개 앞에 그린다
const ZF := 1.6  # 안개 막
const LIGHT_R := 5.0
const LOST_T := 1.5  # 빛 밖에서 이만큼 있으면 길을 잃는다
const LAMP_AHEAD := 12.0  # 켜진 가로등이 앞으로 비추는 거리
const LAMP_SLOW := 6.5  # 이보다 느리게 지나가야 가로등이 켜진다
const LIVES := 3
const POOL_N := 120
const FOG_N := 6
const EDGE_N := 8
const BITS_N := 10
const SKY := Color("5b70d9")  # 밝은 남색 밤하늘
const FOG := Color("e4e8f7")  # 빛 밖 연한 안개
const GLOW := Color("ffe066")
const LAMP_OFF := Color("adb5bd")
const COURSES := [
	{"name": "들길", "rule": "", "say": "빛 안에서만 길이 보인다", "len": 190.0,
		"gnd": Color("f1d7a8"), "top": Color("8ce99a"), "wall": Color("f08c00"),
		"far": Color("8796ea"), "bld": [Color("748ffc"), Color("91a7ff")],
		"segs": ["flat", "pit", "wall", "stairs", "pit", "crates"]},
	{"name": "가로등 마을", "rule": "lamp", "say": "등불 들고 천천히 지나가면 가로등이 켜진다", "len": 250.0,
		"gnd": Color("ffe3e3"), "top": Color("ff8787"), "wall": Color("e64980"),
		"far": Color("8796ea"), "bld": [Color("fcc2d7"), Color("d0bfff"), Color("ffd8a8")],
		"segs": ["flat", "lamp", "pit", "stairs", "lamp", "roof", "wall"]},
	{"name": "바람 고개", "rule": "gust", "say": "휘파람이 불면 등불 빛이 뒤로 날린다", "len": 220.0,
		"gnd": Color("e3fafc"), "top": Color("66d9e8"), "wall": Color("1098ad"),
		"far": Color("9fb0f5"), "bld": [Color("a5d8ff"), Color("99e9f2")],
		"segs": ["flat", "pit", "stairs", "wall", "pit", "flat"]},
]


class Runner:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var grounded := false
	var alive := true
	var ai := true
	var nick := ""
	var col := Color.WHITE
	var node: Node3D
	var streaks: Array[MeshInstance3D] = []
	var poof: MeshInstance3D
	var poof_t := 0.0
	var lost := 0.0
	var coyote := 0.0
	var jbuf := 0.0
	var cut := true
	var skill := 1.0
	var err := 0.12
	var bold := 0.5  # 경쟁자: 등불을 들고 얼마나 빨리 달리나
	var think := 0.0
	var face := 1.0
	var sq := 0.0
	var mx := 0.0
	var i_jump := false
	var i_jheld := false


var ci := 0
var lives := LIVES
var phase := "count"
var pt := 0.0
var rt := 0.0
var cdef: Dictionary
var stage: Node3D
var rects: Array[Rect2] = []
var kinds := PackedInt32Array()
var buckets: Array = []
var goal_x := 0.0
var kill_y := -20.0
var gx := 0.0
var fy := 0.0
var min_fy := 0.0
var gen := RandomNumberGenerator.new()
var game_seed := 0
var runners: Array[Runner] = []
var pl: Runner
var bearer: Runner
var camx := 0.0
var camy := 2.0
var vhv := HWV
var shk := 0.0
# 등불
var lantern: Node3D
var lean := 0.0  # 등불 든 사람의 속도 비율 (클수록 뒤로 젖고 크게 흔들린다)
var swing_t := 0.0
var swing_sign := 1.0
var light_c := 0.0
var lit: Array[Vector2] = []  # 이번 프레임 밝은 구간 (x0, x1), 정렬·합침
var lamps: Array = []
var goal_node: Node3D
var gust_t := 0.0
var gust_on := false
var gust_warn := false
var hold_acc := 0.0
var tick := 0.0
var was_bearer := false
var round_won := false
# 그림
var fogs: Array[MeshInstance3D] = []
var edges: Array[MeshInstance3D] = []
var bits: Array = []
var bit_i := 0
var winds: Array[MeshInstance3D] = []
var wind_x := 0.0
var pips: Array[MeshInstance3D] = []
var marker: MeshInstance3D
var vspecs: Array = []
var vslot := PackedInt32Array()
var vpool: Array[MeshInstance3D] = []
var vfree: Array[int] = []
var v_last := Vector2(1e9, 0)


func _setup() -> void:
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	howto = "밤길 4인 경주! 맨 앞 사람이 등불을 든다. 길(구덩이·벽)은 등불 빛 안에서만 보이고, 빛 밖 안개에 1.5초 넘게 있으면 길을 잃고 탈락.\n조이스틱 좌우(조금만 밀면 천천히), [점프].\n앞지르면 등불이 내게 온다. 등불을 들고 빨리 달릴수록 등불이 뒤로 젖고 흔들려 내 앞은 어둡고 뒷사람 길만 밝다.\n결승선을 1등으로 넘으면 다음 코스. 목숨 3."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1120), 100.0, A)
	for e in get_children():
		if e is WorldEnvironment:
			(e as WorldEnvironment).environment.background_color = SKY


func _reset() -> void:
	ci = 0
	lives = LIVES
	stage = null
	game_seed = randi()
	runners.clear()
	var cols := [ME, A, Color("20c997"), Color("f783ac")]
	var nicks := ["나", "주황", "초록", "분홍"]
	for i in 4:
		var r := Runner.new()
		r.ai = i > 0
		r.col = cols[i]
		r.nick = nicks[i]
		_make_body(r)
		runners.append(r)
	pl = runners[0]
	# 등불: 손잡이 끝을 축으로 기운다
	lantern = Node3D.new()
	world.add_child(lantern)
	box(Vector3(0, 0.45, 0), Vector3(0.08, 0.9, 0.08), INK, lantern)
	box(Vector3(0, 1.05, 0), Vector3(0.5, 0.55, 0.5), GLOW, lantern)
	box(Vector3(0, 1.05, 0.28), Vector3(0.24, 0.3, 0.05), WHITE, lantern)
	box(Vector3(0, 1.38, 0), Vector3(0.6, 0.1, 0.6), INK.lightened(0.2), lantern)
	marker = box(Vector3.ZERO, Vector3(0.36, 0.36, 0.36), ME)
	marker.rotation.z = PI * 0.25
	pips.clear()
	for i in LIVES:
		pips.append(box(Vector3.ZERO, Vector3(0.22, 0.22, 0.22), BAD))
	fogs.clear()
	for i in FOG_N:
		var m := box(Vector3(0, -80, ZF), Vector3.ONE, FOG)
		m.visible = false
		fogs.append(m)
	edges.clear()
	for i in EDGE_N:
		var m := box(Vector3(0, -80, ZF + 0.05), Vector3.ONE, GLOW)
		m.visible = false
		edges.append(m)
	vpool.clear()
	for i in POOL_N:
		var m := box(Vector3(0, -80, 0), Vector3.ONE, WHITE)
		m.visible = false
		vpool.append(m)
	bits.clear()
	for i in BITS_N:
		var m := box(Vector3(0, -80, 0), Vector3(0.26, 0.26, 0.26), WHITE)
		m.visible = false
		bits.append({"node": m, "v": Vector3.ZERO, "life": 0.0})
	winds.clear()
	for i in 4:
		var m := box(Vector3(0, -80, 4.0), Vector3(2.5, 0.06, 0.06), WHITE)
		m.visible = false
		winds.append(m)
	_build_course()
	_start_round()


func _make_body(r: Runner) -> void:
	r.node = Node3D.new()
	world.add_child(r.node)
	box(Vector3(0, 0, 0), Vector3(HW * 2.0, HH * 0.75, 0.8), r.col, r.node)
	box(Vector3(0, 0.63, 0), Vector3(0.42, 0.36, 0.5), SOFT, r.node)
	box(Vector3(0.05, 0.88, 0), Vector3(0.6, 0.14, 0.6), WHITE if not r.ai else r.col.darkened(0.2), r.node)
	r.poof = box(Vector3.ZERO, Vector3(1, 1, 1), WHITE)
	r.poof.visible = false
	for k in 2:
		var s := box(Vector3.ZERO, Vector3(1, 0.07, 0.07), WHITE)
		s.visible = false
		r.streaks.append(s)


# ---- 코스 만들기 ----
func _build_course() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	cdef = COURSES[ci]
	rects.clear()
	kinds = PackedInt32Array()
	lamps.clear()
	vspecs.clear()
	vslot.clear()
	vfree.clear()
	for k in vpool.size():
		vpool[k].visible = false
		vfree.append(k)
	v_last = Vector2(1e9, 0)
	gen.seed = game_seed + ci * 7919
	fy = 0.0
	min_fy = 0.0
	gx = -40.0
	_floor(gx, 50.0)
	gx = 10.0
	var goal: float = cdef.len
	var segs: Array = cdef.segs
	var last := ""
	while gx < goal:
		var s: String = segs[gen.randi() % segs.size()]
		if s == last and s != "flat":
			s = "flat"
		if gx < 26.0 and s != "flat" and s != "stairs":
			s = "flat"  # 출발 직후는 몸 풀기
		last = s
		_seg(s)
	goal_x = gx + 2.0
	_floor(gx, 60.0)
	kill_y = min_fy - 6.0
	# 결승 깃발 (안개 앞에 그려서 늘 보인다)
	goal_node = Node3D.new()
	stage.add_child(goal_node)
	box(Vector3(0, 2.6, 0), Vector3(0.3, 5.2, 0.3), GOOD, goal_node)
	for k in 4:
		box(Vector3(0.45 + (k % 2) * 0.45, 4.85 - float(k >= 2) * 0.45, 0), Vector3(0.45, 0.45, 0.1), WHITE if k == 0 or k == 3 else INK, goal_node)
	goal_node.set_meta("y", fy)
	# 칸 나누기
	buckets.clear()
	var nb := int((gx + 100.0 - BX0) / BK) + 1
	for b in nb:
		buckets.append([])
	for i in rects.size():
		var rc := rects[i]
		for b in range(_bi(rc.position.x), _bi(rc.end.x) + 1):
			buckets[b].append(i)
	# 뒤 집·언덕 (원근으로 느리게 지나간다)
	var bx := -40.0
	var bld: Array = cdef.bld
	while bx < gx + 60.0:
		var w := gen.randf_range(3.5, 7.0)
		var h := gen.randf_range(6.0, 16.0)
		var c: Color = bld[gen.randi() % bld.size()]
		_vbox(Vector3(bx + w * 0.5, h * 0.5 - 10.0, -12.0 - gen.randf() * 3.0), Vector3(w, h, 3.0), c)
		if cdef.rule == "lamp" and gen.randf() < 0.7:
			_vbox(Vector3(bx + w * 0.5, h - 12.0, -10.4), Vector3(0.9, 0.9, 0.2), GLOW)  # 불 켜진 창
		bx += w + gen.randf_range(1.0, 3.0)
	var fx := -60.0
	while fx < gx + 120.0:
		var w := gen.randf_range(12.0, 22.0)
		var h := gen.randf_range(12.0, 26.0)
		var farc: Color = cdef.far
		_vbox(Vector3(fx + w * 0.5, h * 0.3 - 12.0, -34.0), Vector3(w, h * 0.6, 2.0), farc.lightened(gen.randf() * 0.15))
		fx += w * 0.8
	# 달과 별
	var sx := -30.0
	while sx < gx + 80.0:
		_vbox(Vector3(sx, gen.randf_range(10.0, 20.0), -30.0), Vector3(0.35, 0.35, 0.2), WHITE)
		sx += gen.randf_range(5.0, 11.0)
	var mxx := -20.0
	while mxx < gx + 80.0:
		_vbox(Vector3(mxx, 17.0, -40.0), Vector3(3.2, 3.2, 0.5), Color("fff9db"))
		mxx += 90.0


func _seg(s: String) -> void:
	var wallc: Color = cdef.wall
	match s:
		"flat":
			var w := gen.randf_range(6.0, 11.0)
			_floor(gx, w)
			gx += w
		"stairs":
			var up := fy < -1.0 or (fy < 4.0 and gen.randf() < 0.55)
			for k in 5:
				_floor(gx, 1.3)
				gx += 1.3
				fy += 0.5 if up else -0.5
			_floor(gx, 3.0)
			gx += 3.0
		"wall":
			_floor(gx, 9.0)
			_solid(Rect2(gx + 4.0, fy, 0.9, gen.randf_range(1.2, 2.0)), wallc)
			gx += 9.0
		"pit":
			_floor(gx, 2.0)
			gx += 2.0 + gen.randf_range(3.0, 4.2 if ci == 0 else 4.8)
			fy = clampf(fy + gen.randf_range(-1.0, 1.0), -3.0, 6.0)
			_floor(gx, 5.0)
			gx += 5.0
		"crates":
			_floor(gx, 12.0)
			_solid(Rect2(gx + 3.0, fy, 1.2, 1.0), wallc)
			_solid(Rect2(gx + 8.0, fy, 1.2, 1.7), wallc)
			gx += 12.0
		"lamp":  # 꺼진 가로등, 그 앞 12m 안에 구덩이와 벽
			_floor(gx, 5.0)
			var lx := gx + 1.5
			_vbox(Vector3(lx, fy + 1.8, -1.6), Vector3(0.2, 3.6, 0.2), INK.lightened(0.3))
			var head := box(Vector3(lx, fy + 3.7, ZR), Vector3(0.7, 0.45, 0.5), LAMP_OFF, stage)
			lamps.append({"x": lx, "y": fy + 3.7, "lit": false, "head": head})
			gx += 5.0
			_floor(gx, 2.0)
			gx += 2.0 + gen.randf_range(3.6, 4.6)
			_floor(gx, 8.0)
			_solid(Rect2(gx + 4.0, fy, 0.9, gen.randf_range(1.3, 1.9)), wallc)
			gx += 8.0
		"roof":  # 지붕 사이 틈 (높이가 바뀐다)
			_floor(gx, gen.randf_range(5.0, 8.0))
			gx = rects[rects.size() - 1].end.x
			var g := gen.randf_range(3.8, 5.0)
			var ny := clampf(fy + gen.randf_range(-1.5, 1.0), -3.0, 6.0)
			gx += g
			fy = ny
			_floor(gx, 5.0)
			gx += 5.0
	min_fy = minf(min_fy, fy)


func _floor(x: float, w: float) -> void:
	_solid(Rect2(x, fy - 14.0, w, 14.0), cdef.gnd)
	_vbox(Vector3(x + w * 0.5, fy - 0.1, 0), Vector3(w, 0.2, 2.5), cdef.top)


func _solid(rc: Rect2, c: Color) -> void:
	rects.append(rc)
	kinds.append(0)
	var m := rc.get_center()
	_vbox(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, 2.4), c)


## 코스 상자 명세 (실제 상자는 화면 근처일 때만 풀에서 빌린다)
func _vbox(pos: Vector3, size: Vector3, c: Color) -> void:
	vspecs.append([pos, size, c])
	vslot.resize(vspecs.size())
	vslot[vspecs.size() - 1] = -1


func _vis() -> void:
	if absf(camx - v_last.x) < 0.4 and absf(camy - v_last.y) < 0.4:
		return
	v_last = Vector2(camx, camy)
	for i in vspecs.size():
		var sp: Array = vspecs[i]
		var p: Vector3 = sp[0]
		var s: Vector3 = sp[1]
		var f := (CAM_D - p.z) / CAM_D
		var inside := absf(p.x - camx) - s.x * 0.5 < HWV * f + 4.0 and absf(p.y - camy) - s.y * 0.5 < vhv * f + 4.0
		var k := vslot[i]
		if inside and k < 0 and not vfree.is_empty():
			k = vfree.pop_back()
			vslot[i] = k
			var m := vpool[k]
			m.position = p
			m.scale = s
			m.material_override = mat(sp[2])
			m.visible = true
		elif not inside and k >= 0:
			vpool[k].visible = false
			vfree.append(k)
			vslot[i] = -1


func _bi(x: float) -> int:
	return clampi(int(floor((x - BX0) / BK)), 0, buckets.size() - 1)


# ---- 판 ----
func _start_round() -> void:
	var xs := [-2.4, 0.0, -1.2, -3.6]  # 첫 판은 경쟁자가 등불을 들고 내 앞에서 출발
	for i in 4:
		var r := runners[i]
		r.p = Vector2(xs[i], 0.0)
		r.v = Vector2.ZERO
		r.alive = true
		r.lost = 0.0
		r.cut = true
		r.face = 1.0
		r.poof_t = 0.0
		r.poof.visible = false
		r.node.visible = true
		r.sq = 0.0
		r.mx = 0.0
		if r.ai:
			r.skill = 0.94 + 0.03 * ci + (i - 2) * 0.02
			r.err = 0.14 - 0.03 * ci
			r.bold = randf_range(0.35, 0.95)
		_probe(r)
	for lp in lamps:
		lp.lit = false
		(lp.head as MeshInstance3D).material_override = mat(LAMP_OFF)
	for b in bits:
		b.life = 0.0
		(b.node as Node3D).visible = false
	bearer = runners[1]
	was_bearer = false
	lean = 0.0
	swing_t = 0.0
	light_c = bearer.p.x + 3.0
	gust_t = 0.0
	gust_on = false
	gust_warn = false
	camx = 1.5
	camy = 2.0
	rt = 0.0
	phase = "count"
	pt = 2.0
	_lights()
	msg("%s: %s" % [cdef.name, cdef.say], 2.2)
	beep(440.0, 0.12)


func _step(dt: float) -> void:
	shk = maxf(shk - dt * 2.5, 0.0)
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.8 and pt <= 0.8:
				msg("등불 빛 안에 붙어라", 0.9)
				beep(440.0, 0.12)
			if pt <= 0.0:
				phase = "race"
				msg("달려!", 0.6)
				play("good")
		"race":
			rt += dt
			_race(dt)
		"roundend":
			pt -= dt
			if pt <= 0.0:
				_after_round()
	_lantern(dt)
	_lights()
	_camera(dt)
	_draw_all(dt)


func _race(dt: float) -> void:
	pl.mx = kit_move.x
	pl.i_jump = kit_just("jump")
	pl.i_jheld = kit_held("jump")
	if cdef.rule == "gust":
		_gust(dt)
	for r in runners:
		if r.alive and r.ai:
			_ai(r, dt)
	for r in runners:
		if r.alive:
			_runner(r, dt)
	_pass_lantern()
	if cdef.rule == "lamp":
		_lamp_check()
	# 빛 밖은 안개: 오래 있으면 길을 잃는다 (등불 든 사람은 빼고)
	var left := camx - HWV
	for r in runners:
		if not r.alive:
			continue
		if r.p.y < kill_y or r.p.y < camy - vhv - 1.0:
			_out(r, "떨어졌다!")
			continue
		if r.p.x + HW < left:
			_out(r, "어둠에 남겨졌다!")
			continue
		if r == bearer or _lit(r.p.x):
			r.lost = maxf(r.lost - dt * 1.5, 0.0)
		else:
			r.lost += dt
			if r.lost >= LOST_T:
				_out(r, "안개에 길을 잃었다!")
	if phase != "race":
		return
	for r in runners:
		if r.alive and r.p.x > goal_x:
			_round_over(r)
			return
	if not pl.alive:
		_round_over(null)
		return
	# 등불을 들고 있는 동안 점수
	if bearer == pl:
		hold_acc += dt
		if hold_acc >= 1.0:
			hold_acc -= 1.0
			score += 1
		if not was_bearer:
			msg("등불! 빨리 달리면 앞이 안 보인다", 1.1)
			beep(990.0, 0.1, 1480.0, 0.24)
		var fwd := clampf((lit_front(pl.p.x) - pl.p.x) / 8.0, 0.0, 1.0)
		gauge(fwd, D)
	else:
		if was_bearer and pl.alive:
			msg("등불을 뺏겼다: 빛 안에 붙어라", 1.0)
			beep(500.0, 0.2, 260.0, 0.22)
		var safe := 1.0 - pl.lost / LOST_T
		gauge(safe, GOOD if pl.lost <= 0.0 else (A if safe > 0.4 else BAD))
		tick -= dt
		if pl.lost > 0.0 and tick <= 0.0:
			tick = 0.08 + safe * 0.25
			beep(1100.0 - safe * 400.0, 0.04, 0.0, 0.15)
	was_bearer = bearer == pl


## 맨 앞 주자가 0.5m 넘게 앞지르면 등불이 넘어간다. 든 사람이 탈락하면 다음 1등에게.
func _pass_lantern() -> void:
	var lead: Runner = null
	for r in runners:
		if r.alive and (lead == null or r.p.x > lead.p.x):
			lead = r
	if lead == null:
		return
	if bearer == null or not bearer.alive or (lead != bearer and lead.p.x > bearer.p.x + 0.5):
		var had := bearer != null and bearer.alive
		bearer = lead
		if had:
			_snd(lead, 880.0, 0.08, 1320.0, 0.2)
			if lead != pl:
				msg("%s가 등불을 가져갔다" % lead.nick, 0.6)


## 가로등 마을: 등불 든 사람이 천천히 지나가면 켜져서 앞 12m를 계속 밝힌다
func _lamp_check() -> void:
	if bearer == null:
		return
	for lp in lamps:
		if lp.lit:
			continue
		var lx: float = lp.x
		if absf(bearer.p.x - lx) < 1.3:
			if absf(bearer.v.x) < LAMP_SLOW:
				lp.lit = true
				(lp.head as MeshInstance3D).material_override = mat(GLOW)
				_burst(Vector3(lx, lp.y, ZR), 3, GLOW)
				if bearer == pl:
					score += 5
					play("good")
					msg("가로등 켜짐 +5", 0.7)
				else:
					beep(760.0, 0.1, 1100.0, 0.16)
			elif bearer == pl and absf(bearer.p.x - lx) < 0.2:
				msg("너무 빨라서 못 켰다", 0.6)


## 바람 고개: 8초마다 휘파람 1초 뒤 1.5초 돌풍. 빛이 뒤로 날리고 모두 뒤로 밀린다
func _gust(dt: float) -> void:
	gust_t += dt
	var cyc := fmod(gust_t, 8.0)
	var warn := cyc > 5.5 and cyc < 6.5
	var now := cyc >= 6.5
	if warn and not gust_warn:
		beep(1200.0, 0.5, 1800.0, 0.18)
		msg("휘이익", 0.6)
	if now and not gust_on:
		beep(300.0, 0.6, 150.0, 0.25)
		msg("돌풍!", 0.7)
		shk = maxf(shk, 0.25)
	gust_warn = warn
	gust_on = now
	if gust_on:
		for r in runners:
			if r.alive:
				r.v.x -= 9.0 * dt


func _out(r: Runner, why: String) -> void:
	r.alive = false
	r.node.visible = false
	r.poof.visible = true
	r.poof_t = 0.5
	r.poof.position = _front(clampf(r.p.x, camx - HWV + 0.6, camx + HWV), maxf(r.p.y, camy - vhv + 2.0), ZR)
	_burst(r.poof.position, 5, r.col)
	if r == pl:
		play("bad")
		shk = 0.6
		msg(why, 1.2)
	else:
		beep(300.0, 0.2, 120.0, 0.25)
		shk = maxf(shk, 0.25)
		msg("%s 탈락" % r.nick, 0.6)


func _round_over(w: Runner) -> void:
	phase = "roundend"
	pt = 2.0
	round_won = w == pl
	if w == pl:
		score += 30 + 10 * lives
		play("win")
		msg("1등 도착!", 1.8)
		return
	lives -= 1
	if w != null:
		beep(330.0, 0.3, 200.0, 0.25)
		msg("%s 1등. 목숨 %d" % [w.nick, lives], 1.8)
	else:
		msg("목숨 %d" % lives, 1.8)


func _after_round() -> void:
	if lives <= 0:
		msg("등불이 꺼졌다", 3.0)
		end()
		return
	if round_won:
		if ci >= COURSES.size() - 1:
			score += 50
			msg("완주!", 3.0)
			end()
			return
		ci += 1
		_build_course()
	_start_round()


# ---- 달리기 한 명 ----
func _top(r: Runner) -> float:
	return RUN_MAX * (r.skill if r.ai else 1.0)


func _runner(r: Runner, dt: float) -> void:
	var top := _top(r)
	var mx := clampf(r.mx, -1.0, 1.0)
	r.coyote = COYOTE if r.grounded else maxf(r.coyote - dt, 0.0)
	r.jbuf = JBUF if r.i_jump else maxf(r.jbuf - dt, 0.0)
	if r.jbuf > 0.0 and r.coyote > 0.0:
		r.v.y = JUMP_V
		r.coyote = 0.0
		r.jbuf = 0.0
		r.grounded = false
		r.cut = false
		r.sq = -0.3
		_snd(r, 600.0, 0.07, 900.0)
	if not r.cut and r.v.y > 0.0 and not r.i_jheld:
		r.v.y *= 0.5
		r.cut = true
	var acc := GROUND_ACC if r.grounded else AIR_ACC
	if absf(mx) > 0.12:
		# 스틱을 조금 밀면 천천히: 목표 속도 = 스틱 세기 × 최고 속도
		var want := mx * top
		r.v.x = move_toward(r.v.x, want, acc * dt)
		r.face = signf(mx)
	else:
		r.v.x = move_toward(r.v.x, 0.0, (FRICTION if r.grounded else 4.0) * dt)
	r.v.y = maxf(r.v.y - GRAV * dt, -MAX_FALL)
	var was_g := r.grounded
	var vy0 := r.v.y
	for s in 2:
		_mx(r, r.v.x * dt * 0.5)
		_my(r, r.v.y * dt * 0.5)
	_probe(r)
	if r.grounded and not was_g and vy0 < -6.0:
		r.sq = clampf(-vy0 / 40.0, 0.15, 0.5)
		_snd(r, 200.0, 0.05, 0.0, 0.12)
	r.sq = move_toward(r.sq, 0.0, dt * 2.5)


func _box(r: Runner) -> Rect2:
	return Rect2(r.p.x - HW, r.p.y, HW * 2.0, HH)


func _mx(r: Runner, dx: float) -> void:
	if dx == 0.0:
		return
	r.p.x += dx
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if not q.intersects(a):
				continue
			if r.grounded and q.end.y - r.p.y <= STEP:
				r.p.y = q.end.y
				a = _box(r)
				continue
			if dx > 0.0:
				r.p.x = q.position.x - HW - 0.001
			else:
				r.p.x = q.end.x + HW + 0.001
			if absf(r.v.x) > 8.0:
				_snd(r, 160.0, 0.1, 80.0, 0.25)
				r.sq = -0.3
				if r == pl:
					shk = maxf(shk, 0.3)
					_burst(_front(r.p.x + HW, r.p.y + 0.8, ZR), 2, cdef.wall)
			if signf(r.v.x) == signf(dx):
				r.v.x = 0.0
			a = _box(r)


func _my(r: Runner, dy: float) -> void:
	if dy == 0.0:
		return
	r.p.y += dy
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if q.intersects(a):
				if dy < 0.0:
					r.p.y = q.end.y
					r.v.y = 0.0
				else:
					r.p.y = q.position.y - HH - 0.001
					r.v.y = minf(r.v.y, 0.0)
				a = _box(r)


func _probe(r: Runner) -> void:
	var f := Rect2(r.p.x - HW + 0.05, r.p.y - 0.06, HW * 2.0 - 0.1, 0.07)
	r.grounded = false
	for b in range(_bi(f.position.x), _bi(f.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if q.intersects(f) and q.end.y <= r.p.y + 0.02:
				r.grounded = true
				return


func _floor_top(x: float, ymax: float) -> float:
	var best_y := -1.0e9
	for i in buckets[_bi(x)]:
		var q: Rect2 = rects[i]
		if x > q.position.x and x < q.end.x and q.end.y <= ymax:
			best_y = maxf(best_y, q.end.y)
	return best_y


func _solid_in(a: Rect2) -> bool:
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			if (rects[i] as Rect2).intersects(a):
				return true
	return false


func _snd(r: Runner, f: float, d: float, to := 0.0, vol := 0.18) -> void:
	if r == pl:
		beep(f, d, to, vol)
	elif r.alive and absf(r.p.x - camx) < HWV:
		beep(f, d, to, vol * 0.45)


# ---- 등불과 빛 ----
func _lantern(dt: float) -> void:
	if bearer == null:
		return
	var f := 0.0
	if phase == "race" or phase == "roundend":
		f = clampf((absf(bearer.v.x) - 3.0) / (RUN_MAX - 3.0), 0.0, 1.0)
	lean = lerpf(lean, f, 1.0 - exp(-4.0 * dt))
	var amp := lerpf(0.4, 3.2, lean)
	swing_t += dt * lerpf(2.2, 8.0, lean)
	var sw := sin(swing_t) * amp
	var back := lerpf(3.0, -4.0, lean) - (4.5 if gust_on else 0.0)
	light_c = bearer.p.x + back + sw
	# 흔들림 끝마다 삐걱 (빠를수록 박자가 빠르다)
	var sg := signf(cos(swing_t))
	if sg != swing_sign:
		swing_sign = sg
		if lean > 0.25 and phase == "race" and absf(bearer.p.x - camx) < HWV:
			beep(260.0 + lean * 260.0, 0.04, 0.0, 0.08 + lean * 0.06)


## 밝은 구간: 등불 빛 + 켜진 가로등 (정렬·합침)
func _lights() -> void:
	var raw: Array[Vector2] = []
	if bearer and bearer.alive:
		raw.append(Vector2(light_c - LIGHT_R, light_c + LIGHT_R))
	for lp in lamps:
		if lp.lit:
			var lx: float = lp.x
			raw.append(Vector2(lx - 2.0, lx + LAMP_AHEAD))
	raw.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	lit.clear()
	for iv in raw:
		if not lit.is_empty() and iv.x <= lit[lit.size() - 1].y:
			var top := lit[lit.size() - 1]
			lit[lit.size() - 1] = Vector2(top.x, maxf(top.y, iv.y))
		else:
			lit.append(iv)


func _lit(x: float) -> bool:
	for iv in lit:
		if x >= iv.x and x <= iv.y:
			return true
	return false


## x 를 품은 밝은 구간의 앞 끝 (어두우면 x)
func lit_front(x: float) -> float:
	for iv in lit:
		if x >= iv.x and x <= iv.y:
			return iv.y
	return x


# ---- 경쟁자 ----
func _ai(r: Runner, dt: float) -> void:
	r.i_jump = false
	r.i_jheld = true
	r.think -= dt
	if r.think > 0.0:
		return
	r.think = randf_range(0.04, 0.09) / r.skill
	var near_goal := goal_x - r.p.x < 40.0
	if r == bearer:
		# 조심스러운 경쟁자는 등불을 들면 늦춰서 앞을 본다
		r.mx = lerpf(0.45, 1.0, r.bold)
		if near_goal:
			r.mx = 1.0
	elif bearer != null:
		var l := light_c - LIGHT_R
		var want_lead := near_goal or (r.bold > 0.75 and randf() < 0.02)
		if r.p.x < l + 1.2 or not _lit(r.p.x):
			r.mx = 1.0  # 빛 뒤 끝에 걸렸다: 따라붙는다
		elif want_lead:
			r.mx = 1.0
		elif r.p.x > bearer.p.x - 1.3:
			r.mx = clampf(absf(bearer.v.x) / _top(r) * 0.9, 0.2, 1.0)
		else:
			r.mx = clampf(absf(bearer.v.x) / _top(r) + 0.15, 0.3, 1.0)
	if cdef.rule == "lamp" and r == bearer and r.bold < 0.6:
		for lp in lamps:
			if not lp.lit and lp.x - r.p.x > 0.0 and lp.x - r.p.x < 3.0:
				r.mx = 0.5
	# 앞 구덩이·벽: 빛 안이면 잘 보고, 안개 속이면 거의 못 본다
	var look := 0.8 + absf(r.v.x) * 0.12
	var ax := r.p.x + HW + 0.25 + absf(r.v.x) * 0.035
	var pit := _floor_top(ax, r.p.y + 0.6) < r.p.y - 2.0
	var wall := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, look, 2.0))
	if r.grounded and (pit or wall):
		var seen := _lit(ax + 1.0)
		if randf() > (r.err if seen else 0.7):
			r.i_jump = true


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	vhv = HWV * vs.y / maxf(vs.x, 1.0)
	if bearer and phase != "roundend":
		var tx := lerpf(bearer.p.x + 1.5, light_c, 0.3)
		camx = lerpf(camx, tx, 1.0 - exp(-6.0 * dt))
		camy = lerpf(camy, bearer.p.y + 2.0, 1.0 - exp(-4.0 * dt))
	cam.fov = rad_to_deg(2.0 * atan(HWV / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


## z=0 의 점 (x, y) 가 화면에서 같은 자리에 보이도록 깊이 z 로 옮긴 점
func _front(x: float, y: float, z: float) -> Vector3:
	var k := (CAM_D - z) / CAM_D
	return Vector3(camx + (x - camx) * k, camy + (y - camy) * k, z)


func _draw_all(dt: float) -> void:
	var tm := Time.get_ticks_msec() * 0.001
	var kr := (CAM_D - ZR) / CAM_D
	for r in runners:
		r.poof.visible = r.poof_t > 0.0
		if r.poof_t > 0.0:
			r.poof_t -= dt
			var s := 1.0 + (0.5 - r.poof_t) * 6.0
			r.poof.scale = Vector3(s, s, s)
		if not r.alive:
			for s2 in r.streaks:
				s2.visible = false
			continue
		var spd := absf(r.v.x)
		var bob := sin(tm * (8.0 + spd)) * 0.06 if r.grounded and spd > 1.0 else 0.0
		r.node.position = _front(r.p.x, r.p.y + HH * 0.375 + bob, ZR)
		r.node.rotation.z = -clampf(r.v.x * 0.012, -0.2, 0.2)
		r.node.scale = Vector3(kr * (1.0 + r.sq * 0.5), kr * (1.0 - r.sq), kr)
		# 길을 잃어 가면 깜빡인다
		r.node.visible = r.lost < 0.3 or fmod(tm, 0.2) < 0.13
		var ln := clampf((spd - 8.0) * 0.8, 0.0, 3.0)
		for k in 2:
			var s3 := r.streaks[k]
			s3.visible = ln > 0.1
			if s3.visible:
				s3.scale = Vector3(ln * (1.0 - k * 0.25) * kr, 0.07, 0.07)
				s3.position = _front(r.p.x - r.face * (HW + 0.3 + ln * 0.5), r.p.y + 0.3 + k * 0.4, ZR)
	# 등불: 든 사람 손에서, 빛 쪽으로 기운다
	lantern.visible = bearer != null and bearer.alive
	if lantern.visible:
		lantern.position = _front(bearer.p.x + 0.3 * bearer.face, bearer.p.y + HH * 0.7, ZR + 0.1)
		lantern.scale = Vector3.ONE * kr
		lantern.rotation.z = clampf(-(light_c - bearer.p.x) * 0.16, -1.1, 1.1)
	marker.visible = pl.alive
	marker.position = _front(pl.p.x, pl.p.y + HH + 1.0 + sin(tm * 5.0) * 0.12, ZR)
	for k in pips.size():
		pips[k].visible = pl.alive and k < lives
		pips[k].position = _front(pl.p.x - 0.3 + k * 0.3, pl.p.y + HH + 1.6, ZR)
	# 가로등 머리와 결승 깃발은 안개 앞
	for lp in lamps:
		var h: MeshInstance3D = lp.head
		var lx: float = lp.x
		h.visible = absf(lx - camx) < HWV + 2.0
		if h.visible:
			h.position = _front(lx, lp.y, ZR)
			h.scale = Vector3(0.7, 0.45, 0.5) * kr
	if goal_node:
		var gy: float = goal_node.get_meta("y")
		goal_node.visible = absf(goal_x - camx) < HWV + 3.0
		goal_node.position = _front(goal_x, gy, ZR - 0.3)
		goal_node.scale = Vector3.ONE * ((CAM_D - ZR + 0.3) / CAM_D)
	# 파편
	for b in bits:
		if b.life > 0.0:
			b.life -= dt
			var bv: Vector3 = b.v
			bv.y -= GRAV * 0.7 * dt
			b.v = bv
			var m: MeshInstance3D = b.node
			m.position += bv * dt
			m.rotation.z += dt * 9.0
			m.visible = b.life > 0.0
	# 등불 든 사람이 빠르면 화면을 가로지르는 바람 줄
	var ls := absf(bearer.v.x) if bearer and bearer.alive and phase == "race" else 0.0
	wind_x += dt * ls * 2.2
	var wk := (CAM_D - 4.0) / CAM_D
	for k in winds.size():
		var w := winds[k]
		w.visible = ls > 7.0 or gust_on
		if w.visible:
			var ww := HWV * wk * 2.0 + 6.0
			var off := wind_x + k * 7.3
			if gust_on:
				off = -tm * 30.0 + k * 7.3
			w.position = Vector3(camx + HWV * wk + 3.0 - fposmod(off, ww), camy + vhv * wk * (0.7 - k * 0.45), 4.0)
			w.scale = Vector3(1.5 + ls * 0.3, 0.06, 0.06)
	_vis()
	_draw_fog()


## 밝은 구간 사이를 안개 막으로 덮고, 빛 끝에 노란 선
func _draw_fog() -> void:
	var kf := (CAM_D - ZF) / CAM_D
	var sl := camx - HWV - 2.0
	var sr := camx + HWV + 2.0
	var gaps: Array[Vector2] = []
	var x := sl
	var ei := 0
	for iv in lit:
		if iv.y < sl or iv.x > sr:
			continue
		if iv.x > x:
			gaps.append(Vector2(x, iv.x))
		x = maxf(x, iv.y)
		for ex in [iv.x, iv.y]:
			if ex > sl and ex < sr and ei < edges.size():
				var e := edges[ei]
				ei += 1
				e.visible = true
				e.position = Vector3(camx + (ex - camx) * kf, camy, ZF + 0.05)
				e.scale = Vector3(0.16, vhv * 2.6, 0.1)
	if x < sr:
		gaps.append(Vector2(x, sr))
	for k in range(ei, edges.size()):
		edges[k].visible = false
	for k in fogs.size():
		var m := fogs[k]
		m.visible = k < gaps.size()
		if m.visible:
			var l := camx + (gaps[k].x - camx) * kf
			var r := camx + (gaps[k].y - camx) * kf
			m.position = Vector3((l + r) * 0.5, camy, ZF)
			m.scale = Vector3(maxf(r - l, 0.01), vhv * 2.6, 0.1)


func _burst(at: Vector3, n: int, c: Color) -> void:
	for k in n:
		var b: Dictionary = bits[bit_i]
		bit_i = (bit_i + 1) % bits.size()
		var m: MeshInstance3D = b.node
		m.visible = true
		m.position = at
		m.material_override = mat(c)
		b.v = Vector3(randf_range(-5.0, 5.0), randf_range(3.0, 9.0), randf_range(0.0, 1.5))
		b.life = randf_range(0.4, 0.7)
