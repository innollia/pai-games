extends CanvasLayer
## 화면 밖 경주: 고르기·카운트다운·결과 화면 (Pocket Parcel Town 종이 공작).
## - 모드 고르기: 우표 카드 셋 (기본 / 밤 등불 / 과속) + 빨간 [출발!]
## - 특전·길 고르기: 가로로 긴 카드 둘, 누르면 [승인] 도장이 찍히고 넘어간다
## - 카운트다운: 준비 -> 차렷 -> 출발! 도장 + 종이 먼지
## - 결과: 배달 영수증 (찢은 종이, 펼쳐지는 0.45 s, 결과 도장, 코스 봉랍 메달, 버튼 둘)
## - tofu 평가 카드·설명 카드에 종이 옷 입히기 (자리·누르는 칸은 그대로)
## 쓰는 법: var menus = preload("res://g/sr_menus.gd").new(); add_child(menus); menus.setup(self)
## 이음 설명: submit/screenrace/work/ui/INTEGRATE_sr_menus.md

const T = preload("res://g/sr_theme.gd")

signal mode_chosen(id: String)   # "base" / "lantern" / "over"
signal back_pressed
signal lang_pressed
signal perk_chosen(index: int)   # 0 = 위 카드, 1 = 아래 카드
signal route_chosen(index: int)
signal again_pressed
signal title_pressed

const MODE_IDS := ["base", "lantern", "over"]
const MODE_ART := {"base": "mode_classic", "lantern": "mode_lantern", "over": "mode_rush"}
const MODE_ICON := {"base": "icon_parcel", "lantern": "icon_lantern", "over": "icon_flag"}
## 카드에는 한 줄 규칙만 (좁은 카드에서 줄이 넘치지 않게)
const MODE_SHORT := {"base": ["짐을 던져 앞서기", "Drop boxes to get ahead"],
	"lantern": ["빛 안에 머물기", "Stay in the light"],
	"over": ["짐 2개 이하: 천장 부스트", "2 boxes or less: ceiling boost"]}
const MODE_GLYPH := {"base": "parcel", "lantern": "lantern", "over": "rush"}
const PERK_ICON := {"신발": "icon_shoe", "끈": "icon_strap", "용수철": "icon_spring", "바람": "icon_wind",
	"가벼운 상자": "icon_feather_box", "단단한 몸": "icon_shield"}
const ROUTE_ICON := {"gate": "icon_gate", "slide": "icon_ice", "wind": "icon_headwind"}
const ROUTE_GLYPH := {"gate": "gate", "slide": "ice", "wind": "headwind"}

const CARD_W := 190.0
const CARD_H := 460.0
const CARD_Y := 490.0   # 엄지 닿는 아래쪽, 가운데 쯤 (490..950): 빈 아랫단 없이
const CARD_X := [40.0, 265.0, 490.0]
const CH_X := 50.0
const CH_Y := [630.0, 850.0]   # 카드 둘은 엄지 쪽 (630..1030): 위로는 동네가 비쳐 보인다
const CH_HEAD_Y := 508.0        # '특전 고르기' 제목: 첫 카드 약 90 px 위
const CH_SIZE := Vector2(620, 180)
const RATE_BTN := Rect2(620, 0, 100, 100)     # tofu _RATE_BTN: 특전·길 화면에서는 눌리지 않게 막는다
const RC_POS := Vector2(50, 330)      # 영수증은 y 330..830: 바로 아래 절취선(840), tofu 별(860~980) 이 이어진다
const RC_SIZE := Vector2(620, 500)
const RC_STAMP_Y := 100.0             # 영수증 안 결과 도장 가운데
const DUST_N := 22
const OLD_STAR := Color("fcc419")     # tofu 의 채운 별 색 (D)
const WORD_RECT := Rect2(200, 1000, 320, 90)   # tofu _WORD_RECT 와 같게
const STAR_RECT := Rect2(100, 860, 520, 120)   # tofu _STAR_RECT 와 같게 (누르는 칸은 tofu 가 고정 좌표로 본다)
const STUB_RECT := Rect2(50, 816, 620, 364)    # 영수증 바로 이어 붙은 평가 칸 (RC_POS.y + RC_SIZE.y - 14): 한 장의 종이, 사이 틈 없음
const STUB_H0 := 194.0     # 별을 누르기 전: 절취선 + 별 줄까지 (y 816..1010)
const STUB_H1 := 364.0     # 별을 누른 뒤: '한마디 남기기' 글 고리 + 고마워요 줄까지 (..1180)
const WASH_A := 0.5        # 모든 메뉴 덮개 (모드·특전·길·결과·평가): 같은 크림 종이, 동네가 비쳐 보이게
const STATUS_EN := {"고마워요!": "Thanks!", "보내는 중": "Sending...", "한마디 보냈어요": "Comment sent",
	"저장 안 됨 · 별을 다시 탭": "Not saved · tap a star again"}

## 판 사람이 고르기 화면에서 아무것도 안 해도 넘어가게 (smoke 시험용, 화면 없는 실행에서만).
var auto_headless := true
var show_lang := false  # 최소 UI: 언어는 제목 화면, 처음으로는 왼쪽 위 집 아이콘이 맡는다
var show_back := false

var game
var screen := ""   # "" / "mode" / "perk" / "route" / "results"

var _wash_layer: CanvasLayer
var _wash: Control
var _wash_a := 0.0

# 모드
var _mode_root: Control
var _mode_cards: Array = []
var _mode_over: Array = []
var _mode_last := PackedFloat32Array()
var _mode_sel := 0
var _mode_title: Label
var _mode_sub: Label
var _go_btn
var _back_btn
var _lang_btn
var _locked := false

# 특전·길
var _ch_root: Control
var _ch_cards: Array = []
var _ch_over: Array = []
var _ch_head: Label
var _ch_sub: Label
var _ch_cargo: Control
var _ch_ids: Array = []
var _ch_kind := ""
var _ch_n := 0
var _ch_key := 0
var _ch_last := PackedFloat32Array()
var _ch_block: Control
var _approved: Control
var _approved_d := {}

# 카운트다운
var _count_root: Control
var _count_stamp: Control
var _count_d := {}
var _count_hide := 0.0

# 결과
var _res_root: Control
var _rc_clip: Control
var _receipt: Control
var _rc_stamp: Control
var _rc_stamp_d := {}
var _again_btn
var _title_btn
var _res := {}
var _stub_layer: CanvasLayer
var _stub: Control
var _stub_a := 0.0
var _word_btn: Control
var _word_mode := -1   # 0 숨김 / 1 결과 영수증의 글 고리 / 2 평가 카드의 종이 버튼
var _swallow: Swallow
var _holes_plain: Array[Rect2] = [STAR_RECT]
var _holes_rated: Array[Rect2] = [STAR_RECT, WORD_RECT]
var _stub_h := STUB_H0
var _res_t := 0.0
var _fold := 1.0
var _wave := PackedVector2Array()

# 종이 먼지
var _dust: Control
var _dp := PackedVector2Array()
var _dv := PackedVector2Array()
var _dr := PackedFloat32Array()
var _dlife := 0.0

var _auto_t := 0.0
var _tw_of := {}
var _restyled_rate := false
var _restyled_howto := false


## 무엇이든 그리는 빈 판: fn(self) 를 부른다.
class Painter extends Control:
	var fn: Callable

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if fn.is_valid():
			fn.call(self)


## 결과 화면의 빈 곳 탭을 삼킨다 (tofu 가 처음 화면으로 보내지 않게). holes 안은 tofu 로 보낸다.
class Swallow extends Control:
	var holes: Array[Rect2] = []

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _has_point(p: Vector2) -> bool:
		for r in holes:
			if r.has_point(p):
				return false
		return Rect2(Vector2.ZERO, size).has_point(p)


func _init() -> void:
	layer = 15


func setup(g) -> void:
	game = g
	_build()
	_late_restyle.call_deferred()


