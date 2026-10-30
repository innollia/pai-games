extends Tofu
## 화면 밖으로 밀리지 마 (옆모습 4인 배달 경주): 왼쪽 아래 조이스틱 좌우, 점프, 갈고리(앞쪽 고리에 자동으로 걸고 누르는 동안 매달림), 아이템(톡 = 쓰기, 꾹 = 태워서 대시).
## 카메라는 나 말고 1등을 따라간다. 화면 왼쪽 밖·구덩이로 떨어지면 탈락, 마지막까지 남으면 라운드 승. 3승이면 다음 코스(시장 → 공사장 → 지하철 → 옥상), 코스 사이에 특전 하나.

const GRAV := 38.0
const JUMP_V := 15.0
const RUN_MAX := 11.0
const GROUND_ACC := 45.0
const AIR_ACC := 22.0
const OVER_G := 7.0  # 최고 속도보다 빠를 때 땅에서 줄어드는 정도 (갈고리·부스트 속도가 조금 남는다)
const OVER_A := 1.5
const FRICTION := 35.0
const MAX_FALL := 26.0
const PAD_V := 23.0
const BOOST_V := 18.0
const DASH_V := 21.0
const DASH_T := 0.32
const ROCKET_V := 22.0
const ROCKET_T := 0.85
const PUMP := 10.0
const HOOK_RNG := 12.0
const HW := 0.4
const HH := 1.2
const STEP := 0.55
const COYOTE := 0.1
const JBUF := 0.12
const TRAIN_V := 18.0
const CAM_D := 22.0
const BX0 := -60.0
const BK := 6.0
const WIDE := 12.5  # 처음 화면 반폭
const NARROW := 6.0  # 시간이 지나면 이만큼 좁아진다
const BURN_HOLD := 0.28
const PERKS := ["신발", "갈고리", "가방", "바람", "용수철"]
const PERK_SAY := {"신발": "더 빨리", "갈고리": "멀리 걸기", "가방": "로켓 들고 출발", "바람": "바람 두 배", "용수철": "높이 뛰기"}
const BOOSTC := Color("69db7c")
const CRATEC := Color("e599f7")
const PINK := Color("f783ac")
const COURSES := [
	{"name": "시장", "gnd": Color("ffd8a8"), "top": Color("ff922b"), "wall": Color("e8590c"),
		"bld": [Color("ffc9c9"), Color("ffec99"), Color("d3f9d8")],
		"segs": ["flat", "stairs", "wall", "pit", "awning", "crates", "hookflat", "crates"]},
	{"name": "공사장", "gnd": Color("ffe066"), "top": Color("fab005"), "wall": Color("fd7e14"),
		"bld": [Color("dee2e6"), Color("ffe8cc"), Color("fff3bf")],
		"segs": ["flat", "wall", "pit", "girder", "scaffold", "hookgap", "stairs", "girder"]},
	{"name": "지하철", "gnd": Color("a5d8ff"), "top": Color("4dabf7"), "wall": Color("748ffc"),
		"bld": [Color("d0ebff"), Color("e5dbff"), Color("c5f6fa")],
		"segs": ["flat", "stairs", "train", "train", "pit", "wall", "hookflat", "boost"]},
	{"name": "옥상", "gnd": Color("e5dbff"), "top": Color("cc5de8"), "wall": Color("9775fa"),
		"bld": [Color("f3d9fa"), Color("dbe4ff"), Color("ffdeeb")],
		"segs": ["roofgap", "roofgap", "hookgap", "awning", "wall", "boost", "roofgap", "hookflat"]},
]


class Courier:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var grounded := false
	var sup := -1  # 밟은 것: 0 바닥 1 발판 2 부스트
	var dyn := -1
	var alive := true
	var ai := true
	var nick := ""
	var col := Color.WHITE
	var node: Node3D
	var body: MeshInstance3D
	var pack: MeshInstance3D
	var rope: MeshInstance3D
	var fire: MeshInstance3D
	var poof: MeshInstance3D
	var streaks: Array[MeshInstance3D] = []
	var pips: Array[MeshInstance3D] = []
	var item := ""
	var stun := 0.0
	var dash := 0.0
	var rocket := 0.0
	var boost_t := 0.0
	var hooked := false
	var hook := Vector2.ZERO
	var rope_len := 0.0
	var slip := false
	var coyote := 0.0
	var jbuf := 0.0
	var cut := true
	var bonk := false
	var skill := 1.0
	var err := 0.2
	var think := 0.0
	var poof_t := 0.0
	var immune := 0.0
	var face := 1.0
	var item_age := 0.0
	var wins := 0
	var on_boost := false
	# 이번 프레임 입력
	var mx := 0.0
	var i_jump := false
	var i_jheld := false
	var i_hook := false
	var i_hheld := false
	var i_use := false
	var i_burn := false


var ci := 0  # 코스
var rnd := 0  # 이 코스에서 몇 번째 라운드
var phase := "count"
var pt := 0.0
var rt := 0.0  # 라운드 시간
var cdef: Dictionary
var stage: Node3D
var rects: Array[Rect2] = []
var kinds := PackedInt32Array()
var buckets: Array = []
var hooks: Array[Vector2] = []
var hook_nodes: Array[MeshInstance3D] = []
var crates: Array = []
var trains: Array = []
var girders: Array = []
var dyn_rects: Array[Rect2] = []
var bananas: Array = []
var goal_x := 0.0
var kill_y := -20.0
var gx := 0.0
var fy := 0.0
var min_fy := 0.0
var gen := RandomNumberGenerator.new()
var game_seed := 0
var runners: Array[Courier] = []
var pl: Courier
var camx := 0.0
var camy := 0.0
var hwv := WIDE
var vhv := WIDE
var shk := 0.0
var edge_strip: MeshInstance3D
var train_warn: MeshInstance3D
var marker: MeshInstance3D
var target_hook := -1
var item_arm := false
var item_t := 0.0
var danger := false
var tick := 0.0
var was_slip := false
var spd_mul := 1.0
var hook_bonus := 0.0
var jump_mul := 1.0
var slip_mul := 1.0
var bag := false
var perk_offer: Array = []
var btn_names := {}


