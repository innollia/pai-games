extends Tofu
## 일격의 길 (단독판): 빨간 쪽으로 밀어 막고, 초록 쪽으로 밀어 벤다. 끝까지 기다렸다 막으면 '간파'(세상이 느려짐).
## 켜면 튜토리얼부터: 맞는 쪽으로 밀 때까지 멈추고 알려 준다. 그다음 찌르기 → 속임수 → 베기 → 거합 검객이 두 바퀴 나오고
## (뒤로 갈수록 체력·공격력·빠르기가 오른다), 마지막은 쓰러뜨릴 수 없는 끝판왕 검귀. 간파하면 그 자리에서 내가 직접 벤다.
## 빈틈이 아닐 때 휘두르면 헛공격: 체력 -1, 잠깐 굳고, 상대가 바로 친다.
## 막을 때마다 돈(간파는 3배). 쓰러지면 상점에서 업그레이드하고 "플레이"로 첫 검객부터 다시. 돈·업그레이드는 저장된다.

const SWIPE := 60.0
const OFF := [Vector3(-1.5, 0, 0.7), Vector3(1.5, 0, 0.7), Vector3(0, 1.75, 0.7), Vector3(0, -1.75, 0.7)]
const LEAN := [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, -1, 0)]
const OPP := [1, 0, 3, 2]
## 내 칼 자세 (카메라 기준): 위치, z 회전 (왼·오·위·아래)
const POSE := [Vector3(-0.8, -0.1, 2.5), Vector3(0.8, -0.1, 2.5), Vector3(0, 0.55, 2.5), Vector3(0, -0.85, 2.5)]
const TURN := [0.25, -0.25, PI / 2, PI / 2]
const REST_P := Vector3(0.55, -1.25, 2.5)
const REST_R := -0.6
const CAM_O := Vector3(0, 0.3, 5)
const NAMES := ["찌르기 검객", "속임수 검객", "베기 검객", "거합 검객", "끝판왕 검귀"]
const TIPS := [
	"빨간 쪽으로 밀어 막아요",
	"반쯤에 방향이 바뀌어요. 끝까지 보고 막아요",
	"같은 쪽으로 두 번 와요!\n빨간 상자가 두 겹이면 한 번 더 막아요",
	"가만히 있다가 갑자기 뽑아요!\n눈이 번쩍하면 칼 쪽을 막아요. 먼저 치면 헛공격",
	"쓰러뜨릴 수 없어요. 오래 버티며 돈을 벌어요",
]
const BODY := [A, C, B, ME, INK]
const BOSS_AT := 8  # 이 번째(0부터)부터 끝판왕
const BOSS_HP := 9999
const SLOW := 0.3
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
	"빨간 상자 = 칼이 오는 쪽\n화면을 왼쪽으로 밀어서 막아요!",
	"막았어요! (실전에선 막을 때마다 돈 +1냥)\n초록 상자 쪽, 오른쪽으로 밀어서 베요!",
	"끝까지 기다렸다 막으면 '간파'!\n지금 위로 밀어요!",
	"간파: 돈 3배, 세상이 느려지고 빈틈이 길어요.\n아래로 밀어서 베요!",
]
## 업그레이드: 키, 이름, 첫 값, 최대 단계. 값은 단계마다 첫 값만큼 오른다.
const UPS := [
	["hp", "최대 체력", 5, 99],
	["pow", "베기 힘", 8, 99],
	["per", "간파 넓게", 6, 5],
	["earn", "막기 돈", 10, 99],
]

# 저장되는 것
var gold := 0
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
var ind: Array[Node3D] = []  # 공격 표시: 검은 테두리 + 색 면
var ind_c: Array[MeshInstance3D] = []  # 색 면 (앞, 두 겹째)
var ind_2: Array[Node3D] = []  # 두 겹째 (같은 쪽 한 번 더)
var blade_rest := Vector3(0.95, -0.3, 0.6)
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
# 화면 글자
var info_l: Label
var tut_box: ColorRect
var tut_l: Label
var skip_l: Label
var shop: Control
var shop_head: Label
var row_l: Array[Label] = []
var row_c: Array[Label] = []
var row_bg: Array[ColorRect] = []
var play_bg: ColorRect

const SKIP_R := Rect2(470, 1170, 250, 110)
const PLAY_R := Rect2(160, 1110, 400, 120)


