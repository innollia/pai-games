extends Tofu
## 너무 센 몸으로 화면 밖 경주 (옆모습 4인 경주): 왼쪽 아래 조이스틱 좌우, 점프(늘 천장에 쾅), 대시(벽에 꽝). 카메라는 1등을 따라가고 화면 왼쪽 밖으로 밀리면 탈락.
## 한 문장: 나는 힘이 너무 센 주자로서 1등만 따라가는 화면 안에서 점프·대시해 결승에 먼저 닿지만, 그 힘이 천장에선 쾅(쌓일수록 오래 어질), 벽에선 꽝(위로 튕김)이 되어 화면 밖으로 밀려나는 대가를 감수한다.
## v2: 쾅은 가속이지만 3번마다 어질이 길어진다(0.25→0.5→0.75초, 보라 무게추로 풀림). 벽 3칸 앞 빨간 줄무늬, 꽝은 위로 튕김.
## 손으로 짠 트랙 4개, 장소마다 힘의 뜻이 바뀐다: 창고(천장·벽) → 하수도(물: 대시=물수제비 2배, 걷기 반속, 금 간 벽은 대시로 부숨)
## → 공장(프레스가 박자 맞춰 내려찍음, 눌리면 1초 기절·뒤로 밀림) → 지붕(천장 없음, 높이 뜨면 바람에 밀려 넓은 틈에 빠짐, 대시로 건넘).
## 지면 그 트랙부터 다시. 상대가 먼저 닿거나 내가 밀리면 끝.

const GRAV := 40.0
const JUMP_ME := 24.0  # 꼭대기 7칸: 낮은 천장(4칸)에는 반드시 박는다
const JUMP_N := 13.0  # 평범한 점프 (상대, 무게추)
const RUN_ME := 12.5
const RUN_N := 10.8
const GROUND_ACC := 60.0
const AIR_ACC := 25.0
const FRICTION := 40.0
const MAX_FALL := 28.0
const DASH_ME := 40.0
const DASH_N := 17.0
const DASH_T := 0.22
const DASH_CD := 0.6
const SLAM := 20.0  # 이보다 빠르게 벽에 박으면 꽝 (어질, 위로 튕김)
const BONK_CAP := 30.0
const HW := 0.4
const HH := 1.2
const STEP := 0.55
const COYOTE := 0.1
const JBUF := 0.12
const CAM_D := 22.0
const WIDE := 12.0
const NARROW := 7.0
const WEIGHT_T := 6.0
const CEIL_LO := 4.2
const CEIL_HI := 11.0
const POOL_D := 0.5  # 물웅덩이 바닥 깊이 (걸어 나올 수 있다)
const WIND_H := 2.4  # 지붕: 마지막 발판보다 이만큼 높이 뜨면 바람
const PRESS_P := 2.0  # 프레스 한 박자(초)
const WEIGHTC := Color("cc5de8")
const PINK := Color("f783ac")
const WATER := Color("339af0")
const TRACKS := [
	{"name": "창고", "sky": Color("fff4e0"), "gnd": Color("ffd8a8"), "top": Color("ff922b"), "ceil": Color("e8590c"),
		"bld": [Color("ffc9c9"), Color("ffec99"), Color("d3f9d8")], "bh": Vector2(6, 18), "bw": Vector2(2, 5), "bz": -10.0,
		"lo": CEIL_LO, "hi": CEIL_HI, "drift": "crate", "ai": 0.0,
		"segs": ["open", "wall", "hall", "weight", "hall", "pit", "open", "openwall", "hall", "step", "wall", "open",
			"pitlow", "hall", "weight", "hall", "openwall", "open", "pit", "hall", "wall", "step", "open", "openwall", "hall",
			"pitlow", "wall", "open"]},
	{"name": "하수도", "sky": Color("e3fafc"), "gnd": Color("d8f5a2"), "top": Color("66a80f"), "ceil": Color("4c6ef5"),
		"bld": [Color("c5f6fa"), Color("d0ebff"), Color("e5dbff")], "bh": Vector2(11, 15), "bw": Vector2(3, 6), "bz": -7.0,
		"lo": CEIL_LO, "hi": 6.0, "drift": "drip", "ai": 0.0,
		"segs": ["hall", "pool", "hall", "crack", "weight", "pool", "poolcrack", "hall", "pitlow", "pool", "step", "crack",
			"hall", "pool", "open", "pool", "wall", "hall", "poolcrack", "pitlow", "weight", "pool", "crack", "step", "pool",
			"hall"]},
	{"name": "공장", "sky": Color("f3f0ff"), "gnd": Color("e5dbff"), "top": Color("ae3ec9"), "ceil": Color("9775fa"),
		"bld": [Color("f3d9fa"), Color("dbe4ff"), Color("ffdeeb")], "bh": Vector2(12, 24), "bw": Vector2(1.2, 2.6), "bz": -11.0,
		"lo": CEIL_LO, "hi": CEIL_HI, "drift": "steam", "ai": 0.02,
		"segs": ["open", "press", "crack", "press2", "hall", "weight", "press", "pitlow", "open", "openwall", "press2", "pool",
			"crack", "hall", "press", "open", "press2", "wall", "pit", "press", "weight", "crack", "press2", "hall", "press",
			"open"]},
	{"name": "지붕", "sky": Color("ffe8cc"), "gnd": Color("ffc078"), "top": Color("e8590c"), "ceil": Color("d9480f"),
		"bld": [Color("ffd8a8"), Color("fcc2d7"), Color("eebefa")], "bh": Vector2(10, 26), "bw": Vector2(2.5, 5), "bz": -15.0,
		"lo": 0.0, "hi": 0.0, "drift": "cloud", "ai": 0.0,
		"segs": ["roof", "gap", "roof", "chimney", "gap", "drop", "roof", "stair", "gap", "roof", "chimney", "weight", "gap",
			"chimney", "drop", "gap", "roof", "gap", "roof", "stair", "gap", "stair", "chimney", "gap", "roof", "drop", "gap",
			"weight", "gap", "roof"]},
]
const HINTS := {
	"wall": "빨간 줄 = 벽! 대시 끊어", "pool": "물: 대시하면 물수제비", "crack": "금 간 벽: 대시로 부숴",
	"press": "프레스 박자를 봐", "gap": "높이 뜨면 바람! 대시로 건너", "weight": "보라 = 힘이 평범해짐",
}


