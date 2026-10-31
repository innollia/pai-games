extends Tofu
## 어린 배달부(작은 행성) v8 — 처음 v4 설명: (등뒤 3인칭, 한 하늘의 여러 별, 진짜 중력 비행): 별 다섯·달 둘·불 별 하나가 한 장면에 떠 있다. 왼쪽 스틱으로 달려 속도를 모아 점프하면 그 별 중력을 벗어나 날아가고, 가까운 별 중력에 끌려 빙 돌다 내려앉는다. 빗나가면 우주로 떠내려가 죽는다. 발 앞 점선이 "지금 뛰면 갈 길"(초록 = 다른 별에 닿음, 빨강 = 위험).
## 나는 [작은 별들 사이를 맨몸으로 건너는 여행자]로서 [달린 속도와 점프 순간이 곧 비행 궤도가 되는 몸] 속에서 [별 주민들의 부탁을 별과 별 사이로 날라 주]지만 [느리면 못 떠나고, 각도가 틀리면 우주로 떠내려가고, 쿵 내려앉으면 유리가 깨지는 것]을 감수한다.
## 별: 1 풍차(바람 달리기 → 돛, 노란 줄로 첫 비행) → 2 우편(소포를 굴뚝 달의 담 친 집에 공중에서 놓기) → 3 유리꽃(꽃을 들고 친구 달로, 빙 돌다 살살 착지) → 4 노을(얼음 위 속도 맞추기 → 유리 덮개) → 5 장미(빨간 바위 띠를 불 별 중력 새총으로 돌아 덮개를 살살).
## v5 겉모습: 상자 대신 로우폴리. 별은 각진 공(icosphere), 사람·소품은 art/tinyplanet/<이름>.glb+png(없으면 코드가 만든 로우폴리).
## 글은 g/tinyplanet_text.gd 한 곳(한국어·영어, 처음 대사는 Gemini가 쓴 dialogue.json), 소리는 art/tinyplanet_sfx/*.wav(nkido).
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
const HOME_A := 1.8  # v6 1.8 → v7 4.5 → v8 2.8 → v11 1.8 지금 갈 곳(ob_k) 쪽만 (아무 별이나 끌던 것 없앰, 도움 힌트 as_home 때만 모든 별): 방향만 튼다
const CAP_T := 0.5  # v7 0.9 → v8 0.5 잡기: 다른 별 둘레 안에서 옆 속도를 초당 이만큼 깎는다 (안쪽일수록 세게). v11: 지금 갈 곳·도움 힌트 때만 이 값
const CAP_T_LO := 0.25  # v11 갈 곳이 아닌 별: 덜 잡는다 (아무 데나 날다 내려앉지 않게)
const CAP_R := 1.7  # v7 3.0 → v8 1.7 잡기: 그 별 쪽으로 더 끄는 힘 (이미 빨리 내려가면 안 끈다)
const CAP_R_LO := 0.9  # v11 갈 곳이 아닌 별
const HOME_Q := 1.3  # v11 끌어주기 둘레: 비켜 지나는 거리 / (끄는 둘레 × 이 값 + 6) (v8 ×2 + 10)
const DROP_SLOW := 0.9  # v11 소포를 들고 굴뚝 달 둘레 안: 옆 속도를 초당 이만큼 더 깎는다 (굴뚝 위에서 놓을 시간)
const LAND_VMAX := 5.5  # v7 4.0 → v8 5.5 (세게 꽂으면 유리가 깨질 수 있게) 잡기: 다른 별 대기 안에서 내려가는 빠르기 한도 (유리는 3 넘으면 금이 조금)
const SAIL_ADD := 2.5  # v7 돛: 틀면서 조금 빨라진다
const SAIL_TURN := 0.62  # v7 돛: 스틱 없이 쓰면 갈 곳 쪽으로 이만큼(라디안)까지 튼다
const TOW_T := 3.0  # v14 2.4 → 3.0. v8 1.5 → 2.4 (천천히 끌려 돌아온다) # v7 우주 미아: 마지막 별로 끌려 돌아가는 시간
const DOT_SC := 0.78  # v7 점선 점 크기 (v6 대비)
const GHOST_SC := 0.5  # v7 "지금 돛/공중 점프하면" 연한 점선 점 크기
const SAIL_POS := Vector2(400, 1165)  # v7 돛 버튼 (날 때만)
const HUD_TOP := 320.0  # v7 화살표가 다니는 화면 칸 (위 HUD 아래, 말풍선 위)
const HUD_BOT := 880.0
const HEART_T := 2.0  # 하트가 보이는 시간
const BUB_BOTTOM := 940.0  # 말풍선 아래 끝 (조작 키트 바로 위)
const RESTART_TXT := ["< 처음부터", "< Restart", "< Start over"]  # 단독판 tofu 의 왼쪽 위 버튼 (v6: 숨김)
const CFG_BODY := "user://tinyplanet_body.cfg"  # 첫 판 안내를 봤나
const START := Vector3(1, 0, 0)
const NPC_D := Vector3(1, 0.12, -0.35)
const HOME_D := Vector3(1, -0.2, -0.22)  # 맡길 물건이 놓인 곳
const TOWER_H := 2.5
const NW := 10  # 담 칸 (장미 별은 하나가 틈)
const MID := Vector3(57, 1, 8)  # 하늘 가운데 (v12: 흩어 놓은 별들의 가운데)
const BOUND := 84.0  # 어느 별에도 안 끌린 채 여기 밖이면 떠내려간다 (+10이면 끝). v12: 가장 먼 별까지 +6 (78 → 84, 여유는 v11 과 같다)
const BELT_A := Vector3(69.9, -0.5, 42.6)  # 지뢰 울타리 (노을 별 → 장미 별 곧은 길을 막는다). v12: 3D — 울타리 판은 그 곧은 길에 수직으로 선다
const BELT_B := Vector3(64.6, -0.5, 24.8)
const ART := "res://art/tinyplanet/"
const SFX := "res://art/tinyplanet_sfx/"
const CREAM := Color("fff6e6")
const NAVY := Color("2b2d42")
const DANGER := Color("e8453c")  # 빨강은 위험에만
const SKIN := Color("ffe3c7")
const ITEM_ART := {"pkg": "parcel", "flower": "glass_flower", "dome": "glass_dome"}
# 별: 0~4 부탁 별, 5 굴뚝 달, 6 친구 달, 7 불 별. v12 "너가 흩뿌려": 높이(y ±20)·깊이를 섞어 흩어 놓았다 (이웃 사이 거리는 v11 과 거의 같다, ±2)
# v11 별 구별: c0 = 그 별의 주인 색 (초록 풍차 · 보라 우편 · 청록 유리꽃 · 주황 노을 · 분홍 장미 · 갈색 굴뚝 · 하늘 친구 · 빨강 불). 이름표·칩·할 일 목록 고리도 이 색
const BD := [
	{"name": "name.windmill", "r": 12.0, "g": 8.0, "grip": 1.19, "acc": 1.0, "at": Vector3(0, 0, 0), "kind": "planet",
		"c0": Color("8fd16a"), "c1": Color("c9efa8"), "sky": Color("d6ecff"), "who": "who.windmill", "body": Color("8fbf5a"), "hat": A, "id": "p1"},
	{"name": "name.post", "r": 8.0, "g": 8.0, "grip": 1.19, "acc": 1.0, "at": Vector3(27.1, 14.1, -22.8), "kind": "planet",
		"c0": Color("a98ff0"), "c1": Color("d9ccff"), "sky": Color("e6dcff"), "who": "who.post", "body": B, "hat": BAD, "id": "p2"},
	{"name": "name.glass", "r": 10.0, "g": 9.0, "grip": 1.19, "acc": 1.0, "at": Vector3(68.1, -9.3, -17.0), "kind": "planet",
		"c0": Color("5fd8bf"), "c1": Color("b8f2e4"), "sky": Color("d6f5ea"), "who": "who.glass", "body": GOOD, "hat": D, "id": "p3"},
	{"name": "name.sunset", "r": 7.0, "g": 8.0, "grip": -0.8, "acc": 0.6, "at": Vector3(91.0, 17.8, 34.2), "kind": "planet",
		"c0": Color("ffa463"), "c1": Color("ffe0c2"), "sky": Color("ffe0c2"), "who": "who.sunset", "body": C, "hat": A, "id": "p4"},
	{"name": "name.rose", "r": 6.0, "g": 7.0, "grip": 1.19, "acc": 1.0, "at": Vector3(51.3, -15.7, 46.1), "kind": "planet",
		"c0": Color("f58bab"), "c1": Color("ffd3e0"), "sky": Color("ffe3ec"), "who": "who.rose", "body": BAD, "hat": GOOD, "id": "p5"},
	{"name": "name.chimney_moon", "r": 3.5, "g": 6.0, "grip": 1.19, "acc": 1.0, "at": Vector3(52.6, 6.9, -39.9), "kind": "moon",
		"c0": Color("c9a27e"), "c1": Color("efdcc4"), "sky": Color("efe8ff"), "who": "who.chimney", "body": WHITE, "hat": WHITE, "id": ""},
	{"name": "name.friend_moon", "r": 3.5, "g": 6.0, "grip": 1.19, "acc": 1.0, "at": Vector3(85.8, 0.1, 9.0), "kind": "moon",
		"c0": Color("7cc4ff"), "c1": Color("cfe9ff"), "sky": Color("e0fff4"), "who": "who.friend", "body": WHITE, "hat": WHITE, "id": ""},
	{"name": "name.fire", "r": 3.0, "g": 40.0, "grip": 1.19, "acc": 1.0, "at": Vector3(79.2, -4.5, 57.4), "kind": "fire",
		"c0": BAD, "c1": A, "sky": Color("ffe8d6"), "who": "", "body": WHITE, "hat": WHITE, "id": ""},
]
# 부탁 (별 번호 = 부탁 번호). 물건은 src 별 HOME_D 에서 받아 tgt 별 tdir 로.
const JOB := [
	{},
	{"item": "pkg", "src": 1, "tgt": 5, "tdir": Vector3(-1, 0.3, 0.35), "tr": 1.7, "frag": false},  # v14 tr 2.1 → 1.7
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
# v13 처음 줌: 시작 화면(모든 별이 한눈에)에서 풍차지기 말을 읽는 동안 천천히 다가간다. intro_k < 0 = 끝남
const INTRO_DUR := 9.0
const NIGHT := Color("0b1030")  # 멀리 떠 있으면 깊은 밤하늘
var intro_k := -1.0
var intro_boost := 0.0  # v14: 1 = 처음 줌 중에 내가 움직이기 시작했다 (그때부터 빨리 마저 다가간다). 탭으로는 안 빨라진다
var intro_p := Vector3.ZERO
var intro_l := Vector3.ZERO
var _fit_c := Vector3.ZERO  # 모든 별을 감싸는 공
var _fit_r := 0.0
var _cg_want := Vector3.ZERO  # 놀이 카메라가 가고 싶은 자리·볼 곳·위
var _cg_look := Vector3.ZERO
var _cg_up := Vector3.UP
var _title_look := Vector3.ZERO
var _sky_c := NIGHT
var _dark := 1.0
var _space_stars: MultiMeshInstance3D
var _space_mat: StandardMaterial3D
# 나
var me: Node3D
var hearts: Array[MeshInstance3D] = []
var item_b: MeshInstance3D
var sail_b: MeshInstance3D
var bag_b: MeshInstance3D
var mark_b: MeshInstance3D  # 공중에서 놓으면 떨어질 자리
var zone_b: MeshInstance3D  # v11 굴뚝 달: 소포를 놓을 노란 동그라미 (들고 있을 때)
var drop_k := -1  # v11 소포를 들고 있으면 굴뚝 달 번호 (그 둘레에서 옆 속도를 더 깎는다), 아니면 -1
var over_tg := false  # v11 지금 놓으면 받을 곳에 떨어진다
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
# v9 순서 자유: 부탁 다섯(0 풍차 · 1 소포 · 2 유리꽃 · 3 노을 띠 · 4 장미 덮개)을 아무 순서로. 물건은 한 번에 하나
var js := PackedInt32Array([0, 0, 0, 0, 0])  # 부탁마다 0 아직 안 만남, 1 하는 중, 2 끝
var ij := -1  # 지금 하늘에 나와 있는 물건의 부탁 번호 (들고 있음·떨어지는 중·어딘가 놓임), 없으면 -1
var fj := -1  # 할 일 칩·화살표가 가리키는 부탁 (땅에 있을 때 가장 가까운 것으로 다시 고른다)
var goal_st := -1  # 그 부탁의 지금 할 일: -1 없음, 0 말 걸기, 1 풍차 바람, 2 물건 받기, 3 배달, 4 노을 띠
var wprog := 0.0  # 풍차 바람 막대
var bprog := 0.0  # 노을 띠 막대
const ITEM_JOBS := [1, 2, 4]  # 물건이 있는 부탁 (물건은 JOB[j].src 별 주민이 준다)
const TODO_IC := ["wind", "pkg", "flower", "band", "dome"]
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
var bub_talk := false  # v12: 주민과 마주 본 말 — 말풍선 탭·엔터·E 로 넘긴다. v14: 놀이는 안 멈춘다 (안 읽어도 된다)
var bub_talk_age := 0.0
var talk_pl := -1  # v14: 대화를 건 주민의 별 (멀어지거나 날거나 별이 바뀌면 대화를 닫는다)
var bub_more: Label  # 말풍선 오른쪽 아래 "▼" (눌러서 넘기기)
var nag := {}  # 상황 말 번호 -> 다시 해도 되는 시각 (같은 잔소리 반복 없음)
var pbar_bg: Panel
var pbar: Panel
var pbar_sb: StyleBoxFlat
var pb_tag: Panel  # v12 부탁 막대 왼쪽 이름표 (그림 + "바람"/"노을")
var pb_ic: Control
var pb_lbl: Label
var pb_kind := ""  # 이름표 그림: wind / band / fire
var _pb_gain := 0.0  # 막대가 늘 때 1 → 줄어들며 막대·이름표가 톡 커진다
const PB_X := 196.0
const PB_W := 460.0
var sim_pts := PackedVector3Array()
# v6: 캡슐 에너지 막대, 하트, 그림자, 점선(MultiMesh), 단독판 왼쪽 위 버튼
var gauge_bg: Panel
var gauge_fill: Panel
var gauge_sb: StyleBoxFlat
var _g_col := Color(0, 0, 0, 0)
var _g_frac := 0.0  # v12 빠르기 고리 (점프 버튼 둘레) 찬 정도 0..1
var _g_zone := Vector2.ZERO  # 고리 위 바람 구간 (시작, 끝) — 풍차 부탁 때만
var _wind_air := 0.0  # v12: 떠오른 뒤에도 바람을 더 세는 남은 초 (작은 뜀에 바람이 끊기지 않게)
const WIND_LO := 0.55  # 바람이 세지는 빠르기 (뜨는 빠르기 대비)
const WIND_MAX := 1.15  # 풍차 고리 끝 = 뜨는 빠르기의 115%
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
const TX := preload("res://g/tinyplanet_text.gd")  # 화면에 나오는 모든 글 (한국어·영어 한 표)
var ui: UI_GD
var fx: FX_GD
var _bodies_on := false  # fx.set_bodies 는 한 번
var _stepped := false  # 이번 프레임 _step 이 돌았나 (안 돌면 _process 가 대신 tick)
var _title_was := false
var bfire := PackedByteArray()  # 별마다 불 별인가 (비행 도움이 매 단계 사전을 안 읽게)
# v7: 할 일 칩·갈 곳 화살표·알림판·연한 점선(공중 한 번)·돛 버튼·우주 미아 구조·빈 하늘 빨리 감기
var chip: Control
var chip_bg: Panel
var chip_sh: Panel
var chip_l: Label
var chip_ic: Control
var _chip_code := -2
var _chip_icon := ""
var _chip_pk := -1  # v11 칩이 가리키는 별 (그림 고리 색)
var chip_age := 9.0
# v11 별 이름표: 발밑 별이 아닌 별 위에 작은 이름표 (별 색 고리 + 할 일 그림 + 이름), 멀거나 가깝거나 화면 가운데면 옅어짐
const TAG_IC := ["wind", "pkg", "flower", "band", "dome", "pkg", "flower", "fire"]
var tag_n: Array[Control] = []
var tag_l: Array[Label] = []
var tag_bg: Array[Panel] = []
var tag_sh: Array[Panel] = []
var tag_ic: Array[Control] = []
var tag_w := PackedFloat32Array()
var _tag_ord: Array[Vector2] = []  # v13 (카메라 거리, 별 번호) 가까운 순
var _tag_rc: Array[Rect2] = []  # v13 이번 프레임에 놓인 이름표 칸
var arrow: Control
var _arrow_on := false
var _arrow_p := Vector2.ZERO
var _arrow_d := Vector2.DOWN
var ban: Control
var ban_bg: Panel
var ban_sh: Panel
var ban_l: Label
var ban_t := 0.0
var ban_age := 0.0
var ghost_mm: MultiMesh
var ghost_pts := PackedVector3Array()
var sail_open := 0.0  # 돛 펴짐 0 → 1
var sail_used := false  # 이번 판에 돛을 써 봤나 (안 썼으면 버튼이 숨쉰다)
var sail_hinted := false
var lost_t := 0.0
var lost_cd := 0.0
var lost_now := false
var air_tip := false
var tow_t := 0.0
var tow_from := Vector3.ZERO
var ff := 1.0  # 빈 하늘 빨리 감기 배수
var sim_why := 0  # _sim 이 -2 를 낸 까닭: 1 떠내려감, 2 불 별·지뢰
var _lost_pts := PackedVector3Array()
var _first_hint := false
var main_lost := false
var tip_t := 0.0
var _sail_shown := false
var _tri3 := PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
# ---- ?debug=1 성능 표 (웹 주소에 debug=1 이 있을 때만) ----
var _dbg: Label
var _dbg_win := 0.0  # 표를 고치는 0.5초 구간
var _dbg_n := 0  # 구간 프레임 수
var _dbg_last := 0  # 지난 _process 시각 (usec)
var _dbg_fmax := 0  # 구간 최대 프레임 간격 (usec)
var _dbg_sum := {}  # 이름 -> 구간 합 (usec)
var _dbg_max := {}  # 이름 -> 구간 최대 (usec)
var _dbg_txt := ""
var _dbg_cb: JavaScriptObject  # window.tpcmd("...") 로 실험 (list·vis·ol·s3d·launch·tp)
var _dbg_nodes: Array = []
var _dbg_np := {}  # 외곽선 끈 재질 -> 원래 next_pass


func _setup() -> void:
	_dpr_cap()
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
	# v12: 위 빠르기 막대가 점프 버튼 고리로 갔다 — 부탁 막대가 그 자리로 올라오고, 왼쪽에 그림+이름표(바람·노을)를 단다
	pbar_bg = _capsule(hud2, Rect2(PB_X, 202, PB_W, 30), CREAM, 4, NAVY)
	pbar_bg.pivot_offset = Vector2(PB_W * 0.5, 15)
	pbar = _capsule(pbar_bg, Rect2(5, 5, 12, 20), Color("ffd166"), 0, NAVY)
	pbar_sb = pbar.get_theme_stylebox("panel") as StyleBoxFlat
	pbar_bg.visible = false
	pb_tag = _capsule(hud2, Rect2(60, 192, 128, 50), CREAM, 4, NAVY)
	pb_tag.pivot_offset = Vector2(64, 25)
	pb_tag.visible = false
	var pbi := Control.new()
	pbi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pbi.size = Vector2(50, 50)
	pbi.draw.connect(_pb_icon_draw.bind(pbi))
	pb_tag.add_child(pbi)
	pb_ic = pbi
	var ls := LabelSettings.new()
	ls.font = _font
	ls.font_size = 24
	ls.font_color = NAVY
	pb_lbl = Label.new()
	pb_lbl.label_settings = ls
	pb_lbl.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	pb_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pb_lbl.position = Vector2(52, 8)
	pb_lbl.size = Vector2(70, 34)
	pb_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pb_tag.add_child(pb_lbl)
	_bub_build()
	_tags_build()
	_v7_hud_build()
	_dbg_build()


## v8 성능 (웹): 고해상도 폰(devicePixelRatio 3 등)은 화면 픽셀을 다 그리면 GPU 가 벅차다.
## 놀이 화면 폭이 약 800px(설계 720px 보다 조금 크게)을 넘지 않게 브라우저가 알려 주는 픽셀 배율을 낮춘다.
## Godot 웹은 매 프레임 이 값으로 캔버스 크기를 정한다. 주소에 hires=1 이면 그대로.
func _dpr_cap() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval("""(function(){
	if (window.__tpDpr || location.search.indexOf('hires=1') >= 0) return;
	var ds = Object.getOwnPropertyDescriptor(window, 'devicePixelRatio') || Object.getOwnPropertyDescriptor(Window.prototype, 'devicePixelRatio');
	if (!ds || !ds.get) return;
	var g = ds.get;
	window.__tpDpr = true;
	Object.defineProperty(window, 'devicePixelRatio', {configurable: true, get: function(){
		var d = g.call(window) || 1;
		var gw = Math.min(window.innerWidth, window.innerHeight * 0.5625);
		return Math.min(d, Math.max(1, 800 / Math.max(gw, 1)));
	}});
})();""", true)


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
	bub_more = _bub_label(24, NAVY)
	bub_more.text = "▼"
	bub_more.visible = false


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
	# v7: 왕눈 주민 (별마다 다른 몸). 몸은 한 메시, 눈동자만 따로 움직여 나를 쳐다본다
	var v := 4 if bk == 6 else clampi(bk, 0, 3)
	var vb := Node3D.new()
	n.add_child(vb)
	vb.position = Vector3(0, lift, 0)
	_proc("vil_%d" % v, Callable(self, "_shape_vil").bind(v, body, hat), vb)
	var core: Array = VIL[v].core
	var ri := 0
	for e: Array in VIL[v].eyes:
		var er: float = e[1]
		var eg := Node3D.new()
		vb.add_child(eg)
		eg.position = e[0]
		var w := _proc("eye_white", Callable(self, "_shape_eye_white"), eg)
		w.scale = Vector3.ONE * er
		var pu := _proc("pupil", Callable(self, "_shape_pupil"), eg)
		pu.scale = Vector3.ONE * er * 0.5
		pu.position = Vector3(0, 0, -er * 0.62)
		var roam: bool = e[2]
		var c0: Vector3 = core[0]
		# 떠도는 눈마다 따라오는 방향을 조금씩 비튼다 (겹치지 않게, 주민마다 다르게)
		var off := (float(ri) - 0.5) * 0.9 + float(bk) * 0.37 if roam else 0.0
		if roam:
			ri += 1
		vil_pupils.append([eg, pu, er, vb, roam, c0, core[1], ((e[0] as Vector3) - c0).normalized(), off])
	vil_bobs.append([vb, lift, float(bk) * 1.7, bk])  # [3] = 별 번호 (멀면 숨김, _lod)
	npc_mark = _ushape("gem", D, n)
	npc_mark.position = Vector3(0, 2.9, 0)
	npc_mark.scale = Vector3(0.45, 0.95, 0.45)
	return n


## 포스티 조립: 몸(눌림 스프링) · 입 · 왕눈 둘 · 정수리 편지 · 옆 깃발 · 국수 다리 둘(허벅지 → 정강이+발)
func _build_posty() -> void:
	p_body = Node3D.new()
	me_body.add_child(p_body)
	p_body.position = Vector3(0, HIP_Y - 0.03, 0)
	_proc("posty_body", Callable(self, "_shape_posty_body"), p_body)
	p_mouth = _proc("posty_mouth", Callable(self, "_shape_posty_mouth"), p_body)
	p_mouth.position = Vector3(0, 0.3, -0.35)
	p_eyes.clear()
	p_pupils.clear()
	# v9: 눈 둘을 세로로 — 위 눈은 정수리에 솟고 아래 눈은 앞 얼굴에
	for ey: Array in [[Vector3(0, 0.9, -0.06), 0.16], [Vector3(0, 0.62, -0.3), 0.13]]:
		var e := Node3D.new()
		p_body.add_child(e)
		e.position = ey[0]
		var w := _proc("eye_white", Callable(self, "_shape_eye_white"), e)
		w.scale = Vector3.ONE * float(ey[1])
		var pu := _proc("pupil", Callable(self, "_shape_pupil"), e)
		pu.scale = Vector3.ONE * 0.08
		pu.position = Vector3(0, 0, -0.11)
		p_eyes.append(e)
		p_pupils.append(pu)
	p_letter = _proc("posty_letter", Callable(self, "_shape_posty_letter"), p_body)
	p_letter.position = Vector3(0, 0.84, 0.13)
	p_flag = _proc("posty_flag", Callable(self, "_shape_posty_flag"), p_body)
	p_flag.position = Vector3(0.39, 0.45, 0.05)
	p_flag.rotation.x = PI / 2.0
	p_thighs.clear()
	p_shins.clear()
	for sx: float in [-0.14, 0.14]:
		var th := Node3D.new()
		me_body.add_child(th)
		th.position = Vector3(sx, HIP_Y, 0)
		_proc("thigh", Callable(self, "_shape_thigh"), th)
		var sh := Node3D.new()
		th.add_child(sh)
		sh.position = Vector3(0, -THIGH, 0)
		_proc("shin", Callable(self, "_shape_shin"), sh)
		p_thighs.append(th)
		p_shins.append(sh)
	pup_off = Vector3.ZERO
	pup_v = Vector3.ZERO
	sq = 0.0
	sq_v = 0.0
	mouth_o = 0.0
	was_ground = true


var npc_mark: MeshInstance3D
var bk := 0  # 짓는 중인 별
# v7 캐릭터 부품 (포스티)
var p_body: Node3D
var p_mouth: MeshInstance3D
var p_eyes: Array[Node3D] = []
var p_pupils: Array[MeshInstance3D] = []
var p_letter: MeshInstance3D
var p_flag: MeshInstance3D
var p_thighs: Array[Node3D] = []
var p_shins: Array[Node3D] = []
var pup_off := Vector3.ZERO  # 눈동자 스프링 (젤리 여운)
var pup_v := Vector3.ZERO
var sq := 0.0  # 몸 눌림 스프링 (+ 늘어남, - 눌림)
var sq_v := 0.0
var mouth_o := 0.0
var was_ground := true
var vil_pupils: Array = []  # [눈 노드, 눈동자, 반지름, 몸 노드, 떠도나, 몸 겉 가운데, 몸 겉 반지름, 지금 방향, 비틀기]
var vil_bobs: Array = []  # [몸 노드, 바닥 높이, 위상]


func _reset() -> void:
	rng.randomize()
	lives = 3
	has_sail = false
	die_t = 0.0
	fin_t = 0.0
	bub_t = 0.0
	bub_talk = false
	intro_k = -1.0
	intro_boost = 0.0
	_fit_r = 0.0
	clock = 0.0
	hud2.visible = true
	_btns.erase("drop")
	_btns.erase("sail")
	_sail_shown = false
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
		# v7: 불 별 끄는 둘레 16 → 18 (중력 40, 휘는 게 보이게)
		bsoi.append(18.0 if d.kind == "fire" else maxf(2.2 * r, 13.5))
		batm.append(0.0 if d.kind == "fire" else maxf(1.75 * r, r + 4.5))
		bfire.append(1 if d.kind == "fire" else 0)
	here = Node3D.new()
	world.add_child(here)
	# 나: 여행자 모델(망토·목도리), 목숨 3, 든 물건, 돛, 우편 가방
	me = Node3D.new()
	world.add_child(me)
	me_body = Node3D.new()
	me.add_child(me_body)
	_build_posty()
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
	sail_b.position = Vector3(0, 1.0, 0.42)
	sail_b.visible = false
	bag_b = _proc("bag", Callable(self, "_shape_bag"), me_body)
	bag_b.position = Vector3(-0.44, 0.95, 0.0)
	bag_b.visible = false
	mark_b = _ushape("disc", D, here)
	mark_b.visible = false
	over_tg = false
	drop_k = -1
	zone_b = null  # _build 가 굴뚝 달에 새로 짓는다
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
	# v7: "지금 돛(공중 점프)을 쓰면" 연한 점선 — 같은 점, 작고 옅게
	ghost_mm = MultiMesh.new()
	ghost_mm.transform_format = MultiMesh.TRANSFORM_3D
	ghost_mm.use_colors = true
	ghost_mm.mesh = _dots_mesh()
	ghost_mm.instance_count = ND
	ghost_mm.visible_instance_count = 0
	var gmi := MultiMeshInstance3D.new()
	gmi.multimesh = ghost_mm
	gmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(gmi)
	sim_cd = 0
	sim_show = false
	_dot_tmp.resize(ND)
	_help_reset()
	sail_open = 0.0
	sail_used = false
	sail_hinted = false
	tow_t = 0.0
	lost_t = 0.0
	lost_now = false
	ff = 1.0
	ban_t = 0.0
	_chip_code = -2
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
	beacon = _ushape("arrow", D)  # v14 "긴 노란 막대 정체를 모르겠어" → 아래를 가리키는 큰 노란 화살표
	ig_b = _art("parcel", Callable())
	ig_b.visible = false
	# 부탁
	js = PackedInt32Array([0, 0, 0, 0, 0])
	ij = -1
	fj = -1
	goal_st = -1
	wprog = 0.0
	bprog = 0.0
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
	_respawn()
	heart_t = 0.0  # 첫 시작엔 하트를 안 띄운다
	cam_up = START
	lookd = Vector3.FORWARD
	# v8: 시작 글은 위 목표 칸 + 풍차지기 말풍선 둘뿐 (별 이름·소개 알림판은 겹쳐 혼란스러워 뺐다)
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
	vil_pupils.clear()
	vil_bobs.clear()
	deco_n.clear()
	deco_on.clear()
	spin = null
	smoke_n = null
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
				# v11 별 구별: 풍차를 1.5배 (다른 별에서도 풍차가 보이게)
				_stand("windmill_tower", Vector3.UP, WM_SC)
				_shadow_q(0, Vector3.UP, 2.2 * WM_SC)
				blades = Node3D.new()
				n.add_child(blades)
				blades.position = Vector3(0, _sr(0, Vector3.UP) + 8.2 * WM_SC, 0.7 * WM_SC)
				blades.scale = Vector3.ONE * WM_SC
				_art("windmill_blades", Callable(), blades)
			3:
				# 노을 아이의 의자와 노을 띠
				_stand("stool", NPC_D + Vector3(0, 0, 0.12), 1.0)
				for j in 5:
					band_bs.append(_sbox(Vector3.RIGHT, 0.2, Vector3.ONE, WHITE))
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
				# 굴뚝 집과 담. v11 "굴뚝 너무 어려워": 담을 넓고 낮게(1.8/2.6 → 2.7/1.3), 틈 하나(제자리) — 내려서 걸어 들어가도 된다.
				# 놓을 자리(노란 동그라미, 소포를 들 때만)는 tr 2.1 로 넓혔다
				# v14 "걸어 들어가니 굴뚝 의미가 없다": 틈 없는 담(r 2.4, 높이 2.2) — 공중에서 놓아야 한다. 놓을 자리 tr 1.7
				var c: Vector3 = (JOB[1].tdir as Vector3).normalized()
				_stand("chimney_house", c, 1.0)
				_shadow_q(5, c, 1.5)
				_ring(5, c, 2.4, false, 2.2, false)
				_zone(5, c, float(JOB[1].tr), n)
			6:
				# 꽃 친구
				npcs[6] = _person(JOB[2].tdir, Color("f783ac"), C)
				npc_mark.visible = false
				_shadow_q(6, JOB[2].tdir, 0.7)
		_landmark(k, n)
		_deco(k, n)
	# v7 지뢰 울타리 (옛 빨간 바위 띠): 노을 별 → 장미 별 곧은 길을 막는다. 덩어리로 뭉쳐 "끌지 않는 빨간 별"처럼 보이던 것을
	# 띄엄띄엄 떨어진 가시 지뢰 18개(3층 × 6줄, MultiMesh 하나) + 그 사이를 잇는 가는 빨간 줄(한 메시)로. 줄 사이도 닿으면 죽는 칸이다
	var r2 := RandomNumberGenerator.new()
	r2.seed = 991
	var bmm := _mm("mine", 18, world)
	var bi := 0
	var nodes_f: Array[Vector3] = []
	for j in 6:
		var q := BELT_A.lerp(BELT_B, (j + 0.5) / 6.0)
		for ly: float in [-4.0, 0.0, 4.0]:
			var bs := Basis(Vector3(r2.randf_range(-1, 1), 1, r2.randf_range(-1, 1)).normalized(), r2.randf() * TAU).scaled(Vector3.ONE * 1.25)
			bmm.set_instance_transform(bi, Transform3D(bs, q + _bv * ly))  # v12: 판의 높이 축으로 (y 고정 아님)
			nodes_f.append(q + _bv * ly)
			bi += 1
		belt.append(q)
	_begin()
	for j in 6:
		for l in 3:
			var a := nodes_f[j * 3 + l]
			if j < 5:
				var b := nodes_f[(j + 1) * 3 + l]
				_cyl(a, b - a, 0.07, 0.07, a.distance_to(b), 4, DANGER, DANGER)
			# v11 지도 정리: 세로 줄은 뺐다 (가로 줄 셋 + 지뢰만, 막힌 곳은 그대로)
	var fence := MeshInstance3D.new()
	fence.mesh = _end_mesh()
	fence.material_override = _vc(false)
	fence.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(fence)
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


## v12 울타리 판의 축 (별이 흩어져 y=0 평면이 아니다): x = A→B 가로, y = 판의 높이 축(노을→장미 길과 가로에 수직), z = 판에 수직
var _bu := (BELT_B - BELT_A).normalized()
var _bv := _bu.cross(((BD[4].at as Vector3) - (BD[3].at as Vector3)).normalized()).normalized()
var _bn := _bu.cross(_bv).normalized()
var _blen := BELT_A.distance_to(BELT_B)


## 울타리 판 좌표 (A 가 원점): x 가로 0..길이, y 높이, z 판 앞뒤
func _bl(w: Vector3) -> Vector3:
	var r := w - BELT_A
	return Vector3(r.dot(_bu), r.dot(_bv), r.dot(_bn))


func _in_belt(w: Vector3) -> bool:
	var l := _bl(w)
	if absf(l.y) > 6.0:
		return false
	var tt := clampf(l.x / _blen, -0.08, 1.08)
	return Vector2(l.x - _blen * tt, l.z).length() < 2.3


## 발밑 별을 바꾼다 (위치는 새 별 가운데 기준으로 옮긴다)
func _switch(k: int) -> void:
	p += bc[cur] - bc[k]
	cur = k
	P = BD[k]
	R = br[k]
	gp = bg[k]
	mu = bmu[k]
	pl = nodes[k]
	here.position = bc[k]  # v13: 하늘색은 _sky_tint 가 카메라 거리로 부드럽게 바꾼다
	for i in NM:
		mph[i] = 0
		mb[i].visible = false
		msh[i].visible = false


func _ring(k: int, c: Vector3, rr: float, gap: bool, h: float, spin := true) -> void:
	var bs := _basis(c)
	var cnt := NW - 1 if gap else NW + 2
	# v6: 담 조각을 MultiMesh 하나로 (별의 자식이라 별 기준 좌표). v11 spin = false 면 틈이 제자리 (굴뚝 달)
	rings[k] = {"c": c, "r": rr, "gap": gap, "e1": bs.x, "e2": bs.z, "mm": _mm("wall", cnt, pl), "n": cnt, "h": h, "spin": spin}
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
		var th := (gap_a if rg.gap and rg.spin else 0.0) + (j + 0.5) * step
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
	tow_t = 0.0
	lost_t = 0.0
	lost_now = false
	ff = 1.0
	sail_open = 0.0
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
## v12: talk -1 = 저절로 고름 (주민이 곁에서 하는 말이면 대화), 1 = 대화, 0 = 저절로 사라지는 말
func _say(who: String, s: String, dur: float, talk := -1) -> void:
	if s == "":
		return
	var tk := talk == 1 or (talk == -1 and _talk_ok(who))
	# v11: 글 안의 "|" = 말풍선 나눔. 앞 조각을 지금, 나머지는 바로 이어서 (대기열 맨 앞)
	var parts := tr(s).split("|", false)
	if parts.size() > 1:
		for i in range(parts.size() - 1, 0, -1):
			bub_q.push_front([who, parts[i].strip_edges(), dur, 1 if tk else 0])
		s = parts[0].strip_edges()
	bub_who = who
	bub_s = tr(s)
	bub_talk = tk
	bub_talk_age = 0.0
	if tk:
		talk_pl = cur  # v14
		bub_t = 1.0  # 대화 중엔 줄지 않는다 (_talk_next 가 닫는다)
	else:
		bub_t = clampf(bub_s.length() * 0.06, 2.5, 7.0)
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
	var h := th + nh + pady * 2.0 + (14.0 if bub_talk else 0.0)
	bub_more.visible = bub_talk
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
	if bub_talk:
		bub_more.size = Vector2(28, 28)
		bub_more.position = Vector2(bub.size.x - 38.0, bub.size.y - 36.0 - absf(sin(bub_age * 5.0)) * 6.0)


## v12: 주민이 곁에서 하는 말인가 (주민 이름 + 지금 별의 주민 8m 안). 내 혼잣말·안내는 아니다
func _talk_ok(who: String) -> bool:
	if who == "" or who == _tx("who.me"):
		return false
	if not npcs.has(cur):
		return false
	return p.distance_to((npcs[cur] as Node3D).position) < 8.0


## v12: 대화 말풍선 넘기기 — 다음 대화가 기다리면 바로 그것을, 아니면 옅어지며 닫고 놀이가 다시 돈다
func _talk_next() -> void:
	if not bub_talk:
		return
	play("tap")
	bub_talk = false
	# v14: 넘겨도 처음 줌은 빨라지지 않는다 (intro_boost 뺌)
	if not bub_q.is_empty():
		var q: Array = bub_q[0]
		if q.size() > 3 and int(q[3]) == 1:
			bub_q.pop_front()
			_say(str(q[0]), str(q[1]), float(q[2]), 1)
			return
	bub_more.visible = false
	bub_t = 0.25


## v14: 대화가 떠 있는 동안 (_hud 가 부른다, 놀이는 그대로 돈다). 헤드리스(스모크)는 8초 뒤 저절로 넘긴다.
## 주민에게서 9m 넘게 멀어지거나, 날아오르거나, 별이 바뀌면 대화를 닫고 이어질 대화도 버린다
func _talk_wait(dt: float) -> void:
	if not bub_talk:
		return
	bub_talk_age += dt
	var gone := cur != talk_pl or (not grounded and fly_t > 1.0)
	if not gone and npcs.has(talk_pl):
		gone = p.distance_to((npcs[talk_pl] as Node3D).position) > 9.0
	if gone:
		_talk_close()
		return
	if DisplayServer.get_name() == "headless" and bub_talk_age > 8.0:
		_talk_next()


## v14: 대화 닫기 — 지금 말풍선은 옅어지고, 대기열의 대화(q[3]==1)는 버린다 (혼잣말·안내는 남긴다)
func _talk_close() -> void:
	bub_talk = false
	var keep: Array = []
	for q: Array in bub_q:
		if not (q.size() > 3 and int(q[3]) == 1):
			keep.append(q)
	bub_q = keep
	bub_more.visible = false
	bub_t = minf(bub_t, 0.25)


## v14: 대화 중 누름 — 말풍선 위(가장자리 조금 여유)만 넘기고 그 누름은 먹는다. 다른 곳은 그냥 놀이 (점프·스틱)
func _talk_tap(event: InputEvent) -> bool:
	var at := Vector2(-1, -1)
	if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		at = (event as InputEventScreenTouch).position
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and mb.device != InputEvent.DEVICE_ID_EMULATION:
			at = mb.position
	if at.x < 0.0:
		return false
	if over or _rating or ui.title_visible() or ui.todo_open() or (_howto_box and _howto_box.visible):
		return false
	if (at.x < 180.0 and at.y < 100.0) or _RATE_BTN.has_point(at):
		return false
	if not bub.visible or not Rect2(bub.position, bub.size).grow(16.0).has_point(at):
		return false  # v14: 말풍선 밖은 넘기지 않는다
	_talk_next()
	return true


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
		bub_q.append([who, s, dur, 1 if _talk_ok(who) else 0])


## 나의 짧은 혼잣말 (react.*). 주민 말을 끊지 않고, 자주 안 한다. force = 죽은 이유 안내
func _react(key: String, once := false, force := false) -> void:
	if once and said.has(key):
		return
	if not TX.TEXT.has("react." + key):
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
## 비행 도움 (날기와 점선 계산이 같이 쓴다). dm = 지금 가장 세게 끄는 별(-1 없음), src = 이번 비행을 띄운 별.
## 1) 잡기 (v7): 다른 별(불 별 빼고) 둘레 안이면 옆 속도를 깎고 그 별 쪽으로 더 끌어 빙 돌다 내려앉게. 대기 안에선 내려가는 빠르기 한도.
## 2) 순항: 어느 별에도 안 끌리거나, 발밑 별을 벗어날 힘이 있고 대기 위면 CRUISE 까지 앞으로 밀어 준다 (높이 떠서 느릿느릿 없음)
## 3) 끌어당김: 벗어나는 중이면, 이대로 가면 가장 가까이 지나갈 별(불 별·떠난 별 빼고, 지뢰 울타리 너머 빼고, 지금 갈 곳은 더 잘) 쪽으로 방향을 튼다
func _assist(w: Vector3, v: Vector3, dm: int, src: int, h: float) -> Vector3:
	var spd := v.length()
	if spd < 0.5:
		return v
	if dm >= 0 and dm != src and bfire[dm] == 0:
		var rel := w - bc[dm]
		var r := rel.length()
		if r > 0.01:
			var up := rel / r
			var vr := v.dot(up)
			var tanv := v - up * vr
			var k := clampf((bsoi[dm] - r) / (bsoi[dm] * 0.5), 0.0, 1.0)  # 둘레 가장자리 0 → 안쪽 1
			var aim := dm == ob_k or as_home > 0.0  # v11: 지금 갈 곳(또는 도움 힌트 중)만 원래만큼 잡는다
			var ct := (CAP_T if aim else CAP_T_LO) + (DROP_SLOW if dm == drop_k else 0.0)
			tanv *= maxf(0.0, 1.0 - ct * k * h)
			if vr > -2.0:
				vr -= (CAP_R if aim else CAP_R_LO) * k * h
			if r < batm[dm]:
				vr = maxf(vr, -LAND_VMAX * (1.0 - 0.5 * as_vmax))  # v10 as_vmax: 유리 도움 (2.75 밑이면 금이 안 간다)
			return tanv + up * vr
	var vh := v / spd
	var free := _is_free(w, spd, dm)
	if free and spd < CRUISE:
		spd = minf(spd + 6.0 * h, CRUISE)
		v = vh * spd
	if dm >= 0 and dm == src and not free:
		return v
	# 가장 가까이 지나갈 별: q 가 가장 작은 별부터 지뢰 울타리 검사 (예전처럼 별마다 검사하지 않는다 — 고르는 별은 같다)
	# v11: 보통은 지금 갈 곳(ob_k) 하나만 끈다 (아무 별이나 지나가면 끌려 내려앉던 것 없앰). 도움 힌트(as_home) 중엔 예전처럼 모든 별
	var any := as_home > 0.0
	if not any and (ob_k < 0 or ob_k == src):
		return v
	var best := -1
	var bm := 1.0
	var bmv := Vector3.ZERO
	var blocked := 0
	while true:
		var cand := -1
		var cq := 1.0
		var cm := Vector3.ZERO
		for j in bc.size():
			if ((blocked >> j) & 1) == 1 or bfire[j] == 1 or (j == src and dm == src) or (not any and j != ob_k):
				continue
			var rel := bc[j] - w
			var t := rel.dot(vh)
			if t <= 0.0:
				continue
			var m := rel - vh * t
			var q := m.length() / (bsoi[j] * (HOME_Q + 0.7 * as_home) + 6.0 + 4.0 * as_home)
			if j == ob_k:
				q *= 0.6  # 지금 갈 곳은 더 잘 끈다
			if q < cq:
				cq = q
				cand = j
				cm = m
		if cand < 0:
			break
		if not _seg_belt(w, bc[cand]):
			best = cand
			bm = cq
			bmv = cm
			break
		blocked |= 1 << cand
	if best >= 0:
		var ml := bmv.length()
		if ml > br[best] * 0.5:
			v += bmv / ml * (HOME_A * (1.0 + 2.0 * as_home) * clampf((1.0 - bm) * 2.0, 0.0, 1.0) * h)  # v10 as_home: 도움 힌트 끌어주기
			v = v.normalized() * spd
	return v


## 빈 하늘인가: 어느 별에도 안 끌리거나, 끄는 별의 대기 위에서 그 별을 벗어날 힘이 있다
func _is_free(w: Vector3, spd: float, dm: int) -> bool:
	if dm < 0:
		return true
	var r := (w - bc[dm]).length()
	return r > maxf(batm[dm], br[dm] + 3.0) and 0.5 * spd * spd - bmu[dm] / r > -bmu[dm] / bsoi[dm]


## a → b 곧은 길이 지뢰 울타리 가까이(3.4 안)를 지나나 (위아래로 멀리 비켜 가면 아님)
func _seg_belt(a: Vector3, b: Vector3) -> bool:
	# v12: 울타리 판 좌표로 옮겨서 예전(y=0 평면) 셈 그대로
	var la := _bl(a)
	var lb := _bl(b)
	if minf(absf(la.y), absf(lb.y)) > 8.0 and la.y * lb.y > 0.0:
		return false
	# 빠른 거름: 두 선분의 상자(3.4 넓힘)가 안 겹치면 가까이 지날 수 없다 (점선 계산이 매 단계 부른다)
	if maxf(la.x, lb.x) < -3.4 or minf(la.x, lb.x) > _blen + 3.4 or maxf(la.z, lb.z) < -3.4 or minf(la.z, lb.z) > 3.4:
		return false
	var p1 := Vector2(la.x, la.z)
	var p2 := Vector2(lb.x, lb.z)
	var q1 := Vector2.ZERO
	var q2 := Vector2(_blen, 0.0)
	if Geometry2D.segment_intersects_segment(p1, p2, q1, q2) != null:
		return true
	var lim := 3.4 * 3.4
	if p1.distance_squared_to(Geometry2D.get_closest_point_to_segment(p1, q1, q2)) < lim:
		return true
	if p2.distance_squared_to(Geometry2D.get_closest_point_to_segment(p2, q1, q2)) < lim:
		return true
	if q1.distance_squared_to(Geometry2D.get_closest_point_to_segment(q1, p1, p2)) < lim:
		return true
	return q2.distance_squared_to(Geometry2D.get_closest_point_to_segment(q2, p1, p2)) < lim


## fine = true 면 out 에 처음 위치와 매 단계 위치를 다 넣는다 (점선을 매 프레임 그 길 위로 부드럽게 옮길 때)
func _sim(w: Vector3, v: Vector3, k: int, at: float, secs: float, h: float, out: PackedVector3Array, src := -1, fine := false) -> int:
	var n := int(secs / h)
	var every := maxi(1, n / ND)
	out.clear()
	sim_why = 0
	if src < 0:
		src = k
	if fine:
		out.append(w)
	var nb := bc.size()
	for i in n:
		# _gacc + _dominant 를 한 번에 (같은 계산, 별을 한 바퀴만 돈다)
		var acc := Vector3.ZERO
		var dm := -1
		var bf := 0.0
		for j in nb:
			var d := bc[j] - w
			var r := d.length()
			var so := bsoi[j]
			if r >= so:
				continue
			var f := clampf((so - r) / (0.25 * so), 0.0, 1.0)
			if r >= 0.01:
				acc += d / r * (bmu[j] / (r * r) * f)
			var fd := f * bmu[j] / maxf(r * r, 0.01)
			if fd > bf:
				bf = fd
				dm = j
		v += acc * h
		if dm >= 0:
			k = dm
		var rel := w - bc[k]
		if batm[k] > 0.0:
			var rl := rel.length()
			if rl < batm[k]:
				if v.dot(rel) < 0.5 * rl:
					at += h
				v = _air_drag(v, k, rel, at, h)  # 대기 밖이면 _air_drag 는 아무것도 안 한다 (부르지 않는다)
		v = _assist(w, v, dm, src, h)
		w += v * h
		if fine:
			out.append(w)
		elif i % every == every - 1 and out.size() < ND:
			out.append(w)
		if (w - bc[k]).length() <= br[k]:
			if bfire[k] == 1:
				sim_why = 2
				return -2
			return k
		# 지뢰 울타리 (v12: 판 좌표 셈, 내적 셋이라 상자 거름 없이)
		if _in_belt(w):
			sim_why = 2
			return -2
		if dm < 0 and (w - MID).length() > BOUND + 10.0:
			sim_why = 1
			return -2
	return -1


## 앞길 점선: 땅에선 "지금 점프하면", 날 땐 지금 길. 다른 별 초록, 위험 빨강, 제 별로 돌아오면 흰색.
## 점 24개는 MultiMesh 하나. 다른 별에 닿으면 끝 점이 크다. v7: 점 78% 크기.
## 날 때 공중 한 번(돛·공중 점프)이 남았으면 "지금 쓰면 갈 길"을 작고 옅은 점선으로.
## 부드럽게 (v8 성능): 땅에선 매 프레임 계산 (달리면 길 모양이 바뀐다). 날 땐 길 전체(1/30초 단계)를 4프레임에 한 번 계산해 두고,
## 매 프레임 날아간 시간만큼 그 길 위로 점을 옮긴다 (날기와 같은 계산이라 다시 계산해도 안 튄다). 연한 점선은 매 프레임.
const SIM_H := 1.0 / 30.0
const SIM_SECS := 5.5
var sim_fine := PackedVector3Array()  # 날 때 지금 길: [0] = 계산한 순간 위치, [i] = i 단계 뒤
var sim_age := 0.0  # 그 길을 계산한 뒤 날아간 (빨리 감기 포함) 시간
var fly_adv := 0.0  # 이번 프레임 날기에 쓴 시간 (_play 가 넣는다)


func _dots_update(up: Vector3, lift: float) -> void:
	var show := false
	if die_t <= 0.0 and fin_t <= 0.0 and tow_t <= 0.0:
		show = (grounded and (vel.length() > lift * 0.6 or (as_sling > 0.0 and item == "dome"))) or not grounded  # v10: 새총 도움 중엔 땅 점선을 늘
	if not show:
		_dots_off()
		return
	var w := bc[cur] + p
	var lb := cur if grounded else from_b
	if grounded:
		sim_show = true
		sim_cd = 0
		sim_res = _sim(w + up * 0.1, _jump_v(up, vel + up * JUMP), cur, 0.0, SIM_SECS, SIM_H, sim_pts, cur)
		_dots_fill(dots_mm, sim_pts, _dot_col(sim_res, lb), DOT_SC)
		if ghost_mm:
			ghost_mm.visible_instance_count = 0
		return
	sim_age += fly_adv
	sim_cd -= 1
	if not sim_show or sim_cd <= 0:
		sim_cd = 4
		sim_show = true
		sim_age = 0.0
		sim_res = _sim(w, vel, cur, atm_t, SIM_SECS, SIM_H, sim_fine, from_b, true)
	_dots_along(dots_mm, sim_fine, sim_age, _dot_col(sim_res, lb), DOT_SC)
	_ghost_update(w, up, lb)


## 미리 계산한 길(fine) 위에서 age 초 뒤부터 점 간격(_sim 과 같은 시간)마다 점을 놓는다 (사이는 이어서)
func _dots_along(mm: MultiMesh, fine: PackedVector3Array, age: float, col: Color, sc0: float) -> void:
	var n := int(SIM_SECS / SIM_H)
	var gap := float(maxi(1, n / ND)) * SIM_H
	var last := fine.size() - 1
	var cnt := 0
	for m in ND:
		var f := (age + gap * float(m + 1)) / SIM_H
		if f > float(last) + 0.001 or last < 1:
			break
		var i0 := mini(int(f), last - 1)
		_dot_tmp[m] = fine[i0].lerp(fine[i0 + 1], clampf(f - float(i0), 0.0, 1.0))
		cnt += 1
	mm.visible_instance_count = cnt
	for i in cnt:
		var sc := sc0
		if i == cnt - 1 and col == GOOD:
			sc = sc0 * 1.9
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3(sc, sc, sc)), _dot_tmp[i]))
		mm.set_instance_color(i, col)


