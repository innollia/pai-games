extends Tofu
## 고무공 경주 (옆모습 4인 화면 밖 경주): 왼쪽 아래 조이스틱 좌우로 구르고, 꾹을 누르는 동안 말랑(브레이크·충격 흡수), 떼면 누른 만큼 통 튄다. 카메라는 1등만 따라가고 화면 왼쪽 밖이나 구덩이면 탈락.
## 한 문장: 나는 태엽 인형들 사이에 낀 고무공으로서 1등만 따라가는 화면 안에서 꾹 눌렀다 떼며 튀어 결승에 먼저 닿지만, 부딪힐 때마다 속도가 남거나 늘어나는 대신 어디로 튈지 내가 못 정하는 대가를 감수한다.
## 딱딱한 공(평소): 천장에 맞으면 옆으로 빨라지고(×1.12+1.5), 벽에 맞으면 그 속도 그대로 뒤로 튄다. 모서리는 비스듬히. 꾹 중엔 말랑해서 그냥 멈춘다.
## 트랙: 체육관(낮은 천장 지그재그·벽 반동) → 오락실(범퍼·경사판이 방향을 정함) → 모래 놀이터 맛보기(모래=튕김이 죽음, 트램펄린).
## 부모 screenrace_over 의 "나만 과한 몸, 천장=가속·벽=손해"를 물려받고 몸을 고무공(반동)으로, 동사를 꾹 하나로 바꿨다. 지면 그 트랙부터 다시.

# ---- 공 ----
const GRAV := 34.0
const BR := 0.55  # 공 반지름
const ROLL := 11.0  # 바닥에서 굴러서 낼 수 있는 속도 (상대 10.8)
const ROLL_ACC := 24.0
const ROLL_DRAG := 2.5  # 고무공은 오래 구른다
const BRAKE := 16.0  # 꾹 중 바닥 감속
const AIR_ACC := 9.0
const CAP := 32.0
const CEIL_MUL := 1.12
const CEIL_ADD := 1.5
const E_FLOOR := 0.8
const E_WALL := 0.85  # 벽 반동: 그 속도의 85%로 뒤로
const E_SOFT := 0.12
const HOP_MIN := 8.0
const HOP_MAX := 24.0
const CHARGE_T := 0.6
const BUMP_MUL := 1.25
const BUMP_MIN := 15.0
const SAND_TOP := 4.5
# ---- 태엽 인형 (상대) ----
const GRAV_R := 40.0
const JUMP_N := 13.0
const RUN_N := 10.8
const GROUND_ACC := 60.0
const AIR_ACC_R := 25.0
const MAX_FALL := 28.0
const HW := 0.4
const HH := 1.2
const STEP := 0.55
# ---- 화면 ----
const CAM_D := 22.0
const WIDE := 12.0
const NARROW := 7.5
const PINK := Color("f783ac")
const SANDC := Color("ffe066")
const TRAMPC := Color("51cf66")
const BUMPC := Color("ff6b6b")
const TRACKS := [
	{"name": "체육관", "sky": Color("fff9db"), "gnd": Color("ffd8a8"), "top": Color("f08c00"), "ceil": Color("74c0fc"),
		"bld": [Color("d0ebff"), Color("ffec99"), Color("ffe3e3")], "lo": 3.6, "hi": 9.0, "ai": 0.0,
		"segs": ["open", "low", "hall", "wall", "open", "pit", "hall", "low", "wall", "open", "openwall", "hall", "pitlow",
			"hall", "low", "wall", "open", "pit", "hall", "openwall", "low", "pitlow", "hall", "wall", "open"]},
	{"name": "오락실", "sky": Color("f3f0ff"), "gnd": Color("e5dbff"), "top": Color("9775fa"), "ceil": Color("f783ac"),
		"bld": [Color("ffdeeb"), Color("d3f9d8"), Color("fff3bf")], "lo": 3.8, "hi": 8.0, "ai": 0.02,
		"segs": ["open", "bumphall", "hall", "ramp", "bumpfloor", "hall", "steep", "open", "bumppit", "wall", "ramp", "low",
			"bumpfloor", "bumphall", "pitlow", "steep", "hall", "openwall", "ramp", "bumppit", "hall", "bumpfloor", "open"]},
	{"name": "모래 놀이터", "sky": Color("e7f5ff"), "gnd": Color("d8f5a2"), "top": Color("82c91e"), "ceil": Color("82c91e"),
		"bld": [Color("c3fae8"), Color("fff3bf"), Color("ffe8cc")], "lo": 0.0, "hi": 0.0, "ai": 0.03,
		"segs": ["open", "sand", "open", "tramp", "open", "sandlong", "tramp", "pit", "open", "sand", "tramp", "open"]},
]
const HINTS := {
	"low": "낮은 천장: 튀면 쾅쾅 빨라진다", "wall": "빨간 줄 = 벽! 꾹 눌러 멈춰", "bumper": "범퍼: 맞은 자리 반대로 튕긴다",
	"bumpfloor": "바닥 범퍼: 굴러 박으면 뒤로 난다", "ramp": "경사판: 빠를수록 높이 멀리", "sand": "모래: 튕김이 죽는다",
	"tramp": "트램펄린: 높이 통!",
}


class Runner:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var grounded := false
	var alive := true
	var nick := ""
	var col := Color.WHITE
	var node: Node3D
	var key: MeshInstance3D
	var poof: MeshInstance3D
	var skill := 1.0
	var err := 0.2
	var think := 0.0
	var poof_t := 0.0
	var squash := 0.0
	var i_jump := false


