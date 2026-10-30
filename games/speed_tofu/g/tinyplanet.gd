extends Tofu
## 작은 행성 v3(등뒤 3인칭, 구면 중력, 별 여행): 왼쪽 스틱으로 달린다. 빠르면 원심력에 발이 뜨고, 뜬 채 점프를 보태면 탈출해 우주로 날아가 죽는다. 별 다섯, 별마다 상자 주민의 부탁 하나를 속도로 풀고, 빛길에서 알맞게 빨리 뛰어올라 다음 별로 날아간다.
## 나는 [약한 중력의 작은 별 여행자]로서 [빨리 달리면 발이 뜨는 몸] 속에서 [별 주민들의 부탁을 속도로 들어주며 별을 건너]지만 [빠르면 떠서 조종을 잃고 더 빠르면 우주로 영영 떠나는 것]을 감수한다.
## 별: 1 풍차(이륙선 바로 아래로 오래 달려 바람) → 2 우편(일부러 떠서 공중에서 소포 놓기, 돛으로 조준) → 3 유리꽃(느리게 걸으며 운석 비키기) → 4 노을(얼음 위에서 노을 띠와 속도 맞추기) → 5 장미(유리 덮개를 도는 담 틈으로 같이 걸어 넣거나, 탑·돛·놓기로 위에서 넣기).

const TOP := 12.5  # 땅에서 낼 수 있는 최고 속도
const ACC := 7.0
const JUMP := 5.0
const AIRJUMP := 4.5
const LAND_K := 0.55  # 착지 때 남는 접선 속도 비율
const DRAG := 0.12  # 공중 공기 저항 (뜬 시간이 길수록 세진다)
const GREY := Color("c9ccd1")
const NM := 4  # 운석 칸
const START := Vector3(1, 0, 0)  # 별마다 도착·다시 시작하는 곳
const NPC_D := Vector3(1, 0.12, -0.35)
const HOME_D := Vector3(1, -0.2, -0.22)  # 맡길 물건이 놓인 곳
const TOWER_H := 2.5
const NW := 10  # 담 칸 (장미 별은 하나가 틈)
const PL := [
	{"name": "풍차의 별", "r": 12.0, "g": 8.0, "grip": 1.19, "acc": 1.0, "n": 5,
		"c0": Color("bfe3a0"), "c1": Color("e6f5d4"), "sky": Color("d6ecff"), "who": "풍차지기", "body": Color("8fbf5a"), "hat": A,
		"item": "", "frag": 0.0, "tgt": Vector3.ZERO, "tr": 0.0, "pad": Vector3(-0.4, 0.55, -1.0),
		"lines": ["바람이 멎어 풍차가 잠들었어. 별 둘레를 힘껏 달려 바람을 깨워 줄래?",
			"뜨기 직전이 제일 센 바람이야. 발이 뜨면 바람이 끊겨. 바위는 살짝 뛰어넘어.",
			"풍차가 다시 노래해! 이 돛을 가져가. 공중에서 스틱을 밀며 점프하면 방향이 틀어져."]},
	{"name": "우편의 별", "r": 9.0, "g": 8.0, "grip": 1.19, "acc": 1.0, "n": 4,
		"c0": Color("d9ccf5"), "c1": Color("f3edff"), "sky": Color("e6dcff"), "who": "우체부", "body": B, "hat": BAD,
		"item": "pkg", "frag": 0.0, "tgt": Vector3(-1, 0.25, 0.35), "tr": 1.6, "pad": Vector3(0.2, -0.7, -1.0),
		"lines": ["이 소포는 담 너머 굴뚝 집으로 가야 해. 담이 높아서 걸어선 못 들어가.",
			"빨리 달려 떠오른 다음, 발밑 노란 점이 굴뚝에 겹칠 때 '놓기'.",
			"쏙 들어갔네! 하늘에서 보면 길이 짧아지지."]},
	{"name": "유리꽃의 별", "r": 10.0, "g": 10.0, "grip": 1.19, "acc": 1.0, "n": 4,
		"c0": Color("bdebd8"), "c1": Color("e6f8f0"), "sky": Color("d6f5ea"), "who": "정원사", "body": GOOD, "hat": D,
		"item": "flower", "frag": 3.6, "tgt": Vector3(-0.6, 0.3, -1.0), "tr": 1.6, "pad": Vector3(0.1, -1.0, 0.4),
		"lines": ["유리 꽃을 저 건너 친구에게 전해 줘. 빨리 걸으면 금이 가.",
			"막대가 차면 깨져. 천천히. 빨간 그림자는 운석 자리야, 미리 비켜.",
			"꽃이 하나도 안 깨졌어. 천천히가 빠를 때도 있구나."]},
	{"name": "노을의 별", "r": 7.0, "g": 8.0, "grip": -0.8, "acc": 0.6, "n": 4,
		"c0": Color("c9e3fa"), "c1": Color("eef6ff"), "sky": Color("ffe0c2"), "who": "노을 아이", "body": C, "hat": A,
		"item": "", "frag": 0.0, "tgt": Vector3.ZERO, "tr": 0.0, "pad": Vector3(0.3, 0.9, 0.2),
		"lines": ["내 별은 작아서 노을이 금방 달아나. 주황 띠를 따라 같이 달려 줘.",
			"얼음이라 미끄러워. 띠보다 빠르면 떠 버리고 느리면 놓쳐. 띠랑 같은 빠르기로.",
			"노을을 이렇게 오래 본 건 처음이야. 마지막 별의 장미에게 가 봐."]},
	{"name": "장미의 별", "r": 6.0, "g": 7.0, "grip": 1.19, "acc": 1.0, "n": 4,
		"c0": Color("f7d3dc"), "c1": Color("fff4f6"), "sky": Color("ffe3ec"), "who": "장미", "body": BAD, "hat": GOOD,
		"item": "dome", "frag": 3.0, "tgt": Vector3(-1, 0.3, -0.25), "tr": 1.1, "pad": Vector3.ZERO,
		"lines": ["바람이 차가워. 유리 덮개를 씌워 줘. 담은 천천히 돌고, 틈은 하나야.",
			"덮개는 빨리 들면 깨져. 틈과 같이 걸어 들어오거나, 탑에서 날아 돛으로 틀고 위에서 놓아 줘.",
			"따뜻해. 네 빠른 발 덕분에 다섯 별이 다 웃어."]},
]

