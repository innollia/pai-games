extends Tofu
## 신전석을 끌어 바다까지 굴린다. 깔면 커지고 무거워진다. 수로 추락은 보라 수정 동굴(하늘·풍경이 바뀜)로 떨어져 보석을 모으고 노란 출구로 합류한다. 쪼개면 1.3초 돌진(집·석상·얼음벽 관통). 파란 머리 탑·황금 신상은 공중 버티기 내려찍기로만 깨지고 깨면 빨라진다. 다른 구역 추락과 1.5초 저속은 탈락. 흰 빗금 눈은 성장, 노란 길은 해빙, 빨강은 위험. 구역 끝 섞기는 배운 동작을 조합한다. 보라 수정은 초록 조준선일 때 몸 조각을 던져 깬다. 죽으면 구역 처음부터.
# 한 문장: 나는 신전에서 풀려난 거대한 돌로서 "멈추면 끝" 속에서 깔고 꺾고 뛰고 쪼개어 바다까지 굴러가지만, 깔수록 무거워져 오르막·점프·회전에서 속도를 잃는 대가를 감수한다.

const STONE := Color("efe1c4")
const ROCK := Color("e0c896")
const GRASS := Color("8ce99a")
const WATER := Color("a5d8ff")
const GRV := 40.0     # 비탈에서 끄는 힘
const FALL := 32.0    # 공중에서 떨어지는 힘
const DRAG := 0.0014
const ROLL := 0.3
const VSTOP := 8.0    # 이 아래로 STOP_T 초면 멈춤
const STOP_T := 1.5
const VMAX := 55.0    # 게이지 끝
const SMAX := 7.0
const JUMP := 15.0    # 뛰기 세기 (무거울수록 낮게)
const TURN_C := 0.064 # 회전에서 바깥으로 밀리는 정도
const SKILL_COL := {"jump": D, "split": C, "hold": B, "throw": A}
const ICE := Color("397c99")
const ICEWALL := Color("8fd0ff")
const SNOW_GROW := 0.02  # 눈 위 1m 마다 커지는 양
const SUN_MELT := 0.035  # 녹는 길 1m 마다 작아지는 양
# 깔 것: 크기, 깔 수 있는 내 크기, 점수, 커지는 양, 무게(깔 때 속도가 줄어드는 정도), 색
const KIND := {
	"pot": {"size": Vector3(1.4, 1.4, 1.4), "need": 0.0, "pts": 1, "grow": 0.09, "mass": 0.06, "col": [A, D]},
	"statue": {"size": Vector3(1.8, 3.2, 1.8), "need": 2.5, "pts": 3, "grow": 0.25, "mass": 0.18, "col": [WHITE, STONE]},
	"pillar": {"size": Vector3(2.2, 10.0, 2.2), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [WHITE]},
	"fence": {"size": Vector3(3.6, 1.2, 0.4), "need": 0.0, "pts": 1, "grow": 0.04, "mass": 0.04, "col": [WHITE, ROCK]},
	"house": {"size": Vector3(5.0, 4.0, 5.0), "need": 3.4, "pts": 8, "grow": 0.5, "mass": 0.4, "col": [A, B, C]},
	"wall": {"size": Vector3(4.4, 1.4, 1.2), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [ROCK]},
	"post": {"size": Vector3(1.4, 6.0, 1.4), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [D]},
	# 얼음벽: 벽 높이(4.5)만큼 크거나, 쪼갠 직후 돌진이면 깨진다. 뛰어 내려찍기로는 안 깨진다.
	"ice": {"size": Vector3(3.6, 4.5, 1.6), "need": 4.5, "pts": 6, "grow": 0.0, "mass": 0.22, "col": [ICEWALL, WHITE], "nodive": true},
	# 수정: 몸으로는 못 깨고, 던진 덩이로만 깨진다.
	"crystal": {"size": Vector3(3.6, 3.2, 1.2), "need": 99.0, "pts": 4, "grow": 0.0, "mass": 0.0, "col": [C], "nodive": true, "shot": true},
	# 파란 머리(버티기 색) = 공중에서 버티기로 내려찍어야 부서진다. 그냥 굴러 박거나 그냥 떨어지면 튕긴다.
	# 부수면 느려지지 않고 오히려 빨라진다(boost). 집 다음 단계: 탑 → 황금 신상.
	"tower": {"size": Vector3(4.2, 9.0, 4.2), "need": 99.0, "pts": 20, "grow": 0.4, "mass": 0.0, "col": [Color("cfe6ff"), WHITE], "slam": true, "boost": 9.0},
	# 절벽 아래 착지 자리를 통째로 덮는 파란 지붕 탑: 떨어지며 버티기로만 깨진다 (그냥 날아 넘거나 돌아갈 수 없다)
	"roof": {"size": Vector3(30.0, 5.0, 52.0), "need": 99.0, "pts": 40, "grow": 0.4, "mass": 0.0, "col": [Color("cfe6ff"), WHITE], "slam": true, "boost": 12.0},
	"gold": {"size": Vector3(5.6, 7.0, 5.6), "need": 99.0, "pts": 50, "grow": 0.2, "mass": 0.0, "col": [D], "slam": true, "boost": 16.0},
	# 숨은 길 봉인(한 차선에만, 빨간 띠 없음): 못 열면 살짝 튕겨 큰길로 밀려날 뿐(soft). ram = 이 속도면 몸으로 뚫는다(게이지 금빛 눈금)
	"door": {"size": Vector3(4.0, 5.0, 1.2), "need": 6.0, "pts": 10, "grow": 0.0, "mass": 0.05, "col": [STONE], "nodive": true, "soft": true, "ram": 42.0},
	"icedoor": {"size": Vector3(3.6, 4.5, 1.6), "need": 4.5, "pts": 6, "grow": 0.0, "mass": 0.1, "col": [ICEWALL], "nodive": true, "soft": true, "ram": 42.0},
	"vein": {"size": Vector3(3.6, 3.2, 1.2), "need": 99.0, "pts": 4, "grow": 0.0, "mass": 0.0, "col": [C], "nodive": true, "shot": true, "soft": true},
}
const DASH_T := 1.3  # 쪼갠 뒤 돌진 시간: 집·석상·얼음벽을 크기와 상관없이 뚫는다
# 수로 밑 협곡: 떨어지면 공간이 이어진 채 DEEP 아래 "낮잠자는 지하 신전"에 닿는다
const DEEP := 90.0
const UNDER_SKY := Color("9cc3d6")
# 신전 계곡 깔 것 [종류, 거리, 길 가운데에서 옆으로]
const PUT1 := [
	["pot", 36, -4.5], ["pot", 36, -1.5], ["pot", 36, 1.5], ["pot", 36, 4.5], ["pot", 48, 0.0],  # 첫 항아리는 길을 가로질러 놓아 못 피한다: 깔아도 된다는 걸 몸으로 ["pot", 64, -2.0], ["pot", 84, -3.0], ["pot", 88, 3.0],
	["pot", 112, 1.5], ["pot", 120, -2.0], ["pot", 126, 3.5],
	["pillar", 148, 0.0], ["pot", 156, -3.8], ["pot", 156, 3.8],
	["pot", 175, -1.0], ["statue", 185, 2.5], ["pot", 195, -3.0], ["pot", 205, 1.0], ["statue", 215, -2.5],
	["pot", 262, 0.0], ["pillar", 280, 2.0], ["pot", 288, -2.5], ["statue", 300, 1.0], ["pillar", 312, -2.0], ["pot", 320, 2.5],
	["pot", 404, 0.0], ["pot", 410, 2.5], ["pot", 414, -2.5], ["pot", 455, 0.0],
	["pot", 500, -3.0], ["pot", 505, 0.0], ["pot", 510, 3.0], ["statue", 522, -3.0],
	["pillar", 575, 0.0], ["pot", 588, -3.0], ["pot", 592, 3.0],
]
const ROCK_R := [1.6, 3.0, 2.0, 4.4, 1.4, 3.6, 2.4, 5.2, 1.8, 3.2]
const ROCK_X := [-4.0, 2.0, 0.0, -2.0, 4.0, -1.0, 3.0, -3.0, 1.0, -4.5]
# 새긴 돌 디자인 시스템: 새긴 글자색, 그림자, 안내판, 메달, 지하 먼지
const GLYPH := Color("5a3a1e")
const GLYPH_SUB := Color("8a6d4b")
const UI_SH_COL := Color(0.227, 0.165, 0.102, 0.32)
const UI_SH := Vector2(0, 6)
const PLATE := Color(0.937, 0.882, 0.769, 0.88)
const SILVER := Color("ced4da")
const BRONZE := Color("e8a06a")
const DUST := Color("e6d2ad")


class Thing:
	var n: MeshInstance3D
	var kd: Dictionary
	var d := 0.0
	var x := 0.0
	var base := 0.0
	var flat := false
	var col := Color.WHITE
	var shard := "chip"          # 깨질 때 튀는 조각 그림
	var shard_tint := Color.WHITE


var Z: Array = []      # 구역 설계 (_zones_def)
var pd := {}           # 길 표본: 1m 마다 위치·방향·높이·반폭·땅 있음·종류
var start_st := {}
var zones: Array = []  # 지어진 구역
var things: Array = []
var holes: Array = []  # [거리0, 거리1, 옆0, 옆1] 땅이 없는 곳
var says: Array = []   # [거리, 글]
var cams: Array = []   # [거리, 카메라] 조각마다 카메라 바꾸기 (해안 끝 다 섞기)
var cur_k := -1
var mode := "back"
var goal_d := -1.0
var ball: MeshInstance3D
var dist := 0.0
var v := 0.0
var s := 2.0
var s_goal := 2.0
var bx := 0.0
var x_goal := 0.0
var by := 0.0
var vy := 0.0
var on_ground := true
var fallen := false
var fall_t := 0.0
var slow_t := 0.0
var warn_t := 0.0
var hurt := 0.0
var cool := 0.0
var shake := 0.0
var ang := 0.0
var quarter := 0
var roll_t := 0.0
var won := false
var won_t := 0.0
var bonus := 0
var score_base := 0
var clock := 0.0
var last_x := 0.0
var cam_y := 0.0
var cam_off := Vector3.ZERO
var look_off := Vector3.ZERO
var cam_up := Vector3.UP
var tick: ColorRect
var chunk: MeshInstance3D
var chunk_d := 0.0
var chunk_x := 0.0
var chunk_t := 0.0
var rocks: Array = []
var rock_t := 0.0
var rock_i := 0
var rock_a := -1.0
var rock_b := -1.0
# 이어하기: 마지막으로 들어간 구역 처음부터
var cp_k := 0
var cp_st := {}
var cp_s := 2.0
var cp_score := 0
# 설산·협곡
var pads: Array = []   # [거리0, 거리1, 옆0, 옆1, "snow"/"sun"]
var pad_t := 0.0
var ride_told := false
var snow_told := false
var guide_until := 0.0
var shot: MeshInstance3D
var shot_d := 0.0
var shot_x := 0.0
var shot_v := 0.0
var shot_t := 0.0
var shot_hit := false
# 조준: 수정이 앞에 있으면 땅에 점선(지금 속도로 닿는 거리)과 수정 위 깨질 너비 막대
var aim_dots: Array = []
var aim_bar: MeshInstance3D
var aim_legs: Array = []
var aim_ok := false
# 비주얼: 하늘색, 먼 실루엣, 파편, 바람 줄, 찌그러짐
var sky_env: Environment
var sky_mat: ProceduralSkyMaterial
var underground := false
var tunnels: Array = []
var sky_to := Color("d8eeff")
var far: Node3D
var clouds: Node3D
var far_k := -1
var pivot: Node3D
var sq := 0.0
var bits: Array = []
var streaks: Array = []

# v6: model resources stay shared across all instances; collision math uses KIND unchanged.
const ART_ROOT := "res://art/boulder/"
const ART_NAMES := ["stone", "pillar", "valley", "snow", "coast", "crystal", "plank", "temple", "pot"]
const RECORD := "user://boulder_v6.cfg"
const GOLD_TIME := 180.0
const SILVER_TIME := 240.0
var art_meshes := {}
var art_materials := {}
var currents: Array = []
var drums: Array = []
var fresh_run := true
var run_elapsed := 0.0
var run_deaths := 0
var best_time := 0.0
var record_score := 0
var finish_time := 0.0
var finish_speed := 0.0
var new_record := false
var drum_charge := 0.0
var was_holding := false
var drum_used := -1.0
var route_label: Label
var action_label: Label
var result_card: Control
var result_title: Label
var result_values: Label
var result_note: Label
var retry_button: Button
var failure_reason := ""
var bonk_at := -99.0   # 마지막으로 부딪힌 시각: 곧 멈추면 결과 카드에 부딪힌 까닭을 쓴다
var bonk_why := ""
var arrow_mesh: ArrayMesh
# v7: 쪼개기 돌진, 수로 밑 수정 동굴(떨어지면 딴 세상)
var dash_t := 0.0
var crumble: Array = []  # [거리, 조각] 고르지 않은 갈래 조각: 돌이 다가가면 무너진다
var warp_menu: Control       # 비밀 구역·지름길 고르기 창 (스와이프 → ← ← ↑)
var warp_to := 0.0           # 이 거리까지 빨리 감는다 (지름길 앞으로)
var swipe_seq: Array = []    # 최근 스와이프 방향과 시각
var swipe_from := Vector2.ZERO
var swipe_at := -1.0
var stall_d := 0.0  # 멈춤 검사: 마지막으로 앞으로 나아간 자리
var stall_t := 0.0
var bump_t := 0.0  # 기둥에 튕긴 직후: 붉은 깜빡임 없이
var look_soft := 0.0  # 갈래를 고른 직후 카메라를 천천히 돌린다
var zone_queue: Array = []  # 나눠 짓는 중인 구역 (한 프레임에 한 조각)
var branch_nodes: Array = []  # 갈림길 갈래 길 노드 (고르면 다른 쪽을 지운다)
var fork_rail_end := -1.0     # 이 거리까지 길 가장자리가 난간
var cave_nodes: Array = []  # 동굴 장식: 떨어지기 전엔 숨겨 둔다
var gems: Array = []
var under_route: Array = []  # 지금 떨어진 협곡 구간 [시작, 끝]
var geysers: Array = []     # [거리, 노드] 끝의 물기둥: 타면 수로 위로 솟는다
var rising := false         # 물기둥에 실려 올라가는 중
var updraft: Array = []     # 지하 순풍 길 [시작, 나올 틈 시작, 틈 끝, 바닥 높이, 나올 높이]
var lava_mats: Array = []  # 용암 물결을 흘린다
var cave_span: Array = []  # 동굴 맵 [시작, 끝]: 이 안 지하에서는 좌우 벽에 막힌다
const CAVE_HW := 8.0
var wind_on := false        # 순풍을 타고 지상으로 오르는 중
# 튜토리얼: 짧은 연습 코스 5개. 동작이 필요한 자리(gate)에 오면 느려지고 그 버튼이 깜빡인다
var tutorial := false
var gates: Array = []  # [거리, 버튼, 글]        # [거리, 높이(동굴 바닥 위), 노드]
# 손맛: 멈칫(hit-stop)·느린 동작은 _step 안의 dt 로만 (Engine.time_scale 은 튜토리얼 문만 쓴다)
var hs_t := 0.0
var slo_t := 0.0
var slo_k := 1.0
var sq_v := 0.0
var rings: Array = []  # 충격 고리 3개 돌려 쓰기
var ring_i := 0
var dust: Array = []   # 굴러가며 이는 흙먼지
var dust_t := 0.0
# 새긴 돌판 도장·지명판·돌 조각
var stamp_layer: CanvasLayer
var stamps: Array = []
var chips: Array = []
var chip_sb: StyleBoxFlat
var stamp_at := {}
var stamp_gap := 0.0
var stamp_pri := 0
var plaque: Control
var plaque_l: Label
var plaque_sub: Label
var plaque_stripe: ColorRect
var plaque_crack: Line2D
var plaque_tw: Tween
var plaque_pending: Array = []
var chip_at := -99.0
var score_tw: Tween
var wind: AudioStreamPlayer
var wind_lin := 0.0
# 세상 분위기: 색 입힌 그림 재질 모음, 돌 테두리, 구역 지평선 색, 공기 알갱이, 발밑 그림자
var art_tinted := {}
var hero_rim: ShaderMaterial
var hz_to := Color("fff5df")
var air_pt: CPUParticles3D
var blob: MeshInstance3D
var blob_mat: StandardMaterial3D
# 90m 낙하: 첫 착지 한 번만 크게, 수정이 차례로 깨어난다, 솟아오른 뒤 둘러보기
var deep_landed := false
var glows: Array = []  # [거리, 수정 노드, 빛 색, 깨어남]
var reveal_t := 0.0
# 끝 장면: 신전 뒤 금빛 기둥, 혼자 도는 카메라
var rays: Array = []
var ray_mat: StandardMaterial3D
var end_cam := Vector3.ZERO
var end_fov := 55.0
# 결과 돌판·도장, 안내 판, 속도 게이지, 키트 버튼
var result_band_sb: StyleBoxFlat
var result_seal: Control
var seal_sb: StyleBoxTexture
var seal_l: Label
var seal_crack: Line2D
var seal_tw: Tween
var result_tw: Tween
var result_tw2: Tween
var route_plate: Panel
var action_plate: Panel
var msg_plate: Panel
var score_plate: Panel
var back_l: Label
var back_plate: Panel
var rate_plate: Panel
var gauge_frame_sb: StyleBoxFlat
var gauge_fill: Panel
var gauge_fill_sb: StyleBoxFlat
var gauge_hl: Panel
var gauge_last_v := 0.0
var gauge_kick := 0.0
var _btn_born := {}
# 숨은 길(지름길): 바람 줄·턱 틈·동작 색 봉인·속도 눈금으로 읽힌다. 모으는 것·세는 것·저장 없음
var lanes: Array = []         # 바람 줄: {pts, yw, s:[{n, ph, ox, oy}]}
var floor_cracks: Array = []  # 내려찍으면 깨지는 바닥판 → 숨은 방
var ram_tick: ColorRect       # 앞에 '빠르면 뚫리는' 봉인이 있을 때 게이지 위 금빛 눈금
var sling_keep := 0.0         # 물기둥 새총: 착지하면 이 속도를 돌려준다
var drum_last := 0.0          # 마지막 발판 발사 때 힘
var drum_last_d := -999.0
# 구역마다 지평선 색 (안개·주변광이 따라간다)
const HZ := ["fff1d6", "eefbea", "fff3d2", "fbf3e6", "fff0f4", "f4fbff", "ffe9cc", "eafcff", "eef6f2", "fff4ea", "fff3cf"]
# 공기 알갱이: 색, 중력, 처음 속도 최소·최대, 크기 최소·최대
const AIR := {"dust": [Color("fff3d6"), Vector3(0, 0.3, 0), 0.3, 1.0, 0.7, 1.3], "pollen": [Color("f4ffd0"), Vector3(0.8, 0.1, 0), 0.3, 1.0, 0.6, 1.1],
	"petal": [Color("ffd6ec"), Vector3(1.0, -0.8, 0), 0.5, 1.2, 0.8, 1.4], "snow": [WHITE, Vector3(0.5, -2.8, 0), 0.5, 1.5, 1.0, 1.9],
	"sand": [Color("ffc98a"), Vector3(5.0, -0.2, 0), 1.0, 3.0, 0.5, 1.0], "spray": [Color("e6fbff"), Vector3(0, -1.5, 0), 0.8, 2.4, 0.6, 1.5],
	"cave": [Color("ffe39a"), Vector3(0, 0.7, 0), 0.1, 0.5, 0.5, 1.2],
	"ember": [Color("ffffff"), Vector3(0, 2.6, 0), 0.6, 2.2, 0.6, 1.6]}
const AIR_OF := {"rock": "dust", "aq": "pollen", "village": "pollen", "cliff": "dust", "plaza": "petal", "snow": "snow", "canyon": "sand", "coast": "spray"}



## 글꼴은 Tofu 가 라벨을 만들기(_ready) 전에 정해야 해서 _init 에서 언어부터 고른다
func _init() -> void:
	_lang()
	if TranslationServer.get_locale() == "en":
		var base := load("res://fonts/cinzel/Cinzel-VF.ttf") as FontFile
		var fv := FontVariation.new()
		fv.base_font = base
		fv.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 800}
		fv.fallbacks = [_font]
		_font = fv


func _setup() -> void:
	# 깊이 정밀도: 가까운 면을 0.05m 로 두면 먼 바닥 판끼리 지직거린다
	cam.near = 0.4
	cam.far = 1500.0
	_lang()
	# 그리기: 폰 화면은 픽셀이 아주 많다(기기 배율 3배면 1080×2400). 3D 만 세로 약 1000 픽셀로 그리고 늘린다. 글·버튼은 그대로 선명
	if OS.has_feature("web"):
		var vp := get_viewport()
		vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		vp.scaling_3d_scale = clampf(1000.0 / maxf(1.0, float(DisplayServer.window_get_size().y)), 0.45, 1.0)
		vp.msaa_3d = Viewport.MSAA_DISABLED
	# 시작 설명 카드는 없다: 제목은 타이틀 화면이, 조작·실패 규칙은 첫 길 위 안내가 맡는다
	howto = ""
	time_limit = 0.0
	_load_art()
	# 돌 몸에 먹선 테두리 (눈 구역에서만 크림색으로 바꾼다)
	hero_rim = OUTLINE.duplicate() as ShaderMaterial
	(art_materials["stone"] as StandardMaterial3D).next_pass = hero_rim
	var record := ConfigFile.new()
	if record.load(RECORD) == OK:
		best_time = maxf(0.0, float(record.get_value("record", "time", 0.0)))
		record_score = maxi(0, int(record.get_value("record", "score", 0)))
	_build_journey_ui()
	_stamp_build()
	for c in get_children():
		if c is WorldEnvironment:
			sky_env = (c as WorldEnvironment).environment
	tick = ColorRect.new()
	tick.color = INK
	tick.position = Vector2(600.0 * VSTOP / VMAX - 3.0, -10.0)
	tick.size = Vector2(6, 48)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(tick)
	_gauge_build()
	ram_tick = ColorRect.new()
	ram_tick.color = D
	ram_tick.size = Vector2(6, 48)
	ram_tick.position = Vector2(600.0 * 42.0 / VMAX - 3.0, -10.0)
	ram_tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ram_tick.visible = false
	_bar_bg.add_child(ram_tick)
	Z = _zones_def()
	if sky_env:
		sky_mat = ProceduralSkyMaterial.new()
		sky_mat.sky_top_color = sky_to
		sky_mat.sky_horizon_color = Color("fff5df")
		sky_mat.ground_horizon_color = Color("fff5df")
		var sky := Sky.new()
		sky.sky_material = sky_mat
		sky_env.sky = sky
		sky_env.background_mode = Environment.BG_SKY
		# 땅 쪽 하늘은 따뜻한 모래빛, 멀리 갈수록 지평선 색 안개로 겹이 진다
		sky_mat.ground_bottom_color = Color("e9dcc6")
		sky_env.fog_enabled = true
		sky_env.fog_mode = Environment.FOG_MODE_DEPTH
		sky_env.fog_depth_begin = 80.0
		sky_env.fog_depth_end = 520.0
		sky_env.fog_depth_curve = 1.3
		sky_env.fog_density = 0.6
		sky_env.fog_sky_affect = 0.0
	_air_make()
	# 바람 소리: 빠를수록, 깊이 떨어질수록 커진다
	wind = AudioStreamPlayer.new()
	wind.stream = _wind_stream()
	wind.volume_db = -60.0
	add_child(wind)
	wind.play()
	_kit_on()


func _zones_def() -> Array:
	var zs := _zones_list()
	# 구역마다 하늘색, 먼 실루엣 모양과 색
	var look := [
		["d8eeff", "peak", [ROCK, STONE, WHITE]],
		["dcf6e4", "dome", [GRASS, B, WHITE]],
		["fff0d6", "city", [A, D, GRASS]],
		["e0e6ff", "spire", [ROCK, WHITE, B]],
		["ffe6f0", "city", [C, A, B, WHITE]],
		["d0eaff", "peak", [WHITE, ICEWALL, B]],
		["ffe2c4", "spire", [A, D, ROCK]],
		["c8f0ff", "dome", [B, WHITE, GRASS]],
		["c8ece9", "dome", [STONE, B, ROCK]],
		["e3daf1", "city", [STONE, A, C]],
		["ffe7b9", "city", [STONE, D, WHITE]],
	]
	for i in zs.size():
		var lk: Array = look[mini(i, look.size() - 1)]
		zs[i]["sky"] = Color(lk[0])
		zs[i]["far"] = lk[1]
		zs[i]["farcol"] = lk[2]
		zs[i]["hz"] = Color(HZ[mini(i, HZ.size() - 1)])
	return zs


