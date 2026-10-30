extends Tofu
## 저울 감옥 v2 (옆모습): 왼쪽 아래 스틱 = 걷기·흔들기, 오른쪽 "잡기"를 누르는 동안 손잡이를 잡는다(떼면 놓는다).
## 손잡이 끈의 반대편 끝엔 감방(무게)이 매달려 있다. 잡으면 빗장이 풀려 감방이 떨어지고 나는 끌려 올라간다. 오래 잡을수록 빨라진다.
## 속도는 몸으로 읽는다: 빨라질수록 몸이 늘어나고 빨개지며 팔이 빠지려 늘어나고, 끈이 팽팽히 떨리고, 바람 줄무늬가 지나가고, 떨어지는 감방과 그 착지대가 같은 화면에 보인다.
## 끝까지 잡으면 감방이 착지대에 쾅 → 팔이 빠져 그 속도로 날아간다. 알맞은 때 놓아 턱에 손을 걸친다. 세게 부딪히면 으깨진다.
## 구역 1 수직 감방(놓는 높이), 2 엇갈린 감방(그네 + 떨어지는 감방 문), 3 빈 저울(죄수를 업어 내 무게를 바꾼다, "놓기"),
## 4 눕는 탑(비스듬한 끈: 짧아질수록 그네가 저절로 빨라진다, 올라가는 흔들림에서 놓기), 5 출구의 저울(지금까지 떨군 감방이 쌓인 추가 발사 속도를 정한다, 죄수 업기로 맞춘다).
# 한 문장: 나는 저울 감옥의 죄수 추로서 끈 반대편 감방이 떨어지는 힘으로만 움직이는 제약 속에서 손잡이를 잡고 놓아 출구까지 오르지만, 오래 잡을수록 빨라져 팔이 빠지거나 벽에 으깨지는 대가를 감수한다.

const G := 30.0
const TEAR := 14.0  # 끈이 멈출 때 이 속도보다 빠르면 팔이 빠진다
const CRUSH := 17.0  # 이 속도로 벽·천장에 박으면 으깨진다
const FALL := 22.0  # 이 속도로 바닥에 떨어지면 죽는다 (약 8칸 높이)
const GRAB_R := 1.3
const PUMP := 11.0  # 스틱으로 흔드는 힘
const AIR := 9.0
const WALK := 5.5
const ARM := 0.7  # 몸 가운데에서 손까지
const BW := 0.8
const BH := 1.4
const HAND_M := 0.15  # 아무도 안 잡은 손잡이 무게
const WINCH := 4.0  # 다 떨어진 감방을 다시 끌어올리는 속도
const LC0 := 1.0
const CW := 1.3
const EPS := 0.0001
const SOLID := 35  # '#'
const SPIKE := 94  # '^'
const WALLC := Color("c9b48f")
const BEAMC := Color("8a6d4b")
const ZONES := ["수직 감방", "엇갈린 감방", "빈 저울", "눕는 탑", "출구의 저울"]
const ROOMS := [
	{"zone": 0, "name": "첫 저울", "n": 1},
	{"zone": 0, "name": "갈아잡기", "n": 2},
	{"zone": 1, "name": "그네", "n": 1},
	{"zone": 1, "name": "내려오는 감방", "n": 2},
	{"zone": 2, "name": "무거운 몸", "n": 1},
	{"zone": 2, "name": "빈 저울", "n": 2},
	{"zone": 3, "name": "기운 끈", "n": 1},
	{"zone": 3, "name": "지그재그", "n": 2},
	{"zone": 4, "name": "결산", "n": 1},
]
# 구역마다 색: 벽, 뒷벽, 뒷벽 무늬
const PAL := [
	[Color("c9b48f"), Color("efe1c4"), Color("e2cfa8")],
	[Color("9cc3b0"), Color("e2f2e8"), Color("c3e0d0")],
	[Color("c2aad6"), Color("f2e9f8"), Color("dccdea")],
	[Color("e6ad80"), Color("fdebd9"), Color("f3cfae")],
	[Color("93b4dc"), Color("e5effc"), Color("c2d6f0")],
]
const SKY := Color("a5d8ff")
const NSTREAK := 12
const NBIT := 14

var lv := 0
var stage: Node3D
var gw := 0
var gh := 0
var cells := PackedByteArray()
var start := Vector2.ZERO
var door := Rect2()
var ropes: Array = []
var pris: Array = []
var px := 0.0  # 몸 가운데
var py := 0.0
var vx := 0.0
var vy := 0.0
var on_floor := false
var ri := -1  # 잡은 끈
var carry := 0
var carry0 := 0
var drop_cd := 0.0
var die_t := 0.0
var clear_t := 0.0
var shake := 0.0
var anim := 0.0
var cam_x := 0.0
var cam_y := 0.0
var snd_t := 0.0
var trail_t := 0.0
var trail_k := 0
var me: Node3D
var body: MeshInstance3D
var eye: MeshInstance3D
var hand: MeshInstance3D
var loads: Array[MeshInstance3D] = []
var trail: Array[MeshInstance3D] = []
var arm: MeshInstance3D
var streaks: Array[MeshInstance3D] = []
var st_off: Array[Vector2] = []
var bits: Array[MeshInstance3D] = []
var bit_v: Array[Vector3] = []
var bit_life: Array[float] = []
var bit_k := 0
var clouds: Array = []  # [mesh, 창 Rect2, 속도]
var dropped := 0  # 지금까지 방을 깨며 떨어뜨린 감방 수 (5구역 결산 무게)
var squash := 0.0  # 착지 순간 납작해짐
var strain := 0.0  # 0~1 팔이 빠질 만큼 빠른 정도 (몸·끈·소리로 보여 준다)
var warn_t := 0.0
var zone := 0
var tilt := 0.0

func _setup() -> void:
	time_limit = 0.0
	cam.fov = 56.0
	howto = "스틱: 걷기·흔들기. '잡기'를 누르는 동안 손잡이를 잡는다(떼면 놓음).\n반대편 감방이 떨어지는 만큼 나는 끌려 올라간다. 오래 잡을수록 빨라져 몸이 늘어나고 빨개진다.\n감방이 빨간 착지대에 닿기 전에 놓아라. 늦으면 팔이 빠져 날아간다. 턱에 손이 닿으면 올라선다.\n가시·세게 부딪힘·높은 추락은 죽음. 3구역부터 죄수를 업으면 무거워진다('놓기')."
	kit_stick()
	kit_button("grab", "잡기", Vector2(600, 1100), 110.0, A)


func _reset() -> void:
	lv = 0
	dropped = 0
	stage = null
	_room(0)


