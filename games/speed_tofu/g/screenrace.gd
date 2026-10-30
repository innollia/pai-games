extends Tofu
## 짐 지고 화면 밖으로 밀리지 마 (옆모습 4인 배달 경주, 코스 6개): 조이스틱 좌우, 점프, 짐(톡 = 하나 버리고 튀어나감). 짐이 많으면 느리고 낮게 뛰지만 화면 왼쪽 끝에 밀릴 때 짐 하나를 내주고 버틴다. 결승은 짐이 있어야 통과, 화면 폭은 모두가 든 짐의 합. 건널목은 아래 선로가 빠르지만 앞에서 기차가 오고(1등은 못 본다), 흔들다리는 짐 3개 이상이면 밟은 판이 무너진다.
# 한 문장: 나는 막내 배달부로서 "카메라는 1등만 따라가고 화면 폭은 모두의 짐만큼"인 길을 짐 지고 달려 배달하지만, 빨리 갈수록 앞이 안 보이고 가벼울수록 밀려나기 쉬운 대가를 감수한다.
# 표절 점검 (SpeedRunners, 2016)
#  같은 것: 옆모습 4인 · 카메라가 1등을 따라감 · 화면 왼쪽 밖 탈락 · 라운드 승수 · 점프 발판
#  원작 것이라 뺀 것: 갈고리 · 아이템 상자(로켓·바나나, 원작은 로켓·얼음·상자 등) · 부스트 발판 · 시간 따라 좁아지는 화면
#  원작에 없는 우리 것: 1등의 앞 시야가 자기 속도에 비례해 줄어듦(천천히 가면 보임) · 짐(무게=느림·낮은 점프, 왼쪽 끝 목숨, 결승은 짐 필수)
#   · 화면 폭 = 모두가 든 짐의 합 · 앞사람 바람 · 끝이 있는 코스 · 코스마다 하는 방식(흐르는 바닥·정전·벽 없는 지붕)
#   · (5판) 건널목: 아래 도랑 선로는 벽 없이 빠르지만 앞쪽에서 기차가 달려온다. 2등은 기차가 보이고 1등은 종소리만 듣는다 → 시야 규칙의 답이 "선두면 위 승강장, 2등이면 선로"로 갈린다. 가벼우면 기차를 뛰어넘는다.
#   · (5판) 흔들다리: 짐 3개 이상(무게)으로 밟은 판은 금이 가 곧 떨어진다 → 무거우면 멈추지 말고 달려야 하고, 무거운 1등은 뒷사람 앞에 구멍을 낸다. 짐 규칙의 답이 "다리 앞에서 짐을 버려 가볍게 / 일부러 무겁게 다리를 부순다"로 바뀐다.
#   · (5판) 비주얼: 코스마다 하늘색·먼 산 실루엣, 떠가는 구름, 선두 속도 바람 줄, 착지 찌그러짐, 충돌·붕괴 파편(돌려 쓰기). 상자 수를 300 아래로: 코스 상자는 화면 근처만 돌려 쓰는 풀로 그린다.
#  결론: 이전 판은 뼈대와 도구가 원작과 거의 같아 표절 소리 들을 만했다. 지금은 뼈대(옆모습 화면 경주)만 같고 이기는 방법이 다르다.

const GRAV := 38.0
const JUMP_V := 15.0
const RUN_MAX := 11.0
const GROUND_ACC := 45.0
const AIR_ACC := 22.0
const OVER_G := 7.0  # 최고 속도보다 빠를 때 땅에서 줄어드는 정도
const OVER_A := 1.5
const FRICTION := 35.0
const MAX_FALL := 26.0
const PAD_V := 23.0
const DASH_V := 16.0
const DASH_T := 0.25
const HW := 0.4
const HH := 1.2
const STEP := 0.55
const COYOTE := 0.1
const JBUF := 0.12
const CAM_D := 22.0
const BX0 := -60.0
const BK := 6.0
const WIDE := 12.5  # 짐이 다 있을 때 화면 반폭
const NARROW := 5.5  # 짐이 다 없어지면 이만큼
const LOAD0 := 3  # 출발 짐
const LOAD_MAX := 5
const LOAD_SLOW := 0.06  # 짐 하나당 최고 속도 감소
const LOAD_JUMP := 0.035  # 짐 하나당 점프 감소
const FLOW := 5.5  # 흐르는 바닥 속도 (뒤로)
const WINS := 2
const PARCEL := Color("e0a96d")
const NIGHT := Color("1b1f3b")
const PERKS := ["신발", "끈", "용수철", "바람", "가벼운 상자", "단단한 몸"]
const PERK_SAY := {"신발": "더 빨리", "끈": "짐 하나 더", "용수철": "높이 뛰기", "바람": "바람 두 배", "가벼운 상자": "짐 무게 40% 덜", "단단한 몸": "치여도 덜 밀림"}
const TRAIN_V := 21.0  # 기차 속도 (왼쪽으로)
const TRAIN_L := 7.0
const TRAIN_H := 2.0
const TRENCH := 3.2  # 선로 도랑 깊이
const BREAK_W := 3.0  # 이 무게 이상이면 다리 판이 무너진다
const BREAK_T := 0.42  # 금 간 판이 떨어지기까지
const BOARD := Color("c99a6e")
const CRACK := Color("f08c00")
const POOL_N := 100  # 코스 상자를 그리는 풀 (화면 근처만)
const BITS_N := 12
const COURSES := [
	{"name": "시장", "rule": "", "say": "벽을 넘어라",
		"sky": Color("d8eeff"), "far": Color("b2f2bb"),
		"gnd": Color("ffd8a8"), "top": Color("ff922b"), "wall": Color("e8590c"),
		"bld": [Color("ffc9c9"), Color("ffec99"), Color("d3f9d8")],
		"segs": ["flat", "stairs", "wall", "pit", "awning", "crates", "flat", "crates"]},
	{"name": "강변", "rule": "flow", "say": "바닥이 흐른다: 짐이 무거우면 덜 밀린다",
		"sky": Color("e7f5ff"), "far": Color("a5d8ff"),
		"gnd": Color("c5f6fa"), "top": Color("3bc9db"), "wall": Color("1098ad"),
		"bld": [Color("d0ebff"), Color("e3fafc"), Color("d3f9d8")],
		"segs": ["flat", "river", "river", "pit", "stairs", "river", "wall", "river"]},
	{"name": "건널목", "rule": "train", "say": "아래 선로는 빠르다. 기차는 앞에서 온다",
		"sky": Color("fff4e6"), "far": Color("ffd8a8"),
		"gnd": Color("fff3bf"), "top": Color("fab005"), "wall": Color("f08c00"),
		"bld": [Color("ffe8cc"), Color("e7f5ff"), Color("fff9db")],
		"segs": ["flat", "track", "stairs", "track", "crates", "track", "pit"]},
	{"name": "야시장", "rule": "dark", "say": "정전: 꺼지면 아무도 앞을 못 본다",
		"sky": Color("fff0f6"), "far": Color("fcc2d7"),
		"gnd": Color("ffe8cc"), "top": Color("f76707"), "wall": Color("d9480f"),
		"bld": [Color("ffdeeb"), Color("fff3bf"), Color("e5dbff")],
		"segs": ["flat", "wall", "pit", "crates", "stairs", "awning", "wall", "pit"]},
	{"name": "흔들다리", "rule": "bridge", "say": "짐 3개 이상이면 밟은 판이 무너진다",
		"sky": Color("ebfbee"), "far": Color("8ce99a"),
		"gnd": Color("d8f5a2"), "top": Color("74b816"), "wall": Color("5c940d"),
		"bld": [Color("c0eb75"), Color("e9fac8"), Color("d3f9d8")],
		"segs": ["flat", "bridge", "stairs", "bridge", "pit", "bridge", "crates"]},
	{"name": "지붕", "rule": "roof", "say": "벽이 없다: 먼 틈은 짐을 버려야 넘는다",
		"sky": Color("f3f0ff"), "far": Color("d0bfff"),
		"gnd": Color("e5dbff"), "top": Color("cc5de8"), "wall": Color("9775fa"),
		"bld": [Color("f3d9fa"), Color("dbe4ff"), Color("ffdeeb")],
		"segs": ["roofgap", "roofgap", "longgap", "stairs", "roofgap", "longgap"]},
]