func _L(ko: String, en: String) -> String:
	if game == null:
		return en
	return str(game.L(ko, en))


func _snd(name: String) -> void:
	if game != null and game.has_method("_sfx"):
		game._sfx(name)


# ================================================================ 만들기
func _build() -> void:
	# 바탕 종이는 맨 아래 층(0): 3D 위, tofu 글(뒤로·평가 1)·별점(9) 아래라 그것들을 가리지 않는다
	_wash_layer = CanvasLayer.new()
	_wash_layer.layer = 0
	add_child(_wash_layer)
	_wash = _painter(_wash_layer, Vector2(720, 1280), _draw_wash)
	_wash.hide()

	# ---- 모드
	_mode_root = _root()
	_mode_title = T.make_label("", T.FS_H1, T.NAVY, 10, T.CREAM)   # 덮개가 옅어도 동네 위에서 읽히게 크림 테두리
	_place(_mode_title, _mode_root, Vector2(20, 412), Vector2(680, 64))
	_mode_sub = T.make_label("", 24, T.MUTED)
	_place(_mode_sub, _mode_root, Vector2(20, 230), Vector2(680, 44))
	for i in 3:
		var c = T.PaperCard.new()
		c.size = Vector2(CARD_W, CARD_H)
		c.position = Vector2(CARD_X[i], CARD_Y)
		_mode_root.add_child(c)
		c.pressed.connect(_on_mode_card.bind(i))
		var o := _painter(c, c.size, _draw_mode_over.bind(i))
		_mode_cards.append(c)
		_mode_over.append(o)
	_mode_last.resize(6)
	_go_btn = T.PaperButton.new()
	_go_btn.face = T.RED
	_go_btn.font_size = 40
	_go_btn.size = Vector2(460, 108)
	_go_btn.position = Vector2(130, 868)
	_mode_root.add_child(_go_btn)
	_go_btn.pressed.connect(_start_mode)
	_back_btn = T.PaperButton.new()
	_back_btn.face = T.KRAFT
	_back_btn.text_color = T.NAVY
	_back_btn.font_size = 26
	_back_btn.size = Vector2(220, 88)
	_back_btn.position = Vector2(40, 1132)
	_mode_root.add_child(_back_btn)
	_back_btn.pressed.connect(func() -> void:
		_snd("stamp")
		back_pressed.emit())
	_lang_btn = T.PaperButton.new()
	_lang_btn.face = T.CREAM
	_lang_btn.text_color = T.BLUE
	_lang_btn.font_size = 26
	_lang_btn.size = Vector2(220, 88)
	_lang_btn.position = Vector2(460, 1132)
	_mode_root.add_child(_lang_btn)
	_lang_btn.pressed.connect(func() -> void:
		_snd("stamp")
		lang_pressed.emit())

	# ---- 특전·길
	_ch_root = _root()
	_ch_head = T.make_label("", T.FS_H1, T.NAVY, 10, T.CREAM)
	_place(_ch_head, _ch_root, Vector2(20, CH_HEAD_Y), Vector2(680, 64))
	_ch_sub = T.make_label("", T.FS_BODY, T.BLUE)
	_place(_ch_sub, _ch_root, Vector2(20, 462), Vector2(680, 44))
	_ch_sub.hide()
	_ch_cargo = _painter(_ch_root, Vector2(720, 60), _draw_cargo_row)
	_ch_cargo.position = Vector2(0, 378)
	for i in 2:
		var c = T.PaperCard.new()
		c.horizontal = true
		c.size = CH_SIZE
		c.position = Vector2(CH_X, CH_Y[i])
		_ch_root.add_child(c)
		c.pressed.connect(_on_choice.bind(i))
		var o := _painter(c, c.size, _draw_choice_over.bind(i))
		_ch_cards.append(c)
		_ch_over.append(o)
	_ch_last.resize(4)
	_ch_cargo.hide()   # 내 짐 줄은 빼고 카드 한 줄 ('지나간다' / '무거울수록 빠르다') 이 말한다
	_approved = _painter(_ch_root, Vector2(10, 10), _draw_stamp.bind(_approved_d))
	_approved.hide()
	# 특전·길은 판 중간: 오른쪽 위 평가 칸을 눌러도 평가 카드가 뜨지 않게 삼킨다 (평가는 모드 화면·결과 영수증에서)
	_ch_block = Control.new()
	_ch_block.mouse_filter = Control.MOUSE_FILTER_STOP
	_place(_ch_block, _ch_root, RATE_BTN.position, RATE_BTN.size)

	# ---- 카운트다운
	_count_root = _root()
	_count_stamp = _painter(_count_root, Vector2(10, 10), _draw_stamp.bind(_count_d))

	# ---- 결과 영수증
	_res_root = _root()
	# 왼쪽 위 뒤로 칸은 구멍으로 두지 않는다: 결과에서는 영수증의 집 단추 하나가 처음으로 가는 길
	_swallow = Swallow.new()
	_swallow.size = Vector2(720, 1280)
	_swallow.holes = _holes_plain
	_res_root.add_child(_swallow)
	# 별점 쪽지는 tofu 별(층 9) 아래 층 8 에 그린다: 별이 영수증 쪽지 안에 앉는다
	_stub_layer = CanvasLayer.new()
	_stub_layer.layer = 8
	add_child(_stub_layer)
	_stub = _painter(_stub_layer, STUB_RECT.size, _draw_stub)
	_stub.position = STUB_RECT.position
	_stub_layer.visible = false
	_rc_clip = Control.new()
	_rc_clip.clip_contents = true
	_rc_clip.mouse_filter = Control.MOUSE_FILTER_STOP   # 영수증을 눌러도 바로 다시 시작되지 않게
	_rc_clip.position = RC_POS
	_rc_clip.size = Vector2(RC_SIZE.x, 0)
	_res_root.add_child(_rc_clip)
	_receipt = _painter(_rc_clip, RC_SIZE, _draw_receipt)
	_rc_stamp = _painter(_receipt, Vector2(10, 10), _draw_stamp.bind(_rc_stamp_d))
	_again_btn = T.PaperButton.new()
	_again_btn.face = T.RED
	_again_btn.font_size = 36
	_again_btn.size = Vector2(420, 100)
	_again_btn.position = Vector2(36, 360)
	_receipt.add_child(_again_btn)
	_again_btn.pressed.connect(func() -> void:
		_snd("stamp")
		again_pressed.emit())
	_title_btn = T.PaperButton.new()
	_title_btn.face = T.WHITE   # 왼쪽 위 집 아이콘과 같은 흰 동그라미 + 남색 집
	_title_btn.text_color = T.NAVY
	_title_btn.font_size = 28
	_title_btn.radius = 48.0
	_title_btn.size = Vector2(96, 104)
	_title_btn.position = Vector2(484, 358)
	_receipt.add_child(_title_btn)
	var house := _painter(_title_btn, _title_btn.size, _draw_house)
	house.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_btn.pressed.connect(func() -> void:
		_snd("stamp")
		title_pressed.emit())
	_wave.resize(13)

	# ---- 종이 먼지 (맨 위)
	_dust = _painter(self, Vector2(720, 1280), _draw_dust)
	_dp.resize(DUST_N)
	_dv.resize(DUST_N)
	_dr.resize(DUST_N)
	_dust.hide()

	for r in [_mode_root, _ch_root, _count_root, _res_root]:
		(r as Control).hide()


func _root() -> Control:
	var r := Control.new()
	r.size = Vector2(720, 1280)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE   # 빈 곳 탭은 tofu 로 (뒤로·평가 칸 살림)
	r.pivot_offset = r.size * 0.5
	add_child(r)
	return r


func _painter(parent: Node, sz: Vector2, fn: Callable) -> Control:
	var p := Painter.new()
	p.size = sz
	p.fn = fn
	parent.add_child(p)
	return p


