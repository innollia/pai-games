extends Tofu
## 일격의 길 (단독판): [막기]·[베기] 버튼을 누른 채 왼·오·위·아래로 밀면 그쪽으로 바로 막고 벤다.
## 버튼을 그냥 탭하면 마지막으로 잡은 방향으로. 화면 빈 곳을 밀어 방향만 미리 잡아 둘 수도 있다. 1인칭 내 칼은 없다.
## 적 칼은 그쪽으로 들어 올려지고 흐린 잔상이 지나갈 길을 보여 준다(색 없이 칼 모양만 봐도 안다). 초록 상자 = 빈틈.
## 끝까지 기다렸다 막으면 '간파'(세상이 느려짐).
## 켜면 튜토리얼부터: 맞는 쪽으로 밀 때까지 멈추고 알려 준다. 그다음 찌르기 → 속임수 → 베기 → 거합 검객이 두 바퀴 나오고
## (뒤로 갈수록 체력·공격력·빠르기가 오른다), 마지막은 쓰러뜨릴 수 없는 끝판왕 검귀. 간파하면 그 자리에서 내가 직접 벤다.
## 빈틈이 아닐 때 휘두르면 헛공격: 체력 -1, 잠깐 굳고, 상대가 바로 친다.
## 매 판 맨몸으로 시작. 검객을 쓰러뜨리면 능력 셋 중 하나를 고른다(이번 판에만, 체력 자동 회복 없음). 쓰러지면 로비(전투 · 캐릭터 · 도감)에서 [전투]로 처음부터.
## 기록·도감·설정은 저장된다. 튜토리얼은 처음 한 번만(로비에서 다시 볼 수 있다).

const SWIPE := 60.0
const BTN_SWIPE := 38.0  # 버튼 위에서 이만큼 밀면 그 방향으로 바로 발동
const BTN_WAIT := 0.14  # 버튼을 밀지 않고 이만큼 누르고 있으면 잡아 둔 방향으로 발동
const OFF := [Vector3(-1.5, 0, 0.7), Vector3(1.5, 0, 0.7), Vector3(0, 1.75, 0.7), Vector3(0, -1.75, 0.7)]
const LEAN := [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, -1, 0)]
const OPP := [1, 0, 3, 2]
## 적 칼 (검객 기준): 들어 올린 자리 → 내게 닿는 자리, z 회전. 좌우는 세운 칼, 위아래는 눕힌 칼.
const WIND := [Vector3(-1.9, 0.5, 0.3), Vector3(1.9, 0.5, 0.3), Vector3(0, 2.4, 0.3), Vector3(0, -1.6, 0.4)]
const HIT := [Vector3(-0.6, 0.0, 0.9), Vector3(0.6, 0.0, 0.9), Vector3(0, 0.4, 0.9), Vector3(0, -0.7, 0.9)]
const ROT := [0.2, -0.2, PI / 2, PI / 2]
const ARROW := ["←", "→", "↑", "↓"]
## 공격 모양(검객 성향): 0 찌르기 = 칼끝을 겨누고 곧게 찌른다, 1 속임수 = 칼끝을 흔들며 휘두른다,
## 2 베기 = 크게 젖혔다 둥글게 내려 벤다, 3 거합 = 칼집에서 뽑아 한 번에 긋는다
## 찌르기: 당긴 자리 → 찌른 자리 (칼끝이 내 쪽을 향하고 조금 바깥으로 비스듬해서 방향이 보인다)
const T_WIND := [Vector3(-0.75, 0.1, -0.4), Vector3(0.75, 0.1, -0.4), Vector3(0, 0.75, -0.4), Vector3(0, -0.55, -0.4)]
const T_HIT := [Vector3(-1.35, 0.0, 1.5), Vector3(1.35, 0.0, 1.5), Vector3(0, 1.25, 1.5), Vector3(0, -1.15, 1.5)]
const SWING := [1.0, -1.0, 1.0, -1.0]  # 베기: 젖힌 칼이 도는 쪽
## 내 칼 자세 (카메라 기준): 위치, z 회전 (왼·오·위·아래)
const POSE := [Vector3(-0.8, -0.1, 2.5), Vector3(0.8, -0.1, 2.5), Vector3(0, 0.55, 2.5), Vector3(0, -0.85, 2.5)]
const TURN := [0.25, -0.25, PI / 2, PI / 2]
const REST_P := Vector3(0.55, -1.25, 2.5)
const REST_R := -0.6
const CAM_O := Vector3(0, 0.3, 5)
const NAMES := ["찌르기 검객", "속임수 검객", "베기 검객", "거합 검객", "끝판왕 검귀"]
const TIPS := [
	"칼이 오는 쪽으로 밀고 막기",
	"반쯤에 칼이 다른 쪽으로 옮겨 가요\n끝까지 보고 막기",
	"같은 쪽으로 두 번 와요!\n흐린 칼이 두 자루면 한 번 더 막기",
	"가만히 있다가 갑자기 뽑아요!\n눈이 번쩍하면 칼 쪽을 보고 막기. 먼저 베면 헛공격",
	"쓰러뜨릴 수 없어요. 오래 버티며 피해를 쌓아요",
]
const BODY := [A, C, B, ME, INK]
## 파이가 보낸 효과음 (10/30). 막기 소리는 공격 모양(sty: 찌르기·속임수·베기·거합)마다 다르다
const SND := {
	"hit": preload("res://sfx/hit.mp3"),
	"miss": preload("res://sfx/miss.mp3"),
	"whiff": preload("res://sfx/whiff.mp3"),
	"parry": preload("res://sfx/parry.mp3"),
	"death": preload("res://sfx/death.mp3"),
	"iai1": preload("res://sfx/iai_draw1.mp3"),  # 거합: 눈이 번쩍할 때 (10/31)
	"iai2": preload("res://sfx/iai_draw2.mp3"),  # 거합: 칼이 칼집에서 빠져나올 때 (10/31)
}
const BLOCK_SND := [preload("res://sfx/block_thrust.mp3"), preload("res://sfx/block_trick.mp3"), preload("res://sfx/block_slash.mp3"), preload("res://sfx/block_iai.mp3")]
const BOSS_AT := 8  # 이 번째(0부터)부터 끝판왕
const BOSS_HP := 9999
const SLOW := 0.3
const FIELD := Color("b8b07a")
const REED := Color("c9b98a")
const PLUME := Color("efe6d0")
const FILE := "user://blade_path.json"
## 검객 종류 > 단 > [쉼, 빈틈, 연속기 목록]. 연속기 = [보이는 쪽, 진짜 쪽, 예비 시간]의 줄. 보이는 쪽≠진짜 쪽이면 반쯤에 바뀌는 속임수.
const PAT := [
	[
		[0.7, 0.7, [[[0, 0, 0.8]], [[1, 1, 0.8]], [[2, 2, 0.8]], [[3, 3, 0.8]]]],
		[0.6, 0.6, [[[0, 0, 0.6], [1, 1, 0.6]], [[2, 2, 0.6], [3, 3, 0.6]]]],
		[0.5, 0.55, [[[0, 0, 0.45], [2, 2, 0.45], [1, 1, 0.45]], [[3, 3, 0.45], [1, 1, 0.45], [0, 0, 0.45]]]],
	],
	[
		[0.8, 0.4, [[[2, 2, 1.2], [0, 0, 0.35]], [[3, 3, 1.2], [1, 1, 0.35]]]],
		[0.7, 0.35, [[[0, 1, 1.0]], [[2, 3, 1.0]], [[1, 1, 0.5]]]],
		[0.6, 0.3, [[[3, 2, 1.0], [0, 0, 0.3]], [[1, 1, 1.2], [2, 3, 0.7]]]],
	],
	# 베기: 넷째 칸 1 = 앞 칼과 같은 쪽으로 바로 이어지는 두 번째 칼 (상자 두 겹으로 미리 보인다)
	[
		[0.8, 0.6, [[[0, 0, 0.8], [0, 0, 0.35, 1]], [[1, 1, 0.8], [1, 1, 0.35, 1]], [[2, 2, 0.8], [2, 2, 0.35, 1]]]],
		[0.7, 0.5, [[[3, 3, 0.7], [3, 3, 0.3, 1]], [[0, 0, 0.6], [0, 0, 0.3, 1], [1, 1, 0.6]], [[2, 2, 0.6], [2, 2, 0.3, 1], [3, 3, 0.5], [3, 3, 0.3, 1]]]],
		[0.6, 0.45, [[[1, 1, 0.55], [1, 1, 0.28, 1], [0, 0, 0.55], [0, 0, 0.28, 1]], [[2, 2, 0.5], [2, 2, 0.26, 1], [2, 2, 0.26, 1]]]],
	],
	# 거합: 넷째 칸 2 = 가만히 서 있다가(길이 무작위) 눈이 번쩍하고 순식간에 뽑는다
	[
		[0.5, 0.7, [[[0, 0, 0, 2]], [[1, 1, 0, 2]], [[2, 2, 0, 2]], [[3, 3, 0, 2]]]],
		[0.4, 0.6, [[[0, 0, 0, 2], [1, 1, 0.4]], [[3, 3, 0, 2]], [[1, 1, 0, 2], [0, 0, 0.35]]]],
		[0.3, 0.5, [[[2, 2, 0, 2], [3, 3, 0, 2]], [[0, 0, 0, 2], [0, 0, 0.3, 1]]]],
	],
	# 끝판왕: 넷을 섞는다. 단은 체력이 아니라 벤 횟수로 오른다
	[
		[0.6, 0.45, [[[0, 0, 0.6], [1, 1, 0.5]], [[2, 3, 0.9]], [[3, 3, 0.6], [3, 3, 0.3, 1]], [[1, 1, 0, 2]]]],
		[0.5, 0.4, [[[0, 1, 0.8], [2, 2, 0.4], [2, 2, 0.26, 1]], [[3, 3, 0, 2], [1, 1, 0.35]], [[2, 2, 1.1], [0, 0, 0.3]]]],
		[0.4, 0.35, [[[1, 0, 0.8], [3, 3, 0.3], [3, 3, 0.24, 1]], [[0, 0, 0, 2], [0, 0, 0.26, 1], [2, 3, 0.7]], [[2, 2, 0.4], [1, 1, 0.4], [3, 3, 0, 2]]]],
	],
]
## 튜토리얼 공격: 왼쪽(막기 연습), 위(간파 연습)
const TUT_MV := [[0, 0, 1.2], [2, 2, 1.4]]
const TUT_SAY := [
	"칼이 왼쪽에서 와요 (흐린 칼 = 지나갈 길)\n[막기]를 누른 채 왼쪽으로 밀어요!",
	"막았어요!\n초록 상자 = 빈틈. [베기]를 누른 채 오른쪽으로!",
	"끝까지 기다렸다 막으면 '간파'!\n[막기]를 누른 채 위로!",
	"간파: 세상이 느려지고 빈틈이 길어요.\n[베기]를 누른 채 아래로!",
]
const ACT := ["막기", "베기"]
## 검객을 쓰러뜨리면 고르는 능력 (이번 판에만): 키, 이름, 설명, 최대 단계. 상점·돈은 없앴다(10/31).
const PERKS := [
	["hp", "단단한 몸", "최대 체력 +4 (지금 체력도 +4)", 99],
	["pow", "날 선 칼", "베기 힘 +1", 99],
	["per", "맑은 눈", "간파 판정이 0.04초 넓어져요", 4],
	["mend", "상처 동여매기", "체력을 절반만큼 되찾아요", 99],
	["leech", "숨 고르기", "간파할 때마다 체력 +1", 3],
	["steady", "흔들림 없는 손", "헛공격해도 체력이 안 깎여요", 1],
	["gap", "긴 빈틈", "빈틈(초록)이 30% 더 오래 열려요", 3],
]

