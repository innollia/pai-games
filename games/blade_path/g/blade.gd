extends Tofu
## 일격의 길 (단독판): [막기]·[베기] 버튼을 누른 채 왼·오·위·아래로 밀면 그쪽으로 바로 막고 벤다.
## 버튼을 그냥 탭하면 마지막으로 잡은 방향으로. 화면 빈 곳을 밀어 방향만 미리 잡아 둘 수도 있다. 1인칭 내 칼은 없다.
## 적 칼은 그쪽으로 들어 올려지고 흐린 잔상이 지나갈 길을 보여 준다(색 없이 칼 모양만 봐도 안다). 초록 상자 = 빈틈.
## 끝까지 기다렸다 막으면 '간파'(세상이 느려짐).
## 켜면 튜토리얼부터: 맞는 쪽으로 밀 때까지 멈추고 알려 준다. 그다음 찌르기 → 속임수 → 베기 → 거합 검객이 두 바퀴 나오고
## (뒤로 갈수록 체력·공격력·빠르기가 오른다), 마지막은 쓰러뜨릴 수 없는 끝판왕 검귀. 간파하면 그 자리에서 내가 직접 벤다.
## 빈틈이 아닐 때 휘두르면 헛공격: 체력 -1, 잠깐 굳고, 상대가 바로 친다.
## 막을 때마다 돈(간파는 3배). 쓰러지면 로비(아래 탭: 업그레이드 · 전투 · 캐릭터 · 도감)로 가서 강해진 뒤 [전투]로 첫 검객부터 다시.
## 돈·업그레이드·기록·도감은 저장된다. 튜토리얼은 처음 한 번만(로비에서 다시 볼 수 있다).

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
	"쓰러뜨릴 수 없어요. 오래 버티며 돈을 벌어요",
]
const BODY := [A, C, B, ME, INK]
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
	"막았어요! (실전에선 막을 때마다 돈 +1냥)\n초록 상자 = 빈틈. [베기]를 누른 채 오른쪽으로!",
	"끝까지 기다렸다 막으면 '간파'!\n[막기]를 누른 채 위로!",
	"간파: 돈 3배, 세상이 느려지고 빈틈이 길어요.\n[베기]를 누른 채 아래로!",
]
const ACT := ["막기", "베기"]
## 업그레이드: 키, 이름, 첫 값, 최대 단계. 값은 단계마다 첫 값만큼 오른다.
const UPS := [
	["hp", "최대 체력", 5, 99],
	["pow", "베기 힘", 8, 99],
	["per", "간파 넓게", 6, 5],
	["earn", "막기 돈", 10, 99],
]

const TABS := ["업그레이드", "전투", "캐릭터", "도감"]
const DEX := ["찌르기", "속임수", "베기", "거합", "검귀"]
const NAV_Y := 1150.0

# 저장되는 것
var gold := 0
var tut_done := false
var seen := [0, 0, 0, 0, 0]  # 도감: 종류별 만난 수
var kills := [0, 0, 0, 0, 0]
var runs := 0
var blocks := 0
var perfects := 0
var up := {"hp": 0, "pow": 0, "per": 0, "earn": 0}
var best_n := 0
var best_dmg := 0  # 끝판왕에게 준 가장 큰 피해
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
var run_gold := 0
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
var fs := 0  # 0 쉼, 1 예비 동작, 2 빈틈, 3 내가 맞음, 4 상대 휘청
var fs_t := 0.0
var gap := 0.5
var win := 0.5
var rdir := 0
var sdir := 0
var odir := 0
var feint_at := -1.0
var show_at := 0.0  # 거합: 이때부터 빨간 상자가 보인다
var tell_at := -1.0  # 거합: 이때 눈이 번쩍 (이보다 먼저 휘두르면 헛공격)
var told := true
var shown := true
var stun := 0.0  # 헛공격 뒤 굳은 시간
var whiff_t := 0.0
var fl := Vector3.ZERO
var slow := 0.0
var sw_t := 0.0
var flash_t := 0.0
var hurt_t := 0.0
var shake_t := 0.0
var blink := 0.0
var start := Vector2.ZERO
var armed := false
var pend := {}  # 눌렀지만 아직 발동 안 한 버튼 -> 누른 시간
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
var badge: ColorRect
var top_l: Label
var home_l: Label
var shop_head: Label
var row_l: Array[Label] = []
var row_c: Array[Label] = []
var row_bg: Array[ColorRect] = []
var play_bg: ColorRect
var char_l: Label
var dex_bg: Array[ColorRect] = []
var dex_l: Array[Label] = []
var dex_card: Label
var dex_pick := 0
var last_run := ""
var lobby_k := 0  # 전투 탭 뒤에 서 있는 검객 (마지막에 진 상대)