# ---- 방 만들기 ----
func _grid(w: int, h: int) -> void:
	gw = w
	gh = h
	cells = PackedByteArray()
	cells.resize(w * h)
	cells.fill(32)
	_fill(0, 0, w - 1, 0, SOLID)
	_fill(0, h - 1, w - 1, h - 1, SOLID)
	_fill(0, 0, 0, h - 1, SOLID)
	_fill(w - 1, 0, w - 1, h - 1, SOLID)


func _fill(c0: int, y0: int, c1: int, y1: int, ch: int) -> void:
	for yy in range(y0, y1 + 1):
		for c in range(c0, c1 + 1):
			cells[yy * gw + c] = ch


## 도르래 칸(c, y), 시작 끈 길이 rs, 최소·최대 끈 길이, 감방 무게, 감방 줄의 가로 위치 dx, 감방 높이
## th0: 잠긴 손잡이가 걸려 있는 말뚝의 각도 (4·5구역의 비스듬한 끈)
func _rope(c: int, y: int, rs: float, rmin: float, rmax: float, m: float, dx: float, chh := 1.5, th0 := 0.0) -> void:
	var o := Vector2(c + 0.5, y + 0.5)
	var rp := {"o": o, "r": rs, "rs": rs, "rmin": rmin, "rmax": rmax, "M": m, "dx": dx, "chh": chh,
		"rd": 0.0, "th": th0, "th0": th0, "thd": 0.0, "cv": 0.0, "lock": true, "spent": false, "cd": 0.0, "used": false}
	box(Vector3(o.x + dx * 0.5, o.y + 0.05, -0.4), Vector3(absf(dx), 0.22, 0.3), BEAMC, stage)
	rp.pul = box(Vector3(o.x, o.y, 0.0), Vector3(0.75, 0.75, 0.5), D, stage)
	rp.pul2 = box(Vector3(o.x + dx, o.y, -0.4), Vector3(0.65, 0.65, 0.4), D, stage)
	rp.line = box(Vector3.ZERO, Vector3(0.07, 1.0, 0.07), INK, stage)
	rp.cline = box(Vector3.ZERO, Vector3(0.07, 1.0, 0.07), INK, stage)
	rp.handle = box(Vector3.ZERO, Vector3(0.6, 0.18, 0.3), A, stage)
	rp.cell = box(Vector3.ZERO, Vector3(CW, chh, 1.0), C, stage)
	rp.win = box(Vector3.ZERO, Vector3(0.7, 0.32, 0.05), WHITE, stage)
	rp.bars = box(Vector3.ZERO, Vector3(0.08, 0.32, 0.06), INK, stage)
	rp.bolt = box(Vector3(o.x + dx, o.y - 0.55, -0.1), Vector3(0.5, 0.2, 0.5), BAD, stage)
	# 착지대: 감방이 여기 닿으면 끈이 멈춘다 (그 전에 놓아야 한다)
	var low := o.y - LC0 - (rmax - rmin) - chh
	box(Vector3(o.x + dx, low - 0.12, -0.4), Vector3(CW + 0.5, 0.22, 1.1), BAD, stage)
	for s: float in [-0.45, 0.0, 0.45]:
		box(Vector3(o.x + dx + s, low - 0.12, 0.17), Vector3(0.18, 0.24, 0.05), D, stage)
	if th0 != 0.0:
		var pg := o + Vector2(sin(th0), -cos(th0)) * rs
		box(Vector3(pg.x, pg.y + 0.2, -0.5), Vector3(0.25, 0.6, 0.3), BEAMC, stage)
	rp.stack = []
	# 감방이 빠르게 떨어질 때 위로 남는 줄무늬
	rp.cs = [box(Vector3.ZERO, Vector3(0.06, 1.0, 0.06), WHITE, stage), box(Vector3.ZERO, Vector3(0.06, 1.0, 0.06), WHITE, stage)]
	ropes.append(rp)


func _pris(x: float, feet: float) -> void:
	var q := {"p": Vector2(x, feet + 0.5), "vy": 0.0, "taken": false, "fresh": false}
	q.mesh = box(Vector3(x, feet + 0.5, 0.2), Vector3(0.6, 1.0, 0.5), D, stage)
	pris.append(q)


func _door(c: int, y: int) -> void:
	door = Rect2(c, y, 1.0, 2.0)
	box(Vector3(c + 0.5, y + 1.0, -0.6), Vector3(1.1, 2.0, 0.6), GOOD, stage)


