extends Tofu
## 압축된 이웃 (옆모습): 왼쪽 아래 스틱으로 벽·바닥·틈에 몸을 밀어 넣으면 눌리고(납작/가늘어짐), 손을 떼면 눌린 만큼 반대로 튀어나간다. 오른쪽 '걸기'는 구역마다 다른 일.
## 핵심 규칙: 속도는 압축에서 나온다(보이는 상자 = 충돌 상자). 많이 누를수록 멀리 가지만 19 넘게 부딪히면 으깨지고, 빠르게 철근에 닿으면 찢긴다. 문에는 천천히 닿아야 들어간다.
## 구역1 현관 틈: 가로 틈을 밀고 지나가면 저절로 눌려 나오는 순간 발사(좁을수록 빠름). 걸기를 쥔 채 나오면 꼬리가 걸려 가까이 멈춘다.
## 구역2 수직 배관: 바닥의 목이 아래로 쏜다. 공중 걸기 = 양쪽 벽 짚기(압축이 브레이크). 너무 빠를 때나 철근 옆에서 짚으면 찢김.
## 구역3 갈라진 거실(맛보기): 바닥에 눌린 채(납작 = 넓게) 기어 틈을 건넌다. 걸기를 쥐고 기면 뒤꼬리가 남아 몸이 늘어난다. 놓으면 천장 철근으로 튀니 스틱을 살짝만 기울여 천천히 편다.
## v2 구역4 받기: 날다가 걸기를 쥐고 부딪히면 그 면을 미는 속도가 압축으로 저장되고 붙는다. 걸기를 놓으면 스틱 쪽으로 튄다.
## v2 구역5 프레스: 보라 프레스가 내 힘보다 더 납작하게(과압축) 눌러 준다. 스틱을 아래로 쥔 채 기어 나와 놓으면 아주 높이. 빨간 바닥 프레스는 터진다.
## v2 구역6 바깥 벽: 틈 대포 -> 받기 -> 프레스를 한 방에 섞는다. 비주얼: 날아갈 길 점선(빨강 = 으깨짐), 구역별 뒷벽·창문, 먼지.
## v3 스테이지 선택(깬 방까지 열림, user:// 저장, 처음 켜면 선택 판 + '이어하기') + 구역7 옥상 가는 길 6방: 틈·목은 되돌아 나가도 쏜다, 과압축은 덜어 내야 사는 천장, 눌린 몸은 다리, 천장 받기, 종합. 비주얼: 먼 건물·구름, 눈 둘+입, 문틀+화살표.
# 한 문장: 나는 살아 있는 완충재로서 무너진 아파트의 좁은 틈 속에서 몸을 밀어 넣어 눌렀다 놓아 바깥으로 튀어나가지만, 많이 눌릴수록 멀리 가는 대신 벽에 으깨지고 철근에 찢기는 대가를 감수한다.

const S0 := 1.2  # 안 눌린 몸 (정사각)
const SQ := 0.6  # q=1 이면 눌린 쪽이 0.4배, 다른 쪽은 2.5배 (넓이 보존)
const LAUNCH := 26.0  # q=1 발사 속도
const CRUSH := 19.0  # 이보다 세게 부딪히면 으깨짐 (q 0.73)
const TEAR := 21.0  # 이보다 빠르게 떨어지는 중에 벽을 짚으면 찢김
const REBAR_V := 8.0
const DOOR_V := 8.0
const GRAV := 30.0
const CHARGE := 1.3  # 초당 압축
const RELAX := 1.0  # 살짝 기울이면 초당 이만큼 펴진다 (발사 없이)
const PUSH := 0.55  # 스틱을 이보다 밀면 누르기
const LET_GO := 0.25  # 이보다 작으면 놓음 = 발사
const CREEP := 2.5  # 눌린 채 기어가기
const ROLL := 3.5
const ROLL_ACC := 20.0
const FRIC := 28.0
const AIRMAX := 4.0
const SQZ_V := 3.5  # 틈 안에서 밀려 나가는 속도
const GRIP_W := 2.05  # 양쪽 벽 사이가 이보다 좁으면 짚을 수 있다
const GRIP_DEC := 45.0
const TETHER_L := 0.9
const TETHER_K := 70.0
const STRETCH := 2.2  # 뒤꼬리로 더 늘일 수 있는 길이
const WALLC := Color("d9c39a")
const Q_MAX := 1.35  # 프레스가 눌러 주는 최대 압축 (내 힘은 1.0)
const CATCH_MIN := 4.0  # 받기: 이보다 느린 충돌은 그냥 닿음
const CATCH_K := 1.6  # 받기에서 튈 때 스틱으로 꺾는 정도 (보통 0.9)
const PRESSC := Color("b197fc")
const ZONEC := {"1": Color("f6eedd"), "2": Color("eef3f7"), "3": Color("f6efe6"), "4": Color("e7f1fb"), "5": Color("f3eaf8"), "6": Color("e8f6ea"), "7": Color("dcefff")}
const ZONE_NAMES := {"1": "현관 틈", "2": "수직 배관", "3": "갈라진 거실", "4": "받기", "5": "프레스", "6": "바깥 벽", "7": "옥상 가는 길"}
const SAVE_V3 := "user://compress_v3.json"

