extends Tofu
## 작은 행성 v4(등뒤 3인칭, 한 하늘의 여러 별, 진짜 중력 비행): 별 다섯·달 둘·불 별 하나가 한 장면에 떠 있다. 왼쪽 스틱으로 달려 속도를 모아 점프하면 그 별 중력을 벗어나 날아가고, 가까운 별 중력에 끌려 빙 돌다 내려앉는다. 빗나가면 우주로 떠내려가 죽는다. 발 앞 점선이 "지금 뛰면 갈 길"(초록 = 다른 별에 닿음, 빨강 = 위험).
## 나는 [작은 별들 사이를 맨몸으로 건너는 여행자]로서 [달린 속도와 점프 순간이 곧 비행 궤도가 되는 몸] 속에서 [별 주민들의 부탁을 별과 별 사이로 날라 주]지만 [느리면 못 떠나고, 각도가 틀리면 우주로 떠내려가고, 쿵 내려앉으면 유리가 깨지는 것]을 감수한다.
## 별: 1 풍차(바람 달리기 → 돛, 노란 줄로 첫 비행) → 2 우편(소포를 굴뚝 달의 담 친 집에 공중에서 놓기) → 3 유리꽃(꽃을 들고 친구 달로, 빙 돌다 살살 착지) → 4 노을(얼음 위 속도 맞추기 → 유리 덮개) → 5 장미(빨간 바위 띠를 불 별 중력 새총으로 돌아 덮개를 살살).

const TOP := 12.5  # 땅에서 낼 수 있는 최고 속도
const ACC := 7.0
const JUMP := 5.0
const AIRJUMP := 4.5
const LAND_K := 0.55  # 착지 때 남는 접선 속도 비율
const GREY := Color("c9ccd1")
const NM := 4  # 운석 칸
const ND := 18  # 앞길 점선 칸
const START := Vector3(1, 0, 0)
const NPC_D := Vector3(1, 0.12, -0.35)
const HOME_D := Vector3(1, -0.2, -0.22)  # 맡길 물건이 놓인 곳
const TOWER_H := 2.5
const NW := 10  # 담 칸 (장미 별은 하나가 틈)
const MID := Vector3(50, 0, 10)  # 하늘 가운데
const BOUND := 78.0  # 어느 별에도 안 끌린 채 여기 밖이면 떠내려간다 (+10이면 끝)
const BELT_A := Vector3(73.2, 0, 44.4)  # 빨간 바위 띠 (노을 별 → 장미 별 곧은 길을 막는다)
const BELT_B := Vector3(69.0, 0, 27.0)
# 별: 0~4 부탁 별, 5 굴뚝 달, 6 친구 달, 7 불 별. 모두 y=0 평면 위.
const BD := [
	{"name": "풍차의 별", "r": 12.0, "g": 8.0, "grip": 1.19, "acc": 1.0, "at": Vector3(0, 0, 0), "kind": "planet",
		"c0": Color("bfe3a0"), "c1": Color("e6f5d4"), "sky": Color("d6ecff"), "who": "풍차지기", "body": Color("8fbf5a"), "hat": A,
		"lines": ["바람이 멎어 풍차가 잠들었어. 별 둘레를 힘껏 달려 바람을 깨워 줄래?",
			"뜨기 직전이 제일 센 바람이야. 발이 뜨면 바람이 끊겨. 바위는 살짝 뛰어넘어.",
			"고마워! 돛을 가져가. 보라 별이 우편의 별이야. 노란 줄을 힘껏 달려 초록 칸에서 점프! 날다가 스틱 밀며 점프하면 돛으로 방향을 한 번 튼다."]},
	{"name": "우편의 별", "r": 8.0, "g": 8.0, "grip": 1.19, "acc": 1.0, "at": Vector3(26, 0, -26), "kind": "planet",
		"c0": Color("d9ccf5"), "c1": Color("f3edff"), "sky": Color("e6dcff"), "who": "우체부", "body": B, "hat": BAD,
		"lines": ["이 소포를 저 하얀 굴뚝 달의 집에! 담이 높아서 걸어선 못 들어가.",
			"달은 작아서 조금만 빨라도 떠. 떠서 굴뚝 위를 지날 때 '놓기'. 발밑 노란 점이 떨어질 자리야.",
			"잘 도착했대! 다음은 초록 유리꽃의 별로 날아가."]},
	{"name": "유리꽃의 별", "r": 10.0, "g": 9.0, "grip": 1.19, "acc": 1.0, "at": Vector3(70, 0, -16), "kind": "planet",
		"c0": Color("bdebd8"), "c1": Color("e6f8f0"), "sky": Color("d6f5ea"), "who": "정원사", "body": GOOD, "hat": D,
		"lines": ["유리꽃을 저 민트 친구 달에 전해 줘. 쿵 내려앉으면 깨져.",
			"곧장 꽂지 말고 달 둘레를 빙 돌다 살살 내려앉아. 빨간 그림자는 운석 자리, 미리 비켜!",
			"꽃이 무사하대! 하늘색 노을의 별로 가 봐."]},
	{"name": "노을의 별", "r": 7.0, "g": 8.0, "grip": -0.8, "acc": 0.6, "at": Vector3(100, 0, 36), "kind": "planet",
		"c0": Color("c9e3fa"), "c1": Color("eef6ff"), "sky": Color("ffe0c2"), "who": "노을 아이", "body": C, "hat": A,
		"lines": ["내 별은 작아서 노을이 금방 달아나. 주황 띠를 따라 같이 달려 줘.",
			"얼음이라 미끄러워. 띠보다 빠르면 떠 버리고 느리면 놓쳐. 띠랑 같은 빠르기로.",
			"고마워. 이 유리 덮개를 분홍 장미 별에! 곧장 가면 빨간 바위 띠야. 빨간 불 별 옆을 스치면 휘어 돌아가. 불 별에 닿으면 끝."]},
	{"name": "장미의 별", "r": 6.0, "g": 7.0, "grip": 1.19, "acc": 1.0, "at": Vector3(50, 0, 48), "kind": "planet",
		"c0": Color("f7d3dc"), "c1": Color("fff4f6"), "sky": Color("ffe3ec"), "who": "장미", "body": BAD, "hat": GOOD,
		"lines": ["바람이 차가워. 유리 덮개를 씌워 줘. 담은 천천히 돌고, 틈은 하나야.",
			"틈과 같이 걸어 들어오거나, 탑에서 날아 위에서 놓아 줘. 쿵 내리면 깨져.",
			"따뜻해. 네 빠른 발 덕분에 다섯 별이 다 웃어."]},
	{"name": "굴뚝 달", "r": 3.5, "g": 6.0, "grip": 1.19, "acc": 1.0, "at": Vector3(52, 0, -40), "kind": "moon",
		"c0": Color("e9e4d4"), "c1": Color("fffaf0"), "sky": Color("efe8ff"), "who": "굴뚝 집", "body": WHITE, "hat": WHITE, "lines": []},
	{"name": "친구 달", "r": 3.5, "g": 6.0, "grip": 1.19, "acc": 1.0, "at": Vector3(90, 0, 8), "kind": "moon",
		"c0": Color("a8ecd2"), "c1": Color("e8fff6"), "sky": Color("e0fff4"), "who": "꽃 친구", "body": WHITE, "hat": WHITE, "lines": []},
	{"name": "불 별", "r": 3.0, "g": 20.0, "grip": 1.19, "acc": 1.0, "at": Vector3(78, 0, 60), "kind": "fire",
		"c0": BAD, "c1": A, "sky": Color("ffe8d6"), "who": "", "body": WHITE, "hat": WHITE, "lines": []},
]
# 부탁 (별 번호 = 부탁 번호). 물건은 src 별 HOME_D 에서 받아 tgt 별 tdir 로.
const JOB := [
	{},
	{"item": "pkg", "src": 1, "tgt": 5, "tdir": Vector3(-1, 0.3, 0.35), "tr": 1.3, "frag": false},
	{"item": "flower", "src": 2, "tgt": 6, "tdir": Vector3(-0.4, 0.5, -1), "tr": 1.6, "frag": true},
	{},
	{"item": "dome", "src": 3, "tgt": 4, "tdir": Vector3(-1, 0.3, -0.25), "tr": 1.1, "frag": true},
]

