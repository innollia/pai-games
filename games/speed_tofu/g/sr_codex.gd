extends Control
## v50: 도감 (제목 화면 [도감] 버튼). "low door 설명을 매번 붙이지 말고 로비에 도감을 하나 구비해서 맵 종류랑 기물 종류 보여주고 거기에 설명".
## 위 탭 둘: 동네(6코스, 배경 그림 + 그 동네 규칙) / 길·기물(우체통·발판·벽·낮은 문 ... 아이콘 + 한 줄 설명).
## 손가락으로 끌어 위아래로 넘기고, 오른쪽 위 [X]로 닫는다. 그림: art/screenrace/ui/icon_*, cx_* (Codex), 동네는 bg_*.webp.

signal closed

const T = preload("res://g/sr_theme.gd")

const TOP := 250.0  # 목록 시작 (머리 띠 + 탭 아래)
const CARD_H := 156.0
const GAP := 16.0
const PAD := 24.0

var game  # screenrace (L(), 코스·규칙 표)
var K := {}  # screenrace 상수 표 (COURSES, SEG_RULES ...)
var tab := 0  # 0 동네, 1 길·기물
var scroll := 0.0
var _drag := false
var _drag_y := 0.0
var _drag_moved := 0.0
var _vel := 0.0
var _items: Array = []  # {tex, region, name, desc, accent}


func _ready() -> void:
	size = Vector2(720, 1280)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false


func open() -> void:
	tab = 0
	_fill()
	visible = true
	T.pop_in(self)


func close() -> void:
	visible = false
	closed.emit()


func _L(ko: String, en: String) -> String:
	return game.L(ko, en) if game != null else en


## 이름: 설명 으로 된 규칙 글을 둘로
func _split(s: String) -> Array:
	var i := s.find(": ")
	if i < 0:
		return ["", s]
	return [s.substr(0, i), s.substr(i + 2)]


func _ui(n: String) -> Texture2D:
	return T.tex(n)


func _fill() -> void:
	if K.is_empty():
		K = game.get_script().get_script_constant_map()
	_items.clear()
	scroll = 0.0
	_vel = 0.0
	if tab == 0:
		var bgs := ["market", "riverside", "crossing", "night_market", "bridge", "rooftops"]
		for i in K.COURSES.size():
			var c: Dictionary = K.COURSES[i]
			var en: Array = K.COURSES_EN[i]
			var t: Texture2D = null
			var p := "res://art/screenrace/bg_%s.webp" % bgs[i]
			if ResourceLoader.exists(p):
				t = load(p)
			_items.append({"tex": t, "wide": true, "name": "%d. %s" % [i + 1, _L(c.name, en[0])], "desc": _L(c.say, en[1]), "accent": c.top})
		return
	var lang_en: bool = game.lang != "ko"
	# 기본 규칙 (게임 내내)
	var base := [
		["cx_mailbox", "빨간 우체통", "화면에 보이면 [짐] 버튼이 초록. 눌러서 배달. 하나에 짐 하나, 먼저 넣는 사람 것", "Red mailbox", "When one is on screen the BOX button turns green. Tap to deliver. One box each, first come first served", T.RED],
		["cx_gold", "금 우체통", "결승 앞에 하나. 짐 1개로 3점", "Gold mailbox", "One before the finish. One box = 3 points", T.GOLD],
		["icon_flag", "1등 도착", "결승에 가장 먼저 닿으면 +1. 점수가 같으면 먼저 도착한 사람이 이긴다", "First to finish", "First across the finish gets +1. On a tie, whoever arrived first wins", T.GREEN],
		["icon_drop", "짐 던지기 · 대시", "우체통이 없을 때 [짐]: 짐을 뒤로 던지고 앞으로 대시. 던진 짐은 누구나 주워 배달한다", "Throw · dash", "BOX with no mailbox near: throw a box back and dash ahead. Anyone can pick it up and deliver it", T.BLUE],
		["icon_feather_box", "짐 무게", "짐이 많을수록 느리고 낮게 뛴다", "Box weight", "The more boxes you carry, the slower you run and the lower you jump", T.PARCEL],
		["cx_edge", "왼쪽 찢긴 끝", "닿으면 반송: 짐 -1, 잠깐 뒤 화면 안으로. 한 판에 3번이면 탈락", "Torn left edge", "Touch it and you are returned: -1 box, back in a moment. 3 times in a round and you are out", T.RED],
		["icon_spring", "노란 발판", "밟으면 높이 뛰어 빨간 윗길로. 짐 무게를 덜 받는다", "Yellow pad", "Step on it to spring up to the red upper path. Box weight matters less", T.GOLD],
	]
	for b in base:
		_items.append({"tex": _ui(b[0]), "alt": b[0], "name": b[3] if lang_en else b[1], "desc": b[4] if lang_en else b[2], "accent": b[5]})
	# 길에 나오는 것 (규칙 글은 게임 안 SEG_RULES 그대로)
	var segs := [["wall", "cx_wall"], ["pit", "cx_gap"], ["crates", "cx_crate"], ["stairs", "icon_shoe"], ["river", "cx_river"],
		["track", "cx_train"], ["gate", "icon_gate"], ["slide", "icon_ice"], ["wind", "icon_headwind"], ["bridge", "cx_bridge"],
		["roofgap", "cx_roof"], ["longgap", "cx_longgap"], ["ballast", "cx_scale"], ["updraft", "icon_wind"], ["shutter", "cx_shutter"], ["dropfloor", "cx_trapdoor"]]
	for s in segs:
		var txt: String = K.SEG_RULES_EN[s[0]] if lang_en else K.SEG_RULES[s[0]]
		var nd := _split(txt)
		_items.append({"tex": _ui(s[1]), "alt": s[1], "name": nd[0], "desc": nd[1], "accent": T.KRAFT_SH})