# 방: solid/rebar(빠르게 닿으면 찢김)/wallbar(짚으면 찢김) = [x0,y0,x1,y1], slit = [x0,y0,x1,y1, 세로면 1] (틈의 빈 칸), start = 발 가운데
const ROOMS := [
	{"name": "1-1 현관 틈", "cam": 16.0, "start": [1, 0], "door": [23.5, 0, 27.5, 2.2],
		"solid": [[-4, -1, 13, 0], [17, -1, 31, 0], [-4, 0, -3, 7], [30, 0, 31, 7], [-4, 6, 31, 7], [8, 0.6, 9, 6]],
		"slit": [[8, 0, 9, 0.6, 0]],
		"rebar": [[13, -3, 17, -2.6]]},
	{"name": "1-2 가까운 벽", "cam": 15.0, "start": [1.5, 0], "door": [9, 0, 12, 2.2],
		"solid": [[-4, -1, 14, 0], [-4, 0, -3, 6], [13, 0, 14, 6], [-4, 5, 14, 6], [6, 0.45, 7, 5]],
		"slit": [[6, 0, 7, 0.45, 0]],
		"rebar": [[12.85, 0.3, 13, 4.7]]},
	{"name": "1-3 두 틈", "cam": 16.0, "start": [1, 0], "door": [17, 0, 20, 2.2],
		"solid": [[-4, -1, 9, 0], [14, -1, 22, 0], [-4, 0, -3, 8], [21, 0, 22, 8], [-4, 7, 22, 8],
			[8, 0.5, 9, 2.6], [8, 3.5, 9, 7], [5, 2.2, 8, 2.6]],
		"slit": [[8, 0, 9, 0.5, 0], [8, 2.6, 9, 3.5, 0]],
		"rebar": [[9, -3, 14, -2.6]]},
	{"name": "2-1 배관", "cam": 13.0, "start": [0.8, 28], "door": [0.1, 0, 1.5, 2],
		"solid": [[-2.5, 15, 0, 31], [1.6, 15, 4.1, 31], [-2.5, -1, 0, 9.5], [1.6, -1, 4.1, 9.5],
			[-2.5, 9.5, -1.5, 15], [3.1, 9.5, 4.1, 15], [-1.5, 9.0, 0.45, 9.5], [1.15, 9.0, 3.1, 9.5],
			[-2.5, 31, 4.1, 32], [0, 27.5, 0.55, 28], [1.05, 27.5, 1.6, 28], [-2.5, -1, 4.1, 0]],
		"slit": [[0.55, 27.5, 1.05, 28, 1], [0.45, 9.0, 1.15, 9.5, 1]],
		"wallbar": [[0, 21, 0.12, 23.5], [1.48, 21, 1.6, 23.5]]},
	{"name": "2-2 옆 출구", "cam": 13.0, "start": [-2.5, 20], "door": [4.4, 0, 7, 2.2],
		"solid": [[-4.5, 19.5, 0, 20], [-4.5, 19.5, -4, 23], [-4.5, 23, 4, 24], [-1.5, -1, 0, 19.5],
			[1.6, 0.5, 2.6, 23], [2.6, 3, 9, 23], [-1.5, -1, 9, 0], [8, -1, 9, 3]],
		"slit": [[1.6, 0, 2.6, 0.5, 0]],
		"wallbar": [[0, 13, 0.12, 16], [1.48, 13, 1.6, 16], [0, 3.5, 0.12, 6.5], [1.48, 3.5, 1.6, 6.5]]},
	{"name": "3 갈라진 거실", "cam": 16.0, "start": [0, 0], "door": [27, 4, 29.5, 6.2],
		"solid": [[-4, -1, 4, 0], [5.5, -1, 9, 0], [11.5, -1, 15, 0], [18.6, -1, 31, 0],
			[-4, 0, -3, 13], [30, 0, 31, 13], [-4, 12, 31, 13], [-4, 2.4, 14, 4], [14, 1.6, 20.2, 4], [25, 3.5, 30, 4]],
		"rebar": [[-3, 2.2, 14, 2.4], [14, 1.4, 20.2, 1.6], [4, -3, 5.5, -2.6], [9, -3, 11.5, -2.6], [15, -3, 18.6, -2.6]]},
	# 구역4 받기 (catch = 걸기 쥐고 부딪히면 받기)
	{"name": "4-1 받기 우물", "cam": 16.0, "start": [-2, 10], "door": [17, 8, 20, 10.2], "catch": true,
		"solid": [[-5, -1, -4, 22], [22, -1, 23, 22], [-5, 21, 23, 22], [-4, -1, 1, 10], [-4, 11.6, 1, 12.2],
			[1, -1, 10, 0], [10, -1, 22, 8]]},
	{"name": "4-2 벽에 받기", "cam": 15.0, "start": [-2, 0], "door": [-3.5, 3, -1.3, 5.2], "catch": true,
		"solid": [[-5, -4, -4, 10], [8, -4, 9, 10], [-5, 9, 9, 10], [-4, -1, 3, 0], [-4, 2.5, 3, 3]],
		"rebar": [[3, -3, 8, -2.6]]},
	# 구역5 프레스: press = [x0, x1, 내려온 바닥, 올라간 바닥, 위 끝, 주기, 시작 위상, 빨강(터짐)]
	{"name": "5-1 프레스", "cam": 17.0, "start": [0, 0], "door": [16, 14, 19, 16.2], "catch": true,
		"solid": [[-5, -1, -4, 26], [20, -1, 21, 26], [-5, 25, 21, 26], [-4, -1, 20, 0], [13, 13.4, 20, 14]],
		"press": [[4, 9, 0.35, 7, 25, 4.0, 0.0, 0]]},
	{"name": "5-2 빨간 프레스", "cam": 17.0, "start": [0, 0], "door": [24, 14, 27, 16.2], "catch": true,
		"solid": [[-5, -1, -4, 26], [28, -1, 29, 26], [-5, 25, 29, 26], [-4, -1, 28, 0], [20, 13.4, 28, 14]],
		"press": [[4, 6.5, 0.12, 2.2, 25, 3.2, 0.0, 1], [11, 16, 0.35, 7, 25, 4.0, 1.3, 0]]},
	# 구역6 섞기: 틈 대포 -> 구덩이 받기 -> 단 위 프레스 과압축 -> 높은 문
	{"name": "6 바깥 벽", "cam": 16.0, "start": [0, 8], "door": [38, 18, 41, 20.2], "catch": true,
		"solid": [[-5, -1, -4, 31], [42, -1, 43, 31], [-5, 30, 43, 31], [-4, -1, 7, 8], [-4, 12, 7, 12.6],
			[6, 8.84, 7, 12], [7, -1, 22, 0], [22, -1, 42, 4], [35, 17.4, 42, 18]],
		"slit": [[6, 8, 7, 8.84, 0]],
		"press": [[26, 31, 4.35, 11, 30, 4.0, 0.0, 0]]},
	# 구역7 옥상 가는 길 (v3): 같은 대포가 반대로도, 덜어 내서도 쓰인다
	# 7-1 목은 들어간 뒤 위로 되돌아 나오면 위로 25 쏜다 (통로 폭 1.8 = 내 힘으론 3.5칸뿐, 지나가면 철근)
	{"name": "7-1 되돌아 나오는 목", "cam": 14.0, "start": [0, 0], "door": [4.5, 8, 6.5, 10.2],
		"solid": [[-1.9, -5, -0.9, 13], [0.9, -5, 1.9, 8], [-0.9, -1, -0.25, 0], [0.25, -1, 0.9, 0], [-0.9, -5, 0.9, -3.9],
			[1.9, -5, 7, 8], [7, -5, 8, 13], [-1.9, 12, 8, 13]],
		"slit": [[-0.25, -0.5, 0.25, 0, 1]],
		"rebar": [[-0.9, -3.9, 0.9, -3.5]]},
	# 7-2 가로 틈도 되돌아 나오면 들어간 쪽으로 쏜다. 천장 2.3이라 벽 누르기는 호가 끊김, 지나가면 벽장 철근, 걸기 쥐면 꼬리가 걸림. 문엔 미끄러져 지나 되돌아온다
	{"name": "7-2 뒤로 쏘는 틈", "cam": 17.0, "start": [0.3, 0], "door": [-20, 0, -18, 2.2],
		"solid": [[-24, -1, -23, 3.3], [-23, -1, -9, 0], [-9, -5, -1, -3.9], [-1, -1, 1.5, 0], [1.5, 0.5, 2.5, 2.3],
			[2.5, -1, 4.5, 0], [4.5, -1, 5.5, 3.3], [-24, 2.3, 5.5, 3.3]],
		"slit": [[1.5, 0, 2.5, 0.5, 0]],
		"rebar": [[-9, -3.9, -1, -3.5], [4.3, 0, 4.5, 2.3]]},
	# 7-3 과압축(34)은 천장 11에 박힌다. 기어 나온 뒤 살짝 기울여 1.0까지 덜어 내고 비스듬히(20~32°) 쏘면 선반 7.6
	{"name": "7-3 덜어 내기", "cam": 17.0, "start": [3.5, 0], "door": [18, 7.6, 20, 9.8],
		"solid": [[-1, -5, 1, 11], [1, -1, 13, 0], [6, 0.6, 7, 11], [13, -5, 24, 7.6], [24, -5, 25, 12], [-1, 11, 25, 12]],
		"press": [[1, 6, 0.26, 4, 11, 4.0, 0.0, 0]]},
	# 7-4 눌린 몸(폭 5.6)은 4.5 틈 위의 다리. 건넌 뒤 천장 2.3 밑에선 놓으면 죽으니 천천히 편다
	{"name": "7-4 납작한 다리", "cam": 17.0, "start": [3, 0], "door": [18, 0, 20, 2.2],
		"solid": [[-1, -5, 1, 12], [1, -1, 5, 0], [5, -5, 9.5, -3.9], [9.5, -1, 21, 0], [12, 2.3, 21, 12], [21, -5, 22, 13], [-1, 12, 22, 13]],
		"press": [[1, 5, 0.26, 4, 12, 4.0, 0.0, 0]],
		"rebar": [[5, -3.9, 9.5, -3.5]]},
	# 7-5 목으로 위로 쏜 뒤 천장(9.5)에 걸기 쥐고 받기, 오른쪽으로 놓아 벽 위 선반(7)에. 통로 2.2라 짚기는 안 되고 내 힘은 6.5칸
	{"name": "7-5 천장 받기", "cam": 14.0, "start": [0, 0], "door": [5, 7, 7, 9.2], "catch": true,
		"solid": [[-2.1, -5, -1.1, 13], [1.1, -5, 2.1, 7], [-1.1, -1, -0.25, 0], [0.25, -1, 1.1, 0], [-1.1, -5, 1.1, -3.9],
			[2.1, -5, 9, 7], [9, -5, 10, 13], [-2.1, 9.5, 10, 10.5]],
		"slit": [[-0.25, -0.5, 0.25, 0, 1]],
		"rebar": [[-1.1, -3.9, 1.1, -3.5]]},
	# 7-6 종합: 목 되돌아(1층→2층) → 프레스 다리(4.5 틈) → 천장 2.5 밑 살짝 펴기 → 높은 틈 대포 → 마당 미끄러져 문
	{"name": "7-6 옥상", "cam": 17.0, "start": [0, 0], "door": [38, 8.5, 40, 10.7],
		"solid": [[-1.9, -5, -0.9, 20], [-0.9, -1, -0.25, 0], [0.25, -1, 0.9, 0], [-0.9, -5, 0.9, -3.9],
			[0.9, -5, 7, 8.5], [7, -5, 11.5, 5], [11.5, -5, 17, 8.5], [14, 11, 17, 20],
			[17, 8.5, 18, 9.6], [17, 10.1, 18, 20], [18, -5, 45, 8.5], [45, -5, 46, 20], [-1.9, 20, 46, 21]],
		"slit": [[17, 9.6, 18, 10.1, 0]],
		"press": [[3, 7, 8.76, 10.5, 20, 4.0, 0.0, 0]],
		"rebar": [[-0.9, -3.9, 0.9, -3.5], [7, 5, 11.5, 5.4]]},
]