func _build(i: int) -> void:
	match i:
		0:  # 첫 저울: 놓는 높이 하나 (턱과 천장 가시 사이를 넓게 두어 놓는 창이 넓다)
			_grid(14, 22)
			_fill(8, 1, 12, 11, SOLID)
			_fill(1, 19, 12, 19, SPIKE)
			_rope(6, 18, 15.3, 1.5, 15.3, 2.0, -3.5)
			start = Vector2(6.5, 1.0)
			_door(11, 12)
		1:  # 갈아잡기: 끌려 올라가다 놓고 위의 손잡이로
			_grid(16, 30)
			_fill(1, 16, 5, 24, SOLID)
			_fill(2, 15, 5, 15, SPIKE)
			_fill(6, 28, 14, 28, SPIKE)
			_rope(5, 13, 10.3, 1.5, 10.3, 2.5, -3.0)
			_rope(7, 26, 13.0, 1.5, 13.0, 2.5, 4.0)
			start = Vector2(5.5, 1.0)
			_door(2, 25)
		2:  # 그네: 가시 구덩이 위를 흔들어 건넌다
			_grid(23, 14)
			_fill(1, 1, 4, 4, SOLID)
			_fill(17, 1, 21, 4, SOLID)
			_fill(5, 1, 16, 1, SPIKE)
			_rope(5, 12, 5.7, 3.0, 5.7, 1.6, -3.0)
			_rope(11, 12, 6.5, 5.0, 6.5, 1.6, 3.0)
			start = Vector2(3.0, 5.0)
			_door(20, 5)
		3:  # 내려오는 감방: 잡은 끈의 감방이 앞길을 가로질러 떨어진다 (일찍 밑으로 / 늦게 위로)
			_grid(29, 14)
			_fill(1, 1, 4, 4, SOLID)
			_fill(23, 1, 27, 4, SOLID)
			_fill(5, 1, 22, 1, SPIKE)
			_rope(5, 12, 5.7, 3.0, 5.7, 1.6, -3.0)
			_rope(11, 12, 6.5, 2.0, 6.5, 1.6, 4.5, 4.0)
			_rope(17, 12, 6.5, 2.0, 6.5, 1.6, 2.0)
			start = Vector2(3.0, 5.0)
			_door(26, 5)
		4:  # 무거운 몸: 죄수 둘을 업고 시작. 둘이면 감방과 무게가 같아 꼼짝 않고, 다 내려놓으면 너무 빨라 팔이 빠진다
			_grid(14, 20)
			_fill(8, 1, 12, 13, SOLID)
			_fill(1, 17, 12, 17, SPIKE)
			_rope(6, 15, 12.3, 1.5, 12.3, 2.0, -3.5)
			start = Vector2(5.0, 1.0)
			carry0 = 2
			_door(10, 14)
		5:  # 빈 저울: 감방이 나보다 무겁다(1.4). 죄수를 업어야 내려가고, 많이 업으면 바닥에서 팔이 빠진다. 올라오는 감방과 엇갈린다
			_grid(16, 22)
			_fill(1, 1, 5, 15, SOLID)
			_fill(9, 1, 14, 2, SOLID)
			_fill(6, 1, 8, 1, SPIKE)
			_rope(6, 19, 2.0, 2.0, 14.5, 1.4, 3.0)
			start = Vector2(4.2, 16.0)
			_pris(1.5, 16.0)
			_pris(2.3, 16.0)
			_pris(3.1, 16.0)
			_door(13, 3)
		6:  # 기운 끈: 말뚝에 걸린 비스듬한 손잡이. 잡으면 감방이 끌어당기며 그네가 저절로 빨라진다. 오른쪽으로 솟는 흔들림에서 놓는다
			_grid(24, 16)
			_fill(1, 1, 4, 4, SOLID)
			_fill(19, 1, 22, 8, SOLID)
			_fill(5, 1, 18, 1, SPIKE)
			_rope(13, 13, 10.5, 3.5, 10.5, 1.6, -3.0, 1.5, -0.84)
			start = Vector2(3.0, 5.0)
			_door(21, 9)
		7:  # 지그재그: 비스듬한 끈 A로 오른쪽 선반, 끈 B로 왼쪽까지 흔들렸다가 짧아진 끈이 되돌려 올리는 흔들림에서 오른쪽 위 출구로
			_grid(26, 26)
			_fill(1, 1, 3, 3, SOLID)
			_fill(4, 1, 24, 1, SPIKE)
			_fill(20, 5, 24, 5, SOLID)
			_fill(16, 17, 24, 17, SOLID)
			_rope(13, 13, 11.9, 4.0, 11.9, 1.5, -3.0, 1.5, -0.833)
			_rope(10, 22, 17.4, 5.5, 17.4, 1.5, -4.0, 1.5, 0.53)
			start = Vector2(2.5, 4.0)
			_door(23, 18)
		8:  # 출구의 저울: 반대편 감방에 지금까지 떨군 감방이 쌓여 있다. 무거우면 세게 쏜다 → 죄수를 업어 맞춘다
			_grid(26, 20)
			_fill(1, 1, 4, 3, SOLID)
			_fill(5, 1, 17, 1, SPIKE)
			_fill(18, 1, 24, 8, SOLID)
			_fill(22, 9, 24, 18, SOLID)
			var mm := clampf(1.5 + 0.12 * dropped, 1.6, 3.2)
			_rope(12, 16, 12.9, 3.5, 12.9, mm, -3.5, 2.2, -0.55)
			var rp: Dictionary = ropes[0]
			for k in mini(dropped, 10):
				rp.stack.append(box(Vector3.ZERO, Vector3(0.55, 0.4, 0.5), C if k % 2 == 0 else B, stage))
			start = Vector2(4.3, 4.0)
			_pris(1.6, 4.0)
			_pris(2.4, 4.0)
			_pris(3.2, 4.0)
			_door(19, 9)


func _room(i: int) -> void:
	if stage:
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	ropes.clear()
	pris.clear()
	clouds.clear()
	carry0 = 0
	zone = ROOMS[i].zone
	_build(i)
	var pal: Array = PAL[zone]
	var wallc: Color = pal[0]
	# 벽: 줄마다 이어진 칸을 상자 하나로
	for yy in gh:
		var run0 := -1
		for c in gw + 1:
			var ch := cells[yy * gw + c] if c < gw else 32
			if ch == SOLID:
				if run0 < 0:
					run0 = c
				continue
			if run0 >= 0:
				box(Vector3((run0 + c) * 0.5, yy + 0.5, 0.0), Vector3(c - run0, 1.0, 2.0), wallc, stage)
				run0 = -1
			if ch == SPIKE:
				var sp := box(Vector3(c + 0.5, yy + 0.5, 0.0), Vector3(0.55, 0.55, 1.2), BAD, stage)
				sp.rotation.z = PI * 0.25
	# 뒷벽과 눈금 (위아래·옆 속도를 읽는 기준)
	box(Vector3(gw * 0.5, gh * 0.5, -1.4), Vector3(gw, gh, 0.2), pal[1], stage)
	_deco(pal)
	for yy in range(1, gh - 1, 2):
		for c in range(1, gw - 1):
			if _solid(c, yy):
				continue
			if _solid(c - 1, yy):
				box(Vector3(c + 0.04, yy + 0.5, 0.9), Vector3(0.1, 0.35, 0.2), WHITE, stage)
			if _solid(c + 1, yy):
				box(Vector3(c + 0.96, yy + 0.5, 0.9), Vector3(0.1, 0.35, 0.2), WHITE, stage)
	# 죄수가 있는 구역(3·5)에서만 "놓기" 버튼이 생긴다
	if zone == 2 or zone == 4:
		if not _btns.has("drop"):
			kit_button("drop", "놓기", Vector2(600, 880), 80.0, C)
	else:
		_btns.erase("drop")
	# 나
	me = Node3D.new()
	stage.add_child(me)
	body = box(Vector3.ZERO, Vector3(BW, BH, 0.6), ME, me)
	eye = box(Vector3(0.2, 0.35, 0.31), Vector3(0.16, 0.16, 0.05), WHITE, me)
	hand = box(Vector3(0, ARM, 0), Vector3(0.3, 0.3, 0.4), ME, me)
	arm = box(Vector3(0, ARM, 0), Vector3(0.14, 0.1, 0.2), ME, me)
	loads.clear()
	for k in 3:
		var l := box(Vector3(0, -BH * 0.5 - 0.45 - k * 0.9, 0.1), Vector3(0.55, 0.85, 0.45), D, me)
		l.visible = false
		loads.append(l)
	trail.clear()
	for k in 6:
		var tb := box(Vector3.ZERO, Vector3(BW, BH, 0.3), B, stage)
		tb.visible = false
		trail.append(tb)
	# 바람 줄무늬와 파편 (방마다 한 번 만들어 돌려 쓴다)
	streaks.clear()
	st_off.clear()
	for k in NSTREAK:
		var s := box(Vector3.ZERO, Vector3(0.06, 1.0, 0.06), WHITE, stage)
		s.visible = false
		streaks.append(s)
		st_off.append(Vector2(randf_range(-4.0, 4.0), randf_range(-6.0, 6.0)))
	bits.clear()
	bit_v.clear()
	bit_life.clear()
	for k in NBIT:
		var b := box(Vector3.ZERO, Vector3(0.22, 0.22, 0.22), wallc, stage)
		b.visible = false
		bits.append(b)
		bit_v.append(Vector3.ZERO)
		bit_life.append(0.0)
	squash = 0.0
	strain = 0.0
	tilt = -0.07 if zone == 3 else 0.0
	px = start.x
	py = start.y + BH * 0.5 + 0.002
	vx = 0.0
	vy = 0.0
	on_floor = true
	ri = -1
	carry = carry0
	drop_cd = 0.0
	die_t = 0.0
	clear_t = 0.0
	cam_x = px
	cam_y = py + 2.0
	var title := "%s %d-%d\n%s" % [ZONES[zone], zone + 1, ROOMS[i].n, ROOMS[i].name]
	if zone == 4:
		title += "\n떨군 감방 %d개 = 추 무게" % dropped
	msg(title, 1.8)