var _dot_tmp := PackedVector3Array()


## 점선 색: 닿는 별이 다른 별이면 초록, 위험 빨강, 그 밖(제 별로 돌아옴·아직 날고 있음) 흰색
func _dot_col(res: int, lb: int) -> Color:
	if res == -2:
		return BAD
	if res >= 0 and res != lb:
		return GOOD
	return WHITE


func _dots_fill(mm: MultiMesh, pts: PackedVector3Array, col: Color, sc0: float) -> void:
	var n := mini(pts.size(), ND)
	mm.visible_instance_count = n
	for i in n:
		var sc := sc0
		if i == n - 1 and col == GOOD:
			sc = sc0 * 1.9
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3(sc, sc, sc)), pts[i]))
		mm.set_instance_color(i, col)


## 연한 점선: 지금 공중 한 번을 쓰면 (돛이면 스틱 쪽, 안 밀면 갈 곳 쪽 / 돛이 없으면 위로 공중 점프)
func _ghost_update(w: Vector3, up: Vector3, lb: int) -> void:
	if ghost_mm == null:
		return
	if grounded or airjump:
		ghost_mm.visible_instance_count = 0
		return
	var r := _sim(w, _air_v(w, vel, up), cur, atm_t, 5.5, 1.0 / 30.0, ghost_pts, from_b)
	var col := _dot_col(r, lb)
	_dots_fill(ghost_mm, ghost_pts, col.lerp(WHITE, 0.4) if col != WHITE else Color("dfe7ff"), GHOST_SC)