func _place(c: Control, parent: Node, pos: Vector2, sz: Vector2) -> void:
	c.position = pos
	c.size = sz
	parent.add_child(c)


# ================================================================ 공개 API
## 모드 고르기 화면 (phase "mode").
func show_modes() -> void:
	hide_all()
	screen = "mode"
	_locked = false
	_auto_t = 0.0
	_mode_sel = 0
	_fill_modes()
	_wash_to(WASH_A)
	_open_root(_mode_root)
	for i in 3:
		var c = _mode_cards[i]
		c.selected = false
		c.sel_k = 0.0
		c.disabled = false
		_pop(c, 0.05 + 0.07 * i)
	# 처음 온 사람: 기본(Classic)을 들어 올려 '여기부터' 를 보여 준다 (새 글·버튼 없이)
	if game != null and int(game.records.get_value("base", "delivered", 0)) <= 0:
		var tw := _mode_root.create_tween()
		tw.tween_interval(0.42)
		tw.tween_callback(func() -> void:
			if screen == "mode" and not _locked and _mode_sel == 0:
				_mode_cards[0].selected = true)
	_go_btn.visible = false  # 최소 UI: 카드를 누르면 바로 출발
	_mode_sub.visible = false
	_back_btn.visible = show_back
	_lang_btn.visible = show_lang


## 말(언어)을 바꾼 뒤 지금 화면 글을 다시 채운다.
func refresh() -> void:
	if screen == "mode":
		_fill_modes()
	elif screen == "perk" or screen == "route":
		_fill_choice()
	if _restyled_rate:
		restyle_rating(game)
	if _restyled_howto:
		restyle_howto(game)


## 특전 둘 (perk_offer). 고르면 perk_chosen(0/1).
func show_perks(ids: Array) -> void:
	_show_choice("perk", ids, 0)


## 다음 길 둘 (route_offer) + 내 짐 수. 고르면 route_chosen(0/1).
func show_routes(ids: Array, cargo: int) -> void:
	_show_choice("route", ids, cargo)


## 카운트다운: 0 = 준비 (pt 1.4), 1 = 차렷 (pt 0.7), 2 = 출발! (pt 0, 경주 시작). 2 뒤 0.6 s 에 스스로 사라진다.
func countdown_tick(stage: int) -> void:
	if stage < 0 or stage > 2:
		hide_countdown()
		return
	if screen != "":
		hide_all()
	_kill(_count_root)
	_count_root.show()
	_count_root.modulate.a = 1.0
	_count_root.scale = Vector2.ONE
	var txt: String = [_L("준비", "READY"), _L("차렷", "SET"), _L("출발!", "DELIVER!")][stage]
	var ink: Color = [T.RED, T.GOLD, T.GREEN][stage]
	var fs: int = [60, 68, 92][stage]
	var rot: float = [-4.0, 3.0, 0.0][stage]
	_set_stamp(_count_stamp, _count_d, txt, ink, fs, rot, Vector2(360, 560))
	T.stamp_slam(_count_stamp)
	if stage == 2:
		_burst(Vector2(360, 560), 1.4)
		_count_hide = 0.6
	else:
		_snd("stamp")
		_count_hide = 0.0


func hide_countdown() -> void:
	if _count_root.visible:
		_close_root(_count_root)
	_count_hide = 0.0


## 결과 영수증. data 열쇠는 INTEGRATE_sr_menus.md 참고 (빠진 열쇠는 기본값).
func show_results(data: Dictionary) -> void:
	hide_all()
	screen = "results"
	_res = data
	_res_t = 0.0
	_fold = 1.0
	_wash_to(WASH_A)
	_open_root(_res_root)
	_again_btn.text = _L("다시 배달", "PLAY AGAIN")
	_title_btn.text = ""  # 집 그림 (처음으로)
	_again_btn.disabled = true
	_title_btn.disabled = true
	var won := bool(data.get("won", false))
	var place := int(data.get("placement", 1 if won else 2))
	var txt := (_L("%d위 · 배달 완료", "#%d · DELIVERED") if won else _L("%d위 · 반송", "#%d · RETURNED")) % place
	_set_stamp(_rc_stamp, _rc_stamp_d, txt, T.GREEN if won else T.RED, 50, -8.0, Vector2(310, RC_STAMP_Y))
	_rc_stamp.hide()
	_receipt.queue_redraw()
	_stub_a = 0.0
	_stub_h = STUB_H0
	_word_mode = -1
	_stub.queue_redraw()
	_kill(_rc_clip)
	_rc_clip.size = Vector2(RC_SIZE.x, 0)
	var tw := _rc_clip.create_tween()
	tw.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(_rc_clip, "size:y", RC_SIZE.y, 0.45)
	tw.parallel().tween_method(_set_fold, 1.0, 0.0, 0.45)
	tw.tween_callback(func() -> void:
		_rc_stamp.show()
		T.stamp_slam(_rc_stamp)
		_snd("stamp")
		if won:
			_burst(RC_POS + Vector2(310, RC_STAMP_Y), 1.0)   # 종이 꽃가루는 배달 완료에만
		else:
			# 반송: 축하 대신 도장이 쿵 하고 한 번 더 떨린다 (쾅 뒤 작은 흔들림이 끝난 다음)
			var sh := _rc_stamp.create_tween()
			sh.tween_interval(T.T_STAMP + 0.14)
			sh.tween_callback(func() -> void: T.shake(_rc_stamp, 4.0, 0.2)))
	tw.tween_method(_set_stub, 0.0, 1.0, 0.2)
	_tw_of[_rc_clip] = tw


## 모든 고르기·결과 화면을 닫는다 (카운트다운은 그대로). restart/_reset 에서 부른다.
func hide_all() -> void:
	screen = ""
	_locked = false
	for r in [_mode_root, _ch_root, _res_root]:
		var c := r as Control
		_kill(c)
		c.hide()
		c.modulate.a = 1.0
		c.scale = Vector2.ONE
	_approved.hide()
	_stub_a = 0.0
	_wash_to(0.0)


## tofu 평가 카드(_rate_box)에 종이 옷. 자리·크기·누르는 칸(_STAR_RECT/_WORD_RECT/_CLOSE_RECT)은 그대로.
## 평가는 결과 영수증의 별 줄 하나가 맡는다 (판이 끝나면 tofu 가 별을 그 자리에서 받는다, 카드를 열지 않는다).
## 이 카드는 다른 길로 열릴 때만 보인다: 그때도 다른 화면과 같은 크림 덮개 + 찢은 영수증 종이, 단추는 '한마디' 하나, '닫기' 는 글 고리.
func restyle_rating(g) -> void:
	if g == null:
		return
	var extra: Array = g._rate_extra
	if extra.size() >= 4:
		var dim := extra[0] as ColorRect
		if dim:
			dim.color = Color(T.CREAM, WASH_A)   # 다른 메뉴와 같은 크림 덮개 (회색으로 죽이지 않는다)
			if not dim.has_node(^"SrGrain"):
				var gr := _painter(dim, dim.size, _draw_rate_grain)
				gr.name = "SrGrain"
		var panel := extra[1] as ColorRect
		if panel:
			panel.color = Color(0, 0, 0, 0)
			if not panel.has_node(^"SrPaper"):
				var pp := _painter(panel, panel.size, _draw_rate_panel)   # 결과 영수증과 같은 찢은 종이
				pp.name = "SrPaper"
		var title := extra[2] as Label
		if title:
			title.text = _L("이 게임 어때요?", "How was the delivery?")
			_ink(title, T.NAVY, 0)
			title.label_settings.font_size = 32
		var shut := extra[3] as ColorRect
		if shut:
			shut.color = Color(0, 0, 0, 0)   # 종이 단추 없이 남색 글 고리: 단추는 '한마디' 하나뿐
			for ch in shut.get_children():
				if ch is Label:
					var sl := ch as Label
					sl.text = _L("닫기", "Close")
					_ink(sl, T.NAVY, 0)
					sl.label_settings.font_size = 28
					sl.position.y = -16.0   # 글은 '한마디' 쪽으로 조금 올리고 누르는 칸(_CLOSE_RECT)은 그대로
	var stars: Array = g._stars
	for l in stars:
		var ls := (l as Label).label_settings
		ls.outline_color = T.WHITE   # 얇은 흰 종이 테두리 (굵은 남색 윤곽 대신)
		ls.outline_size = 4
	var box := g._rate_box as Control
	if box:
		var wr := WORD_RECT
		for ch in box.get_children():
			if ch is ColorRect and (ch as ColorRect).position == wr.position and (ch as ColorRect).size == wr.size:
				var wb := ch as ColorRect
				wb.color = Color(0, 0, 0, 0)
				_paper_under(wb, T.panel(T.KRAFT, T.WHITE, 18, 4, 8))   # PaperButton 과 같은 둥글기·그림자
				_word_btn = wb
	_word_mode = -1   # 글을 다시 채운다 (말 바꿈)
	_apply_word_mode(2 if bool(g._rating) else 0)
	var st := g._rate_status as Label
	if st:
		_ink(st, T.NAVY, 10, T.CREAM)
	var rb := g._rate_btn_l as Label
	if rb:
		rb.text = _L("평가", "Rate")
		_ink(rb, T.NAVY, 10, T.WHITE)
	_restyled_rate = true