var pi_ := 0  # 별 번호
var P: Dictionary
var R := 12.0
var gp := 8.0  # 이 별의 중력
var mu := 0.0
var pl: Node3D  # 별 노드 (바꿀 때 통째로 버린다)
var env_node: WorldEnvironment
# 나
var me: Node3D
var hearts: Array[MeshInstance3D] = []
var item_b: MeshInstance3D
var sail_b: MeshInstance3D
var bag_b: MeshInstance3D
var mark_b: MeshInstance3D  # 공중에서 놓으면 떨어질 자리
var p := Vector3.ZERO
var vel := Vector3.ZERO
var fwd := Vector3.FORWARD
var cfwd := Vector3.FORWARD
var grounded := true
var airjump := false
var has_sail := false
var lives := 3
var die_t := 0.0
var fin_t := 0.0
var travel_t := 0.0
var gone := false
var step_d := 0.0
var air_t := 0.0
var warn_t := 0.0
var shake := 0.0
var clock := 0.0
var fly_t := 0.0
var trip_cd := 0.0
var bump_cd := 0.0
var tower_cd := 0.0
var rng := RandomNumberGenerator.new()
# 부탁
var req := 0  # 0 아직 안 만남, 1 하는 중, 2 끝
var prog := 0.0
var npc_n: Node3D
var npc_mark: MeshInstance3D
var beacon: MeshInstance3D
var pad_bs: Array[MeshInstance3D] = []
var far_b: MeshInstance3D
var far_moon: MeshInstance3D
# 물건 (소포·유리꽃·유리 덮개)
var item := ""
var ig_on := false
var ig_dir := Vector3.ZERO
var ig_b: MeshInstance3D
var crack := 0.0
var crack_t := 0.0
var pick_cd := 0.0
var fall_on := false
var fall_dir := Vector3.ZERO
var fall_h := 0.0
var fall_h0 := 0.0
var fall_v := 0.0
# 별마다 다른 것
var blades: Node3D  # 풍차
var wind_t := 0.0
var rocks: PackedVector3Array = PackedVector3Array()
var ring_r := 0.0  # 담 (반경 0이면 없음)
var ring_c := Vector3.ZERO
var ring_e1 := Vector3.ZERO
var ring_e2 := Vector3.ZERO
var ring_gap := false
var ring_in := false
var gap_a := 0.0
var walls: Array[MeshInstance3D] = []
var band_a := 0.6  # 노을 띠 경도
var band_bs: Array[MeshInstance3D] = []
var tower_d := Vector3.ZERO
# 운석: phase 0 없음, 1 경고, 2 낙하
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


func _setup() -> void:
	time_limit = 0.0
	howto = "왼쪽 스틱으로 달린다(많이 밀수록 빠름). 빨리 달리면 발이 뜬다. 뜬 채로 점프를 보태면 우주로 날아가 죽는다.\n별마다 상자 주민의 부탁을 속도로 들어준다. 노란 빛기둥이 갈 곳.\n부탁을 풀면 빛길이 생긴다: 알맞게 빨리(초록) 달려와 점프하면 다음 별로. 빨강이면 너무 빨라 빗나간다.\n'놓기'는 든 것을 발밑 노란 점에 떨어뜨린다. 목숨 3(새 별에서 회복)."
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