var ti := 0
var resume_ti := 0
var phase := "count"
var pt := 0.0
var rt := 0.0
var tdef: Dictionary
var stage: Node3D
var rects: Array[Rect2] = []
var kinds: Array[String] = []  # rects 와 같은 순서: "n" 바닥·벽 / "sand" / "tramp"
var bumpers: Array = []  # {c, r, node, pulse}
var ramps: Array = []  # {a, b}
var obst: Array = []  # 상대가 뛰어넘을 x (범퍼·경사판)
var hints: Array = []
var hint_done := {}
var frun := {}
var crun := {}
var goal_x := 0.0
var kill_y := -20.0
var gx := 0.0
var fy := 0.0
var min_fy := 0.0
var gen := RandomNumberGenerator.new()
var vrng := RandomNumberGenerator.new()
var runners: Array[Runner] = []
# 공 (나)
var bp := Vector2.ZERO
var bv := Vector2.ZERO
var b_alive := true
var gnd_t := 0.0  # 바닥에 닿은 뒤 남은 시간 (이 동안 통 가능)
var on_sand := false
var squeeze := false
var chg := 0.0
var rel_buf := 0.0
var rel_chg := 0.0
var spin := 0.0
var sq := 0.0  # 부딪힘 납작
var sq_ang := 0.0
var hopped := false
var ball: Node3D
var ball_sq: Node3D
var ball_spin: Node3D
var ball_parts: Array[MeshInstance3D] = []
var ball_poof: MeshInstance3D
var ball_poof_t := 0.0
var snd_cd := 0.0
# 카메라·비주얼
var camx := 0.0
var camy := 0.0
var hwv := WIDE
var vhv := WIDE
var shk := 0.0
var edge_strip: MeshInstance3D
var marker: MeshInstance3D
var danger := false
var tick := 0.0
var lead_t := 0.0
var sky_env: Environment
var bgs: Array = []
var lamps: Array = []
var lines: Array = []
var chips: Array = []
var chip_i := 0


func _setup() -> void:
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	howto = "장난감 경주에 나만 고무공. 카메라는 1등만 따라간다. 화면 왼쪽 밖으로 밀리거나 구덩이에 빠지면 탈락.\n조이스틱 좌우로 구르기. 꾹을 누르면 말랑(브레이크), 떼면 누른 만큼 통 튄다.\n천장에 맞으면 빨라지고, 벽에 맞으면 그 속도로 뒤로 튄다. 빨간 줄 = 벽: 꾹 눌러 멈추거나 길게 꾹 해서 넘어.\n체육관 → 오락실(범퍼·경사판) → 모래 놀이터."
	kit_stick()
	kit_button("sq", "꾹", Vector2(590, 1080), 120.0, A)
	for c in get_children():
		if c is WorldEnvironment:
			sky_env = (c as WorldEnvironment).environment


func _reset() -> void:
	ti = resume_ti
	stage = null
	runners.clear()
	var cols := [A, B, PINK]
	var nicks := ["주황", "하늘", "분홍"]
	for i in 3:
		var r := Runner.new()
		r.col = cols[i]
		r.nick = nicks[i]
		_make_body(r)
		runners.append(r)
	_make_ball()
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	marker = box(Vector3.ZERO, Vector3(0.36, 0.36, 0.36), ME)
	marker.rotation.z = PI * 0.25
	_make_pools()
	_build_track()
	_start_race()


func _make_ball() -> void:
	ball = Node3D.new()
	world.add_child(ball)
	ball_sq = Node3D.new()
	ball.add_child(ball_sq)
	ball_spin = Node3D.new()
	ball_sq.add_child(ball_spin)
	ball_parts.clear()
	# 상자 둘을 엇갈려 팔각형 공처럼, 흰 띠로 굴러가는 게 보이게
	ball_parts.append(box(Vector3.ZERO, Vector3(BR * 2.0, BR * 1.4, 1.0), ME, ball_spin))
	ball_parts.append(box(Vector3.ZERO, Vector3(BR * 1.4, BR * 2.0, 1.0), ME, ball_spin))
	box(Vector3.ZERO, Vector3(0.22, BR * 2.02, 1.03), WHITE, ball_spin)
	box(Vector3(0, 0, 0.53), Vector3(0.5, 0.22, 0.02), WHITE, ball_spin)
	ball_poof = box(Vector3.ZERO, Vector3.ONE, WHITE)
	ball_poof.visible = false


func _make_body(r: Runner) -> void:
	r.node = Node3D.new()
	world.add_child(r.node)
	box(Vector3(0, 0, 0), Vector3(HW * 2.0, HH * 0.75, 0.8), r.col, r.node)
	box(Vector3(0, 0.63, 0), Vector3(0.42, 0.36, 0.5), SOFT, r.node)
	box(Vector3(0.05, 0.88, 0), Vector3(0.6, 0.14, 0.6), r.col.darkened(0.2), r.node)
	r.key = box(Vector3(-0.55, 0.1, 0), Vector3(0.12, 0.5, 0.12), D, r.node)  # 등의 태엽
	r.poof = box(Vector3.ZERO, Vector3(1, 1, 1), WHITE)
	r.poof.visible = false


func _make_pools() -> void:
	bgs.clear()
	lamps.clear()
	lines.clear()
	chips.clear()
	for k in 10:
		bgs.append({"n": box(Vector3.ZERO, Vector3.ONE, WHITE), "x": 0.0})
	for k in 4:
		lamps.append({"post": box(Vector3.ZERO, Vector3(0.22, 3.0, 0.22), WHITE),
			"arm": box(Vector3.ZERO, Vector3(0.9, 0.22, 0.3), WHITE), "x": 0.0})
	for k in 6:
		var n := box(Vector3.ZERO, Vector3(1, 0.05, 0.05), WHITE)
		n.visible = false
		lines.append({"n": n, "x": 0.0, "y": 0.0})
	for k in 16:
		var n := box(Vector3.ZERO, Vector3(0.25, 0.25, 0.25), WHITE)
		n.visible = false
		chips.append({"n": n, "v": Vector3.ZERO, "life": 0.0})