## '한마디' 모습: 0 숨김 / 1 결과 영수증 아래 작은 파란 글 고리 (별을 누른 뒤) / 2 평가 카드의 종이 단추.
func _apply_word_mode(m: int) -> void:
	if m == _word_mode:
		return
	_word_mode = m
	if _swallow != null:
		_swallow.holes = _holes_rated if m == 1 else _holes_plain   # 글 고리일 때만 그 칸을 tofu 로 보낸다
	if _word_btn == null:
		return
	_word_btn.visible = m != 0
	var paper := _word_btn.get_node_or_null(^"SrPaper") as Control
	if paper:
		paper.visible = m == 2
	for l in _word_btn.get_children():
		if l is Label:
			var lb := l as Label
			if m == 1:
				lb.text = _L("한마디 남기기", "Add a comment")
				_ink(lb, T.BLUE, 0)
				lb.label_settings.font_size = 26
			else:
				lb.text = _L("한마디", "Comment")
				_ink(lb, T.NAVY, 0)
				lb.label_settings.font_size = 32


## tofu 설명 카드(_howto_box)에 종이 옷 (다른 모듈이 대신하면 안 불러도 된다).
func restyle_howto(g) -> void:
	if g == null:
		return
	var card := g._howto_box as ColorRect
	if card == null:
		return
	card.color = Color(0, 0, 0, 0)
	_paper_under(card, T.panel(T.CREAM, T.KRAFT_SH, T.RADIUS, 4, 8))
	var n := 0
	for ch in card.get_children():
		if ch is Label:
			var l := ch as Label
			if n == 0:
				l.text = str(g.howto)
				_ink(l, T.NAVY, 0)
			else:
				l.text = _L("탭해서 시작", "Tap to start")
				_ink(l, T.RED, 0)
			n += 1
	_restyled_howto = true


# ================================================================ 모드
func _fill_modes() -> void:
	_mode_title.text = _L("배달 방식", "Pick a delivery")
	_mode_sub.text = ""
	for i in 3:
		var id: String = MODE_IDS[i]
		var c = _mode_cards[i]
		c.title = str(game._mode_name(id))
		var short: Array = MODE_SHORT[id]
		c.body = _L(str(short[0]), str(short[1]))
		c.art_name = MODE_ART[id]
		c.icon_name = MODE_ICON[id]
		if id == "lantern":
			c.paper = T.NIGHT
			c.accent = T.AMBER
			c.title_color = T.AMBER
			c.body_color = T.CREAM
		elif id == "over":
			c.accent = T.RED
		else:
			c.accent = T.BLUE
		c.queue_redraw()
		(_mode_over[i] as Control).queue_redraw()
	_go_btn.text = _L("출발!", "DELIVER!")
	_back_btn.text = _L("< 처음", "< Title")
	_lang_btn.text = _L("English", "한국어")


func _on_mode_card(i: int) -> void:
	if _locked or screen != "mode":
		return
	_select_mode(i, false)
	_start_mode()


func _select_mode(i: int, sound: bool) -> void:
	_mode_sel = clampi(i, 0, 2)
	for k in 3:
		_mode_cards[k].selected = k == _mode_sel
	if sound:
		_snd("stamp")


func _start_mode() -> void:
	if _locked or screen != "mode":
		return
	_locked = true
	var id: String = MODE_IDS[_mode_sel]
	_snd("bell")
	var cc: Control = _mode_cards[_mode_sel]
	_burst(cc.position + cc.size * 0.5, 0.8)
	for k in 3:
		if k != _mode_sel:
			_close(_mode_cards[k])
	_close_root(_mode_root, 0.22)
	_wash_to(0.0)
	screen = ""
	mode_chosen.emit(id)


# ================================================================ 특전·길
func _show_choice(kind: String, ids: Array, cargo: int) -> void:
	hide_all()
	screen = kind
	_ch_kind = kind
	_ch_ids = ids.duplicate()
	_ch_n = cargo
	_ch_key = 0
	_locked = false
	_auto_t = 0.0
	_approved.hide()
	_fill_choice()
	_wash_to(WASH_A)
	_open_root(_ch_root)
	for i in 2:
		var c = _ch_cards[i]
		c.selected = false
		c.sel_k = 0.0
		c.disabled = false
		c.modulate.a = 1.0
		_pop(c, 0.06 + 0.09 * i)
	_ch_last.fill(-1.0)
	T.bump(_ch_head, 1.12, 0.24)


func _fill_choice() -> void:
	var perk := _ch_kind == "perk"
	_ch_head.text = _L("특전 고르기", "Pick a perk") if perk else _L("다음 길은?", "Next road?")
	_ch_sub.text = ""  # 최소 UI: 길 고르기는 아래 소포 줄(내 짐)이 말한다
	for i in 2:
		if i >= _ch_ids.size():
			(_ch_cards[i] as Control).hide()
			continue
		var id: String = str(_ch_ids[i])
		var c = _ch_cards[i]
		if perk:
			c.title = str(game._perk(id))
			c.body = str(game._perk_say(id))
			c.icon_name = PERK_ICON.get(id, "icon_star")
			c.accent = T.GOLD   # 특전 = 보상: 늘 금색 띠
			c.body_color = Color(0, 0, 0, 0)
		else:
			c.title = str(game._tw(id, 0))
			var adv := _route_advice(id)
			c.body = str(adv[0])  # 한 줄에 규칙과 내 짐 수를 같이 (짐 줄을 따로 안 띄운다)
			c.body_color = adv[1] if id == "gate" else Color(0, 0, 0, 0)   # 문만 통과(초록)/막힘(빨강), 나머지는 기본 글색
			c.icon_name = ROUTE_ICON.get(id, "icon_flag")
			c.accent = T.KRAFT_SH   # 길 = 정보: 늘 골판지 띠 (색에 뜻을 싣지 않는다)
		c.queue_redraw()
		(_ch_over[i] as Control).queue_redraw()


func _on_choice(i: int) -> void:
	if _locked or (screen != "perk" and screen != "route"):
		return
	_locked = true
	var c = _ch_cards[i]
	c.selected = true
	for k in 2:
		_ch_cards[k].disabled = k != i
		if k != i:
			var tw := (_ch_cards[k] as Control).create_tween()
			tw.tween_property(_ch_cards[k], "modulate:a", 0.35, 0.18)
	var center: Vector2 = (c as Control).position + CH_SIZE * 0.5 + Vector2(150, 0)
	_set_stamp(_approved, _approved_d, _L("승인", "APPROVED"), T.GREEN, 44, -9.0, center)
	T.stamp_slam(_approved)
	_snd("stamp")
	_burst(center, 0.7)
	var kind := screen
	var done := _ch_root.create_tween()
	done.tween_interval(0.5)
	done.tween_callback(func() -> void:
		if screen != kind:
			return
		screen = ""
		_close_root(_ch_root)
		_wash_to(0.0)
		if kind == "perk":
			perk_chosen.emit(i)
		else:
			route_chosen.emit(i))


