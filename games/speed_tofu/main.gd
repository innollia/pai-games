extends Node
## speed 두부게임 메뉴. 게임 하나 = g/<id>.gd (Tofu 를 extends).

const GAMES := [
	# ● 개발 중 (제출준비작: 전담 세션이 강화)
	["boulder", "● Rock and Stone (굴러라 신전석)"],
	["screenrace", "● 화면 밖 경주 (옆모습)"],
	["tinyplanet", "● 어린 배달부 (작은 행성)"],
]
## 쓸만한 것 (7세대 대멸종 생존, 폰 별 4 이상)
const USEFUL := [
	["overpower", "★ 과속 플랫포머 (옆모습)"],
	["overpower_v4", "★ 과속 플랫포머 (이전판)"],
	["overpower_edit", "▶ 스테이지 제작 (PC)"],
	["quicksilver_fp", "◇ 찰나 구조대 (1인칭)"],
	["scale_prison", "▲ 저울 감옥 (옆모습)"],
	["compress", "▲ 압축 스프링 (옆모습)"],
	["stretch_roll", "▲ 늘어나는 돌"],
]
# 보류 (폐기 아님: 다른 목적으로 다시 볼 것 — 멀티플레이, 이전 판, 모드로 합쳐진 원본). 메뉴의 "보류" 폴더
const HOLD := [
	["loud_race", "▲ 시끄러운 1등 (옆모습)"],
	["lantern_race", "▲ 등불 경주 (← 화면 밖 경주)"],
	["overpower_map", "과속 플랫포머 v3 이어진 지도 (보류)"],
	# 7세대: 아직 폰 평가를 못 받은 새 게임
	["climb_race", "▲ 위로 경주 (세로)"],
	["speed_snake", "▲ 빠르면 긴 뱀 (← 과속 플랫포머)"],
]
# 2차 폐기 (게임 안 평균 별점 2 이하). 메뉴의 "2차 폐기 (평가 낮음)" 폴더 안에서만 보인다
const DROPPED2 := [
	["bounce_race", "▲ 고무공 경주 (← 경주×과속)"],
	["wheel_down", "▲ 넘어지면 끝 바퀴 (← 신전석)"],
	["tooslow_rpg", "▲ 너무 느린 주인공 (쯔꾸르)"],
	["boulder_fp", "★ 신전석 (1인칭)"],
	["coming_fp", "★ 그가 온다 × 늦추기 (1인칭)"],
	["fallcards", "◆ 낙하 카드 (등뒤)"],
	["tooslow", "◆ 너무 느린 주인공"],
	["bigball", "큰 공 굴리기 (강철코일)"],
	["deepsword_fp", "◇ 깊은 검 (1인칭)"],
	["glider", "☆ 활공 (1인칭)"],
	["overpower_rain", "◇ 과속 플랫포머 × 레인월드"],
	["runaway_train", "☆ 폭주 열차 지붕 (등뒤)"],
	["ice_courier", "☆ 빙판 배달 (위에서)"],
	["quicksilver_tp", "★ 퀵실버 (등뒤 3인칭)"],
	["puzzlerace", "◆ 퍼즐 레이싱"],
	["magnet", "▲ 자석의 망명 (등뒤)"],
	["rain_coming", "◇ 레인월드 × 그가 온다 (등뒤)"],
	["rain_fp", "◇ 레인월드 느림 (1인칭)"],
	["shockwave", "☆ 음속 (등뒤)"],
	["taiji_speed", "◆ 흘러가는 퍼즐 판"],
	# 7세대 대멸종 (최근 판 별 3 이하, 또는 여러 번 평가 기회에도 별 없음)
	["rain_slow", "★ 레인월드 × 느림 (옆모습)"],
	["deepsword", "★ 깊은 검 × 빠르면 고통 (옆모습)"],
	["molten", "☆ 식는 바위 (옆모습)"],
	["boulder_race", "◇ 신전석 × 화면 밖 경주"],
	["coming_boulder", "◇ 그가 온다 × 신전석 (등뒤)"],
	["snapshot", "◆ 순간 포착 (1인칭)"],
	["bombcrawl", "◆ 폭탄 애벌레 (옆모습)"],
	["phase_runner", "▲ 빠르면 투명 (← 과속 플랫포머)"],
	["echo_bat", "▲ 초음파 박쥐 (← 레인월드)"],
	["counterweight", "▲ 균형추 배달부 (← 저울 감옥)"],
	# 7세대 뒤 평가: 최근 판 별 2
	["screenrace_over", "◇ 화면 밖 경주 × 과속"],
]
# 게임 버전: 강화할 때마다 올린다. 메뉴 글자 끝에 " v3" 로 붙고 평가 ver 에 "v3 <빌드>" 로 들어간다 (없으면 1)
const GAME_VER := {"bigball": 3, "blade": 2, "blade_1p": 2, "blade_fp": 1, "blade_run": 2, "bombcrawl": 2, "boulder": 23, "boulder_fp": 1, "boulder_race": 2, "coaster": 1, "coil_side": 1, "coming_boulder": 2, "coming_fp": 2, "coming_top": 1, "compress": 3, "deepsword": 2, "deepsword_3d": 1, "deepsword_fp": 2, "fallcards": 1, "glider": 2, "hot": 2, "hot_side": 2, "hotpack": 2, "ice_courier": 2, "icecream": 1, "kitchen": 1, "lickghost": 1, "loud_race": 1, "magnet": 1, "matchspeed": 2, "molten": 2, "nerve": 3, "onedot": 1, "onlyfast": 2, "overpower": 5, "overpower_3d": 1, "overpower_edit": 1, "overpower_v4": 4, "overpower_map": 3, "overpower_rain": 2, "pitcrew": 1, "piton": 1, "predict": 1, "puzzlerace": 1, "quicksilver": 2, "quicksilver_fp": 4, "quicksilver_tp": 1, "rain_coming": 2, "rain_flee": 1, "rain_fp": 2, "rain_slow": 3, "runaway": 2, "runaway_train": 2, "scale_prison": 3, "screenrace": 28, "screenrace_over": 3, "shockwave": 2, "slowbike": 2, "climb_race": 1, "phase_runner": 2, "counterweight": 2, "speed_snake": 1, "snapshot": 1, "speedcop": 2, "speedthief": 2, "stretch_roll": 4, "superhot": 2, "sword": 2, "synapse": 2, "taiji_speed": 1, "timedebt": 2, "tinyplanet": 9, "tooslow": 1, "tooslow_rpg": 1, "trafficwizard": 2, "wombat_dial": 1, "wombat_fast": 1}
# 1차 폐기 (사용자 판정 탈락 + 첫 판 보존작). 메뉴의 "1차 폐기 (판정 탈락)" 폴더 안에서만 보인다
const DROPPED := [
	["quicksilver", "퀵실버 시티"],
	["synapse", "시냅스 특급"],
	["hot", "나만 빠르다 (1인칭)"],
	["hot_side", "나만 빠르다 (옆모습)"],
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
const FOLDER := "__dropped"  # 1차 폐기 폴더
const FOLDER2 := "__dropped2"  # 2차 폐기 폴더
const FOLDER3 := "__hold"  # 보류 폴더
const FOLDER4 := "__useful"  # 쓸만한 것 폴더
# 제출준비작이 단독 프로젝트로 나가면 메뉴는 그 단독판 주소로 보낸다(웹에서만). 전담 세션이 여기에 한 줄 추가한다
const STANDALONE := {"boulder": "../../shrine_stone/web/?from=tofu", "screenrace": "../../off_screen/web/?from=tofu", "tinyplanet": "../../tiny_planet/web/?from=tofu"}
const UP := "__up"
const IDEA := "__idea"  # 맨 아래 "아이디어 제출하기" -> window.prompt -> Firestore tofu_ideas (tools/tofu_fb.js)
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
var idea_btn: Button
var idea_wait := false  # 아이디어를 보내고 window.tofuLast 를 기다리는 중


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
	_fill(0)


## 목록을 채운다. folder 0 = 메인, 1 = 1차 폐기(판정 탈락), 2 = 2차 폐기(평가 낮음), 3 = 보류, 4 = 쓸만한 것
func _fill(folder: int) -> void:
	for c in list.get_children():
		c.queue_free()
	buttons.clear()
	var title := Label.new()
	title.text = ["SPEED 두부", "1차 폐기 (판정 탈락)", "2차 폐기 (평가 낮음)", "보류 (나중에 다시)", "쓸만한 것"][folder]
	title.add_theme_color_override("font_color", INK)
	title.add_theme_font_size_override("font_size", 72 if folder == 0 else 56)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(title)
	var rows: Array = []
	if folder > 0:
		rows.append([UP, "◀ 돌아가기"])
		rows.append_array([DROPPED, DROPPED2, HOLD, USEFUL][folder - 1])
	else:
		rows.append_array(GAMES)
		rows.append([FOLDER4, "▶ 쓸만한 것 (%d개)" % USEFUL.size()])
		rows.append([FOLDER3, "▶ 보류 (나중에 다시) (%d개)" % HOLD.size()])
		rows.append([FOLDER, "▶ 1차 폐기 (판정 탈락) (%d개)" % DROPPED.size()])
		rows.append([FOLDER2, "▶ 2차 폐기 (평가 낮음) (%d개)" % DROPPED2.size()])
	rows.append([IDEA, "아이디어 제출하기"])
	idea_btn = null
	idea_wait = false
	for g in rows:
		var b := _row_button(g)
		b.set_meta("id", g[0])
		list.add_child(b)
		buttons.append(b)
		if g[0] == IDEA:
			idea_btn = b
	scroll.scroll_vertical = 0


## 한 줄 버튼: 왼쪽에 제목(크게), 오른쪽에 괄호 속 설명·버전(작고 흐리게). 이름이 길어도 줄이 넘치지 않는다
func _row_button(g: Array) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(600, 92)
	b.clip_text = true  # 긴 이름이 줄 폭을 넓혀 메뉴 전체가 화면 밖으로 밀리지 않게
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if g[0] == IDEA:  # 보내는 중·고마워요로 글이 바뀌는 버튼은 그대로
		b.text = g[1]
		return b
	var label: String = g[1]
	var name := label
	var meta: Array = []
	var i := label.find(" (")
	if i > 0:
		name = label.left(i)
		for part in label.substr(i).split(")"):
			var t := part.strip_edges().trim_prefix("(").strip_edges()
			if t != "":
				meta.append(t)
	if not str(g[0]).begins_with("__"):
		meta.append("v%d" % GAME_VER.get(g[0], 1))
	var nl := Label.new()
	nl.text = name
	nl.add_theme_font_size_override("font_size", 38)
	nl.add_theme_color_override("font_color", INK)
	nl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	nl.clip_text = true
	nl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nl.set_anchors_preset(Control.PRESET_FULL_RECT)
	nl.offset_left = 24
	nl.offset_right = -24
	b.add_child(nl)
	if not meta.is_empty():
		var ml := Label.new()
		ml.text = " · ".join(meta)
		ml.add_theme_font_size_override("font_size", 24)
		ml.add_theme_color_override("font_color", Color(INK, 0.5))
		ml.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ml.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		ml.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ml.set_anchors_preset(Control.PRESET_FULL_RECT)
		ml.offset_right = -20
		ml.offset_bottom = -8
		b.add_child(ml)
		nl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		nl.offset_top = 10
	return b


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
	if id == FOLDER or id == FOLDER2 or id == FOLDER3 or id == FOLDER4 or id == UP:
		_fill({FOLDER: 1, FOLDER2: 2, FOLDER3: 3, FOLDER4: 4}.get(id, 0))
		return
	if id == IDEA:
		_idea()
		return
	if STANDALONE.has(id) and OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = %s" % JSON.stringify(STANDALONE[id]), true)
		return
	menu.visible = false
	game = load("res://g/%s.gd" % id).new()
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	game.id = id
	game.gver = GAME_VER.get(id, 1)
	game.back.connect(_close)
	add_child(game)


func _close() -> void:
	game.queue_free()
	game = null
	menu.visible = true


## 아이디어 제출: 웹에서만 (window.prompt -> tofuIdea). 결과는 버튼 글자를 잠깐 바꿔 보여 준다
func _idea() -> void:
	if not OS.has_feature("web") or idea_wait:
		return
	var r: Variant = JavaScriptBridge.eval("window.tofuAsk ? window.tofuAsk('속도 게임 아이디어를 적어 주세요') : ''", true)
	var text := (str(r) if r != null else "").strip_edges().left(2000)
	if text == "":
		return
	JavaScriptBridge.eval("window.tofuIdea && window.tofuIdea(%s, %s)" % [JSON.stringify(text), JSON.stringify(Tofu.VER)], true)
	idea_wait = true
	_idea_say("보내는 중")


func _idea_say(s: String, restore := false) -> void:
	if not idea_btn:
		return
	idea_btn.text = s
	if restore:
		var b := idea_btn
		get_tree().create_timer(2.0, true).timeout.connect(func() -> void:
			if is_instance_valid(b):
				b.text = "아이디어 제출하기")


func _process(_dt: float) -> void:
	if not idea_wait:
		return
	var r: Variant = JavaScriptBridge.eval("window.tofuLast", true)
	if r == "ok":
		idea_wait = false
		_idea_say("보냈어요!", true)
	elif r == "fail":
		idea_wait = false
		_idea_say("저장 안 됨", true)


func _notification(what: int) -> void:
	# 탭이 가려지면 멈추고 소리를 끈다
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		get_tree().paused = true
		AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		get_tree().paused = false
		AudioServer.set_bus_mute(0, false)