class _Hud extends Control:
	var k

	func _draw() -> void:
		k._hud_draw(self)

var lv := 0
var stage: Node3D
var solids: Array[Rect2] = []
var rebars: Array[Rect2] = []
var wallbars: Array[Rect2] = []
var slits: Array = []  # {r: Rect2, v: bool}
var door := Rect2()
var fall_y := -4.0
var cam_d := 16.0
var px := 0.0  # 발 가운데
var py := 0.0
var bw := S0  # 지금 몸 (보이는 상자 = 충돌 상자)
var bh := S0
var vel := Vector2.ZERO
var q := 0.0  # 압축: + 가로로 눌림(가늘고 큼), - 세로로 눌림(납작하고 넓음)
var cn := Vector2.ZERO  # 누르고 있는 면의 바깥 방향
var aim := Vector2.ZERO
var charging := false
var on_floor := false
var mode := 0  # 0 보통, 1 틈 안
var sq_r := Rect2()
var sq_v := false
var sq_dir := 1.0
var sq_q := 0.0
var hooked := false  # 꼬리 고무줄
var anchor := Vector2.ZERO
var grip := false  # 양쪽 벽 짚기
var stretch := false  # 뒤꼬리 남겨 늘이기
var st_dir := 1.0
var st_back := 0.0
var face := 1.0
var die_t := 0.0
var clear_t := 0.0
var shake := 0.0
var anim := 0.0
var cam_x := 0.0
var cam_y := 0.0
var snd_t := 0.0
var whoosh_t := 0.0
var door_warn := 0.0
var trail_t := 0.0
var trail_k := 0
var me: Node3D
var body: MeshInstance3D
var eye: MeshInstance3D
var rope: MeshInstance3D
var trail: Array[MeshInstance3D] = []
var catch_on := false  # 이 방에서 받기가 되는가
var caught := false  # 받아서 면에 붙어 있음
var squashed := false  # 프레스에 눌려 있음
var presses: Array = []  # {x0,x1,lo,hi,top,per,ph,kill,si,node,strip,down}
var rt := 0.0  # 방 시간 (프레스 박자)
var dust: Array = []  # {n: 상자, life, v}
var dust_k := 0
var dots: Array[MeshInstance3D] = []
var cleared := {}  # 깬 방 번호 -> true (기기에 저장)
var picking := false  # 스테이지 선택 판이 떠 있음
var hud: _Hud
var eye2: MeshInstance3D
var mouth: MeshInstance3D
var arrow: MeshInstance3D  # 문 위 통통 뛰는 화살표
var clouds: Array[MeshInstance3D] = []
var room_rect := Rect2()


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 58.0
	howto = "스틱으로 벽·바닥에 몸을 밀면 눌리고, 손을 떼면 눌린 만큼 반대로 튄다(점선 = 날아갈 길, 빨간 점선 = 부딪히면 으깨짐). 좁은 틈은 밀고 지나가면 저절로 눌려 발사 — 되돌아 나가도 쏜다.\n'걸기': 쥔 채 튀면 꼬리가 걸려 가까이 멈춤, 좁은 배관에선 양쪽 벽 짚기. 4구역부터는 날다가 쥐고 부딪히면 그 힘을 받아 붙고, 놓으면 스틱 쪽으로 튄다.\n5구역 보라 프레스는 나보다 더 납작하게 눌러 준다: 스틱을 아래로 쥔 채 기어 나와 놓기. 살짝만 기울이면 터지지 않고 천천히 펴진다.\n세게 부딪히면 으깨지고, 빠르게 빨간 철근에 닿으면 찢긴다. 문엔 천천히. 깬 방은 '방'에서 골라 다시 할 수 있다."
	kit_stick()
	kit_button("hook", "걸기", Vector2(600, 1100), 105.0, A)
	kit_button("retry", "다시", Vector2(420, 1060), 50.0, B)
	kit_button("rooms", "방", Vector2(420, 1200), 50.0, C)
	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)
	hud = _Hud.new()
	hud.k = self
	hud.size = Vector2(720, 1280)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
	_load_cleared()


## 처음 켜면 선택 판이 바로 뜨고, 이어할 방(첫 안 깬 방)이 강조된다
func _reset() -> void:
	stage = null
	hud.visible = true
	lv = ROOMS.size() - 1
	for i in ROOMS.size():
		if not cleared.has(i):
			lv = i
			break
	score = cleared.size()
	_room(lv)
	picking = true


func _rr(a: Array) -> Rect2:
	return Rect2(float(a[0]), float(a[1]), float(a[2]) - float(a[0]), float(a[3]) - float(a[1]))


