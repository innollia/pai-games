extends Tofu
## 신전 돌이 저절로 구른다. 끌어서 방향, 깔면 커지고 무거워지며 1.5초 느리거나 떨어지면 끝. 여덟 구역마다 카메라와 하는 법이 바뀐다: 계곡(등뒤) → 수로(옆, 뛰기 버튼으로 틈·담 넘기) → 갈림길(등뒤, 큰 회전에서 무거우면 바깥으로 밀림, 쪼개기로 가벼워지며 가속) → 절벽(위뒤, 떨어지며 조종, 버티기로 내려찍어 착지 충격으로 부수기) → 광장(위에서, 길 고르기와 좁은 문) → 설산(비스듬히 위, 흰 눈 줄에서 커지고 노란 길에서 녹는다: 얼음벽은 커야 깨지고 오르막은 작아야 넘는다) → 협곡(낮은 등뒤, 던지기 버튼으로 덩이를 앞으로 던져 수정을 깨고, 다리 앞 기둥보다 크면 흔들다리가 끊어진다) → 해안(돌 앞 정면, 뒤에서 오는 돌을 받거나 피하기). 구역마다 하늘·먼 실루엣 색이 바뀐다. 죽으면 그 구역 처음부터.
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
const ICE := Color("d6e9f5")
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
	# 얼음벽: 벽 높이(4.5)만큼 커야 깨진다. 뛰어 내려찍기로도 안 깨진다.
	"ice": {"size": Vector3(3.6, 4.5, 1.6), "need": 4.5, "pts": 6, "grow": 0.0, "mass": 0.22, "col": [ICEWALL, WHITE], "nodive": true},
	# 수정: 몸으로는 못 깨고, 던진 덩이로만 깨진다.
	"crystal": {"size": Vector3(3.6, 3.2, 1.2), "need": 99.0, "pts": 4, "grow": 0.0, "mass": 0.0, "col": [C], "nodive": true, "shot": true},
}
# 신전 계곡 깔 것 [종류, 거리, 길 가운데에서 옆으로]
const PUT1 := [
	["pot", 55, -2.5], ["pot", 62, 2.0], ["pot", 72, 0.0], ["pot", 84, -4.0], ["pot", 88, 4.0],
	["pillar", 100, 0.0], ["pot", 112, 1.5], ["pot", 120, -2.0], ["pot", 126, 3.5],
	["statue", 140, 2.5], ["pillar", 152, -3.8], ["pillar", 152, 3.8],
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
var cur_k := -1
var mode := "back"
var goal_d := -1.0
var ball: MeshInstance3D
var band: MeshInstance3D
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
# 비주얼: 하늘색, 먼 실루엣, 파편, 바람 줄, 찌그러짐
var sky_env: Environment
var sky_to := Color("d8eeff")
var far: Node3D
var clouds: Node3D
var far_k := -1
var pivot: Node3D
var sq := 0.0
var bits: Array = []
var streaks: Array = []


func _setup() -> void:
	howto = "끌어서 방향. 돌은 저절로 구르고, 깔면 커지고 무거워진다.\n구역마다 카메라와 하는 법이 바뀌고 버튼이 하나씩 열린다: 뛰기 · 쪼개기(작아지며 가속) · 버티기(제동, 공중에선 내려찍기) · 던지기(덩이를 앞으로).\n설산: 흰 눈에서 커지고 노란 길에서 녹는다. 협곡: 다리 앞 기둥보다 크면 다리가 끊어진다.\n1.5초 넘게 느리거나 떨어지면 끝. 다시 하면 그 구역 처음부터."
	time_limit = 0.0
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
				[22, -10, 5, 0, "gap"], [28, 0, 5], [70, -4, 2.6, 0, "bridge"], [50, -10, 6], [60, 6, 6]], "put": PUT1}]},
		{"msg": "수로 · 뛰기", "mode": "side", "skill": "jump", "road": STONE, "floor": GRASS, "accent": B, "posts": false, "scen": "aq",
			# 뛰면 30m 가까이 난다: 틈 뒤에는 착지할 자리를 두고, 담은 착지 뒤 한참 지나서
			"items": [{"legs": [[12, -2, 5], [13, -2, 2.2, 0, "aq"], [45, -6, 2.2, 0, "aq"], [10, -1, 2.2, 0, "gap"], [80, -10, 2.2, 0, "aq"],
				[14, -1, 2.2, 0, "gap"], [80, -10, 2.2, 0, "aq"], [18, -2, 2.2, 0, "gap"], [60, -7, 2.2, 0, "aq"], [22, -2, 2.2, 0, "gap"],
				[30, -3, 2.2, 0, "aq"], [15, 0, 4]],
				"put": [["pot", 38, 0], ["pot", 48, 0], ["pot", 60, 0], ["wall", 125, 0], ["pot", 148, 0], ["pot", 153, 0],
					["wall", 222, 0], ["pot", 240, 0], ["pot", 246, 0], ["statue", 310, 0], ["pot", 322, 0]],
				"say": [[60, "틈! 뛰기"], [112, "담도 뛰어"], [296, "석상!\n뛰거나 깔거나"]]}]},
		{"msg": "갈림길 · 쪼개기", "mode": "back", "skill": "split", "road": GRASS, "floor": GRASS, "accent": A, "posts": true, "scen": "village",
			"items": [
				{"legs": [[30, -6, 7], [30, -5, 8]], "put": [["house", 18, -4.5], ["pot", 28, 2], ["pot", 32, 4], ["house", 45, 4], ["pot", 52, -2]],
					"fence": [10], "say": [[6, "쪼개면 가벼워"]]},
				{"fork": [
					{"legs": [[26, -3, 6, 90], [70, -12, 7]], "put": [["house", 34, -3], ["pot", 40, 3], ["house", 48, 3], ["pot", 56, -3],
						["house", 62, -3], ["house", 76, 3], ["pot", 84, 0]], "fence": [92]},
					{"legs": [[26, -3, 5, -90], [70, -18, 4.5]], "put": [["pot", 45, 0], ["pot", 70, -2], ["pot", 72, 2]], "fence": [56]}]},
				{"legs": [[24, -5, 7]], "put": [["pot", 10, -3], ["pot", 12, 3]]},
				{"fork": [
					{"legs": [[22, -2, 6, 100], [50, -10, 7]], "put": [["house", 30, 3], ["house", 40, -3], ["house", 52, 2], ["statue", 60, -2]]},
					{"legs": [[22, -2, 6, -100], [26, -6, 6], [10, 4, 6, 0, "ramp"], [12, -4, 6, 0, "gap"], [22, -4, 6]],
						"put": [["pot", 30, 0], ["pot", 80, -2], ["pot", 82, 2]]}]},
				{"legs": [[40, -8, 7], [30, 3, 7]], "put": [["house", 15, -3.5], ["house", 30, 3.5], ["pot", 50, 0]], "fence": [60]}]},
		{"msg": "절벽 · 버티기", "mode": "fall", "skill": "hold", "road": ROCK, "floor": WATER, "accent": WHITE, "posts": true, "scen": "cliff",
			"items": [
				{"legs": [[40, -6, 7], [30, -5, 7]], "put": [["pot", 20, -2], ["pot", 25, 2]], "say": [[50, "떨어지며 조종"]]},
				{"legs": [[3, -40, 7, 0, "drop"], [55, -6, 12], [25, -3, 8]],
					"put": [["house", 23, 0], ["house", 38, 6], ["house", 52, -6], ["pot", 30, -8], ["pot", 45, 8]],
					"holes": [[30, 42, -12.3, -2], [44, 54, 2, 12.3]], "say": [[70, "버티기로 내려찍기"]]},
				{"legs": [[3, -30, 8, 0, "drop"], [60, -8, 12], [30, -5, 7]],
					"put": [["house", 20, -5], ["house", 34, 5], ["statue", 48, 0], ["pot", 56, -6], ["pot", 58, 6]],
					"holes": [[25, 35, -4, 4], [44, 55, -12.3, -3]]}]},
		{"msg": "광장 · 위에서", "mode": "top", "skill": "", "road": SOFT, "floor": GRASS, "accent": C, "posts": false, "scen": "plaza",
			"items": [{"legs": [[25, -4, 7], [150, -15, 22, 0, "plaza"], [14, -1, 4, 0, "gate"], [25, -4, 6]],
				"put": [["pillar", 55, -8], ["pillar", 55, 8], ["pillar", 70, 0], ["pillar", 88, -10], ["pillar", 88, 10],
					["house", 62, -16], ["house", 76, -16], ["house", 90, -17],
					["pot", 60, 14], ["pot", 64, 17], ["pot", 68, 13], ["pot", 74, 16], ["pot", 80, 14], ["pot", 84, 18],
					["house", 135, -18], ["house", 135, -12], ["house", 135, -6], ["house", 135, 6], ["house", 135, 12], ["house", 135, 18],
					["pot", 145, -2], ["pot", 160, 2], ["post", 177, -3.6], ["post", 177, 3.6]],
				"fence": [102], "holes": [[115, 121, -6, 0], [150, 156, 6, 12]], "say": [[40, "길을 골라"], [158, "좁은 문!"]]}]},
		# 설산: 굴리는 길 자체가 자원. 흰 눈 줄에서 커지고(얼음벽을 깰 자격) 노란 길에서 녹는다(오르막을 넘을 가벼움).
		{"msg": "설산 · 눈 굴리기", "mode": "iso", "skill": "", "road": ICE, "floor": Color("eef8ff"), "accent": B, "posts": false, "scen": "snow",
			"items": [{"legs": [[20, -3, 8], [130, -24, 9], [24, -1, 9], [70, -13, 9], [14, -1, 9], [55, 19, 8], [10, -1, 8],
				[90, -16, 9], [20, -1, 9], [40, -6, 8], [20, -2, 8]],
				"snow": [[28, 142, -9, -1], [182, 240, -9, -1], [322, 410, -9, 9]],
				"sun": [[182, 240, 1, 9], [432, 470, -9, 9]],
				"put": [["pot", 50, 5], ["pot", 72, 4], ["pot", 96, 6], ["pot", 122, 4], ["pot", 200, 5], ["pot", 226, 6], ["pot", 350, 0]],
				"row": [[164, "ice"], [422, "ice"]],
				"holes": [[205, 214, -2.5, 2.5]],
				"say": [[8, "흰 눈 위를 구르면\n커진다"], [140, "얼음벽만큼 커야\n깬다"], [176, "오르막 전에\n노란 길에서 녹여"], [312, "다시 키워!"], [428, "녹는 길"]]}]},
		# 협곡: 던지기(크기 1을 앞으로 던져 수정을 깬다). 흔들다리는 입구 기둥 높이보다 크면 끊어진다. 무게가 탄약이자 죄.
		{"msg": "협곡 · 던지기", "mode": "low", "skill": "throw", "road": STONE, "floor": WATER, "accent": A, "posts": false, "scen": "canyon",
			"items": [{"legs": [[20, -3, 7], [60, -10, 7], [20, -2, 7], [45, -3, 4, 0, "rope", 3.6], [15, -1, 7], [50, -9, 7], [20, -2, 7],
				[55, -4, 3.2, 0, "rope", 3.0], [15, -1, 7], [40, -7, 7], [20, -1, 7]],
				"put": [["pot", 30, -3], ["pot", 34, 3], ["pot", 42, 0], ["statue", 52, -3], ["pot", 60, 3], ["pot", 66, -2], ["pot", 72, 2],
					["pot", 165, -4], ["pot", 168, 0], ["pot", 171, 4], ["house", 182, -3.5], ["statue", 186, 3.5], ["pot", 194, -4], ["pot", 197, 0],
					["pot", 200, 4], ["statue", 206, 0], ["pot", 310, 0]],
				"row": [[90, "crystal"], [222, "crystal"]],
				"say": [[6, "던지기:\n덩이를 앞으로"], [76, "보라 수정은\n던져서 깨"], [96, "기둥보다 크면\n다리가 끊어진다"], [150, "다시 키워"], [212, "또 수정!"], [228, "더 좁은 다리"]]}]},
		{"msg": "해안 · 정면", "mode": "front", "skill": "", "road": STONE, "floor": WATER, "accent": B, "posts": true, "scen": "coast",
			"items": [{"legs": [[20, -4, 7], [260, -46, 7], [20, 0, 8], [3, -30, 8, 0, "drop"], [40, -2, 8, 0, "gap"]],
				"put": [["pot", 60, -3], ["pot", 62, 3], ["pot", 130, 0], ["pot", 200, -4], ["pot", 202, 4]],
				"rocks": [30, 262], "goal": 300, "say": [[22, "노랑은 받고\n빨강은 피해"]]}]},
	]