class Runner:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var grounded := false
	var alive := true
	var ai := true
	var nick := ""
	var col := Color.WHITE
	var node: Node3D
	var body: MeshInstance3D
	var pack: MeshInstance3D
	var poof: MeshInstance3D
	var stars: Array[MeshInstance3D] = []
	var streaks: Array[MeshInstance3D] = []
	var stun := 0.0
	var hang := 0.0
	var dash := 0.0
	var dash_cd := 0.0
	var weight_t := 0.0
	var coyote := 0.0
	var jbuf := 0.0
	var cut := true
	var face := 1.0
	var skill := 1.0
	var err := 0.2
	var think := 0.0
	var poof_t := 0.0
	var squash := 0.0
	var chain := 0  # 쾅 누적 (3번마다 어질이 길어진다, 무게추로 풀림)
	var gy := 0.0  # 마지막으로 서 있던 높이 (지붕 바람)
	var skipped := false  # 이번 대시에 물수제비를 이미 했나
	var wet := false
	var windy := false
	# 이번 프레임 입력
	var mx := 0.0
	var i_jump := false
	var i_jheld := false
	var i_dash := false


var ti := 0  # 트랙
var resume_ti := 0  # 지면 이 트랙부터 다시 (restart 뒤에도 남는다)
var phase := "count"
var pt := 0.0
var rt := 0.0
var tdef: Dictionary
var stage: Node3D
var rects: Array[Rect2] = []
var weights: Array = []
var cracks := {}  # rects 번호 -> 금 간 벽 상자
var pools: Array = []  # {x0, x1, gy}
var presses: Array = []  # {i, x, w, gy, ph, u, node, lamp}
var hints: Array = []  # {x, key}
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
var pl: Runner
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
var bonks := 0
var pclock := 0.0
var sky_env: Environment
# 돌려 쓰는 비주얼 상자
var bgs: Array = []  # 먼 건물 {n, x}
var lamps: Array = []  # 앞 가로등 {post, arm, x}
var drifts: Array = []  # 움직이는 배경 {n, p, v}
var lines: Array = []  # 속도 바람줄 {n, x, y}
var chips: Array = []  # 파편 {n, v, life}
var chip_i := 0


func _setup() -> void:
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	howto = "4인 경주. 카메라는 1등만 따라간다. 화면 왼쪽 밖으로 밀리거나 구덩이에 빠지면 탈락.\n내 몸은 너무 세다. 점프는 천장에 쾅(빨라지지만 3번마다 더 오래 어질), 대시는 벽에 꽝(위로 튕김). 빨간 줄 = 3칸 앞 벽.\n보라 무게추 = 6초간 힘이 평범, 어질 풀림.\n트랙 4개: 창고 → 하수도(물 위 대시=물수제비, 금 간 벽은 부숨) → 공장(프레스 박자) → 지붕(높이 뜨면 바람). 조이스틱 좌우, 점프, 대시."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1120), 100.0, A)
	kit_button("dash", "대시", Vector2(600, 890), 82.0, C)
	for c in get_children():
		if c is WorldEnvironment:
			sky_env = (c as WorldEnvironment).environment


func _reset() -> void:
	ti = resume_ti
	stage = null
	bonks = 0
	runners.clear()
	var cols := [ME, A, B, PINK]
	var nicks := ["나", "주황", "하늘", "분홍"]
	for i in 4:
		var r := Runner.new()
		r.ai = i > 0
		r.col = cols[i]
		r.nick = nicks[i]
		_make_body(r)
		runners.append(r)
	pl = runners[0]
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	marker = box(Vector3.ZERO, Vector3(0.36, 0.36, 0.36), ME)
	marker.rotation.z = PI * 0.25
	_make_pools()
	_build_track()
	_start_race()


func _make_body(r: Runner) -> void:
	r.node = Node3D.new()
	world.add_child(r.node)
	r.body = box(Vector3(0, 0, 0), Vector3(HW * 2.0, HH * 0.75, 0.8), r.col, r.node)
	box(Vector3(0, 0.63, 0), Vector3(0.42, 0.36, 0.5), SOFT, r.node)
	box(Vector3(0.05, 0.88, 0), Vector3(0.6, 0.14, 0.6), WHITE if not r.ai else r.col.darkened(0.2), r.node)
	r.pack = box(Vector3(-0.5, 0.1, 0), Vector3(0.5, 0.5, 0.5), WEIGHTC, r.node)
	r.pack.visible = false
	r.poof = box(Vector3.ZERO, Vector3(1, 1, 1), WHITE)
	r.poof.visible = false
	for k in 3:
		var s := box(Vector3.ZERO, Vector3(0.2, 0.2, 0.2), D, r.node)
		s.visible = false
		r.stars.append(s)
	for k in 3:
		var s := box(Vector3.ZERO, Vector3(1, 0.07, 0.07), WHITE)
		s.visible = false
		r.streaks.append(s)


## 판 시작 때 한 번: 배경·파편·바람줄 상자를 만들어 두고 트랙마다 색만 바꿔 돌려 쓴다
func _make_pools() -> void:
	bgs.clear()
	lamps.clear()
	drifts.clear()
	lines.clear()
	chips.clear()
	for k in 12:
		bgs.append({"n": box(Vector3.ZERO, Vector3.ONE, WHITE), "x": 0.0})
	for k in 4:
		lamps.append({"post": box(Vector3.ZERO, Vector3(0.22, 3.0, 0.22), WHITE),
			"arm": box(Vector3.ZERO, Vector3(0.9, 0.22, 0.3), WHITE), "x": 0.0})
	for k in 8:
		drifts.append({"n": box(Vector3.ZERO, Vector3.ONE, WHITE), "p": Vector3.ZERO, "v": Vector3.ZERO})
	for k in 6:
		var n := box(Vector3.ZERO, Vector3(1, 0.05, 0.05), WHITE)
		n.visible = false
		lines.append({"n": n, "x": 0.0, "y": 0.0})
	for k in 20:
		var n := box(Vector3.ZERO, Vector3(0.25, 0.25, 0.25), WHITE)
		n.visible = false
		chips.append({"n": n, "v": Vector3.ZERO, "life": 0.0})