## 뒷벽 무늬: 벽돌 줄, 창살 창(구름이 지나감), 4구역은 기운 기둥
func _deco(pal: Array) -> void:
	var dc: Color = pal[2]
	for yy in range(2, gh - 1, 3):
		box(Vector3(gw * 0.5, yy + 0.0, -1.28), Vector3(gw - 2.0, 0.08, 0.05), dc, stage)
	var nwin := clampi(gw / 7, 1, 4)
	for k in nwin:
		var wx := (k + 0.5) * gw / float(nwin)
		var wy := gh * (0.45 + 0.25 * float(k % 2))
		if _solid(floori(wx), floori(wy)):
			continue
		var wr := Rect2(wx - 1.1, wy - 0.9, 2.2, 1.8)
		box(Vector3(wx, wy, -1.27), Vector3(2.2, 1.8, 0.04), SKY, stage)
		var cl := box(Vector3(wx, wy, -1.24), Vector3(0.9, 0.35, 0.03), WHITE, stage)
		clouds.append([cl, wr, randf_range(0.3, 0.7)])
		for b in 3:
			box(Vector3(wx - 0.6 + b * 0.6, wy, -1.2), Vector3(0.1, 1.8, 0.05), dc.darkened(0.25), stage)
	if zone == 3:
		for k in 3:
			var pl := box(Vector3(3.0 + k * gw / 3.0, gh * 0.5, -1.3), Vector3(0.6, gh * 0.9, 0.05), dc, stage)
			pl.rotation.z = 0.22
	if zone == 4:
		# 거대 저울 대들보
		box(Vector3(gw * 0.5, gh - 1.6, -1.1), Vector3(gw * 0.7, 0.35, 0.2), BEAMC, stage)
		box(Vector3(gw * 0.5, gh - 1.0, -1.1), Vector3(0.5, 1.2, 0.2), BEAMC, stage)


## 파편 n개를 pos에서 튀긴다
func _burst(pos: Vector2, n: int, sp: float, col: Color) -> void:
	for k in n:
		var bi := bit_k
		bit_k = (bit_k + 1) % bits.size()
		var b := bits[bi]
		b.visible = true
		b.material_override = mat(col)
		b.position = Vector3(pos.x, pos.y, 0.6)
		b.scale = Vector3.ONE * 0.22
		bit_v[bi] = Vector3(randf_range(-1.0, 1.0) * sp, randf_range(0.3, 1.0) * sp, 0.0)
		bit_life[bi] = 0.6


# ---- 칸 ----
func _ch(c: int, yy: int) -> int:
	if c < 0 or c >= gw or yy >= gh:
		return SOLID
	if yy < 0:
		return 32
	return cells[yy * gw + c]


func _solid(c: int, yy: int) -> bool:
	return _ch(c, yy) == SOLID


## 몸 가운데가 (x, y)일 때 벽에 겹치나
func _hits(x: float, y: float) -> bool:
	for c in range(floori(x - BW * 0.5 + EPS), floori(x + BW * 0.5 - EPS) + 1):
		for yy in range(floori(y - BH * 0.5 + EPS), floori(y + BH * 0.5 - EPS) + 1):
			if _solid(c, yy):
				return true
	return false


func _mass() -> float:
	return 1.0 + 0.5 * carry


func _handle(rp: Dictionary) -> Vector2:
	var o: Vector2 = rp.o
	var th: float = rp.th
	var r: float = rp.r
	return o + Vector2(sin(th), -cos(th)) * r


func _cell_rect(rp: Dictionary) -> Rect2:
	var o: Vector2 = rp.o
	var rmax: float = rp.rmax
	var r: float = rp.r
	var dx: float = rp.dx
	var chh: float = rp.chh
	var top := o.y - LC0 - (rmax - r)
	return Rect2(o.x + dx - CW * 0.5, top - chh, CW, chh)


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	anim += dt
	if die_t > 0.0:
		die_t -= dt
		_view(dt)
		if die_t <= 0.0:
			_room(lv)
		return
	if clear_t > 0.0:
		clear_t -= dt
		_view(dt)
		if clear_t <= 0.0:
			lv += 1
			if lv >= ROOMS.size():
				msg("탈옥!", 2.0)
				end()
			else:
				_room(lv)
		return
	_control(h)
	_ropes(h)
	if ri >= 0:
		_held(h)
	else:
		_free(h)
	if die_t <= 0.0:
		_cells_vs_me()
	if die_t <= 0.0:
		_prisoners(h)
		_check()
	_sounds(h)
	# 속도는 막대가 아니라 몸·끈·소리로 보인다. 위 막대는 진행만
	strain = clampf(absf(float(ropes[ri].rd)) / TEAR, 0.0, 1.2) if ri >= 0 else 0.0
	gauge(float(lv) / ROOMS.size(), B)
	_view(dt)


func _control(h: float) -> void:
	drop_cd -= h
	var want := kit_held("grab")
	if ri >= 0 and not want:
		_release(0.35)
		beep(700.0, 0.05, 400.0, 0.18)
	elif ri < 0 and want:
		_try_grab()
	if kit_just("drop") and carry > 0:
		carry -= 1
		drop_cd = 0.9
		_pris(px, py - BH * 0.5)
		pris[pris.size() - 1].vy = minf(vy, 0.0)
		pris[pris.size() - 1].fresh = true  # 내 몸에서 한 번 떨어지기 전엔 다시 안 업힌다
		beep(330.0, 0.1, 500.0, 0.25)
		msg("가벼워짐", 0.5)