func _setup() -> void:
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	howto = "막내 배달부 경주! 카메라는 1등만 따라간다. 화면 왼쪽 밖으로 밀리거나 구덩이에 빠지면 탈락.\n조이스틱 좌우, 점프, 갈고리(앞 고리에 자동, 누르는 동안 매달렸다 놓으면 휙).\n아이템: 톡 = 쓰기(바나나·로켓), 꾹 = 태워서 대시. 남의 뒤에 붙으면 바람 타고 빨라진다.\n마지막까지 남으면 1승, 3승이면 다음 코스. 경쟁자가 먼저 3승하면 끝."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1120), 100.0, A)
	kit_button("hook", "갈고리", Vector2(600, 890), 82.0, INK)
	kit_button("item", "-", Vector2(420, 1000), 72.0, C)
	btn_names = {"jump": "점프", "hook": "갈고리"}


func _reset() -> void:
	ci = 0
	rnd = 0
	stage = null
	spd_mul = 1.0
	hook_bonus = 0.0
	jump_mul = 1.0
	slip_mul = 1.0
	bag = false
	taken.clear()
	game_seed = randi()
	_restore_labels()
	runners.clear()
	var cols := [ME, A, B, PINK]
	var nicks := ["나", "주황", "하늘", "분홍"]
	for i in 4:
		var r := Courier.new()
		r.ai = i > 0
		r.col = cols[i]
		r.nick = nicks[i]
		_make_body(r)
		runners.append(r)
	pl = runners[0]
	bananas.clear()
	for i in 6:
		var n := box(Vector3(0, -50, 0), Vector3(0.7, 0.25, 0.7), D)
		n.visible = false
		bananas.append({"node": n, "on": false, "p": Vector2.ZERO, "owner": null, "nm": false})
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	train_warn = box(Vector3.ZERO, Vector3(0.6, 1.8, 0.2), BAD)
	marker = box(Vector3.ZERO, Vector3(0.36, 0.36, 0.36), ME)
	marker.rotation.z = PI * 0.25
	_build_course()
	_start_round()


func _make_body(r: Courier) -> void:
	r.node = Node3D.new()
	world.add_child(r.node)
	r.body = box(Vector3(0, 0, 0), Vector3(HW * 2.0, HH * 0.75, 0.8), r.col, r.node)
	box(Vector3(0, 0.63, 0), Vector3(0.42, 0.36, 0.5), SOFT, r.node)
	box(Vector3(0.05, 0.88, 0), Vector3(0.6, 0.14, 0.6), WHITE if not r.ai else r.col.darkened(0.2), r.node)
	r.pack = box(Vector3(-0.45, 0.05, 0), Vector3(0.55, 0.55, 0.6), Color("e0a96d"), r.node)
	r.fire = box(Vector3(-0.9, 0, 0), Vector3(0.9, 0.35, 0.35), A, r.node)
	r.fire.visible = false
	r.rope = box(Vector3.ZERO, Vector3(1, 0.07, 0.07), INK)
	r.rope.visible = false
	r.poof = box(Vector3.ZERO, Vector3(1, 1, 1), WHITE)
	r.poof.visible = false
	for k in 3:
		var s := box(Vector3.ZERO, Vector3(1, 0.07, 0.07), WHITE)
		s.visible = false
		r.streaks.append(s)
	for k in 3:
		var q := box(Vector3.ZERO, Vector3(0.24, 0.24, 0.24), r.col)
		q.visible = false
		r.pips.append(q)


# ---- 코스 만들기 ----
func _build_course() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	cdef = COURSES[ci]
	rects.clear()
	kinds = PackedInt32Array()
	hooks.clear()
	hook_nodes.clear()
	crates.clear()
	trains.clear()
	girders.clear()
	dyn_rects.clear()
	gen.seed = game_seed + ci * 7919
	fy = 0.0
	min_fy = 0.0
	gx = -40.0
	_floor(gx, 44.0)
	gx = 4.0
	var goal := 380.0 + ci * 50.0
	var segs: Array = cdef.segs
	var last := ""
	while gx < goal:
		var s: String = segs[gen.randi() % segs.size()]
		if s == last and s != "flat":
			s = "flat"
		last = s
		_seg(s)
	goal_x = gx + 2.0
	_floor(gx, 60.0)
	for z in [-1.4, 1.4]:
		box(Vector3(goal_x, fy + 2.6, z), Vector3(0.3, 5.2, 0.3), GOOD, stage)
	for k in 6:
		box(Vector3(goal_x, fy + 5.2, -1.25 + k * 0.5), Vector3(0.32, 0.4, 0.5), WHITE if k % 2 == 0 else INK, stage)
	kill_y = min_fy - 6.0
	# 칸 나누기 (가까운 상자만 검사)
	buckets.clear()
	var nb := int((gx + 100.0 - BX0) / BK) + 1
	for b in nb:
		buckets.append([])
	for i in rects.size():
		var rc := rects[i]
		for b in range(_bi(rc.position.x), _bi(rc.end.x) + 1):
			buckets[b].append(i)
	# 뒤 건물 (원근 때문에 느리게 지나간다)
	var bx := -40.0
	var bld: Array = cdef.bld
	while bx < gx + 60.0:
		var w := gen.randf_range(4.0, 8.0)
		var h := gen.randf_range(8.0, 26.0)
		var c: Color = bld[gen.randi() % bld.size()]
		box(Vector3(bx + w * 0.5, h * 0.5 - 14.0, -12.0 - gen.randf() * 3.0), Vector3(w, h, 3.0), c, stage)
		bx += w + gen.randf_range(0.5, 2.5)
	# 앞 가로등 (빨리 지나가서 속도가 보인다)
	var px := 0.0
	while px < goal_x:
		var y := _floor_top(px, 60.0)
		if y > -100.0:
			box(Vector3(px, y + 2.0, 3.2), Vector3(0.22, 4.0, 0.22), WHITE, stage)
			box(Vector3(px + 0.35, y + 4.0, 3.2), Vector3(0.9, 0.22, 0.3), cdef.top, stage)
		px += 9.0