# ---- 트랙 만들기 (손으로 짠 순서) ----
func _build_track() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	tdef = TRACKS[ti]
	if sky_env:
		sky_env.background_color = tdef.sky
	rects.clear()
	kinds.clear()
	bumpers.clear()
	ramps.clear()
	obst.clear()
	hints.clear()
	frun = {}
	crun = {}
	gen.seed = 2203 + ti * 7919
	vrng.seed = randi()
	fy = 0.0
	min_fy = 0.0
	gx = -40.0
	_floor(gx, 44.0, tdef.hi)
	gx = 4.0
	for s in tdef.segs:
		_seg(s)
	goal_x = gx + 2.0
	_floor(gx, 60.0, tdef.hi)
	_flush()
	for z in [-1.4, 1.4]:
		box(Vector3(goal_x, fy + 2.6, z), Vector3(0.3, 5.2, 0.3), GOOD, stage)
	for k in 4:
		box(Vector3(goal_x, fy + 5.2, -1.2 + k * 0.8), Vector3(0.32, 0.45, 0.8), WHITE if k % 2 == 0 else INK, stage)
	kill_y = min_fy - 6.0
	for k in bgs.size():
		var b: Dictionary = bgs[k]
		b.x = -26.0 + k * (52.0 / bgs.size())
		_bg_shape(b)
	for k in lamps.size():
		var l: Dictionary = lamps[k]
		l.x = -6.0 + k * 9.0
		(l.arm as MeshInstance3D).material_override = mat(tdef.top)
		_lamp_place(l)
	for c in chips:
		c.life = 0.0
		(c.n as Node3D).visible = false


func _bg_shape(b: Dictionary) -> void:
	var w := vrng.randf_range(2.0, 5.0)
	var h := vrng.randf_range(8.0, 20.0)
	var bld: Array = tdef.bld
	var n: MeshInstance3D = b.n
	n.material_override = mat(bld[vrng.randi() % bld.size()])
	n.scale = Vector3(w, h, 3.0)
	n.position = Vector3(b.x, h * 0.5 - 10.0, -11.0 - vrng.randf() * 2.0)


func _lamp_place(l: Dictionary) -> void:
	var y := _floor_top(l.x, 60.0)
	var ok := y > -100.0
	(l.post as Node3D).visible = ok
	(l.arm as Node3D).visible = ok
	if ok:
		(l.post as Node3D).position = Vector3(l.x, y + 1.5, 3.2)
		(l.arm as Node3D).position = Vector3(l.x + 0.35, y + 3.0, 3.2)


func _seg(s: String) -> void:
	var wallc: Color = tdef.ceil
	var lo: float = tdef.lo
	var hi: float = tdef.hi
	match s:
		"hall":
			var w := gen.randf_range(8.0, 12.0)
			_floor(gx, w, lo)
			gx += w
		"open":
			var w := gen.randf_range(8.0, 12.0)
			_floor(gx, w, hi)
			gx += w
		"low":  # 아주 낮은 천장: 조금만 튀어도 쾅쾅 (지그재그 가속 복도)
			_floor(gx, 2.0, lo)
			_hint(gx, "low")
			_floor(gx + 2.0, 10.0, 2.8 if lo > 0.0 else 0.0)
			for k in 3:
				box(Vector3(gx + 4.0 + k * 3.0, fy + 2.8 - 0.12, 0), Vector3(0.6, 0.24, 2.62), D, stage)
			gx += 12.0
		"pit", "pitlow":
			var ch := hi if s == "pit" else lo
			var g := gen.randf_range(3.0, 4.5)
			_floor(gx, 3.0, ch)
			_stripes(gx, D)
			gx += 3.0
			_ceil(gx, g, ch)
			gx += g
			_floor(gx, 4.0, ch)
			gx += 4.0
		"wall":
			_floor(gx, 9.0, lo)
			_stripes(gx + 1.5, BAD)
			_hint(gx, "wall")
			_solid(Rect2(gx + 4.5, fy, 0.9, gen.randf_range(1.2, 1.6)), wallc)
			gx += 9.0
		"openwall":
			_floor(gx, 13.0, hi)
			_stripes(gx + 1.0, BAD)
			_stripes(gx + 6.0, BAD)
			_hint(gx, "wall")
			_solid(Rect2(gx + 4.0, fy, 0.9, 1.8), wallc)
			_solid(Rect2(gx + 9.0, fy, 0.9, 1.5), wallc)
			gx += 13.0
		"step":
			var up := fy < -1.0 or (fy < 3.0 and gen.randf() < 0.5)
			for k in 4:
				_floor(gx, 1.3, lo)
				gx += 1.3
				fy += 0.5 if up else -0.5
			_floor(gx, 3.0, lo)
			gx += 3.0
		"bumphall":  # 공중 범퍼 둘: 굴러가면 밑으로 지나가고, 튀어서 맞히면 맞은 자리 반대로 세게
			_floor(gx, 12.0, hi)
			_hint(gx, "bumper")
			_bumper(Vector2(gx + 4.0, fy + 2.5), 0.6)
			_bumper(Vector2(gx + 8.5, fy + 4.0), 0.6)
			gx += 12.0
		"bumpfloor":  # 바닥 범퍼: 굴러 박으면 뒤로 날아간다
			_floor(gx, 9.0, lo)
			_stripes(gx + 1.0, BUMPC)
			_hint(gx, "bumpfloor")
			_bumper(Vector2(gx + 5.0, fy + 0.7), 0.7)
			obst.append(gx + 5.0)
			gx += 9.0
		"bumppit":
			_floor(gx, 3.0, hi)
			_stripes(gx, D)
			gx += 3.0
			_ceil(gx, 5.2, hi)
			_bumper(Vector2(gx + 2.6, fy + 1.4), 0.55)
			gx += 5.2
			_floor(gx, 4.0, hi)
			gx += 4.0
		"ramp":  # 구덩이 앞 경사판: 빠를수록 높이 멀리 날린다
			_floor(gx, 5.2, hi)
			_hint(gx, "ramp")
			_ramp(Vector2(gx + 2.45, fy), Vector2(gx + 5.2, fy + 1.0))
			obst.append(gx + 2.45)
			gx += 5.2
			_ceil(gx, 4.2, hi)
			gx += 4.2
			_floor(gx, 5.0, hi)
			gx += 5.0
		"steep":  # 낮은 복도 속 가파른 경사판: 천장으로 쏴 올려 쾅 연쇄
			_floor(gx, 10.0, lo)
			_hint(gx, "ramp")
			_ramp(Vector2(gx + 3.5, fy), Vector2(gx + 5.2, fy + 1.0))
			obst.append(gx + 3.5)
			gx += 10.0
		"sand", "sandlong":
			_floor(gx, 2.0, hi)
			var w := 6.0 if s == "sand" else 10.0
			_hint(gx, "sand")
			_floor(gx + 2.0, w, hi, "sand")
			_floor(gx + 2.0 + w, 2.0, hi)
			gx += 4.0 + w
		"tramp":
			_floor(gx, 3.0, hi)
			_hint(gx, "tramp")
			var tr := Rect2(gx + 0.6, fy, 2.0, 0.15)
			_solid(tr, TRAMPC)
			kinds[kinds.size() - 1] = "tramp"
			box(Vector3(gx + 1.6, fy - 0.35, 0), Vector3(1.6, 0.5, 2.2), INK.lightened(0.5), stage)
			obst.append(gx + 0.6)
			_floor(gx + 3.0, 7.0, hi, "sand")
			_floor(gx + 10.0, 3.0, hi)
			gx += 13.0
	min_fy = minf(min_fy, fy)