func _room(i: int) -> void:
	if stage:
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	var R: Dictionary = ROOMS[i]
	solids.clear()
	rebars.clear()
	wallbars.clear()
	slits.clear()
	for a in R.solid:
		solids.append(_rr(a))
	for a in R.get("rebar", []):
		rebars.append(_rr(a))
	for a in R.get("wallbar", []):
		wallbars.append(_rr(a))
	for a in R.get("slit", []):
		slits.append({"r": _rr(a), "v": int(a[4]) == 1})
	door = _rr(R.door)
	cam_d = float(R.get("cam", 16.0))
	fall_y = -4.0
	catch_on = bool(R.get("catch", false))
	_backdrop(String(R.name).left(1))
	for s in solids:
		box(Vector3(s.get_center().x, s.get_center().y, 0.0), Vector3(s.size.x, s.size.y, 2.0), WALLC, stage)
	presses.clear()
	for a in R.get("press", []):
		var pr := {"x0": float(a[0]), "x1": float(a[1]), "lo": float(a[2]), "hi": float(a[3]), "top": float(a[4]),
			"per": float(a[5]), "ph": float(a[6]), "kill": int(a[7]) == 1, "si": solids.size(), "down": false}
		solids.append(Rect2(pr.x0, pr.hi, pr.x1 - pr.x0, pr.top - pr.hi))
		pr.node = box(Vector3.ZERO, Vector3.ONE, PRESSC, stage)
		pr.strip = box(Vector3.ZERO, Vector3(pr.x1 - pr.x0 + 0.1, 0.22, 2.1), BAD if pr.kill else D, stage)
		presses.append(pr)
	for s in rebars:
		box(Vector3(s.get_center().x, s.get_center().y, 0.0), Vector3(s.size.x, s.size.y, 1.4), BAD, stage)
	for s in wallbars:
		box(Vector3(s.get_center().x, s.get_center().y, 0.0), Vector3(s.size.x, s.size.y, 2.1), BAD, stage)
	# 틈 입구 노란 테두리
	for sl in slits:
		var r: Rect2 = sl.r
		if sl.v:
			box(Vector3(r.position.x + 0.04, r.get_center().y, 1.05), Vector3(0.08, r.size.y + 0.1, 0.1), D, stage)
			box(Vector3(r.end.x - 0.04, r.get_center().y, 1.05), Vector3(0.08, r.size.y + 0.1, 0.1), D, stage)
		else:
			box(Vector3(r.get_center().x, r.end.y - 0.04, 1.05), Vector3(r.size.x + 0.1, 0.08, 0.1), D, stage)
			box(Vector3(r.get_center().x, r.position.y + 0.04, 1.05), Vector3(r.size.x + 0.1, 0.08, 0.1), D, stage)
	# 문: 판 + 문틀(기둥 둘·상인방) + 손잡이 + 위에서 통통 뛰는 화살표
	box(Vector3(door.get_center().x, door.get_center().y, -0.6), Vector3(door.size.x, door.size.y, 0.6), GOOD, stage)
	var frame := GOOD.darkened(0.35)
	box(Vector3(door.position.x - 0.1, door.get_center().y, -0.2), Vector3(0.2, door.size.y, 0.9), frame, stage)
	box(Vector3(door.end.x + 0.1, door.get_center().y, -0.2), Vector3(0.2, door.size.y, 0.9), frame, stage)
	box(Vector3(door.get_center().x, door.end.y + 0.1, -0.2), Vector3(door.size.x + 0.4, 0.2, 0.9), frame, stage)
	box(Vector3(door.end.x - 0.3, door.get_center().y, -0.2), Vector3(0.15, 0.15, 0.2), D, stage)
	arrow = box(Vector3(door.get_center().x, door.end.y + 0.9, 0.3), Vector3(0.45, 0.45, 0.3), D, stage)
	arrow.rotation.z = PI * 0.25
	# 눈금 (속도감 단서): 드러난 윗면·옆면에 2칸마다
	var budget := 205 - stage.get_child_count()
	for s in solids:
		if s.size.x >= 2.0:
			var x := floorf(s.position.x) + 1.0
			while x < s.end.x - 0.3 and budget > 0:
				if not _hit(Rect2(x - 0.05, s.end.y + 0.01, 0.1, 0.3)):
					box(Vector3(x, s.end.y - 0.14, 1.02), Vector3(0.14, 0.28, 0.06), SOFT, stage)
					budget -= 1
				x += 2.0
		if s.size.y >= 4.0:
			var y := floorf(s.position.y) + 1.0
			while y < s.end.y - 0.3 and budget > 1:
				if not _hit(Rect2(s.end.x + 0.01, y - 0.05, 0.3, 0.1)):
					box(Vector3(s.end.x - 0.14, y, 1.02), Vector3(0.28, 0.14, 0.06), SOFT, stage)
					budget -= 1
				if not _hit(Rect2(s.position.x - 0.31, y - 0.05, 0.3, 0.1)):
					box(Vector3(s.position.x + 0.14, y, 1.02), Vector3(0.28, 0.14, 0.06), SOFT, stage)
					budget -= 1
				y += 2.0
	# 나: 흰 줄무늬 스프링 상자 (줄무늬는 몸과 같이 눌린다)
	me = Node3D.new()
	stage.add_child(me)
	body = box(Vector3(0.0, S0 * 0.5, 0.0), Vector3(S0, S0, 0.9), ME, me)
	for k in 3:
		box(Vector3(0.0, -0.3 + k * 0.3, 0.0), Vector3(1.03, 0.07, 1.03), WHITE, body)
	eye = box(Vector3(0.3, 0.85, 0.47), Vector3(0.16, 0.16, 0.05), WHITE, me)
	eye2 = box(Vector3(0.05, 0.85, 0.47), Vector3(0.14, 0.14, 0.05), WHITE, me)
	mouth = box(Vector3(0.2, 0.55, 0.47), Vector3(0.4, 0.06, 0.05), INK, me)
	rope = box(Vector3.ZERO, Vector3(1.0, 0.16, 0.3), A, stage)
	rope.visible = false
	trail.clear()
	for k in 6:
		var tb := box(Vector3.ZERO, Vector3(S0, S0, 0.4), B, stage)
		tb.visible = false
		trail.append(tb)
	dust.clear()
	for k in 9:
		var db := box(Vector3.ZERO, Vector3(0.25, 0.25, 0.25), WHITE, stage)
		db.visible = false
		dust.append({"n": db, "life": 0.0, "v": Vector2.ZERO})
	dots.clear()
	for k in 7:
		var dd := box(Vector3.ZERO, Vector3(0.2, 0.2, 0.2), A, stage)
		dd.visible = false
		dots.append(dd)
	var st: Array = R.start
	px = float(st[0])
	py = float(st[1]) + 0.001
	bw = S0
	bh = S0
	vel = Vector2.ZERO
	q = 0.0
	cn = Vector2.ZERO
	charging = false
	on_floor = true
	mode = 0
	hooked = false
	grip = false
	stretch = false
	caught = false
	squashed = false
	rt = 0.0
	_move_presses()
	die_t = 0.0
	clear_t = 0.0
	door_warn = 0.0
	cam_x = px
	cam_y = py + 1.0
	msg(R.name, 1.4)


# ---- 충돌 도우미 ----
func _rect() -> Rect2:
	return Rect2(px - bw * 0.5, py, bw, bh)


func _hit(r: Rect2) -> bool:
	for s in solids:
		if s.intersects(r):
			return true
	return false


func _floor_now() -> bool:
	return vel.y <= 0.01 and _hit(Rect2(px - bw * 0.5 + 0.01, py - 0.04, bw - 0.02, 0.04))


func _touch_side(sx: float) -> bool:
	var x0 := px + bw * 0.5 if sx > 0.0 else px - bw * 0.5 - 0.04
	return _hit(Rect2(x0, py + 0.05, 0.04, bh - 0.1))


func _touch_up() -> bool:
	return _hit(Rect2(px - bw * 0.5 + 0.02, py + bh, bw - 0.04, 0.04))


## 눌린 정도 -> 몸 크기 (넓이 보존)
func _dims(qq: float) -> Vector2:
	var s := 1.0 - SQ * absf(qq)
	if qq >= 0.0:
		return Vector2(S0 * s, S0 / s)
	return Vector2(S0 / s, S0 * s)


## 크기 d 가 들어갈 자리를 근처에서 찾아 바꾼다
func _fit(d: Vector2) -> bool:
	var dw := (d.x - bw) * 0.5
	var cands: Array[Vector2] = [Vector2(px, py), Vector2(px - dw, py), Vector2(px + dw, py),
		Vector2(px, py + (bh - d.y) * 0.5), Vector2(px, py + bh - d.y)]
	for c in cands:
		if not _hit(Rect2(c.x - d.x * 0.5, c.y, d.x, d.y)):
			px = c.x
			py = c.y
			bw = d.x
			bh = d.y
			return true
	return false


## 누르는 면에 붙인 채로 압축을 바꾼다 (공간이 모자라면 더 못 눌린다 = 공간이 장전 한도)
func _press(nq: float, n: Vector2) -> bool:
	var d := _dims(nq)
	var cands: Array[Vector2] = []
	if n.x != 0.0:
		var s := -n.x
		var edge := px + s * bw * 0.5
		var npy := py if on_floor else py + (bh - d.y) * 0.5
		cands.append(Vector2(edge - s * d.x * 0.5, npy))
	elif n.y > 0.0:
		var dw := (d.x - bw) * 0.5
		cands.append(Vector2(px, py))
		cands.append(Vector2(px - dw, py))
		cands.append(Vector2(px + dw, py))
	else:
		cands.append(Vector2(px, py + bh - d.y))
	for c in cands:
		if not _hit(Rect2(c.x - d.x * 0.5, c.y, d.x, d.y)):
			px = c.x
			py = c.y
			bw = d.x
			bh = d.y
			q = nq
			return true
	return false


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	anim += dt
	door_warn -= dt
	hud.queue_redraw()
	if kit_just("rooms") and clear_t <= 0.0:
		picking = not picking
		beep(700.0 if picking else 500.0, 0.06, 0.0, 0.15)
	if picking:
		_view(dt)
		return
	if kit_just("retry") and die_t <= 0.0 and clear_t <= 0.0:
		beep(400.0, 0.08, 250.0, 0.2)
		_room(lv)
		msg("다시", 0.5)
		return
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
			cleared[lv] = true
			_save_cleared()
			score = cleared.size()
			var nxt := lv + 1
			if nxt >= ROOMS.size():
				for i in ROOMS.size():
					if not cleared.has(i):
						nxt = i
						break
			if nxt >= ROOMS.size():
				hud.visible = false
				msg("옥상!", 1.5)
				end()
			else:
				lv = nxt
				_room(lv)
		return
	rt += h
	_move_presses()
	_squish()
	if die_t > 0.0:
		_view(dt)
		return
	on_floor = mode == 0 and _floor_now()
	if absf(kit_move.x) > 0.2:
		face = signf(kit_move.x)
	_control(h)
	if die_t <= 0.0 and mode == 0:
		_physics(h)
	_check()
	_sounds(h)
	_view(dt)
	var g := sq_q if mode == 1 else absf(q)
	gauge(g, C if g > 1.0 or caught else (BAD if g * LAUNCH > CRUSH else A))