func _try_grab() -> void:
	var hands := Vector2(px, py + ARM)
	var best := -1
	var bd := GRAB_R
	for k in ropes.size():
		if float(ropes[k].cd) > 0.0:
			continue
		var d := hands.distance_to(_handle(ropes[k]))
		if d < bd:
			bd = d
			best = k
	if best < 0:
		return
	var rp: Dictionary = ropes[best]
	var o: Vector2 = rp.o
	var dd := hands - o
	var r := clampf(dd.length(), float(rp.rmin), float(rp.rmax))
	var th := atan2(dd.x, -dd.y)
	var dir := Vector2(sin(th), -cos(th))
	var hp := o + dir * r
	if _hits(hp.x, hp.y - ARM):
		return
	var tn := Vector2(cos(th), sin(th))
	var v := Vector2(vx, vy)
	var m := _mass()
	var bm: float = float(rp.M) + HAND_M
	rp.used = true
	if bool(rp.lock):
		rp.rd = 0.0
		rp.lock = false
		msg("철컥", 0.4)
		beep(180.0, 0.12, 90.0, 0.35)
	rp.rd = (m * v.dot(dir) + bm * float(rp.rd)) / (m + bm)
	rp.thd = v.dot(tn) / r
	rp.r = r
	rp.th = th
	rp.spent = false
	ri = best
	on_floor = false
	var bmm: float = rp.M
	if float(rp.rs) >= float(rp.rmax) and m >= bmm:
		msg("너무 무겁다", 0.6)
	elif float(rp.rs) <= float(rp.rmin) and m <= bmm:
		msg("너무 가볍다", 0.6)
	px = hp.x
	py = hp.y - ARM
	beep(600.0, 0.06, 0.0, 0.22)


func _release(cd: float) -> void:
	if ri < 0:
		return
	ropes[ri].cd = cd
	ri = -1


## 아무도 안 잡은 끈: 감방이 떨어져 손잡이가 위로 올라가고, 다 떨어지면 기계가 천천히 다시 끌어올려 빗장을 건다
func _ropes(h: float) -> void:
	for k in ropes.size():
		var rp: Dictionary = ropes[k]
		rp.cd = maxf(0.0, float(rp.cd) - h)
		if k == ri:
			continue
		var r: float = rp.r
		var r_was := r
		var th: float = rp.th
		var th_to: float = rp.th0 if (bool(rp.lock) or bool(rp.spent)) else 0.0
		th = lerpf(th, th_to, 1.0 - exp(-4.0 * h))
		rp.th = th
		rp.thd = 0.0
		if bool(rp.lock):
			rp.r = rp.rs
			rp.rd = 0.0
			rp.cv = 0.0
			continue
		if bool(rp.spent):
			r = move_toward(r, float(rp.rs), WINCH * h)
			rp.r = r
			rp.rd = 0.0
			rp.cv = (r - r_was) / h
			if absf(r - float(rp.rs)) < 0.001:
				rp.lock = true
				rp.spent = false
			continue
		var bm: float = rp.M
		var rd: float = rp.rd
		var tt := maxf(0.0, G * 2.0 * HAND_M * bm / (HAND_M + bm))
		rd += (tt / bm - G) * h
		r += rd * h
		if r < float(rp.rmin) or r > float(rp.rmax):
			r = clampf(r, float(rp.rmin), float(rp.rmax))
			if r <= float(rp.rmin) + 0.01 and absf(rd) > 3.0:
				var crl := _cell_rect(rp)
				_burst(Vector2(crl.get_center().x, crl.position.y), 4, 4.0, C)
			rd = 0.0
			rp.spent = true
			beep(110.0, 0.1, 60.0, 0.2)
		rp.r = r
		rp.rd = rd
		rp.cv = (r - r_was) / h


## 잡은 끈: 진자(흔들기) + 저울(반대편 감방이 떨어지면 끈이 짧아져 끌려 올라감)
func _held(h: float) -> void:
	var rp: Dictionary = ropes[ri]
	var o: Vector2 = rp.o
	var r: float = rp.r
	var th: float = rp.th
	var rd: float = rp.rd
	var thd: float = rp.thd
	var r_was := r
	var th_was := th
	var m := _mass()
	var bm: float = rp.M
	var tt := maxf(0.0, (G * (1.0 + cos(th)) + r * thd * thd) * m * bm / (m + bm))
	var rdd := tt / bm - G
	var mx := kit_move.x if absf(kit_move.x) > 0.12 else 0.0
	var thdd := (-G * sin(th) - 2.0 * rd * thd + mx * PUMP) / r
	rd += rdd * h
	thd += thdd * h
	thd *= 1.0 - 0.12 * h
	r += rd * h
	th += thd * h
	var hit := 0.0
	var rd_hit := rd
	if r < float(rp.rmin):
		r = rp.rmin
		hit = -rd
		rd = 0.0
	elif r > float(rp.rmax):
		r = rp.rmax
		hit = rd
		rd = 0.0
	var dir := Vector2(sin(th), -cos(th))
	var tn := Vector2(cos(th), sin(th))
	var vel := dir * rd + tn * (r * thd)
	var hp := o + dir * r
	if _hits(hp.x, hp.y - ARM):
		# 흔들리다 벽에 부딪힘: 빠르면 으깨지고, 느리면 튕긴다
		# 옆으로 박은 것이면 흔들림만 멈추고 끈은 계속 끌어올린다 (벽을 타고 미끄러져 오른다)
		var sp := absf(r * thd)
		var dir2 := Vector2(sin(th_was), -cos(th_was))
		var hp2 := o + dir2 * r
		if not _hits(hp2.x, hp2.y - ARM):
			th = th_was
			dir = dir2
			hp = hp2
			vel = dir * rd
			thd = 0.0  # 벽에 붙어 미끄러진다 (튕겨 나가지 않음)
		elif not _hits(o.x + sin(th) * r_was, o.y - cos(th) * r_was - ARM):
			# 바닥·턱에 발이 걸려 끈만 못 움직임: 흔들림은 살리고 끈 길이는 그대로
			r = r_was
			rd = 0.0
			hit = 0.0
			hp = o + dir * r
			vel = tn * (r * thd)
			sp = 0.0
		elif not _hits(o.x + sin(move_toward(th_was, 0.0, 0.05)) * maxf(r_was - 0.06, float(rp.rmin)),
				o.y - cos(move_toward(th_was, 0.0, 0.05)) * maxf(r_was - 0.06, float(rp.rmin)) - ARM):
			# 턱 위에 서서 잡음: 발을 떼며 끈 아래로 걸어 나간다
			th = move_toward(th_was, 0.0, 0.05)
			r = maxf(r_was - 0.06, float(rp.rmin))
			rd = 0.0
			thd = 0.0
			hit = 0.0
			dir = Vector2(sin(th), -cos(th))
			hp = o + dir * r
			vel = Vector2.ZERO
			sp = 0.0
		else:
			sp = vel.length()
			r = r_was
			th = th_was
			rd = 0.0
			hit = 0.0
			dir = dir2
			hp = o + dir * r
			vel = Vector2.ZERO
			thd = -0.3 * thd
		if sp > CRUSH:
			px = hp.x
			py = hp.y - ARM
			_die("으깨짐")
			return
		if sp > 5.0:
			shake = maxf(shake, 0.2)
			beep(140.0, 0.08, 70.0, 0.3)
	rp.r = r
	rp.th = th
	rp.rd = rd
	rp.thd = thd
	rp.cv = (r - r_was) / h
	px = hp.x
	py = hp.y - ARM
	vx = vel.x
	vy = vel.y
	if hit > 3.0 and r <= float(rp.rmin) + 0.01:
		var crh := _cell_rect(rp)
		_burst(Vector2(crh.get_center().x, crh.position.y), 6, 3.0 + hit * 0.3, C)
	if hit > 0.0:
		if hit > TEAR:
			# 감방이 바닥에 쾅: 팔이 빠져 그 속도 그대로 날아간다
			var fly := Vector2(sin(th), -cos(th)) * rd_hit + Vector2(cos(th), sin(th)) * (r * thd)
			vx = fly.x
			vy = fly.y
			_release(0.7)
			shake = maxf(shake, 0.5)
			msg("팔이 빠졌다!", 0.8)
			beep(900.0, 0.12, 200.0, 0.4)
			beep(100.0, 0.2, 50.0, 0.4)
		elif hit > 3.0:
			shake = maxf(shake, 0.12 + hit * 0.02)
			beep(120.0, 0.15, 60.0, 0.4)