## 바닥: 같은 높이·같은 종류로 이어지는 바닥·천장은 상자 하나로 합친다
func _floor(x: float, w: float, ch: float, kind := "n") -> void:
	if not frun.is_empty() and absf(frun.y - fy) < 0.001 and absf(frun.x1 - x) < 0.01 and frun.k == kind:
		frun.x1 = x + w
	else:
		_flush_floor()
		frun = {"x0": x, "x1": x + w, "y": fy, "k": kind}
	_ceil(x, w, ch)


func _ceil(x: float, w: float, ch: float) -> void:
	if ch <= 0.0:
		_flush_ceil()
		return
	var y := fy + ch
	if not crun.is_empty() and absf(crun.y - y) < 0.001 and absf(crun.x1 - x) < 0.01:
		crun.x1 = x + w
	else:
		_flush_ceil()
		crun = {"x0": x, "x1": x + w, "y": y}


func _flush() -> void:
	_flush_floor()
	_flush_ceil()


func _flush_floor() -> void:
	if frun.is_empty():
		return
	var w: float = frun.x1 - frun.x0
	var sand: bool = frun.k == "sand"
	_solid(Rect2(frun.x0, frun.y - 14.0, w, 14.0), SANDC.lightened(0.3) if sand else tdef.gnd)
	kinds[kinds.size() - 1] = frun.k
	box(Vector3(frun.x0 + w * 0.5, frun.y - 0.1, 0), Vector3(w, 0.2, 2.5), SANDC if sand else tdef.top, stage)
	frun = {}


func _flush_ceil() -> void:
	if crun.is_empty():
		return
	_solid(Rect2(crun.x0, crun.y, crun.x1 - crun.x0, 3.0), tdef.ceil)
	crun = {}


func _solid(rc: Rect2, c: Color) -> MeshInstance3D:
	rects.append(rc)
	kinds.append("n")
	var m := rc.get_center()
	return box(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, 2.4), c, stage)


func _stripes(x0: float, c: Color) -> void:
	for k in 3:
		box(Vector3(x0 + 0.25 + k * 1.0, fy - 0.1, 0), Vector3(0.5, 0.24, 2.62), c, stage)


func _hint(x: float, key: String) -> void:
	if not hint_done.has(key):
		hints.append({"x": x, "key": key})


func _bumper(c: Vector2, r: float) -> void:
	var n := box(Vector3(c.x, c.y, 0), Vector3(r * 1.5, r * 1.5, 1.2), BUMPC, stage)
	n.rotation.z = PI * 0.25
	box(Vector3.ZERO, Vector3(0.55, 0.55, 1.05), WHITE, n)
	bumpers.append({"c": c, "r": r, "node": n, "pulse": 0.0})


func _ramp(a: Vector2, b: Vector2) -> void:
	var m := (a + b) * 0.5
	var d := b - a
	var n := box(Vector3(m.x, m.y, 0), Vector3(d.length(), 0.18, 2.4), D, stage)
	n.rotation.z = atan2(d.y, d.x)
	# 받침 (높은 쪽 끝 기둥)
	box(Vector3(b.x - 0.1, fy + (b.y - fy) * 0.5, 0), Vector3(0.2, b.y - fy, 2.2), INK.lightened(0.5), stage)
	ramps.append({"a": a, "b": b})


# ---- 경주 ----
func _start_race() -> void:
	var xs := [-1.0, -3.4, -4.6]
	for i in 3:
		var r := runners[i]
		r.p = Vector2(xs[i], 0.0)
		r.v = Vector2.ZERO
		r.alive = true
		r.poof_t = 0.0
		r.squash = 0.0
		r.node.visible = true
		r.poof.visible = false
		r.skill = 0.95 + 0.03 * ti + (i - 1) * 0.02 + float(tdef.ai)
		r.err = maxf(0.2 - 0.05 * ti, 0.05)
		_probe(r)
	bp = Vector2(-2.2, BR)
	bv = Vector2.ZERO
	b_alive = true
	ball.visible = true
	ball_poof_t = 0.0
	gnd_t = 0.1
	squeeze = false
	chg = 0.0
	rel_buf = 0.0
	sq = 0.0
	hopped = false
	for bu in bumpers:
		bu.pulse = 0.0
	rt = 0.0
	lead_t = 0.0
	hwv = WIDE
	camx = 0.0
	camy = 2.0
	phase = "count"
	pt = 1.4
	danger = false
	msg("%d/%d %s" % [ti + 1, TRACKS.size(), tdef.name], 1.2)
	beep(440.0, 0.12)