func _dots_off() -> void:
	sim_show = false
	sim_cd = 0
	if dots_mm:
		dots_mm.visible_instance_count = 0
	if ghost_mm:
		ghost_mm.visible_instance_count = 0


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
	var ax := _lane_axes(0, 1)
	for sg: float in [1.0, -1.0]:
		for i in 48:
			var a := TAU * i / 48.0
			var d := ax[0] * cos(a) + ax[1] * sin(a)
			var tg := (ax[1] * cos(a) - ax[0] * sin(a)) * sg
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
		var d := ax[0] * cos(a) + ax[1] * sin(a)
		_sbox(d, 0.2, Vector3(1.6, 0.2, 1.6), GOOD if j == 5 else D)
	pl = nodes[cur]
	R = br[cur]


## v12 별이 흩어져(y=0 평면 아님) 발사 원을 적도 대신 src → tgt 방향을 품은 큰 원으로: [가로 축, 갈 곳 쪽 축]
func _lane_axes(src: int, tgt: int) -> Array[Vector3]:
	var t := (bc[tgt] - bc[src]).normalized()
	var s := t.cross(Vector3.UP)
	if s.length() < 0.1:
		s = t.cross(Vector3.RIGHT)
	var out: Array[Vector3] = [s.normalized(), t]
	return out


func _turn(a: Vector3, b: Vector3, t: float) -> Vector3:
	var r := a.slerp(b, t)
	if not r.is_finite() or r.length() < 0.1:
		return b.normalized()
	return r.normalized()


## 매 프레임: 시작 화면이면 하늘을 천천히 돌고, 아니면 놀이. 끝에 ui·fx 에 상태를 넘긴다 (fx 는 _camera 뒤)
## PC 키보드 (플레이테스트용): WASD·화살표 = 조이스틱, 스페이스 = 점프(날 땐 날다리), F·E = 놓기, Tab·Q = 할 일 목록, Enter = 시작
var _kb_move := false
var _kb_prev := {}


func _kb_edge(k: Key) -> bool:
	var on := Input.is_physical_key_pressed(k)
	var was: bool = _kb_prev.get(k, false)
	_kb_prev[k] = on
	return on and not was


func _keyboard() -> void:
	var v := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		v.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		v.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		v.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		v.y += 1.0
	if v != Vector2.ZERO:
		kit_move = v.normalized()
		_kb_move = true
	elif _kb_move:
		kit_move = Vector2.ZERO
		_kb_move = false
	var sp := _kb_edge(KEY_SPACE)
	var en := _kb_edge(KEY_ENTER)
	var kf := _kb_edge(KEY_F)
	var ke := _kb_edge(KEY_E)
	# v14: 주민 말이 떠 있으면 엔터·E = 다음 말. 스페이스는 늘 점프, F 는 늘 놓기 (놀이는 안 멈춘다)
	if bub_talk and not ui.title_visible() and not ui.todo_open():
		if en or ke:
			_talk_next()
		ke = false
	if sp:
		_justs["jump"] = true
		if _btns.has("sail"):
			_justs["sail"] = true
	if kf or ke:
		_justs["drop"] = true
	if _kb_edge(KEY_TAB) or _kb_edge(KEY_Q):
		ui.key_todo()
	if en and ui.title_visible():
		ui.key_start()


func _step(dt: float) -> void:
	_stepped = true
	_keyboard()
	var t0 := Time.get_ticks_usec() if _dbg else 0
	if ui.title_visible():
		clock += dt
		_title_cam(dt)
	elif ui.todo_open():
		pass  # v9: 할 일 목록이 떠 있는 동안 놀이는 멈춘다
	else:  # v14: 주민 말이 떠 있어도 놀이는 돈다 (_hud → _talk_wait)
		_play(dt)
	_lod()
	_post(dt)
	_dbg_add("step", t0)


func _post(dt: float) -> void:
	var s := _state()
	var t0 := Time.get_ticks_usec() if _dbg else 0
	_sky_tint(dt)
	ui.tick(dt, s)
	t0 = _dbg_add("ui.tick", t0)
	fx.tick(dt, s)
	_dbg_add("fx.tick", t0)


## 시작 화면 카메라: 하늘 가운데(MID)를 높이 떠서 천천히 돈다 (별들이 한눈에)
## v13: 모든 별·달을 감싸는 공에 화면 폭을 맞춘 거리에서. 아래 40%(말풍선·조작)는 비우고 별들은 위쪽 60%에
func _title_cam(_dt: float) -> void:
	_fit()
	if _fit_r <= 0.0:
		return
	var a := clock * 0.07 + 0.6
	var el := 0.39 + sin(clock * 0.21) * 0.05
	var dir := Vector3(cos(a) * cos(el), sin(el), sin(a) * cos(el))
	var vp := get_viewport().get_visible_rect().size
	var asp := vp.x / maxf(vp.y, 1.0)
	var th := tan(deg_to_rad(cam.fov * 0.5))
	var tv := th / maxf(asp, 0.01)
	if cam.keep_aspect == Camera3D.KEEP_HEIGHT:
		tv = th
		th = tv * asp
	var lim := minf(th, tv * 0.6)
	var d := _fit_r * 1.1 / sin(atan(lim))
	cam.position = _fit_c + dir * d
	var u := (Vector3.UP - dir * dir.dot(Vector3.UP)).normalized()
	_title_look = _fit_c - u * d * tv * 0.4
	cam.look_at(_title_look, Vector3.UP)


## 모든 별을 감싸는 공 (가운데·반지름)
func _fit() -> void:
	if _fit_r > 0.0 or bc.is_empty():
		return
	var lo := bc[0] - Vector3.ONE * br[0]
	var hi := bc[0] + Vector3.ONE * br[0]
	for k in bc.size():
		lo = lo.min(bc[k] - Vector3.ONE * br[k])
		hi = hi.max(bc[k] + Vector3.ONE * br[k])
	_fit_c = (lo + hi) * 0.5
	var r := 1.0
	for k in bc.size():
		r = maxf(r, _fit_c.distance_to(bc[k]) + br[k])
	_fit_r = r


## v13: 하늘색 = 가장 가까운 별의 파스텔 하늘 ↔ 깊은 밤 (카메라가 별 겉에서 멀수록 어둡게, 작은 별이 보인다)
func _sky_tint(dt: float) -> void:
	if cam == null or bc.is_empty():
		return
	var cp := cam.global_position
	var dk := 1.0
	var col: Color = P.get("sky", Color("d6ecff"))
	var best := 1e9
	for k in bc.size():
		var r := br[k]
		var s := cp.distance_to(bc[k]) - r
		var a := 4.0 + 0.25 * r
		var b := 20.0 + 1.2 * r
		var t := clampf((s - a) / (b - a), 0.0, 1.0)
		t = 1.0 - (1.0 - t) * (1.0 - t)
		if t < dk:
			dk = t
		if s < best:
			best = s
			col = BD[k].get("sky", col) as Color
	var want := col.lerp(NIGHT, dk)
	var f := minf(1.0, dt * 3.0)
	_sky_c = _sky_c.lerp(want, f)
	_dark = lerpf(_dark, dk, f)
	if env_node:
		env_node.environment.background_color = _sky_c
	if _space_stars and _space_mat:
		var on := _dark > 0.02
		if _space_stars.visible != on:
			_space_stars.visible = on
		if on and absf(_space_mat.albedo_color.a - _dark) > 0.01:
			_space_mat.albedo_color = Color(1, 1, 1, _dark)


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
	_st["paused"] = ui.title_visible() or _rating or over or ui.todo_open()  # v14: 대화는 멈춤이 아니다
	# v9 할 일 목록 버튼: 놀이 중에만, 끝낸 부탁 수
	_st["jobs_done"] = _ndone()
	_st["todo_ok"] = not over and not _rating and fin_t <= 0.0 and hud2 != null and hud2.visible and not ui.title_visible()
	return _st


# ---- v9 할 일 목록 (ui 가 열 때 부른다) ----
## 부탁 다섯 줄: 주민 이름·별 이름·할 일(번역된 글)·상태(0 안 만남, 1 하는 중, 2 끝)·그림 이름
func todo_rows() -> Array:
	var out: Array = []
	for k in 5:
		var task := _tx("todo.p%d" % (k + 1))
		if k == 4 and js[3] < 2:
			task = _tx("todo.p5_wait")
		out.append({"who": tr(BD[k].who), "planet": tr(BD[k].name), "task": task, "st": js[k], "icon": TODO_IC[k], "pcol": _pcol(k)})
	return out


## 들고 있는 물건: [그림 이름, 번역된 이름] (빈손이면 ["", ""])
func todo_held() -> Array:
	if item != "":
		return [item, _tx("item." + item)]
	return ["", ""]


## 할 일 그림을 ui 가 빌려 그린다 (노란 동그라미 위에)
func todo_icon(c: CanvasItem, o: Vector2, s: float, kind: String) -> void:
	_icon(c, o, s, kind)


## 두 도우미에게 같은 일을 알린다
func _emit(nm: String, d := {}) -> void:
	_help_ev(nm, d)
	if ui:
		ui.event(nm, d)
	if fx:
		fx.event(nm, d)


## 시작을 눌러 시작 화면이 닫혔다. v6: 튜토리얼 없음 — 첫 판에만 안내 한 줄 (말풍선, 4초)
func _on_title_start() -> void:
	if not over:
		hud2.visible = true
	# v13: 시작 화면의 먼 자리에서 천천히 다가가기 시작 (대화를 읽는 동안)
	if cam and not bc.is_empty():
		_fit()
		if _title_look == Vector3.ZERO or cam.position.distance_to(_fit_c) < _fit_r:
			_title_cam(0.0)
		intro_p = cam.position
		intro_l = _title_look
		intro_k = 0.0
		intro_boost = 0.0
	# v8: 별 이름·"나는 배달부" 알림판은 뺐다 (글 뭉치가 셋이 겹쳐 혼란). 풍차지기 부탁은 첫 프레임에 바로(_tick), 조작 안내는 그 뒤에
	var cf := ConfigFile.new()
	cf.load(CFG_BODY)
	if not bool(cf.get_value("hint", "first", false)):
		cf.set_value("hint", "first", true)
		cf.save(CFG_BODY)
		_first_hint = true  # 풍차지기 부탁 바로 뒤에 (_tick)


## 시작 화면의 언어 전환이 부른다 (ui: game.set_lang(ko)). 번역을 바꾸고 본체가 그린 글(점프·놓기 버튼, 말풍선)을 고친다.
## Label.text 가 한국어 키인 글(tofu 의 "< 메뉴"·"평가")은 Godot 가 저절로 다시 번역한다. ui 글은 ui.refresh_text 가 고친다.
func set_lang(ko: bool) -> void:
	_lang_pick = "ko" if ko else "en"
	_lang()
	if _btns.has("jump"):
		_btns["jump"].label = _tx("ui.jump")
	if _btns.has("drop"):
		_btns["drop"].label = _tx("ui.drop")
	if _btns.has("sail"):
		_btns["sail"].label = _tx("ui.sail")
	_chip_code = -2
	pb_kind = "-"  # 이름표 글을 다음 프레임에 새 말로
	_tags_text()
	ban_t = 0.0
	if bub and bub_t > 0.0:
		bub_t = 0.0
		bub_talk = false
	if ui and ui.has_method("refresh_text"):
		ui.call("refresh_text")


## 지금 한국어인가
func is_korean() -> bool:
	return not _en


func _play(dt: float) -> void:
	clock += dt
	var t0 := Time.get_ticks_usec() if _dbg else 0
	_hud(dt)
	t0 = _dbg_add("hud", t0)
	_vis(dt)
	_dbg_add("vis+posty", t0)
	_sail_btn(dt)
	_help_tick(dt)
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
	if tow_t > 0.0:
		_tow(dt)
		_camera(dt)
		return
	tower_cd -= dt
	bump_cd -= dt
	if grounded:
		ff = 1.0
		_ground(dt, p.normalized())
	else:
		# v7 빈 하늘 빨리 감기: 어느 별 대기에도 안 걸리고 벗어나는 중이면 시간을 2.2배로 (느릿느릿 바라보기 없음)
		var w0 := bc[cur] + p
		var fast := fly_t > 0.6 and not main_lost and _is_free(w0, vel.length(), _dominant(w0))
		# v14 우주 미아: 못 돌아오는 길이면 3.5배로 멀리 휙 날아가 버린다 (미아라는 느낌이 들게)
		var lost_ff := lost_now or tip_t > 3.0
		ff = move_toward(ff, 3.5 if lost_ff else (2.2 if fast else 1.0), dt * (2.0 if lost_ff else 3.0))
		fly_adv = dt * ff
		if _fly(dt * ff):
			return
		if grounded:
			ff = 1.0
		else:
			_lost_check(dt)
			if tow_t > 0.0:
				_camera(dt)
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
	var t2 := Time.get_ticks_usec() if _dbg else 0
	_tick(dt, up, vel.length() / lift)
	t2 = _dbg_add("tick", t2)
	_meteors(dt, up)
	_dots_update(up, lift)
	_dbg_add("sim", t2)
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
	if want.length() < 0.1:
		acc = maxf(acc, ACC)  # v14 "멈추니까 혼자 좀 걷다 멈췄어": 얼음이어도 손을 떼면 바로 선다 (미끄러짐은 출발·방향 바꿀 때만)
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
	lost_t = 0.0
	lost_cd = 0.5
	_lost_r2 = false
	lost_now = false
	air_tip = false
	sail_open = 0.0
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


## 탈출선의 몇 %면 떠날 수 있게 도와주나: 첫 부탁 둘(풍차·우편)은 70%, 그 뒤 80% (v6 82/92 → v7 더 너그럽게)
func _esc_need() -> float:
	return (0.70 if _ndone() <= 1 else 0.80) - 0.12 * as_esc  # v9: 끝낸 부탁 수로 (순서 자유). v10 as_esc: 도움 힌트 떠나기 도와주기


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
	if (kit_just("jump") or kit_just("sail")) and not airjump:
		# 공중 한 번 (v7): 돛이 있으면 돛(점프 버튼·돛 버튼 같음), 없으면 위로 공중 점프. 연한 점선이 미리 보여 준 그대로
		airjump = true
		vel = _air_v(bc[cur] + p, vel, up)
		sim_cd = 0
		lost_t = 0.0
		if has_sail:
			sail_open = 0.01
			sail_used = true
			sfx("sail")  # v14: "지금 날다리" 글은 뺐다 (미니게임 시절 UI)
			_emit("sail")
		else:
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
				msg(_tx("msg.drift_warn_ns"), 0.5)  # v14: 늘 "떠내려가요"만 (돛 안내 글 없음)
				if not drift_said:
					drift_said = true
					_react("drift_warning" if has_sail else "drift_warning_ns")
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
	sfx("land_hard" if hit > 4.0 else "land", -2.0 + clampf(hit, 0.0, 6.0))
	_emit("land", {"hard": hit > 4.0, "speed": hit})
	if item != "" and ij >= 0 and bool((JOB[ij] as Dictionary).get("frag", false)):
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
			var gc := (gap_a if rg.spin else 0.0) + (NW - 0.5) * TAU / NW
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
	_g_zone = Vector2.ZERO
	# v12: 풍차 부탁 중 풍차의 별 = 고리가 '빠르기 / 뜨는 빠르기' 를 보이고, 바람 구간(55~100%)을 초록으로 칠한다
	if js[0] == 1 and cur == 0 and fin_t <= 0.0:
		var lift := sqrt(maxf(gp + float(P.grip), 0.5) * R)
		var lr := vel.length() / maxf(lift, 0.1)
		_g_zone = Vector2(WIND_LO / WIND_MAX, 1.0 / WIND_MAX)
		var c := Color("ffd166")
		if lr >= 1.0:
			c = Color("ff8a5b")  # 너무 빠르다: 뜬다
		elif lr >= WIND_LO:
			c = Color("37b24d")  # 바람 구간
		gauge(lr / WIND_MAX, c)
		return
	var f := _esc_show(up)
	if grounded:
		gauge(f, Color("37b24d") if f >= 1.0 else Color("ffd166"))
	else:
		gauge(f, Color("8fe3c2") if f >= 1.0 else Color("ffd166"))


## v12: 위쪽 막대 대신 점프 버튼을 감싼 고리 (_ring_draw 가 조작판에 그린다). tofu 막대·옛 캡슐 막대는 늘 숨김
func gauge(frac: float, color: Color) -> void:
	_bar_bg.visible = false
	if gauge_bg:
		gauge_bg.visible = false
	_g_frac = clampf(frac, 0.0, 1.0)
	_g_col = color