func _reset() -> void:
	rng.randomize()
	lives = 3
	has_sail = false
	die_t = 0.0
	fin_t = 0.0
	travel_t = 0.0
	bub_t = 0.0
	hud2.visible = true
	_btns.erase("drop")
	# 별 배경 (먼 상자들)과 해
	for i in 34:
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
		var sc := rng.randf_range(0.8, 2.2)
		box(d * 110.0, Vector3.ONE * sc, [WHITE, WHITE, WHITE, D, B, C][i % 6])
	box(Vector3(60, 80, -70), Vector3(8, 8, 8), D)
	far_b = box(Vector3.ZERO, Vector3(7, 7, 7), B)
	far_moon = box(Vector3.ZERO, Vector3(1.6, 1.6, 1.6), WHITE)
	# 나: 몸, 머리, 눈, 목숨 3, 든 물건, 돛, 우편 가방
	me = Node3D.new()
	world.add_child(me)
	box(Vector3(0, 0.5, 0), Vector3(0.8, 1.0, 0.6), ME, me)
	box(Vector3(0, 1.3, 0), Vector3(0.7, 0.6, 0.6), ME, me)
	box(Vector3(-0.17, 1.4, -0.31), Vector3(0.14, 0.14, 0.04), WHITE, me)
	box(Vector3(0.17, 1.4, -0.31), Vector3(0.14, 0.14, 0.04), WHITE, me)
	box(Vector3(0, 1.7, 0), Vector3(0.9, 0.12, 0.9), D, me)  # 노란 목도리 대신 모자 테
	hearts.clear()
	for i in 3:
		hearts.append(box(Vector3(-0.3 + 0.3 * i, 1.95, 0), Vector3(0.18, 0.18, 0.18), BAD, me))
	item_b = box(Vector3(0, 2.5, 0), Vector3(0.55, 0.55, 0.55), WHITE, me)
	item_b.visible = false
	sail_b = box(Vector3(0, 1.1, 0.45), Vector3(1.3, 1.0, 0.08), A, me)
	sail_b.visible = false
	bag_b = box(Vector3(0.5, 0.5, 0.1), Vector3(0.25, 0.5, 0.5), Color("c08a4a"), me)
	bag_b.visible = false
	mark_b = box(Vector3.ZERO, Vector3.ONE, D)
	mark_b.visible = false
	# 운석 칸
	mph.resize(NM)
	mdir.resize(NM)
	mt.resize(NM)
	mb.clear()
	msh.clear()
	for i in NM:
		mph[i] = 0
		var m := box(Vector3.ZERO, Vector3(1.2, 1.2, 1.2), INK)
		m.visible = false
		mb.append(m)
		var s := box(Vector3.ZERO, Vector3(4.4, 0.3, 4.4), BAD)
		s.visible = false
		msh.append(s)
	pl = null
	_planet(0, false)


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