func _reset() -> void:
	dist = 0.0
	v = 16.0
	s = 2.0
	s_goal = 2.0
	bx = 0.0
	x_goal = 0.0
	vy = 0.0
	on_ground = true
	fallen = false
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
	box(Vector3.ZERO, Vector3(1.04, 1.04, 0.22), WHITE, ball)
	band = box(Vector3.ZERO, Vector3(0.22, 1.04, 1.04), ME, ball)
	chunk = box(Vector3.ZERO, Vector3.ONE * 1.3, STONE)
	chunk.visible = false
	chunk_t = 0.0
	shot = box(Vector3.ZERO, Vector3.ONE * 1.4, A)
	box(Vector3.ZERO, Vector3(1.06, 0.3, 1.06), ME, shot)
	shot.visible = false
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
			kit_button("jump", "뛰기", Vector2(610, 1150), 88.0, D)
		"split":
			kit_button("split", "쪼개기", Vector2(610, 955), 80.0, C)
		"hold":
			kit_button("hold", "버티기", Vector2(610, 770), 80.0, B)
		"throw":
			kit_button("throw", "던지기", Vector2(610, 590), 76.0, A)


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
	msg("왼쪽!" if side == 0 else "오른쪽!", 0.7)
	beep(600.0 if side == 0 else 750.0, 0.1, 0.0, 0.2)
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
		while j < b and o.sol[j] == 1 and o.hw[j] == o.hw[i] and o.tg[j] == o.tg[i] \
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
					e.basis = bs
					e.scale = Vector3(hw * 2.0, 0.08, 0.7)
					e.position = p0 + dir * ((q + 0.5) / nb) + up * 0.03
			elif tg != "plaza":
				for sd: float in [-1.0, 1.0]:
					var e := box(Vector3.ZERO, Vector3.ONE, WHITE, nd)
					e.basis = bs
					e.scale = Vector3(0.4, 0.1, ln + 0.4)
					e.position = (p0 + p1) * 0.5 + rt * sd * (hw - 0.2) + up * 0.04
		i = j
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
	m.rotation.y = _oyaw(o, d)