## 아래 탭 줄: 칸 i 는 탭 i + 1 (탭 0 업그레이드는 없앴다)
const TABS := ["전투", "캐릭터", "도감"]
const DEX := ["찌르기", "속임수", "베기", "거합", "검귀"]
const NAV_Y := 1150.0

# 저장되는 것
var tut_done := false
var seen := [0, 0, 0, 0, 0]  # 도감: 종류별 만난 수
var kills := [0, 0, 0, 0, 0]
var runs := 0
var blocks := 0
var perfects := 0
var best_n := 0
var best_dmg := 0  # 끝판왕에게 준 가장 큰 피해
var vol := 8  # 설정: 소리 0~10
var vib := 8  # 설정: 진동 0~10
# 한 판
var tut := 0  # 0~3 튜토리얼 단계, 4 끝 카드, -1 실전
var hold := false  # 튜토리얼: 맞는 손짓을 할 때까지 멈춤
var n := 0  # 몇 번째 검객 (0부터)
var ftype := 0
var foe_max := 6
var foe_hp := 6
var foe_atk := 2
var spd := 1.0
var life := 6
var max_life := 6
var perk := {}  # 이번 판에 고른 능력 -> 단계
var pick: Array = []  # 고르는 중인 능력 셋 (PERKS 번호)
var boss_dmg := 0
var cuts := 0  # 끝판왕: 벤 횟수 (단 오르기)
# 장면
var piv: Node3D
var body: MeshInstance3D
var blade_m: MeshInstance3D
var eyes: Array[MeshInstance3D] = []
var hp_fill: MeshInstance3D
var hp_back: MeshInstance3D
var floor_m: MeshInstance3D
var mark: Node3D
var ind: Array[Node3D] = []  # 빈틈 표시: 검은 테두리 + 초록 면
var ghosts: Array[MeshInstance3D] = []  # 적 칼이 지나갈 길 (흐린 잔상 셋 + 두 번째 칼)
var blade_rest := Vector3(0.95, -0.3, 0.6)
var blade_rr := Vector3(0, 0, 0.5)
var stance := -1  # 내가 밀어서 잡은 칼 방향 (-1 = 아직)
var stance_l: Label
var rig: Node3D
var sword: MeshInstance3D
var my_col := WHITE
var cam_base := Vector3.ZERO
# 결투
var mode := "intro"
var mode_t := 0.0
var ph := 0
var ci := 0
var mi := 0
var fs := 0  # 0 쉼, 1 예비 동작, 2 빈틈, 3 내가 맞음, 4 상대 휘청, 5 연격 사이 텀(흰→노랑)
var beat := 0.3  # 연격 사이 텀 길이
var fs_t := 0.0
var gap := 0.5
var win := 0.5
var rdir := 0
var sdir := 0
var odir := 0
## 연속기마다 방향을 섞는다(10/31): 패턴(박자·몇 번·속임수·같은 쪽 두 번)은 그대로, 쪽만 무작위로 바꿔 끼운다
var dmap := [0, 1, 2, 3]
var feint_at := -1.0
var feinting := false  # 이번 칼이 방향을 바꾸는 속임수인가 (속임수 칼만 흔들린다)
var show_at := 0.0  # 거합: 이때부터 빨간 상자가 보인다
var tell_at := -1.0  # 거합: 이때 눈이 번쩍 (이보다 먼저 휘두르면 헛공격)
var told := true
var shown := true
var stun := 0.0  # 헛공격 뒤 굳은 시간
var whiff_t := 0.0
var fl := Vector3.ZERO
var slow := 0.0
var gp := false  # 지금 빈틈이 간파로 연 것인가 (헛공격하면 피해 없이 간파만 끝남)
var sw_t := 0.0
var flash_t := 0.0
var hurt_t := 0.0
var shake_t := 0.0
var blink := 0.0
var start := Vector2.ZERO
var armed := false
var pend := {}  # 눌렀지만 아직 발동 안 한 버튼 -> 누른 시간
var sty := 0  # 이번 공격 모양 (위 T_WIND 설명)
var hitstop := 0.0  # 막은 순간 화면이 멈추는 시간
var sparks: Array = []  # 불꽃: [상자, 속도, 남은 시간, 처음 시간]
var going := false  # 로비 버튼 누름 애니메이션 끝나고 출발하는 중
var link := false  # 연격: 지금 칼 뒤에 다음 칼이 이미 오고 있다 (노랑)
var link_at := -1.0  # 연격 칼(노랑)이 이때부터 보인다 (처음엔 흰 칼 하나만, 10/31)
var link_b: MeshInstance3D  # 연격 칼 (노랑)
var link_g: Array[MeshInstance3D] = []  # 연격 칼이 지나갈 길 (노랑 잔상)
var sfx_p: Array[AudioStreamPlayer] = []  # 효과음 전용 줄 (삑 소리에 밀려 끊기지 않게)
var sfx_i := 0
# 화면 글자
var info_l: Label
var tut_box: ColorRect
var tut_l: Label
var skip_l: Label
# 로비 (쓰러진 뒤, 다시 켤 때)
var lobby: Control
var tab := 1
var pages: Array[Control] = []
var nav_bg: Array[ColorRect] = []
var nav_l: Array[Label] = []
var top_l: Label
var home_l: Label
var pick_box: ColorRect  # 능력 고르기 창
var pick_head: Label
var pick_bg: Array[ColorRect] = []
var pick_l: Array[Label] = []
var play_bg: ColorRect
var play_edge: ColorRect
var tut_again: Label
var char_l: Label
var dex_bg: Array[ColorRect] = []
var dex_l: Array[Label] = []
var dex_card: Label
var dex_pick := 0
var last_run := ""
var lobby_k := 0  # 전투 탭 뒤에 서 있는 검객 (마지막에 진 상대)
var set_box: ColorRect  # 설정 창 (로비 위 [설정])
var set_btn: ColorRect
var set_fill: Array[ColorRect] = []
var set_val: Array[Label] = []

const SKIP_R := Rect2(470, 296, 250, 90)
const GUARD_P := Vector2(185, 1150)
const CUT_P := Vector2(535, 1150)
const BTN_R := 105.0
const PLAY_R := Rect2(110, 880, 500, 150)
const TUT_R := Rect2(200, 1050, 320, 80)
const SET_R := Rect2(586, 118, 124, 68)
const SET_CLOSE := Rect2(210, 860, 300, 100)


## 설정 창 줄 i(0 소리, 1 진동)의 [-] [+] 칸
func _set_r(i: int, plus: bool) -> Rect2:
	return Rect2(570 if plus else 70, 470 + i * 200, 90, 90)


## 능력 고르기 카드 i (0~2)
func _pick_r(i: int) -> Rect2:
	return Rect2(40, 330 + i * 230, 640, 200)


func _tab_r(i: int) -> Rect2:
	return Rect2(i * 240, NAV_Y, 240, 1280 - NAV_Y)


func _dex_r(i: int) -> Rect2:
	return Rect2(16 + i * 139, 210, 131, 84)


# ---- 저장 ----
func _load_save() -> void:
	if not FileAccess.file_exists(FILE):
		return
	var f := FileAccess.open(FILE, FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if not d is Dictionary:
		return
	tut_done = bool(d.get("tut", false))
	runs = int(d.get("runs", 0))
	blocks = int(d.get("blocks", 0))
	perfects = int(d.get("perfects", 0))
	for key in ["seen", "kills"]:
		var a: Variant = d.get(key, [])
		if a is Array:
			for i in mini(a.size(), 5):
				(seen if key == "seen" else kills)[i] = int(a[i])
	best_n = int(d.get("best", 0))
	best_dmg = int(d.get("dmg", 0))
	vol = clampi(int(d.get("vol", 8)), 0, 10)
	vib = clampi(int(d.get("vib", 8)), 0, 10)


func _save() -> void:
	var f := FileAccess.open(FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"best": best_n, "dmg": best_dmg, "tut": tut_done, "runs": runs, "blocks": blocks, "perfects": perfects, "seen": seen, "kills": kills, "vol": vol, "vib": vib}))


# ---- 능력치 ----
func _lv(k: String) -> int:
	return int(perk.get(k, 0))


func _pow() -> int:
	return 1 + _lv("pow")


## 간파 판정: 칼이 닿기 전 이 시간 안에 막으면 간파. 기본은 좁게(10/31: 0.20 → 0.15), 능력 "맑은 눈"은 한 번에 크게 (+0.04, 다 골라도 0.31초)
func _per() -> float:
	return 0.15 + 0.04 * _lv("per")


