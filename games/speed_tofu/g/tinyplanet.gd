extends Tofu
## 작은 행성 v4(등뒤 3인칭, 한 하늘의 여러 별, 진짜 중력 비행): 별 다섯·달 둘·불 별 하나가 한 장면에 떠 있다. 왼쪽 스틱으로 달려 속도를 모아 점프하면 그 별 중력을 벗어나 날아가고, 가까운 별 중력에 끌려 빙 돌다 내려앉는다. 빗나가면 우주로 떠내려가 죽는다. 발 앞 점선이 "지금 뛰면 갈 길"(초록 = 다른 별에 닿음, 빨강 = 위험).
## 나는 [작은 별들 사이를 맨몸으로 건너는 여행자]로서 [달린 속도와 점프 순간이 곧 비행 궤도가 되는 몸] 속에서 [별 주민들의 부탁을 별과 별 사이로 날라 주]지만 [느리면 못 떠나고, 각도가 틀리면 우주로 떠내려가고, 쿵 내려앉으면 유리가 깨지는 것]을 감수한다.
## 별: 1 풍차(바람 달리기 → 돛, 노란 줄로 첫 비행) → 2 우편(소포를 굴뚝 달의 담 친 집에 공중에서 놓기) → 3 유리꽃(꽃을 들고 친구 달로, 빙 돌다 살살 착지) → 4 노을(얼음 위 속도 맞추기 → 유리 덮개) → 5 장미(빨간 바위 띠를 불 별 중력 새총으로 돌아 덮개를 살살).
## v5 겉모습: 상자 대신 로우폴리. 별은 각진 공(icosphere), 사람·소품은 art/tinyplanet/<이름>.glb+png(없으면 코드가 만든 로우폴리).
## 대사는 DL(Gemini가 쓴 dialogue.json을 박아 넣음), 소리는 art/tinyplanet_sfx/*.wav(nkido).
## v6 "어린 배달부 / The Little Courier": 영어가 기본(?lang=ko 또는 시작 화면 전환 → set_lang). 캡슐 막대, 작은 말풍선(아래쪽, 3~4초),
## 튜토리얼 없음(첫 판 안내 한 줄), 첫 별 바위 없음, 값싼 동그란 그림자, 하트는 잃을 때만, 다른 별 가기 쉽게(끌어당김·탈출 도움), 높이 날면 순항 속도.

const TOP := 12.5  # 땅에서 낼 수 있는 최고 속도
const ACC := 7.0
const JUMP := 5.0
const AIRJUMP := 4.5
const LAND_K := 0.55  # 착지 때 남는 접선 속도 비율
const GREY := Color("c9ccd1")
const NM := 4  # 운석 칸
const ND := 24  # 앞길 점선 칸 (v6: 18 → 24, 5.5초 앞까지)
const CRUISE := 9.5  # v6: 높이 떠서 날 때 이 빠르기 밑으로는 안 느려진다
const HOME_A := 1.8  # v6: 앞으로 가장 가까이 지나갈 별 쪽으로 살짝 끄는 힘 (속도 크기는 그대로, 방향만)
const HEART_T := 2.0  # 하트가 보이는 시간
const BUB_BOTTOM := 940.0  # 말풍선 아래 끝 (조작 키트 바로 위)
const RESTART_TXT := ["< 처음부터", "< Restart", "< Start over"]  # 단독판 tofu 의 왼쪽 위 버튼 (v6: 숨김)
const CFG_BODY := "user://tinyplanet_body.cfg"  # 첫 판 안내를 봤나
const START := Vector3(1, 0, 0)
const NPC_D := Vector3(1, 0.12, -0.35)
const HOME_D := Vector3(1, -0.2, -0.22)  # 맡길 물건이 놓인 곳
const TOWER_H := 2.5
const NW := 10  # 담 칸 (장미 별은 하나가 틈)
const MID := Vector3(50, 0, 10)  # 하늘 가운데
const BOUND := 78.0  # 어느 별에도 안 끌린 채 여기 밖이면 떠내려간다 (+10이면 끝)
const BELT_A := Vector3(73.2, 0, 44.4)  # 빨간 바위 띠 (노을 별 → 장미 별 곧은 길을 막는다)
const BELT_B := Vector3(69.0, 0, 27.0)
const ART := "res://art/tinyplanet/"
const SFX := "res://art/tinyplanet_sfx/"
const CREAM := Color("fff6e6")
const NAVY := Color("2b2d42")
const DANGER := Color("e8453c")  # 빨강은 위험에만
const SKIN := Color("ffe3c7")
const ITEM_ART := {"pkg": "parcel", "flower": "glass_flower", "dome": "glass_dome"}
# 별: 0~4 부탁 별, 5 굴뚝 달, 6 친구 달, 7 불 별. 모두 y=0 평면 위.
const BD := [
	{"name": "풍차의 별", "r": 12.0, "g": 8.0, "grip": 1.19, "acc": 1.0, "at": Vector3(0, 0, 0), "kind": "planet",
		"c0": Color("bfe3a0"), "c1": Color("e6f5d4"), "sky": Color("d6ecff"), "who": "풍차지기", "body": Color("8fbf5a"), "hat": A, "id": "p1"},
	{"name": "우편의 별", "r": 8.0, "g": 8.0, "grip": 1.19, "acc": 1.0, "at": Vector3(26, 0, -26), "kind": "planet",
		"c0": Color("d9ccf5"), "c1": Color("f3edff"), "sky": Color("e6dcff"), "who": "우체부", "body": B, "hat": BAD, "id": "p2"},
	{"name": "유리꽃의 별", "r": 10.0, "g": 9.0, "grip": 1.19, "acc": 1.0, "at": Vector3(70, 0, -16), "kind": "planet",
		"c0": Color("bdebd8"), "c1": Color("e6f8f0"), "sky": Color("d6f5ea"), "who": "정원사", "body": GOOD, "hat": D, "id": "p3"},
	{"name": "노을의 별", "r": 7.0, "g": 8.0, "grip": -0.8, "acc": 0.6, "at": Vector3(100, 0, 36), "kind": "planet",
		"c0": Color("c9e3fa"), "c1": Color("eef6ff"), "sky": Color("ffe0c2"), "who": "노을 아이", "body": C, "hat": A, "id": "p4"},
	{"name": "장미의 별", "r": 6.0, "g": 7.0, "grip": 1.19, "acc": 1.0, "at": Vector3(50, 0, 48), "kind": "planet",
		"c0": Color("f7d3dc"), "c1": Color("fff4f6"), "sky": Color("ffe3ec"), "who": "장미", "body": BAD, "hat": GOOD, "id": "p5"},
	{"name": "굴뚝 달", "r": 3.5, "g": 6.0, "grip": 1.19, "acc": 1.0, "at": Vector3(52, 0, -40), "kind": "moon",
		"c0": Color("e9e4d4"), "c1": Color("fffaf0"), "sky": Color("efe8ff"), "who": "굴뚝 집", "body": WHITE, "hat": WHITE, "id": ""},
	{"name": "친구 달", "r": 3.5, "g": 6.0, "grip": 1.19, "acc": 1.0, "at": Vector3(90, 0, 8), "kind": "moon",
		"c0": Color("a8ecd2"), "c1": Color("e8fff6"), "sky": Color("e0fff4"), "who": "꽃 친구", "body": WHITE, "hat": WHITE, "id": ""},
	{"name": "불 별", "r": 3.0, "g": 20.0, "grip": 1.19, "acc": 1.0, "at": Vector3(78, 0, 60), "kind": "fire",
		"c0": BAD, "c1": A, "sky": Color("ffe8d6"), "who": "", "body": WHITE, "hat": WHITE, "id": ""},
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
var fnorm: Array = []  # 별마다 각진 공의 면 방향 (PackedVector3Array) — 발을 실제 면 위에 놓는다
var fdist: Array = []  # 별마다 면까지 거리 (PackedFloat32Array)
var spin: Node3D  # 불 별 장식 (돈다)
var me_body: Node3D  # 나 몸통 (달리면 끄덕이고 기운다)
var step_ph := 0.0
var _en := false  # 영어
# 말·소리
var bub_q: Array = []  # 이어서 나올 말풍선 [누구, 말, 시간]
var bub_last := ""
var react_cd := 0.0
var said := {}  # 한 번만 하는 혼잣말
var drift_said := false
var won := false
var wind_pl: AudioStreamPlayer
var wind_v := -60.0
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
var rings := {}  # 별 번호 -> {c, r, gap, e1, e2, mm(담 MultiMesh), n, h}
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
var bub: Control  # v6: 작은 크림 말풍선 (아래쪽, 글 크기에 맞춤)
var bub_bg: Panel
var bub_sh: Panel
var bub_n: Label  # 말하는 사람 (작게, 색)
var bub_l: Label
var bub_t := 0.0
var bub_s := ""
var bub_who := ""
var bub_age := 0.0
var nag := {}  # 상황 말 번호 -> 다시 해도 되는 시각 (같은 잔소리 반복 없음)
var pbar_bg: Panel
var pbar: Panel
var pbar_sb: StyleBoxFlat
var sim_pts := PackedVector3Array()
# v6: 캡슐 에너지 막대, 하트, 그림자, 점선(MultiMesh), 단독판 왼쪽 위 버튼
var gauge_bg: Panel
var gauge_fill: Panel
var gauge_sb: StyleBoxFlat
var _g_col := Color(0, 0, 0, 0)
var heart_t := 0.0
var heart_lost := -1
var shadow_me: MeshInstance3D
var _shv := PackedVector3Array()  # 움직이지 않는 그림자 (한 메시로 합친다)
var _shu := PackedVector2Array()
var _shi := PackedInt32Array()
var _sf_n := Vector3.UP  # _srn 이 찾은 면 방향
var dots_mm: MultiMesh
var _dot_mesh: Mesh
var sim_cd := 0
var sim_res := -1
var sim_show := false
var _back_l: Label
var _back_hid := false
var _st := {}  # _state 가 매 프레임 다시 쓰는 사전 (새로 만들지 않는다)
var ob_k := -1  # 이번 프레임 갈 곳 (_obj)
var ob_d := Vector3.ZERO
var _band_last := -99.0
var _band_on := false
var _item_key := ""
var _item_q := -1.0
static var _lang_pick := ""  # set_lang 으로 고른 언어 ("ko"/"en"), 이 탭이 열려 있는 동안
# v5 도우미: 시작 화면·튜토리얼·끝 화면(ui), 속도감·연출(fx). submit/tinyplanet/MODULES.md 약속
const UI_GD := preload("res://g/tinyplanet_ui.gd")
const FX_GD := preload("res://g/tinyplanet_fx.gd")
var ui: UI_GD
var fx: FX_GD
var _bodies_on := false  # fx.set_bodies 는 한 번
var _stepped := false  # 이번 프레임 _step 이 돌았나 (안 돌면 _process 가 대신 tick)
var _title_was := false
var bfire := PackedByteArray()  # 별마다 불 별인가 (비행 도움이 매 단계 사전을 안 읽게)


func _setup() -> void:
	_lang()
	time_limit = 0.0
	howto = ""  # 설명 카드·튜토리얼 없음 (v6: 첫 판에만 말풍선 안내 한 줄)
	ui = UI_GD.new()
	add_child(ui)
	ui.setup(self)
	fx = FX_GD.new()
	add_child(fx)
	fx.setup(self)
	ui.show_title(_on_title_start)
	_title_was = true
	if DisplayServer.get_name() == "headless":
		ui.call("_title_go", false)  # smoke: 시작 화면을 바로 닫고 놀이를 돌린다
	kit_stick()
	kit_button("jump", _tx("ui.jump"), Vector2(580, 1070), 110.0, A)
	for ch in get_children():
		if ch is WorldEnvironment:
			env_node = ch
			# 밝은 화면: 그늘 쪽 면도 너무 어둡지 않게
			env_node.environment.ambient_light_energy = 0.8
		elif ch is DirectionalLight3D:
			(ch as DirectionalLight3D).light_energy = 0.75
	wind_pl = AudioStreamPlayer.new()
	add_child(wind_pl)
	var ws: Variant = _sfx_get("wind")
	if ws is AudioStreamWAV:
		var w := (ws as AudioStreamWAV).duplicate() as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate) - 1
		wind_pl.stream = w
	wind_pl.volume_db = -60.0
	# 단독판의 "< 처음부터"는 숨긴다 (메뉴판 "< 메뉴"·목록에서 온 "< 목록"은 그대로). 글자는 번역 전 키라 한국어로 찾힌다
	_back_l = _find_back(self)
	hud2 = CanvasLayer.new()
	hud2.layer = 4
	add_child(hud2)
	# 에너지 막대: 양 끝이 둥근 캡슐 (크림 바탕·잉크 테두리·아래 그림자), 채움도 캡슐. tofu 의 네모 막대는 안 쓴다
	gauge_bg = _capsule(hud2, Rect2(60, 190, 600, 40), CREAM, 5, NAVY)
	var gsh := _capsule(gauge_bg, Rect2(0, 6, 600, 40), Color(NAVY, 0.4), 0, NAVY)
	gsh.show_behind_parent = true
	gauge_fill = _capsule(gauge_bg, Rect2(8, 8, 26, 24), Color("ffd166"), 0, NAVY)
	gauge_sb = gauge_fill.get_theme_stylebox("panel") as StyleBoxFlat
	gauge_bg.visible = false
	# 부탁 막대 (풍차 바람·노을 띠·유리 금): 막대 아래 가는 캡슐
	pbar_bg = _capsule(hud2, Rect2(110, 242, 500, 20), CREAM, 3, NAVY)
	pbar = _capsule(pbar_bg, Rect2(4, 4, 12, 12), Color("ffd166"), 0, NAVY)
	pbar_sb = pbar.get_theme_stylebox("panel") as StyleBoxFlat
	pbar_bg.visible = false
	_bub_build()


## 둥근 판 (모서리 = 높이/2 → 캡슐). bw > 0 이면 잉크 테두리
func _capsule(parent: Node, rc: Rect2, fill: Color, bw: int, line: Color, rad := -1) -> Panel:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.set_corner_radius_all(int(rc.size.y * 0.5) if rad < 0 else rad)
	sb.corner_detail = 10
	sb.anti_aliasing = true
	if bw > 0:
		sb.set_border_width_all(bw)
		sb.border_color = line
	var pn := Panel.new()
	pn.add_theme_stylebox_override("panel", sb)
	pn.position = rc.position
	pn.size = rc.size
	pn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(pn)
	return pn


## 말풍선: 크림 판(모서리 22, 잉크 테두리 4, 아래 5px 잉크 40% 그림자) + 이름(작게, 색) + 말. 크기는 글에 맞춰 _bub_layout 이 정한다
func _bub_build() -> void:
	bub = Control.new()
	bub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bub.visible = false
	hud2.add_child(bub)
	bub_sh = _capsule(bub, Rect2(0, 5, 100, 60), Color(NAVY, 0.4), 0, NAVY, 22)
	bub_bg = _capsule(bub, Rect2(0, 0, 100, 60), CREAM, 4, NAVY, 22)
	bub_n = _bub_label(22, NAVY)
	bub_l = _bub_label(28, NAVY)
	bub_l.autowrap_mode = TextServer.AUTOWRAP_WORD


func _bub_label(fs: int, col: Color) -> Label:
	var s := LabelSettings.new()
	s.font = _font
	s.font_size = fs
	s.font_color = col
	s.line_spacing = 2.0
	var l := Label.new()
	l.label_settings = s
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED  # 이미 번역한 글
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bub.add_child(l)
	return l


func _find_back(n: Node) -> Label:
	for c in n.get_children():
		if c is Label:
			var tx := (c as Label).text
			if tx in RESTART_TXT or tx == "< 메뉴":
				return c as Label
		if c is CanvasLayer:
			var r := _find_back(c)
			if r:
				return r
	return null


func _basis(up: Vector3) -> Basis:
	var x := up.cross(Vector3.FORWARD if absf(up.z) < 0.9 else Vector3.RIGHT).normalized()
	return Basis(x, up, x.cross(up))


func _orient(m: MeshInstance3D, at: Vector3, up: Vector3, sz: Vector3) -> void:
	var bs := _basis(up)
	m.transform = Transform3D(Basis(bs.x * sz.x, bs.y * sz.y, bs.z * sz.z), at)


## 표면 판 하나 (dir 방향, 땅에서 h 높이에 가운데, 육각 판) — 노란 줄·노을 띠
func _sbox(dir: Vector3, h: float, sz: Vector3, col: Color) -> MeshInstance3D:
	var m := _ushape("hex", col, pl)
	var d := dir.normalized()
	# 각진 겉면(_sr) 위에 얹는다. R 에 두면 꼭짓점에서 판이 반쯤 묻힌다
	var k := nodes.find(pl)
	_orient(m, d * ((_sr(k, d) if k >= 0 else R) + h), d, sz)
	return m