func _zones_list() -> Array:
	if tutorial:
		return _tutorial_list()
	return [
		{"msg": "신전 계곡", "mode": "back", "skill": "", "road": STONE, "floor": WATER, "accent": ROCK, "scen": "rock",
			# 숨은 길 1 (옛 배수로): 왼쪽 끝 차선에 바람 줄, 왼쪽 턱 줄이 끊긴 곳으로 꺾어 내려가면 오르막과 석상을 건너뛴다
			"items": [{"legs": [[30, 0, 7], [88, -19.4, 7], [12, -2.6, 7, 0, "mouthL"]], "put": _cut(PUT1, 0, 130),
					"say": [[2, "끌어서 조향"], [24, "끌어서 항아리를 깔아봐"], [100, "빨간 기둥은 옆으로 피해"]]},
				{"fork": [
					{"legs": [[14, -0.7, 7, 32], [10, -2, 5], [54, -9, 4.5, -32], [12, 0, 4.5]], "put": [["pot", 30, 0], ["pot", 46, 0], ["pot", 62, 0]]},
					{"legs": [[40, -2, 7], [60, 8, 6]], "put": _cut(PUT1, 130, 230), "say": [[30, "큼 = 무거움"]]}],
					"hidden": true, "pick_x": -4.0, "lane_x": -5.5, "name": "옛 배수로"},
				{"legs": [[20, 0, 6], [100, -23, 4], [20, 5, 4, 0, "ramp"], [22, -10, 5, 0, "gap"], [28, 0, 5], [70, -4, 3.5, 0, "bridge"], [50, -10, 6], [60, 6, 6]],
					"put": _cut(PUT1, 230, 9999), "say": [[92, "노란 경사대에서\n저절로 날아간다"], [180, "다리는 가운데로"]]}]},
		{"msg": "수로 · 뛰기", "mode": "side", "skill": "jump", "road": STONE, "floor": GRASS, "accent": B, "scen": "aq",
			# 뛰면 30m 가까이 난다: 틈 뒤에는 착지할 자리를 두고, 담은 착지 뒤 한참 지나서
			"items": [{"legs": [[12, -2, 5], [13, -2, 2.2, 0, "aq"], [45, -6, 2.2, 0, "aq"], [10, -1, 2.2, 0, "gap"], [80, -10, 2.2, 0, "aq"],
				[14, -1, 2.2, 0, "gap"], [80, -10, 2.2, 0, "aq"], [18, -2, 2.2, 0, "gap"], [60, -7, 2.2, 0, "aq"], [22, -2, 2.2, 0, "gap"],
				[30, -3, 2.2, 0, "aq"], [15, 0, 4]],
				"put": [["pot", 38, 0], ["pot", 48, 0], ["pot", 60, 0], ["wall", 125, 0], ["pot", 148, 0], ["pot", 153, 0],
					["wall", 222, 0], ["pot", 240, 0], ["pot", 246, 0], ["statue", 310, 0], ["pot", 322, 0]],
				"say": [[60, "틈! 뛰기"], [112, "담도 뛰어"], [296, "석상!\n뛰거나 깔거나"]],
				},
				# 섞기: 항아리로 커져야 석상을 깐다. 석상 바로 뒤가 틈이라 튕기면 빠진다. 담 바로 뒤도 틈.
				{"legs": [[30, -4, 2.2, 0, "aq"], [40, -8, 2.2, 0, "aq"], [16, -1, 2.2, 0, "gap"], [40, -6, 2.2, 0, "aq"],
					[12, -1, 2.2, 0, "gap"], [40, -6, 2.2, 0, "aq"], [15, 0, 4]],
					"put": [["pot", 10, 0], ["pot", 18, 0], ["pot", 26, 0], ["statue", 62, 0], ["wall", 121, 0]],
					"say": [[2, "섞기: 깔고 뛰기"], [46, "석상 뒤에 틈!\n깔고 뛰거나 넘거나"], [104, "담과 틈:\n한 번에!"]]}]},
		{"msg": "갈림길 · 쪼개기", "mode": "back", "skill": "split", "road": GRASS, "floor": GRASS, "accent": A, "scen": "village",
			"items": [
				{"legs": [[30, -6, 7], [30, -5, 8]], "put": [["house", 18, -4.5], ["pot", 28, 2], ["pot", 32, 4], ["house", 45, 4], ["pot", 52, -2]],
					"fence": [10], "say": [[6, "쪼개면 가볍고\n잠깐 돌진: 집도 뚫는다"]]},
				{"fork": [
					{"legs": [[26, -3, 6, 35], [70, -12, 7]], "put": [["house", 34, -3], ["pot", 40, 3], ["house", 48, 3], ["pot", 56, -3],
						["house", 62, -3], ["house", 76, 3], ["pot", 84, 0]], "fence": [92]},
					{"legs": [[26, -3, 5, -35], [70, -18, 4.5]], "put": [["pot", 45, 0], ["pot", 70, -2], ["pot", 72, 2]], "fence": [56]}]},
				{"legs": [[12, -2.5, 7], [12, -2.5, 7, 0, "mouthL"]], "put": [["pot", 8, 0], ["pot", 12, 3]]},
				# 숨은 길 3 (뒷골목): 왼쪽 차선에만 보라 금 돌문. 쪼개 돌진하거나 42m/s 로 들이받으면 열리고, 다음 갈림길을 건너뛴다
				{"fork": [
					{"legs": [[14, -2, 7, 32], [12, -4, 5], [46, -12, 4.5, -32], [12, -1, 5]], "put": [["pot", 30, 0], ["pot", 44, 0], ["pot", 58, 0]]},
					{"legs": [[56, -8, 7]], "put": [["pot", 14, -3], ["pot", 26, 3], ["pot", 40, 0]]}],
					"hidden": true, "pick_x": -3.5, "seal": ["door", 10, -4.8], "skip": 1, "name": "뒷골목"},
				{"fork": [
					{"legs": [[22, -2, 6, 38], [50, -10, 7]], "put": [["house", 30, 3], ["house", 40, -3], ["house", 52, 2], ["statue", 60, -2]]},
					{"legs": [[22, -2, 6, -38], [26, -6, 6], [10, 4, 6, 0, "ramp"], [12, -4, 6, 0, "gap"], [22, -4, 6]],
						"put": [["pot", 30, 0], ["pot", 80, -2], ["pot", 82, 2]]}]},
				{"legs": [[40, -8, 7], [30, 3, 7]], "put": [["house", 15, -3.5], ["house", 30, 3.5], ["pot", 50, 0]], "fence": [60]},
				# 섞기: 집을 깔아 무거워진 뒤 큰 회전(무거우면 밀려 떨어짐) → 쪼개기, 곧바로 경사대 틈 → 뛰기
				{"legs": [[20, -4, 7], [40, -8, 6, 70], [10, 4, 6, 0, "ramp"], [14, -4, 6, 0, "gap"], [30, -6, 7]],
					"put": [["house", 6, -3], ["pot", 10, 0], ["house", 14, 3]],
					"say": [[2, "섞기: 깔면 무거워\n회전에서 밀린다"], [22, "쪼개서 가볍게!"], [64, "뛰어!"]]}]},
		{"msg": "절벽 · 버티기", "mode": "fall", "skill": "hold", "road": ROCK, "floor": WATER, "accent": WHITE, "scen": "cliff",
			"items": [
				{"legs": [[40, -6, 7], [30, -5, 7]], "put": [["pot", 20, -2], ["pot", 25, 2]], "say": [[34, "떨어지며 조종"]]},
				# 배우기: 24m 절벽. 버티기를 누르면 빨리 떨어져 약 10m 앞에 내려찍는다: 그 자리에 탑. 안 누르면 30m 날아가 탑을 놓친다
				{"legs": [[3, -24, 8, 0, "drop"], [50, -5, 12], [25, -3, 8]],
					"put": [["roof", 31, 0], ["pot", 62, -4], ["pot", 66, 0], ["pot", 70, 4]],
					"say": [[2, "파란 머리 탑!\n떨어지며 버티기로 쾅"]]},
				# 무리: 36m 절벽 아래 넓은 착지 광장 한가운데 탑 넷. 한 번에 쾅 하면 크게 빨라진다. 구멍은 가장자리에만
				{"legs": [[20, -4, 8], [3, -36, 9, 0, "drop"], [60, -6, 14], [25, -3, 8]],
					"put": [["roof", 51, 0], ["pot", 82, -6], ["pot", 84, 0], ["pot", 86, 6]],
					"holes": [[66, 82, -14.3, -10], [66, 82, 10, 14.3]], "say": [[86, "탑을 부수면 빨라진다"]]},
				# 두 단 절벽: 탑 둘 판 -> 바로 다시 떨어져 황금 신상과 둘레 탑 판
				{"legs": [[20, -4, 8], [3, -28, 9, 0, "drop"], [45, -5, 12], [3, -22, 9, 0, "drop"], [50, -6, 12], [25, -3, 8]],
					"put": [["roof", 45, 0], ["roof", 98, 0], ["pot", 128, 0]],
					"say": [[2, "파란 머리 탑!\n떨어지며 버티기로 쾅"]]},
				# 섞기: 틈 뛰기 → 떨어지며 구멍 피해 집 내려찍기 → 착지 뒤 큰 회전(버티기 또는 쪼개기)
				{"legs": [[20, -4, 8], [10, 4, 6, 0, "ramp"], [16, -6, 6, 0, "gap"], [30, -4, 8], [3, -30, 12, 0, "drop"], [50, -6, 12],
					[30, -5, 7, 60], [20, -3, 7]],
					"put": [["gold", 92, -6], ["pot", 96, 0], ["tower", 100, 6], ["tower", 118, -4]],
					"holes": [[86, 98, 0, 12.3], [102, 114, -12.3, 0]],
					"say": [[2, "섞기: 뛰고\n내려찍고"], [70, "구멍 피해\n신상을 내려찍어"], [124, "회전!\n버티거나 쪼개"]],
					# 숨은 길 4 (숨은 저수조): 경사대 착지 자리의 파란 금 바닥판. 버티기로 내려찍으면 깨져 22m 아래 방으로 → 물기둥 새총으로 광장
					"crack": [46, 64, -5.0, 5.0], "lane": [[22, 56, 0.0, 3.0]],
					# from 34: 경사대에서 일찍 버텨 틈(30~46)에 짧게 떨어져도 판이 깨진 셈으로 방에 떨어진다 (_try_crack)
					"under": {"from": 34, "to": 179, "depth": 22.0, "geyser": 158, "lo": 183, "hi": 209, "vmin": 38.0, "name": "숨은 저수조"}}]},
		{"msg": "광장 · 위에서", "mode": "top", "skill": "", "road": SOFT, "floor": GRASS, "accent": C, "scen": "plaza",
			"items": [{"legs": [[25, -4, 7], [150, -15, 22, 0, "plaza"], [14, -1, 4, 0, "gate"], [25, -4, 6]],
				"put": [["pillar", 55, -8], ["pillar", 55, 8], ["pillar", 70, 0], ["pillar", 88, -10], ["pillar", 88, 10],
					["house", 62, -16], ["house", 76, -16], ["house", 90, -17],
					["pot", 60, 14], ["pot", 64, 17], ["pot", 68, 13], ["pot", 74, 16], ["pot", 80, 14], ["pot", 84, 18],
					["house", 135, -18], ["house", 135, -12], ["house", 135, -6], ["house", 135, 6], ["house", 135, 12], ["house", 135, 18],
					["pot", 145, -2], ["pot", 160, 2], ["post", 177, -3.6], ["post", 177, 3.6]],
				"fence": [102], "holes": [[115, 121, -6, 0], [150, 156, 6, 12]], "say": [[40, "길을 골라"], [158, "좁은 문!"]]},
				# 섞기: 집 두 채가 길을 막는다(커서 깔거나, 뛰어 내려찍거나) → 바로 틈 뛰기
				{"legs": [[20, -4, 8], [14, -1, 8], [30, -6, 8]], "put": [["house", 8, -3.5], ["house", 8, 3.5]],
					"cam": [[0, "back"]]}]},
		# 설산: 굴리는 길 자체가 자원. 흰 눈 줄에서 커지고(얼음벽을 깰 자격) 노란 길에서 녹는다(오르막을 넘을 가벼움).
		{"msg": "설산 · 눈 굴리기", "mode": "iso", "skill": "", "road": ICE, "floor": Color("abcbd8"), "accent": B, "scen": "snow",
			"items": [{"legs": [[20, -3, 8], [130, -24, 9], [24, -1, 9], [58, -10.8, 9], [12, -2.2, 9, 0, "mouthL"]],
				"snow": [[28, 142, -9, -1], [182, 240, -9, -1]],
				"sun": [[182, 240, 1, 9]],
				"put": [["pot", 50, 5], ["pot", 72, 4], ["pot", 96, 6], ["pot", 122, 4], ["pot", 200, 5], ["pot", 226, 6]],
				"row": [[164, "ice"]],
				"holes": [[205, 214, -2.5, 2.5]],
				"say": [[8, "흰 눈 위를 구르면\n커진다"], [140, "얼음벽만큼 커야\n깬다"], [176, "오르막 전에\n노란 길에서 녹여"]]},
				# 숨은 길 5 (얼음 골짜기): '녹여'라는 말과 반대로 왼쪽 눈길에 남아 커지면, 왼쪽 차선 얼음판을 깨고 오르막 없이 내려간다
				{"fork": [
					# 둘째 다리는 살짝 오른다: 큰길이 바로 오르막이라, 내려가면 큰길 판 밑으로 파고든다
					{"legs": [[14, -1, 9, 28], [16, 1, 6], [60, -19, 6, -28], [14, -3, 6]], "put": [["pot", 34, 0], ["pot", 54, 0]]},
					{"legs": [[14, -1, 9], [55, 19, 8], [10, -1, 8]], "say": [[68, "다시 키워!"]]}],
					"hidden": true, "pick_x": -4.5, "seal": ["icedoor", 12, -6.0], "name": "얼음 골짜기"},
				{"legs": [[90, -16, 9], [20, -1, 9], [40, -6, 8], [20, -2, 8]],
					"snow": [[0, 87, -9, 9]], "sun": [[109, 147, -9, 9]], "row": [[99, "ice"]], "put": [["pot", 27, 0]], "say": [[105, "녹는 길"]]},
				# 갈래 눈길: 눈 줄이 좌우로 번갈아 놓여 지그재그로 따라가야 다 먹는다(놓치면 얼음벽 4.5 에 모자람).
				# 얼음벽을 깬 바로 뒤가 녹는 길이고 그다음이 오르막: 키우기 → 깨기 → 녹이기 → 오르기를 한 호흡에.
				{"legs": [[20, -3, 9], [120, -20, 10], [20, -1, 9], [40, 8, 8], [20, -2, 8]],
					"snow": [[10, 42, -10, -1], [42, 74, 1, 10], [74, 106, -10, -1], [106, 132, 1, 10]],
					"row": [[138, "ice"]], "sun": [[146, 162, -9, 9]],
					"put": [["pot", 26, 6], ["pot", 58, -6], ["pot", 90, 6], ["pot", 118, -6]],
					"say": [[2, "눈 줄을 따라 지그재그"], [140, "깨고 녹이고 올라"]]},
				# 섞기: 눈으로 키워 얼음벽 깨기 → 커진(무거운) 몸으로 틈 뛰기 → 오르막 앞 쪼개기
				{"legs": [[20, -4, 9], [90, -16, 9], [14, -1, 9], [12, -1, 8, 0, "gap"], [30, -4, 8], [30, 6, 8], [20, -3, 8]],
					"snow": [[2, 108, -9, 9]], "row": [[114, "ice"]], "put": [["pot", 40, 5], ["pot", 60, -5], ["pot", 80, 3]],
					"say": [[2, "섞기: 눈으로 키워\n얼음벽 깨기"], [116, "무거운 몸으로\n뛰어!"], [150, "오르막!\n쪼개서 가볍게"]]}]},
		# 협곡: 던지기(크기 1을 앞으로 던져 수정을 깬다). 흔들다리는 입구 기둥 높이보다 크면 끊어진다. 무게가 탄약이자 죄.
		{"msg": "협곡 · 던지기", "mode": "low", "skill": "throw", "road": STONE, "floor": WATER, "accent": A, "scen": "canyon",
			"items": [{"legs": [[20, -3, 7], [60, -10, 7], [20, -2, 7], [45, -3, 7], [15, -1, 7], [38, -6.84, 7], [12, -2.16, 7, 0, "mouthL"]],
				"put": [["pot", 30, -3], ["pot", 34, 3], ["pot", 42, 0], ["statue", 52, -3], ["pot", 60, 3], ["pot", 66, -2], ["pot", 72, 2],
					["pot", 165, -4], ["pot", 168, 0], ["pot", 171, 4], ["house", 182, -3.5], ["statue", 186, 3.5], ["pot", 194, -4], ["pot", 197, 0],
					["pot", 200, 4], ["statue", 206, 0]],
				"row": [[90, "crystal"]],
				"say": [[6, "던지기 = 내 몸 한 덩이를\n앞으로 (작아진다)"], [50, "보라 벽은 몸으로 못 지나간다\n점선이 초록이면 던져"], [150, "다시 키워"], [206, "빠를수록 멀리 닿는다"]]},
				# 숨은 길 6 (수정 맥 길): 조준선이 막히지 않은 왼쪽 차선의 수정 하나를 가리킨다. 던져 깨면 좁은 흔들다리 없이 벼랑 틈으로 내려간다
				{"fork": [
					{"legs": [[14, -1.4, 7, 32], [12, -4, 5], [44, -15, 4.5, -32], [12, -2, 5]], "put": [["pot", 26, 0], ["pot", 44, 0]]},
					{"legs": [[20, -2, 7], [55, -4, 7], [15, -1, 7]], "row": [[12, "crystal"]]}],
					"hidden": true, "pick_x": -3.5, "seal": ["vein", 14, -5.0], "name": "수정 맥 길"},
				# 던지고 채우기: 왼쪽 반 눈길에서 몸을 채우고 → 수정 벽을 던져 깨고 → 다시 채우고 → 또 깬다.
				# 마지막은 무거운 몸이 밀려나는 큰 회전: 마지막 한 덩이를 던져 가볍게 돌지, 채운 채 버틸지.
				{"legs": [[20, -4, 8], [160, -22, 8], [50, -6, 7, 60], [20, -2, 7]],
					"snow": [[4, 56, -8, -0.5], [80, 132, -8, -0.5]],
					"row": [[70, "crystal"], [146, "crystal"]],
					"put": [["pot", 20, 4], ["pot", 30, 4], ["pot", 96, 4], ["pot", 106, 4], ["statue", 120, 4]],
					"say": [[2, "던지고, 눈으로 다시 채우고"], [178, "무거우면 회전에서 밀린다\n던져서 가볍게"]]},
				{"legs": [[40, -7, 7], [20, -1, 7]], "put": [["pot", 10, 0]]},
				# 섞기: 깔아서 커지고 → 수정에 던지면 작아져 → 바로 뒤 좁은 흔들다리를 건넌다 → 경사대 틈 뛰기
				{"legs": [[20, -4, 7], [40, -8, 7], [16, -1, 7], [45, -3, 7], [12, -1, 7], [10, 4, 6, 0, "ramp"], [14, -4, 6, 0, "gap"], [30, -5, 7]],
					"put": [["pot", 8, -3], ["pot", 12, 3], ["house", 30, -3], ["statue", 44, 3], ["pot", 50, 0]],
					"row": [[66, "crystal"]],
					"say": [[128, "뛰어!"]]}]},
		{"msg": "해안 · 추격", "mode": "front", "skill": "", "road": STONE, "floor": WATER, "accent": B, "scen": "coast",
			"items": [
				# 길이 좁아지면 빨강 돌을 피할 수 없다 → 쪼개기(떼어낸 덩이가 뒤 돌을 막는다)
				{"legs": [[20, -4, 7], [140, -25, 7], [60, -11, 3.5], [60, -10, 7], [20, 0, 8]],
					"put": [["pot", 60, -3], ["pot", 62, 3], ["pot", 130, 0], ["pot", 230, -3], ["pot", 232, 3]],
					"rocks": [30, 282], "say": [[22, "노랑은 받고\n빨강은 피해"], [150, "좁다! 빨강은\n쪼개서 막아"]]},
				# 좁아지는 방파제: 뒤에서 돌이 쫓아오는 채로 길 폭이 8 → 6 → 4 → 3 으로 줄어 피할 자리가 사라진다.
				# 좁은 끝에서는 쪼개 막거나 앞으로 달아날 수밖에 없고, 끝의 경사대로 만(灣)을 건너뛰면 추격이 끝난다.
				{"legs": [[20, -3, 8], [80, -12, 6], [60, -10, 4], [40, -6, 3], [10, 4, 6, 0, "ramp"], [18, -6, 6, 0, "gap"], [40, -6, 8]],
					"rocks": [10, 196], "put": [["pot", 40, -3], ["pot", 40, 3], ["pot", 120, 0]],
					"say": [[2, "방파제가 좁아진다"], [196, "뛰어 건너!"]]},
				# 마지막 다 섞기: 등뒤 카메라로 돌아와 지금까지 배운 것을 전부
				{"cam": [[0, "back"]],
					"legs": [[20, -3, 8], [60, -12, 8], [14, -1, 8], [45, -4, 7], [15, -1, 8], [50, -9, 8, 50],
						[10, 4, 6, 0, "ramp"], [14, -4, 6, 0, "gap"], [3, -28, 12, 0, "drop"], [50, -6, 12], [30, -6, 8],
						[3, -24, 8, 0, "drop"], [80, -8, 10]],
					"snow": [[22, 78, -8, 8]], "row": [[86, "crystal"]],
					"put": [["pot", 30, -4], ["pot", 40, 4], ["pot", 50, 0], ["pot", 60, -4], ["house", 246, -6], ["pot", 254, 0], ["house", 262, 6], ["pot", 290, 0]],
					"holes": [[238, 252, 0, 12.3], [256, 270, -12.3, 0]],
					"say": [[0, "해안 응용: 배운 것을 섞어!"], [20, "눈으로 키우고"], [150, "회전! 버티기"],
						[200, "뛰어!"], [226, "구멍 피해\n내려찍기"]]}]},
		# 물살은 지면 위에 있을 때만 몸을 옆으로 나른다. 작은 몸은 더 밀린다.
		{"msg": "조수 정원 · 물살 타기", "mode": "iso", "skill": "", "road": STONE, "floor": WATER, "accent": B, "scen": "coast",
			"objective": "물살을 타면 빨라진다 · 버티면 제자리",
			"items": [
				{"legs": [[36, -5, 10], [72, -10, 11], [36, -4, 10], [72, -10, 11], [36, -4, 9]],
					"flow": [[40, 104, -11, 11, 1], [148, 212, -11, 11, -1]],
					"put": [["pot", 52, -4], ["pot", 70, 0], ["pot", 88, 4], ["pot", 98, 8], ["pillar", 116, -5], ["pot", 162, 4], ["pot", 200, -8], ["pillar", 224, 5]],
					"say": [[4, "물살은 몸을 옆으로!\n화살표를 봐"], [30, "물살을 타면 빨라진다!"], [132, "이번엔 반대 방향\n뛰면 물살을 벗어난다"]]},
				{"legs": [[24, -4, 10], [72, -10, 10], [16, -2, 8], [14, -2, 8, 0, "gap"], [56, -8, 10], [24, -3, 9]],
					"flow": [[24, 92, -10, 10, 1], [132, 184, -10, 10, -1]],
					"put": [["pot", 8, 0], ["pot", 16, 0], ["pillar", 58, -4], ["pillar", 164, 4]],
					"row": [[88, "crystal"]], "snow": [[2, 23, -9, 9]],
					"say": [[2, "섞기: 눈으로 탄약 확보"], [22, "물살을 타고\n초록이면 던져"], [88, "벽을 열고 물살 밖에서 뛰어!"], [130, "반대 물살 착지\n가운데로 조종"]]}]},
		# 제동의 역할을 바꾼다: 발판에서 누르면 힘을 모으고, 떼면 크게 날아간다.
		{"msg": "공명 제단 · 눌렀다 놓기", "mode": "back", "skill": "", "road": STONE, "floor": Color("b8cbd8"), "accent": D, "scen": "plaza",
			"objective": "황금 발판에서 버티기 → 힘이 차면 손을 떼 발사",
			"items": [
				{"legs": [[38, -6, 10], [50, -5, 10, 0, "drum"], [9, -1, 10, 0, "gap"]],
					"drum": [[38, 88]],
					"put": [["pot", 12, -3], ["pot", 18, 3], ["pot", 24, 0]],
					"say": [[4, "앞의 넓은 틈:\n보통 점프로는 짧다"], [26, "황금 발판에서 버티기!\n초록이 되면 손을 떼"]]},
				# 숨은 길 7 (하늘 수로): 초록을 넘겨 줄무늬가 금빛으로 깜빡일 때까지 버텼다 떼면, 위에 떠 있는 부서진 수로에 내려 다음 제단을 통째로 건너뛴다
				{"fork": [
					{"legs": [[27, 8, 9, 20, "gap"], [140, -16, 7, 0, "aq"], [3, -20, 9, -20, "drop"], [50, -4, 10]], "put": [["pot", 90, 0], ["pot", 120, 0]]},
					{"legs": [[27, -3, 10, 0, "gap"], [90, -12, 12], [30, -4, 10]], "put": [["pot", 69, -4], ["pot", 83, 0]],
						"say": [[43, "공중에서 버티면 내려찍기\n착지까지는 손을 떼자"]]}],
					"hidden": true, "pick_air": 0.95, "skip": 1, "lane_x": 0.0, "lane_dy": 16.0, "name": "하늘 수로"},
				{"legs": [[24, -4, 10], [46, -5, 10, 0, "drum"], [38, -5, 10, 0, "gap"], [90, -12, 12], [25, -3, 9]],
					"drum": [[24, 70]], "row": [[170, "crystal"]],
					"snow": [[2, 24, -9, 9]],
					"put": [["house", 132, -5], ["house", 144, 5], ["pot", 152, 0]],
					"say": [[2, "섞기: 눈으로 몸을 키워"], [24, "무거운 몸으로 발판 누르기\n초록에서 손을 떼!"], [118, "착지 후 수정을 던져 깨고"], [178, "마지막 신전이 보인다"]]}]},
		{"msg": "바다 신전 · 마지막 도약", "mode": "back", "skill": "", "road": STONE, "floor": WATER, "accent": D, "scen": "coast",
			"objective": "키우고 → 던지고 → 가볍게 날아 바다 신전까지",
			"items": [
				{"legs": [[24, -4, 10], [66, -10, 10], [18, -2, 9], [42, -4, 7], [42, -6, 10],
					[48, -5, 10, 0, "drum"], [36, -4, 10, 0, "gap"], [100, -10, 12]],
					"snow": [[2, 70, -9, 9]], "row": [[82, "crystal"]], "drum": [[192, 240]],
					"flow": [[152, 188, -10, 10, 1]], "goal": 326,
					"put": [["pot", 22, 0], ["pot", 42, -3], ["pot", 54, 3], ["pillar", 172, 5]],
					"say": [[2, "마지막 응용\n눈으로 탄약을 만들고"], [150, "물살 뒤 황금 발판\n버티다가 손을 떼!"], [284, "돌아왔다\n신전의 빛을 향해"]]}]},
	]


func _reset() -> void:
	if fresh_run:
		fresh_run = false
		run_elapsed = 0.0
		run_deaths = 0
	finish_time = 0.0
	failure_reason = ""
	bonk_at = -99.0
	ride_told = false
	snow_told = false
	guide_until = 0.0
	new_record = false
	drum_charge = 0.0
	was_holding = false
	drum_used = -1.0
	currents.clear()
	drums.clear()
	if result_card:
		result_card.visible = false
		result_card.position = Vector2.ZERO
		result_card.modulate.a = 1.0
		for tw: Tween in [seal_tw, result_tw, result_tw2]:
			if tw:
				tw.kill()
		if seal_l:
			seal_l.scale = Vector2.ONE
		gauge_last_v = 0.0
		gauge_kick = 0.0
	dist = 0.0
	v = 16.0
	s = 2.0
	s_goal = 2.0
	bx = 0.0
	x_goal = 0.0
	vy = 0.0
	on_ground = true
	fallen = false
	underground = false
	tunnels.clear()
	updraft = []
	cave_span = []
	lava_mats.clear()
	wind_on = false
	lanes.clear()
	floor_cracks.clear()
	sling_keep = 0.0
	drum_last = 0.0
	drum_last_d = -999.0
	if ram_tick:
		ram_tick.visible = false
	cave_nodes.clear()
	gems.clear()
	under_route = []
	geysers.clear()
	# 수정·빛 기둥은 구역을 지을 때 채우므로 _open_zone 보다 먼저 비운다
	glows.clear()
	rays.clear()
	rising = false
	gates.clear()
	Engine.time_scale = 1.0
	dash_t = 0.0
	zone_queue.clear()
	crumble.clear()
	stall_d = 0.0
	stall_t = 0.0
	branch_nodes.clear()
	fork_rail_end = -1.0
	hs_t = 0.0
	slo_t = 0.0
	slo_k = 1.0
	fall_t = 0.0
	slow_t = 0.0
	warn_t = 0.0
	hurt = 0.0
	cool = 0.0
	shake = 0.0
	ang = 0.0
	quarter = 0
	won = false
	won_t = 0.0
	bonus = 0
	clock = 0.0
	mode = "back"
	cur_k = -1
	goal_d = -1.0
	rock_a = -1.0
	rock_b = -1.0
	rock_t = 0.0
	rock_i = 0
	for nm in ["jump", "split", "hold", "throw"]:
		_btns.erase(nm)
	pd = {"px": [], "pz": [], "yw": [], "hh": [], "hw": [], "sol": [], "tg": []}
	zones.clear()
	things.clear()
	holes.clear()
	says.clear()
	cams.clear()
	pads.clear()
	pad_t = 0.0
	shot_t = 0.0
	sq = 0.0
	sq_v = 0.0
	far_k = -1
	far = Node3D.new()
	world.add_child(far)
	clouds = Node3D.new()
	far.add_child(clouds)
	for i in 6:
		var a := TAU * i / 6.0 + 0.4
		var r := 230.0 + 30.0 * (i % 3)
		# 구름: 납작한 둥근 덩이 셋을 겹친다 (흰 상자로 보이지 않게)
		var cc := Vector3(cos(a) * r, 70.0 + 14.0 * (i % 3), sin(a) * r)
		for q in 3:
			var puff := MeshInstance3D.new()
			var sp := SphereMesh.new()
			sp.radial_segments = 12
			sp.rings = 6
			puff.mesh = sp
			_skin(puff, "chip")  # 흰 붓결 구름
			clouds.add_child(puff)
			puff.position = cc + Vector3((q - 1) * 14.0, (6.0 if q == 1 else 0.0), 0.0).rotated(Vector3.UP, -a)
			puff.scale = Vector3(24, 10, 16) * (1.25 if q == 1 else 1.0)
	var k0 := 0
	start_st = {"x": 0.0, "z": 0.0, "yw": 0.0, "h": 60.0}
	score_base = 0
	if cp_k > 0:
		k0 = cp_k
		start_st = cp_st
		s_goal = cp_s
		s = cp_s
		score_base = cp_score
		for k in range(1, cp_k):
			if Z[k].skill != "":
				_unlock(Z[k].skill)
	_open_zone(k0)
	by = _h(0.0)
	cam_y = by
	pivot = Node3D.new()
	world.add_child(pivot)
	ball = box(Vector3.ZERO, Vector3.ONE * s, ME, pivot)
	_stone_mesh(ball)
	chunk = box(Vector3.ZERO, Vector3.ONE * 2.0, STONE)
	chunk.visible = false
	chunk_t = 0.0
	# 던진 덩이 = 내 몸 한 조각. 작아서 안 보였다: 크게, 금빛(던지기)·자수정(쪼개기) 물들이고 진한 외곽선
	shot = box(Vector3.ZERO, Vector3.ONE * 3.2, ME)
	_apply_art(shot, "stone", Color("ffe08a"))
	_apply_art(chunk, "stone", Color("e2b8ff"))
	_ink_outline(shot, INK)
	_ink_outline(chunk, INK)
	shot.visible = false
	aim_dots.clear()
	for i in 10:
		# 조준 점: 납작한 조약돌 (색은 붓결 위에 초록·노랑·빨강)
		var n := box(Vector3.ZERO, Vector3(0.8, 0.3, 0.8), GOOD)
		n.mesh = _shard_mesh(i)
		n.material_override = _shard_mat("chip", GOOD)
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		n.visible = false
		aim_dots.append(n)
	aim_bar = box(Vector3.ZERO, Vector3(8.4, 0.5, 0.5), GOOD)
	_skin(aim_bar, "chip", GOOD)
	aim_bar.visible = false
	aim_legs.clear()
	for i in 2:
		var n := box(Vector3.ZERO, Vector3(0.4, 1.6, 0.4), GOOD)
		_skin(n, "chip", GOOD)
		n.visible = false
		aim_legs.append(n)
	aim_ok = false
	# 파편·바람 줄은 미리 만들어 돌려 쓴다. 파편 = 모난 낮은 다각 조각 (깨진 것의 그림을 입는다)
	bits.clear()
	for i in 16:
		var n := MeshInstance3D.new()
		n.mesh = _shard_mesh(i)
		n.material_override = _shard_mat("chip")
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		n.visible = false
		world.add_child(n)
		bits.append({"n": n, "v": Vector3.ZERO, "life": 0.0, "max": 1.0, "sz": 0.5})
	streaks.clear()
	for i in 14:
		var n := _wind_node(world)
		n.visible = false
		streaks.append({"n": n, "d": 30.0 * i / 14.0 - 8.0, "x": 0.0, "y": 0.0, "p": false})
	# 충격 고리: 착지·탑 깨기 때 땅 위로 퍼지는 납작한 고리
	rings.clear()
	ring_i = 0
	for i in 3:
		var tm := TorusMesh.new()
		tm.inner_radius = 0.86
		tm.outer_radius = 1.0
		tm.rings = 24
		tm.ring_segments = 4
		var rm := StandardMaterial3D.new()
		rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		rm.cull_mode = BaseMaterial3D.CULL_DISABLED
		rm.albedo_texture = load(ART_ROOT + "chip.png") as Texture2D  # 붓결 고리 (색·투명은 _ring 이 정한다)
		var rn := MeshInstance3D.new()
		rn.mesh = tm
		rn.material_override = rm
		rn.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		rn.visible = false
		world.add_child(rn)
		rings.append(rn)
	# 흙먼지
	dust.clear()
	dust_t = 0.0
	for i in 14:
		var n := MeshInstance3D.new()
		n.mesh = _puff_mesh()
		n.material_override = _shard_mat("chip", _dust_col())
		n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		n.visible = false
		world.add_child(n)
		dust.append({"n": n, "life": 0.0, "max": 1.0, "v": Vector3.ZERO, "sz": 1.0})
	# 도장·조각·점수 튐은 판이 바뀌면 다 거둔다
	if stamp_layer:
		stamp_layer.layer = 7
		for st: Dictionary in stamps:
			var stw: Tween = st.tw
			if stw and stw.is_valid():
				stw.kill()
			(st.root as Control).visible = false
			st.busy = false
			st.pri = 0
		for c: Panel in chips:
			_chip_kill(c)
			c.visible = false
		if plaque_tw:
			plaque_tw.kill()
		plaque.visible = false
		plaque_pending = []
		stamp_at.clear()
		stamp_gap = 0.0
		stamp_pri = 0
		chip_at = -99.0
		if score_tw:
			score_tw.kill()
		if _score_l:
			_score_l.scale = Vector2.ONE
			_score_l.label_settings.font_color = INK
	rocks.clear()
	for i in 6:
		var n := box(Vector3.ZERO, Vector3.ONE, BAD)
		_stone_mesh(n)
		var warning := box(Vector3(0, -0.45, 0), Vector3.ONE, BAD, n)
		_red(warning)
		var disk := CylinderMesh.new()
		disk.height = 0.08
		disk.top_radius = 0.62
		disk.bottom_radius = 0.62
		disk.radial_segments = 12
		warning.mesh = disk
		n.visible = false
		rocks.append({"n": n, "on": false, "d": 0.0, "x": 0.0, "r": 1.0, "v": 0.0, "a": 0.0})
	var yw := _yaw(0.0)
	var fw := Vector3(-sin(yw), 0.0, -cos(yw))
	cam_off = -fw * 12.0 + Vector3.UP * 6.0
	look_off = fw * 14.0
	cam_up = Vector3.UP
	cam.fov = 55.0
	deep_landed = false
	reveal_t = 0.0
	end_cam = Vector3.ZERO
	end_fov = 55.0
	# 발밑 그림자: 먹색 둥근 판. 높이 뜰수록 작고 옅어진다
	blob = MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.top_radius = 0.5
	bm.bottom_radius = 0.5
	bm.height = 0.02
	bm.radial_segments = 20
	bm.rings = 1
	blob.mesh = bm
	blob_mat = StandardMaterial3D.new()
	blob_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	blob_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	blob_mat.albedo_color = Color(INK, 0.38)
	blob.material_override = blob_mat
	blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(blob)
	_place(0.0)


func _unlock(nm: String) -> void:
	_btn_born[nm] = Time.get_ticks_msec() * 0.001
	match nm:
		"jump":
			kit_button("jump", tr("뛰기"), Vector2(610, 1150), 88.0, D)
		"split":
			kit_button("split", tr("쪼개기"), Vector2(610, 955), 80.0, C)
		"hold":
			kit_button("hold", tr("버티기"), Vector2(610, 770), 80.0, B)
		"throw":
			kit_button("throw", tr("던지기"), Vector2(610, 590), 76.0, A)


# ---- 길 표본 ----
func _push(o: Dictionary, x: float, z: float, yw: float, h: float, hw: float, sol: int, tg: String) -> void:
	o.px.append(x)
	o.pz.append(z)
	o.yw.append(yw)
	o.hh.append(h)
	o.hw.append(hw)
	o.sol.append(sol)
	o.tg.append(tg)


## 다리 목록 [길이, 높이 변화, 반폭, 회전(도), 종류] -> 1m 표본
func _gen(st: Dictionary, legs: Array) -> Dictionary:
	var o := {"px": [], "pz": [], "yw": [], "hh": [], "hw": [], "sol": [], "tg": []}
	var x: float = st.x
	var z: float = st.z
	var yw: float = st.yw
	var h: float = st.h
	var hw := 6.0
	var kind := ""
	for lg: Array in legs:
		var n: int = int(lg[0])
		var dh: float = float(lg[1]) / n
		hw = float(lg[2])
		var turn := 0.0
		if lg.size() > 3:
			turn = deg_to_rad(float(lg[3])) / n
		kind = str(lg[4]) if lg.size() > 4 else ""
		var solid := 0 if kind == "gap" or kind == "drop" else 1
		for i in n:
			_push(o, x, z, yw, h, hw, solid, kind)
			var my := yw + turn * 0.5
			x -= sin(my)
			z -= cos(my)
			yw += turn
			h += dh
	_push(o, x, z, yw, h, hw, 1, kind)
	return o


func _len() -> int:
	return pd.px.size() - 1


func _end_st() -> Dictionary:
	if pd.px.is_empty():
		return start_st
	return {"x": pd.px[-1], "z": pd.pz[-1], "yw": pd.yw[-1], "h": pd.hh[-1]}


func _extend(legs: Array) -> void:
	var st := _end_st()
	if not pd.px.is_empty():
		for key in pd:
			(pd[key] as Array).pop_back()
	var o := _gen(st, legs)
	for key in pd:
		(pd[key] as Array).append_array(o[key])


func _oi(o: Dictionary, d: float) -> int:
	return clampi(floori(d), 0, maxi(o.px.size() - 2, 0))


func _oh(o: Dictionary, d: float) -> float:
	var i := _oi(o, d)
	return lerpf(o.hh[i], o.hh[i + 1], clampf(d - i, 0.0, 1.0))


func _oyaw(o: Dictionary, d: float) -> float:
	var i := _oi(o, d)
	return lerpf(o.yw[i], o.yw[i + 1], clampf(d - i, 0.0, 1.0))


## 길 거리 d, 옆 x, 높이 y 의 세상 위치
func _opos(o: Dictionary, d: float, x: float, y: float) -> Vector3:
	var i := _oi(o, d)
	var f := clampf(d - i, 0.0, 1.0)
	var yw: float = lerpf(o.yw[i], o.yw[i + 1], f)
	var px: float = lerpf(o.px[i], o.px[i + 1], f)
	var pz: float = lerpf(o.pz[i], o.pz[i + 1], f)
	return Vector3(px + cos(yw) * x, y, pz - sin(yw) * x)


func _h(d: float) -> float:
	return _oh(pd, d)


func _yaw(d: float) -> float:
	return _oyaw(pd, d)


func _pos(d: float, x: float, y: float) -> Vector3:
	return _opos(pd, d, x, y)


func _slope(d: float) -> float:
	var i := _oi(pd, d)
	return pd.hh[i + 1] - pd.hh[i]


func _curv(d: float) -> float:
	var i := _oi(pd, d)
	return pd.yw[i + 1] - pd.yw[i]


## (d, x) 아래 땅 높이. 땅이 없으면 NAN
## 구멍으로 떨어지는 중 앞쪽 길 판 옆면: 빠르면 구멍 건너편 판 두께 속으로 파고들어 그냥 뚫고 지나갔다 → 벽처럼 박고 튕긴다
func _hole_wall(d_prev: float) -> void:
	if on_ground or fallen or wind_on or d_prev >= _len():
		return
	# 아직 지하로 넘어가기 전(틈 속 4m)도 본다: 동굴로 넘어가는 순간보다 판에 먼저 닿는다
	if not underground and pd.sol[_oi(pd, d_prev)] != 0:
		return
	var top := _h(dist)
	if by > top - 0.3 or by + s < top - 6.0:  # 판(두께 약 6m) 높이에 몸이 걸칠 때만
		return
	var was_under := underground
	underground = false
	var solid_now := not is_nan(_ground(dist, bx))
	var solid_was := not is_nan(_ground(d_prev, bx))
	underground = was_under
	if solid_now and not solid_was:
		dist = d_prev - 0.3
		v = maxf(4.0, v * 0.25)
		vy = minf(vy, -6.0)
		shake = 1.0
		sq = 0.35
		sfx("bonk", 2.0, 0.8)
		_hitstop(0.08, -8.0)
		_burst(_pos(dist + s, bx, by), DUST, 12, 12.0, 0.8)
		_stamp("쿵!", 4, _pos(dist, bx, by + s))


## 길 가장자리: 몸이 반쯤 걸치면 바깥으로 기울어 굴러 떨어지고, 떨어지는 중에는 길 판 옆으로 비켜 떨어진다 (판을 뚫고 수직으로 빠지지 않게)
func _edge_tick(dt: float) -> void:
	if underground or fallen or dist >= _len():
		return
	var i := _oi(pd, dist)
	if pd.sol[i] == 0:
		return
	var hw := float(pd.hw[i])
	var over := absf(bx) - hw
	if on_ground and over > 0.0:
		x_goal += signf(bx) * 10.0 * dt * clampf(over / maxf(s * 0.35, 0.3), 0.0, 1.0)
	elif not on_ground and over > 0.0 and is_nan(_ground(dist, bx)) and by < _h(dist) - 0.2 and by > _h(dist) - 6.0:
		bx = signf(bx) * (hw + s * 0.5 + 0.05)
		x_goal = bx


func _ground(d: float, x: float) -> float:
	if underground:
		return _h(d) - _tunnel_depth(d)
	if d >= _len():
		return NAN
	var i := _oi(pd, d)
	# 공 중심이 아니라 몸의 1/3 이상이 길 밖으로 나가야 떨어진다
	if pd.sol[i] == 0 or absf(x) > float(pd.hw[i]) + maxf(0.3, s * 0.35):
		return NAN
	for hl: Array in holes:
		if d > hl[0] and d < hl[1] and x > hl[2] and x < hl[3]:
			return NAN
	return _h(d)


# ---- 구역 짓기 ----
func _open_zone(k: int) -> void:
	var nd := Node3D.new()
	world.add_child(nd)
	var z := {"k": k, "start": float(maxi(_len(), 0)), "end": -1.0, "node": nd, "things": [], "item": 0, "fork": null, "freed": false}
	zones.append(z)
	_zone_items(z, 0 if zones.size() == 1 else 1)  # 달리는 중에 여는 구역은 한 프레임에 한 조각씩


## 구역의 다음 조각들을 길에 붙이고 짓는다. 갈림길을 만나면 두 갈래를 미리 짓고 멈춘다.
## step > 0 이면 그만큼만 짓고 다음 프레임으로 넘긴다 (갈래를 고른 순간 한꺼번에 지으면 멈칫한다)
func _zone_items(z: Dictionary, step := 0) -> void:
	var items: Array = Z[z.k].items
	var n := 0
	while int(z.item) < items.size():
		if step > 0 and n >= step:
			zone_queue.append(z)
			_relist()
			return
		n += 1
		var it: Dictionary = items[z.item]
		if it.has("fork"):
			var st := _end_st()
			var d0 := float(_len())
			var pair := []
			var o0: Dictionary = {}
			for side in 2:
				var br: Dictionary = it.fork[side]
				# 갈래에 거리로 전역 등록되는 것(발판·구멍·물살…)을 두면 안 고른 갈래 것이 새어 나온다
				for bad: String in ["snow", "sun", "holes", "flow", "drum", "cam", "gate", "goal", "rocks", "under", "crack"]:
					if br.has(bad):
						push_error("fork branch cannot carry '%s'" % bad)
				var o := _gen(st, br.legs)
				if side == 0:
					o0 = o
				var zn: Node3D = z.node
				var bn := Node3D.new()
				zn.add_child(bn)
				branch_nodes.append(bn)
				z["node"] = bn
				bn.position.y = 0.04 * side  # 두 갈래 입구가 같은 높이로 겹쳐 깜빡이지 않게
				# 숨은 갈림길 두 갈래는 가까이 붙어 가서, 옆 풍경 기둥이 다른 갈래 길 위에 선다 (옛 배수로: 큰길 155m 왼쪽 반을 막는 20m 기둥) → 풍경 없이
				z["bare"] = bool(it.get("hidden", false))
				_draw_road(o, 0, o.px.size() - 1, z)
				z.erase("bare")
				# 안내 글은 고른 갈래 것만 (_choose 에서 등록)
				var vis: Dictionary = br.duplicate()
				vis.erase("say")
				pair.append(_make_things(vis, o, 0.0, d0, z))
				z["node"] = zn
			z.fork = {"at": d0, "things": pair, "seal": null, "nodes": branch_nodes.slice(branch_nodes.size() - 2), "arrows": []}
			if not bool(it.get("hidden", false)):
				var os := [_gen(st, it.fork[0].legs), _gen(st, it.fork[1].legs)]
				for sd in 2:
					var o2: Dictionary = os[sd]
					var ar := MeshInstance3D.new()
					ar.mesh = _flow_arrow()
					z.node.add_child(ar)
					ar.position = _pos(d0 - 7.0, -2.6 if sd == 0 else 2.6, _h(d0 - 7.0) + 0.35)
					# 화살표 메시는 +X 를 가리킨다: 그 갈래 12m 앞 방향으로 돌린다
					ar.rotation.y = _oyaw(o2, 12.0) + PI * 0.5
					ar.scale = Vector3(3.2, 1.0, 3.2)
					ar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
					z.fork.arrows.append(ar)
			if bool(it.get("hidden", false)):
				_hidden_fork(it, d0, o0, z)
			else:
				says.append([d0 - 45.0, "← 갈림길 →"])
			_relist()
			return
		var d1 := float(maxi(_len(), 0))
		_extend(it.legs)
		_draw_road(pd, int(d1), _len(), z)
		if int(z.k) == 1 and not tutorial and int(z.item) + 1 == items.size():
			# 수로 구역이 다 지어지면 구역 처음부터 끝까지 하나로 잇는다: 떨어지면 구역 끝 물기둥까지 아래 세상을 달린다 (무거워서 다음 프레임에)
			z["tunnel"] = true
		z.things.append_array(_make_things(it, pd, d1, d1, z))
		if it.has("under") and not tutorial:
			_hidden_chamber(it, d1, z)
		z.item += 1
	# 무거운 마무리(아래 협곡 전체, 구역 끝 장식)는 길 조각을 지은 프레임과 따로, 하나씩 다음 프레임에 (폰에서 멈칫)
	if step > 0 and n > 0:
		zone_queue.append(z)
		_relist()
		return
	if z.get("tunnel", false):
		z.erase("tunnel")
		_build_tunnel(float(z.start), float(_len()), z.node, {"ext": 80.0, "updraft": true, "cave": true})
		z.things.append_array(_under_things(float(z.start), float(_len()), z))
		_relist()
		if step > 0:
			zone_queue.append(z)
			return
	z.end = float(_len())
	_extras(z)
	_cull_far(z.node)
	_relist()