## v12 빠르기 고리: 점프 버튼 둘레, 위에서 시계 방향으로 찬다 (끝이 둥근 캡슐 호). 풍차 부탁 땐 바람 구간을 옅은 초록으로
func _ring_draw(c: Control) -> void:
	if not _btns.has("jump") or _g_col.a <= 0.0 or ui == null or ui.title_visible():
		return
	var b: Dictionary = _btns["jump"]
	var o: Vector2 = b.pos
	var rr: float = float(b.r) + 14.0
	var a0 := -PI * 0.5
	c.draw_arc(o, rr, 0.0, TAU, 64, NAVY, 17.0, true)
	c.draw_arc(o, rr, 0.0, TAU, 64, CREAM, 11.0, true)
	if _g_zone.y > _g_zone.x:
		var za := a0 + TAU * _g_zone.x
		var zb := a0 + TAU * _g_zone.y
		var zc := Color(Color("37b24d"), 0.3 + 0.12 * sin(clock * 5.0))
		c.draw_arc(o, rr, za, zb, 24, zc, 11.0, true)
		c.draw_line(o + Vector2(cos(za), sin(za)) * (rr - 9.0), o + Vector2(cos(za), sin(za)) * (rr + 9.0), NAVY, 3.0, true)
		c.draw_line(o + Vector2(cos(zb), sin(zb)) * (rr - 9.0), o + Vector2(cos(zb), sin(zb)) * (rr + 9.0), NAVY, 3.0, true)
	if _g_frac > 0.01:
		var a1 := a0 + TAU * _g_frac
		c.draw_arc(o, rr, a0, a1, maxi(4, int(64.0 * _g_frac)), _g_col, 9.0, true)
		c.draw_circle(o + Vector2(cos(a0), sin(a0)) * rr, 4.5, _g_col)
		c.draw_circle(o + Vector2(cos(a1), sin(a1)) * rr, 4.5, _g_col)


## v9: 부탁 j 의 물건을 그 물건 주인(JOB[j].src 별 주민) 곁 자리에 내놓는다. 다른 물건이 주인 곁에 놓여 있기만 했으면 그건 주인에게 돌아간다
func _give(j: int) -> void:
	var J: Dictionary = JOB[j]
	ij = j
	crack = 0.0
	fall_on = false
	ig_on = true
	ig_pl = int(J.src)
	ig_dir = HOME_D.normalized()
	ig_b.visible = true
	_set_item(ig_b, str(J.item), 0.0)
	_set_item(item_b, str(J.item), 0.0)
	_item_key = str(J.item)
	_item_q = 0.0


## 끝낸 부탁 수
func _ndone() -> int:
	var n := 0
	for s in js:
		if s == 2:
			n += 1
	return n


## 손이 비었나: 하늘에 나온 물건이 없거나, 있어도 주인 곁 제자리에 놓여 있기만 하면 (그건 주인에게 돌려주고 새 물건을 받는다)
func _hands_free() -> bool:
	if ij < 0:
		return true
	return item == "" and not fall_on and ig_on and ig_pl == int(JOB[ij].src) and ig_dir.distance_to(HOME_D.normalized()) < 0.01


## 별 k 주민이 지금 줄 물건이 있나 (부탁은 하는 중, 물건은 아직 하늘에 안 나옴, 덮개는 노을 띠를 끝낸 뒤에만)
func _gives(k: int) -> int:
	for j: int in ITEM_JOBS:
		if int(JOB[j].src) == k and js[j] == 1 and ij != j and (j != 4 or js[3] == 2):
			return j
	return -1


## "!" 표시: 아직 안 만났거나 줄 물건이 있는 주민. 장미는 아직 안 만났거나 덮개가 생긴 뒤
func _mark_on(k: int) -> bool:
	if fin_t > 0.0 or won:
		return false
	if k == 4:
		return js[4] != 2 and (js[4] == 0 or js[3] == 2)
	return js[k] == 0 or _gives(k) >= 0


## v9 주민 만나기 (주민 5m 안에 서 있으면 매 프레임): 처음이면 부탁 말, 줄 물건이 있으면 내놓고, 손이 차 있으면 "그것부터 배달해 줘"
func _meet(k: int) -> void:
	var first := false
	if js[k] == 0:
		first = true
		js[k] = 1
		_emit("job_start", {"job": k})
		bub_q.clear()
		if k == 4 and js[3] < 2:
			_say(P.who, _tx("rose.early"), 6.0)  # 덮개는 아직 없다: 노을 아이에게 가 보라고
			nag[250] = clock + 30.0
		else:
			_say(P.who, _line(k, "ask"), 6.0)
			if k == 4:
				rose_said = true
		_first_hint = false  # v11: 첫 조작 안내 말풍선(hint.first)은 뺐다 (사용자 수정)
		# v14 "설명이 쓸데없이 많아": 부탁 뒤에 붙던 방법 안내(hint)는 뺐다. 막히면 _help 가 돕는다
	elif k == 4 and js[3] == 2 and not rose_said:
		rose_said = true
		_say(P.who, _line(4, "ask"), 6.0)
	elif k == 4 and js[4] == 1 and js[3] < 2 and _can(250):
		_nag(250, 30.0, P.who, _tx("rose.early"))
	var j := _gives(k)
	if j < 0:
		return
	if _hands_free():
		_give(j)
		if j == 4 and not first and _can(260):
			_nag(260, 30.0, P.who, _line(3, "thanks"))  # 맡아 둔 덮개를 이제 내준다 (지뢰 울타리 안내)
	elif _can(700 + k):
		var bk := str(BD[k].id) + ".busy"  # v11: 주민마다 제 말투로 (없으면 talk.busy)
		var busy := _tx(bk if TX.TEXT.has(bk) else "talk.busy", {"item": _tx("item." + str(JOB[ij].item))})
		nag[700 + k] = clock + 30.0
		if first:
			_sayq(P.who, busy, 4.0)
		else:
			_say(P.who, busy, 4.0)


## 물건: 줍기, 금, 놓기, 떨어지기, 전하기
func _items(dt: float, up: Vector3) -> void:
	pick_cd -= dt
	if ij < 0:
		mark_b.visible = false
		drop_k = -1
		over_tg = false
		if zone_b:
			zone_b.visible = false
		return
	var J: Dictionary = JOB[ij]
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
			sfx("pickup")
			_emit("pickup", {"item": item})
			# v7: 받는 순간을 또렷하게 (글만): "소포! 굴뚝 달에 전해 주자". 위 할 일 칩도 바로 바뀌며 톡 튄다
			_banner(_tx("got." + item, {"target": tr(BD[int(J.tgt)].name)}), 3.0)
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
	# v11 굴뚝: 소포를 들면 굴뚝 달 둘레에서 천천히 돌고(drop_k), 놓을 노란 동그라미가 보이고, 그 위면 점이 초록·'놓기'가 숨쉰다
	var tk := int(J.tgt)
	drop_k = tk if item == "pkg" else -1
	if zone_b:
		zone_b.visible = item == "pkg" or (fall_on and ij == 1)
	var tgd: Vector3 = (J.tdir as Vector3).normalized()
	var was := over_tg
	over_tg = item != "" and not grounded and cur == tk and up.angle_to(tgd) * br[tk] < float(J.tr)
	mark_b.visible = item != "" and not grounded
	if mark_b.visible:
		var km := (1.0 + 1.2 * _cue("mark")) * (1.6 if over_tg else 1.2)  # v10 도움 힌트: 떨어질 자리 크게
		_orient(mark_b, up * (_sr(cur, up) + 0.2), up, Vector3(km, 0.15, km))
	if over_tg != was:
		mark_b.material_override = _pm(GOOD if over_tg else D)
		if over_tg:
			sfx("ui_tap", -6.0, 1.6)
	if _btns.has("drop"):
		_btns["drop"].r = 90.0 + (24.0 * (0.5 + 0.5 * sin(clock * 9.0)) if over_tg else 0.0)
		_btns["drop"].color = GOOD if over_tg else B


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
	var J: Dictionary = JOB[ij]
	var tg: Vector3 = (J.tdir as Vector3).normalized()
	if J.frag and fall_h0 > 5.5:
		_break()
		return
	var off := (fall_dir * br[fall_pl]).distance_to(tg * br[fall_pl])
	if fall_pl == int(J.tgt) and off < float(J.tr):
		if ij == 1 and off < 0.6:
			# v14 한가운데(굴뚝 바로 위) 놓기: 덤 +10, 쿵 흔들림
			score += 10
			shake = 0.35
			sfx("slingshot", 0.0, 1.2)
			_emit("score", {"n": 10, "pos": bc[fall_pl] + fall_dir * (br[fall_pl] + 2.5)})
		_deliver()
		return
	ig_on = true
	ig_pl = fall_pl
	ig_dir = fall_dir
	msg(_tx("msg.missed_drop"), 1.0)
	if ij == 1:
		h_drop += 8.0


func _break() -> void:
	# 깨진 자리: 떨어뜨린 물건이면 그 물건, 들고 있던 것이면 내 머리 위
	var bp: Vector3 = ig_b.global_position if ig_b.visible else bc[cur] + p + p.normalized() * 1.5
	var J: Dictionary = JOB[ij]  # v9: 깨지면 그 물건 주인(src) 곁 제자리로
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
	var k := ij
	var J: Dictionary = JOB[k]
	var tgt_k := int(J.tgt)
	var tg: Vector3 = (J.tdir as Vector3).normalized()
	item = ""
	item_b.visible = false
	ig_on = false
	fall_on = false
	ig_b.visible = false
	# 닿은 물건: 소포는 굴뚝 집 지붕, 유리꽃은 친구 머리 위, 덮개는 장미를 덮는다.
	# ig_b 는 다음 부탁이 다시 쓰므로, 놓인 물건은 따로 세워 둔다 (world 가 다시 지어질 때 함께 지워진다)
	var hh := 2.35 if k == 1 else (2.1 if k == 2 else -0.05)
	var put := _art(str(ITEM_ART.get(str(J.item), "parcel")), Callable())
	_orient(put, bc[tgt_k] + tg * (_sr(tgt_k, tg) + hh), tg, Vector3.ONE * (2.2 if k == 4 else 1.3))
	_drop_btn(false)
	ij = -1
	_emit("deliver", {"job": k, "pos": put.global_position})
	_done(k)


func _done(k: int) -> void:
	js[k] = 2
	if k == 0:
		wprog = 1.0
	elif k == 3:
		bprog = 1.0
	var last := _ndone() >= 5
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
	elif k == 4 and not last:
		_say(gv.who, _tx("p5.thanks_more"), 6.0)  # v9: 장미가 먼저 끝났으면 "다섯 별이 다 웃는다" 대신
	elif k == 3 and not _hands_free():
		_say(gv.who, _tx("p4.keep"), 6.0)  # v9: 손에 다른 물건 — 덮개는 노을 아이가 맡아 둔다
	else:
		_say(gv.who, _line(k, "thanks"), 6.0)
	# v14: 고맙다 뒤의 덧붙임 안내(thanks2)는 뺐다 (설명이 너무 많다)
	if k == 3:
		# 덮개가 생겼다: 장미 부탁이 열린다 (손이 비면 바로 내놓고, 아니면 노을 아이가 맡아 둔다)
		if js[4] == 0:
			js[4] = 1
		if _hands_free():
			_give(4)
	if k == 0:
		sfx("windmill_wake")
		_emit("windmill_wake")
		has_sail = true
		sail_b.visible = true
		# v7: 돛을 왜·어떻게 — 풍차지기의 고마움, 하늘에서 '돛' 버튼 한 번
		_banner(_tx("banner.sail"), 5.0)
		_lane()
	elif k == 1:
		bag_b.visible = true
	if last:
		# 끝 (v9: 다섯 부탁을 다 끝냈을 때, 마지막이 어느 것이든): 고마움 → 나의 혼잣말 넷, 카메라가 천천히 물러나 별들이 다 보인다
		won = true
		fin_t = 18.0
		msg(_tx("msg.rose_smiles" if k == 4 else "msg.all_done"), 3.0)
		sfx("win")
		_emit("finish")
		for i in 4:
			_sayq(_tx("who.me"), _tx("ending.%d" % (i + 1)), 2.8)
		return
	if k == 4:
		msg(_tx("msg.rose_smiles"), 1.8)
	# 다음 갈 곳: 가장 가까운 남은 부탁 (칩·화살표와 같은 것)
	fj = -1
	_obj()
	if ob_k >= 0 and k != 4:
		msg(_tx("msg.next", {"planet": tr(BD[ob_k].name)}), 1.8)


## 별마다 다른 움직임과 부탁 진행
func _tick(dt: float, up: Vector3, lf: float) -> void:
	for k in marks:
		var m: MeshInstance3D = marks[k]
		m.visible = _mark_on(int(k))
		if m.visible and k != 4:
			m.position.y = 2.9 + sin(clock * 4.0) * 0.2
	# 주민 만나기 (v9: 어느 별 주민이든 언제든)
	if grounded and cur <= 4 and npcs.has(cur) and fin_t <= 0.0:
		if p.distance_to((npcs[cur] as Node3D).position) < 5.0:
			_meet(cur)
	# 풍차 바람: v12 이륙선 55% 이상으로 달린 시간 (약 9초). 떠도 1초는 더 세고, 공중에선 줄지 않는다 (작은 뜀에 안 끊긴다)
	if js[0] == 1 and cur == 0:
		if grounded:
			_wind_air = 1.0
		else:
			_wind_air -= dt
		var on_ := lf >= WIND_LO and (grounded or _wind_air > 0.0)
		var w0 := wprog
		wprog = clampf(wprog + (dt / 9.0 if on_ else (-0.02 * dt if grounded else 0.0)), 0.0, 1.0)
		if int(wprog * 20.0) > int(w0 * 20.0):
			_pb_gain = 1.0  # 5% 오를 때마다 막대가 톡
		if on_:
			wind_t -= dt
			if wind_t <= 0.0:
				wind_t = 0.35
		if wprog >= 1.0:
			_done(0)
	if blades:
		# v12: 바람 막대가 찰수록 날개가 빨라진다 (막대와 풍차가 한 몸으로 보이게)
		var wsp := wprog * 7.0 if js[0] == 1 else 0.0
		blades.rotation.z += ((lf * 9.0 * (1.0 if grounded else 0.2) if cur == 0 else 0.0) + wsp + (6.0 if js[0] == 2 else 0.3)) * dt
	if js[0] == 1 and cur == 0:
		_streaks_tick(dt, lf >= WIND_LO and (grounded or _wind_air > 0.0), up)
	elif _streak_n > 0:
		_streaks_tick(dt, false, up)
	# 노을 띠: 적도를 이륙선의 80%(후반 90%) 빠르기로 돈다 (v9: 노을의 별 위에 있을 때만 움직인다)
	var r3 := br[3]
	var band_w := 0.0
	if js[3] == 1 and cur == 3:
		band_w = (0.8 if bprog < 0.5 else 0.9) * (1.0 - 0.3 * as_band) * sqrt((bg[3] - 0.8) * r3) / r3
		band_a += band_w * dt
	var inb := false
	if cur == 3 and grounded:
		var lon := atan2(-up.z, up.x)
		var lat := asin(clampf(up.y, -1.0, 1.0))
		inb = absf(wrapf(lon - band_a, -PI, PI)) < 0.34 and absf(lat) < 0.5  # v14 "형님별 어려워": 0.24 → 0.34
	if inb and band_w > 0.0:
		# v14 살짝 도와주기: 띠 위에 서 있으면 내 속도를 띠의 빠르기·방향 쪽으로 조금씩 당긴다
		var vb := Vector3(0, band_w, 0).cross(p)
		vb -= up * vb.dot(up)
		vel = vel.lerp(vb, minf(1.0, dt * 1.2))
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
			bb.material_override = _pm(GOOD if inb else WHITE)  # v11: 노을 별이 주황이 되어 띠는 흰색 (올라서면 초록)
	if js[3] == 1 and cur == 3:
		_help_band(inb, dt)
		var b0 := bprog
		bprog = clampf(bprog + (dt / 10.0 if inb else -0.025 * dt), 0.0, 1.0)  # v14: 14초 → 10초, 줄어듦 0.04 → 0.025
		if int(bprog * 20.0) > int(b0 * 20.0):
			_pb_gain = 1.0
		if inb:
			wind_t -= dt
			if wind_t <= 0.0:
				wind_t = 0.4
				sfx("ui_tap", -9.0, 1.0 + bprog)
		if bprog >= 1.0:
			_done(3)
	# 장미 별의 도는 담
	gap_a += 0.8 * dt
	if deco_on.size() <= 4 or deco_on[4] == 1:
		_place_walls(4)  # 멀어서 장식을 숨긴 동안은 안 고친다 (각도는 gap_a 라 다시 보이면 제자리)
	# 갈 곳 빛기둥 (다른 별 위에서도 보이게 길게)
	_obj()
	beacon.visible = ob_k >= 0 and fin_t <= 0.0
	var kb := _cue("beacon")  # v10 도움 힌트: 빛기둥 더 크고 밝게
	if beacon.visible:
		# v14: 갈 자리 위 몇 칸에서 위아래로 둥실. 카메라가 멀수록 크게 (다른 별에서도 보이게, 1.2~5배)
		var gp0 := bc[ob_k] + ob_d * br[ob_k]
		var cd := cam.global_position.distance_to(gp0) if cam else 20.0
		var bs := clampf(cd * 0.06, 1.2, 5.0) * (1.0 + kb * (0.6 + 0.15 * sin(clock * 5.0)))
		var bob := (0.5 + 0.5 * sin(clock * 3.0)) * 0.6 * bs
		_orient(beacon, gp0 + ob_d * (2.0 + bob), ob_d, Vector3.ONE * bs)
		beacon.rotate_object_local(Vector3.UP, clock * 1.2)
	if (kb > 0.0) != _beacon_lit:
		_beacon_lit = kb > 0.0
		beacon.material_override = _pm(Color("fff0a6") if _beacon_lit else D)


## 갈 곳: ob_k(별 번호, 없으면 -1)·ob_d(방향). v6: 매 프레임 새 배열을 만들지 않게 멤버에 쓴다
## v9 순서 자유: 든 물건(떨어지는 중·빗나가 놓인 것 포함)이 있으면 그 물건 일이 먼저, 없으면 남은 부탁 중 가장 가까운 별의 것.
## 고르기는 땅에 있을 때만 다시 한다 (날다가 칩·화살표·돛이 가리키는 곳이 바뀌지 않게). fj·goal_st·ob_k·ob_d 를 쓴다
func _obj() -> void:
	ob_k = -1
	goal_st = -1
	if won or fin_t > 0.0:
		fj = -1
		return
	if ij >= 0 and (item != "" or fall_on or (ig_on and not _hands_free())):
		fj = ij
		var J: Dictionary = JOB[ij]
		if item != "" or fall_on:
			goal_st = 3
			ob_k = int(J.tgt)
			ob_d = (J.tdir as Vector3).normalized()
		else:
			goal_st = 2
			ob_k = ig_pl
			ob_d = ig_dir
		return
	if grounded or fj < 0 or not _job_open(fj):
		fj = -1
		var w := bc[cur] + p
		var best := INF
		for j in 5:
			if not _job_open(j):
				continue
			var dd := w.distance_to(bc[_job_planet(j)])
			if dd < best - 0.5:
				best = dd
				fj = j
	if fj < 0:
		return
	var j := fj
	ob_k = _job_planet(j)
	ob_d = NPC_D.normalized()
	if js[j] == 0:
		goal_st = 0
		if j == 4:
			ob_d = (JOB[4].tdir as Vector3).normalized()
	elif j == 0:
		goal_st = 1
		if cur == 0:
			ob_k = -1  # 풍차의 별 위: 갈 곳 없이 달리기만
	elif j == 3:
		goal_st = 4
		if cur == 3:
			ob_d = Vector3(cos(band_a), 0, -sin(band_a))
	elif ij == j and ig_on:
		goal_st = 2
		ob_k = ig_pl
		ob_d = ig_dir
	else:
		goal_st = 2  # 물건을 받으러 주인에게


## 칩이 고를 수 있는 부탁: 안 끝났고, 장미는 덮개가 생긴 뒤에만 (그 전엔 노을 띠가 먼저라 장미로 보내지 않는다)
func _job_open(j: int) -> bool:
	if js[j] == 2:
		return false
	if j == 4:
		return js[3] == 2
	return true


## 부탁 j 를 하러 갈 별: 물건 부탁(하는 중)은 물건 주인 별, 그 밖엔 부탁한 주민 별
func _job_planet(j: int) -> int:
	if js[j] == 1 and (j == 1 or j == 2 or j == 4):
		if ij == j and ig_on:
			return ig_pl
		return int(JOB[j].src)
	return j


## 말풍선과 부탁 막대. v6: 늘 떠 있는 말 없음 — 상황 말은 한 번씩, 같은 말은 한참 쉬었다가 (_nag)
func _hud(dt: float) -> void:
	_talk_wait(dt)  # v14: 대화 넘기기·닫기는 놀이 중에
	if not bub_talk:
		bub_t -= dt
	if bub_t <= 0.0 and not bub_q.is_empty():
		var q: Array = bub_q.pop_front()
		var qt := int(q[3]) if q.size() > 3 else -1
		if qt == 1 and not _talk_ok(str(q[0])):
			_talk_close()  # v14: 주민 곁을 떠났으면 남은 대화는 버린다
		else:
			_say(str(q[0]), str(q[1]), float(q[2]), qt)
	if bub_t <= 0.0 and die_t <= 0.0 and fin_t <= 0.0:
		_situation()
	_bub_anim(dt)
	_ban_anim(dt)
	_chip_update(dt)
	_tags_update()
	_arrow_update()
	var show := false
	var kind := ""
	if js[0] == 1 and cur == 0:
		show = true
		kind = "wind"
		_pbar_set(Color("ffd166"), wprog)
	elif js[3] == 1 and cur == 3:
		show = true
		kind = "band"
		_pbar_set(Color("ffd166"), bprog)
	elif item != "" and ij >= 0 and bool((JOB[ij] as Dictionary).get("frag", false)):
		show = true
		_pbar_set(DANGER, clampf(crack, 0.0, 1.0))
	pbar_bg.visible = show
	# v12 이름표: 바람(풍차)·노을(해) 막대에만. 늘 때 막대와 이름표가 톡 커진다
	pb_tag.visible = show and kind != ""
	if kind != pb_kind:
		pb_kind = kind
		pb_lbl.text = _tx("ui.wind") if kind == "wind" else (_tx("ui.sunset") if kind == "band" else "")
		pb_ic.queue_redraw()
	_pb_gain = maxf(_pb_gain - dt * 3.0, 0.0)
	var ps := 1.0 + 0.12 * _bo(1.0 - _pb_gain) * _pb_gain if _pb_gain > 0.0 else 1.0
	pbar_bg.scale = Vector2(ps, ps)
	pb_tag.scale = Vector2(ps, ps)


func _pbar_set(col: Color, f: float) -> void:
	pbar.visible = f > 0.01
	pbar.size.x = maxf((PB_W - 10.0) * f, 20.0)
	if pbar_sb.bg_color != col:
		pbar_sb.bg_color = col


## 이름표 그림: 노란 동그라미 위에 바람 / 지는 해
func _pb_icon_draw(c: Control) -> void:
	if pb_kind == "":
		return
	var o := Vector2(27, 25)
	c.draw_circle(o, 19.0, Color("ffd166"))
	c.draw_arc(o, 19.0, 0.0, TAU, 32, NAVY, 3.0, true)
	_icon(c, o, 0.75, pb_kind)


## v12 바람 줄: 바람이 세지는 동안 내 곁에서 풍차 쪽으로 흰 줄이 날아간다 (막대 = 풍차 바람이라는 걸 보이게)
var _streaks: Array[MeshInstance3D] = []
var _streak_life := PackedFloat32Array()
var _streak_dir: Array[Vector3] = []
var _streak_spawn := 0.0
var _streak_n := 0  # 살아 있는 줄 수
const STREAK_LIFE := 0.55