## 별 표면 위 dir 자리에 그림 모델을 세운다 (바닥 가운데가 원점인 모델). 각진 면 높이에 발을 맞춘다.
func _stand(nm: String, dir: Vector3, sc: float, tint := Color.WHITE, parent: Node3D = null) -> MeshInstance3D:
	var m := _art(nm, Callable(), parent if parent else pl, tint)
	var d := dir.normalized()
	var bs := _basis(d)
	m.transform = Transform3D(Basis(bs.x * sc, bs.y * sc, bs.z * sc), d * (_sr(bk, d) - 0.05))
	return m


## 주민: 그림 모델 + 색 모자 + 머리 위 "!" (부탁이 남아 있으면)
func _person(dir: Vector3, body: Color, hat: Color) -> Node3D:
	var n := Node3D.new()
	pl.add_child(n)
	var d := dir.normalized()
	n.transform = Transform3D(_basis(d), d * R)
	var lift := _sr(bk, d) - R - 0.05
	var v := _art("villager", Callable(), n, WHITE.lerp(body, 0.35))
	v.transform = Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * 1.1), Vector3(0, lift, 0))
	var h := _proc("hat", Callable(self, "_shape_hat"), n, hat)
	h.position = Vector3(0, lift + 1.66, 0)
	npc_mark = _ushape("gem", D, n)
	npc_mark.position = Vector3(0, 2.9, 0)
	npc_mark.scale = Vector3(0.45, 0.95, 0.45)
	return n


var npc_mark: MeshInstance3D
var bk := 0  # 짓는 중인 별


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
	bub_q.clear()
	bub_last = ""
	react_cd = 0.0
	said = {}
	drift_said = false
	won = false
	# 먼 하늘: 흰·노란 별 조각과 구름 덩어리 (밝은 파스텔 하늘, 어두운 우주 없음)
	_sky()
	# 별 수치
	bc.clear()
	br.clear()
	bg.clear()
	bmu.clear()
	bsoi.clear()
	batm.clear()
	bfire.clear()
	for k in BD.size():
		var d: Dictionary = BD[k]
		var r: float = d.r
		bc.append(d.at)
		br.append(r)
		bg.append(d.g)
		bmu.append(float(d.g) * r * r)
		# v6: 작은 별·달의 끄는 둘레 12 → 13.5, 대기 1.6R → 1.75R (스치기만 해도 잡히게)
		bsoi.append(16.0 if d.kind == "fire" else maxf(2.2 * r, 13.5))
		batm.append(0.0 if d.kind == "fire" else maxf(1.75 * r, r + 4.5))
		bfire.append(1 if d.kind == "fire" else 0)
	here = Node3D.new()
	world.add_child(here)
	# 나: 여행자 모델(망토·목도리), 목숨 3, 든 물건, 돛, 우편 가방
	me = Node3D.new()
	world.add_child(me)
	me_body = Node3D.new()
	me.add_child(me_body)
	_art("traveler", Callable(), me_body)
	hearts.clear()
	heart_t = 0.0
	heart_lost = -1
	for i in 3:
		var h := _proc("heart", Callable(self, "_shape_heart"), me)
		h.position = Vector3(-0.32 + 0.32 * i, 1.95, 0)
		h.visible = false  # v6: 목숨을 잃을 때·다시 설 때만 잠깐
		hearts.append(h)
	# v6 값싼 그림자: 흐린 잉크색 원판 (빛 없음, 반투명). 나는 발밑 별 면에 비추고, 높이 뜰수록 작고 옅게
	shadow_me = MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(1, 1)
	shadow_me.mesh = pm
	shadow_me.material_override = _shadow_mat()
	shadow_me.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(shadow_me)
	if gauge_bg:
		gauge_bg.visible = false
	_g_col = Color(0, 0, 0, 0)
	_item_key = ""
	_band_last = -99.0
	_band_on = false
	nag.clear()
	bub_who = ""
	item_b = _art("parcel", Callable(), me_body)
	item_b.position = Vector3(0, 2.2, 0)
	item_b.scale = Vector3.ONE * 1.25
	item_b.visible = false
	sail_b = _proc("sail", Callable(self, "_shape_sail"), me_body)
	sail_b.position = Vector3(0, 0.55, 0.32)
	sail_b.visible = false
	bag_b = _proc("bag", Callable(self, "_shape_bag"), me_body)
	bag_b.position = Vector3(0.36, 0.55, 0.0)
	bag_b.visible = false
	mark_b = _ushape("disc", D, here)
	mark_b.visible = false
	# 앞길 점선: 점 24개를 MultiMesh 하나로 (그리기 2번: 점 + 구운 외곽선)
	dots.clear()
	dots_mm = MultiMesh.new()
	dots_mm.transform_format = MultiMesh.TRANSFORM_3D
	dots_mm.use_colors = true
	dots_mm.mesh = _dots_mesh()
	dots_mm.instance_count = ND
	dots_mm.visible_instance_count = 0
	var dmi := MultiMeshInstance3D.new()
	dmi.multimesh = dots_mm
	dmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(dmi)
	sim_cd = 0
	sim_show = false
	# 운석 칸 (발밑 별에 붙는다)
	mph.resize(NM)
	mdir.resize(NM)
	mt.resize(NM)
	mb.clear()
	msh.clear()
	for i in NM:
		mph[i] = 0
		var m := _art("meteor", Callable(), here)
		m.visible = false
		mb.append(m)
		var s := _ushape("disc", DANGER, here)
		s.visible = false
		msh.append(s)
	_build()
	if not _bodies_on:
		_bodies_on = true
		var rad := PackedFloat32Array()
		for k in BD.size():
			rad.append(0.0 if BD[k].kind == "fire" else br[k])
		fx.set_bodies(bc, rad)
	ui.reset_run()
	beacon = _ushape("hex", D)
	ig_b = _art("parcel", Callable())
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
	heart_t = 0.0  # 첫 시작엔 하트를 안 띄운다
	cam_up = START
	lookd = Vector3.FORWARD
	msg(_tx("msg.start", {"planet": tr(BD[0].name)}), 2.0)
	if DisplayServer.get_name() == "headless" and not _counted:
		_counted = true
		_count_draws.call_deferred()


## 별 여덟 개를 한 하늘에 짓는다. 별마다 각진 공 하나 + 겉에 뿌린 작은 장식(달릴 때 속도가 읽히는 표지).
func _build() -> void:
	nodes.clear()
	fnorm.clear()
	fdist.clear()
	rings.clear()
	_shv = PackedVector3Array()
	_shu = PackedVector2Array()
	_shi = PackedInt32Array()
	band_bs.clear()
	npcs.clear()
	marks.clear()
	belt.clear()
	spin = null
	for k in BD.size():
		var d: Dictionary = BD[k]
		var n := Node3D.new()
		world.add_child(n)
		n.position = bc[k]
		nodes.append(n)
		pl = n
		R = br[k]
		bk = k
		_planet(k, n)
		if k <= 3:
			npcs[k] = _person(NPC_D, d.body, d.hat)
			marks[k] = npc_mark
			_shadow_q(k, NPC_D, 0.75)
		match k:
			0:
				# 북극의 큰 풍차 (v6: 적도의 바위 일곱은 뺐다 — 걸려 느려지는 게 불쾌)
				_stand("windmill_tower", Vector3.UP, 1.0)
				_shadow_q(0, Vector3.UP, 2.2)
				blades = Node3D.new()
				n.add_child(blades)
				blades.position = Vector3(0, _sr(0, Vector3.UP) + 8.2, 0.7)
				_art("windmill_blades", Callable(), blades)
			3:
				# 노을 아이의 의자와 노을 띠
				_stand("stool", NPC_D + Vector3(0, 0, 0.12), 1.0)
				for j in 5:
					band_bs.append(_sbox(Vector3.RIGHT, 0.2, Vector3.ONE, A))
			4:
				# 담 안의 장미 (담은 돌고 틈이 하나), 탑
				var c: Vector3 = (JOB[4].tdir as Vector3).normalized()
				var rn := Node3D.new()
				n.add_child(rn)
				rn.transform = Transform3D(_basis(c), c * R)
				var ro := _art("rose", Callable(), rn)
				ro.position = Vector3(0, _sr(4, c) - R - 0.05, 0)
				npcs[4] = rn
				var mk := _ushape("gem", D, rn)
				mk.position = Vector3(0, 2.6, 0)
				mk.scale = Vector3(0.45, 0.95, 0.45)
				marks[4] = mk
				_ring(4, c, 2.2, true, 1.6)
				_shadow_q(4, c, 0.6)
				_stand("tower", tower_d, TOWER_H / 2.5)
				_shadow_q(4, tower_d, 1.0)
			5:
				# 굴뚝 집과 높은 담
				var c: Vector3 = (JOB[1].tdir as Vector3).normalized()
				_stand("chimney_house", c, 1.0)
				_shadow_q(5, c, 1.5)
				_ring(5, c, 1.8, false, 2.6)
			6:
				# 꽃 친구
				npcs[6] = _person(JOB[2].tdir, Color("f783ac"), C)
				npc_mark.visible = false
				_shadow_q(6, JOB[2].tdir, 0.7)
		_deco(k, n)
	# 빨간 바위 띠: 노을 별에서 장미 별로 곧게 가는 길을 막는다 (가운데 y=0 이 가장 굵다). v6: 12개를 MultiMesh 하나로
	var r2 := RandomNumberGenerator.new()
	r2.seed = 991
	var bmm := _mm("red_rock", 12, world)
	var bi := 0
	for j in 6:
		var q := BELT_A.lerp(BELT_B, (j + 0.5) / 6.0)
		for flip in [false, true]:
			var bs := Basis(Vector3.UP, r2.randf() * TAU).scaled(Vector3(1.45, r2.randf_range(0.8, 1.05), 1.45))
			if flip:
				bs = Basis(Vector3.RIGHT, PI) * bs
			bmm.set_instance_transform(bi, Transform3D(bs, q))
			bi += 1
		belt.append(q)
	# 움직이지 않는 그림자 (주민·풍차·집·탑·나무) 를 한 메시로
	if _shv.size() > 0:
		var arr := []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = _shv
		arr[Mesh.ARRAY_TEX_UV] = _shu
		arr[Mesh.ARRAY_INDEX] = _shi
		var am := ArrayMesh.new()
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		var sm := MeshInstance3D.new()
		sm.mesh = am
		sm.material_override = _shadow_mat()
		sm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		world.add_child(sm)
	pl = nodes[0]
	R = br[0]


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


func _ring(k: int, c: Vector3, rr: float, gap: bool, h: float) -> void:
	var bs := _basis(c)
	var cnt := NW - 1 if gap else NW + 2
	# v6: 담 조각을 MultiMesh 하나로 (별의 자식이라 별 기준 좌표)
	rings[k] = {"c": c, "r": rr, "gap": gap, "e1": bs.x, "e2": bs.z, "mm": _mm("wall", cnt, pl), "n": cnt, "h": h}
	_place_walls(k)


## 같은 모델 n 개를 MultiMesh 하나로 (그림 재질 + 외곽선 next_pass 그대로)
func _mm(nm: String, n: int, parent: Node3D) -> MultiMesh:
	var e := _art_entry(nm, Callable())
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = e[0]
	mm.instance_count = n
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = _art_mat(nm, Color.WHITE)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mm


func _ring_pt(rg: Dictionary, rk: float, th: float) -> Vector3:
	var al: float = float(rg.r) / rk
	var c: Vector3 = rg.c
	var e1: Vector3 = rg.e1
	var e2: Vector3 = rg.e2
	return (c * cos(al) + (e1 * cos(th) + e2 * sin(th)) * sin(al)).normalized()


func _place_walls(k: int) -> void:
	var rg: Dictionary = rings[k]
	var rk := br[k]
	var mm: MultiMesh = rg.mm
	var cnt: int = rg.n
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
		# 담 조각 모델은 바닥 가운데가 원점, 1 x 1 x 0.5 (각진 땅에 묻히게 살짝 내린다)
		mm.set_instance_transform(j, Transform3D(Basis(tang * ln, d * h, side), d * (rk - 0.12)))


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
	_hearts_show(-1)
	_dots_off()
	_place_me()
	_emit("respawn")


## up 에 수직인 단위 방향 (평행이면 아무 수직 방향)
func _flat(v: Vector3, up: Vector3) -> Vector3:
	var f := v - up * v.dot(up)
	if f.length() < 0.01:
		f = up.cross(Vector3.UP if absf(up.y) < 0.9 else Vector3.RIGHT)
	return f.normalized()


## 말풍선 하나 (who 가 "" 이면 이름 없는 안내). v6: 3~4초만 (글 길이에 맞춰), 놀이는 안 멈춘다
func _say(who: String, s: String, dur: float) -> void:
	if s == "":
		return
	bub_who = who
	bub_s = tr(s)
	bub_t = clampf(2.2 + bub_s.length() * 0.03, 2.6, clampf(dur, 2.6, 4.2))
	bub_age = 0.0
	_bub_layout()
	sfx("talk", -7.0, 0.8 + float(bub_s.unicode_at(0) % 7) * 0.09)


## 상황 말: 같은 번호는 cd 초 안에 다시 안 한다 (잔소리 반복 없음)
func _nag(id: int, cd: float, who: String, s: String) -> bool:
	if s == "" or clock < float(nag.get(id, -1.0)):
		return false
	nag[id] = clock + cd
	_say(who, s, 4.0)
	return true


## 말하는 사람 색: 주민은 옷 색(조금 진하게), 나는 잉크, 안내는 없음
func _who_col(who: String) -> Color:
	for d: Dictionary in BD:
		if str(d.who) == who and who != "":
			return (d.body as Color).darkened(0.3) if d.body != WHITE else NAVY
	if who == BD[5].who:
		return Color("8a6d3b")
	return Color("6a4fc9")


## 글 크기에 맞춰 말풍선을 짓고, 아래쪽(조작 키트 바로 위)에 둔다. '놓기' 버튼이 있으면 왼쪽으로 비킨다
func _bub_layout() -> void:
	var nm := tr(bub_who) if bub_who != "" else ""
	var narrow := _btns.has("drop")
	var maxw := 440.0 if narrow else 560.0
	var padx := 22.0
	var pady := 12.0
	bub_l.size = Vector2(maxw - padx * 2.0, 10)
	bub_l.text = bub_s
	var tw := _font.get_multiline_string_size(bub_s, HORIZONTAL_ALIGNMENT_LEFT, maxw - padx * 2.0, 28)
	var nw := _font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x if nm != "" else 0.0
	var w := clampf(maxf(tw.x + 6.0, nw) + padx * 2.0, 150.0, maxw)
	var lines := maxi(bub_l.get_line_count(), 1)
	var th := lines * bub_l.get_line_height() + (lines - 1) * 2.0
	var nh := 28.0 if nm != "" else 0.0
	var h := th + nh + pady * 2.0
	bub_n.visible = nm != ""
	bub_n.text = nm
	bub_n.label_settings.font_color = _who_col(bub_who)
	bub_n.position = Vector2(padx, pady - 2.0)
	bub_n.size = Vector2(w - padx * 2.0, 28)
	bub_l.position = Vector2(padx, pady + nh)
	bub_l.size = Vector2(w - padx * 2.0, th)
	bub_bg.size = Vector2(w, h)
	bub_sh.size = Vector2(w, h)
	bub.size = Vector2(w, h)
	bub.position = Vector2(24.0 if narrow else 360.0 - w * 0.5, BUB_BOTTOM - h)
	bub.pivot_offset = Vector2(w * 0.5, h)


## 말풍선 뜨고 지기: 0.15초에 살짝 커지며 나타나고, 끝 0.25초에 옅어진다
func _bub_anim(dt: float) -> void:
	if bub_t <= 0.0:
		bub.visible = false
		return
	bub.visible = true
	bub_age += dt
	var k := clampf(bub_age / 0.15, 0.0, 1.0)
	bub.modulate.a = minf(k, clampf(bub_t / 0.25, 0.0, 1.0))
	var sc := 0.88 + 0.12 * _bo(k)
	bub.scale = Vector2(sc, sc)


## 튀어나오는 곡선 (0→1, 살짝 넘쳤다 돌아옴)
func _bo(t: float) -> float:
	var c1 := 1.70158
	var u := t - 1.0
	return 1.0 + (c1 + 1.0) * u * u * u + c1 * u * u