var cur := 0  # 발밑 별 (가장 세게 끄는 별)
var P: Dictionary
var R := 12.0
var gp := 8.0  # 발밑 별의 중력
var mu := 0.0
var pl: Node3D  # 발밑 별 노드
var here: Node3D  # 발밑 별 가운데 (운석·놓을 자리가 붙는다)
var nodes: Array[Node3D] = []
var shells: Array = []  # 별마다 멀리서 보이는 정육면체 셋
var pool: Array[MeshInstance3D] = []  # 발밑 별에만 까는 땅 타일
var pool_on := -1
var bc := PackedVector3Array()
var br := PackedFloat32Array()
var bg := PackedFloat32Array()
var bmu := PackedFloat32Array()
var bsoi := PackedFloat32Array()  # 끄는 둘레
var batm := PackedFloat32Array()  # 대기 (여기서 내려가면 옆 속도가 깎여 내려앉는다)
var env_node: WorldEnvironment
# 나
var me: Node3D
var hearts: Array[MeshInstance3D] = []
var item_b: MeshInstance3D
var sail_b: MeshInstance3D
var bag_b: MeshInstance3D
var mark_b: MeshInstance3D  # 공중에서 놓으면 떨어질 자리
var dots: Array[MeshInstance3D] = []
var p := Vector3.ZERO  # 발밑 별 가운데 기준 위치
var vel := Vector3.ZERO
var fwd := Vector3.FORWARD
var cfwd := Vector3.FORWARD
var cam_up := Vector3.RIGHT
var lookd := Vector3.FORWARD
var grounded := true
var airjump := false
var has_sail := false
var lives := 3
var die_t := 0.0
var fin_t := 0.0
var step_d := 0.0
var air_t := 0.0
var warn_t := 0.0
var shake := 0.0
var clock := 0.0
var fly_t := 0.0
var atm_t := 0.0
var trip_cd := 0.0
var bump_cd := 0.0
var tower_cd := 0.0
var rng := RandomNumberGenerator.new()
var from_b := 0  # 이번 비행을 띄운 별
var passed := {}  # 이번 비행에 끌려 본 별
var home_b := 0
var home_d := START
var visited := {}
var in_atm := false
# 부탁
var mi := 0
var req := 0  # 0 아직 안 만남, 1 하는 중, 2 끝
var prog := 0.0
var npcs := {}  # 별 번호 -> 주민 노드
var marks := {}  # 별 번호 -> "!" 상자
var beacon: MeshInstance3D
var rose_said := false
# 물건 (소포·유리꽃·유리 덮개)
var item := ""
var ig_on := false
var ig_pl := 0
var ig_dir := Vector3.ZERO
var ig_b: MeshInstance3D
var crack := 0.0
var pick_cd := 0.0
var fall_on := false
var fall_pl := 0
var fall_dir := Vector3.ZERO
var fall_h := 0.0
var fall_h0 := 0.0
var fall_v := 0.0
# 별마다 다른 것
var blades: Node3D  # 풍차
var wind_t := 0.0
var rocks: Array = []  # [방향, 상자] (풍차의 별)
var rings := {}  # 별 번호 -> {c, r, gap, e1, e2, walls}
var ring_in := false
var gap_a := 0.0
var band_a := 0.6  # 노을 띠 경도
var band_bs: Array[MeshInstance3D] = []
var tower_d := Vector3(0.35, 0.6, -0.7).normalized()  # 장미의 별 탑
var belt := PackedVector3Array()
# 운석: phase 0 없음, 1 경고, 2 낙하 (유리꽃의 별)
var mph: PackedInt32Array = PackedInt32Array()
var mdir: PackedVector3Array = PackedVector3Array()
var mt: PackedFloat32Array = PackedFloat32Array()
var mb: Array[MeshInstance3D] = []
var msh: Array[MeshInstance3D] = []
var spawn_t := 0.0
# 말풍선·부탁 막대
var hud2: CanvasLayer
var bub: Control
var bub_l: Label
var bub_t := 0.0
var bub_s := ""
var pbar_bg: ColorRect
var pbar: ColorRect
var sim_pts := PackedVector3Array()


func _setup() -> void:
	time_limit = 0.0
	howto = "별 여러 개가 한 하늘에 떠 있다. 왼쪽 스틱으로 달린다(많이 밀수록 빠름). 빨리 달리면 발이 뜬다.\n아주 빨리 달려 점프하면 그 별 중력을 벗어나 날아간다. 가까운 별에 끌려 빙 돌다 내려앉는다. 빗나가면 우주로 떠내려가 죽는다.\n빨리 달리면 발 앞에 점선 = 지금 뛰면 갈 길. 초록이면 다른 별에 닿고, 빨강은 위험. 위 막대가 초록이면 점프로 떠날 수 있다.\n날다가 점프 한 번: 돛이 있으면 스틱 쪽으로 방향을 튼다. '놓기'는 든 것을 발밑 노란 점에. 유리는 쿵 내리면 깨진다. 노란 빛기둥이 갈 곳. 목숨 3(처음 가는 별에서 회복)."
	kit_stick()
	kit_button("jump", "점프", Vector2(580, 1070), 110.0, A)
	for ch in get_children():
		if ch is WorldEnvironment:
			env_node = ch
	# 말풍선: 화면 위 흰 상자 (이름: 대사)
	hud2 = CanvasLayer.new()
	hud2.layer = 4
	add_child(hud2)
	bub = Control.new()
	bub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud2.add_child(bub)
	var edge := ColorRect.new()
	edge.color = INK
	edge.position = Vector2(30, 262)
	edge.size = Vector2(660, 176)
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bub.add_child(edge)
	var inner := ColorRect.new()
	inner.color = WHITE
	inner.position = Vector2(36, 268)
	inner.size = Vector2(648, 164)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bub.add_child(inner)
	var tail := ColorRect.new()
	tail.color = WHITE
	tail.position = Vector2(330, 430)
	tail.size = Vector2(36, 26)
	tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bub.add_child(tail)
	bub_l = _label(bub, 34, 276, 150)
	bub_l.label_settings.outline_size = 0
	bub_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bub_l.position.x = 54
	bub_l.size.x = 612
	bub_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pbar_bg = ColorRect.new()
	pbar_bg.color = INK
	pbar_bg.position = Vector2(60, 236)
	pbar_bg.size = Vector2(600, 18)
	pbar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud2.add_child(pbar_bg)
	pbar = ColorRect.new()
	pbar.position = Vector2(3, 3)
	pbar.size = Vector2(0, 12)
	pbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pbar_bg.add_child(pbar)


func _basis(up: Vector3) -> Basis:
	var x := up.cross(Vector3.FORWARD if absf(up.z) < 0.9 else Vector3.RIGHT).normalized()
	return Basis(x, up, x.cross(up))


func _orient(m: MeshInstance3D, at: Vector3, up: Vector3, sz: Vector3) -> void:
	var bs := _basis(up)
	m.transform = Transform3D(Basis(bs.x * sz.x, bs.y * sz.y, bs.z * sz.z), at)


## 표면 상자 하나 (dir 방향, 땅에서 h 높이에 가운데)
func _sbox(dir: Vector3, h: float, sz: Vector3, col: Color) -> MeshInstance3D:
	var m := box(Vector3.ZERO, Vector3.ONE, col, pl)
	var d := dir.normalized()
	_orient(m, d * (R + h), d, sz)
	return m


