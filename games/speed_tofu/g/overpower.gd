extends Tofu
## 너무 센 몸 v5 (옆모습 스테이지 퍼즐): 왼쪽 아래 조이스틱으로 좌우(끝까지 밀면 질주), 오른쪽 버튼으로 점프. 한 화면짜리 방 12개를 하나씩 깬다. 문에 닿으면 다음 방, 죽으면 그 방 처음.
## v5: 방 12개를 퍼즐 전담이 PUZZLE_DESIGN.md 절차로 다시 짰다. 방마다 깨달음 하나(주석), 자연스러운 첫 오답이 보이는 이유로 막히고, 앞 방의 지식이 다음 방에서 방해가 되는 비틀기(2-2, 3-2, 4-2). 몸 규칙·형식은 v4 그대로.
## 핵심 규칙: 속도 = 몸의 모양. 빠르면 길고 납작(1칸 틈 통과, 2칸 구덩이 위를 걸쳐 건넘), 서면 가늘고 높다(1칸 굴뚝·구멍), 달리며 천장에 쾅 하면 질주보다 빨라져 금 간 벽을 깬다.
## 묶음 4개(납작 / 걸침 / 가늘기 / 쾅) × 방 3개. 묶음 첫 방은 새 지식 하나와 흐린 몸 그림자, 나머지 두 방은 앞의 지식과 섞는다. 제한시간 없음.
## 방은 순수 데이터(ROOMS: name, rows, ents). 편집기는 load_room_data(d)로 방 하나를 짓고 바로 플레이한다.
# 한 문장: 나는 너무 센 몸으로서 속도가 곧 몸의 모양이 되는 제약 속에서 한 방씩 속도를 골라 몸을 틈·구덩이·굴뚝에 맞춰 문에 닿지만, 빨라지면 멈추지 못하고 느려지면 낮은 틈에 끼이고 구덩이에 빠지는 대가를 감수한다.

const GRAV := 45.0
const JUMP_V := 24.0
const SPRINT := 26.0  # 스틱을 0.7 넘게 밀면 이 속도 (몸이 납작해지는 달리기)
const JOG := 14.0
const STICK_RUN := 0.7
const GROUND_ACC := 90.0
const AIR_ACC := 30.0
const FRICTION := 35.0
const MAX_FALL := 30.0
const BONK_CAP := 34.0
const SLAM_V := 12.0
const CRACK_V := 29.0  # 금 간 벽이 부서지는 옆속도: 질주(26)로는 모자라고 천장 쾅(34)이면 된다
const VMAX := 30.0
const W0 := 0.9  # 서 있을 때 몸: 0.9 x 1.8
const W1 := 2.7  # 최고속 몸: 2.7 x 0.72
const H0 := 1.8
const H1 := 0.72
const EPS := 0.0001
const SAVE_V4 := "user://overpower_v5.json"