## 지금 말이 끝나면 이어서
func _sayq(who: String, s: String, dur: float) -> void:
	if bub_t <= 0.0 and bub_q.is_empty():
		_say(who, s, dur)
	else:
		bub_q.append([who, s, dur])


## 나의 짧은 혼잣말 (react.*). 주민 말을 끊지 않고, 자주 안 한다. force = 죽은 이유 안내
func _react(key: String, once := false, force := false) -> void:
	if once and said.has(key):
		return
	if not DL.has("react." + key):
		return
	if not force and (react_cd > 0.0 or bub_t > 0.5 or not bub_q.is_empty()):
		return
	said[key] = true
	react_cd = 9.0
	_say(_tx("who.me"), _tx("react." + key), 2.8)


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
	var tanv := v - up * vr
	tanv *= maxf(0.0, 1.0 - minf(0.35 + 0.25 * at, 1.2) * h)
	v = tanv + up * vr
	if at > 2.0:
		v += -up * bg[k] * 0.6 * h
	return v


## 지금 위치·속도로 날면 어떻게 되나: 닿는 별 번호, -1 아직 날고 있음, -2 위험(불 별·바위 띠·떠내려감).
## out 에 점 위치를 넣는다.
## v6 비행 도움 (날기와 점선 계산이 같이 쓴다). dm = 지금 가장 세게 끄는 별(-1 없음), src = 이번 비행을 띄운 별.
## 1) 순항: 어느 별에도 안 끌리거나, 발밑 별을 벗어날 힘이 있고 대기 위면 CRUISE 까지 앞으로 밀어 준다 (높이 떠서 느릿느릿 없음)
## 2) 끌어당김: 떠난 별 둘레를 벗어나면, 이대로 가면 가장 가까이 지나갈 별(불 별 빼고) 쪽으로 방향만 살짝 튼다 (빗나감에 너그럽게)
func _assist(w: Vector3, v: Vector3, dm: int, src: int, h: float) -> Vector3:
	var spd := v.length()
	if spd < 0.5:
		return v
	var vh := v / spd
	var free := dm < 0
	if not free:
		var r := (w - bc[dm]).length()
		free = r > maxf(batm[dm], br[dm] + 3.0) and 0.5 * spd * spd - bmu[dm] / r > -bmu[dm] / bsoi[dm]
	if free and spd < CRUISE:
		spd = minf(spd + 6.0 * h, CRUISE)
		v = vh * spd
	if dm == src:
		return v
	var best := -1
	var bm := 1.0
	var bmv := Vector3.ZERO
	for j in bc.size():
		if bfire[j] == 1:
			continue
		var rel := bc[j] - w
		var t := rel.dot(vh)
		if t <= 0.0:
			continue
		var m := rel - vh * t
		var q := m.length() / (bsoi[j] * 1.6 + 6.0)
		if q < bm:
			bm = q
			best = j
			bmv = m
	if best >= 0:
		var ml := bmv.length()
		if ml > br[best] * 0.6:
			v += bmv / ml * (HOME_A * clampf((1.0 - bm) * 2.0, 0.0, 1.0) * h)
			v = v.normalized() * spd
	return v


func _sim(w: Vector3, v: Vector3, k: int, at: float, secs: float, h: float, out: PackedVector3Array, src := -1) -> int:
	var n := int(secs / h)
	var every := maxi(1, n / ND)
	out.clear()
	if src < 0:
		src = k
	for i in n:
		v += _gacc(w) * h
		var dm := _dominant(w)
		if dm >= 0:
			k = dm
		var rel := w - bc[k]
		if batm[k] > 0.0 and rel.length() < batm[k] and v.dot(rel) < 0.5 * rel.length():
			at += h
		v = _air_drag(v, k, rel, at, h)
		v = _assist(w, v, dm, src, h)
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
## v6: 계산은 3프레임에 한 번 (날기↔땅이 바뀌면 바로), 점 24개는 MultiMesh 하나. 다른 별에 닿으면 끝 점이 크다.
func _dots_update(up: Vector3, lift: float) -> void:
	var show := false
	if die_t <= 0.0 and fin_t <= 0.0:
		show = (grounded and vel.length() > lift * 0.6) or not grounded
	if not show:
		_dots_off()
		return
	sim_cd -= 1
	if sim_show and sim_cd > 0:
		return
	sim_cd = 3
	sim_show = true
	var w := bc[cur] + p
	if grounded:
		sim_res = _sim(w + up * 0.1, _jump_v(up, vel + up * JUMP), cur, 0.0, 5.5, 1.0 / 30.0, sim_pts, cur)
	else:
		sim_res = _sim(w, vel, cur, atm_t, 5.5, 1.0 / 30.0, sim_pts, from_b)
	var lb := cur if grounded else from_b
	var col := WHITE
	if sim_res == -2:
		col = BAD
	elif sim_res >= 0 and sim_res != lb:
		col = GOOD
	var n := mini(sim_pts.size(), ND)
	dots_mm.visible_instance_count = n
	for i in n:
		var sc := 1.0
		if i == n - 1 and col == GOOD:
			sc = 1.9
		dots_mm.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3(sc, sc, sc)), sim_pts[i]))
		dots_mm.set_instance_color(i, col)


func _dots_off() -> void:
	sim_show = false
	sim_cd = 0
	if dots_mm:
		dots_mm.visible_instance_count = 0


## 점 하나: 각진 공 + 구운 외곽선 (MultiMesh 가 점마다 색을 곱한다)
func _dots_mesh() -> Mesh:
	if _dot_mesh:
		return _dot_mesh
	_begin()
	_rs.seed = 17
	_ico(Vector3.ZERO, Vector3.ONE * 0.27, 0, WHITE, WHITE, _rs)
	_hull(0, Vector3.ZERO, 0.07)
	var am := _end_mesh()
	var sm := StandardMaterial3D.new()
	sm.vertex_color_use_as_albedo = true
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	am.surface_set_material(0, sm)
	_dot_mesh = am
	return am


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
		_sbox(d, 0.2, Vector3(1.6, 0.2, 1.6), GOOD if j == 5 else D)
	pl = nodes[cur]
	R = br[cur]


func _turn(a: Vector3, b: Vector3, t: float) -> Vector3:
	var r := a.slerp(b, t)
	if not r.is_finite() or r.length() < 0.1:
		return b.normalized()
	return r.normalized()


## 매 프레임: 시작 화면이면 하늘을 천천히 돌고, 아니면 놀이. 끝에 ui·fx 에 상태를 넘긴다 (fx 는 _camera 뒤)
func _step(dt: float) -> void:
	_stepped = true
	if ui.title_visible():
		clock += dt
		_title_cam(dt)
	else:
		_play(dt)
	_post(dt)


func _post(dt: float) -> void:
	var s := _state()
	ui.tick(dt, s)
	fx.tick(dt, s)


## 시작 화면 카메라: 하늘 가운데(MID)를 높이 떠서 천천히 돈다 (별들이 한눈에)
func _title_cam(_dt: float) -> void:
	var a := clock * 0.07 + 0.6
	cam.position = MID + Vector3(cos(a) * 88.0, 34.0 + sin(clock * 0.21) * 6.0, sin(a) * 88.0)
	cam.look_at(MID + Vector3(0, -4.0, 0), Vector3.UP)


## ui·fx 에 넘기는 상태 (MODULES.md 의 키 전부)
func _state() -> Dictionary:
	var up := p.normalized() if p.length() > 0.01 else Vector3.UP
	var lf := sqrt(maxf(gp + float(P.get("grip", 1.19)), 0.5) * R)
	var spd := vel.length()
	# v6: 매 프레임 새 사전을 만들지 않고 같은 사전의 값만 바꾼다
	_st["speed"] = spd
	_st["top"] = TOP
	_st["lift"] = spd / maxf(lf, 0.1)
	_st["esc"] = _esc_show(up)
	_st["grounded"] = grounded
	_st["flying"] = not grounded
	_st["pos"] = bc[cur] + p if cur < bc.size() else p
	_st["vel"] = vel
	_st["up"] = up
	_st["fwd"] = fwd
	_st["me"] = me
	_st["sky"] = P.get("sky", Color("d6ecff"))
	_st["planet"] = cur
	_st["paused"] = ui.title_visible() or _rating or over
	return _st


## 두 도우미에게 같은 일을 알린다
func _emit(nm: String, d := {}) -> void:
	if ui:
		ui.event(nm, d)
	if fx:
		fx.event(nm, d)


## 시작을 눌러 시작 화면이 닫혔다. v6: 튜토리얼 없음 — 첫 판에만 안내 한 줄 (말풍선, 4초)
func _on_title_start() -> void:
	if not over:
		hud2.visible = true
	msg(_tx("msg.start", {"planet": tr(BD[0].name)}), 2.0)
	var cf := ConfigFile.new()
	cf.load(CFG_BODY)
	if not bool(cf.get_value("hint", "first", false)):
		cf.set_value("hint", "first", true)
		cf.save(CFG_BODY)
		_say("", _tx("hint.first"), 4.2)


## 시작 화면의 언어 전환이 부른다 (ui: game.set_lang(ko)). 번역을 바꾸고 본체가 그린 글(점프·놓기 버튼, 말풍선)을 고친다.
## Label.text 가 한국어 키인 글(tofu 의 "< 메뉴"·"평가")은 Godot 가 저절로 다시 번역한다. ui 글은 ui.refresh_text 가 고친다.
func set_lang(ko: bool) -> void:
	_lang_pick = "ko" if ko else "en"
	_lang()
	if _btns.has("jump"):
		_btns["jump"].label = _tx("ui.jump")
	if _btns.has("drop"):
		_btns["drop"].label = _tx("ui.drop")
	if bub and bub_t > 0.0:
		bub_t = 0.0
	if ui and ui.has_method("refresh_text"):
		ui.call("refresh_text")


## 지금 한국어인가
func is_korean() -> bool:
	return not _en


func _play(dt: float) -> void:
	clock += dt
	_hud(dt)
	_vis(dt)
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
		sfx("step", -10.0 + 6.0 * spd / TOP, 0.85 + 0.45 * spd / TOP)
		_emit("step")
	# 이륙 경고음: 이륙선 가까우면 잦아진다
	if spd > lift * 0.8:
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = lerpf(0.5, 0.12, clampf((spd - lift * 0.8) / (lift * 0.2), 0.0, 1.0))
			sfx("ui_tap", -12.0, 1.0 + 0.8 * clampf((spd - lift * 0.8) / (lift * 0.2), 0.0, 1.0))
	if cur == 4 and tower_cd <= 0.0 and p.distance_to(tower_d * R) < 1.2:
		# 탑: 꼭대기로 올라가 뛰어내린다 (천천히 들어와도 된다)
		var tf := _flat(fwd, tower_d)
		_liftoff()
		p = tower_d * (R + TOWER_H + 0.3)
		vel = tf * clampf(spd, 2.5, 3.5)
		tower_cd = 2.5
		msg(_tx("msg.tower_jump"), 0.9)
		sfx("liftoff")
	elif kit_just("jump"):
		_liftoff()
		vel = _jump_v(up, vel + up * JUMP)
		if 0.5 * vel.length_squared() - mu / R > -mu / bsoi[cur]:
			sfx("escape")
			_emit("escape", {"from": cur})  # 대표 장면: fx 가 느려지며 하늘을 넓게 보여 준다
			_react("first_liftoff", true)
		else:
			sfx("liftoff", -3.0)
	elif spd * spd / R > gp + grip:
		_liftoff()
		sfx("liftoff", -2.0, 1.1)


func _liftoff() -> void:
	_emit("liftoff")
	grounded = false
	airjump = false
	fly_t = 0.0
	atm_t = 0.0
	from_b = cur
	passed = {}
	in_atm = false
	drift_said = false
	sim_cd = 0  # 점선을 바로 다시 계산


## v6 탈출 도움: 점프 순간 에너지가 탈출선의 _esc_need() 를 넘었으면 모자란 만큼 앞으로 밀어 탈출선 바로 위(1.03)로.
## 땅의 점선 계산도 같은 것을 쓴다.
func _jump_v(up: Vector3, v: Vector3) -> Vector3:
	var e0 := -mu / R
	var e1 := -mu / bsoi[cur]
	var ef := (0.5 * v.length_squared() - mu / R - e0) / maxf(e1 - e0, 0.01)
	if ef >= _esc_need() and ef < 1.03 and v.length() > 0.1:
		var v2 := 2.0 * (e0 + 1.03 * (e1 - e0) + mu / R)
		return v.normalized() * sqrt(maxf(v2, 0.0))
	return v


## 탈출선의 몇 %면 떠날 수 있게 도와주나: 첫 부탁 둘(풍차·우편)은 82%, 그 뒤 92%
func _esc_need() -> float:
	return 0.82 if mi <= 1 else 0.92


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
		if not in_atm and fly_t > 0.6 and cur != from_b:
			sfx("atmo")  # 다른 별의 대기에 들어왔다 (제 별에서 뛰는 건 소리 없음)
			_emit("atmo", {"k": cur})
	in_atm = ia
	vel = _air_drag(vel, cur, p, atm_t, dt)
	vel = _assist(bc[cur] + p, vel, _dominant(bc[cur] + p), from_b, dt)  # v6: 순항 속도·끌어당김 (점선과 같은 계산)
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
			sfx("pickup", -9.0, 0.6 + 0.07 * dm)
			msg(tr(P.name), 0.8)
	if dm >= 0:
		passed[dm] = true
	up = p.normalized()
	r = p.length()
	air_t -= dt
	if air_t <= 0.0:
		air_t = 0.3
	if kit_just("jump") and not airjump:
		airjump = true
		if has_sail and kit_move.length() > 0.3:
			# 돛: 속도는 그대로, 비행 방향만 스틱 쪽(화면 기준)으로 튼다
			var bs := cam.global_transform.basis
			var sd := (bs.x * kit_move.x - bs.y * kit_move.y).normalized()
			var sp := maxf(vel.length(), 3.0)
			var vd := vel.normalized() if vel.length() > 0.1 else up
			vel = (vd + sd * 0.7).normalized() * sp
			sfx("sail")
			_emit("sail")
		else:
			vel += up * AIRJUMP
			sfx("liftoff", -4.0, 1.25)
	# 위험: 불 별, 바위 띠, 떠내려감
	if P.kind == "fire" and r <= R + 0.4:
		_die("fire")
		return true
	if _in_belt(w):
		_die("rocks")
		return true
	if dm < 0:
		var far := (w - MID).length()
		if far > BOUND:
			warn_t -= dt
			if warn_t <= 0.0:
				warn_t = 0.35
				sfx("drift_warn")
				_emit("drift_warn")
				msg(_tx("msg.drift_warn"), 0.5)
				if not drift_said:
					drift_said = true
					_react("drift_warning")
			if far > BOUND + 10.0:
				_die("drift")
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
	sfx("land_hard" if hit > 4.0 else "land", -2.0 + clampf(hit, 0.0, 6.0))
	_emit("land", {"hard": hit > 4.0, "speed": hit})
	if item != "" and bool((JOB[mi] as Dictionary).get("frag", false)):
		var c := clampf((hit - 3.0) / 4.0, 0.0, 1.0)
		if c > 0.0:
			crack += c
			sfx("crack", 3.0)
			_emit("crack")
			_react("flower_cracked")
	if rings.has(cur):
		ring_in = up.angle_to(rings[cur].c) * R < float(rings[cur].r)
	home_b = cur
	home_d = up
	if cur != from_b:
		var sling := false
		for k in passed:
			if k != cur and k != from_b:
				sling = true
		var rk := ""
		var mp := bc[cur] + p
		if sling:
			score += 3
			sfx("slingshot")
			_emit("slingshot")
			_emit("score", {"n": 3, "pos": mp})
			rk = "slingshot"
		elif atm_t > 1.2 and hit < 3.0:
			rk = "orbit_landing"
			_emit("orbit_land")
		if not visited.has(cur):
			visited[cur] = true
			score += 5
			if lives < 3:
				lives = 3
				_hearts_show(-1)  # 새 별: 목숨이 차는 걸 잠깐 보여 준다
			sfx("deliver", -6.0, 1.25)
			_emit("new_planet", {"k": cur})
			_emit("score", {"n": 5, "pos": mp + p.normalized() * 1.5})
			msg(tr(P.name), 1.6)
			if rk == "":
				rk = "new_planet" if said.has("first_landing") else "first_landing"
		if rk != "":
			_react(rk, rk == "first_landing")


## 땅 위 부딪힘: 담(막힘, 틈만 통과). v6: 풍차의 별 바위는 없앴다
func _collide(up: Vector3) -> void:
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
					sfx("land", -4.0, 1.5)
					msg(_tx("msg.wall_gap") if rg.gap else _tx("msg.wall_high"), 0.7)
	else:
		ring_in = d < rr