func _route_advice(id: String) -> Array:
	var n := maxi(_ch_n, 1)
	match id:
		"gate":
			var say := _L("짐 2개 이하만 통과 · 지금 %d개", "Only 2 boxes or fewer fit · you have %d") % n
			return [say, T.GREEN if n <= 2 else T.RED]
		"slide":
			return [_L("얼음: 무거울수록 빠르다", "Ice: heavier = faster"), T.BLUE]
		"wind":
			return [_L("앞사람 바로 뒤에 붙어라", "Tuck in right behind a rival"), T.BLUE]
	return ["", T.NAVY]


# ================================================================ 프레임
func _process(dt: float) -> void:
	if game == null:
		return
	# tofu 설명 카드(10)·평가 카드(9) 가 떠 있으면 비켜 준다
	var hb = game._howto_box
	var blocked := bool(game._rating) or (hb != null and (hb as Control).visible)
	visible = not blocked
	_wash_layer.visible = not blocked
	if _restyled_rate:
		_sync_rating()
	# 카운트다운 끝
	if _count_hide > 0.0:
		_count_hide -= dt
		if _count_hide <= 0.0:
			hide_countdown()
	# 카드 들림이 바뀔 때만 덧그림 다시
	if screen == "mode":
		for i in 3:
			var c = _mode_cards[i]
			var sk: float = c.sel_k
			var pk: float = c.press_k
			if absf(sk - _mode_last[i * 2]) > 0.001 or absf(pk - _mode_last[i * 2 + 1]) > 0.001:
				_mode_last[i * 2] = sk
				_mode_last[i * 2 + 1] = pk
				(_mode_over[i] as Control).queue_redraw()
	elif screen == "perk" or screen == "route":
		for i in 2:
			var c = _ch_cards[i]
			var sk: float = c.sel_k
			var pk: float = c.press_k
			if absf(sk - _ch_last[i * 2]) > 0.001 or absf(pk - _ch_last[i * 2 + 1]) > 0.001:
				_ch_last[i * 2] = sk
				_ch_last[i * 2 + 1] = pk
				(_ch_over[i] as Control).queue_redraw()
	elif screen == "results":
		_res_t += dt
		if _stub_layer.visible:
			_grow_stub(dt)
		if _res_t > 0.8 and bool(_again_btn.disabled):
			_again_btn.disabled = false
			_title_btn.disabled = false
	# 먼지
	if _dlife > 0.0:
		_dlife -= dt
		for i in DUST_N:
			_dv[i] = _dv[i] * (1.0 - 2.6 * dt) + Vector2(0, 260.0 * dt)
			_dp[i] += _dv[i] * dt
			_dr[i] += dt * (4.0 if i % 2 == 0 else -4.0)
		_dust.queue_redraw()
		if _dlife <= 0.0:
			_dust.hide()
	# 화면 없는 시험 실행: 고르기에서 멈추지 않게
	if auto_headless and not blocked and (screen == "mode" or screen == "perk" or screen == "route") and not _locked:
		if DisplayServer.get_name() == "headless":
			_auto_t += dt
			if _auto_t > 0.8:
				_auto_t = 0.0
				if screen == "mode":
					_start_mode()
				else:
					_on_choice(randi() % 2)


func _unhandled_input(e: InputEvent) -> void:
	if not visible or not (e is InputEventKey):
		return
	var k := e as InputEventKey
	if not k.pressed or k.echo:
		return
	var code := k.keycode
	var ok := code == KEY_ENTER or code == KEY_KP_ENTER or code == KEY_SPACE
	match screen:
		"mode":
			if code == KEY_LEFT or code == KEY_A:
				_select_mode((_mode_sel + 2) % 3, true)
			elif code == KEY_RIGHT or code == KEY_D:
				_select_mode((_mode_sel + 1) % 3, true)
			elif code >= KEY_1 and code <= KEY_3:
				_select_mode(code - KEY_1, true)
			elif ok:
				_start_mode()
			else:
				return
		"perk", "route":
			if code == KEY_UP or code == KEY_W or code == KEY_DOWN or code == KEY_S:
				_ch_key = 1 - _ch_key
				for i in 2:
					_ch_cards[i].selected = i == _ch_key
				_snd("stamp")
			elif code == KEY_1 or code == KEY_2:
				_on_choice(code - KEY_1)
			elif ok:
				_on_choice(_ch_key)
			else:
				return
		"results":
			if _res_t < 0.8:
				return
			if ok:
				again_pressed.emit()
			elif code == KEY_ESCAPE or code == KEY_BACKSPACE:
				title_pressed.emit()
			else:
				return
		_:
			return
	get_viewport().set_input_as_handled()


func _late_restyle() -> void:
	if game == null:
		return
	restyle_rating(game)
	restyle_howto(game)


## 별을 누른 뒤 쪽지 길이를 부드럽게 늘린다 (바뀌는 동안만 다시 그림).
func _grow_stub(dt: float) -> void:
	var want := STUB_H1 if int(game._rated) > 0 else STUB_H0
	if absf(_stub_h - want) < 0.5:
		return
	_stub_h = lerpf(_stub_h, want, minf(1.0, dt * 12.0))
	if absf(_stub_h - want) < 0.5:
		_stub_h = want
	_stub.queue_redraw()


func _set_stub(a: float) -> void:
	_stub_a = a
	_stub.queue_redraw()


## tofu 가 별 색을 직접 바꾸므로 (빈 별 SOFT / 채운 별 D) 매 프레임 우리 색으로 맞춘다. 별 5개뿐.
## 결과 화면에서는 별을 영수증 아래 쪽지 안에 두고 '한마디'는 숨긴다 (평가 카드에서는 보인다).
func _sync_rating() -> void:
	var box := game._rate_box as Control
	var on_res := screen == "results" and visible and not bool(game._rating)
	_stub_layer.visible = on_res and box != null and box.visible
	if box == null or not box.visible:
		return
	var want_a := _stub_a if on_res else 1.0
	if not is_equal_approx(box.modulate.a, want_a):
		box.modulate.a = want_a
	# 결과 영수증: 별을 누르기 전엔 별 줄만, 누른 뒤엔 쪽지가 조금 늘어나며 '한마디 남기기' 글 고리가 나온다
	if on_res:
		_apply_word_mode(1 if int(game._rated) > 0 else 0)
	else:
		_apply_word_mode(2 if bool(game._rating) else 0)
	var stars: Array = game._stars
	for l in stars:
		var ls := (l as Label).label_settings
		var on := ls.font_color.is_equal_approx(OLD_STAR) or ls.font_color.is_equal_approx(T.GOLD)
		var want := T.GOLD if on else T.EMPTY_SLOT   # 빈 별 = 빈 칸 색 (금색 스티커와 확 다르게)
		if not ls.font_color.is_equal_approx(want):
			ls.font_color = want
	if str(game.lang) == "en":
		var st := game._rate_status as Label
		if st and st.text != "":
			var en: String = STATUS_EN.get(st.text, st.text)
			if en != st.text:
				st.text = en


# ================================================================ 움직임
func _kill(n: Node) -> void:
	if _tw_of.has(n):
		var tw: Tween = _tw_of[n]
		if tw != null and tw.is_valid():
			tw.kill()
		_tw_of.erase(n)


func _pop(n: Control, delay: float) -> void:
	_kill(n)
	n.pivot_offset = n.size * 0.5
	_tw_of[n] = T.pop_in(n, delay)


