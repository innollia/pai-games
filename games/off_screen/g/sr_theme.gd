extends RefCounted
## 화면 밖 경주 디자인 시스템 (Pocket Parcel Town, 종이 공작 디오라마).
## 모든 UI 모듈(sr_*.gd)과 screenrace.gd 가 같은 색·글꼴·모서리·그림자·움직임을 쓰도록 모은 곳.
## 사용: const T = preload("res://g/sr_theme.gd")  ->  T.RED, T.panel(), T.PaperButton.new(), T.pop_in(n)
## 규칙 요약은 submit/screenrace/DESIGN_SYSTEM.md.

# ---------------------------------------------------------------- 색 (이것과 밝기 변형만 쓴다)
const NAVY := Color("2A2C44")      # 잉크: 글자, 외곽선, 그림자
const KRAFT := Color("E3BA88")     # 골판지: 조작 덱, 배지 바탕
const KRAFT_SH := Color("BA8E5C")  # 골판지 그늘: 카드 테두리, 판 그림자
const CREAM := Color("FFFDF5")     # 마닐라 종이: 패널, 카드
const WHITE := Color("FFFFFF")     # 종이 가장자리(흰 테두리)
const RED := Color("E85244")       # 우편 빨강: 위험, 주 행동 버튼(강조색 하나)
const GOLD := Color("F7B336")      # 배달 금색: 보상, 선택, 1등
const PARCEL := Color("D99B5B")    # 소포 갈색
const GREEN := Color("2B9348")     # 성공, 배달 완료
const BLUE := Color("3D78B5")      # 플레이어, 효과 글
const NIGHT := Color("1B1F38")     # 등불 모드 밤
const AMBER := Color("FFD166")     # 등불 빛
const MUTED := Color("6C757D")     # 보조 글(조언, 비활성)

# 파생 색 (같은 팔레트의 밝기 변형)
const SHADOW := Color(0.165, 0.173, 0.267, 0.25)   # NAVY 25%: 모든 떨어진 그림자
const TROUGH := Color("EAD7BC")                    # 빈 홈(거리 막대 등)
const EMPTY_SLOT := Color("D0C2AE")                # 빈 소포 칸 점선
const SILVER := Color("BAC4C8")
const BRONZE := Color("CD7F32")

# ---------------------------------------------------------------- 글자 크기 단계
const FS_HERO := 56    # 출발!, 큰 결과 도장
const FS_H1 := 40      # 화면 제목
const FS_H2 := 32      # 카드 제목, 버튼
const FS_BODY := 26    # 본문, 배지
const FS_SMALL := 22   # 카드 설명
const FS_TINY := 18    # 조언, 작은 태그

# ---------------------------------------------------------------- 모양 규칙
const RADIUS := 14         # 카드·패널
const RADIUS_SM := 10      # 태그·배지
const EDGE := 4            # 흰 종이 테두리 두께
const SHADOW_Y := 8        # 그림자는 아래로만 (0, 8)
const PRESS_Y := 6.0       # 눌렀을 때 내려가는 거리
const BTN_H := 96          # 주 버튼 높이 (폰 엄지 기준)
const BTN_W := 420

# ---------------------------------------------------------------- 움직임 시간
const T_OPEN := 0.32
const T_CLOSE := 0.20
const T_DOWN := 0.06
const T_UP := 0.22
const T_STAMP := 0.14

const FONT: Font = preload("res://fonts/Pretendard-Bold.otf")
const UI_DIR := "res://art/screenrace/ui/"



static func font() -> Font:
	return FONT


## 종이 카드 StyleBox: 테두리 + 아래로 떨어진 남색 25% 그림자 + 둥근 모서리.
static func panel(bg: Color = CREAM, border: Color = KRAFT_SH, radius: int = 14, border_w: int = 4, shadow: int = 8) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.corner_detail = 6
	sb.anti_aliasing = true
	sb.shadow_color = SHADOW
	sb.shadow_size = 0 if shadow <= 0 else 1
	sb.shadow_offset = Vector2(0, shadow)
	sb.set_content_margin_all(float(border_w + 12))
	return sb


## 글꼴을 넣은 가운데 정렬 라벨 (터치를 막지 않음).
static func make_label(text: String, size: int, color: Color = NAVY, outline: int = 0, outline_color: Color = WHITE) -> Label:
	var l := Label.new()
	var ls := LabelSettings.new()
	ls.font = FONT
	ls.font_size = size
	ls.font_color = color
	ls.outline_size = outline
	ls.outline_color = outline_color
	l.label_settings = ls
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