# ---- 트랙 만들기 (손으로 짠 순서, 폭도 트랙마다 늘 같다) ----
func _build_track() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	tdef = TRACKS[ti]
	if sky_env:
		sky_env.background_color = tdef.sky
	rects.clear()
	weights.clear()
	cracks.clear()
	pools.clear()
	presses.clear()
	hints.clear()
	frun = {}
	crun = {}
	gen.seed = 1009 + ti * 7919
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
	# 돌려 쓰는 배경 상자 색·자리
	for k in bgs.size():
		var b: Dictionary = bgs[k]
		b.x = -26.0 + k * (52.0 / bgs.size())
		_bg_shape(b)
	for k in lamps.size():
		var l: Dictionary = lamps[k]
		l.x = -6.0 + k * 9.0
		(l.post as MeshInstance3D).material_override = mat(WHITE)
		(l.arm as MeshInstance3D).material_override = mat(tdef.top)
		_lamp_place(l)
	for d in drifts:
		_drift_reset(d, true)
	for c in chips:
		c.life = 0.0
		(c.n as Node3D).visible = false
	for ln in lines:
		ln.x = vrng.randf_range(-12.0, 12.0)
		ln.y = vrng.randf_range(-6.0, 6.0)


func _bg_shape(b: Dictionary) -> void:
	var bh: Vector2 = tdef.bh
	var bw: Vector2 = tdef.bw
	var w := vrng.randf_range(bw.x, bw.y)
	var h := vrng.randf_range(bh.x, bh.y)
	var bld: Array = tdef.bld
	var n: MeshInstance3D = b.n
	n.material_override = mat(bld[vrng.randi() % bld.size()])
	n.scale = Vector3(w, h, 3.0)
	n.position = Vector3(b.x, h * 0.5 - 10.0, tdef.bz - vrng.randf() * 2.0)


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
		"open", "roof":
			var w := gen.randf_range(8.0, 12.0)
			_floor(gx, w, hi)
			gx += w
		"pit", "pitlow", "gap":
			var ch := hi if s != "pitlow" else lo
			var g := gen.randf_range(3.0, 4.5) if s != "gap" else gen.randf_range(4.6, 5.8)
			_floor(gx, 3.0, ch)
			_stripes(gx, D)
			gx += 3.0
			_ceil(gx, g, ch)
			if s == "gap":
				_hint(gx, "gap")
			gx += g
			_floor(gx, 4.0, ch)
			gx += 4.0
		"wall":
			_floor(gx, 9.0, lo)
			_stripes(gx + 1.5, BAD)
			_hint(gx, "wall")
			_solid(Rect2(gx + 4.5, fy, 0.9, gen.randf_range(1.3, 2.0)), wallc)
			gx += 9.0
		"openwall":
			_floor(gx, 13.0, hi)
			_stripes(gx + 1.0, BAD)
			_stripes(gx + 6.0, BAD)
			_hint(gx, "wall")
			_solid(Rect2(gx + 4.0, fy, 0.9, 1.8), wallc)
			_solid(Rect2(gx + 9.0, fy, 0.9, 1.5), wallc)
			gx += 13.0
		"antenna":
			_floor(gx, 9.0, lo)
			_stripes(gx + 2.0, BAD)
			_solid(Rect2(gx + 5.0, fy, 0.5, 1.15), INK.lightened(0.3))
			gx += 9.0
		"weight":
			_floor(gx, 8.0, lo)
			_weight(gx + 4.0, fy + 0.35)
			_hint(gx, "weight")
			gx += 8.0
		"step", "stair":
			var up := s == "stair" or fy < -1.0 or (fy < 3.0 and gen.randf() < 0.5)
			for k in 4:
				_floor(gx, 1.3, lo)
				gx += 1.3
				fy += 0.5 if up else -0.5
			_floor(gx, 3.0, lo)
			gx += 3.0
		"drop":
			_floor(gx, 6.0, hi)
			gx += 6.0
			fy -= 1.6
			_floor(gx, 4.0, hi)
			gx += 4.0
		"pool", "poolcrack":
			_floor(gx, 2.0, lo)
			gx += 2.0
			var w := gen.randf_range(8.0, 11.0)
			_pool(gx, w, lo)
			_hint(gx, "pool")
			gx += w
			if s == "poolcrack":
				_floor(gx, 6.0, lo)
				_crack(gx + 2.6, 1.8)
				gx += 6.0
			else:
				_floor(gx, 2.0, lo)
				gx += 2.0
		"crack", "chimney":
			_floor(gx, 9.0, lo)
			_stripes(gx + 2.0, A)
			_hint(gx, "crack")
			_crack(gx + 5.0, 1.8 if s == "crack" else 1.6)
			gx += 9.0
		"press", "press2":
			var w := 11.0 if s == "press" else 15.0
			_floor(gx, w, hi)
			_hint(gx, "press")
			var ph := gen.randf()
			_press(gx + 4.2, ph)
			if s == "press2":
				_press(gx + 9.6, ph + 0.5)
			gx += w
	min_fy = minf(min_fy, fy)


## 바닥: 같은 높이로 이어지는 바닥·천장은 상자 하나로 합친다 (상자 수를 아낀다)
func _floor(x: float, w: float, ch: float) -> void:
	if not frun.is_empty() and absf(frun.y - fy) < 0.001 and absf(frun.x1 - x) < 0.01:
		frun.x1 = x + w
	else:
		_flush_floor()
		frun = {"x0": x, "x1": x + w, "y": fy}
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
	_solid(Rect2(frun.x0, frun.y - 14.0, w, 14.0), tdef.gnd)
	box(Vector3(frun.x0 + w * 0.5, frun.y - 0.1, 0), Vector3(w, 0.2, 2.5), tdef.top, stage)
	frun = {}


func _flush_ceil() -> void:
	if crun.is_empty():
		return
	_solid(Rect2(crun.x0, crun.y, crun.x1 - crun.x0, 3.0), tdef.ceil)
	crun = {}


func _solid(rc: Rect2, c: Color) -> MeshInstance3D:
	rects.append(rc)
	var m := rc.get_center()
	return box(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, 2.4), c, stage)


## 벽·구덩이 3칸 앞 바닥 앞면의 줄무늬 (선두 카메라로도 미리 보인다)
func _stripes(x0: float, c: Color) -> void:
	for k in 3:
		box(Vector3(x0 + 0.25 + k * 1.0, fy - 0.1, 0), Vector3(0.5, 0.24, 2.62), c, stage)