func _close(n: Control) -> void:
	_kill(n)
	n.pivot_offset = n.size * 0.5
	var tw := n.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(n, "scale", Vector2(0.92, 0.92), T.T_CLOSE)
	tw.tween_property(n, "modulate:a", 0.0, T.T_CLOSE)
	_tw_of[n] = tw


func _open_root(r: Control) -> void:
	_kill(r)
	r.show()
	r.scale = Vector2.ONE
	r.modulate.a = 0.0
	var tw := r.create_tween()
	tw.tween_property(r, "modulate:a", 1.0, 0.16)
	_tw_of[r] = tw


func _close_root(r: Control, delay := 0.0) -> void:
	_kill(r)
	var tw := r.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(r, "modulate:a", 0.0, T.T_CLOSE)
	tw.tween_property(r, "scale", Vector2(0.96, 0.96), T.T_CLOSE)
	tw.chain().tween_callback(func() -> void:
		r.hide()
		r.modulate.a = 1.0
		r.scale = Vector2.ONE)
	_tw_of[r] = tw


func _wash_to(a: float) -> void:
	_kill(_wash)
	if a > 0.0:
		_wash.show()
	var tw := _wash.create_tween()
	tw.tween_method(_set_wash, _wash_a, a, 0.2)
	if a <= 0.0:
		tw.tween_callback(_wash.hide)
	_tw_of[_wash] = tw


func _set_wash(a: float) -> void:
	_wash_a = a
	_wash.queue_redraw()


func _set_fold(k: float) -> void:
	_fold = k
	_receipt.queue_redraw()


func _burst(at: Vector2, power: float) -> void:
	for i in DUST_N:
		var ang := TAU * float(i) / float(DUST_N) + randf_range(-0.2, 0.2)
		var sp := randf_range(260.0, 620.0) * power
		_dp[i] = at + Vector2(cos(ang), sin(ang)) * randf_range(20.0, 60.0)
		_dv[i] = Vector2(cos(ang), sin(ang) * 0.7) * sp
		_dr[i] = randf() * TAU
	_dlife = 0.55
	_dust.show()
	_dust.queue_redraw()


# ================================================================ 도장
func _set_stamp(p: Control, d: Dictionary, text: String, ink: Color, fs: int, rot_deg: float, center: Vector2) -> void:
	d["text"] = text
	d["ink"] = ink
	d["fs"] = fs
	var w := T.FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + fs * 1.4
	var h := float(fs) * 1.9
	p.size = Vector2(w, h)
	p.pivot_offset = p.size * 0.5
	p.position = center - p.size * 0.5
	p.rotation = deg_to_rad(rot_deg)
	if p.has_meta(&"_sr_shake_o"):
		p.remove_meta(&"_sr_shake_o")
	p.queue_redraw()


func _draw_stamp(ci: Control, d: Dictionary) -> void:
	if not d.has("text"):
		return
	var ink: Color = d.ink
	var fs: int = d.fs
	var r := Rect2(Vector2.ZERO, ci.size)
	# 종이 바탕 + 아래 그림자 + 잉크 두 줄 테두리
	T.draw_paper_rect(ci, r.grow(-4.0), Color(T.CREAM, 0.94), T.WHITE, 6.0, 10.0)
	ci.draw_rect(r.grow(-10.0), ink, false, maxf(4.0, fs * 0.09))
	ci.draw_rect(r.grow(-10.0 - fs * 0.16), Color(ink, 0.7), false, 2.0)
	var txt_c := ink.darkened(0.25) if ink == T.GOLD else ink
	T.draw_text_center(ci, str(d.text), r.get_center(), fs, txt_c)
	# 잉크가 덜 묻은 자국 (고정 무늬)
	for i in 9:
		var hx := fposmod(sin(float(i) * 12.99 + 3.1) * 4375.85, 1.0)
		var hy := fposmod(sin(float(i) * 78.23 + 1.7) * 4375.85, 1.0)
		ci.draw_circle(Vector2(14.0 + hx * (r.size.x - 28.0), 14.0 + hy * (r.size.y - 28.0)), 1.5 + hx * 2.0, Color(T.CREAM, 0.55))


# ================================================================ 그리기
func _draw_wash(ci: Control) -> void:
	if _wash_a <= 0.001:
		return
	var a := _wash_a
	ci.draw_rect(Rect2(0, 0, 720, 1280), Color(T.CREAM, a))
	T.draw_grain(ci, Rect2(0, 0, 720, 1280), 0.10 * a)


func _draw_mode_over(ci: Control, i: int) -> void:
	var c = _mode_cards[i]
	var id: String = MODE_IDS[i]
	var sk: float = c.sel_k
	var pk: float = c.press_k
	var lift := -10.0 * sk + pk * 6.0
	var sz: Vector2 = c.size
	var inner := Rect2(Vector2(18, 18 + lift), sz - Vector2(36, 44))
	var accent: Color = c.accent
	var paper: Color = c.paper
	# 그림이 없으면 아이콘 원 안에 직접 그린다 (머리글자 덮기)
	if T.tex(MODE_ART[id]) == null and T.tex(MODE_ICON[id]) == null:
		var cr := minf(inner.size.x * 0.28, 56.0)
		var cc := Vector2(inner.get_center().x, inner.position.y + 20.0 + cr + 6.0)
		ci.draw_circle(cc, cr, accent.lerp(T.WHITE, 0.75))
		_glyph(ci, MODE_GLYPH[id], cc, cr)
	# 속도 줄무늬 장식 (과속)
	if id == "over":
		for k in 3:
			var y := inner.position.y + 30.0 + k * 14.0
			ci.draw_line(Vector2(inner.end.x - 46.0 + k * 8.0, y), Vector2(inner.end.x - 12.0, y), Color(T.RED, 0.55), 4.0, true)
	# 카드 = 버튼: 아래 빨간 띠 + 흰 재생 화살표 (누르면 바로 출발)
	var strip := Rect2(inner.position.x, inner.end.y - 34.0, inner.size.x, 34.0)
	ci.draw_rect(strip, T.RED)
	var ac := strip.get_center()
	ci.draw_colored_polygon(PackedVector2Array([ac + Vector2(-8, -10), ac + Vector2(11, 0), ac + Vector2(-8, 10)]), T.WHITE)
	# 누르는 순간 금색 테두리
	if pk > 0.01:
		ci.draw_rect(Rect2(Vector2(10, 10 + lift), sz - Vector2(20, 28)).grow(10.0), Color(T.GOLD, pk), false, 4.0)
	# 최고 기록 꼬리표: 세 카드 모두 같은 자리 (기록이 없으면 점선 빈 칸 + '-')
	var best := 0
	if game != null:
		best = int(game.records.get_value(id, "delivered", 0))
	var tag := Rect2(inner.position.x + 8.0, strip.position.y - 50.0, inner.size.x - 16.0, 42.0)
	var s := _L("최고 ×%d", "Best ×%d") % best if best > 0 else "-"
	var ink := T.NAVY
	if best > 0:
		T.draw_paper_rect(ci, tag, T.CREAM, T.WHITE, 3.0, 10.0)
		ci.draw_rect(tag.grow(-1.0), Color(T.NAVY, 0.25), false, 2.0)
	else:
		ink = T.EMPTY_SLOT if paper != T.NIGHT else Color(T.CREAM, 0.5)
		var r := tag.grow(-2.0)
		var dc := Color(ink, 0.9)
		ci.draw_dashed_line(r.position, Vector2(r.end.x, r.position.y), dc, 2.0, 7.0)
		ci.draw_dashed_line(Vector2(r.position.x, r.end.y), r.end, dc, 2.0, 7.0)
		ci.draw_dashed_line(r.position, Vector2(r.position.x, r.end.y), dc, 2.0, 7.0)
		ci.draw_dashed_line(Vector2(r.end.x, r.position.y), r.end, dc, 2.0, 7.0)
	T.draw_parcel_icon(ci, Vector2(tag.position.x + 22.0, tag.get_center().y), 22.0, best > 0)
	var fs := _fit(s, 22, tag.size.x - 48.0)
	T.draw_text_center(ci, s, Vector2(tag.position.x + 40.0 + (tag.size.x - 44.0) * 0.5, tag.get_center().y), fs, ink, tag.size.x - 48.0)