## 탈출선 대비 에너지: 땅에선 "지금 점프하면", 날 땐 지금 (0 = 땅, 1 = 탈출)
func _esc_frac(up: Vector3) -> float:
	if cur >= bsoi.size():
		return 0.0
	var r := maxf(p.length(), R)
	var v := vel + up * JUMP if grounded else vel
	var e := 0.5 * v.length_squared() - mu / r
	var e0 := -mu / R
	var e1 := -mu / bsoi[cur]
	return (e - e0) / maxf(e1 - e0, 0.01)


## 막대에 보이는 값: 땅에선 "지금 점프하면" 을 탈출 도움 문턱(_esc_need) 대비로, 날 땐 탈출선 대비 그대로
func _esc_show(up: Vector3) -> float:
	var f := _esc_frac(up)
	return f / _esc_need() if grounded else f


## 막대: 노랑(강조색), 땅에서 차면 = 지금 뛰면 떠난다 → 초록. 날 때 탈출선 위면 민트
func _gauge_now(up: Vector3) -> void:
	var f := _esc_show(up)
	if grounded:
		gauge(f, Color("37b24d") if f >= 1.0 else Color("ffd166"))
	else:
		gauge(f, Color("8fe3c2") if f >= 1.0 else Color("ffd166"))


## tofu 의 네모 막대 대신 캡슐 막대 (tofu 막대는 늘 숨김)
func gauge(frac: float, color: Color) -> void:
	_bar_bg.visible = false
	if gauge_bg == null:
		return
	gauge_bg.visible = true
	var iw := 600.0 - 16.0
	var fw := iw * clampf(frac, 0.0, 1.0)
	gauge_fill.visible = fw > 2.0
	gauge_fill.size.x = maxf(fw, 24.0)
	if color != _g_col:
		_g_col = color
		gauge_sb.bg_color = color


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
		_set_item(ig_b, str(J.item), 0.0)
		_set_item(item_b, str(J.item), 0.0)
		_item_key = str(J.item)
		_item_q = 0.0
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
		_orient(ig_b, bc[fall_pl] + fall_dir * (br[fall_pl] + 0.05 + maxf(fall_h, 0.0)), fall_dir, Vector3.ONE * 1.4)
		if fall_h <= 0.0:
			fall_on = false
			_item_landed()
	elif ig_on:
		_orient(ig_b, bc[ig_pl] + ig_dir * (br[ig_pl] + 0.3 + sin(clock * 3.0) * 0.12), ig_dir, Vector3.ONE * 1.4)
		ig_b.rotate_object_local(Vector3.UP, clock * 1.5)
		if item == "" and grounded and cur == ig_pl and pick_cd <= 0.0 and p.distance_to(ig_dir * R) < 1.5:
			item = J.item
			ig_on = false
			ig_b.visible = false
			item_b.visible = true
			if req == 0:
				req = 1
				_emit("job_start", {"job": mi})
			sfx("pickup")
			_emit("pickup", {"item": item})
			msg(_tx("msg.picked", {"target": tr(BD[int(J.tgt)].name)}), 1.2)
			_drop_btn(true)
	if item != "":
		var q := floorf(clampf(crack, 0.0, 1.0) * 8.0) / 8.0
		if item != _item_key or q != _item_q:  # v6: 바뀔 때만 (매 프레임 재질 이름 글자를 만들지 않게)
			_item_key = item
			_item_q = q
			_set_item(item_b, item, q)
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
		_orient(mark_b, up * (_sr(cur, up) + 0.2), up, Vector3(1.0, 0.15, 1.0))


func _drop_btn(on: bool) -> void:
	if on:
		kit_button("drop", _tx("ui.drop"), Vector2(580, 860), 90.0, B)
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
	sfx("drop")
	_emit("drop")


func _item_landed() -> void:
	sfx("land", -6.0, 1.4)
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
	msg(_tx("msg.missed_drop"), 1.0)


func _break() -> void:
	# 깨진 자리: 떨어뜨린 물건이면 그 물건, 들고 있던 것이면 내 머리 위
	var bp: Vector3 = ig_b.global_position if ig_b.visible else bc[cur] + p + p.normalized() * 1.5
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
	msg(_tx("msg.glass_broken", {"src": tr(BD[int(J.src)].name)}), 1.6)
	sfx("shatter", 3.0)
	_emit("shatter", {"pos": bp})
	_react("flower_broken")


## 물건이 닿을 곳에 닿았다
func _deliver() -> void:
	var J: Dictionary = JOB[mi]
	var tgt_k := int(J.tgt)
	var tg: Vector3 = (J.tdir as Vector3).normalized()
	item = ""
	item_b.visible = false
	ig_on = false
	fall_on = false
	ig_b.visible = false
	# 닿은 물건: 소포는 굴뚝 집 지붕, 유리꽃은 친구 머리 위, 덮개는 장미를 덮는다.
	# ig_b 는 다음 부탁이 다시 쓰므로, 놓인 물건은 따로 세워 둔다 (world 가 다시 지어질 때 함께 지워진다)
	var hh := 2.35 if mi == 1 else (2.1 if mi == 2 else -0.05)
	var put := _art(str(ITEM_ART.get(str(J.item), "parcel")), Callable())
	_orient(put, bc[tgt_k] + tg * (_sr(tgt_k, tg) + hh), tg, Vector3.ONE * (2.2 if mi == 4 else 1.3))
	_drop_btn(false)
	_emit("deliver", {"job": mi, "pos": put.global_position})
	_done()


func _done() -> void:
	var k := mi
	req = 2
	prog = 1.0
	score += 10
	play("win")
	shake = 0.2
	_emit("job_done", {"job": k})
	_emit("score", {"n": 10, "pos": bc[cur] + p + p.normalized() * 2.0})
	var gv: Dictionary = BD[k]
	bub_q.clear()
	if k == 1:
		_say(BD[5].who, _tx("moon.chimney.got"), 3.5)
		_sayq(gv.who, _line(k, "thanks"), 6.0)
	elif k == 2:
		_say(BD[6].who, _tx("moon.friend.got"), 3.5)
		_sayq(gv.who, _line(k, "thanks"), 6.0)
	else:
		_say(gv.who, _line(k, "thanks"), 6.0)
	if DL.has(str(gv.id) + ".thanks2"):
		_sayq(gv.who, _line(k, "thanks2"), 7.0)
	if k == 0:
		sfx("windmill_wake")
		_emit("windmill_wake")
		has_sail = true
		sail_b.visible = true
		_lane()
	elif k == 1:
		bag_b.visible = true
	if k >= 4:
		# 끝: 장미의 고마움 → 나의 혼잣말 넷, 카메라가 천천히 물러나 별들이 다 보인다
		won = true
		fin_t = 18.0
		msg(_tx("msg.rose_smiles"), 3.0)
		sfx("win")
		_emit("finish")
		for i in 4:
			_sayq(_tx("who.me"), _tx("ending.%d" % (i + 1)), 2.8)
		return
	mi = k + 1
	req = 1 if mi == 4 else 0
	_start_job(mi)
	if req == 1:
		_emit("job_start", {"job": mi})
	msg(_tx("msg.next", {"planet": tr(BD[mi].name)}), 1.8)


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
				_emit("job_start", {"job": mi})
				_say(P.who, _line(cur, "ask"), 6.0)
				if mi == 0 or mi == 3:
					nag[300 + mi] = clock + 40.0
					_sayq(P.who, _line(cur, "hint"), 4.0)
			elif mi == 4 and not rose_said:
				rose_said = true
				_say(P.who, _line(cur, "ask"), 6.0)
	# 풍차 바람: 이륙선 80% 이상으로 땅에 붙어 달린 시간
	if mi == 0 and req == 1 and cur == 0:
		var on_ := grounded and lf >= 0.8
		prog = clampf(prog + (dt / 12.0 if on_ else -0.03 * dt), 0.0, 1.0)
		if on_:
			wind_t -= dt
			if wind_t <= 0.0:
				wind_t = 0.35
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
	# v6: 띠가 움직일 때만 다시 놓고(각진 면 거리 계산이 무겁다), 색은 바뀔 때만
	if band_a != _band_last:
		_band_last = band_a
		for j in band_bs.size():
			var l := -0.4 + 0.2 * j
			var d := Vector3(cos(band_a) * cos(l), sin(l), -sin(band_a) * cos(l))
			_orient(band_bs[j], d * (_sr(3, d) + 0.2), d, Vector3(2.2, 0.25, 1.6))
	if inb != _band_on:
		_band_on = inb
		for bb in band_bs:
			bb.material_override = _pm(D if inb else A)
	if mi == 3 and req == 1 and cur == 3:
		prog = clampf(prog + (dt / 14.0 if inb else -0.04 * dt), 0.0, 1.0)
		if inb:
			wind_t -= dt
			if wind_t <= 0.0:
				wind_t = 0.4
				sfx("ui_tap", -9.0, 1.0 + prog)
		if prog >= 1.0:
			_done()
	# 장미 별의 도는 담
	gap_a += 0.8 * dt
	_place_walls(4)
	# 갈 곳 빛기둥 (다른 별 위에서도 보이게 길게)
	_obj()
	beacon.visible = ob_k >= 0 and fin_t <= 0.0
	if beacon.visible:
		_orient(beacon, bc[ob_k] + ob_d * (br[ob_k] + 7.0), ob_d, Vector3(0.6, 14.0, 0.6))


## 갈 곳: ob_k(별 번호, 없으면 -1)·ob_d(방향). v6: 매 프레임 새 배열을 만들지 않게 멤버에 쓴다
func _obj() -> void:
	ob_k = -1
	var J: Dictionary = JOB[mi]
	if req == 0 and mi <= 3:
		ob_k = mi
		ob_d = NPC_D.normalized()
	elif J.has("item"):
		if item != "":
			ob_k = int(J.tgt)
			ob_d = (J.tdir as Vector3).normalized()
		elif ig_on:
			ob_k = ig_pl
			ob_d = ig_dir
	elif mi == 3:
		ob_k = 3
		ob_d = Vector3(cos(band_a), 0, -sin(band_a))


## 말풍선과 부탁 막대. v6: 늘 떠 있는 말 없음 — 상황 말은 한 번씩, 같은 말은 한참 쉬었다가 (_nag)
func _hud(dt: float) -> void:
	bub_t -= dt
	if bub_t <= 0.0 and not bub_q.is_empty():
		var q: Array = bub_q.pop_front()
		_say(str(q[0]), str(q[1]), float(q[2]))
	if bub_t <= 0.0 and die_t <= 0.0 and fin_t <= 0.0:
		_situation()
	_bub_anim(dt)
	var show := false
	if req == 1 and (mi == 0 or mi == 3):
		show = true
		_pbar_set(Color("ffd166"), prog)
	elif item != "" and bool((JOB[mi] as Dictionary).get("frag", false)):
		show = true
		_pbar_set(DANGER, clampf(crack, 0.0, 1.0))
	pbar_bg.visible = show


func _pbar_set(col: Color, f: float) -> void:
	pbar.visible = f > 0.01
	pbar.size.x = maxf(492.0 * f, 12.0)
	if pbar_sb.bg_color != col:
		pbar_sb.bg_color = col


## 지금 할 만한 말 하나 (번호 = 종류*100 + 별·부탁). 끝낸 주민의 혼잣말은 드물게(60초), 안내는 40초에 한 번까지
func _situation() -> void:
	var near := grounded and cur <= 4 and npcs.has(cur) and p.distance_to((npcs[cur] as Node3D).position) < 6.0
	if near:
		if cur < mi:
			if cur != mi - 1 and _can(100 + cur):
				_nag(100 + cur, 60.0, P.who, _line(cur, "idle1" if randf() < 0.5 else "idle2"))
			return
		if cur > mi:
			if _can(200 + cur):
				_nag(200 + cur, 40.0, P.who, _line(cur, "ask"))
			return
	# 글자는 쉬는 시간이 끝났을 때만 만든다 (매 프레임 글자·사전을 만들지 않게)
	if req == 1 and (mi == 0 or mi == 3) and cur == mi and prog < 0.15:
		if _can(300 + mi):
			_nag(300 + mi, 40.0, BD[mi].who, _line(mi, "hint"))
	elif item != "" and mi == 4:
		if _can(400):
			_nag(400, 45.0, BD[3].who, _line(3, "thanks2"))  # 불 별 새총 안내
	elif item != "":
		if _can(500 + mi):
			_nag(500 + mi, 45.0, BD[mi].who, _line(mi, "hint"))
	elif grounded and ob_k >= 0 and ob_k != cur:
		if _can(600 + mi * 10 + cur):
			_nag(600 + mi * 10 + cur, 50.0, "", _tx("hud.next_hint", {"planet": tr(BD[ob_k].name)}))


func _can(id: int) -> bool:
	return clock >= float(nag.get(id, -1.0))


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	lives -= 1
	_hearts_show(lives)  # v6: 잃은 하트가 줄어들며 사라지는 걸 2초 보여 준다
	die_t = 1.3
	shake = 0.4
	play("bad")
	_emit("die", {"why": why})
	msg(_tx("die." + why), 1.2)
	_react("die_" + why, false, true)
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
	_dots_off()


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
				sfx("meteor_warn")
				_emit("meteor_warn", {"pos": bc[cur] + d * R})
				break
	for i in NM:
		if mph[i] == 0:
			continue
		var d := mdir[i]
		mt[i] -= dt
		if mph[i] == 1:
			var pulse := 0.8 + 0.2 * sin(clock * 12.0)
			_orient(msh[i], d * (_sr(cur, d) + 0.22), d, Vector3(4.4 * pulse, 0.3, 4.4 * pulse))
			if fmod(mt[i], 0.4) < dt:
				sfx("ui_tap", -14.0, 0.7)
			if mt[i] <= 0.0:
				mph[i] = 2
				mt[i] = 1.1
				mb[i].visible = true
		else:
			var alt := maxf(mt[i], 0.0) / 1.1 * 22.0
			_orient(mb[i], d * (R + alt), d, Vector3.ONE * 1.3)
			mb[i].rotate(d, clock * 5.0)
			if mt[i] <= 0.0:
				mph[i] = 0
				mb[i].visible = false
				msh[i].visible = false
				shake = 0.3
				sfx("meteor_hit")
				_emit("meteor_hit", {"pos": bc[cur] + d * R})
				if p.distance_to(d * R) < 2.2:
					_die("meteor")


func _place_me() -> void:
	var up := p.normalized()
	var f := _flat(fwd, up)
	var x := up.cross(-f).normalized()
	# 발을 각진 땅 면 위에 (날 때는 땅 아래로 안 묻히게만)
	var sr := _srn(cur, up)
	var h := sr if grounded else maxf(p.length(), sr)
	me.transform = Transform3D(Basis(x, up, -f), bc[cur] + up * h)
	# v6 그림자: 발밑 별의 각진 면 위에 (면 방향으로 눕힌다), 높이 뜰수록 작고 옅게, 10 넘게 뜨면 없음
	if shadow_me:
		var alt := h - sr
		shadow_me.visible = alt < 10.0 and bfire[cur] == 0
		if shadow_me.visible:
			var k := clampf(alt / 10.0, 0.0, 1.0)
			var s := lerpf(1.3, 0.5, k)
			var n := _sf_n
			var bs := _basis(n)
			shadow_me.transform = Transform3D(Basis(bs.x * s, bs.y, bs.z * s), bc[cur] + up * sr + n * 0.04)
			shadow_me.transparency = k * 0.85


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
	if fin_t > 0.0:
		dist += (18.0 - fin_t) * 1.4  # 끝: 천천히 물러나 별들이 보인다
	var want := pw + upp * (3.2 + alt * 0.2) - lookd * dist
	if shake > 0.0:
		shake -= dt
		want += Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * shake * 1.2
	cam.position = cam.position.lerp(want, minf(1.0, dt * 5.0))
	var look := pw + upp * 1.0 + lookd * 3.0
	if cam.position.distance_to(look) > 0.1:
		cam.look_at(look, upp)
	# cam.fov·h_offset·v_offset 는 fx 몫 (속도·탈출 장면에 따라 넓힌다)