## 조각의 깔 것·구멍·안내·끝·돌 굴러오는 구간. loc0 = o 안에서의 시작 거리, d0 = 길 전체에서의 시작 거리
func _make_things(it: Dictionary, o: Dictionary, loc0: float, d0: float, z: Dictionary) -> Array:
	var out := []
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
			_plate(o, loc0 + float(hl[0]), loc0 + float(hl[1]), float(hl[2]), float(hl[3]), WATER, z.node, 0.08)
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
	var p0 := _opos(o, la, xm, _oh(o, la))
	var p1 := _opos(o, lb, xm, _oh(o, lb))
	var m := box(Vector3.ZERO, Vector3.ONE, col, nd)
	m.basis = Basis.looking_at((p1 - p0).normalized(), Vector3.UP)
	m.scale = Vector3(x1 - x0, 0.2, (p1 - p0).length())
	m.position = (p0 + p1) * 0.5 + Vector3.UP * lift


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
	box(Vector3(mid.x, fy, mid.y), Vector3(hi.x - lo.x + 80.0, 1.0, hi.y - lo.y + 80.0), def.floor, nd)
	if z.k == 0:
		var p := _pos(0.0, 0.0, 0.0)
		var h := _h(0.0)
		box(p + Vector3(0, h + 6.0, 10.0), Vector3(20, 12, 6), WHITE, nd)
		box(p + Vector3(0, h + 12.6, 10.0), Vector3(22, 1.4, 7), D, nd)
		for sd: float in [-1.0, 1.0]:
			box(p + Vector3(sd * 7.8, h + 4.0, 3.0), Vector3(1.4, 8, 1.4), WHITE, nd)
	if z.k + 1 < Z.size():
		var col: Color = SKILL_COL.get(Z[z.k + 1].skill, WHITE)
		var gd := float(b) - 4.0
		var hw: float = pd.hw[_oi(pd, gd)]
		var gh := _h(gd)
		var yw := _yaw(gd)
		for sd: float in [-1.0, 1.0]:
			var g := box(_pos(gd, sd * (hw + 1.0), gh + 5.0), Vector3(1.4, 10, 1.4), col, nd)
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
		if int(z.k) > cur_k and dist >= float(z.start):
			_enter(z)
	var gone := false
	for z: Dictionary in zones:
		if not z.freed and float(z.end) >= 0.0 and dist > float(z.end) + 30.0:
			(z.node as Node3D).queue_free()
			z.freed = true
			gone = true
	if gone:
		_relist()
	for i in range(says.size() - 1, -1, -1):
		if dist >= float(says[i][0]):
			msg(says[i][1], 1.4)
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
func _far_build(k: int) -> void:
	if far_k == k:
		return
	far_k = k
	for c in far.get_children():
		if c != clouds:
			c.queue_free()
	var def: Dictionary = Z[k]
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
			var cap := box(Vector3(0, 0.5 - 6.0 / (h - bot), 0), Vector3(0.7, 12.0 / (h - bot), 0.7), WHITE.lerp(sky, 0.2), m)
			cap.rotation.y = 0.3


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
	if sky_env:
		sky_env.background_color = sky_env.background_color.lerp(sky_to, minf(1.0, dt * 1.5))
	if clouds:
		clouds.rotation.y += dt * 0.015


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	_fx(dt)
	_zones_tick()
	s = lerpf(s, s_goal, minf(1.0, dt * 4.0))
	var mm := s / 2.0
	hurt -= dt
	cool -= dt
	shake = maxf(0.0, shake - dt * 2.5)
	_chunk(dt)
	if won:
		won_t += dt
		if won_t > 1.6:
			end()
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
	if kit_just("jump") and on_ground:
		vy = JUMP / pow(mm, 0.7)
		by += 0.05
		on_ground = false
		beep(440.0, 0.12, 880.0, 0.25)
	if kit_just("split"):
		_split()
	if kit_just("throw"):
		_throw()
	_shot(dt)
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
				beep(150.0, 0.08, 90.0, 0.25)
				msg("삐걱!", 0.3)
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
	var g := _ground(dist, bx)
	if is_nan(g):
		var i := _oi(pd, dist)
		if on_ground and pd.sol[i] == 0:
			if pd.tg[i] == "drop":
				msg("떨어진다!", 0.8)
				beep(520.0, 0.4, 180.0, 0.22)
			else:
				msg("날아라!", 0.6)
				beep(330.0, 0.15, 660.0, 0.22)
		on_ground = false
		if by < _h(dist) - 4.0 and not won:
			_fall("떨어짐!")
	elif by <= g:
		if by < g - 1.4 and not won:
			_fall("쾅!")
		else:
			if not on_ground:
				_land(vy, hold)
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
		if th.flat:
			continue
		var dd := th.d - dist
		if absf(dd) > 14.0:
			continue
		var sz: Vector3 = th.kd.size
		if absf(dd) < (s + sz.z) * 0.5 and absf(th.x - bx) < (s + sz.x) * 0.45 and by < th.base + sz.y * 0.8:
			var need: float = th.kd.need
			if s_goal >= need or (diving and need < 90.0 and not th.kd.get("nodive", false)):
				_crush(th, mm, not diving)
			elif hurt <= 0.0:
				_bonk(th)
			elif th.kd.get("nodive", false):
				# 얼음벽·수정은 진짜 벽: 튕긴 뒤에도 못 지나간다
				dist = minf(dist, th.d - (s + sz.z) * 0.5 - 0.2)
				v = minf(v, 3.0)
	_rocks(dt, mm)
	# 멈춤 검사
	if on_ground and v < VSTOP and not won:
		slow_t += dt
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = 0.3
			beep(260.0, 0.1, 200.0, 0.25)
			msg("느려!", 0.35)
		if slow_t > STOP_T:
			msg("멈췄다", 2.0)
			end()
			return
	else:
		slow_t = 0.0
		warn_t = 0.0
	if goal_d > 0.0 and dist >= goal_d and not won:
		won = true
		bonus += 500 + int(v * 10.0)
		cp_k = 0
		msg("바다다!", 2.0)
		play("win")
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
					beep(500.0 + s_goal * 60.0, 0.06, 0.0, 0.18)
					msg("커진다", 0.3)
			else:
				s_goal = maxf(2.0, s_goal - SUN_MELT * v * dt)
				if pad_t <= 0.0:
					pad_t = 0.12
					_burst(_pos(dist, bx, by + s * 0.6), WATER, 1, 4.0, 0.4)
				if floori(s_goal * 2.0) < before:
					beep(900.0, 0.05, 600.0, 0.14)
					msg("녹는다", 0.3)
			return