# ---- 방 데이터 형식 (편집기와 같이 쓴다) ----
# 격자 크기는 고정: GRID_W 칸 x GRID_H 줄. rows[0]이 맨 위 줄, 글자 하나 = 칸 하나.
# ents의 x는 왼쪽부터 칸 번호(0~GRID_W-1), y는 위부터 줄 번호(0~GRID_H-1). 몸·문은 그 칸 바닥에 선다.
const GRID_W := 22
const GRID_H := 12
const TILES := {
	".": "빈 칸",
	"#": "벽 (밟고 박는다)",
	"^": "가시 (닿으면 죽음, 밟을 수 없다)",
	"X": "금 간 벽 (옆속도 29 이상으로 박으면 부서진다, 그 밖엔 벽)",
}
const ENT_KINDS := {
	"start": "시작 자리 (하나)",
	"door": "끝 문 (하나, 2칸 높이)",
	"hint": "흐린 몸 그림자 (shape: flat/long/thin/fast, dx: 옆 어긋남)",
}
const HINT_SIZE := {"flat": Vector2(2.36, 0.86), "long": Vector2(2.36, 0.86), "thin": Vector2(0.9, 1.8), "fast": Vector2(2.7, 0.72)}
# 묶음: 이름, 새 지식, 팔레트 (밝게)
const BUNDLES := [
	{"name": "납작", "learn": "빠르면 납작!", "wall": Color("d9c39a"), "trim": Color("8fcf6b"), "back": Color("eef8e4"), "sky": Color("d8eeff"), "crack": Color("c9a66b")},
	{"name": "걸침", "learn": "길면 걸친다!", "wall": Color("e6bd8f"), "trim": Color("f08c5a"), "back": Color("fff1e2"), "sky": Color("fdebd8"), "crack": Color("d29a62")},
	{"name": "가늘기", "learn": "멈추면 가늘다!", "wall": Color("cdbdf0"), "trim": Color("9775fa"), "back": Color("f3efff"), "sky": Color("e7e1fb"), "crack": Color("a996d6")},
	{"name": "쾅", "learn": "쾅 하면 더 빠르다!", "wall": Color("b9db92"), "trim": Color("20c997"), "back": Color("e9fbf1"), "sky": Color("dff6ea"), "crack": Color("d9a441")},
]
const PER_BUNDLE := 3
const ROOMS := [
	# 1-1 깨달음: 문 반대쪽 빈 공간은 낭비가 아니라 몸을 납작하게 만들 도움닫기다. 바로 앞 틈은 2칸으론 못 들어간다.
	{"name": "멀어져서 들어가기", "rows": [
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"#.......#######......#",
		"#.......#######......#",
		"#.......#######......#",
		"#.......#######......#",
		"#.......#######......#",
		"#....................#",
		"######################",
	], "ents": [{"k": "start", "x": 7, "y": 10}, {"k": "hint", "x": 11, "y": 10, "shape": "flat", "dx": 0.0}, {"k": "door", "x": 19, "y": 10}]},
	# 1-2 깨달음: 틈을 지나 도착한 방이 다음 도움닫기다. 문에 가까워지려면 두 번 멀어진다(아래로 오른쪽, 위로 왼쪽).
	{"name": "돌아오는 길", "rows": [
		"######################",
		"#........####........#",
		"#........####........#",
		"#........####........#",
		"#....................#",
		"###################..#",
		"#........####........#",
		"#........####........#",
		"#........####........#",
		"#........####.......##",
		"#...................##",
		"######################",
	], "ents": [{"k": "start", "x": 1, "y": 10}, {"k": "door", "x": 2, "y": 4}]},
	# 1-3 깨달음: 틈과 틈 사이의 높은 빈칸은 쉬는 곳이 아니다. 한 번 만든 납작함은 버리지 않고 이어 쓴다(2칸에선 멈출 수 없다).
	# 시작은 틈A 바로 앞(6열): 그냥 오른쪽으로 밀면 2칸으론 납작해지지 못해 벽에 "꽝"(1-1처럼 물러나야 한다). 물러난 뒤 질주는 끊지 않고 두 틈을 한 번에.
	{"name": "두 틈 한 질주", "rows": [
		"######################",
		"###########..#########",
		"###########..#########",
		"###########..#########",
		"###########..#########",
		"#.......###..####....#",
		"#.......###..####....#",
		"#.......###..####....#",
		"#.......###..####....#",
		"#.......###..####....#",
		"#....................#",
		"######################",
	], "ents": [{"k": "start", "x": 6, "y": 10}, {"k": "door", "x": 19, "y": 10}]},
	# 2-1 깨달음: 긴 몸은 2칸 구덩이에 빠지지 않는다. 뛸 천장이 없으니 걸어서는 빠지고 달려서만 건넌다.
	# 몸은 9행에 서고(발 높이 2) 바닥은 10행. 10~11열은 바닥이 뚫린 2칸 구덩이, 그 밑(11행)이 가시. 7행 가시 천장: 서면 머리(3.8)가 가시 판정(4.15)에 안 닿고, 뛰면 바로 닿는다.
	{"name": "구덩이 위", "rows": [
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"#^^^^^^^^^^^^^^^^^^^^#",
		"#....................#",
		"#....................#",
		"##########..##########",
		"##########^^##########",
	], "ents": [{"k": "start", "x": 1, "y": 9}, {"k": "hint", "x": 10, "y": 9, "shape": "long", "dx": 0.5}, {"k": "door", "x": 19, "y": 9}]},
	# 2-2 깨달음: 틈에서 열쇠였던 긴 몸이 구덩이 앞에선 방해다. 지나쳤으면 돌아와 느려진 몸으로 빠진다.
	{"name": "지나친 구덩이", "rows": [
		"######################",
		"######################",
		"#.......#####........#",
		"#.......#####........#",
		"#.......#####........#",
		"#.......#####........#",
		"#....................#",
		"###############..#####",
		"#############........#",
		"#############........#",
		"#############........#",
		"######################",
	], "ents": [{"k": "start", "x": 1, "y": 6}, {"k": "door", "x": 19, "y": 10}]},
	# 2-3 깨달음: 똑같은 2칸 구덩이 둘. 앞은 걸쳐야 하고 뒤는 빠져야 한다. 사이 3칸이 속도를 버리는 자리다.
	{"name": "두 구덩이", "rows": [
		"######################",
		"######################",
		"#.......###..........#",
		"#.......###..........#",
		"#.......###..........#",
		"#.......###..........#",
		"#....................#",
		"###########..###..####",
		"###########^^#.......#",
		"##############.......#",
		"##############.......#",
		"######################",
	], "ents": [{"k": "start", "x": 1, "y": 6}, {"k": "door", "x": 19, "y": 10}]},
	# 3-1 깨달음: 멈춘 몸만 1칸 굴뚝에 들어간다. 공중에서도 스틱을 밀면 넓어져 끼이니, 뛰고 나서 손을 뗀다.
	{"name": "굴뚝", "rows": [
		"######################",
		"######################",
		"#....................#",
		"#....................#",
		"#....................#",
		"#....................#",
		"##########.###########",
		"##########.###########",
		"##########.###########",
		"#....................#",
		"#....................#",
		"######################",
	], "ents": [{"k": "start", "x": 1, "y": 10}, {"k": "hint", "x": 10, "y": 8, "shape": "thin", "dx": 0.0}, {"k": "door", "x": 17, "y": 5}]},
	# 3-2 깨달음: 2칸 구덩이는 느려지면 빠졌지만 1칸 구멍은 달리는 몸이 걸쳐 지나간다. 완전히 멈춰 서야 빠진다.
	{"name": "지나친 구멍", "rows": [
		"######################",
		"######################",
		"#.......#####........#",
		"#.......#####........#",
		"#.......#####........#",
		"#.......#####........#",
		"#....................#",
		"################.#####",
		"################.#####",
		"#############........#",
		"#############........#",
		"######################",
	], "ents": [{"k": "start", "x": 1, "y": 6}, {"k": "door", "x": 19, "y": 10}]},
	# 3-3 깨달음: 문은 위에 보이지만 길은 아래로 간다. 구멍(멈춤)→틈(물러나 질주)→굴뚝(멈춤), 벽이 대신 멈춰 주는 자리를 쓴다.
	{"name": "내려가서 올라가기", "rows": [
		"######################",
		"###############......#",
		"#.......#######......#",
		"#.......#######......#",
		"#######.##########.###",
		"#######.##########.###",
		"#..........####......#",
		"#....................#",
		"######################",
		"######################",
		"######################",
		"######################",
	], "ents": [{"k": "start", "x": 1, "y": 3}, {"k": "door", "x": 19, "y": 3}]},
	# 4-1 깨달음: 질주(26)로는 금 간 벽이 안 깨진다. 낮은 천장에 달리며 쾅 하면 34가 되어 깨진다.
	{"name": "금 간 벽", "rows": [
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"######################",
		"#.............X......#",
		"#.............X......#",
		"######################",
	], "ents": [{"k": "start", "x": 1, "y": 10}, {"k": "hint", "x": 11, "y": 10, "shape": "fast", "dx": 0.0}, {"k": "door", "x": 19, "y": 10}]},
	# 4-2 깨달음: 쾅에는 천장이 필요하다. 벽 앞 높은 방에선 뛰어도 쾅이 없으니, 낮은 천장이 있는 뒤쪽까지 물러나 거기서 뛴다.
	{"name": "쾅할 천장", "rows": [
		"######################",
		"######################",
		"##########.......X...#",
		"##########.......X...#",
		"##########.......X...#",
		"##########.......X...#",
		"##########.......X...#",
		"##########.......X...#",
		"##########.......X...#",
		"#................X...#",
		"#................X...#",
		"######################",
	], "ents": [{"k": "start", "x": 13, "y": 10}, {"k": "door", "x": 19, "y": 10}]},
	# 4-3 깨달음(종합): 내려온 상태로는 벽을 못 연다. 납작(틈)→가늘기(구멍)→질주 거리 만들기→쾅→금 간 벽, 어디서 어떤 몸을 만들지 순서를 고른다.
	{"name": "내려와서 다시 만들기", "rows": [
		"######################",
		"#........####........#",
		"#........####........#",
		"#........####........#",
		"#....................#",
		"###############.######",
		"###############.######",
		"###############.######",
		"###############.######",
		"#.........X..........#",
		"#.........X..........#",
		"######################",
	], "ents": [{"k": "start", "x": 1, "y": 4}, {"k": "door", "x": 2, "y": 10}]},
]