const SKIP_R := Rect2(470, 296, 250, 90)
const GUARD_P := Vector2(185, 1150)
const CUT_P := Vector2(535, 1150)
const BTN_R := 105.0
const PLAY_R := Rect2(110, 880, 500, 150)
const TUT_R := Rect2(200, 1050, 320, 80)


func _row_r(i: int) -> Rect2:
	return Rect2(50, 440 + i * 132, 620, 116)


func _tab_r(i: int) -> Rect2:
	return Rect2(i * 180, NAV_Y, 180, 1280 - NAV_Y)


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
	gold = int(d.get("gold", 0))
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
	var u: Variant = d.get("up", {})
	if u is Dictionary:
		for k: String in up:
			up[k] = int(u.get(k, 0))


func _save() -> void:
	var f := FileAccess.open(FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"gold": gold, "up": up, "best": best_n, "dmg": best_dmg, "tut": tut_done, "runs": runs, "blocks": blocks, "perfects": perfects, "seen": seen, "kills": kills}))


# ---- 능력치 ----
func _max_hp(lv: int) -> int:
	return 6 + 3 * lv


func _pow(lv: int) -> int:
	return 1 + lv


func _per(lv: int) -> float:
	return 0.2 + 0.04 * lv


func _earn(lv: int) -> int:
	return 1 + lv


func _cost(i: int) -> int:
	return int(UPS[i][2]) * (int(up[UPS[i][0]]) + 1)


# ---- 화면 글자 ----
func _setup() -> void:
	howto = ""
	time_limit = 0.0
	_load_save()
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


## 로비: 위 돈 띠, 가운데 탭 화면, 아래 탭 줄(업그레이드 · 전투 · 캐릭터 · 도감)
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
	for i in 4:
		var pg := Control.new()
		pg.size = Vector2(720, 1280)
		pg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lobby.add_child(pg)
		pages.append(pg)
	# 0 업그레이드
	_panel(pages[0], Rect2(0, 194, 720, NAV_Y - 194), Color(0.12, 0.08, 0.05, 0.8))
	shop_head = _white(_label(pages[0], 38, 220, 190))
	shop_head.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for i in UPS.size():
		var r := _row_r(i)
		var bg := _panel(pages[0], r, SOFT)
		row_bg.append(bg)
		var l := _label(bg, 34, 0, r.size.y)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.position.x = 24
		l.size.x = 420
		l.label_settings.outline_size = 0
		row_l.append(l)
		var c := _label(bg, 38, 0, r.size.y)
		c.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		c.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		c.size.x = 596
		c.label_settings.outline_size = 0
		row_c.append(c)
	var hint := _white(_label(pages[0], 30, 990, 120))
	hint.text = "누르면 사요\n다 샀으면 아래 [전투] 탭에서 싸우러 가요"
	# 1 전투 (뒤에 검객이 서 있다)
	var title := _label(pages[1], 72, 210, 100)
	title.text = "일격의 길"
	var card := _panel(pages[1], Rect2(60, 320, 600, 150), Color(0.12, 0.08, 0.05, 0.7))
	home_l = _white(_label(card, 30, 0, 150))
	home_l.size.x = 600
	home_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_panel(pages[1], Rect2(PLAY_R.position + Vector2(-8, -8), PLAY_R.size + Vector2(16, 24)), INK)
	play_bg = _panel(pages[1], PLAY_R, D)
	var pl := _label(play_bg, 80, 0, PLAY_R.size.y)
	pl.size.x = PLAY_R.size.x
	pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pl.text = "전투"
	var tl := _label(pages[1], 30, TUT_R.position.y, TUT_R.size.y)
	tl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tl.text = "튜토리얼 다시 보기"
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
	for i in 4:
		var r := _tab_r(i)
		var bg := _panel(lobby, r.grow(-4), Color("5a4632"))
		nav_bg.append(bg)
		var l := _white(_label(bg, 32, 0, r.size.y - 8))
		l.size.x = r.size.x - 8
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.text = TABS[i]
		nav_l.append(l)
	badge = _panel(lobby, Rect2(140, NAV_Y + 8, 32, 32), BAD)
	var bl := _white(_label(badge, 24, 0, 32))
	bl.size.x = 32
	bl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bl.label_settings.outline_size = 0
	bl.text = "!"