# ---- 화면 글자 ----
func _setup() -> void:
	howto = ""
	time_limit = 0.0
	_load_save()
	_apply_vol()
	for i in 4:
		var ap := AudioStreamPlayer.new()
		ap.stream = SND["whiff"] if i % 2 == 0 else SND["miss"]
		add_child(ap)
		sfx_p.append(ap)
	var hud := CanvasLayer.new()
	hud.layer = 2
	add_child(hud)
	info_l = _label(hud, 34, 236, 60)
	stance_l = _label(hud, 32, 1012, 50)
	_buttons()
	# 튜토리얼 안내 (아래쪽 띠, 깜빡임)
	var tl := CanvasLayer.new()
	tl.layer = 3
	add_child(tl)
	tut_box = ColorRect.new()
	tut_box.color = Color(0.1, 0.07, 0.04, 0.82)
	tut_box.position = Vector2(0, 740)
	tut_box.size = Vector2(720, 270)
	tut_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tl.add_child(tut_box)
	tut_l = _label(tut_box, 36, 0, 270)
	tut_l.label_settings.font_color = WHITE
	tut_l.label_settings.outline_color = INK
	tut_l.label_settings.line_spacing = 6
	tut_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tut_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tut_l.position.x = 20
	tut_l.size.x = 680
	skip_l = _label(tl, 32, 310, 60)
	skip_l.text = "건너뛰기 >"
	skip_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip_l.size.x = 696
	_lobby_ui()


func _panel(parent: Node, r: Rect2, c: Color) -> ColorRect:
	var bg := ColorRect.new()
	bg.color = c
	bg.position = r.position
	bg.size = r.size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	return bg


func _white(l: Label) -> Label:
	l.label_settings.font_color = WHITE
	l.label_settings.outline_color = INK
	return l


## 로비: 위 기록 띠, 가운데 탭 화면, 아래 탭 줄(전투 · 캐릭터 · 도감)
func _lobby_ui() -> void:
	var sl := CanvasLayer.new()
	sl.layer = 4
	add_child(sl)
	lobby = Control.new()
	lobby.size = Vector2(720, 1280)
	lobby.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lobby.visible = false
	sl.add_child(lobby)
	var top := _panel(lobby, Rect2(0, 110, 720, 84), Color(0.12, 0.08, 0.05, 0.85))
	top_l = _white(_label(top, 38, 0, 84))
	top_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_l.size.x = 580  # 오른쪽은 [설정] 자리
	for i in 4:
		var pg := Control.new()
		pg.size = Vector2(720, 1280)
		pg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lobby.add_child(pg)
		pages.append(pg)
	# 0 업그레이드: 없앴다 (빈 쪽). 능력은 싸우다 검객을 쓰러뜨리면 고른다
	# 1 전투 (뒤에 검객이 서 있다)
	var title := _label(pages[1], 72, 210, 100)
	title.text = "일격의 길"
	var card := _panel(pages[1], Rect2(60, 320, 600, 150), Color(0.12, 0.08, 0.05, 0.7))
	home_l = _white(_label(card, 30, 0, 150))
	home_l.size.x = 600
	home_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	play_edge = _panel(pages[1], Rect2(PLAY_R.position + Vector2(-8, -8), PLAY_R.size + Vector2(16, 24)), INK)
	play_bg = _panel(pages[1], PLAY_R, D)
	var pl := _label(play_bg, 80, 0, PLAY_R.size.y)
	pl.size.x = PLAY_R.size.x
	pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pl.text = "전투"
	tut_again = _label(pages[1], 30, TUT_R.position.y, TUT_R.size.y)
	tut_again.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tut_again.text = "튜토리얼 다시 보기"
	# 2 캐릭터: 상자 검객 그림 + 능력치 + 기록
	_panel(pages[2], Rect2(0, 194, 720, NAV_Y - 194), Color(0.12, 0.08, 0.05, 0.8))
	var fig := Control.new()
	fig.position = Vector2(310, 220)
	fig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pages[2].add_child(fig)
	var sw := _panel(fig, Rect2(118, -10, 16, 190), WHITE)
	sw.rotation = 0.5
	_panel(fig, Rect2(10, 40, 60, 56), Color("3b2a20"))
	_panel(fig, Rect2(-6, 26, 92, 20), INK)
	_panel(fig, Rect2(-10, 96, 100, 120), ME)
	_panel(fig, Rect2(-10, 150, 100, 14), INK)
	_panel(fig, Rect2(4, 216, 30, 44), INK)
	_panel(fig, Rect2(46, 216, 30, 44), INK)
	_panel(fig, Rect2(90, 120, 40, 26), ME)
	char_l = _white(_label(pages[2], 32, 500, 640))
	char_l.label_settings.line_spacing = 4
	# 3 도감: 위 칩 다섯, 가운데 검객(3D), 아래 설명 카드
	for i in 5:
		var bg := _panel(pages[3], _dex_r(i), SOFT)
		dex_bg.append(bg)
		var l := _label(bg, 30, 0, 84)
		l.size.x = 131
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.label_settings.outline_size = 0
		dex_l.append(l)
	var dc := _panel(pages[3], Rect2(30, 860, 660, 270), Color(0.12, 0.08, 0.05, 0.8))
	dex_card = _white(_label(dc, 30, 0, 270))
	dex_card.size.x = 660
	dex_card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dex_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# 아래 탭 줄
	_panel(lobby, Rect2(0, NAV_Y, 720, 1280 - NAV_Y), INK)
	for i in TABS.size():
		var r := _tab_r(i)
		var bg := _panel(lobby, r.grow(-4), Color("5a4632"))
		nav_bg.append(bg)
		var l := _white(_label(bg, 32, 0, r.size.y - 8))
		l.size.x = r.size.x - 8
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.text = TABS[i]
		nav_l.append(l)
	# 위 띠 오른쪽 [설정] → 소리·진동 창
	set_btn = _panel(lobby, SET_R, Color("5a4632"))
	var sl2 := _white(_label(set_btn, 30, 0, SET_R.size.y))
	sl2.size.x = SET_R.size.x
	sl2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sl2.text = "설정"
	set_box = _panel(lobby, Rect2(0, 194, 720, NAV_Y - 194), Color(0.08, 0.05, 0.03, 0.94))
	set_box.visible = false
	var st := _white(_label(set_box, 48, 120, 90))
	st.text = "설정"
	for i in 2:
		var y := 470.0 + i * 200.0 - 194.0
		var nm := _white(_label(set_box, 34, y - 70, 60))
		nm.text = ["소리 크기", "진동 세기"][i]
		for plus in [false, true]:
			var r := _set_r(i, plus)
			var b := _panel(set_box, Rect2(r.position - Vector2(0, 194), r.size), D)
			var bl2 := _label(b, 56, 0, r.size.y)
			bl2.size.x = r.size.x
			bl2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			bl2.label_settings.outline_size = 0
			bl2.text = "+" if plus else "-"
		var back := _panel(set_box, Rect2(180, y + 25, 360, 40), SOFT)
		var fill := _panel(back, Rect2(0, 0, 360, 40), GOOD)
		set_fill.append(fill)
		var v := _white(_label(set_box, 30, y + 92, 50))
		set_val.append(v)
	var close := _panel(set_box, Rect2(SET_CLOSE.position - Vector2(0, 194), SET_CLOSE.size), Color("5a4632"))
	var cl := _white(_label(close, 38, 0, SET_CLOSE.size.y))
	cl.size.x = SET_CLOSE.size.x
	cl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cl.text = "닫기"
	var sh := _white(_label(set_box, 28, 1010 - 194, 80))
	sh.text = "진동은 안드로이드 폰에서만 울려요
0이면 꺼져요"
	# 검객을 쓰러뜨리면 뜨는 능력 고르기 (카드 셋)
	var pl2 := CanvasLayer.new()
	pl2.layer = 5
	add_child(pl2)
	pick_box = _panel(pl2, Rect2(0, 0, 720, 1280), Color(0.08, 0.05, 0.03, 0.82))
	pick_box.visible = false
	pick_head = _white(_label(pick_box, 44, 170, 140))
	pick_head.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for i in 3:
		var r := _pick_r(i)
		var edge := _panel(pick_box, r.grow(6), INK)
		var bg := _panel(edge, Rect2(Vector2(6, 6), r.size), D)
		pick_bg.append(edge)
		var l := _label(bg, 34, 0, r.size.y)
		l.size.x = r.size.x
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.label_settings.outline_size = 0
		pick_l.append(l)


## 설정 창 글자·막대
func _set_refresh() -> void:
	for i in 2:
		var v: int = vol if i == 0 else vib
		set_fill[i].size.x = 360.0 * v / 10.0
		set_val[i].text = "끔" if v == 0 else "%d%%" % (v * 10)


## 소리 크기: 전체 소리 길(버스)에 건다
func _apply_vol() -> void:
	AudioServer.set_bus_mute(0, vol == 0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(vol, 1) / 10.0))


## 진동: 설정 세기만큼 길이·세기를 줄인다. 0이면 안 울린다
func _buzz(ms: int, amp: float) -> void:
	if vib == 0:
		return
	var k := vib / 10.0
	Input.vibrate_handheld(maxi(10, int(ms * (0.4 + 0.6 * k))), clampf(amp * k, 0.05, 1.0))


## 막기·베기 버튼 (여러 손가락: 한 손가락으로 밀면서 다른 손가락으로 누른다). 상점에서는 뺀다.
func _buttons() -> void:
	kit_button("guard", "막기", GUARD_P, BTN_R, B)
	kit_button("cut", "베기", CUT_P, BTN_R, A)