## 갈림길: 그 순간 서 있는 쪽 갈래로 간다.
## 숨은 갈림길: 갈래 0 이 지름길. 봉인이 열렸고(없으면 그냥) 그쪽 끝 차선에 있을 때만, 하늘 수로는 금빛 발사로 공중에 있을 때만.
func _choose(z: Dictionary) -> void:
	var it: Dictionary = Z[z.k].items[z.item]
	var fk: Dictionary = z.fork
	var hidden := bool(it.get("hidden", false))
	var side := 0 if bx < 0.0 else 1
	if hidden:
		side = 1
		var sl: Thing = fk.get("seal")
		var open := sl == null or sl.flat
		if it.has("pick_air"):
			if not on_ground and drum_last >= float(it.pick_air) and dist - drum_last_d < 90.0:
				side = 0
		else:
			var px := float(it.get("pick_x", -4.0))
			if open and ((bx < px) if px < 0.0 else (bx > px)):
				side = 0
	var br: Dictionary = it.fork[side]
	# 고르지 않은 갈래 길은 지운다: 화면에 남아 있으면 그 위로 굴러가 바닥을 뚫고 떨어진다
	var bns: Array = fk.get("nodes", [])
	if bns.size() == 2 and is_instance_valid(bns[1 - side]):
		# 한꺼번에 지우지 않는다: 16m 조각마다 돌이 다가갈 때 차례로 무너져 내린다 (조각 아닌 것은 바로 가라앉힌다)
		var gone: Node3D = bns[1 - side]
		for c in gone.get_children():
			if c is Node3D and (c as Node3D).has_meta("ci"):
				crumble.append([float(fk.at) + float((c as Node3D).get_meta("ci")) * CHUNK, c])
			elif c is Node3D:
				_sink(c as Node3D, 0.0)
		crumble.append([float(fk.at) + 9999.0, gone])  # 빈 껍데기는 맨 끝에
	fork_rail_end = float(fk.at) + 35.0
	look_soft = 1.2
	var ars: Array = fk.get("arrows", [])
	if ars.size() == 2 and is_instance_valid(ars[1 - side]):
		(ars[1 - side] as Node3D).queue_free()
	_extend(br.legs)
	z.things.append_array(fk.things[side])
	for sy: Array in br.get("say", []):
		says.append([float(fk.at) + float(sy[0]), sy[1]])
	z.fork = null
	z.item += 1
	if hidden and side == 0:
		# 깔때기: 가운데 쪽으로 모으되 ±2.5 까지만 (0 으로 모으면 수정 맥 길 앞 206m 가운데 석상에 박는다)
		x_goal = clampf(x_goal, -2.5, 2.5)
		z.item += int(it.get("skip", 0))
		if not fallen:
			_secret(str(it.get("name", "")))
	if not hidden:
		sfx("tick")
	_zone_items(z, 1)


## 숨은 갈림길을 미리 지을 때: 봉인(한 차선) + 바람 줄 두 토막(갈림길 앞 36m, 지름길 첫 24m)
func _hidden_fork(it: Dictionary, d0: float, o0: Dictionary, z: Dictionary) -> void:
	var lx := float(it.get("pick_x", 0.0))
	if it.has("seal"):
		var sl: Array = it.seal
		var l := d0 - float(sl[1])
		var th := _thing(pd, l, l, float(sl[2]), str(sl[0]), z)
		z.things.append(th)
		z.fork["seal"] = th
		lx = float(sl[2])
	lx = float(it.get("lane_x", lx))
	var ldy := float(it.get("lane_dy", 1.6))
	_lane(pd, maxf(0.0, d0 - 36.0), d0 - 1.0, lx, ldy, z.node)
	if not o0.is_empty():
		_lane(o0, 1.0, 24.0, 0.0, ldy, (z.fork.nodes[0] as Node3D) if z.fork != null and z.fork.has("nodes") else z.node)  # 지름길 위 바람은 지름길과 함께 지워진다


## 지름길을 찾았다: 새긴 지명판에 그곳 이름 (모으는 것·세는 것 없음)
func _secret(nm: String) -> void:
	if nm == "":
		return
	_plaque(nm, tr("지름길!"), D, 1.2)
	sfx("launch", -4.0, 1.3)
	shake = maxf(shake, 0.3)


## [a, b) 거리에 있는 깔 것만 a 를 0 으로 옮겨 복사
func _cut(list: Array, a: float, b: float) -> Array:
	var out := []
	for e: Array in list:
		if float(e[1]) >= a and float(e[1]) < b:
			var c := e.duplicate()
			c[1] = float(e[1]) - a
			out.append(c)
	return out


## 바람 줄: 빠른 공기가 이쪽으로 흐른다는 표시. 길 표본 o 의 [la, lb] 를 따라 흰 줄 6개가 흘러간다
func _lane(o: Dictionary, la: float, lb: float, x: float, dy: float, nd: Node3D) -> void:
	var pts := PackedVector3Array()
	var yws := PackedFloat32Array()
	var l := la
	while l <= lb:
		pts.append(_opos(o, l, x, _oh(o, l) + dy))
		yws.append(_oyaw(o, l))
		l += 1.0
	if pts.size() < 3:
		return
	var ss := []
	for i in 6:
		var n := _wind_node(nd)
		ss.append({"n": n, "ph": randf() * float(pts.size() - 1), "ox": randf_range(-1.5, 1.5), "oy": randf_range(0.0, 2.0)})
	lanes.append({"pts": pts, "yw": yws, "s": ss})


## 바람 줄 흐르기 + 깨지는 바닥판 금 깜빡임
func _lane_tick(dt: float) -> void:
	for i in range(lanes.size() - 1, -1, -1):
		var ln: Dictionary = lanes[i]
		var ss: Array = ln.s
		if ss.is_empty() or not is_instance_valid((ss[0] as Dictionary).n):
			lanes.remove_at(i)
			continue
		var pts: PackedVector3Array = ln.pts
		var yws: PackedFloat32Array = ln.yw
		var m := float(pts.size() - 1)
		for sd: Dictionary in ss:
			var ph := fposmod(float(sd.ph) + 26.0 * dt, m)
			sd.ph = ph
			var k := mini(int(ph), pts.size() - 2)
			var f := ph - float(k)
			var yw := lerpf(yws[k], yws[k + 1], f)
			var ox: float = sd.ox
			var n: MeshInstance3D = sd.n
			# 양 끝에서는 짧아져 순간이동처럼 보이지 않는다
			var ll := 4.2 * clampf(sin(PI * ph / m) * 3.0, 0.05, 1.0)
			_wind_place(n, pts[k].lerp(pts[k + 1], f) + Vector3(cos(yw) * ox, float(sd.oy), -sin(yw) * ox), Vector3(-sin(yw), 0.0, -cos(yw)), ll, ll * 0.26)
	var blink := _pm("blue") if fmod(clock, 0.5) < 0.25 else _pm("chip")
	for ck: Dictionary in floor_cracks:
		if bool(ck.open) or absf(float(ck.a) - dist) > 70.0:
			continue
		for n in ck.seam:
			if is_instance_valid(n):
				(n as MeshInstance3D).material_override = blink


func _relist() -> void:
	things.clear()
	for z: Dictionary in zones:
		if not z.freed:
			things.append_array(z.things)


## 고르지 않은 갈래 조각: 돌이 그 조각 30m 앞에 오면(또는 지나치면) 흔들리다 가라앉는다
func _crumble_tick() -> void:
	var i := crumble.size() - 1
	while i >= 0:
		var cr: Array = crumble[i]
		if not is_instance_valid(cr[1]):
			crumble.remove_at(i)
		elif dist >= float(cr[0]) - 30.0 or float(cr[0]) > 9000.0 and crumble.size() == 1:
			_sink(cr[1] as Node3D, randf_range(0.0, 0.15))
			crumble.remove_at(i)
		i -= 1