func _step(dt: float) -> void:
	shk = maxf(shk - dt * 2.5, 0.0)
	snd_cd = maxf(snd_cd - dt, 0.0)
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.7 and pt <= 0.7:
				beep(440.0, 0.12)
			if pt <= 0.0:
				phase = "race"
				msg("굴러!", 0.6)
				play("good")
		"race":
			rt += dt
			_race(dt)
		"done":
			pt -= dt
			if pt <= 0.0:
				_next_track()
	_camera(dt)
	_draw_all(dt)


func _race(dt: float) -> void:
	_ball(dt)
	for r in runners:
		if r.alive:
			_ai(r, dt)
			_runner(r, dt)
	if ti == 0 and not hopped and rt > 2.2 and rt < 2.3:
		msg("꾹 눌렀다 떼면 통!", 1.4)
	for h in hints:
		if not hint_done.has(h.key) and bp.x > float(h.x) - 9.0:
			hint_done[h.key] = true
			msg(HINTS[h.key], 1.4)
			beep(660.0, 0.08, 990.0, 0.18)
	var left := camx - hwv
	for r in runners:
		if r.alive and r.p.y < kill_y:
			_out(r)
	if bp.y < kill_y or bp.x + BR < left or bp.y < camy - vhv - 1.5:
		_ball_out()
		msg("밀려났다" if bp.y > kill_y else "빠졌다", 1.6)
		resume_ti = ti
		end()
		return
	if bp.x > goal_x:
		_race_over(true, "")
		return
	for r in runners:
		if r.alive and r.p.x > goal_x:
			_race_over(false, r.nick)
			return
	var n := 0
	for r in runners:
		if r.alive:
			n += 1
	if n == 0:
		_race_over(true, "")
		return
	if _me_lead():
		if lead_t == 0.0:
			msg("선두!", 0.6)
			beep(900.0, 0.1, 1400.0, 0.2)
		lead_t += dt
	else:
		lead_t = 0.0
	var ed := bp.x - left
	gauge(ed / (hwv * 2.0), GOOD if ed > hwv * 0.6 else (A if ed > 2.5 else BAD))
	if ed < 1.6:
		danger = true
	elif danger and ed > 4.0:
		danger = false
		beep(1000.0, 0.1, 1600.0, 0.22)
		msg("아슬!", 0.5)
	tick -= dt
	if ed < 3.5 and tick <= 0.0:
		tick = 0.08 + ed * 0.07
		beep(1200.0 - ed * 150.0, 0.04, 0.0, 0.14)


func _out(r: Runner) -> void:
	r.alive = false
	r.node.visible = false
	r.poof.visible = true
	r.poof_t = 0.5
	r.poof.position = Vector3(clampf(r.p.x, camx - hwv + 0.6, camx + hwv), maxf(r.p.y, camy - vhv + 2.0), 0.5)
	score += 5
	beep(300.0, 0.2, 120.0, 0.25)
	shk = maxf(shk, 0.25)
	msg("%s 탈락" % r.nick, 0.6)


func _ball_out() -> void:
	b_alive = false
	ball.visible = false
	ball_poof.visible = true
	ball_poof_t = 0.5
	ball_poof.position = Vector3(clampf(bp.x, camx - hwv + 0.6, camx + hwv), maxf(bp.y, camy - vhv + 2.0), 0.5)
	play("bad")
	shk = 0.6


func _race_over(me: bool, who: String) -> void:
	phase = "done"
	pt = 1.6
	if me:
		score += 50
		play("win")
		msg("1등!", 1.6)
	else:
		beep(330.0, 0.3, 200.0, 0.25)
		msg("%s 먼저 도착" % who, 1.6)


func _next_track() -> void:
	if bp.x <= goal_x and not _all_out():
		resume_ti = ti
		end()
		return
	ti += 1
	if ti >= TRACKS.size():
		resume_ti = 0
		msg("완주! 다음 구역은 준비 중", 3.0)
		end()
		return
	play("good")
	_build_track()
	_start_race()


func _all_out() -> bool:
	for r in runners:
		if r.alive:
			return false
	return true


func _me_lead() -> bool:
	for r in runners:
		if r.alive and r.p.x > bp.x:
			return false
	return true


# ---- 고무공 ----
func _ball(dt: float) -> void:
	var mx := kit_move.x
	var was := squeeze
	squeeze = kit_held("sq")
	if squeeze:
		chg = minf(chg + dt, CHARGE_T)
		if not was:
			beep(240.0, 0.06, 180.0, 0.14)
	elif was:
		rel_buf = 0.12
		rel_chg = chg
		chg = 0.0
	gnd_t = maxf(gnd_t - dt, 0.0)
	rel_buf = maxf(rel_buf - dt, 0.0)
	# 통: 떼는 순간(조금 늦어도) 바닥에 닿아 있으면 누른 만큼 튄다
	if rel_buf > 0.0 and gnd_t > 0.0:
		var k := rel_chg / CHARGE_T
		bv.y = lerpf(HOP_MIN, HOP_MAX, k) * (0.6 if on_sand else 1.0)
		bp.y += 0.03
		rel_buf = 0.0
		gnd_t = 0.0
		hopped = true
		sq = 0.5
		sq_ang = PI * 0.5
		beep(300.0 + k * 200.0, 0.1, 900.0 + k * 900.0, 0.26)
	var rolling := gnd_t > 0.0 and absf(bv.y) < 0.5
	if rolling:
		if squeeze:
			bv.x = move_toward(bv.x, 0.0, BRAKE * dt)
		elif on_sand:
			bv.x = move_toward(bv.x, signf(mx) * SAND_TOP if absf(mx) > 0.15 else 0.0, 20.0 * dt)
		elif absf(mx) > 0.15:
			var want := signf(mx) * ROLL
			if signf(bv.x) != signf(mx) or absf(bv.x) < ROLL:
				bv.x = move_toward(bv.x, want, ROLL_ACC * dt)
			else:
				bv.x = move_toward(bv.x, want, ROLL_DRAG * dt)
		else:
			bv.x = move_toward(bv.x, 0.0, ROLL_DRAG * dt)
	elif absf(mx) > 0.15 and (signf(bv.x) != signf(mx) or absf(bv.x) < ROLL):
		bv.x += signf(mx) * AIR_ACC * dt
	# 4번 나눠 움직이고 부딪힌다 (빠르면 한 프레임에 반지름 넘게 간다)
	for s in 4:
		var h := dt * 0.25
		bv.y -= GRAV * h
		bp += bv * h
		_ball_hits()
	if bv.length() > CAP:
		bv = bv.normalized() * CAP
	spin -= bv.x * dt / BR
	sq = maxf(sq - dt * 3.0, 0.0)
	for bu in bumpers:
		bu.pulse = maxf(float(bu.pulse) - dt * 4.0, 0.0)