func _free(h: float) -> void:
	var mx := kit_move.x if absf(kit_move.x) > 0.12 else 0.0
	if on_floor:
		vx = move_toward(vx, mx * WALK, 45.0 * h)
	else:
		vx += mx * AIR * h
	vy = maxf(vy - G * h, -40.0)
	for i in 4:
		_mx(vx * h * 0.25)
		_my(vy * h * 0.25)
		if die_t > 0.0:
			return
	on_floor = vy <= 0.0 and _hits(px, py - 0.04)
	if not on_floor and vy < 10.0:
		_mantle()


func _mx(d: float) -> void:
	if d == 0.0:
		return
	px += d
	if not _hits(px, py):
		return
	if d > 0.0:
		px = floori(px + BW * 0.5) - BW * 0.5 - 0.001
	else:
		px = floori(px - BW * 0.5) + 1.0 + BW * 0.5 + 0.001
	_impact(absf(vx), "으깨짐")
	vx = 0.0


func _my(d: float) -> void:
	if d == 0.0:
		return
	py += d
	if not _hits(px, py):
		return
	if d > 0.0:
		py = floori(py + BH * 0.5) - BH * 0.5 - 0.001
		_impact(absf(vy), "으깨짐")
	else:
		py = floori(py - BH * 0.5) + 1.0 + BH * 0.5 + 0.001
		_impact(absf(vy), "떨어짐")
	vy = 0.0


func _impact(sp: float, why: String) -> void:
	if sp > (FALL if why == "떨어짐" else CRUSH):
		_die(why)
	elif sp > 6.0:
		shake = maxf(shake, sp * 0.015)
		beep(90.0, 0.08, 50.0, 0.3)
		squash = clampf(sp / 20.0, 0.15, 0.5)
		var pal: Array = PAL[zone]
		_burst(Vector2(px, py - BH * 0.5 if why == "떨어짐" else py), 3, 2.0 + sp * 0.15, pal[0])
	elif sp > 2.5 and why == "떨어짐":
		squash = 0.12


## 날다가 턱 모서리 가까이 손이 오면 올라선다 (너무 빨리 솟구치는 중이면 지나쳐 버린다)
func _mantle() -> void:
	var hands := Vector2(px, py + ARM)
	for s: float in [1.0, -1.0]:
		var c := floori(hands.x + s * 1.05)
		var yy := floori(hands.y - 0.4)
		if not _solid(c, yy) and _solid(c, yy - 1) and hands.y - 1.0 < yy:
			yy -= 1  # 손이 턱보다 조금 위
		elif _solid(c, yy) and _solid(c, yy + 1) and hands.y + 1.0 >= yy + 2:
			yy += 1  # 손이 턱보다 조금 아래(1칸 안)여도 잡는다
		if _solid(c, yy) and not _solid(c, yy + 1) and not _solid(c, yy + 2):
			var nx := c + 0.5
			var ny := yy + 1.0 + BH * 0.5 + 0.002
			if _hits(nx, ny):
				continue
			px = nx
			py = ny
			vx = 0.0
			vy = 0.0
			on_floor = true
			beep(500.0, 0.08, 800.0, 0.25)
			msg("턱!", 0.4)
			return


## 움직이는 감방은 벽이다: 위에 서면 같이 움직이고, 밑에 깔리거나 세게 들이받으면 죽는다
func _cells_vs_me() -> void:
	for rp in ropes:
		var pr := Rect2(px - BW * 0.5, py - BH * 0.5, BW, BH)
		var cr := _cell_rect(rp)
		if not cr.intersects(pr):
			continue
		var cv: float = rp.cv
		if ri >= 0:
			_release(0.4)
		var ox := minf(pr.end.x - cr.position.x, cr.end.x - pr.position.x)
		var oy := minf(pr.end.y - cr.position.y, cr.end.y - pr.position.y)
		if oy <= ox:
			if py > cr.get_center().y:
				py += oy + 0.001
				if vy - cv < -FALL:
					_die("떨어짐")
					return
				vy = maxf(vy, cv)
				on_floor = true
			else:
				py -= oy + 0.001
				vy = minf(vy, cv)
				if _hits(px, py):
					_die("깔림")
					return
		else:
			px += (ox + 0.001) * (1.0 if px > cr.get_center().x else -1.0)
			if absf(vx) > CRUSH:
				_die("으깨짐")
				return
			vx = 0.0
			if _hits(px, py):
				_die("깔림")
				return