## 상자 인물: 몸·머리·눈·모자 + 머리 위 "!" (부탁이 남아 있으면)
func _person(dir: Vector3, body: Color, hat: Color) -> Node3D:
	var n := Node3D.new()
	pl.add_child(n)
	var d := dir.normalized()
	n.transform = Transform3D(_basis(d), d * R)
	box(Vector3(0, 0.55, 0), Vector3(0.8, 1.1, 0.6), body, n)
	box(Vector3(0, 1.4, 0), Vector3(0.7, 0.6, 0.6), Color("ffe3c7"), n)
	box(Vector3(-0.16, 1.45, -0.31), Vector3(0.12, 0.12, 0.04), INK, n)
	box(Vector3(0.16, 1.45, -0.31), Vector3(0.12, 0.12, 0.04), INK, n)
	box(Vector3(-0.16, 1.45, 0.31), Vector3(0.12, 0.12, 0.04), INK, n)
	box(Vector3(0.16, 1.45, 0.31), Vector3(0.12, 0.12, 0.04), INK, n)
	box(Vector3(0, 1.8, 0), Vector3(0.9, 0.18, 0.9), hat, n)
	box(Vector3(0, 2.0, 0), Vector3(0.5, 0.3, 0.5), hat, n)
	npc_mark = box(Vector3(0, 2.9, 0), Vector3(0.3, 0.7, 0.3), D, n)
	return n


var npc_mark: MeshInstance3D


func _reset() -> void:
	rng.randomize()
	lives = 3
	has_sail = false
	die_t = 0.0
	fin_t = 0.0
	bub_t = 0.0
	clock = 0.0
	hud2.visible = true
	_btns.erase("drop")
	# 먼 별 배경과 해
	for i in 18:
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.7, 0.7), rng.randf_range(-1, 1)).normalized()
		box(MID + d * 260.0, Vector3.ONE * rng.randf_range(3.0, 6.5), [WHITE, WHITE, D, B, C, WHITE][i % 6])
	box(MID + Vector3(120, 160, -140), Vector3(22, 22, 22), D)
	# 별 수치
	bc.clear()
	br.clear()
	bg.clear()
	bmu.clear()
	bsoi.clear()
	batm.clear()
	for k in BD.size():
		var d: Dictionary = BD[k]
		var r: float = d.r
		bc.append(d.at)
		br.append(r)
		bg.append(d.g)
		bmu.append(float(d.g) * r * r)
		bsoi.append(16.0 if d.kind == "fire" else maxf(2.2 * r, 12.0))
		batm.append(0.0 if d.kind == "fire" else maxf(1.6 * r, r + 4.0))
	here = Node3D.new()
	world.add_child(here)
	# 나: 몸, 머리, 눈, 모자, 목숨 3, 든 물건, 돛, 우편 가방
	me = Node3D.new()
	world.add_child(me)
	box(Vector3(0, 0.5, 0), Vector3(0.8, 1.0, 0.6), ME, me)
	box(Vector3(0, 1.3, 0), Vector3(0.7, 0.6, 0.6), ME, me)
	box(Vector3(-0.17, 1.4, -0.31), Vector3(0.14, 0.14, 0.04), WHITE, me)
	box(Vector3(0.17, 1.4, -0.31), Vector3(0.14, 0.14, 0.04), WHITE, me)
	box(Vector3(0, 1.7, 0), Vector3(0.9, 0.12, 0.9), D, me)
	hearts.clear()
	for i in 3:
		hearts.append(box(Vector3(-0.3 + 0.3 * i, 1.95, 0), Vector3(0.18, 0.18, 0.18), BAD, me))
	item_b = box(Vector3(0, 2.5, 0), Vector3(0.55, 0.55, 0.55), WHITE, me)
	item_b.visible = false
	sail_b = box(Vector3(0, 1.1, 0.45), Vector3(1.3, 1.0, 0.08), A, me)
	sail_b.visible = false
	bag_b = box(Vector3(0.5, 0.5, 0.1), Vector3(0.25, 0.5, 0.5), Color("c08a4a"), me)
	bag_b.visible = false
	mark_b = box(Vector3.ZERO, Vector3.ONE, D, here)
	mark_b.visible = false
	dots.clear()
	for i in ND:
		var m := box(Vector3.ZERO, Vector3(0.4, 0.4, 0.4), WHITE)
		m.visible = false
		dots.append(m)
	# 운석 칸 (발밑 별에 붙는다)
	mph.resize(NM)
	mdir.resize(NM)
	mt.resize(NM)
	mb.clear()
	msh.clear()
	for i in NM:
		mph[i] = 0
		var m := box(Vector3.ZERO, Vector3(1.2, 1.2, 1.2), INK, here)
		m.visible = false
		mb.append(m)
		var s := box(Vector3.ZERO, Vector3(4.4, 0.3, 4.4), BAD, here)
		s.visible = false
		msh.append(s)
	# 발밑 별 땅 타일 (별을 바꾸면 옮겨 깐다)
	pool.clear()
	for i in 96:
		pool.append(box(Vector3.ZERO, Vector3.ONE, WHITE))
	pool_on = -1
	_build()
	beacon = box(Vector3.ZERO, Vector3.ONE, D)
	ig_b = box(Vector3.ZERO, Vector3.ONE, WHITE)
	ig_b.visible = false
	# 부탁
	mi = 0
	req = 0
	prog = 0.0
	item = ""
	crack = 0.0
	fall_on = false
	ig_on = false
	rose_said = false
	gap_a = 0.0
	band_a = 0.6
	visited = {0: true}
	home_b = 0
	home_d = START
	cur = 0
	p = START * br[0]
	_switch(0)
	_start_job(0)
	_respawn()
	cam_up = START
	lookd = Vector3.FORWARD
	msg("1. 풍차의 별", 2.0)