func _ball_hits() -> void:
	for i in rects.size():
		var q := rects[i]
		if q.end.x < bp.x - BR - 0.1 or q.position.x > bp.x + BR + 0.1:
			continue
		var c := Vector2(clampf(bp.x, q.position.x, q.end.x), clampf(bp.y, q.position.y, q.end.y))
		var d := bp - c
		var l := d.length()
		if l >= BR:
			continue
		var n: Vector2
		if l < 0.0001:
			# 가운데가 상자 안: 가장 얕은 쪽으로 밀어낸다
			var dl := bp.x - q.position.x
			var dr := q.end.x - bp.x
			var dd := bp.y - q.position.y
			var du := q.end.y - bp.y
			var m := minf(minf(dl, dr), minf(dd, du))
			n = Vector2.LEFT if m == dl else (Vector2.RIGHT if m == dr else (Vector2.DOWN if m == dd else Vector2.UP))
			bp = c + n * BR
		else:
			n = d / l
			bp += n * (BR - l)
		_respond(n, kinds[i])
	for bu in bumpers:
		var cc: Vector2 = bu.c
		var rr: float = bu.r
		var d := bp - cc
		var l := d.length()
		if l >= BR + rr or l < 0.0001:
			continue
		var n := d / l
		bp = cc + n * (BR + rr)
		if bv.dot(n) < 0.0 or bv.length() < 2.0:
			var sp := bv.length()
			bv = n * (maxf(sp * BUMP_MUL, BUMP_MIN) if not squeeze else maxf(sp * 0.3, 3.0))
			bu.pulse = 1.0
			if not squeeze:
				sq = 0.7
				sq_ang = n.angle()
				shk = maxf(shk, 0.25)
				_ping(900.0, 0.08, 1500.0, 0.3)
				_chips(cc + n * rr, 4, BUMPC, 8.0)
				if snd_cd <= 0.05:
					msg("뿅!", 0.3)
			else:
				_ping(200.0, 0.08, 150.0, 0.18)
	for rp in ramps:
		var a: Vector2 = rp.a
		var b: Vector2 = rp.b
		var ab := b - a
		var k := clampf((bp - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
		var c := a + ab * k
		var d := bp - c
		var l := d.length()
		if l >= BR + 0.09 or l < 0.0001:
			continue
		var n := d / l
		bp = c + n * (BR + 0.09)
		var vn := bv.dot(n)
		if vn < 0.0:
			var e := E_SOFT if squeeze else 0.9
			bv -= (1.0 + e) * vn * n
			if n.y > 0.5:
				gnd_t = 0.1
			if -vn > 4.0 and not squeeze:
				sq = 0.5
				sq_ang = n.angle()
				_ping(500.0, 0.06, 1100.0, 0.22)


## 부딪힌 면의 방향으로 반응: 바닥은 튕김, 천장은 옆으로 가속, 벽은 그 속도로 뒤로. 꾹 중엔 말랑
func _respond(n: Vector2, kind: String) -> void:
	var vn := bv.dot(n)
	if n.y > 0.3 and kind == "tramp":
		bv.y = maxf(absf(bv.y) * 1.35, 15.0) * (0.7 if squeeze else 1.0)
		gnd_t = 0.0
		sq = 0.8
		sq_ang = PI * 0.5
		_ping(400.0, 0.12, 1300.0, 0.3)
		_chips(bp - Vector2(0, BR), 3, TRAMPC, 6.0)
		return
	if vn >= 0.0:
		if n.y > 0.65:
			gnd_t = 0.1
			on_sand = kind == "sand"
		return
	var vt := bv - vn * n
	if n.y > 0.65:  # 바닥
		gnd_t = 0.1
		on_sand = kind == "sand"
		var out := -vn * (E_SOFT if squeeze else E_FLOOR)
		if on_sand:
			out = 0.0
			vt.x *= 0.6
			if -vn > 4.0:
				_ping(120.0, 0.08, 60.0, 0.2)
				_chips(bp - Vector2(0, BR), 3, SANDC, 4.0)
		if out < 3.0:
			out = 0.0
		elif -vn > 5.0:
			sq = clampf(-vn / 25.0, 0.2, 0.7)
			sq_ang = PI * 0.5
			_ping(160.0 + -vn * 25.0, 0.06, 0.0, 0.2)
		bv = vt + n * out
	elif n.y < -0.65:  # 천장: 딱딱하면 옆으로 빨라진다
		var out := -vn * (E_SOFT if squeeze else 1.0)
		bv = vt + n * out
		if not squeeze and -vn > 3.0:
			if absf(bv.x) > 4.0:
				bv.x = signf(bv.x) * minf(absf(bv.x) * CEIL_MUL + CEIL_ADD, CAP)
			sq = 0.6
			sq_ang = -PI * 0.5
			shk = maxf(shk, 0.2)
			_ping(220.0 + absf(bv.x) * 30.0, 0.1, 80.0, 0.32)
			_chips(bp + Vector2(0, BR), 2, tdef.ceil, 5.0)
			if snd_cd <= 0.05:
				msg("쾅! %d" % int(absf(bv.x)), 0.35)
	else:  # 벽·모서리: 딱딱하면 그 속도 그대로 뒤로
		var out := -vn * (E_SOFT * 0.5 if squeeze else E_WALL)
		bv = vt + n * out
		if -vn > 6.0 and not squeeze:
			sq = clampf(-vn / 25.0, 0.3, 0.8)
			sq_ang = n.angle()
			shk = maxf(shk, 0.25 + -vn / 80.0)
			_ping(700.0 + -vn * 20.0, 0.05, 200.0, 0.32)
			_chips(bp - n * BR, 4, tdef.ceil, 7.0)
			msg("딱! 뒤로" if n.x < -0.5 else "딱!", 0.4)
		elif -vn > 3.0:
			_ping(150.0, 0.06, 90.0, 0.16)


func _ping(f: float, d: float, to: float, vol: float) -> void:
	if snd_cd > 0.0:
		return
	snd_cd = 0.06
	beep(f, d, to, vol)


# ---- 태엽 인형 (평범한 몸) ----
func _ai(r: Runner, dt: float) -> void:
	r.i_jump = false
	r.think -= dt
	if r.think > 0.0:
		return
	r.think = randf_range(0.04, 0.1) / r.skill
	var look := 0.8 + absf(r.v.x) * 0.12
	var ax := r.p.x + HW + 0.25 + absf(r.v.x) * 0.035
	var pit := _floor_top(ax, r.p.y + 0.6) < r.p.y - 2.0
	var wall := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, look, 1.5))
	var ob := false
	for x in obst:
		if float(x) > r.p.x and float(x) < r.p.x + HW + look + 0.6:
			ob = true
	if r.grounded and (pit or wall or ob) and randf() > r.err:
		r.i_jump = true