# ---- v5 겉모습: 움직임 ----
## 매 프레임 겉모습만 (규칙·수치는 안 건드린다): 달리기 끄덕임, 돛 펴기, 하트·"!" 돌기, 불 별 돌기, 바람 소리
func _vis(dt: float) -> void:
	react_cd -= dt
	if me_body == null:
		return
	var spd := vel.length()
	var k := clampf(spd / TOP, 0.0, 1.0)
	if grounded:
		step_ph += spd * dt * 1.15
		me_body.position.y = absf(sin(step_ph)) * 0.14 * minf(1.0, spd / 3.0)
		me_body.rotation = Vector3(-0.32 * k, 0.0, sin(step_ph) * 0.07 * k)
		sail_b.scale = sail_b.scale.lerp(Vector3.ONE * 0.7, minf(1.0, dt * 6.0))
	else:
		me_body.position.y = lerpf(me_body.position.y, 0.0, minf(1.0, dt * 6.0))
		me_body.rotation = me_body.rotation.lerp(Vector3(-0.55, 0.0, 0.0), minf(1.0, dt * 4.0))
		sail_b.scale = sail_b.scale.lerp(Vector3.ONE * 1.35, minf(1.0, dt * 5.0))
	_hearts_anim(dt)
	for mk in marks:
		(marks[mk] as MeshInstance3D).rotation.y = clock * 2.5
	if spin:
		spin.rotate_y(dt * 0.5)
	# 바람: 풍차 부탁 중 힘껏 달리면 크게, 날 때는 빠르기만큼
	var want := -60.0
	if die_t <= 0.0 and fin_t <= 0.0:
		if mi == 0 and req == 1 and cur == 0 and grounded:
			want = lerpf(-30.0, -4.0, clampf((k - 0.4) / 0.6, 0.0, 1.0))
		elif not grounded:
			want = lerpf(-30.0, -10.0, clampf(spd / 16.0, 0.0, 1.0))
	wind_v = move_toward(wind_v, want, dt * 60.0)
	if wind_pl.stream:
		if wind_v > -45.0 and not wind_pl.playing:
			wind_pl.play()
		elif wind_v <= -45.0 and wind_pl.playing:
			wind_pl.stop()
		wind_pl.volume_db = wind_v
		wind_pl.pitch_scale = 0.9 + 0.3 * k


## 든 물건 모델 바꾸기 (금 간 정도 q 만큼 빨개진다)
func _set_item(m: MeshInstance3D, kind: String, q: float) -> void:
	var nm: String = ITEM_ART.get(kind, "parcel")
	var e := _art_entry(nm, Callable())
	m.mesh = e[0]
	m.material_override = _art_mat(nm, WHITE.lerp(DANGER, q) if q > 0.0 else Color.WHITE)


## 하트를 HEART_T 초 보여 준다. lost = 방금 잃은 하트 번호 (줄어들며 사라짐), -1 이면 남은 것만 톡 튀어나옴
func _hearts_show(lost: int) -> void:
	heart_t = HEART_T
	heart_lost = lost


func _hearts_anim(dt: float) -> void:
	if heart_t <= 0.0:
		return
	heart_t -= dt
	var age := HEART_T - heart_t
	var out := clampf(heart_t / 0.3, 0.0, 1.0)  # 끝 0.3초에 다 같이 작아진다
	for i in hearts.size():
		var h := hearts[i]
		var sc := 0.0
		if i < lives:
			sc = _bo(clampf((age - i * 0.06) / 0.25, 0.0, 1.0)) * out
		elif i == heart_lost:
			# 크게 튀었다가 0.7초에 걸쳐 줄어 사라진다
			sc = (1.0 + 0.35 * sin(clampf(age / 0.2, 0.0, 1.0) * PI)) * (1.0 - clampf((age - 0.2) / 0.7, 0.0, 1.0))
		h.visible = sc > 0.02 and heart_t > 0.0
		h.scale = Vector3.ONE * maxf(sc, 0.02)
		h.rotation.y = clock * 2.0


## _sr 과 같고, 찾은 면의 방향을 _sf_n 에 남긴다 (그림자를 면에 눕힐 때)
func _srn(k: int, d: Vector3) -> float:
	_sf_n = d
	if k >= fnorm.size():
		return br[k]
	var nr: PackedVector3Array = fnorm[k]
	var ds: PackedFloat32Array = fdist[k]
	var best := 1e9
	for i in nr.size():
		var c := nr[i].dot(d)
		if c > 0.5:
			var v := ds[i] / c
			if v < best:
				best = v
				_sf_n = nr[i]
	return best if best < 1e8 else br[k]


## 움직이지 않는 그림자 하나를 모은다 (별 k 의 d 방향 땅 위, 반지름 rad). _build 끝에 한 메시로 합친다
func _shadow_q(k: int, d: Vector3, rad: float) -> void:
	d = d.normalized()
	var sr := _srn(k, d)
	var n := _sf_n
	var c := bc[k] + d * sr + n * 0.035
	var x := n.cross(Vector3.FORWARD if absf(n.z) < 0.9 else Vector3.RIGHT).normalized() * rad
	var z := n.cross(x)
	var i0 := _shv.size()
	_shv.append(c - x - z)
	_shv.append(c + x - z)
	_shv.append(c + x + z)
	_shv.append(c - x + z)
	_shu.append(Vector2(0, 0))
	_shu.append(Vector2(1, 0))
	_shu.append(Vector2(1, 1))
	_shu.append(Vector2(0, 1))
	for j: int in [0, 1, 2, 0, 2, 3]:
		_shi.append(i0 + j)


## 그림자 재질: 가운데 잉크 35% → 가장자리 0 (둥근 그라데이션), 빛 없음, 양면
func _shadow_mat() -> StandardMaterial3D:
	if _mats3.has("shadow"):
		return _mats3["shadow"]
	var g := Gradient.new()
	g.set_color(0, Color(NAVY, 0.36))
	g.set_color(1, Color(NAVY, 0.0))
	g.add_point(0.6, Color(NAVY, 0.24))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 64
	gt.height = 64
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.albedo_texture = gt
	sm.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mats3["shadow"] = sm
	return sm


## 별 k 의 각진 겉면까지 거리 (d 방향, 정규화). 볼록 다면체라 면마다 거리/cos 중 가장 작은 것
func _sr(k: int, d: Vector3) -> float:
	if k >= fnorm.size():
		return br[k]
	var nr: PackedVector3Array = fnorm[k]
	var ds: PackedFloat32Array = fdist[k]
	var best := 1e9
	for i in nr.size():
		var c := nr[i].dot(d)
		if c > 0.5:
			best = minf(best, ds[i] / c)
	return best if best < 1e8 else br[k]


# ---- 그림 모델 (art/tinyplanet/<이름>.glb + png) 또는 로우폴리 대신 모델 ----
var _am := {}  # 이름 -> [Mesh, 그림인가, 가운데]
var _mats3 := {}  # 재질 캐시
var _ols := {}  # 가운데별 외곽선 재질
static var OL_SH: Shader


## 이름의 모델 하나를 세운다. 그림 파일이 있으면 그림, 없으면 fb(비면 _shape_<이름>)로 만든 로우폴리
func _art(nm: String, fb: Callable, parent: Node3D = null, tint := Color.WHITE) -> MeshInstance3D:
	var e := _art_entry(nm, fb)
	var m := MeshInstance3D.new()
	m.mesh = e[0]
	m.material_override = _art_mat(nm, tint)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	(parent if parent else world).add_child(m)
	return m


func _proc(nm: String, fb: Callable, parent: Node3D = null, tint := Color.WHITE) -> MeshInstance3D:
	return _art(nm, fb, parent, tint)


func _art_entry(nm: String, fb: Callable) -> Array:
	if _am.has(nm):
		return _am[nm]
	var mesh: Mesh = _art_file_mesh(nm)
	var is_art := mesh != null
	if mesh == null:
		var cb := fb if fb.is_valid() else Callable(self, "_shape_" + nm)
		_begin()
		if cb.is_valid():
			cb.call()
		else:
			_dia(Vector3(0, 0.3, 0), 0.3, 0.3, WHITE, Vector3.UP)
		mesh = _end_mesh()
	_am[nm] = [mesh, is_art, mesh.get_aabb().get_center()]
	return _am[nm]


## 그림 모델 메시 (파일 없으면 null)
func _art_file_mesh(nm: String) -> Mesh:
	var glb_path := ART + nm + ".glb"
	if not ResourceLoader.exists(glb_path) or not ResourceLoader.exists(ART + nm + ".png"):
		return null
	var sc := load(glb_path) as PackedScene
	if sc == null:
		return null
	var inst := sc.instantiate()
	# 부품(머리·몸·팔·다리…)이 여럿인 모델도 있어 전부 제자리 그대로 한 메시로 합친다
	var st := SurfaceTool.new()
	var n := _merge_meshes(inst, Transform3D.IDENTITY, st)
	inst.free()
	if n == 0:
		return null
	return st.commit()


func _merge_meshes(node: Node, xf: Transform3D, st: SurfaceTool) -> int:
	var here_xf := xf
	if node is Node3D:
		here_xf = xf * (node as Node3D).transform
	var n := 0
	if node is MeshInstance3D and (node as MeshInstance3D).mesh:
		var mesh: Mesh = (node as MeshInstance3D).mesh
		for s in mesh.get_surface_count():
			st.append_from(mesh, s, here_xf)
			n += 1
	for ch in node.get_children():
		n += _merge_meshes(ch, here_xf, st)
	return n


## 모델 재질: 그림이면 칠한 그림(빛 없음, 밉맵), 아니면 꼭짓점 색(약한 빛). 둘 다 진한 외곽선.
func _art_mat(nm: String, tint: Color) -> Material:
	var key := nm + "|" + tint.to_html()
	if _mats3.has(key):
		return _mats3[key]
	var e: Array = _am[nm]
	var sm := StandardMaterial3D.new()
	sm.albedo_color = tint
	sm.roughness = 1.0
	if bool(e[1]):
		sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm.albedo_texture = _tex(nm)
		sm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	else:
		sm.vertex_color_use_as_albedo = true
		sm.vertex_color_is_srgb = true
	sm.next_pass = _ol(e[2])
	_mats3[key] = sm
	return sm


var _texs := {}


## 그림 텍스처에 밉맵을 붙여 멀리서도 지글거리지 않게
func _tex(nm: String) -> Texture2D:
	if _texs.has(nm):
		return _texs[nm]
	var tx := load(ART + nm + ".png") as Texture2D
	if tx:
		var img := tx.get_image()
		if img:
			if img.is_compressed():
				img.decompress()
			img.generate_mipmaps()
			tx = ImageTexture.create_from_image(img)
	_texs[nm] = tx
	return tx


## 가운데 기준 단위 모양 (육각 판·원판·보석·점) + 단색 재질. _orient 로 크기를 준다.
func _ushape(nm: String, col: Color, parent: Node3D = null) -> MeshInstance3D:
	var e := _art_entry("u_" + nm, Callable(self, "_shape_u_" + nm))
	var m := MeshInstance3D.new()
	m.mesh = e[0]
	m.material_override = _pm(col)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	(parent if parent else world).add_child(m)
	return m


## 단색 재질 (가운데가 원점인 모양용 외곽선)
func _pm(col: Color) -> StandardMaterial3D:
	var key := "pm|" + col.to_html()
	if not _mats3.has(key):
		var sm := StandardMaterial3D.new()
		sm.albedo_color = col
		sm.roughness = 1.0
		sm.next_pass = _ol(Vector3.ZERO)
		_mats3[key] = sm
	return _mats3[key]


## 꼭짓점 색 재질 (lit = 약한 빛, 아니면 빛 없음). 외곽선 없음(합친 장식은 외곽선을 구워 넣는다)
func _vc(lit: bool) -> StandardMaterial3D:
	var key := "vc|%s" % lit
	if not _mats3.has(key):
		var sm := StandardMaterial3D.new()
		sm.vertex_color_use_as_albedo = true
		sm.vertex_color_is_srgb = true
		sm.roughness = 1.0
		if not lit:
			sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_mats3[key] = sm
	return _mats3[key]


## 진한 남색 외곽선: 모델 가운데(ctr)에서 바깥으로 조금 부풀린 뒷면. 멀수록 두꺼워 화면 굵기가 비슷하다.
func _ol(ctr: Vector3) -> ShaderMaterial:
	var key := "%.2f,%.2f,%.2f" % [ctr.x, ctr.y, ctr.z]
	if _ols.has(key):
		return _ols[key]
	if OL_SH == null:
		OL_SH = Shader.new()
		OL_SH.code = """
shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;
uniform vec4 ink : source_color = vec4(0.169, 0.176, 0.259, 1.0);
uniform vec3 ctr = vec3(0.0);
void vertex() {
	vec3 sc = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float d = distance(wp, (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz);
	float th = clamp(d * 0.006, 0.015, 0.6);
	vec3 dv = (VERTEX - ctr) * sc;
	float l = length(dv);
	if (l > 0.0001) {
		VERTEX += dv / l * th / max(sc, vec3(0.0001));
	}
}
void fragment() {
	ALBEDO = ink.rgb;
}
"""
	var m := ShaderMaterial.new()
	m.shader = OL_SH
	m.set_shader_parameter("ctr", ctr)
	_ols[key] = m
	return m


func _ink() -> StandardMaterial3D:
	if not _mats3.has("ink"):
		var sm := StandardMaterial3D.new()
		sm.albedo_color = NAVY
		sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_mats3["ink"] = sm
	return _mats3["ink"]


# ---- 로우폴리 메시 도구: 삼각형을 모았다가 한 메시로 (면마다 평평한 빛) ----
var _tv := PackedVector3Array()  # 삼각형 꼭짓점 (그려지는 순서, 3개씩)
var _tc := PackedColorArray()
var _hv := PackedVector3Array()  # 구워 넣은 외곽선 껍질
var _icos := {}


func _begin() -> void:
	_tv = PackedVector3Array()
	_tc = PackedColorArray()
	_hv = PackedVector3Array()


## 삼각형 하나. out 쪽이 겉. (Godot 은 시계 방향이 앞면이라 a, c, b 로 넣는다)
func _tri(a: Vector3, b: Vector3, c: Vector3, col: Color, out: Vector3) -> void:
	var n := (b - a).cross(c - a)
	if n.dot(out) < 0.0:
		var tmp := b
		b = c
		c = tmp
	_tv.append(a)
	_tv.append(c)
	_tv.append(b)
	_tc.append(col)
	_tc.append(col)
	_tc.append(col)


func _end_mesh() -> ArrayMesh:
	var am := ArrayMesh.new()
	if _tv.size() > 0:
		var nn := PackedVector3Array()
		nn.resize(_tv.size())
		for i in range(0, _tv.size(), 3):
			var n := (_tv[i + 2] - _tv[i]).cross(_tv[i + 1] - _tv[i]).normalized()
			nn[i] = n
			nn[i + 1] = n
			nn[i + 2] = n
		var arr := []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = _tv
		arr[Mesh.ARRAY_NORMAL] = nn
		arr[Mesh.ARRAY_COLOR] = _tc
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	if _hv.size() > 0:
		var arr2 := []
		arr2.resize(Mesh.ARRAY_MAX)
		arr2[Mesh.ARRAY_VERTEX] = _hv
		am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr2)
		am.surface_set_material(am.get_surface_count() - 1, _ink())
	_begin()
	return am


## from 부터 모은 삼각형을 xf 로 옮긴다
func _xf(from: int, xf: Transform3D) -> void:
	for i in range(from, _tv.size()):
		_tv[i] = xf * _tv[i]


## from 부터 모은 삼각형의 외곽선 껍질을 굽는다 (ctr 에서 th 만큼 부풀리고 뒤집는다)
func _hull(from: int, ctr: Vector3, th: float) -> void:
	for i in range(from, _tv.size(), 3):
		var a := _tv[i]
		var b := _tv[i + 1]
		var c := _tv[i + 2]
		_hv.append(a + (a - ctr).normalized() * th)
		_hv.append(c + (c - ctr).normalized() * th)
		_hv.append(b + (b - ctr).normalized() * th)


## 그림 메시의 외곽선 껍질을 굽는다
func _hull_mesh(mesh: Mesh, xf: Transform3D, th: float) -> void:
	var arr := mesh.surface_get_arrays(0)
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var ix: PackedInt32Array = PackedInt32Array()
	if arr[Mesh.ARRAY_INDEX] != null:
		ix = arr[Mesh.ARRAY_INDEX]
	var ctr := xf * mesh.get_aabb().get_center()
	var cnt := ix.size() if ix.size() > 0 else vs.size()
	for i in range(0, cnt - 2, 3):
		var i0 := ix[i] if ix.size() > 0 else i
		var i1 := ix[i + 1] if ix.size() > 0 else i + 1
		var i2 := ix[i + 2] if ix.size() > 0 else i + 2
		var a := xf * vs[i0]
		var b := xf * vs[i1]
		var c := xf * vs[i2]
		_hv.append(a + (a - ctr).normalized() * th)
		_hv.append(c + (c - ctr).normalized() * th)
		_hv.append(b + (b - ctr).normalized() * th)