class _Hud extends Control:
	var k

	func _draw() -> void:
		k._hud_draw(self)


var lv := 0  # 지금 방 번호 (-1 = 편집기에서 받은 방)
var cur: Dictionary = {}
var stage: Node3D
var grid: Array[String] = []
var start_pt := Vector2.ZERO
var door := Rect2()
var cracks := {}  # "c:yy" -> [상자, 금 표시]
var cleared := {}  # 깬 방 번호 -> true (기기에 저장)
var learned := [false, false, false, false]
var picking := false  # 방 고르기 판이 떠 있음
var view := Rect2()
var cam_base := Vector3.ZERO
var fov0 := 50.0
var px := 0.0  # 발 가운데
var py := 0.0
var vx := 0.0
var vy := 0.0
var bw := W0
var bh := H0
var flat := false
var on_floor := false
var coyote := 0.0
var jbuf := 0.0
var cut := true
var stun := 0.0
var hang := 0.0
var face := 1.0
var die_t := 0.0
var clear_t := 0.0
var shake := 0.0
var squash := 0.0
var stretch := 0.0
var step_t := 0.0
var dust_t := 0.0
var anim := 0.0
var trail_t := 0.0
var trail_k := 0
var wind_t := 0.0
var wind_k := 0
var env: Environment
var hud: _Hud
var me: Node3D
var body: MeshInstance3D
var eyes: Array[MeshInstance3D] = []
var stars: Array[MeshInstance3D] = []
var trail: Array[MeshInstance3D] = []
var bits: Array[MeshInstance3D] = []
var bit_v: Array[Vector3] = []
var bit_l: Array[float] = []
var bit_k := 0
var winds: Array[MeshInstance3D] = []
var ghost: MeshInstance3D
var door_in: MeshInstance3D


func _setup() -> void:
	time_limit = 0.0
	howto = "조이스틱으로 좌우, 끝까지 밀면 질주. 오른쪽 버튼은 점프.\n빠르면 몸이 길고 납작해지고(낮은 틈, 구덩이 위), 서면 가늘고 높다(1칸 굴뚝). 방마다 이 몸으로 문까지 가는 풀이가 하나 있다.\n가시·구덩이, 틈 안에서 느려져 끼이면 죽고 그 방 처음부터. 막히면 '다시', 방 고르기는 '방'."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1100), 105.0, A)
	kit_button("retry", "다시", Vector2(420, 1060), 50.0, B)
	kit_button("rooms", "방", Vector2(420, 1200), 50.0, C)
	for ch in get_children():
		if ch is WorldEnvironment:
			env = ch.environment
	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)
	hud = _Hud.new()
	hud.k = self
	hud.size = Vector2(720, 1280)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
	_load_cleared()


func _reset() -> void:
	stage = null
	picking = false
	hud.visible = true
	_score()
	var first := 0
	for i in ROOMS.size():
		if not cleared.has(i):
			first = i
			break
	_start_room(first)


func _score() -> void:
	score = cleared.size() * 10


func _room_label() -> String:
	if lv < 0:
		return "내 방"
	return "%d-%d %s" % [lv / PER_BUNDLE + 1, lv % PER_BUNDLE + 1, ROOMS[lv].name]


func _bundle() -> Dictionary:
	if lv < 0:
		return BUNDLES[clampi(int(cur.get("pal", 0)), 0, BUNDLES.size() - 1)]
	return BUNDLES[mini(lv / PER_BUNDLE, BUNDLES.size() - 1)]


func _start_room(i: int) -> void:
	_play_room(ROOMS[i], i)
	msg(_room_label(), 1.3)


## 방 데이터 하나를 짓고 바로 플레이한다 (편집기용 입구). 팔레트는 d.pal(0~3, 없으면 0), 깬 기록에는 안 남는다.
func load_room_data(d: Dictionary) -> void:
	_play_room(d, -1)
	msg(String(d.get("name", "내 방")), 1.3)


func _play_room(d: Dictionary, i: int) -> void:
	lv = i
	cur = d
	picking = false
	_build()
	_place_start()