func _lobby_refresh() -> void:
	top_l.text = "최고 %d명 쓰러뜨림" % best_n
	for i in 4:
		pages[i].visible = i == tab
	for i in TABS.size():
		nav_bg[i].color = D if i + 1 == tab else Color("5a4632")
		nav_l[i].label_settings.font_size = 36 if i + 1 == tab else 30
	match tab:
		1:
			var h := last_run if last_run != "" else "매 판 맨몸으로 시작해요\n검객을 쓰러뜨릴 때마다 능력을 하나 골라요"
			if best_dmg > 0:
				h += "\n끝판왕 최고 피해 %d" % best_dmg
			home_l.text = h
		2:
			char_l.text = "나 · 떠돌이 검객\n\n체력 6 · 베기 힘 1 · 간파 0.20초\n(판마다 맨몸으로 시작,\n검객을 쓰러뜨리면 능력을 골라요)\n\n— 기록 —\n최고 %d명 쓰러뜨림 · 끝판왕 최고 피해 %d\n싸운 판 %d · 막기 %d · 간파 %d" % [
				best_n, best_dmg, runs, blocks, perfects]
		3:
			for i in 5:
				dex_l[i].text = DEX[i] if seen[i] > 0 else "???"
				dex_bg[i].color = D if i == dex_pick else (SOFT if seen[i] > 0 else Color("8a7a66"))
			var i := dex_pick
			if seen[i] == 0:
				dex_card.text = "???\n아직 못 만났어요\n싸우다 보면 열려요"
			else:
				var rec := "만남 %d번 · 쓰러뜨림 %d번" % [seen[i], kills[i]] if i < 4 else "만남 %d번 · 준 피해 최고 %d" % [seen[i], best_dmg]
				dex_card.text = "%s\n%s\n%s" % [NAMES[i], TIPS[i].replace("\n", " "), rec]


## 로비로 (t = 탭). 막기·베기 버튼은 뺀다.
func _to_lobby(t: int) -> void:
	mode = "lobby"
	tut = -1
	hold = false
	_btns.clear()
	pend.clear()
	tut_box.visible = false
	skip_l.visible = false
	lobby.visible = true
	set_box.visible = false
	slow = 0.0
	stun = 0.0
	floor_m.material_override = mat(SOFT)
	_set_tab(t)


func _set_tab(t: int) -> void:
	tab = t
	# 전투 탭 = 마지막 상대, 도감 = 고른 검객(못 만났으면 검은 그림자)
	if t == 3:
		_spawn(BOSS_AT if dex_pick == 4 else dex_pick)
		if seen[dex_pick] == 0:
			for c in piv.get_children():
				if c is MeshInstance3D:
					c.material_override = mat(INK)
	else:
		_spawn(lobby_k)
	_clear()
	hp_back.visible = false
	hp_fill.visible = false
	fl = Vector3.ZERO
	piv.rotation = Vector3.ZERO
	_lobby_refresh()


# ---- 판 ----
func _reset() -> void:
	_scenery()
	mark = Node3D.new()
	world.add_child(mark)
	ind.clear()
	for i in 4:
		var g := Node3D.new()
		g.position = OFF[i]
		g.visible = false
		mark.add_child(g)
		box(Vector3.ZERO, Vector3(0.82, 0.82, 0.06), Color.BLACK, g)
		box(Vector3(0, 0, 0.04), Vector3(0.6, 0.6, 0.06), GOOD, g)
		ind.append(g)
	rig = Node3D.new()
	world.add_child(rig)
	sword = box(REST_P, Vector3(0.12, 1.7, 0.12), WHITE, rig)
	sword.rotation.z = REST_R
	sword.visible = false  # 1인칭 칼 없음 (눈앞 칼이 막은 것처럼 보여 헷갈렸다)
	cam_base = CAM_O
	cam.position = cam_base
	cam.look_at(Vector3.ZERO)
	score = n
	slow = 0.0
	sw_t = 0.0
	flash_t = 0.0
	hurt_t = 0.0
	shake_t = 0.0
	armed = false
	stun = 0.0
	whiff_t = 0.0
	stance = -1
	if tut_done:
		_to_lobby(1)
		return
	_begin_tut()


## 처음 켜면(또는 로비에서 다시 보기) 튜토리얼
func _begin_tut() -> void:
	going = false
	lobby.visible = false
	tut_box.visible = true
	skip_l.visible = true
	_buttons()
	pend.clear()
	stance = -1
	tut = 0
	hold = false
	n = 0
	spd = 1.0
	foe_atk = 0
	_spawn(0)
	foe_max = 99
	foe_hp = 99
	hp_back.visible = false
	hp_fill.visible = false
	_intro()
	msg("일격의 길", 1.4)
	tut_l.text = "검객이 공격하려고 해요. 잘 봐요!"


func _scenery() -> void:
	floor_m = box(Vector3(0, -1.9, -1), Vector3(8, 0.3, 8), SOFT)
	for s in [-1.0, 1.0]:
		box(Vector3(s * 2.8, 0.2, -3.5), Vector3(0.35, 4.2, 0.35), BAD)
	box(Vector3(0, 2.4, -3.5), Vector3(7.0, 0.35, 0.5), BAD)
	box(Vector3(0, 1.8, -3.5), Vector3(6.0, 0.2, 0.3), INK)
	box(Vector3(0, -5.1, 0), Vector3(24, 6, 24), FIELD)
	_reeds()
	if Look.ON:
		Look.stage(self)
	for m: Vector3 in [Vector3(-12, 6, -45), Vector3(6, 10, -52), Vector3(20, 4, -42)]:
		box(m, Vector3(16, m.y * 2.0 + 6.0, 4), B)
		box(m + Vector3(0, m.y + 3.0, 0.2), Vector3(6, 2, 4), WHITE)


## 갈대밭: 가운데 싸우는 자리는 비우고, 옅은 색 가는 줄기 + 이삭만. 칼 상자(빨강·초록)보다 눈에 안 띄게.
func _reeds() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	# 외곽선 없는 재질: 가는 줄기에 검은 테두리가 붙으면 오히려 어지럽다
	var stalk := StandardMaterial3D.new()
	stalk.albedo_color = REED
	var plume := StandardMaterial3D.new()
	plume.albedo_color = PLUME
	var placed := 0
	while placed < 110:
		var x := rng.randf_range(-11.0, 11.0)
		var z := rng.randf_range(-14.0, 1.5)
		if absf(x) < 3.4 and z > -5.0:
			continue
		placed += 1
		var h := rng.randf_range(1.2, 2.4)
		var r := Node3D.new()
		r.position = Vector3(x, -2.1, z)
		r.rotation.z = rng.randf_range(-0.18, 0.18)
		world.add_child(r)
		box(Vector3(0, h * 0.5, 0), Vector3(0.06, h, 0.06), REED, r).material_override = stalk
		box(Vector3(0, h + 0.2, 0), Vector3(0.14, 0.4, 0.14), PLUME, r).material_override = plume


## n번째 검객을 만든다. 종류는 번갈아, 뒤로 갈수록 몸이 어둡고 머리 위 금장식이 늘어난다.
func _spawn(k: int) -> void:
	if piv:
		piv.queue_free()
	ftype = 4 if k >= BOSS_AT else k % 4
	var col: Color = BODY[ftype]
	if ftype < 4:
		col = col.lerp(INK, minf(0.6, floorf(k / 4.0) * 0.3))
	piv = Node3D.new()
	world.add_child(piv)
	eyes.clear()
	blade_rest = Vector3(0.95, -0.3, 0.6)
	blade_rr = Vector3(0, 0, 0.5)
	var hp_y := 2.0
	var eye_y := 0.6
	var eye_z := 0.6 if ftype == 4 else 0.5
	var top := 1.5
	if Look.ON and ftype < 4:
		# 설정화 모양 (g/look.gd, 끄려면 거기서 ON = false)
		var lk := Look.dress(self, ftype, minf(0.6, floorf(k / 4.0) * 0.3), piv)
		body = lk.body
		eye_y = lk.eye_y
		eye_z = lk.eye_z
		top = lk.top
		hp_y = lk.hp_y
		if ftype == 3:
			blade_rest = Vector3(0.7, -0.55, 0.45)
			blade_rr = Vector3(PI / 2, 0, 0)
	else:
		_dress_box(col)
		if ftype == 4:
			hp_y = 2.9
			eye_y = 0.95
	body.set_meta("col", (body.material_override as StandardMaterial3D).albedo_color)
	if ftype < 4:
		for i in mini(k / 2, 5):
			box(Vector3((i - (mini(k / 2, 5) - 1) * 0.5) * 0.36, top, 0), Vector3(0.22, 0.3, 0.22), D, piv)
	for s in [-1.0, 1.0]:
		eyes.append(box(Vector3(s * 0.33 * (0.75 if Look.ON and ftype < 4 else 1.0), eye_y, eye_z), Vector3(0.24, 0.24, 0.06) * (0.75 if Look.ON and ftype < 4 else 1.0), INK, piv))
	_spawn_rest(k, hp_y)


## 예전 상자 검객 몸
func _dress_box(col: Color) -> void:
	match ftype:
		0:
			body = box(Vector3.ZERO, Vector3(1.4, 2.8, 0.9), col, piv)
			box(Vector3(0, 0.95, 0), Vector3(1.45, 0.18, 0.95), BAD, piv)
		1:
			body = box(Vector3(0, -0.25, 0), Vector3(2.0, 2.3, 1.0), col, piv)
			box(Vector3(0, 1.0, 0), Vector3(2.8, 0.18, 1.8), D, piv)
			box(Vector3(0, 1.2, 0), Vector3(1.0, 0.25, 0.8), D, piv)
		2:
			# 베기: 넓은 어깨, 긴 칼
			body = box(Vector3.ZERO, Vector3(1.6, 2.7, 1.0), col, piv)
			for s in [-1.0, 1.0]:
				box(Vector3(s * 1.0, 0.95, 0), Vector3(0.6, 0.3, 1.1), INK, piv)
		3:
			# 거합: 마르고 칼은 허리춤 칼집에
			body = box(Vector3(0, -0.1, 0), Vector3(1.1, 2.9, 0.8), col, piv)
			box(Vector3(0, 0.85, 0), Vector3(1.6, 0.12, 1.2), INK, piv)
			box(Vector3(0.7, -0.55, 0.15), Vector3(0.18, 0.18, 1.3), INK, piv)
			blade_rest = Vector3(0.7, -0.55, 0.45)
			blade_rr = Vector3(PI / 2, 0, 0)  # 칼집 안에 눕혀 둠
		4:
			# 끝판왕: 크고 검다, 붉은 눈, 금관
			body = box(Vector3(0, 0.1, 0), Vector3(2.4, 3.4, 1.2), col, piv)
			box(Vector3(0, 1.95, 0), Vector3(1.6, 0.4, 1.0), D, piv)
			for s in [-1.0, 0.0, 1.0]:
				box(Vector3(s * 0.55, 2.3, 0), Vector3(0.25, 0.4 if s == 0.0 else 0.28, 0.25), D, piv)