func _control(h: float) -> void:
	var k := kit_move
	var mag := k.length()
	var kw := Vector2(k.x, -k.y)  # 위가 +
	charging = false
	if caught:
		# 받아서 붙어 있다: 스틱으로 꺾을 쪽을 고르고, 걸기를 놓으면 튄다
		if mag > 0.3:
			aim = kw.normalized()
		if not kit_held("hook"):
			caught = false
			_launch(CATCH_K)
		return
	if mode == 1:
		_squeeze(h, kw)
		return
	if mag > PUSH and not grip:
		var best_c := 0.0
		var n := Vector2.ZERO
		if kw.y < -0.35 and on_floor:
			var ti := _throat()
			if ti >= 0:
				_enter(ti, -1.0)
				return
			best_c = -kw.y
			n = Vector2(0.0, 1.0)
		if absf(kw.x) > 0.35:
			var sx := signf(kw.x)
			if _touch_side(sx):
				var si := _slit_h(sx)
				if si >= 0:
					_enter(si, sx)
					return
				if absf(kw.x) > best_c:
					best_c = absf(kw.x)
					n = Vector2(-sx, 0.0)
		if kw.y > 0.35 and _touch_up() and kw.y > best_c:
			n = Vector2(0.0, -1.0)
		if n != Vector2.ZERO:
			charging = true
			_charge(h, n, kw)
	elif mag > LET_GO and q != 0.0 and not stretch:
		# 살짝 기울임: 터지지 않고 천천히 펴진다
		var nq := move_toward(q, 0.0, RELAX * h)
		if absf(nq) < 0.06:
			nq = 0.0
		if _fit(_dims(nq)):
			q = nq
			if q == 0.0:
				cn = Vector2.ZERO
	if stretch and (not charging or not kit_held("hook")):
		_end_stretch()
	if mag <= LET_GO and q != 0.0:
		if absf(q) > 0.06 and cn != Vector2.ZERO:
			_launch()
		elif _fit(_dims(0.0)):
			q = 0.0
	if charging:
		vel.x = 0.0
	elif on_floor:
		var tg := 0.0
		if absf(kw.x) > 0.3 and absf(q) < 0.05:
			tg = signf(kw.x) * ROLL * minf(1.0, absf(kw.x) / 0.7)
		var acc := ROLL_ACC if absf(vel.x) <= ROLL + 0.1 else FRIC
		vel.x = move_toward(vel.x, tg, acc * h)
	elif absf(kw.x) > 0.3 and absf(vel.x) < AIRMAX:
		vel.x = move_toward(vel.x, signf(kw.x) * AIRMAX, 10.0 * h)


func _charge(h: float, n: Vector2, kw: Vector2) -> void:
	aim = kw.normalized()
	cn = n
	if n.y > 0.5 and absf(kw.x) > 0.3:
		var dx := signf(kw.x)
		if kit_held("hook"):
			_stretch_to(h, dx)
			return
		_move_x(dx * CREEP * h)
	if stretch:
		return
	var sgn := 1.0 if n.x != 0.0 else -1.0
	var nq: float
	var qmax := maxf(1.0, absf(q))  # 프레스가 눌러 준 과압축은 쥐고 있는 동안 유지
	if q * sgn < 0.0:
		nq = move_toward(q, 0.0, 4.0 * h)
	else:
		nq = clampf(q + sgn * CHARGE * h, -qmax, qmax)
	if nq != q and _press(nq, n):
		snd_t -= h
		if snd_t <= 0.0:
			snd_t = 0.07
			beep(180.0 + absf(q) * 520.0, 0.04, 0.0, 0.12)


## 걸기를 쥐고 기면 뒤 끝은 그 자리에 남고 앞 끝만 나간다 (몸이 다리가 된다)
func _stretch_to(h: float, dx: float) -> void:
	if not stretch or dx != st_dir:
		_end_stretch()
		stretch = true
		st_dir = dx
		st_back = px - dx * bw * 0.5
		beep(700.0, 0.06, 900.0, 0.15)
	var base := _dims(q).x
	var lead := px + dx * bw * 0.5 + dx * CREEP * h
	var w := clampf(absf(lead - st_back), base, base + STRETCH)
	lead = st_back + dx * w
	if not _hit(Rect2(minf(st_back, lead), py, w, bh)):
		if w > bw + 0.001:
			snd_t -= h
			if snd_t <= 0.0:
				snd_t = 0.1
				beep(500.0 + (w - base) * 200.0, 0.04, 0.0, 0.1)
		bw = w
		px = (st_back + lead) * 0.5


func _end_stretch() -> void:
	if not stretch:
		return
	stretch = false
	var d := _dims(q)
	var lead := px + st_dir * bw * 0.5
	var a := lead - st_dir * d.x * 0.5
	var b := st_back + st_dir * d.x * 0.5
	if not _hit(Rect2(a - d.x * 0.5, py, d.x, d.y)):
		px = a
	elif not _hit(Rect2(b - d.x * 0.5, py, d.x, d.y)):
		px = b
	else:
		return
	bw = d.x
	bh = d.y
	beep(1200.0, 0.05, 600.0, 0.15)


func _launch(kk := 0.9) -> void:
	var sp := LAUNCH * absf(q)
	var n := cn
	var dir := _ldir(kk)
	var faceat := Vector2(px, py + bh * 0.5) - n * Vector2(bw, bh) * 0.5
	if not _fit(_dims(0.0)):
		return  # 펴질 자리가 없으면 눌린 채로
	q = 0.0
	cn = Vector2.ZERO
	squashed = false
	vel = dir * sp
	_dust(faceat, n, 4)
	if kit_held("hook"):
		hooked = true
		anchor = faceat
	shake = maxf(shake, sp / 80.0)
	beep(260.0 + sp * 20.0, 0.14, 700.0 + sp * 40.0, 0.3)
	if sp > LAUNCH:
		msg("과압축!", 0.6)
	elif sp > CRUSH:
		msg("슝!", 0.4)


## 발사 방향: 미는 면의 바깥 + 스틱의 접선 성분
func _ldir(kk: float) -> Vector2:
	var tg := Vector2(cn.y, -cn.x)
	return (cn + tg * aim.dot(tg) * kk).normalized()


## 받기: 걸기를 쥔 채 부딪히면 면을 미는 속도가 압축이 되고 그 면에 붙는다
func _try_catch(sp: float, n: Vector2) -> bool:
	if not catch_on or not kit_held("hook") or hooked or grip or caught or mode != 0 or sp < CATCH_MIN:
		return false
	if sp > LAUNCH:
		_die("터짐")
		return true
	var nq := sp / LAUNCH * (1.0 if n.x != 0.0 else -1.0)
	var was_floor := on_floor
	on_floor = n.y > 0.5
	while absf(nq) > 0.08 and not _press(nq, n):
		nq *= 0.85
	on_floor = was_floor
	if absf(nq) <= 0.08:
		return false
	caught = true
	cn = n
	aim = -n
	vel = Vector2.ZERO
	shake = maxf(shake, sp / 90.0)
	_dust(Vector2(px, py + bh * 0.5) - n * Vector2(bw, bh) * 0.5, n, 5)
	beep(160.0 + sp * 12.0, 0.12, 90.0, 0.3)
	beep(500.0 + sp * 30.0, 0.08, 0.0, 0.15)
	msg("받기!", 0.5)
	return true