func _streaks_tick(dt: float, on_: bool, up: Vector3) -> void:
	if _streaks.is_empty() or not is_instance_valid(_streaks[0]):
		_streaks.clear()
		_streak_life.clear()
		_streak_dir.clear()
		for i in 8:
			var m := box(Vector3.ZERO, Vector3(0.09, 0.09, 1.3), WHITE)
			m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			m.visible = false
			_streaks.append(m)
			_streak_life.append(0.0)
			_streak_dir.append(Vector3.FORWARD)
	var pw := bc[cur] + p
	_streak_spawn -= dt
	if on_ and blades and _streak_spawn <= 0.0:
		_streak_spawn = 0.1
		for i in _streaks.size():
			if _streak_life[i] <= 0.0:
				var d := _flat(blades.global_position - pw, up)
				var side := up.cross(d)
				_streaks[i].global_position = pw + up * randf_range(0.6, 2.0) + side * randf_range(-1.2, 1.2)
				_streak_dir[i] = d
				_streak_life[i] = STREAK_LIFE
				_streaks[i].visible = true
				break
	_streak_n = 0
	var sp := vel.length() + 6.0
	for i in _streaks.size():
		if _streak_life[i] <= 0.0:
			continue
		_streak_life[i] -= dt
		var m := _streaks[i]
		if _streak_life[i] <= 0.0:
			m.visible = false
			continue
		_streak_n += 1
		var d: Vector3 = _streak_dir[i]
		m.global_position += d * sp * dt
		var k := _streak_life[i] / STREAK_LIFE
		m.global_basis = Basis.looking_at(d, up) * Basis.from_scale(Vector3(0.09, 0.09, 1.3 * sin(k * PI) + 0.05))


## 지금 할 만한 말 하나 (번호 = 종류*100 + 별·부탁). 끝낸 주민의 혼잣말은 드물게(60초), 안내는 40초에 한 번까지
func _situation() -> void:
	var near := grounded and cur <= 4 and npcs.has(cur) and p.distance_to((npcs[cur] as Node3D).position) < 6.0
	# v9: 부탁을 끝낸 주민은 가끔 혼잣말 (줄 물건이 남았으면 안 함 — _meet 이 말한다)
	if near and js[cur] == 2 and _gives(cur) < 0:
		if _can(100 + cur):
			_nag(100 + cur, 60.0, P.who, _line(cur, "idle1" if randf() < 0.5 else "idle2"))
		return
	# v14 "설명이 쓸데없이 많아": 때마다 되풀이하던 주민 안내(바람·띠·물건·장미·불 별)와 "다음은 ○○ 별" 잔소리는 뺐다.
	# 막혔을 때 돕는 말은 _help (help.*) 가 그대로 맡는다


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
	# 마지막으로 내려앉은 자리에서 다시: 든 물건은 그 물건 주인 별 제자리로 (v9: 순서와 상관없이 JOB[ij].src)
	if ij >= 0 and (item != "" or fall_on):
		var J: Dictionary = JOB[ij]
		item = ""
		item_b.visible = false
		fall_on = false
		ig_on = true
		ig_pl = J.src
		ig_dir = HOME_D.normalized()
		ig_b.visible = true
		_drop_btn(false)
	crack = 0.0
	# 바람·띠 막대는 0부터 (하는 중인 것만)
	if js[0] == 1:
		wprog = 0.0
	if js[3] == 1:
		bprog = 0.0
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
	shake = maxf(shake - dt, 0.0)  # v7: 덜컹이는 흔들림 없음 — 흔들림은 fx 가 작고 부드럽게
	var look := pw + upp * 1.0 + lookd * 3.0
	if intro_k >= 0.0:
		_cg_want = want
		_cg_look = look
		_cg_up = upp
		_intro_cam(dt)
		return
	cam.position = cam.position.lerp(want, minf(1.0, dt * 5.0))
	if cam.position.distance_to(look) > 0.1:
		cam.look_at(look, upp)
	# cam.fov·h_offset·v_offset 는 fx 몫 (속도·탈출 장면에 따라 넓힌다)


## v13 처음 줌: 먼 자리(intro_p, intro_l)에서 놀이 카메라 자리로. 천천히 시작해 천천히 멈춘다(ease-in-out).
## 거리는 비율로 줄여(멀 때도 가까울 때도 같은 느낌), 볼 곳은 먼저 별 쪽으로 가서 별이 화면 밖으로 안 나간다.
## v14: 대화를 넘겨도 빨라지지 않는다. 내가 움직이기 시작하면(스틱·뜀) 1.5초 안에 마저 다가간다
func _intro_cam(dt: float) -> void:
	var rate := 1.0 / INTRO_DUR
	if kit_move.length() > 0.1 or not grounded:
		intro_boost = 1.0  # v14: 한 번 움직이면 멈춰도 계속 빨리
	if intro_boost > 0.0:
		rate += 1.0 / 1.5
	intro_k = minf(1.0, intro_k + dt * rate)
	var e := intro_k * intro_k * (3.0 - 2.0 * intro_k)
	var ec := 1.0 - pow(1.0 - e, 3.0)
	var d0v := intro_p - intro_l
	var d1v := _cg_want - _cg_look
	var d0 := maxf(d0v.length(), 0.1)
	var d1 := maxf(d1v.length(), 0.1)
	var dir := _turn(d0v / d0, d1v / d1, e)
	var dist := d0 * pow(d1 / d0, e)
	var ctr := intro_l.lerp(_cg_look, ec)
	var upv := _turn(Vector3.UP, _cg_up, e)
	cam.position = ctr + dir * dist
	if absf(dir.dot(upv)) > 0.98:
		upv = _flat(upv, dir)
	if cam.position.distance_to(ctr) > 0.1:
		cam.look_at(ctr, upv)
	if intro_k >= 1.0:
		intro_k = -1.0
		intro_boost = 0.0


# ---- v7: 공중 한 번 · 우주 미아 구조 · 돛 버튼 ----
## 공중 한 번: 돛이 있으면 스틱 쪽(화면 기준)으로, 스틱을 안 밀면 갈 곳(빛기둥) 쪽으로 SAIL_TURN 까지 틀고 SAIL_ADD 만큼 빨라진다.
## 돛이 없으면 위로 공중 점프. 날기와 연한 점선·우주 미아 판정이 같이 쓴다.
func _air_v(w: Vector3, v: Vector3, up: Vector3) -> Vector3:
	if not has_sail:
		return v + up * AIRJUMP
	var sp := maxf(v.length(), 3.0) + SAIL_ADD
	var vd := v.normalized() if v.length() > 0.1 else up
	if kit_move.length() > 0.3:
		var bs := cam.global_transform.basis
		var sd := (bs.x * kit_move.x - bs.y * kit_move.y).normalized()
		return (vd + sd * 0.7).normalized() * sp
	if ob_k >= 0 and ob_k != from_b and bfire[ob_k] == 0:
		var td := (bc[ob_k] + ob_d * br[ob_k] - w).normalized()
		var ang := vd.angle_to(td)
		if ang > 0.001 and ang < 3.1:
			vd = vd.slerp(td, minf(1.0, SAIL_TURN / ang))
	return vd.normalized() * sp


## 우주 미아: 0.3초마다 12초 앞까지 본다. 지금 길이 어느 별에도 안 닿고(떠내려감·아직 날고 있음) 공중 한 번으로도 못 고치면
## 2.6초 뒤, 공중 한 번으로 고칠 수 있는데 안 쓰면 4.5초 뒤(하늘 끝 가까이면 바로) 마지막 별로 끌려 돌아간다 (바라만 보는 시간 없음)
var _lost_r2 := false


func _lost_check(dt: float) -> void:
	if fly_t < 0.4 or die_t > 0.0 or fin_t > 0.0:
		lost_t = 0.0
		tip_t = 0.0
		return
	lost_cd -= dt
	if _lost_r2:
		# 공중 한 번으로 고칠 수 있나는 다음 프레임에 (한 프레임에 긴 계산 둘이 몰리지 않게)
		_lost_r2 = false
		if main_lost and not airjump:
			var w2 := bc[cur] + p
			var r2 := _sim(w2, _air_v(w2, vel, p.normalized()), cur, atm_t, 12.0, 1.0 / 12.0, _lost_pts, from_b)
			if not (r2 == -1 or (r2 == -2 and sim_why == 1)):
				lost_now = false
				if not air_tip:
					air_tip = true
					# v14: 글 대신 돛 버튼이 숨쉰다 (돛이 없으면 아무 글도 없이). _cue 는 6초가 최대라 4초로 또렷하게
					if has_sail:
						_cue_on("sail", 4.0)
	elif lost_cd <= 0.0:
		lost_cd = 0.3
		var w := bc[cur] + p
		var r1 := _sim(w, vel, cur, atm_t, 12.0, 1.0 / 12.0, _lost_pts, from_b)
		main_lost = r1 == -1 or (r1 == -2 and sim_why == 1)
		lost_now = main_lost
		_lost_r2 = main_lost and not airjump
	lost_t = lost_t + dt if lost_now else 0.0
	tip_t = tip_t + dt if main_lost else 0.0
	# 하늘 끝(떠내려가 죽는 선) 가까이면 기다리지 않는다
	# v14: 하늘 끝 밖 6칸까지 (떠내려가 죽는 선은 +10)
	var near_edge := main_lost and _dominant(bc[cur] + p) < 0 and (bc[cur] + p - MID).length() > BOUND + 6.0
	# v8: 판정이 너무 빨라서 늘림 (0.9/2.5 → 2.6/4.5초). v14: 더 멀리 날아간 뒤에 (3.8/5.5초)
	if lost_t >= 3.8 or tip_t >= 5.5 or near_edge:
		_tow_start()


func _tow_start() -> void:
	_help_ev("tow", {})  # v10: 우주 미아 셈 (airjump 가 이번 비행 그대로일 때)
	# v14 "체력도 안 떨어져": 끌려 돌아오면 목숨 하나. 마지막 목숨이면 보통 죽음(떠내려감)으로
	if lives <= 1:
		lost_t = 0.0
		tip_t = 0.0
		lost_now = false
		main_lost = false
		_die("drift")
		return
	lives -= 1
	_hearts_show(lives)
	play("bad")
	tow_t = TOW_T
	lost_t = 0.0
	tip_t = 0.0
	lost_now = false
	main_lost = false
	ff = 1.0
	tow_from = bc[cur] + p
	if cur != home_b:
		_switch(home_b)
	_dots_off()
	_banner(_tx("banner.lost"), TOW_T)
	sfx("drift_warn")
	sfx("atmo", -3.0, 0.8)
	_emit("drift_warn")


## 끌려 돌아가기: 마지막으로 내려앉은 자리 위로 둥글게 날아와 그 자리에 선다 (든 물건 그대로. v14: 목숨 하나는 _tow_start 에서 잃는다)
func _tow(dt: float) -> void:
	tow_t -= dt
	var e := smoothstep(0.0, 1.0, 1.0 - maxf(tow_t, 0.0) / TOW_T)
	var c0 := bc[home_b]
	var dest := c0 + home_d * (br[home_b] + 1.5)
	var ctl := c0 + home_d * (br[home_b] + 14.0)
	var u := 1.0 - e
	var pos := tow_from * (u * u) + ctl * (2.0 * u * e) + dest * (e * e)
	var dv := (ctl - tow_from) * (2.0 * u) + (dest - ctl) * (2.0 * e)
	p = pos - c0
	if dv.length() > 0.01:
		vel = dv.normalized() * 10.0
	_place_me()
	if tow_t <= 0.0:
		_respawn()


## 돛 버튼: 돛이 있고 날고 있고 공중 한 번이 남았을 때만 (안 보일 땐 화면 밖으로 치워 둔다 — 누르는 중에 지우면 키트가 손가락을 잃는다).
## 처음 뜰 때 안내 한 줄, 한 번 써 볼 때까지 숨쉰다
func _sail_btn(_dt: float) -> void:
	var want := has_sail and not grounded and not airjump and die_t <= 0.0 and fin_t <= 0.0 and tow_t <= 0.0
	if want != _sail_shown:
		_sail_shown = want
		if want:
			kit_button("sail", _tx("ui.sail"), SAIL_POS, 72.0, Color("12b886"))
			sail_hinted = true  # v14: 돛 설명은 banner.sail 하나만 (hint.sail 말풍선 뺌)
		elif _btns.has("sail"):
			_btns["sail"].pos = Vector2(-600, -600)
			_btns["sail"].r = 1.0
	if want and not sail_used and _btns.has("sail"):
		_btns["sail"].r = 72.0 + 9.0 * (0.5 + 0.5 * sin(clock * 7.0))
	if want and _btns.has("sail") and hcue.has("sail"):
		_btns["sail"].r = 72.0 + 26.0 * (0.5 + 0.5 * sin(clock * 9.0)) * _cue("sail")  # v10 도움 힌트: 돛 버튼 크게 깜빡


# ---- v7: 할 일 칩 · 알림판 · 갈 곳 화살표 ----
func _hud_label(parent: Control, fs: int, col: Color) -> Label:
	var st := LabelSettings.new()
	st.font = _font
	st.font_size = fs
	st.font_color = col
	st.line_spacing = 2.0
	var l := Label.new()
	l.label_settings = st
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED  # 이미 번역한 글
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


## 할 일 칩(막대 아래, 늘 보임) · 알림판(위 가운데, 중요한 순간에 잠깐) · 갈 곳 화살표(화면 밖·별 뒤면 가장자리에서 가리킴)
func _v7_hud_build() -> void:
	chip = Control.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.visible = false
	hud2.add_child(chip)
	chip_sh = _capsule(chip, Rect2(0, 5, 100, 50), Color(NAVY, 0.4), 0, NAVY)
	chip_bg = _capsule(chip, Rect2(0, 0, 100, 50), CREAM, 4, NAVY)
	chip_ic = Control.new()
	chip_ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip_ic.position = Vector2(7, 5)
	chip_ic.size = Vector2(40, 40)
	chip_ic.draw.connect(_chip_icon_draw)
	chip.add_child(chip_ic)
	chip_l = _hud_label(chip, 26, NAVY)
	chip_l.clip_text = true
	ban = Control.new()
	ban.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ban.visible = false
	hud2.add_child(ban)
	ban_sh = _capsule(ban, Rect2(0, 6, 100, 60), Color(NAVY, 0.4), 0, NAVY, 26)
	ban_bg = _capsule(ban, Rect2(0, 0, 100, 60), Color("fff1c9"), 5, NAVY, 26)
	ban_l = _hud_label(ban, 26, NAVY)
	ban_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ban_l.autowrap_mode = TextServer.AUTOWRAP_WORD
	arrow = Control.new()
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow.position = Vector2.ZERO
	arrow.size = Vector2(720, 1280)
	arrow.draw.connect(_arrow_draw)
	hud2.add_child(arrow)


## 알림판: 글 한두 줄 (시작·물건 받음·돛 받음·우주 미아). 효과 글 없이 할 말만
func _banner(tx: String, dur: float) -> void:
	if ban == null or tx == "":
		return
	var maxw := 600.0
	var padx := 26.0
	var pady := 16.0
	var ts := _font.get_multiline_string_size(tx, HORIZONTAL_ALIGNMENT_CENTER, maxw - padx * 2.0, 26)
	var w := clampf(ts.x + 8.0 + padx * 2.0, 260.0, maxw)
	ban_l.size = Vector2(w - padx * 2.0, 10)
	ban_l.text = tx
	var lines := maxi(ban_l.get_line_count(), 1)
	var th := lines * ban_l.get_line_height() + (lines - 1) * 2.0
	var h := th + pady * 2.0
	ban_l.position = Vector2(padx, pady)
	ban_l.size = Vector2(w - padx * 2.0, th)
	ban_bg.size = Vector2(w, h)
	ban_sh.size = Vector2(w, h)
	ban.size = Vector2(w, h)
	ban.position = Vector2(360.0 - w * 0.5, 318.0)
	ban.pivot_offset = Vector2(w * 0.5, h * 0.5)
	ban_t = dur
	ban_age = 0.0


func _ban_anim(dt: float) -> void:
	if ban == null:
		return
	if ban_t <= 0.0:
		ban.visible = false
		return
	ban_t -= dt
	ban_age += dt
	ban.visible = true
	var k := clampf(ban_age / 0.2, 0.0, 1.0)
	ban.modulate.a = minf(k, clampf(ban_t / 0.3, 0.0, 1.0))
	var sc := 0.85 + 0.15 * _bo(k)
	ban.scale = Vector2(sc, sc)


## 지금 할 일: -1 없음, 0 주민에게 말 걸기, 1 풍차 바람, 2 물건 받기, 3 물건 배달, 4 노을 띠
func _goal_state() -> int:
	if won or fin_t > 0.0 or fj < 0:
		return -1
	return goal_st  # v9: _obj 가 고른 부탁(fj)의 할 일


## 할 일 칩: 바뀔 때만 글을 다시 쓰고 톡 튄다 (매 프레임 글자를 만들지 않는다)
func _chip_update(dt: float) -> void:
	if chip == null:
		return
	var st := _goal_state()
	var code := -1 if st < 0 else fj * 1000 + st * 100 + (ob_k + 1)
	if code != _chip_code:
		_chip_code = code
		chip.visible = code >= 0
		if code >= 0:
			_chip_set(st, JOB[fj])
			chip_age = 0.0
	if chip.visible and chip_age < 0.5:
		chip_age += dt
		var sc := 0.8 + 0.2 * _bo(clampf(chip_age / 0.3, 0.0, 1.0))
		chip.scale = Vector2(sc, sc)


func _chip_set(st: int, J: Dictionary) -> void:
	var tx := ""
	match st:
		0:
			tx = _tx("goal.talk", {"who": tr(BD[fj].who)})
			_chip_icon = "talk"
		1:
			tx = _tx("goal.wind")
			_chip_icon = "wind"
		2:
			var pk := ig_pl if (ij == fj and ig_on) else int(J.src)
			tx = _tx("goal.pick", {"item": _tx("item." + str(J.item)), "planet": tr(BD[pk].name)})
			_chip_icon = str(J.item)
		3:
			tx = _tx("goal.deliver", {"item": _tx("item." + str(J.item)), "target": tr(BD[int(J.tgt)].name)})
			_chip_icon = str(J.item)
		_:
			tx = _tx("goal.band")
			_chip_icon = "band"
	_chip_pk = ob_k if ob_k >= 0 else fj
	chip_l.text = tx
	var tw := _font.get_string_size(tx, HORIZONTAL_ALIGNMENT_LEFT, -1, 26).x
	var w := minf(tw + 56.0 + 22.0, 680.0)
	chip_l.position = Vector2(54, 7)
	chip_l.size = Vector2(w - 54.0 - 14.0, 36)
	chip_bg.size = Vector2(w, 50)
	chip_sh.size = Vector2(w, 50)
	chip.size = Vector2(w, 50)
	chip.position = Vector2(360.0 - w * 0.5, 272.0)
	chip.pivot_offset = Vector2(w * 0.5, 25.0)
	chip_ic.queue_redraw()


func _chip_icon_draw() -> void:
	if _chip_pk >= 0:
		chip_ic.draw_circle(Vector2(20, 20), 21.0, _pcol(_chip_pk))  # v11: 갈 별의 색 고리 (이름표·할 일 목록과 같은 색)
		chip_ic.draw_circle(Vector2(20, 20), 16.5, CREAM)
	_icon(chip_ic, Vector2(20, 20), 0.85, _chip_icon)


## v11 별의 주인 색 (이름표·칩·할 일 목록 고리). 불 별은 위험 빨강
func _pcol(k: int) -> Color:
	if k < 0 or k >= BD.size():
		return NAVY
	if str(BD[k].kind) == "fire":
		return DANGER
	return (BD[k].c0 as Color).darkened(0.12)


## v11 별 이름표 짓기 (한 번, hud2 에 칩·화살표보다 아래)
func _tags_build() -> void:
	tag_n.clear()
	tag_l.clear()
	tag_bg.clear()
	tag_sh.clear()
	tag_ic.clear()
	tag_w.resize(BD.size())
	for k in BD.size():
		var t := Control.new()
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.visible = false
		hud2.add_child(t)
		var sh := _capsule(t, Rect2(0, 4, 100, 40), Color(NAVY, 0.4), 0, NAVY)
		var bgp := _capsule(t, Rect2(0, 0, 100, 40), CREAM, 3, NAVY)
		var ic := Control.new()
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ic.position = Vector2(4, 2)
		ic.size = Vector2(36, 36)
		ic.draw.connect(_tag_icon_draw.bind(k))
		t.add_child(ic)
		var l := _hud_label(t, 22, NAVY)
		l.position = Vector2(44, 6)
		tag_n.append(t)
		tag_sh.append(sh)
		tag_bg.append(bgp)
		tag_ic.append(ic)
		tag_l.append(l)
	_tags_text()