func _runner(r: Runner, dt: float) -> void:
	r.squash = maxf(r.squash - dt * 4.0, 0.0)
	var top := RUN_N * r.skill
	if r.p.x < camx - hwv:
		# 화면 왼쪽 밖으로 밀린 상대는 보이지 않는 동안 최대 2배로 따라붙는다
		top *= 1.0 + clampf((camx - hwv - r.p.x) / 8.0, 0.0, 1.0)
	if r.grounded and _kind_under(r.p) == "sand":
		top *= 0.6
	if r.i_jump and r.grounded:
		r.v.y = JUMP_N
		r.grounded = false
		if absf(r.p.x - camx) < hwv:
			beep(420.0, 0.08, 1000.0, 0.08)
	var acc := GROUND_ACC if r.grounded else AIR_ACC_R
	r.v.x = move_toward(r.v.x, top, acc * dt)
	r.v.y = maxf(r.v.y - GRAV_R * dt, -MAX_FALL)
	var fall := r.v.y
	for s in 2:
		_mx(r, r.v.x * dt * 0.5)
		_my(r, r.v.y * dt * 0.5)
	var was := r.grounded
	_probe(r)
	if r.grounded and not was:
		r.squash = 0.35 + clampf(-fall / 60.0, 0.0, 0.35)


func _box(r: Runner) -> Rect2:
	return Rect2(r.p.x - HW, r.p.y, HW * 2.0, HH)


func _mx(r: Runner, dx: float) -> void:
	r.p.x += dx
	var a := _box(r)
	for q in rects:
		if q.end.x < a.position.x - 1.0 or q.position.x > a.end.x + 1.0:
			continue
		if not q.intersects(a):
			continue
		if r.grounded and q.end.y - r.p.y <= STEP and q.end.y > r.p.y:
			r.p.y = q.end.y
			a = _box(r)
			continue
		r.p.x = q.position.x - HW - 0.001 if dx > 0.0 else q.end.x + HW + 0.001
		r.v.x = 0.0
		a = _box(r)


func _my(r: Runner, dy: float) -> void:
	r.p.y += dy
	var a := _box(r)
	for q in rects:
		if q.end.x < a.position.x - 1.0 or q.position.x > a.end.x + 1.0:
			continue
		if q.intersects(a):
			if dy < 0.0:
				r.p.y = q.end.y
			else:
				r.p.y = q.position.y - HH - 0.001
			r.v.y = 0.0
			a = _box(r)


func _probe(r: Runner) -> void:
	var f := Rect2(r.p.x - HW + 0.05, r.p.y - 0.06, HW * 2.0 - 0.1, 0.07)
	r.grounded = false
	for q in rects:
		if q.end.x < f.position.x or q.position.x > f.end.x:
			continue
		if q.intersects(f) and q.end.y <= r.p.y + 0.02:
			r.grounded = true
			return


func _kind_under(p: Vector2) -> String:
	for i in rects.size():
		var q := rects[i]
		if p.x > q.position.x and p.x < q.end.x and absf(q.end.y - p.y) < 0.1:
			return kinds[i]
	return ""


func _floor_top(x: float, ymax: float) -> float:
	var best_y := -1.0e9
	for q in rects:
		if x > q.position.x and x < q.end.x and q.end.y <= ymax:
			best_y = maxf(best_y, q.end.y)
	return best_y