## 별 하나를 짓는다. arrive 면 하늘에서 떨어져 도착한다.
func _planet(i: int, arrive: bool) -> void:
	if pl:
		pl.queue_free()
	pl = Node3D.new()
	world.add_child(pl)
	pi_ = i
	P = PL[i]
	R = P.r
	gp = P.g
	mu = gp * R * R
	if env_node:
		env_node.environment.background_color = P.sky
	# 정육면체-구 타일
	var n: int = P.n
	var w := 2.0 * R / n * 1.3
	var k := 0
	for ax: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK]:
		var tu: Vector3 = Vector3.UP if absf(ax.y) < 0.5 else Vector3.RIGHT
		var tv: Vector3 = ax.cross(tu)
		for a in n:
			for b in n:
				var u := (a + 0.5) / n * 2.0 - 1.0
				var v := (b + 0.5) / n * 2.0 - 1.0
				var d := (ax + tu * u + tv * v).normalized()
				var tl := box(Vector3.ZERO, Vector3.ONE, P.c0 if (k + a) % 2 == 0 else P.c1, pl)
				_orient(tl, d * (R - 0.5), d, Vector3(w, 1.0, w))
				k += 1
	if i != 4:
		npc_n = _person(NPC_D, P.body, P.hat)
	beacon = box(Vector3.ZERO, Vector3.ONE, D, pl)
	# 빛길 (부탁을 풀면 보인다): 노란 고리 + 하늘의 다음 별
	pad_bs.clear()
	var pd: Vector3 = P.pad
	if pd.length() > 0.1:
		var pu := pd.normalized()
		var bs := _basis(pu)
		for j in 6:
			var a := TAU * j / 6.0
			var o := (bs.x * cos(a) + bs.z * sin(a)) * 2.2
			var pb := _sbox((pu * R + o), 0.1, Vector3(0.9, 0.25, 0.9), D)
			pb.visible = false
			pad_bs.append(pb)
		far_b.position = pu * 55.0
		far_b.material_override = mat((PL[i + 1] as Dictionary).c0)
		far_b.visible = true
	else:
		far_b.visible = false
	far_moon.visible = far_b.visible
	# 부탁 상태
	req = 0
	prog = 0.0
	item = ""
	crack = 0.0
	fall_on = false
	ig_on = false
	ig_b = box(Vector3.ZERO, Vector3.ONE, WHITE, pl)
	ig_b.visible = false
	if P.item != "":
		ig_on = true
		ig_dir = HOME_D.normalized()
		ig_b.visible = true
		ig_b.material_override = mat(_item_col())
	item_b.material_override = mat(_item_col())
	rocks.clear()
	ring_r = 0.0
	walls.clear()
	band_bs.clear()
	blades = null
	tower_d = Vector3.ZERO
	match i:
		0:
			# 북극의 큰 풍차 (적도에서도 지평선 위로 보인다), 적도의 바위
			_sbox(Vector3.UP, 4.5, Vector3(1.0, 9.0, 1.0), WHITE)
			blades = Node3D.new()
			pl.add_child(blades)
			blades.position = Vector3(0, R + 9.0, 0.8)
			for j in 4:
				var bl := box(Vector3.ZERO, Vector3(0.6, 3.6, 0.2), A if j % 2 == 0 else WHITE, blades)
				bl.position = Vector3(cos(j * TAU / 4.0), sin(j * TAU / 4.0), 0) * 1.8
				bl.rotation.z = j * TAU / 4.0 - PI / 2.0
			for j in 7:
				var a := 0.6 + j * TAU / 7.0
				var rd := Vector3(cos(a), 0, -sin(a))
				rocks.append(rd)
				_sbox(rd, 0.45, Vector3(1.3, 1.0, 1.3), GREY)
		1:
			# 담 두른 굴뚝 집
			var c: Vector3 = (P.tgt as Vector3).normalized()
			_sbox(c, 0.8, Vector3(1.6, 1.6, 1.6), Color("f4a6a6"))
			_sbox(c, 2.0, Vector3(0.5, 1.0, 0.5), INK)
			_ring_setup(c, 2.8, false)
		2:
			# 건너편 친구
			var keep := npc_mark
			_person(P.tgt, Color("f783ac"), C)
			npc_mark.visible = false
			npc_mark = keep
		3:
			# 노을 띠: 적도를 도는 주황 상자들, 의자에 앉은 아이
			_sbox(NPC_D + Vector3(0, 0, 0.12), 0.3, Vector3(1.0, 0.6, 1.0), Color("c08a4a"))
			band_a = 0.6
			for j in 5:
				band_bs.append(_sbox(Vector3.RIGHT, 0.12, Vector3.ONE, A))
		4:
			# 담 안의 장미 (담은 돌고 틈이 하나), 탑
			var c: Vector3 = (P.tgt as Vector3).normalized()
			_sbox(c, 0.6, Vector3(0.18, 1.2, 0.18), GOOD)
			_sbox(c, 1.4, Vector3(0.7, 0.6, 0.7), BAD)
			npc_n = Node3D.new()
			pl.add_child(npc_n)
			npc_n.position = c * R
			npc_mark = _sbox(c, 2.6, Vector3(0.3, 0.7, 0.3), D)
			_ring_setup(c, 2.2, true)
			tower_d = Vector3(0.35, 0.6, -0.7).normalized()
			_sbox(tower_d, TOWER_H * 0.5, Vector3(1.4, TOWER_H, 1.4), GREY)
			_sbox(tower_d, TOWER_H, Vector3(1.8, 0.3, 1.8), A)
	for j in NM:
		mph[j] = 0
		mb[j].visible = false
		msh[j].visible = false
	spawn_t = 2.5
	_respawn()
	if arrive:
		p = START * R * 2.4
		grounded = false
		fly_t = 0.0
		vel = Vector3.ZERO
		lives = 3
		score += 5
		play("win")
		_place_me()
		_camera(1.0)
	msg("%d. %s" % [i + 1, P.name], 2.0)


func _ring_setup(c: Vector3, rr: float, gap: bool) -> void:
	ring_c = c
	ring_r = rr
	ring_gap = gap
	ring_in = false
	gap_a = 0.0
	var bs := _basis(c)
	ring_e1 = bs.x
	ring_e2 = bs.z
	var cnt := NW - 1 if gap else NW + 2
	for j in cnt:
		walls.append(_sbox(c, 0.8, Vector3.ONE, GREY))
	_place_walls()


func _ring_pt(th: float) -> Vector3:
	var al := ring_r / R
	return (ring_c * cos(al) + (ring_e1 * cos(th) + ring_e2 * sin(th)) * sin(al)).normalized()


func _place_walls() -> void:
	var cnt := walls.size()
	var step := TAU / (NW if ring_gap else cnt)
	for j in cnt:
		var th := gap_a + (j + 0.5) * step
		var d := _ring_pt(th)
		var m := walls[j]
		var tang := (ring_e2 * cos(th) - ring_e1 * sin(th))
		tang = (tang - d * tang.dot(d)).normalized()
		var side := tang.cross(d)
		var ln := ring_r * step * 1.05
		m.transform = Transform3D(Basis(tang * ln, d * 1.6, side * 0.5), d * (R + 0.8))


func _item_col() -> Color:
	match P.get("item", ""):
		"pkg": return Color("c08a4a")
		"flower": return Color("ffd6ec")
		"dome": return Color("bfe8ff")
	return WHITE


func _respawn() -> void:
	p = START * R
	vel = Vector3.ZERO
	fwd = Vector3.FORWARD
	cfwd = Vector3.FORWARD
	grounded = true
	airjump = false
	gone = false
	ring_in = false
	for i in 3:
		hearts[i].visible = i < lives
	_place_me()