class Courier:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var grounded := false
	var sup := -1  # 밟은 것: 0 바닥 1 발판 3 흐르는 바닥
	var alive := true
	var ai := true
	var nick := ""
	var col := Color.WHITE
	var node: Node3D
	var fire: MeshInstance3D
	var poof: MeshInstance3D
	var packs: Array[MeshInstance3D] = []
	var streaks: Array[MeshInstance3D] = []
	var pips: Array[MeshInstance3D] = []
	var cargo := 0
	var stun := 0.0
	var dash := 0.0
	var drop_cd := 0.0
	var slip := false
	var coyote := 0.0
	var jbuf := 0.0
	var cut := true
	var skill := 1.0
	var err := 0.2
	var think := 0.0
	var poof_t := 0.0
	var immune := 0.0
	var face := 1.0
	var wins := 0
	var sq := 0.0  # 찌그러짐 (+ 납작, - 길쭉)
	var dive := false  # 경쟁자: 건널목에서 선로로 내려갈지
	# 이번 프레임 입력
	var mx := 0.0
	var i_jump := false
	var i_jheld := false
	var i_drop := false


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
var spots: Array[Vector2] = []  # 코스에 놓인 짐 자리
var parcels: Array = []  # 땅에 있는 짐 (돌려 쓴다)
var flows: Array = []  # 흐르는 바닥 눈금
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
var lean := 0.0  # 1등인 내 속도 비율 (클수록 화면이 앞으로 쏠려 앞이 안 보인다)
var load_all0 := 1
var edge_strip: MeshInstance3D
var curtain: MeshInstance3D
var marker: MeshInstance3D
var danger := false
var tick := 0.0
var was_slip := false
var spd_mul := 1.0
var jump_mul := 1.0
var slip_mul := 1.0
var load_bonus := 0
var load_w := 1.0
var perk_offer: Array = []
var taken: Array = []
var lead_t := 0.0
var radar_t := 0.0
var dark_t := 0.0
var dark_on := false
var dark_warn := false
var knock_mul := 1.0
# 코스 상자는 명세만 들고, 화면 근처 것만 풀 상자로 그린다
var vspecs: Array = []
var vslot := PackedInt32Array()
var vpool: Array[MeshInstance3D] = []
var vfree: Array[int] = []
var v_last := Vector3(1e9, 0, 0)
var trains: Array = []  # 건널목 선로마다 기차 하나
var boards: Array = []  # 흔들다리 판
var board_of := {}  # 상자 번호 -> 판
var bridge_said := false
var bits: Array = []  # 파편 (돌려 쓴다)
var bit_i := 0
var clouds: Array = []
var winds: Array[MeshInstance3D] = []
var wind_x := 0.0


func _setup() -> void:
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	howto = "막내 배달부 경주! 카메라는 1등만 따라간다. 화면 왼쪽 끝에 밀리면 짐 하나를 내주고 버틴다. 짐이 없을 때 밀리거나 구덩이에 빠지면 탈락.\n짐이 많을수록 느리고 낮게 뛴다. [짐]을 누르면 하나 버리고 튀어나간다. 결승선은 짐이 있어야 통과. 화면 폭은 모두가 든 짐만큼이라 짐이 줄면 좁아진다.\n1등이면 빨리 달릴수록 화면이 쏠려 앞이 안 보인다(천천히 가면 보인다).\n코스 6개: 강변은 바닥이 흐르고, 건널목은 아래 선로로 기차가 오고, 야시장은 정전, 흔들다리는 짐 3개 이상이면 판이 무너지고, 지붕은 먼 틈. 2승이면 다음 코스."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1120), 100.0, A)
	kit_button("drop", "짐", Vector2(600, 890), 82.0, PARCEL)


func _reset() -> void:
	ci = 0
	rnd = 0
	stage = null
	spd_mul = 1.0
	jump_mul = 1.0
	slip_mul = 1.0
	load_bonus = 0
	load_w = 1.0
	knock_mul = 1.0
	taken.clear()
	game_seed = randi()
	runners.clear()
	var cols := [ME, A, B, Color("f783ac")]
	var nicks := ["나", "주황", "하늘", "분홍"]
	for i in 4:
		var r := Courier.new()
		r.ai = i > 0
		r.col = cols[i]
		r.nick = nicks[i]
		_make_body(r)
		runners.append(r)
	pl = runners[0]
	parcels.clear()
	for i in 18:
		var n := box(Vector3(0, -50, 0), Vector3(0.6, 0.5, 0.6), PARCEL)
		n.visible = false
		parcels.append({"node": n, "on": false, "p": Vector2.ZERO, "owner": null, "cd": 0.0})
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	curtain = box(Vector3.ZERO, Vector3(1, 1, 0.2), NIGHT)
	curtain.visible = false
	marker = box(Vector3.ZERO, Vector3(0.36, 0.36, 0.36), ME)
	marker.rotation.z = PI * 0.25
	vpool.clear()
	for i in POOL_N:
		var m := box(Vector3(0, -80, 0), Vector3.ONE, WHITE)
		m.visible = false
		vpool.append(m)
	bits.clear()
	for i in BITS_N:
		var m := box(Vector3(0, -80, 0), Vector3(0.28, 0.28, 0.28), WHITE)
		m.visible = false
		bits.append({"node": m, "v": Vector3.ZERO, "life": 0.0})
	clouds.clear()
	for i in 4:
		var m := box(Vector3(0, 0, -22.0), Vector3(gen.randf_range(5.0, 9.0), 1.4, 1.0), WHITE)
		clouds.append({"node": m, "x": i * 17.0 + randf() * 6.0, "y": 13.0 + randf() * 7.0})
	winds.clear()
	for i in 5:
		var m := box(Vector3(0, -80, 4.0), Vector3(2.5, 0.06, 0.06), WHITE)
		m.visible = false
		winds.append(m)
	_restore_labels()
	_build_course()
	_start_round()