## 별 여덟 개를 한 하늘에 짓는다. 멀리서는 정육면체 셋, 발밑에선 타일.
func _build() -> void:
	nodes.clear()
	shells.clear()
	rocks.clear()
	rings.clear()
	band_bs.clear()
	npcs.clear()
	marks.clear()
	belt.clear()
	for k in BD.size():
		var d: Dictionary = BD[k]
		var n := Node3D.new()
		world.add_child(n)
		n.position = bc[k]
		nodes.append(n)
		var s := br[k] * 1.62
		var sh: Array = []
		for j in 3:
			var m := box(Vector3.ZERO, Vector3.ONE * s, d.c0 if j != 1 else d.c1, n)
			m.rotation = [Vector3.ZERO, Vector3(0, PI / 4.0, 0), Vector3(PI / 4.0, 0, PI / 4.0)][j]
			sh.append(m)
		shells.append(sh)
		pl = n
		R = br[k]
		if k <= 3:
			npcs[k] = _person(NPC_D, d.body, d.hat)
			marks[k] = npc_mark
		match k:
			0:
				# 북극의 큰 풍차, 적도의 바위
				_sbox(Vector3.UP, 4.5, Vector3(1.0, 9.0, 1.0), WHITE)
				blades = Node3D.new()
				n.add_child(blades)
				blades.position = Vector3(0, R + 9.0, 0.8)
				for j in 4:
					var bl := box(Vector3.ZERO, Vector3(0.6, 3.6, 0.2), A if j % 2 == 0 else WHITE, blades)
					bl.position = Vector3(cos(j * TAU / 4.0), sin(j * TAU / 4.0), 0) * 1.8
					bl.rotation.z = j * TAU / 4.0 - PI / 2.0
				for j in 7:
					var a := 0.6 + j * TAU / 7.0
					var rd := Vector3(cos(a), 0, -sin(a))
					rocks.append([rd, _sbox(rd, 0.45, Vector3(1.3, 1.0, 1.3), GREY)])
			3:
				# 노을 아이의 의자와 노을 띠
				_sbox(NPC_D + Vector3(0, 0, 0.12), 0.3, Vector3(1.0, 0.6, 1.0), Color("c08a4a"))
				for j in 5:
					band_bs.append(_sbox(Vector3.RIGHT, 0.12, Vector3.ONE, A))
			4:
				# 담 안의 장미 (담은 돌고 틈이 하나), 탑
				var c: Vector3 = (JOB[4].tdir as Vector3).normalized()
				_sbox(c, 0.6, Vector3(0.18, 1.2, 0.18), GOOD)
				_sbox(c, 1.4, Vector3(0.7, 0.6, 0.7), BAD)
				var rn := Node3D.new()
				n.add_child(rn)
				rn.position = c * R
				npcs[4] = rn
				marks[4] = _sbox(c, 2.6, Vector3(0.3, 0.7, 0.3), D)
				_ring(4, c, 2.2, true, 1.6)
				_sbox(tower_d, TOWER_H * 0.5, Vector3(1.4, TOWER_H, 1.4), GREY)
				_sbox(tower_d, TOWER_H, Vector3(1.8, 0.3, 1.8), A)
			5:
				# 굴뚝 집과 높은 담
				var c: Vector3 = (JOB[1].tdir as Vector3).normalized()
				_sbox(c, 0.7, Vector3(1.3, 1.4, 1.3), Color("f4a6a6"))
				_sbox(c, 1.8, Vector3(0.45, 0.9, 0.45), INK)
				_ring(5, c, 1.8, false, 2.6)
			6:
				# 꽃 친구
				npcs[6] = _person(JOB[2].tdir, Color("f783ac"), C)
				npc_mark.visible = false
	# 빨간 바위 띠: 노을 별에서 장미 별로 곧게 가는 길을 막는다
	for j in 6:
		var q := BELT_A.lerp(BELT_B, (j + 0.5) / 6.0)
		for y in [-3.0, 3.0]:
			box(q + Vector3(0, y, 0), Vector3(3.4, 5.6, 3.4), BAD)
		belt.append(q)


func _in_belt(w: Vector3) -> bool:
	if absf(w.y) > 6.0:
		return false
	var a := Vector2(BELT_A.x, BELT_A.z)
	var b := Vector2(BELT_B.x, BELT_B.z)
	var q := Vector2(w.x, w.z)
	var tt := clampf((q - a).dot(b - a) / (b - a).length_squared(), -0.08, 1.08)
	return q.distance_to(a + (b - a) * tt) < 2.3


## 발밑 별을 바꾼다 (위치는 새 별 가운데 기준으로 옮긴다)
func _switch(k: int) -> void:
	p += bc[cur] - bc[k]
	cur = k
	P = BD[k]
	R = br[k]
	gp = bg[k]
	mu = bmu[k]
	pl = nodes[k]
	here.position = bc[k]
	if env_node:
		env_node.environment.background_color = P.sky
	for i in NM:
		mph[i] = 0
		mb[i].visible = false
		msh[i].visible = false
	_pave(k)


## 땅 타일 96개를 별 k 에 깐다. 그 별의 먼 모습(정육면체 셋)은 숨긴다.
func _pave(k: int) -> void:
	if pool_on == k:
		return
	if pool_on >= 0:
		for s in shells[pool_on]:
			s.visible = true
	pool_on = k
	for s in shells[k]:
		s.visible = false
	var n := 4
	var rr := br[k]
	var w := 2.0 * rr / n * 1.3
	var c0: Color = BD[k].c0
	var c1: Color = BD[k].c1
	var i := 0
	for ax: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK]:
		var tu: Vector3 = Vector3.UP if absf(ax.y) < 0.5 else Vector3.RIGHT
		var tv: Vector3 = ax.cross(tu)
		for a in n:
			for b in n:
				var u := (a + 0.5) / n * 2.0 - 1.0
				var v := (b + 0.5) / n * 2.0 - 1.0
				var d := (ax + tu * u + tv * v).normalized()
				var tl := pool[i]
				tl.material_override = mat(c0 if (i + a) % 2 == 0 else c1)
				_orient(tl, bc[k] + d * (rr - 0.5), d, Vector3(w, 1.0, w))
				i += 1


func _ring(k: int, c: Vector3, rr: float, gap: bool, h: float) -> void:
	var bs := _basis(c)
	var walls: Array = []
	var cnt := NW - 1 if gap else NW + 2
	for j in cnt:
		walls.append(_sbox(c, 0.8, Vector3.ONE, GREY))
	rings[k] = {"c": c, "r": rr, "gap": gap, "e1": bs.x, "e2": bs.z, "walls": walls, "h": h}
	_place_walls(k)


func _ring_pt(rg: Dictionary, rk: float, th: float) -> Vector3:
	var al: float = float(rg.r) / rk
	var c: Vector3 = rg.c
	var e1: Vector3 = rg.e1
	var e2: Vector3 = rg.e2
	return (c * cos(al) + (e1 * cos(th) + e2 * sin(th)) * sin(al)).normalized()


func _place_walls(k: int) -> void:
	var rg: Dictionary = rings[k]
	var rk := br[k]
	var walls: Array = rg.walls
	var cnt := walls.size()
	var step := TAU / (NW if rg.gap else cnt)
	var h: float = rg.h
	var e1: Vector3 = rg.e1
	var e2: Vector3 = rg.e2
	for j in cnt:
		var th := (gap_a if rg.gap else 0.0) + (j + 0.5) * step
		var d := _ring_pt(rg, rk, th)
		var tang := e2 * cos(th) - e1 * sin(th)
		tang = (tang - d * tang.dot(d)).normalized()
		var side := tang.cross(d)
		var ln: float = float(rg.r) * step * 1.05
		(walls[j] as MeshInstance3D).transform = Transform3D(Basis(tang * ln, d * h, side * 0.5), d * (rk + h * 0.5))


func _item_col() -> Color:
	var kind := item if item != "" else str((JOB[mi] as Dictionary).get("item", ""))
	match kind:
		"pkg": return Color("c08a4a")
		"flower": return Color("ffd6ec")
		"dome": return Color("bfe8ff")
	return WHITE


## 마지막으로 내려앉은 별·자리에서 다시
func _respawn() -> void:
	if cur != home_b:
		_switch(home_b)
	p = home_d * R
	vel = Vector3.ZERO
	fwd = _flat(Vector3.FORWARD, home_d)
	cfwd = fwd
	grounded = true
	airjump = false
	ring_in = false
	if rings.has(cur):
		ring_in = home_d.angle_to(rings[cur].c) * R < float(rings[cur].r)
	for i in 3:
		hearts[i].visible = i < lives
	for d in dots:
		d.visible = false
	_place_me()


## up 에 수직인 단위 방향 (평행이면 아무 수직 방향)
func _flat(v: Vector3, up: Vector3) -> Vector3:
	var f := v - up * v.dot(up)
	if f.length() < 0.01:
		f = up.cross(Vector3.UP if absf(up.y) < 0.9 else Vector3.RIGHT)
	return f.normalized()


func _say(who: String, s: String, dur: float) -> void:
	bub_s = "%s: %s" % [who, s]
	bub_t = dur


## 모든 별이 w 에서 끄는 힘 (둘레 밖에선 0, 가장자리에서 부드럽게)
func _gacc(w: Vector3) -> Vector3:
	var a := Vector3.ZERO
	for k in bc.size():
		var d := bc[k] - w
		var r := d.length()
		if r >= bsoi[k] or r < 0.01:
			continue
		var f := clampf((bsoi[k] - r) / (0.25 * bsoi[k]), 0.0, 1.0)
		a += d / r * (bmu[k] / (r * r) * f)
	return a