func _say(s: String, dur: float) -> void:
	bub_s = "%s: %s" % [P.who, s]
	bub_t = dur


func _step(dt: float) -> void:
	clock += dt
	var up := p.normalized()
	var r := p.length()
	_hud(dt)
	if fin_t > 0.0:
		fin_t -= dt
		_planet_tick(dt, up, 0.0)
		_camera(dt)
		if fin_t <= 0.0:
			hud2.visible = false
			end()
		return
	if die_t > 0.0:
		die_t -= dt
		if not grounded:
			vel += -up * gp * dt
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
	if travel_t > 0.0:
		# 빛길: 다음 별 쪽으로 곧장 날아간다
		travel_t -= dt
		vel += vel.normalized() * 30.0 * dt
		p += vel * dt
		_place_me()
		_camera(dt)
		if travel_t <= 0.0:
			_planet(pi_ + 1, true)
		return
	var spd := vel.length()
	tower_cd -= dt
	trip_cd -= dt
	bump_cd -= dt
	_far()
	var grip: float = P.grip
	var lift := sqrt((gp + grip) * R)
	if grounded:
		var cright := cfwd.cross(up).normalized()
		var want := Vector3.ZERO
		if kit_move.length() > 0.05:
			want = (cright * kit_move.x - cfwd * kit_move.y) * TOP
		var acc: float = ACC * P.acc
		if P.acc < 1.0 and want.length() < 0.1:
			acc = 0.5  # 얼음: 손을 떼도 잘 안 멈춘다
		vel = vel.move_toward(want, acc * dt)
		vel -= up * vel.dot(up)
		p += vel * dt
		up = p.normalized()
		p = up * R
		vel -= up * vel.dot(up)
		_collide(up)
		up = p.normalized()
		spd = vel.length()
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
		# 빛길: 알맞은 빠르기(초록)면 다음 별, 너무 빠르면(빨강) 빗나감
		var on_pad := req == 2 and not pad_bs.is_empty() and p.distance_to((P.pad as Vector3).normalized() * R) < 2.8
		_pad_glow(on_pad, spd / lift)
		if tower_d.length() > 0.5 and tower_cd <= 0.0 and p.distance_to(tower_d * R) < 1.2:
			# 탑: 꼭대기로 올라가 뛰어내린다 (천천히 들어와도 된다)
			var tf := fwd - tower_d * fwd.dot(tower_d)
			if tf.length() < 0.1:
				tf = Vector3.UP - tower_d * tower_d.y
			_liftoff(tower_d)
			p = tower_d * (R + TOWER_H + 0.3)
			vel = tf.normalized() * clampf(spd, 2.5, 3.5)
			tower_cd = 2.5
			msg("탑에서 뛰어내린다", 0.9)
			beep(500.0, 0.3, 1200.0, 0.25)
		elif kit_just("jump"):
			if on_pad and spd >= lift * 0.6:
				_liftoff(up)
				if spd <= lift * 0.92:
					travel_t = 1.4
					vel = (up * 2.0 + vel.normalized() * 0.3).normalized() * 16.0
					msg("빛길로!", 1.0)
					beep(800.0, 0.6, 2400.0, 0.3)
					return
				vel += up * JUMP * 2.2 + vel.normalized() * 4.0
				msg("너무 빨라 빗나갔다", 1.2)
				beep(700.0, 0.6, 2000.0, 0.3)
			else:
				_liftoff(up)
				vel += up * JUMP
				if on_pad:
					msg("더 빨리 달려와서", 0.8)
				beep(400.0, 0.1, 700.0, 0.2)
		elif spd * spd / R > gp + grip:
			_liftoff(up)
			msg("떴다", 0.6)
			beep(600.0, 0.25, 1400.0, 0.25)
	else:
		vel += -up * gp * dt
		if not gone:
			# 공기 저항: 오래 뜰수록 세져서 궤도에 갇히지 않고 내려온다
			fly_t += dt
			var vr := vel.dot(up)
			var tanv := vel - up * vr
			var tl := tanv.length()
			tanv *= maxf(0.0, 1.0 - (DRAG + 0.1 * fly_t) * dt)
			if kit_move.length() > 0.05:
				var cright := cfwd.cross(up).normalized()
				var sd := cright * kit_move.x - cfwd * kit_move.y
				sd -= up * sd.dot(up)
				tanv += sd * 4.0 * dt
				if tanv.length() > tl:
					tanv = tanv.normalized() * tl
			vel = tanv + up * vr
			if fly_t > 2.0:
				vel += -up * gp * 0.6 * dt  # 궤도가 서서히 낮아진다
		p += vel * dt
		up = p.normalized()
		r = p.length()
		air_t -= dt
		if air_t <= 0.0:
			air_t = 0.3
			beep(300.0 + (r - R) * 25.0, 0.08, 0.0, 0.08)
		if kit_just("jump") and not airjump:
			airjump = true
			if has_sail and kit_move.length() > 0.3:
				# 돛: 속도는 그대로, 비행 방향만 스틱 쪽으로 튼다
				var cright := cfwd.cross(up).normalized()
				var sd := cright * kit_move.x - cfwd * kit_move.y
				sd -= up * sd.dot(up)
				var vr := vel.dot(up)
				var tl := (vel - up * vr).length()
				vel = sd.normalized() * maxf(tl, 3.0) + up * (maxf(vr, 0.0) + 1.0)
				msg("돛!", 0.6)
				beep(500.0, 0.2, 300.0, 0.25)
			else:
				vel += up * AIRJUMP
				beep(500.0, 0.12, 900.0, 0.2)
		var en := 0.5 * vel.length_squared() - mu / r
		if not gone and en > -mu / (3.0 * R):
			gone = true
			msg("날아간다…", 1.5)
			beep(700.0, 0.6, 2000.0, 0.3)
		if r > 3.0 * R:
			_die("우주로 날아갔다")
			return
		if r <= R and vel.dot(up) <= 0.0:
			var hit := -vel.dot(up)
			p = up * R
			var tan := vel - up * vel.dot(up)
			vel = tan * LAND_K
			grounded = true
			gone = false
			shake = maxf(shake, 0.15)
			beep(90.0, 0.12, 50.0, 0.3)
			if item != "" and P.frag > 0.0:
				crack += clampf((hit - 2.5) / 8.0, 0.0, 0.6)
			# 담 안에 내려앉았는지
			if ring_r > 0.0:
				ring_in = up.angle_to(ring_c) * R < ring_r
	# 몸 방향·카메라 방향
	var tv := vel - up * vel.dot(up)
	if tv.length() > 0.3:
		fwd = tv.normalized()
	fwd = (fwd - up * fwd.dot(up)).normalized()
	cfwd = (cfwd - up * cfwd.dot(up)).normalized()
	if tv.length() > 1.0:
		cfwd = cfwd.slerp(fwd, minf(1.0, dt * (2.5 if grounded else 0.8))).normalized()
	_place_me()
	# 궤도 에너지 막대: 0 땅에 서 있음, 1 탈출
	var e_now := 0.5 * vel.length_squared() - mu / r
	gauge((e_now + mu / R) / (mu / R - mu / (3.0 * R)), BAD if gone else (D if not grounded else GOOD))
	_items(dt, up, spd)
	_planet_tick(dt, up, spd / lift)
	_meteors(dt, up)
	_camera(dt)