func _seg(s: String) -> void:
	var wallc: Color = cdef.wall
	match s:
		"flat":
			var w := gen.randf_range(6.0, 12.0)
			_floor(gx, w)
			if gen.randf() < 0.45:
				_crate(gx + w * 0.5, fy + 1.4)
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
			_solid(Rect2(gx + 4.0, fy, 0.9, gen.randf_range(1.3, 2.3)), wallc, 0)
			gx += 9.0
		"pit":
			_floor(gx, 2.0)
			gx += 2.0 + gen.randf_range(3.0, 5.5)
			fy = clampf(fy + gen.randf_range(-1.0, 1.0), -3.0, 6.0)
			_floor(gx, 5.0)
			gx += 5.0
		"hookgap":
			_floor(gx, 3.0)
			gx += 3.0
			var g := gen.randf_range(9.0, 12.0)
			_hook(gx + g * 0.5, fy + 7.5)
			if gen.randf() < 0.4:
				_plat(gx + g * 0.5 - 0.8, fy - 0.4, 1.6, wallc)
			gx += g
			_floor(gx, 5.0)
			gx += 5.0
		"hookflat":
			_floor(gx, 14.0)
			_hook(gx + 4.0, fy + 6.5)
			_hook(gx + 10.0, fy + 6.5)
			gx += 14.0
		"boost":
			_floor(gx, 10.0)
			_solid(Rect2(gx + 3.0, fy, 4.0, 0.2), BOOSTC, 2, 2.5)
			gx += 10.0
		"awning":  # 노란 발판 → 위쪽 지름길(부스트), 아래는 상자벽
			_floor(gx, 4.0)
			_solid(Rect2(gx + 2.2, fy, 1.6, 0.4), D, 1, 2.5)
			_plat(gx + 5.0, fy + 6.5, 17.0, wallc)
			_solid(Rect2(gx + 6.0, fy + 6.5, 4.0, 0.2), BOOSTC, 2, 2.0)
			_floor(gx + 4.0, 18.0)
			_solid(Rect2(gx + 9.0, fy, 1.2, 1.1), wallc, 0)
			_solid(Rect2(gx + 15.0, fy, 1.2, 1.6), wallc, 0)
			_hook(gx + 24.0, fy + 9.0)
			gx += 22.0
		"crates":
			_floor(gx, 12.0)
			_solid(Rect2(gx + 3.0, fy, 1.2, 1.0), wallc, 0)
			_solid(Rect2(gx + 8.0, fy, 1.2, 1.7), wallc, 0)
			if gen.randf() < 0.5:
				_crate(gx + 6.0, fy + 1.4)
			gx += 12.0
		"girder":  # 오르내리는 크레인 철골
			_floor(gx, 3.0)
			gx += 3.0
			var top := fy - 0.6
			dyn_rects.append(Rect2(gx + 5.5 - 1.6, top - 0.5, 3.2, 0.5))
			girders.append({"cx": gx + 5.5, "base": top, "amp": 1.8, "ph": gen.randf() * TAU,
				"node": box(Vector3(gx + 5.5, top - 0.25, 0), Vector3(3.2, 0.5, 1.6), wallc, stage)})
			box(Vector3(gx + 5.5, fy + 10.0, -0.5), Vector3(0.1, 20.0, 0.1), INK, stage)
			_hook(gx + 5.5, fy + 8.0)
			gx += 11.0
			_floor(gx, 5.0)
			gx += 5.0
		"scaffold":  # 비계 계단 위쪽 지름길
			_floor(gx, 16.0)
			_solid(Rect2(gx + 3.0, fy, 1.5, 1.2), wallc, 0)
			_plat(gx + 6.0, fy + 2.6, 3.0, wallc)
			_plat(gx + 10.0, fy + 4.4, 6.0, wallc)
			_solid(Rect2(gx + 10.5, fy + 4.4, 3.0, 0.2), BOOSTC, 2, 2.0)
			_solid(Rect2(gx + 12.5, fy, 0.9, 2.0), wallc, 0)
			_hook(gx + 19.0, fy + 8.0)
			gx += 16.0
		"train":  # 아래 선로에는 열차, 위 승강장은 틈이 있다
			var x0 := gx
			var ty := fy - 3.2
			min_fy = minf(min_fy, ty)
			_solid(Rect2(x0, ty - 14.0, 34.0, 14.0), cdef.gnd, 0)
			box(Vector3(x0 + 17.0, ty - 0.1, 0), Vector3(34.0, 0.2, 2.5), INK, stage)
			for ab in [[0.0, 9.0], [12.0, 20.0], [23.5, 27.5]]:
				_plat(x0 + ab[0], fy, ab[1] - ab[0], wallc)
			_solid(Rect2(x0 + 30.0, ty, 2.0, 1.2), wallc, 0)
			_solid(Rect2(x0 + 32.0, ty, 2.0, 2.4), wallc, 0)
			var tn := box(Vector3(0, -50, 0), Vector3(4.5, 1.9, 2.0), B, stage)
			box(Vector3(-1.6, 0.15, 0.55), Vector3(0.12, 0.25, 0.1), WHITE, tn)
			tn.visible = false
			var lamp := box(Vector3(x0 + 29.0, ty + 2.2, 1.2), Vector3(0.5, 0.5, 0.3), BAD, stage)
			trains.append({"x0": x0, "x1": x0 + 30.0, "y": ty, "x": 0.0, "run": false, "wait": 1.0, "node": tn, "lamp": lamp, "nm": false})
			gx = x0 + 34.0
			_floor(gx, 6.0)
			gx += 6.0
		"roofgap":
			_floor(gx, gen.randf_range(6.0, 10.0))
			gx = rects[rects.size() - 1].end.x
			var g := gen.randf_range(4.5, 7.5)
			var ny := clampf(fy + gen.randf_range(-2.0, 1.5), -3.0, 6.0)
			if ny > fy + 0.5:
				g = minf(g, 5.0)
			if g > 6.0:
				_hook(gx + g * 0.5, maxf(fy, ny) + 7.0)
			gx += g
			fy = ny
			_floor(gx, 4.0)
			gx += 4.0
	min_fy = minf(min_fy, fy)