func _spawn_rest(k: int, hp_y: float) -> void:
	# 칼은 세로로 긴 막대: 좌우 공격은 세운 칼, 위아래 공격은 눕힌 칼로 보인다
	blade_m = box(blade_rest, Vector3(0.16, 2.0 if ftype == 2 else 1.7, 0.16), WHITE, piv)
	blade_m.rotation = blade_rr
	ghosts.clear()
	for i in 4:
		var gm := StandardMaterial3D.new()
		gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		gm.albedo_color = Color(1, 1, 1, [0.22, 0.34, 0.5, 0.5][i])
		var gh := box(Vector3.ZERO, blade_m.scale, WHITE, piv)
		gh.material_override = gm
		gh.visible = false
		ghosts.append(gh)
	link_b = box(Vector3.ZERO, blade_m.scale, D, piv)
	link_b.visible = false
	link_g.clear()
	for i in 3:
		var om := StandardMaterial3D.new()
		om.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		om.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		om.albedo_color = Color(D, [0.25, 0.38, 0.55][i])
		var og := box(Vector3.ZERO, blade_m.scale, A, piv)
		og.material_override = om
		og.visible = false
		link_g.append(og)
	link = false
	hp_back = box(Vector3(0, hp_y, 0), Vector3(2.0, 0.22, 0.2), INK, piv)
	hp_fill = box(Vector3(0, hp_y, 0.08), Vector3(1.9, 0.16, 0.16), BAD, piv)
	foe_max = BOSS_HP if ftype == 4 else 6 + 4 * k
	foe_hp = foe_max
	foe_atk = 2 + k
	spd = maxf(0.55, 1.0 - 0.05 * k)
	boss_dmg = 0
	cuts = 0
	ph = 0
	_eyes()
	_hp_bar()


func _eyes() -> void:
	var c := BAD if ph == 2 or ftype == 4 else INK
	for e in eyes:
		e.material_override = mat(c)


func _hp_bar() -> void:
	var f := clampf(float(foe_hp) / float(foe_max), 0.0, 1.0)
	hp_fill.scale.x = maxf(0.001, 1.9 * f)
	hp_fill.position.x = -0.95 + 0.95 * f


func _intro() -> void:
	ph = 0
	ci = 0
	mi = 0
	fs = 0
	fs_t = 0.0
	fl = Vector3.ZERO
	mode = "intro"
	mode_t = 1.6
	piv.rotation = Vector3.ZERO
	if tut < 0:
		seen[ftype] += 1
		mode_t = 2.6
		var hp_s := "∞" if ftype == 4 else str(foe_max)
		# 상대가 누구인지는 글로 알려 주지 않는다 (로비 도감에서만)
		msg("%d번째 상대\n체력 %s · 공격 %d" % [n + 1, hp_s, foe_atk], 2.0)


func _start_run() -> void:
	going = false
	tut = -1
	hold = false
	lobby.visible = false
	tut_box.visible = false
	tut_done = true
	runs += 1
	_save()
	skip_l.visible = false
	n = 0
	max_life = 6
	perk = {}
	life = max_life
	stun = 0.0
	my_col = WHITE
	sword.material_override = mat(my_col)
	sword.visible = false
	pend.clear()
	slow = 0.0
	floor_m.material_override = mat(SOFT)
	_spawn(0)
	_clear()
	stance = -1
	_buttons()
	fl = Vector3(0, 0, -10)
	mode = "enter"
	mode_t = 1.0
	play("tap")


func _pat() -> Array:
	return PAT[ftype][ph]


## 빈틈 상자 (내가 벨 쪽). -1 이면 숨김
func _show(d: int) -> void:
	for i in 4:
		ind[i].visible = i == d
	if d >= 0:
		ind[d].scale = Vector3.ONE


## 적 칼이 d 쪽에서 올 길: 흐린 잔상 셋(멀리서 가까이), twice 면 들어 올린 칼 옆에 두 번째 칼. -1 이면 숨김
func _path(d: int, twice := false) -> void:
	for i in 4:
		ghosts[i].visible = d >= 0 and (i < 3 or twice)
	if d < 0:
		return
	for i in 3:
		var t: float = [0.35, 0.68, 1.0][i]
		ghosts[i].position = _bpos(d, t)
		ghosts[i].rotation = _brot(d, t)
	ghosts[3].position = _bpos(d, 0.0) + (Vector3(0.38, 0, -0.1) if d < 2 else Vector3(0, 0.38, -0.1)) * (-1.0 if d == 1 else 1.0)
	ghosts[3].rotation = _brot(d, 0.0)


## 적 칼 자리: d 쪽 공격, t 0 = 들어 올린 자리 ~ 1 = 내게 닿는 자리. 모양(sty)마다 길이 다르다.
func _bpos(d: int, t: float) -> Vector3:
	match sty:
		0:
			return (T_WIND[d] as Vector3).lerp(T_HIT[d], t)
		2:
			# 크게 젖힌 자리에서 바깥으로 둥글게 돌아 내려온다
			var a: Vector3 = WIND[d] * 1.25 + Vector3(0, 0.35, -0.5)
			var h: Vector3 = HIT[d]
			var mid: Vector3 = (a + h) * 0.5 + LEAN[d] * 0.9 + Vector3(0, 0, 0.3)
			return a.lerp(mid, t).lerp(mid.lerp(h, t), t)
	return (WIND[d] as Vector3).lerp(HIT[d], t)


func _brot(d: int, t: float) -> Vector3:
	match sty:
		0:
			# 칼(긴 쪽)이 찌르는 방향을 향한다
			var dir: Vector3 = (T_HIT[d] - T_WIND[d]).normalized()
			return Basis(Quaternion(Vector3.UP, dir)).get_euler()
		2:
			return Vector3(0, 0, ROT[d] + SWING[d] * lerpf(1.1, -0.35, t))
	return Vector3(0, 0, ROT[d])


## 이 수의 공격 모양: 검객 성향대로. 끝판왕은 수에 맞춰 넷을 섞는다.
func _style(mv: Array) -> int:
	if ftype < 4:
		return ftype
	if _flag(mv) == 2:
		return 3
	if _flag(mv) == 1 or _twice_next():
		return 2
	if int(mv[0]) != int(mv[1]):
		return 1
	return 0 if (ci + mi) % 2 == 0 else 2


func _clear() -> void:
	_show(-1)
	_path(-1)
	_link_show(false)


## 연격이 오는가: 2단부터(끝판왕은 늘) 연속기의 다음 칼이 이번 칼과 겹쳐 온다. 베기 검객의 두 번째 칼·거합은 빼고
func _link_next() -> bool:
	if tut >= 0 or (ph < 1 and ftype != 4):
		return false
	var c: Array = _pat()[2][ci]
	if mi + 1 >= c.size() or _flag(c[mi]) == 2:
		return false
	return _flag(c[mi + 1]) == 0


## 연격 칼(노랑)을 다음 칼 쪽에 들어 올려 두고 주황 잔상으로 길을 보여 준다. false 면 숨김
func _link_show(on: bool) -> void:
	link = on
	if link_b == null:
		return
	link_b.visible = on
	for g in link_g:
		g.visible = on
	if not on:
		return
	var nx: Array = _pat()[2][ci][mi + 1]
	var d: int = dmap[nx[0]]
	var keep := sty
	mi += 1
	sty = _style(nx)
	mi -= 1
	for i in 3:
		var t: float = [0.35, 0.68, 1.0][i]
		link_g[i].position = _bpos(d, t)
		link_g[i].rotation = _brot(d, t)
	link_b.position = _bpos(d, 0.0)
	link_b.rotation = _brot(d, 0.0)
	sty = keep


func _rest(g: float) -> void:
	blade_m.material_override = mat(WHITE)
	fs = 0
	fs_t = 0.0
	gap = g * spd
	_clear()


func _relax(dt: float) -> void:
	fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 10.0))
	piv.rotation.z = lerpf(piv.rotation.z, 0.0, minf(1.0, dt * 10.0))
	blade_m.position = blade_m.position.lerp(blade_rest, minf(1.0, dt * 10.0))
	blade_m.rotation = blade_m.rotation.lerp(blade_rr, minf(1.0, dt * 10.0))