func _tags_text() -> void:
	for k in tag_n.size():
		var tx := tr(str(BD[k].name))
		tag_l[k].text = tx
		var w := _font.get_string_size(tx, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x + 44.0 + 16.0
		tag_w[k] = w
		tag_l[k].size = Vector2(w - 52.0, 28)
		tag_bg[k].size = Vector2(w, 40)
		tag_sh[k].size = Vector2(w, 40)
		tag_n[k].size = Vector2(w, 40)
		tag_ic[k].queue_redraw()


func _tag_icon_draw(k: int) -> void:
	var c := tag_ic[k]
	var o := Vector2(18, 18)
	c.draw_circle(o, 17.0, _pcol(k))
	c.draw_circle(o, 12.5, Color("ffd166"))
	_icon(c, o, 0.5, str(TAG_IC[k]))


## 매 프레임: 이름표를 별 위(화면 위쪽)에 놓고 옅게. 발밑 별, 카메라 뒤, 발밑 별에 가림, 아주 멀거나(110~150) 아주 가깝거나,
## 화면 가운데(나 둘레)·위 HUD·아래 버튼 칸이면 숨긴다
func _tags_update() -> void:
	if tag_n.is_empty() or cam == null:
		return
	var off := ui.title_visible() or die_t > 0.0 or fin_t > 0.0 or tow_t > 0.0 or not hud2.visible or intro_k >= 0.0
	var cp := cam.global_position
	var cu := cam.global_basis.y
	var ctr := Vector2(360.0, 620.0)
	# v13: 가까운 별 이름표부터 놓고, 먼저 놓인 이름표·말풍선과 겹치면 숨긴다 (아래 40% 칸에는 안 놓는다)
	_tag_ord.clear()
	for k in tag_n.size():
		_tag_ord.append(Vector2(cp.distance_to(bc[k]) if k < bc.size() else 1e9, k))
	_tag_ord.sort()
	_tag_rc.clear()
	var bub_rc := Rect2(bub.position, bub.size).grow(10.0) if bub and bub.visible else Rect2()
	for o: Vector2 in _tag_ord:
		var k := int(o.y)
		var t := tag_n[k]
		var al := 0.0
		if not off and k != cur:
			var tp := bc[k] + cu * (br[k] + 2.5)
			var dd := cp.distance_to(bc[k])
			if not cam.is_position_behind(tp):
				var sp := cam.unproject_position(tp)
				al = 1.0 - smoothstep(110.0, 150.0, dd)
				al *= smoothstep(br[k] + 9.0, br[k] + 18.0, dd)
				al *= smoothstep(110.0, 190.0, sp.distance_to(ctr))
				al *= smoothstep(300.0, 330.0, sp.y) * (1.0 - smoothstep(730.0, 768.0, sp.y))
				if al > 0.03:
					var dv := tp - cp
					var ln := dv.length()
					if ln > 0.01 and _occ1(cp, dv / ln, ln, cur):
						al = 0.0
				if al > 0.03:
					var w := tag_w[k]
					t.position = Vector2(clampf(sp.x - w * 0.5, 8.0, 712.0 - w), sp.y - 44.0)
					var rc := Rect2(t.position, Vector2(w, 44.0))
					if bub_rc.has_area() and rc.intersects(bub_rc):
						al = 0.0
					for q: Rect2 in _tag_rc:
						if rc.intersects(q.grow(4.0)):
							al = 0.0
							break
					if al > 0.03:
						_tag_rc.append(rc)
		if al > 0.03:
			t.visible = true
			t.modulate.a = al
		elif t.visible:
			t.visible = false


## 할 일 그림 (가운데 o, 크기 배수 s): 말 걸기 "!", 바람, 소포, 유리꽃, 유리 덮개, 노을. bgc = 그림 뒤 바탕색
func _icon(c: CanvasItem, o: Vector2, s: float, kind: String) -> void:
	var bgc := CREAM if c == chip_ic else Color("ffd166")
	match kind:
		"talk":
			c.draw_circle(o, 17.0 * s, Color("ffd166"))
			c.draw_arc(o, 17.0 * s, 0.0, TAU, 24, NAVY, 3.0 * s)
			c.draw_rect(Rect2(o + Vector2(-2.5, -11.0) * s, Vector2(5.0, 13.0) * s), NAVY)
			c.draw_circle(o + Vector2(0, 8.0) * s, 3.0 * s, NAVY)
		"wind":
			for i in 3:
				var y := (-9.0 + 9.0 * i) * s
				var x1 := (8.0 - 5.0 * i) * s
				c.draw_line(o + Vector2(-15.0 * s, y), o + Vector2(x1, y), Color("4dabf7"), 4.0 * s)
				c.draw_arc(o + Vector2(x1, y - 4.0 * s), 4.0 * s, PI * 0.5, PI * 2.0, 8, Color("4dabf7"), 3.0 * s)
		"pkg":
			var rc := Rect2(o + Vector2(-13.0, -11.0) * s, Vector2(26.0, 22.0) * s)
			c.draw_rect(rc, Color("c08a4a"))
			c.draw_rect(Rect2(o + Vector2(-3.0, -11.0) * s, Vector2(6.0, 22.0) * s), CREAM)
			c.draw_rect(rc, NAVY, false, 2.5 * s)
		"flower":
			c.draw_line(o + Vector2(0, 2.0) * s, o + Vector2(0, 16.0) * s, Color("37b24d"), 3.0 * s)
			_tri3[0] = o + Vector2(0, -15.0) * s
			_tri3[1] = o + Vector2(10.0, -4.0) * s
			_tri3[2] = o + Vector2(-10.0, -4.0) * s
			c.draw_colored_polygon(_tri3, Color("8fe3c2"))
			_tri3[0] = o + Vector2(0, 6.0) * s
			c.draw_colored_polygon(_tri3, Color("5fc9a0"))
		"dome":
			c.draw_circle(o + Vector2(0, 5.0) * s, 14.0 * s, Color("9fd3ff"))
			c.draw_rect(Rect2(o + Vector2(-16.0, 5.0) * s, Vector2(32.0, 12.0) * s), bgc)
			c.draw_rect(Rect2(o + Vector2(-15.0, 5.0) * s, Vector2(30.0, 4.0) * s), NAVY)
		"fire":
			_tri3[0] = o + Vector2(0, -15.0) * s
			_tri3[1] = o + Vector2(15.0, 12.0) * s
			_tri3[2] = o + Vector2(-15.0, 12.0) * s
			c.draw_colored_polygon(_tri3, DANGER)
			c.draw_rect(Rect2(o + Vector2(-2.5, -6.0) * s, Vector2(5.0, 10.0) * s), WHITE)
			c.draw_circle(o + Vector2(0, 8.0) * s, 2.5 * s, WHITE)
		"band":
			c.draw_circle(o + Vector2(0, 5.0) * s, 13.0 * s, Color("ff922b"))
			c.draw_rect(Rect2(o + Vector2(-17.0, 6.0) * s, Vector2(34.0, 12.0) * s), bgc)
			c.draw_line(o + Vector2(-16.0, 6.0) * s, o + Vector2(16.0, 6.0) * s, NAVY, 3.0 * s)


## 갈 곳 화살표: 갈 곳이 화면 밖·뒤이거나 별에 가려 있으면, 화면 가운데 칸 가장자리에서 그쪽을 가리킨다 (노란 동그라미 + 할 일 그림 + 삼각형)
func _arrow_update() -> void:
	if arrow == null:
		return
	var on := false
	if ob_k >= 0 and die_t <= 0.0 and fin_t <= 0.0 and tow_t <= 0.0 and chip.visible:
		var tp := bc[ob_k] + ob_d * (br[ob_k] + 1.2)
		var c := Vector2(360.0, (HUD_TOP + HUD_BOT) * 0.5)
		var sp := cam.unproject_position(tp)
		var behind := cam.is_position_behind(tp)
		var dir := sp - c
		if behind:
			dir = -dir
		var inside := not behind and sp.x > 40.0 and sp.x < 680.0 and sp.y > HUD_TOP and sp.y < HUD_BOT
		if inside and _occluded(tp):
			inside = false
		if not inside:
			if dir.length() < 1.0:
				dir = Vector2.DOWN
			var dn := dir.normalized()
			var hx := 360.0 - 64.0
			var hy := (HUD_BOT - HUD_TOP) * 0.5 - 44.0
			var t := minf(hx / maxf(absf(dn.x), 0.001), hy / maxf(absf(dn.y), 0.001))
			_arrow_p = c + dn * t
			_arrow_d = dn
			on = true
	var hd := hcue.has("stick") or hcue.has("gauge")  # v10 도움 그림도 같은 판에 그린다
	if on or _arrow_on or hd or _help_drew:
		arrow.queue_redraw()
	_arrow_on = on
	_help_drew = hd


## 카메라에서 tp 까지가 발밑 별이나 갈 곳 별에 가리나
func _occluded(tp: Vector3) -> bool:
	var o := cam.global_position
	var d := tp - o
	var ln := d.length()
	if ln < 0.01:
		return false
	d /= ln
	return _occ1(o, d, ln, cur) or _occ1(o, d, ln, ob_k)


func _occ1(o: Vector3, d: Vector3, ln: float, k: int) -> bool:
	var t := clampf((bc[k] - o).dot(d), 0.0, ln)
	return t < ln - 0.8 and (o + d * t).distance_to(bc[k]) < br[k] * 0.95


func _arrow_draw() -> void:
	_help_draw()
	if not _arrow_on:
		return
	var o := _arrow_p
	var d := _arrow_d
	var ka := 1.0 + 0.45 * _cue("arrow")  # v10 도움 힌트: 화살표 크게
	if ka > 1.0:
		arrow.draw_set_transform(o * (1.0 - ka), 0.0, Vector2(ka, ka))
	var n := Vector2(-d.y, d.x)
	var pulse := 1.0 + 0.08 * sin(clock * 6.0)
	_tri3[0] = o + d * 50.0 * pulse
	_tri3[1] = o + d * 22.0 + n * 19.0
	_tri3[2] = o + d * 22.0 - n * 19.0
	arrow.draw_colored_polygon(_tri3, NAVY)
	_tri3[0] = o + d * 43.0 * pulse
	_tri3[1] = o + d * 24.0 + n * 13.0
	_tri3[2] = o + d * 24.0 - n * 13.0
	arrow.draw_colored_polygon(_tri3, Color("ffd166"))
	arrow.draw_circle(o + Vector2(0, 4), 30.0, Color(NAVY, 0.4))
	arrow.draw_circle(o, 30.0, NAVY)
	arrow.draw_circle(o, 26.0, Color("ffd166"))
	_icon(arrow, o, 0.85, _chip_icon)
	if ka > 1.0:
		arrow.draw_set_transform(Vector2.ZERO)


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
		me_body.position.y = absf(sin(step_ph)) * 0.1 * minf(1.0, spd / 3.0)
		me_body.rotation = Vector3(-0.32 * k, 0.0, sin(step_ph) * 0.07 * k)
		sail_b.scale = sail_b.scale.lerp(Vector3.ONE * 0.7, minf(1.0, dt * 6.0))
	else:
		me_body.position.y = lerpf(me_body.position.y, 0.0, minf(1.0, dt * 6.0))
		me_body.rotation = me_body.rotation.lerp(Vector3(-0.55, 0.0, 0.0), minf(1.0, dt * 4.0))
		# v7: 돛은 접혀 있다가 쓸 때 활짝 펴진다 (튀어나오는 곡선)
		if sail_open > 0.0:
			sail_open = minf(1.0, sail_open + dt * 3.0)
			sail_b.scale = Vector3.ONE * (0.7 + 1.0 * _bo(sail_open))
		else:
			sail_b.scale = sail_b.scale.lerp(Vector3.ONE * 0.7, minf(1.0, dt * 5.0))
	_posty_anim(dt, spd, k)
	_hearts_anim(dt)
	for mk in marks:
		(marks[mk] as MeshInstance3D).rotation.y = clock * 2.5
	if spin:
		spin.rotate_y(dt * 0.5)
	if smoke_n and is_instance_valid(smoke_n):
		smoke_n.rotate_object_local(Vector3.UP, dt * 0.6)
		var sb := 1.0 + 0.08 * sin(clock * 2.2)
		smoke_n.scale = Vector3(sb, 1.0 + 0.12 * sin(clock * 2.2 + 0.8), sb)
	# 바람: 풍차 부탁 중 힘껏 달리면 크게, 날 때는 빠르기만큼
	var want := -60.0
	if die_t <= 0.0 and fin_t <= 0.0:
		if js[0] == 1 and cur == 0 and grounded:
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


## 포스티 움직임: 속도가 곧 다리 (느리면 종종, 빠르면 길게 휘며 바퀴처럼), 공중엔 다리가 뒤로 휘날림.
## 눈동자는 가는 쪽을 보고 젤리처럼 따라오고, 내려앉으면 몸이 눌렸다 튄다. 물건을 들면 깃발이 선다.
func _posty_anim(dt: float, spd: float, k: float) -> void:
	if p_body == null:
		return
	var dd := minf(dt, 0.05)
	# 다리
	for i in 2:
		var ph := step_ph + PI * i
		var hip := 0.0
		var knee := 0.0
		if grounded:
			var amp := (0.22 + 0.95 * k) * minf(1.0, spd / 1.5)
			hip = sin(ph) * amp
			knee = -maxf(0.0, cos(ph)) * (0.35 + 1.15 * k) * minf(1.0, spd / 1.5)
		else:
			hip = -0.85 + sin(clock * 13.0 + PI * i) * 0.18
			knee = -0.55 - sin(clock * 13.0 + PI * i) * 0.15
		var th := p_thighs[i]
		var sh := p_shins[i]
		th.rotation.x = lerp_angle(th.rotation.x, hip, minf(1.0, dd * 18.0))
		sh.rotation.x = lerp_angle(sh.rotation.x, knee, minf(1.0, dd * 18.0))
	# 내려앉음 · 뜸 → 눌림 스프링
	if grounded and not was_ground:
		sq_v = -2.6 - minf(2.5, absf(vel.dot(-cam_up)) * 0.25)
	elif not grounded and was_ground:
		sq_v = 2.2
	was_ground = grounded
	sq_v += (-sq * 170.0 - sq_v * 11.0) * dd
	sq += sq_v * dd
	var breath := 0.025 * sin(clock * 2.6) if grounded and spd < 1.0 else 0.0
	var sy := 1.0 + sq + breath
	p_body.scale = Vector3(1.0 - sq * 0.5, sy, 1.0 - sq * 0.5)
	# 눈동자: 가는 쪽(몸 기준) + 앞쪽 버릇, 스프링으로 늦게 따라온다
	var look := Vector3(0, 0, -1)
	if spd > 0.5:
		var lv := me_body.global_transform.basis.inverse() * vel
		look = (lv.normalized() + Vector3(0, 0, -0.6)).normalized()
	var tgt := look * 0.11
	pup_v += ((tgt - pup_off) * 140.0 - pup_v * 8.0) * dd
	pup_off += pup_v * dd
	if pup_off.length() > 0.12:
		pup_off = pup_off.normalized() * 0.12
	for pu in p_pupils:
		pu.position = pup_off
	# 빨리 달리면 왕눈이 바람에 뒤로 눌린다
	for e in p_eyes:
		e.rotation.x = lerpf(e.rotation.x, 0.35 * k if grounded else 0.5, minf(1.0, dd * 6.0))
	# 입: 놀람(높이 날 때 빠름, 쿵 착지, 죽음)이면 벌어진다
	var open := 0.0
	if die_t > 0.0 or sq < -0.12 or (not grounded and spd > 10.0):
		open = 1.0
	mouth_o = lerpf(mouth_o, open, minf(1.0, dd * 10.0))
	p_mouth.scale = Vector3(1.0 - mouth_o * 0.25, 1.0 + mouth_o * 2.6, 1.0)
	# 깃발: 물건 들면 세우고 아니면 뒤로 눕힌다
	var fl := 0.0 if item != "" else PI / 2.0
	p_flag.rotation.x = lerpf(p_flag.rotation.x, fl, minf(1.0, dd * 7.0))
	# 편지: 날 때 바람에 떤다
	var fz := 0.0
	var fx := 0.0
	if not grounded:
		fx = 0.3 + sin(clock * 24.0) * 0.18 * clampf(spd / 8.0, 0.3, 1.0)
	else:
		fz = sin(clock * 3.0) * 0.05
		fx = 0.18 * k
	p_letter.rotation = Vector3(fx, 0.0, fz)
	# 주민: 숨쉬듯 들썩, 눈동자는 나를 본다
	for b: Array in vil_bobs:
		var vb: Node3D = b[0]
		if not vb.visible:
			continue  # 먼 주민은 숨겨 두고 움직이지도 않는다 (_lod)
		var ph2: float = b[2]
		vb.position.y = float(b[1]) + absf(sin(clock * 2.2 + ph2)) * 0.05
		vb.scale = Vector3(1.0 + 0.02 * sin(clock * 4.4 + ph2), 1.0 - 0.02 * sin(clock * 4.4 + ph2), 1.0 + 0.02 * sin(clock * 4.4 + ph2))
	var mp := me.global_position + me.global_transform.basis.y * 1.0
	for e2: Array in vil_pupils:
		var vb2: Node3D = e2[3]
		if not vb2.is_visible_in_tree():
			continue
		var eg2: Node3D = e2[0]
		var pu2: MeshInstance3D = e2[1]
		var er: float = e2[2]
		var lp := vb2.to_local(mp)
		if bool(e2[4]):
			# 몸 겉(타원)을 따라 미끄러진다: 나를 향한 방향(배 아래로는 안 감), 비틀어 서로 안 겹치게, 천천히
			var cc: Vector3 = e2[5]
			var rr: Vector3 = e2[6]
			var want := (lp - cc)
			want.y = maxf(want.y, 0.0) + 0.15
			if want.length_squared() < 0.0001:
				want = Vector3(0, 0, -1)
			want = want.normalized().rotated(Vector3.UP, float(e2[8]))
			var cur_d: Vector3 = e2[7]
			cur_d = cur_d.slerp(want, minf(1.0, dd * 2.2)).normalized()
			e2[7] = cur_d
			eg2.position = cc + cur_d * rr + cur_d * er * 0.45
		var dv := lp - eg2.position
		if dv.length_squared() > 0.0001:
			pu2.position = dv.normalized() * er * 0.62


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


## v11 별 구별: 멀리서 한눈에 알아보는 큰 표지 (장식과 달리 멀어도 안 숨긴다). 별마다 메시 하나 + 구운 외곽선
## 우편 = 높은 우편탑 위 큰 편지 둘(엇갈려) · 유리꽃 = 큰 유리꽃 · 노을 = 기운 노을 고리 · 장미 = 탑 꼭대기 큰 장미 · 굴뚝 = 연기 · 친구 = 큰 꽃
const WM_SC := 1.5  # 풍차 크기 배수
const LM_POST := Vector3(-0.35, 0.8, 0.45)
const LM_GLASS := Vector3(-0.5, 0.75, 0.45)
const LM_FRIEND := Vector3(0.6, 0.55, 0.55)
var smoke_n: Node3D  # 굴뚝 연기 (천천히 돌며 숨쉰다)


func _landmark(k: int, n: Node3D) -> void:
	var col: Color = BD[k].c0
	var r2 := RandomNumberGenerator.new()
	r2.seed = 1300 + k
	_begin()
	var s0 := 0
	match k:
		1:
			var d := LM_POST.normalized()
			var bs := _basis(d)
			var b := d * (_sr(1, d) - 0.1)
			s0 = _tv.size()
			_cyl(b, d, 0.6, 0.42, 6.2, 6, CREAM, CREAM)
			_cyl(b + d * 6.2, d, 0.75, 0.75, 0.35, 6, col.darkened(0.25), col)
			_hull(s0, b + d * 3.0, 0.07)
			for i in 2:
				var ex := (bs.x if i == 0 else bs.z) * 1.9
				var ez := (bs.z if i == 0 else -bs.x) * 0.16
				var c := b + d * 7.9
				s0 = _tv.size()
				_slab(c, ex, d * 1.25, ez, WHITE)
				for sg: float in [1.0, -1.0]:
					var f := c + ez.normalized() * (0.17 * sg)
					var o := ez.normalized() * sg
					_tri(f + ex * 0.98 + d * 1.2, f - ex * 0.98 + d * 1.2, f - d * 0.15, col.darkened(0.15), o)
					_tri(f + d * 0.1 + ex * 0.2, f + d * 0.1 - ex * 0.2, f - d * 0.35, DANGER, o)
				_hull(s0, c, 0.07)
		2:
			var d := LM_GLASS.normalized()
			var bs := _basis(d)
			var b := d * (_sr(2, d) - 0.1)
			s0 = _tv.size()
			_cyl(b, d, 0.28, 0.2, 5.4, 5, Color("2f9e6f"), Color("2f9e6f"))
			_dia(b + d * 2.2 + bs.x * 0.7, 0.2, 0.8, Color("37b24d"), d + bs.x)
			_dia(b + d * 3.2 - bs.z * 0.7, 0.2, 0.8, Color("37b24d"), d - bs.z)
			_hull(s0, b + d * 2.7, 0.06)
			var top := b + d * 5.8
			s0 = _tv.size()
			for i in 6:
				var a := TAU * i / 6.0
				var rd := (bs.x * cos(a) + bs.z * sin(a)).normalized()
				var pd := (rd + d * 0.55).normalized()
				_dia(top + pd * 1.5, 0.75, 1.5, Color("c3fbef") if i % 2 == 0 else Color("8ae9d2"), pd, a)
			_ico(top, Vector3.ONE * 0.6, 1, Color("ffd166"), Color("fff0a6"), r2)
			_hull(s0, top, 0.07)
		3:
			# 노을 고리: 별을 비스듬히 두른 주황→노랑 띠 (토성 고리처럼)
			var nrm := Vector3(0.28, 1.0, 0.18).normalized()
			var u := _basis(nrm).x
			var w := nrm.cross(u)
			var rr := br[3] + 4.6
			s0 = _tv.size()
			for i in 30:
				var a := TAU * i / 30.0
				var rd := u * cos(a) + w * sin(a)
				var tg := (w * cos(a) - u * sin(a)).normalized()
				var cc: Color = Color("ff6b4a").lerp(Color("ffd166"), 0.5 + 0.5 * sin(a * 2.0))
				_dia(rd * rr, 0.42, 0.95, cc, tg, 0.0)
			_hull(s0, Vector3.ZERO, 0.05)
		4:
			# 탑 꼭대기 큰 장미 (멀리서 장미의 별)
			var d := tower_d
			var c := d * (_sr(4, d) + TOWER_H + 1.3)
			s0 = _tv.size()
			_ico(c, Vector3(1.25, 1.05, 1.25), 1, Color("e64980"), Color("f783ac"), r2)
			_ico(c + d * 0.55, Vector3.ONE * 0.6, 1, Color("c2255c"), Color("e64980"), r2)
			var bs := _basis(d)
			for i in 4:
				var a := TAU * i / 4.0 + 0.4
				var ld := (bs.x * cos(a) + bs.z * sin(a)).normalized()
				_dia(c - d * 0.7 + ld * 1.0, 0.45, 0.9, Color("37b24d"), (ld + d * -0.3).normalized())
			_hull(s0, c, 0.07)
		5:
			# 굴뚝 연기: 집 위로 오르는 구름 셋 (smoke_n 이 천천히 돌며 숨쉰다)
			var c: Vector3 = (JOB[1].tdir as Vector3).normalized()
			smoke_n = Node3D.new()
			n.add_child(smoke_n)
			smoke_n.transform = Transform3D(_basis(c), c * (_sr(5, c) + 2.6))
			for i in 3:
				var o := Vector3(0.35 * float(i % 2) - 0.1, 0.6 + 1.25 * i, 0.15 * i)
				var rr := 0.55 + 0.28 * i
				s0 = _tv.size()
				_ico(o, Vector3(rr, rr * 0.8, rr), 1, Color("f1f3f5"), Color("dee2e6"), r2)
				_hull(s0, o, 0.06)
			var sm := MeshInstance3D.new()
			sm.mesh = _end_mesh()
			sm.material_override = _vc(true)
			sm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			smoke_n.add_child(sm)
			return
		6:
			# 친구 달의 큰 꽃
			var d := LM_FRIEND.normalized()
			var bs := _basis(d)
			var b := d * (_sr(6, d) - 0.1)
			s0 = _tv.size()
			_cyl(b, d, 0.22, 0.16, 3.4, 5, Color("2f9e6f"), Color("2f9e6f"))
			_dia(b + d * 1.4 + bs.x * 0.55, 0.18, 0.65, Color("37b24d"), d + bs.x)
			_hull(s0, b + d * 1.7, 0.06)
			var top := b + d * 3.7
			s0 = _tv.size()
			for i in 5:
				var a := TAU * i / 5.0
				var rd := (bs.x * cos(a) + bs.z * sin(a)).normalized()
				var pd := (rd + d * 0.35).normalized()
				_dia(top + pd * 1.0, 0.6, 1.0, Color("f783ac") if i % 2 == 0 else Color("faa2c1"), pd, a)
			_ico(top, Vector3.ONE * 0.5, 1, Color("ffd166"), Color("fff0a6"), r2)
			_hull(s0, top, 0.07)
		_:
			return
	var m := MeshInstance3D.new()
	m.mesh = _end_mesh()
	m.material_override = _vc(true)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(m)


## v11 굴뚝 달: 소포를 놓을 자리 = 노란 점 고리 (지름 tr 호 길이). 소포를 들 때만 보인다 (_items)
func _zone(k: int, c: Vector3, tr_: float, n: Node3D) -> void:
	var bs := _basis(c)
	var al := tr_ / br[k]
	_begin()
	for i in 14:
		var th := TAU * i / 14.0
		var d := (c * cos(al) + (bs.x * cos(th) + bs.z * sin(th)) * sin(al)).normalized()
		_dia(d * (_sr(k, d) + 0.08), 0.3, 0.07, D, d, th)
	zone_b = MeshInstance3D.new()
	zone_b.mesh = _end_mesh()
	zone_b.material_override = _vc(false)
	zone_b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	zone_b.visible = false
	n.add_child(zone_b)


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
	# v7: 끄는 둘레가 보이게 — 둘레 안쪽에 주황 줄무늬 고리 둘 (spin 이 돌린다 = 빨려 드는 소용돌이)
	for ring: Array in [[8.0, 18], [13.5, 26]]:
		var rad: float = ring[0]
		var cnt: int = ring[1]
		for i in cnt:
			var a := TAU * i / float(cnt)
			_dia(Vector3(cos(a), 0, sin(a)) * rad, 0.1, 0.45, A.lightened(0.2) if rad > 10.0 else A, Vector3(-sin(a), 0, cos(a)))
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
	var cnt := int(rr * rr * 0.45) + 5  # v11 지도 정리: 장식 약 60% (0.75R² + 8 → 0.45R² + 5)
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
	_deco_add(k, m)
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
	_deco_add(k, tmi)
	_deco_add(k, hm)


## v8 성능: 별마다 작은 장식(풀·꽃·돌·나무와 외곽선) 메시를 모아 둔다 — 놀이 중 멀리 있는 별은 통째로 숨긴다 (_lod)
var deco_n: Array = []  # 별 번호 -> [MeshInstance3D...]
var deco_on := PackedByteArray()
const DECO_FAR := 80.0  # 카메라에서 별 겉면까지 이보다 멀면 장식을 숨긴다 (멀어도 시작 화면에선 다 보인다)
const VIL_NEAR := 55.0  # v8 30 → 55: 주민은 카메라에서 이 안이면 보인다 (발밑 별이 아니어도, 다가가는 별 주민이 보이게)


func _deco_add(k: int, m: Node3D) -> void:
	while deco_n.size() <= k:
		deco_n.append([])
	(deco_n[k] as Array).append(m)


## 매 프레임 (시작 화면 포함): 먼 별 장식·먼 주민 숨기기. 숨긴 주민은 눈동자·들썩임도 안 고친다 (_posty_anim)
func _lod() -> void:
	if cam == null or nodes.is_empty():
		return
	var cp := cam.global_position
	var title: bool = ui.title_visible()
	if deco_on.size() != deco_n.size():
		deco_on.resize(deco_n.size())
		deco_on.fill(1)
	for k in deco_n.size():
		var far := cp.distance_to(bc[k]) - br[k]
		var lim := DECO_FAR + (2.0 if deco_on[k] == 1 else -2.0)
		var on := 1 if (title or far < lim) else 0
		if on != deco_on[k]:
			deco_on[k] = on
			for m: Node3D in deco_n[k]:
				m.visible = on == 1
	for b: Array in vil_bobs:
		var vb: Node3D = b[0]
		var lim2 := VIL_NEAR + (2.0 if vb.visible else -2.0)
		var bk2 := int(b[3])
		# 지금 갈 곳(칩이 가리키는 별)과 나와 있는 물건의 주인 별·전할 별 주민은 거리와 상관없이 늘 보인다
		var jd: Dictionary = JOB[ij] if ij >= 0 else {}
		var job_k := bk2 == ob_k or bk2 == int(jd.get("src", -1)) or bk2 == int(jd.get("tgt", -1))
		var on2 := not title and (job_k or cp.distance_to(vb.global_position) < lim2)
		if on2 != vb.visible:
			vb.visible = on2


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
			keep.append([Vector3.UP, 2.4 * WM_SC])
			keep.append([START, 1.2])
		4:
			keep.append([(JOB[4].tdir as Vector3).normalized(), 3.0])
			keep.append([tower_d, 1.6])
		5:
			keep.append([(JOB[1].tdir as Vector3).normalized(), 3.4])
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
	for i in 9:  # v11 지도 정리: 먼 구름 무리 16 → 9
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
	# v13: 우주의 작은 별 260개 — 멀리 떠서 하늘이 어두워질수록 또렷해진다 (_sky_tint 가 투명도를 바꾼다)
	var sm := SphereMesh.new()
	sm.radius = 0.5
	sm.height = 1.0
	sm.radial_segments = 4
	sm.rings = 2
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = sm
	mm.instance_count = 260
	for i in 260:
		var d := Vector3(r2.randf_range(-1, 1), r2.randf_range(-1, 1), r2.randf_range(-1, 1))
		if d.length() < 0.05:
			d = Vector3.UP
		var sc := r2.randf_range(1.3, 2.8)
		mm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * sc), MID + d.normalized() * r2.randf_range(330.0, 390.0)))
	_space_mat = StandardMaterial3D.new()
	_space_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_space_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_space_mat.albedo_color = Color(1, 1, 1, _dark)
	_space_stars = MultiMeshInstance3D.new()
	_space_stars.multimesh = mm
	_space_stars.material_override = _space_mat
	_space_stars.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(_space_stars)


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