## 기둥·뿔·각기둥: 바닥 가운데 at, 축 ax, 바닥 반지름 r0, 위 반지름 r1(0 이면 뿔), 높이 h, 면 n 개
func _cyl(at: Vector3, ax: Vector3, r0: float, r1: float, h: float, n: int, cs: Color, ct: Color, rot := 0.0) -> void:
	ax = ax.normalized()
	var u := ax.cross(Vector3.FORWARD if absf(ax.z) < 0.9 else Vector3.RIGHT).normalized()
	var w := ax.cross(u)
	var top := at + ax * h
	var mid := at + ax * h * 0.5
	for i in n:
		var a0 := rot + TAU * i / n
		var a1 := rot + TAU * (i + 1) / n
		var d0 := u * cos(a0) + w * sin(a0)
		var d1 := u * cos(a1) + w * sin(a1)
		var p0 := at + d0 * r0
		var p1 := at + d1 * r0
		var q0 := top + d0 * r1
		var q1 := top + d1 * r1
		var cs2 := cs if i % 2 == 0 else cs.darkened(0.05)
		var out := (p0 + p1 + q0 + q1) * 0.25 - mid
		if r1 <= 0.001:
			_tri(p0, p1, top, cs2, out)
		else:
			_tri(p0, p1, q1, cs2, out)
			_tri(p0, q1, q0, cs2, out)
			_tri(top, q0, q1, ct, ax)
		if r0 > 0.001:
			_tri(at, p1, p0, cs.darkened(0.15), -ax)


## 마름모(팔면체): 가운데 c, 옆 반지름 rx, 위아래 반지름 ry, 축 up
func _dia(c: Vector3, rx: float, ry: float, col: Color, up: Vector3, rot := 0.0) -> void:
	up = up.normalized()
	var u := up.cross(Vector3.FORWARD if absf(up.z) < 0.9 else Vector3.RIGHT).normalized()
	var w := up.cross(u)
	var tp := c + up * ry
	var b := c - up * ry
	for i in 4:
		var a0 := rot + TAU * i / 4.0
		var a1 := rot + TAU * (i + 1) / 4.0
		var p0 := c + (u * cos(a0) + w * sin(a0)) * rx
		var p1 := c + (u * cos(a1) + w * sin(a1)) * rx
		_tri(p0, p1, tp, col.lightened(0.06) if i % 2 == 0 else col, (p0 + p1 + tp) / 3.0 - c)
		_tri(p0, p1, b, col.darkened(0.08), (p0 + p1 + b) / 3.0 - c)


## 각진 공(icosphere) 면들 (단위 공 위, 분할 sub 번)
func _ico_faces(sub: int) -> Array:
	if _icos.has(sub):
		return _icos[sub]
	var g := (1.0 + sqrt(5.0)) / 2.0
	var v := [Vector3(-1, g, 0), Vector3(1, g, 0), Vector3(-1, -g, 0), Vector3(1, -g, 0),
		Vector3(0, -1, g), Vector3(0, 1, g), Vector3(0, -1, -g), Vector3(0, 1, -g),
		Vector3(g, 0, -1), Vector3(g, 0, 1), Vector3(-g, 0, -1), Vector3(-g, 0, 1)]
	var f := [[0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11], [1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
		[3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9], [4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1]]
	var tris: Array = []
	for fc: Array in f:
		tris.append([(v[fc[0]] as Vector3).normalized(), (v[fc[1]] as Vector3).normalized(), (v[fc[2]] as Vector3).normalized()])
	for _s in sub:
		var nt: Array = []
		for t3: Array in tris:
			var a: Vector3 = t3[0]
			var b: Vector3 = t3[1]
			var c: Vector3 = t3[2]
			var ab := (a + b).normalized()
			var bc_ := (b + c).normalized()
			var ca := (c + a).normalized()
			nt.append([a, ab, ca])
			nt.append([b, bc_, ab])
			nt.append([c, ca, bc_])
			nt.append([ab, bc_, ca])
		tris = nt
	_icos[sub] = tris
	return tris


## 각진 공 하나 (가운데 c, 축마다 반지름 sc), 면마다 ca~cb 사이 색
func _ico(c: Vector3, sc: Vector3, sub: int, ca: Color, cb: Color, r2: RandomNumberGenerator) -> void:
	for t3: Array in _ico_faces(sub):
		var a: Vector3 = c + (t3[0] as Vector3) * sc
		var b: Vector3 = c + (t3[1] as Vector3) * sc
		var d: Vector3 = c + (t3[2] as Vector3) * sc
		_tri(a, b, d, ca.lerp(cb, r2.randf()), (a + b + d) / 3.0 - c)


## 기울인 판(납작한 상자): 가운데 c, 반축 ex·ey·ez
func _slab(c: Vector3, ex: Vector3, ey: Vector3, ez: Vector3, col: Color) -> void:
	var sides := [[ex, ey, ez], [-ex, ey, ez], [ey, ex, ez], [-ey, ex, ez], [ez, ex, ey], [-ez, ex, ey]]
	for sd: Array in sides:
		var n: Vector3 = sd[0]
		var a: Vector3 = sd[1]
		var b: Vector3 = sd[2]
		var o := c + n
		var shade := col.lightened(0.08) if n.dot(ey) > 0.001 else (col.darkened(0.06) if n.dot(ey) < -0.001 else col)
		_tri(o - a - b, o + a - b, o + a + b, shade, n)
		_tri(o - a - b, o + a + b, o - a + b, shade, n)


# ---- 별·하늘 짓기 ----
## 별 k: 각진 공 하나. 면 평균 거리가 R 이 되게 키워 발이 땅에 붙는다. 면마다 c0~c1 사이 색.
func _planet(k: int, n: Node3D) -> void:
	var d: Dictionary = BD[k]
	var fire: bool = d.kind == "fire"
	var faces := _ico_faces(2 if d.kind == "planet" else 1)
	var mean := 0.0
	for t3: Array in faces:
		mean += (((t3[0] as Vector3) + (t3[1] as Vector3) + (t3[2] as Vector3)) / 3.0).length()
	mean /= float(faces.size())
	var s := br[k] / mean
	var nr := PackedVector3Array()
	var ds := PackedFloat32Array()
	var r2 := RandomNumberGenerator.new()
	r2.seed = 77 + k * 13
	var c0: Color = DANGER if fire else d.c0
	var c1: Color = A if fire else d.c1
	_begin()
	for t3: Array in faces:
		var a: Vector3 = (t3[0] as Vector3) * s
		var b: Vector3 = (t3[1] as Vector3) * s
		var c: Vector3 = (t3[2] as Vector3) * s
		var nn := (b - a).cross(c - a).normalized()
		if nn.dot(a) < 0.0:
			nn = -nn
		nr.append(nn)
		ds.append(nn.dot(a))
		var tt := r2.randf()
		var col := c0.lerp(c1, tt * tt)
		if not fire:
			col = col.darkened(r2.randf_range(0.0, 0.07))
		_tri(a, b, c, col, a + b + c)
	fnorm.append(nr)
	fdist.append(ds)
	var m := MeshInstance3D.new()
	m.mesh = _end_mesh()
	var key := "planet|%s" % fire
	if not _mats3.has(key):
		var sm := (_vc(not fire) as StandardMaterial3D).duplicate() as StandardMaterial3D
		sm.next_pass = _ol(Vector3.ZERO)
		_mats3[key] = sm
	m.material_override = _mats3[key]
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(m)


## 불 별: 빛나는 가시와 둘레를 도는 불씨 (돈다, 위험 = 빨강)
func _fire_deco(k: int, n: Node3D) -> void:
	var r2 := RandomNumberGenerator.new()
	r2.seed = 4040
	spin = Node3D.new()
	n.add_child(spin)
	var rr := br[k]
	_begin()
	for i in 16:
		var d := Vector3(r2.randf_range(-1, 1), r2.randf_range(-1, 1), r2.randf_range(-1, 1))
		if d.length() < 0.1:
			continue
		d = d.normalized()
		_cyl(d * rr * 0.8, d, 0.5, 0.0, 1.2 + r2.randf() * 0.5, 4, A, D, r2.randf() * TAU)
	for i in 8:
		var a := TAU * i / 8.0
		var d := Vector3(cos(a), r2.randf_range(-0.3, 0.3), sin(a)).normalized()
		_dia(d * (rr + 2.4), 0.22, 0.36, D, d)
	var m := MeshInstance3D.new()
	m.mesh = _end_mesh()
	m.material_override = _vc(false)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	spin.add_child(m)


## 별 겉에 작은 장식을 뿌린다 (풀·꽃·돌·수정·나무). 별마다 한 메시로 합치고 외곽선은 구워 넣는다.
func _deco(k: int, n: Node3D) -> void:
	var d: Dictionary = BD[k]
	if d.kind == "fire":
		_fire_deco(k, n)
		return
	var r2 := RandomNumberGenerator.new()
	r2.seed = 500 + k * 31
	_rs.seed = 900 + k
	var rr := br[k]
	var cnt := int(rr * rr * 0.75) + 8
	var te := _art_entry("tree", Callable())
	var tree_art: bool = te[1]
	var trees: Array = []
	var gcol: Color = [Color("7cc35a"), Color("a78bdb"), Color("5fc9a0"), Color("9cc8ee"), Color("e88aa6"), Color("cfc6a8"), Color("6fd6b0")][k]
	var xcol: Color = [Color("fff6e6"), Color("b9a7f2"), Color("9fe8d6"), Color("dff1ff"), Color("ffd6e2"), Color("fff6e6"), Color("8fe3c2")][k]
	var flw: Array = [D, Color("ff8a80"), WHITE, Color("b9a7f2"), Color("9fd3ff")]
	_begin()
	var placed := 0
	var tries := 0
	while placed < cnt and tries < cnt * 5:
		tries += 1
		var dir := Vector3(r2.randf_range(-1, 1), r2.randf_range(-1, 1), r2.randf_range(-1, 1))
		if dir.length() < 0.2 or dir.length() > 1.0:
			continue
		dir = dir.normalized()
		var kind := _deco_kind(k, r2.randf())
		if kind == "tree" and k == 0 and (absf(dir.y) < 0.4 or absf(dir.y) > 0.85):
			kind = "tuft"  # 풍차의 별: 적도(달리는 길)와 북극(풍차)에는 나무 없음
		if not _free_spot(k, dir, 3.2 if kind == "tree" else 1.4):
			continue
		placed += 1
		var bs := _basis(dir).rotated(dir, r2.randf() * TAU)
		var sc := r2.randf_range(0.75, 1.3)
		var xf := Transform3D(Basis(bs.x * sc, bs.y * sc, bs.z * sc), dir * (_sr(k, dir) - 0.04))
		if kind == "tree" and tree_art:
			xf.origin = dir * (_sr(k, dir) - 0.1)
			trees.append(xf)
			_shadow_q(k, dir, 1.0 * sc)  # 나무 그림자 (별 그림자 메시 하나에 합쳐진다)
			continue
		var s0 := _tv.size()
		var cy := 0.2
		var hull := true
		match kind:
			"tree":
				_shape_tree()
				cy = 1.2
			"tuft":
				_shape_tuft(gcol)
				hull = false
			"flower":
				_shape_flower(gcol, flw[r2.randi() % flw.size()])
				hull = false
			"pebble":
				_shape_pebble((d.c0 as Color).darkened(0.22))
				cy = 0.1
			"crystal":
				_shape_crystal(xcol)
				cy = 0.3
			_:
				_shape_mound(WHITE.lerp(xcol, 0.5))
				cy = 0.08
		_xf(s0, xf)
		if hull:
			_hull(s0, xf * Vector3(0, cy, 0), 0.045)
	var has_tv := _tv.size() > 0
	var m := MeshInstance3D.new()
	m.mesh = _end_mesh()
	if has_tv:
		(m.mesh as ArrayMesh).surface_set_material(0, _vc(true))
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(m)
	if trees.is_empty():
		return
	# 그림 나무: 한 별의 나무를 한 메시로, 외곽선 껍질도 한 메시로
	var tm: Mesh = te[0]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for xf2: Transform3D in trees:
		st.append_from(tm, 0, xf2)
	var tmi := MeshInstance3D.new()
	tmi.mesh = st.commit()
	var tint: Color = [WHITE, Color("ece4ff"), Color("e4fff4"), WHITE, Color("fff0f4"), WHITE, WHITE][k]
	var tmat := (_art_mat("tree", tint) as StandardMaterial3D).duplicate() as StandardMaterial3D
	tmat.next_pass = null
	tmi.material_override = tmat
	tmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(tmi)
	_begin()
	for xf2: Transform3D in trees:
		_hull_mesh(tm, xf2, 0.05)
	var hm := MeshInstance3D.new()
	hm.mesh = _end_mesh()
	hm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(hm)


## 별마다 장식 고르기 (roll 0~1)
func _deco_kind(k: int, roll: float) -> String:
	var tb: Array = [
		[["tree", 0.1], ["tuft", 0.5], ["flower", 0.25], ["pebble", 0.15]],
		[["tree", 0.08], ["tuft", 0.45], ["crystal", 0.2], ["pebble", 0.15], ["flower", 0.12]],
		[["tree", 0.08], ["crystal", 0.35], ["tuft", 0.4], ["flower", 0.17]],
		[["crystal", 0.35], ["mound", 0.3], ["pebble", 0.2], ["tuft", 0.15]],
		[["tuft", 0.45], ["flower", 0.35], ["pebble", 0.2]],
		[["pebble", 0.5], ["tuft", 0.3], ["crystal", 0.2]],
		[["flower", 0.4], ["crystal", 0.3], ["tuft", 0.3]],
	]
	var acc := 0.0
	for e: Array in tb[k]:
		acc += float(e[1])
		if roll < acc:
			return str(e[0])
	return "tuft"


## 장식을 피할 자리: 주민·물건·풍차·담·탑 둘레 (호 길이 clr 만큼 더 띄운다)
func _free_spot(k: int, dir: Vector3, clr: float) -> bool:
	var keep: Array = []
	if k <= 3:
		keep.append([NPC_D.normalized(), 2.0])
	if k >= 1 and k <= 3:
		keep.append([HOME_D.normalized(), 1.6])
	match k:
		0:
			keep.append([Vector3.UP, 2.4])
			keep.append([START, 1.2])
		4:
			keep.append([(JOB[4].tdir as Vector3).normalized(), 3.0])
			keep.append([tower_d, 1.6])
		5:
			keep.append([(JOB[1].tdir as Vector3).normalized(), 2.6])
		6:
			keep.append([(JOB[2].tdir as Vector3).normalized(), 1.6])
	for kp: Array in keep:
		if dir.angle_to(kp[0]) * br[k] < float(kp[1]) + clr:
			return false
	return true


## 먼 하늘: 흰·노란 별 조각(빛 없음)과 큰 흰 구름 덩어리(약한 빛), 해
func _sky() -> void:
	var r2 := RandomNumberGenerator.new()
	r2.seed = 4242
	_begin()
	for i in 80:
		var d := Vector3(r2.randf_range(-1, 1), r2.randf_range(-0.8, 0.8), r2.randf_range(-1, 1)).normalized()
		var c := MID + d * r2.randf_range(240.0, 300.0)
		var sz := r2.randf_range(1.6, 4.2)
		var col: Color = [WHITE, Color("fff1b8"), WHITE, Color("ffe08a")][i % 4]
		_dia(c, sz, sz * 1.7, col, Vector3(r2.randf_range(-0.3, 0.3), 1.0, r2.randf_range(-0.3, 0.3)), r2.randf() * TAU)
	_ico(MID + Vector3(120, 160, -140), Vector3.ONE * 16.0, 1, Color("ffe08a"), Color("fff3c4"), r2)
	var m := MeshInstance3D.new()
	m.mesh = _end_mesh()
	m.material_override = _vc(false)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(m)
	_begin()
	for i in 16:
		var d := Vector3(r2.randf_range(-1, 1), r2.randf_range(-0.4, 0.3), r2.randf_range(-1, 1)).normalized()
		var c := MID + d * r2.randf_range(170.0, 220.0)
		for j in r2.randi_range(4, 7):
			var o := Vector3(r2.randf_range(-16, 16), r2.randf_range(-3, 5), r2.randf_range(-16, 16))
			var cr := r2.randf_range(6.0, 12.0)
			_ico(c + o, Vector3(cr, cr * 0.62, cr), 1, WHITE, Color("eef4ff"), r2)
	var cm := MeshInstance3D.new()
	cm.mesh = _end_mesh()
	cm.material_override = _vc(true)
	cm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(cm)


# ---- 로우폴리 대신 모델 (그림 파일이 없을 때). 원점 = 바닥 가운데, +Y 위, 앞 = -Z (ART_DIRECTION.md 크기) ----
var _rs := RandomNumberGenerator.new()


func _eyes(y: float, z: float) -> void:
	_dia(Vector3(-0.1, y, z), 0.045, 0.03, NAVY, Vector3(0, 0, -1))
	_dia(Vector3(0.1, y, z), 0.045, 0.03, NAVY, Vector3(0, 0, -1))


func _shape_traveler() -> void:
	_rs.seed = 11
	_cyl(Vector3(-0.13, 0, 0), Vector3.UP, 0.1, 0.09, 0.16, 5, NAVY, NAVY)
	_cyl(Vector3(0.13, 0, 0), Vector3.UP, 0.1, 0.09, 0.16, 5, NAVY, NAVY)
	_cyl(Vector3(0, 0.12, 0), Vector3.UP, 0.36, 0.17, 0.8, 7, Color("f3e6cf"), CREAM)  # 망토
	_cyl(Vector3(0, 0.84, 0), Vector3.UP, 0.25, 0.22, 0.15, 7, D, D.lightened(0.2))  # 목도리
	_cyl(Vector3(0.14, 0.92, 0.16), Vector3(0.3, -1.0, 0.7), 0.07, 0.04, 0.42, 4, D, D)  # 목도리 꼬리
	_ico(Vector3(0, 1.24, 0), Vector3.ONE * 0.3, 1, SKIN, SKIN.darkened(0.06), _rs)
	_eyes(1.27, -0.27)
	_cyl(Vector3(0, 1.48, 0), Vector3(0.15, 1, 0.1), 0.15, 0.0, 0.16, 5, D, D)  # 머리칼


func _shape_villager() -> void:
	_rs.seed = 12
	_cyl(Vector3(-0.13, 0, 0), Vector3.UP, 0.1, 0.09, 0.15, 5, NAVY, NAVY)
	_cyl(Vector3(0.13, 0, 0), Vector3.UP, 0.1, 0.09, 0.15, 5, NAVY, NAVY)
	_cyl(Vector3(0, 0.12, 0), Vector3.UP, 0.36, 0.24, 0.85, 7, CREAM, CREAM)
	_ico(Vector3(0, 1.24, 0), Vector3.ONE * 0.3, 1, SKIN, SKIN.darkened(0.06), _rs)
	_eyes(1.27, -0.27)


func _shape_hat() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 0.36, 0.36, 0.06, 8, WHITE, WHITE)
	_cyl(Vector3(0, 0.06, 0), Vector3.UP, 0.24, 0.05, 0.34, 7, WHITE, WHITE)