## 던지기: 크기 1을 떼어 앞으로 던진다. 수정은 이것으로만 깨진다.
func _throw() -> void:
	if cool > 0.0 or shot_t > 0.0:
		return
	if s_goal < 2.6:
		msg("너무 작다", 0.5)
		beep(200.0, 0.1, 150.0, 0.2)
		return
	s_goal = maxf(2.0, s_goal - 1.0)
	cool = 0.4
	shot_t = 1.6
	shot_d = dist + s * 0.5 + 0.8
	shot_x = bx
	shot_v = v + 30.0
	shot.visible = true
	sq = maxf(sq, 0.18)
	beep(260.0, 0.12, 1000.0, 0.28)
	msg("던졌다!", 0.4)


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
				msg("깼다!", 0.5)
				play("good")
				shake = maxf(shake, 0.3)
				shot_t = 0.0
			elif float(th.kd.need) < 90.0 and not th.kd.get("nodive", false):
				_smash(th)
			else:
				shot_t = 0.0
				_burst(shot.position, A, 4, 6.0)
			break
	if shot_t <= 0.0 or shot_d > _len() - 1.0:
		shot_t = 0.0
		shot.visible = false


## 덩이에 맞아 부서짐: 점수만, 커지지 않는다
func _smash(th: Thing) -> void:
	th.flat = true
	th.n.visible = false
	bonus += int(th.kd.pts) * 5
	_burst(th.n.position, th.col, 8, 11.0, 0.7)
	beep(1200.0, 0.1, 500.0, 0.26)