# ---- 방 짓기 ----
func _build() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	var pal := _bundle()
	if env:
		env.background_color = pal.sky
	grid.clear()
	var src: Array = cur.get("rows", [])
	for k in GRID_H:
		var s := String(src[k]) if k < src.size() else ""
		grid.append(s.replace(" ", ".").rpad(GRID_W, "#").substr(0, GRID_W))
	cracks.clear()
	start_pt = Vector2(1.5, 1.0)
	door = Rect2(-99, -99, 1, 2)
	var hint := {}
	for e in cur.get("ents", []):
		var ex := int(e.get("x", 0))
		var ey := GRID_H - 1 - int(e.get("y", 0))
		match String(e.get("k", "")):
			"start":
				start_pt = Vector2(ex + 0.5, ey)
			"door":
				door = Rect2(ex, ey, 1.0, 2.0)
			"hint":
				hint = e
	# 열린 칸을 다 담는 화면 (벽 한 칸씩 여유)
	var mn := Vector2(INF, INF)
	var mxv := Vector2(-INF, -INF)
	for yy in GRID_H:
		for c in GRID_W:
			if _ch(c, yy) != "#":
				mn = mn.min(Vector2(c, yy))
				mxv = mxv.max(Vector2(c + 1, yy + 1))
	if mn.x == INF:
		mn = Vector2.ZERO
		mxv = Vector2(GRID_W, GRID_H)
	view = Rect2(mn - Vector2.ONE, mxv - mn + Vector2.ONE * 2.0)
	# 카메라: 방 전체를 화면 위쪽 구역(y 330~1000)에 고정으로 담는다. 폭 기준 시야(KEEP_WIDTH).
	var ppu := minf(680.0 / view.size.x, 660.0 / view.size.y)
	var dist := 720.0 / (ppu * 2.0 * tan(deg_to_rad(fov0) * 0.5))
	var ctr := view.get_center()
	cam_base = Vector3(ctr.x, ctr.y + 25.0 / ppu, dist + 1.0)
	# 뒤판과 기둥 (속도 기준물), 바깥 먼 실루엣
	box(Vector3(ctr.x, ctr.y, -1.4), Vector3(view.size.x, view.size.y, 0.2), pal.back, stage)
	var c0 := int(view.position.x) + 2
	while c0 < view.end.x - 1:
		box(Vector3(c0, ctr.y, -1.2), Vector3(0.28, view.size.y, 0.1), pal.back.darkened(0.07), stage)
		c0 += 4
	var rng := RandomNumberGenerator.new()
	rng.seed = (lv + 7) * 977
	for k in 6:
		var w := rng.randf_range(3.0, 7.0)
		var hh := rng.randf_range(8.0, 20.0)
		box(Vector3(ctr.x + rng.randf_range(-28.0, 28.0), view.position.y - 6.0 + hh * 0.5, -30.0), Vector3(w, hh, 1.0), pal.trim.lerp(WHITE, 0.6), stage)
	# 벽 (줄마다 이어 붙임), 윗면 띠, 아랫면 띠, 가시, 금 간 벽
	for yy in GRID_H:
		var run0 := -1
		var top0 := -1
		var bot0 := -1
		for c in GRID_W + 1:
			var ch := _ch(c, yy) if c < GRID_W else "."
			var topped := ch == "#" and yy + 1 < GRID_H and not _solid(c, yy + 1)
			if topped and top0 < 0:
				top0 = c
			elif not topped and top0 >= 0:
				box(Vector3((top0 + c) * 0.5, yy + 0.93, 0.0), Vector3(c - top0, 0.16, 2.08), pal.trim, stage)
				top0 = -1
			var under := ch == "#" and yy > 0 and not _solid(c, yy - 1)
			if under and bot0 < 0:
				bot0 = c
			elif not under and bot0 >= 0:
				box(Vector3((bot0 + c) * 0.5, yy + 0.05, 0.0), Vector3(c - bot0, 0.1, 2.06), pal.wall.darkened(0.14), stage)
				bot0 = -1
			if ch == "#":
				if run0 < 0:
					run0 = c
				continue
			if run0 >= 0:
				box(Vector3((run0 + c) * 0.5, yy + 0.5, 0.0), Vector3(c - run0, 1.0, 2.0), pal.wall, stage)
				run0 = -1
			if ch == "^":
				var sp := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.55, 0.55, 1.2), BAD, stage)
				sp.rotation.z = PI * 0.25
			elif ch == "X":
				var cb := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(1.0, 1.0, 1.9), pal.crack, stage)
				var mk := box(Vector3(c + 0.5, yy + 0.5, 0.97), Vector3(0.1, 0.8, 0.06), INK, stage)
				mk.rotation.z = 0.5 if (c + yy) % 2 == 0 else -0.5
				cracks["%d:%d" % [c, yy]] = [cb, mk]
	# 바닥 눈금 (앞면, 속도감 단서)
	for yy in range(0, GRID_H - 1):
		for c in GRID_W:
			if c % 2 == 0 and _solid(c, yy) and not _solid(c, yy + 1):
				box(Vector3(c + 0.5, yy + 0.75, 1.06), Vector3(0.14, 0.3, 0.06), pal.wall.darkened(0.1), stage)
	# 문: 틀 + 초록 문 + 손잡이
	var fr: Color = pal.trim.darkened(0.25)
	box(Vector3(door.position.x + 0.06, door.position.y + 1.0, -0.5), Vector3(0.16, 2.1, 0.6), fr, stage)
	box(Vector3(door.position.x + 0.94, door.position.y + 1.0, -0.5), Vector3(0.16, 2.1, 0.6), fr, stage)
	box(Vector3(door.position.x + 0.5, door.position.y + 2.05, -0.5), Vector3(1.2, 0.18, 0.6), fr, stage)
	door_in = box(Vector3(door.position.x + 0.5, door.position.y + 1.0, -0.7), Vector3(0.8, 1.9, 0.3), GOOD, stage)
	box(Vector3(door.position.x + 0.75, door.position.y + 1.0, -0.5), Vector3(0.14, 0.14, 0.2), D, stage)
	# 흐린 몸 그림자 (그 자리에 필요한 몸 모양)
	ghost = null
	if not hint.is_empty():
		var sz: Vector2 = HINT_SIZE.get(String(hint.get("shape", "flat")), HINT_SIZE.flat)
		var gx := int(hint.get("x", 0)) + 0.5 + float(hint.get("dx", 0.0))
		var gy := GRID_H - 1 - int(hint.get("y", 0)) + sz.y * 0.5
		ghost = box(Vector3(gx, gy, -0.8), Vector3(sz.x, sz.y, 0.2), ME.lerp(WHITE, 0.72), stage)
	# 나
	me = Node3D.new()
	stage.add_child(me)
	body = box(Vector3(0, H0 * 0.5, 0), Vector3(W0, H0, 0.7), ME, me)
	eyes.clear()
	for k in 2:
		eyes.append(box(Vector3.ZERO, Vector3(0.14, 0.16, 0.05), WHITE, me))
	stars.clear()
	for k in 2:
		var s := box(Vector3.ZERO, Vector3(0.2, 0.2, 0.2), D, me)
		s.visible = false
		stars.append(s)
	trail.clear()
	for k in 6:
		var tb := box(Vector3.ZERO, Vector3(W0, H0, 0.4), B, stage)
		tb.visible = false
		trail.append(tb)
	# 파편 (착지·충돌·깸 순간, 돌려 쓴다)
	bits.clear()
	bit_v.clear()
	bit_l.clear()
	var bcol := [pal.trim, WHITE, D, pal.wall.darkened(0.2)]
	for k in 18:
		var b := box(Vector3.ZERO, Vector3(0.22, 0.22, 0.22), bcol[k % bcol.size()], stage)
		b.visible = false
		bits.append(b)
		bit_v.append(Vector3.ZERO)
		bit_l.append(0.0)
	winds.clear()
	for k in 7:
		var wb := box(Vector3.ZERO, Vector3(1.6, 0.07, 0.07), WHITE, stage)
		wb.visible = false
		winds.append(wb)