func _row_r(i: int) -> Rect2:
	return Rect2(50, 420 + i * 132, 620, 116)


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
	best_n = int(d.get("best", 0))
	best_dmg = int(d.get("dmg", 0))
	var u: Variant = d.get("up", {})
	if u is Dictionary:
		for k: String in up:
			up[k] = int(u.get(k, 0))


func _save() -> void:
	var f := FileAccess.open(FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"gold": gold, "up": up, "best": best_n, "dmg": best_dmg}))


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
	# 튜토리얼 안내 (아래쪽 띠, 깜빡임)
	var tl := CanvasLayer.new()
	tl.layer = 3
	add_child(tl)
	tut_box = ColorRect.new()
	tut_box.color = Color(0.1, 0.07, 0.04, 0.82)
	tut_box.position = Vector2(0, 860)
	tut_box.size = Vector2(720, 300)
	tut_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tl.add_child(tut_box)
	tut_l = _label(tut_box, 38, 0, 300)
	tut_l.label_settings.font_color = WHITE
	tut_l.label_settings.outline_color = INK
	tut_l.label_settings.line_spacing = 6
	tut_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tut_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tut_l.position.x = 20
	tut_l.size.x = 680
	skip_l = _label(tl, 32, 1200, 60)
	skip_l.text = "건너뛰기 >"
	skip_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip_l.size.x = 696
	# 상점 (쓰러진 뒤)
	var sl := CanvasLayer.new()
	sl.layer = 4
	add_child(sl)
	shop = Control.new()
	shop.size = Vector2(720, 1280)
	shop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop.visible = false
	sl.add_child(shop)
	var dim := ColorRect.new()
	dim.color = Color(0.12, 0.08, 0.05, 0.78)
	dim.position = Vector2(0, 110)
	dim.size = Vector2(720, 1170)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop.add_child(dim)
	shop_head = _label(shop, 40, 150, 250)
	shop_head.label_settings.font_color = WHITE
	shop_head.label_settings.outline_color = INK
	shop_head.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for i in UPS.size():
		var r := _row_r(i)
		var bg := ColorRect.new()
		bg.position = r.position
		bg.size = r.size
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shop.add_child(bg)
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
	play_bg = ColorRect.new()
	play_bg.color = GOOD
	play_bg.position = PLAY_R.position
	play_bg.size = PLAY_R.size
	play_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop.add_child(play_bg)
	var pl := _label(play_bg, 56, 0, PLAY_R.size.y)
	pl.size.x = PLAY_R.size.x
	pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pl.text = "▶ 플레이"


func _shop_refresh(dead: bool) -> void:
	var head := ""
	if dead:
		if ftype == 4:
			head = "쓰러졌어요\n끝판왕에게 %d 피해 · 이번 판 +%d냥\n" % [boss_dmg, run_gold]
		else:
			head = "쓰러졌어요\n%d번째 · %s · 이번 판 +%d냥\n" % [n + 1, NAMES[ftype], run_gold]
	head += "가진 돈 %d냥 · 최고 %d명" % [gold, best_n]
	if best_dmg > 0:
		head += " · 끝판왕 %d 피해" % best_dmg
	shop_head.text = head
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