## 착지: 높이 떨어질수록(버티면 더) 넓게 부순다
func _land(vy0: float, hard: bool) -> void:
	sq = maxf(sq, clampf(-vy0 / 45.0, 0.0, 0.42))
	if vy0 < -10.0:
		_burst(_pos(dist, bx, by + 0.2), (Z[cur_k].road as Color).darkened(0.1), 3 + int(-vy0 / 8.0), 4.0 + -vy0 * 0.25)
	if vy0 > -14.0:
		if vy0 < -7.0:
			beep(90.0, 0.14, 50.0, 0.3)
		return
	var r := s * 0.6 + (-vy0) * 0.09 + (2.5 if hard else 0.0)
	var n := 0
	for th: Thing in things:
		if th.flat or float(th.kd.need) > 90.0 or th.kd.get("nodive", false):
			continue
		var sz: Vector3 = th.kd.size
		if absf(th.d - dist) < r + sz.z * 0.5 and absf(th.x - bx) < r + sz.x * 0.5:
			_crush(th, s / 2.0, false)
			n += 1
	if vy0 < -20.0:
		v *= 0.9
	shake = minf(1.2, 0.2 + (-vy0) / 50.0 + n * 0.15)
	beep(70.0, 0.3, 40.0, 0.35)
	if n > 0:
		msg("%d개 쾅!" % n, 0.8)
	elif vy0 < -24.0:
		msg("쾅 착지!", 0.8)


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
	var before := floori(s_goal)
	s_goal = minf(SMAX, s_goal + float(th.kd.grow))
	bonus += int(th.kd.pts) * 5
	shake = maxf(shake, 0.1 + float(th.kd.mass))
	beep(maxf(120.0, 560.0 - float(th.kd.mass) * 900.0), 0.1, 110.0, 0.28)
	if floori(s_goal) > before:
		msg("커졌다!", 0.6)
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
	elif th.kd.get("nodive", false):
		msg("더 커져야!", 0.8)
	else:
		msg("쿵!", 0.6)


