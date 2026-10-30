extends Node
## speed 두부게임 메뉴. 게임 하나 = g/<id>.gd (Tofu 를 extends).

const GAMES := [
	# 합격 (10/30 판정)
	["blade", "★ 일격의 길"],
	["boulder", "★ 굴러라 신전석"],
	["quicksilver_tp", "★ 퀵실버 (등뒤 3인칭)"],
	["boulder_fp", "★ 신전석 (1인칭)"],
	["screenrace", "★ 화면 밖 경주 (옆모습)"],
	["overpower", "★ 과속 플랫포머 (옆모습)"],
	["rain_slow", "★ 레인월드 × 느림 (옆모습)"],
	["coming_fp", "★ 그가 온다 × 늦추기 (1인칭)"],
	["deepsword", "★ 깊은 검 × 빠르면 고통 (옆모습)"],
	["bigball", "큰 공 굴리기 (강철코일)"],
]
# 탈락 (보존). 메뉴의 "탈락 게임 모음" 폴더 안에서만 보인다
const DROPPED := [
	["quicksilver", "퀵실버 시티"],
	["synapse", "시냅스 특급"],
	["hot", "나만 빠르다 (1인칭)"],
	["hot_side", "나만 빠르다 (옆모습)"],
	["blade_fp", "일격의 길 (어깨 너머)"],
	["coil_side", "강철코일 (옆모습)"],
	["speedcop", "단속 경찰 (1인칭)"],
	["speedthief", "속도 도둑 (등뒤)"],
	["trafficwizard", "교통 마법사 (위에서)"],
	["kitchen", "주방 막내 (1인칭)"],
	["coaster", "코스터 정비공 (등뒤)"],
	["pitcrew", "피트 크루 (위에서)"],
	["overpower_3d", "과속 플랫포머 (3D)"],
	["piton", "못 연쇄 등반 (옆모습)"],
	["predict", "예측 회피 (위에서)"],
	["onedot", "점 하나 핀볼 (정면)"],
	["icecream", "아이스크림 vs 띵 (1인칭)"],
	["lickghost", "귀신 핥기 (등뒤)"],
	["wombat_fast", "모사리나 × 폭주 도구 (옆모습)"],
	["wombat_dial", "모사리나 × 속도 다이얼 (위에서)"],
	["rain_flee", "레인월드 × 비 질주 (등뒤)"],
	["coming_top", "그가 온다 × 다급함 (위에서)"],
	["deepsword_3d", "깊은 검 × 폭주 (등뒤)"],
	["nerve", "도약 전도"],
	["sword", "빠른 검술"],
	["superhot", "내가 움직일 때만"],
	["onlyfast", "나만 빠르다"],
	["hotpack", "핫팩 몰래 넣기"],
	["timedebt", "시간 빚"],
	["runaway", "브레이크 고장"],
	["slowbike", "느린 자전거 경주"],
	["matchspeed", "속도 맞춰 건너기"],
]
const FOLDER := "__dropped"
const UP := "__up"
const INK := Color("3a2a1a")

const DRAG := 15.0  # 이보다 많이 끌면 넘기기, 아니면 탭

var menu: Control
var game: Tofu
var scroll: ScrollContainer
var list: VBoxContainer
var buttons: Array[Button] = []
var press_at := Vector2.ZERO
var press_scroll := 0
var pressing := false
var dragged := false


func _ready() -> void:
	randomize()
	# 웹에서 처음 열 때 포커스가 없어 멈춰 있으면 첫 탭이 버려지므로, 메뉴는 늘 입력을 받는다
	process_mode = Node.PROCESS_MODE_ALWAYS
	var theme := Theme.new()
	theme.default_font = preload("res://fonts/Pretendard-Bold.otf")
	theme.default_font_size = 44
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color.WHITE
	normal.border_width_left = 14
	normal.border_color = Color("3b5bdb")
	var pressed := normal.duplicate()
	pressed.bg_color = Color("efe1c4")
	theme.set_stylebox("normal", "Button", normal)
	theme.set_stylebox("hover", "Button", normal)
	theme.set_stylebox("pressed", "Button", pressed)
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		theme.set_color(k, "Button", INK)
	menu = Control.new()
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.theme = theme
	add_child(menu)
	var bg := ColorRect.new()
	bg.color = Color("fff4d6")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.add_child(bg)
	# 게임이 많아 위아래로 끌어 넘긴다. 끌기·탭은 _input 에서 직접 처리 (버튼이 터치를 먹지 않게)
	scroll = ScrollContainer.new()
	scroll.position = Vector2(60, 40)
	scroll.size = Vector2(600, 1220)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(scroll)
	list = VBoxContainer.new()
	list.custom_minimum_size = Vector2(600, 0)
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	_fill(false)


## 목록을 채운다. dropped 면 탈락 게임 모음 폴더 안
func _fill(dropped: bool) -> void:
	for c in list.get_children():
		c.queue_free()
	buttons.clear()
	var title := Label.new()
	title.text = "탈락 게임 모음" if dropped else "SPEED 두부"
	title.add_theme_color_override("font_color", INK)
	title.add_theme_font_size_override("font_size", 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(title)
	var rows: Array = []
	if dropped:
		rows.append([UP, "◀ 돌아가기"])
		rows.append_array(DROPPED)
	else:
		rows.append_array(GAMES)
		rows.append([FOLDER, "▶ 탈락 게임 모음 (%d)" % DROPPED.size()])
	for g in rows:
		var b := Button.new()
		b.text = g[1]
		b.custom_minimum_size = Vector2(600, 92)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.set_meta("id", g[0])
		list.add_child(b)
		buttons.append(b)
	scroll.scroll_vertical = 0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and get_tree().paused:
		_wake()
	if not menu.visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				scroll.scroll_vertical += 120 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -120
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if event.pressed:
			pressing = true
			dragged = false
			press_at = event.position
			press_scroll = scroll.scroll_vertical
			_light(_hit(event.position))
		elif pressing:
			pressing = false
			_light(null)
			var b := _hit(event.position)
			if not dragged and b:
				get_viewport().set_input_as_handled()
				_open(b.get_meta("id"))
	elif event is InputEventMouseMotion and pressing:
		var dy: float = event.position.y - press_at.y
		if not dragged and absf(dy) > DRAG:
			dragged = true
			_light(null)
		if dragged:
			scroll.scroll_vertical = press_scroll - int(dy)


## 화면 점 p 아래 버튼 (목록 칸 안에서만)
func _hit(p: Vector2) -> Button:
	if not scroll.get_global_rect().has_point(p):
		return null
	for b in buttons:
		if b.get_global_rect().has_point(p):
			return b
	return null


## 누르고 있는 버튼만 눌린 색
func _light(on: Button) -> void:
	for b in buttons:
		if b == on:
			b.add_theme_stylebox_override("normal", b.get_theme_stylebox("pressed"))
		else:
			b.remove_theme_stylebox_override("normal")


func _wake() -> void:
	get_tree().paused = false
	AudioServer.set_bus_mute(0, false)


func _open(id: String) -> void:
	if id == FOLDER or id == UP:
		_fill(id == FOLDER)
		return
	menu.visible = false
	game = load("res://g/%s.gd" % id).new()
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	game.id = id
	game.back.connect(_close)
	add_child(game)


func _close() -> void:
	game.queue_free()
	game = null
	menu.visible = true


func _notification(what: int) -> void:
	# 탭이 가려지면 멈추고 소리를 끈다
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		get_tree().paused = true
		AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		get_tree().paused = false
		AudioServer.set_bus_mute(0, false)