## 땅 위 부딪힘: 바위(걸리면 감속), 담(막힘, 틈만 통과)
func _collide(up: Vector3) -> void:
	for rd in rocks:
		if trip_cd <= 0.0 and p.distance_to(rd * R) < 1.15:
			vel *= 0.2
			trip_cd = 0.8
			shake = 0.25
			msg("바위에 걸렸다", 0.8)
			beep(120.0, 0.15, 60.0, 0.3)
	if ring_r <= 0.0:
		return
	var d := up.angle_to(ring_c) * R
	if absf(d - ring_r) < 0.5:
		var pass_ := false
		if ring_gap:
			var v := up - ring_c * up.dot(ring_c)
			var th := atan2(v.dot(ring_e2), v.dot(ring_e1))
			var gc := gap_a + (NW - 0.5) * TAU / NW
			pass_ = absf(wrapf(th - gc, -PI, PI)) < 0.3
		if not pass_:
			var axis := ring_c.cross(up)
			if axis.length() > 0.001:
				var td := ring_r - 0.5 if ring_in else ring_r + 0.5
				p = ring_c.rotated(axis.normalized(), td / R) * R
				var nu := p.normalized()
				var o := ring_c - nu * ring_c.dot(nu)
				if o.length() > 0.001:
					o = o.normalized()
					vel -= o * vel.dot(o)
				vel -= nu * vel.dot(nu)
				if bump_cd <= 0.0:
					bump_cd = 0.5
					beep(150.0, 0.08, 0.0, 0.2)
					if ring_gap:
						msg("담 — 틈으로", 0.7)
					else:
						msg("담이 높다", 0.7)
	else:
		ring_in = d < ring_r


func _pad_glow(on: bool, frac: float) -> void:
	if pad_bs.is_empty() or req != 2:
		return
	var c := D
	if on:
		c = WHITE if frac < 0.6 else (GOOD if frac <= 0.92 else BAD)
	for pb in pad_bs:
		pb.material_override = mat(c)


func _liftoff(up: Vector3) -> void:
	grounded = false
	airjump = false
	fly_t = 0.0