func _shape_heart() -> void:
	var co := Color("ff8a80")
	_dia(Vector3(-0.055, 0.03, 0), 0.07, 0.07, co, Vector3.UP, PI / 4.0)
	_dia(Vector3(0.055, 0.03, 0), 0.07, 0.07, co, Vector3.UP, PI / 4.0)
	_dia(Vector3(0, -0.05, 0), 0.08, 0.08, co, Vector3.UP, PI / 4.0)


func _shape_sail() -> void:
	_cyl(Vector3(0, -0.3, 0), Vector3.UP, 0.03, 0.03, 1.35, 4, Color("8a5a3c"), Color("8a5a3c"))
	var top := Vector3(0, 1.0, 0.02)
	var bot := Vector3(0, -0.15, 0.02)
	for sd: float in [1.0, -1.0]:
		var tip := Vector3(0.72 * sd, 0.0, 0.08)
		var col := A if sd > 0.0 else CREAM
		_tri(top, bot, tip, col, Vector3(0, 0, 1))
		_tri(top, bot, tip, col.darkened(0.12), Vector3(0, 0, -1))


func _shape_bag() -> void:
	_slab(Vector3.ZERO, Vector3(0.1, 0, 0), Vector3(0, 0.17, 0), Vector3(0, 0, 0.2), Color("c08a4a"))
	_slab(Vector3(0.02, 0.12, 0), Vector3(0.1, 0, 0), Vector3(0, 0.05, 0), Vector3(0, 0, 0.21), Color("d9a566"))


func _shape_stool() -> void:
	for i in 3:
		var a := TAU * i / 3.0
		_cyl(Vector3(cos(a) * 0.28, 0, sin(a) * 0.28), Vector3.UP, 0.05, 0.05, 0.45, 4, Color("8a5a3c"), Color("8a5a3c"))
	_cyl(Vector3(0, 0.45, 0), Vector3.UP, 0.45, 0.45, 0.12, 8, Color("c08a4a"), Color("d9a566"))


func _shape_windmill_tower() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 1.3, 0.55, 8.3, 8, CREAM, CREAM)
	_cyl(Vector3(0, 8.3, 0), Vector3.UP, 0.75, 0.0, 0.7, 8, D, D)
	_slab(Vector3(0, 0.55, -1.2), Vector3(0.3, 0, 0), Vector3(0, 0.55, 0), Vector3(0, 0, 0.12), NAVY)


func _shape_windmill_blades() -> void:
	_rs.seed = 13
	_ico(Vector3.ZERO, Vector3.ONE * 0.35, 0, Color("c08a4a"), Color("d9a566"), _rs)
	for j in 4:
		var a := TAU * j / 4.0
		var dj := Vector3(cos(a), sin(a), 0)
		var pj := Vector3(-sin(a), cos(a), 0)
		_slab(dj * 2.0, dj * 1.6, pj * 0.3, Vector3(0, 0, 0.06), D if j % 2 == 0 else CREAM)


func _shape_chimney_house() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 1.0, 1.0, 1.4, 8, CREAM, CREAM)
	_cyl(Vector3(0, 1.4, 0), Vector3.UP, 1.15, 0.0, 0.9, 8, Color("ff8a80"), Color("ff8a80"))
	_slab(Vector3(0.45, 2.0, 0.2), Vector3(0.14, 0, 0), Vector3(0, 0.6, 0), Vector3(0, 0, 0.14), NAVY)
	_slab(Vector3(0, 0.5, -0.98), Vector3(0.22, 0, 0), Vector3(0, 0.5, 0), Vector3(0, 0, 0.05), NAVY)


func _shape_rock() -> void:
	_rs.seed = 14
	_ico(Vector3(0, 0.45, 0), Vector3(0.62, 0.5, 0.6), 0, Color("b9a7f2"), Color("cfc2f7"), _rs)


func _shape_red_rock() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 1.3, 0.3, 5.6, 6, DANGER, DANGER.lightened(0.15))
	_cyl(Vector3(0.7, 0, 0.3), Vector3(0.3, 1, 0), 0.6, 0.0, 3.2, 5, DANGER.darkened(0.1), DANGER)


func _shape_tower() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 0.8, 0.72, 2.2, 8, CREAM, CREAM)
	_cyl(Vector3(0, 2.2, 0), Vector3.UP, 0.88, 0.88, 0.3, 8, D, D.lightened(0.15))
	_slab(Vector3(0, 0.45, -0.76), Vector3(0.2, 0, 0), Vector3(0, 0.45, 0), Vector3(0, 0, 0.05), NAVY)


func _shape_rose() -> void:
	_rs.seed = 15
	var g := Color("5fc9a0")
	_cyl(Vector3.ZERO, Vector3.UP, 0.035, 0.03, 0.95, 4, g, g)
	_dia(Vector3(0.14, 0.45, 0), 0.12, 0.05, g, Vector3(1, 0.4, 0))
	_dia(Vector3(-0.14, 0.62, 0), 0.12, 0.05, g, Vector3(-1, 0.4, 0))
	_ico(Vector3(0, 1.12, 0), Vector3(0.28, 0.26, 0.28), 1, Color("ff8a80"), Color("f06595"), _rs)


func _shape_glass_flower() -> void:
	var g := Color("8fe3c2")
	_cyl(Vector3.ZERO, Vector3.UP, 0.025, 0.02, 0.35, 4, g, g)
	_dia(Vector3(0.12, 0.2, 0), 0.08, 0.04, g, Vector3(1, 0.5, 0))
	_dia(Vector3(-0.12, 0.26, 0), 0.08, 0.04, g, Vector3(-1, 0.5, 0))
	_dia(Vector3(0, 0.45, 0), 0.15, 0.15, Color("bdf5ea"), Vector3.UP, PI / 4.0)


func _shape_glass_dome() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 0.46, 0.46, 0.08, 8, CREAM, CREAM)
	_cyl(Vector3(0, 0.08, 0), Vector3.UP, 0.42, 0.2, 0.55, 8, Color("9fd3ff"), Color("bfe8ff"))
	_cyl(Vector3(0, 0.63, 0), Vector3.UP, 0.2, 0.0, 0.17, 8, Color("bfe8ff"), Color("bfe8ff"))


func _shape_parcel() -> void:
	_slab(Vector3(0, 0.275, 0), Vector3(0.38, 0, 0), Vector3(0, 0.275, 0), Vector3(0, 0, 0.28), Color("c08a4a"))
	_slab(Vector3(0, 0.276, 0), Vector3(0.39, 0, 0), Vector3(0, 0.28, 0), Vector3(0, 0, 0.04), CREAM)


func _shape_meteor() -> void:
	_rs.seed = 16
	_ico(Vector3.ZERO, Vector3(0.62, 0.58, 0.62), 0, NAVY, Color("3a2a3a"), _rs)
	_dia(Vector3(0.3, 0.3, -0.3), 0.18, 0.12, DANGER, Vector3(1, 1, -1))
	_dia(Vector3(-0.32, -0.1, 0.28), 0.16, 0.1, DANGER, Vector3(-1, 0, 1))


func _shape_tree() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 0.15, 0.11, 0.85, 5, Color("8a5a3c"), Color("8a5a3c"))
	_ico(Vector3(0, 1.55, 0), Vector3(0.85, 0.8, 0.85), 1, Color("7cc35a"), Color("a6dc84"), _rs)


func _shape_wall() -> void:
	_slab(Vector3(0, 0.46, 0), Vector3(0.5, 0, 0), Vector3(0, 0.46, 0), Vector3(0, 0, 0.25), Color("e9e0f5"))
	_slab(Vector3(0, 0.96, 0), Vector3(0.52, 0, 0), Vector3(0, 0.04, 0), Vector3(0, 0, 0.27), D)


# 가운데가 원점인 단위 모양 (_unit)
func _shape_u_hex() -> void:
	_cyl(Vector3(0, -0.5, 0), Vector3.UP, 0.5, 0.5, 1.0, 6, WHITE, WHITE)


func _shape_u_disc() -> void:
	_cyl(Vector3(0, -0.5, 0), Vector3.UP, 0.5, 0.5, 1.0, 8, WHITE, WHITE)


func _shape_u_gem() -> void:
	_dia(Vector3.ZERO, 0.5, 0.5, WHITE, Vector3.UP)


func _shape_u_dot() -> void:
	_rs.seed = 17
	_ico(Vector3.ZERO, Vector3.ONE * 0.2, 0, WHITE, WHITE, _rs)


# 별 장식 (합쳐서 한 메시)
func _shape_tuft(col: Color) -> void:
	for i in 3:
		var a := TAU * i / 3.0 + 0.4
		_cyl(Vector3(cos(a) * 0.05, 0, sin(a) * 0.05), Vector3(cos(a) * 0.35, 1.0, sin(a) * 0.35), 0.05, 0.0, 0.3 + 0.07 * i, 3, col.lightened(0.06 * i), col)


func _shape_flower(stem: Color, petal: Color) -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 0.025, 0.02, 0.32, 3, stem, stem)
	_dia(Vector3(0, 0.36, 0), 0.11, 0.06, petal, Vector3.UP, 0.3)


func _shape_pebble(col: Color) -> void:
	_ico(Vector3(0, 0.07, 0), Vector3(0.22, 0.14, 0.18), 0, col, col.lightened(0.1), _rs)


func _shape_crystal(col: Color) -> void:
	for i in 3:
		var a := TAU * i / 3.0 + _rs.randf()
		var ax := Vector3(cos(a) * 0.3, 1.0, sin(a) * 0.3) if i > 0 else Vector3.UP
		var h := 0.25 + 0.2 * _rs.randf() + (0.15 if i == 0 else 0.0)
		var base := Vector3(cos(a) * 0.08, 0, sin(a) * 0.08) if i > 0 else Vector3.ZERO
		_cyl(base, ax, 0.08, 0.08, h * 0.6, 5, col, col)
		_cyl(base + ax.normalized() * h * 0.6, ax, 0.08, 0.0, h * 0.45, 5, col.lightened(0.2), col)


func _shape_mound(col: Color) -> void:
	_ico(Vector3(0, -0.05, 0), Vector3(0.5, 0.25, 0.45), 0, col, col.lightened(0.1), _rs)


# ---- 소리 (nkido, art/tinyplanet_sfx) ----
var _sfx := {}
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_i := 0
var _sfx_at := {}


func _sfx_get(nm: String) -> Variant:
	if not _sfx.has(nm):
		var pth := SFX + nm + ".wav"
		_sfx[nm] = load(pth) if ResourceLoader.exists(pth) else null
	return _sfx[nm]


## 효과음 (파일이 없으면 조용히 넘어간다). 같은 소리는 50ms 안에 겹치지 않는다
func sfx(nm: String, db := 0.0, pitch := 1.0) -> void:
	var st: Variant = _sfx_get(nm)
	if st == null:
		return
	var now := Time.get_ticks_msec()
	if now - int(_sfx_at.get(nm, -1000)) < 50:
		return
	_sfx_at[nm] = now
	if _sfx_pool.is_empty():
		for i in 10:
			var np := AudioStreamPlayer.new()
			add_child(np)
			_sfx_pool.append(np)
	var ap: AudioStreamPlayer = _sfx_pool[_sfx_i % _sfx_pool.size()]
	for i in _sfx_pool.size():
		var c: AudioStreamPlayer = _sfx_pool[(_sfx_i + i) % _sfx_pool.size()]
		if not c.playing:
			ap = c
			break
	_sfx_i += 1
	ap.stream = st
	ap.volume_db = db - 4.0
	ap.pitch_scale = clampf(pitch * randf_range(0.97, 1.03), 0.3, 3.0)
	ap.play()


## 공통 삑 소리 대신
func play(nm: String) -> void:
	match nm:
		"good": sfx("pickup")
		"bad":
			# _die 에서 이미 울렸다: end() 의 "bad" 는 다시 울리지 않는다
			if not won and not over:
				sfx("die")
		"win": sfx("deliver")
		"tap": sfx("ui_tap")
		_: super(nm)


## 게임 끝 글 (tofu.gd 의 "최고"·"탭해서 다시"를 영어로)
func _process(dt: float) -> void:
	_stepped = false
	super(dt)
	# 평가 카드·끝 화면에선 _step 이 안 돈다: ui·fx 는 멈춘 상태(paused)로 계속 받는다
	if not _stepped and ui and me:
		_post(dt)
	# 시작 화면 동안: 점수·말풍선·조작 키트·막대가 비치지 않게
	var tv: bool = ui != null and ui.title_visible()
	if tv:
		_score_l.visible = false
		_msg_l.visible = false
		_bar_bg.visible = false
		_rate_btn_l.visible = false
		hud2.visible = false
		if _pad:
			_pad.visible = false
	elif _title_was:
		_score_l.visible = true
		if not over and fin_t <= 0.0:
			hud2.visible = true
	_title_was = tv
	# 평가 카드·끝 화면에선 _step 이 멈춰 바람이 안 줄어든다: 바로 끈다
	if (_rating or over) and wind_pl and wind_pl.playing:
		wind_pl.stop()
	if _en and over:
		_over_l.text = "%d\nBest %d%s" % [score, best, "\nTap to play again" if wait <= 0.0 else ""]
	# v6: 단독판 "< 처음부터"는 숨긴다. 단독판이 목록에서 왔으면 나중에 "< 목록"으로 바뀌니 그때 다시 보인다 (내가 숨긴 것만 되돌린다)
	if _back_l:
		if _back_l.text in RESTART_TXT:
			if _back_l.visible:
				_back_l.visible = false
				_back_hid = true
		elif _back_hid:
			_back_hid = false
			_back_l.visible = true


## 숨긴 "< 처음부터" 자리(왼쪽 위)를 눌러도 처음부터 다시가 되지 않게 그 누름만 버린다
func _unhandled_input(event: InputEvent) -> void:
	if _back_l and _back_l.text in RESTART_TXT:
		var at := Vector2(-1, -1)
		if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
			at = (event as InputEventScreenTouch).position
		elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
			at = (event as InputEventMouseButton).position
		if at.x >= 0.0 and at.x < 180.0 and at.y >= 0.0 and at.y < 100.0:
			return
	super(event)