# ---- v7 캐릭터: 우체통 꼬마 포스티와 왕눈 주민들 (submit/tinyplanet/CHARACTER.md) ----
const POSTY := Color("ff6b5e")  # 산호 우체통
const NOODLE := Color("ffd166")  # 국수 다리
const EYE_W := Color("fffdf7")
const HIP_Y := 0.62
const THIGH := 0.34
const SHIN := 0.24


## 몸: 위가 둥근 우체통 콩 (원점 = 엉덩이, 가운데 y 0.45), 아래 진한 띠
func _shape_posty_body() -> void:
	_rs.seed = 21
	_ico(Vector3(0, 0.45, 0), Vector3(0.4, 0.48, 0.37), 2, POSTY, POSTY.darkened(0.05), _rs)
	_cyl(Vector3(0, 0.03, 0), Vector3.UP, 0.33, 0.37, 0.09, 10, POSTY.darkened(0.28), POSTY.darkened(0.28))
	# 등의 작은 크림 우편 표지 (뒤에서 보는 카메라에 읽히게)
	_slab(Vector3(0, 0.5, 0.36), Vector3(0.11, 0, 0), Vector3(0, 0.08, 0), Vector3(0, 0, 0.02), CREAM)
	_slab(Vector3(0, 0.5, 0.375), Vector3(0.07, 0, 0), Vector3(0, 0.025, 0), Vector3(0, 0, 0.01), POSTY.darkened(0.2))


## 입 = 편지 투입구 (가운데 원점, 놀라면 위아래로 벌어진다)
func _shape_posty_mouth() -> void:
	_slab(Vector3.ZERO, Vector3(0.19, 0, 0), Vector3(0, 0.035, 0), Vector3(0, 0, 0.03), NAVY)


## 왕눈 흰자 (반지름 1, 크기는 노드 scale)
func _shape_eye_white() -> void:
	_rs.seed = 22
	_ico(Vector3.ZERO, Vector3.ONE, 1, EYE_W, EYE_W.darkened(0.04), _rs)


func _shape_pupil() -> void:
	_rs.seed = 23
	_ico(Vector3.ZERO, Vector3.ONE, 1, NAVY, NAVY.lightened(0.08), _rs)


## 정수리 투입구에 꽂힌 편지 (아래 가장자리가 원점)
func _shape_posty_letter() -> void:
	_slab(Vector3(0, 0.1, 0), Vector3(0.15, 0, 0), Vector3(0, 0.1, 0), Vector3(0, 0, 0.012), CREAM)
	_slab(Vector3(0.07, 0.15, -0.014), Vector3(0.035, 0, 0), Vector3(0, 0.035, 0), Vector3(0, 0, 0.005), A)
	_tri(Vector3(-0.15, 0.2, -0.014), Vector3(0.15, 0.2, -0.014), Vector3(0, 0.1, -0.014), CREAM.darkened(0.12), Vector3(0, 0, -1))


## 우체통 깃발: 막대가 +Y, 깃발은 앞(-Z)으로. 드는 중이면 세우고(0), 아니면 뒤로 눕힌다(PI/2)
func _shape_posty_flag() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 0.025, 0.025, 0.34, 4, NAVY, NAVY)
	_slab(Vector3(0, 0.28, -0.08), Vector3(0.014, 0, 0), Vector3(0, 0.055, 0), Vector3(0, 0, 0.085), D)


func _shape_thigh() -> void:
	_cyl(Vector3.ZERO, Vector3.DOWN, 0.06, 0.055, THIGH, 6, NOODLE, NOODLE)


## 정강이 + 둥근 발 (발끝이 앞 -Z)
func _shape_shin() -> void:
	_rs.seed = 24
	_cyl(Vector3.ZERO, Vector3.DOWN, 0.055, 0.05, SHIN, 6, NOODLE, NOODLE)
	_ico(Vector3(0, -SHIN - 0.01, -0.05), Vector3(0.09, 0.06, 0.13), 1, NAVY, NAVY.lightened(0.1), _rs)


## 주민 몸 (변형 v: 0 풍차지기 키다리 캡슐·외눈, 1 우체부 쌓은 공, 2 정원사 넓적 방울, 3 노을 아이 작은 공, 4 꽃 친구 콩)
## v9 눈: 개수 = 예전 x1.5 내림 (1→1, 2→3). 눈 = [자리, 반지름, 떠도나]. 떠도는 눈은 core(가운데, 반지름) 몸 겉을 미끄러져 나를 따라온다.
## 주민마다 다르게: 풍차지기 외눈이 통째로 떠돌고, 우체부는 아래 공에서 하나, 정원사는 둘, 노을 아이는 작은 하나, 꽃 친구는 셋 다.
const VIL := [
	{"eyes": [[Vector3(0, 1.22, -0.25), 0.17, true]], "hip": 0.52, "core": [Vector3(0, 1.05, 0), Vector3(0.3, 0.55, 0.3)]},
	{"eyes": [[Vector3(-0.1, 1.32, -0.2), 0.1, false], [Vector3(0.1, 1.32, -0.2), 0.1, false], [Vector3(0, 0.75, -0.36), 0.09, true]], "hip": 0.41, "core": [Vector3(0, 0.75, 0), Vector3(0.36, 0.36, 0.36)]},
	{"eyes": [[Vector3(0, 1.0, -0.36), 0.11, false], [Vector3(-0.2, 0.9, -0.33), 0.09, true], [Vector3(0.2, 0.9, -0.33), 0.09, true]], "hip": 0.47, "core": [Vector3(0, 0.85, 0), Vector3(0.48, 0.4, 0.42)]},
	{"eyes": [[Vector3(-0.13, 0.98, -0.2), 0.15, false], [Vector3(0.13, 0.98, -0.2), 0.15, false], [Vector3(0, 0.75, -0.28), 0.07, true]], "hip": 0.57, "core": [Vector3(0, 0.85, 0), Vector3(0.3, 0.3, 0.3)]},
	{"eyes": [[Vector3(-0.12, 1.02, -0.24), 0.09, true], [Vector3(0.12, 1.02, -0.24), 0.09, true], [Vector3(0, 0.85, -0.29), 0.08, true]], "hip": 0.5, "core": [Vector3(0, 0.9, 0), Vector3(0.33, 0.42, 0.3)]},
]


func _shape_vil(v: int, body: Color, hat: Color) -> void:
	_rs.seed = 30 + v
	var bd := body.darkened(0.06)
	match v:
		0:
			_ico(Vector3(0, 1.05, 0), Vector3(0.3, 0.55, 0.3), 2, body, bd, _rs)
			_cyl(Vector3(0, 1.56, 0), Vector3.UP, 0.48, 0.44, 0.04, 10, hat, hat)  # 밀짚모자 챙
			_cyl(Vector3(0, 1.6, 0), Vector3.UP, 0.22, 0.04, 0.24, 8, hat.darkened(0.08), hat)
		1:
			_ico(Vector3(0, 0.75, 0), Vector3.ONE * 0.36, 2, body, bd, _rs)
			_ico(Vector3(0, 1.28, 0), Vector3.ONE * 0.26, 1, body.lightened(0.08), body, _rs)
			_cyl(Vector3(0, 1.48, 0), Vector3.UP, 0.19, 0.19, 0.12, 8, hat, hat)  # 우편 모자
			_slab(Vector3(0, 1.5, -0.2), Vector3(0.15, 0, 0), Vector3(0, 0.015, 0), Vector3(0, 0, 0.08), NAVY)
		2:
			_ico(Vector3(0, 0.85, 0), Vector3(0.48, 0.4, 0.42), 2, body, bd, _rs)
			_cyl(Vector3(0, 1.12, 0), Vector3.UP, 0.24, 0.0, 0.3, 8, body, body)
			_cyl(Vector3(0, 1.38, 0), Vector3.UP, 0.025, 0.02, 0.18, 4, GOOD, GOOD)  # 새싹
			_dia(Vector3(-0.09, 1.56, 0), 0.09, 0.03, GOOD.lightened(0.2), Vector3(1, 0.4, 0))
			_dia(Vector3(0.09, 1.56, 0), 0.09, 0.03, GOOD.lightened(0.2), Vector3(-1, 0.4, 0))
		3:
			_ico(Vector3(0, 0.85, 0), Vector3.ONE * 0.3, 2, body, bd, _rs)
			_cyl(Vector3(0, 1.1, 0), Vector3(0.2, 1, 0), 0.06, 0.0, 0.2, 5, hat, hat)  # 삐친 머리
		_:
			_ico(Vector3(0, 0.9, 0), Vector3(0.33, 0.42, 0.3), 2, body, bd, _rs)
			_cyl(Vector3(0, 1.3, 0), Vector3.UP, 0.025, 0.02, 0.16, 4, GOOD, GOOD)
			for i in 5:
				var a := TAU * i / 5.0
				_dia(Vector3(cos(a) * 0.09, 1.5, sin(a) * 0.09), 0.08, 0.03, hat, Vector3(cos(a), 2.0, sin(a)))
			_ico(Vector3(0, 1.5, 0), Vector3.ONE * 0.05, 0, D, D, _rs)
	var hip: float = VIL[v].hip
	for sx: float in [-0.12, 0.12]:
		_cyl(Vector3(sx, hip, 0), Vector3.DOWN, 0.05, 0.045, hip - 0.04, 5, NOODLE, NOODLE)
		_ico(Vector3(sx, 0.03, -0.04), Vector3(0.08, 0.05, 0.11), 0, NAVY, NAVY, _rs)


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


## v7 지뢰 (옛 빨간 바위 띠 자리): 작은 빨간 각진 공 + 가시 10개 + 크림 띠. 가운데 원점
func _shape_mine() -> void:
	_rs.seed = 31
	_ico(Vector3.ZERO, Vector3.ONE * 0.62, 1, DANGER, DANGER.darkened(0.12), _rs)
	for d0: Vector3 in [Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK,
			Vector3(1, 1, 1), Vector3(-1, 1, -1), Vector3(1, -1, -1), Vector3(-1, -1, 1)]:
		var d := d0.normalized()
		_cyl(d * 0.5, d, 0.2, 0.0, 0.6, 4, DANGER.lightened(0.2), CREAM)
	_cyl(Vector3(0, -0.08, 0), Vector3.UP, 0.66, 0.66, 0.16, 10, CREAM, CREAM)


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


## v14 갈 곳 화살표: 끝(원점)이 아래를 가리키는 뿔 + 짧은 자루 (높이 1.7)
func _shape_u_arrow() -> void:
	_cyl(Vector3.ZERO, Vector3.UP, 0.0, 0.6, 0.85, 8, WHITE, WHITE)
	_cyl(Vector3(0, 0.85, 0), Vector3.UP, 0.22, 0.22, 0.85, 8, WHITE, WHITE)


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
const SFX_SMALL := ["step", "ui_tap", "talk", "sail"]  # 잦고 짧은 소리: 다른 소리를 끊지 않는다


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
		for i in 14:
			var np := AudioStreamPlayer.new()
			add_child(np)
			_sfx_pool.append(np)
	# v15 "소리 끊겨": 발소리·경고음·말소리 같은 잦은 짧은 소리는 빈 자리가 없으면 그냥 건너뛴다.
	# 긴 소리(배달·죽음·탈출 등)는 빈 자리가 없을 때 짧은 소리 자리를 먼저 빼앗고, 긴 소리끼리는 가장 오래된 것을 뺏는다
	var small: bool = nm in SFX_SMALL
	var ap: AudioStreamPlayer = null
	var steal: AudioStreamPlayer = null
	var n := _sfx_pool.size()
	for i in n:
		var c: AudioStreamPlayer = _sfx_pool[(_sfx_i + i) % n]
		# 웹 샘플 재생에서도 확실하게: 끝날 시각(직접 계산)이 지났으면 빈 자리로 본다
		if not c.playing or now >= int(c.get_meta("end", 0)):
			ap = c
			break
		if steal == null and c.has_meta("small") and bool(c.get_meta("small")):
			steal = c
	if ap == null:
		if small:
			return
		ap = steal if steal != null else _sfx_pool[_sfx_i % n]
		ap.stop()
	_sfx_i += 1
	ap.set_meta("small", small)
	if ap.stream != st:
		ap.stream = st
	ap.volume_db = db - 4.0
	ap.pitch_scale = clampf(pitch * randf_range(0.97, 1.03), 0.3, 3.0)
	ap.set_meta("end", now + int((st as AudioStream).get_length() * 1000.0 / ap.pitch_scale) + 30)
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
	var tp0 := Time.get_ticks_usec() if _dbg else 0
	super(dt)
	if _dbg:
		_dbg_add("game._process", tp0)
		_dbg_frame(dt)
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
	if (_rating or over or (ui != null and ui.todo_open())) and wind_pl and wind_pl.playing:
		wind_pl.stop()
	if _en and over:
		_over_l.text = "%d\n%s %d%s" % [score, TX.en("tofu.over_best"), best, ("\n" + TX.en("tofu.over_again")) if wait <= 0.0 else ""]
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
	if bub_talk and _talk_tap(event):
		get_viewport().set_input_as_handled()
		return
	if _back_l and _back_l.text in RESTART_TXT:
		var at := Vector2(-1, -1)
		if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
			at = (event as InputEventScreenTouch).position
		elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
			at = (event as InputEventMouseButton).position
		if at.x >= 0.0 and at.x < 180.0 and at.y >= 0.0 and at.y < 100.0:
			return
	super(event)


## ?debug=1 (웹) 이면 왼쪽 위에 성능 표: FPS·프레임 간격, 그리기 수, 물체 수, 삼각형 수, 무거운 블록 시간(평균/최대 usec)
func _dbg_build() -> void:
	var on := OS.get_cmdline_user_args().has("debug")
	if OS.has_feature("web"):
		on = str(JavaScriptBridge.eval("location.search.indexOf('debug=1')>=0?'y':'n'", true)) == "y"
	if not on:
		return
	var cl := CanvasLayer.new()
	cl.layer = 120
	add_child(cl)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.position = Vector2(4, 104)
	bg.size = Vector2(470, 530)  # v10: 도움 힌트 셈 두 줄
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(bg)
	_dbg = Label.new()
	_dbg.position = Vector2(10, 4)
	_dbg.add_theme_font_size_override("font_size", 19)
	_dbg.add_theme_color_override("font_color", Color.WHITE)
	_dbg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(_dbg)
	_dbg_last = Time.get_ticks_usec()
	if fx:
		fx.dbg = true
	if ui:
		ui.dbg = true
	if OS.has_feature("web"):
		_dbg_cb = JavaScriptBridge.create_callback(_dbg_js)
		JavaScriptBridge.get_interface("window").set("tpcmd", _dbg_cb)


## 브라우저 콘솔 실험: 결과는 window.tpout 에
func _dbg_js(args: Array) -> void:
	var out := _dbg_cmd(str(args[0]) if args.size() > 0 else "")
	JavaScriptBridge.eval("window.tpout=" + JSON.stringify(out), true)


func _dbg_cmd(cmd: String) -> String:
	var a := cmd.split(" ", false)
	if a.is_empty():
		return "?"
	match a[0]:
		"list":
			_dbg_nodes.clear()
			var rows: Array = []
			_dbg_walk(self, rows, a.size() > 1)
			return "
".join(rows)
		"vis":
			var gi: Node3D = _dbg_nodes[int(a[1])]
			gi.visible = a[2] == "1"
			return "ok"
		"ol":
			if a[1] == "0":
				for m: Variant in _mats3.values():
					if m is BaseMaterial3D and (m as BaseMaterial3D).next_pass:
						_dbg_np[m] = (m as BaseMaterial3D).next_pass
						(m as BaseMaterial3D).next_pass = null
			else:
				for m: Variant in _dbg_np:
					(m as BaseMaterial3D).next_pass = _dbg_np[m]
				_dbg_np.clear()
			return "ok"
		"cv":
			var n := 0
			for c in _dbg_layers(self, []):
				if c != _dbg.get_parent().get_parent():
					(c as CanvasLayer).visible = a[1] == "1"
					n += 1
			return "layers %d" % n
		"uivis":
			(ui.get(a[1]) as CanvasItem).visible = a[2] == "1"
			return "ok"
		"all3d":
			world.visible = a[1] == "1"
			(fx.get("_root") as Node3D).visible = a[1] == "1"
			return "ok"
		"simbench":
			var w := bc[cur] + p
			var up := p.normalized()
			var v0 := _jump_v(up, vel + up * JUMP) if grounded else vel
			if v0.length() < 1.0:
				v0 = _flat(fwd, up) * 9.0 + up * JUMP
			var tb := Time.get_ticks_usec()
			var res := 0
			for i in 50:
				res = _sim(w + up * 0.1, v0, cur, 0.0, SIM_SECS, SIM_H, _lost_pts, cur)
			return "sim %d us/run res %d pts %d" % [(Time.get_ticks_usec() - tb) / 50, res, _lost_pts.size()]
		"maxfps":
			Engine.max_fps = int(a[1])
			return "ok"
		"s3d":
			get_viewport().scaling_3d_scale = float(a[1])
			return "ok"
		"launch":
			var up := p.normalized()
			_liftoff()
			vel = _flat(fwd, up) * sqrt(maxf(gp + 1.19, 0.5) * R) * float(a[1] if a.size() > 1 else "1.1") + up * JUMP
			return "ok"
	return "?"


func _dbg_layers(n: Node, acc: Array) -> Array:
	for ch in n.get_children():
		if ch is CanvasLayer:
			acc.append(ch)
		_dbg_layers(ch, acc)
	return acc


func _dbg_walk(n: Node, rows: Array, all: bool) -> void:
	for ch in n.get_children():
		if ch is GeometryInstance3D and (ch as GeometryInstance3D).is_visible_in_tree():
			var gi := ch as GeometryInstance3D
			var mesh: Mesh = null
			var inst := 1
			if gi is MeshInstance3D:
				mesh = (gi as MeshInstance3D).mesh
			elif gi is MultiMeshInstance3D and (gi as MultiMeshInstance3D).multimesh:
				var mm := (gi as MultiMeshInstance3D).multimesh
				mesh = mm.mesh
				inst = mm.visible_instance_count if mm.visible_instance_count >= 0 else mm.instance_count
			elif gi is CPUParticles3D:
				mesh = (gi as CPUParticles3D).mesh
				inst = (gi as CPUParticles3D).amount
			var tris := 0
			var passes := 0
			if mesh:
				for si in mesh.get_surface_count():
					var m: Material = gi.material_override if gi.material_override else mesh.surface_get_material(si)
					passes += 1
					while m and m.next_pass:
						passes += 1
						m = m.next_pass
					if mesh is ArrayMesh:
						var il := (mesh as ArrayMesh).surface_get_array_index_len(si)
						tris += (il if il > 0 else (mesh as ArrayMesh).surface_get_array_len(si)) / 3
			var ab := gi.global_transform * gi.get_aabb()
			var inf := true
			for pln in cam.get_frustum():
				var c := ab.get_center()
				var e := ab.size * 0.5
				var r := absf(pln.normal.x) * e.x + absf(pln.normal.y) * e.y + absf(pln.normal.z) * e.z
				if pln.distance_to(c) > r:
					inf = false
					break
			if inf or all:
				var i := _dbg_nodes.size()
				_dbg_nodes.append(gi)
				rows.append("%d %s/%s inf=%s d=%.0f aabb=%.0f tri=%d x%d pass=%d" % [i, str(gi.get_parent().name), gi.get_class(), inf, cam.global_position.distance_to(ab.get_center()), ab.size.length(), tris, inst, passes])
		_dbg_walk(ch, rows, all)


## 구간 합·최대에 더하고 지금 시각을 돌려준다 (다음 블록 시작으로 쓴다)
func _dbg_add(nm: String, t0: int) -> int:
	if _dbg == null:
		return 0
	var t1 := Time.get_ticks_usec()
	var us := t1 - t0
	_dbg_sum[nm] = int(_dbg_sum.get(nm, 0)) + us
	if us > int(_dbg_max.get(nm, 0)):
		_dbg_max[nm] = us
	return t1