func _step(dt: float) -> void:
	score = n
	# 막은 순간 잠깐 멈춤 (불꽃은 그 자리에 멈춰 보였다가 튄다)
	if hitstop > 0.0:
		hitstop -= dt
		return
	_sparks(dt)
	var fdt := dt
	if slow > 0.0:
		slow -= dt
		fdt = dt * SLOW
		if slow <= 0.0:
			floor_m.material_override = mat(SOFT)
	if stun > 0.0:
		stun -= dt
	if whiff_t > 0.0:
		whiff_t -= dt
		if whiff_t <= 0.0:
			floor_m.material_override = mat(B if slow > 0.0 else SOFT)
	mode_t -= dt
	# 버튼: 누르고 밀면 _btn_drag 에서 바로, 안 밀고 떼거나 잠깐 누르고 있으면 잡아 둔 방향으로
	for k in ["guard", "cut"]:
		if pend.has(k):
			pend[k] += dt
			if pend[k] >= BTN_WAIT:
				_btn_fire(k)
	match mode:
		"intro", "shift":
			_relax(dt)
			if mode_t <= 0.0:
				mode = "fight"
				_rest(0.5)
		"fight":
			if not hold:
				_fight(fdt)
		"fall":
			piv.rotation.x = lerpf(piv.rotation.x, -1.45, minf(1.0, dt * 5.0))
			fl = fl.lerp(Vector3(-1.6, -1.3, -1.5), minf(1.0, dt * 5.0))
			if mode_t <= 0.0:
				_open_pick()
		"lobby":
			_relax(dt)
		"enter":
			fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 4.0))
			if mode_t <= 0.0:
				_intro()
		"dead":
			sword.position = sword.position.lerp(Vector3(0.3, -3.0, 2.5), minf(1.0, dt * 4.0))
			sword.rotation.z = lerpf(sword.rotation.z, -1.5, minf(1.0, dt * 4.0))
			if mode_t <= 0.0:
				if ftype == 4:
					last_run = "지난 판: %d번째 상대에게 %d 피해\n%s" % [n + 1, boss_dmg, _perk_text()]
				else:
					last_run = "지난 판: %d번째 상대에게 쓰러짐\n%s" % [n + 1, _perk_text()]
				lobby_k = n
				_to_lobby(1)
	piv.position = fl
	mark.position = piv.position
	mark.rotation.z = piv.rotation.z
	# 내 칼은 카메라를 따라간다
	rig.transform = Transform3D(cam.basis, cam_base) * Transform3D(Basis(), -CAM_O)
	if sw_t > 0.0:
		sw_t -= dt
	elif stun > 0.0 and mode != "dead":
		# 헛공격: 칼이 아래로 처진다
		sword.position = sword.position.lerp(Vector3(0.2, -1.9, 2.5), minf(1.0, dt * 10.0))
		sword.rotation.z = lerpf(sword.rotation.z, -1.2, minf(1.0, dt * 10.0))
	elif mode != "dead" and mode != "lobby":
		# 밀어서 잡은 방향에 칼을 대고 있는다
		sword.position = sword.position.lerp(REST_P if stance < 0 else POSE[stance], minf(1.0, dt * 16.0))
		sword.rotation.z = lerpf(sword.rotation.z, REST_R if stance < 0 else TURN[stance], minf(1.0, dt * 16.0))
	stance_l.visible = mode != "lobby"
	_score_l.visible = mode != "lobby"
	stance_l.text = "버튼을 누른 채 칼이 오는 쪽으로 밀기" if stance < 0 else "버튼을 밀어 방향 · 지금 %s" % ARROW[stance]
	if flash_t > 0.0:
		flash_t -= dt
		if flash_t <= 0.0:
			body.material_override = mat(body.get_meta("col"))
	if hurt_t > 0.0:
		hurt_t -= dt
		if hurt_t <= 0.0:
			sword.material_override = mat(my_col)
	cam.position = cam_base
	if shake_t > 0.0:
		shake_t -= dt
		cam.position += Vector3(randf_range(-0.12, 0.12), randf_range(-0.12, 0.12), 0)
	# 화면 글자
	if tut >= 0:
		_bar_bg.visible = false
		info_l.text = "튜토리얼"
		blink += dt
		tut_l.modulate.a = 0.55 + 0.45 * absf(cos(blink * 4.0)) if hold or tut == 4 else 1.0
	elif mode == "lobby":
		_bar_bg.visible = false
		info_l.text = ""
	else:
		gauge(float(life) / float(max_life), GOOD if life > foe_atk else BAD)
		if ftype == 4:
			info_l.text = "나 %d/%d   ·   %d번째 · 준 피해 %d · 공격 %d" % [maxi(life, 0), max_life, n + 1, boss_dmg, foe_atk]
		else:
			info_l.text = "나 %d/%d   ·   %d번째 %d/%d · 공격 %d" % [maxi(life, 0), max_life, n + 1, maxi(foe_hp, 0), foe_max, foe_atk]


func _fight(dt: float) -> void:
	fs_t += dt
	# 튜토리얼: 맞는 순간에 멈추고 기다린다
	if tut >= 0 and tut < 4:
		var stop := false
		if fs == 1:
			stop = (tut == 0 and fs_t >= 0.55) or (tut == 2 and fs_t >= win - 0.08)
		elif fs == 2:
			stop = (tut == 1 or tut == 3) and fs_t >= 0.05
		if stop:
			hold = true
			tut_l.text = TUT_SAY[tut]
			beep(660.0, 0.1, 0.0, 0.18)
			return
	var k := 0.0
	match fs:
		0:
			_relax(dt)
			if fs_t >= gap:
				_attack()
		1:
			if not shown:
				# 거합: 가만히 서 있다가, 눈이 번쩍하면 칼이 그쪽으로 간다
				if not told and fs_t >= tell_at:
					told = true
					for e in eyes:
						e.material_override = mat(WHITE)
					beep(1700.0, 0.04, 0.0, 0.16)
					sfx(SND["iai1"])
				if told:
					# 칼집에서 칼이 그쪽으로 빠져나온다: 칼만 보고도 방향을 안다
					blade_m.position = blade_m.position.lerp(_bpos(sdir, 0.0), minf(1.0, dt * 9.0))
					blade_m.rotation = blade_m.rotation.lerp(_brot(sdir, 0.0), minf(1.0, dt * 9.0))
					fl = fl.lerp(Vector3(0, -0.15, 0), minf(1.0, dt * 6.0))
				else:
					_relax(dt)
				if fs_t < show_at:
					return
				shown = true
				_eyes()
				_path(sdir)
				beep(1200.0, 0.05, 2400.0, 0.25)
				sfx(SND["iai2"])
			# 연격: 처음엔 흰 칼 하나만, 반쯤 와서야 노랑 칼이 뒤에 붙는다 (10/31)
			if link and fs_t >= link_at and not link_b.visible:
				_link_show(true)
			# 간파할 수 있는 거리에 들어오면 칼이 빨갛게 (맑은 눈으로 넓어지면 더 일찍 빨개진다)
			var can := win - fs_t <= _per() and not (feint_at >= 0.0 and fs_t < feint_at)
			var bc := mat(BAD if can else WHITE)
			if blade_m.material_override != bc:
				blade_m.material_override = bc
			if feint_at >= 0.0 and fs_t >= feint_at and sdir != rdir:
				sdir = rdir
				_path(rdir, _twice_next())
				beep(880.0, 0.06, 500.0, 0.2)
			k = clampf((fs_t - show_at) / (win - show_at), 0.0, 1.0)
			var l: Vector3 = LEAN[sdir]
			match sty:
				0:
					# 찌르기: 옆으로 기울지 않고 곧게 뛰어든다
					fl = Vector3(l.x * 0.1 * k, l.y * 0.08 * k, 1.3 * k * k)
					piv.rotation.z = 0.0
				2:
					# 베기: 몸을 크게 틀어 실어 벤다
					fl = Vector3(l.x * 0.5 * k, l.y * 0.3 * k, 1.6 * k * k)
					piv.rotation.z = -l.x * 0.45 * k
				_:
					fl = Vector3(l.x * 0.35 * k, l.y * 0.25 * k, 1.8 * k * k)
					piv.rotation.z = -l.x * 0.25 * k
			# 칼은 들어 올린 자리에서 버티다 끝에 몰아쳐 잔상 길을 따라 내게 온다
			var bp := _bpos(sdir, k * k * k)
			var br := _brot(sdir, k * k * k)
			if sty == 0 and k < 0.85:
				bp.z -= 0.15 * k  # 찌르기: 칼을 조금씩 더 당겼다가
			elif sty == 1 and feinting and k < 0.8:
				br.z += sin(fs_t * 16.0) * 0.08 * (1.0 - k)  # 속임수: 진짜 속임수일 때만 칼끝이 살짝 흔들린다 (10/31)
			blade_m.position = blade_m.position.lerp(bp, minf(1.0, dt * 22.0))
			blade_m.rotation = blade_m.rotation.lerp(br, minf(1.0, dt * 18.0))
			if fs_t >= win:
				_hurt()
		2:
			k = clampf(fs_t / win, 0.0, 1.0)
			fl = fl.lerp(Vector3(0, 0, -0.7), minf(1.0, dt * 14.0))
			# 막힌 칼은 온 쪽 바깥으로 튕겨 나가 반대쪽이 빈다
			blade_m.position = blade_m.position.lerp(WIND[rdir] * 1.15 + Vector3(0, 0.3, -0.3), minf(1.0, dt * 12.0))
			blade_m.rotation.z = lerpf(blade_m.rotation.z, ROT[rdir] + 0.7, minf(1.0, dt * 12.0))
			ind[odir].scale = Vector3.ONE * (1.2 - 0.6 * k)
			if fs_t >= win:
				beep(260.0, 0.1, 200.0, 0.15)
				_rest(_pat()[0])
		3:
			if fs_t >= 0.5:
				_rest(_pat()[0])
		5:
			# 앞 절반은 흰 칼, 뒤 절반은 노랑 칼로 바뀌며 살짝 더 젖힌다 (곧 온다)
			if fs_t >= beat * 0.5 and blade_m.material_override != mat(D):
				blade_m.material_override = mat(D)
			var bp := _bpos(sdir, 0.0)
			if fs_t >= beat * 0.5:
				bp += (bp - Vector3(0, 0.3, 0)).normalized() * 0.12
			blade_m.position = blade_m.position.lerp(bp, minf(1.0, dt * 18.0))
			if fs_t >= beat:
				_attack(true)
		4:
			fl = fl.lerp(Vector3(0, 0, -0.9), minf(1.0, dt * 8.0))
			if fs_t >= 0.45:
				if tut == 4:
					_tut_done()
				else:
					_rest(_pat()[0])


## linked = 앞 칼을 그냥 막아서 이미 오던 연격 칼이 이어 들어온다 (텀 뒤, 예비 시간 조금 짧음)
func _attack(linked := false) -> void:
	var mv: Array
	if tut >= 0:
		mv = TUT_MV[0 if tut < 2 else 1]
		if tut == 2:
			tut_l.text = "이번엔 칼이 거의 닿을 때까지\n기다려요…"
	else:
		mv = _pat()[2][ci][mi]
		if mi == 0 and not linked:
			dmap.shuffle()
	sdir = mv[0] if tut >= 0 else dmap[mv[0]]
	rdir = mv[1] if tut >= 0 else dmap[mv[1]]
	sty = 0 if tut >= 0 else _style(mv)
	fs = 1
	fs_t = 0.0
	if _flag(mv) == 2:
		# 거합: 서 있는 시간은 무작위, 뽑는 건 순식간
		win = randf_range(1.0, 2.4)
		show_at = win - maxf(0.2, 0.32 * spd)
		tell_at = win - maxf(0.42, 0.65 * spd)
		told = false
		shown = false
		feint_at = -1.0
		blade_m.material_override = mat(WHITE)
		_clear()
		return
	win = float(mv[2]) * (1.0 if tut >= 0 else spd)
	blade_m.material_override = mat(WHITE)
	if linked:
		# 이미 오고 있던 칼: 노랑 칼 자리에서 이어서, 막을 틈은 넉넉히 남긴다
		win = maxf(0.45, win * 0.85)
		blade_m.position = _bpos(sdir, 0.0)
		blade_m.rotation = _brot(sdir, 0.0)
	if _flag(mv) == 1:
		# 두 번째 칼: 튕겨 나간 칼을 바로 다시 크게 젖혀 들고, 막을 틈은 남긴다
		win = maxf(0.4, win)
		blade_m.position = _bpos(sdir, 0.0)
		blade_m.rotation = _brot(sdir, 0.0)
		fl = Vector3(0, 0, -0.3)
	show_at = 0.0
	tell_at = -1.0
	told = true
	shown = true
	feint_at = win * 0.5 if sdir != rdir else -1.0
	feinting = feint_at >= 0.0
	_path(sdir, _twice_next())
	_link_show(false)
	link = _link_next()
	link_at = win * 0.5
	# 느린 예비 동작은 낮은 소리, 갑작스러운 건 높은 소리
	beep(lerpf(760.0, 300.0, clampf((win - 0.3) / 0.9, 0.0, 1.0)), 0.06, 0.0, 0.17)