func _place_start() -> void:
	px = start_pt.x
	py = start_pt.y
	vx = 0.0
	vy = 0.0
	bw = W0
	bh = H0
	flat = false
	on_floor = true
	coyote = 0.0
	jbuf = 0.0
	cut = true
	stun = 0.0
	hang = 0.0
	die_t = 0.0
	clear_t = 0.0
	squash = 0.0
	stretch = 0.0
	face = 1.0
	cam.position = cam_base
	cam.fov = fov0


# ---- 칸 (yy는 아래부터) ----
func _ch(c: int, yy: int) -> String:
	if c < 0 or c >= GRID_W or yy >= GRID_H:
		return "#"
	if yy < 0:
		return "."
	return grid[GRID_H - 1 - yy][c]


func _solid(c: int, yy: int) -> bool:
	var ch := _ch(c, yy)
	return ch == "#" or ch == "X"


func _x0() -> int:
	return floori(px - bw * 0.5 + EPS)


func _x1() -> int:
	return floori(px + bw * 0.5 - EPS)


func _y0() -> int:
	return floori(py + EPS)


func _y1() -> int:
	return floori(py + bh - EPS)


func _ground() -> bool:
	var yy := floori(py - 0.02)
	for c in range(_x0(), _x1() + 1):
		if _solid(c, yy):
			return true
	return false


func _col_solid(c: int, y0: int, y1: int) -> bool:
	for yy in range(y0, y1 + 1):
		if _solid(c, yy):
			return true
	return false


## 몸 높이의 막힌 칸이 전부 금 간 벽인가
func _col_crack(c: int, y0: int, y1: int) -> bool:
	var any := false
	for yy in range(y0, y1 + 1):
		var ch := _ch(c, yy)
		if ch == "#":
			return false
		if ch == "X":
			any = true
	return any


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	anim += dt
	gauge(float(cleared.size()) / ROOMS.size(), GOOD)
	hud.queue_redraw()
	if kit_just("rooms") and clear_t <= 0.0:
		picking = not picking
		beep(700.0 if picking else 500.0, 0.06, 0.0, 0.15)
	if picking:
		return
	if kit_just("retry") and die_t <= 0.0 and clear_t <= 0.0:
		beep(400.0, 0.08, 250.0, 0.2)
		_build()
		_place_start()
		msg("다시", 0.5)
		return
	if die_t > 0.0:
		die_t -= dt
		_view(dt)
		if die_t <= 0.0:
			_build()
			_place_start()
		return
	if clear_t > 0.0:
		clear_t -= dt
		_view(dt)
		if clear_t <= 0.0:
			_next_room()
		return
	_control(h)
	_shape(h)
	if die_t > 0.0:
		_view(dt)
		return
	_physics(h)
	_check()
	_sounds(h)
	_view(dt)


func _next_room() -> void:
	if lv < 0:
		_build()
		_place_start()
		return
	if lv + 1 < ROOMS.size():
		_start_room(lv + 1)
		return
	for i in ROOMS.size():
		if not cleared.has(i):
			_start_room(i)
			return
	hud.visible = false
	play("win")
	end()