## w 에서 가장 세게 끄는 별 (아무도 안 끌면 -1)
func _dominant(w: Vector3) -> int:
	var best := -1
	var bf := 0.0
	for k in bc.size():
		var r := (bc[k] - w).length()
		if r >= bsoi[k]:
			continue
		var f := clampf((bsoi[k] - r) / (0.25 * bsoi[k]), 0.0, 1.0) * bmu[k] / maxf(r * r, 0.01)
		if f > bf:
			bf = f
			best = k
	return best


## 대기: 내려가는 중이면 옆 속도를 깎아 빙 돌다 내려앉게 한다 (올라가는 중엔 안 깎아 떠날 수 있다)
func _air_drag(v: Vector3, k: int, rel: Vector3, at: float, h: float) -> Vector3:
	var r := rel.length()
	if batm[k] <= 0.0 or r >= batm[k] or r < 0.01:
		return v
	var up := rel / r
	var vr := v.dot(up)
	if vr >= 0.5:
		return v
	var tan := v - up * vr
	tan *= maxf(0.0, 1.0 - minf(0.35 + 0.25 * at, 1.2) * h)
	v = tan + up * vr
	if at > 2.0:
		v += -up * bg[k] * 0.6 * h
	return v


## 지금 위치·속도로 날면 어떻게 되나: 닿는 별 번호, -1 아직 날고 있음, -2 위험(불 별·바위 띠·떠내려감).
## out 에 점 위치를 넣는다.
func _sim(w: Vector3, v: Vector3, k: int, at: float, secs: float, h: float, out: PackedVector3Array) -> int:
	var n := int(secs / h)
	var every := maxi(1, n / ND)
	out.clear()
	for i in n:
		v += _gacc(w) * h
		var dm := _dominant(w)
		if dm >= 0:
			k = dm
		var rel := w - bc[k]
		if batm[k] > 0.0 and rel.length() < batm[k] and v.dot(rel) < 0.5 * rel.length():
			at += h
		v = _air_drag(v, k, rel, at, h)
		w += v * h
		if i % every == every - 1 and out.size() < ND:
			out.append(w)
		if (w - bc[k]).length() <= br[k]:
			return -2 if BD[k].kind == "fire" else k
		if _in_belt(w):
			return -2
		if dm < 0 and (w - MID).length() > BOUND + 10.0:
			return -2
	return -1


## 앞길 점선: 땅에선 "지금 점프하면", 날 땐 지금 길. 다른 별 초록, 위험 빨강.
func _dots_update(up: Vector3, lift: float) -> void:
	var show := false
	var res := -1
	var w := bc[cur] + p
	if die_t <= 0.0 and fin_t <= 0.0:
		if grounded and vel.length() > lift * 0.6:
			show = true
			res = _sim(w + up * 0.1, vel + up * JUMP, cur, 0.0, 4.0, 1.0 / 30.0, sim_pts)
		elif not grounded:
			show = true
			res = _sim(w, vel, cur, atm_t, 4.0, 1.0 / 30.0, sim_pts)
	var lb := cur if grounded else from_b
	var col := WHITE
	if res == -2:
		col = BAD
	elif res >= 0 and res != lb:
		col = GOOD
	for i in ND:
		var on := show and i < sim_pts.size()
		dots[i].visible = on
		if on:
			dots[i].position = sim_pts[i]
			dots[i].material_override = mat(col)


## 첫 비행 연습: 풍차의 별 적도에서 힘껏 달려 점프하면 우편의 별에 닿는 곳을 찾아 노란 줄을 깐다
func _lane() -> void:
	var lift := sqrt((bg[0] + 1.19) * br[0])
	var good: Array = []
	var pts := PackedVector3Array()
	for sg: float in [1.0, -1.0]:
		for i in 48:
			var a := TAU * i / 48.0
			var d := Vector3(cos(a), 0, -sin(a))
			var tg := Vector3(-sin(a), 0, -cos(a)) * sg
			if _sim(bc[0] + d * (br[0] + 0.1), tg * lift * 0.96 + d * JUMP, 0, 0.0, 9.0, 1.0 / 20.0, pts) == 1:
				good.append([a, sg])
	if good.is_empty():
		return
	var pick: Array = good[good.size() / 2]
	var a0: float = pick[0]
	var sg0: float = pick[1]
	pl = nodes[0]
	R = br[0]
	for j in 6:
		var a := a0 - sg0 * (5 - j) * 0.13
		var d := Vector3(cos(a), 0, -sin(a))
		_sbox(d, 0.06, Vector3(1.6, 0.2, 1.6), GOOD if j == 5 else D)
	# 줄 위 바위는 치운다
	for rk in rocks:
		var rd: Vector3 = rk[0]
		var ra := atan2(-rd.z, rd.x)
		if absf(wrapf(ra - (a0 - sg0 * 0.35), -PI, PI)) < 0.55:
			(rk[1] as MeshInstance3D).visible = false
	pl = nodes[cur]
	R = br[cur]


func _turn(a: Vector3, b: Vector3, t: float) -> Vector3:
	var r := a.slerp(b, t)
	if not r.is_finite() or r.length() < 0.1:
		return b.normalized()
	return r.normalized()


func _step(dt: float) -> void:
	clock += dt
	_hud(dt)
	if fin_t > 0.0:
		fin_t -= dt
		_tick(dt, p.normalized(), 0.0)
		_camera(dt)
		if fin_t <= 0.0:
			hud2.visible = false
			end()
		return
	if die_t > 0.0:
		die_t -= dt
		if not grounded:
			p += vel * dt
			_place_me()
		_camera(dt)
		if die_t <= 0.0:
			if lives <= 0:
				hud2.visible = false
				end()
			else:
				_respawn()
		return
	tower_cd -= dt
	trip_cd -= dt
	bump_cd -= dt
	if grounded:
		_ground(dt, p.normalized())
	elif _fly(dt):
		return
	var lift := sqrt(maxf(gp + float(P.grip), 0.5) * R)
	var up := p.normalized()
	var tv := vel - up * vel.dot(up)
	if tv.length() > 0.3:
		fwd = tv.normalized()
	fwd = _flat(fwd, up)
	cfwd = _flat(cfwd, up)
	if tv.length() > 1.0:
		cfwd = _flat(_turn(cfwd, fwd, minf(1.0, dt * (2.5 if grounded else 0.8))), up)
	_place_me()
	_gauge_now(up)
	_items(dt, up)
	_tick(dt, up, vel.length() / lift)
	_meteors(dt, up)
	_dots_update(up, lift)
	_camera(dt)