func _floor(x: float, w: float) -> void:
	_solid(Rect2(x, fy - 14.0, w, 14.0), cdef.gnd, 0)
	box(Vector3(x + w * 0.5, fy - 0.1, 0), Vector3(w, 0.2, 2.5), cdef.top, stage)


func _plat(x: float, top: float, w: float, c: Color) -> void:
	_solid(Rect2(x, top - 0.5, w, 0.5), c, 0, 2.0)


func _solid(rc: Rect2, c: Color, kind: int, depth := 2.4) -> void:
	rects.append(rc)
	kinds.append(kind)
	var m := rc.get_center()
	box(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, depth), c, stage)


func _hook(x: float, y: float) -> void:
	hooks.append(Vector2(x, y))
	hook_nodes.append(box(Vector3(x, y, 0), Vector3(0.55, 0.55, 0.55), INK, stage))
	box(Vector3(x, y + 4.0, -0.3), Vector3(0.08, 8.0, 0.08), INK, stage)


func _crate(x: float, y: float) -> void:
	crates.append({"p": Vector2(x, y), "cd": 0.0, "node": box(Vector3(x, y, 0), Vector3(0.8, 0.8, 0.8), CRATEC, stage)})


func _bi(x: float) -> int:
	return clampi(int(floor((x - BX0) / BK)), 0, buckets.size() - 1)


# ---- 라운드 ----
func _start_round() -> void:
	rnd += 1
	var xs := [-2.2, -1.0, -3.4, -4.6]
	for i in 4:
		var r := runners[i]
		r.p = Vector2(xs[i], 0.0)
		r.v = Vector2.ZERO
		r.alive = true
		r.item = "로켓" if (not r.ai and bag) else ""
		r.stun = 0.0
		r.dash = 0.0
		r.rocket = 0.0
		r.boost_t = 0.0
		r.hooked = false
		r.cut = true
		r.face = 1.0
		r.poof_t = 0.0
		r.node.visible = true
		r.node.rotation = Vector3.ZERO
		r.rope.visible = false
		r.poof.visible = false
		r.item_age = 0.0
		if r.ai:
			r.skill = 0.93 + 0.025 * ci + (i - 2) * 0.02
			r.err = 0.22 - 0.04 * ci
		_probe(r)
	for c in crates:
		c.cd = 0.0
		(c.node as Node3D).visible = true
	for b in bananas:
		b.on = false
		(b.node as Node3D).visible = false
	for tr in trains:
		tr.run = false
		tr.wait = 1.0
		(tr.node as Node3D).visible = false
	rt = 0.0
	hwv = WIDE
	camx = 0.0
	camy = 2.0
	phase = "count"
	pt = 1.4
	danger = false
	item_arm = false
	msg("%s %d판" % [cdef.name, rnd], 1.2)
	beep(440.0, 0.12)


func _step(dt: float) -> void:
	shk = maxf(shk - dt * 2.5, 0.0)
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.7 and pt <= 0.7:
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
			_tick_runners(dt, false)
			if pt <= 0.0:
				_after_round()
		"perk":
			msg("특전 고르기", 0.2)
			for n in ["jump", "hook", "item"]:
				if kit_just(n):
					_pick_perk(n)
					break
	_update_items(dt)
	_camera(dt)
	_draw_all(dt)
	_set_item_label()


func _race(dt: float) -> void:
	# 내 입력
	pl.mx = kit_move.x
	pl.i_jump = kit_just("jump")
	pl.i_jheld = kit_held("jump")
	pl.i_hook = kit_just("hook")
	pl.i_hheld = kit_held("hook")
	pl.i_use = false
	pl.i_burn = false
	if kit_just("item"):
		item_arm = true
		item_t = 0.0
	if item_arm:
		if kit_held("item"):
			item_t += dt
			if item_t >= BURN_HOLD:
				pl.i_burn = true
				item_arm = false
		else:
			pl.i_use = true
			item_arm = false
	for r in runners:
		if r.alive and r.ai:
			_ai(r, dt)
	_slipstream()
	_move_girders(dt)
	_tick_runners(dt, true)
	_trains(dt)
	_bananas_hit()
	_pickups()
	# 탈락
	var left := camx - hwv
	for r in runners:
		if not r.alive:
			continue
		if r.p.x + HW < left or r.p.y < kill_y or r.p.y < camy - vhv - 1.0:
			_out(r)
	if phase != "race":
		return
	for r in runners:
		if r.alive and r.p.x > goal_x:
			_round_over(r)
			return
	if not pl.alive:
		var w: Courier = null
		for r in runners:
			if r.alive and (w == null or r.p.x > w.p.x):
				w = r
		_round_over(w)
		return
	var n := 0
	for r in runners:
		if r.alive:
			n += 1
	if n <= 1:
		_round_over(pl)
		return
	# 화면 끝 압박
	var ed := pl.p.x - left
	gauge(ed / (hwv * 2.0), GOOD if ed > hwv * 0.6 else (A if ed > 2.5 else BAD))
	if ed < 1.6:
		danger = true
	elif danger and ed > 4.0:
		danger = false
		_close(pl)
	tick -= dt
	if ed < 3.5 and tick <= 0.0:
		tick = 0.08 + ed * 0.07
		beep(1200.0 - ed * 150.0, 0.04, 0.0, 0.14)
	if pl.slip and not was_slip:
		beep(700.0, 0.12, 1000.0, 0.12)
		msg("바람 타기", 0.4)
	was_slip = pl.slip


func _tick_runners(dt: float, live: bool) -> void:
	for r in runners:
		if r.alive:
			if live:
				_runner(r, dt)
		elif r.poof_t > 0.0:
			r.poof_t -= dt


func _out(r: Courier) -> void:
	r.alive = false
	r.hooked = false
	r.node.visible = false
	r.rope.visible = false
	r.poof.visible = true
	r.poof_t = 0.5
	r.poof.position = Vector3(clampf(r.p.x, camx - hwv + 0.6, camx + hwv), maxf(r.p.y, camy - vhv + 2.0), 0.5)
	if r == pl:
		play("bad")
		shk = 0.6
		msg("밀려났다!", 1.0)
	else:
		beep(300.0, 0.2, 120.0, 0.25)
		shk = maxf(shk, 0.25)
		msg("%s 탈락" % r.nick, 0.6)


