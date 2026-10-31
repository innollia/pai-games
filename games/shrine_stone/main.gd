extends Node
## 굴러라 신전석 단독 실행. 메뉴 없이 바로 boulder 를 연다. "< 메뉴" 를 누르면 처음부터 다시.
## 새 게임의 기반으로 쓸 때: g/boulder.gd 를 고치거나, g/ 에 Tofu 를 extends 한 새 파일을 만들고 GAME 을 바꾼다.

const GAME := "boulder"
const GVER := 31  # speed_tofu main.gd GAME_VER["boulder"] (tools/sync.ps1 이 맞춘다). 평가 ver = "v<GVER> <빌드>"

var game: Tofu
var from_tofu := false  # SPEED 두부 목록(?from=tofu)에서 왔으면 "<" 가 목록으로 돌아간다


func _ready() -> void:
	randomize()
	if OS.has_feature("web"):
		from_tofu = str(JavaScriptBridge.eval("location.search.indexOf('from=tofu') >= 0 ? 'y' : 'n'", true)) == "y"  # bool 로 비교하면 웹에서 스크립트 오류 -> 빈 화면
	process_mode = Node.PROCESS_MODE_ALWAYS
	_open()


func _open() -> void:
	game = load("res://g/%s.gd" % GAME).new()
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	game.id = GAME
	game.gver = GVER
	game.back.connect(_close)
	add_child(game)
	# 확인용: 주소에 ?zone=N 이면 N 구역(1부터)에서 시작한다
	if OS.has_feature("web"):
		var zq := int(str(JavaScriptBridge.eval("(location.search.match(/zone=(\\d+)/) || [0, 0])[1]", true)))
		if zq > 1 and zq <= game.Z.size():
			game.cp_k = zq - 1
			game.cp_st = {"x": 0.0, "z": 0.0, "yw": 0.0, "h": 200.0}
			game.cp_s = 2.6
			game.restart()
	if from_tofu:
		_relabel(game)
	else:
		# itch 에서는 목록으로 돌아갈 곳도, 평가를 받을 곳도 없다: 두 구석 버튼을 끈다
		game.back_on = false
		game._RATE_BTN = Rect2()
		game._rate_btn_l.visible = false
	_title_open()


# ---- 타이틀 화면: 뒤에는 1구역 신전 앞 장면이 멈춰 있고(게임의 설명 카드가 떠 있는 동안 멈춤), 위에 제목과 버튼 ----
# 게임(boulder)의 ui_* 함수로 같은 새긴 돌 디자인을 쓴다. 그 함수가 없으면 예전 모습.
const INK := Color("3a2a1a")
const GOLD := Color("fcc419")
const STONE := Color("efe1c4")
const GLYPH_SUB := Color("8a6d4b")
const RECORD := "user://boulder_v6.cfg"
const UI_FNS := ["ui_box", "ui_stone", "ui_panel", "ui_slab", "ui_glyph", "ui_button_styles", "ui_squash", "fit_fs"]
var _font: Font = preload("res://fonts/Pretendard-Bold.otf")
var title: CanvasLayer
var lintel: Control
var title_tws: Array = []  # 닫을 때 멈출 트윈 (등장·흔들림·숨쉬기)


func _ui_ok() -> bool:
	for nm: String in UI_FNS:
		if not game.has_method(nm):
			return false
	return true