func _hint(x: float, key: String) -> void:
	if not hint_done.has(key):
		hints.append({"x": x, "key": key})


func _weight(x: float, y: float) -> void:
	var n := box(Vector3(x, y, 0), Vector3(0.9, 0.7, 0.9), WEIGHTC, stage)
	box(Vector3(0, 0.6, 0), Vector3(0.5, 0.25, 0.3), INK, n)
	weights.append({"p": Vector2(x, y), "node": n, "on": true})


## 금 간 벽: 센 대시(20 넘게)로 박으면 부서진다. 그래도 0.4초 어질 (뒤의 상대가 그 구멍을 공짜로 쓴다)
func _crack(x: float, h: float) -> void:
	var c: Color = tdef.ceil
	var n := _solid(Rect2(x, fy, 0.9, h), c.lightened(0.35))
	box(Vector3(-0.1, 0.15, 0.51), Vector3(0.12, 0.6, 0.02), INK, n)
	box(Vector3(0.12, -0.2, 0.51), Vector3(0.5, 0.06, 0.02), INK, n)
	cracks[rects.size() - 1] = n


## 물웅덩이: 바닥이 0.5 낮고 물이 차 있다. 안에선 걷기 반속, 물 위 대시는 한 번 더 늘어난다(물수제비)
func _pool(x: float, w: float, ch: float) -> void:
	var g := fy
	_flush_floor()
	fy = g - POOL_D
	_floor(x, w, ch + POOL_D)
	_flush_floor()
	fy = g
	box(Vector3(x + w * 0.5, g - POOL_D + 0.19, 0), Vector3(w, 0.38, 2.45), WATER, stage)
	box(Vector3(x + w * 0.5, g - 0.1, 0), Vector3(w, 0.05, 2.5), Color("e7f5ff"), stage)
	pools.append({"x0": x, "x1": x + w, "gy": g})


## 프레스: 박자마다 내려찍는다. 내려오는 프레스에 쾅 = 더 빨라짐, 눌리면 1초 기절하고 뒤로 밀린다
func _press(x: float, ph: float) -> void:
	var w := 2.6
	rects.append(Rect2(x, fy + 5.0, w, 2.0))
	var n := box(Vector3(x + w * 0.5, fy + 6.0, 0), Vector3(w, 2.0, 2.3), Color("868e96").lightened(0.35), stage)
	box(Vector3(0, 2.5, 0), Vector3(0.25, 3.0, 0.25), INK.lightened(0.4), n)  # 축
	var lamp := box(Vector3(0, 0.62, 0.0), Vector3(0.3, 0.25, 0.6), GOOD, n)
	for k in 2:
		box(Vector3(x + 0.55 + k * 1.5, fy - 0.1, 0), Vector3(0.5, 0.24, 2.62), D, stage)
	presses.append({"i": rects.size() - 1, "x": x, "w": w, "gy": fy, "ph": fposmod(ph, 1.0), "u": 0.0,
		"node": n, "lamp": lamp, "bot": fy + 5.0, "desc": false})


func _press_bottom(u: float, gy: float) -> float:
	var hi_y := gy + 5.0
	var lo_y := gy + 0.7
	if u < 0.5:
		return hi_y
	if u < 0.58:
		var k := (u - 0.5) / 0.08
		return lerpf(hi_y, lo_y, k * k)
	if u < 0.72:
		return lo_y
	return lerpf(lo_y, hi_y, (u - 0.72) / 0.28)


func _presses(dt: float, live: bool) -> void:
	pclock += dt
	for pr in presses:
		var before: float = pr.u
		pr.u = fposmod(pclock / PRESS_P + pr.ph, 1.0)
		var u: float = pr.u
		var b := _press_bottom(u, pr.gy)
		pr.desc = u >= 0.5 and u < 0.58
		pr.bot = b
		var i: int = pr.i
		rects[i] = Rect2(pr.x, b, pr.w, 2.0)
		var n: MeshInstance3D = pr.node
		var jit := sin(pclock * 70.0) * 0.06 if u > 0.32 and u < 0.5 else 0.0
		n.position = Vector3(pr.x + pr.w * 0.5 + jit, b + 1.0, 0)
		var lc := GOOD
		if u > 0.32 and u < 0.5:
			lc = D
		elif u >= 0.5 and u < 0.72:
			lc = BAD
		(pr.lamp as MeshInstance3D).material_override = mat(lc)
		# 쿵 소리: 화면 안에서 바닥에 닿는 순간
		if before < 0.58 and u >= 0.58 and absf(pr.x - camx) < hwv + 2.0:
			beep(70.0, 0.12, 40.0, 0.3)
			_chips(Vector2(pr.x + pr.w * 0.5, pr.gy + 0.2), 3, SOFT, 5.0)
			shk = maxf(shk, 0.08)
		if not live or not pr.desc:
			continue
		var rc := rects[i]
		for r in runners:
			if not r.alive:
				continue
			var a := _box(r)
			if a.intersects(rc) and r.p.y < rc.position.y:
				_crush(r, rc)


func _crush(r: Runner, rc: Rect2) -> void:
	r.p.x = rc.position.x - HW - 0.02
	r.v = Vector2(-3.0, 0.0)
	r.dash = 0.0
	r.stun = maxf(r.stun, 1.0)
	r.squash = 0.9
	_snd(r, 90.0, 0.25, 40.0, 0.45)
	if r == pl:
		shk = maxf(shk, 0.5)
		msg("눌림!", 0.6)
		_chips(r.p + Vector2(0, 0.6), 4, r.col, 7.0)


func _press_of(q: Rect2) -> Variant:
	for pr in presses:
		if rects[pr.i].is_equal_approx(q):
			return pr
	return null