## 땅 위 달리기
func _ground(dt: float, up: Vector3) -> void:
	var grip: float = P.grip
	var lift := sqrt(maxf(gp + grip, 0.5) * R)
	var cright := cfwd.cross(up).normalized()
	var want := Vector3.ZERO
	if kit_move.length() > 0.05:
		want = (cright * kit_move.x - cfwd * kit_move.y) * TOP
	var acc: float = ACC * float(P.acc)
	if float(P.acc) < 1.0 and want.length() < 0.1:
		acc = 0.5  # 얼음: 손을 떼도 잘 안 멈춘다
	vel = vel.move_toward(want, acc * dt)
	vel -= up * vel.dot(up)
	p += vel * dt
	up = p.normalized()
	p = up * R
	vel -= up * vel.dot(up)
	_collide(up)
	up = p.normalized()
	var spd := vel.length()
	step_d += spd * dt
	if spd > 0.5 and step_d > 1.4:
		step_d = 0.0
		beep(140.0 + 160.0 * spd / TOP, 0.03, 0.0, 0.12)
	# 이륙 경고음: 이륙선 가까우면 잦아진다
	if spd > lift * 0.8:
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = lerpf(0.5, 0.12, clampf((spd - lift * 0.8) / (lift * 0.2), 0.0, 1.0))
			beep(900.0, 0.03, 0.0, 0.1)
	if cur == 4 and tower_cd <= 0.0 and p.distance_to(tower_d * R) < 1.2:
		# 탑: 꼭대기로 올라가 뛰어내린다 (천천히 들어와도 된다)
		var tf := _flat(fwd, tower_d)
		_liftoff()
		p = tower_d * (R + TOWER_H + 0.3)
		vel = tf * clampf(spd, 2.5, 3.5)
		tower_cd = 2.5
		msg("탑에서 뛰어내린다", 0.9)
		beep(500.0, 0.3, 1200.0, 0.25)
	elif kit_just("jump"):
		_liftoff()
		vel += up * JUMP
		if 0.5 * vel.length_squared() - mu / R > -mu / bsoi[cur]:
			msg("떠난다!", 0.8)
			beep(600.0, 0.5, 1800.0, 0.28)
		else:
			beep(400.0, 0.1, 700.0, 0.2)
	elif spd * spd / R > gp + grip:
		_liftoff()
		msg("떴다", 0.6)
		beep(600.0, 0.25, 1400.0, 0.25)


func _liftoff() -> void:
	grounded = false
	airjump = false
	fly_t = 0.0
	atm_t = 0.0
	from_b = cur
	passed = {}
	in_atm = false


## 날기: 모든 별이 끈다. 대기에서 내려가면 빙 돌다 내려앉는다. 죽으면 true.
func _fly(dt: float) -> bool:
	var up := p.normalized()
	vel += _gacc(bc[cur] + p) * dt
	fly_t += dt
	var r := p.length()
	var vr := vel.dot(up)
	var ia := batm[cur] > 0.0 and r < batm[cur] and vr < 0.5
	if ia:
		atm_t += dt
		if not in_atm and fly_t > 0.6:
			beep(180.0, 0.4, 90.0, 0.15)  # 대기에 들어왔다
	in_atm = ia
	vel = _air_drag(vel, cur, p, atm_t, dt)
	if ia and kit_move.length() > 0.05:
		# 대기 안에선 스틱으로 살짝 옆으로 (빨라지진 않는다)
		var vr2 := vel.dot(up)
		var tanv := vel - up * vr2
		var tl := tanv.length()
		var cright := cfwd.cross(up).normalized()
		var sd := cright * kit_move.x - cfwd * kit_move.y
		sd -= up * sd.dot(up)
		tanv += sd * 4.0 * dt
		if tanv.length() > tl:
			tanv = tanv.normalized() * tl
		vel = tanv + up * vr2
	p += vel * dt
	var w := bc[cur] + p
	var dm := _dominant(w)
	if dm >= 0 and dm != cur:
		_switch(dm)
		if dm != from_b and not passed.has(dm):
			beep(700.0 + 90.0 * dm, 0.15, 0.0, 0.15)
			msg(P.name, 0.8)
	if dm >= 0:
		passed[dm] = true
	up = p.normalized()
	r = p.length()
	air_t -= dt
	if air_t <= 0.0:
		air_t = 0.3
		beep(300.0 + minf(r - R, 30.0) * 12.0, 0.08, 0.0, 0.08)
	if kit_just("jump") and not airjump:
		airjump = true
		if has_sail and kit_move.length() > 0.3:
			# 돛: 속도는 그대로, 비행 방향만 스틱 쪽(화면 기준)으로 튼다
			var bs := cam.global_transform.basis
			var sd := (bs.x * kit_move.x - bs.y * kit_move.y).normalized()
			var sp := maxf(vel.length(), 3.0)
			var vd := vel.normalized() if vel.length() > 0.1 else up
			vel = (vd + sd * 0.7).normalized() * sp
			msg("돛!", 0.6)
			beep(500.0, 0.2, 300.0, 0.25)
		else:
			vel += up * AIRJUMP
			beep(500.0, 0.12, 900.0, 0.2)
	# 위험: 불 별, 바위 띠, 떠내려감
	if P.kind == "fire" and r <= R + 0.4:
		_die("불 별에 닿았다")
		return true
	if _in_belt(w):
		_die("빨간 바위 띠에 부딪혔다")
		return true
	if dm < 0:
		var far := (w - MID).length()
		if far > BOUND:
			warn_t -= dt
			if warn_t <= 0.0:
				warn_t = 0.35
				beep(1200.0, 0.06, 0.0, 0.15)
				msg("우주로 떠내려간다… 돛으로 돌려!", 0.5)
			if far > BOUND + 10.0:
				_die("우주로 떠내려갔다")
				return true
	if r <= R and vel.dot(up) <= 0.0 and P.kind != "fire":
		_land(up)
	return false


func _land(up: Vector3) -> void:
	var hit := -vel.dot(up)
	p = up * R
	vel = (vel - up * vel.dot(up)) * LAND_K
	grounded = true
	in_atm = false
	shake = maxf(shake, 0.15)
	beep(90.0, 0.12, 50.0, 0.3)
	if item != "" and bool((JOB[mi] as Dictionary).get("frag", false)):
		var c := clampf((hit - 3.0) / 4.0, 0.0, 1.0)
		if c > 0.0:
			crack += c
			msg("쿵! 유리에 금이 갔다", 0.9)
			beep(2600.0, 0.15, 900.0, 0.25)
	if rings.has(cur):
		ring_in = up.angle_to(rings[cur].c) * R < float(rings[cur].r)
	home_b = cur
	home_d = up
	if cur != from_b:
		var sling := false
		for k in passed:
			if k != cur and k != from_b:
				sling = true
		if sling:
			score += 3
			msg("새총!", 1.0)
			beep(1500.0, 0.2, 2200.0, 0.25)
		if not visited.has(cur):
			visited[cur] = true
			score += 5
			lives = 3
			for i in 3:
				hearts[i].visible = true
			play("win")
			msg(P.name, 1.6)


## 땅 위 부딪힘: 바위(걸리면 감속), 담(막힘, 틈만 통과)
func _collide(up: Vector3) -> void:
	if cur == 0:
		for rk in rocks:
			var rd: Vector3 = rk[0]
			if trip_cd <= 0.0 and (rk[1] as MeshInstance3D).visible and p.distance_to(rd * R) < 1.15:
				vel *= 0.2
				trip_cd = 0.8
				shake = 0.25
				msg("바위에 걸렸다", 0.8)
				beep(120.0, 0.15, 60.0, 0.3)
	if not rings.has(cur):
		return
	var rg: Dictionary = rings[cur]
	var rc: Vector3 = rg.c
	var rr: float = rg.r
	var d := up.angle_to(rc) * R
	if absf(d - rr) < 0.5:
		var pass_ := false
		if rg.gap:
			var v := up - rc * up.dot(rc)
			var th := atan2(v.dot(rg.e2), v.dot(rg.e1))
			var gc := gap_a + (NW - 0.5) * TAU / NW
			pass_ = absf(wrapf(th - gc, -PI, PI)) < 0.3
		if not pass_:
			var axis := rc.cross(up)
			if axis.length() > 0.001:
				var td := rr - 0.5 if ring_in else rr + 0.5
				p = rc.rotated(axis.normalized(), td / R) * R
				var nu := p.normalized()
				var o := rc - nu * rc.dot(nu)
				if o.length() > 0.001:
					o = o.normalized()
					vel -= o * vel.dot(o)
				vel -= nu * vel.dot(nu)
				if bump_cd <= 0.0:
					bump_cd = 0.5
					beep(150.0, 0.08, 0.0, 0.2)
					msg("담 — 틈으로" if rg.gap else "담이 높다 — 공중에서 놓기", 0.7)
	else:
		ring_in = d < rr