func _dbg_frame(_dt: float) -> void:
	var now := Time.get_ticks_usec()
	var gap := now - _dbg_last
	_dbg_last = now
	_dbg_fmax = maxi(_dbg_fmax, gap)
	_dbg_n += 1
	_dbg_sum["frame"] = int(_dbg_sum.get("frame", 0)) + gap
	if fx:
		_dbg_sum["fx.clouds"] = int(_dbg_sum.get("fx.clouds", 0)) + fx.dbg_cl
		_dbg_max["fx.clouds"] = maxi(int(_dbg_max.get("fx.clouds", 0)), fx.dbg_cl)
		_dbg_sum["fx.overlay"] = int(_dbg_sum.get("fx.overlay", 0)) + fx.dbg_ov
		_dbg_max["fx.overlay"] = maxi(int(_dbg_max.get("fx.overlay", 0)), fx.dbg_ov)
		fx.dbg_cl = 0
		fx.dbg_ov = 0
	if ui:
		_dbg_sum["ui._process"] = int(_dbg_sum.get("ui._process", 0)) + ui.dbg_us
		_dbg_max["ui._process"] = maxi(int(_dbg_max.get("ui._process", 0)), ui.dbg_us)
		ui.dbg_us = 0
	_dbg_win += float(gap) / 1000000.0
	if _dbg_win < 0.5:
		return
	var n := maxi(_dbg_n, 1)
	var mode := "title" if ui.title_visible() else ("ground p%d" % cur if grounded else "fly p%d" % cur)
	var vs := get_viewport().get_visible_rect().size
	var ws := DisplayServer.window_get_size()
	var t := "FPS %d  frame %.1f ms (max %.1f)  %s
" % [Engine.get_frames_per_second(), float(_dbg_sum["frame"]) / n / 1000.0, _dbg_fmax / 1000.0, mode]
	t += "draws %d  objs %d  prims %dk
" % [Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME), int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME) / 1000.0)]
	t += "proc %.2f ms  win %dx%d  vp %dx%d  sc %.2f
" % [Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, ws.x, ws.y, int(vs.x), int(vs.y), get_viewport().scaling_3d_scale]
	t += "block      avg us   max us
"
	for nm: String in ["game._process", "step", "hud", "vis+posty", "tick", "sim", "ui.tick", "fx.tick", "fx.clouds", "fx.overlay", "ui._process"]:
		t += "%-12s %6d  %6d
" % [nm, int(_dbg_sum.get(nm, 0)) / n, int(_dbg_max.get(nm, 0))]
	t += _help_dbg()
	_dbg_txt = t
	_dbg.text = t
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.tpdbg=" + JSON.stringify(t), true)  # 브라우저 콘솔에서 읽기
	_dbg_win = 0.0
	_dbg_n = 0
	_dbg_fmax = 0
	_dbg_sum.clear()
	_dbg_max.clear()


## v8 성능: 조작판(스틱·버튼)은 tofu 가 매 프레임 다시 그린다. tofu 의 draw_circle·draw_arc 는 웹 호환 렌더러에서 부를 때마다
## GPU 버퍼를 새로 만들어서, 같은 모양을 한 번 만든 2D 메시로 그린다 (모양·색·크기는 tofu _kit_draw 와 같다)
var _kd_disc: ArrayMesh
var _kd_rings := {}  # 반지름 -> 두께 6 고리 메시


func _kit_draw(c: Control) -> void:
	_ring_draw(c)
	if _stick_zone.has_area():
		var o := _st_o if _stick_on else _st_home
		_kd_circle(c, o, _STICK_R, Color(1, 1, 1, 0.45))
		_kd_ring(c, o, _STICK_R, ME)
		_kd_circle(c, o + kit_move * _STICK_R, 48.0, ME)
	for n: String in _btns:
		var b: Dictionary = _btns[n]
		var r: float = b.r * (0.92 if b.down else 1.0)
		var col: Color = b.color
		_kd_circle(c, b.pos, r, col.lightened(0.35) if b.down else col)
		_kd_ring(c, b.pos, r, WHITE)
		var fs := int(clampf(b.r * 0.42, 22.0, 44.0))
		c.draw_string(_font, b.pos + Vector2(-r, fs * 0.35), b.label, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, WHITE)


func _kd_mesh(vs: PackedVector2Array, ix: PackedInt32Array) -> ArrayMesh:
	var cs := PackedColorArray()
	cs.resize(vs.size())
	cs.fill(Color.WHITE)
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vs
	arr[Mesh.ARRAY_COLOR] = cs
	arr[Mesh.ARRAY_INDEX] = ix
	var am := ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return am


## 꽉 찬 원 (draw_circle 처럼 64 조각, 단위 원을 r 배)
func _kd_circle(c: Control, o: Vector2, r: float, col: Color) -> void:
	if _kd_disc == null:
		var vs := PackedVector2Array([Vector2.ZERO])
		var ix := PackedInt32Array()
		for i in 64:
			var a := TAU * float(i) / 64.0
			vs.append(Vector2(cos(a), sin(a)))
			ix.append_array([0, 1 + i, 1 + (i + 1) % 64])
		_kd_disc = _kd_mesh(vs, ix)
	c.draw_mesh(_kd_disc, null, Transform2D(0.0, Vector2(r, r), 0.0, o), col)


## 두께 6 고리 (draw_arc(o, r, 0, TAU, 48, col, 6.0) 처럼 반지름 r 을 가운데로 안팎 3)
func _kd_ring(c: Control, o: Vector2, r: float, col: Color) -> void:
	var key := snappedf(r, 0.01)
	if not _kd_rings.has(key):
		var vs := PackedVector2Array()
		var ix := PackedInt32Array()
		for i in 48:
			var a := TAU * float(i) / 48.0
			var d := Vector2(cos(a), sin(a))
			vs.append(d * (r - 3.0))
			vs.append(d * (r + 3.0))
			var j := (i + 1) % 48
			ix.append_array([i * 2, i * 2 + 1, j * 2 + 1, i * 2, j * 2 + 1, j * 2])
		_kd_rings[key] = _kd_mesh(vs, ix)
	c.draw_mesh(_kd_rings[key], null, Transform2D(0.0, o), col)


## smoke(화면 없음)에서 한 번: 그리는 것 수를 센다 (MeshInstance3D·MultiMesh, 재질의 next_pass 외곽선까지 = 대략 그리기 수)
var _counted := false


func _count_draws() -> void:
	var c := [0, 0, 0, 0]  # 메시 노드, MultiMesh 노드, 그리기(전부), 그리기(지금 보이는 것)
	_count_in(self, c)
	print("tinyplanet v7 count: MeshInstance3D %d, MultiMeshInstance3D %d, draw passes all %d, visible now %d" % c)


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

# ---- v10 도움 힌트 (submit/tinyplanet/HELP_HINTS.md) ----
## 못 하는 것을 셈하다 문턱을 넘으면 아래 말풍선에 짧은 글 하나 (잘하는 사람은 문턱에 안 닿는다).
## 같은 힌트: 1번째 뒤 다시 문턱이 차면(최소 HELP_GAP 뒤) 2번째 = 더 자세한 글 + 그림·도와주기, 그 뒤로는 HELP_CD 쉰다 (판마다 새로).
## 쉬는 중에 문턱이 차면 셈만 0으로 (다시 처음부터 쌓여야 나온다). 서로 다른 힌트 사이도 HELP_ANY 쉰다. 말풍선이 떠 있으면 기다린다.
## 도와주기·그림은 정해진 시간 뒤 마지막 6초에 걸쳐 원래로 돌아온다. 다시 걸리면 시간만 다시 채운다 (쌓이지 않는다).
const HELP_GAP := 20.0
const HELP_CD := 150.0
const HELP_ANY := 10.0
const ASSIST_T := 25.0
var hl_lv := {}  # 힌트 이름 -> 알려 준 단계 (1, 2)
var hl_next := {}  # 힌트 이름 -> 다시 알려도 되는 clock
var hl_any := 0.0
var hcue := {}  # 그림·도와주기 이름 -> 남은 초: stick gauge arrow todo beacon sail mark / esc home vmax band sling
var h_idle := 0.0  # 1 안 움직인 시간 (이번 판 거의 안 달려 본 사람만)
var h_run := 0.0  # 이번 판 땅에서 달린 거리
var h_nolift := 0.0  # 2 미는데 이륙선 60% 밑인 시간 (60% 넘으면 0)
var h_jumps := 0  # 3 갈 곳이 다른 별인데 뛰어서 제 별로 돌아온 수 (다른 별에 닿거나 탈출하면 0)
var h_stay := 0.0  # 3 첫 실패 뒤 흐른 시간
var h_lost := 0  # 4 우주 미아 (끌려 돌아옴·떠내려가 죽음) 수 (다른 별에 닿으면 0)
var h_goal := 0.0  # 5 갈 곳 별에 못 간 시간 (그 별에 서면 0)
var h_crack := 0  # 6 유리 금·깨짐 수 (유리 배달하면 0)
var h_band := 0  # 7 노을 띠 놓친 수 (띠 부탁 끝나면 0)
var h_band_in := false
var h_band_out := 0.0
var h_fire := 0  # 8 불 별·지뢰 울타리 죽음 수 (덮개 배달하면 0)
var h_sailmiss := 0  # 9 돛이 있는데 안 쓰고 빗나간 비행 수 (돛을 쓰면 0)
var h_drop := 0.0  # 10 소포를 들고 굴뚝 달 근처에 있은 시간 (배달하면 0)
var h_sling := PackedVector3Array()  # 새총 길 미리 보기 점 (노을의 별 → 장미의 별)
var help_mm: MultiMesh
var as_esc := 0.0  # 도와주기 세기 0..1 (_help_tick 이 매 프레임 한 번 고친다 — 비행 계산이 사전을 안 읽게)
var as_home := 0.0
var as_vmax := 0.0
var as_band := 0.0
var as_sling := 0.0
var _beacon_lit := false
var _help_drew := false
var _nudged := false


func _help_reset() -> void:
	hl_lv.clear()
	hl_next.clear()
	hcue.clear()
	hl_any = 0.0
	h_idle = 0.0
	h_run = 0.0
	h_nolift = 0.0
	h_jumps = 0
	h_stay = 0.0
	h_lost = 0
	h_goal = 0.0
	h_crack = 0
	h_band = 0
	h_band_in = false
	h_band_out = 0.0
	h_fire = 0
	h_sailmiss = 0
	h_drop = 0.0
	h_sling.clear()
	as_esc = 0.0
	as_home = 0.0
	as_vmax = 0.0
	as_band = 0.0
	as_sling = 0.0
	_beacon_lit = false
	_help_drew = false
	_nudged = false
	if ui:
		ui.todo_nudge(false)
	help_mm = MultiMesh.new()
	help_mm.transform_format = MultiMesh.TRANSFORM_3D
	help_mm.use_colors = true
	help_mm.mesh = _dots_mesh()
	help_mm.instance_count = ND
	help_mm.visible_instance_count = 0
	var hmi := MultiMeshInstance3D.new()
	hmi.multimesh = help_mm
	hmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(hmi)


## 그림·도와주기 세기 0..1 (마지막 6초에 걸쳐 0으로)
func _cue(nm: String) -> float:
	return clampf(float(hcue.get(nm, 0.0)) / 6.0, 0.0, 1.0)


func _cue_on(nm: String, t: float) -> void:
	hcue[nm] = maxf(float(hcue.get(nm, 0.0)), t)


## 힌트 하나: 쉬는 중이면 0, 아니면 이번 단계(1·2) 글을 아래 말풍선에 내고 단계를 돌려준다. alt2 = 2단계에 쓸 다른 키
func _help(id: String, alt2 := "") -> int:
	if clock < float(hl_next.get(id, -1.0)):
		return 0
	var lv := mini(int(hl_lv.get(id, 0)) + 1, 2)
	hl_lv[id] = lv
	hl_next[id] = clock + (HELP_GAP if lv == 1 else HELP_CD)
	hl_any = clock + HELP_ANY
	_say("", _tx(alt2 if lv == 2 and alt2 != "" else "help.%s%d" % [id, lv]), 4.2)
	return lv


## 일이 일어날 때 (_emit 이 먼저 부른다): 실패를 세고, 성공이면 그 셈을 0으로
func _help_ev(nm: String, d: Dictionary) -> void:
	match nm:
		"escape":
			h_jumps = 0
			h_stay = 0.0
		"land":
			if cur != from_b:
				h_jumps = 0
				h_stay = 0.0
				h_lost = 0
				h_nolift = 0.0
			elif ob_k >= 0 and ob_k != cur:
				if fly_t < 4.0:
					h_jumps += 1  # 뛰었는데 제 별로 돌아왔다
				elif has_sail and not airjump:
					h_sailmiss += 1  # 오래 날다 제 별로 (돛을 안 씀)
		"tow":
			h_lost += 1
			if has_sail and not airjump:
				h_sailmiss += 1
		"die":
			var why := str(d.get("why", ""))
			if why == "fire" or why == "rocks":
				h_fire += 1
			elif why == "drift":
				h_lost += 1
				if has_sail and not airjump:
					h_sailmiss += 1
		"crack", "shatter":
			h_crack += 1
		"sail":
			h_sailmiss = 0
		"deliver":
			var j := int(d.get("job", -1))
			if j == 1:
				h_drop = 0.0
				hcue.erase("mark")
			elif j == 2 or j == 4:
				h_crack = 0
		"job_done":
			var j2 := int(d.get("job", -1))
			if j2 == 3:
				h_band = 0
				hcue.erase("band")
			elif j2 == 4:
				h_fire = 0
				hcue.erase("sling")


## 노을 띠 놓침: 띠 위에 있다가 1.5초 넘게 벗어나면 한 번 (가장자리에서 들락날락은 안 센다)
func _help_band(inb: bool, dt: float) -> void:
	if inb:
		h_band_in = true
		h_band_out = 0.0
	elif h_band_in:
		h_band_out += dt
		if h_band_out > 1.5:
			h_band_in = false
			h_band += 1


## 매 프레임 (_play): 그림·도와주기 시간 줄이기, 셈, 문턱 넘은 힌트 하나
func _help_tick(dt: float) -> void:
	if not hcue.is_empty():
		for nm: String in hcue.keys():
			var left := float(hcue[nm]) - dt
			if left <= 0.0:
				hcue.erase(nm)
			else:
				hcue[nm] = left
	as_esc = _cue("esc")
	as_home = _cue("home")
	as_vmax = _cue("vmax")
	as_band = _cue("band")
	as_sling = _cue("sling")
	var hn := h_sling.size() if as_sling > 0.0 else 0
	if help_mm and help_mm.visible_instance_count != hn:
		if hn > 0:
			_dots_fill(help_mm, h_sling, GOOD, DOT_SC)
		else:
			help_mm.visible_instance_count = 0
	var tn := hcue.has("todo")
	if tn != _nudged:
		_nudged = tn
		ui.todo_nudge(tn)
	if die_t > 0.0 or fin_t > 0.0 or tow_t > 0.0 or won:
		return
	# ---- 셈 ----
	var spd := vel.length()
	if grounded:
		h_run += spd * dt
		var lf := sqrt(maxf(gp + float(P.grip), 0.5) * R)
		var push := kit_move.length() > 0.05
		if push:
			h_idle = 0.0
		elif spd < 0.5 and h_run < 60.0 and bub_t <= 0.0 and bub_q.is_empty():
			h_idle += dt
		if spd >= lf * 0.6:
			h_nolift = 0.0
		elif push:
			h_nolift += dt
		if h_jumps > 0 and ob_k >= 0 and ob_k != cur:
			h_stay += dt
	if ob_k >= 0 and ob_k != cur:
		h_goal += dt
	elif ob_k == cur:
		h_goal = 0.0
	if item == "pkg" and (bc[cur] + p).distance_to(bc[5]) < br[5] + 12.0:
		h_drop += dt
	# ---- 힌트 (말풍선이 비고, 다른 힌트 뒤 쉬는 시간이 끝났을 때 하나만) ----
	if bub_t > 0.3 or not bub_q.is_empty() or clock < hl_any:
		return
	var lv := 0
	if h_idle >= 8.0:
		h_idle = 0.0
		lv = _help("idle")
		if lv == 2:
			_cue_on("stick", 8.0)
		if lv > 0:
			return
	if h_nolift >= 20.0:
		h_nolift = 0.0
		lv = _help("lift")
		if lv == 2:
			_cue_on("gauge", 8.0)
		if lv > 0:
			return
	if grounded and (h_jumps >= 4 or (h_jumps >= 1 and h_stay >= 30.0)):
		h_jumps = 0
		h_stay = 0.0
		lv = _help("jump")
		if lv == 2:
			_cue_on("esc", ASSIST_T)
			_cue_on("gauge", 6.0)
		if lv > 0:
			return
	if grounded and has_sail and h_sailmiss >= 3:
		h_sailmiss = 0
		lv = _help("sail")
		if lv == 2:
			_cue_on("sail", 30.0)
		if lv > 0:
			return
	if grounded and h_lost >= 2:
		h_lost = 0
		lv = _help("lost")
		if lv == 2:
			_cue_on("home", ASSIST_T)
		if lv > 0:
			return
	if h_crack >= 2:
		h_crack = 0
		lv = _help("glass")
		if lv == 2:
			_cue_on("vmax", ASSIST_T)
		if lv > 0:
			return
	if h_band >= 3:
		h_band = 0
		lv = _help("band")
		if lv == 2:
			_cue_on("band", ASSIST_T)
		if lv > 0:
			return
	if grounded and h_fire >= 2:
		h_fire = 0
		var alt := ""
		if int(hl_lv.get("fire", 0)) >= 1 and clock >= float(hl_next.get("fire", -1.0)):
			_help_sling()
			if h_sling.is_empty():
				alt = "help.fire2b"
		lv = _help("fire", alt)
		if lv == 2:
			_cue_on("sling", 40.0)
		if lv > 0:
			return
	if h_drop >= 15.0:  # v11 "굴뚝 너무 어려워": 40초 → 15초 (빗나간 놓기는 한 번에 8초)
		h_drop = 0.0
		lv = _help("drop")
		if lv == 1:
			_cue_on("mark", 15.0)
		if lv == 2:
			_cue_on("mark", 30.0)
		if lv > 0:
			return
	if h_goal >= 90.0:
		h_goal = 0.0
		lv = _help("goal")
		if lv == 1:
			_cue_on("arrow", 20.0)
			_cue_on("todo", 20.0)
		elif lv == 2:
			_cue_on("beacon", 30.0)
			_cue_on("arrow", 20.0)


## 새총 길: 노을의 별(3) 적도에서 힘껏 달려 뛰면 장미의 별(4)에 닿는 길 하나를 찾는다 (_lane 과 같은 방법, 없으면 빈 채로)
func _help_sling() -> void:
	h_sling.clear()
	var lift := sqrt(maxf(bg[3] + float(BD[3].grip), 0.5) * br[3])
	var pts := PackedVector3Array()
	var ax := _lane_axes(3, 4)
	for sg: float in [1.0, -1.0]:
		for i in 48:
			var a := TAU * i / 48.0
			var d := ax[0] * cos(a) + ax[1] * sin(a)
			var tg := (ax[1] * cos(a) - ax[0] * sin(a)) * sg
			if _sim(bc[3] + d * (br[3] + 0.1), tg * lift * 0.96 + d * JUMP, 3, 0.0, 9.0, 1.0 / 20.0, pts) == 4:
				h_sling = pts.duplicate()
				return


## 도움 그림 (갈 곳 화살표 판에 같이 그린다): 스틱 자리에서 위로 미는 손가락, 위 막대 둘레 깜빡 + 끝을 가리키는 삼각형
func _help_draw() -> void:
	var ks := _cue("stick")
	if ks > 0.0:
		var ph := fposmod(clock, 1.2) / 1.2
		if ph < 0.85:
			var o: Vector2 = _st_home + Vector2(0.0, -70.0 * smoothstep(0.0, 0.6, ph))
			var al := clampf(ks * 2.0, 0.0, 1.0)
			arrow.draw_rect(Rect2(o + Vector2(-26, 0), Vector2(52, 120)), Color(NAVY, al))
			arrow.draw_circle(o, 26.0, Color(NAVY, al))
			arrow.draw_rect(Rect2(o + Vector2(-20, 0), Vector2(40, 114)), Color(CREAM, al))
			arrow.draw_circle(o, 20.0, Color(CREAM, al))
			arrow.draw_circle(o + Vector2(0, -6), 8.0, Color(Color("ffd166"), al))
	var kg := _cue("gauge")
	if kg > 0.0 and fposmod(clock, 0.8) < 0.5 and _btns.has("jump"):
		# v12: 빠르기 고리(점프 버튼 둘레)를 노란 테로 감싸고 왼쪽 위에서 세모로 가리킨다
		var jb: Dictionary = _btns["jump"]
		var jo: Vector2 = jb.pos
		var jr: float = float(jb.r) + 30.0
		arrow.draw_arc(jo, jr + 4.0, 0.0, TAU, 64, NAVY, 3.0, true)
		arrow.draw_arc(jo, jr, 0.0, TAU, 64, Color("ffd166"), 6.0, true)
		var tp := jo + Vector2(-0.7071, -0.7071) * (jr + 10.0)
		_tri3[0] = tp
		_tri3[1] = tp + Vector2(-44, -8)
		_tri3[2] = tp + Vector2(-8, -44)
		arrow.draw_colored_polygon(_tri3, NAVY)


## ?debug=1 표 아래: 도움 힌트 셈
func _help_dbg() -> String:
	var s := "help idle %.0f lift %.0f jump %d/%.0f lost %d goal %.0f\n" % [h_idle, h_nolift, h_jumps, h_stay, h_lost, h_goal]
	s += "  glass %d band %d fire %d sail %d drop %.0f\n" % [h_crack, h_band, h_fire, h_sailmiss, h_drop]
	s += "  lv %s cue %s\n" % [str(hl_lv), str(hcue.keys())]
	return s


# ---- 말 (모든 글은 g/tinyplanet_text.gd 의 TX.TEXT) ----
func _tx(key: String, args := {}) -> String:
	if not TX.TEXT.has(key):
		return key
	var s := tr(key)  # 번역 열쇠 = 키 (TX.make 가 en·ko 번역을 만든다)
	if not args.is_empty():
		s = s.format(args)
	return s


## 별 k 주민의 말 (ask / hint / thanks / thanks2 / idle1 / idle2)
func _line(k: int, part: String) -> String:
	var key := str(BD[k].id) + "." + part
	return _tx(key) if TX.TEXT.has(key) else ""


## 영어 번역은 이 게임이 떠 있는 동안만 TranslationServer 에 둔다 (나가면 빼서 다른 게임 글이 영어로 바뀌지 않게).
## 단독판 "처음부터"는 새 게임이 먼저 뜨고 옛 게임이 나중에 빠질 수 있어 쓰는 수를 센다.
static var _tl: Translation
static var _tl_n := 0
static var _tl_ko: Translation
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
	# 한국어 = 원문 그대로인 ko 번역을 하나 올려 둔다. 없으면 ko 고를 때 대체 언어(en) 번역이 쓰여 영어가 나왔다
	if _tl_ko == null:
		var tk: Translation = TX.make(true)  # 키 -> 한국어 (g/tinyplanet_text.gd 한 표에서)
		for k: String in FX_GD.EN:
			tk.add_message(k, k)
		_tl_ko = tk
		TranslationServer.add_translation(tk)
	if not en:
		# 영어 번역을 내린다: 올려 두면 ko 번역이 없어서 대체 언어(en)로 영어가 그대로 나온다
		# 이 판·지난 판 어느 쪽이 올렸든 통째로 내린다 (판이 바뀌면 _tl_on 이 새로 false 라 셈이 어긋났다)
		if _tl != null:
			TranslationServer.remove_translation(_tl)
		_tl_on = false
		_tl_n = 0
		TranslationServer.set_locale("ko")
		return
	if _tl == null:
		var tl: Translation = TX.make(false)  # 키 -> English (본체·ui·tofu 글 모두 같은 표)
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