## 막기·베기 버튼 (여러 손가락: 한 손가락으로 밀면서 다른 손가락으로 누른다). 상점에서는 뺀다.
func _buttons() -> void:
	kit_button("guard", "막기", GUARD_P, BTN_R, B)
	kit_button("cut", "베기", CUT_P, BTN_R, A)


func _can_buy() -> bool:
	for i in UPS.size():
		if up[UPS[i][0]] < int(UPS[i][3]) and gold >= _cost(i):
			return true
	return false


func _lobby_refresh() -> void:
	top_l.text = "돈 %d냥   ·   최고 %d명" % [gold, best_n]
	badge.visible = _can_buy() and tab != 0
	for i in 4:
		pages[i].visible = i == tab
		nav_bg[i].color = D if i == tab else Color("5a4632")
		nav_l[i].label_settings.font_size = 36 if i == tab else 30
	match tab:
		0:
			shop_head.text = "업그레이드\n가진 돈 %d냥" % gold
			for i in UPS.size():
				var k: String = UPS[i][0]
				var lv: int = up[k]
				var maxed := lv >= int(UPS[i][3])
				var t := ""
				match k:
					"hp": t = "최대 체력 %d → %d" % [_max_hp(lv), _max_hp(lv + 1)]
					"pow": t = "베기 힘 %d → %d" % [_pow(lv), _pow(lv + 1)]
					"per": t = "간파 넓게 %.2f → %.2f초" % [_per(lv), _per(lv + 1)] if not maxed else "간파 넓게 %.2f초 (끝)" % _per(lv)
					"earn": t = "막기 돈 %d → %d냥" % [_earn(lv), _earn(lv + 1)]
				row_l[i].text = t
				row_c[i].text = "끝" if maxed else "%d냥" % _cost(i)
				row_bg[i].color = SOFT if maxed or gold < _cost(i) else D
		1:
			var h := last_run if last_run != "" else "막을 때마다 돈을 벌어요\n쓰러지면 업그레이드하고 다시!"
			if best_dmg > 0:
				h += "\n끝판왕 최고 피해 %d" % best_dmg
			home_l.text = h
		2:
			char_l.text = "나 · 떠돌이 검객\n\n최대 체력 %d\n베기 힘 %d\n간파 시간 %.2f초\n막기 돈 %d냥 (간파 %d냥)\n\n— 기록 —\n최고 %d명 쓰러뜨림 · 끝판왕 최고 피해 %d\n싸운 판 %d · 막기 %d · 간파 %d" % [
				_max_hp(up["hp"]), _pow(up["pow"]), _per(up["per"]), _earn(up["earn"]), _earn(up["earn"]) * 3,
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
	score = gold
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
		msg("%d번째 · %s\n체력 %s · 공격 %d\n%s" % [n + 1, NAMES[ftype], hp_s, foe_atk, TIPS[ftype]], 2.6)


func _start_run() -> void:
	tut = -1
	hold = false
	lobby.visible = false
	tut_box.visible = false
	tut_done = true
	runs += 1
	_save()
	skip_l.visible = false
	n = 0
	max_life = _max_hp(up["hp"])
	life = max_life
	run_gold = 0
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
	var w: Vector3 = WIND[d]
	var h: Vector3 = HIT[d]
	for i in 3:
		ghosts[i].position = w.lerp(h, [0.35, 0.68, 1.0][i])
		ghosts[i].rotation = Vector3(0, 0, ROT[d])
	ghosts[3].position = w + (Vector3(0.38, 0, -0.1) if d < 2 else Vector3(0, 0.38, -0.1)) * (-1.0 if d == 1 else 1.0)
	ghosts[3].rotation = Vector3(0, 0, ROT[d])


func _clear() -> void:
	_show(-1)
	_path(-1)


func _rest(g: float) -> void:
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
	score = gold
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
				_next_foe()
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
					last_run = "지난 판: 끝판왕에게 %d 피해\n번 돈 +%d냥" % [boss_dmg, run_gold]
				else:
					last_run = "지난 판: %d번째 %s에게 쓰러짐\n번 돈 +%d냥" % [n + 1, NAMES[ftype], run_gold]
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
			info_l.text = "나 %d/%d   ·   끝판왕 피해 %d · 공격 %d" % [maxi(life, 0), max_life, boss_dmg, foe_atk]
		else:
			info_l.text = "나 %d/%d   ·   %d번째 %s %d/%d · 공격 %d" % [maxi(life, 0), max_life, n + 1, NAMES[ftype], maxi(foe_hp, 0), foe_max, foe_atk]


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
				if told:
					# 칼집에서 칼이 그쪽으로 빠져나온다: 칼만 보고도 방향을 안다
					blade_m.position = blade_m.position.lerp(WIND[sdir], minf(1.0, dt * 9.0))
					blade_m.rotation = blade_m.rotation.lerp(Vector3(0, 0, ROT[sdir]), minf(1.0, dt * 9.0))
					fl = fl.lerp(Vector3(0, -0.15, 0), minf(1.0, dt * 6.0))
				else:
					_relax(dt)
				if fs_t < show_at:
					return
				shown = true
				_eyes()
				_path(sdir)
				beep(1200.0, 0.05, 2400.0, 0.25)
			if feint_at >= 0.0 and fs_t >= feint_at and sdir != rdir:
				sdir = rdir
				_path(rdir, _twice_next())
				beep(880.0, 0.06, 500.0, 0.2)
			k = clampf((fs_t - show_at) / (win - show_at), 0.0, 1.0)
			var l: Vector3 = LEAN[sdir]
			fl = Vector3(l.x * 0.35 * k, l.y * 0.25 * k, 1.8 * k * k)
			piv.rotation.z = -l.x * 0.25 * k
			# 칼은 들어 올린 자리에서 버티다 끝에 몰아쳐 잔상 길을 따라 내게 온다
			blade_m.position = blade_m.position.lerp(WIND[sdir].lerp(HIT[sdir], k * k * k), minf(1.0, dt * 22.0))
			blade_m.rotation = blade_m.rotation.lerp(Vector3(0, 0, ROT[sdir]), minf(1.0, dt * 18.0))
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
		4:
			fl = fl.lerp(Vector3(0, 0, -0.9), minf(1.0, dt * 8.0))
			if fs_t >= 0.45:
				if tut == 4:
					_tut_done()
				else:
					_rest(_pat()[0])


func _attack() -> void:
	var mv: Array
	if tut >= 0:
		mv = TUT_MV[0 if tut < 2 else 1]
		if tut == 2:
			tut_l.text = "이번엔 칼이 거의 닿을 때까지\n기다려요…"
	else:
		mv = _pat()[2][ci][mi]
	sdir = mv[0]
	rdir = mv[1]
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
		_clear()
		return
	win = float(mv[2]) * (1.0 if tut >= 0 else spd)
	if _flag(mv) == 1:
		win = maxf(0.22, win)
	show_at = 0.0
	tell_at = -1.0
	told = true
	shown = true
	feint_at = win * 0.5 if sdir != rdir else -1.0
	_path(sdir, _twice_next())
	# 느린 예비 동작은 낮은 소리, 갑작스러운 건 높은 소리
	beep(lerpf(760.0, 300.0, clampf((win - 0.3) / 0.9, 0.0, 1.0)), 0.06, 0.0, 0.17)


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
		mode = "dead"
		mode_t = 1.4
		msg("쓰러짐", 1.4)
		best_n = maxi(best_n, n)
		if ftype == 4:
			best_dmg = maxi(best_dmg, boss_dmg)
		_save()


## 빈틈이 아닐 때 휘두름: 체력 -1, 잠깐 굳고, 상대가 바로 친다
func _whiff() -> void:
	beep(180.0, 0.25, 70.0, 0.3)
	msg("헛공격!  체력 -1\n빈틈을 보였어요", 0.9)
	stun = 0.55
	whiff_t = 0.35
	floor_m.material_override = mat(BAD)
	if fs != 1:
		ci = (ci + 1) % _pat()[2].size()
		mi = 0
		_rest(0.12)
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
	if mode == "dead" or mode == "lobby" or stun > 0.0:
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
		beep(300.0, 0.05, 150.0, 0.1)
		return
	if a == 0:
		# 막기: 칼이 보일 때만. 잡은 방향이 다르거나 속임수에 먼저 막으면 맞는다
		if fs == 1 and told:
			var fooled := feint_at >= 0.0 and fs_t < feint_at
			if d == rdir and not fooled:
				_parry(win - fs_t <= _per(up["per"]))
			else:
				_hurt()
		elif fs == 0 or fs == 1 or fs == 2:
			_empty_guard()
		return
	# 베기: 빈틈에 맞는 쪽만. 그 밖에는 헛공격
	match fs:
		2:
			if d == odir:
				_cut()
				msg("베기!", 0.35)
			else:
				_whiff()
		0, 1:
			_whiff()
		_:
			beep(300.0, 0.05, 150.0, 0.1)


func _parry(perfect: bool) -> void:
	beep(1500.0, 0.05, 0.0, 0.25)
	beep(2100.0, 0.09, 1600.0, 0.15)
	body.material_override = mat(WHITE)
	flash_t = 0.1
	fl = Vector3(0, 0, -0.4)
	_eyes()
	var combos: Array = _pat()[2]
	mi += 1
	if tut < 0:
		var g: int = _earn(up["earn"]) * (3 if perfect else 1)
		gold += g
		run_gold += g
		blocks += 1
		if perfect:
			perfects += 1
		msg(("간파 +%d냥" if perfect else "+%d냥") % g, 0.6)
	if perfect:
		slow = 0.7
		floor_m.material_override = mat(B)
		beep(200.0, 0.4, 90.0, 0.22)
		if tut < 0:
			msg("간파 +%d냥\n지금 초록 쪽으로 베요!" % (_earn(up["earn"]) * 3), 0.8)
	# 간파하면 연속기 중간이라도 끊고 내가 벨 차례 (초록 상자)
	if tut < 0 and not perfect and mi < combos[ci].size():
		_rest(0.03 if _flag(combos[ci][mi]) == 1 else 0.12)
		return
	ci = (ci + 1) % combos.size()
	mi = 0
	fs = 2
	fs_t = 0.0
	win = float(_pat()[1]) * (1.8 if perfect else 1.0)
	odir = OPP[rdir]
	_path(-1)
	_show(odir)


func _cut() -> void:
	play("good")
	body.material_override = mat(GOOD)
	flash_t = 0.15
	fl = Vector3(0, 0, -1.2)
	fs = 4
	fs_t = 0.0
	_clear()
	if tut >= 0:
		return
	foe_hp -= _pow(up["pow"])
	if ftype == 4:
		boss_dmg += _pow(up["pow"])
		foe_hp = maxi(foe_hp, 1)  # 끝판왕은 쓰러지지 않는다
	_hp_bar()
	if foe_hp <= 0:
		var g := 5 + 3 * n
		kills[ftype] += 1
		gold += g
		run_gold += g
		_save()
		mode = "fall"
		mode_t = 1.4
		msg("승리 +%d냥" % g, 1.2)
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



func _next_foe() -> void:
	n += 1
	best_n = maxi(best_n, n)
	_save()
	life = max_life
	_spawn(n)
	fl = Vector3(0, 0, -10)
	mode = "enter"
	mode_t = 1.2
	msg("체력 회복", 0.8)


func _tut_done() -> void:
	tut_done = true
	_save()
	tut = 4
	hold = true
	mode = "ready"
	_clear()
	tut_l.text = "준비 끝!\n막을 때마다 돈을 벌어요. 쓰러지면 그 돈으로\n강해져서 다시 싸워요. 갈수록 적이 세져요.\n\n탭해서 싸우러 가기"


func _tap(p: Vector2) -> void:
	if mode == "lobby":
		_lobby_tap(p)
		return
	if tut >= 0 and SKIP_R.has_point(p):
		_start_run()
		return
	if mode == "ready":
		_start_run()
		return
	start = p
	armed = true


func _buy(i: int) -> void:
	var k: String = UPS[i][0]
	if up[k] >= int(UPS[i][3]) or gold < _cost(i):
		beep(220.0, 0.12, 160.0, 0.2)
		return
	gold -= _cost(i)
	up[k] += 1
	_save()
	play("good")
	_lobby_refresh()


func _lobby_tap(p: Vector2) -> void:
	for i in 4:
		if _tab_r(i).has_point(p):
			if i != tab:
				play("tap")
				_set_tab(i)
			return
	match tab:
		0:
			for i in UPS.size():
				if _row_r(i).has_point(p):
					_buy(i)
					return
		1:
			if PLAY_R.has_point(p):
				_start_run()
			elif TUT_R.has_point(p):
				play("tap")
				_begin_tut()
		3:
			for i in 5:
				if _dex_r(i).has_point(p):
					dex_pick = i
					play("tap")
					_set_tab(3)
					return


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