## 막대: 땅에선 "지금 점프하면 탈출선까지"(넘으면 초록), 날 땐 발밑 별 탈출선 대비
func _gauge_now(up: Vector3) -> void:
	var r := maxf(p.length(), R)
	var v := vel + up * JUMP if grounded else vel
	var e := 0.5 * v.length_squared() - mu / r
	var e0 := -mu / R
	var e1 := -mu / bsoi[cur]
	var f := (e - e0) / maxf(e1 - e0, 0.01)
	if grounded:
		gauge(f, GOOD if f >= 1.0 else D)
	else:
		gauge(f, B if f >= 1.0 else A)


## 부탁 k 시작: 물건이 있으면 받는 별에 놓는다
func _start_job(k: int) -> void:
	var J: Dictionary = JOB[k]
	crack = 0.0
	fall_on = false
	if J.has("item"):
		ig_on = true
		ig_pl = J.src
		ig_dir = HOME_D.normalized()
		ig_b.visible = true
		ig_b.material_override = mat(_item_col())
		item_b.material_override = mat(_item_col())
	else:
		ig_on = false
		ig_b.visible = false


## 물건: 줍기, 금, 놓기, 떨어지기, 전하기
func _items(dt: float, up: Vector3) -> void:
	pick_cd -= dt
	var J: Dictionary = JOB[mi]
	if not J.has("item") or req == 2:
		mark_b.visible = false
		return
	if fall_on:
		fall_v += bg[fall_pl] * dt
		fall_h -= fall_v * dt
		_orient(ig_b, bc[fall_pl] + fall_dir * (br[fall_pl] + 0.3 + maxf(fall_h, 0.0)), fall_dir, Vector3(0.55, 0.55, 0.55))
		if fall_h <= 0.0:
			fall_on = false
			_item_landed()
	elif ig_on:
		_orient(ig_b, bc[ig_pl] + ig_dir * (br[ig_pl] + 0.4 + sin(clock * 3.0) * 0.12), ig_dir, Vector3(0.55, 0.55, 0.55))
		if item == "" and grounded and cur == ig_pl and pick_cd <= 0.0 and p.distance_to(ig_dir * R) < 1.5:
			item = J.item
			ig_on = false
			ig_b.visible = false
			item_b.visible = true
			if req == 0:
				req = 1
			play("good")
			msg("들었다 → %s" % BD[int(J.tgt)].name, 1.2)
			_drop_btn(true)
	if item != "":
		item_b.material_override = mat(_item_col().lerp(BAD, floorf(clampf(crack, 0.0, 1.0) * 8.0) / 8.0))
		if crack >= 1.0:
			_break()
			return
		var tg: Vector3 = (J.tdir as Vector3).normalized()
		if kit_just("drop"):
			_drop(up)
		elif grounded and cur == int(J.tgt) and p.distance_to(tg * R) < float(J.tr) + 0.6:
			_deliver()
	# 들고 날면 떨어질 자리를 보여 준다
	mark_b.visible = item != "" and not grounded
	if mark_b.visible:
		_orient(mark_b, up * (R + 0.12), up, Vector3(1.0, 0.15, 1.0))


func _drop_btn(on: bool) -> void:
	if on:
		kit_button("drop", "놓기", Vector2(580, 860), 90.0, B)
	else:
		_btns.erase("drop")


func _drop(up: Vector3) -> void:
	item = ""
	item_b.visible = false
	ig_b.visible = true
	fall_on = true
	fall_pl = cur
	fall_dir = up
	fall_h = maxf(p.length() - R, 0.0) + 1.6
	fall_h0 = fall_h
	fall_v = 0.0
	pick_cd = 1.0
	_drop_btn(false)
	beep(700.0, 0.15, 350.0, 0.2)


func _item_landed() -> void:
	beep(160.0, 0.1, 0.0, 0.25)
	var J: Dictionary = JOB[mi]
	var tg: Vector3 = (J.tdir as Vector3).normalized()
	if J.frag and fall_h0 > 5.5:
		_break()
		return
	if fall_pl == int(J.tgt) and (fall_dir * br[fall_pl]).distance_to(tg * br[fall_pl]) < float(J.tr):
		_deliver()
		return
	ig_on = true
	ig_pl = fall_pl
	ig_dir = fall_dir
	msg("빗나갔다 — 다시 줍기", 1.0)


func _break() -> void:
	var J: Dictionary = JOB[mi]
	item = ""
	item_b.visible = false
	crack = 0.0
	fall_on = false
	ig_on = true
	ig_pl = J.src
	ig_dir = HOME_D.normalized()
	ig_b.visible = true
	_drop_btn(false)
	shake = 0.3
	msg("쨍그랑! %s에서 다시 받아 와" % BD[int(J.src)].name, 1.6)
	beep(3000.0, 0.25, 800.0, 0.3)


## 물건이 닿을 곳에 닿았다
func _deliver() -> void:
	var J: Dictionary = JOB[mi]
	var t := int(J.tgt)
	var tg: Vector3 = (J.tdir as Vector3).normalized()
	item = ""
	item_b.visible = false
	ig_on = false
	fall_on = false
	ig_b.visible = true
	_orient(ig_b, bc[t] + tg * (br[t] + (2.5 if mi == 1 else 1.2)), tg, Vector3(0.6, 0.6, 0.6))
	_drop_btn(false)
	_done()


func _done() -> void:
	var k := mi
	req = 2
	prog = 1.0
	score += 10
	play("win")
	shake = 0.2
	var gv: Dictionary = BD[k]
	_say(gv.who, gv.lines[2], 7.0)
	if k == 0:
		has_sail = true
		sail_b.visible = true
		_lane()
	elif k == 1:
		bag_b.visible = true
	if k >= 4:
		fin_t = 5.0
		msg("장미가 웃는다", 3.0)
		return
	mi = k + 1
	req = 1 if mi == 4 else 0
	_start_job(mi)
	msg("다음: %s" % BD[mi].name, 1.8)


## 별마다 다른 움직임과 부탁 진행
func _tick(dt: float, up: Vector3, lf: float) -> void:
	for k in marks:
		var m: MeshInstance3D = marks[k]
		m.visible = k == mi and (req == 0 or k == 4) and fin_t <= 0.0
		if m.visible and k != 4:
			m.position.y = 2.9 + sin(clock * 4.0) * 0.2
	# 주민 만나기
	if grounded and cur == mi and npcs.has(cur):
		if p.distance_to((npcs[cur] as Node3D).position) < 5.0:
			if req == 0:
				req = 1
				_say(P.who, P.lines[0], 6.0)
				beep(1000.0, 0.15, 1300.0, 0.2)
			elif mi == 4 and not rose_said:
				rose_said = true
				_say(P.who, P.lines[0], 6.0)
	# 풍차 바람: 이륙선 80% 이상으로 땅에 붙어 달린 시간
	if mi == 0 and req == 1 and cur == 0:
		var on_ := grounded and lf >= 0.8
		prog = clampf(prog + (dt / 12.0 if on_ else -0.03 * dt), 0.0, 1.0)
		if on_:
			wind_t -= dt
			if wind_t <= 0.0:
				wind_t = 0.35
				beep(220.0 + 300.0 * prog, 0.3, 160.0, 0.08)
		if prog >= 1.0:
			_done()
	if blades:
		blades.rotation.z += ((lf * 9.0 * (1.0 if grounded else 0.2) if cur == 0 else 0.0) + (6.0 if mi > 0 else 0.3)) * dt
	# 노을 띠: 적도를 이륙선의 80%(후반 90%) 빠르기로 돈다
	var r3 := br[3]
	if mi == 3 and req == 1:
		band_a += (0.8 if prog < 0.5 else 0.9) * sqrt((bg[3] - 0.8) * r3) / r3 * dt
	var inb := false
	if cur == 3 and grounded:
		var lon := atan2(-up.z, up.x)
		var lat := asin(clampf(up.y, -1.0, 1.0))
		inb = absf(wrapf(lon - band_a, -PI, PI)) < 0.24 and absf(lat) < 0.5
	for j in band_bs.size():
		var l := -0.4 + 0.2 * j
		var d := Vector3(cos(band_a) * cos(l), sin(l), -sin(band_a) * cos(l))
		_orient(band_bs[j], d * (r3 + 0.12), d, Vector3(2.2, 0.25, 1.6))
		band_bs[j].material_override = mat(D if inb else A)
	if mi == 3 and req == 1 and cur == 3:
		prog = clampf(prog + (dt / 14.0 if inb else -0.04 * dt), 0.0, 1.0)
		if inb:
			wind_t -= dt
			if wind_t <= 0.0:
				wind_t = 0.4
				beep(520.0 + 260.0 * prog, 0.12, 0.0, 0.1)
		if prog >= 1.0:
			_done()
	# 장미 별의 도는 담
	gap_a += 0.8 * dt
	_place_walls(4)
	# 갈 곳 빛기둥 (다른 별 위에서도 보이게 길게)
	var ob := _objective()
	beacon.visible = not ob.is_empty() and fin_t <= 0.0
	if beacon.visible:
		var bk: int = ob[0]
		var bd: Vector3 = ob[1]
		_orient(beacon, bc[bk] + bd * (br[bk] + 7.0), bd, Vector3(0.6, 14.0, 0.6))