# ================================================================ 트윈
static func _tw(n: CanvasItem) -> Tween:
	if n.is_inside_tree():
		return n.create_tween()
	var st := Engine.get_main_loop() as SceneTree
	return st.create_tween().bind_node(n)


static func _center_pivot(n: CanvasItem) -> void:
	if n is Control:
		var c := n as Control
		c.pivot_offset = c.size * 0.5


## 카드 열기: 0.32 s BACK OUT, 크기 .85->1, 기울기 -5°->0, 투명 0->1.
static func pop_in(n: CanvasItem, delay := 0.0) -> Tween:
	_center_pivot(n)
	n.show()
	n.set("scale", Vector2(0.85, 0.85))
	n.set("rotation", deg_to_rad(-5.0))
	n.modulate.a = 0.0
	var tw := _tw(n)
	tw.set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if delay > 0.0:
		tw.tween_interval(delay)
		tw.chain()
		tw.set_parallel(true)
	tw.tween_property(n, "scale", Vector2.ONE, T_OPEN)
	tw.tween_property(n, "rotation", 0.0, T_OPEN)
	tw.tween_property(n, "modulate:a", 1.0, T_OPEN * 0.6).set_trans(Tween.TRANS_QUAD)
	return tw


## 닫기: 0.2 s QUAD IN, 크기 ->.92, 아래로 80, 투명 ->0, 끝나면 숨기고 자리·크기 되돌림.
static func pop_out(n: CanvasItem) -> Tween:
	_center_pivot(n)
	var p0: Vector2 = n.get("position")
	var tw := _tw(n)
	tw.set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(n, "scale", Vector2(0.92, 0.92), T_CLOSE)
	tw.tween_property(n, "position", p0 + Vector2(0, 80), T_CLOSE)
	tw.tween_property(n, "modulate:a", 0.0, T_CLOSE)
	tw.chain().tween_callback(func() -> void:
		n.hide()
		n.set("position", p0)
		n.set("scale", Vector2.ONE))
	return tw


## 도장 쾅: 0.14 s CUBIC IN, 크기 1.7->1, 투명 .2->1, 이어서 2 px 0.1 s 흔들림.
static func stamp_slam(n: CanvasItem) -> Tween:
	_center_pivot(n)
	n.show()
	n.set("scale", Vector2(1.7, 1.7))
	n.modulate.a = 0.2
	var tw := _tw(n)
	tw.set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(n, "scale", Vector2.ONE, T_STAMP)
	tw.tween_property(n, "modulate:a", 1.0, T_STAMP)
	tw.chain().tween_callback(func() -> void: shake(n, 2.0, 0.1))
	return tw


## 숫자·아이콘 톡: 잠깐 커졌다 제자리. 연달아 불러도 크기가 밀리지 않게 이전 것을 끊는다.
static func bump(n: CanvasItem, amount := 1.15, t := 0.18) -> Tween:
	_center_pivot(n)
	if n.has_meta(&"_sr_bump"):
		var old: Tween = n.get_meta(&"_sr_bump")
		if old != null and old.is_valid():
			old.kill()
	var base := Vector2.ONE
	n.set("scale", base * amount)
	var tw := _tw(n)
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "scale", base, t)
	n.set_meta(&"_sr_bump", tw)
	return tw


## 흔들기: 원래 자리를 기억해 두고 몇 번 튀었다가 정확히 돌아온다.
static func shake(n: CanvasItem, amount := 6.0, t := 0.2) -> void:
	var o: Vector2
	if n.has_meta(&"_sr_shake"):
		var old: Tween = n.get_meta(&"_sr_shake")
		if old != null and old.is_valid():
			old.kill()
		o = n.get_meta(&"_sr_shake_o")
	else:
		o = n.get("position")
	n.set_meta(&"_sr_shake_o", o)
	var tw := _tw(n)
	var steps := 5
	for i in steps:
		var a := amount * (1.0 - float(i) / float(steps))
		tw.tween_property(n, "position", o + Vector2(randf_range(-a, a), randf_range(-a, a)), t / float(steps + 1))
	tw.tween_property(n, "position", o, t / float(steps + 1))
	tw.tween_callback(func() -> void:
		n.remove_meta(&"_sr_shake")
		n.remove_meta(&"_sr_shake_o"))
	n.set_meta(&"_sr_shake", tw)