func _make_body(r: Courier) -> void:
	r.node = Node3D.new()
	world.add_child(r.node)
	box(Vector3(0, 0, 0), Vector3(HW * 2.0, HH * 0.75, 0.8), r.col, r.node)
	box(Vector3(0, 0.63, 0), Vector3(0.42, 0.36, 0.5), SOFT, r.node)
	box(Vector3(0.05, 0.88, 0), Vector3(0.6, 0.14, 0.6), WHITE if not r.ai else r.col.darkened(0.2), r.node)
	for k in LOAD_MAX + 1:
		var q := box(Vector3(-0.5, -0.2 + k * 0.4, 0), Vector3(0.5, 0.38, 0.6), PARCEL, r.node)
		q.visible = false
		r.packs.append(q)
	r.fire = box(Vector3(-0.9, 0, 0), Vector3(0.9, 0.35, 0.35), C, r.node)
	r.fire.visible = false
	r.poof = box(Vector3.ZERO, Vector3(1, 1, 1), WHITE)
	r.poof.visible = false
	for k in 3:
		var s := box(Vector3.ZERO, Vector3(1, 0.07, 0.07), WHITE)
		s.visible = false
		r.streaks.append(s)
	for k in WINS:
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
	spots.clear()
	flows.clear()
	trains.clear()
	boards.clear()
	board_of.clear()
	vspecs.clear()
	vslot.clear()
	vfree.clear()
	for k in vpool.size():
		vpool[k].visible = false
		vfree.append(k)
	v_last = Vector3(1e9, 0, 0)
	for e in get_children():
		if e is WorldEnvironment:
			(e as WorldEnvironment).environment.background_color = cdef.sky
	gen.seed = game_seed + ci * 7919
	fy = 0.0
	min_fy = 0.0
	gx = -40.0
	_floor(gx, 44.0)
	gx = 4.0
	var goal := 380.0 + mini(ci, 3) * 45.0
	var segs: Array = cdef.segs
	var last := ""
	var n_river := 0
	var n_bridge := 0
	while gx < goal:
		var s: String = segs[gen.randi() % segs.size()]
		if s == last and s != "flat" and s != "roofgap" and s != "river":
			s = "flat" if cdef.rule != "roof" else "roofgap"
		# 움직이는 상자가 많은 구간은 코스마다 몇 개까지만
		if (s == "river" and n_river >= 4) or (s == "track" and trains.size() >= 4) or (s == "bridge" and n_bridge >= 3):
			s = "flat"
		if gx < 30.0 and (s == "track" or s == "bridge"):
			s = "flat"  # 출발 직후는 몸 풀기
		n_river += 1 if s == "river" else 0
		n_bridge += 1 if s == "bridge" else 0
		last = s
		_seg(s)
	goal_x = gx + 2.0
	_floor(gx, 60.0)
	for z in [-1.4, 1.4]:
		_vbox(Vector3(goal_x, fy + 2.6, z), Vector3(0.3, 5.2, 0.3), GOOD)
	for k in 6:
		_vbox(Vector3(goal_x, fy + 5.2, -1.25 + k * 0.5), Vector3(0.32, 0.4, 0.5), WHITE if k % 2 == 0 else INK)
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
		_vbox(Vector3(bx + w * 0.5, h * 0.5 - 14.0, -12.0 - gen.randf() * 3.0), Vector3(w, h, 3.0), c)
		bx += w + gen.randf_range(0.5, 2.5)
	# 먼 산·건물 실루엣 (아주 느리게 지나간다)
	var fx := -60.0
	var farc: Color = cdef.far
	while fx < gx + 120.0:
		var w := gen.randf_range(10.0, 22.0)
		var h := gen.randf_range(14.0, 34.0)
		var c2 := farc.lightened(gen.randf() * 0.25)
		if cdef.rule == "roof" or cdef.rule == "train" or cdef.rule == "dark":
			_vbox(Vector3(fx + w * 0.5, h * 0.5 - 12.0, -34.0), Vector3(w, h, 2.0), c2)  # 먼 빌딩
		else:
			# 계단꼴 산: 넓은 아래 + 좁은 위
			_vbox(Vector3(fx + w * 0.5, h * 0.3 - 12.0, -34.0), Vector3(w, h * 0.6, 2.0), c2)
			_vbox(Vector3(fx + w * 0.5, h * 0.75 - 12.0, -34.5), Vector3(w * 0.45, h * 0.3, 2.0), c2.lightened(0.15))
		fx += w * 0.8
	# 앞 가로등 (빨리 지나가서 속도가 보인다)
	var px := 0.0
	while px < goal_x:
		var y := _floor_top(px, 60.0)
		if y > -100.0:
			_vbox(Vector3(px, y + 2.0, 3.2), Vector3(0.22, 4.0, 0.22), WHITE)
			_vbox(Vector3(px + 0.35, y + 4.0, 3.2), Vector3(0.9, 0.22, 0.3), cdef.top)
		px += 9.0


