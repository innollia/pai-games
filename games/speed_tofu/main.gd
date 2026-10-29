extends Node
## speed 두부게임 메뉴. 게임 하나 = g/<id>.gd (Tofu 를 extends).

const GAMES := [
	["bigball", "큰 공 굴리기"],
	["sword", "빠른 검술"],
	["nerve", "도약 전도"],
	["superhot", "내가 움직일 때만"],
	["onlyfast", "나만 빠르다"],
	["hotpack", "핫팩 몰래 넣기"],
	["timedebt", "시간 빚"],
	["runaway", "브레이크 고장"],
	["slowbike", "느린 자전거 경주"],
	["matchspeed", "속도 맞춰 건너기"],
]
const INK := Color("3a2a1a")

var menu: Control
var game: Tofu


func _ready() -> void:
	randomize()
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
	var list := VBoxContainer.new()
	list.position = Vector2(60, 70)
	list.size = Vector2(600, 1180)
	list.add_theme_constant_override("separation", 12)
	menu.add_child(list)
	var title := Label.new()
	title.text = "SPEED 두부"
	title.add_theme_color_override("font_color", INK)
	title.add_theme_font_size_override("font_size", 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list.add_child(title)
	for g in GAMES:
		var b := Button.new()
		b.text = g[1]
		b.custom_minimum_size = Vector2(600, 92)
		b.pressed.connect(_open.bind(g[0]))
		list.add_child(b)


func _open(id: String) -> void:
	menu.visible = false
	game = load("res://g/%s.gd" % id).new()
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