func _control(h: float) -> void:
	var mx := kit_move.x
	if absf(mx) < 0.12:
		mx = 0.0
	if kit_just("jump"):
		jbuf = 0.12
	jbuf -= h
	coyote -= h
	stun -= h
	squash = maxf(0.0, squash - h * 4.0)
	stretch = maxf(0.0, stretch - h * 5.0)
	if mx != 0.0 and stun <= 0.0:
		face = signf(mx)
	if stun <= 0.0:
		var target := 0.0
		if mx != 0.0:
			target = signf(mx) * (SPRINT if absf(mx) >= STICK_RUN else JOG * absf(mx) / STICK_RUN)
		var too_fast := mx != 0.0 and signf(vx) == signf(target) and absf(vx) > absf(target)
		if on_floor:
			if mx == 0.0:
				vx = move_toward(vx, 0.0, FRICTION * h)
			elif too_fast:
				vx = move_toward(vx, target, FRICTION * h)
			else:
				vx = move_toward(vx, target, GROUND_ACC * h)
		elif mx != 0.0 and not too_fast:
			vx = move_toward(vx, target, AIR_ACC * h)
		# 미끄럼 먼지: 빠른데 브레이크·반대로 미는 중
		if on_floor and absf(vx) > 10.0 and (mx == 0.0 or signf(mx) != signf(vx)):
			dust_t -= h
			if dust_t <= 0.0:
				dust_t = 0.05
				_burst(Vector3(px - signf(vx) * bw * 0.4, py + 0.1, 0.7), 1, 0.4)
	elif on_floor:
		vx = move_toward(vx, 0.0, FRICTION * h)
	_snap(h)
	if jbuf > 0.0 and stun <= 0.0 and (on_floor or coyote > 0.0):
		_jump()
	if not cut and vy > 0.0 and not kit_held("jump"):
		vy *= 0.93
		cut = true


## 거의 서 있을 때 1칸 굴뚝(머리 위)·1칸 구멍(발밑) 가까이면 가운데로 붙인다 (터치로 1칸 맞추기 어려움)
func _snap(h: float) -> void:
	if not on_floor or absf(vx) > 2.5 or stun > 0.0:
		return
	var top := floori(py + bh + 0.05)
	var fy := floori(py - 0.02)
	for k in [floori(px) - 1, floori(px), floori(px) + 1]:
		var dx: float = k + 0.5 - px
		if absf(dx) > 0.8:
			continue
		var up: bool = not _solid(k, top) and _solid(k - 1, top) and _solid(k + 1, top)
		var down: bool = not _solid(k, fy) and _ch(k, fy) != "^" and _solid(k - 1, fy) and _solid(k + 1, fy)
		if (up or down) and not _col_solid(k, _y0(), _y1()):
			px += clampf(dx, -3.0 * h, 3.0 * h)
			return


func _jump() -> void:
	vy = JUMP_V
	on_floor = false
	coyote = 0.0
	jbuf = 0.0
	cut = false
	stretch = 0.6
	beep(420.0, 0.1, 1000.0, 0.24)


## 속도 = 몸의 모양. 빠를수록 옆으로 길고 납작. 새 모양이 벽에 겹치면 옆은 밀려나고 머리가 박히면 끼인다.
func _shape(h: float) -> void:
	var s := clampf(absf(vx) / VMAX, 0.0, 1.0)
	var tw := lerpf(W0, W1, pow(s, 1.5))
	var th := lerpf(H0, H1, s)
	var k := 1.0 - exp(-30.0 * h)
	bw = lerpf(bw, tw, k)
	bh = lerpf(bh, th, k)
	var now := bh < 1.0
	if now != flat:
		flat = now
		if flat:
			beep(500.0, 0.1, 1100.0, 0.22)
		else:
			beep(1100.0, 0.1, 500.0, 0.18)
	var y0 := _y0()
	var y1 := _y1()
	if _col_solid(_x0(), y0, y1):
		px = _x0() + 1.0 + bw * 0.5 + 0.001
		if _col_solid(_x1(), y0, y1):
			_die("끼임")
			return
	elif _col_solid(_x1(), y0, y1):
		px = _x1() - bw * 0.5 - 0.001
		if _col_solid(_x0(), y0, y1):
			_die("끼임")
			return
	for c in range(_x0(), _x1() + 1):
		if _solid(c, y1):
			_die("끼임")
			return


func _physics(h: float) -> void:
	var fall := vy
	if hang > 0.0:
		hang -= h
		vy = 0.0
	else:
		vy = maxf(vy - GRAV * h, -MAX_FALL)
	for i in 4:
		_move_x(vx * h * 0.25)
		_move_y(vy * h * 0.25)
	var was := on_floor
	on_floor = vy <= 0.0 and _ground()
	if on_floor:
		coyote = 0.08
		if not was:
			squash = maxf(squash, clampf(-fall / 40.0, 0.2, 0.7))
			beep(90.0, 0.06, 0.0, 0.2)
			if fall < -8.0:
				var n := clampi(int(-fall / 5.0), 2, 6)
				_burst(Vector3(px - bw * 0.4, py + 0.05, 0.7), n / 2, 0.8)
				_burst(Vector3(px + bw * 0.4, py + 0.05, 0.7), n - n / 2, 0.8)
				shake = maxf(shake, -fall / 150.0)


func _move_x(d: float) -> void:
	if d == 0.0:
		return
	px += d
	var c := _x1() if d > 0.0 else _x0()
	if not _col_solid(c, _y0(), _y1()):
		return
	if absf(vx) >= CRACK_V and _col_crack(c, _y0(), _y1()):
		_crack(c)
		return
	px = c - bw * 0.5 - 0.001 if d > 0.0 else c + 1.0 + bw * 0.5 + 0.001
	_wall_hit(signf(d), _col_crack(c, _y0(), _y1()))


func _move_y(d: float) -> void:
	if d == 0.0:
		return
	py += d
	var r := _y1() if d > 0.0 else floori(py)
	var hit := false
	for c in range(_x0(), _x1() + 1):
		if _solid(c, r):
			hit = true
			break
	if not hit:
		return
	if d > 0.0:
		py = r - bh - 0.001
		_bonk()
	else:
		py = r + 1.0
		vy = 0.0