func _seg(s: String) -> void:
	var wallc: Color = cdef.wall
	match s:
		"flat":
			var w := gen.randf_range(6.0, 12.0)
			_floor(gx, w)
			if gen.randf() < 0.4:
				spots.append(Vector2(gx + w * 0.5, fy))
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
			_solid(Rect2(gx + 4.0, fy, 0.9, gen.randf_range(1.3, 2.2)), wallc, 0)
			gx += 9.0
		"pit":
			_floor(gx, 2.0)
			gx += 2.0 + gen.randf_range(3.0, 5.0)
			fy = clampf(fy + gen.randf_range(-1.0, 1.0), -3.0, 6.0)
			_floor(gx, 5.0)
			gx += 5.0
		"awning":  # 노란 발판 → 위쪽 지름길(짐 하나), 아래는 상자벽
			_floor(gx, 4.0)
			_solid(Rect2(gx + 2.2, fy, 1.6, 0.4), D, 1, 2.5)
			_plat(gx + 5.0, fy + 6.5, 17.0, wallc)
			spots.append(Vector2(gx + 12.0, fy + 6.5))
			_floor(gx + 4.0, 18.0)
			_solid(Rect2(gx + 9.0, fy, 1.2, 1.1), wallc, 0)
			_solid(Rect2(gx + 15.0, fy, 1.2, 1.6), wallc, 0)
			gx += 22.0
		"crates":
			_floor(gx, 12.0)
			_solid(Rect2(gx + 3.0, fy, 1.2, 1.0), wallc, 0)
			_solid(Rect2(gx + 8.0, fy, 1.2, 1.7), wallc, 0)
			if gen.randf() < 0.5:
				spots.append(Vector2(gx + 6.0, fy))
			gx += 12.0
		"river":  # 뒤로 흐르는 바닥 조각들, 사이는 물
			for k in 3:
				var w := gen.randf_range(7.0, 10.0)
				_solid(Rect2(gx, fy - 14.0, w, 14.0), cdef.gnd, 3)
				_vbox(Vector3(gx + w * 0.5, fy - 0.1, 0), Vector3(w, 0.2, 2.5), cdef.top)
				var marks: Array = []
				for m in 3:
					marks.append(box(Vector3(gx, fy + 0.05, 0.9), Vector3(0.7, 0.12, 0.4), WHITE, stage))
				flows.append({"x0": gx, "w": w, "y": fy, "marks": marks})
				gx += w
				if k < 2:
					var g := gen.randf_range(2.5, 3.5)
					_vbox(Vector3(gx + g * 0.5, fy - 2.5, 0), Vector3(g, 0.3, 2.5), B)
					gx += g
			_floor(gx, 3.0)
			gx += 3.0
		"track":  # 위 승강장(틈·상자) / 아래 도랑 선로(벽 없이 빠름, 앞에서 기차)
			_floor(gx, 3.0)
			gx += 3.0
			var x0 := gx
			var ln := gen.randf_range(26.0, 32.0)
			var yb := fy - TRENCH
			_solid(Rect2(x0, yb - 14.0, ln, 14.0), cdef.gnd, 0)
			_vbox(Vector3(x0 + ln * 0.5, yb + 0.02, 0), Vector3(ln, 0.06, 1.6), Color("e9ecef"))
			for z in [-0.55, 0.55]:
				_vbox(Vector3(x0 + ln * 0.5, yb + 0.1, z), Vector3(ln, 0.12, 0.14), Color("868e96"))
			var sx := x0 + 1.0
			while sx < x0 + ln:
				_vbox(Vector3(sx, yb + 0.05, 0), Vector3(0.3, 0.08, 1.5), Color("ced4da"))
				sx += 2.0
			# 승강장 조각: 틈에 빠지면 선로로 떨어진다 (다시는 못 올라온다)
			var x := x0
			var first := true
			var end_x := x0 + ln - 4.5  # 마지막 틈은 4.5 (넘을 수 있다)
			while x < end_x - 1.5:
				var w := gen.randf_range(4.5, 7.0)
				if x + w > end_x - 3.5:
					w = end_x - x
				_solid(Rect2(x, fy - 0.8, w, 0.8), cdef.gnd.darkened(0.04), 0)
				_vbox(Vector3(x + w * 0.5, fy - 0.08, 0), Vector3(w, 0.16, 2.5), cdef.top)
				if not first and w > 5.0 and gen.randf() < 0.6:
					_solid(Rect2(x + w * 0.5, fy, 1.1, gen.randf_range(1.0, 1.6)), cdef.wall, 0)
				elif gen.randf() < 0.4:
					spots.append(Vector2(x + w * 0.5, fy))
				first = false
				x += w + gen.randf_range(2.2, 3.0)
			# 끝: 마지막 틈 밑 용수철이 선로에서 위로 올려 준다
			_solid(Rect2(x0 + ln - 2.6, yb, 1.8, 0.4), D, 1, 2.0)
			gx = x0 + ln
			var tn := Node3D.new()
			stage.add_child(tn)
			box(Vector3(TRAIN_L * 0.5, TRAIN_H * 0.5, 0), Vector3(TRAIN_L, TRAIN_H, 1.8), B, tn)
			box(Vector3(TRAIN_L * 0.5, TRAIN_H + 0.08, 0), Vector3(TRAIN_L - 0.3, 0.16, 1.6), WHITE, tn)
			for k in 3:
				box(Vector3(1.6 + k * 2.0, TRAIN_H * 0.62, 0.92), Vector3(1.1, 0.6, 0.05), WHITE, tn)
			box(Vector3(-0.05, TRAIN_H * 0.35, 0), Vector3(0.12, 0.35, 1.0), D, tn)
			tn.position = Vector3(x0 + ln + 2.0, yb, 0)
			var lamp := box(Vector3(x0 + ln + 0.6, fy + 1.6, 1.3), Vector3(0.5, 0.5, 0.3), WHITE, stage)
			box(Vector3(x0 + ln + 0.6, fy + 0.7, 1.3), Vector3(0.14, 1.4, 0.14), INK, stage)
			trains.append({"x0": x0, "x1": x0 + ln, "y": yb, "x": x0 + ln + 2.0, "node": tn, "lamp": lamp,
				"st": "wait", "t": gen.randf_range(1.0, 3.0), "lit": false})
			min_fy = minf(min_fy, yb)
		"bridge":  # 짐 3개 이상으로 밟은 판은 곧 떨어진다
			_floor(gx, 3.0)
			gx += 3.0
			var n := gen.randi_range(8, 10)
			for k in n:
				var rc := Rect2(gx + k * 1.5, fy - 0.35, 1.45, 0.35)
				rects.append(rc)
				kinds.append(4)
				var bn := box(Vector3(rc.get_center().x, rc.get_center().y, 0), Vector3(1.45, 0.35, 2.2), BOARD, stage)
				var bd := {"i": rects.size() - 1, "node": bn, "home": bn.position, "t": -1.0, "gone": false, "vy": 0.0}
				boards.append(bd)
				board_of[rects.size() - 1] = bd
			var bw := n * 1.5
			for z in [-1.15, 1.15]:
				_vbox(Vector3(gx + bw * 0.5, fy + 1.0, z), Vector3(bw, 0.09, 0.09), INK.lightened(0.3))
				_vbox(Vector3(gx - 0.1, fy + 0.6, z), Vector3(0.22, 1.4, 0.22), cdef.wall)
				_vbox(Vector3(gx + bw + 0.1, fy + 0.6, z), Vector3(0.22, 1.4, 0.22), cdef.wall)
			_vbox(Vector3(gx + bw * 0.5, fy - 11.0, -1.0), Vector3(bw + 2.0, 0.4, 5.0), B.lightened(0.3))  # 아래 계곡물
			gx += bw
			_floor(gx, 3.0)
			gx += 3.0
		"roofgap", "longgap":
			_floor(gx, gen.randf_range(6.0, 10.0))
			gx = rects[rects.size() - 1].end.x
			if gen.randf() < 0.35:
				spots.append(Vector2(gx - 3.0, fy))
			var g := gen.randf_range(4.5, 6.2) if s == "roofgap" else gen.randf_range(6.8, 7.4)
			var ny := clampf(fy + gen.randf_range(-2.0, 1.0), -3.0, 6.0)
			if s == "longgap":
				ny = minf(ny, fy - 0.5)
			elif ny > fy + 0.5:
				g = minf(g, 5.0)
			gx += g
			fy = ny
			_floor(gx, 4.0)
			gx += 4.0
	min_fy = minf(min_fy, fy)


func _floor(x: float, w: float) -> void:
	_solid(Rect2(x, fy - 14.0, w, 14.0), cdef.gnd, 0)
	_vbox(Vector3(x + w * 0.5, fy - 0.1, 0), Vector3(w, 0.2, 2.5), cdef.top)


func _plat(x: float, top: float, w: float, c: Color) -> void:
	_solid(Rect2(x, top - 0.5, w, 0.5), c, 0, 2.0)


func _solid(rc: Rect2, c: Color, kind: int, depth := 2.4) -> void:
	rects.append(rc)
	kinds.append(kind)
	var m := rc.get_center()
	_vbox(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, depth), c)


## 코스 상자 명세 하나 (실제 상자는 화면 근처일 때만 풀에서 빌린다)
func _vbox(pos: Vector3, size: Vector3, c: Color) -> void:
	vspecs.append([pos, size, c])
	vslot.resize(vspecs.size())
	vslot[vspecs.size() - 1] = -1


func _vis() -> void:
	if absf(camx - v_last.x) < 0.4 and absf(camy - v_last.y) < 0.4 and absf(hwv - v_last.z) < 0.15:
		return
	v_last = Vector3(camx, camy, hwv)
	for i in vspecs.size():
		var sp: Array = vspecs[i]
		var p: Vector3 = sp[0]
		var s: Vector3 = sp[1]
		var f := (CAM_D - p.z) / CAM_D
		var inside := absf(p.x - camx) - s.x * 0.5 < hwv * f + 4.0 and absf(p.y - camy) - s.y * 0.5 < vhv * f + 4.0
		var k := vslot[i]
		if inside and k < 0 and not vfree.is_empty():
			k = vfree.pop_back()
			vslot[i] = k
			var m := vpool[k]
			m.position = p
			m.scale = s
			m.material_override = mat(sp[2])
			m.visible = true
		elif not inside and k >= 0:
			vpool[k].visible = false
			vfree.append(k)
			vslot[i] = -1


func _bi(x: float) -> int:
	return clampi(int(floor((x - BX0) / BK)), 0, buckets.size() - 1)