## 연격 사이 텀 (10/31): 막은 뒤 다음 칼이 그 자리에 들린 채 잠깐 서서 흰색 → 노랑으로 바뀐 뒤 들어온다
func _link_beat() -> void:
	var mv: Array = _pat()[2][ci][mi]
	sdir = dmap[mv[0]]
	sty = _style(mv)
	fs = 5
	fs_t = 0.0
	beat = maxf(0.4, 0.6 * spd)
	_clear()
	blade_m.material_override = mat(WHITE)
	blade_m.position = _bpos(sdir, 0.0)
	blade_m.rotation = _brot(sdir, 0.0)
	msg("연격!", 0.5)


func _flag(mv: Array) -> int:
	return int(mv[3]) if mv.size() > 3 else 0


## 다음 칼이 같은 쪽으로 바로 이어지면 상자를 두 겹으로 보인다
func _twice_next() -> bool:
	if tut >= 0:
		return false
	var c: Array = _pat()[2][ci]
	return mi + 1 < c.size() and _flag(c[mi + 1]) == 1


func _hurt() -> void:
	play("bad")
	msg("맞음 -%d" % foe_atk, 0.5)
	fs = 3
	fs_t = 0.0
	_clear()
	_eyes()
	ci = (ci + 1) % _pat()[2].size()
	mi = 0
	_damage(foe_atk)


func _damage(v: int) -> void:
	life -= v
	sword.material_override = mat(BAD)
	hurt_t = 0.3
	shake_t = 0.22
	if life <= 0:
		sfx(SND["death"])
		mode = "dead"
		mode_t = 1.4
		msg("쓰러짐", 1.4)
		best_n = maxi(best_n, n)
		if ftype == 4:
			best_dmg = maxi(best_dmg, boss_dmg)
		_save()


## 빈틈이 아닐 때 휘두름: 체력 -1, 잠깐 굳고, 상대가 바로 친다
## wrong = 빈틈은 열렸는데 엉뚱한 쪽으로 벰 (공격 실패 소리)
func _whiff(wrong := false) -> void:
	sfx(SND["miss"] if wrong else SND["whiff"])
	var steady := _lv("steady") > 0  # 능력 "흔들림 없는 손": 체력은 안 깎인다
	msg("헛공격!\n빈틈을 보였어요" if steady else "헛공격!  체력 -1\n빈틈을 보였어요", 0.9)
	stun = 0.55
	whiff_t = 0.35
	floor_m.material_override = mat(BAD)
	if fs != 1:
		ci = (ci + 1) % _pat()[2].size()
		mi = 0
		_rest(0.12)
	if not steady:
		_damage(1)


## 헛막기: 칼이 오지 않을 때 막기. 피해는 없지만 잠깐 굳어서 진짜 칼을 놓칠 수 있다
func _empty_guard() -> void:
	beep(240.0, 0.12, 160.0, 0.2)
	msg("헛막기", 0.5)
	stun = 0.35