## 쪼개기: 한 덩이 떼어 버리고 그만큼 가볍고 빨라진다. 떼어낸 덩이는 뒤로 굴러 뒤에서 오는 돌을 막는다.
func _split() -> void:
	if cool > 0.0:
		return
	if s_goal < 2.6:
		msg("더 못 쪼갠다", 0.5)
		beep(200.0, 0.1, 150.0, 0.2)
		return
	s_goal = maxf(2.0, s_goal - 1.0)
	v += 11.0
	cool = 0.6
	chunk.visible = true
	chunk_d = dist - s * 0.5
	chunk_x = bx
	chunk_t = 1.2
	shake = maxf(shake, 0.3)
	sq = maxf(sq, 0.22)
	_burst(_pos(dist - s * 0.5, bx, by + 1.0), STONE, 5, 7.0)
	beep(300.0, 0.12, 900.0, 0.26)
	msg("쪼갰다!", 0.5)
	for rk: Dictionary in rocks:
		if rk.on and rk.d < dist and dist - float(rk.d) < 45.0 and absf(float(rk.x) - bx) < 4.0:
			rk.on = false
			(rk.n as MeshInstance3D).visible = false
			msg("막았다!", 0.6)
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
					beep(110.0, 0.2, 80.0, 0.18)
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
		n.material_override = mat(D if s_goal >= r else BAD)
		if absf(rd - dist) < (s + r) * 0.5 and absf(float(rk.x) - bx) < (s + r) * 0.45 and by < _h(rd) + r:
			rk.on = false
			n.visible = false
			if s_goal >= r:
				s_goal = minf(SMAX, s_goal + r * 0.1)
				v += maxf(0.0, float(rk.v) - v) * 0.5
				bonus += int(r * 10.0)
				beep(700.0, 0.12, 1100.0, 0.26)
				msg("받았다!", 0.5)
			else:
				v *= 0.6
				x_goal += (3.5 if bx >= float(rk.x) else -3.5) / sqrt(mm)
				hurt = 0.5
				shake = 0.8
				play("bad")
				msg("쿵!", 0.5)