# ---- 경주 ----
func _start_race() -> void:
	var xs := [-2.2, -1.0, -3.4, -4.6]
	for i in 4:
		var r := runners[i]
		r.p = Vector2(xs[i], 0.0)
		r.v = Vector2.ZERO
		r.alive = true
		r.stun = 0.0
		r.hang = 0.0
		r.dash = 0.0
		r.dash_cd = 0.0
		r.weight_t = 0.0
		r.cut = true
		r.face = 1.0
		r.poof_t = 0.0
		r.squash = 0.0
		r.chain = 0
		r.gy = 0.0
		r.node.visible = true
		r.node.rotation = Vector3.ZERO
		r.poof.visible = false
		if r.ai:
			r.skill = 0.95 + 0.03 * ti + (i - 2) * 0.02 + float(tdef.ai)
			r.err = maxf(0.2 - 0.05 * ti, 0.05)
		_probe(r)
	for w in weights:
		w.on = true
		(w.node as Node3D).visible = true
	rt = 0.0
	pclock = 0.0
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
	_presses(dt, phase == "race")
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
		"done":
			pt -= dt
			if pt <= 0.0:
				_next_track()
	_camera(dt)
	_draw_all(dt)


func _race(dt: float) -> void:
	pl.mx = kit_move.x
	pl.i_jump = kit_just("jump")
	pl.i_jheld = kit_held("jump")
	pl.i_dash = kit_just("dash")
	for r in runners:
		if r.alive and r.ai:
			_ai(r, dt)
	for r in runners:
		if r.alive:
			_runner(r, dt)
	_pickups()
	# 처음 보는 장소 알림 (판마다 한 번)
	for h in hints:
		if not hint_done.has(h.key) and pl.p.x > float(h.x) - 9.0:
			hint_done[h.key] = true
			msg(HINTS[h.key], 1.4)
			beep(660.0, 0.08, 990.0, 0.18)
	# 탈락
	var left := camx - hwv
	for r in runners:
		if not r.alive:
			continue
		# 화면 왼쪽 밖 탈락은 나만. 상대는 구덩이로만 죽고, 뒤처지면 화면 밖에서 따라붙는다
		if r.p.y < kill_y or (r == pl and (r.p.x + HW < left or r.p.y < camy - vhv - 1.0)):
			_out(r)
	if not pl.alive:
		msg("밀려났다", 1.6)
		resume_ti = ti
		end()
		return
	for r in runners:
		if r.alive and r.p.x > goal_x:
			_race_over(r)
			return
	var n := 0
	for r in runners:
		if r.alive:
			n += 1
	if n <= 1:
		_race_over(pl)
		return
	if _leader() == pl:
		if lead_t == 0.0:
			msg("선두!", 0.6)
			beep(900.0, 0.1, 1400.0, 0.2)
		lead_t += dt
	else:
		lead_t = 0.0
	# 화면 끝 압박
	var ed := pl.p.x - left
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
	if r == pl:
		play("bad")
		shk = 0.6
	else:
		score += 5
		beep(300.0, 0.2, 120.0, 0.25)
		shk = maxf(shk, 0.25)
		msg("%s 탈락" % r.nick, 0.6)


func _race_over(w: Runner) -> void:
	phase = "done"
	pt = 1.6
	if w == pl:
		score += 50
		play("win")
		msg("1등!", 1.6)
	else:
		beep(330.0, 0.3, 200.0, 0.25)
		msg("%s 먼저 도착" % w.nick, 1.6)


func _next_track() -> void:
	var w := _leader()
	if w != pl and pl.p.x <= goal_x:
		resume_ti = ti
		end()
		return
	ti += 1
	if ti >= TRACKS.size():
		resume_ti = 0
		msg("완주!", 3.0)
		end()
		return
	play("good")
	_build_track()
	_start_race()


# ---- 달리기 한 명 ----
func _runner(r: Runner, dt: float) -> void:
	r.squash = maxf(r.squash - dt * 4.0, 0.0)
	r.dash_cd = maxf(r.dash_cd - dt, 0.0)
	var heavy := r.weight_t > 0.0
	if heavy:
		r.weight_t -= dt
		if r.weight_t <= 0.0 and r == pl:
			msg("무게추 떨어짐", 0.8)
			beep(500.0, 0.12, 900.0, 0.2)
	var normal := r.ai or heavy
	var top := RUN_N * r.skill if r.ai else (RUN_N if heavy else RUN_ME)
	if r.ai and r.p.x < camx - hwv:
		# 화면 왼쪽 밖으로 밀린 상대는 보이지 않는 동안 최대 2배로 따라붙는다(화면 안에서는 평범하게 뛴다)
		top *= 1.0 + clampf((camx - hwv - r.p.x) / 8.0, 0.0, 1.0)
	var was_wet := r.wet
	r.wet = _in_water(r)
	if r.wet:
		# 너무 센 몸은 무거워 물에 잠긴다: 나는 반속, 평범한 상대는 덜 느려진다 -> 물에서는 물수제비가 답
		top *= 0.45 if not normal else 0.8
		if not was_wet and r.v.y < -2.0:
			_snd(r, 300.0, 0.1, 120.0, 0.2)
			_chips(r.p, 3, WATER, 6.0)
	var mx := r.mx
	if r.stun > 0.0:
		r.stun -= dt
		mx = 0.0
		r.i_jump = false
		r.i_dash = false
	if r.grounded:
		r.gy = r.p.y
	r.coyote = COYOTE if r.grounded else maxf(r.coyote - dt, 0.0)
	r.jbuf = JBUF if r.i_jump else maxf(r.jbuf - dt, 0.0)
	if r.jbuf > 0.0 and r.coyote > 0.0 and r.hang <= 0.0:
		r.v.y = JUMP_N if normal else JUMP_ME
		r.coyote = 0.0
		r.jbuf = 0.0
		r.grounded = false
		r.cut = false
		r.dash = 0.0
		_snd(r, 420.0 if normal else 300.0, 0.1, 1000.0 if normal else 1300.0, 0.24)
	if not r.cut and r.v.y > 0.0 and not r.i_jheld:
		r.v.y *= 0.7 if normal else 0.93
		r.cut = true
	if r.i_dash and r.dash_cd <= 0.0 and r.hang <= 0.0:
		r.dash = DASH_T
		r.dash_cd = DASH_CD
		r.skipped = false
		r.v.x = (DASH_N if normal else DASH_ME) * (r.face if r.face != 0.0 else 1.0)
		if r.wet:
			# 물속에서 대시: 수면으로 튀어 올라 물수제비
			var pool: Variant = _pool_at(r.p.x)
			if pool != null:
				r.p.y = float(pool.gy) + 0.02
				_chips(r.p, 3, WATER, 8.0)
		_snd(r, 260.0, 0.16, 1500.0, 0.3)
		if r == pl and not normal:
			shk = maxf(shk, 0.12)
	r.windy = false
	if r.hang > 0.0:
		r.hang -= dt
		r.v.y = 0.0
	elif r.dash > 0.0:
		r.dash -= dt
		r.v.y = 0.0
		if r.dash <= 0.0:
			if not r.skipped and _over_water(r):
				# 물수제비: 물 위에서 대시가 끝나면 한 번 더 같은 거리
				r.skipped = true
				r.dash = DASH_T
				_snd(r, 700.0, 0.06, 1100.0, 0.22)
				_chips(r.p, 3, WATER, 7.0)
				if r == pl and not hint_done.has("skip"):
					hint_done["skip"] = true
					msg("물수제비!", 0.6)
			else:
				r.v.x = signf(r.v.x) * top
	else:
		var acc := GROUND_ACC if r.grounded else AIR_ACC
		var high: bool = not r.grounded and tdef.lo <= 0.0 and r.p.y - r.gy > WIND_H
		if high:
			# 지붕: 높이 뜨면 맞바람. 손을 못 쓰고 뒤로 밀린다 (센 점프 24만 이만큼 뜬다)
			r.windy = true
			r.v.x = move_toward(r.v.x, -2.0, (18.0 + absf(r.v.x) * 1.2) * dt)
		elif absf(mx) > 0.15:
			var want := signf(mx) * top
			if signf(r.v.x) != signf(mx) or absf(r.v.x) < top:
				r.v.x = move_toward(r.v.x, want, acc * dt)
			else:
				r.v.x = move_toward(r.v.x, want, (8.0 if r.grounded else 1.5) * dt)
			r.face = signf(mx)
		else:
			r.v.x = move_toward(r.v.x, 0.0, (FRICTION if r.grounded else 4.0) * dt)
		r.v.y = maxf(r.v.y - GRAV * dt, -MAX_FALL)
	var fall := r.v.y
	for s in 2:
		_mx(r, r.v.x * dt * 0.5)
		_my(r, r.v.y * dt * 0.5)
	var was := r.grounded
	_probe(r)
	if r.grounded and not was:
		r.squash = maxf(r.squash, 0.35 + clampf(-fall / 60.0, 0.0, 0.35))
		_snd(r, 90.0, 0.06, 0.0, 0.18)
		if r == pl and fall < -14.0:
			_chips(r.p, 2, SOFT, 4.0)