func _sink(n: Node3D, delay: float) -> void:
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_property(n, "position:y", n.position.y - 1.2, 0.18)
	tw.tween_property(n, "position:y", n.position.y - 60.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(n.queue_free)


## 드로우콜 줄이기: 길 조각 안에서 같은 모양·같은 재질인 정적 물체(길 판·턱 줄·물·기둥·풍경)를 MultiMesh 하나로 묶는다.
## 조각 노드는 그대로라 갈래 무너뜨리기(_sink)와 멀리 숨기기가 그대로 된다. 다른 데서 붙잡고 있는 물체는 조각에 넣지 않는다.
func _batch_chunks(root: Node3D) -> void:
	for c in root.get_children():
		if c is Node3D and (c as Node3D).has_meta("ci"):
			_batch(c as Node3D)


## 이번에 지은 길 조각만 묶는다 (구역 전체를 다시 훑으면 길을 지을 때 멈칫한다)
var touched: Dictionary = {}
func _batch_touched() -> void:
	for c in touched:
		if is_instance_valid(c):
			_batch(c as Node3D)
	touched.clear()


func _batch(c: Node3D) -> void:
	var groups := {}
	for ch in c.get_children():
		var m := ch as MeshInstance3D
		if m == null or m.get_child_count() > 0 or m.mesh == null or not m.visible:
			continue
		var key := "%d:%d" % [m.mesh.get_instance_id(), m.material_override.get_instance_id() if m.material_override else 0]
		if not groups.has(key):
			groups[key] = []
		(groups[key] as Array).append(m)
	for key in groups:
		var list: Array = groups[key]
		if list.size() < 2:
			continue
		var first: MeshInstance3D = list[0]
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = first.mesh
		mm.instance_count = list.size()
		for q in list.size():
			mm.set_instance_transform(q, (list[q] as MeshInstance3D).transform)
		var mi := MultiMeshInstance3D.new()
		mi.multimesh = mm
		mi.material_override = first.material_override
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.visibility_range_end = 260.0
		c.add_child(mi)
		for m: MeshInstance3D in list:
			c.remove_child(m)
			m.free()


## 길 조각(16m)마다 노드 하나: 고르지 않은 갈래를 조각 단위로 차례차례 무너뜨린다
const CHUNK := 16
func _road_chunk(root: Node3D, i: int) -> Node3D:
	var nm := "ch%d" % (i / CHUNK)
	var c := root.get_node_or_null(nm) as Node3D
	if c == null:
		c = Node3D.new()
		c.name = nm
		c.set_meta("ci", i / CHUNK)
		root.add_child(c)
	touched[c] = true
	return c


func _draw_road(o: Dictionary, a: int, b: int, z: Dictionary) -> void:
	var def: Dictionary = Z[z.k]
	var root: Node3D = z.node
	var nd: Node3D = root
	var i := a
	while i < b:
		if o.sol[i] == 0:
			i += 1
			continue
		nd = _road_chunk(root, i)
		var j := i + 1
		var sl0: float = o.hh[i + 1] - o.hh[i]
		while j < b and j - i < 8 and o.sol[j] == 1 and o.hw[j] == o.hw[i] and o.tg[j] == o.tg[i] \
				and absf(o.yw[j] - o.yw[i]) < 0.25 and absf(o.hh[j + 1] - o.hh[j] - sl0) < 0.002:
			j += 1
		var tg: String = o.tg[i]
		var hw: float = o.hw[i]
		var p0 := Vector3(o.px[i], o.hh[i], o.pz[i])
		var p1 := Vector3(o.px[j], o.hh[j], o.pz[j])
		var dir := p1 - p0
		var ln := dir.length()
		var bs := Basis.looking_at(dir / ln, Vector3.UP)
		var up := bs.y.normalized()
		var rt := bs.x.normalized()
		var thick := 1.2 if tg == "aq" else 5.0
		var col: Color = def.road
		match tg:
			"ramp", "gate":
				col = D
			"bridge":
				col = A
		var m := box(Vector3.ZERO, Vector3.ONE, col, nd)
		_apply_art(m, "plank" if tg == "bridge" else _ground_art(int(z.k)))
		m.basis = bs
		m.scale = Vector3(hw * 2.0, thick, ln + 0.4 + hw * absf(o.yw[j] - o.yw[i]))
		m.position = (p0 + p1) * 0.5 - up * thick * 0.5 + up * (0.025 * float(i % 3))  # 겹친 이음매가 깜빡이지 않게
		if ln > 5.0:
			if tg == "aq":
				var w := box(Vector3.ZERO, Vector3.ONE, WATER, nd)
				_skin(w, "water", Color("c4dcff"))  # 수로 물: 물살판(청록)보다 푸르게
				w.basis = bs
				w.scale = Vector3(hw, 0.1, ln + 0.4)
				w.position = (p0 + p1) * 0.5 + up * 0.04
			elif tg != "plaza":
				for sd: float in [-1.0, 1.0]:
					# 숨은 길 입구(mouthL/R): 그쪽 턱 줄이 끊겨 있다
					if (tg == "mouthL" and sd < 0.0) or (tg == "mouthR" and sd > 0.0):
						continue
					var e := box(Vector3.ZERO, Vector3.ONE, Color("24566b"), nd)
					_skin(e, "pit")  # 턱 줄: 짙은 청록 붓결
					e.basis = bs
					e.scale = Vector3(0.22, 0.1, ln + 0.4)
					e.position = (p0 + p1) * 0.5 + rt * sd * (hw - 0.2) + up * 0.04
		i = j
	# 틈 앞뒤에 같은 붉은 경계선을 쓴다.
	for q in range(a + 1, b):
		if o.sol[q] != o.sol[q - 1]:
			nd = _road_chunk(root, q)
			var edge := q - 1 if o.sol[q - 1] == 1 else q
			_plate(o, float(edge), float(edge) + 0.65, -float(o.hw[edge]), float(o.hw[edge]), BAD, nd, 0.18)
	# 기둥(속도 눈금)과 옆 풍경
	if bool(z.get("bare", false)):
		_batch_touched()
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = int(z.k) * 1000 + a + int(absf(float(o.px[a])))
	for q in range(a, b):
		if o.sol[q] == 0:
			continue
		nd = _road_chunk(root, q)
		var hw: float = o.hw[q]
		var h: float = o.hh[q]
		var tg: String = o.tg[q]
		var fq := float(q)
		match def.scen:
			"rock":
				if q % 40 == 20:
					for sd: float in [-1.0, 1.0]:
						_column(o, fq, sd * (hw + rng.randf_range(9.0, 34.0)), h + rng.randf_range(-12.0, 26.0), rng.randf_range(6.0, 13.0), [ROCK, STONE, WHITE].pick_random(), nd)
			"aq":
				if q % 15 == 0 and tg == "aq":
					if int(z.k) == 1 and not tutorial:
						# 수로 기둥은 협곡 중간 어둠 속에서 끝난다: 굴 바닥까지 내려오면 등뒤 카메라를 가린다
						_column(o, fq, 0.0, h - 1.2, 1.6, WHITE, nd, 45.0)
					else:
						_column(o, fq, 0.0, h - 1.2, 1.6, WHITE, nd, 70.0)
				if q % 25 == 5:
					_column(o, fq, -(28.0 + rng.randf_range(0.0, 20.0)), h + rng.randf_range(-4.0, 18.0), rng.randf_range(6.0, 12.0), [GRASS, ROCK].pick_random(), nd)
			"village":
				if q % 48 == 24:
					var sd := 1.0 if (q / 48) % 2 == 0 else -1.0
					var x := sd * (hw + rng.randf_range(8.0, 20.0))
					var top := h - rng.randf_range(2.0, 9.0)
					_column(o, fq, x, top, 6.0, GRASS, nd)
					var hs := box(_opos(o, fq, x, top + 2.0), Vector3(4, 4, 4), WHITE, nd)
					_apply_art(hs, "temple", [WHITE, Color("ffe3b8"), Color("d9ecff"), Color("f3dcff")].pick_random())
					_roof(hs)
					hs.rotation.y = o.yw[q]
			"cliff":
				if q % 30 == 15:
					var sd := 1.0 if (q / 30) % 2 == 0 else -1.0
					_column(o, fq, sd * (hw + rng.randf_range(6.0, 16.0)), h + rng.randf_range(4.0, 20.0), rng.randf_range(5.0, 10.0), [ROCK, WHITE].pick_random(), nd)
			"plaza":
				if tg == "plaza" and q % 24 == 0:
					for sd: float in [-1.0, 1.0]:
						_column(o, fq, sd * (hw + 5.0), h + rng.randf_range(5.0, 10.0), 6.0, [A, B, C, WHITE].pick_random(), nd)
				if tg == "plaza" and q % 12 == 6:
					var st := box(_opos(o, fq, 0.0, h + 0.08), Vector3(hw * 2.0, 0.12, 1.0), WHITE, nd)
					_skin(st, "wall", Color("fff1d6"))
					st.rotation = Vector3(atan(float(o.hh[q + 1]) - h), o.yw[q], 0.0)
			"coast":
				if q % 40 == 0:
					_column(o, fq, -(hw + rng.randf_range(6.0, 14.0)), h + rng.randf_range(2.0, 14.0), rng.randf_range(5.0, 9.0), [WHITE, ROCK].pick_random(), nd)
			"snow":
				# 전나무(초록 기둥 + 흰 모자)와 눈 바위
				if q % 34 == 17:
					var sd := 1.0 if (q / 34) % 2 == 0 else -1.0
					var x := sd * (hw + rng.randf_range(4.0, 12.0))
					var top := h + rng.randf_range(3.0, 7.0)
					_column(o, fq, x, top, 2.2, Color("4fbf6a"), nd)
					var cap := box(_opos(o, fq, x, top + 0.6), Vector3(3.2, 1.4, 3.2), WHITE, nd)
					_skin(cap, "snowfield")
					cap.rotation.y = o.yw[q]
				if q % 60 == 0:
					var sd := -1.0 if (q / 60) % 2 == 0 else 1.0
					_column(o, fq, sd * (hw + rng.randf_range(14.0, 30.0)), h + rng.randf_range(6.0, 22.0), rng.randf_range(7.0, 12.0), [WHITE, ICEWALL].pick_random(), nd)
			"canyon":
				if q % 30 == 15:
					for sd: float in [-1.0, 1.0]:
						_column(o, fq, sd * (hw + rng.randf_range(7.0, 16.0)), h + rng.randf_range(8.0, 28.0), rng.randf_range(6.0, 11.0), [A, ROCK, Color("ffc078")].pick_random(), nd)


## 땅 밑 깊은 곳에서 top 까지 솟은 기둥
	_batch_touched()


func _column(o: Dictionary, d: float, x: float, top: float, w: float, col: Color, nd: Node3D, depth := 70.0) -> void:
	var bot := _oh(o, d) - depth
	var m := box(_opos(o, d, x, (top + bot) * 0.5), Vector3(w, top - bot, w), col, nd)
	_apply_art(m, "pillar")
	m.rotation.y = _oyaw(o, d)


## 조각의 깔 것·구멍·안내·끝·돌 굴러오는 구간. loc0 = o 안에서의 시작 거리, d0 = 길 전체에서의 시작 거리
func _make_things(it: Dictionary, o: Dictionary, loc0: float, d0: float, z: Dictionary) -> Array:
	var out := []
	if it.has("flow"):
		for f: Array in it.flow:
			var markers := []
			_plate(o, loc0 + float(f[0]), loc0 + float(f[1]), float(f[2]), float(f[3]), Color("69bdbf"), z.node, 0.08)
			for d in range(int(f[0]) + 6, int(f[1]) - 2, 12):
				for x: float in [-4.0, 0.0, 4.0]:
					var marker := box(_opos(o, loc0 + d, x, _oh(o, loc0 + d) + 0.24), Vector3(1.6, 0.12, 1.6), WHITE, z.node)
					marker.mesh = _flow_arrow()
					_skin(marker, "chip")
					marker.scale = Vector3.ONE
					marker.rotation = Vector3(0.0, _oyaw(o, loc0 + d) + (PI if float(f[4]) < 0.0 else 0.0), 0.0)
					markers.append(marker)
			currents.append({"a": d0 + float(f[0]), "b": d0 + float(f[1]), "x0": float(f[2]), "x1": float(f[3]), "dir": float(f[4]), "markers": markers})
	if it.has("drum"):
		for f: Array in it.drum:
			var nodes := []
			_plate(o, loc0 + float(f[0]), loc0 + float(f[1]), -8.0, 8.0, D, z.node, 0.08)
			for d in range(int(f[0]) + 4, int(f[1]), 8):
				var m := box(_opos(o, loc0 + d, 0.0, _oh(o, loc0 + d) + 0.22), Vector3(6, 0.15, 1), WHITE, z.node)
				_skin(m, "chip")
				m.rotation.y = _oyaw(o, loc0 + d)
				nodes.append(m)
			drums.append({"a": d0 + float(f[0]), "b": d0 + float(f[1]), "nodes": nodes})
	if it.has("put"):
		for p: Array in it.put:
			out.append(_thing(o, loc0 + float(p[1]), d0 + float(p[1]), float(p[2]), p[0], z))
	if it.has("fence"):
		for fr in it.fence:
			var l := loc0 + float(fr)
			var hw: float = o.hw[_oi(o, l)]
			var fx := -hw + 1.8
			while fx < hw - 1.0:
				out.append(_thing(o, l, d0 + float(fr), fx, "fence", z))
				fx += 3.6
	if it.has("row"):
		# 길 폭 전체를 막는 줄 (얼음벽·수정)
		for rw: Array in it.row:
			var l := loc0 + float(rw[0])
			var hw: float = o.hw[_oi(o, l)]
			var w: float = (KIND[rw[1]].size as Vector3).x
			var fx := -hw + w * 0.5
			while fx < hw - 1.0:
				out.append(_thing(o, l, d0 + float(rw[0]), fx, rw[1], z))
				fx += w
	for key in ["snow", "sun"]:
		if it.has(key):
			for pp: Array in it[key]:
				pads.append([d0 + float(pp[0]), d0 + float(pp[1]), float(pp[2]), float(pp[3]), key])
				_plate(o, loc0 + float(pp[0]), loc0 + float(pp[1]), float(pp[2]), float(pp[3]), WHITE if key == "snow" else D, z.node, 0.06)
				if key == "snow":
					var mark := loc0 + float(pp[0]) + 3.0
					while mark < loc0 + float(pp[1]) - 2.0:
						for sd: float in [-1.0, 1.0]:
							var stripe := box(_opos(o, mark, (float(pp[2]) + float(pp[3])) * 0.5 + sd * 0.65, _oh(o, mark) + 0.23), Vector3(0.18, 0.08, 1.8), ICE, z.node)
							_skin(stripe, "pit")
							stripe.rotation.y = _oyaw(o, mark) + sd * 0.6
						mark += 9.0
				if key == "sun":
					# 녹는 길 위 햇살 무늬
					var l := loc0 + float(pp[0]) + 4.0
					while l < loc0 + float(pp[1]) - 2.0:
						var st := box(_opos(o, l, (float(pp[2]) + float(pp[3])) * 0.5, _oh(o, l) + 0.1), Vector3(float(pp[3]) - float(pp[2]) - 1.0, 0.1, 0.8), A, z.node)
						_skin(st, "sand", Color("ffb066"))  # 햇살 무늬: 금빛 모래에 주황
						st.rotation.y = _oyaw(o, l)
						l += 11.0
	if it.has("holes"):
		for hl: Array in it.holes:
			holes.append([d0 + float(hl[0]), d0 + float(hl[1]), float(hl[2]), float(hl[3])])
			_plate(o, loc0 + float(hl[0]), loc0 + float(hl[1]), float(hl[2]), float(hl[3]), Color("183e53"), z.node, 0.16)
			for edge: float in [float(hl[0]), float(hl[1])]:
				_plate(o, loc0 + edge, loc0 + edge + 0.65, float(hl[2]), float(hl[3]), BAD, z.node, 0.3)
	if it.has("cam"):
		for cm: Array in it.cam:
			cams.append([d0 + float(cm[0]), cm[1]])
	if it.has("say"):
		for sy: Array in it.say:
			says.append([d0 + float(sy[0]), sy[1]])
	if it.has("lane"):
		# 바람 줄은 보이기만 한다 (갈래에 두어도 새지 않는다)
		for ln: Array in it.lane:
			_lane(o, loc0 + float(ln[0]), loc0 + float(ln[1]), float(ln[2]), float(ln[3]), z.node)
	if it.has("gate"):
		for g: Array in it.gate:
			gates.append([d0 + float(g[0]), g[1], g[2]])
	if it.has("goal"):
		goal_d = d0 + float(it.goal)
	if it.has("rocks"):
		rock_a = d0 + float(it.rocks[0])
		rock_b = d0 + float(it.rocks[1])
	return out


## 길 위 얇은 판 (구멍·눈·녹는 길)
func _plate(o: Dictionary, la: float, lb: float, x0: float, x1: float, col: Color, nd: Node3D, lift: float) -> void:
	var xm := (x0 + x1) * 0.5
	var holder := Node3D.new()  # 판 조각들은 MultiMesh 하나로 묶는다
	nd.add_child(holder)
	# 짧은 판으로 지면을 따라가 눈·구멍 무늬가 경사 위에 뜨지 않게 한다.
	var d := la
	while d < lb:
		var next := minf(d + 4.0, lb)
		var p0 := _opos(o, d, xm, _oh(o, d))
		var p1 := _opos(o, next, xm, _oh(o, next))
		var m := box(Vector3.ZERO, Vector3.ONE, col, holder)
		_plate_skin(m, col)
		m.basis = Basis.looking_at((p1 - p0).normalized(), Vector3.UP)
		m.scale = Vector3(x1 - x0, 0.2, (p1 - p0).length() + 0.02)
		m.position = (p0 + p1) * 0.5 + Vector3.UP * lift
		d = next
	_batch(holder)


## 뒤집은 껍질 외곽선: 같은 메시를 조금 키워 앞면을 버리고 진한 색으로 (작은 것이 배경에 묻히지 않게)
func _ink_outline(n: MeshInstance3D, col: Color) -> void:
	var key := "outline" + col.to_html()
	if not art_tinted.has(key):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = col
		m.cull_mode = BaseMaterial3D.CULL_FRONT
		art_tinted[key] = m
	var o := MeshInstance3D.new()
	o.mesh = n.mesh
	o.material_override = art_tinted[key]
	o.scale = Vector3.ONE * 1.16
	o.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.add_child(o)


func _thing(o: Dictionary, l: float, d: float, x: float, kind: String, z: Dictionary) -> Thing:
	# 규칙: 낮은 담(뛰어넘기)은 옆모습 시점에서만. 등뒤·위 시점에서는 높이가 안 읽혀 석상으로 바꾼다
	if kind == "wall" and str(Z[z.k].mode) != "side":
		kind = "statue"
	var th := Thing.new()
	th.kd = KIND[kind]
	th.d = d
	th.x = x
	th.base = _oh(o, l)
	var sz: Vector3 = th.kd.size
	th.col = (th.kd.col as Array).pick_random()
	th.n = box(_opos(o, l, x, th.base + sz.y * 0.5), sz, th.col, z.node)
	th.n.rotation.y = _oyaw(o, l)
	var look: Array = SHARD_OF.get(kind, ["chip", th.col])
	th.shard = look[0]
	th.shard_tint = look[1]
	if kind in ["pot", "pillar", "post", "crystal", "vein"]:
		var shape := CylinderMesh.new()
		shape.radial_segments = 6
		shape.height = 1.0
		shape.bottom_radius = 0.5
		shape.top_radius = 0.0 if kind in ["crystal", "vein"] else (0.34 if kind == "pot" else 0.5)
		th.n.mesh = shape
	if kind in ["pot", "pillar", "post", "crystal", "vein"]:
		var art := "pillar" if kind == "post" else ("crystal" if kind == "vein" else kind)
		_apply_art(th.n, art)
		if kind in ["pillar", "post"]:
			# 위험 기둥 = 붉은 흙빛(테라코타)으로 칠한 신전 기둥: 같은 홈·얼룩 그림에 색만 붉게. 빨강 = 위험 하나로 읽힌다
			_skin(th.n, "pillar_red")
	elif kind == "house":
		_apply_art(th.n, "temple")
	elif kind == "door":
		_apply_art(th.n, "temple", STONE)
	elif kind == "ice" or kind == "icedoor":
		_apply_art(th.n, "crystal")
		th.n.material_override = art_materials["ice_wall"]
	elif kind == "statue":
		_apply_art(th.n, "pillar")
		# 석상 머리와 받침: 기둥이 아니라 서 있는 상으로 읽히게
		var head := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radial_segments = 10
		sph.rings = 6
		head.mesh = sph
		th.n.add_child(head)
		head.position = Vector3(0, 0.62, 0)
		head.scale = Vector3(0.62, 0.3, 0.62)
		_skin(head, "wall", Color("fff1d6"))
		var foot := box(Vector3(0, -0.47, 0), Vector3(1.3, 0.08, 1.3), STONE, th.n)
		_skin(foot, "wall")
	elif kind == "wall":
		_skin(th.n, "pillar_red")
		var cope := box(Vector3(0, 0.58, 0), Vector3(1.1, 0.18, 1.2), STONE, th.n)
		_skin(cope, "wall", Color("fff6e4"))
	elif kind == "fence":
		_apply_art(th.n, "plank")
	elif kind == "tower":
		_apply_art(th.n, "pillar", Color("cfe6ff"))
	elif kind == "roof":
		_skin(th.n, "roof", Color("cfe6ff"))
	elif kind == "gold":
		_apply_art(th.n, "temple", D)
	if th.kd.get("slam", false):
		# 파란 머리 + 둘레 띠: 버티기 버튼 색. 위에서 보이도록 크게.
		_skin(box(Vector3(0, 0.56, 0), Vector3(1.3, 0.14, 1.3), B, th.n), "blue")
		_skin(box(Vector3(0, 0.2, 0), Vector3(1.08, 0.06, 1.08), B, th.n), "blue")
		return th
	if bool(th.kd.get("soft", false)):
		_seal_marks(th, kind)  # 숨은 길 봉인: 빨간 띠 없음(위험이 아니라 선택), 여는 동작 색 무늬
		return th
	var ring_band := kind == "pillar" or kind == "post"
	if float(th.kd.need) > 90.0 or kind == "ice":
		var foot := _red(box(Vector3(0, -0.43, 0), Vector3(1.05, 0.18, 1.05), BAD, th.n))
		if ring_band:
			foot.mesh = _band_mesh()
	if kind == "house":
		_roof(th.n)
	elif ring_band:
		# 기둥머리 아래 가는 붉은 띠 (둥근 고리라 기둥 홈에 감긴다)
		var band := _red(box(Vector3(0, 0.46, 0), Vector3(1.22, 0.07, 1.22), BAD, th.n))
		band.mesh = _band_mesh()
	return th


## 기둥에 감는 둥근 띠 (모두 같이 쓴다)
var band_mesh: CylinderMesh


func _band_mesh() -> CylinderMesh:
	if band_mesh == null:
		band_mesh = CylinderMesh.new()
		band_mesh.radial_segments = 12
		band_mesh.rings = 1
		band_mesh.top_radius = 0.5
		band_mesh.bottom_radius = 0.5
		band_mesh.height = 1.0
	return band_mesh


## 깨진 것마다 튀는 조각 그림 [그림, 색]: 항아리는 사금파리, 기둥은 테라코타, 울타리는 나무, 수정은 자수정, 얼음은 얼음결
const SHARD_OF := {
	"pot": ["potshard", Color.WHITE], "statue": ["wall", Color("fff1d6")], "pillar": ["roof", Color.WHITE], "post": ["roof", Color.WHITE],
	"fence": ["wood", Color.WHITE], "house": ["roof", Color.WHITE], "wall": ["wall", Color.WHITE], "ice": ["snowfield", Color("8fd0ff")],
	"icedoor": ["snowfield", Color("8fd0ff")], "crystal": ["amethyst", Color.WHITE], "vein": ["amethyst", Color.WHITE],
	"tower": ["chip", Color("cfe6ff")], "gold": ["sand", Color.WHITE], "door": ["wall", Color("efe1c4")],
}


## 봉인 무늬 = 여는 버튼 색: 돌문은 쪼개기 보라 지그재그 금, 얼음판은 눈(키우기) 흰 서리 띠, 수정 하나는 밝은 받침
func _seal_marks(th: Thing, kind: String) -> void:
	match kind:
		"door":
			var zz := [[-0.2, 0.25, 0.7], [0.1, 0.0, -0.7], [-0.1, -0.25, 0.7]]
			for q: Array in zz:
				var sm := box(Vector3(float(q[0]), float(q[1]), 0.0), Vector3(0.06, 0.32, 1.06), C, th.n)
				_skin(sm, "amethyst")
				sm.rotation.z = float(q[2])
		"icedoor":
			_skin(box(Vector3(0, 0.3, 0), Vector3(1.04, 0.06, 1.04), WHITE, th.n), "snowfield")
		"vein":
			_skin(box(Vector3(0, -0.45, 0), Vector3(1.1, 0.1, 1.1), C.lightened(0.3), th.n), "chip", C.lightened(0.3))


## 게이지 금빛 눈금: 80m 안에 '이 속도면 뚫리는' 봉인이 있으면 그 속도 자리에. 그만큼 빠르면 초록
func _ram_gauge() -> void:
	if ram_tick == null:
		return
	var rt: Thing = null
	for th: Thing in things:
		if th.flat or not th.kd.has("ram"):
			continue
		var dd := th.d - dist
		if dd > 0.0 and dd < 80.0:
			rt = th
			break
	if rt == null or fallen or won:
		ram_tick.visible = false
		return
	var rv := float(rt.kd.ram)
	ram_tick.visible = true
	ram_tick.position.x = 600.0 * rv / VMAX - 3.0
	ram_tick.color = GOOD if v >= rv else D


## 구역이 다 이어진 뒤: 바닥, 신전, 다음 구역 문
## 멀리 있는 작은 것은 그리지 않는다: 폰에서 그리기 호출을 줄인다 (큰 신전·바닥판·하늘 기둥은 늘 보인다)
func _cull_far(n: Node) -> void:
	for c in n.get_children():
		if c is MeshInstance3D:
			var m := c as MeshInstance3D
			if m.scale.length() < 40.0 and m.visibility_range_end <= 0.0:
				m.visibility_range_end = 230.0
		_cull_far(c)


func _extras(z: Dictionary) -> void:
	var def: Dictionary = Z[z.k]
	var nd: Node3D = z.node
	var a := int(z.start)
	var b := int(z.end)
	var mn := INF
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for i in range(a, b + 1):
		mn = minf(mn, pd.hh[i])
		lo = Vector2(minf(lo.x, pd.px[i]), minf(lo.y, pd.pz[i]))
		hi = Vector2(maxf(hi.x, pd.px[i]), maxf(hi.y, pd.pz[i]))
	var fy := mn - (3.0 if z.k == Z.size() - 1 else (DEEP + 4.0 if z.k == 1 and not tutorial else 30.0))
	var mid := (lo + hi) * 0.5
	var margin := 600.0 if z.k == Z.size() - 1 else 80.0
	var flr := box(Vector3(mid.x, fy, mid.y), Vector3(hi.x - lo.x + margin, 1.0, hi.y - lo.y + margin), def.floor, nd)
	# 아래 바닥: 물이면 물결, 아니면 그 색 붓결 (넓어서 그림을 여러 번 깐다)
	if def.floor == WATER:
		_skin(flr, "water", Color("c4dcff"), 12.0)
	else:
		_skin(flr, "chip", def.floor, 12.0)
	if int(z.k) == Z.size() - 1:
		var temple_d := goal_d + 24.0
		var temple := box(_pos(temple_d, 0.0, _h(temple_d) + 11.0), Vector3(40, 24, 20), STONE, nd)
		_apply_art(temple, "temple")
		temple.rotation.y = _yaw(temple_d)
		for side: float in [-1.0, 1.0]:
			var column := box(_pos(goal_d + 2.0, side * 13.0, _h(goal_d) + 8.0), Vector3(3, 16, 3), WHITE, nd)
			_apply_art(column, "pillar")
		# 신전 뒤 금빛 기둥 7개: 닿기 전엔 숨어 있다가 도착하면 부채꼴로 솟는다
		if not ray_mat:
			ray_mat = StandardMaterial3D.new()
			ray_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			ray_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			ray_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			ray_mat.albedo_color = Color(1.0, 0.85, 0.3, 0.3)
		for i in 7:
			var rh := Node3D.new()
			nd.add_child(rh)
			rh.position = _pos(temple_d - 10.0, 0.0, _h(temple_d) + 2.0)
			rh.rotation = Vector3(0.0, _yaw(temple_d), (i - 3) * 0.22)
			var bx2 := box(Vector3(0, 0.5, 0), Vector3(1.6, 1.0, 1.6), D, rh)
			bx2.material_override = ray_mat
			bx2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			rh.scale = Vector3(1, 0.001, 1)
			rh.visible = false
			rays.append(rh)
	if z.k == 0:
		var p := _pos(0.0, 0.0, 0.0)
		var h := _h(0.0)
		var home := box(p + Vector3(0, h + 9.0, 14.0), Vector3(24, 18, 14), STONE, nd)
		_apply_art(home, "temple")
		for sd: float in [-1.0, 1.0]:
			var pillar := box(p + Vector3(sd * 7.8, h + 4.0, 3.0), Vector3(1.4, 8, 1.4), WHITE, nd)
			_apply_art(pillar, "pillar")
	if z.k + 1 < Z.size():
		var col: Color = SKILL_COL.get(Z[z.k + 1].skill, WHITE)
		var gd := float(b) - 4.0
		var hw: float = pd.hw[_oi(pd, gd)]
		var gh := _h(gd)
		var yw := _yaw(gd)
		for sd: float in [-1.0, 1.0]:
			var g := box(_pos(gd, sd * (hw + 1.0), gh + 5.0), Vector3(1.4, 10, 1.4), col, nd)
			_apply_art(g, "pillar")
			g.rotation.y = yw
		var bar := box(_pos(gd, 0.0, gh + 10.0), Vector3(hw * 2.0 + 3.4, 1.6, 1.6), col, nd)
		_skin(bar, "wall", col.lightened(0.45))
		z["lintel"] = bar
		bar.rotation.y = yw


func _zones_tick() -> void:
	for z: Dictionary in zones:
		if z.fork != null and z.fork.has("arrows") and (z.fork.arrows as Array).size() == 2:
			var near := float(z.fork.at) - dist < 70.0
			for sd in 2:
				var ar: MeshInstance3D = z.fork.arrows[sd]
				if is_instance_valid(ar):
					var mine := (bx < 0.0) == (sd == 0)
					ar.material_override = mat(G_TOP.lerp(WHITE, 0.25 + 0.25 * sin(clock * 12.0)) if mine and near else Color("e9dcc2"))
					ar.scale = Vector3(3.8, 1.0, 3.8) if mine and near else Vector3(2.8, 1.0, 2.8)
		if z.fork != null and dist >= float(z.fork.at) - 4.0:
			_choose(z)
	var last: Dictionary = zones.back()
	if float(last.end) >= 0.0 and int(last.k) + 1 < Z.size() and _len() - dist < 170.0:
		_open_zone(int(last.k) + 1)
	for z: Dictionary in zones:
		if int(z.k) > cur_k and dist >= float(z.start) and not fallen:
			_enter(z)
	var gone := false
	for z: Dictionary in zones:
		if not z.freed and float(z.end) >= 0.0 and dist > float(z.end) + 30.0:
			(z.node as Node3D).queue_free()
			z.freed = true
			gone = true
	if gone:
		_relist()
	for i in range(cams.size() - 1, -1, -1):
		if dist >= float(cams[i][0]) and cur_k >= 0:
			mode = cams[i][1]
			cams.remove_at(i)
	for i in range(says.size() - 1, -1, -1):
		if dist >= float(says[i][0]):
			if not underground:  # 지하에서는 위 수로 안내를 띄우지 않는다
				guide(says[i][1])
			says.remove_at(i)


func _enter(z: Dictionary) -> void:
	var first := cur_k < 0
	cur_k = z.k
	if int(z.k) == 1 and not tutorial:
		_prewarm(z.node)
	var def: Dictionary = Z[cur_k]
	mode = def.mode
	# 돌 테두리: 어두운 얼음길(설산)에서는 크림색이라야 돌이 보인다
	if hero_rim:
		hero_rim.set_shader_parameter("ink", Color("fff5df") if (cur_k == 5 and not tutorial) else INK)
	sky_to = def.sky
	hz_to = def.hz
	if first and sky_mat:
		sky_mat.sky_top_color = sky_to
		sky_mat.sky_horizon_color = hz_to
		sky_mat.ground_horizon_color = hz_to
	_far_build(cur_k)
	_air_set(str(AIR_OF.get(def.get("scen", "rock"), "dust")))
	# 구역 이름은 새긴 지명판으로 쾅
	_plaque(def.msg, "%02d / %02d" % [cur_k + 1, Z.size()], SKILL_COL.get(def.skill, ROCK))
	# 방금 지난 문 상판이 쿵 하고 내려앉으며 먼지를 턴다
	if cur_k > 0:
		for zz: Dictionary in zones:
			if int(zz.k) != cur_k - 1 or not zz.has("lintel") or not is_instance_valid(zz.lintel):
				continue
			var bar: Node3D = zz.lintel
			_burst(bar.global_position, STONE, 6, 5.0, 0.5)
			var y0 := bar.position.y
			var ltw := bar.create_tween()
			ltw.tween_property(bar, "position:y", y0 - 0.5, 0.06)
			ltw.tween_property(bar, "position:y", y0, 0.25).set_trans(Tween.TRANS_BACK)
	if def.skill != "":
		_unlock(def.skill)
	if cur_k > 0:
		play("good")
		var i := int(z.start)
		cp_k = cur_k
		cp_st = {"x": pd.px[i], "z": pd.pz[i], "yw": pd.yw[i], "h": pd.hh[i]}
		cp_s = s_goal
		cp_score = score_base + int(dist) + bonus


## 먼 실루엣: 카메라를 따라다니는 고리 위의 큰 상자들 (구역마다 모양·색, 하늘색 쪽으로 흐리게)
func _far_build(k: int, cave := false) -> void:
	if far_k == k:
		return
	far_k = k
	for c in far.get_children():
		if c != clouds:
			c.queue_free()
	var def: Dictionary = Z[k]
	if cave:
		def = {"sky": UNDER_SKY, "far": "peak", "farcol": [ROCK, Color("8a6d4b"), STONE]}
	clouds.visible = not cave
	var sky: Color = def.sky
	var cols: Array = def.farcol
	var rng := RandomNumberGenerator.new()
	rng.seed = 77 + k * 13
	for i in 12:
		var a := TAU * i / 12.0 + rng.randf_range(-0.15, 0.15)
		var r := rng.randf_range(280.0, 380.0)
		var w := 60.0
		var h := 80.0
		match def.far:
			"peak":
				w = rng.randf_range(60.0, 100.0)
				h = rng.randf_range(60.0, 140.0)
			"city":
				w = rng.randf_range(26.0, 50.0)
				h = rng.randf_range(30.0, 80.0)
			"spire":
				w = rng.randf_range(16.0, 30.0)
				h = rng.randf_range(60.0, 150.0)
			_:
				w = rng.randf_range(70.0, 120.0)
				h = rng.randf_range(15.0, 45.0)
		var col: Color = (cols[i % cols.size()] as Color).lerp(sky, 0.45)
		var bot := -220.0
		var m := box(Vector3(cos(a) * r, (h + bot) * 0.5, sin(a) * r), Vector3(w, h - bot, w * 0.8), col, far)
		m.rotation.y = rng.randf_range(0.0, PI)
		# 먼 실루엣도 칠한 그림: 도시 = 신전 기둥, 나머지 = 지층 띠 절벽 (하늘색 쪽으로 물든 채)
		if def.far == "city":
			_apply_art(m, "pillar", col.lightened(0.1))
		else:
			_skin(m, "strata", col.lightened(0.12))
		if def.far == "peak":
			var peak := CylinderMesh.new()
			peak.radial_segments = 6
			peak.top_radius = 0.0
			peak.bottom_radius = 0.65
			peak.height = 1.0
			m.mesh = peak
		elif def.far == "dome" or def.far == "spire":
			var hill := CylinderMesh.new()
			hill.radial_segments = 6
			hill.top_radius = 0.25 if def.far == "dome" else 0.0
			hill.bottom_radius = 0.65
			hill.height = 1.0
			m.mesh = hill
	if cave:
		return
	# A painted landmark anchors the skyline in every region.
	var landmark := box(Vector3(-150, 42, -280), Vector3(110, 70, 70), STONE, far)
	_apply_art(landmark, "temple", Color("b8cfda"))


## 파편 n개를 p 에서 튀긴다 (미리 만든 상자를 돌려 쓴다)
func _burst(p: Vector3, col: Color, n: int, spd: float, sz := 0.5, tex := "") -> void:
	# 조각 그림: tex 를 주면 그 그림에 col 색, 아니면 색으로 그림을 고른다 (재질은 모두 캐시)
	var look: Array = [tex, col] if tex != "" else _shard_look(col)
	var tint: Color = look[1]
	var sm := _shard_mat(str(look[0]), tint)
	for b: Dictionary in bits:
		if n <= 0:
			break
		if float(b.life) > 0.0:
			continue
		var bn: MeshInstance3D = b.n
		bn.visible = true
		bn.material_override = sm
		bn.position = p + Vector3(randf_range(-0.5, 0.5), randf_range(0.0, 0.6), randf_range(-0.5, 0.5))
		bn.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		b.v = Vector3(randf_range(-1.0, 1.0), randf_range(0.6, 1.4), randf_range(-1.0, 1.0)) * spd
		b.max = randf_range(0.5, 0.9)
		b.life = b.max
		b.sz = sz * randf_range(0.7, 1.3)
		n -= 1


func _fx(dt: float) -> void:
	for b: Dictionary in bits:
		if float(b.life) <= 0.0:
			continue
		b.life = float(b.life) - dt
		var bn: MeshInstance3D = b.n
		if float(b.life) <= 0.0:
			bn.visible = false
			continue
		b.v = (b.v as Vector3) + Vector3.DOWN * 30.0 * dt
		bn.position += (b.v as Vector3) * dt
		bn.rotation.x += dt * 9.0
		bn.scale = Vector3.ONE * float(b.sz) * (0.3 + 0.7 * float(b.life) / float(b.max))
	# 찌그러짐은 용수철: 납작했다가 살짝 늘어나며 되돌아온다 (긴 프레임에도 터지지 않게 dt 를 묶는다)
	var fdt := minf(dt, 0.033)
	sq_v += (-sq * 260.0 - sq_v * 22.0) * fdt
	sq = maxf(-0.14, sq + sq_v * fdt)
	if sky_mat:
		sky_mat.sky_top_color = sky_mat.sky_top_color.lerp(sky_to, minf(1.0, dt * 1.5))
		var hz := hz_to
		sky_mat.sky_horizon_color = sky_mat.sky_horizon_color.lerp(hz, minf(1.0, dt * 1.5))
		sky_mat.ground_horizon_color = sky_mat.sky_horizon_color
		# 안개·주변광은 지평선 색을 따라간다 (지하는 가까운 호박빛 안개)
		if sky_env:
			sky_env.fog_light_color = sky_mat.sky_horizon_color
			sky_env.fog_depth_begin = lerpf(sky_env.fog_depth_begin, 18.0 if underground else 80.0, minf(1.0, dt))
			sky_env.fog_depth_end = lerpf(sky_env.fog_depth_end, 190.0 if underground else 520.0, minf(1.0, dt))
			sky_env.ambient_light_color = WHITE.lerp(sky_mat.sky_horizon_color, 0.5)
	if clouds:
		clouds.rotation.y += dt * 0.015


## 멈칫: sec 실제 초 동안 판이 거의 멈춘다. fov_kick 은 순간 화각 튐 (그 뒤 _place 가 되돌린다)
func _hitstop(sec: float, fov_kick := 0.0) -> void:
	hs_t = maxf(hs_t, sec)
	if cam and fov_kick != 0.0:
		cam.fov = clampf(cam.fov + fov_kick, 35.0, 110.0)


## 느린 동작: sec 실제 초 동안 판이 k 배로 흐른다
func _slowmo(sec: float, k: float) -> void:
	slo_t = maxf(slo_t, sec)
	slo_k = k


## 충격 고리: p 에서 땅 위로 납작하게 퍼지며 사라진다
func _ring(p: Vector3, col: Color, r: float, dur := 0.35) -> void:
	if rings.is_empty():
		return
	var n: MeshInstance3D = rings[ring_i % rings.size()]
	ring_i += 1
	if not is_instance_valid(n):
		return
	if n.has_meta("tw"):
		var old: Tween = n.get_meta("tw")
		if old and old.is_valid():
			old.kill()
	var m := n.material_override as StandardMaterial3D
	m.albedo_color = Color(col, 0.85)
	n.position = p
	n.scale = Vector3(0.6, 1.0, 0.6)
	n.visible = true
	var tw := n.create_tween().set_parallel()
	tw.tween_property(n, "scale", Vector3(r, 1.0, r), dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(m, "albedo_color:a", 0.0, dur)
	tw.chain().tween_callback(n.hide)
	n.set_meta("tw", tw)


## 땅 먼지 색 하나: 구역 땅에 맞춘다 (지하는 먼지 크림, 눈은 흰색, 해안은 모래)
func _dust_col() -> Color:
	if underground:
		return DUST
	match _ground_art(maxi(cur_k, 0)):
		"snow":
			return WHITE
		"coast":
			return Color("f3dcaa")
	return Color("ecd3a0")


## 발밑 그림자: 땅(또는 협곡 바닥) 위에 먹색 원. 높이 뜰수록 작고 옅다
func _blob_tick(yw: float) -> void:
	var g := _ground(dist, bx)
	if is_nan(g) and not underground and _tunnel_depth(dist) > 0.0:
		g = _h(dist) - _tunnel_depth(dist)
	blob.visible = not is_nan(g) and not fallen and not won
	if blob.visible:
		var k := clampf(1.0 - maxf(0.0, by - g) / 30.0, 0.22, 1.0)
		blob.position = _pos(dist, bx, g + 0.3)
		blob.rotation = Vector3(atan(_slope(dist)), yw, 0.0)
		blob.scale = Vector3.ONE * s * 1.05 * k
		blob_mat.albedo_color.a = 0.38 * k


## 공기 알갱이: 카메라에 붙은 입자 하나. 구역마다 먼지·꽃가루·꽃잎·눈·모래·물보라로 바뀐다
func _air_make() -> void:
	if not cam:
		return
	air_pt = CPUParticles3D.new()
	air_pt.amount = 44
	air_pt.lifetime = 3.0
	air_pt.preprocess = 3.0
	air_pt.local_coords = false
	air_pt.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	air_pt.emission_box_extents = Vector3(24, 10, 24)
	air_pt.position = Vector3(0, -2, -24)
	var qm := QuadMesh.new()
	qm.size = Vector2(0.9, 0.3)
	air_pt.mesh = qm
	var am := StandardMaterial3D.new()
	am.albedo_texture = load(ART_ROOT + "fx_gpt/wind_1.png") as Texture2D  # 네모 점 대신 바람결 그림
	am.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	am.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	am.vertex_color_use_as_albedo = true
	am.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	air_pt.material_override = am
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.set_color(1, Color(1, 1, 1, 0))
	fade.add_point(0.2, WHITE)
	fade.add_point(0.8, WHITE)
	air_pt.color_ramp = fade
	air_pt.direction = Vector3.UP
	air_pt.spread = 180.0
	cam.add_child(air_pt)
	_air_set("dust")


func _air_set(kind: String) -> void:
	if not air_pt or not AIR.has(kind):
		return
	var p: Array = AIR[kind]
	air_pt.color = p[0]
	air_pt.gravity = p[1]
	air_pt.initial_velocity_min = p[2]
	air_pt.initial_velocity_max = p[3]
	air_pt.scale_amount_min = p[4]
	air_pt.scale_amount_max = p[5]
	if kind == "ember":
		# 지옥 협곡: 용암에서 솟는 불티
		var ge := Gradient.new()
		ge.set_color(0, Color("ffd27a"))
		ge.set_color(1, Color("ff4a1a"))
		air_pt.color_initial_ramp = ge
	elif kind == "cave":
		# 지하: 수정 빛 네 가지가 섞인 반딧불
		var gl := Gradient.new()
		gl.set_color(0, Color("7ff0ff"))
		gl.set_color(1, Color("9cf2c4"))
		gl.add_point(0.33, Color("ffd27a"))
		gl.add_point(0.66, C.lightened(0.35))
		air_pt.color_initial_ramp = gl
	else:
		air_pt.color_initial_ramp = null


## 흙먼지: 빠를수록 촘촘히 돌 뒤에서 피어올라 부풀다 사라진다
func _dust(dt: float) -> void:
	for p: Dictionary in dust:
		if float(p.life) <= 0.0:
			continue
		p.life = float(p.life) - dt
		var pn: MeshInstance3D = p.n
		if float(p.life) <= 0.0:
			pn.visible = false
			continue
		p.v = (p.v as Vector3) * exp(-3.0 * dt)
		pn.position += (p.v as Vector3) * dt
		pn.rotation.y += dt * 2.0
		var t01 := 1.0 - float(p.life) / float(p.max)
		pn.scale = Vector3.ONE * maxf(0.01, float(p.sz) * sin(PI * clampf(t01 * 0.85 + 0.15, 0.0, 1.0)))
	dust_t -= dt
	var spd := clampf((v - 16.0) / 39.0, 0.0, 1.0)
	if not on_ground or fallen or won or spd <= 0.0 or dust_t > 0.0:
		return
	dust_t = lerpf(0.1, 0.035, spd)
	for p: Dictionary in dust:
		if float(p.life) > 0.0:
			continue
		var pn: MeshInstance3D = p.n
		pn.material_override = _shard_mat("chip", _dust_col())
		pn.position = _pos(dist - s * 0.4, bx + randf_range(-0.35, 0.35) * s, by + 0.2)
		pn.scale = Vector3.ONE * 0.01
		pn.visible = true
		p.v = Vector3(randf_range(-2.0, 2.0), randf_range(1.5, 3.5) + spd * 2.0, randf_range(-2.0, 2.0))
		p.sz = s * randf_range(0.22, 0.32) * (0.8 + spd * 0.7)
		p.max = randf_range(0.45, 0.75)
		p.life = p.max
		break


## 바람 소리 고리: 저역 잡음 1초, 끝과 처음을 겹쳐 이음매 없이 돈다
func _wind_stream() -> AudioStreamWAV:
	var n := 22050
	var f := 2000
	var raw := PackedFloat32Array()
	raw.resize(n)
	var lp := 0.0
	for i in n:
		lp += (randf_range(-1.0, 1.0) - lp) * 0.12
		raw[i] = clampf(lp * 2.2, -1.0, 1.0)
	var m := n - f
	var data := PackedByteArray()
	data.resize(m * 2)
	for i in m:
		var x: float = raw[i] if i >= f else lerpf(raw[m + i], raw[i], float(i) / float(f))
		data.encode_s16(i * 2, int(x * 16000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = 22050
	w.stereo = false
	w.data = data
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = m
	return w


# ---- 판 ----
func _step(dt: float) -> void:
	if warp_menu and warp_menu.visible:
		return  # 구역 고르기 창이 떠 있는 동안 판을 멈춘다
	if warp_to > 0.0:
		_warp_tick()
	# 멈칫·느린 동작: 실제 초로 세고, 판 안의 dt 만 줄인다
	var real_dt := dt / maxf(Engine.time_scale, 0.05)
	if hs_t > 0.0:
		hs_t -= real_dt
		dt *= 0.04
	elif slo_t > 0.0:
		slo_t -= real_dt
		dt *= slo_k
	clock += dt
	if not won:
		run_elapsed += dt
	_fx(dt)
	_dust(dt)
	_zones_tick()
	_lane_tick(dt)
	s = lerpf(s, s_goal, minf(1.0, dt * 4.0))
	var mm := s / 2.0
	hurt -= dt
	cool -= dt
	dash_t -= dt
	shake = maxf(0.0, shake - dt * 2.5)
	_chunk(dt)
	if won:
		_ending_tick(dt)
		return
	if fallen:
		fall_t += dt
		vy -= FALL * dt
		by += vy * dt
		dist += v * dt
		v *= 0.98
		_place(dt)
		if fall_t > 1.1:
			end()
		return
	var hold := kit_held("hold")
	_gate_tick()
	_drum_tick(dt, hold)
	_current_tick(dt, hold)
	if kit_just("jump") and on_ground:
		vy = maxf(JUMP * 0.8, JUMP / pow(mm, 0.7))  # 커져도 뛰기는 뛰기답게
		by += 0.05
		on_ground = false
		sfx("jump", 0.0, 1.15 / pow(mm, 0.25))
	if kit_just("split"):
		_split()
	if kit_just("throw"):
		_throw()
	_shot(dt)
	_aim()
	if mode == "side" and not underground:  # 동굴 안에서는 등뒤 카메라라 좌우로 몬다
		x_goal = 0.0
	if on_ground:
		_pads(dt)
	# 큰 회전: 무거울수록 빠를수록 바깥으로 밀린다 (버티면 덜)
	var k := _curv(dist)
	if on_ground and absf(k) > 0.0005:
		x_goal += k * v * v * TURN_C * mm * (0.35 if hold else 1.0) * dt
	if underground:
		x_goal = clampf(x_goal, -5.0, 5.0)  # 지하 바닥판은 12m 폭
	bx = lerpf(bx, x_goal, minf(1.0, dt * 10.0 / sqrt(mm)))
	if dist < fork_rail_end and on_ground and not underground:
		var rw: float = float(pd.hw[_oi(pd, dist)]) - 0.6
		bx = clampf(bx, -rw, rw)
		x_goal = clampf(x_goal, -rw, rw)
	if on_ground:
		var sl := _slope(dist)
		if underground:
			sl += _tunnel_depth(dist) - _tunnel_depth(dist + 1.0)
		var f := 0.5 + 0.5 * sqrt(mm)
		if sl > 0.0:
			f = 0.35 + 0.65 * sqrt(mm)
		v += (-sl * GRV * f - ROLL - DRAG * v * v / mm) * dt
		if hold:
			v -= 20.0 * dt
		v = maxf(v, 0.0)
	else:
		v -= DRAG * 0.3 * v * v * dt
		if hold and not rising:
			v *= exp(-2.2 * dt)
			vy -= 46.0 * dt
	var d_prev := dist
	dist += v * dt
	vy -= FALL * dt
	by += vy * dt
	_hole_wall(d_prev)
	_edge_tick(dt)
	_geyser_tick()
	if cur_k == 1 and not tutorial and not underground and by < _h(dist) - 4.0:
		_fall("퐁당!")
	if not floor_cracks.is_empty() and hold and not on_ground and not underground and not fallen and vy < -10.0:
		_try_crack()
	var g := _ground(dist, bx)
	if is_nan(g):
		var i := _oi(pd, dist)
		if on_ground and pd.sol[i] == 0:
			if pd.tg[i] == "drop":
				sfx("fall", -4.0)
			else:
				sfx("jump", -2.0, 1.2)
		on_ground = false
		if by < _h(dist) - 4.0 and not won:
			_fall("퐁당!" if pd.sol[i] == 0 else "데구루루~")
	elif by <= g:
		# 지난 프레임에도 이미 땅보다 한참 아래였을 때만 턱에 박은 것 (빠른 착지가 한 프레임에 파고든 것은 착지)
		if by < g - 1.4 and by - vy * dt < g - 1.4 and not won:
			_fall("턱!")
		else:
			if not on_ground:
				if underground:
					if not deep_landed:
						# 90m 아래 첫 착지: 멈칫, 먼지 고리, 수정이 차례로 깨어나고, 이곳의 이름
						deep_landed = true
						_burst(_pos(dist, bx, g), DUST, 16, 12.0, 0.9)
						shake = 1.0
						sq = 0.4
						sfx("land", 2.0, 0.8)
						sfx("cave", -2.0)
						v = maxf(v, float(under_route[8]) if under_route.size() > 8 else 30.0)
						_hitstop(0.15, -12.0)
						_ring(_pos(dist, bx, g + 0.3), DUST, 16.0, 0.5)
						_wake(dist, 45.0, 60.0)
						var rname := str(under_route[7]) if under_route.size() > 7 else "낮잠자는 지하 신전"
						if rname == "낮잠자는 지하 신전":
							_plaque(rname, tr("지하 90m"), C, 2.2)
						else:
							_secret(rname)  # 숨은 방: 그곳 이름을 새긴 지명판
					else:
						# 지하에서 뛰고 내려앉기: 작은 착지 (_land 는 위 수로 항아리까지 깔아서 쓰지 않는다)
						sq = maxf(sq, clampf(-vy / 45.0, 0.0, 0.42))
						sfx("land", -10.0, 1.2)
						if vy < -14.0:
							_ring(_pos(dist, bx, g + 0.3), DUST, s * 1.6)
				else:
					_land(vy, hold)
					if sling_keep > 0.0:
						# 물기둥 새총 착지: 지하에서 달리던 속도를 돌려준다
						v = maxf(v, sling_keep)
						sling_keep = 0.0
			by = g
			vy = v * _slope(dist)
			on_ground = true
	else:
		on_ground = false
	if fallen:
		_place(dt)
		return
	# 깔기 / 부딪힘 (빠르게 떨어지는 중이면 무엇이든 깐다)
	var diving := not on_ground and vy < -12.0
	for th: Thing in things:
		if th.flat or warp_to > 0.0:  # 빨리 감는 동안은 부딪히지 않는다
			continue
		var dd := th.d - dist
		if absf(dd) > 14.0:
			continue
		var sz: Vector3 = th.kd.size
		if (th.kd == KIND.pillar or th.kd == KIND.post) and by < th.base + sz.y and by + s > th.base:
			# 기둥은 둥글다: 원과 원으로 맞닿음을 보고 그 면을 따라 튕긴다 (네모 판정은 모서리를 스치기만 해도 박혔다)
			var rel := Vector2(dist - th.d, bx - th.x)
			var rr := s * 0.5 + sz.x * 0.5
			if rel.length() < rr:
				_pillar_hit(th, rel, rr)
			continue
		if absf(dd) < (s + sz.z) * 0.5 and absf(th.x - bx) < (s + sz.x) * 0.45 and by < th.base + sz.y * 0.8 and by + s > th.base:
			if th.kd == KIND.wall and not on_ground and by > th.base + sz.y * 0.3:
				# 담 위쪽 모서리만 스쳤다: 넉백하지 않고 담 위로 넘겨 준다
				by = maxf(by, th.base + sz.y + 0.05)
				vy = maxf(vy, 3.0)
				continue
			var need: float = th.kd.need
			var slam: bool = th.kd.get("slam", false)
			var dive_ok: bool = diving and not th.kd.get("nodive", false) and (hold if slam else need < 90.0)
			# 쪼갠 직후 돌진: 크기가 모자라도 집·석상·얼음벽을 뚫고, 느려지지 않는다 (수정·담·탑은 안 됨)
			var dash_ok: bool = dash_t > 0.0 and not slam and not th.kd.has("shot") and need < 90.0
			# 숨은 길 돌문·얼음판: 이 속도(게이지 금빛 눈금) 이상이면 몸으로 뚫고 느려지지 않는다
			var ram_ok: bool = v >= float(th.kd.get("ram", 999.0))
			if s_goal >= need or dive_ok or dash_ok or ram_ok:
				_crush(th, mm, not diving and not dash_ok and not ram_ok)
			elif th.kd == KIND.roof:
				# 버티기 없이 지붕에 닿았다: 죽이지 않고 지붕 위로 굴러 넘는다. 기와에 긁혀 크게 느려질 뿐
				by = maxf(by, th.base + sz.y + 0.02)
				vy = maxf(vy, 0.0)
				on_ground = true
				if not th.has_meta("rode"):
					th.set_meta("rode", true)
					v = clampf(v * 0.45, VSTOP + 3.0, maxf(v, VSTOP + 3.0))
					shake = 0.3
					sfx("crush_s", -2.0, 0.7)
					_stamp(tr("드르륵"), 2, _pos(dist + s, bx, by + s), GLYPH, 1.0)
					msg("기와에 긁혀 느려졌다\n떨어질 때 버티기 = 깨고 가속", 1.4)
			elif hurt <= 0.0 and bump_t <= 0.0:
				_bonk(th)
			elif bool(th.kd.get("soft", false)):
				# 봉인은 밀려나는 동안만 막는다 (속도는 그대로: 멈춤 탈락으로 이어지지 않게)
				dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
			elif th.kd.get("nodive", false) or slam:
				# 얼음벽·수정은 진짜 벽: 튕긴 뒤에도 못 지나간다
				dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
				v = minf(v, 3.0)
	_rocks(dt, mm)
	if underground:
		_gems()
		_wake(dist + 6.0, 10.0)
	# 멈춤 검사: 땅이나 땅 가까운 공중(튕기는 중)에서 느리면, 또는 2.5초 동안 3m 도 못 나아가면(같은 벽에 계속 박힘)
	var gg := _ground(dist, bx)
	var near := on_ground or (not is_nan(gg) and by - gg < 6.0)
	if dist > stall_d + 3.0 or rising or wind_on or won or not near:
		stall_d = dist
		stall_t = 0.0
	else:
		stall_t += dt
	if near and (v < VSTOP or stall_t > 2.5) and not won and not rising and not wind_on:
		slow_t += dt
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = 0.3
			sfx("warn", -4.0)
		if slow_t > STOP_T:
			failure_reason = bonk_why if clock - bonk_at < 2.2 else tr("털썩…")
			end()
			return
	else:
		slow_t = 0.0
		warn_t = 0.0
	if goal_d > 0.0 and dist >= goal_d and not won:
		if tutorial:
			_tutorial_done()
			return
		_finish()
	score = score_base + int(dist) + bonus
	var col := GOOD
	if v < VSTOP:
		col = BAD
	elif v < VSTOP * 1.8:
		col = D
	_ram_gauge()
	gauge(v / VMAX, col)
	_place(dt)


## 설산: 흰 눈 줄 위면 커지고, 노란 길 위면 녹아 작아진다 (지나간 거리만큼)
func _pads(dt: float) -> void:
	pad_t -= dt
	for pp: Array in pads:
		if dist > float(pp[0]) and dist < float(pp[1]) and bx > float(pp[2]) and bx < float(pp[3]):
			var before := floori(s_goal * 2.0)
			if pp[4] == "snow":
				s_goal = minf(SMAX, s_goal + SNOW_GROW * v * dt)
				v -= 1.5 * dt
				if pad_t <= 0.0:
					pad_t = 0.09
					_burst(_pos(dist - s * 0.4, bx + randf_range(-0.5, 0.5) * s, by + 0.2), WHITE, 2, 5.0, 0.6)
				if not snow_told:
					snow_told = true
					guide("눈 위를 구르면\n몸이 커진다!")
				if floori(s_goal * 2.0) > before:
					sfx("snow", -6.0)
					sq = maxf(sq, 0.22)
			else:
				s_goal = maxf(2.0, s_goal - SUN_MELT * v * dt)
				if pad_t <= 0.0:
					pad_t = 0.12
					_burst(_pos(dist, bx, by + s * 0.6), WATER, 1, 4.0, 0.4)
				if floori(s_goal * 2.0) < before:
					sfx("melt", -8.0)
			return


## 던지기: 크기 1을 떼어 앞으로 던진다. 수정은 이것으로만 깨진다.
func _throw() -> void:
	if cool > 0.0 or shot_t > 0.0:
		return
	if s_goal < 2.6:
		msg("너무 작다", 0.5)
		sfx("warn", -6.0, 1.4)
		return
	s_goal = maxf(2.0, s_goal - 1.0)
	cool = 0.4
	shot_d = dist + s * 0.5 + 0.8
	shot_x = bx
	shot_v = v * 1.5 + 30.0
	shot_t = _throw_range() / shot_v
	shot_hit = false
	shot.visible = true
	sq = maxf(sq, 0.18)
	sfx("throw")


func _shot(dt: float) -> void:
	if shot_t <= 0.0:
		return
	shot_t -= dt
	shot_d += shot_v * dt
	shot.position = _pos(shot_d, shot_x, _h(shot_d) + 1.7)
	shot.scale = Vector3.ONE * (1.0 + 0.15 * sin(shot_t * 40.0))  # 두근거리며 날아가 눈에 띈다
	if fmod(shot_t, 0.035) < dt:
		_burst(shot.position, G_TOP, 3, 3.0, 0.8)  # 날아가는 길에 금빛 부스러기 (멀리서도 보이게 굵고 오래)
	shot.rotation = Vector3(-shot_d * 1.4, _yaw(shot_d), 0.0)
	for th: Thing in things:
		if th.flat:
			continue
		var sz: Vector3 = th.kd.size
		if absf(th.d - shot_d) < sz.z * 0.5 + 1.0 and absf(th.x - shot_x) < (1.4 + sz.x) * 0.45:
			if th.kd.get("shot", false):
				# 수정 줄은 맞은 자리 둘레가 함께 깨져 돌이 지나갈 틈이 난다
				for t2: Thing in things:
					if not t2.flat and t2.kd.get("shot", false) and absf(t2.d - th.d) < 0.5 and absf(t2.x - shot_x) < 6.0:
						_smash(t2)
				play("good")
				shake = maxf(shake, 0.3)
				shot_t = 0.0
				shot_hit = true
			elif float(th.kd.need) < 90.0 and not th.kd.get("nodive", false):
				_smash(th)
			else:
				shot_t = 0.0
				shot_hit = true
				_burst(shot.position, ME, 4, 6.0)
			break
	if shot_t <= 0.0 or shot_d > _len() - 1.0:
		if shot_t <= 0.0 and not shot_hit:
			# 닿기 전에 떨어졌다: 몸만 작아졌다
			_burst(shot.position, ME, 4, 5.0)
			sfx("bonk", -8.0, 1.5)
			msg("안 닿았다!\n더 빨리, 더 가까이", 0.8)
		shot_t = 0.0
		shot.visible = false


## 던지는 거리: 구르는 속도에 비례한다 (점선 길이 = 이 거리)
func _throw_range() -> float:
	return 20.0 + v * 1.8


## 조준: 90m 안 가장 가까운 수정까지 땅에 점선, 수정 위에 깨질 너비 막대.
## 초록 = 지금 던지면 닿는다, 노랑 = 아직 멀다(더 빨리 또는 더 가까이), 빨강 = 몸이 너무 작다.
func _aim() -> void:
	var tgt: Thing = null
	if _btns.has("throw") and not fallen and not won:
		for th: Thing in things:
			if th.flat or not th.kd.get("shot", false):
				continue
			var dd := th.d - dist
			if dd > 0.0 and dd < 90.0 and (tgt == null or th.d < tgt.d):
				tgt = th
	if tgt == null:
		for n: MeshInstance3D in aim_dots:
			n.visible = false
		aim_bar.visible = false
		for n: MeshInstance3D in aim_legs:
			n.visible = false
		aim_ok = false
		if _btns.has("throw"):
			_btns["throw"].color = A
		return
	var sz: Vector3 = tgt.kd.size
	var gap := tgt.d - sz.z * 0.5 - dist
	var reach := gap <= _throw_range()
	var big := s_goal >= 2.6
	var col := GOOD if reach else D
	if not big:
		col = BAD
	var a := dist + s * 0.5 + 1.0
	var e := dist + minf(_throw_range(), gap)
	var dot_m := _shard_mat("chip", col)
	var bar_m := _pm("chip", col)
	for i in aim_dots.size():
		var n: MeshInstance3D = aim_dots[i]
		var dd := lerpf(a, e, (i + 0.5) / aim_dots.size())
		n.visible = dd < e and shot_t <= 0.0
		n.position = _pos(dd, bx, _h(dd) + 0.12)
		n.rotation.y = _yaw(dd)
		n.material_override = dot_m
	# 막대: 덩이가 맞으면 열리는 틈 너비 (돌이 지금 있는 옆 위치 기준)
	var top := tgt.base + sz.y + 1.6 + 0.3 * sin(clock * 9.0)
	var yw := _yaw(tgt.d)
	aim_bar.visible = true
	aim_bar.position = _pos(tgt.d, bx, top)
	aim_bar.rotation.y = yw
	aim_bar.material_override = bar_m
	for i in 2:
		var n: MeshInstance3D = aim_legs[i]
		n.visible = true
		n.position = _pos(tgt.d, bx + (-4.0 if i == 0 else 4.0), top - 0.8)
		n.rotation.y = yw
		n.material_override = bar_m
	var ready := reach and big and shot_t <= 0.0
	_btns["throw"].color = GOOD if ready else (A if big else BAD)
	if ready and not aim_ok:
		aim_ok = true
		sfx("tick", -4.0, 1.5)
	elif not reach:
		aim_ok = false


## 덩이에 맞아 부서짐: 점수만, 커지지 않는다
func _smash(th: Thing) -> void:
	th.flat = true
	th.n.visible = false
	bonus += int(th.kd.pts) * 5
	_score_chip(th.n.global_position, th.col)
	_burst(th.n.position, th.shard_tint, 8, 11.0, 0.7, th.shard)
	sfx("glass" if th.kd.has("shot") else "crush_s", 7.0 if th.kd.has("shot") else 0.0)


## 착지: 높이 떨어질수록(버티면 더) 넓게 부순다
func _land(vy0: float, hard: bool) -> void:
	sq = maxf(sq, clampf(-vy0 / 45.0, 0.0, 0.42))
	if vy0 < -10.0:
		_burst(_pos(dist, bx, by + 0.2), _dust_col(), 3 + int(-vy0 / 8.0), 4.0 + -vy0 * 0.25)
	if vy0 > -14.0:
		if vy0 < -7.0:
			sfx("land", -12.0, 1.3)
		return
	var r := s * 0.6 + (-vy0) * 0.09 + (2.5 if hard else 0.0)
	var n := 0
	for th: Thing in things:
		var slam: bool = th.kd.get("slam", false)
		if th.flat or th.kd.get("nodive", false) or (slam and not hard) or (not slam and float(th.kd.need) > 90.0):
			continue
		var sz: Vector3 = th.kd.size
		if absf(th.d - dist) < r + sz.z * 0.5 and absf(th.x - bx) < r + sz.x * 0.5:
			_crush(th, s / 2.0, false)
			n += 1
	if vy0 < -20.0:
		v *= 0.9
	shake = minf(1.2, 0.2 + (-vy0) / 50.0 + n * 0.15)
	# 무거운 착지: 땅색 고리, 여럿 깔면 멈칫, 아주 높은 데서면 쿠웅! 돌판
	if vy0 < -14.0:
		_ring(_pos(dist, bx, by + 0.3), _dust_col(), s * 1.6 + -vy0 * 0.08)
	if n >= 2 or vy0 < -34.0:
		_hitstop(minf(0.1, 0.04 + n * 0.015), -6.0)
	if not underground and vy0 < -30.0 and (n >= 2 or vy0 < -40.0):
		_stamp("쿠웅!", 3, _pos(dist, bx, by), GLYPH, 0.9)
	sfx("land", minf(0.0, -12.0 - vy0 * 0.3), clampf(1.25 - s * 0.06, 0.8, 1.2))


func _crush(th: Thing, mm: float, slow := true) -> void:
	var top_p: Vector3 = th.n.global_position + Vector3.UP * float(th.kd.size.y) * 0.6
	th.flat = true
	var sz: Vector3 = th.kd.size
	_burst(th.n.position, th.shard_tint, 3 + int(sz.y), 6.0 + sz.y, clampf(sz.y * 0.25, 0.4, 1.0), th.shard)
	sq = maxf(sq, 0.1 + float(th.kd.mass) * 0.5)
	if th.kd.get("nodive", false):
		th.n.visible = false
	else:
		th.n.scale.y = 0.15
		th.n.position.y = th.base + 0.08
	if slow:
		v *= mm / (mm + float(th.kd.mass))
	if th.kd.has("boost"):
		v = maxf(v, minf(VMAX + 10.0, v + float(th.kd.boost)))
		_burst(th.n.position + Vector3.UP * 2.0, B, 10, 14.0, 0.9)
	var before := floori(s_goal)
	s_goal = minf(SMAX, s_goal + float(th.kd.grow))
	bonus += int(th.kd.pts) * 5
	shake = maxf(shake, 0.1 + float(th.kd.mass))
	sfx("crush_big" if th.kd.get("slam", false) else ("glass" if th.kd.get("nodive", false) else ("crush_s" if float(th.kd.size.y) < 2.0 else "crush_m")), 7.0 if th.kd.get("nodive", false) else (-2.0 if float(th.kd.size.y) < 2.0 else 0.0), randf_range(0.9, 1.12))
	if th.kd.get("slam", false):
		# 탑·신상 내려찍기: 멈칫 + 고리 + 새긴 돌판
		var gold: bool = th.kd == KIND.gold
		_hitstop(0.13 if gold else 0.09, -10.0)
		_ring(th.n.global_position + Vector3.UP * 0.3, D if gold else B.lightened(0.5), 7.0 + float(th.kd.size.x))
		if gold:
			_stamp("번쩍!", 5, top_p, D.darkened(0.6), 1.15, 0.45, D.lightened(0.55))
		else:
			_stamp("와르르!", 4, top_p)
	else:
		_score_chip(top_p, th.col.lerp(STONE, 0.3))
	if floori(s_goal) > before:
		play("good")


## 기둥에 맞닿음: 맞은 면 바깥으로 밀어내고, 들어오던 속도를 그 면에 비춰 되튕긴다.
## 정면이면 뒤로 튀며 크게 느려지고, 비스듬하면 옆으로 미끄러지며 조금만 느려진다. 붉은 깜빡임·찌그러짐 없음.
func _pillar_hit(th: Thing, rel: Vector2, rr: float) -> void:
	var n := rel.normalized() if rel.length() > 0.01 else Vector2(-1.0, 0.0)
	var vel := Vector2(v, (x_goal - bx) * 4.0)
	var vn := vel.dot(n)
	dist = th.d + n.x * (rr + 0.05)
	bx = th.x + n.y * (rr + 0.05)
	if vn >= 0.0:
		return  # 이미 떨어지는 중: 밀어내기만
	vel -= 1.5 * vn * n  # 반발 0.5
	var lat := vel.y
	if absf(n.y) < 0.2:
		# 거의 정면: 둥근 면이라 어느 한쪽으로 미끄러져 나간다 (한가운데 박혀 멈추지 않게)
		var side := signf(n.y) if absf(n.y) > 0.01 else (1.0 if int(th.d) % 2 == 0 else -1.0)
		lat += side * maxf(6.0, -vn * 0.4)
	# 그쪽에 빠져나갈 자리가 없으면(용암 가장자리·길 끝) 반대로 미끄러진다
	var room_w := _cave_hw(dist) if underground and cave_span.size() >= 2 else float(pd.hw[_oi(pd, dist)])
	if room_w - absf(bx) < s * 0.6 and signf(lat) == signf(bx):
		lat = -lat
	# 뒤로 튀지 않는다: 들어온 속도의 대부분을 옆으로 미끄러지며 지나간다 (정면일수록 조금 더 잃는다)
	v = maxf(v * lerpf(0.95, 0.7, absf(n.x)), minf(v, VSTOP + 2.0))
	x_goal = bx + signf(lat) * maxf(absf(lat) * 0.3, rr * 0.6)
	if -vn > 6.0 and bump_t <= 0.0:
		bump_t = 0.3
		shake = clampf(-vn / 40.0, 0.2, 0.7)
		_hitstop(0.05)
		sfx("bonk", -2.0 + clampf(-vn / 10.0, 0.0, 3.0), randf_range(0.9, 1.1))
		_burst(_pos(th.d + n.x * _pillar_r(th), th.x + n.y * _pillar_r(th), by + s * 0.5), th.shard_tint, 5, 7.0, 0.5, th.shard)
		bonk_at = clock
		bonk_why = "쿵!"


func _pillar_r(th: Thing) -> float:
	return float((th.kd.size as Vector3).x) * 0.5


func _bonk(th: Thing) -> void:
	var sz: Vector3 = th.kd.size
	if bool(th.kd.get("soft", false)):
		# 숨은 길 봉인을 못 열었다: 조금 느려지고 큰길 쪽으로 밀려날 뿐 (멈춤 탈락 까닭이 되지 않는다)
		v = maxf(v * 0.75, minf(v, VSTOP + 4.0))
		dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
		hurt = 0.5
		x_goal = th.x + signf(-th.x) * ((s + sz.x) * 0.45 + 0.6)
		shake = 0.4
		sq = 0.0
		_burst(_pos(dist + s * 0.5, bx, by + s * 0.5), th.shard_tint, 4, 6.0, 0.5, th.shard)
		play("bad")
		if th.kd.has("shot"):
			msg("수정은 던져서!", 0.8)
		elif th.kd == KIND.icedoor:
			msg("더 커지거나\n직전에 쪼개서 돌진!", 0.9)
		else:
			msg("쪼개서 돌진!\n아니면 더 빨리", 0.9)
		return
	v *= 0.3
	dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
	hurt = 0.5
	bonk_at = clock
	bonk_why = "쿵!" if float(th.kd.need) < 90.0 else "쾅!"
	shake = 0.6
	_hitstop(0.05)
	sq = 0.0  # 부딪혀도 말랑하게 찌그러지지 않는다
	_burst(_pos(dist + s * 0.5, bx, by + s * 0.5), th.shard_tint, 4, 6.0, 0.5, th.shard)
	play("bad")
	if th.kd.has("shot"):
		msg("수정은 던져서!", 0.8)
		bonk_why = "띵!"
	elif th.kd.get("slam", false):
		msg("위에서 버티기로 쾅!", 0.9)
		bonk_why = "꽝!"
	elif th.kd == KIND.ice and _btns.has("split"):
		msg("더 커지거나\n직전에 쪼개서 돌진!", 0.9)
		bonk_why = "쩡!"
	elif th.kd.get("nodive", false):
		msg("더 커져야!", 0.8)
		bonk_why = "쿵!"


## 쪼개기: 한 덩이 떼어 버리고 그만큼 가볍고 빨라진다. 떼어낸 덩이는 뒤로 굴러 뒤에서 오는 돌을 막는다.
func _split() -> void:
	if cool > 0.0:
		return
	if s_goal < 2.6:
		msg("더 못 쪼갠다", 0.5)
		sfx("warn", -6.0, 1.4)
		return
	s_goal = maxf(2.0, s_goal - 1.0)
	v += 13.0
	dash_t = DASH_T
	cool = 0.6
	chunk.visible = true
	chunk_d = dist - s * 0.5
	chunk_x = bx
	chunk_t = 1.2
	shake = maxf(shake, 0.3)
	sq = maxf(sq, 0.22)
	_burst(_pos(dist - s * 0.5, bx, by + 1.0), STONE, 5, 7.0)
	sfx("split")
	_hitstop(0.05, 12.0)
	if s_goal >= 3.0 and not tutorial:
		_stamp("쩌억!", 2, _pos(dist, bx, by + s), C.darkened(0.45), 0.75, 0.08)
	for rk: Dictionary in rocks:
		if rk.on and rk.d < dist and dist - float(rk.d) < 45.0 and absf(float(rk.x) - bx) < 4.0:
			rk.on = false
			(rk.n as MeshInstance3D).visible = false
			play("good")
			break


func _chunk(dt: float) -> void:
	if chunk_t <= 0.0:
		return
	chunk_t -= dt
	chunk_d -= 9.0 * dt
	chunk.position = _pos(chunk_d, chunk_x, _h(chunk_d) + 0.65)
	chunk.rotation = Vector3(chunk_t * 8.0, _yaw(chunk_d), 0.0)
	if chunk_t <= 0.0:
		chunk.visible = false


## 해안: 뒤에서 더 빠르게 굴러오는 돌. 나보다 작으면(노랑) 받아 커지고 빨라진다, 크면(빨강) 부딪혀 튕긴다.
func _rocks(dt: float, mm: float) -> void:
	if rock_a < 0.0:
		return
	if dist > rock_a and dist < rock_b and not won:
		rock_t -= dt
		if rock_t <= 0.0:
			rock_t = 1.4
			for rk: Dictionary in rocks:
				if not rk.on:
					rk.on = true
					rk.r = ROCK_R[rock_i % ROCK_R.size()]
					rk.x = ROCK_X[rock_i % ROCK_X.size()]
					rk.d = dist - 38.0
					rk.v = maxf(v + 10.0, 30.0)
					rk.a = 0.0
					(rk.n as MeshInstance3D).visible = true
					rock_i += 1
					sfx("rumble", -3.0)
					break
	for rk: Dictionary in rocks:
		if not rk.on:
			continue
		var n: MeshInstance3D = rk.n
		var r: float = rk.r
		rk.d += float(rk.v) * dt
		rk.a += float(rk.v) * dt / r
		if rk.d > dist + 35.0 or rk.d > _len() - 1.0:
			rk.on = false
			n.visible = false
			continue
		var rd: float = rk.d
		n.position = _pos(rd, rk.x, _h(rd) + r * 0.5)
		n.rotation = Vector3(-float(rk.a), _yaw(rd), 0.0)
		n.scale = Vector3.ONE * r
		# 쫓아오는 돌은 내 돌과 다른 그림: 금빛 모래돌=받기, 붉은 테라코타=위험
		var rkm := _pm("sand") if s_goal >= r else _pm("roof", Color("ff8a7a"))
		n.material_override = rkm
		(n.get_child(0) as MeshInstance3D).material_override = rkm
		if absf(rd - dist) < (s + r) * 0.5 and absf(float(rk.x) - bx) < (s + r) * 0.45 and by < _h(rd) + r:
			rk.on = false
			n.visible = false
			if s_goal >= r:
				s_goal = minf(SMAX, s_goal + r * 0.1)
				v += maxf(0.0, float(rk.v) - v) * 0.5
				bonus += int(r * 10.0)
				_score_chip(n.global_position, D)
				sfx("catch")
			else:
				v *= 0.6
				x_goal += (3.5 if bx >= float(rk.x) else -3.5) / sqrt(mm)
				hurt = 0.5
				shake = 0.8
				play("bad")


func _fall(text: String) -> void:
	# 밑에 열린 지하(수로 밑 신전, 깨고 들어간 숨은 방)가 있으면 떨어져도 이어진다. 닫힌 방은 0 이라 보통 추락은 그대로 탈락
	if not underground and _tunnel_depth(dist) > 0.0:
		underground = true
		on_ground = false
		x_goal = 0.0
		for route: Array in tunnels:
			if bool(route[6]) and dist >= float(route[0]) and dist < float(route[1]):
				under_route = route.duplicate()
				break
		sfx("fall", 0.0, 0.8)
		deep_landed = false
		_cave(true)
		if cave_span.size() >= 2:
			_wake(dist + 30.0, 70.0, 60.0)  # 떨어지는 동안 아래 수정이 먼저 깨어나 굴을 비춘다
		return
	sling_keep = 0.0
	if ram_tick:
		ram_tick.visible = false
	fallen = true
	failure_reason = text
	Engine.time_scale = 1.0  # 튜토리얼 문(0.2배)에서 떨어져도 떨어지는 장면은 제 속도로
	fall_t = 0.0
	v = minf(v, 6.0)
	sfx("fall")
	# 떨어지는 순간이 느리게 보인다 (카메라는 _place 에서 아래로 내려다본다)
	_slowmo(0.7, 0.4)


func _place(dt: float) -> void:
	ang += v * dt * PI / (2.0 * s)
	var m := fposmod(ang, PI * 0.5)
	var yw := _yaw(dist)
	# 찌그러짐: 착지·깔기에 납작, 공중에선 위아래로 늘고, 빠르면 앞뒤로 늘어난다
	var air := 0.0 if on_ground else clampf(absf(vy) / 110.0, 0.0, 0.16)
	var fast := clampf((v - 30.0) / 160.0, 0.0, 0.12) if on_ground else 0.0
	pivot.position = _pos(dist, bx, by + s * 0.5 * (cos(m) + sin(m)) - s * 0.5 * sq)
	pivot.rotation = Vector3(0.0, yw, 0.0)
	pivot.scale = Vector3(1.0 + sq * 0.55 - air * 0.5 - fast * 0.4, 1.0 - sq + air, 1.0 + sq * 0.3 - air * 0.5 + fast)
	ball.rotation = Vector3(-ang, 0.0, 0.0)
	# 느려지면 무거운 돌이 좌우로 비틀거린다 (곧 멈출 것 같은 무게)
	if on_ground and not won and not fallen and v < VSTOP * 1.8:
		ball.rotation.z = sin(clock * 16.0) * 0.07 * clampf((VSTOP * 1.8 - v) / VSTOP, 0.0, 1.0)
	ball.scale = Vector3.ONE * s
	_streaks(dt, yw)
	bump_t -= get_process_delta_time()
	ball.material_override = art_materials["stone"]
	if dash_t > 0.0 and hurt <= 0.0 and fmod(dash_t, 0.16) < 0.08:
		ball.material_override = _art_mat("stone", C.lightened(0.3))  # 돌진 중: 쪼개기 색으로 물든 돌 그림이 깜빡
	var q := floori(ang / (PI * 0.5))
	roll_t -= dt
	if q != quarter:
		quarter = q
		if roll_t <= 0.0 and on_ground and not fallen:
			roll_t = 0.07
			sfx("roll", -10.0 + minf(6.0, v * 0.12), clampf(1.35 - s * 0.08, 0.7, 1.3))
	# 카메라: 구역마다 구도가 다르다 (돌 기준 거리만 부드럽게 옮겨 간다)
	if blob:
		_blob_tick(yw)
	# 90m 낙하: 처음엔 카메라가 늦게 따라가 돌이 멀어지고, 바닥이 가까울수록 빨리 따라붙는다
	var plunge := underground and not on_ground and not rising and vy < -2.0 and not fallen
	if plunge and cave_span.size() >= 2 and by < _h(dist) - _tunnel_depth(dist) + 22.0:
		plunge = false  # 동굴 천장 아래로 들어오면 옆 카메라는 벽에 가린다: 등뒤로
	if not fallen:
		var rate := 6.0
		if plunge:
			var dp := maxf(_tunnel_depth(dist), 1.0)
			var ff := clampf(1.0 - (by - (_h(dist) - dp)) / dp, 0.0, 1.0)
			rate = lerpf(1.2, 9.0, ff * ff)
		cam_y = lerpf(cam_y, by, minf(1.0, dt * rate))
		if plunge:
			cam_y = minf(cam_y, by + 30.0)
	var fw := Vector3(-sin(yw), 0.0, -cos(yw))
	var rt := Vector3(cos(yw), 0.0, -sin(yw))
	var c := _pos(dist, bx, cam_y)
	var off := Vector3.ZERO
	var look := Vector3.ZERO
	var up := Vector3.UP
	var fov := 55.0
	# 지하에서는 위에서 내려다보는 카메라가 길 판 위에 걸리므로 낮은 등뒤로
	match ("low" if underground and (mode != "side" or cave_span.size() >= 2) else mode):
		"side":
			off = rt * (34.0 + v * 0.4 + s * 1.5) + fw * (8.0 + v * 0.12) + Vector3.UP * (3.0 + s * 0.5)
			look = fw * (12.0 + v * 0.2) + Vector3.UP * (1.0 + s * 0.4)
			fov = 55.0 + v * 0.15
		"fall":
			off = -fw * (9.0 + s) + Vector3.UP * (15.0 + s * 1.5)
			look = _pos(dist + 14.0 + v * 0.2, bx * 0.5, cam_y - 4.0) - c
			fov = 60.0 + v * 0.3
		"top":
			off = fw * 8.0 + Vector3.UP * (44.0 + s * 2.0 + v * 0.15)
			look = fw * 8.0
			up = fw
			fov = 54.0
		"front":
			off = rt * (38.0 + v * 0.25) - fw * 8.0 + Vector3.UP * (25.0 + s)
			look = fw * (10.0 + v * 0.15)
			fov = 60.0 + v * 0.25
		"iso":
			# 비스듬히 위 오른쪽 뒤: 눈 줄과 녹는 길이 한눈에
			off = -fw * (13.0 + s * 1.2) + rt * (12.0 + s) + Vector3.UP * (19.0 + s * 1.6)
			look = fw * (12.0 + v * 0.15) - rt * bx * 0.3
			fov = 52.0 + v * 0.2
		"low":
			# 땅에 붙은 낮은 등뒤: 다리 폭과 수정 줄이 눈앞에
			off = -fw * (6.0 + s * 1.5) + Vector3.UP * (6.0 + s * 1.1)
			look = _pos(dist + 22.0 + v * 0.2, bx * 0.6, cam_y + s * 0.5) - c
			fov = clampf(66.0 + v * 0.5, 66.0, 100.0)
		_:
			off = -fw * (8.0 + s * 2.0 + v * 0.1) - rt * bx * 0.4 + Vector3.UP * (3.2 + s * 1.3)
			look = _pos(dist + 20.0 + v * 0.25, bx * 0.5, cam_y + s * 0.4 - 1.5) - c
			fov = clampf(52.0 + v * 0.55, 52.0, 90.0)
	if plunge:
		# 옆에서 길게: 돌은 화면 위 가운데, 아래로 잠든 도시가 달려든다
		var lag := cam_y - by
		if cave_span.size() >= 2:
			# 동굴 맵: 뒤 위에서 천장 틈 아래로 내려다본다 (깨어나는 수정과 굴 바닥이 달려든다)
			off = -fw * 9.0 + Vector3.UP * (8.0 + lag * 0.2)
			look = Vector3.UP * (by - cam_y - 24.0) + fw * (10.0 + v * 0.2)
			up = fw
			fov = 72.0
		else:
			off = rt * (30.0 + lag * 0.6) - fw * 4.0 + Vector3.UP * (2.0 + lag * 0.15)
			look = Vector3.UP * (by - cam_y - 8.0) + fw * (4.0 + v * 0.1)
			up = (Vector3.UP + rt * 0.12).normalized()
			fov = 70.0
	elif rising and by < _h(dist) - 2.0:
		# 물기둥: 아래에서 올려다본다
		off = rt * 16.0 - fw * 8.0 + Vector3.UP * -6.0
		look = Vector3.UP * (by - cam_y + 14.0) + fw * 6.0
		fov = 74.0
	if reveal_t > 0.0:
		# 솟아오른 뒤: 넓게 물러나 수로와 아래 협곡을 한 번 보여 준다
		reveal_t -= dt
		var r := clampf(reveal_t / 1.4, 0.0, 1.0)
		off = off.lerp(rt * 48.0 - fw * 4.0 + Vector3.UP * 16.0, r)
		look = look.lerp(fw * 20.0 + Vector3.UP * -4.0, r)
		fov = lerpf(fov, 66.0, r)
	if fallen:
		# 실패: 제자리에서 떨어지는 돌을 내려다본다
		look = Vector3.UP * (by - cam_y) * 0.75 + fw * 4.0
		fov = 44.0
	var kk :=minf(1.0, dt * (5.0 if mode == "back" else 3.5)) if dt > 0.0 else 1.0
	if look_soft > 0.0:
		look_soft -= dt
		kk *= lerpf(1.0, 0.3, clampf(look_soft / 1.2, 0.0, 1.0))  # 갈래를 고른 직후: 새 길 쪽으로 천천히 돈다
	cam_off = cam_off.lerp(off, kk)
	look_off = look_off.lerp(look, minf(1.0, kk * 1.4))
	cam_up = cam_up.lerp(up, minf(1.0, dt * 3.0)).normalized()
	var jit := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.7
	cam.position = c + cam_off + jit
	var tgt := c + look_off
	var dv := tgt - cam.position
	if dv.length() > 0.1:
		var u := cam_up
		var dn := dv.normalized()
		if absf(dn.dot(u)) > 0.97:
			u = fw if absf(dn.dot(fw)) < 0.9 else Vector3.UP
		cam.look_at(tgt, u)
	cam.fov = lerpf(cam.fov, fov, minf(1.0, dt * 2.5))
	if far:
		far.position = Vector3(cam.position.x, c.y - 10.0, cam.position.z)


## 바람 줄: 빠를 때 돌 둘레를 스쳐 뒤로 날아가는 가는 흰 상자
## 협곡으로 곧게 떨어질 때는 세로 줄: 지층을 스치며 위로 솟구친다 (물기둥을 탈 때는 물빛)
func _streaks(dt: float, yw: float) -> void:
	var plunge := underground and not on_ground and absf(vy) > 18.0 and not fallen
	var spd := clampf((v - 22.0) / 33.0, 0.0, 1.0)
	if dash_t > 0.0:
		spd = maxf(spd, 0.8)
	var on := plunge or ((v > 26.0 or dash_t > 0.0) and mode != "top" and not fallen)
	var count := 14 if plunge else int(lerpf(5.0, 14.0, spd))
	for i in streaks.size():
		var sk: Dictionary = streaks[i]
		var n: MeshInstance3D = sk.n
		if not on or i >= count:
			n.visible = false
			continue
		var was_p: bool = sk.get("p", false)
		if plunge:
			sk.y = float(sk.y) - vy * 0.85 * dt
			var gone: bool = (float(sk.y) > 16.0) if vy < 0.0 else (float(sk.y) < -16.0)
			if gone or not was_p:
				var sy := randf_range(-22.0, -12.0) if vy < 0.0 else randf_range(12.0, 22.0)
				if not was_p:
					sy = randf_range(-22.0, 16.0) * (1.0 if vy < 0.0 else -1.0)  # 처음엔 위아래로 고루
				sk.y = sy
				sk.x = bx + (1.0 if randf() < 0.5 else -1.0) * (s * 0.5 + randf_range(1.5, 7.0))
				sk.d = randf_range(-6.0, 8.0)
			sk.p = true
			n.visible = true
			var vl := clampf(absf(vy) * 0.12, 2.0, 10.0)
			_wind_place(n, _pos(dist + float(sk.d), float(sk.x), by + s * 0.5 + float(sk.y)), Vector3.DOWN if vy < 0.0 else Vector3.UP, vl, vl * 0.28)
			continue
		sk.p = false
		sk.d = float(sk.d) - v * (0.7 + spd * 0.5) * dt
		if float(sk.d) < -10.0 or was_p:
			sk.d = randf_range(18.0, 34.0) if not was_p else randf_range(-8.0, 30.0)
			var sd := 1.0 if randf() < 0.5 else -1.0
			sk.x = bx + sd * (s * 0.5 + randf_range(1.0, 5.0))
			sk.y = randf_range(0.4, s + 3.0)
		var d := dist + float(sk.d)
		n.visible = true
		var wp := _pos(d, float(sk.x), _h(d) - (_tunnel_depth(d) if underground else 0.0) + float(sk.y)) if on_ground else _pos(d, float(sk.x), by + float(sk.y) - s * 0.5)
		var wy := _yaw(d)
		var wl := clampf((v - 20.0) * 0.2, 1.2, 10.0)
		_wind_place(n, wp, Vector3(-sin(wy), 0.0, -cos(wy)), wl, wl * 0.26)



# ---- 바람: 흰 줄 대신 붓으로 쓸고 간 모래 바람결 그림 (art/boulder/fx_gpt/wind_*.png, Codex GPT) ----
var wind_mats: Array = []
var wind_quad: QuadMesh


func _wind_node(parent: Node) -> MeshInstance3D:
	if wind_quad == null:
		wind_quad = QuadMesh.new()
		wind_quad.orientation = PlaneMesh.FACE_X  # YZ 평면: 길이는 Z(진행 방향), 높이는 Y
		wind_quad.size = Vector2(1.0, 1.0)
		for i in 4:
			var m := StandardMaterial3D.new()
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
			m.albedo_texture = load(ART_ROOT + "fx_gpt/wind_%d.png" % i) as Texture2D
			m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			wind_mats.append(m)
	var n := MeshInstance3D.new()
	n.mesh = wind_quad
	n.material_override = wind_mats[randi() % 4]
	n.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(n)
	return n


## 바람결 하나를 p 에 진행 방향 f 로 놓고, 카메라 쪽으로 면을 돌린다 (어느 시점에서도 옆면이 아니라 붓자국으로 보이게)
func _wind_place(n: MeshInstance3D, p: Vector3, f: Vector3, length: float, height: float) -> void:
	n.position = p
	var to_cam := cam.global_position - p
	to_cam -= f * to_cam.dot(f)
	if to_cam.length() < 0.01:
		to_cam = Vector3.UP if absf(f.y) < 0.9 else Vector3.RIGHT
	var nx := to_cam.normalized()
	var ny := f.cross(nx)
	# 텍스처 왼쪽(짙은 머리)이 앞(돌 쪽), 흩어지는 꼬리가 뒤로
	n.basis = Basis(nx, ny * height, -f * length)

# ---- 입력 ----
func _tap(p: Vector2) -> void:
	last_x = p.x


func _drag(p: Vector2) -> void:
	var dx := p.x - last_x
	last_x = p.x
	if mode == "side" and not underground:
		return  # 옆모습 수로는 외길: 뛰기만
	# 높은 해안 사선 시점도 등뒤 시점과 같은 방향으로 조종한다
	x_goal += dx * 0.05 * 1.0


## 공통 삑 소리 대신 nkido 효과음 (submit/boulder/build_sfx.py)
func play(nm: String) -> void:
	if nm == "bad" and won:
		return  # 결승 순간에 이미 win 소리를 냈다
	match nm:
		"good": sfx("gem", -6.0, 0.75)
		"bad": sfx("bonk")
		"win": sfx("charge", 0.0, 0.8)
		"tap": sfx("tick")
		_: super(nm)


var _sfx := {}
var _sfx_pool: Array = []
var _sfx_i := 0
var _sfx_at := {}  # 소리 이름 → 마지막으로 낸 시각(ms): 같은 소리가 한꺼번에 겹치지 않게


func sfx(nm: String, db := 0.0, pitch := 1.0) -> void:
	var now := Time.get_ticks_msec()
	if now - int(_sfx_at.get(nm, -1000)) < 50:
		return
	_sfx_at[nm] = now
	if _sfx_pool.is_empty():
		for i in 10:
			var pl := AudioStreamPlayer.new()
			add_child(pl)
			_sfx_pool.append(pl)
	if not _sfx.has(nm):
		_sfx[nm] = load("res://art/boulder/sfx/%s.wav" % nm)
	# 쉬는 자리부터 쓴다: 굴러가는 딸깍 소리가 긴 소리(동굴·탑 깨기)를 끊지 않게
	var pl: AudioStreamPlayer = _sfx_pool[_sfx_i % _sfx_pool.size()]
	for i in _sfx_pool.size():
		var c: AudioStreamPlayer = _sfx_pool[(_sfx_i + i) % _sfx_pool.size()]
		if not c.playing:
			pl = c
			break
	_sfx_i += 1
	pl.stream = _sfx[nm]
	pl.volume_db = db - 4.0
	pl.pitch_scale = pitch * randf_range(0.97, 1.03)
	pl.play()


func _stone_mesh(n: MeshInstance3D) -> void:
	_apply_art(n, "stone")


## 협곡 아래로 내려가고 올라온다: 올려다본 하늘·먼 절벽 색이 바뀐다
func _cave(on: bool) -> void:
	var deep := on and cave_span.size() >= 2
	sky_to = (Z[maxi(cur_k, 0)].sky if deep else UNDER_SKY) if on else Z[maxi(cur_k, 0)].sky  # 깊은 협곡은 _hell_sky 가 깊이 따라 바꾼다
	hz_to = ((Z[maxi(cur_k, 0)].hz as Color) if deep else Color("f2dcb8")) if on else (Z[maxi(cur_k, 0)].hz as Color)
	if hero_rim:
		hero_rim.set_shader_parameter("ink", INK)
	_air_set(("ember" if deep else "cave") if on else str(AIR_OF.get(Z[maxi(cur_k, 0)].get("scen", "rock"), "dust")))
	# 먼 풍경을 새로 짓지 않는다(떨어지는 순간 렉): 동굴에서는 숨기고, 나오면 다시 보인다
	if far:
		far.visible = not deep
	if not deep:
		far_k = -1
		_far_build(maxi(cur_k, 0), on)
	if on:
		shake = 0.6
	else:
		play("good")


## 지하 수정이 깨어난다: center 둘레 radius 안의 수정이 번쩍 커졌다 제 빛으로. speed 가 있으면 가까운 것부터 물결처럼
func _wake(center: float, radius: float, speed := 0.0) -> void:
	for gl: Array in glows:
		if gl[3] or not is_instance_valid(gl[1]) or absf(float(gl[0]) - center) > radius:
			continue
		gl[3] = true
		var n: MeshInstance3D = gl[1]
		var m := n.material_override as StandardMaterial3D
		var base_sc := n.scale
		var gc: Color = gl[2]
		var tw := n.create_tween()
		if speed > 0.0:
			tw.tween_interval(absf(float(gl[0]) - center) / speed)
		tw.tween_property(m, "albedo_color", gc.lightened(0.45), 0.08)
		tw.parallel().tween_property(n, "scale", base_sc * 1.3, 0.08)
		tw.tween_property(m, "albedo_color", gc, 0.35)
		tw.parallel().tween_property(n, "scale", base_sc, 0.35).set_trans(Tween.TRANS_BACK)


## 동굴 보석: 닿으면 점수와 조금의 속도
func _gems() -> void:
	var fl := _h(dist) - _tunnel_depth(dist)
	for gm: Array in gems:
		if not is_instance_valid(gm[2]):
			continue
		var n: MeshInstance3D = gm[2]
		if not n.visible:
			continue
		n.rotation.y += 0.05
		if absf(float(gm[0]) - dist) < s * 0.5 + 0.9 and absf(fl + float(gm[1]) - (by + s * 0.5)) < s * 0.5 + 1.2:
			n.visible = false
			bonus += 40
			_score_chip(n.global_position, Color("ff8fd8"), true)
			v += 2.0
			_burst(n.global_position, Color("ff8fd8"), 6, 9.0, 0.5)
			sfx("gem", -3.0, randf_range(0.94, 1.12))


## 협곡 깊이: 수로 구간 [시작, 끝] 어디서 떨어져도 DEEP 아래 지하 신전 바닥. 떨어진 뒤에는 끝 너머 80m 까지 바닥이 이어진다.


## 물기둥: 지하 바닥에서 닿으면 다음 수로 위 단단한 곳까지 정확히 날려 올린다. 수로 높이를 넘으면 다시 위 세상.
func _geyser_tick() -> void:
	if not underground:
		return
	_hell_sky()
	_cave_clamp()
	if _updraft_tick():
		return
	if rising:
		# 물기둥을 타는 동안: 돌 밑에서 물보라가 튀고 기둥이 꿈틀댄다
		if fmod(clock, 0.06) < get_process_delta_time():
			_burst(pivot.position - Vector3.UP * s * 0.5, Color("9fe8ff"), 2, 5.0, 0.45)
		for gy: Array in geysers:
			if is_instance_valid(gy[1]):
				var gn: Node3D = gy[1]
				gn.scale.x = 5.0 + sin(clock * 30.0) * 0.5
				gn.scale.z = 5.0 + sin(clock * 30.0) * 0.5
		if vy < 0.0 and by > _h(dist) + 0.5:
			var classic := under_route.size() > 4 and float(under_route[4]) < 0.0
			underground = false
			rising = false
			under_route = []
			_cave(false)
			if classic:
				msg("다음 틈을 봐", 1.4)
			# 수로 위로 솟아 나옴: 물보라, 잠깐 느리게, 넓게 한 번 둘러보기
			_burst(_pos(dist, 0.0, _h(dist)), WATER, 12, 12.0, 0.7)
			_slowmo(0.35, 0.45)
			reveal_t = 1.4
		return
	if under_route.size() < 9:
		return
	var gd := float(under_route[3])
	if dist < gd:
		return
	# 깊은 물길: 물기둥 자리(gd..gd+6)를 공중으로 넘기면 물기둥이 안 솟고, 바로 다음 수로 밑 바닥으로 이어 달린다
	var nxt := _route_after(float(under_route[1]))
	if not nxt.is_empty() and dist > gd + 6.0:
		if dist >= float(under_route[1]):
			under_route = nxt.duplicate()
			under_route[4] = float(nxt[1]) + 6.0
			under_route[5] = float(nxt[1]) + 32.0
			_secret("깊은 물길")
		return
	if not on_ground:
		return
	if float(under_route[4]) >= 0.0:
		_sling()
		return
	var target := float(under_route[1]) + 12.0
	var apex := _h(target) + 12.0
	vy = sqrt(2.0 * FALL * maxf(4.0, apex - by))
	var t_all := vy / FALL + sqrt(2.0 * maxf(1.0, apex - _h(target)) / FALL)
	v = maxf(8.0, (target - dist) / t_all)
	on_ground = false
	rising = true
	by += 0.2
	shake = 0.8
	sq = 0.3
	_burst(_pos(dist, bx, by), Color("9fe8ff"), 16, 14.0, 0.8)
	sfx("launch", 2.0, 0.9)
	_hitstop(0.0, 16.0)
	_ring(_pos(dist, bx, by), Color("9fe8ff"), 8.0)
	_stamp("푸화악!", 3, _pos(dist, bx, by), Color("1c7ed6"), 0.9)


## 물기둥 새총(숨은 길): 지하에서 달리던 속도를 기억하고, 창 [lo, hi] 안 단단한 길로 쏘아 올린다. 착지하면 그 속도를 돌려준다
func _sling() -> void:
	var lo := float(under_route[4])
	var hi := float(under_route[5])
	var keep := minf(v, 44.0)  # 착지 직후 회전에서 밀려 떨어지지 않을 만큼만
	var target := hi
	var apex := 0.0
	var t_all := 1.0
	for i in 3:
		# 꼭대기는 물기둥 자리 길보다 높게: 솟는 동안 길 판 밑에 걸리지 않는다
		apex = maxf(_h(target), _h(dist)) + 7.0
		vy = sqrt(2.0 * FALL * maxf(4.0, apex - by))
		t_all = vy / FALL + sqrt(2.0 * maxf(1.0, apex - _h(target)) / FALL)
		if i < 2:
			target = clampf(dist + keep * t_all, lo, hi)
	v = maxf(8.0, (target - dist) / t_all)
	sling_keep = keep
	on_ground = false
	rising = true
	by += 0.2
	shake = 0.8
	sq = 0.3
	_burst(_pos(dist, bx, by), Color("9fe8ff"), 16, 14.0, 0.8)
	sfx("launch", 2.0, 0.9)
	_hitstop(0.0, 16.0)
	_ring(_pos(dist, bx, by), Color("9fe8ff"), 8.0)
	_stamp("푸화악!", 3, _pos(dist, bx, by), Color("1c7ed6"), 0.9)


## 끝이 b 인 지하에서 바로 이어지는 열린 지하 (없으면 빈 배열)
func _route_after(b: float) -> Array:
	for route: Array in tunnels:
		if bool(route[6]) and absf(float(route[0]) - b) < 0.5:
			return route
	return []


## 지하 깊이: 떨어진 지하는 끝 너머 80m 까지, 아니면 열린 지하 [a, b) 안. 닫힌 숨은 방은 0
## 지하 배열: [a, b, 깊이, 물기둥 거리, 창 lo, 창 hi, 열림, 이름, 착지 최소 속도]  (lo < 0 = 예전처럼 b+12 로 정확히)
func _tunnel_depth(d: float) -> float:
	if underground and under_route.size() > 2 and d >= float(under_route[0]) and d < float(under_route[1]) + 80.0:
		return float(under_route[2])
	for route: Array in tunnels:
		if bool(route[6]) and d >= float(route[0]) and d < float(route[1]):
			return float(route[2])
	return 0.0


## 숨은 방: 처음엔 안 보이고 닫혀 있다. 파란 금 바닥판을 내려찍어 깨면 열린다
func _hidden_chamber(it: Dictionary, d1: float, z: Dictionary) -> void:
	var u: Dictionary = it.under
	var cn := Node3D.new()
	(z.node as Node3D).add_child(cn)
	cn.visible = false
	var route := _build_tunnel(d1 + float(u["from"]), d1 + float(u["to"]), cn, {"depth": float(u["depth"]), "gd": d1 + float(u["geyser"]),
		"lo": d1 + float(u["lo"]), "hi": d1 + float(u["hi"]), "open": false, "name": str(u["name"]), "vmin": float(u["vmin"]), "gems": false, "ext": 30.0})
	if not it.has("crack"):
		return
	var ck: Array = it.crack
	var a := d1 + float(ck[0])
	var b := d1 + float(ck[1])
	var x0 := float(ck[2])
	var x1 := float(ck[3])
	var ckn := Node3D.new()
	(z.node as Node3D).add_child(ckn)
	_plate(pd, a, b, x0, x1, ROCK.darkened(0.3), ckn, 0.12)
	# 버티기 색(파랑) 지그재그 금: 탑·신상 머리와 같은 색 = 내려찍어라
	var seam := []
	for i in 4:
		var dd := a + 2.0 + i * 3.0
		var sn := box(_pos(dd, -1.0 if i % 2 == 0 else 1.0, _h(dd) + 0.25), Vector3(0.25, 0.08, 2.6), B, ckn)
		_skin(sn, "blue")
		sn.rotation.y = _yaw(dd) + (0.7 if i % 2 == 0 else -0.7)
		seam.append(sn)
	floor_cracks.append({"a": a, "b": b, "x0": x0, "x1": x1, "ckn": ckn, "seam": seam, "route": route, "cn": cn, "nd": z.node, "open": false})


## 버티기로 내려찍으며 금 간 바닥판에 닿으면: 판이 깨져 구멍이 되고, 그대로 아래 숨은 방으로 떨어진다
func _try_crack() -> void:
	for ck: Dictionary in floor_cracks:
		if bool(ck.open):
			continue
		# 판 앞 틈 위(방 시작부터)에서 버티며 떨어져도 연다: 판을 노리다 짧게 떨어져 죽지 않게
		var lo := minf(float(ck.a), float((ck.route as Array)[0]))
		if dist > lo - 1.0 and dist < float(ck.b) + 1.0 and bx > float(ck.x0) - 0.5 and bx < float(ck.x1) + 0.5 and by <= _h(dist) + 1.0:
			ck.open = true
			holes.append([float(ck.a), float(ck.b), float(ck.x0), float(ck.x1)])
			if is_instance_valid(ck.ckn):
				(ck.ckn as Node3D).visible = false
			if is_instance_valid(ck.nd):
				_plate(pd, float(ck.a), float(ck.b), float(ck.x0), float(ck.x1), Color("183e53"), ck.nd as Node3D, 0.16)
			var route: Array = ck.route
			route[6] = true  # tunnels 안 같은 배열
			if is_instance_valid(ck.cn):
				(ck.cn as Node3D).visible = true
			_burst(_pos(dist, bx, by), B, 16, 14.0, 0.8)
			sfx("crush_big")
			shake = 1.0
			_hitstop(0.1, -8.0)
			_stamp("와르르!", 4, _pos(dist, bx, by + s))
			# 깨진 판 가장자리에 걸리지 않게 바로 아래 방으로
			if _tunnel_depth(dist) > 0.0:
				_fall("")
			return


## 지하 신전 바닥에 놓는 것: 위 수로와 다른 놀이. 항아리 무리로 크게 커지고(위에서는 못 먹는 양),
## 석상은 깔거나 뛰어넘고, 무너진 담은 뛰어넘는다. 커진 몸은 물기둥이 위로 솟을 때 그대로 간다.
func _under_things(a: float, b: float, z: Dictionary) -> Array:
	# 동굴 맵: 넓은 굴방에서는 항아리를 쓸어 담아 커지고 석상을 깔고, 좁은 굴길에서는 붉은 석순 사이를 비틀고 무너진 담을 뛴다
	var out := []
	var lim := b - 60.0
	if updraft.size() >= 5:
		lim = minf(lim, float(updraft[0]) - 10.0)
	var d := a + 30.0
	var n := 0
	while d < lim:
		var hall := _cave_hw(d) > 8.0 and _cave_hw(d + 14.0) > 8.0  # 무리 하나가 굴길로 넘어가지 않게
		var put: Array = []
		if hall:
			match n % 3:
				0:
					put = [[0.0, -7.0, "pot"], [2.0, -3.5, "pot"], [4.0, 0.0, "pot"], [2.0, 3.5, "pot"], [0.0, 7.0, "pot"], [9.0, 0.0, "statue"]]
				1:
					put = [[0.0, -5.0, "statue"], [0.0, 5.0, "statue"], [4.0, 0.0, "pot"], [8.0, -2.0, "pot"], [8.0, 2.0, "pot"]]
				2:
					put = [[0.0, 0.0, "pot"], [3.0, -6.0, "pot"], [3.0, 6.0, "pot"], [6.0, 0.0, "pot"], [10.0, 0.0, "statue"]]  # 석순은 하나씩: 둘을 나란히 두면 큰 몸이 못 지나간다
		else:
			match n % 3:
				0:
					put = [[0.0, -2.6, "statue"], [9.0, 2.6, "statue"], [18.0, -2.6, "statue"], [4.5, 2.4, "pot"], [13.5, -2.4, "pot"]]
				1:
					put = [[0.0, -2.2, "statue"], [0.0, 2.2, "statue"], [8.0, 0.0, "pot"]]
				2:
					put = [[0.0, 0.0, "statue"], [6.0, -3.0, "pot"], [6.0, 3.0, "pot"], [12.0, 0.0, "statue"]]
		for pt: Array in put:
			var dd := d + float(pt[0])
			var th := _thing(pd, dd, dd, _cave_cx(dd) + clampf(float(pt[1]), -_cave_hw(dd) + 1.0, _cave_hw(dd) - 1.0), str(pt[2]), z)
			th.base -= DEEP
			th.n.position.y -= DEEP
			out.append(th)
		d += 22.0 if hall else 26.0
		n += 1
	return out

## 수로 밑 협곡과 잠든 지하 신전. 숨기지 않는다: 위에서도 저 아래가 보여 궁금하게 만든다.
## 뒤 절벽(지층 띠), 바닥 길, 옛 기둥·신전 폐허, 빛나는 수정, 수로 틈으로 내려오는 햇빛 기둥, 끝의 물기둥.
func _build_tunnel(a: float, b: float, nd: Node3D, opt := {}) -> Array:
	var dp := float(opt.get("depth", DEEP))
	var ext := float(opt.get("ext", 80.0))
	var route := [a, b, dp, float(opt.get("gd", b - 40.0)), float(opt.get("lo", -1.0)), float(opt.get("hi", -1.0)), bool(opt.get("open", true)), str(opt.get("name", "낮잠자는 지하 신전")), float(opt.get("vmin", 30.0))]
	tunnels.append(route)
	if bool(opt.get("cave", false)):
		cave_span = [a, b]
	if bool(opt.get("updraft", false)):
		_build_updraft(a, b, dp, nd)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(a) * 7 + 3
	var glow := [Color("ffb347"), Color("ff7a2a"), Color("ffd27a"), Color("ff5a3a")] if bool(opt.get("cave", false)) else [Color("7ff0ff"), Color("ffd27a"), C.lightened(0.35), Color("9cf2c4")]
	# 바닥 길: 수로 끝 너머 80m 까지 (늦게 떨어져도 착지할 곳). 끝 너머는 마지막 방향으로 곧게 잇는다.
	var e := b - 1.0
	var fwe := Vector3(-sin(_yaw(e)), 0.0, -cos(_yaw(e)))
	var floor_root := Node3D.new()  # 바닥 판은 60m 마다 MultiMesh 로 묶는다
	nd.add_child(floor_root)
	var d := a
	while d < b + ext:
		var end_d := minf(d + 12.0, b + ext)  # 12m 판: 바닥 조각 수를 1/3 로
		var p0 := _pos(d, _cave_cx(d), _h(d) - dp) if d <= e else _pos(e, 0.0, _h(e) - dp) + fwe * (d - e)
		var p1 := _pos(end_d, _cave_cx(end_d), _h(end_d) - dp) if end_d <= e else _pos(e, 0.0, _h(e) - dp) + fwe * (end_d - e)
		var bs := Basis.looking_at((p1 - p0).normalized(), Vector3.UP)
		var fk := "f%d" % int((d - a) / 60.0)
		var fc := floor_root.get_node_or_null(fk) as Node3D
		if fc == null:
			fc = Node3D.new()
			fc.name = fk
			fc.set_meta("ci", int((d - a) / 60.0))
			floor_root.add_child(fc)
		var slab := box((p0 + p1) * 0.5 - bs.y * 1.0, Vector3.ONE, Color("c9b28c"), fc)
		_apply_art(slab, "valley", Color("f0dcb4"))
		slab.basis = bs
		# 지옥 협곡: 바닥 폭이 굴방·굴길을 따른다 (밝은 돌길 = 용암 위에서 또렷하게)
		slab.scale = Vector3(_cave_hw(d + 6.0) * 2.0 if bool(opt.get("cave", false)) else 12.0, 2.0, p0.distance_to(p1) + 0.3)
		d = end_d
	_batch_chunks(floor_root)
	d = a
	while d < b:
		var h := _h(d)
		var fl := h - dp
		var yw := _yaw(d)
		# 뒤 절벽: 위는 밝은 사암, 아래로 갈수록 진한 흙빛 (떨어지며 지층을 지나친다)
		# 판 하나에 지층 그림(위 밝은 사암 -> 아래 진한 흙) : 예전엔 띠마다 상자라 그리기가 6배였다
		if not bool(opt.get("cave", false)) and int(d - a) % 24 == 0:
			var w := box(_pos(d + 12.0, -36.0, h - 4.0 - (dp - 4.0) * 0.5), Vector3(2.0, dp - 4.0, 26.0), WHITE, nd)
			_skin(w, "strata", Color("e4ebee"))
			w.rotation.y = yw
		# 옛 기둥 폐허 (뒤쪽, 높이 제각각 = 부서진 기둥)
		if not bool(opt.get("cave", false)) and int(d - a) % 24 == 8:
			var x := -rng.randf_range(9.0, 18.0)
			var ph := rng.randf_range(6.0, 22.0)
			var col := box(_pos(d, x, fl + ph * 0.5), Vector3(2.4, ph, 2.4), STONE, nd)
			_apply_art(col, "pillar", Color("e9dcc2"))
			col.rotation.y = yw
		# 신전 정면 (멀리, 반쯤 묻힘)
		if not bool(opt.get("cave", false)) and int(d - a) % 96 == 40:
			var tp := box(_pos(d, -34.0, fl + 7.0), Vector3(30, 18, 12), STONE, nd)
			_apply_art(tp, "temple", Color("d8c6a4"))
			tp.rotation.y = yw
		# 빛나는 수정 무리 (바닥 가까이, 앞뒤 양쪽)
		if int(d - a) % 18 == 4:
			for sd: float in [-1.0, 1.0]:
				if rng.randf() < 0.6:
					var cr := box(_pos(d + rng.randf_range(-3.0, 3.0), _cave_cx(d) + sd * rng.randf_range(7.0, 11.0) * (_cave_hw(d) / 11.0 + 0.4), fl), Vector3.ONE, WHITE, nd)
					# 잠든 수정: 제 재질을 따로 갖고(깨어날 때 빛이 바뀐다) 처음엔 흐릿하다
					var gc: Color = glow.pick_random()
					_apply_art(cr, "crystal")
					var cm: StandardMaterial3D = art_materials["crystal"].duplicate()
					cm.albedo_color = gc.lerp(Color("b9a58a"), 0.4)
					cr.material_override = cm
					glows.append([d, cr, gc, false])
					var hg := rng.randf_range(2.5, 7.0)
					cr.scale = Vector3(hg * 0.4, hg, hg * 0.4)
					cr.position.y += hg * 0.5
					cr.rotation = Vector3(0.0, yw, rng.randf_range(-0.4, 0.4))
		# 보석: 바닥에 하나, 뛰어야 닿는 높이에 하나씩 번갈아
		if bool(opt.get("gems", true)) and int(d - a) % 16 < 8 and d > a + 20.0 and d < b - 50.0 and int(d) % 8 == 0:
			var up := 1.6 if int(d / 16.0) % 2 == 0 else 7.0
			var gm := box(_pos(d, _cave_cx(d), fl + up), Vector3(1.2, 1.8, 1.2), WHITE, nd)
			_apply_art(gm, "crystal", glow[int(d) % glow.size()])
			gems.append([d, up, gm])
		d += 1.0
	# 수로 틈으로 내려오는 햇빛 기둥: 위와 아래가 이어진 공간이라는 걸 보여 준다
	var shaft := StandardMaterial3D.new()
	shaft.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shaft.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shaft.albedo_color = Color(1.0, 0.95, 0.75, 0.16)
	shaft.cull_mode = BaseMaterial3D.CULL_DISABLED
	var i := int(a)
	while i < int(b):
		if pd.tg[i] == "gap":
			var j := i
			while j < int(b) and pd.tg[j] == "gap":
				j += 1
			var mid := (i + j) * 0.5
			var sh := box(_pos(mid, 0.0, _h(mid) - dp * 0.5), Vector3(4.0, dp, float(j - i)), WHITE, nd)
			sh.material_override = shaft
			sh.rotation.y = _yaw(mid)
			i = j
		i += 1
	# 끝의 물기둥: 바닥에서 수로 위까지 솟는 물. 타면 다음 수로 위로 날아오른다.
	var gd := float(route[3])
	var water := StandardMaterial3D.new()
	water.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water.albedo_color = Color(0.85, 1.0, 1.0, 0.55)
	water.albedo_texture = load(ART_ROOT + "water.png") as Texture2D  # 비치는 물에 붓결
	var gy := box(_pos(gd, 0.0, _h(gd) - dp * 0.5 + 3.0), Vector3(5.0, dp + 6.0, 5.0), WHITE, nd)
	var cyl := CylinderMesh.new()
	cyl.radial_segments = 10
	cyl.top_radius = 0.5
	cyl.bottom_radius = 0.5
	cyl.height = 1.0
	gy.mesh = cyl
	gy.material_override = water
	for r in 6:
		var ring := box(_pos(gd, 0.0, _h(gd) - dp + 2.0 + r * dp / 6.0), Vector3(6.4, 0.5, 6.4), WHITE, nd)
		ring.mesh = cyl
		_skin(ring, "snowfield")  # 물거품 고리
	geysers.append([gd, gy])
	if bool(opt.get("cave", false)):
		_build_cave(a, b, dp, nd)
	return route


## 처음 그려질 때 재질 셰이더를 만드느라 멈칫한다: 그 구역 재질을 카메라 앞에 한 번씩 아주 작게 그려 미리 만든다
func _prewarm(root: Node) -> void:
	if not cam:
		return
	var mats := {}
	var stack: Array = [root]
	while stack.size() > 0:
		var n: Node = stack.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).material_override:
			mats[(n as MeshInstance3D).material_override] = true
		stack.append_array(n.get_children())
	var holder := Node3D.new()
	cam.add_child(holder)
	holder.position = Vector3(0, 0, -2.0)
	var i := 0
	for m in mats.keys():
		var b := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3.ONE * 0.002
		b.mesh = bm
		b.material_override = m
		b.position = Vector3(float(i % 10) * 0.003, float(i / 10) * 0.003, 0)
		holder.add_child(b)
		i += 1
	get_tree().create_timer(0.5).timeout.connect(holder.queue_free)


## 지옥 협곡: 떨어질수록 하늘이 검붉게 가라앉고 지평선이 용암빛으로 달아오른다 (깊이에 따라 실시간)
const HELL_SKY := Color("160604")
const HELL_HZ := Color("a8320c")
func _hell_sky() -> void:
	if cave_span.size() < 2 or dist < float(cave_span[0]) or dist > float(cave_span[1]) + 80.0:
		return
	var t := clampf((_h(dist) - by) / DEEP, 0.0, 1.0)
	t = sqrt(t)
	var zd: Dictionary = Z[maxi(cur_k, 0)]
	sky_to = (zd.sky as Color).lerp(HELL_SKY, t)
	hz_to = (zd.hz as Color).lerp(HELL_HZ, t)


## 지옥 협곡 바닥 길: 넓은 굴방(폭 22m)과 좁은 굴길(폭 11m)이 60m 마다 번갈아 나온다. 양옆은 용암.
const CAVE_SEC := 60.0
func _cave_hw(d: float) -> float:
	if cave_span.size() < 2:
		return CAVE_HW
	return 11.0 if int(floorf((d - float(cave_span[0])) / CAVE_SEC)) % 2 == 0 else 5.5


func _build_cave(a: float, b: float, dp: float, nd: Node3D) -> void:
	# 벽·천장 없이 열린 지옥 협곡: 밝은 돌길 양옆이 끓는 용암, 길 가장자리는 달아오른 띠
	var lava := StandardMaterial3D.new()
	lava.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lava.albedo_color = Color("ff6a1c")
	lava.albedo_texture = load(ART_ROOT + "water.png") as Texture2D  # 물결 붓결을 용암빛으로
	lava.uv1_scale = Vector3(4, 4, 1)
	var rim := StandardMaterial3D.new()
	rim.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rim.albedo_color = Color("ffd27a")
	var st := Node3D.new()  # 용암·띠는 MultiMesh 로 묶는다 (60m 마다 한 덩이)
	nd.add_child(st)
	var bucket := {}
	var seg := 10.0  # 짧게: 구불구불한 길 가장자리를 따라간다 (MultiMesh 로 묶여 그리기 횟수는 그대로)
	var d := a
	while d < b + 70.0:
		var mid := d + seg * 0.5
		var dd := minf(mid, b - 1.0)
		var fl := _h(dd) - dp
		var yw := _yaw(dd)
		var hw := _cave_hw(mid)
		for sd: float in [-1.0, 1.0]:
			var ck := int((d - a) / 60.0)
			if not bucket.has(ck):
				var bn := Node3D.new()
				bn.set_meta("ci", ck)
				st.add_child(bn)
				bucket[ck] = bn
			var cx := _cave_cx(mid)
			var lv := box(_pos(dd, cx + sd * (hw + 40.0), fl - 2.5), Vector3(80.0, 0.5, seg + 0.6), WHITE, bucket[ck])
			lv.material_override = lava
			lv.rotation.y = yw
			var eg := box(_pos(dd, cx + sd * (hw + 0.15), fl - 0.4), Vector3(0.5, 1.0, seg + 0.6), WHITE, bucket[ck])
			eg.material_override = rim
			eg.rotation.y = yw
		d += seg
	_batch_chunks(st)
	lava_mats.append(lava)


## 지옥 협곡 길은 좌우로 굽이친다 (양옆 용암). 처음 30m 와 순풍 길 앞은 곧게 펴서 떨어져 내리는 자리와 바람 기둥을 맞춘다
func _cave_cx(d: float) -> float:
	if cave_span.size() < 2:
		return 0.0
	var a := float(cave_span[0])
	var end := float(updraft[0]) - 10.0 if updraft.size() >= 5 else float(cave_span[1])
	var k := clampf((d - a) / 30.0, 0.0, 1.0) * clampf((end - d) / 40.0, 0.0, 1.0)
	return 7.5 * sin((d - a) * TAU / 150.0) * k * k * (3.0 - 2.0 * k)


## 지옥 협곡: 길 밖으로 굴러 나가면 용암에 빠진다. 떨어지는 동안은 길 위로 몸이 흘러가게 해 착지 자리를 맞춘다
func _cave_clamp() -> void:
	if cave_span.size() < 2 or not underground or dist < float(cave_span[0]) or dist > float(cave_span[1]) + 70.0 or wind_on:
		return
	var cx := _cave_cx(dist)
	if not on_ground and not deep_landed:
		x_goal = _cave_cx(dist + 25.0)
		return
	if on_ground and absf(bx - cx) > _cave_hw(dist) + s * 0.3 and not fallen:
		_burst(pivot.position, Color("ff7a2a"), 14, 10.0, 0.8)
		_fall("치익!")


## 순풍 길: 동굴 뒤쪽 바닥에서 바람결이 비스듬히 위로 감아 올라가 수로 틈으로 빠져나간다.
## 그 자리에 굴러 들어오면 바람이 돌을 밀어 올리고 앞으로 더 빠르게 지상으로 돌려보낸다.
func _build_updraft(a: float, b: float, dp: float, nd: Node3D) -> void:
	# 동굴 맨 끝 틈: 어느 구멍으로 떨어져도 동굴을 끝까지 달린 뒤에 올라온다
	var i := int(b) - 1
	while i > int(a) and pd.tg[i] != "gap":
		i -= 1
	while i > int(a) and pd.tg[i - 1] == "gap":
		i -= 1
	if i <= int(a):
		return
	var gs := float(i)
	var j := i
	while j < int(b) and pd.tg[j] == "gap":
		j += 1
	var ge := float(j)
	var u0 := gs - 80.0
	if u0 < a + 30.0:
		return
	var fl := _h(u0) - dp
	var top := _h(gs + (ge - gs) * 0.4) + 3.0
	updraft = [u0, gs, ge, fl, top]
	# 바닥 금빛 바람 줄: 여기서부터 바람이 감아 오른다
	for q in 5:
		var ln := box(_pos(u0 - 14.0 + q * 3.0, 0.0, _h(u0) - dp + 0.1), Vector3(5.0, 0.08, 0.6), G_TOP, nd)
		ln.rotation.y = _yaw(u0)
	var d := u0 - 6.0
	while d < gs + (ge - gs) * 0.4:
		var y := _updraft_y(d)
		var f := (_pos(d + 4.0, 0.0, _updraft_y(d + 4.0)) - _pos(d, 0.0, y)).normalized()
		for sd: float in [-1.0, 1.0]:
			var w := _wind_node(nd)
			w.position = _pos(d, sd * 2.2, y + 2.0)
			w.basis = Basis.looking_at(f, Vector3.UP).rotated(f, 0.0 if sd < 0.0 else PI * 0.5)
			w.scale = Vector3(1.0, 5.0, 9.0)
		d += 5.0


## 순풍 길 높이: 시작점 바닥에서 틈 속 나올 높이까지 부드럽게 (느리게 떠서 가파르게 솟고 다시 눕는다)
func _updraft_y(d: float) -> float:
	var t := clampf((d - float(updraft[0])) / (float(updraft[1]) + (float(updraft[2]) - float(updraft[1])) * 0.4 - float(updraft[0])), 0.0, 1.0)
	return lerpf(float(updraft[3]), float(updraft[4]), t * t * (3.0 - 2.0 * t))


## 순풍 타기. 타는 중이면 true (물기둥 처리를 건너뛴다)
func _updraft_tick() -> bool:
	if updraft.size() < 5 or fallen:
		return false
	var dt := get_process_delta_time()
	if not wind_on:
		if dist >= float(updraft[0]) and dist < float(updraft[1]) and by < float(updraft[3]) + 4.0:
			wind_on = true
			rising = true
			on_ground = false
			x_goal = 0.0
			shake = 0.6
			sq = 0.3
			sfx("launch", 0.0, 0.7)
			_hitstop(0.0, 12.0)
			_stamp("휘오오!", 3, _pos(dist, bx, by + s), Color("c58a1e"), 0.9)
			_wake(dist, 80.0, 90.0)
		else:
			return false
	x_goal = 0.0
	v = minf(VMAX + 8.0, v + 22.0 * dt)  # 순풍: 뒤에서 밀어 준다
	var ny := _updraft_y(dist)
	vy = (ny - by) / maxf(dt, 0.001)
	by = ny
	if fmod(clock, 0.05) < dt:
		_burst(pivot.position, Color("f3dcaa"), 2, 6.0, 0.5)
	if dist >= float(updraft[1]) + (float(updraft[2]) - float(updraft[1])) * 0.4:
		wind_on = false
		rising = false
		underground = false
		under_route = []
		updraft = []
		vy = 9.0
		_cave(false)
		_burst(_pos(dist, 0.0, _h(dist)), Color("f3dcaa"), 14, 12.0, 0.7)
		_slowmo(0.3, 0.5)
		reveal_t = 1.2
		_secret("순풍 길")
	return true

func _load_art() -> void:
	for name: String in ART_NAMES:
		var scene := load(ART_ROOT + name + ".glb") as PackedScene
		assert(scene != null, "Missing painted model: " + name)
		var instance := scene.instantiate()
		var mesh := _find_art_mesh(instance)
		assert(mesh != null, "Model has no mesh: " + name)
		art_meshes[name] = mesh
		instance.free()
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_texture = load(ART_ROOT + name + ".png") as Texture2D
		assert(material.albedo_texture != null, "Missing GPT texture: " + name)
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		material.roughness = 1.0
		art_materials[name] = material
	# Ice is pale cyan, so it cannot be mistaken for the purple throw-only barricade.
	var ice_material := StandardMaterial3D.new()
	ice_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ice_material.albedo_color = ICEWALL
	# 수정 그림을 밝게 바랜 얼음결로: 같은 모양 메시에 칠한 얼음 면
	ice_material.albedo_texture = load(ART_ROOT + "ice_crystal.png") as Texture2D
	ice_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	art_materials["ice_wall"] = ice_material


func _find_art_mesh(node: Node) -> Mesh:
	if node is MeshInstance3D:
		return (node as MeshInstance3D).mesh
	for child in node.get_children():
		var mesh := _find_art_mesh(child)
		if mesh:
			return mesh
	return null


func _apply_art(node: MeshInstance3D, name: String, tint := Color.WHITE) -> void:
	node.mesh = art_meshes[name]
	node.material_override = _art_mat(name, tint)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## 칠한 모델 재질 + 색. 같은 그림·같은 색이면 재질 하나를 같이 쓴다 (지하 협곡은 수백 개라 폰에서 무겁다)
func _art_mat(name: String, tint := Color.WHITE) -> StandardMaterial3D:
	if tint == Color.WHITE:
		return art_materials[name]
	var key: String = name + tint.to_html()
	if not art_tinted.has(key):
		var m: StandardMaterial3D = art_materials[name].duplicate()
		m.albedo_color = tint
		art_tinted[key] = m
	return art_tinted[key]


## 메시는 그대로 두고 잘라 낸 그림 재질만 입힌다: roof(신전 테라코타), wall(계곡 사암 띠). tint 로 색을 바꾼다.
func _skin(node: MeshInstance3D, tex_name: String, tint := Color.WHITE, rep := 1.0) -> void:
	node.material_override = _pm(tex_name, tint, rep)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## 잘라 낸 그림 재질 하나 (그림·색·반복 수가 같으면 돌려 쓴다). 그림들: roof wall strata chip(무채 붓결: 색을 그대로 입힌다)
## sand(금빛 모래) snowfield(눈) water(물) pit(어두운 얼음 구멍) blue(파란 돌) potshard wood amethyst pillar_red ice_crystal
func _pm(tex_name: String, tint := Color.WHITE, rep := 1.0) -> StandardMaterial3D:
	var key := "skin_" + tex_name + tint.to_html() + ("" if rep == 1.0 else str(rep))
	if not art_tinted.has(key):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_texture = load(ART_ROOT + tex_name + ".png") as Texture2D
		m.albedo_color = tint
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		if rep != 1.0:
			m.uv1_scale = Vector3(rep, rep, 1.0)
		art_tinted[key] = m
	return art_tinted[key]


## 파편·먼지 재질: 그림 + 면마다 구운 밝기(정점색) + 양면
func _shard_mat(tex_name: String, tint := Color.WHITE) -> StandardMaterial3D:
	var key := "shard_" + tex_name + tint.to_html()
	if not art_tinted.has(key):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.vertex_color_use_as_albedo = true
		m.albedo_texture = load(ART_ROOT + tex_name + ".png") as Texture2D
		m.albedo_color = tint
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		art_tinted[key] = m
	return art_tinted[key]


## 낮은 다각 덩이 (반지름 0.5): 위도 rows × 경도 seg 꼭짓점을 흔들어 각진 면을 만들고, 면 밝기는 위 왼쪽 빛으로 정점색에 굽는다
func _lowpoly(rseed: int, seg: int, rows: int, jitter: float, squash: Vector3) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = rseed
	var top := Vector3(rng.randf_range(-0.1, 0.1), 0.5, rng.randf_range(-0.1, 0.1)) * squash
	var bot := Vector3(rng.randf_range(-0.1, 0.1), -0.5, rng.randf_range(-0.1, 0.1)) * squash
	var grid: Array = []
	for r in rows + 1:
		var row: Array = []
		for q in seg:
			if r == 0:
				row.append(bot)
				continue
			if r == rows:
				row.append(top)
				continue
			var lat := PI * float(r) / float(rows) - PI * 0.5
			var lon := TAU * (float(q) + rng.randf_range(-0.2, 0.2)) / float(seg)
			var p := Vector3(cos(lat) * cos(lon), sin(lat), cos(lat) * sin(lon)) * 0.5 * (1.0 + rng.randf_range(-jitter, jitter))
			row.append(p * squash)
		grid.append(row)
	var light := Vector3(-0.4, 1.0, 0.3).normalized()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for r in rows:
		for q in seg:
			var a: Vector3 = grid[r][q]
			var b: Vector3 = grid[r][(q + 1) % seg]
			var c: Vector3 = grid[r + 1][q]
			var d: Vector3 = grid[r + 1][(q + 1) % seg]
			for tri: Array in [[a, c, b], [b, c, d]]:
				var p0: Vector3 = tri[0]
				var p1: Vector3 = tri[1]
				var p2: Vector3 = tri[2]
				var nrm := (p1 - p0).cross(p2 - p0)
				if nrm.length() < 0.0001:
					continue
				nrm = nrm.normalized()
				if nrm.dot((p0 + p1 + p2) / 3.0) < 0.0:
					nrm = -nrm
				var k := 0.72 + 0.28 * maxf(0.0, nrm.dot(light))
				var ax := absf(nrm.x)
				var ay := absf(nrm.y)
				var az := absf(nrm.z)
				for p: Vector3 in tri:
					var uv := Vector2(p.x, p.z) if ay >= ax and ay >= az else (Vector2(p.z, p.y) if ax >= az else Vector2(p.x, p.y))
					st.set_color(Color(k, k, k))
					st.set_uv(uv * 0.9 + Vector2(0.5, 0.5))
					st.add_vertex(p)
	return st.commit()


## 파편 메시 셋(납작하고 모난 돌·사금파리)과 먼지 덩이 하나: 처음 한 번 만들어 돌려 쓴다
var shard_meshes: Array = []
var puff_mesh: ArrayMesh


func _shard_mesh(i: int) -> ArrayMesh:
	if shard_meshes.is_empty():
		shard_meshes.append(_lowpoly(11, 5, 2, 0.35, Vector3(1.1, 0.55, 0.9)))
		shard_meshes.append(_lowpoly(23, 4, 2, 0.3, Vector3(1.2, 0.4, 0.8)))
		shard_meshes.append(_lowpoly(37, 5, 3, 0.3, Vector3(0.9, 0.7, 1.0)))
	return shard_meshes[i % shard_meshes.size()]


func _puff_mesh() -> ArrayMesh:
	if puff_mesh == null:
		puff_mesh = _lowpoly(5, 7, 4, 0.12, Vector3(1.0, 0.8, 1.0))
	return puff_mesh


## 색만 받은 파편: 색에 맞는 그림을 고른다 [그림, 색]
func _shard_look(col: Color) -> Array:
	if col == A:
		return ["wood", WHITE]
	if col == D:
		return ["sand", WHITE]
	if col == B or col == ME:
		return ["blue", WHITE]
	if col == STONE:
		return ["wall", WHITE]
	if col == WATER or col == Color("9fe8ff"):
		return ["water", WHITE]
	if col == WHITE:
		return ["snowfield", WHITE]
	return ["chip", col]


## 길 위 판 색 -> 그림: 흰 = 눈, 노랑 = 녹는 모래, 청록 = 물살, 먹청 = 구멍, 빨강 = 위험
func _plate_skin(m: MeshInstance3D, col: Color) -> void:
	if col == BAD:
		_red(m)
	elif col == WHITE:
		_skin(m, "snowfield")
	elif col == D:
		_skin(m, "sand")
	elif col == Color("69bdbf"):
		_skin(m, "water")
	elif col == Color("183e53"):
		_skin(m, "pit")
	else:
		_skin(m, "chip", col)


## 위험 표시(빨간 띠·머리·경계): 맨 빨강 대신 붉게 칠한 테라코타 돌결
func _red(node: MeshInstance3D) -> MeshInstance3D:
	_skin(node, "roof", Color("ff8a7a"))
	return node


## 박공 지붕: 바닥이 평평하고 용마루가 위로 선 삼각 기둥(직접 만든 메시)에 테라코타
var roof_mesh: ArrayMesh
var roof_mat2: StandardMaterial3D


func _roof(parent: MeshInstance3D) -> void:
	if roof_mesh == null:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var a := Vector3(-0.5, 0.0, -0.5)
		var b := Vector3(0.5, 0.0, -0.5)
		var c := Vector3(0.0, 1.0, -0.5)
		var a2 := Vector3(-0.5, 0.0, 0.5)
		var b2 := Vector3(0.5, 0.0, 0.5)
		var c2 := Vector3(0.0, 1.0, 0.5)
		# 앞뒤 삼각 면 + 비탈 두 면 (UV 는 그림 한 장을 면마다)
		for tri: Array in [[a, c, b, Vector2(0, 1), Vector2(0.5, 0), Vector2(1, 1)], [a2, b2, c2, Vector2(0, 1), Vector2(1, 1), Vector2(0.5, 0)],
				[a, a2, c2, Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)], [a, c2, c, Vector2(0, 1), Vector2(1, 0), Vector2(0, 0)],
				[b, c, c2, Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)], [b, c2, b2, Vector2(0, 1), Vector2(1, 0), Vector2(1, 1)]]:
			for q in 3:
				st.set_uv(tri[3 + q])
				st.add_vertex(tri[q])
		st.generate_normals()
		roof_mesh = st.commit()
	var r := MeshInstance3D.new()
	r.mesh = roof_mesh
	parent.add_child(r)
	# 부모(집) 단위 공간: 처마가 조금 나오고 높이는 집의 0.45
	r.position = Vector3(0, 0.5, 0)
	r.scale = Vector3(1.2, 0.45, 1.12)
	_skin(r, "roof")
	# 삼각 면 감는 방향이 섞여 있어 한쪽 면이 빠져 세모 구멍처럼 보였다 → 양면으로
	if roof_mat2 == null:
		roof_mat2 = (r.material_override as StandardMaterial3D).duplicate()
		roof_mat2.cull_mode = BaseMaterial3D.CULL_DISABLED
	r.material_override = roof_mat2


func _ground_art(k: int) -> String:
	if k == 5:
		return "snow"
	return "coast" if k in [7, 8, 10] else "valley"


# ---- 새긴 돌판: 도장·지명판·돌 조각·점수 튐 ----
## 큰 순간에 쾅 박히는 돌판 3개, 지명판 1개, 날아가는 조각 18개를 미리 만든다 (자신에 붙어 다시 시작해도 남는다)
func _stamp_build() -> void:
	stamp_layer = CanvasLayer.new()
	stamp_layer.layer = 7
	add_child(stamp_layer)
	stamps.clear()
	for i in 3:
		var root := Control.new()
		root.size = Vector2(340, 150)
		root.pivot_offset = root.size * 0.5
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.visible = false
		stamp_layer.add_child(root)
		var a := ui_slab(root, Vector2(0, 0), Vector2(170, 150), 1)
		var b := ui_slab(root, Vector2(170, 0), Vector2(170, 150), 2)
		var lab := ui_glyph(root, 76)
		var crack := Line2D.new()
		crack.default_color = INK
		crack.width = 0.0
		crack.joint_mode = Line2D.LINE_JOINT_SHARP
		crack.begin_cap_mode = Line2D.LINE_CAP_NONE
		crack.end_cap_mode = Line2D.LINE_CAP_NONE
		root.add_child(crack)
		stamps.append({"root": root, "a": a, "b": b, "lab": lab, "crack": crack,
			"boxes": [a.get_meta("sb"), b.get_meta("sb")], "tw": null, "busy": false, "pri": 0, "base": Vector2.ZERO, "word": ""})
	# 지명판: 구역에 들어설 때·지하 신전에 닿을 때
	plaque = Control.new()
	# 왼쪽 안내 줄(x 24..524)에 맞춘다: 오른쪽 키트 버튼(x 534~)을 가리지 않게
	plaque.position = Vector2(40, 520)
	plaque.size = Vector2(500, 120)
	plaque.pivot_offset = Vector2(250, 60)
	plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plaque.visible = false
	stamp_layer.add_child(plaque)
	ui_slab(plaque, Vector2.ZERO, Vector2(640, 150), 0, STONE, "plaque")
	plaque.pivot_offset = Vector2(320, 75)
	plaque_stripe = ColorRect.new()
	plaque_stripe.position = Vector2(18, 14)
	plaque_stripe.size = Vector2(464, 8)
	plaque_stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plaque_stripe.visible = false  # 그림 명패에는 띠가 그려져 있다
	plaque.add_child(plaque_stripe)
	plaque_l = ui_glyph(plaque, 60)
	plaque_l.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	plaque_l.position = Vector2(100, 22)
	plaque_l.size = Vector2(440, 74)
	plaque_l.label_settings.font_color = GLYPH.darkened(0.25)
	plaque_sub = ui_glyph(plaque, 26, GLYPH_SUB)
	plaque_sub.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	plaque_sub.position = Vector2(100, 94)
	plaque_sub.size = Vector2(440, 30)
	plaque_crack = Line2D.new()
	plaque_crack.default_color = INK
	plaque_crack.width = 0.0
	plaque_crack.joint_mode = Line2D.LINE_JOINT_SHARP
	plaque.add_child(plaque_crack)
	# 돌·보석 조각
	chip_sb = ui_box(WHITE, 3, 3, false)
	chips.clear()
	for i in 18:
		var c := Panel.new()
		c.size = Vector2(16, 16)
		c.pivot_offset = Vector2(8, 8)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.visible = false
		c.add_theme_stylebox_override("panel", chip_sb)
		stamp_layer.add_child(c)
		chips.append(c)


## 돌판 가운데로 내려가는 금: 6점, 옆으로 들쭉날쭉
func _crack_pts() -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 6:
		pts.append(Vector2(170.0 + randf_range(-14.0, 14.0), lerpf(8.0, 142.0, i / 5.0)))
	return pts


func _chip_kill(c: Panel) -> void:
	if c.has_meta("tw"):
		var old: Tween = c.get_meta("tw")
		if old and old.is_valid():
			old.kill()


## 돌 조각 n개가 center 둘레에서 튀어 올랐다가 떨어진다
func _stamp_chips(center: Vector2, n: int, col: Color) -> void:
	for c: Panel in chips:
		if n <= 0:
			break
		if c.visible:
			continue
		n -= 1
		_chip_kill(c)
		c.visible = true
		c.self_modulate = col
		c.modulate.a = 1.0
		c.scale = Vector2.ONE
		c.position = center + Vector2(randf_range(-120.0, 120.0), randf_range(-20.0, 50.0))
		var up := c.position + Vector2(randf_range(-170.0, 170.0), randf_range(-160.0, -60.0))
		var tw := create_tween().set_ignore_time_scale(true)
		tw.tween_property(c, "position", up, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(c, "rotation", c.rotation + randf_range(-6.0, 6.0), 0.53)
		tw.tween_property(c, "position:y", up.y + 200.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.parallel().tween_property(c, "modulate:a", 0.0, 0.25).set_delay(0.1)
		tw.tween_callback(c.hide)
		c.set_meta("tw", tw)


## 새긴 돌판 도장: 크게 떨어져 쾅 박히고(bonk), 잠깐 버틴 뒤 금이 가 둘로 갈라져 떨어진다.
## pri 가 높을수록 중요한 순간: 낮은 도장은 높은 도장을 덮지 못한다
func _stamp(word: String, pri: int, at: Vector3, tint := GLYPH, big := 1.0, hold := 0.32, slab := STONE) -> void:
	if not stamp_layer or stamps.is_empty():
		return
	if fallen or (over and pri < 6) or Engine.time_scale < 1.0:
		return
	var cd := 4.0 if word == "쩌억!" else 2.5
	if clock - float(stamp_at.get(word, -99.0)) < cd:
		return
	if clock < stamp_gap and pri <= stamp_pri:
		return
	var st: Dictionary = {}
	for c: Dictionary in stamps:
		if not bool(c.busy):
			st = c
			break
	if st.is_empty():
		for c: Dictionary in stamps:
			if st.is_empty() or int(c.pri) < int(st.pri):
				st = c
		if int(st.pri) > pri:
			return
		# 덜 중요한 도장을 바로 부수고 그 자리를 쓴다
		var old: Tween = st.tw
		if old and old.is_valid():
			old.kill()
		var oroot: Control = st.root
		_stamp_chips(oroot.position + oroot.size * 0.5, 6, STONE)
	stamp_at[word] = clock
	stamp_gap = clock + 0.7
	stamp_pri = pri
	var root: Control = st.root
	var a: Control = st.a
	var b: Control = st.b
	var lab: Label = st.lab
	var crack: Line2D = st.crack
	var sp := Vector2(360, 600) if cam.is_position_behind(at) else cam.unproject_position(at)
	# 오른쪽 키트 버튼(x 534~)을 덮지 않게: 돌판 오른쪽 끝이 x 520 안에 들도록
	var hw := 170.0 * big
	sp = sp.clamp(Vector2(hw + 8.0, 430), Vector2(maxf(hw + 8.0, 520.0 - hw), 820))
	root.position = sp - root.size * 0.5
	st.base = root.position
	st.word = word
	root.rotation = randf_range(-0.12, 0.12)
	root.scale = Vector2.ONE * 1.6 * big
	root.modulate.a = 0.0
	root.visible = true
	a.position = Vector2(0, 0)
	b.position = Vector2(170, 0)
	a.rotation = 0.0
	b.rotation = 0.0
	a.modulate.a = 1.0
	b.modulate.a = 1.0
	for sb: StyleBox in st.boxes:
		_sb_fill(sb, slab)
	lab.text = tr(word)
	lab.modulate.a = 1.0
	lab.label_settings.font_color = tint
	lab.label_settings.font_size = fit_fs(tr(word), 76, 296.0)
	crack.points = _crack_pts()
	crack.width = 0.0
	var tw := create_tween().set_ignore_time_scale(true)
	st.tw = tw
	st.busy = true
	st.pri = pri
	tw.tween_property(root, "modulate:a", 1.0, 0.05)
	tw.parallel().tween_property(root, "scale", Vector2.ONE * big, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		sfx("bonk", 2.0, 0.7)
		shake = maxf(shake, 0.35)
		_stamp_chips(root.position + root.size * 0.5 + Vector2(0, 60), 4, STONE))
	var wob := func(k: float) -> void:
		root.position.x = (st.base as Vector2).x + sin(k * 42.0) * 10.0 * (1.0 - k)
	tw.tween_method(wob, 0.0, 1.0, 0.18)
	tw.tween_interval(hold)
	tw.tween_callback(_stamp_break.bind(st, false))


## 도장 깨짐: 가운데 금이 가고, 두 쪽이 기울며 떨어지고, 조각이 튄다
func _stamp_break(st: Dictionary, fast: bool) -> void:
	var f := 0.4 if fast else 1.0
	var root: Control = st.root
	var a: Control = st.a
	var b: Control = st.b
	var lab: Label = st.lab
	var crack: Line2D = st.crack
	_stamp_chips(root.position + root.size * 0.5, 6, STONE.darkened(0.08))
	if not fast:
		sfx("crush_s", -4.0, 1.3)
	var tw := create_tween().set_ignore_time_scale(true).set_parallel()
	st.tw = tw
	tw.tween_property(crack, "width", 5.0, 0.06 * f)
	tw.tween_property(lab, "modulate:a", 0.0, 0.08 * f)
	tw.tween_property(a, "position", a.position + Vector2(-70, 120), 0.4 * f).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(a, "rotation", -0.45, 0.4 * f).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(b, "position", b.position + Vector2(80, 130), 0.45 * f).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(b, "rotation", 0.5, 0.45 * f).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(root, "modulate:a", 0.0, 0.3 * f).set_delay(0.12 * f)
	tw.chain().tween_callback(func() -> void:
		root.visible = false
		st.busy = false)


## 지명판: 새긴 돌판에 곳 이름. 플레이 방법 상자가 떠 있으면 닫힐 때까지 기다린다
func _plaque(word: String, sub: String, accent: Color, hold := 1.3) -> void:
	if not plaque:
		return
	# 설명 카드가 떠 있거나 곧 뜰 때(Tofu._ready 는 restart 뒤에 카드를 만든다)는 닫힐 때까지 미룬다
	if (_howto_box and _howto_box.visible) or (_howto_box == null and howto != ""):
		plaque_pending = [word, sub, accent, hold]
		return
	if plaque_tw:
		plaque_tw.kill()
	plaque_l.text = tr(word)
	plaque_l.label_settings.font_size = fit_fs(tr(word), 60, 430.0)
	plaque_sub.text = sub
	plaque_stripe.color = accent
	plaque_crack.points = PackedVector2Array([Vector2(330, 20), Vector2(348, 56), Vector2(336, 94), Vector2(360, 130)])
	plaque_crack.width = 0.0
	plaque.visible = true
	plaque.position = Vector2(40, 520)
	plaque.modulate.a = 0.0
	plaque.scale = Vector2.ONE * 1.5
	plaque.rotation = -0.05
	plaque_tw = create_tween().set_ignore_time_scale(true)
	plaque_tw.tween_property(plaque, "modulate:a", 1.0, 0.06)
	plaque_tw.parallel().tween_property(plaque, "scale", Vector2.ONE, 0.16).set_ease(Tween.EASE_IN)
	plaque_tw.parallel().tween_property(plaque, "rotation", 0.0, 0.16)
	plaque_tw.tween_callback(func() -> void:
		sfx("bonk", -2.0, 0.75)
		shake = maxf(shake, 0.25)
		plaque_crack.width = 3.0
		_stamp_chips(Vector2(360, 670), 8, DUST))
	plaque_tw.tween_property(plaque, "scale", Vector2(1.04, 0.96), 0.05)
	plaque_tw.tween_property(plaque, "scale", Vector2.ONE, 0.08)
	plaque_tw.tween_interval(hold)
	plaque_tw.tween_property(plaque, "position:y", 490.0, 0.25).set_ease(Tween.EASE_IN)
	plaque_tw.parallel().tween_property(plaque, "modulate:a", 0.0, 0.25)
	plaque_tw.tween_callback(plaque.hide)


## 점수 글에서 숫자 끝자리쯤 (조각이 날아가 닿는 곳)
func _score_target() -> Vector2:
	var fs := _score_l.label_settings.font_size
	var w := _font.get_string_size(_score_l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var nw := _font.get_string_size(str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	return _score_l.position + Vector2(_score_l.size.x * 0.5 - w * 0.5 + nw * 0.5, _score_l.size.y * 0.5)


## 점수가 톡 커졌다 돌아오고, 잠깐 받은 것의 색으로 물든다
func _score_bump(col := D) -> void:
	if not _score_l:
		return
	_score_l.pivot_offset = Vector2(_score_target().x - _score_l.position.x, _score_l.size.y * 0.5)
	if score_tw:
		score_tw.kill()
	_score_l.scale = Vector2.ONE * 1.2
	_score_l.label_settings.font_color = col.darkened(0.35)
	score_tw = create_tween().set_ignore_time_scale(true).set_parallel()
	score_tw.tween_property(_score_l, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	score_tw.tween_property(_score_l.label_settings, "font_color", INK, 0.3)


## 작은 것을 깔거나 주우면 돌·보석 조각 하나가 점수로 날아가 닿고 점수가 톡
func _score_chip(at: Vector3, col: Color, gem := false) -> void:
	if not stamp_layer:
		return
	if clock - chip_at < 0.05 or cam.is_position_behind(at):
		_score_bump(col)
		return
	var c: Panel = null
	for k: Panel in chips:
		if not k.visible:
			c = k
			break
	if c == null:
		_score_bump(col)
		return
	chip_at = clock
	_chip_kill(c)
	var p0 := cam.unproject_position(at)
	var p1 := _score_target()
	var mid := (p0 + p1) * 0.5 + Vector2(randf_range(-90.0, 90.0), -150.0)
	c.visible = true
	c.self_modulate = col
	c.modulate.a = 1.0
	c.scale = Vector2.ONE * 1.5
	c.rotation = PI / 4.0 if gem else 0.0
	c.position = p0 - Vector2(8, 8)
	var tw := create_tween().set_ignore_time_scale(true)
	var fly := func(k: float) -> void:
		c.position = p0.lerp(mid, k).lerp(mid.lerp(p1, k), k) - Vector2(8, 8)
	tw.tween_method(fly, 0.0, 1.0, 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(c, "scale", Vector2.ONE * 0.7, 0.42)
	tw.tween_callback(func() -> void:
		c.visible = false
		_score_bump(col))
	c.set_meta("tw", tw)


# ---- UI 디자인 시스템 ----
# 새긴 돌 한 벌: 알약 버튼(반지름 = 높이/2, 테 5), 카드 반지름 24, 돌판 반지름 14 + 아래 두께 12, 그림자는 곧게 아래로.
# main.gd 도 game.call 로 이 함수들을 쓴다.
## 신전 돌결 판 (art/boulder/ui_gpt/*.png: Codex 가 GPT 로 그린 9-patch UI, submit/boulder/UI_ART.md).
## 그림은 색이 빠진 밝은 돌결이고 modulate 로 색을 입힌다. 테두리·아래 두께는 그림에 들어 있다.
## kind: slab(새긴 판, 안쪽 파인 테), card(큰 카드), btn / btn_dn(버튼 평소·눌림). half 1 = 왼쪽 반, 2 = 오른쪽 반.
var _ui_tex := {}


## kind -> [그림, 왼, 위, 오른, 아래 여백]. 작은 버튼·게이지는 절반 크기 그림(_s)을 쓴다
const UI_GPT := {
	"slab": ["panel", 56, 56, 56, 64], "card": ["panel", 56, 56, 56, 64],
	"btn": ["button", 48, 48, 48, 72], "btn_dn": ["button_down", 48, 48, 48, 48],
	"btn_s": ["button_s", 24, 24, 24, 36], "btn_dn_s": ["button_down_s", 24, 24, 24, 24],
	"title": ["title_s", 120, 78, 120, 84], "plaque": ["plaque", 96, 48, 96, 48],
	"seal": ["seal", 0, 0, 0, 0], "gauge": ["gauge_s", 32, 20, 32, 20],
}


func ui_stone(fill: Color, kind := "slab", half := 0) -> StyleBoxTexture:
	var spec: Array = UI_GPT[kind]
	var file: String = spec[0]
	if not _ui_tex.has(file):
		_ui_tex[file] = load(ART_ROOT + "ui_gpt/" + file + ".png")
	var tex: Texture2D = _ui_tex[file]
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = float(spec[1])
	sb.texture_margin_top = float(spec[2])
	sb.texture_margin_right = float(spec[3])
	sb.texture_margin_bottom = float(spec[4])
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 10.0 if not kind.begins_with("btn_dn") else 6.0
	# 그림이 이미 크림 돌이라 STONE 은 그대로, 다른 색은 밝게 물들인다
	sb.modulate_color = Color.WHITE if fill.is_equal_approx(STONE) or fill.is_equal_approx(WHITE) else fill.lightened(0.15)
	var w := float(tex.get_width())
	var h := float(tex.get_height())
	if half == 1:
		sb.region_rect = Rect2(0, 0, w * 0.5, h)
		sb.texture_margin_right = 0.0
	elif half == 2:
		sb.region_rect = Rect2(w * 0.5, 0, w * 0.5, h)
		sb.texture_margin_left = 0.0
	return sb


## 판 색 바꾸기 (평판·돌결판 어느 쪽이든)
func _sb_fill(sb: StyleBox, col: Color) -> void:
	if sb is StyleBoxTexture:
		(sb as StyleBoxTexture).modulate_color = col
	elif sb is StyleBoxFlat:
		(sb as StyleBoxFlat).bg_color = col


func ui_box(fill: Color, r := 24, bw := 5, shadow := true) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.set_corner_radius_all(mini(r, 9))
	sb.corner_detail = 1  # 둥근 모서리 대신 비스듬히 깎은 모서리
	sb.set_border_width_all(bw)
	sb.border_color = INK
	sb.anti_aliasing = true
	if shadow:
		sb.shadow_color = UI_SH_COL
		sb.shadow_size = 2
		sb.shadow_offset = UI_SH
	return sb


func ui_panel(parent: Node, pos: Vector2, size: Vector2, sb: StyleBox) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", sb)
	parent.add_child(p)
	return p


## 누르면 납작해졌다가 뗄 때 탄력 있게 돌아온다
func ui_squash(b: BaseButton) -> void:
	b.button_down.connect(func() -> void:
		b.pivot_offset = b.size * 0.5
		if b.has_meta("sq_tw"):
			var old: Tween = b.get_meta("sq_tw")
			if old and old.is_valid():
				old.kill()
		var tw := b.create_tween().set_ignore_time_scale(true)
		tw.tween_property(b, "scale", Vector2(1.07, 0.88), 0.06)
		b.set_meta("sq_tw", tw))
	b.button_up.connect(func() -> void:
		if b.has_meta("sq_tw"):
			var old: Tween = b.get_meta("sq_tw")
			if old and old.is_valid():
				old.kill()
		var tw := b.create_tween().set_ignore_time_scale(true)
		tw.tween_property(b, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		b.set_meta("sq_tw", tw))


## 알약 버튼 겉모습: 평소·눌림(가라앉음: 그림자 짧게, 12% 어둡게). 폰에서는 hover 가 남으므로 hover = 평소
func ui_button_styles(b: Button, fill: Color) -> void:
	var small := b.size.y < 110.0
	var n := ui_stone(fill, "btn_s" if small else "btn")
	var dn := ui_stone(fill.darkened(0.12), "btn_dn_s" if small else "btn_dn")
	dn.content_margin_top = 10.0
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", n)
	# focus 는 눌림 위에 덧그려지므로 비워 둔다 (채운 상자면 가라앉은 모습을 덮는다)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_stylebox_override("pressed", dn)
	b.add_theme_stylebox_override("hover_pressed", dn)
	for fc: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(fc, INK)


## 새긴 돌판: 테 5 + 아래 두께 12, 안쪽에 파인 테두리. half 1 = 왼쪽 반, 2 = 오른쪽 반 (가운데 이음매에는 테가 없다)
func ui_slab(parent: Node, pos: Vector2, size: Vector2, half := 0, slab := STONE, kind := "slab") -> Panel:
	var sb := ui_stone(slab, kind, half)
	var p := ui_panel(parent, pos, size, sb)
	p.set_meta("sb", sb)
	return p


## 돌에 새긴 글자: 진한 갈색, 아래에 밝은 입술(파인 홈의 아랫단)
func ui_glyph(parent: Control, fs: int, col := GLYPH) -> Label:
	var ls := LabelSettings.new()
	ls.font = _font
	ls.font_size = fs
	ls.font_color = col
	ls.outline_size = 0
	ls.shadow_color = Color(1, 1, 1, 0.75)
	ls.shadow_offset = Vector2(0, 3)
	ls.shadow_size = 0
	var l := Label.new()
	l.label_settings = ls
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return l


## 글이 폭 w 안에 들어가는 글자 크기 (영어가 길어도 넘치지 않게)
func fit_fs(txt: String, base: int, w: float) -> int:
	return mini(base, int(base * w / maxf(1.0, _font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, base).x)))


func _build_journey_ui() -> void:
	# Portrait: keep the next landing clear. Information belongs above the road, actions on the right.
	var layer := CanvasLayer.new()
	layer.layer = 6
	add_child(layer)
	route_label = _label(layer, 28, 156, 48)
	route_label.label_settings = route_label.label_settings.duplicate()
	route_label.label_settings.font_color = INK
	route_label.label_settings.outline_size = 6
	action_label = _label(layer, 28, 248, 84)
	action_label.size.x = 504
	action_label.position.x = 24
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_msg_l.position = Vector2(24, 358)
	_msg_l.size = Vector2(500, 146)
	_msg_l.label_settings = _msg_l.label_settings.duplicate()
	_msg_l.label_settings.font_size = 42
	_msg_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_score_l.label_settings = _score_l.label_settings.duplicate()
	_score_l.label_settings.font_size = 40
	_score_l.position = Vector2(24, 50)
	_score_l.size = Vector2(672, 50)
	# 화면 글은 판 없이 흰 외곽선만: 길을 가리지 않게 덜어낸다
	route_label.label_settings.outline_size = 10
	route_label.label_settings.font_size = 26
	action_label.label_settings.outline_size = 10
	_msg_l.label_settings.outline_size = 12
	_score_l.label_settings.font_size = 56
	_score_l.label_settings.outline_size = 12
	for c in _score_l.get_parent().get_children():
		if c is Label and (c as Label).text.begins_with("<"):
			back_l = c as Label
	var result_layer := CanvasLayer.new()
	result_layer.layer = 8
	add_child(result_layer)
	result_card = Control.new()
	result_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_card.visible = false
	result_layer.add_child(result_card)
	# 결과 = 새긴 돌판: 크림 판 + 위에 메달색 띠, 가운데 위에 도장이 쾅
	ui_panel(result_card, Vector2(40, 230), Vector2(640, 520), ui_stone(STONE, "card"))
	result_band_sb = ui_box(D, 0, 0, false)
	result_band_sb.corner_radius_top_left = 24
	result_band_sb.corner_radius_top_right = 24
	# 그림 돌판 위에 평평한 색 띠를 얹지 않는다(색은 메달 도장이 맡는다). 띠 색 바꾸는 코드는 그대로 둬도 안 보인다
	result_title = _label(result_card, 52, 316, 72)
	result_values = _label(result_card, 36, 392, 140)
	result_note = _label(result_card, 26, 536, 96)
	result_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_note.position.x = 64
	result_note.size.x = 592
	# 돌판 위 글은 먹색만 (흰 테두리는 3D 위에 바로 쓰는 글에만)
	for l: Label in [result_title, result_values, result_note]:
		l.label_settings.outline_size = 0
	result_seal = Control.new()
	result_seal.position = Vector2(285, 150)
	result_seal.size = Vector2(150, 150)
	result_seal.pivot_offset = Vector2(75, 75)
	result_seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_card.add_child(result_seal)
	seal_sb = ui_stone(BAD.darkened(0.12), "seal")
	ui_panel(result_seal, Vector2.ZERO, Vector2(150, 150), seal_sb)
	var seal_fr := StyleBoxFlat.new()
	seal_fr.draw_center = false
	seal_fr.set_border_width_all(3)
	seal_fr.border_color = Color(STONE, 0.85)
	seal_fr.set_corner_radius_all(12)
	seal_fr.anti_aliasing = true
	# 메달 그림에 테두리가 그려져 있어 따로 네모 테를 두르지 않는다
	var seal_ls := LabelSettings.new()
	seal_ls.font = _font
	seal_ls.font_size = 52
	seal_ls.font_color = STONE
	seal_ls.outline_size = 0
	seal_ls.shadow_color = Color(0, 0, 0, 0.25)
	seal_ls.shadow_offset = Vector2(0, -2)
	seal_ls.shadow_size = 0
	seal_l = Label.new()
	seal_l.label_settings = seal_ls
	seal_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	seal_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_seal.add_child(seal_l)
	seal_l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	seal_l.pivot_offset = Vector2(75, 75)
	seal_crack = Line2D.new()
	seal_crack.default_color = INK
	seal_crack.width = 3.0
	seal_crack.joint_mode = Line2D.LINE_JOINT_SHARP
	seal_crack.points = PackedVector2Array([Vector2(18, 30), Vector2(64, 62), Vector2(52, 96), Vector2(132, 128)])
	seal_crack.visible = false
	result_seal.add_child(seal_crack)
	retry_button = _journey_button(result_card, "구역 다시", Vector2(64, 640))
	retry_button.pressed.connect(func() -> void:
		if wait <= 0.0:
			restart())
	var fresh := _journey_button(result_card, "처음부터", Vector2(368, 640))
	fresh.pressed.connect(func() -> void:
		if wait <= 0.0:
			cp_k = 0
			fresh_run = true
			restart())


func _journey_button(parent: Control, text: String, pos: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(288, 70)
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 30)
	# 다시 하기(금) / 처음부터(흰): 알약 + 누르면 가라앉고 납작
	ui_button_styles(button, D if text in ["구역 다시", "한 번 더"] else WHITE)
	ui_squash(button)
	parent.add_child(button)
	return button


## 글 뒤에 까는 크림 안내 판 (글의 자식이라 글이 커지고 숨으면 같이 따라간다)
func _ui_plate(l: Label, r := 18, bw := 3) -> Panel:
	var p := Panel.new()
	p.show_behind_parent = true
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", ui_box(PLATE, r, bw, false))
	l.add_child(p)
	return p


## 판을 글 길이에 맞춘다. 글이 바뀔 때만 다시 잰다. force 를 주면 그 글로 잰다
func _ui_fit(l: Label, p: Panel, force := "") -> void:
	var txt := force if force != "" else tr(l.text)
	if str(p.get_meta("t", "")) == txt:
		return
	p.set_meta("t", txt)
	p.visible = txt != ""
	if txt == "":
		return
	var ls := l.label_settings
	var w := ls.font.get_multiline_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, l.size.x if l.autowrap_mode != TextServer.AUTOWRAP_OFF else -1.0, ls.font_size).x
	w = minf(w, l.size.x)
	var h := l.get_line_count() * l.get_line_height()
	var x := 0.0
	if l.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
		x = l.size.x - w
	elif l.horizontal_alignment != HORIZONTAL_ALIGNMENT_LEFT:
		x = (l.size.x - w) * 0.5
	p.position = Vector2(x - 16.0, -6.0)
	p.size = Vector2(w + 32.0, h + 12.0)
	# 새 안내가 뜨면 톡 커졌다 앉는다
	if l == _msg_l:
		l.pivot_offset = l.size * 0.5
		l.scale = Vector2(1.18, 1.18)
		l.create_tween().set_ignore_time_scale(true).tween_property(l, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## _process 앞쪽에서 부른다: 한 프레임 전 글에 맞추지만 눈에 띄지 않는다
func _fit_plates() -> void:
	if route_plate == null:
		return
	_ui_fit(route_label, route_plate)
	_ui_fit(action_label, action_plate)
	# 숨은 동안은 비워 둔다: 같은 안내가 다시 떠도 톡 커진다
	if _msg_l.visible:
		_ui_fit(_msg_l, msg_plate)
	else:
		msg_plate.set_meta("t", "")
	# 점수 글은 Tofu 가 숫자만 넣은 뒤 아래에서 다시 쓴다: 게임 중에는 보일 글로 잰다
	_ui_fit(_score_l, score_plate, "" if over else tr("%d점   ·   속도 %02d m/s") % [score, int(v)])
	if back_plate:
		_ui_fit(back_l, back_plate)
	if rate_plate:
		_ui_fit(_rate_btn_l, rate_plate)


## 속도 게이지 = 돌 알약: 크림 테, 멈춤 구간은 옅은 빨강, 채움은 둥근 막대 + 윗빛
func _gauge_build() -> void:
	_bar_bg.self_modulate.a = 0.0
	_bar.self_modulate.a = 0.0
	gauge_frame_sb = ui_box(STONE, 22, 4)
	var frame := ui_panel(_bar_bg, Vector2(-8, -8), Vector2(616, 44), gauge_frame_sb)
	_bar_bg.move_child(frame, 0)
	var danger := ui_panel(_bar_bg, Vector2(0, 0), Vector2(600.0 * VSTOP / VMAX, 28), ui_box(Color(G_SLOW, 0.35), 14, 0, false))
	_bar_bg.move_child(danger, 1)
	gauge_fill_sb = ui_box(GOOD, 14, 0, false)
	gauge_fill = ui_panel(_bar, Vector2.ZERO, Vector2(28, 28), gauge_fill_sb)
	gauge_hl = ui_panel(gauge_fill, Vector2(8, 4), Vector2(0, 6), ui_box(Color(1, 1, 1, 0.4), 3, 0, false))
	var groove := ui_panel(_bar_bg, Vector2(-26, -14), Vector2(652, 56), ui_stone(STONE, "gauge"))
	_bar_bg.move_child(groove, _bar.get_index() + 1)
	tick.color = INK
	tick.size = Vector2(8, 48)
	tick.position.x = 600.0 * VSTOP / VMAX - 4.0
	_bar_bg.pivot_offset = Vector2(300, 14)
	_bar_bg.position.y = 118.0  # 속도 숫자 바로 아래
	_bar_bg.scale = GAUGE_S


## 속도 바: 숫자 아래 짧고 가는 홈. 색은 칠한 그림 팔레트
const GAUGE_S := Vector2(0.42, 0.5)
const G_FAST := Color("3f8f9a")  # 길 금의 청록
const G_MID := Color("d39a3e")   # 황토
const G_SLOW := Color("c8553d")  # 테라코타
const G_TOP := Color("e8b64a")   # 금
const G_DASH := Color("9b6bb8")  # 자수정


func gauge(frac: float, color: Color) -> void:
	super(frac, color)
	if gauge_fill == null:
		return
	var now := Time.get_ticks_msec() * 0.001
	var c := G_FAST if color == GOOD else (G_SLOW if color == BAD else G_MID)
	if dash_t > 0.0:
		c = G_DASH.lerp(WHITE, 0.2 + 0.2 * sin(now * 30.0))
	elif frac >= 0.88:
		c = G_TOP.lerp(Color("fff1d6"), 0.35 + 0.35 * sin(now * 22.0))
	gauge_fill_sb.bg_color = c
	gauge_fill.size.x = maxf(_bar.size.x, 28.0)
	gauge_hl.size.x = maxf(0.0, gauge_fill.size.x - 16.0)
	gauge_frame_sb.border_color = BAD if slow_t > 0.0 else INK
	# 느려지면 떨고, 확 빨라지면 위아래로 불룩
	_bar_bg.position.x = 60.0 + (sin(now * 55.0) * 5.0 * slow_t / STOP_T if slow_t > 0.0 else 0.0)
	if v - gauge_last_v > 5.0:
		gauge_kick = 1.0
	gauge_last_v = v
	gauge_kick = move_toward(gauge_kick, 0.0, get_process_delta_time() / maxf(Engine.time_scale, 0.05) * 4.0)
	_bar_bg.scale = GAUGE_S * Vector2(1.0 + gauge_kick * 0.04, 1.0 + gauge_kick * 0.45)


# ---- 비밀 구역·지름길 고르기: 화면을 오른쪽 → 왼쪽 → 왼쪽 → 위로 쓸면 창이 뜬다 (확인·연습용) ----
const SWIPE_SEQ := ["R", "L", "L", "U"]

func _input(event: InputEvent) -> void:
	var pressed := false
	var released := false
	var pos := Vector2.ZERO
	if event is InputEventScreenTouch:
		pressed = event.pressed
		released = not event.pressed
		pos = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = event.pressed
		released = not event.pressed
		pos = event.position
	else:
		return
	var now := Time.get_ticks_msec() * 0.001
	if pressed:
		swipe_from = pos
		swipe_at = now
	elif released and swipe_at > 0.0:
		var dv := pos - swipe_from
		swipe_at = -1.0
		if dv.length() < 90.0:
			return
		var dir := ("R" if dv.x > 0.0 else "L") if absf(dv.x) > absf(dv.y) else ("D" if dv.y > 0.0 else "U")
		swipe_seq.append([dir, now])
		while swipe_seq.size() > SWIPE_SEQ.size():
			swipe_seq.pop_front()
		if swipe_seq.size() == SWIPE_SEQ.size() and now - float(swipe_seq[0][1]) < 4.0:
			var ok := true
			for i in SWIPE_SEQ.size():
				if swipe_seq[i][0] != SWIPE_SEQ[i]:
					ok = false
			if ok:
				swipe_seq.clear()
				_warp_open()


## 구역 k 안의 지름길(숨은 갈림길·깨는 바닥판) 이름과 구역 시작부터의 거리 (큰길 쪽 갈래 길이로 센다)
func _warp_spots() -> Array:
	var out := []
	for k in Z.size():
		var acc := 0.0
		for it: Dictionary in Z[k].items:
			if it.has("fork"):
				if bool(it.get("hidden", false)) and it.has("name"):
					out.append([k, acc - 60.0, str(it.name)])
				for lg: Array in it.fork[1].legs:
					acc += float(lg[0])
				continue
			if it.has("under") and it.has("crack"):
				out.append([k, acc + float(it.crack[0]) - 45.0, str(it.under.name)])
			for lg: Array in it.legs:
				acc += float(lg[0])
	return out


func _warp_open() -> void:
	if warp_menu:
		warp_menu.visible = true
		return
	var layer := CanvasLayer.new()
	layer.layer = 9
	add_child(layer)
	warp_menu = Control.new()
	warp_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(warp_menu)
	var dim := ColorRect.new()
	dim.color = Color(INK, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	warp_menu.add_child(dim)
	ui_panel(warp_menu, Vector2(30, 120), Vector2(660, 1040), ui_box(STONE, 22, 4))
	var title := Label.new()
	title.text = tr("구역 · 지름길로 가기")
	title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", INK)
	title.position = Vector2(60, 145)
	warp_menu.add_child(title)
	var y := 205.0
	for k in Z.size():
		var b := _warp_button("%d  %s" % [k + 1, tr(str(Z[k].msg))], Vector2(60 + (k % 2) * 305, y + float(k / 2) * 66), Vector2(295, 58), WHITE)
		b.pressed.connect(_warp_go.bind(k, 0.0))
	y += float((Z.size() + 1) / 2) * 66 + 16.0
	for sp: Array in _warp_spots():
		var b := _warp_button("%d  %s" % [int(sp[0]) + 1, tr(str(sp[2]))], Vector2(60 + 0, y), Vector2(600, 54), D)
		b.pressed.connect(_warp_go.bind(int(sp[0]), float(sp[1])))
		y += 60.0
	var close := _warp_button(tr("닫기"), Vector2(220, y + 10.0), Vector2(280, 58), WHITE)
	close.pressed.connect(func() -> void: warp_menu.visible = false)


func _warp_button(text: String, pos: Vector2, size: Vector2, fill: Color) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", 24)
	ui_button_styles(b, fill)
	warp_menu.add_child(b)
	return b


## 구역 k 처음에서 다시 시작하고, at > 0 이면 그 거리(지름길 입구 조금 앞)까지 빨리 감는다
func _warp_go(k: int, at: float) -> void:
	if warp_menu:
		warp_menu.visible = false
	cp_k = k
	cp_st = {"x": 0.0, "z": 0.0, "yw": 0.0, "h": 200.0}
	cp_s = maxf(s_goal, 2.6)
	if k == 0:
		cp_k = 0
	fresh_run = true
	restart()
	warp_to = float(zones[0].start) + at if at > 0.0 else 0.0


## 빨리 감기: 길 위에 붙인 채 한 프레임에 6m 씩. 앞 길이 아직 안 지어졌으면 기다린다. 갈림길은 큰길로
func _warp_tick() -> void:
	if fallen or won:
		warp_to = 0.0
		return
	if dist < _len() - 3.0:  # 갈림길 끝까지 가야 큰길이 골라져 이어진다
		dist = minf(warp_to, dist + 6.0)
	bx = 0.0
	x_goal = 0.0
	by = _h(dist) + 0.05
	vy = 0.0
	on_ground = true
	v = 28.0
	hurt = 0.3
	cam_y = by
	if dist >= warp_to:
		warp_to = 0.0


## 키트 버튼 = GPT 가 그린 팔각 새김 돌 메달(ui_gpt/seal.png)에 기술 색을 물들인 것: 아래 먹 그림자, 누르면 가라앉아 어두워짐,
## 먹 글자. 새로 열리면 톡 튀어나온다 (기본 원·테 도형은 쓰지 않는다)
var seal_tex: Texture2D
func _kit_draw(c: Control) -> void:
	if _stick_zone.has_area():
		super(c)
		return
	var now := Time.get_ticks_msec() * 0.001
	for n in _btns:
		var b: Dictionary = _btns[n]
		var down: bool = b.down
		var br: float = b.r
		var bp: Vector2 = b.pos
		var col: Color = b.color
		var lab: String = b.label
		var pop := clampf((now - float(_btn_born.get(n, -9.0))) / 0.4, 0.0, 1.0)
		var r := br * (1.0 + 0.3 * sin(pop * PI) * (1.0 - pop)) * (0.93 if down else 1.0)
		var p := bp + (Vector2(0, 5) if down else Vector2.ZERO)
		if seal_tex == null:
			seal_tex = load(ART_ROOT + "ui_gpt/seal.png") as Texture2D
		var rr := r * 1.12  # 팔각 메달 모서리까지
		c.draw_texture_rect(seal_tex, Rect2(bp + Vector2(-rr, -rr + 8.0), Vector2(rr, rr) * 2.0), false, Color(INK, 0.4))
		var tint := col.lerp(WHITE, 0.35)
		c.draw_texture_rect(seal_tex, Rect2(p - Vector2(rr, rr), Vector2(rr, rr) * 2.0), false, tint.darkened(0.2) if down else tint)
		var fs := int(clampf(br * 0.38, 22.0, 40.0))
		var tp := p + Vector2(-r, fs * 0.35)
		c.draw_string_outline(_font, tp, lab, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, 7, WHITE)
		c.draw_string(_font, tp, lab, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, INK)
		if n == "split" and dash_t > 0.0:
			c.draw_arc(p, r + 11.0, -PI / 2.0, -PI / 2.0 + TAU * dash_t / DASH_T, 40, C, 9.0, true)
		elif n == "split" and cool > 0.0:
			c.draw_circle(p, r, Color(INK, 0.25))
		if n == "hold" and drum_charge > 0.0:
			var acol := GOOD if drum_charge >= 0.4 else D
			if drum_charge >= 0.95 and fmod(now, 0.24) < 0.12:
				acol = D  # 끝까지 찼다: 발판 줄무늬처럼 금빛 깜빡
			c.draw_arc(p, r + 11.0, -PI / 2.0, -PI / 2.0 + TAU * drum_charge, 40, acol, 9.0, true)


func _process(dt: float) -> void:
	super(dt)
	_crumble_tick()
	for lm: StandardMaterial3D in lava_mats:
		lm.uv1_offset.x = fmod(clock * 0.05, 1.0)
		lm.albedo_color = Color("ff6a1c").lerp(Color("ff9a2c"), 0.5 + 0.5 * sin(clock * 3.0))
	if zone_queue.size() > 0:
		var zq: Dictionary = zone_queue.pop_front()
		if not zq.freed:
			_zone_items(zq, 1)
	if stamp_layer:
		stamp_layer.visible = not _rating
		if plaque_pending.size() == 4 and not (_howto_box and _howto_box.visible):
			var pp := plaque_pending
			plaque_pending = []
			_plaque(str(pp[0]), str(pp[1]), pp[2] as Color, float(pp[3]))
	if wind:
		var wt := 0.0
		if not over and not won and not fallen and not _rating and not (_howto_box and _howto_box.visible):
			wt = clampf((v - 14.0) / 41.0, 0.0, 1.0) * 0.6 + (0.3 if dash_t > 0.0 else 0.0)
			if underground and not on_ground:
				wt = maxf(wt, clampf(absf(vy) / 70.0, 0.0, 1.0) * 0.9)
		wind_lin = move_toward(wind_lin, wt, dt * 1.5)
		wind.volume_db = linear_to_db(maxf(wind_lin, 0.001)) - 8.0
		wind.pitch_scale = 0.7 + wind_lin * 0.8
	_fit_plates()
	if not route_label:
		return
	var howto_visible := _howto_box != null and _howto_box.visible
	route_label.visible = not howto_visible and not _rating and not over
	action_label.visible = route_label.visible
	_score_l.visible = not howto_visible  # 설명 카드·타이틀 위에 "0점" 판이 떠 있지 않게
	result_card.visible = over and not _rating
	if over:
		_over_l.visible = false
		return
	_score_l.text = "%d m/s" % int(v)
	var k := maxi(cur_k, cp_k)
	route_label.text = "%02d / %02d   ·   %s" % [k + 1, Z.size(), _format_time(run_elapsed)]
	action_label.text = ""  # 평소엔 비워 둔다: 필요한 순간(발판·다리·얼음벽)에만 뜬다
	for drum: Dictionary in drums:
		if dist >= float(drum.a) and dist < float(drum.b) and on_ground:
			action_label.text = tr("발판 힘 %d%% · %s") % [int(drum_charge * 100.0), tr("손을 떼서 발사!" if drum_charge >= 0.4 else "버티기를 길게 눌러")]
			return
	if k == 5 and not tutorial:
		for th: Thing in things:
			if not th.flat and th.kd == KIND.ice and th.d > dist and th.d - dist < 85.0:
				action_label.text = tr("얼음벽 4.5 / 내 몸 %.1f\n%s") % [s_goal, tr(("돌진 중! 그대로 뚫어" if dash_t > 0.0 else "눈으로 키우거나 · 벽 앞에서 쪼개 돌진") if s_goal < 4.5 else "충분히 커졌다 · 벽을 깨자")]
				return


## 길 안내: 글 길이만큼 오래 보이고, 1.8초 동안은 짧은 사건 글이 덮지 못한다
func guide(t: String) -> void:
	super.msg(t, clampf(2.4 + tr(t).length() * 0.05, 2.8, 5.0))
	guide_until = clock + 1.8


func msg(t: String, dur := 0.6) -> void:
	if clock < guide_until:
		return
	super.msg(t, maxf(dur, 1.2))


func _current_tick(dt: float, hold: bool) -> void:
	for flow: Dictionary in currents:
		if dist < float(flow.a) - 80.0 or dist > float(flow.b) + 10.0:
			continue
		var pulse := 0.5 + 0.5 * sin(clock * 1.8 + float(flow.a) * 0.02)
		var fm := _pm("chip") if pulse < 0.5 else _pm("chip", D)
		for node: MeshInstance3D in flow.markers:
			if is_instance_valid(node):
				node.material_override = fm
		if dist >= float(flow.a) and dist < float(flow.b) and bx > float(flow.x0) and bx < float(flow.x1) and on_ground:
			x_goal += float(flow.dir) * (2.5 + pulse * 5.0) / sqrt(s / 2.0) * (0.14 if hold else 1.0) * dt
			# Flow pushes the body, so shedding weight also changes the steering problem.
			if not hold:
				v = minf(v + 9.0 * dt, VMAX * 0.9)
				if not ride_told:
					ride_told = true
					guide("물살을 타면 빨라진다!")
			return


func _drum_tick(dt: float, hold: bool) -> void:
	var active: Dictionary = {}
	for drum: Dictionary in drums:
		if dist >= float(drum.a) and dist < float(drum.b) and on_ground and absf(bx) <= 8.0 and drum_used != float(drum.a):
			active = drum
			break
	if not active.is_empty():
		if hold:
			var before := drum_charge
			drum_charge = minf(1.0, drum_charge + dt * (0.8 + s_goal * 0.1))
			# The moving pressure bed carries the stone while held; no artificial stop death.
			v = maxf(v, 12.5)
			if before < 0.4 and drum_charge >= 0.4:
				sfx("charge")
		elif was_holding and drum_charge >= 0.4:
			vy = (36.0 + drum_charge * 8.0) / pow(s / 2.0, 0.22)
			v = maxf(v, 45.0 + 9.0 * drum_charge)
			by += 0.1
			on_ground = false
			drum_used = float(active.a)
			_burst(_pos(dist, bx, by), D, 12, 10.0, 0.6)
			shake = 0.4
			bonus += 60
			_hitstop(0.0, 10.0)
			_score_chip(_pos(dist, bx, by), D)
			sfx("launch")
			drum_last = drum_charge  # 하늘 수로: 금빛(0.95+)에서 뗐는지 갈림길이 본다
			drum_last_d = dist
			drum_charge = 0.0
		else:
			drum_charge = maxf(0.0, drum_charge - dt * 0.8)
		# 줄무늬: 흰색 → 초록(쏠 수 있다) → 금빛 깜빡임(끝까지 찼다)
		var dcol := GOOD if drum_charge >= 0.4 else WHITE
		if drum_charge >= 0.95 and fmod(clock, 0.24) < 0.12:
			dcol = D
		var dm := _pm("chip", dcol)
		for node: MeshInstance3D in active.nodes:
			if is_instance_valid(node):
				node.material_override = dm
	else:
		drum_charge = 0.0
	was_holding = hold


func _finish() -> void:
	won = true
	finish_time = run_elapsed
	finish_speed = v
	bonus += 1000 + int(v * 10.0)
	score = score_base + int(dist) + bonus
	cp_k = 0
	fresh_run = true
	new_record = best_time <= 0.0 or finish_time < best_time
	if new_record:
		best_time = finish_time
	record_score = maxi(record_score, score)
	var config := ConfigFile.new()
	config.set_value("record", "time", best_time)
	config.set_value("record", "score", record_score)
	config.save(RECORD)
	play("win")
	_burst(_pos(dist, bx, by + s), D, 16, 12.0, 0.8)
	# 신전 뒤 금빛 기둥이 가운데부터 부채꼴로 솟는다
	for i in rays.size():
		if not is_instance_valid(rays[i]):
			continue
		var rh: Node3D = rays[i]
		rh.visible = true
		rh.create_tween().tween_property(rh, "scale:y", 55.0, 0.9).set_delay(0.2 + absf(i - 3) * 0.08).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_ring(_pos(dist, bx, by + 0.3), D, 12.0, 0.6)
	_stamp("바다다!", 6, _pos(dist, bx, by + s), INK, 1.25, 2.2, D.lightened(0.6))
	end_cam = cam.position
	end_fov = cam.fov


func _ending_tick(dt: float) -> void:
	won_t += dt
	v = move_toward(v, 0.0, dt * 24.0)
	dist = minf(goal_d + 12.0, dist + v * dt)
	by = _h(dist)
	bx = lerpf(bx, 0.0, dt * 2.0)
	on_ground = true
	_place(dt)
	# 끝 카메라: 제 상태로 돌아 올라가며 신전과 바다를 넓게 연다 (_place 의 카메라를 덮어쓴다)
	var e := ease(clampf(won_t / 3.2, 0.0, 1.0), -2.0)
	var yw := _yaw(goal_d)
	var fw := Vector3(-sin(yw), 0.0, -cos(yw))
	var rt := Vector3(cos(yw), 0.0, -sin(yw))
	var center := _pos(goal_d + 10.0, 0.0, _h(goal_d))
	var a := lerpf(-1.1, 0.4, e)
	var want := center + (rt * sin(a) - fw * cos(a)) * lerpf(16.0, 46.0, e) + Vector3.UP * lerpf(4.0, 26.0, e)
	end_cam = end_cam.lerp(want, minf(1.0, dt * 2.5))
	cam.position = end_cam
	cam.look_at(pivot.position.lerp(_pos(goal_d + 24.0, 0.0, _h(goal_d) + 12.0), e), Vector3.UP)
	end_fov = lerpf(end_fov, lerpf(48.0, 64.0, e), minf(1.0, dt * 2.0))
	cam.fov = end_fov
	if fmod(won_t, 0.45) < dt:
		_burst(_pos(goal_d + 24.0, randf_range(-14.0, 14.0), _h(goal_d) + 20.0), [D, STONE, B].pick_random(), 8, 10.0, 0.6)
	if won_t > 3.2:
		end()


func end() -> void:
	if over:
		return
	Engine.time_scale = 1.0
	if ram_tick:
		ram_tick.visible = false
	if not won:
		run_deaths += 1
		if score > record_score:
			record_score = score
			var cfg := ConfigFile.new()
			cfg.load(RECORD)
			cfg.set_value("record", "score", record_score)
			cfg.save(RECORD)
	super()
	result_title.text = tr("금메달" if finish_time <= GOLD_TIME else ("은메달" if finish_time <= SILVER_TIME else "동메달")) + tr(" · 바다 도착") if won else tr("다시 굴러가자")
	var record_text := _format_time(best_time) if best_time > 0.0 else tr("아직 없음")
	result_values.text = tr("%s   ·   %d점\n최고 완주 %s\n%s") % [_format_time(finish_time if won else run_elapsed), score, record_text, tr("새 시간 기록!") if new_record else (tr("최고 점수 %d") % record_score)]
	result_note.text = tr("금 3:00 / 은 4:00 / 동 완주\n재도전 %d회 · 출발부터 실패 시간 포함") % run_deaths if won else tr("%s\n%s에서 이어서") % [tr(failure_reason), tr(str(Z[maxi(cp_k, 0)].msg))]
	retry_button.text = tr("한 번 더" if won else "구역 다시")
	_over_l.visible = false
	result_card.visible = true
	# 결과 돌판 위 도장이 속도 게이지와 겹치지 않게 숨기고, 돌 조각은 돌판 위로 (지명판은 거둔다)
	_bar_bg.visible = false
	if stamp_layer:
		stamp_layer.layer = 9
		if plaque_tw:
			plaque_tw.kill()
		plaque.visible = false
		plaque_pending = []
	# 도장: 완주 = 메달색 별, 실패 = 붉은 도장에 의성어 한 마디 (까닭은 도장이 말하므로 아래 글에서 뺀다)
	if won:
		var medal: Color = D if finish_time <= GOLD_TIME else (SILVER if finish_time <= SILVER_TIME else BRONZE)
		seal_sb.modulate_color = medal
		seal_l.text = "★"
		seal_l.label_settings.font_size = 84
		seal_l.label_settings.font_color = INK
		result_band_sb.bg_color = medal
		seal_crack.visible = false
	else:
		seal_sb.modulate_color = BAD.darkened(0.12)
		var w := tr(failure_reason if failure_reason != "" else "털썩…")
		seal_l.text = w
		seal_l.label_settings.font_size = fit_fs(w, 52, 118)
		seal_l.label_settings.font_color = STONE
		result_band_sb.bg_color = ROCK
		seal_crack.visible = true
		result_note.text = tr("%s에서 이어서") % tr(str(Z[maxi(cp_k, 0)].msg))
	# 돌판이 아래에서 튀어 올라 앉는다
	result_card.pivot_offset = Vector2(360, 490)
	result_card.position = Vector2(0, 90)
	result_card.modulate.a = 0.0
	if result_tw:
		result_tw.kill()
	result_tw = create_tween().set_ignore_time_scale(true).set_parallel()
	result_tw.tween_property(result_card, "position:y", 0.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	result_tw.tween_property(result_card, "modulate:a", 1.0, 0.15)
	# 도장이 크게 기울어 내려와 쾅 찍히고, 돌판이 덜컹
	result_seal.scale = Vector2.ONE * 2.6
	result_seal.rotation = -0.5
	result_seal.modulate.a = 0.0
	if result_tw2:
		result_tw2.kill()
	result_tw2 = create_tween().set_ignore_time_scale(true)
	result_tw2.tween_interval(0.3)
	result_tw2.tween_property(result_seal, "modulate:a", 1.0, 0.05)
	result_tw2.parallel().tween_property(result_seal, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	result_tw2.parallel().tween_property(result_seal, "rotation", -0.08, 0.14)
	result_tw2.tween_callback(func() -> void:
		sfx("bonk", 4.0, 0.6)
		_stamp_chips(result_seal.position + Vector2(75, 150), 6, seal_sb.modulate_color))
	var jolt := func(k: float) -> void:
		result_card.position = Vector2(sin(k * 50.0) * 8.0 * (1.0 - k), cos(k * 37.0) * 5.0 * (1.0 - k))
	result_tw2.tween_method(jolt, 0.0, 1.0, 0.22)
	if seal_tw:
		seal_tw.kill()
	seal_l.scale = Vector2.ONE
	if new_record:
		seal_l.pivot_offset = seal_l.size * 0.5
		seal_tw = seal_l.create_tween().set_ignore_time_scale(true).set_loops()
		seal_tw.tween_property(seal_l, "scale", Vector2.ONE * 1.08, 0.5).set_trans(Tween.TRANS_SINE)
		seal_tw.tween_property(seal_l, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)


func _format_time(seconds: float) -> String:
	var centis := maxi(0, int(seconds * 100.0))
	return "%02d:%02d.%02d" % [centis / 6000, (centis / 100) % 60, centis % 100]


func _flow_arrow() -> ArrayMesh:
	if arrow_mesh:
		return arrow_mesh
	arrow_mesh = ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3(-0.8, 0, -0.28), Vector3(0, 0, -0.28), Vector3(0, 0, -0.8), Vector3(1, 0, 0), Vector3(0, 0, 0.8), Vector3(0, 0, 0.28), Vector3(-0.8, 0, 0.28)])
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP, Vector3.UP])
	# 붓결 그림이 얹히게 위에서 내려다본 자리를 그대로 UV 로
	var uvs := PackedVector2Array()
	for vtx: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
		uvs.append(Vector2(vtx.x * 0.5 + 0.5, vtx.z * 0.5 + 0.5))
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 6, 1, 1, 6, 5, 2, 4, 3, 2, 5, 4, 2, 1, 5])
	arrow_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return arrow_mesh


# ---- 튜토리얼 ----
## 타이틀의 [튜토리얼] 버튼: 짧은 연습 코스로 다시 시작한다. 끝 신전에 닿으면 진짜 길 처음으로.
func start_tutorial() -> void:
	tutorial = true
	Z = _zones_def()
	cp_k = 0
	fresh_run = true
	restart()


func _tutorial_done() -> void:
	tutorial = false
	Engine.time_scale = 1.0
	Z = _zones_def()
	cp_k = 0
	fresh_run = true
	restart()
	sfx("charge", 0.0, 0.8)
	msg("튜토리얼 끝!\n이제 진짜 길로", 2.5)


## 동작이 필요한 자리: 그 버튼을 누를 때까지 느리게(0.2배), 버튼은 깜빡이고 무엇을 할지 크게 보여 준다
func _gate_tick() -> void:
	for i in range(gates.size() - 1, -1, -1):
		var g: Array = gates[i]
		if dist < float(g[0]) or fallen:
			continue
		var nm: String = g[1]
		if kit_just(nm) or kit_held(nm) or dist > float(g[0]) + 40.0 or not _btns.has(nm):
			gates.remove_at(i)
			Engine.time_scale = 1.0
			if _btns.has(nm):
				_btns[nm].color = SKILL_COL[nm]
			continue
		Engine.time_scale = 0.2
		_btns[nm].color = WHITE if fmod(clock, 0.24) < 0.12 else SKILL_COL[nm]
		msg(tr(str(g[2])), 0.2)
		return


func _tutorial_list() -> Array:
	return [
		{"msg": "연습 1 · 끌어서 조향", "mode": "back", "skill": "", "road": STONE, "floor": WATER, "accent": ROCK, "scen": "rock",
			"objective": "손가락을 좌우로 끌어 항아리를 깔아 봐",
			"items": [{"legs": [[30, -4, 7], [100, -15, 7], [30, -4, 7]],
				"put": [["pot", 28, -3], ["pot", 36, 3], ["pot", 44, -3], ["pot", 52, 3], ["pot", 60, 0], ["pot", 66, 0], ["pillar", 84, -3],
					["pot", 90, 3], ["pot", 95, 3], ["pillar", 110, 3], ["pot", 116, -3], ["pot", 121, -3], ["pot", 132, 0], ["pot", 140, 0]],
				"say": [[3, "손가락을 좌우로 끌어 봐"], [24, "항아리를 깔면 커진다"], [76, "빨간 기둥은 피해!"]]}]},
		{"msg": "연습 2 · 뛰기", "mode": "side", "skill": "jump", "road": STONE, "floor": GRASS, "accent": B, "scen": "aq",
			"objective": "틈 앞에서 뛰기",
			"items": [{"legs": [[12, -2, 5], [34, -5, 2.2, 0, "aq"], [14, -1, 2.2, 0, "gap"], [44, -6, 2.2, 0, "aq"], [16, -1, 2.2, 0, "gap"], [36, -4, 2.2, 0, "aq"], [15, 0, 4]],
				"put": [["pot", 20, 0], ["pot", 28, 0], ["pot", 70, 0]],
				"gate": [[38, "jump", "지금 뛰기!"], [94, "jump", "한 번 더, 뛰기!"]],
				"say": [[2, "앞에 틈이 있다"]]}]},
		{"msg": "연습 3 · 쪼개기", "mode": "back", "skill": "split", "road": GRASS, "floor": GRASS, "accent": A, "scen": "village",
			"objective": "쪼개면 가볍고 1초 동안 돌진한다",
			"items": [{"legs": [[30, -5, 7], [70, -9, 7], [30, -4, 7]],
				"put": [["pot", 6, -2], ["pot", 10, 2], ["pot", 14, -2], ["pot", 18, 2], ["pot", 22, 0], ["pot", 72, 0], ["pot", 80, 0]],
				"row": [[56, "house"]],
				"gate": [[40, "split", "쪼개기!\n돌진해서 집을 뚫어"]],
				"say": [[2, "집은 너무 커서 못 깐다"]]}]},
		{"msg": "연습 4 · 버티기", "mode": "fall", "skill": "hold", "road": ROCK, "floor": WATER, "accent": WHITE, "scen": "cliff",
			"objective": "공중에서 버티기 = 내려찍기 · 땅에서는 제동",
			"items": [{"legs": [[28, -5, 8], [3, -40, 8, 0, "drop"], [70, -8, 12], [30, -5, 7]],
				"put": [["tower", 50, 0], ["tower", 58, -6], ["tower", 58, 6], ["tower", 68, 0], ["pot", 90, 0]],
				"gate": [[33, "hold", "버티기를 꾹!\n파란 머리 탑을 쾅"]],
				"say": [[2, "절벽이다"], [80, "탑을 부수면 빨라진다"]]}]},
		{"msg": "연습 5 · 던지기", "mode": "low", "skill": "throw", "road": ICE, "floor": Color("abcbd8"), "accent": B, "scen": "snow",
			"objective": "흰 눈으로 커지고 초록 점선이면 던지기",
			"items": [{"legs": [[30, -4, 8], [90, -9, 8], [40, -4, 8]],
				"snow": [[2, 34, -8, 8]], "row": [[80, "crystal"]],
				"gate": [[50, "throw", "초록 점선!\n던지기"]],
				"say": [[2, "흰 눈 위를 굴러 커져"], [38, "보라 수정은 몸으로 못 지나간다"]], "goal": 140}]},
	]

# ---- English: 폰·브라우저 언어가 한국어가 아니면(또는 주소에 ?lang=en) 영어로 ----
# 라벨은 Godot 자동 번역(같은 글이면 바뀜), 그려지는 버튼·서식 글은 tr() 로 감싼다.
func _lang() -> void:
	var en := true
	if OS.has_feature("web"):
		var q := str(JavaScriptBridge.eval("location.search", true))
		if q.contains("lang=ko"):
			en = false
	if not en:
		TranslationServer.set_locale("ko")
		return
	if TranslationServer.get_translation_object("en") == null:
		var tl := Translation.new()
		tl.locale = "en"
		for k: String in EN:
			tl.add_message(k, EN[k])
		TranslationServer.add_translation(tl)
	TranslationServer.set_locale("en")



const EN := {
	"MAX": "MAX",
	# 실패 의성어
	"와장창!": "Smash!",
	"퐁당!": "Plop!",
	"데구루루~": "Roll-roll~",
	"턱!": "Thunk!",
	"털썩…": "Flop…",
	"띵!": "Clink!",
	"꽝!": "Bang!",
	"쩡!": "Crack!",
	# 새긴 돌판 도장·지명판
	"와르르!": "CRUMBLE!", "번쩍!": "GLEAM!", "쿠웅!": "THOOM!", "쩌억!": "CRRACK!", "푸화악!": "WHOOSH!", "휘오오!": "Whooo!", "바다다!": "The sea!",
	"지하 90m": "90 m underground", "%s에서 이어서": "Continue from %s",
	# 타이틀·튜토리얼
	"굴러라 신전석": "SHRINE\nSTONE", "신전에서 풀려난 돌,\n바다까지 멈추지 말고 굴러라": "A stone freed from the temple,\nroll to the sea without stopping",
	"최고 완주 %s": "Best finish %s", "▶  시작": "▶  Start", "튜토리얼": "Tutorial",
	"튜토리얼 끝!\n이제 진짜 길로": "Tutorial over!\nNow the real road",
	"연습 1 · 끌어서 조향": "Practice 1 · Drag to steer", "연습 2 · 뛰기": "Practice 2 · JUMP", "연습 3 · 쪼개기": "Practice 3 · SPLIT",
	"연습 4 · 버티기": "Practice 4 · HOLD", "연습 5 · 던지기": "Practice 5 · THROW",
	"손가락을 좌우로 끌어 항아리를 깔아 봐": "Drag your finger left and right to crush pots", "손가락을 좌우로 끌어 봐": "Drag your finger left and right",
	"항아리를 깔면 커진다": "Crushing pots makes you bigger", "빨간 기둥은 피해!": "Dodge the red pillars!",
	"틈 앞에서 뛰기": "JUMP in front of the gap", "앞에 틈이 있다": "There's a gap ahead", "지금 뛰기!": "JUMP now!", "한 번 더, 뛰기!": "Again, JUMP!",
	"쪼개면 가볍고 1초 동안 돌진한다": "SPLIT makes you lighter and you dash for 1 second", "집은 너무 커서 못 깐다": "Houses are too big to crush",
	"쪼개기!\n돌진해서 집을 뚫어": "SPLIT!\nDash and break through the house",
	"공중에서 버티기 = 내려찍기 · 땅에서는 제동": "HOLD in the air = slam · on the ground = brake", "절벽이다": "A cliff",
	"버티기를 꾹!\n파란 머리 탑을 쾅": "Press HOLD hard!\nSlam the blue-roofed tower",
	"흰 눈으로 커지고 초록 점선이면 던지기": "Grow in white snow, THROW on the green dotted line",
	"흰 눈 위를 굴러 커져": "Roll on white snow to grow", "보라 수정은 몸으로 못 지나간다": "Your body can't pass purple crystals",
	"초록 점선!\n던지기": "Green dotted line!\nTHROW",
	# tofu.gd (공통 화면)
	"< 메뉴": "< Menu", "< 처음부터": "< Restart", "< 목록": "< List", "평가": "Rate", "탭해서 시작": "Tap to start",
	"이 게임 어때요?": "How's this game?", "닫기": "Close", "한마디": "Comment", "고마워요!": "Thanks!",
	"보내는 중": "Sending", "한마디 보냈어요": "Comment sent", "저장 안 됨 · 별을 다시 탭": "Not saved · tap a star again",
	# 버튼
	"뛰기": "JUMP", "쪼개기": "SPLIT", "버티기": "HOLD", "던지기": "THROW",
	# 구역
	"신전 계곡": "Temple Valley", "수로 · 뛰기": "Aqueduct · JUMP", "갈림길 · 쪼개기": "Crossroads · SPLIT",
	"절벽 · 버티기": "Cliffs · HOLD", "광장 · 위에서": "Plaza · From Above", "설산 · 눈 굴리기": "Snow Peak · Snowball",
	"협곡 · 던지기": "Canyon · THROW", "해안 · 추격": "Coast · Chase", "조수 정원 · 물살 타기": "Tide Garden · Currents",
	"공명 제단 · 눌렀다 놓기": "Echo Altar · Press and Release", "바다 신전 · 마지막 도약": "Sea Temple · Final Leap",
	"물살을 타면 빨라진다 · 버티면 제자리": "Ride the current = speed up · HOLD = stay put", "물살을 타면 빨라진다!": "Riding the current speeds you up!", "눈 위를 구르면\n몸이 커진다!": "Roll on snow\nand your body grows!", "물살을 타고\n초록이면 던져": "Ride the current\nTHROW on green",
	"황금 발판에서 버티기 → 힘이 차면 손을 떼 발사": "HOLD on the golden pad → when charged, let go to launch",
	"키우고 → 던지고 → 가볍게 날아 바다 신전까지": "Grow → throw → fly light all the way to the sea temple",
	# 안내
	"11개의 길 너머\n마지막 신전으로": "Beyond 11 roads\nto the last temple",
	"끌어서 항아리를 깔아봐": "Drag to crush the pots",
	"빨간 기둥은 옆으로 피해": "Dodge the red pillars to the side",
	"큼 = 무거움": "Big = heavy",
	"노란 경사대에서\n저절로 날아간다": "Yellow ramp\nlaunches you",
	"다리는 가운데로": "Keep to the middle on bridges",
	"틈! 뛰기": "Gap! JUMP", "담도 뛰어": "Jump the wall too", "석상!\n뛰거나 깔거나": "Statue!\njump or crush", "석상 뒤에 틈!\n깔고 뛰거나 넘거나": "Gap behind the statue!\nCrush and jump, or jump over",
	"담과 틈:\n한 번에!": "Wall and gap:\nin one go!",
	"쪼개면 가볍고\n잠깐 돌진: 집도 뚫는다": "SPLIT makes you light\nShort dash: breaks even houses",
	"섞기: 깔면 무거워\n회전에서 밀린다": "Mix: crushing makes you heavy\nturns push you out",
	"쪼개서 가볍게!": "SPLIT to get light!", "뛰어!": "JUMP!",
	"떨어지며 조종": "Steer while falling",
	"파란 머리 탑!\n떨어지며 버티기로 쾅": "Blue-roofed tower!\nHOLD while falling to SLAM",
	"탑을 부수면 빨라진다": "Smashed towers speed you up",
	"황금 신상은\n버티기로만 깨진다": "The golden idol breaks\nonly with HOLD",
	"섞기: 뛰고\n내려찍고": "Mix: jump\nthen slam",
	"구멍 피해\n신상을 내려찍어": "Avoid the holes\nslam down on the idol",
	"회전!\n버티거나 쪼개": "Turn!\nHOLD or SPLIT",
	"길을 골라": "Pick a path", "좁은 문!": "Narrow gate!",
	"흰 눈 위를 구르면\n커진다": "Roll on white snow\nto grow",
	"얼음벽만큼 커야\n깬다": "Be as big as the ice wall\nto break it",
	"오르막 전에\n노란 길에서 녹여": "Before the hill\nmelt down on the yellow road",
	"다시 키워!": "Grow again!", "녹는 길": "Melting road",
	"섞기: 눈으로 키워\n얼음벽 깨기": "Mix: grow in snow\nbreak the ice wall",
	"무거운 몸으로\n뛰어!": "JUMP\nwith a heavy body!",
	"오르막!\n쪼개서 가볍게": "Hill!\nSPLIT to get light",
	"던지기 = 내 몸 한 덩이를\n앞으로 (작아진다)": "THROW = one chunk of your body\nforward (you shrink)",
	"보라 벽은 몸으로 못 지나간다\n점선이 초록이면 던져": "Your body can't pass purple walls\nTHROW when the dotted line is green",
	"다시 키워": "Grow again", "빠를수록 멀리 닿는다": "Faster = longer throw",
	"노랑은 받고\n빨강은 피해": "Catch yellow\ndodge red",
	"좁다! 빨강은\n쪼개서 막아": "Narrow! Block red\nby SPLITTING",
	"해안 응용: 배운 것을 섞어!": "Coast finale: mix what you learned!",
	"눈으로 키우고": "Grow in snow",
	"회전! 버티기": "Turn! HOLD", "구멍 피해\n내려찍기": "Avoid holes\nslam",
	"물살은 몸을 옆으로!\n화살표를 봐": "Currents push you sideways!\nWatch the arrows",
	"버티면 덜 밀린다": "HOLD = pushed less",
	"이번엔 반대 방향\n뛰면 물살을 벗어난다": "Opposite way this time\nJUMP to leave the current",
	"섞기: 눈으로 탄약 확보": "Mix: get ammo from snow",
	"물살을 버티며\n초록이면 던져": "HOLD in the current\nTHROW on green",
	"벽을 열고 물살 밖에서 뛰어!": "Open the wall, JUMP out of the current!",
	"반대 물살 착지\n가운데로 조종": "Land in the reverse current\nsteer to the middle",
	"앞의 넓은 틈:\n보통 점프로는 짧다": "Wide gap ahead:\na normal jump falls short",
	"황금 발판에서 버티기!\n초록이 되면 손을 떼": "HOLD on the golden pad!\nLet go when it turns green",
	"공중에서 버티면 내려찍기\n착지까지는 손을 떼자": "HOLD in the air = slam\nlet go until you land",
	"섞기: 눈으로 몸을 키워": "Mix: grow your body in snow",
	"무거운 몸으로 발판 누르기\n초록에서 손을 떼!": "Press the pad with a heavy body\nlet go on green!",
	"착지 후 수정을 던져 깨고": "After landing, THROW to break the crystal",
	"마지막 신전이 보인다": "The last temple is in sight",
	"마지막 응용\n눈으로 탄약을 만들고": "Final mix\nmake ammo with snow",
	"물살 뒤 황금 발판\n버티다가 손을 떼!": "Golden pad after the current\nHOLD, then let go!",
	"돌아왔다\n신전의 빛을 향해": "Back again\ntoward the temple's light",
	# 순간 글
	"← 갈림길 →": "← Fork →", "왼쪽!": "Left!", "오른쪽!": "Right!", "삐걱!": "Creak!",
	"지하로!": "To the underground!", "떨어진다!": "Falling!", "날아라!": "Fly!",
	"떨어짐!": "Fell!", "쾅!": "Boom!", "수로 합류! 다음 틈을 봐": "Joined the aqueduct! Watch the next gap",
	"돌진 관통!": "Dashed right through!", "느려!": "Slow!", "멈췄다": "Stopped",

	"커진다": "Getting bigger", "녹는다": "Melting", "너무 작다": "Too small", "던졌다!": "Threw it!", "깼다!": "Broke it!",
	"닿는다! 던져": "It reaches! THROW", "%d개 쾅!": "%d smashed!", "쾅 착지!": "Boom landing!",
	"황금 신상 쾅! 가속": "Golden idol smashed! Speed up", "탑 쾅! 가속": "Tower smashed! Speed up", "커졌다!": "Bigger!",
	"수정은 던져서!": "Crystals: THROW at them!", "위에서 버티기로 쾅!": "HOLD from above to slam!", "드르륵": "Scrrrape", "기와에 긁혀 느려졌다\n떨어질 때 버티기 = 깨고 가속": "Scraped by the roof tiles, slowed down\nHOLD while falling = break it and speed up",
	"더 커지거나\n직전에 쪼개서 돌진!": "Grow bigger, or\nSPLIT right before and dash!",
	"더 커져야!": "Must be bigger!", "쿵!": "Thud!", "더 못 쪼갠다": "Can't split any more",
	"쪼개서 돌진!": "SPLIT dash!", "막았다!": "Blocked!", "받았다!": "Caught it!",
	"숨은 수정 동굴!\n보석을 모아 노란 출구로": "Hidden crystal cave!\nCollect gems, go to the yellow exit",
	"보석 +40": "Gem +40", "힘이 찼다!\n손을 떼서 날아": "Charged!\nLet go to fly", "공명 도약!": "Echo leap!",
	"바다에 도착했다!": "You reached the sea!",
	"숨은 수정 동굴": "Hidden crystal cave", "낮잠자는 지하 신전": "The Napping Under-Temple", "다음 틈을 봐": "Watch the next gap",
	"안 닿았다!\n더 빨리, 더 가까이": "Didn't reach!\nFaster, closer",
	# 숨은 길(지름길) 지명판
	"눈 줄을 따라 지그재그": "Zigzag along the snow lanes", "깨고 녹이고 올라": "Break, melt, climb",
	"던지고, 눈으로 다시 채우고": "Throw, then refill in the snow", "무거우면 회전에서 밀린다\n던져서 가볍게": "Heavy = pushed out on turns\nTHROW to get lighter",
	"방파제가 좁아진다": "The breakwater narrows", "뛰어 건너!": "Jump across!",
	"구역 · 지름길로 가기": "Go to zone · shortcuts",
	"끌어서 조향": "Drag to steer", "섞기: 깔고 뛰기": "Mix: crush then jump",
	"치익!": "Sizzle!",
	"지름길!": "Shortcut!", "옛 배수로": "Old Drain", "깊은 물길": "Deep Waterway", "순풍 길": "Tailwind Road", "뒷골목": "Back Alley",
	"숨은 저수조": "Hidden Cistern", "얼음 골짜기": "Ice Gully", "수정 맥 길": "Crystal Vein Cut", "하늘 수로": "Sky Aqueduct",
	"쪼개서 돌진!\n아니면 더 빨리": "SPLIT and dash!\nOr go faster",
	# 결과 카드: 왜 끝났는지









	# 화면 글
	"구역 다시": "Retry zone", "처음부터": "From start", "한 번 더": "Once more",
	"%d점   ·   속도 %02d m/s": "%d pts   ·   speed %02d m/s",
	"%02d / %02d   ·   %s   ·   크기 %.1f": "%02d / %02d   ·   %s   ·   size %.1f",
	"끌어서 항아리를 깔고 빨간 기둥은 피해": "Drag to crush pots, dodge red pillars",
	"뛰기 · 떨어지면 저 아래 지하 신전으로": "JUMP · if you fall, you drop to the underground temple far below",
	"쪼개면 잠깐 돌진 · 집을 뚫고 가볍게 회전": "SPLIT = short dash · break through houses, turn while light",
	"파란 머리 탑·신상 = 공중에서 버티기로 쾅 → 가속": "Blue-roofed towers, idols = HOLD in the air to slam → speed up",
	"집을 깔거나 뛰어넘어 길을 골라": "Crush or jump over houses, pick your road",
	"흰 빗금 눈 = 성장 · 노란 길 = 해빙": "White hatched snow = grow · yellow road = melt",
	"초록 점선에서 던져 수정에 통로를 열어": "THROW on the green dotted line to open a way through crystals",
	"노란 돌은 받아 · 빨간 돌은 피해 / 쪼개서 막아": "Catch yellow stones · dodge red stones / SPLIT to block",
	"발판 힘 %d%% · %s": "Pad power %d%% · %s", "손을 떼서 발사!": "Let go to launch!", "버티기를 길게 눌러": "Keep holding HOLD",
	"얼음벽 4.5 / 내 몸 %.1f\n%s": "Ice wall 4.5 / you %.1f\n%s",
	"돌진 중! 그대로 뚫어": "Dashing! Break straight through", "눈으로 키우거나 · 벽 앞에서 쪼개 돌진": "Grow with snow · or SPLIT and dash at the wall",
	"충분히 커졌다 · 벽을 깨자": "Big enough · let's break the wall",
	"금메달": "Gold medal", "은메달": "Silver medal", "동메달": "Bronze medal", " · 바다 도착": " · Reached the sea",
	"다시 굴러가자": "Let's roll again", "아직 없음": "none yet",
	"%s   ·   %d점\n최고 완주 %s\n%s": "%s   ·   %d pts\nBest finish %s\n%s",
	"새 시간 기록!": "New time record!", "최고 점수 %d": "Best score %d",
	"금 3:00 / 은 4:00 / 동 완주\n재도전 %d회 · 출발부터 실패 시간 포함": "Gold 3:00 / Silver 4:00 / Bronze = finish\n%d retries · time from the start, fails included",
	"%s\n%s에서 이어서": "%s\nContinue from %s",
}