# ---- 라운드 ----
func _start_round() -> void:
	rnd += 1
	var xs := [-2.2, -1.0, -3.4, -4.6]
	load_all0 = 0
	for i in 4:
		var r := runners[i]
		r.p = Vector2(xs[i], 0.0)
		r.v = Vector2.ZERO
		r.alive = true
		r.cargo = LOAD0 + (0 if r.ai else load_bonus)
		load_all0 += r.cargo
		r.stun = 0.0
		r.dash = 0.0
		r.drop_cd = 0.0
		r.immune = 0.0
		r.cut = true
		r.face = 1.0
		r.poof_t = 0.0
		r.node.visible = true
		r.node.rotation = Vector3.ZERO
		r.poof.visible = false
		r.sq = 0.0
		r.node.scale = Vector3.ONE
		if r.ai:
			var lv := ci * 0.6  # 코스 6개를 예전 4개 난이도 폭에 맞춘다
			r.skill = 0.93 + 0.025 * lv + (i - 2) * 0.02
			r.err = 0.2 - 0.03 * lv
			r.dive = randf() < 0.45
		_probe(r)
	for bd in boards:
		bd.t = -1.0
		bd.gone = false
		bd.vy = 0.0
		kinds[bd.i] = 4
		var bn: MeshInstance3D = bd.node
		bn.position = bd.home
		bn.rotation = Vector3.ZERO
		bn.visible = true
		bn.material_override = mat(BOARD)
	for tr in trains:
		tr.st = "wait"
		tr.t = randf_range(1.5, 3.5)
		tr.x = tr.x1 + 2.0
		(tr.node as Node3D).position.x = tr.x
	bridge_said = false
	for b in bits:
		b.life = 0.0
		(b.node as Node3D).visible = false
	for pc in parcels:
		pc.on = false
		(pc.node as Node3D).visible = false
	for i in mini(spots.size(), parcels.size() - 6):
		_put_parcel(spots[i], null)
	rt = 0.0
	lead_t = 0.0
	lean = 0.0
	dark_t = 0.0
	dark_on = false
	dark_warn = false
	curtain.visible = false
	hwv = WIDE
	camx = 0.0
	camy = 2.0
	phase = "count"
	pt = 1.4
	danger = false
	msg("%s %d판" % [cdef.name, rnd] if rnd > 1 else "%s: %s" % [cdef.name, cdef.say], 1.2 if rnd > 1 else 2.2)
	beep(440.0, 0.12)


func _put_parcel(at: Vector2, who: Courier) -> void:
	for pc in parcels:
		if not pc.on:
			pc.on = true
			pc.p = at
			pc.owner = who
			pc.cd = 0.8 if who else 0.0
			var n: Node3D = pc.node
			n.visible = true
			n.position = Vector3(at.x, at.y + 0.25, 0)
			return


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
			if pt <= 0.0:
				_after_round()
		"perk":
			msg("특전 고르기", 0.2)
			for n in ["jump", "drop"]:
				if kit_just(n):
					_pick_perk(n)
					break
	_update_parcels(dt)
	_camera(dt)
	_draw_all()
	if phase != "perk" and _btns.has("drop"):
		_btns["drop"].label = "짐 %d" % pl.cargo


func _race(dt: float) -> void:
	pl.mx = kit_move.x
	pl.i_jump = kit_just("jump")
	pl.i_jheld = kit_held("jump")
	pl.i_drop = kit_just("drop")
	if cdef.rule == "dark":
		_dark(dt)
	for r in runners:
		if r.alive and r.ai:
			_ai(r, dt)
	_slipstream()
	for r in runners:
		if r.alive:
			_runner(r, dt)
	_pickups()
	if not trains.is_empty():
		_trains(dt)
	if not boards.is_empty():
		_boards(dt)
	if phase != "race":
		return
	# 화면 왼쪽 끝: 짐이 있으면 하나 내주고 버틴다, 없으면 탈락
	var left := camx - hwv
	for r in runners:
		if not r.alive:
			continue
		if r.p.y < kill_y or r.p.y < camy - vhv - 1.0:
			_out(r, "떨어졌다!")
		elif r.p.x + HW < left + 0.15:
			if r.immune > 0.0 and r.p.x + HW > left - 2.0:
				pass
			elif r.cargo > 0 and r.immune <= 0.0:
				_shove(r, left)
			else:
				_out(r, "밀려났다!")
	if phase != "race":
		return
	for r in runners:
		if r.alive and r.p.x > goal_x:
			if r.cargo > 0:
				_round_over(r)
				return
			_out(r, "빈손이라 실격!")
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
	# 1등이면 빠를수록 화면이 쏠린다: 앞이 안 보이니 벽·구덩이는 소리로만
	radar_t -= dt
	if _leader() == pl:
		if lead_t == 0.0:
			msg("선두! 빠를수록 앞이 안 보인다", 0.9)
			beep(900.0, 0.1, 1400.0, 0.2)
		lead_t += dt
		if lean > 0.35 and pl.grounded:
			var ax := pl.p.x + HW + 2.2
			var pit := _floor_top(ax, pl.p.y + 0.6) < pl.p.y - 2.0
			var wall := _solid_in(Rect2(pl.p.x + HW + 0.6, pl.p.y + STEP + 0.05, 3.5, 2.0))
			if (pit or wall) and radar_t <= 0.0:
				radar_t = 0.22
				beep(240.0 if pit else 420.0, 0.05, 0.0, 0.18)
	else:
		lead_t = 0.0
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


## 야시장: 6초마다 1.6초 정전. 꺼지면 1등 앞이 모두에게 가려진다
func _dark(dt: float) -> void:
	dark_t += dt
	var cyc := fmod(dark_t, 6.0)
	var warn := cyc > 3.6 and cyc < 4.4
	var now := cyc >= 4.4
	if warn and not dark_warn:
		beep(520.0, 0.08, 0.0, 0.16)
	if warn and fmod(cyc, 0.2) < dt:
		beep(520.0, 0.04, 0.0, 0.1)
	if now and not dark_on:
		beep(180.0, 0.35, 90.0, 0.25)
		msg("정전!", 0.6)
	elif dark_on and not now:
		beep(660.0, 0.1, 990.0, 0.18)
	dark_warn = warn
	dark_on = now


## 건널목: 기차는 선로 오른쪽 끝(벽 속)에서 나와 왼쪽으로 달린다. 종이 울리고 1초 뒤 출발.
## 2등은 화면 오른쪽에서 오는 기차가 보이지만, 빨리 달리는 1등은 화면이 쏠려 종소리만 듣는다.
func _trains(dt: float) -> void:
	var tm := Time.get_ticks_msec() * 0.001
	for tr in trains:
		var near: bool = pl.alive and pl.p.x > tr.x0 - 14.0 and pl.p.x < tr.x1 + 4.0
		match tr.st:
			"wait":
				tr.t -= dt
				if tr.t <= 1.1:
					tr.st = "warn"
					if near:
						msg("땡땡땡", 0.6)
			"warn":
				tr.t -= dt
				if near and fmod(tm, 0.3) < dt:
					beep(880.0 if fmod(tm, 0.6) < 0.3 else 740.0, 0.07, 0.0, 0.16)
				if tr.t <= 0.0:
					tr.st = "run"
					tr.x = tr.x1 + 2.0
					if near:
						beep(200.0, 0.45, 160.0, 0.28)
			"run":
				tr.x -= TRAIN_V * dt
				if tr.x + TRAIN_L < tr.x0 - 1.0:
					tr.st = "wait"
					tr.t = randf_range(2.2, 4.5)
					tr.x = tr.x1 + 2.0
				else:
					var hit := Rect2(tr.x, tr.y, TRAIN_L, TRAIN_H)
					for r in runners:
						if r.alive and r.immune <= 0.0 and hit.intersects(_box(r)):
							_train_hit(r)
		(tr.node as Node3D).position.x = tr.x
		var lit: bool = tr.st != "wait" and fmod(tm, 0.3) < 0.15
		if lit != tr.lit:
			tr.lit = lit
			(tr.lamp as MeshInstance3D).material_override = mat(BAD if lit else WHITE)


