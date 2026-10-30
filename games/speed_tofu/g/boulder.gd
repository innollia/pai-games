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
	"statue": {"size": Vector3(1.8, 3.2, 1.8), "need": 2.5, "pts": 3, "grow": 0.25, "mass": 0.18, "col": [WHITE, C]},
	"pillar": {"size": Vector3(2.2, 10.0, 2.2), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [WHITE]},
	"fence": {"size": Vector3(3.6, 1.2, 0.4), "need": 0.0, "pts": 1, "grow": 0.04, "mass": 0.04, "col": [WHITE, B]},
	"house": {"size": Vector3(5.0, 4.0, 5.0), "need": 3.4, "pts": 8, "grow": 0.5, "mass": 0.4, "col": [A, B, C]},
	"wall": {"size": Vector3(4.4, 1.4, 1.2), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [ROCK]},
	"post": {"size": Vector3(1.4, 6.0, 1.4), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [D]},
	# 얼음벽: 벽 높이(4.5)만큼 크거나, 쪼갠 직후 돌진이면 깨진다. 뛰어 내려찍기로는 안 깨진다.
	"ice": {"size": Vector3(3.6, 4.5, 1.6), "need": 4.5, "pts": 6, "grow": 0.0, "mass": 0.22, "col": [ICEWALL, WHITE], "nodive": true},
	# 수정: 몸으로는 못 깨고, 던진 덩이로만 깨진다.
	"crystal": {"size": Vector3(3.6, 3.2, 1.2), "need": 99.0, "pts": 4, "grow": 0.0, "mass": 0.0, "col": [C], "nodive": true, "shot": true},
	# 파란 머리(버티기 색) = 공중에서 버티기로 내려찍어야 부서진다. 그냥 굴러 박거나 그냥 떨어지면 튕긴다.
	# 부수면 느려지지 않고 오히려 빨라진다(boost). 집 다음 단계: 탑 → 황금 신상.
	"tower": {"size": Vector3(4.2, 9.0, 4.2), "need": 6.5, "pts": 20, "grow": 0.4, "mass": 0.0, "col": [A, C, WHITE], "slam": true, "boost": 9.0},
	"gold": {"size": Vector3(5.6, 7.0, 5.6), "need": 99.0, "pts": 50, "grow": 0.2, "mass": 0.0, "col": [D], "slam": true, "boost": 16.0},
}
const DASH_T := 1.3  # 쪼갠 뒤 돌진 시간: 집·석상·얼음벽을 크기와 상관없이 뚫는다
const CAVE_SKY := Color("cbb8ff")
# 신전 계곡 깔 것 [종류, 거리, 길 가운데에서 옆으로]
const PUT1 := [
	["pot", 36, 0.0], ["pot", 48, 0.0], ["pot", 64, -2.0], ["pot", 84, -3.0], ["pot", 88, 3.0],
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


class Thing:
	var n: MeshInstance3D
	var kd: Dictionary
	var d := 0.0
	var x := 0.0
	var base := 0.0
	var flat := false
	var col := Color.WHITE


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
var ropes: Array = []  # [거리0, 거리1, 버티는 크기] 흔들다리
var crack_t := 0.0
var pad_t := 0.0
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
var arrow_mesh: ArrayMesh
# v7: 쪼개기 돌진, 수로 밑 수정 동굴(떨어지면 딴 세상)
var dash_t := 0.0
var cave_nodes: Array = []  # 동굴 장식: 떨어지기 전엔 숨겨 둔다
var gems: Array = []        # [거리, 높이(동굴 바닥 위), 노드]


func _setup() -> void:
	_lang()
	howto = "굴러라 신전석\n끌어 조향. 항아리는 깔고 빨강은 피해!\n커지면 무거워진다. 1.5초 느리면 끝.\n\n버튼은 구역마다 열린다.\n뛰기 / 쪼개기 / 버티기 / 던지기\n초록 조준선 → 던져서 보라 수정 깨기\n흰 빗금 눈 = 성장 / 노랑 = 해빙\n수로에서 떨어지면 숨은 수정 동굴!\n쪼개면 1초 돌진: 집·얼음벽 관통\n파란 머리 탑은 공중 버티기로 쾅\n\n물살은 버티거나 뛰어 벗어나고,\n황금 발판은 버티기를 눌렀다 놓기!\n11구역 끝 신전에 도착하자.\n금 3분 / 은 4분 / 동 완주"
	time_limit = 0.0
	howto = howto.replace("끝 신전", "끝 바다 신전")
	howto += "\n발판 힘 40% 이상에서 손을 떼자.\n완주 시간과 최고 기록에 도전!"
	if TranslationServer.get_locale() == "en":
		howto = HOWTO_EN
	_load_art()
	var record := ConfigFile.new()
	if record.load(RECORD) == OK:
		best_time = maxf(0.0, float(record.get_value("record", "time", 0.0)))
		record_score = maxi(0, int(record.get_value("record", "score", 0)))
	_build_journey_ui()
	for c in get_children():
		if c is WorldEnvironment:
			sky_env = (c as WorldEnvironment).environment
	tick = ColorRect.new()
	tick.color = INK
	tick.position = Vector2(600.0 * VSTOP / VMAX - 3.0, -10.0)
	tick.size = Vector2(6, 48)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(tick)
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
	return zs


func _zones_list() -> Array:
	return [
		{"msg": "신전 계곡", "mode": "back", "skill": "", "road": STONE, "floor": WATER, "accent": ROCK, "posts": false, "scen": "rock",
			"items": [{"legs": [[30, 0, 7], [100, -22, 7], [40, -2, 7], [60, 8, 6], [20, 0, 6], [100, -23, 4], [20, 5, 4, 0, "ramp"],
				[22, -10, 5, 0, "gap"], [28, 0, 5], [70, -4, 3.5, 0, "bridge"], [50, -10, 6], [60, 6, 6]], "put": PUT1,
				"say": [[2, "11개의 길 너머\n마지막 신전으로"], [24, "끌어서 항아리를 깔아봐"], [100, "빨간 기둥은 옆으로 피해"], [224, "큰 돌은 무거워\n오르막 전엔 욕심내지 마"], [322, "노란 경사대에서\n저절로 날아간다"], [432, "다리는 가운데로"]]}]},
		{"msg": "수로 · 뛰기", "mode": "side", "skill": "jump", "road": STONE, "floor": GRASS, "accent": B, "posts": false, "scen": "aq",
			# 뛰면 30m 가까이 난다: 틈 뒤에는 착지할 자리를 두고, 담은 착지 뒤 한참 지나서
			"items": [{"legs": [[12, -2, 5], [13, -2, 2.2, 0, "aq"], [45, -6, 2.2, 0, "aq"], [10, -1, 2.2, 0, "gap"], [80, -10, 2.2, 0, "aq"],
				[14, -1, 2.2, 0, "gap"], [80, -10, 2.2, 0, "aq"], [18, -2, 2.2, 0, "gap"], [60, -7, 2.2, 0, "aq"], [22, -2, 2.2, 0, "gap"],
				[30, -3, 2.2, 0, "aq"], [15, 0, 4]],
				"put": [["pot", 38, 0], ["pot", 48, 0], ["pot", 60, 0], ["wall", 125, 0], ["pot", 148, 0], ["pot", 153, 0],
					["wall", 222, 0], ["pot", 240, 0], ["pot", 246, 0], ["statue", 310, 0], ["pot", 322, 0]],
				"say": [[60, "틈! 뛰기"], [112, "담도 뛰어"], [296, "석상!\n뛰거나 깔거나"]]},
				# 섞기: 항아리로 커져야 석상을 깐다. 석상 바로 뒤가 틈이라 튕기면 빠진다. 담 바로 뒤도 틈.
				{"legs": [[30, -4, 2.2, 0, "aq"], [40, -8, 2.2, 0, "aq"], [16, -1, 2.2, 0, "gap"], [40, -6, 2.2, 0, "aq"],
					[12, -1, 2.2, 0, "gap"], [40, -6, 2.2, 0, "aq"], [15, 0, 4]],
					"put": [["pot", 10, 0], ["pot", 18, 0], ["pot", 26, 0], ["statue", 62, 0], ["wall", 121, 0]],
					"say": [[2, "섞기: 깔고 뛰기"], [46, "석상 뒤에 틈!\n깔고 뛰거나 넘거나"], [104, "담과 틈:\n한 번에!"]]}]},
		{"msg": "갈림길 · 쪼개기", "mode": "back", "skill": "split", "road": GRASS, "floor": GRASS, "accent": A, "posts": true, "scen": "village",
			"items": [
				{"legs": [[30, -6, 7], [30, -5, 8]], "put": [["house", 18, -4.5], ["pot", 28, 2], ["pot", 32, 4], ["house", 45, 4], ["pot", 52, -2]],
					"fence": [10], "say": [[6, "쪼개면 가볍고
잠깐 돌진: 집도 뚫는다"]]},
				{"fork": [
					{"legs": [[26, -3, 6, 90], [70, -12, 7]], "put": [["house", 34, -3], ["pot", 40, 3], ["house", 48, 3], ["pot", 56, -3],
						["house", 62, -3], ["house", 76, 3], ["pot", 84, 0]], "fence": [92]},
					{"legs": [[26, -3, 5, -90], [70, -18, 4.5]], "put": [["pot", 45, 0], ["pot", 70, -2], ["pot", 72, 2]], "fence": [56]}]},
				{"legs": [[24, -5, 7]], "put": [["pot", 10, -3], ["pot", 12, 3]]},
				{"fork": [
					{"legs": [[22, -2, 6, 100], [50, -10, 7]], "put": [["house", 30, 3], ["house", 40, -3], ["house", 52, 2], ["statue", 60, -2]]},
					{"legs": [[22, -2, 6, -100], [26, -6, 6], [10, 4, 6, 0, "ramp"], [12, -4, 6, 0, "gap"], [22, -4, 6]],
						"put": [["pot", 30, 0], ["pot", 80, -2], ["pot", 82, 2]]}]},
				{"legs": [[40, -8, 7], [30, 3, 7]], "put": [["house", 15, -3.5], ["house", 30, 3.5], ["pot", 50, 0]], "fence": [60]},
				# 섞기: 집을 깔아 무거워진 뒤 큰 회전(무거우면 밀려 떨어짐) → 쪼개기, 곧바로 경사대 틈 → 뛰기
				{"legs": [[20, -4, 7], [40, -8, 6, 70], [10, 4, 6, 0, "ramp"], [14, -4, 6, 0, "gap"], [30, -6, 7]],
					"put": [["house", 6, -3], ["pot", 10, 0], ["house", 14, 3]],
					"say": [[2, "섞기: 깔면 무거워\n회전에서 밀린다"], [22, "쪼개서 가볍게!"], [64, "뛰어!"]]}]},
		{"msg": "절벽 · 버티기", "mode": "fall", "skill": "hold", "road": ROCK, "floor": WATER, "accent": WHITE, "posts": true, "scen": "cliff",
			"items": [
				{"legs": [[40, -6, 7], [30, -5, 7]], "put": [["pot", 20, -2], ["pot", 25, 2]], "say": [[50, "떨어지며 조종"]]},
				{"legs": [[3, -40, 7, 0, "drop"], [55, -6, 12], [25, -3, 8]],
					"put": [["tower", 23, 0], ["house", 38, 6], ["tower", 52, -6], ["pot", 30, -8], ["pot", 45, 8]],
					"holes": [[30, 42, -12.3, -2], [44, 54, 2, 12.3]], "say": [[30, "파란 머리 탑!\n떨어지며 버티기로 쾅"], [80, "탑을 부수면 빨라진다"]]},
				{"legs": [[3, -30, 8, 0, "drop"], [60, -8, 12], [30, -5, 7]],
					"put": [["tower", 20, -5], ["tower", 34, 5], ["gold", 48, 0], ["pot", 56, -6], ["pot", 58, 6]],
					"holes": [[25, 35, -4, 4], [44, 55, -12.3, -3]], "say": [[2, "황금 신상은\n버티기로만 깨진다"]]},
				# 섞기: 틈 뛰기 → 떨어지며 구멍 피해 집 내려찍기 → 착지 뒤 큰 회전(버티기 또는 쪼개기)
				{"legs": [[20, -4, 8], [10, 4, 6, 0, "ramp"], [16, -6, 6, 0, "gap"], [30, -4, 8], [3, -30, 12, 0, "drop"], [50, -6, 12],
					[30, -5, 7, 60], [20, -3, 7]],
					"put": [["gold", 92, -6], ["pot", 96, 0], ["tower", 100, 6], ["tower", 118, -4]],
					"holes": [[86, 98, 0, 12.3], [102, 114, -12.3, 0]],
					"say": [[2, "섞기: 뛰고\n내려찍고"], [70, "구멍 피해\n신상을 내려찍어"], [124, "회전!\n버티거나 쪼개"]]}]},
		{"msg": "광장 · 위에서", "mode": "top", "skill": "", "road": SOFT, "floor": GRASS, "accent": C, "posts": false, "scen": "plaza",
			"items": [{"legs": [[25, -4, 7], [150, -15, 22, 0, "plaza"], [14, -1, 4, 0, "gate"], [25, -4, 6]],
				"put": [["pillar", 55, -8], ["pillar", 55, 8], ["pillar", 70, 0], ["pillar", 88, -10], ["pillar", 88, 10],
					["house", 62, -16], ["house", 76, -16], ["house", 90, -17],
					["pot", 60, 14], ["pot", 64, 17], ["pot", 68, 13], ["pot", 74, 16], ["pot", 80, 14], ["pot", 84, 18],
					["house", 135, -18], ["house", 135, -12], ["house", 135, -6], ["house", 135, 6], ["house", 135, 12], ["house", 135, 18],
					["pot", 145, -2], ["pot", 160, 2], ["post", 177, -3.6], ["post", 177, 3.6]],
				"fence": [102], "holes": [[115, 121, -6, 0], [150, 156, 6, 12]], "say": [[40, "길을 골라"], [158, "좁은 문!"]]},
				# 섞기: 집 두 채가 길을 막는다(커서 깔거나, 뛰어 내려찍거나) → 바로 틈 뛰기
				{"legs": [[20, -4, 8], [14, -1, 8, 0, "gap"], [30, -6, 8]], "put": [["house", 8, -3.5], ["house", 8, 3.5]],
					"say": [[0, "섞기: 깔고 뛰기"]]}]},
		# 설산: 굴리는 길 자체가 자원. 흰 눈 줄에서 커지고(얼음벽을 깰 자격) 노란 길에서 녹는다(오르막을 넘을 가벼움).
		{"msg": "설산 · 눈 굴리기", "mode": "iso", "skill": "", "road": ICE, "floor": Color("abcbd8"), "accent": B, "posts": false, "scen": "snow",
			"items": [{"legs": [[20, -3, 8], [130, -24, 9], [24, -1, 9], [70, -13, 9], [14, -1, 9], [55, 19, 8], [10, -1, 8],
				[90, -16, 9], [20, -1, 9], [40, -6, 8], [20, -2, 8]],
				"snow": [[28, 142, -9, -1], [182, 240, -9, -1], [322, 410, -9, 9]],
				"sun": [[182, 240, 1, 9], [432, 470, -9, 9]],
				"put": [["pot", 50, 5], ["pot", 72, 4], ["pot", 96, 6], ["pot", 122, 4], ["pot", 200, 5], ["pot", 226, 6], ["pot", 350, 0]],
				"row": [[164, "ice"], [422, "ice"]],
				"holes": [[205, 214, -2.5, 2.5]],
				"say": [[8, "흰 눈 위를 구르면\n커진다"], [140, "얼음벽만큼 커야\n깬다"], [176, "오르막 전에\n노란 길에서 녹여"], [312, "다시 키워!"], [428, "녹는 길"]]},
				# 섞기: 눈으로 키워 얼음벽 깨기 → 커진(무거운) 몸으로 틈 뛰기 → 오르막 앞 쪼개기
				{"legs": [[20, -4, 9], [90, -16, 9], [14, -1, 9], [12, -1, 8, 0, "gap"], [30, -4, 8], [30, 6, 8], [20, -3, 8]],
					"snow": [[2, 108, -9, 9]], "row": [[114, "ice"]], "put": [["pot", 40, 5], ["pot", 60, -5], ["pot", 80, 3]],
					"say": [[2, "섞기: 눈으로 키워\n얼음벽 깨기"], [116, "무거운 몸으로\n뛰어!"], [150, "오르막!\n쪼개서 가볍게"]]}]},
		# 협곡: 던지기(크기 1을 앞으로 던져 수정을 깬다). 흔들다리는 입구 기둥 높이보다 크면 끊어진다. 무게가 탄약이자 죄.
		{"msg": "협곡 · 던지기", "mode": "low", "skill": "throw", "road": STONE, "floor": WATER, "accent": A, "posts": false, "scen": "canyon",
			"items": [{"legs": [[20, -3, 7], [60, -10, 7], [20, -2, 7], [45, -3, 4, 0, "rope", 3.6], [15, -1, 7], [50, -9, 7], [20, -2, 7],
				[55, -4, 3.2, 0, "rope", 3.0], [15, -1, 7], [40, -7, 7], [20, -1, 7]],
				"put": [["pot", 30, -3], ["pot", 34, 3], ["pot", 42, 0], ["statue", 52, -3], ["pot", 60, 3], ["pot", 66, -2], ["pot", 72, 2],
					["pot", 165, -4], ["pot", 168, 0], ["pot", 171, 4], ["house", 182, -3.5], ["statue", 186, 3.5], ["pot", 194, -4], ["pot", 197, 0],
					["pot", 200, 4], ["statue", 206, 0], ["pot", 310, 0]],
				"row": [[90, "crystal"], [222, "crystal"]],
				"say": [[6, "던지기 = 내 몸 한 덩이를\n앞으로 (작아진다)"], [50, "보라 벽은 몸으로 못 지나간다\n점선이 초록이면 던져"], [96, "기둥보다 크면\n다리가 끊어진다"], [150, "다시 키워"], [206, "빠를수록 멀리 닿는다"], [228, "더 좁은 다리"]]},
				# 섞기: 깔아서 커지고 → 수정에 던지면 작아져 → 바로 뒤 좁은 흔들다리를 건넌다 → 경사대 틈 뛰기
				{"legs": [[20, -4, 7], [40, -8, 7], [16, -1, 7], [45, -3, 3.4, 0, "rope", 3.2], [12, -1, 7], [10, 4, 6, 0, "ramp"], [14, -4, 6, 0, "gap"], [30, -5, 7]],
					"put": [["pot", 8, -3], ["pot", 12, 3], ["house", 30, -3], ["statue", 44, 3], ["pot", 50, 0]],
					"row": [[66, "crystal"]],
					"say": [[2, "섞기: 커지고, 던져서\n작아지고, 건너기"], [128, "뛰어!"]]}]},
		{"msg": "해안 · 추격", "mode": "front", "skill": "", "road": STONE, "floor": WATER, "accent": B, "posts": true, "scen": "coast",
			"items": [
				# 길이 좁아지면 빨강 돌을 피할 수 없다 → 쪼개기(떼어낸 덩이가 뒤 돌을 막는다)
				{"legs": [[20, -4, 7], [140, -25, 7], [60, -11, 3.5], [60, -10, 7], [20, 0, 8]],
					"put": [["pot", 60, -3], ["pot", 62, 3], ["pot", 130, 0], ["pot", 230, -3], ["pot", 232, 3]],
					"rocks": [30, 282], "say": [[22, "노랑은 받고\n빨강은 피해"], [150, "좁다! 빨강은\n쪼개서 막아"]]},
				# 마지막 다 섞기: 등뒤 카메라로 돌아와 지금까지 배운 것을 전부
				{"cam": [[0, "back"]],
					"legs": [[20, -3, 8], [60, -12, 8], [14, -1, 8], [45, -4, 3.4, 0, "rope", 3.4], [15, -1, 8], [50, -9, 8, 50],
						[10, 4, 6, 0, "ramp"], [14, -4, 6, 0, "gap"], [3, -28, 12, 0, "drop"], [50, -6, 12], [30, -6, 8],
						[3, -24, 8, 0, "drop"], [80, -8, 10]],
					"snow": [[22, 78, -8, 8]], "row": [[86, "crystal"]],
					"put": [["pot", 30, -4], ["pot", 40, 4], ["pot", 50, 0], ["pot", 60, -4], ["house", 246, -6], ["pot", 254, 0], ["house", 262, 6], ["pot", 290, 0]],
					"holes": [[238, 252, 0, 12.3], [256, 270, -12.3, 0]],
					"say": [[0, "해안 응용: 배운 것을 섞어!"], [20, "눈으로 키우고"], [62, "수정은 던져\n작아져야 다리를 건넌다"], [150, "회전! 버티기"],
						[200, "뛰어!"], [226, "구멍 피해\n내려찍기"]]}]},
		# 물살은 지면 위에 있을 때만 몸을 옆으로 나른다. 작은 몸은 더 밀린다.
		{"msg": "조수 정원 · 물살 타기", "mode": "iso", "skill": "", "road": STONE, "floor": WATER, "accent": B, "posts": false, "scen": "coast",
			"objective": "화살표가 물살 방향 · 버티면 고정 / 뛰면 벗어남",
			"items": [
				{"legs": [[36, -5, 10], [72, -10, 11], [36, -4, 10], [72, -10, 11], [36, -4, 9]],
					"flow": [[40, 104, -11, 11, 1], [148, 212, -11, 11, -1]],
					"put": [["pot", 52, -4], ["pot", 70, 0], ["pot", 88, 4], ["pillar", 116, 5], ["pot", 162, 4], ["pot", 184, -2], ["pillar", 224, -5]],
					"say": [[4, "물살은 몸을 옆으로!\n화살표를 봐"], [30, "버티면 덜 밀린다"], [132, "이번엔 반대 방향\n뛰면 물살을 벗어난다"]]},
				{"legs": [[24, -4, 10], [72, -10, 10], [16, -2, 8], [14, -2, 8, 0, "gap"], [56, -8, 10], [24, -3, 9]],
					"flow": [[24, 92, -10, 10, 1], [132, 184, -10, 10, -1]],
					"put": [["pot", 8, 0], ["pot", 16, 0], ["pillar", 58, 4], ["pillar", 164, -4]],
					"row": [[88, "crystal"]], "snow": [[2, 23, -9, 9]],
					"say": [[2, "섞기: 눈으로 탄약 확보"], [22, "물살을 버티며\n초록이면 던져"], [88, "벽을 열고 물살 밖에서 뛰어!"], [130, "반대 물살 착지\n가운데로 조종"]]}]},
		# 제동의 역할을 바꾼다: 발판에서 누르면 힘을 모으고, 떼면 크게 날아간다.
		{"msg": "공명 제단 · 눌렀다 놓기", "mode": "back", "skill": "", "road": STONE, "floor": Color("b8cbd8"), "accent": D, "posts": true, "scen": "plaza",
			"objective": "황금 발판에서 버티기 → 힘이 차면 손을 떼 발사",
			"items": [
				{"legs": [[38, -6, 10], [50, -5, 10, 0, "drum"], [36, -4, 10, 0, "gap"], [90, -12, 12], [30, -4, 10]],
					"drum": [[38, 88]],
					"put": [["pot", 12, -3], ["pot", 18, 3], ["pot", 24, 0], ["pot", 166, -4], ["pot", 180, 0]],
					"say": [[4, "앞의 넓은 틈:\n보통 점프로는 짧다"], [26, "황금 발판에서 버티기!\n초록이 되면 손을 떼"], [140, "공중에서 버티면 내려찍기\n착지까지는 손을 떼자"]]},
				{"legs": [[24, -4, 10], [46, -5, 10, 0, "drum"], [38, -5, 10, 0, "gap"], [90, -12, 12], [25, -3, 9]],
					"drum": [[24, 70]], "row": [[170, "crystal"]],
					"snow": [[2, 24, -9, 9]],
					"put": [["house", 132, -5], ["house", 144, 5], ["pot", 152, 0]],
					"say": [[2, "섞기: 눈으로 몸을 키워"], [24, "무거운 몸으로 발판 누르기\n초록에서 손을 떼!"], [118, "착지 후 수정을 던져 깨고"], [178, "마지막 신전이 보인다"]]}]},
		{"msg": "바다 신전 · 마지막 도약", "mode": "back", "skill": "", "road": STONE, "floor": WATER, "accent": D, "posts": false, "scen": "coast",
			"objective": "키우고 → 던지고 → 가볍게 날아 바다 신전까지",
			"items": [
				{"legs": [[24, -4, 10], [66, -10, 10], [18, -2, 9], [42, -4, 4, 0, "rope", 3.8], [42, -6, 10],
					[48, -5, 10, 0, "drum"], [36, -4, 10, 0, "gap"], [100, -10, 12]],
					"snow": [[2, 70, -9, 9]], "row": [[82, "crystal"]], "drum": [[192, 240]],
					"flow": [[152, 188, -10, 10, 1]], "goal": 326,
					"put": [["pot", 22, 0], ["pot", 42, -3], ["pot", 54, 3], ["pillar", 172, 5]],
					"say": [[2, "마지막 응용\n눈으로 탄약을 만들고"], [50, "던져 작아져야\n다리가 버틴다"], [150, "물살 뒤 황금 발판\n버티다가 손을 떼!"], [284, "돌아왔다\n신전의 빛을 향해"]]}]},
	]


func _reset() -> void:
	if fresh_run:
		fresh_run = false
		run_elapsed = 0.0
		run_deaths = 0
	finish_time = 0.0
	failure_reason = ""
	new_record = false
	drum_charge = 0.0
	was_holding = false
	drum_used = -1.0
	currents.clear()
	drums.clear()
	if result_card:
		result_card.visible = false
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
	cave_nodes.clear()
	gems.clear()
	dash_t = 0.0
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
	ropes.clear()
	crack_t = 0.0
	pad_t = 0.0
	shot_t = 0.0
	sq = 0.0
	far_k = -1
	far = Node3D.new()
	world.add_child(far)
	clouds = Node3D.new()
	far.add_child(clouds)
	for i in 6:
		var a := TAU * i / 6.0 + 0.4
		var r := 230.0 + 30.0 * (i % 3)
		box(Vector3(cos(a) * r, 70.0 + 14.0 * (i % 3), sin(a) * r), Vector3(46, 6, 20), WHITE, clouds)
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
	chunk = box(Vector3.ZERO, Vector3.ONE * 1.3, STONE)
	chunk.visible = false
	chunk_t = 0.0
	# 던진 덩이 = 내 몸 한 조각: 돌과 같은 색, 같은 흰 띠
	shot = box(Vector3.ZERO, Vector3.ONE * 1.4, ME)
	_stone_mesh(shot)
	_stone_mesh(chunk)
	shot.visible = false
	aim_dots.clear()
	for i in 10:
		var n := box(Vector3.ZERO, Vector3(0.7, 0.16, 0.7), GOOD)
		n.visible = false
		aim_dots.append(n)
	aim_bar = box(Vector3.ZERO, Vector3(8.4, 0.5, 0.5), GOOD)
	aim_bar.visible = false
	aim_legs.clear()
	for i in 2:
		var n := box(Vector3.ZERO, Vector3(0.4, 1.6, 0.4), GOOD)
		n.visible = false
		aim_legs.append(n)
	aim_ok = false
	# 파편·바람 줄은 미리 만들어 돌려 쓴다
	bits.clear()
	for i in 16:
		var n := box(Vector3.ZERO, Vector3.ONE * 0.5, WHITE)
		n.visible = false
		bits.append({"n": n, "v": Vector3.ZERO, "life": 0.0, "max": 1.0, "sz": 0.5})
	streaks.clear()
	for i in 8:
		var n := box(Vector3.ZERO, Vector3(0.09, 0.09, 1.0), WHITE)
		n.visible = false
		streaks.append({"n": n, "d": 30.0 * i / 8.0 - 8.0, "x": 0.0, "y": 0.0})
	rocks.clear()
	for i in 6:
		var n := box(Vector3.ZERO, Vector3.ONE, BAD)
		_stone_mesh(n)
		var warning := box(Vector3(0, -0.45, 0), Vector3.ONE, BAD, n)
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
	_place(0.0)


func _unlock(nm: String) -> void:
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
func _ground(d: float, x: float) -> float:
	if underground:
		return _h(d) - _tunnel_depth(d)
	if d >= _len():
		return NAN
	var i := _oi(pd, d)
	if pd.sol[i] == 0 or absf(x) > float(pd.hw[i]) + 0.3:
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
	_zone_items(z)


## 구역의 다음 조각들을 길에 붙이고 짓는다. 갈림길을 만나면 두 갈래를 미리 짓고 멈춘다.
func _zone_items(z: Dictionary) -> void:
	var items: Array = Z[z.k].items
	while int(z.item) < items.size():
		var it: Dictionary = items[z.item]
		if it.has("fork"):
			var st := _end_st()
			var d0 := float(_len())
			var pair := []
			for side in 2:
				var br: Dictionary = it.fork[side]
				var o := _gen(st, br.legs)
				_draw_road(o, 0, o.px.size() - 1, z)
				pair.append(_make_things(br, o, 0.0, d0, z))
			z.fork = {"at": d0, "things": pair}
			says.append([d0 - 45.0, "← 갈림길 →"])
			_relist()
			return
		var d1 := float(maxi(_len(), 0))
		_extend(it.legs)
		_draw_road(pd, int(d1), _len(), z)
		if int(z.k) == 1:
			_build_tunnel(d1, float(_len()), z.node)
		var acc := d1
		for lg: Array in it.legs:
			if lg.size() > 5 and str(lg[4]) == "rope":
				ropes.append([acc, acc + float(lg[0]), float(lg[5])])
				_arch(acc + 1.0, float(lg[5]), z.node)
			acc += float(lg[0])
		z.things.append_array(_make_things(it, pd, d1, d1, z))
		z.item += 1
	z.end = float(_len())
	_extras(z)
	_relist()


## 갈림길: 그 순간 서 있는 쪽 갈래로 간다
func _choose(z: Dictionary) -> void:
	var side := 0 if bx < 0.0 else 1
	var it: Dictionary = Z[z.k].items[z.item]
	_extend(it.fork[side].legs)
	z.things.append_array(z.fork.things[side])
	z.fork = null
	z.item += 1
	sfx("tick")
	_zone_items(z)


func _relist() -> void:
	things.clear()
	for z: Dictionary in zones:
		if not z.freed:
			things.append_array(z.things)


func _draw_road(o: Dictionary, a: int, b: int, z: Dictionary) -> void:
	var def: Dictionary = Z[z.k]
	var nd: Node3D = z.node
	var i := a
	while i < b:
		if o.sol[i] == 0:
			i += 1
			continue
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
			"rope":
				col = A
				thick = 0.5
		var m := box(Vector3.ZERO, Vector3.ONE, col, nd)
		_apply_art(m, "plank" if tg in ["rope", "bridge"] else _ground_art(int(z.k)))
		m.basis = bs
		m.scale = Vector3(hw * 2.0, thick, ln + 0.4 + hw * absf(o.yw[j] - o.yw[i]))
		m.position = (p0 + p1) * 0.5 - up * thick * 0.5
		if ln > 5.0:
			if tg == "aq":
				var w := box(Vector3.ZERO, Vector3.ONE, WATER, nd)
				w.basis = bs
				w.scale = Vector3(hw, 0.1, ln + 0.4)
				w.position = (p0 + p1) * 0.5 + up * 0.04
			elif tg == "rope":
				# 난간 밧줄 + 발판 줄무늬
				for sd: float in [-1.0, 1.0]:
					var e := box(Vector3.ZERO, Vector3.ONE, WHITE, nd)
					e.basis = bs
					e.scale = Vector3(0.18, 0.18, ln + 0.4)
					e.position = (p0 + p1) * 0.5 + rt * sd * (hw + 0.1) + up * 1.3
				var nb := int(ln / 6.0)
				for q in nb:
					var e := box(Vector3.ZERO, Vector3.ONE, D, nd)
					_apply_art(e, "plank")
					e.basis = bs
					e.scale = Vector3(hw * 2.0, 0.08, 0.7)
					e.position = p0 + dir * ((q + 0.5) / nb) + up * 0.03
			elif tg != "plaza":
				for sd: float in [-1.0, 1.0]:
					var e := box(Vector3.ZERO, Vector3.ONE, Color("24566b"), nd)
					e.basis = bs
					e.scale = Vector3(0.22, 0.1, ln + 0.4)
					e.position = (p0 + p1) * 0.5 + rt * sd * (hw - 0.2) + up * 0.04
		i = j
	# 틈 앞뒤에 같은 붉은 경계선을 쓴다.
	for q in range(a + 1, b):
		if o.sol[q] != o.sol[q - 1]:
			var edge := q - 1 if o.sol[q - 1] == 1 else q
			_plate(o, float(edge), float(edge) + 0.65, -float(o.hw[edge]), float(o.hw[edge]), BAD, nd, 0.18)
	# 기둥(속도 눈금)과 옆 풍경
	var rng := RandomNumberGenerator.new()
	rng.seed = int(z.k) * 1000 + a + int(absf(float(o.px[a])))
	for q in range(a, b):
		if o.sol[q] == 0:
			continue
		var hw: float = o.hw[q]
		var h: float = o.hh[q]
		var tg: String = o.tg[q]
		var fq := float(q)
		if def.posts and q % 30 == 0:
			var sd := 1.0 if (q / 30) % 2 == 0 else -1.0
			box(_opos(o, fq, sd * (hw + 1.2), h + 1.5), Vector3(0.8, 3.0, 0.8), WHITE if sd > 0.0 else def.accent, nd)
		match def.scen:
			"rock":
				if q % 40 == 20:
					for sd: float in [-1.0, 1.0]:
						_column(o, fq, sd * (hw + rng.randf_range(9.0, 34.0)), h + rng.randf_range(-12.0, 26.0), rng.randf_range(6.0, 13.0), [ROCK, STONE, WHITE].pick_random(), nd)
			"aq":
				if q % 15 == 0 and tg == "aq":
					_column(o, fq, 0.0, h - 1.2, 1.6, WHITE, nd)
				if q % 25 == 5:
					_column(o, fq, -(28.0 + rng.randf_range(0.0, 20.0)), h + rng.randf_range(-4.0, 18.0), rng.randf_range(6.0, 12.0), [GRASS, ROCK].pick_random(), nd)
			"village":
				if q % 48 == 24:
					var sd := 1.0 if (q / 48) % 2 == 0 else -1.0
					var x := sd * (hw + rng.randf_range(8.0, 20.0))
					var top := h - rng.randf_range(2.0, 9.0)
					_column(o, fq, x, top, 6.0, GRASS, nd)
					var hs := box(_opos(o, fq, x, top + 2.0), Vector3(4, 4, 4), [A, B, C, WHITE].pick_random(), nd)
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
					cap.rotation.y = o.yw[q]
				if q % 60 == 0:
					var sd := -1.0 if (q / 60) % 2 == 0 else 1.0
					_column(o, fq, sd * (hw + rng.randf_range(14.0, 30.0)), h + rng.randf_range(6.0, 22.0), rng.randf_range(7.0, 12.0), [WHITE, ICEWALL].pick_random(), nd)
			"canyon":
				if tg == "rope" and q % 15 == 0:
					for sd: float in [-1.0, 1.0]:
						box(_opos(o, fq, sd * (hw + 0.1), h + 0.8), Vector3(0.5, 2.0, 0.5), D, nd)
				if q % 30 == 15:
					for sd: float in [-1.0, 1.0]:
						_column(o, fq, sd * (hw + rng.randf_range(7.0, 16.0)), h + rng.randf_range(8.0, 28.0), rng.randf_range(6.0, 11.0), [A, ROCK, Color("ffc078")].pick_random(), nd)


## 땅 밑 깊은 곳에서 top 까지 솟은 기둥
func _column(o: Dictionary, d: float, x: float, top: float, w: float, col: Color, nd: Node3D) -> void:
	var bot := _oh(o, d) - 70.0
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
							stripe.rotation.y = _oyaw(o, mark) + sd * 0.6
						mark += 9.0
				if key == "sun":
					# 녹는 길 위 햇살 무늬
					var l := loc0 + float(pp[0]) + 4.0
					while l < loc0 + float(pp[1]) - 2.0:
						var st := box(_opos(o, l, (float(pp[2]) + float(pp[3])) * 0.5, _oh(o, l) + 0.1), Vector3(float(pp[3]) - float(pp[2]) - 1.0, 0.1, 0.8), A, z.node)
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
	if it.has("goal"):
		goal_d = d0 + float(it.goal)
	if it.has("rocks"):
		rock_a = d0 + float(it.rocks[0])
		rock_b = d0 + float(it.rocks[1])
	return out


## 길 위 얇은 판 (구멍·눈·녹는 길)
func _plate(o: Dictionary, la: float, lb: float, x0: float, x1: float, col: Color, nd: Node3D, lift: float) -> void:
	var xm := (x0 + x1) * 0.5
	# 짧은 판으로 지면을 따라가 눈·구멍 무늬가 경사 위에 뜨지 않게 한다.
	var d := la
	while d < lb:
		var next := minf(d + 4.0, lb)
		var p0 := _opos(o, d, xm, _oh(o, d))
		var p1 := _opos(o, next, xm, _oh(o, next))
		var m := box(Vector3.ZERO, Vector3.ONE, col, nd)
		m.basis = Basis.looking_at((p1 - p0).normalized(), Vector3.UP)
		m.scale = Vector3(x1 - x0, 0.2, (p1 - p0).length() + 0.02)
		m.position = (p0 + p1) * 0.5 + Vector3.UP * lift
		d = next


## 흔들다리 입구 기둥: 기둥 높이(빨간 머리 밑) = 버티는 크기. 돌이 기둥보다 크면 끊어진다.
## (가로대를 두면 낮은 카메라가 그 속을 지나가 화면이 가려져서 기둥 두 개만 둔다)
func _arch(d: float, lim: float, nd: Node3D) -> void:
	var hw: float = pd.hw[_oi(pd, d)]
	var h := _h(d)
	var yw := _yaw(d)
	for sd: float in [-1.0, 1.0]:
		var p := box(_pos(d, sd * (hw + 0.8), h + lim * 0.5), Vector3(1.0, lim, 1.0), D, nd)
		p.rotation.y = yw
		var cap := box(_pos(d, sd * (hw + 0.8), h + lim + 0.3), Vector3(1.6, 0.6, 1.6), BAD, nd)
		cap.rotation.y = yw


func _thing(o: Dictionary, l: float, d: float, x: float, kind: String, z: Dictionary) -> Thing:
	var th := Thing.new()
	th.kd = KIND[kind]
	th.d = d
	th.x = x
	th.base = _oh(o, l)
	var sz: Vector3 = th.kd.size
	th.col = (th.kd.col as Array).pick_random()
	th.n = box(_opos(o, l, x, th.base + sz.y * 0.5), sz, th.col, z.node)
	th.n.rotation.y = _oyaw(o, l)
	if kind in ["pot", "pillar", "post", "crystal"]:
		var shape := CylinderMesh.new()
		shape.radial_segments = 6
		shape.height = 1.0
		shape.bottom_radius = 0.5
		shape.top_radius = 0.0 if kind == "crystal" else (0.34 if kind == "pot" else 0.5)
		th.n.mesh = shape
	if kind in ["pot", "pillar", "post", "crystal"]:
		_apply_art(th.n, "pillar" if kind == "post" else kind)
	elif kind == "house":
		_apply_art(th.n, "temple")
	elif kind == "ice":
		_apply_art(th.n, "crystal")
		th.n.material_override = art_materials["ice_wall"]
	elif kind == "statue":
		_apply_art(th.n, "pillar")
	elif kind == "tower":
		_apply_art(th.n, "pillar", th.col.lightened(0.2))
	elif kind == "gold":
		_apply_art(th.n, "temple", D)
	if th.kd.get("slam", false):
		# 파란 머리 + 둘레 띠: 버티기 버튼 색. 위에서 보이도록 크게.
		box(Vector3(0, 0.56, 0), Vector3(1.3, 0.14, 1.3), B, th.n)
		box(Vector3(0, 0.2, 0), Vector3(1.08, 0.06, 1.08), B, th.n)
		return th
	if float(th.kd.need) > 90.0 or kind == "ice":
		box(Vector3(0, -0.43, 0), Vector3(1.05, 0.18, 1.05), BAD, th.n)
	if kind == "house":
		box(Vector3(0, 0.6, 0), Vector3(1.15, 0.25, 1.15), BAD, th.n)
	elif kind == "pillar" or kind == "post":
		box(Vector3(0, 0.46, 0), Vector3(1.4, 0.08, 1.4), D if kind == "pillar" else BAD, th.n)
	return th


## 구역이 다 이어진 뒤: 바닥, 신전, 다음 구역 문
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
	var fy := mn - (3.0 if z.k == Z.size() - 1 else 30.0)
	var mid := (lo + hi) * 0.5
	var margin := 600.0 if z.k == Z.size() - 1 else 80.0
	box(Vector3(mid.x, fy, mid.y), Vector3(hi.x - lo.x + margin, 1.0, hi.y - lo.y + margin), def.floor, nd)
	if int(z.k) == Z.size() - 1:
		var temple_d := goal_d + 24.0
		var temple := box(_pos(temple_d, 0.0, _h(temple_d) + 11.0), Vector3(40, 24, 20), STONE, nd)
		_apply_art(temple, "temple")
		temple.rotation.y = _yaw(temple_d)
		for side: float in [-1.0, 1.0]:
			var column := box(_pos(goal_d + 2.0, side * 13.0, _h(goal_d) + 8.0), Vector3(3, 16, 3), WHITE, nd)
			_apply_art(column, "pillar")
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
		bar.rotation.y = yw


func _zones_tick() -> void:
	for z: Dictionary in zones:
		if z.fork != null and dist >= float(z.fork.at) - 9.0:
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
			msg(says[i][1], 2.2)
			says.remove_at(i)


func _enter(z: Dictionary) -> void:
	var first := cur_k < 0
	cur_k = z.k
	var def: Dictionary = Z[cur_k]
	mode = def.mode
	sky_to = def.sky
	if first and sky_env:
		sky_env.background_color = sky_to
	_far_build(cur_k)
	msg(def.msg, 1.6)
	if def.skill != "":
		_unlock(def.skill)
	if cur_k > 0:
		play("good")
		var i := int(z.start)
		cp_k = cur_k
		cp_st = {"x": pd.px[i], "z": pd.pz[i], "yw": pd.yw[i], "h": pd.hh[i]}
		cp_s = s_goal
		cp_score = score


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
		def = {"sky": CAVE_SKY, "far": "spire", "farcol": [C, Color("ff8fd8"), Color("7ff0ff"), D]}
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
func _burst(p: Vector3, col: Color, n: int, spd: float, sz := 0.5) -> void:
	for b: Dictionary in bits:
		if n <= 0:
			break
		if float(b.life) > 0.0:
			continue
		var bn: MeshInstance3D = b.n
		bn.visible = true
		bn.material_override = mat(col)
		bn.position = p + Vector3(randf_range(-0.5, 0.5), randf_range(0.0, 0.6), randf_range(-0.5, 0.5))
		bn.rotation = Vector3(randf() * TAU, randf() * TAU, 0.0)
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
	sq = move_toward(sq, 0.0, dt * 2.2)
	if sky_mat:
		sky_mat.sky_top_color = sky_mat.sky_top_color.lerp(sky_to, minf(1.0, dt * 1.5))
		var hz := Color("ffc4ee") if underground else Color("fff5df")
		sky_mat.sky_horizon_color = sky_mat.sky_horizon_color.lerp(hz, minf(1.0, dt * 1.5))
		sky_mat.ground_horizon_color = sky_mat.sky_horizon_color
	if clouds:
		clouds.rotation.y += dt * 0.015


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	if not won:
		run_elapsed += dt
	_fx(dt)
	_zones_tick()
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
	_drum_tick(dt, hold)
	_current_tick(dt, hold)
	if kit_just("jump") and on_ground:
		vy = JUMP / pow(mm, 0.7)
		by += 0.05
		on_ground = false
		sfx("jump", 0.0, 1.15 / pow(mm, 0.25))
	if kit_just("split"):
		_split()
	if kit_just("throw"):
		_throw()
	_shot(dt)
	_aim()
	if mode == "side":
		x_goal = 0.0
	var rope := _rope_at(dist)
	if on_ground and rope.size() > 0:
		# 흔들다리: 바람에 옆으로 흔들린다. 입구 기둥보다 크면 삐걱이다 끊어진다.
		x_goal += sin(clock * 2.3) * 2.6 * dt
		if s_goal > float(rope[2]) + 0.05:
			crack_t += dt
			shake = maxf(shake, 0.35)
			if fmod(crack_t, 0.12) < dt:
				sfx("creak", -2.0)
			if crack_t > 0.4:
				_burst(_pos(dist, bx, by), A, 10, 9.0, 0.8)
				_fall("다리가 끊어졌다!")
				_place(dt)
				return
		else:
			crack_t = maxf(0.0, crack_t - dt)
	else:
		crack_t = 0.0
	if on_ground:
		_pads(dt)
	# 큰 회전: 무거울수록 빠를수록 바깥으로 밀린다 (버티면 덜)
	var k := _curv(dist)
	if on_ground and absf(k) > 0.0005:
		x_goal += k * v * v * TURN_C * mm * (0.35 if hold else 1.0) * dt
	bx = lerpf(bx, x_goal, minf(1.0, dt * 10.0 / sqrt(mm)))
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
		if hold:
			v *= exp(-2.2 * dt)
			vy -= 46.0 * dt
	dist += v * dt
	vy -= FALL * dt
	by += vy * dt
	if cur_k == 1 and not underground and by < _h(dist) - 4.0:
		_fall("지하로!")
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
			_fall("떨어짐!")
	elif by <= g:
		if by < g - 1.4 and not won:
			_fall("쾅!")
		else:
			if not on_ground:
				if underground:
					_burst(_pos(dist, bx, g), Color("68cfca"), 12, 8.0)
					shake = 0.35
					sq = 0.2
					sfx("land", -2.0, 0.9)
				else:
					_land(vy, hold)
			by = g
			if underground and _tunnel_depth(dist) <= 0.01:
				underground = false
				_cave(false)
				msg("다음 틈을 봐", 1.4)
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
		if th.flat:
			continue
		var dd := th.d - dist
		if absf(dd) > 14.0:
			continue
		var sz: Vector3 = th.kd.size
		if absf(dd) < (s + sz.z) * 0.5 and absf(th.x - bx) < (s + sz.x) * 0.45 and by < th.base + sz.y * 0.8 and by + s > th.base:
			var need: float = th.kd.need
			var slam: bool = th.kd.get("slam", false)
			var dive_ok: bool = diving and not th.kd.get("nodive", false) and (hold if slam else need < 90.0)
			# 쪼갠 직후 돌진: 크기가 모자라도 집·석상·얼음벽을 뚫고, 느려지지 않는다 (수정·담·탑은 안 됨)
			var dash_ok: bool = dash_t > 0.0 and not slam and not th.kd.has("shot") and need < 90.0
			if s_goal >= need or dive_ok or dash_ok:
				_crush(th, mm, not diving and not dash_ok)
			elif hurt <= 0.0:
				_bonk(th)
			elif th.kd.get("nodive", false) or slam:
				# 얼음벽·수정은 진짜 벽: 튕긴 뒤에도 못 지나간다
				dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
				v = minf(v, 3.0)
	_rocks(dt, mm)
	if underground:
		_gems()
	# 멈춤 검사
	if on_ground and v < VSTOP and not won:
		slow_t += dt
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = 0.3
			sfx("warn", -4.0)
		if slow_t > STOP_T:
			failure_reason = tr("속도 %.0f 아래에서 1.5초 · 오르막 전엔 가볍게") % VSTOP
			end()
			return
	else:
		slow_t = 0.0
		warn_t = 0.0
	if goal_d > 0.0 and dist >= goal_d and not won:
		_finish()
	score = score_base + int(dist) + bonus
	var col := GOOD
	if v < VSTOP:
		col = BAD
	elif v < VSTOP * 1.8:
		col = D
	gauge(v / VMAX, col)
	_place(dt)


func _rope_at(d: float) -> Array:
	for rp: Array in ropes:
		if d > float(rp[0]) and d < float(rp[1]):
			return rp
	return []


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
				if floori(s_goal * 2.0) > before:
					sfx("snow", -6.0)
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
	shot_v = v + 25.0
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
	shot.position = _pos(shot_d, shot_x, _h(shot_d) + 0.75)
	shot.rotation = Vector3(-shot_d * 1.4, _yaw(shot_d), 0.0)
	for th: Thing in things:
		if th.flat:
			continue
		var sz: Vector3 = th.kd.size
		if absf(th.d - shot_d) < sz.z * 0.5 + 1.0 and absf(th.x - shot_x) < (1.4 + sz.x) * 0.45:
			if th.kd.get("shot", false):
				# 수정 줄은 맞은 자리 둘레가 함께 깨져 돌이 지나갈 틈이 난다
				for t2: Thing in things:
					if not t2.flat and t2.kd.get("shot", false) and absf(t2.d - th.d) < 0.5 and absf(t2.x - shot_x) < 4.2:
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
			msg("안 닿았다!
더 빨리, 더 가까이", 0.8)
		shot_t = 0.0
		shot.visible = false


## 던지는 거리: 구르는 속도에 비례한다 (점선 길이 = 이 거리)
func _throw_range() -> float:
	return 12.0 + v * 1.3


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
	for i in aim_dots.size():
		var n: MeshInstance3D = aim_dots[i]
		var dd := lerpf(a, e, (i + 0.5) / aim_dots.size())
		n.visible = dd < e and shot_t <= 0.0
		n.position = _pos(dd, bx, _h(dd) + 0.12)
		n.rotation.y = _yaw(dd)
		n.material_override = mat(col)
	# 막대: 덩이가 맞으면 열리는 틈 너비 (돌이 지금 있는 옆 위치 기준)
	var top := tgt.base + sz.y + 1.6 + 0.3 * sin(clock * 9.0)
	var yw := _yaw(tgt.d)
	aim_bar.visible = true
	aim_bar.position = _pos(tgt.d, bx, top)
	aim_bar.rotation.y = yw
	aim_bar.material_override = mat(col)
	for i in 2:
		var n: MeshInstance3D = aim_legs[i]
		n.visible = true
		n.position = _pos(tgt.d, bx + (-4.0 if i == 0 else 4.0), top - 0.8)
		n.rotation.y = yw
		n.material_override = mat(col)
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
	_burst(th.n.position, th.col, 8, 11.0, 0.7)
	sfx("glass" if th.kd.has("shot") else "crush_s")


## 착지: 높이 떨어질수록(버티면 더) 넓게 부순다
func _land(vy0: float, hard: bool) -> void:
	sq = maxf(sq, clampf(-vy0 / 45.0, 0.0, 0.42))
	if vy0 < -10.0:
		_burst(_pos(dist, bx, by + 0.2), (Z[cur_k].road as Color).darkened(0.1), 3 + int(-vy0 / 8.0), 4.0 + -vy0 * 0.25)
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
	sfx("land", minf(0.0, -12.0 - vy0 * 0.3), clampf(1.25 - s * 0.06, 0.8, 1.2))


func _crush(th: Thing, mm: float, slow := true) -> void:
	th.flat = true
	var sz: Vector3 = th.kd.size
	_burst(th.n.position, th.col, 3 + int(sz.y), 6.0 + sz.y, clampf(sz.y * 0.25, 0.4, 1.0))
	sq = maxf(sq, 0.1 + float(th.kd.mass) * 0.5)
	if th.kd.get("nodive", false):
		th.n.visible = false
	else:
		th.n.scale.y = 0.15
		th.n.position.y = th.base + 0.08
	if slow:
		v *= mm / (mm + float(th.kd.mass))
	if th.kd.has("boost"):
		v = minf(VMAX + 10.0, v + float(th.kd.boost))
		_burst(th.n.position + Vector3.UP * 2.0, B, 10, 14.0, 0.9)
	var before := floori(s_goal)
	s_goal = minf(SMAX, s_goal + float(th.kd.grow))
	bonus += int(th.kd.pts) * 5
	shake = maxf(shake, 0.1 + float(th.kd.mass))
	sfx("crush_big" if th.kd.get("slam", false) else ("glass" if th.kd.get("nodive", false) else ("crush_s" if float(th.kd.size.y) < 2.0 else "crush_m")), -2.0 if float(th.kd.size.y) < 2.0 else 0.0, randf_range(0.9, 1.12))
	if floori(s_goal) > before:
		play("good")


func _bonk(th: Thing) -> void:
	var sz: Vector3 = th.kd.size
	v *= 0.3
	dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
	hurt = 0.5
	shake = 0.6
	sq = 0.35
	_burst(_pos(dist + s * 0.5, bx, by + s * 0.5), th.col, 4, 6.0)
	play("bad")
	if th.kd.has("shot"):
		msg("수정은 던져서!", 0.8)
	elif th.kd.get("slam", false):
		msg("위에서 버티기로 쾅!", 0.9)
	elif th.kd == KIND.ice and _btns.has("split"):
		msg("더 커지거나\n직전에 쪼개서 돌진!", 0.9)
	elif th.kd.get("nodive", false):
		msg("더 커져야!", 0.8)


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
		n.material_override = art_materials["stone"]
		(n.get_child(0) as MeshInstance3D).material_override = mat(D if s_goal >= r else BAD)
		if absf(rd - dist) < (s + r) * 0.5 and absf(float(rk.x) - bx) < (s + r) * 0.45 and by < _h(rd) + r:
			rk.on = false
			n.visible = false
			if s_goal >= r:
				s_goal = minf(SMAX, s_goal + r * 0.1)
				v += maxf(0.0, float(rk.v) - v) * 0.5
				bonus += int(r * 10.0)
				sfx("catch")
			else:
				v *= 0.6
				x_goal += (3.5 if bx >= float(rk.x) else -3.5) / sqrt(mm)
				hurt = 0.5
				shake = 0.8
				play("bad")


func _fall(text: String) -> void:
	if cur_k == 1 and not underground and _tunnel_depth(dist) > 0.0:
		underground = true
		on_ground = false
		bx = 0.0
		x_goal = 0.0
		v = maxf(v, 32.0) # 낙하 운동량으로 출구 오르막을 넘을 여유
		_cave(true)
		msg("숨은 수정 동굴", 2.2)
		return
	fallen = true
	failure_reason = text
	fall_t = 0.0
	v = minf(v, 6.0)
	sfx("fall")


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
	ball.scale = Vector3.ONE * s
	_streaks(dt, yw)
	ball.material_override = mat(BAD) if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else art_materials["stone"]
	if dash_t > 0.0 and hurt <= 0.0 and fmod(dash_t, 0.16) < 0.08:
		ball.material_override = mat(C.lightened(0.3))  # 돌진 중: 쪼개기 색으로 깜빡
	var q := floori(ang / (PI * 0.5))
	roll_t -= dt
	if q != quarter:
		quarter = q
		if roll_t <= 0.0 and on_ground:
			roll_t = 0.07
			sfx("roll", -10.0 + minf(6.0, v * 0.12), clampf(1.35 - s * 0.08, 0.7, 1.3))
	# 카메라: 구역마다 구도가 다르다 (돌 기준 거리만 부드럽게 옮겨 간다)
	if not fallen:
		cam_y = lerpf(cam_y, by, minf(1.0, dt * 6.0))
	var fw := Vector3(-sin(yw), 0.0, -cos(yw))
	var rt := Vector3(cos(yw), 0.0, -sin(yw))
	var c := _pos(dist, bx, cam_y)
	var off := Vector3.ZERO
	var look := Vector3.ZERO
	var up := Vector3.UP
	var fov := 55.0
	match mode:
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
	var kk := minf(1.0, dt * (5.0 if mode == "back" else 3.5)) if dt > 0.0 else 1.0
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
func _streaks(dt: float, yw: float) -> void:
	var on := (v > 26.0 or dash_t > 0.0) and mode != "top" and not fallen
	for sk: Dictionary in streaks:
		var n: MeshInstance3D = sk.n
		if not on:
			n.visible = false
			continue
		sk.d = float(sk.d) - v * 0.7 * dt
		if float(sk.d) < -10.0:
			sk.d = randf_range(18.0, 34.0)
			var sd := 1.0 if randf() < 0.5 else -1.0
			sk.x = bx + sd * (s * 0.5 + randf_range(1.0, 5.0))
			sk.y = randf_range(0.4, s + 3.0)
		var d := dist + float(sk.d)
		n.visible = true
		n.position = _pos(d, float(sk.x), _h(d) + float(sk.y)) if on_ground else _pos(d, float(sk.x), by + float(sk.y) - s * 0.5)
		n.rotation = Vector3(0.0, _yaw(d), 0.0)
		n.scale = Vector3(0.09, 0.09, clampf((v - 20.0) * 0.12, 0.5, 6.0))


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	last_x = p.x


func _drag(p: Vector2) -> void:
	var dx := p.x - last_x
	last_x = p.x
	if mode == "side":
		return  # 옆모습 수로는 외길: 뛰기만
	# 높은 해안 사선 시점도 등뒤 시점과 같은 방향으로 조종한다
	x_goal += dx * 0.05 * 1.0


## 공통 삑 소리 대신 nkido 효과음 (submit/boulder/build_sfx.py)
func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	match nm:
		"good": sfx("gem", -6.0, 0.75)
		"bad": sfx("bonk")
		"win": sfx("charge", 0.0, 0.8)
		"tap": sfx("tick")
		_: super(nm)


var _sfx := {}
var _sfx_pool: Array = []
var _sfx_i := 0


func sfx(nm: String, db := 0.0, pitch := 1.0) -> void:
	if _sfx_pool.is_empty():
		for i in 10:
			var pl := AudioStreamPlayer.new()
			add_child(pl)
			_sfx_pool.append(pl)
	if not _sfx.has(nm):
		_sfx[nm] = load("res://art/boulder/sfx/%s.wav" % nm)
	var pl: AudioStreamPlayer = _sfx_pool[_sfx_i % _sfx_pool.size()]
	_sfx_i += 1
	pl.stream = _sfx[nm]
	pl.volume_db = db - 4.0
	pl.pitch_scale = pitch * randf_range(0.97, 1.03)
	pl.play()


func _stone_mesh(n: MeshInstance3D) -> void:
	_apply_art(n, "stone")


## 수정 동굴에 들어가고 나온다: 하늘·먼 풍경·지평선 색이 통째로 바뀐다
func _cave(on: bool) -> void:
	for n in cave_nodes:
		if is_instance_valid(n):
			(n as Node3D).visible = on
	sky_to = CAVE_SKY if on else Z[maxi(cur_k, 0)].sky
	far_k = -1
	_far_build(maxi(cur_k, 0), on)
	if on:
		shake = 0.6
		sfx("cave")
	else:
		play("good")


## 동굴 보석: 닿으면 점수와 조금의 속도
func _gems() -> void:
	var fl := _h(dist) - _tunnel_depth(dist)
	for gm: Array in gems:
		var n: MeshInstance3D = gm[2]
		if not is_instance_valid(n) or not n.visible:
			continue
		n.rotation.y += 0.05
		if absf(float(gm[0]) - dist) < s * 0.5 + 0.9 and absf(fl + float(gm[1]) - (by + s * 0.5)) < s * 0.5 + 1.2:
			n.visible = false
			bonus += 40
			v += 2.0
			_burst(n.global_position, Color("ff8fd8"), 6, 9.0, 0.5)
			sfx("gem", -3.0, randf_range(0.94, 1.12))


func _tunnel_depth(d: float) -> float:
	for route: Array in tunnels:
		if d >= float(route[0]) and d < float(route[1]):
			return 14.0 * clampf((float(route[1]) - 5.0 - d) / 70.0, 0.0, 1.0)
	return 0.0


func _build_tunnel(a: float, b: float, nd: Node3D) -> void:
	tunnels.append([a, b])
	var d := a
	while d < b:
		var end_d := minf(d + 4.0, b)
		var p0 := _pos(d, 0.0, _h(d) - _tunnel_depth(d))
		# 끝 표본은 다음 조각이 아닌 이 출구의 높이.
		var depth1 := 14.0 * clampf((b - 5.0 - end_d) / 70.0, 0.0, 1.0)
		var p1 := _pos(end_d, 0.0, _h(end_d) - depth1)
		var basis := Basis.looking_at((p1 - p0).normalized(), Vector3.UP)
		var slab := box((p0 + p1) * 0.5 - basis.y * 0.7, Vector3.ONE, Color("68cfca"), nd)
		slab.basis = basis
		slab.scale = Vector3(12.0, 1.4, p0.distance_to(p1) + 0.3)
		if _tunnel_depth(d) > 6.0:
			var wall := box((p0 + p1) * 0.5 - basis.x * 6.5 + Vector3.UP * 3.0, Vector3.ONE, ICE, nd)
			wall.basis = basis
			wall.scale = Vector3(1.0, 6.0, p0.distance_to(p1) + 0.3)
		var stripe := box((p0 + p1) * 0.5 + basis.y * 0.12, Vector3.ONE, D if _tunnel_depth(d) < 14.0 else WHITE, nd)
		stripe.basis = basis
		stripe.scale = Vector3(0.5, 0.1, 2.0)
		d = end_d
	# 수정 동굴: 떨어지기 전엔 숨겨 둔다. 떨어지면 배경째 바뀐다 (보라 벽, 빛나는 수정 숲, 공중 보석).
	var cave := Node3D.new()
	cave.visible = underground
	nd.add_child(cave)
	cave_nodes.append(cave)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(a) * 7 + 3
	var pal := [C.lightened(0.25), Color("ff8fd8"), Color("7ff0ff"), D]
	d = a
	while d < b - 10.0:
		var fl := _h(d) - _tunnel_depth(d)
		var yw := _yaw(d)
		var back := box(_pos(d, -16.0, fl + 12.0), Vector3(1.0, 34.0, 8.4), Color("9d7bff"), cave)
		back.rotation.y = yw
		for q in rng.randi_range(1, 3):
			var cr := box(_pos(d + rng.randf_range(-3.0, 3.0), rng.randf_range(-13.0, -8.0), fl), Vector3.ONE, WHITE, cave)
			_apply_art(cr, "crystal", pal.pick_random())
			var hgt := rng.randf_range(4.0, 14.0)
			cr.scale = Vector3(hgt * 0.35, hgt, hgt * 0.35)
			cr.position.y += hgt * 0.5
			cr.rotation = Vector3(0.0, yw, rng.randf_range(-0.3, 0.3))
		# 천장에서 늘어진 수정 (머리 위 수로 바닥 아래)
		if fmod(d - a, 16.0) < 8.0 and _tunnel_depth(d) > 9.0:
			var st := box(_pos(d, rng.randf_range(-6.0, -2.0), fl + _tunnel_depth(d) - 3.5), Vector3(1.6, 4.0, 1.6), WHITE, cave)
			_apply_art(st, "crystal", pal.pick_random())
			st.rotation = Vector3(PI, yw, 0.0)
		# 보석: 바닥에 하나, 뛰어야 닿는 높이에 하나씩 번갈아
		if _tunnel_depth(d) > 8.0 and int(d - a) % 16 < 8:
			var up := 1.6 if int(d / 16.0) % 2 == 0 else 7.0
			var gm := box(_pos(d, 0.0, fl + up), Vector3(1.2, 1.8, 1.2), WHITE, cave)
			_apply_art(gm, "crystal", pal[int(d) % pal.size()])
			gems.append([d, up, gm])
		d += 8.0


# ---- v6 painted models / UI / two new verbs ----
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
	node.material_override = art_materials[name]
	if tint != Color.WHITE:
		var material: StandardMaterial3D = art_materials[name].duplicate()
		material.albedo_color = tint
		node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _ground_art(k: int) -> String:
	if k == 5:
		return "snow"
	return "coast" if k in [7, 8, 10] else "valley"


func _build_journey_ui() -> void:
	# Portrait: keep the next landing clear. Information belongs above the road, actions on the right.
	var layer := CanvasLayer.new()
	layer.layer = 6
	add_child(layer)
	route_label = _label(layer, 28, 132, 48)
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
	_score_l.label_settings = _score_l.label_settings.duplicate()
	_score_l.label_settings.font_size = 40
	_score_l.position = Vector2(24, 82)
	_score_l.size = Vector2(672, 50)
	var result_layer := CanvasLayer.new()
	result_layer.layer = 8
	add_child(result_layer)
	result_card = Control.new()
	result_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_card.visible = false
	result_layer.add_child(result_card)
	var panel := ColorRect.new()
	panel.position = Vector2(40, 250)
	panel.size = Vector2(640, 466)
	panel.color = STONE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_card.add_child(panel)
	var stripe := ColorRect.new()
	stripe.position = Vector2(40, 250)
	stripe.size = Vector2(640, 8)
	stripe.color = D
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_card.add_child(stripe)
	result_title = _label(result_card, 52, 280, 72)
	result_values = _label(result_card, 36, 364, 140)
	result_note = _label(result_card, 26, 520, 96)
	result_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_note.position.x = 64
	result_note.size.x = 592
	retry_button = _journey_button(result_card, "구역 다시", Vector2(64, 634))
	retry_button.pressed.connect(func() -> void:
		if wait <= 0.0:
			restart())
	var fresh := _journey_button(result_card, "처음부터", Vector2(368, 634))
	fresh.pressed.connect(func() -> void:
		if wait <= 0.0:
			cp_k = 0
			fresh_run = true
			restart())


func _journey_button(parent: Control, text: String, pos: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(288, 60)
	button.add_theme_font_override("font", _font)
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_color_override("font_color", INK)
	var style := StyleBoxFlat.new()
	style.bg_color = WHITE
	style.set_border_width_all(3)
	style.border_color = D
	button.add_theme_stylebox_override("normal", style)
	var pressed := style.duplicate() as StyleBoxFlat
	pressed.bg_color = D
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", pressed)
	button.add_theme_stylebox_override("focus", pressed)
	parent.add_child(button)
	return button


func _process(dt: float) -> void:
	super(dt)
	if not route_label:
		return
	var howto_visible := _howto_box != null and _howto_box.visible
	route_label.visible = not howto_visible and not _rating and not over
	action_label.visible = route_label.visible
	result_card.visible = over and not _rating
	if over:
		_over_l.visible = false
		return
	_score_l.text = tr("%d점   ·   속도 %02d m/s") % [score, int(v)]
	var k := maxi(cur_k, cp_k)
	route_label.text = tr("%02d / %02d   ·   %s   ·   크기 %.1f") % [k + 1, Z.size(), _format_time(run_elapsed), s_goal]
	var hints := ["끌어서 항아리를 깔고 빨간 기둥은 피해", "뛰기 · 놓치면 숨은 수정 동굴로", "쪼개면 1초 돌진 · 집을 뚫고 가볍게 회전", "파란 머리 탑·신상 = 공중에서 버티기로 쾅 → 가속", "집을 깔거나 뛰어넘어 길을 골라", "흰 빗금 눈 = 성장 · 노란 길 = 해빙", "초록 점선에서 던져 수정에 통로를 열어", "노란 돌은 받아 · 빨간 돌은 피해 / 쪼개서 막아"]
	action_label.text = tr(str(Z[k].get("objective", hints[mini(k, hints.size() - 1)])))
	for drum: Dictionary in drums:
		if dist >= float(drum.a) and dist < float(drum.b) and on_ground:
			action_label.text = tr("발판 힘 %d%% · %s") % [int(drum_charge * 100.0), tr("손을 떼서 발사!" if drum_charge >= 0.4 else "버티기를 길게 눌러")]
			return
	for rope: Array in ropes:
		if float(rope[0]) - dist > 0.0 and float(rope[0]) - dist < 60.0:
			action_label.text = tr("앞 다리 한계 %.1f / 내 몸 %.1f\n%s") % [float(rope[2]), s_goal, tr("더 쪼개서 가볍게!" if s_goal > float(rope[2]) else "가운데로 건너자")]
			return
	if k == 5:
		for th: Thing in things:
			if not th.flat and th.kd == KIND.ice and th.d > dist and th.d - dist < 85.0:
				action_label.text = tr("얼음벽 4.5 / 내 몸 %.1f\n%s") % [s_goal, tr(("돌진 중! 그대로 뚫어" if dash_t > 0.0 else "눈으로 키우거나 · 벽 앞에서 쪼개 돌진") if s_goal < 4.5 else "충분히 커졌다 · 벽을 깨자")]
				return


func _current_tick(dt: float, hold: bool) -> void:
	for flow: Dictionary in currents:
		if dist < float(flow.a) - 80.0 or dist > float(flow.b) + 10.0:
			continue
		var pulse := 0.5 + 0.5 * sin(clock * 1.8 + float(flow.a) * 0.02)
		for node: MeshInstance3D in flow.markers:
			if is_instance_valid(node):
				node.material_override = mat(WHITE if pulse < 0.5 else D)
		if dist >= float(flow.a) and dist < float(flow.b) and bx > float(flow.x0) and bx < float(flow.x1) and on_ground:
			x_goal += float(flow.dir) * (2.5 + pulse * 5.0) / sqrt(s / 2.0) * (0.14 if hold else 1.0) * dt
			# Flow pushes the body, so shedding weight also changes the steering problem.
			if hold:
				v += 7.0 * dt
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
			sfx("launch")
			drum_charge = 0.0
		else:
			drum_charge = maxf(0.0, drum_charge - dt * 0.8)
		for node: MeshInstance3D in active.nodes:
			if is_instance_valid(node):
				node.material_override = mat(GOOD if drum_charge >= 0.4 else WHITE)
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


func _ending_tick(dt: float) -> void:
	won_t += dt
	v = move_toward(v, 0.0, dt * 24.0)
	dist = minf(goal_d + 12.0, dist + v * dt)
	by = _h(dist)
	bx = lerpf(bx, 0.0, dt * 2.0)
	on_ground = true
	_place(dt)
	var target := _pos(goal_d + 20.0, 0.0, _h(goal_d) + 8.0)
	cam.position = cam.position.lerp(_pos(goal_d - 24.0, 26.0, _h(goal_d) + 24.0), minf(1.0, dt * 1.5))
	cam.look_at(target, Vector3.UP)
	if won_t > 3.2:
		end()


func end() -> void:
	if over:
		return
	if not won:
		run_deaths += 1
	super()
	result_title.text = tr("금메달" if finish_time <= GOLD_TIME else ("은메달" if finish_time <= SILVER_TIME else "동메달")) + tr(" · 바다 도착") if won else tr("다시 굴러가자")
	var record_text := _format_time(best_time) if best_time > 0.0 else tr("아직 없음")
	result_values.text = tr("%s   ·   %d점\n최고 완주 %s\n%s") % [_format_time(finish_time if won else run_elapsed), score, record_text, tr("새 시간 기록!") if new_record else (tr("최고 점수 %d") % record_score)]
	result_note.text = tr("금 3:00 / 은 4:00 / 동 완주\n재도전 %d회 · 출발부터 실패 시간 포함") % run_deaths if won else tr("%s\n%s에서 이어서") % [tr(failure_reason), tr(str(Z[maxi(cp_k, 0)].msg))]
	retry_button.text = tr("한 번 더" if won else "구역 다시")
	_over_l.visible = false
	result_card.visible = true


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
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 6, 1, 1, 6, 5, 2, 4, 3, 2, 5, 4, 2, 1, 5])
	arrow_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return arrow_mesh


func _howto_card() -> Control:
	var card := super()
	for node in card.get_children():
		if node is Label:
			(node as Label).label_settings.font_size = 32
	return card


# ---- English: 폰·브라우저 언어가 한국어가 아니면(또는 주소에 ?lang=en) 영어로 ----
# 라벨은 Godot 자동 번역(같은 글이면 바뀜), 그려지는 버튼·서식 글은 tr() 로 감싼다.
func _lang() -> void:
	var en := OS.get_locale_language() != "ko"
	if OS.has_feature("web"):
		var q := str(JavaScriptBridge.eval("location.search", true))
		if q.contains("lang=en"):
			en = true
		elif q.contains("lang=ko"):
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


const HOWTO_EN := "Roll, Temple Stone!\nDrag to steer. Crush pots, dodge red!\nBigger = heavier. Too slow for 1.5s = out.\n\nA new button opens in each region:\nJUMP / SPLIT / HOLD / THROW\nGreen aim line → THROW to break purple crystal\nWhite striped snow = grow / yellow = melt\nFall off the aqueduct → hidden crystal cave!\nSPLIT = 1s dash: smash houses & ice walls\nBlue-capped towers: HOLD in mid-air to SLAM\n\nCurrents: HOLD or JUMP out of them.\nGolden pad: hold HOLD, then let go!\nReach the sea temple after 11 regions.\nGold 3:00 / Silver 4:00 / Bronze finish"

const EN := {
	# tofu.gd (공통 화면)
	"< 메뉴": "< Menu", "< 처음부터": "< Restart", "평가": "Rate", "탭해서 시작": "Tap to start",
	"이 게임 어때요?": "How was it?", "닫기": "Close", "한마디": "Comment", "고마워요!": "Thanks!",
	"보내는 중": "Sending", "한마디 보냈어요": "Comment sent", "저장 안 됨 · 별을 다시 탭": "Not saved · tap a star again",
	# 버튼
	"뛰기": "JUMP", "쪼개기": "SPLIT", "버티기": "HOLD", "던지기": "THROW",
	# 구역
	"신전 계곡": "Temple Valley", "수로 · 뛰기": "Aqueduct · JUMP", "갈림길 · 쪼개기": "Crossroads · SPLIT",
	"절벽 · 버티기": "Cliffs · HOLD", "광장 · 위에서": "Plaza · From Above", "설산 · 눈 굴리기": "Snow Peak · Snowball",
	"협곡 · 던지기": "Canyon · THROW", "해안 · 추격": "Coast · Chase", "조수 정원 · 물살 타기": "Tide Garden · Currents",
	"공명 제단 · 눌렀다 놓기": "Echo Altar · Hold & Release", "바다 신전 · 마지막 도약": "Sea Temple · Final Leap",
	"화살표가 물살 방향 · 버티면 고정 / 뛰면 벗어남": "Arrows = current · HOLD to stay / JUMP to escape",
	"황금 발판에서 버티기 → 힘이 차면 손을 떼 발사": "HOLD on the golden pad → release when charged",
	"키우고 → 던지고 → 가볍게 날아 바다 신전까지": "Grow → throw → fly light to the sea temple",
	# 안내
	"11개의 길 너머\n마지막 신전으로": "Across 11 roads\nto the last temple",
	"끌어서 항아리를 깔아봐": "Drag to crush the pots",
	"빨간 기둥은 옆으로 피해": "Dodge the red pillars",
	"큰 돌은 무거워\n오르막 전엔 욕심내지 마": "Big = heavy\ndon't overeat before hills",
	"노란 경사대에서\n저절로 날아간다": "Yellow ramp\nlaunches you",
	"다리는 가운데로": "Stay center on bridges",
	"틈! 뛰기": "Gap! JUMP", "담도 뛰어": "Jump the wall too", "석상!\n뛰거나 깔거나": "Statue!\njump or crush",
	"섞기: 깔고 뛰기": "Mix: crush & jump", "석상 뒤에 틈!\n깔고 뛰거나 넘거나": "Gap behind the statue!\ncrush & jump, or leap over",
	"담과 틈:\n한 번에!": "Wall and gap:\nin one go!",
	"쪼개면 가볍고\n잠깐 돌진: 집도 뚫는다": "SPLIT = lighter\n+ dash through houses",
	"섞기: 깔면 무거워\n회전에서 밀린다": "Mix: crushing = heavy\nturns push you out",
	"쪼개서 가볍게!": "SPLIT to get light!", "뛰어!": "JUMP!",
	"떨어지며 조종": "Steer while falling",
	"파란 머리 탑!\n떨어지며 버티기로 쾅": "Blue-capped tower!\nHOLD while falling to SLAM",
	"탑을 부수면 빨라진다": "Smashed towers speed you up",
	"황금 신상은\n버티기로만 깨진다": "Golden idol breaks\nonly with a HOLD slam",
	"섞기: 뛰고\n내려찍고": "Mix: jump\nthen slam",
	"구멍 피해\n신상을 내려찍어": "Avoid holes\nslam the idol",
	"회전!\n버티거나 쪼개": "Turn!\nHOLD or SPLIT",
	"길을 골라": "Pick a path", "좁은 문!": "Narrow gate!",
	"흰 눈 위를 구르면\n커진다": "Roll on white snow\nto grow",
	"얼음벽만큼 커야\n깬다": "Be as big as the ice wall\nto break it",
	"오르막 전에\n노란 길에서 녹여": "Melt on yellow\nbefore the hill",
	"다시 키워!": "Grow again!", "녹는 길": "Melting road",
	"섞기: 눈으로 키워\n얼음벽 깨기": "Mix: grow in snow\nbreak the ice wall",
	"무거운 몸으로\n뛰어!": "JUMP while heavy!",
	"오르막!\n쪼개서 가볍게": "Hill!\nSPLIT to get light",
	"던지기 = 내 몸 한 덩이를\n앞으로 (작아진다)": "THROW = toss a chunk of yourself\nforward (you shrink)",
	"보라 벽은 몸으로 못 지나간다\n점선이 초록이면 던져": "Purple walls block you\nTHROW when the line is green",
	"기둥보다 크면\n다리가 끊어진다": "Bigger than the posts\n= the bridge snaps",
	"다시 키워": "Grow again", "빠를수록 멀리 닿는다": "Faster = longer throw", "더 좁은 다리": "Narrower bridge",
	"섞기: 커지고, 던져서\n작아지고, 건너기": "Mix: grow, throw to\nshrink, then cross",
	"노랑은 받고\n빨강은 피해": "Catch yellow\ndodge red",
	"좁다! 빨강은\n쪼개서 막아": "Narrow! SPLIT\nto block red",
	"해안 응용: 배운 것을 섞어!": "Coast: mix everything!",
	"눈으로 키우고": "Grow in snow",
	"수정은 던져\n작아져야 다리를 건넌다": "THROW at crystals\nshrink to cross the bridge",
	"회전! 버티기": "Turn! HOLD", "구멍 피해\n내려찍기": "Avoid holes\nslam",
	"물살은 몸을 옆으로!\n화살표를 봐": "Currents push you sideways!\nWatch the arrows",
	"버티면 덜 밀린다": "HOLD = pushed less",
	"이번엔 반대 방향\n뛰면 물살을 벗어난다": "Other way now\nJUMP to escape",
	"섞기: 눈으로 탄약 확보": "Mix: grow ammo in snow",
	"물살을 버티며\n초록이면 던져": "HOLD in the current\nTHROW on green",
	"벽을 열고 물살 밖에서 뛰어!": "Open the wall, JUMP out of the current!",
	"반대 물살 착지\n가운데로 조종": "Land in the reverse current\nsteer to center",
	"앞의 넓은 틈:\n보통 점프로는 짧다": "Wide gap ahead:\na normal jump falls short",
	"황금 발판에서 버티기!\n초록이 되면 손을 떼": "HOLD on the golden pad!\nRelease on green",
	"공중에서 버티면 내려찍기\n착지까지는 손을 떼자": "HOLD in the air = slam\nlet go until you land",
	"섞기: 눈으로 몸을 키워": "Mix: grow in snow",
	"무거운 몸으로 발판 누르기\n초록에서 손을 떼!": "Press the pad while heavy\nrelease on green!",
	"착지 후 수정을 던져 깨고": "After landing, THROW at the crystal",
	"마지막 신전이 보인다": "The last temple is in sight",
	"마지막 응용\n눈으로 탄약을 만들고": "Final mix\nmake ammo in snow",
	"던져 작아져야\n다리가 버틴다": "THROW to shrink\nor the bridge snaps",
	"물살 뒤 황금 발판\n버티다가 손을 떼!": "Golden pad after the current\nHOLD, then release!",
	"돌아왔다\n신전의 빛을 향해": "Home again\ntoward the temple light",
	# 순간 글
	"← 갈림길 →": "← Fork →", "왼쪽!": "Left!", "오른쪽!": "Right!", "삐걱!": "Creak!",
	"다리가 끊어졌다!": "The bridge snapped!", "지하로!": "Down below!", "떨어진다!": "Falling!", "날아라!": "Fly!",
	"떨어짐!": "Fell off!", "쾅!": "Crash!", "수로 합류! 다음 틈을 봐": "Back on the aqueduct! Watch the next gap",
	"돌진 관통!": "Dashed through!", "느려!": "Too slow!", "멈췄다": "Stopped",
	"속도 %.0f 아래에서 1.5초 · 오르막 전엔 가볍게": "Under speed %.0f for 1.5s · get light before hills",
	"커진다": "Growing", "녹는다": "Melting", "너무 작다": "Too small", "던졌다!": "Thrown!", "깼다!": "Broken!",
	"닿는다! 던져": "In range! THROW", "%d개 쾅!": "%d smashed!", "쾅 착지!": "Big landing!",
	"황금 신상 쾅! 가속": "Idol smashed! Speed up", "탑 쾅! 가속": "Tower smashed! Speed up", "커졌다!": "Bigger!",
	"수정은 던져서!": "THROW at crystals!", "위에서 버티기로 쾅!": "HOLD-slam it from above!",
	"더 커지거나\n직전에 쪼개서 돌진!": "Grow bigger, or\nSPLIT right before to dash!",
	"더 커져야!": "Need to be bigger!", "쿵!": "Bonk!", "더 못 쪼갠다": "Can't split more",
	"쪼개서 돌진!": "Split dash!", "막았다!": "Blocked!", "받았다!": "Caught!",
	"숨은 수정 동굴!\n보석을 모아 노란 출구로": "Hidden crystal cave!\nGrab gems, head for the yellow exit",
	"보석 +40": "Gem +40", "힘이 찼다!\n손을 떼서 날아": "Charged!\nLet go to fly", "공명 도약!": "Echo leap!",
	"바다에 도착했다!": "You reached the sea!",
	# 화면 글
	"구역 다시": "Retry region", "처음부터": "From start", "한 번 더": "Once more",
	"%d점   ·   속도 %02d m/s": "%d pts   ·   speed %02d m/s",
	"%02d / %02d   ·   %s   ·   크기 %.1f": "%02d / %02d   ·   %s   ·   size %.1f",
	"끌어서 항아리를 깔고 빨간 기둥은 피해": "Drag to crush pots, dodge red pillars",
	"뛰기 · 놓치면 숨은 수정 동굴로": "JUMP · miss and fall into the crystal cave",
	"쪼개면 1초 돌진 · 집을 뚫고 가볍게 회전": "SPLIT = 1s dash · smash houses, turn light",
	"파란 머리 탑·신상 = 공중에서 버티기로 쾅 → 가속": "Blue caps = HOLD-slam from the air → speed up",
	"집을 깔거나 뛰어넘어 길을 골라": "Crush or jump houses, pick your path",
	"흰 빗금 눈 = 성장 · 노란 길 = 해빙": "White snow = grow · yellow = melt",
	"초록 점선에서 던져 수정에 통로를 열어": "THROW on the green line to open crystals",
	"노란 돌은 받아 · 빨간 돌은 피해 / 쪼개서 막아": "Catch yellow rocks · dodge red / SPLIT to block",
	"발판 힘 %d%% · %s": "Pad power %d%% · %s", "손을 떼서 발사!": "Let go to launch!", "버티기를 길게 눌러": "Hold HOLD",
	"앞 다리 한계 %.1f / 내 몸 %.1f\n%s": "Bridge limit %.1f / you %.1f\n%s",
	"더 쪼개서 가볍게!": "SPLIT to get lighter!", "가운데로 건너자": "Cross in the center",
	"얼음벽 4.5 / 내 몸 %.1f\n%s": "Ice wall 4.5 / you %.1f\n%s",
	"돌진 중! 그대로 뚫어": "Dashing! Smash through", "눈으로 키우거나 · 벽 앞에서 쪼개 돌진": "Grow in snow · or SPLIT-dash at the wall",
	"충분히 커졌다 · 벽을 깨자": "Big enough · break the wall",
	"금메달": "Gold", "은메달": "Silver", "동메달": "Bronze", " · 바다 도착": " · Reached the sea",
	"다시 굴러가자": "Roll again", "아직 없음": "none yet",
	"%s   ·   %d점\n최고 완주 %s\n%s": "%s   ·   %d pts\nBest finish %s\n%s",
	"새 시간 기록!": "New time record!", "최고 점수 %d": "Best score %d",
	"금 3:00 / 은 4:00 / 동 완주\n재도전 %d회 · 출발부터 실패 시간 포함": "Gold 3:00 / Silver 4:00 / Bronze finish\n%d retries · time includes fails",
	"%s\n%s에서 이어서": "%s\nContinue from %s",
}