func _box(r: Runner) -> Rect2:
	return Rect2(r.p.x - HW, r.p.y, HW * 2.0, HH)


func _mx(r: Runner, dx: float) -> void:
	if dx == 0.0:
		return
	r.p.x += dx
	var a := _box(r)
	for i in rects.size():
		var q := rects[i]
		if q.end.x < a.position.x - 1.0 or q.position.x > a.end.x + 1.0:
			continue
		if not q.intersects(a):
			continue
		if (r.grounded or r.dash > 0.0) and q.end.y - r.p.y <= STEP and q.end.y > r.p.y:
			r.p.y = q.end.y
			a = _box(r)
			continue
		_bump_x(r, q, dx, i)
		a = _box(r)


## 벽에 옆으로 박기: 내가 빠르면 꽝 (어질, 위로 튕김) 또는 금 간 벽이면 부순다. 평범한 몸은 그냥 멈춘다
func _bump_x(r: Runner, q: Rect2, dx: float, i: int) -> void:
	var sp := absf(r.v.x)
	var strong := not (r.ai or r.weight_t > 0.0)
	if sp > SLAM and strong and cracks.has(i):
		var n: MeshInstance3D = cracks[i]
		cracks.erase(i)
		rects[i] = Rect2(-9999.0, -9999.0, 0.0, 0.0)
		n.visible = false
		var c: Color = tdef.ceil
		_chips(Vector2(q.get_center().x, q.position.y + q.size.y * 0.5), 8, c.lightened(0.35), 11.0)
		r.dash = 0.0
		r.stun = maxf(r.stun, 0.4)
		r.squash = 0.6
		r.v.x = signf(dx) * 5.0
		if r == pl:
			shk = maxf(shk, 0.4)
			msg("부쉈다!", 0.4)
		_snd(r, 140.0, 0.25, 50.0, 0.45)
		_snd(r, 1000.0, 0.06, 300.0, 0.25)
		return
	if dx > 0.0:
		r.p.x = q.position.x - HW - 0.001
	else:
		r.p.x = q.end.x + HW + 0.001
	r.dash = 0.0
	if sp > SLAM and strong:
		# 꽝: 뒤(방금 넘은 구덩이)가 아니라 위로 튕긴다. 낮은 천장이면 또 쾅
		r.stun = maxf(r.stun, 0.4)
		r.squash = 0.6
		r.v.x = -signf(dx) * 1.5
		r.v.y = 12.0
		r.grounded = false
		if r == pl:
			shk = maxf(shk, 0.3 + sp / 120.0)
			msg("꽝!", 0.35)
			_chips(Vector2(r.p.x + signf(dx) * HW, r.p.y + 0.7), 5, tdef.ceil, 8.0)
		_snd(r, 110.0, 0.2, 45.0, 0.45)
		_snd(r, 800.0, 0.04, 0.0, 0.2)
	else:
		if sp > 8.0:
			_snd(r, 160.0, 0.08, 80.0, 0.2)
		r.v.x = 0.0


func _my(r: Runner, dy: float) -> void:
	if dy == 0.0:
		return
	r.p.y += dy
	var a := _box(r)
	for q in rects:
		if q.end.x < a.position.x - 1.0 or q.position.x > a.end.x + 1.0:
			continue
		if q.intersects(a):
			_bump_y(r, q, dy)
			a = _box(r)


func _bump_y(r: Runner, q: Rect2, dy: float) -> void:
	if dy < 0.0:
		r.p.y = q.end.y
		r.v.y = 0.0
	else:
		r.p.y = q.position.y - HH - 0.001
		var pr: Variant = _press_of(q)
		_bonk(r, 1.5 if pr != null and pr.desc else 1.3)