## 물건: 줍기, 금, 놓기, 떨어지기, 전하기
func _items(dt: float, up: Vector3, spd: float) -> void:
	pick_cd -= dt
	var kind: String = P.item
	if kind == "" or req == 2:
		mark_b.visible = false
		return
	if fall_on:
		fall_v += gp * dt
		fall_h -= fall_v * dt
		_orient(ig_b, fall_dir * (R + 0.3 + maxf(fall_h, 0.0)), fall_dir, Vector3(0.55, 0.55, 0.55))
		if fall_h <= 0.0:
			fall_on = false
			_item_landed()
	elif ig_on:
		_orient(ig_b, ig_dir * (R + 0.4 + sin(clock * 3.0) * 0.12), ig_dir, Vector3(0.55, 0.55, 0.55))
		if item == "" and grounded and pick_cd <= 0.0 and p.distance_to(ig_dir * R) < 1.5:
			item = kind
			ig_on = false
			ig_b.visible = false
			item_b.visible = true
			if req == 0:
				req = 1
			play("good")
			msg("들었다", 0.6)
			_drop_btn(true)
	if item != "":
		var frag: float = P.frag
		if frag > 0.0 and grounded and spd > frag:
			crack += ((spd - frag) * 0.3 + 0.15) * dt
			crack_t -= dt
			if crack_t <= 0.0:
				crack_t = 0.25
				beep(2400.0 + rng.randf() * 600.0, 0.03, 0.0, 0.12)
		item_b.material_override = mat(_item_col().lerp(BAD, floorf(clampf(crack, 0.0, 1.0) * 8.0) / 8.0))
		if crack >= 1.0:
			_break()
			return
		if kit_just("drop"):
			_drop(up)
		elif grounded and p.distance_to((P.tgt as Vector3).normalized() * R) < P.tr + 0.6:
			_deliver((P.tgt as Vector3).normalized())
	# 공중에서 들고 있으면 떨어질 자리를 보여 준다
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
	fall_dir = up
	fall_h = maxf(p.length() - R, 0.0) + 1.6
	fall_h0 = fall_h
	fall_v = 0.0
	pick_cd = 1.0
	_drop_btn(false)
	beep(700.0, 0.15, 350.0, 0.2)


func _item_landed() -> void:
	beep(160.0, 0.1, 0.0, 0.25)
	var tg := (P.tgt as Vector3).normalized()
	if P.frag > 0.0 and fall_h0 > 5.5:
		_break()
		return
	if (fall_dir * R).distance_to(tg * R) < P.tr:
		_deliver(tg)
		return
	ig_on = true
	ig_dir = fall_dir
	msg("빗나갔다 — 다시 줍기", 1.0)


func _break() -> void:
	item = ""
	item_b.visible = false
	crack = 0.0
	fall_on = false
	ig_on = true
	ig_dir = HOME_D.normalized()
	ig_b.visible = true
	_drop_btn(false)
	shake = 0.3
	msg("쨍그랑! 다시 받아 와", 1.2)
	beep(3000.0, 0.25, 800.0, 0.3)


## 물건이 닿을 곳에 닿았다
func _deliver(tg: Vector3) -> void:
	item = ""
	item_b.visible = false
	ig_on = false
	fall_on = false
	ig_b.visible = true
	_orient(ig_b, tg * (R + (2.7 if pi_ == 1 else 1.2)), tg, Vector3(0.6, 0.6, 0.6))
	_drop_btn(false)
	_done()


func _done() -> void:
	req = 2
	prog = 1.0
	score += 10
	play("win")
	shake = 0.2
	_say(P.lines[2], 6.0)
	npc_mark.visible = false
	for pb in pad_bs:
		pb.visible = true
	if pi_ == 0:
		has_sail = true
		sail_b.visible = true
	elif pi_ == 1:
		bag_b.visible = true
	if pi_ + 1 >= PL.size():
		fin_t = 5.0
		msg("장미가 웃는다", 3.0)
	else:
		msg("빛길이 열렸다", 1.5)


## 별마다 다른 움직임과 부탁 진행
func _planet_tick(dt: float, up: Vector3, lf: float) -> void:
	if npc_mark.get_parent() != pl:
		npc_mark.position.y = 2.9 + sin(clock * 4.0) * 0.2
	if req == 0 and p.distance_to(npc_n.position) < 5.0:
		req = 1
		_say(P.lines[0], 6.0)
		beep(1000.0, 0.15, 1300.0, 0.2)
	if pi_ == 4 and req == 0 and p.distance_to(HOME_D.normalized() * R) < 4.0:
		req = 1
		_say(P.lines[0], 6.0)
	match pi_:
		0:
			# 바람: 이륙선 80% 이상으로 땅에 붙어 달린 시간
			var on_ := req == 1 and grounded and lf >= 0.8
			if req == 1:
				prog = clampf(prog + (dt / 12.0 if on_ else -0.03 * dt), 0.0, 1.0)
				if on_:
					wind_t -= dt
					if wind_t <= 0.0:
						wind_t = 0.35
						beep(220.0 + 300.0 * prog, 0.3, 160.0, 0.08)
				if prog >= 1.0:
					_done()
			if blades:
				blades.rotation.z += (lf * 9.0 * (1.0 if grounded else 0.2) + (6.0 if req == 2 else 0.3)) * dt
		3:
			# 노을 띠: 적도를 이륙선의 80%(후반 90%) 빠르기로 돈다
			if req == 1:
				var lift := sqrt((gp + float(P.grip)) * R)
				band_a += (0.8 if prog < 0.5 else 0.9) * lift / R * dt
			var lon := atan2(-up.z, up.x)
			var lat := asin(clampf(up.y, -1.0, 1.0))
			var inb := grounded and absf(wrapf(lon - band_a, -PI, PI)) < 0.24 and absf(lat) < 0.5
			for j in band_bs.size():
				var l := -0.4 + 0.2 * j
				var d := Vector3(cos(band_a) * cos(l), sin(l), -sin(band_a) * cos(l))
				_orient(band_bs[j], d * (R + 0.12), d, Vector3(2.2, 0.25, 1.6))
				band_bs[j].material_override = mat(D if inb else A)
			if req == 1:
				prog = clampf(prog + (dt / 14.0 if inb else -0.04 * dt), 0.0, 1.0)
				if inb:
					wind_t -= dt
					if wind_t <= 0.0:
						wind_t = 0.4
						beep(520.0 + 260.0 * prog, 0.12, 0.0, 0.1)
				if prog >= 1.0:
					_done()
		4:
			# 도는 담
			gap_a += 0.8 * dt
			_place_walls()
	# 갈 곳 빛기둥
	var od := _objective()
	beacon.visible = od.length() > 0.5
	if beacon.visible:
		_orient(beacon, od * (R + 5.0), od, Vector3(0.35, 10.0, 0.35))