# ================================================================ 그리기 도우미 (_draw 안에서)
## 안쪽 클래스(PaperButton 등)는 바깥 static 함수를 못 부르므로 실제 구현은 D 에 두고 바깥은 넘겨준다.
class D:
	static var _tex_cache: Dictionary = {}
	static var _sb_cache: Dictionary = {}

	## UI 그림 (없으면 null -> 부르는 쪽이 직접 그린다). 결과는 캐시.
	static func tex(name: String) -> Texture2D:
		if _tex_cache.has(name):
			return _tex_cache[name]
		var p := UI_DIR + name + ".png"
		var t: Texture2D = null
		if ResourceLoader.exists(p):
			t = load(p) as Texture2D
		_tex_cache[name] = t
		return t


	static func _sb(face: Color, radius: float, border: Color, bw: int) -> StyleBoxFlat:
		var key := "%s|%d|%s|%d" % [face.to_html(), int(radius), border.to_html(), bw]
		if _sb_cache.has(key):
			return _sb_cache[key]
		var sb := StyleBoxFlat.new()
		sb.bg_color = face
		sb.border_color = border
		sb.set_border_width_all(bw)
		sb.set_corner_radius_all(int(radius))
		sb.corner_detail = 6
		sb.anti_aliasing = true
		_sb_cache[key] = sb
		return sb


	## 종이 판: 아래 그림자 + 흰 가장자리 + 면.
	static func draw_paper_rect(ci: CanvasItem, r: Rect2, face: Color, edge := WHITE, shadow := 6.0, radius := 12.0) -> void:
		if shadow > 0.0:
			ci.draw_style_box(_sb(SHADOW, radius, SHADOW, 0), Rect2(r.position + Vector2(0, shadow), r.size))
		ci.draw_style_box(_sb(face, radius, edge, EDGE), r)


	## 찢은 종이 띠: from->to 선을 따라 한쪽(진행 방향의 왼쪽 법선)이 들쭉날쭉. seed 가 같으면 모양도 같다.
	static func draw_torn_edge(ci: CanvasItem, from: Vector2, to: Vector2, color: Color, depth := 10.0, seed_n := 1) -> void:
		var d := to - from
		var ln := d.length()
		if ln < 1.0:
			return
		var dir := d / ln
		var nrm := Vector2(dir.y, -dir.x)
		var cnt := maxi(2, int(ln / 14.0))
		var pts := PackedVector2Array()
		pts.resize(cnt + 3)
		pts[0] = from
		for i in cnt + 1:
			var f := float(i) / float(cnt)
			var h := _hash01(i, seed_n)
			var along := 0.0 if (i == 0 or i == cnt) else (h - 0.5) * 6.0
			pts[i + 1] = from + dir * (ln * f + along) + nrm * depth * (0.35 + 0.65 * _hash01(i + 97, seed_n))
		pts[cnt + 2] = to
		ci.draw_colored_polygon(pts, color)


	static func _hash01(i: int, s: int) -> float:
		var v := sin(float(i) * 12.9898 + float(s) * 78.233) * 43758.5453
		return v - floorf(v)


	## 소포 아이콘 (그림 없을 때): 골판지 상자 + 빨간 테이프 십자. 빈 칸 = 점선 윤곽.
	static func draw_parcel_icon(ci: CanvasItem, center: Vector2, size: float, filled := true) -> void:
		var w := size
		var h := size * 0.86
		var r := Rect2(center - Vector2(w, h) * 0.5, Vector2(w, h))
		if not filled:
			var c := EMPTY_SLOT
			var tl := r.position
			var tr := r.position + Vector2(w, 0)
			var br := r.end
			var bl := r.position + Vector2(0, h)
			var dash := maxf(3.0, size * 0.14)
			ci.draw_dashed_line(tl, tr, c, 2.0, dash, true, true)
			ci.draw_dashed_line(tr, br, c, 2.0, dash, true, true)
			ci.draw_dashed_line(br, bl, c, 2.0, dash, true, true)
			ci.draw_dashed_line(bl, tl, c, 2.0, dash, true, true)
			return
		var rad := maxf(2.0, size * 0.12)
		draw_paper_rect(ci, r, PARCEL, WHITE, maxf(2.0, size * 0.1), rad)
		# 뚜껑 그늘 띠
		ci.draw_rect(Rect2(r.position + Vector2(4, 4), Vector2(w - 8, h * 0.22)), KRAFT_SH.lerp(PARCEL, 0.4))
		# 빨간 테이프 십자
		var tw := maxf(2.0, size * 0.16)
		ci.draw_rect(Rect2(Vector2(center.x - tw * 0.5, r.position.y + 3), Vector2(tw, h - 6)), RED)
		ci.draw_rect(Rect2(Vector2(r.position.x + 3, center.y - tw * 0.5), Vector2(w - 6, tw)), RED)


	## 가운데 정렬 글자 (세로 가운데). outline > 0 이면 외곽선 먼저.
	static func draw_text_center(ci: CanvasItem, text: String, center: Vector2, size: int, color: Color, width := -1.0, outline := 0, outline_color := NAVY) -> void:
		var asc := FONT.get_ascent(size)
		var desc := FONT.get_descent(size)
		var w := width if width > 0.0 else FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var pos := Vector2(center.x - w * 0.5, center.y + (asc - desc) * 0.5)
		if outline > 0:
			ci.draw_string_outline(FONT, pos, text, HORIZONTAL_ALIGNMENT_CENTER, w, size, outline, outline_color)
		ci.draw_string(FONT, pos, text, HORIZONTAL_ALIGNMENT_CENTER, w, size, color)


	## 여러 줄 글 (카드 설명용). 위 왼쪽 기준, 너비 안에서 줄바꿈.
	static func draw_text_block(ci: CanvasItem, text: String, top_left: Vector2, width: float, size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT, max_lines := 4) -> void:
		ci.draw_multiline_string(FONT, top_left + Vector2(0, FONT.get_ascent(size)), text, align, width, size, max_lines, color)


	## 종이결 (그림 있으면 살짝 덮기, 없으면 아무것도 안 함).
	static func draw_grain(ci: CanvasItem, r: Rect2, alpha := 0.12) -> void:
		var g := tex("paper_grain")
		if g == null:
			return
		ci.draw_texture_rect(g, r, true, Color(1, 1, 1, alpha))


	static func darken(c: Color, k := 0.08) -> Color:
		return c.darkened(k)


	## 바탕색에 맞는 글자색 (밝은 면 = 남색, 진한 면 = 흰색).
	static func ink_on(face: Color) -> Color:
		return NAVY if face.get_luminance() > 0.6 else WHITE