func _round_over(w: Courier) -> void:
	phase = "roundend"
	pt = 1.8
	pl.hooked = false
	if w == null:
		msg("무승부", 1.6)
		return
	w.wins += 1
	if w == pl:
		score += 10
		play("win")
		msg("라운드 승!", 1.6)
	else:
		beep(330.0, 0.3, 200.0, 0.25)
		msg("%s 승" % w.nick, 1.6)


func _after_round() -> void:
	if pl.wins >= 3:
		score += 50
		if ci >= COURSES.size() - 1:
			msg("배달 완료!", 3.0)
			end()
			return
		play("win")
		var pool := []
		for k in PERKS:
			if not perk_taken(k):
				pool.append(k)
		pool.shuffle()
		perk_offer = pool.slice(0, 3)
		var names := ["jump", "hook", "item"]
		for i in 3:
			_btns[names[i]].label = perk_offer[i]
		phase = "perk"
		return
	for r in runners:
		if r.ai and r.wins >= 3:
			msg("%s 우승" % r.nick, 3.0)
			end()
			return
	_start_round()


var taken: Array = []


func perk_taken(k: String) -> bool:
	return taken.has(k)


func _pick_perk(n: String) -> void:
	var i := ["jump", "hook", "item"].find(n)
	var k: String = perk_offer[i]
	taken.append(k)
	match k:
		"신발": spd_mul += 0.08
		"갈고리": hook_bonus += 4.0
		"가방": bag = true
		"바람": slip_mul = 2.0
		"용수철": jump_mul += 0.12
	play("good")
	msg("%s: %s" % [k, PERK_SAY[k]], 1.4)
	_restore_labels()
	_kit_clear()
	ci += 1
	rnd = 0
	for r in runners:
		r.wins = 0
	_build_course()
	_start_round()


func _restore_labels() -> void:
	if _btns.has("jump"):
		_btns["jump"].label = "점프"
		_btns["hook"].label = "갈고리"


func _set_item_label() -> void:
	if phase == "perk" or not _btns.has("item"):
		return
	_btns["item"].label = pl.item if pl.item != "" else "-"


# ---- 달리기 한 명 ----
func _runner(r: Courier, dt: float) -> void:
	r.immune = maxf(r.immune - dt, 0.0)
	r.bonk = false
	var top := RUN_MAX * (r.skill if r.ai else spd_mul)
	if r.slip:
		top *= 1.0 + 0.12 * (1.0 if r.ai else slip_mul)
	if r.boost_t > 0.0:
		r.boost_t -= dt
		top = maxf(top, BOOST_V)
	var mx := r.mx
	if r.stun > 0.0:
		r.stun -= dt
		mx = 0.0
		r.i_jump = false
		r.i_hook = false
		r.i_use = false
		r.i_burn = false
	if r.item != "":
		r.item_age += dt
		if r.i_burn:
			_burn(r)
		elif r.i_use:
			_use(r)
	if r.i_hook and not r.hooked:
		_try_hook(r)
	if r.hooked and (not r.i_hheld or r.stun > 0.0):
		_unhook(r)
	r.coyote = COYOTE if r.grounded else maxf(r.coyote - dt, 0.0)
	r.jbuf = JBUF if r.i_jump else maxf(r.jbuf - dt, 0.0)
	if r.jbuf > 0.0:
		if r.hooked:
			_unhook(r)
			r.v.y = maxf(r.v.y, 0.0) + 6.0
			r.jbuf = 0.0
			r.cut = true
			_snd(r, 900.0, 0.08, 1300.0)
		elif r.coyote > 0.0:
			r.v.y = JUMP_V * (1.0 if r.ai else jump_mul)
			r.coyote = 0.0
			r.jbuf = 0.0
			r.grounded = false
			r.cut = false
			_snd(r, 600.0, 0.07, 900.0)
	if not r.cut and r.v.y > 0.0 and not r.i_jheld:
		r.v.y *= 0.5
		r.cut = true
	if r.rocket > 0.0:
		r.rocket -= dt
		r.v = Vector2(ROCKET_V, 0.0)
	elif r.dash > 0.0:
		r.dash -= dt
		r.v.x = maxf(r.v.x, DASH_V)
		r.v.y = 0.0
	else:
		var acc := (GROUND_ACC if r.grounded else AIR_ACC) * (1.3 if r.slip else 1.0)
		if absf(mx) > 0.15:
			var want := signf(mx) * top
			if signf(r.v.x) != signf(mx) or absf(r.v.x) < top:
				r.v.x = move_toward(r.v.x, want, acc * dt)
			else:
				r.v.x = move_toward(r.v.x, want, (OVER_G if r.grounded else OVER_A) * dt)
			r.face = signf(mx)
		else:
			r.v.x = move_toward(r.v.x, 0.0, (FRICTION if r.grounded else 4.0) * dt)
		if r.hooked:
			var n := (r.p + Vector2(0, HH * 0.5) - r.hook).normalized()
			var tg := Vector2(-n.y, n.x)
			if tg.x < 0.0:
				tg = -tg
			r.v += tg * PUMP * dt
		r.v.y = maxf(r.v.y - GRAV * dt, -MAX_FALL)
	for s in 2:
		_mx(r, r.v.x * dt * 0.5)
		_my(r, r.v.y * dt * 0.5)
	if r.hooked:
		var c := r.p + Vector2(0, HH * 0.5)
		var d := c - r.hook
		var L := d.length()
		if L > r.rope_len and L > 0.01:
			var nn := d / L
			r.p = r.hook + nn * r.rope_len - Vector2(0, HH * 0.5)
			var vr := r.v.dot(nn)
			if vr > 0.0:
				r.v -= nn * vr
		if c.y > r.hook.y - 0.3 and r.v.y > 0.0:
			_unhook(r)
	if r.rocket > 0.0 and r.bonk:
		r.rocket = 0.0
	_probe(r)
	if r.grounded:
		if r.sup == 1:
			r.v.y = PAD_V
			r.grounded = false
			r.cut = true
			_snd(r, 300.0, 0.25, 1100.0, 0.25)
			if r == pl:
				shk = maxf(shk, 0.2)
		elif r.sup == 2:
			r.v.x = maxf(r.v.x, BOOST_V)
			r.boost_t = 0.6
			if not r.on_boost:
				_snd(r, 500.0, 0.15, 1400.0)
	r.on_boost = r.grounded and r.sup == 2