func _content_h() -> float:
	return _items.size() * (CARD_H + GAP) + 40.0


func _max_scroll() -> float:
	return maxf(_content_h() - (size.y - TOP), 0.0)


func _process(dt: float) -> void:
	if not visible:
		return
	if not _drag and absf(_vel) > 1.0:
		scroll = clampf(scroll + _vel * dt, 0.0, _max_scroll())
		_vel *= exp(-5.0 * dt)
		queue_redraw()


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			_drag = true
			_drag_y = e.position.y
			_drag_moved = 0.0
			_vel = 0.0
		else:
			_drag = false
			if _drag_moved < 14.0:
				_tap(e.position)
		accept_event()
	elif e is InputEventMouseButton and e.pressed and (e.button_index == MOUSE_BUTTON_WHEEL_DOWN or e.button_index == MOUSE_BUTTON_WHEEL_UP):
		scroll = clampf(scroll + (90.0 if e.button_index == MOUSE_BUTTON_WHEEL_DOWN else -90.0), 0.0, _max_scroll())
		queue_redraw()
		accept_event()
	elif e is InputEventMouseMotion and _drag:
		var dy: float = e.position.y - _drag_y
		_drag_y = e.position.y
		_drag_moved += absf(dy)
		scroll = clampf(scroll - dy, 0.0, _max_scroll())
		_vel = -dy * 60.0
		queue_redraw()
		accept_event()


func _close_rect() -> Rect2:
	return Rect2(600, 40, 96, 96)


func _tab_rect(i: int) -> Rect2:
	return Rect2(PAD + i * 342.0, 162, 330, 72)