func _train_hit(r: Courier) -> void:
	var k := knock_mul if r == pl else 1.0
	r.v = Vector2(-17.0 * k, 7.0)
	r.stun = 0.55 * k
	r.immune = 0.9
	r.grounded = false
	r.sq = -0.4
	_burst(Vector3(r.p.x, r.p.y + 0.8, 0.6), 6, PARCEL if r.cargo > 0 else r.col)
	_snd(r, 140.0, 0.3, 60.0, 0.3)
	if r == pl:
		shk = 0.6
	if r.cargo > 0:
		r.cargo -= 1
		if r == pl:
			msg("기차에 치였다! 짐 하나", 0.8)
	else:
		_out(r, "기차에 치였다!")


## 흔들다리: 무게 BREAK_W 이상으로 밟은 판은 금이 가고 BREAK_T 뒤 떨어진다
func _crack(i: int, r: Courier) -> void:
	var bd: Dictionary = board_of.get(i, {})
	if bd.is_empty() or bd.t >= 0.0:
		return
	bd.t = 0.0
	(bd.node as MeshInstance3D).material_override = mat(CRACK)
	_snd(r, 330.0, 0.06, 200.0, 0.14)
	if r == pl and not bridge_said:
		bridge_said = true
		msg("무거워! 판이 무너진다", 0.9)


func _boards(dt: float) -> void:
	for bd in boards:
		if bd.t < 0.0:
			continue
		var bn: MeshInstance3D = bd.node
		var home: Vector3 = bd.home
		if not bd.gone:
			bd.t += dt
			bn.position.x = home.x + sin(bd.t * 70.0) * 0.06
			if bd.t >= BREAK_T:
				bd.gone = true
				kinds[bd.i] = -1
				bd.vy = 0.0
				if absf(home.x - camx) < hwv + 2.0:
					beep(160.0, 0.12, 90.0, 0.16)
					_burst(home, 2, BOARD)
		elif bn.visible:
			bd.vy -= GRAV * dt
			bn.position.y += bd.vy * dt
			bn.rotation.z += dt * 2.5
			if bn.position.y < home.y - 14.0:
				bn.visible = false


## 작은 상자 파편 (미리 만든 것을 돌려 쓴다)
func _burst(at: Vector3, n: int, c: Color) -> void:
	for k in n:
		var b: Dictionary = bits[bit_i]
		bit_i = (bit_i + 1) % bits.size()
		var m: MeshInstance3D = b.node
		m.visible = true
		m.position = at
		m.material_override = mat(c)
		b.v = Vector3(randf_range(-5.0, 5.0), randf_range(3.0, 9.0), randf_range(-1.0, 2.0))
		b.life = randf_range(0.4, 0.7)


func _shove(r: Courier, left: float) -> void:
	r.cargo -= 1
	r.immune = 0.7
	_mx(r, left + HW + 0.6 - r.p.x)
	r.v.x = maxf(r.v.x, 8.0)
	_snd(r, 260.0, 0.18, 520.0, 0.25)
	_burst(Vector3(r.p.x - 0.5, r.p.y + 1.0, 0.6), 3, PARCEL)
	r.sq = -0.35
	if r == pl:
		shk = maxf(shk, 0.35)
		msg("짐 하나 잃음" if r.cargo > 0 else "마지막 짐!", 0.7)


func _out(r: Courier, why: String) -> void:
	r.alive = false
	r.node.visible = false
	r.poof.visible = true
	r.poof_t = 0.5
	r.poof.position = Vector3(clampf(r.p.x, camx - hwv + 0.6, camx + hwv), maxf(r.p.y, camy - vhv + 2.0), 0.5)
	_burst(r.poof.position, 5, r.col)
	if r == pl:
		play("bad")
		shk = 0.6
		msg(why, 1.0)
	else:
		beep(300.0, 0.2, 120.0, 0.25)
		shk = maxf(shk, 0.25)
		msg("%s 탈락" % r.nick, 0.6)


func _round_over(w: Courier) -> void:
	phase = "roundend"
	pt = 1.8
	curtain.visible = false
	if w == null:
		msg("무승부", 1.6)
		return
	w.wins += 1
	if w == pl:
		score += 10 + 5 * pl.cargo
		play("win")
		msg("배달 성공! 짐 %d" % pl.cargo, 1.6)
	else:
		beep(330.0, 0.3, 200.0, 0.25)
		msg("%s 승" % w.nick, 1.6)


func _after_round() -> void:
	if pl.wins >= WINS:
		score += 50
		if ci >= COURSES.size() - 1:
			msg("배달 완료!", 3.0)
			end()
			return
		play("win")
		var pool := []
		for k in PERKS:
			if not taken.has(k):
				pool.append(k)
		pool.shuffle()
		perk_offer = pool.slice(0, 2)
		_btns["jump"].label = perk_offer[0]
		_btns["drop"].label = perk_offer[1]
		phase = "perk"
		return
	for r in runners:
		if r.ai and r.wins >= WINS:
			msg("%s 우승" % r.nick, 3.0)
			end()
			return
	_start_round()


func _pick_perk(n: String) -> void:
	var k: String = perk_offer[0 if n == "jump" else 1]
	taken.append(k)
	match k:
		"신발": spd_mul += 0.08
		"끈": load_bonus += 1
		"용수철": jump_mul += 0.12
		"바람": slip_mul = 2.0
		"가벼운 상자": load_w = 0.6
		"단단한 몸": knock_mul = 0.5
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
		_btns["drop"].label = "짐"


# ---- 달리기 한 명 ----
func _weight(r: Courier) -> float:
	return r.cargo * (1.0 if r.ai else load_w)


func _top(r: Courier) -> float:
	var top := RUN_MAX * (r.skill if r.ai else spd_mul) * (1.0 - LOAD_SLOW * _weight(r))
	if r.slip:
		top *= 1.0 + 0.12 * (1.0 if r.ai else slip_mul)
	return top


func _jump_v(r: Courier) -> float:
	return JUMP_V * (1.0 if r.ai else jump_mul) * (1.0 - LOAD_JUMP * _weight(r))


func _runner(r: Courier, dt: float) -> void:
	r.immune = maxf(r.immune - dt, 0.0)
	r.drop_cd = maxf(r.drop_cd - dt, 0.0)
	var top := _top(r)
	var mx := r.mx
	if r.stun > 0.0:
		r.stun -= dt
		mx = 0.0
		r.i_jump = false
		r.i_drop = false
	if r.i_drop and r.cargo > 0 and r.drop_cd <= 0.0:
		_drop(r)
	r.coyote = COYOTE if r.grounded else maxf(r.coyote - dt, 0.0)
	r.jbuf = JBUF if r.i_jump else maxf(r.jbuf - dt, 0.0)
	if r.jbuf > 0.0 and r.coyote > 0.0:
		r.v.y = _jump_v(r)
		r.coyote = 0.0
		r.jbuf = 0.0
		r.grounded = false
		r.cut = false
		r.sq = -0.3
		_snd(r, 600.0 - r.cargo * 40.0, 0.07, 900.0 - r.cargo * 60.0)
	if not r.cut and r.v.y > 0.0 and not r.i_jheld:
		r.v.y *= 0.5
		r.cut = true
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
	if r.dash > 0.0:
		r.dash -= dt
		r.v.x = maxf(r.v.x, DASH_V)
	r.v.y = maxf(r.v.y - GRAV * dt, -MAX_FALL)
	# 흐르는 바닥: 짐이 무거울수록 덜 밀린다
	if r.grounded and r.sup == 3:
		_mx(r, -FLOW * clampf(1.0 - 0.15 * _weight(r), 0.2, 1.0) * dt)
	var was_g := r.grounded
	var vy0 := r.v.y
	for s in 2:
		_mx(r, r.v.x * dt * 0.5)
		_my(r, r.v.y * dt * 0.5)
	_probe(r)
	if r.grounded and not was_g and vy0 < -6.0:
		r.sq = clampf(-vy0 / 40.0, 0.15, 0.5)
		if vy0 < -15.0 and absf(r.p.x - camx) < hwv + 2.0:
			_burst(Vector3(r.p.x, r.p.y + 0.1, 0.6), 2, cdef.top)
	r.sq = move_toward(r.sq, 0.0, dt * 2.5)
	if r.grounded and r.sup == 1:
		r.v.y = PAD_V * (1.0 - LOAD_JUMP * _weight(r))
		r.grounded = false
		r.cut = true
		_snd(r, 300.0, 0.25, 1100.0, 0.25)
		if r == pl:
			shk = maxf(shk, 0.2)