## 천장에 박기: 내가 빠르면 옆으로 더 빨라진다. 대신 3번마다 어질이 길어진다(0.25 → 0.5 → 0.75초), 무게추로 풀린다
func _bonk(r: Runner, mult: float) -> void:
	var sp := r.v.y
	r.v.y = 0.0
	if sp < 3.0 or r.ai or r.weight_t > 0.0:
		return
	bonks += 1
	r.chain += 1
	var lv := mini((r.chain - 1) / 3, 2)
	r.hang = 0.1
	r.stun = maxf(r.stun, 0.25 * (lv + 1))
	r.dash = 0.0
	r.squash = 0.7
	if absf(r.v.x) > 6.0:
		r.v.x = signf(r.v.x) * minf(absf(r.v.x) * mult + 3.0, BONK_CAP)
	if r == pl:
		shk = maxf(shk, 0.3 + lv * 0.1)
		if r.chain == 4 or r.chain == 7:
			msg("어질 %d단! 보라로 풀기" % (lv + 1), 1.0)
		else:
			msg("쾅!" if mult < 1.4 else "프레스 쾅!", 0.35)
		_chips(Vector2(r.p.x, r.p.y + HH), 3 + lv, tdef.ceil, 6.0)
	_snd(r, 200.0 - lv * 40.0, 0.14 + lv * 0.06, 60.0, 0.45)
	_snd(r, 1300.0, 0.05, 700.0, 0.2)


func _probe(r: Runner) -> void:
	var f := Rect2(r.p.x - HW + 0.05, r.p.y - 0.06, HW * 2.0 - 0.1, 0.07)
	r.grounded = false
	for q in rects:
		if q.end.x < f.position.x or q.position.x > f.end.x:
			continue
		if q.intersects(f) and q.end.y <= r.p.y + 0.02:
			r.grounded = true
			return


## x 위에서 높이 ymax 아래 가장 높은 바닥 윗면 (없으면 아주 낮은 수)
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


func _pool_at(x: float) -> Variant:
	for pool in pools:
		if x > float(pool.x0) and x < float(pool.x1):
			return pool
	return null


func _in_water(r: Runner) -> bool:
	var pool: Variant = _pool_at(r.p.x)
	return pool != null and r.p.y < float(pool.gy) - 0.05


func _over_water(r: Runner) -> bool:
	var pool: Variant = _pool_at(r.p.x + r.face * 0.5)
	if pool == null:
		return false
	var dy: float = r.p.y - float(pool.gy)
	return dy > -0.7 and dy < 1.2


func _snd(r: Runner, f: float, d: float, to := 0.0, vol := 0.18) -> void:
	if r == pl:
		beep(f, d, to, vol)
	elif r.alive and absf(r.p.x - camx) < hwv:
		beep(f, d, to, vol * 0.45)


func _pickups() -> void:
	if pl.weight_t > 0.0:
		return
	for w in weights:
		if not w.on:
			continue
		var wp: Vector2 = w.p
		if absf(pl.p.x - wp.x) < 0.8 and wp.y - pl.p.y > -0.6 and wp.y - pl.p.y < HH:
			w.on = false
			(w.node as Node3D).visible = false
			pl.weight_t = WEIGHT_T
			pl.dash = 0.0
			msg("무게추: 힘 평범, 어질 풀림" if pl.chain >= 3 else "무게추: 힘이 평범", 1.0)
			pl.chain = 0
			beep(700.0, 0.12, 400.0, 0.22)
			shk = maxf(shk, 0.1)
			_chips(wp, 4, WEIGHTC, 5.0)
			break


func _leader() -> Runner:
	var w: Runner = null
	for r in runners:
		if r.alive and (w == null or r.p.x > w.p.x):
			w = r
	return w