func _draw_choice_over(ci: Control, i: int) -> void:
	if i >= _ch_ids.size():
		return
	var c = _ch_cards[i]
	var id: String = str(_ch_ids[i])
	var sk: float = c.sel_k
	var pk: float = c.press_k
	var lift := -10.0 * sk + pk * 6.0
	var inner := Rect2(Vector2(18, 18 + lift), CH_SIZE - Vector2(36, 44))
	var cr := minf(inner.size.y * 0.32, 52.0)
	var cc := Vector2(inner.position.x + 28.0 + cr, inner.get_center().y)
	var icon: String = c.icon_name
	if T.tex(icon) == null:
		var accent: Color = c.accent
		ci.draw_circle(cc, cr, accent.lerp(T.WHITE, 0.75))
		var g := "parcel"
		if _ch_kind == "route":
			g = ROUTE_GLYPH.get(id, "parcel")
		_glyph(ci, g, cc, cr)
	# 배지 테두리: 카드가 그린 남색 고리를 흰 종이 가장자리로 덮고, 아래로만 떨어진 그림자 (막대·단추와 같은 말씨)
	ci.draw_arc(cc + Vector2(0, 6), cr + 3.0, 0.15 * PI, 0.85 * PI, 24, T.SHADOW, 6.0, true)
	ci.draw_arc(cc, cr + 2.0, 0.0, TAU, 48, T.WHITE, 6.0, true)


func _draw_cargo_row(ci: Control) -> void:
	var n := clampi(_ch_n, 1, 8)
	var sz := 40.0
	var gap := 10.0
	var total := n * sz + (n - 1) * gap
	var x0 := 360.0 - total * 0.5 + sz * 0.5
	for k in n:
		T.draw_parcel_icon(ci, Vector2(x0 + k * (sz + gap), 30.0), sz, true)


func _draw_dust(ci: Control) -> void:
	var a := clampf(_dlife / 0.55, 0.0, 1.0)
	var cols := [T.KRAFT, T.CREAM, T.WHITE, T.GOLD]
	for i in DUST_N:
		var p := _dp[i]
		if i % 3 == 0:
			# 속도 줄 (흰 선)
			ci.draw_line(p, p - _dv[i] * 0.06, Color(T.WHITE, a * 0.9), 4.0, true)
			continue
		ci.draw_set_transform(p, _dr[i], Vector2.ONE)
		var col: Color = cols[i % 4]
		ci.draw_rect(Rect2(-8, -5, 16, 10), Color(T.KRAFT_SH, a * 0.5))
		ci.draw_rect(Rect2(-7, -6, 14, 10), Color(col, a))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## 그림 없을 때 쓰는 손그림 아이콘 (원 안).
func _glyph(ci: Control, kind: String, c: Vector2, r: float) -> void:
	match kind:
		"lantern":
			ci.draw_circle(c, r * 0.9, Color(T.AMBER, 0.45))
			ci.draw_arc(c - Vector2(0, r * 0.42), r * 0.22, PI, TAU, 12, T.NAVY, 3.0, true)
			ci.draw_rect(Rect2(c + Vector2(-r * 0.32, -r * 0.42), Vector2(r * 0.64, r * 0.12)), T.NAVY)
			var body := Rect2(c + Vector2(-r * 0.28, -r * 0.3), Vector2(r * 0.56, r * 0.68))
			ci.draw_rect(body, T.AMBER)
			ci.draw_rect(body, T.NAVY, false, 3.0)
			ci.draw_line(Vector2(c.x, body.position.y), Vector2(c.x, body.end.y), Color(T.NAVY, 0.6), 2.0)
			ci.draw_rect(Rect2(c + Vector2(-r * 0.32, r * 0.38), Vector2(r * 0.64, r * 0.1)), T.NAVY)
		"rush":
			for k in 3:
				var x := c.x - r * 0.55 + k * r * 0.36
				ci.draw_polyline(PackedVector2Array([Vector2(x, c.y - r * 0.42), Vector2(x + r * 0.32, c.y), Vector2(x, c.y + r * 0.42)]), T.RED, 7.0, true)
		"gate":
			ci.draw_rect(Rect2(c + Vector2(-r * 0.62, -r * 0.5), Vector2(r * 0.16, r * 1.05)), T.NAVY)
			ci.draw_rect(Rect2(c + Vector2(r * 0.46, -r * 0.5), Vector2(r * 0.16, r * 1.05)), T.NAVY)
			ci.draw_rect(Rect2(c + Vector2(-r * 0.62, -r * 0.2), Vector2(r * 1.24, r * 0.18)), T.RED)
			T.draw_parcel_icon(ci, c + Vector2(0, r * 0.28), r * 0.5, true)
		"ice":
			for k in 3:
				var ang := PI / 3.0 * k
				var d := Vector2(cos(ang), sin(ang)) * r * 0.66
				ci.draw_line(c - d, c + d, T.BLUE, 5.0, true)
				for s in [-1.0, 1.0]:
					var tip: Vector2 = c + d * s * 0.62
					var nrm := Vector2(-d.y, d.x).normalized() * r * 0.16
					ci.draw_line(tip, tip + d * s * 0.25 + nrm, T.BLUE, 3.0, true)
					ci.draw_line(tip, tip + d * s * 0.25 - nrm, T.BLUE, 3.0, true)
		"headwind":
			for k in 3:
				var y := c.y - r * 0.4 + k * r * 0.4
				var x0 := c.x - r * 0.55 + (k % 2) * r * 0.12
				ci.draw_line(Vector2(x0 + r * 0.18, y), Vector2(c.x + r * 0.6, y), T.BLUE, 5.0, true)
				ci.draw_line(Vector2(x0 + r * 0.18, y), Vector2(x0 + r * 0.4, y - r * 0.16), T.BLUE, 5.0, true)
				ci.draw_line(Vector2(x0 + r * 0.18, y), Vector2(x0 + r * 0.4, y + r * 0.16), T.BLUE, 5.0, true)
		_:
			T.draw_parcel_icon(ci, c, r * 1.1, true)


func _fit(s: String, fs: int, maxw: float) -> int:
	var f := fs
	while f > 14 and T.FONT.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, f).x > maxw:
		f -= 1
	return f