func _objective() -> Vector3:
	if req == 2:
		return (P.pad as Vector3).normalized() if not pad_bs.is_empty() else Vector3.ZERO
	if req == 0:
		return NPC_D.normalized() if pi_ != 4 else HOME_D.normalized()
	if P.item != "":
		if item != "":
			return (P.tgt as Vector3).normalized()
		if ig_on:
			return ig_dir
		return Vector3.ZERO
	if pi_ == 3:
		return Vector3(cos(band_a), 0, -sin(band_a))
	return Vector3.ZERO


## 말풍선과 부탁 막대
func _hud(dt: float) -> void:
	bub_t -= dt
	var s := ""
	if bub_t > 0.0:
		s = bub_s
	elif req == 1 and P.item == "" and prog < 0.15:
		s = "%s: %s" % [P.who, P.lines[1]]
	elif p.distance_to(npc_n.position) < 6.0:
		s = "%s: %s" % [P.who, P.lines[mini(req, 2)]]
	elif req == 1 and item != "" and P.item != "":
		s = "%s: %s" % [P.who, P.lines[1]] if (clock - floorf(clock / 12.0) * 12.0) < 4.0 else ""
	elif req == 2 and not pad_bs.is_empty() and die_t <= 0.0:
		s = "빛길: 초록 빠르기로 달려와 점프 → 다음 별. 빨강은 너무 빠름."
	bub.visible = s != ""
	bub_l.text = s
	var show := false
	if req == 1 and P.item == "":
		show = true
		pbar.color = A
		pbar.size.x = 594.0 * prog
	elif item != "" and P.frag > 0.0:
		show = true
		pbar.color = BAD
		pbar.size.x = 594.0 * clampf(crack, 0.0, 1.0)
	pbar_bg.visible = show


## 하늘의 다음 별: 천천히 돌고 작은 달이 빠르게 돈다
func _far() -> void:
	if not far_b.visible:
		return
	far_b.rotation.y = clock * 1.5
	var c := far_b.position
	var ax := c.normalized()
	var bx := ax.cross(Vector3.UP if absf(ax.y) < 0.9 else Vector3.RIGHT).normalized()
	var by := ax.cross(bx)
	far_moon.position = c + (bx * cos(clock * 2.5) + by * sin(clock * 2.5)) * 7.0


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
	# 그 별에서 다시: 든 물건은 주인에게, 진행은 처음부터
	if item != "" or fall_on:
		item = ""
		item_b.visible = false
		fall_on = false
		ig_on = true
		ig_dir = HOME_D.normalized()
		ig_b.visible = true
		_drop_btn(false)
	crack = 0.0
	if req == 1:
		prog = 0.0
		band_a = 0.6


func _meteors(dt: float, up: Vector3) -> void:
	var active := (pi_ == 2 and item != "") or (pi_ == 4 and req == 1)
	spawn_t -= dt
	if spawn_t <= 0.0 and active and grounded:
		spawn_t = 2.6 if pi_ == 2 else 3.2
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
	var f := (fwd - up * fwd.dot(up)).normalized()
	var x := up.cross(-f).normalized()
	me.transform = Transform3D(Basis(x, up, -f), p)


func _camera(dt: float) -> void:
	var up := p.normalized()
	var alt := maxf(p.length() - R, 0.0)
	var spd := vel.length()
	var dist := 7.0 + alt * 0.5 + spd / TOP * 1.5
	var want := p + up * (3.2 + alt * 0.3) - cfwd * dist
	if shake > 0.0:
		shake -= dt
		want += Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * shake * 1.2
	cam.position = cam.position.lerp(want, minf(1.0, dt * 5.0))
	cam.look_at(p + up * 1.0 + cfwd * 2.5, up)
	cam.fov = 60.0 + 22.0 * clampf(spd / TOP, 0.0, 1.0)