## [별 번호, 방향] 또는 []
func _objective() -> Array:
	var J: Dictionary = JOB[mi]
	if req == 0 and mi <= 3:
		return [mi, NPC_D.normalized()]
	if J.has("item"):
		if item != "":
			return [int(J.tgt), (J.tdir as Vector3).normalized()]
		if ig_on:
			return [ig_pl, ig_dir]
		return []
	if mi == 3:
		return [3, Vector3(cos(band_a), 0, -sin(band_a))]
	return []


## 말풍선과 부탁 막대
func _hud(dt: float) -> void:
	bub_t -= dt
	var s := ""
	var near := grounded and cur <= 4 and npcs.has(cur) and p.distance_to((npcs[cur] as Node3D).position) < 6.0
	var ob := _objective()
	if bub_t > 0.0:
		s = bub_s
	elif near:
		var idx := 2 if cur < mi else (0 if (req == 0 or cur > mi) else 1)
		s = "%s: %s" % [P.who, P.lines[idx]]
	elif req == 1 and (mi == 0 or mi == 3) and cur == mi and prog < 0.15:
		s = "%s: %s" % [BD[mi].who, BD[mi].lines[1]]
	elif item != "" and fmod(clock, 12.0) < 4.0:
		s = "%s: %s" % [BD[mi].who, BD[mi].lines[1]]
	elif grounded and not ob.is_empty() and int(ob[0]) != cur and die_t <= 0.0 and fmod(clock, 14.0) < 5.0:
		s = "다음: %s (노란 빛기둥). 힘껏 달려 점프! 점선이 초록이면 닿는다." % BD[int(ob[0])].name
	bub.visible = s != ""
	bub_l.text = s
	var show := false
	if req == 1 and (mi == 0 or mi == 3):
		show = true
		pbar.color = A
		pbar.size.x = 594.0 * prog
	elif item != "" and bool((JOB[mi] as Dictionary).get("frag", false)):
		show = true
		pbar.color = BAD
		pbar.size.x = 594.0 * clampf(crack, 0.0, 1.0)
	pbar_bg.visible = show


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	lives -= 1
	for i in 3:
		hearts[i].visible = i < lives
	die_t = 1.3
	shake = 0.4
	play("bad")
	msg(why, 1.2)
	# 마지막으로 내려앉은 자리에서 다시: 든 물건은 처음 받은 별로
	var J: Dictionary = JOB[mi]
	if item != "" or fall_on:
		item = ""
		item_b.visible = false
		fall_on = false
		ig_on = true
		ig_pl = J.src
		ig_dir = HOME_D.normalized()
		ig_b.visible = true
		_drop_btn(false)
	crack = 0.0
	if req == 1 and (mi == 0 or mi == 3):
		prog = 0.0
		band_a = 0.6
	for d in dots:
		d.visible = false


## 운석: 유리꽃을 들고 유리꽃의 별 위에 있으면 나를 노린다
func _meteors(dt: float, up: Vector3) -> void:
	var active := cur == 2 and item == "flower"
	spawn_t -= dt
	if spawn_t <= 0.0 and active and grounded:
		spawn_t = 2.6
		for i in NM:
			if mph[i] == 0:
				# 나를 겨냥: 걷는 쪽 조금 앞
				var ahead := up + fwd * (0.1 + 0.2 * vel.length() / TOP)
				var d := (ahead + Vector3(rng.randf_range(-0.15, 0.15), rng.randf_range(-0.15, 0.15), rng.randf_range(-0.15, 0.15))).normalized()
				mph[i] = 1
				mdir[i] = d
				mt[i] = 2.2
				msh[i].visible = true
				beep(260.0, 0.1, 0.0, 0.15)
				break
	for i in NM:
		if mph[i] == 0:
			continue
		var d := mdir[i]
		mt[i] -= dt
		if mph[i] == 1:
			var pulse := 0.8 + 0.2 * sin(clock * 12.0)
			_orient(msh[i], d * (R + 0.15), d, Vector3(4.4 * pulse, 0.3, 4.4 * pulse))
			if fmod(mt[i], 0.4) < dt:
				beep(330.0, 0.04, 0.0, 0.1)
			if mt[i] <= 0.0:
				mph[i] = 2
				mt[i] = 1.1
				mb[i].visible = true
		else:
			var alt := maxf(mt[i], 0.0) / 1.1 * 22.0
			_orient(mb[i], d * (R + alt), d, Vector3(1.2, 1.2, 1.2))
			mb[i].rotate(d, clock * 5.0)
			if mt[i] <= 0.0:
				mph[i] = 0
				mb[i].visible = false
				msh[i].visible = false
				shake = 0.3
				beep(60.0, 0.35, 30.0, 0.4)
				if p.distance_to(d * R) < 2.2:
					_die("운석에 맞았다")


func _place_me() -> void:
	var up := p.normalized()
	var f := _flat(fwd, up)
	var x := up.cross(-f).normalized()
	me.transform = Transform3D(Basis(x, up, -f), bc[cur] + p)


## 땅에선 등 뒤, 날 땐 속도 방향 뒤에서 (갈 곳이 화면 앞)
func _camera(dt: float) -> void:
	var up := p.normalized()
	var pw := bc[cur] + p
	cam_up = _turn(cam_up, up, minf(1.0, dt * (5.0 if grounded else 1.5)))
	var alt := clampf(p.length() - R, 0.0, 20.0)
	var spd := vel.length()
	var tgt := cfwd
	if not grounded and spd > 1.0:
		tgt = vel / spd
	lookd = _turn(lookd, tgt, minf(1.0, dt * (4.0 if grounded else 2.0)))
	var upp := _flat(cam_up, lookd)
	var dist := 7.0 + alt * 0.35 + spd / TOP * 1.5
	var want := pw + upp * (3.2 + alt * 0.2) - lookd * dist
	if shake > 0.0:
		shake -= dt
		want += Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * shake * 1.2
	cam.position = cam.position.lerp(want, minf(1.0, dt * 5.0))
	var look := pw + upp * 1.0 + lookd * 3.0
	if cam.position.distance_to(look) > 0.1:
		cam.look_at(look, upp)
	cam.fov = 60.0 + 22.0 * clampf(spd / TOP, 0.0, 1.0)