func _title_open() -> void:
	_font = game._font  # 영어면 Cinzel, 한국어면 Pretendard
	if title:
		title.queue_free()
	title_tws.clear()
	lintel = null
	game.set_process_unhandled_input(false)  # 버튼을 누른 터치가 게임 시작으로 새지 않게
	_back_label(false)  # 타이틀 위에서는 '< 처음부터' 를 숨긴다
	game.process_mode = Node.PROCESS_MODE_DISABLED  # 타이틀이 떠 있는 동안 뒤 장면은 그려지기만 하고 멈춘다
	for nm: String in ["_score_l", "route_label", "_rate_btn_l", "_time_l"]:  # 멈춘 동안 게임 글판이 타이틀 위에 남지 않게
		var l = game.get(nm)
		if l is CanvasItem:
			(l as CanvasItem).visible = false
	title = CanvasLayer.new()
	title.layer = 20
	add_child(title)
	var ui := _ui_ok()
	# 아래로 갈수록 크림빛이 짙어진다: 위쪽 멈춘 신전 장면은 밝게, 버튼은 잘 보이게
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	g.colors = PackedColorArray([Color(1, 0.96, 0.87, 0.0), Color(1, 0.96, 0.87, 0.15), Color(1, 0.96, 0.87, 0.78)])
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 4
	gt.height = 64
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	var shade := TextureRect.new()
	shade.texture = gt
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.position = Vector2(0, 0)
	shade.size = Vector2(720, 1280)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	title.add_child(shade)
	var sub := "Shrinestone" if TranslationServer.get_locale() != "en" else "A speed game about weight"  # 영어면 제목 아래 한 줄 소개
	if ui:
		# 제목 = 신전 문 위 돌 상인방: 위에서 떨어져 쿵 박히고 천천히 흔들린다
		lintel = Control.new()
		lintel.position = Vector2(10, 120)
		lintel.size = Vector2(700, 360)
		lintel.pivot_offset = Vector2(350, 180)
		lintel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title.add_child(lintel)
		game.call("ui_slab", lintel, Vector2.ZERO, Vector2(700, 360), 0, STONE, "title")  # GPT 가 그린 신전 상인방
		# 글은 양 끝 기둥머리 사이 돌면 안에만 (가로 420)
		# 제목은 크게, 두 줄(SHRINE / STONE). 가장 긴 줄이 기둥머리 사이 돌면(가로 450) 안에
		var lines := tr("굴러라 신전석").split("\n")
		var longest := ""
		for ln: String in lines:
			if ln.length() > longest.length():
				longest = ln
		var fs: int = mini(game.call("fit_fs", longest, 120, 400), int(200.0 / maxf(1.0, lines.size() * 0.95)))
		var tl: Label = game.call("ui_glyph", lintel, fs)
		tl.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		tl.position = Vector2(125, 72)
		tl.size = Vector2(450, 210)
		tl.label_settings.line_spacing = -fs * 0.18
		tl.text = tr("굴러라 신전석")
		# 한 줄 소개는 상인방 아래에 (흰 테로 3D 위에서도 읽히게)
		var sl: Label = game.call("ui_glyph", lintel, 34, GLYPH_SUB)
		sl.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		sl.position = Vector2(0, 366)
		sl.size = Vector2(700, 50)
		sl.label_settings.outline_size = 10
		sl.label_settings.outline_color = Color.WHITE
		sl.text = sub
		var li := lintel
		lintel.position.y = -280.0
		var tw := lintel.create_tween()
		tw.tween_interval(0.1)
		tw.tween_property(lintel, "position:y", 120.0, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func() -> void:
			if game and game.has_method("sfx"):
				game.call("sfx", "bonk", 2.0, 0.7)
			var bob := li.create_tween().set_loops()
			bob.tween_property(li, "position:y", 132.0, 1.4).set_trans(Tween.TRANS_SINE)
			bob.tween_property(li, "position:y", 120.0, 1.4).set_trans(Tween.TRANS_SINE)
			var rot := li.create_tween().set_loops()
			rot.tween_property(li, "rotation", -0.02, 2.1).set_trans(Tween.TRANS_SINE)
			rot.tween_property(li, "rotation", 0.02, 2.1).set_trans(Tween.TRANS_SINE)
			title_tws.append(bob)
			title_tws.append(rot))
		title_tws.append(tw)
	else:
		_text(tr("굴러라 신전석"), 104, Vector2(0, 170), Vector2(720, 140), INK, 18)
		_text(sub, 40, Vector2(0, 300), Vector2(720, 60), Color("8a5a2b"), 10)
	var cfg := ConfigFile.new()
	if cfg.load(RECORD) == OK and float(cfg.get_value("record", "time", 0.0)) > 0.0:
		var c := int(float(cfg.get_value("record", "time", 0.0)) * 100.0)
		var best := tr("최고 완주 %s") % ("%02d:%02d.%02d" % [c / 6000, (c / 100) % 60, c % 100])
		if ui:
			game.call("ui_panel", title, Vector2(190, 630), Vector2(340, 58), game.call("ui_stone", STONE, "btn"))
			_text(best, 30, Vector2(190, 630), Vector2(340, 58), Color("2b7a3d"), 0)
		else:
			_text(best, 34, Vector2(0, 520), Vector2(720, 50), Color("2b7a3d"), 10)
	var play_b := _button(tr("▶  시작"), Vector2(110, 960), Vector2(500, 130), GOLD, 56, _title_start)
	var bs: Array = [play_b]
	if OS.has_feature("web"):
		bs.append(_button("English" if TranslationServer.get_locale() != "en" else "한국어", Vector2(250, 1130), Vector2(220, 70), Color(1, 1, 1, 0.8), 30, _title_lang))
	if ui:
		# 버튼이 차례로 아래에서 솟아오르고, 시작 버튼은 그 뒤 숨 쉬듯 커졌다 작아진다
		for i in bs.size():
			var b: Button = bs[i]
			var h: Control = b.get_meta("holder")
			var y := h.position.y
			var delay := 0.25 + i * 0.08
			h.modulate.a = 0.0
			h.position.y = y + 140.0
			var tw := h.create_tween().set_parallel()
			tw.tween_property(h, "position:y", y, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
			tw.tween_property(h, "modulate:a", 1.0, 0.25).set_delay(delay)
			title_tws.append(tw)
			if b == play_b:
				tw.chain().tween_callback(func() -> void:
					var br := h.create_tween().set_loops()
					br.tween_property(h, "scale", Vector2.ONE * 1.045, 0.9).set_trans(Tween.TRANS_SINE)
					br.tween_property(h, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE)
					title_tws.append(br))


func _text(s: String, size: int, pos: Vector2, box: Vector2, col: Color, outline: int, parent: Node = null) -> Label:
	var ls := LabelSettings.new()
	ls.font = _font
	ls.font_size = size
	ls.font_color = col
	ls.outline_size = outline
	ls.outline_color = Color.WHITE
	var l := Label.new()
	l.label_settings = ls
	l.text = s
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.position = pos
	l.size = box
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent else title).add_child(l)
	return l