## smoke(화면 없음)에서 한 번: 그리는 것 수를 센다 (MeshInstance3D·MultiMesh, 재질의 next_pass 외곽선까지 = 대략 그리기 수)
var _counted := false


func _count_draws() -> void:
	var c := [0, 0, 0, 0]  # 메시 노드, MultiMesh 노드, 그리기(전부), 그리기(지금 보이는 것)
	_count_in(self, c)
	print("tinyplanet v6 count: MeshInstance3D %d, MultiMeshInstance3D %d, draw passes all %d, visible now %d" % c)


func _count_in(n: Node, c: Array) -> void:
	for ch in n.get_children():
		if ch is MeshInstance3D or ch is MultiMeshInstance3D:
			var gi := ch as GeometryInstance3D
			var mesh: Mesh = null
			if ch is MeshInstance3D:
				mesh = (ch as MeshInstance3D).mesh
				c[0] += 1
			else:
				var mmi := ch as MultiMeshInstance3D
				if mmi.multimesh:
					mesh = mmi.multimesh.mesh
				c[1] += 1
			if mesh:
				var dr := 0
				for si in mesh.get_surface_count():
					var m: Material = gi.material_override if gi.material_override else mesh.surface_get_material(si)
					dr += 1
					while m and m.next_pass:
						dr += 1
						m = m.next_pass
				c[2] += dr
				if gi.is_visible_in_tree():
					c[3] += dr
		_count_in(ch, c)

# ---- 말 (dialogue.json 을 박아 넣은 DL) ----
func _tx(key: String, args := {}) -> String:
	if not DL.has(key):
		return key
	var s := tr(str(DL[key][0]))
	if not args.is_empty():
		s = s.format(args)
	return s


## 별 k 주민의 말 (ask / hint / thanks / thanks2 / idle1 / idle2)
func _line(k: int, part: String) -> String:
	var key := str(BD[k].id) + "." + part
	return _tx(key) if DL.has(key) else ""


## 영어 번역은 이 게임이 떠 있는 동안만 TranslationServer 에 둔다 (나가면 빼서 다른 게임 글이 영어로 바뀌지 않게).
## 단독판 "처음부터"는 새 게임이 먼저 뜨고 옛 게임이 나중에 빠질 수 있어 쓰는 수를 센다.
static var _tl: Translation
static var _tl_n := 0
var _tl_on := false


## v6: 영어가 기본. 웹 주소에 lang=ko 가 있으면 한국어. 시작 화면 전환(set_lang)이 고른 게 있으면 그것. JS 값은 글자로 비교한다(bool 비교는 웹에서 멈춘다).
func _lang() -> void:
	var en := true
	if _lang_pick != "":
		en = _lang_pick == "en"
	elif OS.has_feature("web"):
		if str(JavaScriptBridge.eval("location.search.indexOf('lang=ko')>=0?'y':'n'", true)) == "y":
			en = false
	_en = en
	if not en:
		TranslationServer.set_locale("ko")  # 영어 번역이 올라가 있어도 ko 에선 안 쓰인다
		return
	if _tl == null:
		var tl := Translation.new()
		tl.locale = "en"
		for k: String in DL:
			var pr: Array = DL[k]
			tl.add_message(str(pr[0]), str(pr[1]))
		for k: String in EN_UI:
			tl.add_message(k, str(EN_UI[k]))
		for k: String in UI_GD.EN:  # 시작 화면·튜토리얼·끝 화면 글
			tl.add_message(k, str(UI_GD.EN[k]))
		for k: String in FX_GD.EN:
			tl.add_message(k, str(FX_GD.EN[k]))
		_tl = tl
	if not _tl_on:
		_tl_on = true
		if _tl_n <= 0:
			TranslationServer.add_translation(_tl)
		_tl_n += 1
	TranslationServer.set_locale("en")


func _exit_tree() -> void:
	if not _tl_on:
		return
	_tl_on = false
	_tl_n -= 1
	if _tl_n <= 0:
		_tl_n = 0
		TranslationServer.remove_translation(_tl)


const EN_UI := {
	"< 메뉴": "< Menu", "< 처음부터": "< Restart", "< 목록": "< List", "평가": "Rate", "탭해서 시작": "Tap to start",
	"이 게임 어때요?": "How was it?", "닫기": "Close", "한마디": "Comment", "고마워요!": "Thanks!",
	"보내는 중": "Sending", "한마디 보냈어요": "Comment sent", "저장 안 됨 · 별을 다시 탭": "Not saved · tap a star again",
	"이 게임에 한마디 (선택)": "A word about this game (optional)",
}


# ---- 대사: submit/tinyplanet/dialogue.json (Antigravity · Gemini) 을 그대로 박아 넣음. [한국어, 영어] ----
const DL := {
	"name.windmill": ["풍차의 별", "Windmill Planet"],
	"name.post": ["우편의 별", "Post Planet"],
	"name.glass": ["유리꽃의 별", "Glass Flower Planet"],
	"name.sunset": ["노을의 별", "Sunset Planet"],
	"name.rose": ["장미의 별", "Rose Planet"],
	"name.chimney_moon": ["굴뚝 달", "Chimney Moon"],
	"name.friend_moon": ["친구 달", "Friend Moon"],
	"name.fire": ["불 별", "Fire Star"],
	"who.windmill": ["풍차지기", "Windmill Keeper"],
	"who.post": ["우체부", "Mail Carrier"],
	"who.glass": ["정원사", "Gardener"],
	"who.sunset": ["노을 아이", "Sunset Child"],
	"who.rose": ["장미", "Rose"],
	"who.chimney": ["굴뚝 집", "Chimney House"],
	"who.friend": ["꽃 친구", "Flower Friend"],
	"who.me": ["나", "Me"],
	"p1.ask": ["바람이 멎어 풍차가 잠들었네. 별 둘레를 힘껏 달려 바람을 깨워 주겠나?", "The wind died and the mill sleeps. Run hard around to wake my friend?"],
	"p1.hint": ["뜨기 직전이 제일 센 바람이지. 발이 뜨면 바람이 끊기니 땅에 붙어 달리게나.", "Fastest just before liftoff is best. Keep your feet on the ground!"],
	"p1.thanks": ["고마우이, 돛을 받게나. 보라 별이 우편의 별이니 노란 줄을 힘껏 달리게.", "Thank you! Take the sail. Purple is Post Planet; run the yellow lane."],
	"p1.thanks2": ["초록 칸에서 점프하게. 날다 스틱 밀며 뛰면 돛으로 방향을 한 번 튼다네.", "Jump at the green cell! In flight, jump and push stick to turn once."],
	"p2.ask": ["이 소포, 저 하얀 굴뚝 달 집에 전해 줘! 담이 높아 걸어선 못 들어가.", "Take this parcel to Chimney Moon! The walls are too high to walk in."],
	"p2.hint": ["달은 작아 금방 떠! 굴뚝 위 지날 때 '놓기'. 발밑 노란 점에 떨어져!", "The moon lifts fast! Press 'Drop' over chimney onto the yellow dot."],
	"p2.thanks": ["잘 도착했대, 고마워! 다음은 초록 유리꽃의 별로 힘차게 날아가 봐.", "Delivered safely! Next, fly out to the green Glass Flower Planet."],
	"p3.ask": ["유리꽃을 저 민트 친구 달에 전해 줘요… 세게 내려앉으면 깨져 버려요.", "Carry the glass flower to Friend Moon... A hard landing will break it."],
	"p3.hint": ["곧장 말고 빙 돌아 살살 앉아요. 빨간 그림자는 운석 자리니 미리 피해요!", "Don't dive straight; circle to land softly. Red shadows are meteors!"],
	"p3.thanks": ["꽃이 무사하대요… 정말 다행이에요. 이제 하늘색 노을의 별로 가 보세요.", "The flower is safe... thank you! Now visit the sky-blue Sunset Planet."],
	"p4.ask": ["내 별은 너무 작아서 노을이 자꾸 달아나. 저 주황 띠랑 같이 달려 줘!", "My planet is small and the sunset runs away. Run with the orange band!"],
	"p4.hint": ["얼음이라 미끄러워! 빠르면 뜨고 느리면 놓쳐. 띠랑 같은 빠르기로 뛰어!", "Slick ice! Too fast you float, too slow you lose it. Match its speed!"],
	"p4.thanks": ["고마워! 분홍 장미 별에 유리 덮개를 줘. 곧장 가면 빨간 바위 띠야.", "Bring this dome to Rose Planet! A red rock belt blocks the direct way."],
	"p4.thanks2": ["빨간 불 별 옆을 스치면 휘어 돌아가. 불 별에 닿으면 끝이니까 닿지 마!", "Skim beside the red fire star to whip around. Touching it is death!"],
	"p5.ask": ["바람이 차가워… 유리 덮개를 씌워 줘. 담이 천천히 돌고 틈은 하나야.", "It's cold... Put the dome over me. The wall turns; there is one gap."],
	"p5.hint": ["담 틈 맞춰 들어오거나 탑에서 날아 위에서 놓아 줘. 세게 내리면 깨져.", "Walk in with the wall gap, or drop from tower. Land hard, it breaks."],
	"p5.thanks": ["…따뜻해. 고마워. 네 빠른 발 덕분에 우리 다섯 별이 다 웃고 있어.", "...Warm now. Thank you. Your fast feet made all five planets smile."],
	"p1.idle1": ["바람결을 느끼며 달리면 하늘도 그 발소리를 듣는다네.", "When you run with the wind, the sky listens to your steps."],
	"p1.idle2": ["서두르지 말게. 별은 언제나 제자리에서 자네를 기다리니.", "No need to hurry. The stars always wait patiently in place."],
	"p2.idle1": ["하늘에 띄운 편지는 길을 잃지 않아. 언제나 닿을 곳으로 가지!", "Letters sent across the sky never get lost. They always arrive!"],
	"p2.idle2": ["오늘도 우편 가방이 든든하네! 다음 행선지는 어디야?", "My mailbag is nice and full today! Where are you flying next?"],
	"p3.idle1": ["유리꽃은 아주 여려요… 가만히 숨소리를 들으면 맑게 울리지요.", "Glass flowers are fragile... listen close and they ring softly."],
	"p3.idle2": ["별들 사이를 날아갈 땐 마음도 깃털처럼 가볍게 가져 보세요.", "When soaring between stars, let your heart be light as a feather."],
	"p4.idle1": ["노을빛이 주황색으로 번질 때 별을 달리면 마음이 몽글몽글해.", "Running as the sunset spreads orange makes my heart flutter."],
	"p4.idle2": ["혼자 달릴 땐 외로웠는데, 같이 뛰니까 노을이 안 무서워!", "I was lonely running alone, but with you I do not fear sunset!"],
	"p5.idle1": ["…뭘 그렇게 봐? 유리 덮개가 마음에 들어서 가만있는 것뿐이야.", "...What are you looking at? I just happen to like this glass dome."],
	"p5.idle2": ["별빛이 덮개에 닿아 반짝이는 건… 조금 예쁜 것 같네.", "The starlight sparkling against the glass... looks rather nice."],
	"moon.chimney.got": ["굴뚝 속으로 소포가 쏙 들어왔어! 따뜻한 온기가 번지네.", "The parcel dropped right down the chimney! Cozy warmth spreads inside."],
	"moon.friend.got": ["정원사의 맑은 꽃이 깨지지 않고 닿았어… 달이 환해졌네!", "The gardener's clear flower arrived unbroken... the moon glows!"],
	"msg.start": ["1. {planet}", "1. {planet}"],
	"msg.tower_jump": ["탑에서 뛰어내린다", "Leaping from the tower"],
	"msg.liftoff": ["중력을 벗어난다!", "Escaping gravity!"],
	"msg.float": ["발이 떴다", "Floating"],
	"msg.sail": ["돛으로 방향을 튼다", "Turning with the sail"],
	"msg.drift_warn": ["우주로 떠내려간다… 돛으로 돌려!", "Drifting away! Turn with sail!"],
	"msg.flower_crack": ["착지가 세서 금이 갔다", "Landed hard, glass cracked"],
	"msg.slingshot": ["중력을 타고 휘어 돈다", "Curving past with gravity"],
	"msg.rock_snag": ["바위에 걸렸다", "Caught on a rock"],
	"msg.wall_gap": ["담 — 틈으로", "Wall — find the gap"],
	"msg.wall_high": ["담이 높다 — 공중에서 놓기", "High wall — drop from above"],
	"msg.picked": ["들었다 → {target}", "Picked up → {target}"],
	"msg.missed_drop": ["빗나갔다 — 다시 줍기", "Missed — pick it up again"],
	"msg.glass_broken": ["깨졌다… {src}에서 다시 받기", "Broken... get another at {src}"],
	"msg.rose_smiles": ["장미가 환하게 웃는다", "The rose smiles brightly"],
	"msg.next": ["다음: {planet}", "Next: {planet}"],
	"hud.next_hint": ["다음: {planet} (노란 빛기둥). 달려 점프! 초록 점선이면 닿아.", "Next: {planet} (yellow pillar). Run and jump! Green dots will reach."],
	"die.fire": ["뜨거운 불 별에 닿았다", "Touched the burning star"],
	"die.rocks": ["빨간 바위 띠에 부딪혔다", "Hit the red rock belt"],
	"die.drift": ["깊은 우주로 떠내려갔다", "Drifted into deep space"],
	"die.meteor": ["떨어지는 운석에 맞았다", "Struck by a falling meteor"],
	"react.first_liftoff": ["별을 떠나 날아오른다", "Leaving gravity behind..."],
	"react.first_landing": ["새로운 별에 내려앉았다", "Stepped onto a new world"],
	"react.slingshot": ["별의 곁을 스쳐 가속한다", "Whipping past the planet"],
	"react.orbit_landing": ["궤도를 돌아 살포시 앉았다", "A gentle orbit touchdown"],
	"react.flower_cracked": ["금이 갔다… 더 살살 앉자", "Cracked... land gentler!"],
	"react.flower_broken": ["깨져 버렸다… 다시 가자", "Shattered... start again"],
	"react.drift_warning": ["멀어진다… 돛으로 돌리자!", "Drifting! Turn with sail!"],
	"react.die_fire": ["스치기만 하고 닿지 말자", "Skim beside, do not touch!"],
	"react.die_rocks": ["불 별 쪽으로 돌아가자", "Go around via the fire star!"],
	"react.die_drift": ["초록 점선을 보고 뛰자", "Jump only on green dots!"],
	"react.die_meteor": ["빨간 그림자를 미리 피하자", "Step off red shadows early!"],
	"react.new_planet": ["새 별에 닿아 힘이 난다", "New planet! Life restored"],
	"ending.1": ["발끝으로 건넌 별마다 다정한 빛이 켜졌다.", "A gentle light now glows on every star I crossed."],
	"ending.2": ["작고 외롭던 별들이 하늘 한가운데서 서로 웃는다.", "Small, lonely worlds now smile together across the sky."],
	"ending.3": ["차가운 유리 너머로 전해진 온기가 마음을 데운다.", "Warmth shared through glass softly warms my heart."],
	"ending.4": ["언젠가 또 바람이 불면, 다시 달려 날아가야지.", "When the wind rises again, I will run and take flight."],
	"ui.title": ["어린 배달부", "The Little Courier"],
	"hint.first": ["스틱으로 달리기 · 막대가 차면 점프!", "Hold the stick to run · Jump when the bar fills"],
	"ui.jump": ["점프", "Jump"],
	"ui.drop": ["놓기", "Drop"],
	"howto": ["별 여러 개가 한 하늘에 떠 있다. 왼쪽 스틱으로 달린다(밀수록 빠름). 빨리 달리면 발이 뜬다.\n아주 빨리 달려 점프하면 중력을 벗어난다. 다른 별에 끌려 돌다 내리고, 빗나가면 떠내려간다.\n발 앞 점선: 지금 뛰면 갈 길(초록 도달, 빨강 위험). 위 막대 초록이면 점프 가능. 노란 빛기둥이 갈 곳.\n날다 점프: 돛으로 스틱 쪽 방향 전환. '놓기'는 발밑 노란 점에. 유리는 세게 내리면 깨짐. 목숨 3(새 별서 회복).", "Tiny planets share one sky. Run with left stick (push more for speed); fast running lifts feet.\nSprint and jump to escape gravity and fly. Nearby planets pull you into orbit; miss and you drift off.\nDotted line shows path (green reaches, red is danger). Green top bar = escape ready. Yellow pillar is goal.\nJump mid-flight to turn toward stick with sail. 'Drop' lands on yellow dot. Glass breaks if slammed. 3 lives (refill on new planet)."],
}