# ---- 프레스 ----
func _press_y(pr: Dictionary) -> float:
	var u := fposmod(rt + float(pr.ph), float(pr.per)) / float(pr.per)
	if u < 0.15:
		return lerpf(pr.hi, pr.lo, smoothstep(0.0, 0.15, u))
	if u < 0.45:
		return pr.lo
	if u < 0.65:
		return lerpf(pr.lo, pr.hi, smoothstep(0.45, 0.65, u))
	return pr.hi


func _move_presses() -> void:
	for pr in presses:
		var b := _press_y(pr)
		var w: float = pr.x1 - pr.x0
		solids[pr.si] = Rect2(pr.x0, b, w, pr.top - b)
		pr.node.position = Vector3(pr.x0 + w * 0.5, (b + pr.top) * 0.5, 0.0)
		pr.node.scale = Vector3(w, pr.top - b, 2.0)
		pr.strip.position = Vector3(pr.x0 + w * 0.5, b + 0.11, 0.0)
		var dn: bool = b <= pr.lo + 0.01
		if dn and not pr.down and die_t <= 0.0 and rt > 0.0:
			var near := absf(px - (pr.x0 + w * 0.5)) < 9.0
			beep(90.0, 0.14, 45.0, 0.3 if near else 0.12)
			if near:
				shake = maxf(shake, 0.12)
				_dust(Vector2(pr.x0 + w * 0.5, b), Vector2(0.0, 1.0), 3)
		pr.down = dn


## 프레스가 몸에 닿으면 바닥 쪽으로 납작하게 누른다 (내 힘보다 더, 1.35까지). 넘으면 터짐
func _squish() -> void:
	if mode != 0:
		return
	for pr in presses:
		var r: Rect2 = solids[pr.si]
		if not r.intersects(_rect()):
			continue
		var npy := r.position.y - bh - 0.001
		if npy < py and not _floor_now() and not _hit(Rect2(px - bw * 0.5, npy, bw, bh)):
			py = npy
			vel.y = minf(vel.y, 0.0)
			continue
		var hgt := r.position.y - py - 0.002
		var nq := -(1.0 - hgt / S0) / SQ
		if hgt <= 0.0 or -nq > Q_MAX:
			_die("터짐")
			return
		var d := _dims(nq)
		var dw := (d.x - bw) * 0.5
		var ok := false
		for cx: float in [px, px - dw, px + dw]:
			if not _hit(Rect2(cx - d.x * 0.5, py, d.x, d.y)):
				px = cx
				bw = d.x
				bh = d.y
				ok = true
				break
		if not ok:
			_die("터짐")
			return
		q = nq
		cn = Vector2(0.0, 1.0)
		if not charging:
			aim = Vector2(0.0, -1.0)
		vel = Vector2.ZERO
		caught = false
		grip = false
		if not squashed:
			squashed = true
			msg("꾹! 쥔 채 기어 나와", 1.2)
			beep(120.0, 0.2, 70.0, 0.3)
			shake = maxf(shake, 0.25)


# ---- 틈 ----
func _throat() -> int:
	for i in slits.size():
		if not slits[i].v:
			continue
		var r: Rect2 = slits[i].r
		if absf(py - r.end.y) < 0.08 and absf(px - r.get_center().x) < 0.7 and r.size.x < S0:
			return i
	return -1


func _slit_h(sx: float) -> int:
	var front := px + sx * bw * 0.5
	var cy := py + bh * 0.5
	for i in slits.size():
		if slits[i].v:
			continue
		var r: Rect2 = slits[i].r
		var fx := r.position.x if sx > 0.0 else r.end.x
		if absf(front - fx) < 0.08 and cy > r.position.y - 0.7 and cy < r.end.y + 0.7 and r.size.y < S0:
			return i
	return -1


func _enter(i: int, d: float) -> void:
	var sl: Dictionary = slits[i]
	sq_r = sl.r
	sq_v = sl.v
	sq_dir = d
	mode = 1
	q = 0.0
	cn = Vector2.ZERO
	hooked = false
	grip = false
	stretch = false
	vel = Vector2.ZERO
	if sq_v:
		bw = sq_r.size.x - 0.002
		bh = S0 * S0 / bw
		sq_q = clampf((1.0 - bw / S0) / SQ, 0.0, 1.0)
		px = sq_r.get_center().x
		py = sq_r.end.y - 0.05
	else:
		bh = sq_r.size.y - 0.002
		bw = S0 * S0 / bh
		sq_q = clampf((1.0 - bh / S0) / SQ, 0.0, 1.0)
		py = sq_r.position.y + 0.001
		px = (sq_r.position.x + 0.05 - bw * 0.5) if d > 0.0 else (sq_r.end.x - 0.05 + bw * 0.5)
	beep(300.0, 0.1, 140.0, 0.25)
	msg("끼익", 0.4)


## 틈 안: 스틱 방향으로 밀려 나간다. 다 빠져나가는 순간 눌린 만큼 발사 (되돌아 나가도 발사)
func _squeeze(h: float, kw: Vector2) -> void:
	var along := kw.y * sq_dir if sq_v else kw.x * sq_dir
	var mv := 0.0
	if along > 0.35:
		mv = 1.0
	elif along < -0.35:
		mv = -1.0
	if mv != 0.0:
		var stp := sq_dir * mv * SQZ_V * h
		if sq_v:
			py += stp
		else:
			px += stp
		snd_t -= h
		if snd_t <= 0.0:
			snd_t = 0.12
			beep(150.0 + sq_q * 200.0, 0.05, 110.0, 0.15)
	if sq_v:
		if py + bh <= sq_r.position.y:
			_slit_out(-1.0)
		elif py >= sq_r.end.y:
			_slit_out(1.0)
		return
	var front := px + sq_dir * bw * 0.5
	var tail := px - sq_dir * bw * 0.5
	if (sq_dir > 0.0 and tail >= sq_r.end.x) or (sq_dir < 0.0 and tail <= sq_r.position.x):
		_slit_out(sq_dir)
	elif (sq_dir > 0.0 and front <= sq_r.position.x) or (sq_dir < 0.0 and front >= sq_r.end.x):
		_slit_out(-sq_dir)


func _slit_out(d: float) -> void:
	mode = 0
	var sp := LAUNCH * sq_q
	var c := sq_r.get_center()
	bw = S0
	bh = S0
	if sq_v:
		px = c.x
		if d < 0.0:
			py = sq_r.position.y - S0 - 0.002
			anchor = Vector2(c.x, sq_r.position.y)
		else:
			py = sq_r.end.y + 0.002
			anchor = Vector2(c.x, sq_r.end.y)
		vel = Vector2(0.0, d * sp)
	else:
		py = sq_r.position.y + 0.001
		if d > 0.0:
			px = sq_r.end.x + S0 * 0.5 + 0.002
			anchor = Vector2(sq_r.end.x, c.y)
		else:
			px = sq_r.position.x - S0 * 0.5 - 0.002
			anchor = Vector2(sq_r.position.x, c.y)
		vel = Vector2(d, 0.3).normalized() * sp
	hooked = kit_held("hook")
	sq_q = 0.0
	shake = maxf(shake, sp / 70.0)
	beep(240.0 + sp * 22.0, 0.16, 800.0 + sp * 40.0, 0.32)
	msg("퐁!", 0.4)


# ---- 물리 ----
func _physics(h: float) -> void:
	if caught:
		vel = Vector2.ZERO
		return
	if kit_held("hook") and not hooked and not on_floor and not charging:
		var sp := _span()
		if sp.y - sp.x <= GRIP_W:
			if not grip:
				if absf(vel.y) > TEAR:
					_die("찢김")
					return
				grip = true
				beep(900.0, 0.08, 500.0, 0.22)
			bw = sp.y - sp.x - 0.004
			bh = S0 * S0 / bw
			px = (sp.x + sp.y) * 0.5
			for wb in wallbars:
				if wb.intersects(_rect()):
					_die("찢김")
					return
		elif grip:
			_end_grip()
	elif grip:
		_end_grip()
	if grip:
		var tg := -3.0 if kit_move.y > 0.4 else 0.0  # 스틱 아래 = 미끄러져 내려가기
		vel.y = move_toward(vel.y, tg, GRIP_DEC * h)
		vel.x = 0.0
	else:
		vel.y -= GRAV * h
	if hooked:
		_tether(h)
	for i in 4:
		_move_x(vel.x * h * 0.25)
		if die_t > 0.0:
			return
		_move_y(vel.y * h * 0.25)
		if die_t > 0.0:
			return
	on_floor = _floor_now()