func _fall(text: String) -> void:
	fallen = true
	fall_t = 0.0
	v = minf(v, 6.0)
	msg(text, 2.0)
	beep(400.0, 0.6, 60.0, 0.3)


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
	ball.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else ME)
	var q := floori(ang / (PI * 0.5))
	roll_t -= dt
	if q != quarter:
		quarter = q
		if roll_t <= 0.0 and on_ground:
			roll_t = 0.07
			beep(clampf(60.0 + v * 2.0 - s * 4.0, 50.0, 200.0), 0.05, 45.0, 0.12)
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
			off = rt * (26.0 + v * 0.2 + s * 1.5) + Vector3.UP * (3.0 + s * 0.5)
			look = fw * 9.0 + Vector3.UP * (1.0 + s * 0.4)
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
			off = fw * (15.0 + s * 1.5) + Vector3.UP * (8.0 + s)
			look = -fw * 10.0 + Vector3.UP * (s * 0.3)
			fov = 60.0 + v * 0.25
		"iso":
			# 비스듬히 위 오른쪽 뒤: 눈 줄과 녹는 길이 한눈에
			off = -fw * (13.0 + s * 1.2) + rt * (12.0 + s) + Vector3.UP * (19.0 + s * 1.6)
			look = fw * (12.0 + v * 0.15) - rt * bx * 0.3
			fov = 52.0 + v * 0.2
		"low":
			# 땅에 붙은 낮은 등뒤: 다리 폭과 수정 줄이 눈앞에
			off = -fw * (6.0 + s * 1.5) + Vector3.UP * (1.8 + s * 0.95)
			look = _pos(dist + 22.0 + v * 0.2, bx * 0.6, cam_y + s * 0.5) - c
			fov = clampf(66.0 + v * 0.5, 66.0, 100.0)
		_:
			off = -fw * (8.0 + s * 2.0 + v * 0.1) - rt * bx * 0.4 + Vector3.UP * (3.2 + s * 1.3)
			look = _pos(dist + 14.0 + v * 0.15, bx * 0.5, cam_y + s * 0.4 - 1.5) - c
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
	var on := v > 26.0 and mode != "top" and not fallen
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
	# 정면(돌 앞 카메라)에서는 화면에서 보이는 쪽으로 움직이게 뒤집는다
	x_goal += dx * 0.05 * (-1.0 if mode == "front" else 1.0)


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)