# ---- 판 ----
func _reset() -> void:
	_scenery()
	mark = Node3D.new()
	world.add_child(mark)
	ind.clear()
	ind_c.clear()
	ind_2.clear()
	for i in 4:
		var g := Node3D.new()
		g.position = OFF[i]
		g.visible = false
		mark.add_child(g)
		# 두 겹째: 오른쪽 위 뒤로 살짝 비켜서
		var g2 := Node3D.new()
		g2.position = Vector3(0.24, 0.24, -0.12)
		g.add_child(g2)
		box(Vector3.ZERO, Vector3(0.82, 0.82, 0.06), Color.BLACK, g2)
		var c2 := box(Vector3(0, 0, 0.04), Vector3(0.6, 0.6, 0.06), BAD, g2)
		box(Vector3.ZERO, Vector3(0.82, 0.82, 0.06), Color.BLACK, g)
		var c := box(Vector3(0, 0, 0.04), Vector3(0.6, 0.6, 0.06), BAD, g)
		ind.append(g)
		ind_c.append(c)
		ind_c.append(c2)
		ind_2.append(g2)
	rig = Node3D.new()
	world.add_child(rig)
	sword = box(REST_P, Vector3(0.12, 1.7, 0.12), WHITE, rig)
	sword.rotation.z = REST_R
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
	# 켜면 튜토리얼부터
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
	box(Vector3(0, -5.1, 0), Vector3(24, 6, 24), GOOD)
	for p: Vector3 in [Vector3(-5, 0, -2), Vector3(5.5, 0, -3), Vector3(-6, 0, 2), Vector3(-4, 0, -9), Vector3(6, 0, -10)]:
		box(p + Vector3(0, -1.3, 0), Vector3(0.35, 1.6, 0.35), INK)
		box(p + Vector3(0, 0.3, 0), Vector3(1.4, 1.8, 1.4), GOOD)
	for m: Vector3 in [Vector3(-12, 6, -45), Vector3(6, 10, -52), Vector3(20, 4, -42)]:
		box(m, Vector3(16, m.y * 2.0 + 6.0, 4), B)
		box(m + Vector3(0, m.y + 3.0, 0.2), Vector3(6, 2, 4), WHITE)


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
	var hp_y := 2.0
	var eye_y := 0.6
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
		4:
			# 끝판왕: 크고 검다, 붉은 눈, 금관
			body = box(Vector3(0, 0.1, 0), Vector3(2.4, 3.4, 1.2), col, piv)
			box(Vector3(0, 1.95, 0), Vector3(1.6, 0.4, 1.0), D, piv)
			for s in [-1.0, 0.0, 1.0]:
				box(Vector3(s * 0.55, 2.3, 0), Vector3(0.25, 0.4 if s == 0.0 else 0.28, 0.25), D, piv)
			hp_y = 2.9
			eye_y = 0.95
	body.set_meta("col", col)
	if ftype < 4:
		for i in mini(k / 2, 5):
			box(Vector3((i - (mini(k / 2, 5) - 1) * 0.5) * 0.36, 1.5, 0), Vector3(0.22, 0.3, 0.22), D, piv)
	for s in [-1.0, 1.0]:
		eyes.append(box(Vector3(s * 0.33, eye_y, 0.6 if ftype == 4 else 0.5), Vector3(0.24, 0.24, 0.06), INK, piv))
	blade_m = box(blade_rest, Vector3(0.12, 0.12, 2.0 if ftype == 2 else 1.6), WHITE, piv)
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
		mode_t = 2.6
		var hp_s := "∞" if ftype == 4 else str(foe_max)
		msg("%d번째 · %s\n체력 %s · 공격 %d\n%s" % [n + 1, NAMES[ftype], hp_s, foe_atk, TIPS[ftype]], 2.6)


func _start_run() -> void:
	tut = -1
	hold = false
	shop.visible = false
	tut_box.visible = false
	skip_l.visible = false
	n = 0
	max_life = _max_hp(up["hp"])
	life = max_life
	run_gold = 0
	stun = 0.0
	my_col = WHITE
	sword.material_override = mat(my_col)
	sword.visible = true
	slow = 0.0
	floor_m.material_override = mat(SOFT)
	_show(-1, BAD)
	_spawn(0)
	fl = Vector3(0, 0, -10)
	mode = "enter"
	mode_t = 1.0
	play("tap")


func _pat() -> Array:
	return PAT[ftype][ph]


func _show(d: int, color: Color, twice := false) -> void:
	for i in 4:
		ind[i].visible = i == d
	if d >= 0:
		ind[d].scale = Vector3.ONE
		ind_c[d * 2].material_override = mat(color)
		ind_c[d * 2 + 1].material_override = mat(color)
		ind_2[d].visible = twice


func _rest(g: float) -> void:
	fs = 0
	fs_t = 0.0
	gap = g * spd
	_show(-1, BAD)