## UI 그림 (없으면 null -> 부르는 쪽이 직접 그린다). 결과는 캐시.
static func tex(name: String) -> Texture2D:
	return D.tex(name)


## 종이 판: 아래 그림자 + 흰 가장자리 + 면.
static func draw_paper_rect(ci: CanvasItem, r: Rect2, face: Color, edge := WHITE, shadow := 6.0, radius := 12.0) -> void:
	D.draw_paper_rect(ci, r, face, edge, shadow, radius)


## 찢은 종이 띠 (seed 가 같으면 모양도 같다).
static func draw_torn_edge(ci: CanvasItem, from: Vector2, to: Vector2, color: Color, depth := 10.0, seed_n := 1) -> void:
	D.draw_torn_edge(ci, from, to, color, depth, seed_n)


## 소포 아이콘: 골판지 상자 + 빨간 테이프 십자. 빈 칸 = 점선 윤곽.
static func draw_parcel_icon(ci: CanvasItem, center: Vector2, size: float, filled := true) -> void:
	D.draw_parcel_icon(ci, center, size, filled)


## 가운데 정렬 글자 (세로 가운데).
static func draw_text_center(ci: CanvasItem, text: String, center: Vector2, size: int, color: Color, width := -1.0, outline := 0, outline_color := NAVY) -> void:
	D.draw_text_center(ci, text, center, size, color, width, outline, outline_color)


## 여러 줄 글.
static func draw_text_block(ci: CanvasItem, text: String, top_left: Vector2, width: float, size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT, max_lines := 4) -> void:
	D.draw_text_block(ci, text, top_left, width, size, color, align, max_lines)


## 종이결 덮기 (paper_grain.png 있을 때만).
static func draw_grain(ci: CanvasItem, r: Rect2, alpha := 0.12) -> void:
	D.draw_grain(ci, r, alpha)


static func darken(c: Color, k := 0.08) -> Color:
	return c.darkened(k)


## 바탕색에 맞는 글자색 (밝은 면 = 남색, 진한 면 = 흰색).
static func ink_on(face: Color) -> Color:
	return D.ink_on(face)