func _box(r: Courier) -> Rect2:
	return Rect2(r.p.x - HW, r.p.y, HW * 2.0, HH)


func _mx(r: Courier, dx: float) -> void:
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
			_bump_x(r, q, dx)
			a = _box(r)
	for q in dyn_rects:
		if q.intersects(a):
			_bump_x(r, q, dx)
			a = _box(r)


func _bump_x(r: Courier, q: Rect2, dx: float) -> void:
	if dx > 0.0:
		r.p.x = q.position.x - HW - 0.001
	else:
		r.p.x = q.end.x + HW + 0.001
	if absf(r.v.x) > 13.0:
		_snd(r, 160.0, 0.1, 80.0, 0.25)
		if r == pl:
			shk = maxf(shk, 0.3)
	r.v.x = 0.0
	r.bonk = true


func _my(r: Courier, dy: float) -> void:
	if dy == 0.0:
		return
	r.p.y += dy
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if q.intersects(a):
				_bump_y(r, q, dy)
				a = _box(r)
	for q in dyn_rects:
		if q.intersects(a):
			_bump_y(r, q, dy)
			a = _box(r)


func _bump_y(r: Courier, q: Rect2, dy: float) -> void:
	if dy < 0.0:
		r.p.y = q.end.y
		r.v.y = 0.0
	else:
		r.p.y = q.position.y - HH - 0.001
		r.v.y = minf(r.v.y, 0.0)