## 양쪽 벽면 사이 (몸 높이 띠 안)
func _span() -> Vector2:
	var xl := -1e9
	var xr := 1e9
	var y0 := py + 0.05
	var y1 := py + bh - 0.05
	for s in solids:
		if s.position.y < y1 and s.end.y > y0:
			if s.end.x <= px + 0.01:
				xl = maxf(xl, s.end.x)
			elif s.position.x >= px - 0.01:
				xr = minf(xr, s.position.x)
	return Vector2(xl, xr)


func _end_grip() -> void:
	grip = false
	_fit(_dims(q))


## 꼬리 고무줄: 나온 자리에서 멀어질수록 당긴다
func _tether(h: float) -> void:
	if not kit_held("hook"):
		hooked = false
		beep(1200.0, 0.05, 600.0, 0.15)
		return
	var d := Vector2(px, py + bh * 0.5) - anchor
	var L := d.length()
	if L > 8.0:
		hooked = false
		return
	if L > TETHER_L:
		var nn := d / L
		var out := vel.dot(nn)
		if out > 0.0:
			vel -= nn * out * (1.0 - exp(-6.0 * h))
		vel -= nn * TETHER_K * (L - TETHER_L) * h


func _move_x(d: float) -> void:
	if d == 0.0:
		return
	px += d
	var r := _rect()
	for s in solids:
		if s.intersects(r):
			px = (s.position.x - bw * 0.5 - 0.001) if d > 0.0 else (s.end.x + bw * 0.5 + 0.001)
			var sp := absf(vel.x)
			if _try_catch(sp, Vector2(-signf(d), 0.0)):
				return
			vel.x = -vel.x * 0.3 if sp > 5.0 else 0.0
			_bump(sp)
			return


func _move_y(d: float) -> void:
	if d == 0.0:
		return
	py += d
	var r := _rect()
	for s in solids:
		if s.intersects(r):
			var sp := absf(vel.y)
			if d < 0.0:
				py = s.end.y + 0.001
			else:
				py = s.position.y - bh - 0.001
			if _try_catch(sp, Vector2(0.0, 1.0 if d < 0.0 else -1.0)):
				return
			if d < 0.0:
				vel.y = sp * 0.25 if sp > 6.0 else 0.0
			else:
				vel.y = -sp * 0.3 if sp > 3.0 else 0.0
			_bump(sp)
			return


func _bump(sp: float) -> void:
	if sp > CRUSH:
		_die("으깨짐")
	elif sp > 5.0:
		shake = maxf(shake, sp / 60.0)
		beep(70.0 + sp * 5.0, 0.08, 40.0, 0.3)
		_dust(Vector2(px, py + bh * 0.5), Vector2.ZERO, 2)


func _check() -> void:
	if die_t > 0.0 or clear_t > 0.0:
		return
	if py < fall_y:
		_die("떨어짐")
		return
	var r := _rect()
	var spd := vel.length() if mode == 0 else 0.0
	for rb in rebars:
		if rb.intersects(r) and spd > REBAR_V:
			_die("찢김")
			return
	if mode == 0 and door.intersects(r):
		if spd < DOOR_V:
			clear_t = 1.0
			vel = Vector2.ZERO
			hooked = false
			grip = false
			play("win")
			msg("문!", 0.8)
		elif door_warn <= 0.0:
			door_warn = 1.0
			msg("천천히!", 0.6)


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	die_t = 1.0
	hooked = false
	grip = false
	caught = false
	mode = 0
	body.material_override = mat(BAD)
	_dust(Vector2(px, py + bh * 0.5), Vector2.ZERO, 6)
	shake = maxf(shake, 0.5)
	if why == "으깨짐":
		bw = S0 * 1.8
		bh = S0 * 0.35
	play("bad")
	msg(why, 1.0)


## 바람 소리(빠를수록 박자·음 높게), 벽 짚고 미끄러지는 소리
func _sounds(h: float) -> void:
	var spd := vel.length() if mode == 0 else 0.0
	whoosh_t -= h
	if spd > 9.0 and whoosh_t <= 0.0:
		whoosh_t = clampf(1.6 / spd, 0.04, 0.2)
		beep(200.0 + spd * 22.0, 0.03, 0.0, 0.08)
	if grip and absf(vel.y) > 0.5:
		snd_t -= h
		if snd_t <= 0.0:
			snd_t = 0.05
			beep(600.0 + absf(vel.y) * 40.0, 0.04, 0.0, 0.1)


func _view(dt: float) -> void:
	me.position = Vector3(px, py, 0.0)
	body.position = Vector3(0.0, bh * 0.5, 0.0)
	body.scale = Vector3(bw, bh, 0.9)
	eye.position = Vector3(face * bw * 0.3, bh * 0.72, 0.47)
	eye.scale = Vector3(0.16, minf(0.16, bh * 0.25), 0.05)
	eye2.position = Vector3(face * bw * 0.06, bh * 0.72, 0.47)
	eye2.scale = Vector3(0.14, minf(0.14, bh * 0.22), 0.05)
	var gg := sq_q if mode == 1 else absf(q)
	var scared := die_t > 0.0 or gg * LAUNCH > CRUSH or vel.length() > CRUSH
	mouth.position = Vector3(face * bw * 0.18, bh * (0.38 if scared else 0.45), 0.47)
	mouth.scale = Vector3(clampf(bw * 0.3, 0.12, 0.9), minf(0.2 if scared else 0.06, bh * 0.2), 0.05)
	arrow.position.y = door.end.y + 0.9 + 0.25 * absf(sin(anim * 4.0))
	arrow.rotation.z = PI * 0.25 + 0.3 * sin(anim * 2.0)
	for i in clouds.size():
		var cl := clouds[i]
		cl.position.x += (0.25 + 0.1 * i) * dt
		if cl.position.x > room_rect.end.x + 2.0:
			cl.position.x = room_rect.position.x - 2.0
	if die_t <= 0.0:
		var g := sq_q if mode == 1 else absf(q)
		var col := ME
		if caught or g > 1.0:
			col = C
		elif g * LAUNCH > CRUSH:
			col = A
		elif grip:
			col = B
		body.material_override = mat(col)
	# 꼬리 고무줄
	rope.visible = hooked and die_t <= 0.0
	if rope.visible:
		var c := Vector2(px, py + bh * 0.5)
		var d := c - anchor
		var mid := (c + anchor) * 0.5
		rope.position = Vector3(mid.x, mid.y, 0.2)
		rope.rotation.z = atan2(d.y, d.x)
		rope.scale = Vector3(maxf(d.length(), 0.05), 0.16, 0.3)
	# 빠를 때 잔상 (눌린 모양 그대로)
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.03
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = vel.length() > 12.0 and die_t <= 0.0 and mode == 0
		tb.position = Vector3(px, py + bh * 0.5, -0.3)
		tb.scale = Vector3(bw, bh, 0.4)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	var look := _aim_dots()
	_dust_step(dt)
	var k := 1.0 - exp(-8.0 * dt)
	cam_x = lerpf(cam_x, px + vel.x * 0.12 + look.x, k)
	cam_y = lerpf(cam_y, py + bh * 0.5 + vel.y * 0.08 + look.y, k)
	shake = maxf(0.0, shake - dt * 1.5)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.8
	cam.position = Vector3(cam_x + off.x, cam_y - 1.5 + off.y, cam_d)
	cam.rotation = Vector3.ZERO
	cam.fov = lerpf(cam.fov, 54.0 + minf(vel.length(), 40.0) * 0.35, k)