# ================================================================ 종이 버튼
## 두툼한 종이 버튼. 누르면 6 px 내려가며 그림자 8->2, 크기 .96; 떼면 탄력 있게 복귀, 안에서 뗐을 때 pressed.
class PaperButton extends Control:
	signal pressed

	var text := "":
		set(v):
			text = v
			queue_redraw()
	var face := Color("E85244"):
		set(v):
			face = v
			queue_redraw()
	var icon_name := "":
		set(v):
			icon_name = v
			queue_redraw()
	var font_size := 30:
		set(v):
			font_size = v
			queue_redraw()
	var disabled := false:
		set(v):
			disabled = v
			queue_redraw()
	var text_color := Color(0, 0, 0, 0)   # 투명 = 바탕에 맞춰 자동
	var radius := 18.0

	var press_k := 0.0:   # 0 = 떠 있음, 1 = 눌림
		set(v):
			press_k = v
			queue_redraw()
	var _down := false
	var _tween: Tween

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_NONE
		resized.connect(func() -> void: pivot_offset = size * 0.5)

	func _gui_input(e: InputEvent) -> void:
		var is_press := false
		var is_release := false
		var pos := Vector2.ZERO
		if e is InputEventScreenTouch:
			var t := e as InputEventScreenTouch
			is_press = t.pressed
			is_release = not t.pressed
			pos = t.position
		elif e is InputEventMouseButton:
			var m := e as InputEventMouseButton
			if m.button_index != MOUSE_BUTTON_LEFT:
				return
			is_press = m.pressed
			is_release = not m.pressed
			pos = m.position
		else:
			return
		accept_event()
		if disabled:
			return
		if is_press and not _down:
			_down = true
			_anim(true)
		elif is_release and _down:
			_down = false
			_anim(false)
			if Rect2(Vector2.ZERO, size).grow(16.0).has_point(pos):
				pressed.emit()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_EXIT and _down and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_down = false
			_anim(false)

	func _anim(down: bool) -> void:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		pivot_offset = size * 0.5
		_tween = create_tween().set_parallel(true)
		if down:
			_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_tween.tween_property(self, "press_k", 1.0, 0.06)
			_tween.tween_property(self, "scale", Vector2(0.96, 0.96), 0.06)
		else:
			_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			_tween.tween_property(self, "press_k", 0.0, 0.22)
			_tween.tween_property(self, "scale", Vector2.ONE, 0.22)

	func _draw() -> void:
		var sh := 8.0
		var body_h := size.y - sh
		var dy := press_k * 6.0
		var f := face
		if disabled:
			f = f.lerp(Color("D0C2AE"), 0.7)
		elif press_k > 0.0:
			f = f.darkened(0.08 * press_k)
		# 받침(그림자 판): 면보다 진한 색, 아래로 8 -> 눌리면 2
		var plate := Rect2(Vector2(0, sh), Vector2(size.x, body_h))
		draw_style_box(D._sb(f.darkened(0.32), radius, f.darkened(0.32), 0), plate)
		var r := Rect2(Vector2(0, dy), Vector2(size.x, body_h))
		draw_style_box(D._sb(f, radius, Color.WHITE, 4), r)
		D.draw_grain(self, r.grow(-6.0), 0.10)
		# 위쪽 하이라이트 줄 (종이 접힘)
		draw_line(r.position + Vector2(radius, 9), Vector2(r.end.x - radius, r.position.y + 9), Color(1, 1, 1, 0.28), 3.0, true)
		var ink := text_color if text_color.a > 0.0 else D.ink_on(f)
		if disabled:
			ink = Color("6C757D")
		var cx := r.position.x + r.size.x * 0.5
		var cy := r.position.y + r.size.y * 0.5
		var ic := D.tex(icon_name) if icon_name != "" else null
		if ic != null:
			var isz := minf(r.size.y - 20.0, 72.0)
			var ix := r.position.x + 18.0
			draw_texture_rect(ic, Rect2(Vector2(ix, cy - isz * 0.5), Vector2(isz, isz)), false)
			var left := ix + isz + 8.0
			D.draw_text_center(self, text, Vector2((left + r.end.x - 14.0) * 0.5, cy), font_size, ink, r.end.x - 14.0 - left)
		else:
			D.draw_text_center(self, text, Vector2(cx, cy), font_size, ink, r.size.x - 24.0)