## 짐 하나를 뒤에 내려놓고 튀어나간다 (다른 사람이 주워 갈 수 있다)
func _drop(r: Courier) -> void:
	r.cargo -= 1
	r.drop_cd = 0.4
	r.dash = DASH_T
	r.v.x = maxf(r.v.x, DASH_V)
	var x := r.p.x - r.face * 1.2
	var y := _floor_top(x, r.p.y + 0.5)
	if y > r.p.y - 6.0:
		_put_parcel(Vector2(x, y), r)
	_snd(r, 420.0, 0.14, 1300.0, 0.22)
	if r == pl:
		shk = maxf(shk, 0.15)
		msg("가볍게!", 0.4)


func _box(r: Courier) -> Rect2:
	return Rect2(r.p.x - HW, r.p.y, HW * 2.0, HH)


func _mx(r: Courier, dx: float) -> void:
	if dx == 0.0:
		return
	r.p.x += dx
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			if kinds[i] < 0:
				continue
			var q: Rect2 = rects[i]
			if not q.intersects(a):
				continue
			if r.grounded and q.end.y - r.p.y <= STEP:
				r.p.y = q.end.y
				a = _box(r)
				continue
			if dx > 0.0:
				r.p.x = q.position.x - HW - 0.001
			else:
				r.p.x = q.end.x + HW + 0.001
			if absf(r.v.x) > 12.0:
				_snd(r, 160.0, 0.1, 80.0, 0.25)
				r.sq = -0.3
				if r == pl:
					_burst(Vector3(r.p.x + HW, r.p.y + 0.8, 0.6), 2, cdef.wall)
					shk = maxf(shk, 0.3)
			if signf(r.v.x) == signf(dx):
				r.v.x = 0.0
			a = _box(r)


func _my(r: Courier, dy: float) -> void:
	if dy == 0.0:
		return
	r.p.y += dy
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			if kinds[i] < 0:
				continue
			var q: Rect2 = rects[i]
			if q.intersects(a):
				if dy < 0.0:
					r.p.y = q.end.y
					r.v.y = 0.0
				else:
					r.p.y = q.position.y - HH - 0.001
					r.v.y = minf(r.v.y, 0.0)
				a = _box(r)


func _probe(r: Courier) -> void:
	var f := Rect2(r.p.x - HW + 0.05, r.p.y - 0.06, HW * 2.0 - 0.1, 0.07)
	r.grounded = false
	r.sup = -1
	var pad := false
	var flow := false
	for b in range(_bi(f.position.x), _bi(f.end.x) + 1):
		for i in buckets[b]:
			if kinds[i] < 0:
				continue
			var q: Rect2 = rects[i]
			if q.intersects(f) and q.end.y <= r.p.y + 0.02:
				r.grounded = true
				pad = pad or kinds[i] == 1
				flow = flow or kinds[i] == 3
				if kinds[i] == 4 and _weight(r) >= BREAK_W:
					_crack(i, r)
	if r.grounded:
		r.sup = 1 if pad else (3 if flow else 0)


## x 위에서 높이 ymax 아래 가장 높은 바닥 윗면 (없으면 아주 낮은 수)
func _floor_top(x: float, ymax: float) -> float:
	var best_y := -1.0e9
	for i in buckets[_bi(x)]:
		if kinds[i] < 0:
			continue
		var q: Rect2 = rects[i]
		if x > q.position.x and x < q.end.x and q.end.y <= ymax:
			best_y = maxf(best_y, q.end.y)
	return best_y


func _solid_in(a: Rect2) -> bool:
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			if kinds[i] < 0:
				continue
			var q: Rect2 = rects[i]
			if q.intersects(a):
				return true
	return false


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
	for pc in parcels:
		if not pc.on:
			continue
		var cp: Vector2 = pc.p
		for r in runners:
			if not r.alive or (r == pc.owner and pc.cd > 0.0):
				continue
			if r.cargo >= LOAD_MAX + (0 if r.ai else load_bonus):
				continue
			if absf(r.p.x - cp.x) < 0.8 and r.p.y - cp.y > -0.6 and r.p.y - cp.y < HH:
				r.cargo += 1
				pc.on = false
				(pc.node as Node3D).visible = false
				_snd(r, 660.0, 0.1, 880.0)
				if r == pl:
					msg("짐 %d" % r.cargo, 0.4)
				break


func _update_parcels(dt: float) -> void:
	for pc in parcels:
		if pc.on:
			pc.cd = maxf(pc.cd - dt, 0.0)
			(pc.node as Node3D).rotation.y += dt * 1.5


func _leader() -> Courier:
	var w: Courier = null
	for r in runners:
		if r.alive and (w == null or r.p.x > w.p.x):
			w = r
	return w


# ---- 경쟁자 ----
## 지금 짐으로 뛸 수 있는 거리
func _reach(r: Courier) -> float:
	return _top(r) * 2.0 * _jump_v(r) / GRAV


## 앞 구덩이 너비 (없으면 0)
func _gap_len(r: Courier) -> float:
	var x := r.p.x + HW
	var start := -1.0
	for k in 24:
		var gtop := _floor_top(x, r.p.y + 0.6)
		if gtop < r.p.y - 2.0:
			if start < 0.0:
				start = x
		elif start >= 0.0:
			return x - start
		x += 0.4
	return 0.0 if start < 0.0 else 9.0


func _track_at(x: float) -> Dictionary:
	for tr in trains:
		if x > tr.x0 - 1.0 and x < tr.x1:
			return tr
	return {}