func _tap(p: Vector2) -> void:
	if _close_rect().grow(10.0).has_point(p):
		if game:
			game.play("tap")
		close()
		return
	for i in 2:
		if _tab_rect(i).has_point(p) and tab != i:
			tab = i
			if game:
				game.play("tap")
			_fill()
			queue_redraw()
			return


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), T.CREAM)
	T.draw_grain(self, Rect2(Vector2.ZERO, size), 0.1)
	# 목록 (머리 띠 아래로 잘라 그린다)
	var y0 := TOP - scroll + 16.0
	for i in _items.size():
		var y := y0 + i * (CARD_H + GAP)
		if y > size.y or y + CARD_H < TOP - CARD_H:
			continue
		_card(_items[i], Rect2(PAD, y, size.x - PAD * 2.0, CARD_H))
	# 머리 띠 + 탭 (목록 위에 덮는다)
	draw_rect(Rect2(0, 0, size.x, TOP), T.CREAM)
	draw_rect(Rect2(0, 0, size.x, 150), T.KRAFT)
	T.draw_torn_edge(self, Vector2(0, 150), Vector2(size.x, 150), T.KRAFT, 10.0, 3)
	var book := _ui("cx_book")
	if book:
		draw_texture_rect(book, Rect2(26, 22, 108, 108), false)
	else:
		T.draw_parcel_icon(self, Vector2(80, 76), 70.0, true)
	T.draw_text_center(self, _L("도감", "Field Guide"), Vector2(360, 78), 54, T.NAVY, 420.0)
	var cr := _close_rect()
	draw_circle(cr.get_center() + Vector2(0, 5), 44.0, T.SHADOW)
	draw_circle(cr.get_center(), 44.0, T.WHITE)
	draw_circle(cr.get_center(), 39.0, T.CREAM)
	T.draw_text_center(self, "✕", cr.get_center(), 40, T.NAVY)
	for i in 2:
		var r := _tab_rect(i)
		var on := tab == i
		T.draw_paper_rect(self, r, T.GOLD if on else T.WHITE, T.WHITE, 4.0 if on else 6.0, 36.0)
		var label := _L("동네 6곳", "6 Towns") if i == 0 else _L("길 · 기물", "Roads & Things")
		T.draw_text_center(self, label, r.get_center(), 32, T.NAVY, r.size.x - 20.0)
	draw_line(Vector2(PAD, TOP - 2), Vector2(size.x - PAD, TOP - 2), T.EMPTY_SLOT, 3.0)
	# 넘길 수 있다는 표 (오른쪽 얇은 막대)
	var ms := _max_scroll()
	if ms > 0.0:
		var vh := size.y - TOP
		var bh := maxf(vh * vh / _content_h(), 60.0)
		var by := TOP + (vh - bh) * (scroll / ms)
		draw_rect(Rect2(size.x - 10, by, 5, bh), Color(T.NAVY, 0.25))


func _card(it: Dictionary, r: Rect2) -> void:
	T.draw_paper_rect(self, r, T.WHITE, T.WHITE, 6.0, 16.0)
	draw_rect(Rect2(r.position + Vector2(0, 14), Vector2(8, r.size.y - 28)), it.accent)
	var tex: Texture2D = it.get("tex")
	var th := r.size.y - 28.0
	var tr := Rect2(r.position + Vector2(22, 14), Vector2(th * (1.5 if it.get("wide", false) else 1.0), th))
	if tex != null:
		if it.get("wide", false):
			# 배경 그림 가운데 아래쪽(거리)을 잘라 보인다
			var tw := float(tex.get_width())
			var tht := float(tex.get_height())
			var rw := tw * 0.42
			var rh := rw / 1.5
			var src := Rect2((tw - rw) * 0.5, tht * 0.62 - rh * 0.5, rw, rh)
			draw_texture_rect_region(tex, tr, src)
			draw_rect(tr, T.WHITE, false, 4.0)
		else:
			draw_rect(tr, T.CREAM)
			draw_texture_rect(tex, tr.grow(-6.0), false)
	else:
		draw_rect(tr, T.CREAM)
		T.draw_parcel_icon(self, tr.get_center(), th * 0.55, true)
	var tx := tr.end.x + 20.0
	var w := r.end.x - tx - 16.0
	T.draw_text_block(self, it.name, Vector2(tx, r.position.y + 16), w, 32, T.NAVY, HORIZONTAL_ALIGNMENT_LEFT, 1)
	T.draw_text_block(self, it.desc, Vector2(tx, r.position.y + 62), w, 24, T.MUTED.darkened(0.25), HORIZONTAL_ALIGNMENT_LEFT, 3)