# ================================================================ 우표 카드 (모드·특기·길 고르기)
## 우표처럼 가장자리가 톱니(둥근 이)인 크림 카드. 강조 띠, 위쪽 그림, 아이콘 원, 제목·설명.
## selected = 들려 올라가고 금색 테두리 + 살짝 기울기.
class PaperCard extends Control:
	signal pressed

	var title := "":
		set(v):
			title = v
			queue_redraw()
	var body := "":
		set(v):
			body = v
			queue_redraw()
	var icon_name := "":
		set(v):
			icon_name = v
			queue_redraw()
	var art_name := "":
		set(v):
			art_name = v
			queue_redraw()
	var accent := Color("3D78B5"):
		set(v):
			accent = v
			queue_redraw()
	var selected := false:
		set(v):
			if v == selected:
				return
			selected = v
			_anim_sel()
	var paper := Color("FFFDF5")     # 카드 면 (등불 카드는 NIGHT 로 바꿔도 됨)
	var title_color := Color(0, 0, 0, 0)  # 투명 = 자동
	var body_color := Color(0, 0, 0, 0)
	var disabled := false:
		set(v):
			disabled = v
			queue_redraw()
	var horizontal := false   # true = 아이콘 왼쪽, 글 오른쪽 (가로로 긴 특기·길 카드)

	var press_k := 0.0:
		set(v):
			press_k = v
			queue_redraw()
	var sel_k := 0.0:
		set(v):
			sel_k = v
			rotation = deg_to_rad(-2.0) * v
			queue_redraw()
	var _down := false
	var _tween: Tween
	var _stw: Tween

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_NONE
		resized.connect(func() -> void: pivot_offset = size * 0.5)

	func _gui_input(e: InputEvent) -> void:
		var is_press := false
		var is_release := false
		var pos := Vector2.ZERO
		if e is InputEventScreenTouch:
			var t := e as InputEventScreenTouch
			is_press = t.pressed
			is_release = not t.pressed
			pos = t.position
		elif e is InputEventMouseButton:
			var m := e as InputEventMouseButton
			if m.button_index != MOUSE_BUTTON_LEFT:
				return
			is_press = m.pressed
			is_release = not m.pressed
			pos = m.position
		else:
			return
		accept_event()
		if disabled:
			return
		if is_press and not _down:
			_down = true
			_anim(true)
		elif is_release and _down:
			_down = false
			_anim(false)
			if Rect2(Vector2.ZERO, size).grow(12.0).has_point(pos):
				pressed.emit()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_EXIT and _down and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_down = false
			_anim(false)

	func _anim(down: bool) -> void:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		pivot_offset = size * 0.5
		_tween = create_tween().set_parallel(true)
		var s := 1.0 + 0.04 * sel_k
		if down:
			_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_tween.tween_property(self, "press_k", 1.0, 0.06)
			_tween.tween_property(self, "scale", Vector2(0.96, 0.96), 0.06)
		else:
			_tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			_tween.tween_property(self, "press_k", 0.0, 0.22)
			_tween.tween_property(self, "scale", Vector2(s, s), 0.22)

	func _anim_sel() -> void:
		if not is_inside_tree():
			sel_k = 1.0 if selected else 0.0
			return
		if _stw != null and _stw.is_valid():
			_stw.kill()
		pivot_offset = size * 0.5
		_stw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		var k := 1.0 if selected else 0.0
		_stw.tween_property(self, "sel_k", k, 0.24)
		_stw.tween_property(self, "scale", Vector2.ONE * (1.0 + 0.04 * k), 0.24)

	func _draw() -> void:
		var lift := -10.0 * sel_k + press_k * 6.0
		var sh := 8.0 - press_k * 6.0 + sel_k * 6.0
		var r := Rect2(Vector2(10, 10 + lift), size - Vector2(20, 28))
		var perf := 7.0
		# 그림자 (톱니 포함한 크기)
		draw_style_box(D._sb(Color(0.165, 0.173, 0.267, 0.25), 10.0, Color(0, 0, 0, 0), 0), Rect2(r.position + Vector2(0, sh), r.size).grow(perf * 0.5))
		# 흰 종이 가장자리 + 둥근 이 (우표 톱니)
		var edge_c := Color.WHITE
		draw_rect(r, edge_c)
		_perforate(r, perf, edge_c)
		# 금색 선택 테두리
		if sel_k > 0.01:
			draw_rect(r.grow(perf + 3.0), Color(0.969, 0.702, 0.212, sel_k), false, 5.0 * sel_k)
		# 면
		var inner := r.grow(-8.0)
		var pf := paper
		if disabled:
			pf = pf.lerp(Color("D0C2AE"), 0.5)
		draw_rect(inner, pf)
		D.draw_grain(self, inner, 0.10)
		var tc := title_color if title_color.a > 0.0 else D.ink_on(pf)
		var bc := body_color if body_color.a > 0.0 else (tc if pf.get_luminance() < 0.6 else Color("2A2C44").lerp(pf, 0.15))
		if disabled:
			tc = Color("6C757D")
			bc = Color("6C757D")
		if horizontal:
			_draw_horizontal(inner, tc, bc)
		else:
			_draw_vertical(inner, tc, bc)

	func _draw_vertical(inner: Rect2, tc: Color, bc: Color) -> void:
		# 강조 띠 (위)
		draw_rect(Rect2(inner.position, Vector2(inner.size.x, 12)), accent)
		var y := inner.position.y + 20.0
		var art := D.tex(art_name) if art_name != "" else null
		if art != null:
			var aw := inner.size.x - 16.0
			var ah := minf(aw * 1.2, inner.size.y * 0.5)
			draw_texture_rect(art, Rect2(Vector2(inner.position.x + 8, y), Vector2(aw, ah)), false)
			y += ah + 6.0
		else:
			var cr := minf(inner.size.x * 0.28, 56.0)
			_icon_circle(Vector2(inner.get_center().x, y + cr + 6.0), cr)
			y += cr * 2.0 + 20.0
		D.draw_text_center(self, title, Vector2(inner.get_center().x, y + 20.0), 32, tc, inner.size.x - 16.0)
		y += 46.0
		D.draw_text_block(self, body, Vector2(inner.position.x + 12, y), inner.size.x - 24.0, 22, bc, HORIZONTAL_ALIGNMENT_CENTER, 6)

	func _draw_horizontal(inner: Rect2, tc: Color, bc: Color) -> void:
		# 강조 띠 (왼쪽)
		draw_rect(Rect2(inner.position, Vector2(12, inner.size.y)), accent)
		var cr := minf(inner.size.y * 0.32, 52.0)
		var cc := Vector2(inner.position.x + 28.0 + cr, inner.get_center().y)
		_icon_circle(cc, cr)
		var left := cc.x + cr + 22.0
		var w := inner.end.x - left - 14.0
		D.draw_text_block(self, title, Vector2(left, inner.position.y + 22.0), w, 32, tc, HORIZONTAL_ALIGNMENT_LEFT, 1)
		D.draw_text_block(self, body, Vector2(left, inner.position.y + 70.0), w, 22, bc, HORIZONTAL_ALIGNMENT_LEFT, 4)

	func _icon_circle(c: Vector2, cr: float) -> void:
		draw_circle(c + Vector2(0, 4), cr + 4.0, Color(0.165, 0.173, 0.267, 0.2))
		draw_circle(c, cr + 4.0, Color("2A2C44"))
		draw_circle(c, cr, accent.lerp(Color.WHITE, 0.75))
		var ic := D.tex(icon_name) if icon_name != "" else null
		if ic != null:
			var s := cr * 1.6
			draw_texture_rect(ic, Rect2(c - Vector2(s, s) * 0.5, Vector2(s, s)), false)
		elif icon_name == "parcel" or icon_name == "":
			D.draw_parcel_icon(self, c, cr * 1.1, true)
		else:
			# 그림이 없으면 머리글자 한 자
			D.draw_text_center(self, title.left(1), c, int(cr * 0.9), Color("2A2C44"))

	func _perforate(r: Rect2, pr: float, c: Color) -> void:
		var step := pr * 2.6
		var nx := maxi(2, int(r.size.x / step))
		var ny := maxi(2, int(r.size.y / step))
		var sx := r.size.x / float(nx)
		var sy := r.size.y / float(ny)
		for i in nx + 1:
			var x := r.position.x + sx * float(i)
			draw_circle(Vector2(x, r.position.y), pr, c)
			draw_circle(Vector2(x, r.end.y), pr, c)
		for j in ny + 1:
			var y := r.position.y + sy * float(j)
			draw_circle(Vector2(r.position.x, y), pr, c)
			draw_circle(Vector2(r.end.x, y), pr, c)