## 버튼은 holder(자리·숨쉬기) 안에 넣는다: 버튼 자신의 눌림 납작과 크기를 다투지 않게. holder 는 meta "holder"
func _button(s: String, pos: Vector2, box: Vector2, col: Color, size: int, cb: Callable, parent: Node = null) -> Button:
	var holder := Control.new()
	holder.position = pos
	holder.size = box
	holder.pivot_offset = box * 0.5
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	(parent if parent else title).add_child(holder)
	var b := Button.new()
	b.text = s
	b.position = Vector2.ZERO
	b.size = box
	b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", size)
	if _ui_ok():
		game.call("ui_button_styles", b, col)
		game.call("ui_squash", b)
	else:
		for st in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			b.add_theme_color_override(st, INK)
		var sb := StyleBoxFlat.new()
		sb.bg_color = col
		sb.set_corner_radius_all(int(box.y * 0.5))
		sb.set_border_width_all(5)
		sb.border_color = INK
		sb.shadow_color = Color(0, 0, 0, 0.25)
		sb.shadow_size = 6
		sb.shadow_offset = Vector2(0, 6)
		var down := sb.duplicate() as StyleBoxFlat
		down.bg_color = col.darkened(0.15)
		down.shadow_offset = Vector2(0, 2)
		for k in ["normal", "hover", "focus"]:
			b.add_theme_stylebox_override(k, sb)
		b.add_theme_stylebox_override("pressed", down)
	b.pressed.connect(cb)
	holder.add_child(b)
	b.set_meta("holder", holder)
	return b


## 닫는 동안 손을 못 대게: 모든 Control 은 입력을 흘리고 버튼은 잠근다
func _lock(n: Node) -> void:
	for c in n.get_children():
		if c is Control:
			(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		if c is Button:
			(c as Button).disabled = true
		_lock(c)


func _title_close() -> void:
	if title == null:
		return
	var old := title
	title = null
	_lock(old)
	for t: Tween in title_tws:
		if t and t.is_valid():
			t.kill()
	title_tws.clear()
	game.set_process_unhandled_input(true)
	_back_label(from_tofu)
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	game.play("tap")
	# 글·버튼은 흐려지고 상인방은 위로 빠져나간다
	var tw := old.create_tween().set_parallel()
	for c in old.get_children():
		if c is Control:
			tw.tween_property(c, "modulate:a", 0.0, 0.25)
	if lintel and is_instance_valid(lintel):
		tw.tween_property(lintel, "position:y", -220.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	lintel = null
	tw.chain().tween_callback(old.queue_free)


func _title_start() -> void:
	_title_close()


func _title_tutorial() -> void:
	_title_close()
	game.call("start_tutorial")


func _title_lang() -> void:
	var q := "?lang=" + ("ko" if TranslationServer.get_locale() == "en" else "en") + ("&from=tofu" if from_tofu else "")
	JavaScriptBridge.eval("window.location.search = '%s'" % q, true)


func _relabel(n: Node) -> void:
	for c in n.get_children():
		if c is Label and c.text == "< 처음부터":
			c.text = "< 목록"
		_relabel(c)


func _close() -> void:
	Engine.time_scale = 1.0  # 튜토리얼 느린 화면 중에 나가도 원래 속도로
	if from_tofu:
		JavaScriptBridge.eval("window.location.href = '../../speed_tofu/web/'", true)
		return
	game.queue_free()
	game = null
	_open.call_deferred()


func _notification(what: int) -> void:
	# 탭이 가려지면 멈추고 소리를 끈다
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		get_tree().paused = true
		AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		get_tree().paused = false
		AudioServer.set_bus_mute(0, false)


## 게임 왼쪽 위 "< 처음부터"/"< 목록" 글자 보이기·숨기기
func _back_label(on: bool, n: Node = null) -> void:
	if n == null:
		n = game
	for c in n.get_children():
		if c is Label and (c as Label).text.begins_with("< "):
			(c as Label).visible = on
		_back_label(on, c)