func _ai(r: Courier, dt: float) -> void:
	r.mx = 1.0
	r.i_jump = false
	r.i_drop = false
	r.i_jheld = true
	r.think -= dt
	if r.think > 0.0:
		return
	r.think = randf_range(0.04, 0.1) / r.skill
	var look := 0.8 + absf(r.v.x) * 0.12
	var ax := r.p.x + HW + 0.25 + absf(r.v.x) * 0.035
	var pit := _floor_top(ax, r.p.y + 0.6) < r.p.y - 2.0
	var wall := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, look, 2.0))
	# 경쟁자도 1등이면 빠를수록 못 보고, 정전이면 못 본다
	var miss := r.err
	if _leader() == r:
		miss += 0.4 * clampf((absf(r.v.x) - 4.0) / (RUN_MAX - 4.0), 0.0, 1.0)
	if dark_on:
		miss += 0.3
	# 건널목: 선로로 내려갈 경쟁자는 승강장 틈을 일부러 안 넘는다
	var tr := _track_at(r.p.x)
	if pit and r.dive and not tr.is_empty() and r.p.y > tr.y + 1.0 and ax < tr.x1 - 5.0:
		pit = false
	if r.grounded and (pit or wall) and randf() > miss:
		r.i_jump = true
	# 선로 위: 보이면 기차를 뛰어넘는다 (1등이면 잘 못 본다)
	if not tr.is_empty() and tr.st == "run" and r.grounded and r.p.y < tr.y + 0.5:
		var gap: float = tr.x - (r.p.x + HW)
		if gap > 0.5 and gap < 4.5 and randf() > miss + 0.15:
			r.i_jump = true
	# 흔들다리: 무거우면 다리 앞에서 짐 하나를 버리기도 한다
	if cdef.rule == "bridge" and r.grounded and _weight(r) >= BREAK_W and r.cargo >= 2 and r.drop_cd <= 0.0:
		var ahead := r.p.x + HW + 1.5
		for i in buckets[_bi(ahead)]:
			if kinds[i] == 4 and rects[i].position.x > r.p.x and rects[i].position.x < ahead + 1.0 and randf() < 0.5:
				r.i_drop = true
				break
	# 짐 버리기: 먼 틈 앞, 또는 화면 끝에 몰렸을 때
	if r.cargo >= 2 and r.drop_cd <= 0.0:
		var far: bool = cdef.rule == "roof" and r.grounded and _gap_len(r) > _reach(r) * 0.95
		var behind := r.p.x - (camx - hwv) < 3.0
		if far or (behind and randf() < 0.25):
			r.i_drop = true


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	var asp := vs.y / maxf(vs.x, 1.0)
	if phase == "race":
		# 화면 폭 = 모두가 든 짐의 합
		var all := 0
		for r in runners:
			if r.alive:
				all += r.cargo
		var want := lerpf(NARROW, WIDE, clampf(float(all) / float(maxi(load_all0, 1)), 0.0, 1.0))
		hwv = lerpf(hwv, want, 1.0 - exp(-1.5 * dt))
	vhv = hwv * asp
	var lead := _leader()
	if lead and phase != "perk":
		var k := 1.0 - exp(-9.0 * dt)
		# 내가 1등이면 내 속도만큼 화면이 앞으로 쏠려 나는 오른쪽 끝에 붙는다
		var f := 0.0
		if lead == pl and phase == "race":
			f = clampf((absf(pl.v.x) - 4.0) / (RUN_MAX - 4.0), 0.0, 1.0)
		lean = lerpf(lean, f, 1.0 - exp(-3.0 * dt))
		camx = lerpf(camx, lead.p.x - hwv * lerpf(0.16, 0.74, lean), k)
		camy = lerpf(camy, lead.p.y + 2.0, 1.0 - exp(-4.0 * dt))
	cam.fov = rad_to_deg(2.0 * atan(hwv / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


func _draw_all() -> void:
	var tm := Time.get_ticks_msec() * 0.001
	for r in runners:
		r.poof.visible = r.poof_t > 0.0
		if r.poof_t > 0.0:
			r.poof_t -= get_process_delta_time()
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
		r.node.rotation.z = -clampf(r.v.x * 0.012, -0.2, 0.2)
		r.node.visible = r.immune <= 0.0 or fmod(tm, 0.12) < 0.08
		for k in r.packs.size():
			var q := r.packs[k]
			q.visible = k < r.cargo
			q.position.x = -0.5 * r.face
		r.fire.visible = r.dash > 0.0
		r.fire.position.x = -0.9 * r.face
		r.fire.scale.x = 0.9 + sin(tm * 50.0) * 0.3
		var ln := clampf((spd - 10.0) * 0.6, 0.0, 4.0)
		for k in 3:
			var s3 := r.streaks[k]
			s3.visible = ln > 0.1
			if s3.visible:
				s3.material_override = mat(B if r.slip else WHITE)
				s3.scale = Vector3(ln * (1.0 - k * 0.2), 0.07, 0.07)
				s3.position = Vector3(r.p.x - r.face * (HW + 0.3 + ln * 0.5 + k * 0.2), r.p.y + 0.25 + k * 0.35, 0.5)
		for k in r.pips.size():
			var q := r.pips[k]
			q.visible = k < r.wins
			q.position = Vector3(r.p.x - 0.15 + k * 0.3, r.p.y + HH + 0.55, 0)
	marker.visible = pl.alive
	marker.position = Vector3(pl.p.x, pl.p.y + HH + 1.1 + sin(tm * 5.0) * 0.12, 0)
	# 흐르는 바닥 눈금 (뒤로 흐른다)
	for fl in flows:
		var w: float = fl.w
		var x0: float = fl.x0
		var marks: Array = fl.marks
		if absf(x0 - camx) > hwv + w + 4.0:
			continue
		for m in marks.size():
			var mk: Node3D = marks[m]
			mk.position.x = x0 + 0.4 + fposmod(w * m / 3.0 - tm * FLOW, w - 0.8)
	var dt := get_process_delta_time()
	# 파편
	for b in bits:
		if b.life > 0.0:
			b.life -= dt
			var bv: Vector3 = b.v
			bv.y -= GRAV * 0.7 * dt
			b.v = bv
			var m: MeshInstance3D = b.node
			m.position += bv * dt
			m.rotation.z += dt * 9.0
			m.visible = b.life > 0.0
	# 구름 (천천히 흘러가며 원근으로 느리게 지나간다)
	var span := hwv * (CAM_D + 22.0) / CAM_D * 2.0 + 16.0
	for c in clouds:
		c.x -= dt * 0.7
		var m2: MeshInstance3D = c.node
		m2.position = Vector3(camx + fposmod(c.x - camx * 0.35, span) - span * 0.5, camy + c.y, -22.0)
	# 선두가 빠르면 화면을 가로지르는 바람 줄 (선두 속도만큼 빨리)
	var ld := _leader()
	var ls := absf(ld.v.x) if ld and phase == "race" else 0.0
	wind_x += dt * ls * 2.2
	var wk := (CAM_D - 4.0) / CAM_D
	for k in winds.size():
		var w: MeshInstance3D = winds[k]
		w.visible = ls > 7.5
		if w.visible:
			var ww := hwv * wk * 2.0 + 6.0
			w.position = Vector3(camx + hwv * wk + 3.0 - fposmod(wind_x + k * 7.3, ww), camy + vhv * wk * (0.75 - k * 0.33), 4.0)
			w.scale = Vector3(1.0 + (ls - 7.5) * 0.6, 0.06, 0.06)
	_vis()
	var k2 := (CAM_D - 1.6) / CAM_D
	# 정전: 1등 바로 앞부터 화면 오른쪽 끝까지 가린다
	var lead := _leader()
	curtain.visible = dark_on and phase == "race" and lead != null
	if curtain.visible:
		var l := camx + (lead.p.x + 1.2 - camx) * k2
		var rgt := camx + (hwv + 1.0) * k2
		if rgt > l:
			curtain.position = Vector3((l + rgt) * 0.5, camy, 1.6)
			curtain.scale = Vector3(rgt - l, vhv * 2.2, 0.2)
		else:
			curtain.visible = false
	# 왼쪽 화면 끝 경고 띠
	var ed := pl.p.x - (camx - hwv)
	edge_strip.visible = phase == "race" and pl.alive and ed < 4.0 and (ed > 2.0 or fmod(tm, 0.16) < 0.1)
	edge_strip.position = Vector3(camx - hwv * k2 + 0.18, camy, 1.6)
	edge_strip.scale = Vector3(0.35 + maxf(0.0, 4.0 - ed) * 0.1, vhv * 2.0, 0.2)