func _relax(dt: float) -> void:
	fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 10.0))
	piv.rotation.z = lerpf(piv.rotation.z, 0.0, minf(1.0, dt * 10.0))
	blade_m.position = blade_m.position.lerp(blade_rest, minf(1.0, dt * 10.0))


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
		"enter":
			fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 4.0))
			if mode_t <= 0.0:
				_intro()
		"dead":
			sword.position = sword.position.lerp(Vector3(0.3, -3.0, 2.5), minf(1.0, dt * 4.0))
			sword.rotation.z = lerpf(sword.rotation.z, -1.5, minf(1.0, dt * 4.0))
			if mode_t <= 0.0:
				mode = "shop"
				_shop_refresh(true)
				shop.visible = true
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
	elif mode != "dead" and mode != "shop":
		sword.position = sword.position.lerp(REST_P, minf(1.0, dt * 12.0))
		sword.rotation.z = lerpf(sword.rotation.z, REST_R, minf(1.0, dt * 12.0))
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
	elif mode == "shop":
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
					var o2: Vector3 = OFF[sdir]
					blade_m.position = blade_m.position.lerp(Vector3(o2.x * 0.3, o2.y * 0.3 - 0.2, 0.6), minf(1.0, dt * 4.0))
					fl = fl.lerp(Vector3(0, -0.15, 0), minf(1.0, dt * 6.0))
				else:
					_relax(dt)
				if fs_t < show_at:
					return
				shown = true
				_eyes()
				_show(sdir, BAD)
				beep(1200.0, 0.05, 2400.0, 0.25)
			if feint_at >= 0.0 and fs_t >= feint_at and sdir != rdir:
				sdir = rdir
				_show(rdir, BAD, _twice_next())
				beep(880.0, 0.06, 500.0, 0.2)
			k = clampf((fs_t - show_at) / (win - show_at), 0.0, 1.0)
			var l: Vector3 = LEAN[sdir]
			fl = Vector3(l.x * 0.35 * k, l.y * 0.25 * k, 1.8 * k * k)
			piv.rotation.z = -l.x * 0.25 * k
			var o: Vector3 = OFF[sdir]
			blade_m.position = blade_m.position.lerp(Vector3(o.x * 0.6, o.y * 0.6, 0.9), minf(1.0, dt * 14.0))
			ind[sdir].scale = Vector3.ONE * (1.2 - 0.6 * k)
			if fs_t >= win:
				_hurt()
		2:
			k = clampf(fs_t / win, 0.0, 1.0)
			fl = fl.lerp(Vector3(0, 0, -0.7), minf(1.0, dt * 14.0))
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
			tut_l.text = "이번엔 빨간 상자가 작아질 때까지\n기다려요…"
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
		_show(-1, BAD)
		return
	win = float(mv[2]) * (1.0 if tut >= 0 else spd)
	if _flag(mv) == 1:
		win = maxf(0.22, win)
	show_at = 0.0
	tell_at = -1.0
	told = true
	shown = true
	feint_at = win * 0.5 if sdir != rdir else -1.0
	_show(sdir, BAD, _twice_next())
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
	_show(-1, BAD)
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


func _swing(d: int) -> void:
	if mode == "dead" or mode == "shop" or stun > 0.0:
		return
	sword.position = POSE[d]
	sword.rotation.z = TURN[d]
	sw_t = 0.16
	if tut >= 0:
		if not hold:
			return
		var want: int = rdir if fs == 1 else odir
		if d != want:
			msg("다른 쪽이에요!", 0.6)
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
	match fs:
		1:
			if not told:
				_whiff()
				return
			var fooled := feint_at >= 0.0 and fs_t < feint_at
			if d == rdir and not fooled:
				_parry(win - fs_t <= _per(up["per"]))
			else:
				_hurt()
		2:
			if d == odir:
				_cut()
				msg("베기!", 0.35)
			else:
				_whiff()
		0:
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
	_show(odir, GOOD)


func _cut() -> void:
	play("good")
	body.material_override = mat(GOOD)
	flash_t = 0.15
	fl = Vector3(0, 0, -1.2)
	fs = 4
	fs_t = 0.0
	_show(-1, BAD)
	if tut >= 0:
		return
	foe_hp -= _pow(up["pow"])
	if ftype == 4:
		boss_dmg += _pow(up["pow"])
		foe_hp = maxi(foe_hp, 1)  # 끝판왕은 쓰러지지 않는다
	_hp_bar()
	if foe_hp <= 0:
		var g := 5 + 3 * n
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
	tut = 4
	hold = true
	mode = "ready"
	_show(-1, BAD)
	tut_l.text = "준비 끝!\n막을 때마다 돈을 벌어요. 쓰러지면 그 돈으로\n강해져서 다시 싸워요. 갈수록 적이 세져요.\n\n탭해서 싸우러 가기"


func _tap(p: Vector2) -> void:
	if mode == "shop":
		for i in UPS.size():
			if _row_r(i).has_point(p):
				_buy(i)
				return
		if PLAY_R.has_point(p):
			_start_run()
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
	_shop_refresh(true)


func _drag(p: Vector2) -> void:
	if not armed:
		return
	var v := p - start
	if v.length() < SWIPE:
		return
	armed = false
	if absf(v.x) > absf(v.y):
		_swing(0 if v.x < 0.0 else 1)
	else:
		_swing(2 if v.y < 0.0 else 3)


func _lift(_p: Vector2) -> void:
	armed = false