## 날아갈 길 점선: 장전·받기·눌림 중 짧은 궤적 (간격 = 속도, 19 넘으면 빨강). 돌려주는 값 = 카메라 앞 여유
func _aim_dots() -> Vector2:
	var g := absf(q)
	var show := die_t <= 0.0 and mode == 0 and g > 0.06 and cn != Vector2.ZERO and (charging or caught or squashed)
	var sp := LAUNCH * g
	var dir := _ldir(CATCH_K if caught else 0.9) if show else Vector2.ZERO
	var p := Vector2(px, py + bh * 0.5) + dir * 0.9
	var v := dir * sp
	var col := mat(BAD if sp > CRUSH else (C if g > 1.0 else A))
	for dd in dots:
		if show:
			v.y -= GRAV * 0.06
			p += v * 0.06
			if _hit(Rect2(p.x - 0.1, p.y - 0.1, 0.2, 0.2)):
				show = false
		dd.visible = show
		if show:
			dd.position = Vector3(p.x, p.y, 0.6)
			dd.material_override = col
	return dir * minf(sp * 0.12, 3.0)


## 먼지 상자: at 에서 면 바깥(n)·옆으로 튄다
func _dust(at: Vector2, n: Vector2, cnt: int) -> void:
	var tg := Vector2(n.y, -n.x) if n != Vector2.ZERO else Vector2(1.0, 0.0)
	for i in cnt:
		var dd: Dictionary = dust[dust_k]
		dust_k = (dust_k + 1) % dust.size()
		dd.life = 0.45
		var side := -1.0 if i % 2 == 0 else 1.0
		if n != Vector2.ZERO:
			dd.v = n * 2.5 + tg * side * randf_range(2.0, 5.0)
		else:
			dd.v = Vector2(randf_range(-4.0, 4.0), randf_range(1.0, 4.0))
		dd.n.position = Vector3(at.x, at.y, 0.8)
		dd.n.scale = Vector3.ONE * 0.3
		dd.n.visible = true


func _dust_step(dt: float) -> void:
	for dd in dust:
		if dd.life <= 0.0:
			continue
		dd.life -= dt
		var dv: Vector2 = dd.v
		dd.n.position += Vector3(dv.x, dv.y, 0.0) * dt
		dd.n.scale = Vector3.ONE * maxf(0.02, 0.3 + (0.45 - dd.life) * 0.4) * clampf(dd.life / 0.2, 0.0, 1.0)
		dd.n.visible = dd.life > 0.0


## 구역 색 뒷벽과 창문 상자 (방 크기에 맞춰 판 시작 때 한 번)
func _backdrop(zone: String) -> void:
	var r := solids[0]
	for s in solids:
		r = r.merge(s)
	var col: Color = ZONEC.get(zone, SOFT)
	room_rect = r
	box(Vector3(r.get_center().x, r.get_center().y, -1.5), Vector3(r.size.x, r.size.y, 0.2), col, stage)
	# 뒷벽 뒤 먼 건물 실루엣 (높이가 다른 상자), 구역 7은 구름이 흐른다
	var nb := clampi(int(r.size.x / 3.0), 4, 10)
	var bwid := r.size.x / float(nb)
	var far := col.darkened(0.2)
	for i in nb:
		var hgt := r.size.y * (0.25 + 0.5 * fposmod(sin(float(i) * 12.9898 + r.size.x) * 43758.5453, 1.0))
		box(Vector3(r.position.x + (float(i) + 0.5) * bwid, r.position.y + hgt * 0.5, -2.4), Vector3(bwid * 0.78, hgt, 0.3), far, stage)
	clouds.clear()
	if zone == "7":
		for i in 3:
			var cl := box(Vector3(r.position.x + r.size.x * (0.15 + 0.3 * i), r.end.y - 2.0 - 2.5 * i, -2.0), Vector3(2.6 - 0.4 * i, 0.7, 0.2), WHITE, stage)
			clouds.append(cl)
	var win := col.darkened(0.12)
	var n := 0
	var y := r.position.y + 3.0
	while y < r.end.y - 2.0 and n < 12:
		var x := r.position.x + 3.0
		while x < r.end.x - 2.0 and n < 12:
			if not _hit(Rect2(x - 1.2, y - 1.2, 2.4, 2.4)):
				box(Vector3(x, y, -1.38), Vector3(1.6, 1.8, 0.06), win, stage)
				n += 1
			x += 6.0
		y += 6.0


# ---- 스테이지 선택 (v3) ----
const PANEL := Rect2(16, 230, 688, 404)
const CONT := Rect2(40, 282, 640, 52)


func _zone_of(i: int) -> int:
	return int(String(ROOMS[i].name).left(1)) - 1


func _tile(i: int) -> Rect2:
	var z := _zone_of(i)
	var k := 0
	for j in i:
		if _zone_of(j) == z:
			k += 1
	return Rect2(196 + k * 70, 344 + z * 41, 64, 36)


func _open(i: int) -> bool:
	return i == 0 or cleared.has(i) or cleared.has(i - 1)


func _tap(p: Vector2) -> void:
	if not picking:
		return
	if CONT.has_point(p):
		picking = false
		play("tap")
		_room(lv)
		return
	for i in ROOMS.size():
		if _tile(i).has_point(p):
			if _open(i):
				play("tap")
				lv = i
				picking = false
				_room(i)
			else:
				beep(150.0, 0.08, 0.0, 0.2)
			return
	if not PANEL.has_point(p):
		picking = false
		play("tap")


func _hud_draw(c: Control) -> void:
	if over or _rating or (_howto_box and _howto_box.visible):
		return
	c.draw_string(_font, Vector2(24, 268), String(ROOMS[lv].name), HORIZONTAL_ALIGNMENT_LEFT, 420, 28, INK)
	for i in ROOMS.size():
		var rr := Rect2(360 + i * 19 + _zone_of(i) * 4, 246, 15, 20)
		var zc: Color = ZONEC.get(String(ROOMS[i].name).left(1), SOFT)
		if i == lv:
			c.draw_rect(rr, ME.lerp(WHITE, 0.2 + 0.2 * sin(anim * 6.0)))
		elif cleared.has(i):
			c.draw_rect(rr, GOOD)
		else:
			c.draw_rect(rr, zc)
		c.draw_rect(rr, INK, false, 2.0)
	if not picking:
		return
	c.draw_rect(PANEL, Color(1, 1, 1, 0.96))
	c.draw_rect(PANEL, INK, false, 4.0)
	c.draw_string(_font, Vector2(40, 268), "스테이지  (깬 방 %d/%d)" % [cleared.size(), ROOMS.size()], HORIZONTAL_ALIGNMENT_LEFT, 640, 28, INK)
	c.draw_rect(CONT, ME)
	var cont_s := "▶ 이어하기  %s" % String(ROOMS[lv].name)
	if cleared.has(lv):
		cont_s = "▶ 다시 하기  %s" % String(ROOMS[lv].name)
	c.draw_string(_font, Vector2(CONT.position.x, CONT.position.y + 37), cont_s, HORIZONTAL_ALIGNMENT_CENTER, CONT.size.x, 28, WHITE)
	for z in 7:
		var zk := str(z + 1)
		var zc: Color = ZONEC.get(zk, SOFT)
		c.draw_rect(Rect2(32, 344 + z * 41, 158, 36), zc.darkened(0.08))
		c.draw_string(_font, Vector2(40, 344 + z * 41 + 26), "%s %s" % [zk, ZONE_NAMES.get(zk, "")], HORIZONTAL_ALIGNMENT_LEFT, 150, 20, INK)
	for i in ROOMS.size():
		var rr := _tile(i)
		var col := Color("dddddd")
		if cleared.has(i):
			col = GOOD.lightened(0.45)
		elif _open(i):
			col = WHITE
		c.draw_rect(rr, col)
		c.draw_rect(rr, ME if i == lv else INK, false, 5.0 if i == lv else 2.0)
		var s := String(ROOMS[i].name).get_slice(" ", 0)
		if cleared.has(i):
			s += "✓"
		elif not _open(i):
			s = "·"
		c.draw_string(_font, rr.position + Vector2(0, 26), s, HORIZONTAL_ALIGNMENT_CENTER, rr.size.x, 20, INK)


func _load_cleared() -> void:
	cleared = {}
	if not FileAccess.file_exists(SAVE_V3):
		return
	var f := FileAccess.open(SAVE_V3, FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		for v in d.get("cleared", []):
			cleared[int(v)] = true


func _save_cleared() -> void:
	var f := FileAccess.open(SAVE_V3, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"cleared": cleared.keys()}))