func _probe(r: Courier) -> void:
	var f := Rect2(r.p.x - HW + 0.05, r.p.y - 0.06, HW * 2.0 - 0.1, 0.07)
	r.grounded = false
	r.sup = -1
	r.dyn = -1
	var pad := false
	var bst := false
	for b in range(_bi(f.position.x), _bi(f.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if q.intersects(f) and q.end.y <= r.p.y + 0.02:
				r.grounded = true
				pad = pad or kinds[i] == 1
				bst = bst or kinds[i] == 2
	for j in dyn_rects.size():
		var q := dyn_rects[j]
		if q.intersects(f) and q.end.y <= r.p.y + 0.05:
			r.grounded = true
			r.dyn = j
	if r.grounded:
		r.sup = 1 if pad else (2 if bst else 0)


## x 위에서 높이 ymax 아래 가장 높은 바닥 윗면 (없으면 아주 낮은 수)
func _floor_top(x: float, ymax: float) -> float:
	var best_y := -1.0e9
	for i in buckets[_bi(x)]:
		var q: Rect2 = rects[i]
		if x > q.position.x and x < q.end.x and q.end.y <= ymax:
			best_y = maxf(best_y, q.end.y)
	for q in dyn_rects:
		if x > q.position.x and x < q.end.x and q.end.y <= ymax:
			best_y = maxf(best_y, q.end.y)
	return best_y


func _solid_in(a: Rect2) -> bool:
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if q.intersects(a):
				return true
	return false


# ---- 갈고리·아이템 ----
func _hook_target(r: Courier) -> int:
	var c := r.p + Vector2(0, HH * 0.5)
	var rng := HOOK_RNG + (0.0 if r.ai else hook_bonus)
	var pick := -1
	var bs := 1.0e9
	for i in hooks.size():
		var h := hooks[i]
		var dx := h.x - c.x
		if dx < -1.0 or h.y < c.y + 1.5:
			continue
		var d := c.distance_to(h)
		if d > rng:
			continue
		var s := d - dx * 0.3
		if s < bs:
			bs = s
			pick = i
	return pick


func _try_hook(r: Courier) -> void:
	var i := _hook_target(r)
	if i < 0:
		if r == pl:
			beep(200.0, 0.06, 0.0, 0.12)
		return
	r.hooked = true
	r.hook = hooks[i]
	r.rope_len = maxf((r.p + Vector2(0, HH * 0.5)).distance_to(r.hook) * 0.92, 2.5)
	r.v.x = maxf(r.v.x, 4.0)
	r.rocket = 0.0
	r.dash = 0.0
	_snd(r, 1300.0, 0.06, 700.0)


func _unhook(r: Courier) -> void:
	if not r.hooked:
		return
	r.hooked = false
	r.rope.visible = false
	r.cut = true
	_snd(r, 800.0, 0.05, 1200.0, 0.12)


func _use(r: Courier) -> void:
	var it := r.item
	r.item = ""
	if it == "바나나":
		var x := r.p.x - r.face * 1.2
		var y := _floor_top(x, r.p.y + 0.5)
		if y > r.p.y - 6.0:
			for b in bananas:
				if not b.on:
					b.on = true
					b.p = Vector2(x, y)
					b.owner = r
					b.nm = false
					(b.node as Node3D).visible = true
					(b.node as Node3D).position = Vector3(x, y + 0.125, 0)
					break
		r.immune = 0.6
		_snd(r, 500.0, 0.1, 250.0)
	else:
		_unhook(r)
		r.rocket = ROCKET_T
		r.v = Vector2(ROCKET_V, 0.0)
		_snd(r, 200.0, 0.5, 900.0, 0.25)
		if r == pl:
			shk = maxf(shk, 0.25)
			msg("로켓!", 0.5)


## 아이템을 태워서 앞으로 대시 (네온 화이트처럼 쓰기 대신 이동)
func _burn(r: Courier) -> void:
	r.item = ""
	_unhook(r)
	r.dash = DASH_T
	r.v.x = maxf(r.v.x, DASH_V)
	r.v.y = 0.0
	_snd(r, 400.0, 0.18, 1500.0, 0.22)
	if r == pl:
		shk = maxf(shk, 0.2)
		msg("태워!", 0.4)


func _snd(r: Courier, f: float, d: float, to := 0.0, vol := 0.18) -> void:
	if r == pl:
		beep(f, d, to, vol)
	elif r.alive and absf(r.p.x - camx) < hwv:
		beep(f, d, to, vol * 0.45)


func _close(r: Courier) -> void:
	r.v.x += 3.0
	beep(1000.0, 0.1, 1600.0, 0.22)
	msg("아슬!", 0.5)
	shk = maxf(shk, 0.15)


func _slipstream() -> void:
	for r in runners:
		r.slip = false
		if not r.alive:
			continue
		for o in runners:
			if o == r or not o.alive:
				continue
			var dx := o.p.x - r.p.x
			if dx > 0.8 and dx < 4.5 and absf(o.p.y - r.p.y) < 1.5:
				r.slip = true
				break


func _pickups() -> void:
	for c in crates:
		if c.cd > 0.0:
			continue
		var cp: Vector2 = c.p
		for r in runners:
			if r.alive and r.item == "" and absf(r.p.x - cp.x) < 0.9 and cp.y - r.p.y > -0.6 and cp.y - r.p.y < HH + 0.5:
				r.item = "바나나" if randf() < 0.5 else "로켓"
				r.item_age = 0.0
				c.cd = 3.0
				(c.node as Node3D).visible = false
				_snd(r, 880.0, 0.1, 1320.0)
				break


func _update_items(dt: float) -> void:
	for c in crates:
		var n: Node3D = c.node
		if c.cd > 0.0:
			c.cd -= dt
			if c.cd <= 0.0:
				n.visible = true
		n.rotation.y += dt * 2.0


func _bananas_hit() -> void:
	for b in bananas:
		if not b.on:
			continue
		var bp: Vector2 = b.p
		for r in runners:
			if not r.alive or (r == b.owner and r.immune > 0.0):
				continue
			var dx := absf(r.p.x - bp.x)
			var dy := r.p.y - bp.y
			if dx < 0.7 and dy > -0.3 and dy < 0.4:
				r.stun = 0.75
				r.v = Vector2(r.v.x * 0.25, 4.0)
				_unhook(r)
				b.on = false
				(b.node as Node3D).visible = false
				_snd(r, 300.0, 0.25, 150.0, 0.25)
				if r == pl:
					msg("미끌!", 0.6)
					shk = maxf(shk, 0.3)
				break
			if r == pl and not b.nm and dx < 0.6 and dy >= 0.4 and dy < 1.8:
				b.nm = true
				_close(r)


func _move_girders(_dt: float) -> void:
	for j in girders.size():
		var g: Dictionary = girders[j]
		var top: float = g.base + sin(rt * 1.5 + g.ph) * g.amp
		var q := dyn_rects[j]
		var dy := top - q.end.y
		q.position.y = top - 0.5
		dyn_rects[j] = q
		(g.node as Node3D).position.y = top - 0.25
		for r in runners:
			if r.alive and r.dyn == j:
				r.p.y += dy


func _trains(dt: float) -> void:
	var lead := _leader()
	var right := camx + hwv
	train_warn.visible = false
	for tr in trains:
		var tn: Node3D = tr.node
		var lamp: Node3D = tr.lamp
		var ty: float = tr.y
		if not tr.run:
			lamp.visible = true
			if lead and lead.p.x > tr.x0 - 14.0:
				tr.wait -= dt
				lamp.visible = tr.wait > 0.9 or fmod(rt, 0.2) < 0.1
				if tr.wait <= 0.9 and tr.x1 > right and tr.x0 < right + 30.0:
					train_warn.visible = fmod(rt, 0.2) < 0.12
					train_warn.position = Vector3(camx + hwv * (CAM_D - 1.6) / CAM_D - 0.4, ty + 1.0, 1.6)
				if tr.wait <= 0.0:
					tr.run = true
					tr.x = tr.x1 + 2.25
					tr.nm = false
					tn.visible = true
					if absf(tr.x1 - pl.p.x) < 25.0:
						beep(700.0, 0.3, 500.0, 0.2)
			continue
		tr.x -= TRAIN_V * dt
		var tx: float = tr.x
		tn.position = Vector3(tx, ty + 0.95, 0)
		if tx - 2.25 > right:
			train_warn.visible = fmod(rt, 0.2) < 0.12
			train_warn.position = Vector3(camx + hwv * (CAM_D - 1.6) / CAM_D - 0.4, ty + 1.0, 1.6)
		if tx < tr.x0 - 2.5:
			tr.run = false
			tr.wait = randf_range(1.4, 2.8)
			tn.visible = false
			continue
		var trc := Rect2(tx - 2.25, ty, 4.5, 1.9)
		for r in runners:
			if not r.alive:
				continue
			if trc.intersects(_box(r)) and r.stun <= 0.0:
				r.stun = 0.6
				r.v = Vector2(-7.0, 8.0)
				_unhook(r)
				_snd(r, 140.0, 0.3, 60.0, 0.3)
				if r == pl:
					shk = 0.6
					msg("쾅!", 0.6)
			elif r == pl and not tr.nm and absf(r.p.x - tx) < 2.4 and r.p.y > ty + 1.9 and r.p.y < ty + 3.4 and not r.grounded:
				tr.nm = true
				_close(r)


func _leader() -> Courier:
	var w: Courier = null
	for r in runners:
		if r.alive and (w == null or r.p.x > w.p.x):
			w = r
	return w


# ---- 경쟁자 ----
func _ai(r: Courier, dt: float) -> void:
	r.mx = 1.0
	r.i_jump = false
	r.i_hook = false
	r.i_use = false
	r.i_burn = false
	r.i_jheld = true
	if r.hooked:
		var c := r.p + Vector2(0, HH * 0.5)
		var land := _floor_top(c.x + 2.0, r.p.y + 0.5) > r.p.y - 3.0
		r.i_hheld = not ((c.x > r.hook.x + 2.0 and r.v.y > 0.0) or c.y > r.hook.y - 1.0 or (land and c.x > r.hook.x + 0.5))
	else:
		r.i_hheld = true
	r.think -= dt
	if r.think > 0.0:
		return
	r.think = randf_range(0.04, 0.1) / r.skill
	var look := 0.8 + absf(r.v.x) * 0.12
	var ax := r.p.x + HW + 0.25 + absf(r.v.x) * 0.035
	var pit := _floor_top(ax, r.p.y + 0.6) < r.p.y - 2.0
	var wall := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, look, 2.0))
	var danger_ahead := false
	for b in bananas:
		if b.on and b.owner != r:
			var bp: Vector2 = b.p
			if bp.x - r.p.x > 0.4 and bp.x - r.p.x < 2.5 and absf(bp.y - r.p.y) < 0.5:
				danger_ahead = true
	for tr in trains:
		if tr.run:
			var dx: float = tr.x - r.p.x
			var ty: float = tr.y
			if dx > 2.5 and dx < 8.0 and absf(r.p.y - ty) < 0.6:
				danger_ahead = true
	if r.grounded and (pit or wall or danger_ahead) and randf() > r.err:
		r.i_jump = true
	if not r.grounded and not r.hooked and r.v.y < 3.0:
		var below := _floor_top(r.p.x + 1.5, r.p.y)
		if (pit or below < r.p.y - 4.0) and _hook_target(r) >= 0 and randf() > r.err:
			r.i_hook = true
		elif randf() < 0.05 and _hook_target(r) >= 0:
			r.i_hook = true
	if r.item != "":
		var lead := _leader()
		if r.item == "바나나":
			for o in runners:
				if o != r and o.alive and r.p.x - o.p.x > 1.0 and r.p.x - o.p.x < 7.0:
					r.i_use = true
		elif r.item == "로켓" and lead != r and not pit and randf() < 0.25:
			r.i_use = true
		if not r.i_use and r.item_age > 3.0 and randf() < 0.15:
			r.i_burn = true


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	var asp := vs.y / maxf(vs.x, 1.0)
	if phase == "race":
		hwv = lerpf(WIDE, NARROW, clampf((rt - 10.0) / 28.0, 0.0, 1.0))
	vhv = hwv * asp
	var lead := _leader()
	if lead and phase != "perk":
		var k := 1.0 - exp(-9.0 * dt)
		camx = lerpf(camx, lead.p.x - hwv * 0.16, k)
		camy = lerpf(camy, lead.p.y + 2.0, 1.0 - exp(-4.0 * dt))
	cam.fov = rad_to_deg(2.0 * atan(hwv / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


func _draw_all(_dt: float) -> void:
	var tm := Time.get_ticks_msec() * 0.001
	for r in runners:
		r.poof.visible = r.poof_t > 0.0
		if r.poof.visible:
			var s := 1.0 + (0.5 - r.poof_t) * 6.0
			r.poof.scale = Vector3(s, s, s)
		if not r.alive:
			for s2 in r.streaks:
				s2.visible = false
			for q in r.pips:
				q.visible = false
			continue
		var spd := absf(r.v.x)
		var bob := sin(tm * (8.0 + spd)) * 0.06 if r.grounded and spd > 1.0 else 0.0
		r.node.position = Vector3(r.p.x, r.p.y + HH * 0.375 + bob, 0)
		r.node.rotation.z = (tm * 14.0 if r.stun > 0.0 else -clampf(r.v.x * 0.012, -0.2, 0.2))
		r.pack.position.x = -0.45 * r.face
		r.fire.visible = r.rocket > 0.0 or r.dash > 0.0
		r.fire.scale.x = 0.9 + sin(tm * 50.0) * 0.3
		r.fire.material_override = mat(A if r.rocket > 0.0 else C)
		r.rope.visible = r.hooked
		if r.hooked:
			var a := r.p + Vector2(0, HH * 0.6)
			var d := r.hook - a
			r.rope.position = Vector3(a.x + d.x * 0.5, a.y + d.y * 0.5, 0)
			r.rope.rotation.z = atan2(d.y, d.x)
			r.rope.scale = Vector3(d.length(), 0.07, 0.07)
		var ln := clampf((spd - 11.5) * 0.6, 0.0, 4.0)
		for k in 3:
			var s3 := r.streaks[k]
			s3.visible = ln > 0.1
			if s3.visible:
				s3.material_override = mat(B if r.slip else WHITE)
				s3.scale = Vector3(ln * (1.0 - k * 0.2), 0.07, 0.07)
				s3.position = Vector3(r.p.x - r.face * (HW + 0.3 + ln * 0.5 + k * 0.2), r.p.y + 0.25 + k * 0.35, 0.5)
		for k in 3:
			var q := r.pips[k]
			q.visible = k < r.wins
			q.position = Vector3(r.p.x - 0.3 + k * 0.3, r.p.y + HH + 0.55, 0)
	marker.visible = pl.alive
	marker.position = Vector3(pl.p.x, pl.p.y + HH + 1.1 + sin(tm * 5.0) * 0.12, 0)
	# 내가 걸 수 있는 고리
	var ti := _hook_target(pl) if pl.alive and not pl.hooked else -1
	if ti != target_hook:
		if target_hook >= 0 and target_hook < hook_nodes.size():
			hook_nodes[target_hook].material_override = mat(INK)
			hook_nodes[target_hook].scale = Vector3(0.55, 0.55, 0.55)
		if ti >= 0:
			hook_nodes[ti].material_override = mat(GOOD)
			hook_nodes[ti].scale = Vector3(0.9, 0.9, 0.9)
		target_hook = ti
	# 왼쪽 화면 끝 경고 띠
	var ed := pl.p.x - (camx - hwv)
	var k2 := (CAM_D - 1.6) / CAM_D
	edge_strip.visible = phase == "race" and pl.alive and ed < 4.0 and (ed > 2.0 or fmod(tm, 0.16) < 0.1)
	edge_strip.position = Vector3(camx - hwv * k2 + 0.18, camy, 1.6)
	edge_strip.scale = Vector3(0.35 + maxf(0.0, 4.0 - ed) * 0.1, vhv * 2.0, 0.2)