func _solid_in(a: Rect2) -> bool:
	for q in rects:
		if q.intersects(a):
			return true
	return false


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	var asp := vs.y / maxf(vs.x, 1.0)
	if phase == "race":
		hwv = lerpf(WIDE, NARROW, clampf((rt - 8.0) / 25.0, 0.0, 1.0))
	vhv = hwv * asp
	var lx := bp.x
	var ly := bp.y - BR
	var me := true
	for r in runners:
		if r.alive and r.p.x > lx:
			lx = r.p.x
			ly = r.p.y
			me = false
	var k := 1.0 - exp(-9.0 * dt)
	var off := 0.16
	if me:
		off = lerpf(0.16, 0.4, clampf(lead_t / 1.5, 0.0, 1.0))
	camx = lerpf(camx, lx - hwv * off, k)
	camy = lerpf(camy, ly + 2.5, 1.0 - exp(-4.0 * dt))
	cam.fov = rad_to_deg(2.0 * atan(hwv / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


func _chips(at: Vector2, n: int, c: Color, sp: float) -> void:
	for k in n:
		var ch: Dictionary = chips[chip_i]
		chip_i = (chip_i + 1) % chips.size()
		var nd: MeshInstance3D = ch.n
		nd.material_override = mat(c)
		nd.visible = true
		nd.position = Vector3(at.x + vrng.randf_range(-0.3, 0.3), at.y + vrng.randf_range(0.0, 0.4), vrng.randf_range(-0.5, 1.2))
		var s := vrng.randf_range(0.12, 0.3)
		nd.scale = Vector3(s, s, s)
		ch.v = Vector3(vrng.randf_range(-1.0, 1.0) * sp, vrng.randf_range(0.4, 1.0) * sp, vrng.randf_range(0.0, 3.0))
		ch.life = vrng.randf_range(0.4, 0.7)


func _draw_all(dt: float) -> void:
	var tm := Time.get_ticks_msec() * 0.001
	# 공: 부딪힌 순간은 그 면 쪽으로 납작, 아니면 날아가는 방향으로 늘어남, 꾹 중엔 눌린 떡
	if ball_poof_t > 0.0:
		ball_poof_t -= dt
		ball_poof.scale = Vector3.ONE * (1.0 + (0.5 - ball_poof_t) * 6.0)
	ball_poof.visible = ball_poof_t > 0.0
	ball.position = Vector3(bp.x, bp.y, 0)
	var spd := bv.length()
	if sq > 0.02:
		ball_sq.rotation.z = sq_ang
		ball_sq.scale = Vector3(1.0 - sq * 0.45, 1.0 + sq * 0.3, 1.0)
	elif squeeze and gnd_t > 0.0:
		ball_sq.rotation.z = PI * 0.5
		var c := chg / CHARGE_T
		ball_sq.scale = Vector3(0.8 - c * 0.2, 1.2 + c * 0.15, 1.0)
		ball.position.y = bp.y - BR * (0.2 + c * 0.2)
	else:
		ball_sq.rotation.z = bv.angle() if spd > 1.0 else 0.0
		var st := clampf(spd / 60.0, 0.0, 0.4)
		ball_sq.scale = Vector3(1.0 + st, 1.0 - st * 0.5, 1.0)
	ball_spin.rotation.z = spin - ball_sq.rotation.z
	var bc := ME.lightened(0.45) if squeeze else ME
	for m in ball_parts:
		m.material_override = mat(bc)
	for r in runners:
		if r.poof_t > 0.0:
			r.poof_t -= dt
		r.poof.visible = r.poof_t > 0.0
		if r.poof.visible:
			r.poof.scale = Vector3.ONE * (1.0 + (0.5 - r.poof_t) * 6.0)
		if not r.alive:
			continue
		var rs := absf(r.v.x)
		var bob := sin(tm * (8.0 + rs)) * 0.06 if r.grounded and rs > 1.0 else 0.0
		r.node.position = Vector3(r.p.x, r.p.y + HH * 0.375 + bob, 0)
		r.node.scale = Vector3(1.0 + r.squash * 0.4, 1.0 - r.squash * 0.45, 1.0)
		r.key.rotation.x = tm * 9.0
	for bu in bumpers:
		var n: MeshInstance3D = bu.node
		var s := 1.0 + float(bu.pulse) * 0.35
		n.scale = Vector3(float(bu.r) * 1.5 * s, float(bu.r) * 1.5 * s, 1.2)
	marker.visible = b_alive
	marker.position = Vector3(bp.x, bp.y + BR + 1.0 + sin(tm * 5.0) * 0.12, 0)
	for b in bgs:
		if b.x < camx - 26.0:
			b.x += 52.0
			_bg_shape(b)
	for l in lamps:
		if l.x < camx - 18.0:
			l.x += 36.0
			_lamp_place(l)
	# 속도 바람줄: 공이 빠를 때 화면 앞을 휙휙 지나간다
	var psp := absf(bv.x)
	var on := phase == "race" and b_alive and psp > 13.0
	for ln in lines:
		var n2: MeshInstance3D = ln.n
		n2.visible = on
		if on:
			ln.x -= (psp * 2.5) * dt
			if ln.x < -9.0:
				ln.x = 9.0
				ln.y = vrng.randf_range(-5.0, 5.0)
			n2.scale = Vector3(0.6 + (psp - 13.0) * 0.12, 0.05, 0.05)
			n2.position = Vector3(camx + ln.x * hwv / WIDE, camy + ln.y * hwv / WIDE, 9.0)
	for ch in chips:
		if ch.life <= 0.0:
			continue
		ch.life -= dt
		var nd: MeshInstance3D = ch.n
		ch.v.y -= 30.0 * dt
		nd.position += ch.v * dt
		nd.rotation += Vector3(7.0, 5.0, 9.0) * dt
		if ch.life <= 0.0:
			nd.visible = false
	var ed := bp.x - (camx - hwv)
	var k2 := (CAM_D - 1.6) / CAM_D
	edge_strip.visible = phase == "race" and b_alive and ed < 4.0 and (ed > 2.0 or fmod(tm, 0.16) < 0.1)
	edge_strip.position = Vector3(camx - hwv * k2 + 0.18, camy, 1.6)
	edge_strip.scale = Vector3(0.35 + maxf(0.0, 4.0 - ed) * 0.1, vhv * 2.0, 0.2)