func _prisoners(h: float) -> void:
	var pr := Rect2(px - BW * 0.5, py - BH * 0.5, BW, BH)
	for q in pris:
		if bool(q.taken):
			continue
		var p: Vector2 = q.p
		var qv: float = q.vy
		qv = maxf(qv - G * h, -30.0)
		p.y += qv * h
		var below := floori(p.y - 0.5)
		if _solid(floori(p.x), below):
			p.y = below + 1.5
			qv = 0.0
		q.p = p
		q.vy = qv
		q.mesh.position = Vector3(p.x, p.y, 0.2)
		if p.y < -3.0:
			q.taken = true
			q.mesh.visible = false
			continue
		var touch := Rect2(p.x - 0.3, p.y - 0.5, 0.6, 1.0).intersects(pr)
		if bool(q.fresh):
			if not touch:
				q.fresh = false
			continue
		if carry < 3 and drop_cd <= 0.0 and touch:
			carry += 1
			q.taken = true
			q.mesh.visible = false
			beep(440.0, 0.1, 660.0, 0.25)
			msg("업었다 (무거워짐)", 0.6)


func _check() -> void:
	var pr := Rect2(px - BW * 0.5, py - BH * 0.5, BW, BH)
	if py < -3.0:
		_die("떨어짐")
		return
	for c in range(floori(pr.position.x), floori(pr.end.x) + 1):
		for yy in range(floori(pr.position.y), floori(pr.end.y) + 1):
			if _ch(c, yy) == SPIKE and Rect2(c + 0.15, yy + 0.15, 0.7, 0.7).intersects(pr):
				_die("가시")
				return
	if door.intersects(pr):
		for rp in ropes:
			if bool(rp.used):
				dropped += 1
		_release(1.0)
		clear_t = 1.0
		vx = 0.0
		vy = 0.0
		score += 10 + 5 * carry
		play("win")
		msg("탈출 + 죄수 %d" % carry if carry > 0 else "문!", 0.9)


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	_release(1.0)
	die_t = 0.9
	body.material_override = mat(BAD)
	_burst(Vector2(px, py), 6, 6.0, ME)
	shake = maxf(shake, 0.45)
	play("bad")
	msg(why, 0.9)


## 소리: 잡고 있으면 끈이 도르래를 긁는 드르륵(빠를수록 촘촘·높게), 날 때는 바람
func _sounds(h: float) -> void:
	snd_t -= h
	warn_t -= h
	if die_t > 0.0:
		return
	# 감방이 착지대에 곧 닿는데 빠르면: 삐삐 (지금 놓아라)
	if ri >= 0 and warn_t <= 0.0:
		var rpw: Dictionary = ropes[ri]
		var rdw: float = rpw.rd
		if rdw < -TEAR * 0.6 and (float(rpw.r) - float(rpw.rmin)) / -rdw < 0.45:
			warn_t = 0.09
			beep(1300.0, 0.05, 1500.0, 0.16)
		elif strain > 0.55:
			warn_t = 0.16
			beep(90.0 + strain * 60.0, 0.12, 70.0, 0.1)  # 끈이 끼익 늘어나는 소리
	if snd_t > 0.0:
		return
	if ri >= 0:
		var sp := absf(float(ropes[ri].rd))
		if sp > 1.5:
			snd_t = clampf(1.4 / sp, 0.035, 0.2)
			beep(260.0 + sp * 30.0, 0.025, 0.0, 0.12)
	else:
		var sp := Vector2(vx, vy).length()
		if not on_floor and sp > 10.0:
			snd_t = 0.09
			beep(150.0 + sp * 12.0, 0.06, 100.0 + sp * 8.0, 0.08)
		elif on_floor and absf(vx) > 1.0:
			snd_t = 0.28
			beep(140.0, 0.03, 0.0, 0.08)