func _bonk() -> void:
	var sp := vy
	vy = 0.0
	if sp < 3.0:
		return
	hang = 0.08
	stun = 0.18
	shake = maxf(shake, 0.3)
	squash = 0.7
	stretch = 0.0
	if absf(vx) > 8.0:
		vx = signf(vx) * maxf(absf(vx), minf(absf(vx) * 1.35 + 4.0, BONK_CAP))
	_burst(Vector3(px, py + bh, 0.7), 3, -1.0)
	msg("쾅!", 0.35)
	beep(200.0, 0.14, 60.0, 0.45)
	beep(1300.0, 0.05, 700.0, 0.2)


func _wall_hit(dir: float, crack: bool) -> void:
	var sp := absf(vx)
	if sp > SLAM_V:
		stun = 0.3
		shake = maxf(shake, 0.3 + sp / 120.0)
		squash = 0.6
		vx = -dir * sp * 0.25
		_burst(Vector3(px + dir * bw * 0.5, py + bh * 0.5, 0.7), 5, 0.0)
		msg("더 빨리!" if crack else "꽝!", 0.6 if crack else 0.35)
		beep(110.0, 0.2, 45.0, 0.45)
		beep(800.0, 0.04, 0.0, 0.2)
	else:
		vx = 0.0


## 금 간 벽 c 줄을 통째로 부순다
func _crack(c: int) -> void:
	for yy in GRID_H:
		if _ch(c, yy) == "X":
			var r := GRID_H - 1 - yy
			grid[r] = grid[r].substr(0, c) + "." + grid[r].substr(c + 1)
			var key := "%d:%d" % [c, yy]
			if cracks.has(key):
				for m in cracks[key]:
					(m as MeshInstance3D).visible = false
			_burst(Vector3(c + 0.5, yy + 0.5, 0.7), 3, 1.0)
	vx *= 0.92
	shake = maxf(shake, 0.6)
	msg("와장창!", 0.6)
	beep(160.0, 0.25, 40.0, 0.5)
	beep(1500.0, 0.08, 400.0, 0.25)
	_learn(3)


func _check() -> void:
	if die_t > 0.0:
		return
	var r := Rect2(px - bw * 0.5, py, bw, bh)
	if py < -2.0:
		_die("떨어짐")
		return
	for c in range(floori(r.position.x), floori(r.end.x) + 1):
		for yy in range(floori(py), floori(py + bh) + 1):
			if _ch(c, yy) == "^" and Rect2(c + 0.15, yy + 0.15, 0.7, 0.7).intersects(r):
				_die("가시")
				return
	var cc := floori(px)
	# 지식 ①: 납작해서 낮은 틈·가시 천장 아래를 지나는 중
	var above := _ch(cc, _y0() + 1)
	if bh < 1.0 and (above == "#" or above == "^") and not _solid(cc, _y0()):
		_learn(0)
	# 지식 ②: 긴 몸이 구덩이 위에 걸쳐 서 있다
	var fy := floori(py - 0.02)
	if on_floor and not _solid(cc, fy) and _solid(_x0(), fy) and _solid(_x1(), fy) and absf(vx) > 15.0:
		_learn(1)
	# 지식 ③: 가는 몸이 1칸 굴뚝·구멍 속에 있다
	var my := floori(py + bh * 0.5)
	if not on_floor and absf(vx) < 3.0 and not _solid(cc, my) and _solid(cc - 1, my) and _solid(cc + 1, my):
		_learn(2)
	if door.intersects(r):
		clear_t = 1.1
		vx = 0.0
		vy = 0.0
		if lv >= 0:
			cleared[lv] = true
			_save_cleared()
		_score()
		door_in.material_override = mat(WHITE)
		_burst(Vector3(door.position.x + 0.5, door.position.y + 1.5, 0.7), 12, 1.0)
		play("win")
		beep(660.0, 0.08, 0.0, 0.2)
		beep(990.0, 0.12, 1320.0, 0.2)
		msg("%s 깸!" % _room_label().split(" ")[0], 1.1)


func _learn(k: int) -> void:
	if learned[k]:
		return
	learned[k] = true
	msg(BUNDLES[k].learn, 1.4)
	beep(880.0, 0.12, 1320.0, 0.25)
	beep(1320.0, 0.18, 1760.0, 0.18)


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 0.9
	body.material_override = mat(BAD)
	shake = maxf(shake, 0.4)
	_burst(Vector3(px, py + bh * 0.5, 0.7), 8, 1.0)
	play("bad")
	msg(why, 0.9)


func _sounds(h: float) -> void:
	step_t -= h
	if on_floor and absf(vx) > 3.0 and step_t <= 0.0:
		step_t = clampf(2.2 / absf(vx), 0.05, 0.3)
		beep(120.0 + absf(vx) * 8.0, 0.03, 0.0, 0.1)


## 작은 상자 파편 n개 (up: 1 위로, -1 아래로, 0 옆으로)
func _burst(at: Vector3, n: int, up: float) -> void:
	for i in n:
		var b := bits[bit_k]
		bit_v[bit_k] = Vector3(randf_range(-5.0, 5.0), randf_range(2.0, 8.0) * (up if up != 0.0 else 0.6), randf_range(-1.0, 3.0))
		bit_l[bit_k] = randf_range(0.35, 0.65)
		b.position = at
		b.scale = Vector3.ONE * randf_range(0.16, 0.3)
		b.visible = true
		bit_k = (bit_k + 1) % bits.size()