# ---- 경쟁자 ----
func _ai(r: Runner, dt: float) -> void:
	r.mx = 1.0
	r.i_jump = false
	r.i_dash = false
	r.i_jheld = true
	# 프레스 앞에서는 박자를 기다린다 (밑에 들어갔으면 그냥 지나간다)
	for pr in presses:
		var px: float = pr.x
		var u: float = pr.u
		if px > r.p.x + HW - 0.05 and px < r.p.x + HW + 1.2 + absf(r.v.x) * 0.12 and u > 0.22 and u < 0.8:
			r.mx = 0.0
			return
	r.think -= dt
	if r.think > 0.0:
		return
	r.think = randf_range(0.04, 0.1) / r.skill
	var look := 0.8 + absf(r.v.x) * 0.12
	var ax := r.p.x + HW + 0.25 + absf(r.v.x) * 0.035
	var pit := _floor_top(ax, r.p.y + 0.6) < r.p.y - 2.0
	var wall := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, look, 1.5))
	if r.grounded and (pit or wall) and randf() > r.err:
		r.i_jump = true
	elif r.grounded and not wall and not pit and randf() < 0.04:
		var far := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, 6.0, 1.5))
		if not far:
			r.i_dash = true


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	var asp := vs.y / maxf(vs.x, 1.0)
	if phase == "race":
		hwv = lerpf(WIDE, NARROW, clampf((rt - 8.0) / 25.0, 0.0, 1.0))
	vhv = hwv * asp
	var lead := _leader()
	if lead:
		var k := 1.0 - exp(-9.0 * dt)
		# 내가 1등이면 화면이 앞으로 쏠려 나는 오른쪽에 붙는다 (v2: 0.55 → 0.4, 앞 벽 줄무늬가 보일 만큼)
		var off := 0.16
		if lead == pl:
			off = lerpf(0.16, 0.4, clampf(lead_t / 1.5, 0.0, 1.0))
		camx = lerpf(camx, lead.p.x - hwv * off, k)
		camy = lerpf(camy, lead.p.y + 2.5, 1.0 - exp(-4.0 * dt))
	cam.fov = rad_to_deg(2.0 * atan(hwv / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


## 파편: 미리 만든 20개를 돌려 쓴다
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


func _drift_reset(d: Dictionary, anywhere: bool) -> void:
	var n: MeshInstance3D = d.n
	var span := 30.0
	match String(tdef.drift):
		"crate":  # 창고: 천장 레일 위 상자가 오른쪽으로 흘러간다
			n.material_override = mat(Color("e8590c").lightened(0.3))
			n.scale = Vector3(1.0, 0.9, 0.9)
			var x := camx + (vrng.randf_range(-span, span) if anywhere else -span)
			d.p = Vector3(x, 7.5, -4.0)
			d.v = Vector3(2.5, 0, 0)
		"drip":  # 하수도: 물방울이 떨어진다
			n.material_override = mat(WATER)
			n.scale = Vector3(0.14, 0.4, 0.14)
			d.p = Vector3(camx + vrng.randf_range(-span * 0.5, span * 0.5), camy + (vrng.randf_range(-6.0, 8.0) if anywhere else 8.0), vrng.randf_range(-3.5, -1.6))
			d.v = Vector3(0, -vrng.randf_range(7.0, 11.0), 0)
		"steam":  # 공장: 김이 올라가며 커진다
			n.material_override = mat(WHITE)
			n.scale = Vector3.ONE
			d.p = Vector3(camx + vrng.randf_range(-span * 0.6, span * 0.6), camy + (vrng.randf_range(-6.0, 10.0) if anywhere else -6.0), -8.0)
			d.v = Vector3(0.5, vrng.randf_range(2.0, 3.5), 0)
		_:  # 지붕: 구름이 왼쪽으로 (맞바람)
			n.material_override = mat(WHITE)
			n.scale = Vector3(vrng.randf_range(3.0, 6.0), 0.8, 1.0)
			var x := camx + (vrng.randf_range(-span, span) if anywhere else span)
			d.p = Vector3(x, camy + vrng.randf_range(3.0, 10.0), -18.0)
			d.v = Vector3(-vrng.randf_range(2.0, 4.0), 0, 0)
	n.position = d.p


func _draw_all(dt: float) -> void:
	var tm := Time.get_ticks_msec() * 0.001
	for r in runners:
		if r.poof_t > 0.0:
			r.poof_t -= dt
		r.poof.visible = r.poof_t > 0.0
		if r.poof.visible:
			var s := 1.0 + (0.5 - r.poof_t) * 6.0
			r.poof.scale = Vector3(s, s, s)
		if not r.alive:
			for s2 in r.streaks:
				s2.visible = false
			continue
		var spd := absf(r.v.x)
		var bob := sin(tm * (8.0 + spd)) * 0.06 if r.grounded and spd > 1.0 else 0.0
		r.node.position = Vector3(r.p.x, r.p.y + HH * 0.375 + bob, 0)
		# 찌그러짐: 빠르면 옆으로 늘고, 쾅·꽝·착지 때 납작, 위로 날면 세로로 길다
		var stretch := clampf(spd / 50.0, 0.0, 0.8)
		var vy := clampf(absf(r.v.y) / 40.0, 0.0, 0.3) if not r.grounded else 0.0
		r.node.scale = Vector3(1.0 + stretch * 0.5 + r.squash * 0.4 - vy * 0.3, 1.0 - r.squash * 0.45 - stretch * 0.2 + vy, 1.0)
		r.node.rotation.z = (tm * 14.0 if r.stun > 0.0 else -clampf(r.v.x * 0.012, -0.25, 0.25))
		r.pack.visible = r.weight_t > 0.0
		r.pack.position.x = -0.5 * r.face
		# 어질 별: 쾅이 쌓인 단계만큼 (1~3개), 단계가 높을수록 빨갛다
		var lv := mini(maxi(r.chain - 1, 0) / 3, 2)
		var stc: Color = [D, A, BAD][lv]
		for k in 3:
			var st := r.stars[k]
			st.visible = r.stun > 0.0 and k <= lv
			if st.visible:
				var a := tm * 14.0 + k * TAU / 3.0
				st.position = Vector3(cos(a) * 0.5, 1.2, sin(a) * 0.5)
				st.material_override = mat(stc)
		var ln := clampf((spd - 12.0) * 0.4, 0.0, 4.0)
		for k in 3:
			var s3 := r.streaks[k]
			s3.visible = ln > 0.1
			if s3.visible:
				s3.scale = Vector3(ln * (1.0 - k * 0.2), 0.07, 0.07)
				s3.material_override = mat(WATER if r.skipped and r.dash > 0.0 else WHITE)
				s3.position = Vector3(r.p.x - r.face * (HW + 0.3 + ln * 0.5 + k * 0.2), r.p.y + 0.25 + k * 0.35, 0.5)
	for w in weights:
		(w.node as Node3D).rotation.y += dt * 1.5
	marker.visible = pl.alive
	marker.position = Vector3(pl.p.x, pl.p.y + HH + 1.1 + sin(tm * 5.0) * 0.12, 0)
	# 먼 건물·가로등: 카메라 뒤로 빠진 것을 앞으로 옮겨 돌려 쓴다
	for b in bgs:
		if b.x < camx - 26.0:
			b.x += 52.0
			_bg_shape(b)
	for l in lamps:
		if l.x < camx - 18.0:
			l.x += 36.0
			_lamp_place(l)
	# 움직이는 배경
	for d in drifts:
		d.p += d.v * dt
		var n: MeshInstance3D = d.n
		if String(tdef.drift) == "steam":
			var g: float = 1.0 + (d.p.y - camy + 6.0) * 0.12
			n.scale = Vector3(g, g * 0.8, g)
		n.position = d.p
		var p3: Vector3 = d.p
		if p3.x < camx - 32.0 or p3.x > camx + 32.0 or p3.y < camy - 8.0 or p3.y > camy + 12.0:
			_drift_reset(d, false)
	# 속도 바람줄: 내가 빠를 때 화면 앞을 휙휙 지나간다
	var psp := absf(pl.v.x)
	var on := phase == "race" and pl.alive and psp > 14.0
	for ln2 in lines:
		var n2: MeshInstance3D = ln2.n
		n2.visible = on
		if on:
			ln2.x -= (psp * 2.5) * dt
			if ln2.x < -9.0:
				ln2.x = 9.0
				ln2.y = vrng.randf_range(-5.0, 5.0)
			n2.scale = Vector3(0.6 + (psp - 14.0) * 0.12, 0.05, 0.05)
			n2.position = Vector3(camx + ln2.x * hwv / WIDE, camy + ln2.y * hwv / WIDE, 9.0)
	# 파편
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
	# 왼쪽 화면 끝 경고 띠
	var ed := pl.p.x - (camx - hwv)
	var k2 := (CAM_D - 1.6) / CAM_D
	edge_strip.visible = phase == "race" and pl.alive and ed < 4.0 and (ed > 2.0 or fmod(tm, 0.16) < 0.1)
	edge_strip.position = Vector3(camx - hwv * k2 + 0.18, camy, 1.6)
	edge_strip.scale = Vector3(0.35 + maxf(0.0, 4.0 - ed) * 0.1, vhv * 2.0, 0.2)