## 버튼: a 0 = 막기, 1 = 베기. 방향은 밀어서 잡아 둔 stance.
func _act(a: int) -> void:
	if mode == "ready":
		_start_run()
		return
	if mode == "dead" or mode == "lobby" or mode == "pick" or mode == "picked":
		return
	if stun > 0.0:
		# 굳어서 못 휘두름: 베기는 헛공격 소리만 (벌은 없음)
		if a == 1 and tut < 0:
			sfx(SND["whiff"])
		return
	var d := stance
	if d >= 0:
		if a == 0:
			# 막기: 잡은 자리에서 칼을 앞으로 내민다
			sword.position = POSE[d] + Vector3(0, 0, -0.35)
			sword.rotation.z = TURN[d]
		else:
			# 베기: 잡은 쪽에서 반대쪽으로 휘두른다
			var o: Vector3 = POSE[OPP[d]]
			sword.position = Vector3(o.x * 0.5, o.y * 0.5, 2.2)
			sword.rotation.z = TURN[d] - 0.9
		sw_t = 0.16
	if tut >= 0:
		if not hold:
			return
		var want: int = rdir if fs == 1 else odir
		var want_a := 0 if fs == 1 else 1
		if d != want:
			msg("버튼을 누른 채 %s 쪽으로 밀어요!" % ARROW[want], 0.8)
			beep(300.0, 0.05, 150.0, 0.1)
			return
		if a != want_a:
			msg("[%s]를 눌러요!" % ACT[want_a], 0.8)
			beep(300.0, 0.05, 150.0, 0.1)
			return
		hold = false
		tut += 1
		tut_l.modulate.a = 1.0
		tut_l.text = "좋아요!"
		if fs == 1:
			_parry(tut == 3)
		else:
			_cut()
		return
	if mode != "fight":
		if a == 1:
			sfx(SND["whiff"])
		else:
			beep(300.0, 0.05, 150.0, 0.1)
		return
	if a == 0:
		# 막기: 칼이 보일 때만. 잡은 방향이 다르거나 속임수에 먼저 막으면 맞는다
		if fs == 1 and told:
			var fooled := feint_at >= 0.0 and fs_t < feint_at
			if d == rdir and not fooled:
				_parry(win - fs_t <= _per())
			else:
				_hurt()
		elif fs == 2 and gp:
			# 간파 빈틈에 헛막기: 간파 기회도 사라진다 (10/31)
			_lose_chance()
			_empty_guard()
			msg("헛막기
간파 놓침", 0.6)
		elif fs == 0 or fs == 1 or fs == 2 or fs == 5:
			_empty_guard()
		return
	# 베기: 빈틈에 맞는 쪽만. 그 밖에는 헛공격
	match fs:
		2:
			if d == odir:
				_cut()
				msg("베기!", 0.35)
			elif gp:
				_lose_chance()
			else:
				_whiff(true)
		0, 1:
			_whiff()
		_:
			# 맞은 직후·벤 직후에 또 휘두름: 벌은 없고 헛공격 소리만
			sfx(SND["whiff"])


## 간파 빈틈에 엉뚱한 쪽으로 휘두름: 피해 없이 간파만 끝난다
func _lose_chance() -> void:
	sfx(SND["miss"])
	msg("간파 놓침", 0.6)
	gp = false
	slow = 0.0
	floor_m.material_override = mat(SOFT)
	_rest(0.12)


func _parry(perfect: bool) -> void:
	# 연격이 오던 중: 그냥 막으면 연격 칼이 바로 들어오고, 간파하면 다 끊긴다
	var linked := link and not perfect
	_link_show(false)
	blade_m.material_override = mat(WHITE)
	# 칼이 막히면 폰 진동, 간파는 더 길고 세게
	_buzz(160 if perfect else 45, 1.0 if perfect else 0.5)
	# 진동과 같은 순간: 칼 부딪친 자리에 불꽃, 화면 잠깐 멈춤 (간파는 더 많이·더 길게)
	_burst(blade_m.global_position, 26 if perfect else 14, perfect)
	hitstop = 0.09 if perfect else 0.05
	shake_t = maxf(shake_t, 0.12 if perfect else 0.06)
	# 간파 = 패링 소리, 그냥 막기 = 이번 칼 모양의 막기 소리
	sfx(SND["parry"] if perfect else BLOCK_SND[sty])
	body.material_override = mat(WHITE)
	flash_t = 0.1
	fl = Vector3(0, 0, -0.4)
	_eyes()
	var combos: Array = _pat()[2]
	mi += 1
	# 베기 검객의 두 번째 칼: 첫 칼을 간파해도 끊기지 않고 반드시 한 번 더 온다
	var twice: bool = tut < 0 and mi < combos[ci].size() and _flag(combos[ci][mi]) == 1
	if tut < 0:
		blocks += 1
		if perfect:
			perfects += 1
			# 능력 "숨 고르기": 간파하면 체력이 조금 찬다
			if _lv("leech") > 0 and life < max_life:
				life = mini(max_life, life + _lv("leech"))
		msg("간파!" if perfect else "막기", 0.6)
	if perfect and twice:
		msg("간파!\n한 번 더 와요!", 0.7)
	elif perfect:
		slow = 0.7
		floor_m.material_override = mat(B)
		if tut < 0:
			msg("간파!\n지금 초록 쪽으로 베요!", 0.8)
	# 간파하면 연속기 중간이라도 끊고 내가 벨 차례 (초록 상자)
	if linked and mi < combos[ci].size():
		_link_beat()
		return
	if twice or (tut < 0 and not perfect and mi < combos[ci].size()):
		# 그냥 막은 뒤 다음 칼은 숨 돌릴 틈을 두고 온다 (10/31: 0.12 → 0.6)
		_rest(0.03 if twice else 0.6)
		return
	ci = (ci + 1) % combos.size()
	mi = 0
	fs = 2
	fs_t = 0.0
	gp = perfect
	win = float(_pat()[1]) * (1.8 if perfect else 1.0) * (1.0 + 0.3 * _lv("gap"))
	odir = OPP[rdir]  # 빈틈은 늘 마지막 칼이 온 쪽의 반대 (간파든 막기든)
	_path(-1)
	_show(odir)


func _cut() -> void:
	sfx(SND["hit"])
	var dmg := _pow() * (2 if gp else 1)  # 간파로 연 빈틈에 벤 칼은 피해 두 배
	body.material_override = mat(GOOD)
	flash_t = 0.15
	fl = Vector3(0, 0, -1.2)
	fs = 4
	fs_t = 0.0
	_clear()
	if tut >= 0:
		return
	foe_hp -= dmg
	if gp:
		msg("간파 일격! x2", 0.6)
	if ftype == 4:
		boss_dmg += dmg
		foe_hp = maxi(foe_hp, 1)  # 끝판왕은 쓰러지지 않는다
	_hp_bar()
	if foe_hp <= 0:
		kills[ftype] += 1
		_save()
		mode = "fall"
		mode_t = 1.4
		msg("승리!", 1.2)
		play("win")
		hp_back.visible = false
		hp_fill.visible = false
		return
	var want := 0
	if ftype == 4:
		cuts += 1
		want = mini(2, cuts / 5)
	elif foe_hp * 3 <= foe_max:
		want = 2
	elif foe_hp * 3 <= foe_max * 2:
		want = 1
	if want > ph:
		ph = want
		ci = 0
		mi = 0
		mode = "shift"
		mode_t = 1.2
		msg("%d단" % (ph + 1), 1.0)
		beep(440.0, 0.25, 220.0, 0.25)
		_eyes()



## 검객을 쓰러뜨림: 능력 셋 중 하나를 고른다 (체력은 저절로 차지 않는다)
func _open_pick() -> void:
	n += 1
	best_n = maxi(best_n, n)
	_save()
	var pool: Array = []
	for i in PERKS.size():
		var k: String = PERKS[i][0]
		if _lv(k) >= int(PERKS[i][3]):
			continue
		if k == "mend" and life >= max_life:
			continue
		pool.append(i)
	pool.shuffle()
	pick = pool.slice(0, 3)
	mode = "pick"
	mode_t = 0.45  # 베기를 연타하다 카드를 잘못 누르지 않게 잠깐 막는다
	_btns.clear()
	pend.clear()
	pick_head.text = "승리!  능력을 하나 골라요\n체력 %d/%d" % [life, max_life]
	for i in 3:
		pick_bg[i].visible = i < pick.size()
		if i < pick.size():
			var p: Array = PERKS[pick[i]]
			var lv := _lv(p[0])
			pick_l[i].text = "%s%s\n%s" % [p[1], "" if lv == 0 else " (+%d)" % lv, p[2]]
			pick_bg[i].scale = Vector2.ONE
	pick_box.visible = true
	play("win")


func _choose(i: int) -> void:
	var k: String = PERKS[pick[i]][0]
	perk[k] = _lv(k) + 1
	if k == "hp":
		max_life += 4
		life += 4
	elif k == "mend":
		life = mini(max_life, life + ceili(max_life / 2.0))
	play("good")
	msg(PERKS[pick[i]][1], 0.8)
	_press(pick_bg[i]).tween_callback(_next_foe)
	mode = "picked"


func _next_foe() -> void:
	pick_box.visible = false
	_buttons()
	_spawn(n)
	fl = Vector3(0, 0, -10)
	mode = "enter"
	mode_t = 1.2


func _tut_done() -> void:
	tut_done = true
	_save()
	tut = 4
	hold = true
	mode = "ready"
	_clear()
	tut_l.text = "준비 끝!\n검객을 쓰러뜨리면 능력을 하나 골라요.\n체력은 저절로 차지 않아요. 갈수록 적이 세져요.\n\n탭해서 싸우러 가기"


func _tap(p: Vector2) -> void:
	if mode == "lobby":
		_lobby_tap(p)
		return
	if mode == "pick":
		if mode_t <= 0.0:
			for i in pick.size():
				if _pick_r(i).has_point(p):
					_choose(i)
					return
		return
	if mode == "picked":
		return
	if tut >= 0 and SKIP_R.has_point(p):
		_start_run()
		return
	if mode == "ready":
		_start_run()
		return
	start = p
	armed = true


## 지난 판에 고른 능력 한 줄
func _perk_text() -> String:
	var s: Array = []
	for p: Array in PERKS:
		var lv := _lv(p[0])
		if lv > 0:
			s.append(p[1] if lv == 1 else "%s+%d" % [p[1], lv])
	return "고른 능력 없음" if s.is_empty() else "능력: " + ", ".join(s)


func _lobby_tap(p: Vector2) -> void:
	if going:
		return
	if set_box.visible:
		for i in 2:
			for plus in [false, true]:
				if _set_r(i, plus).has_point(p):
					var dv := 1 if plus else -1
					if i == 0:
						vol = clampi(vol + dv, 0, 10)
						_apply_vol()
					else:
						vib = clampi(vib + dv, 0, 10)
						_buzz(160, 1.0)  # 바뀐 세기를 바로 느껴 본다
					play("tap")
					_save()
					_set_refresh()
					return
		if SET_CLOSE.has_point(p) or SET_R.has_point(p) or p.y >= NAV_Y:
			play("tap")
			set_box.visible = false
		return
	if SET_R.has_point(p):
		_press(set_btn)
		play("tap")
		_set_refresh()
		set_box.visible = true
		return
	for i in TABS.size():
		if _tab_r(i).has_point(p):
			_press(nav_bg[i])
			if i + 1 != tab:
				play("tap")
				_set_tab(i + 1)
			return
	match tab:
		1:
			# 눌린 버튼이 다시 튀어 오르는 걸 보여 주고 출발
			if PLAY_R.has_point(p):
				going = true
				play("tap")
				_press(play_edge)
				_press(play_bg).tween_callback(_start_run)
			elif TUT_R.has_point(p):
				going = true
				play("tap")
				_press(tut_again).tween_callback(_begin_tut)
		3:
			for i in 5:
				if _dex_r(i).has_point(p):
					_press(dex_bg[i])
					dex_pick = i
					play("tap")
					_set_tab(3)
					return


## 버튼 누름 애니메이션: 쑥 들어갔다가 살짝 튀어 오르며 제자리
func _press(c: Control) -> Tween:
	c.pivot_offset = c.size * 0.5
	var tw := create_tween()
	tw.tween_property(c, "scale", Vector2.ONE * 0.86, 0.06)
	tw.tween_property(c, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tw


## 불꽃: 노랗고 흰 작은 조각이 사방으로 튀고 떨어지며 줄어든다
func _burst(at: Vector3, count: int, big: bool) -> void:
	for i in count:
		var sm := StandardMaterial3D.new()
		sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm.albedo_color = [Color("fff3bf"), Color("ffd43b"), Color("ffa94d")][i % 3]
		var m := box(at, Vector3.ONE * 0.1, WHITE)
		m.material_override = sm
		var v := Vector3(randf_range(-1, 1), randf_range(-0.6, 1.2), randf_range(0.2, 1.0)).normalized() * randf_range(3.0, 7.0 if big else 5.0)
		var lt := randf_range(0.22, 0.4)
		sparks.append([m, v, lt, lt])


func _sparks(dt: float) -> void:
	for i in range(sparks.size() - 1, -1, -1):
		var sp: Array = sparks[i]
		var m: MeshInstance3D = sp[0]
		sp[2] -= dt
		if sp[2] <= 0.0 or not is_instance_valid(m):
			if is_instance_valid(m):
				m.queue_free()
			sparks.remove_at(i)
			continue
		sp[1].y -= 12.0 * dt
		m.position += sp[1] * dt
		m.scale = Vector3.ONE * 0.1 * (sp[2] / sp[3])


## 밀면 칼 방향만 정한다 (막기·베기는 버튼). 손을 떼지 않고 계속 밀어 방향을 또 바꿀 수 있다.
func _drag(p: Vector2) -> void:
	if not armed:
		return
	var v := p - start
	if v.length() < SWIPE:
		return
	start = p
	if absf(v.x) > absf(v.y):
		_aim(0 if v.x < 0.0 else 1)
	else:
		_aim(2 if v.y < 0.0 else 3)


func _aim(d: int) -> void:
	if mode == "lobby" or mode == "dead" or d == stance:
		return
	stance = d
	beep(900.0, 0.03, 0.0, 0.1)


func _lift(_p: Vector2) -> void:
	armed = false


func _btn_down(k: String, _p: Vector2) -> void:
	if k == "guard" or k == "cut":
		pend[k] = 0.0


## 버튼을 누른 채 밀면: 민 쪽으로 방향을 잡고 그 자리에서 막기/베기
func _btn_drag(k: String, p: Vector2) -> void:
	if not pend.has(k):
		return
	var v: Vector2 = p - _btns[k].at
	if v.length() < BTN_SWIPE:
		return
	if absf(v.x) > absf(v.y):
		_aim(0 if v.x < 0.0 else 1)
	else:
		_aim(2 if v.y < 0.0 else 3)
	_btn_fire(k)


func _btn_up(k: String, _p: Vector2) -> void:
	if pend.has(k):
		_btn_fire(k)


func _btn_fire(k: String) -> void:
	pend.erase(k)
	_act(0 if k == "guard" else 1)


## PC: 방향키/WASD = 칼 방향, J = 막기, K = 베기
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or over or _rating:
		return
	match event.keycode:
		KEY_LEFT, KEY_A: _aim(0)
		KEY_RIGHT, KEY_D: _aim(1)
		KEY_UP, KEY_W: _aim(2)
		KEY_DOWN, KEY_S: _aim(3)
		KEY_J, KEY_Z: _act(0)
		KEY_K, KEY_X: _act(1)


## 효과음 한 번 (효과음 전용 줄 넷을 돌려 쓴다. 삑 소리와 섞여 끊기지 않게. 소리 크기 설정은 버스 0 에 걸려 있다)
## 파이 요청(10/31): 파이가 보낸 효과음(sfx)만 쓴다. 틀(tofu)의 삑 소리는 전부 끈다.
func beep(_freq: float, _dur := 0.08, _to := 0.0, _vol := 0.2) -> void:
	pass


func sfx(st: AudioStream) -> void:
	var p: AudioStreamPlayer = sfx_p[sfx_i]
	sfx_i = (sfx_i + 1) % sfx_p.size()
	p.stream = st
	p.play()