func _view(dt: float) -> void:
	me.position = Vector3(px, py, 0.0)
	me.scale = Vector3(1.0 + squash * 0.3 - stretch * 0.25, 1.0 - squash * 0.3 + stretch * 0.35, 1.0)
	body.scale = Vector3(bw, bh, 0.7)
	body.position.y = bh * 0.5
	for k in eyes.size():
		eyes[k].position = Vector3(face * (bw * 0.5 - 0.16 - k * 0.24), bh * 0.66, 0.36)
		eyes[k].scale = Vector3(0.14, clampf(bh * 0.2, 0.05, 0.18), 0.05)
	for k in stars.size():
		stars[k].visible = stun > 0.0 and die_t <= 0.0
		var a := anim * 14.0 + k * PI
		stars[k].position = Vector3(cos(a) * 0.45, bh + 0.3, sin(a) * 0.45)
	if ghost:
		var p := 1.0 + sin(anim * 4.0) * 0.05
		ghost.scale.z = 0.2 * p
		ghost.position.z = -0.8 + sin(anim * 4.0) * 0.05
	door_in.scale.x = 0.8 + sin(anim * 3.0) * 0.04
	for i in bits.size():
		if bit_l[i] > 0.0:
			bit_l[i] -= dt
			bit_v[i].y -= 30.0 * dt
			bits[i].position += bit_v[i] * dt
			bits[i].rotation.z += dt * 9.0
			if bit_l[i] <= 0.0:
				bits[i].visible = false
	# 빠를 때 남는 잔상 (늘어난 몸 모양 그대로)
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.03
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = Vector2(vx, vy).length() > 14.0 and die_t <= 0.0
		tb.position = Vector3(px, py + bh * 0.5, -0.3)
		tb.scale = Vector3(bw, bh, 0.4)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	# 바람 줄: 빠를수록 많이
	wind_t -= dt
	if wind_t <= 0.0 and absf(vx) > 16.0 and die_t <= 0.0:
		wind_t = 0.045
		var wb := winds[wind_k]
		wind_k = (wind_k + 1) % winds.size()
		wb.visible = true
		wb.position = Vector3(px + signf(vx) * randf_range(0.5, 3.5), py + randf_range(0.1, 1.6), 0.9)
		wb.scale = Vector3(1.0 + absf(vx) * 0.06, 0.07, 0.07)
	for wb in winds:
		if wb.visible:
			wb.scale.x -= dt * 7.0
			if wb.scale.x <= 0.05:
				wb.visible = false
	# 카메라: 방 전체 고정. 흔들림과 속도만큼 살짝 넓어지는 시야.
	shake = maxf(0.0, shake - dt * 1.5)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.6
	cam.position = cam_base + Vector3(off.x, off.y, 0.0)
	cam.rotation = Vector3.ZERO
	var k := 1.0 - exp(-6.0 * dt)
	cam.fov = lerpf(cam.fov, fov0 + minf(Vector2(vx, vy).length(), 34.0) * 0.08, k)


# ---- 진행 표시·방 고르기 ----
func _tile(i: int) -> Rect2:
	return Rect2(230 + (i % PER_BUNDLE) * 155, 290 + (i / PER_BUNDLE) * 84, 140, 72)


func _open(i: int) -> bool:
	return i == 0 or cleared.has(i) or cleared.has(i - 1)


func _tap(p: Vector2) -> void:
	if not picking:
		return
	for i in ROOMS.size():
		if _tile(i).has_point(p):
			if _open(i):
				play("tap")
				_start_room(i)
			else:
				beep(150.0, 0.08, 0.0, 0.2)
			return
	picking = false


func _hud_draw(c: Control) -> void:
	if over:
		return
	c.draw_string(_font, Vector2(24, 272), _room_label(), HORIZONTAL_ALIGNMENT_LEFT, 400, 32, INK)
	for i in ROOMS.size():
		var g := i / PER_BUNDLE
		var rr := Rect2(436 + i * 20 + g * 8, 250, 16, 22)
		var col: Color = BUNDLES[mini(g, BUNDLES.size() - 1)].trim
		if i == lv:
			c.draw_rect(rr, ME.lerp(WHITE, 0.2 + 0.2 * sin(anim * 6.0)))
		elif cleared.has(i):
			c.draw_rect(rr, col)
		else:
			c.draw_rect(rr, Color(1, 1, 1, 0.8))
		c.draw_rect(rr, INK, false, 2.0)
	if not picking:
		return
	c.draw_rect(Rect2(16, 230, 688, 420), Color(1, 1, 1, 0.95))
	c.draw_rect(Rect2(16, 230, 688, 420), INK, false, 4.0)
	c.draw_string(_font, Vector2(40, 272), "방 고르기  (깬 방 %d/%d)" % [cleared.size(), ROOMS.size()], HORIZONTAL_ALIGNMENT_LEFT, 640, 32, INK)
	for g in ceili(float(ROOMS.size()) / PER_BUNDLE):
		var b: Dictionary = BUNDLES[mini(g, BUNDLES.size() - 1)]
		c.draw_string(_font, Vector2(40, 290 + g * 84 + 48), "%d %s" % [g + 1, b.name], HORIZONTAL_ALIGNMENT_LEFT, 180, 32, INK)
	for i in ROOMS.size():
		var rr := _tile(i)
		var b: Dictionary = BUNDLES[mini(i / PER_BUNDLE, BUNDLES.size() - 1)]
		var col: Color = b.trim if cleared.has(i) else (b.back if _open(i) else Color("dddddd"))
		c.draw_rect(rr, col)
		c.draw_rect(rr, ME if i == lv else INK, false, 5.0 if i == lv else 3.0)
		var s := "%d-%d" % [i / PER_BUNDLE + 1, i % PER_BUNDLE + 1]
		if cleared.has(i):
			s += " ✓"
		elif not _open(i):
			s = "잠김"
		c.draw_string(_font, rr.position + Vector2(0, 48), s, HORIZONTAL_ALIGNMENT_CENTER, rr.size.x, 30, INK)


# ---- 깬 방 기록 ----
func _load_cleared() -> void:
	cleared = {}
	if not FileAccess.file_exists(SAVE_V4):
		return
	var f := FileAccess.open(SAVE_V4, FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		for v in d.get("cleared", []):
			cleared[int(v)] = true


func _save_cleared() -> void:
	var f := FileAccess.open(SAVE_V4, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"cleared": cleared.keys()}))