func _view(dt: float) -> void:
	var tremble := sin(anim * 70.0) * 0.06 * strain * strain
	var hot := BAD if strain > 0.85 else (A if strain > 0.55 else INK)
	# 끈·감방
	for k in ropes.size():
		var rp: Dictionary = ropes[k]
		var mine := k == ri
		var o: Vector2 = rp.o
		var r: float = rp.r
		var th: float = rp.th
		var hp := _handle(rp)
		var perp := Vector2(cos(th), sin(th)) * (tremble if mine else 0.0)
		var line: MeshInstance3D = rp.line
		line.position = Vector3((o.x + hp.x) * 0.5 + perp.x, (o.y + hp.y) * 0.5 + perp.y, 0.0)
		line.rotation.z = th
		var thick := 0.07 + (0.06 * strain if mine else 0.0)
		line.scale = Vector3(thick, r, thick)
		line.material_override = mat(hot if mine else INK)
		var hd: MeshInstance3D = rp.handle
		hd.position = Vector3(hp.x, hp.y, 0.0)
		hd.rotation.z = th
		var pul: MeshInstance3D = rp.pul
		pul.rotation.z = -r * 1.6
		var pul2: MeshInstance3D = rp.pul2
		pul2.rotation.z = -r * 1.6
		var cr := _cell_rect(rp)
		var cx := cr.get_center().x
		var top := cr.end.y
		var cline: MeshInstance3D = rp.cline
		var cl := o.y - top
		cline.position = Vector3(cx + (tremble if mine else 0.0), top + cl * 0.5, -0.4)
		cline.scale = Vector3(thick, maxf(cl, 0.05), thick)
		cline.material_override = mat(hot if mine else INK)
		var cell: MeshInstance3D = rp.cell
		cell.position = Vector3(cx, cr.get_center().y, -0.4)
		var win: MeshInstance3D = rp.win
		win.position = Vector3(cx, top - 0.4, 0.12)
		var bars: MeshInstance3D = rp.bars
		bars.position = Vector3(cx, top - 0.4, 0.16)
		var bolt: MeshInstance3D = rp.bolt
		bolt.visible = bool(rp.lock)
		# 떨어지는 감방 위로 남는 줄무늬
		var cv: float = rp.cv
		var cs: Array = rp.cs
		for j in 2:
			var s: MeshInstance3D = cs[j]
			s.visible = cv > 4.0 and die_t <= 0.0
			if s.visible:
				var ln := minf(cv * 0.12, 2.5)
				s.position = Vector3(cx - 0.35 + j * 0.7, top + 0.3 + ln * 0.5 + 0.2 * sin(anim * 30.0 + j), -0.2)
				s.scale = Vector3(0.06, ln, 0.06)
		var stack: Array = rp.stack
		for j in stack.size():
			var sb: MeshInstance3D = stack[j]
			sb.position = Vector3(cx - 0.3 + (j % 2) * 0.6, top + 0.22 + floorf(j * 0.5) * 0.42, -0.4)
	# 나: 끌려가는 속도만큼 몸이 늘어나고 빨개지며 팔이 빠지려 늘어난다
	squash = maxf(0.0, squash - dt * 2.5)
	var speed := Vector2(vx, vy).length()
	var sy := 1.0
	var a := 0.0
	var ext := 0.0
	if ri >= 0 and die_t <= 0.0:
		var hp := _handle(ropes[ri])
		a = clampf(float(ropes[ri].th), -0.7, 0.7)
		sy = 1.0 + 0.55 * minf(strain, 1.1)
		ext = strain * strain * 0.5
		me.position = Vector3(hp.x + sin(a) * (ARM + ext), hp.y - cos(a) * (ARM + ext), 0.0)
	else:
		if speed > 8.0 and not on_floor:
			a = atan2(-vx, vy) if vy >= 0.0 else atan2(vx, -vy)
			a = clampf(a, -0.9, 0.9)
			sy = 1.0 + minf((speed - 8.0) / 40.0, 0.45)
		me.position = Vector3(px, py, 0.0)
	me.rotation.z = lerp_angle(me.rotation.z, a, 1.0 - exp(-14.0 * dt))
	sy *= 1.0 - squash
	var sx := 1.0 / sqrt(sy)
	body.scale = Vector3(BW * sx, BH * sy, 0.6)
	body.position.y = (ARM - BH * 0.5 * sy) if ri >= 0 else (-BH * 0.5 + BH * 0.5 * sy)
	if die_t <= 0.0:
		body.material_override = mat(BAD if strain > 0.85 else (A if strain > 0.55 else ME))
	var face := signf(vx) if absf(vx) > 0.5 else 1.0
	eye.position = Vector3(face * 0.2 * sx, body.position.y + 0.35 * sy, 0.31)
	eye.scale = Vector3.ONE * (0.16 + 0.14 * minf(strain, 1.0))
	eye.scale.z = 0.05
	hand.visible = ri >= 0
	hand.position = Vector3(0, ARM + ext, 0)
	arm.visible = ri >= 0 and ext > 0.03
	arm.position = Vector3(0, ARM + ext * 0.5, 0)
	arm.scale = Vector3(0.14, ext + 0.05, 0.2)
	var bottom := body.position.y - BH * 0.5 * sy
	for k in loads.size():
		loads[k].visible = k < carry
		loads[k].position.y = bottom - 0.45 - k * 0.9
		loads[k].rotation.z = clampf(-vx * 0.03, -0.6, 0.6)
	# 빠를 때 잔상
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.035
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = speed > 9.0 and die_t <= 0.0
		tb.position = Vector3(me.position.x, me.position.y, -0.3)
		tb.rotation.z = me.rotation.z
		tb.scale = Vector3(BW * sx, BH * sy, 0.3)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	# 바람 줄무늬: 세상에 박혀 있다가 내가 지나치면 앞쪽에 다시 생긴다 (빠를수록 길고 많이 스친다)
	var vdir := Vector2(vx, vy).normalized() if speed > 0.1 else Vector2.UP
	var on := speed > 7.0 and die_t <= 0.0
	for k in streaks.size():
		var s := streaks[k]
		var sp2: Vector2 = st_off[k]
		var rel := sp2 - Vector2(px, py)
		if not s.visible or rel.length() > 7.0 or rel.dot(vdir) < -5.0:
			var side := Vector2(-vdir.y, vdir.x)
			sp2 = Vector2(px, py) + vdir * randf_range(2.0, 7.0) + side * randf_range(-3.5, 3.5)
			st_off[k] = sp2
		s.visible = on and k < int(speed / 2.0)
		if s.visible:
			s.position = Vector3(sp2.x, sp2.y, 1.15)
			s.rotation.z = atan2(-vdir.x, vdir.y)
			s.scale = Vector3(0.06, clampf(speed * 0.07, 0.4, 2.6), 0.06)
	# 파편
	for k in bits.size():
		if bit_life[k] <= 0.0:
			continue
		bit_life[k] -= dt
		var b := bits[k]
		var bv := bit_v[k]
		bv.y -= G * 0.6 * dt
		bit_v[k] = bv
		b.position += bv * dt
		b.rotation.z += dt * 8.0
		b.scale = Vector3.ONE * 0.22 * clampf(bit_life[k] / 0.3, 0.0, 1.0)
		if bit_life[k] <= 0.0:
			b.visible = false
	# 창밖 구름
	for c in clouds:
		var cm: MeshInstance3D = c[0]
		var wr: Rect2 = c[1]
		cm.position.x += float(c[2]) * dt
		if cm.position.x > wr.end.x - 0.45:
			cm.position.x = wr.position.x + 0.45
	# 카메라: 잡고 있으면 나와 떨어지는 감방이 한 화면에 (멀면 물러난다), 아니면 가는 쪽을 더 보여 준다
	var k2 := 1.0 - exp(-5.0 * dt)
	var tx := px + vx * 0.12
	var ty := py + 2.0 + vy * 0.15
	var dist := 18.0 + minf(speed, 30.0) * 0.12
	if ri >= 0:
		var crc := _cell_rect(ropes[ri]).get_center()
		var low := float(ropes[ri].o.y) - LC0 - (float(ropes[ri].rmax) - float(ropes[ri].rmin)) - float(ropes[ri].chh)
		var y0 := minf(minf(py, crc.y), low) - 1.5
		var y1 := maxf(py, crc.y) + 2.5
		var x0 := minf(px, crc.x) - 1.5
		var x1 := maxf(px, crc.x) + 1.5
		tx = (x0 + x1) * 0.5
		ty = (y0 + y1) * 0.5
		dist = maxf(dist, maxf((y1 - y0) * 0.5 / 0.5, (x1 - x0) * 0.5 / 0.28))
	dist = minf(dist, 30.0)
	cam_x = lerpf(cam_x, tx, k2)
	cam_y = lerpf(cam_y, ty, k2)
	cam.position.z = lerpf(cam.position.z if cam.position.z > 1.0 else 18.0, dist, k2 * 0.6)
	var hw := cam.position.z * 0.29
	if gw > hw * 2.0:
		cam_x = clampf(cam_x, hw, gw - hw)
	else:
		cam_x = gw * 0.5
	shake = maxf(0.0, shake - dt * 1.5)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.8
	cam.position.x = cam_x + off.x
	cam.position.y = cam_y + off.y
	cam.rotation = Vector3(0.0, 0.0, tilt + off.x * 0.02)
	cam.fov = lerpf(cam.fov, 56.0 + minf(speed, 30.0) * 0.3, k2)