# ---------------------------------------------------------------- 영수증
func _draw_receipt(ci: Control) -> void:
	var W := RC_SIZE.x
	var H := RC_SIZE.y
	var d := _res
	# 그림자 + 종이 + 찢은 위아래
	ci.draw_rect(Rect2(6, 22, W - 12, H - 40), T.SHADOW)
	ci.draw_rect(Rect2(0, 14, W, H - 28), T.CREAM)
	T.draw_torn_edge(ci, Vector2(0, 15), Vector2(W, 15), T.CREAM, 12.0, 11)
	# 아래는 찢지 않는다: 평가 칸(_stub)이 바로 이어 붙어 한 장이 된다
	ci.draw_rect(Rect2(0, H - 16, W, 16), T.CREAM)
	T.draw_grain(ci, Rect2(0, 14, W, H - 28), 0.12)
	# (큰 결과 도장은 _rc_stamp 가 y RC_STAMP_Y 에 찍는다)
	# 한 줄: 소포 아이콘 × 배달한 짐 (모드 카드의 '최고 ×N' 과 같은 점수) + 새 기록이면 금색 표. 시간은 기록이 아니라 뺀다.
	var y := 190.0
	var n := int(d.get("delivered", 0))
	var line := "×%d" % n
	var fs := 34
	var tw := T.FONT.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var nr_w := 0.0
	var nt := _L("새 기록!", "NEW BEST!")
	var newrec := bool(d.get("new_record", false))
	if newrec:
		nr_w = T.FONT.get_string_size(nt, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x + 24.0
	var total := 44.0 + tw + (nr_w + 14.0 if newrec else 0.0)
	var x := W * 0.5 - total * 0.5
	T.draw_parcel_icon(ci, Vector2(x + 18.0, y), 34.0, true)
	ci.draw_string(T.FONT, Vector2(x + 44.0, y + T.FONT.get_ascent(fs) * 0.5 - 3.0), line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, T.NAVY)
	if newrec:
		var nr := Rect2(x + 44.0 + tw + 14.0, y - 19.0, nr_w, 38)
		T.draw_paper_rect(ci, nr, T.GOLD, T.WHITE, 3.0, 8.0)
		T.draw_text_center(ci, nt, nr.get_center(), 22, T.NAVY)
	if not bool(d.get("saved", true)):
		T.draw_text_center(ci, _L("기록 저장 안 됨", "record not saved"), Vector2(W * 0.5, y + 36.0), 22, T.MUTED)
	# 코스 봉랍 한 줄 (6 동네: 금·은·동, 못 간 동네는 빈 소포 칸)
	var medals: Array = d.get("medals", [])
	var gap := 92.0
	var x0 := W * 0.5 - gap * 2.5
	for k in 6:
		var m := int(medals[k]) if k < medals.size() else 0
		_seal(ci, Vector2(x0 + gap * float(k), 284.0), 30.0, m)
	# 접힌 자국 (펼쳐지며 사라짐)
	if _fold > 0.01:
		for k in 2:
			var fy := H * float(k + 1) / 3.0
			ci.draw_line(Vector2(8, fy), Vector2(W - 8.0, fy), Color(T.KRAFT_SH, 0.6 * _fold), 3.0)
			ci.draw_line(Vector2(8, fy + 3.0), Vector2(W - 8.0, fy + 3.0), Color(T.WHITE, 0.8 * _fold), 2.0)


## 처음으로 버튼 위 작은 집 그림.
func _draw_house(ci: Control) -> void:
	var c := Vector2(ci.size.x * 0.5, (ci.size.y - 8.0) * 0.5 + 2.0)   # 단추 면(아래 8 은 받침) 가운데
	var roof := PackedVector2Array([c + Vector2(-24, -2), c + Vector2(0, -24), c + Vector2(24, -2)])
	ci.draw_polyline(roof, T.NAVY, 6.0, true)
	ci.draw_rect(Rect2(c + Vector2(-16, -2), Vector2(32, 24)), T.NAVY)
	ci.draw_rect(Rect2(c + Vector2(-6, 8), Vector2(12, 14)), T.WHITE)


## 영수증 아랫단 (같은 종이): 점선 절취선 + 크림 종이 + 찢은 아래 끝. tofu 별 5개가 이 위(층 9)에 앉는다.
func _draw_stub(ci: Control) -> void:
	var W := STUB_RECT.size.x
	var H := _stub_h
	var a := _stub_a
	ci.draw_rect(Rect2(6, 8, W - 12, H - 16), Color(T.SHADOW, T.SHADOW.a * a))
	ci.draw_rect(Rect2(0, 0, W, H - 14), Color(T.CREAM, a))
	T.draw_torn_edge(ci, Vector2(W, H - 15), Vector2(0, H - 15), Color(T.CREAM, a), 12.0, 13)
	T.draw_grain(ci, Rect2(0, 0, W, H - 14), 0.12 * a)
	# 절취선: 영수증 단추 바로 아래, 별 줄 약 40 px 위
	ci.draw_dashed_line(Vector2(24, 24), Vector2(W - 24.0, 24), Color(T.NAVY, 0.3 * a), 2.0, 8.0)


## 평가 카드 종이: 결과 영수증과 같은 찢은 위아래 + 크림 + 아래 그림자.
func _draw_rate_panel(ci: Control) -> void:
	var W := ci.size.x
	var H := ci.size.y
	ci.draw_rect(Rect2(6, 22, W - 12, H - 30), T.SHADOW)
	ci.draw_rect(Rect2(0, 14, W, H - 28), T.CREAM)
	T.draw_torn_edge(ci, Vector2(0, 15), Vector2(W, 15), T.CREAM, 12.0, 21)
	T.draw_torn_edge(ci, Vector2(W, H - 15), Vector2(0, H - 15), T.CREAM, 12.0, 23)
	T.draw_grain(ci, Rect2(0, 14, W, H - 28), 0.12)


## 평가 카드 덮개의 종이결 (다른 메뉴 덮개 _draw_wash 와 같은 세기).
func _draw_rate_grain(ci: Control) -> void:
	T.draw_grain(ci, Rect2(Vector2.ZERO, ci.size), 0.10 * WASH_A)


func _best_line(d: Dictionary) -> String:
	var bd := int(d.get("best_delivery", 0))
	var bt := float(d.get("best_time", 0.0))
	var ts := (_L("%.1f초", "%.1fs") % bt) if bt > 0.0 else _L("완주 도전 중", "no finish yet")
	return (_L("%d개 · %s", "%d · %s")) % [bd, ts]


func _dash(ci: Control, y: float) -> void:
	ci.draw_dashed_line(Vector2(24, y), Vector2(RC_SIZE.x - 24.0, y), Color(T.NAVY, 0.35), 2.0, 8.0)


## 봉랍 메달: m 3 금 / 2 은 / 1 동 / 0 아직 (점선 빈 원).
func _seal(ci: Control, c: Vector2, r: float, m: int) -> void:
	if m <= 0:
		ci.draw_arc(c, r, 0.0, TAU, 24, Color(T.KRAFT_SH, 0.6), 3.0, true)
		T.draw_parcel_icon(ci, c, r * 0.95, false)   # 아직 못 간 동네 = 빈 소포 칸 (숫자 대신)
		return
	var tex_name: String = ["", "seal_bronze", "seal_silver", "seal_gold"][clampi(m, 1, 3)]
	var tx := T.tex(tex_name)
	if tx != null:
		ci.draw_texture_rect(tx, Rect2(c - Vector2(r, r) * 1.25, Vector2(r, r) * 2.5), false)
		return
	var col: Color = [T.BRONZE, T.SILVER, T.GOLD][clampi(m, 1, 3) - 1]
	ci.draw_circle(c + Vector2(0, 3), r + 2.0, T.SHADOW)
	for k in 10:
		var a := TAU * k / 10.0
		ci.draw_circle(c + Vector2(cos(a), sin(a)) * r * 0.9, r * 0.3, col.darkened(0.12))
	ci.draw_circle(c, r * 0.92, col)
	ci.draw_arc(c, r * 0.66, 0.0, TAU, 20, col.darkened(0.25), 2.0, true)
	# 별
	var pts := PackedVector2Array()
	pts.resize(10)
	for k in 10:
		var a := -PI * 0.5 + PI * k / 5.0
		var rr := r * (0.42 if k % 2 == 0 else 0.18)
		pts[k] = c + Vector2(cos(a), sin(a)) * rr
	ci.draw_colored_polygon(pts, T.WHITE if m == 3 else col.lightened(0.5))


func _ink(l: Label, col: Color, outline: int, outline_col := T.WHITE) -> void:
	var ls := l.label_settings
	if ls == null:
		return
	if not l.has_meta(&"_sr_ls"):
		ls = ls.duplicate() as LabelSettings
		l.label_settings = ls
		l.set_meta(&"_sr_ls", true)
	ls.font_color = col
	ls.outline_size = outline
	ls.outline_color = outline_col


func _paper_under(c: Control, sb: StyleBoxFlat) -> void:
	if c.has_node(^"SrPaper"):
		return
	var p := Panel.new()
	p.name = "SrPaper"
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size = c.size
	p.add_theme_stylebox_override(&"panel", sb)
	c.add_child(p)
	c.move_child(p, 0)
