extends "res://g/overpower.gd"
## 과속 플랫포머 방 만들기 (PC 마우스): 위 격자에 칸을 칠하고, 아래 버튼으로 해보기·되돌리기·저장·내려받기·제출. 왼쪽 끌기 칠하기, 오른쪽 끌기 지우기, Shift+끌기 네모 채우기, Ctrl+Z 되돌리기.
## 해보기는 진짜 게임(load_room_data)으로 그 방을 바로 플레이하고, 오른쪽 아래 '편집' 버튼으로 같은 방 그대로 돌아온다.
## 방 데이터는 overpower.gd 와 같다: {name, rows(12줄 x 22글자), ents[{k,x,y}], pal}. 저장은 웹 localStorage "tofu_overpower_rooms"(아니면 user://).

const ED_KEY := "tofu_overpower_rooms"
const DRAFT_KEY := "tofu_overpower_draft"
const CELL := 32.0
const GX := 8.0
const GY := 116.0
const GRID_RECT := Rect2(8, 116, 704, 384)
const SHAPES := ["flat", "long", "thin", "fast"]
const SHAPE_KO := {"flat": "납작", "long": "길게", "thin": "가늘게", "fast": "질주"}
const TOOLS := [".", "#", "^", "X", "start", "door", "hint"]
const TOOL_KO := {".": "빈칸", "#": "벽", "^": "가시", "X": "금 간 벽", "start": "시작", "door": "문", "hint": "힌트"}
const PAGE := 16


class _Ed extends Control:
	var k

	func _draw() -> void:
		k._ed_draw(self)


var editing := true
var ed_rows: Array = []
var ed_ents: Array = []
var ed_name := "새 방"
var ed_pal := 0
var tool := "#"
var hint_shape := "flat"
var undo: Array = []
var saved: Array = []
var ed_layer: CanvasLayer
var ed: _Ed
var hover := Vector2(-1, -1)
var stroke := 0  # 0 없음, 1 칠하기(왼쪽), 2 지우기(오른쪽)
var rect_on := false
var rect_a := Vector2i(-1, -1)
var rect_b := Vector2i(-1, -1)
var last_cell := Vector2i(-1, -1)
var status := ""
var status_bad := false
var status_t := 0.0
var picker := false
var pick_page := 0
var sub_wait := false


func _setup() -> void:
	super._setup()
	howto = "방 만들기 (PC 마우스)\n왼쪽 끌기: 칠하기\n오른쪽 끌기: 지우기\nShift+끌기: 네모 채우기\nCtrl+Z 또는 '되돌리기'\n아래 도구로 벽·가시·금 간 벽·시작·문·힌트를 고르고, '해보기'로 바로 플레이, '편집'으로 돌아온다. 저장은 이 브라우저에, '제출'은 만든 방을 보낸다."
	ed_layer = CanvasLayer.new()
	ed_layer.layer = 0
	add_child(ed_layer)
	ed = _Ed.new()
	ed.k = self
	ed.size = Vector2(720, 1280)
	ed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ed_layer.add_child(ed)
	saved = _read_list(ED_KEY)
	var draft: Variant = _read_any(DRAFT_KEY)
	if draft is Dictionary and not (draft as Dictionary).is_empty():
		_set_room(_norm(draft))
	else:
		_set_room(_blank())


func _reset() -> void:
	stage = null
	picking = false
	_enter_edit()


# ---- 방 데이터 ----
func _blank() -> Dictionary:
	var rows: Array = []
	for r in GRID_H:
		if r == 0 or r == GRID_H - 1:
			rows.append("#".repeat(GRID_W))
		else:
			rows.append("#" + ".".repeat(GRID_W - 2) + "#")
	return {"name": "새 방", "rows": rows, "ents": [{"k": "start", "x": 1, "y": GRID_H - 2}, {"k": "door", "x": GRID_W - 2, "y": GRID_H - 2}], "pal": ed_pal}


## 어디서 온 방이든 편집기 모양으로 맞춘다 (빠진 줄은 벽, 모르는 요소는 버림)
func _norm(d: Dictionary) -> Dictionary:
	var src: Array = d.get("rows", []) if d.get("rows", []) is Array else []
	var rows: Array = []
	for r in GRID_H:
		var s := String(src[r]) if r < src.size() else ""
		s = s.replace(" ", ".").rpad(GRID_W, "#").substr(0, GRID_W)
		var t := ""
		for ch in s:
			t += ch if TILES.has(ch) else "#"
		rows.append(t)
	var ents: Array = []
	var src_e: Array = d.get("ents", []) if d.get("ents", []) is Array else []
	for e in src_e:
		if not e is Dictionary:
			continue
		var k := String(e.get("k", ""))
		if not ENT_KINDS.has(k):
			continue
		var n := {"k": k, "x": clampi(int(e.get("x", 0)), 0, GRID_W - 1), "y": clampi(int(e.get("y", 0)), 0, GRID_H - 1)}
		if k == "hint":
			n["shape"] = String(e.get("shape", "flat")) if SHAPES.has(String(e.get("shape", "flat"))) else "flat"
			n["dx"] = float(e.get("dx", 0.0))
		ents.append(n)
	return {"name": String(d.get("name", "내 방")).left(30), "rows": rows, "ents": ents, "pal": clampi(int(d.get("pal", 0)), 0, BUNDLES.size() - 1)}


func _room() -> Dictionary:
	return {"name": ed_name, "rows": ed_rows.duplicate(), "ents": ed_ents.duplicate(true), "pal": ed_pal}


func _set_room(d: Dictionary) -> void:
	ed_rows = (d.rows as Array).duplicate()
	ed_ents = (d.ents as Array).duplicate(true)
	ed_name = d.name
	ed_pal = d.pal


func _push_undo() -> void:
	undo.append(_room())
	if undo.size() > 100:
		undo.pop_front()


func _undo() -> void:
	if undo.is_empty():
		_say("더 되돌릴 게 없어요", true)
		return
	_set_room(undo.pop_back())
	_draft()
	play("tap")
	_say("되돌렸어요")


func _tile_at(c: int, r: int) -> String:
	return String(ed_rows[r])[c]


func _set_tile(c: int, r: int, ch: String) -> void:
	var s := String(ed_rows[r])
	if s[c] == ch:
		return
	ed_rows[r] = s.substr(0, c) + ch + s.substr(c + 1)


func _ent(k: String) -> int:
	for i in ed_ents.size():
		if ed_ents[i].k == k:
			return i
	return -1


func _put_ent(k: String, c: int, r: int) -> void:
	var i := _ent(k)
	if i < 0:
		ed_ents.append({"k": k})
		i = ed_ents.size() - 1
	var e: Dictionary = ed_ents[i]
	e["x"] = c
	e["y"] = r
	if k == "hint":
		e["shape"] = hint_shape
		e["dx"] = float(e.get("dx", 0.0))
	# 같은 종류가 여럿이면(불러온 방) 하나만 남긴다
	for j in range(ed_ents.size() - 1, i, -1):
		if ed_ents[j].k == k:
			ed_ents.remove_at(j)


## 틀린 점을 한국어로 (없으면 "")
func _check_room() -> String:
	var ns := 0
	var nd := 0
	for e in ed_ents:
		ns += 1 if e.k == "start" else 0
		nd += 1 if e.k == "door" else 0
	if ns == 0:
		return "시작 자리(파란 몸)를 하나 놓아 주세요"
	if ns > 1:
		return "시작 자리는 하나만 있어야 해요"
	if nd == 0:
		return "문(초록)을 하나 놓아 주세요"
	if nd > 1:
		return "문은 하나만 있어야 해요"
	var d: Dictionary = ed_ents[_ent("door")]
	if int(d.y) < 1:
		return "문은 2칸 높이라 맨 윗줄에는 못 놓아요"
	if _tile_at(d.x, d.y) != "." or _tile_at(d.x, d.y - 1) != ".":
		return "문 자리 2칸(문과 그 위)이 비어 있어야 해요"
	var s: Dictionary = ed_ents[_ent("start")]
	if _tile_at(s.x, s.y) != "." or (int(s.y) > 0 and _tile_at(s.x, s.y - 1) != "."):
		return "시작 자리 2칸(발과 머리)이 비어 있어야 해요"
	return ""


# ---- 모드 ----
func _enter_edit() -> void:
	editing = true
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = null
	hud.visible = false
	ed_layer.visible = true
	held = false
	stroke = 0
	rect_on = false
	_kit_clear()
	if _btns.has("rooms"):
		_btns["rooms"].label = "방"


func _play_test() -> void:
	var why := _check_room()
	if why != "":
		_say(why, true)
		play("bad")
		return
	editing = false
	picker = false
	ed_layer.visible = false
	hud.visible = true
	_kit_clear()
	_btns["rooms"].label = "편집"
	_draft()
	load_room_data(_room())


func _room_label() -> String:
	if lv < 0:
		return "시험 " + String(cur.get("name", "내 방"))
	return super._room_label()


func _step(dt: float) -> void:
	if editing:
		return
	if kit_just("rooms"):
		play("tap")
		_enter_edit()
		_say("편집으로 돌아왔어요")
		return
	super._step(dt)


func _process(dt: float) -> void:
	super._process(dt)
	_score_l.visible = false
	if not editing:
		return
	if _pad:
		_pad.visible = false
	_bar_bg.visible = false
	status_t -= dt
	if sub_wait:
		var r: Variant = JavaScriptBridge.eval("window.tofuLast", true)
		if r == "ok":
			sub_wait = false
			_say("제출했어요! 고마워요")
		elif r == "fail":
			sub_wait = false
			_say("제출이 안 됐어요 (인터넷 확인)", true)
	ed.queue_redraw()


# ---- 입력 ----
func _unhandled_input(event: InputEvent) -> void:
	if not editing:
		super._unhandled_input(event)
		return
	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_Z and (event.ctrl_pressed or event.meta_pressed):
			_undo()
		return
	if event is InputEventMouseMotion:
		hover = event.position
		if stroke != 0:
			_stroke_to(event.position)
		return
	if not event is InputEventMouseButton:
		return
	var p: Vector2 = event.position
	var bi: int = event.button_index
	if bi == MOUSE_BUTTON_LEFT and event.pressed:
		if p.x < 180.0 and p.y < 100.0:
			back.emit()
			return
		if _howto_box and _howto_box.visible:
			_howto_box.visible = false
			play("tap")
			return
		if _rating:
			_rate_hit(p)
			return
		if _RATE_BTN.has_point(p):
			_rate_open()
			return
	if (_howto_box and _howto_box.visible) or _rating:
		return
	if bi != MOUSE_BUTTON_LEFT and bi != MOUSE_BUTTON_RIGHT:
		return
	if event.pressed:
		_press(p, 1 if bi == MOUSE_BUTTON_LEFT else 2, event.shift_pressed)
	else:
		_release()


func _cell(p: Vector2) -> Vector2i:
	if not GRID_RECT.has_point(p):
		return Vector2i(-1, -1)
	return Vector2i(clampi(int((p.x - GX) / CELL), 0, GRID_W - 1), clampi(int((p.y - GY) / CELL), 0, GRID_H - 1))


func _press(p: Vector2, which: int, shift: bool) -> void:
	if picker:
		if which == 1:
			_pick_hit(p)
		return
	var cl := _cell(p)
	if cl.x < 0:
		if which == 1:
			_button_hit(p)
		return
	_push_undo()
	stroke = which
	last_cell = cl
	var ent_tool := tool == "start" or tool == "door" or tool == "hint"
	if shift and not (ent_tool and which == 1):
		rect_on = true
		rect_a = cl
		rect_b = cl
		return
	_apply(cl)


func _stroke_to(p: Vector2) -> void:
	var cl := _cell(p)
	if cl.x < 0:
		return
	if rect_on:
		rect_b = cl
		return
	# 빠르게 끌어도 칸이 비지 않게 사이 칸도 칠한다
	var n := maxi(absi(cl.x - last_cell.x), absi(cl.y - last_cell.y))
	for i in range(1, n + 1):
		var f := float(i) / n
		_apply(Vector2i(roundi(lerpf(last_cell.x, cl.x, f)), roundi(lerpf(last_cell.y, cl.y, f))))
	last_cell = cl


func _release() -> void:
	if stroke == 0:
		return
	if rect_on:
		var a := Vector2i(mini(rect_a.x, rect_b.x), mini(rect_a.y, rect_b.y))
		var b := Vector2i(maxi(rect_a.x, rect_b.x), maxi(rect_a.y, rect_b.y))
		for r in range(a.y, b.y + 1):
			for c in range(a.x, b.x + 1):
				_apply(Vector2i(c, r))
		rect_on = false
	stroke = 0
	_draft()


func _apply(cl: Vector2i) -> void:
	if stroke == 2:
		_set_tile(cl.x, cl.y, ".")
		for j in range(ed_ents.size() - 1, -1, -1):
			var e: Dictionary = ed_ents[j]
			if e.k == "hint" and int(e.x) == cl.x and int(e.y) == cl.y:
				ed_ents.remove_at(j)
		return
	if tool == "start" or tool == "door" or tool == "hint":
		_put_ent(tool, cl.x, cl.y)
	else:
		_set_tile(cl.x, cl.y, tool)


# ---- 버튼 ----
func _tool_rect(i: int) -> Rect2:
	if i < 4:
		return Rect2(8 + i * 178, 556, 170, 84)
	return Rect2(8 + (i - 4) * 178, 648, 170, 84)


const PAL_RECT := Rect2(542, 648, 170, 84)


func _act_rects() -> Dictionary:
	var w := 229.0
	return {
		"play": Rect2(8, 752, w, 84), "undo": Rect2(8 + 237, 752, w, 84), "new": Rect2(8 + 474, 752, w, 84),
		"load": Rect2(8, 844, w, 84), "save": Rect2(8 + 237, 844, w, 84), "name": Rect2(8 + 474, 844, w, 84),
		"down": Rect2(8, 936, 348, 84), "send": Rect2(364, 936, 348, 84),
	}


const ACT_KO := {"play": "▶ 해보기", "undo": "되돌리기", "new": "새 방", "load": "불러오기", "save": "저장", "name": "이름", "down": "내려받기 (JSON)", "send": "제출"}


func _button_hit(p: Vector2) -> void:
	for i in TOOLS.size():
		if _tool_rect(i).has_point(p):
			var t: String = TOOLS[i]
			if t == "hint" and tool == "hint":
				hint_shape = SHAPES[(SHAPES.find(hint_shape) + 1) % SHAPES.size()]
				var hi := _ent("hint")
				if hi >= 0:
					_push_undo()
					ed_ents[hi]["shape"] = hint_shape
					_draft()
			tool = t
			play("tap")
			_say(_tool_help())
			return
	if PAL_RECT.has_point(p):
		_push_undo()
		ed_pal = (ed_pal + 1) % BUNDLES.size()
		_draft()
		play("tap")
		_say("팔레트 %d: %s" % [ed_pal, BUNDLES[ed_pal].name])
		return
	var acts := _act_rects()
	for a in acts:
		if (acts[a] as Rect2).has_point(p):
			play("tap")
			_do(a)
			return


func _do(a: String) -> void:
	match a:
		"play":
			_play_test()
		"undo":
			_undo()
		"new":
			_push_undo()
			_set_room(_blank())
			_draft()
			_say("새 방 (되돌리기로 돌아갈 수 있어요)")
		"load":
			picker = true
			pick_page = 0
		"save":
			_save_room()
		"name":
			var s := _js_ask("방 이름 (30자까지)").strip_edges()
			if s == "":
				_say("이름은 웹에서 바꿀 수 있어요" if not OS.has_feature("web") else "이름을 안 바꿨어요")
				return
			_push_undo()
			ed_name = s.left(30)
			_draft()
			_say("이름: " + ed_name)
		"down":
			_download()
		"send":
			_submit()


func _tool_help() -> String:
	match tool:
		"start":
			return "시작: 칸을 누르면 몸이 거기 선다 (발 칸 + 위 칸이 비어야)"
		"door":
			return "문: 칸을 누르면 문이 거기 (그 칸 + 위 칸, 2칸이 비어야)"
		"hint":
			return "힌트(%s): 흐린 몸 그림자. 버튼을 한 번 더 누르면 모양이 바뀐다" % SHAPE_KO[hint_shape]
	return "%s: 왼쪽 끌기 칠하기 · 오른쪽 끌기 지우기 · Shift 네모" % TOOL_KO[tool]


func _say(s: String, bad := false) -> void:
	status = s
	status_bad = bad
	status_t = 3.0


# ---- 불러오기 ----
func _pick_list() -> Array:
	var out: Array = []
	for i in ROOMS.size():
		var d: Dictionary = (ROOMS[i] as Dictionary).duplicate(true)
		d["pal"] = mini(i / PER_BUNDLE, BUNDLES.size() - 1)
		out.append({"label": "기본 %d-%d %s" % [i / PER_BUNDLE + 1, i % PER_BUNDLE + 1, ROOMS[i].name], "room": d})
	for d in saved:
		out.append({"label": "내 방 · " + String(d.get("name", "")), "room": d})
	return out


func _pick_rect(i: int) -> Rect2:
	return Rect2(32 + (i % 2) * 336, 190 + (i / 2) * 96, 320, 84)


const PICK_PREV := Rect2(32, 990, 200, 84)
const PICK_NEXT := Rect2(260, 990, 200, 84)
const PICK_CLOSE := Rect2(488, 990, 200, 84)


func _pick_hit(p: Vector2) -> void:
	var items := _pick_list()
	var pages := maxi(1, ceili(float(items.size()) / PAGE))
	if PICK_PREV.has_point(p):
		pick_page = (pick_page - 1 + pages) % pages
		play("tap")
		return
	if PICK_NEXT.has_point(p):
		pick_page = (pick_page + 1) % pages
		play("tap")
		return
	if PICK_CLOSE.has_point(p):
		picker = false
		play("tap")
		return
	for i in PAGE:
		var n := pick_page * PAGE + i
		if n < items.size() and _pick_rect(i).has_point(p):
			_push_undo()
			_set_room(_norm(items[n].room))
			_draft()
			picker = false
			play("tap")
			_say("불러옴: " + ed_name)
			return


# ---- 저장·내려받기·제출 ----
func _json() -> String:
	return JSON.stringify(_room())


func _save_room() -> void:
	var d := _room()
	var put := false
	for i in saved.size():
		if String(saved[i].get("name", "")) == ed_name:
			saved[i] = d
			put = true
	if not put:
		saved.append(d)
	if _write(ED_KEY, JSON.stringify(saved)):
		_say("저장했어요: %s (내 방 %d개, 같은 이름은 덮어씀)" % [ed_name, saved.size()])
	else:
		_say("저장이 안 됐어요", true)


func _draft() -> void:
	_write(DRAFT_KEY, _json())


func _download() -> void:
	if not OS.has_feature("web"):
		_say("내려받기는 웹에서만 돼요")
		return
	var fname := "overpower_%s.json" % ed_name.validate_filename()
	JavaScriptBridge.download_buffer(JSON.stringify(_room(), "  ").to_utf8_buffer(), fname, "application/json")
	_say("내려받음: " + fname)


func _submit() -> void:
	var why := _check_room()
	if why != "":
		_say(why, true)
		play("bad")
		return
	var s := _json()
	if s.length() > 2000:
		_say("방 데이터가 너무 길어요 (이름을 줄여 보세요)", true)
		return
	if not OS.has_feature("web"):
		_say("제출은 웹에서만 돼요")
		return
	if sub_wait:
		return
	var ver := ("v%d %s" % [gver, VER]).left(40)
	JavaScriptBridge.eval("window.tofuNote && window.tofuNote(%s, %s, %s)" % [JSON.stringify("overpower_stage"), JSON.stringify(ver), JSON.stringify(s)], true)
	sub_wait = true
	_say("보내는 중")


func _read_any(key: String) -> Variant:
	var text := ""
	if OS.has_feature("web"):
		var r: Variant = JavaScriptBridge.eval("(function(){try{return localStorage.getItem(%s)||''}catch(e){return ''}})()" % JSON.stringify(key), true)
		text = str(r) if r != null else ""
	else:
		var path := "user://%s.json" % key
		if FileAccess.file_exists(path):
			var f := FileAccess.open(path, FileAccess.READ)
			if f:
				text = f.get_as_text()
	if text == "":
		return null
	return JSON.parse_string(text)


func _read_list(key: String) -> Array:
	var v: Variant = _read_any(key)
	var out: Array = []
	if v is Array:
		for d in v:
			if d is Dictionary:
				out.append(_norm(d))
	return out


func _write(key: String, text: String) -> bool:
	if OS.has_feature("web"):
		var r: Variant = JavaScriptBridge.eval("(function(){try{localStorage.setItem(%s,%s);return 'ok'}catch(e){return 'fail'}})()" % [JSON.stringify(key), JSON.stringify(text)], true)
		return str(r) == "ok"
	var f := FileAccess.open("user://%s.json" % key, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(text)
	return true


# ---- 그리기 ----
func _cell_rect(c: float, r: float, w := 1.0, h := 1.0) -> Rect2:
	return Rect2(GX + c * CELL, GY + r * CELL, w * CELL, h * CELL)


func _swatch(c: Control, at: Rect2, t: String) -> void:
	var pal: Dictionary = BUNDLES[ed_pal]
	match t:
		".":
			c.draw_rect(at, pal.back)
		"#":
			c.draw_rect(at, pal.wall)
			c.draw_rect(Rect2(at.position, Vector2(at.size.x, at.size.y * 0.18)), pal.trim)
		"^":
			c.draw_rect(at, pal.back)
			c.draw_rect(at.grow(-at.size.x * 0.22), BAD)
		"X":
			c.draw_rect(at, pal.crack)
			c.draw_line(at.position + at.size * Vector2(0.3, 0.15), at.position + at.size * Vector2(0.7, 0.85), INK, 3.0)
		"start":
			c.draw_rect(at, pal.back)
			c.draw_rect(Rect2(at.position + at.size * Vector2(0.25, 0.1), at.size * Vector2(0.5, 0.9)), ME)
		"door":
			c.draw_rect(at, pal.back)
			c.draw_rect(Rect2(at.position + at.size * Vector2(0.2, 0.05), at.size * Vector2(0.6, 0.95)), GOOD)
		"hint":
			c.draw_rect(at, pal.back)
			c.draw_rect(Rect2(at.position + at.size * Vector2(0.1, 0.55), at.size * Vector2(0.8, 0.45)), ME.lerp(WHITE, 0.6))
	c.draw_rect(at, INK, false, 2.0)


func _btn(c: Control, at: Rect2, text: String, on := false, fill := WHITE, size := 32) -> void:
	c.draw_rect(at, ME.lerp(WHITE, 0.82) if on else fill)
	c.draw_rect(at, ME if on else INK, false, 6.0 if on else 3.0)
	c.draw_string(_font, at.position + Vector2(0, at.size.y * 0.5 + size * 0.36), text, HORIZONTAL_ALIGNMENT_CENTER, at.size.x, size, INK)


func _ed_draw(c: Control) -> void:
	var pal: Dictionary = BUNDLES[ed_pal]
	c.draw_rect(Rect2(0, 0, 720, 1280), Color("fff8e6"))
	c.draw_string(_font, Vector2(180, 74), ed_name, HORIZONTAL_ALIGNMENT_CENTER, 360, 38, INK)
	# 격자
	for r in GRID_H:
		for col in GRID_W:
			var ch := _tile_at(col, r)
			var at := _cell_rect(col, r)
			if ch == "#":
				c.draw_rect(at, pal.wall)
			elif ch == "X":
				c.draw_rect(at, pal.crack)
				c.draw_line(at.position + Vector2(10, 4), at.position + Vector2(22, 28), INK, 3.0)
			else:
				c.draw_rect(at, pal.back)
				if ch == "^":
					c.draw_rect(at.grow(-8.0), BAD)
	for col in GRID_W + 1:
		c.draw_line(Vector2(GX + col * CELL, GY), Vector2(GX + col * CELL, GY + GRID_H * CELL), Color(INK, 0.15), 1.0)
	for r in GRID_H + 1:
		c.draw_line(Vector2(GX, GY + r * CELL), Vector2(GX + GRID_W * CELL, GY + r * CELL), Color(INK, 0.15), 1.0)
	# 요소: 힌트(뒤) → 문 → 시작
	for e in ed_ents:
		if e.k == "hint":
			var sz: Vector2 = HINT_SIZE.get(String(e.get("shape", "flat")), HINT_SIZE.flat)
			var cx := int(e.x) + 0.5 + float(e.get("dx", 0.0))
			var at := _cell_rect(cx - sz.x * 0.5, int(e.y) + 1 - sz.y, sz.x, sz.y)
			c.draw_rect(at, Color(ME.lerp(WHITE, 0.6), 0.75))
			c.draw_rect(at, ME, false, 2.0)
	for e in ed_ents:
		if e.k == "door":
			var at := _cell_rect(int(e.x), int(e.y) - 1, 1, 2)
			c.draw_rect(at, pal.trim.darkened(0.25))
			c.draw_rect(at.grow(-4.0), GOOD)
			c.draw_rect(Rect2(at.position + Vector2(20, 30), Vector2(6, 6)), D)
	for e in ed_ents:
		if e.k == "start":
			var at := _cell_rect(int(e.x) + 0.05, int(e.y) + 1 - 1.8, 0.9, 1.8)
			c.draw_rect(at, ME)
			c.draw_rect(at, INK, false, 2.0)
			c.draw_rect(Rect2(at.position + Vector2(at.size.x - 12, 10), Vector2(5, 7)), WHITE)
	c.draw_rect(GRID_RECT, INK, false, 4.0)
	# 네모 채우기 미리보기 / 마우스 칸
	if rect_on:
		var a := Vector2i(mini(rect_a.x, rect_b.x), mini(rect_a.y, rect_b.y))
		var b := Vector2i(maxi(rect_a.x, rect_b.x), maxi(rect_a.y, rect_b.y))
		var rr := _cell_rect(a.x, a.y, b.x - a.x + 1, b.y - a.y + 1)
		c.draw_rect(rr, Color(BAD if stroke == 2 else ME, 0.2))
		c.draw_rect(rr, BAD if stroke == 2 else ME, false, 4.0)
	var hc := _cell(hover)
	if hc.x >= 0 and not picker:
		c.draw_rect(_cell_rect(hc.x, hc.y), ME, false, 3.0)
	# 알림 줄
	var line := status if status_t > 0.0 else _tool_help()
	c.draw_string(_font, Vector2(8, 540), line, HORIZONTAL_ALIGNMENT_LEFT, 704, 26, BAD if (status_bad and status_t > 0.0) else INK)
	# 도구
	for i in TOOLS.size():
		var t: String = TOOLS[i]
		var at := _tool_rect(i)
		var on := t == tool
		c.draw_rect(at, ME.lerp(WHITE, 0.82) if on else WHITE)
		c.draw_rect(at, ME if on else INK, false, 6.0 if on else 3.0)
		_swatch(c, Rect2(at.position + Vector2(12, 18), Vector2(48, 48)), t)
		var nm: String = TOOL_KO[t]
		if t == "hint":
			nm = "힌트:" + SHAPE_KO[hint_shape]
		c.draw_string(_font, at.position + Vector2(66, 54), nm, HORIZONTAL_ALIGNMENT_CENTER, at.size.x - 72, 28, INK)
	c.draw_rect(PAL_RECT, WHITE)
	c.draw_rect(PAL_RECT, INK, false, 3.0)
	c.draw_rect(Rect2(PAL_RECT.position + Vector2(12, 18), Vector2(24, 48)), pal.wall)
	c.draw_rect(Rect2(PAL_RECT.position + Vector2(36, 18), Vector2(24, 48)), pal.trim)
	c.draw_rect(Rect2(PAL_RECT.position + Vector2(12, 18), Vector2(48, 48)), INK, false, 2.0)
	c.draw_string(_font, PAL_RECT.position + Vector2(66, 54), "팔레트 %d" % ed_pal, HORIZONTAL_ALIGNMENT_CENTER, PAL_RECT.size.x - 72, 28, INK)
	# 동작 버튼
	var acts := _act_rects()
	for a in acts:
		var fill := WHITE
		if a == "play":
			fill = GOOD.lerp(WHITE, 0.55)
		elif a == "send":
			fill = D.lerp(WHITE, 0.5)
		_btn(c, acts[a], ACT_KO[a], false, fill, 32)
	# 도움말
	var help := "왼쪽 끌기: 칠하기   오른쪽 끌기: 지우기 (힌트도)\nShift+끌기: 네모 채우기   Ctrl+Z: 되돌리기\n시작·문은 하나씩: 누른 칸으로 옮겨진다. 문은 2칸 높이.\n해보기 중 오른쪽 아래 '편집'을 누르면 이 방으로 돌아온다.\n저장은 이 브라우저에만. '제출'은 만든 방을 보내 준다."
	var y := 1062.0
	for l in help.split("\n"):
		c.draw_string(_font, Vector2(16, y), l, HORIZONTAL_ALIGNMENT_LEFT, 690, 26, INK.lerp(WHITE, 0.25))
		y += 40.0
	if picker:
		_pick_draw(c)


func _pick_draw(c: Control) -> void:
	var items := _pick_list()
	var pages := maxi(1, ceili(float(items.size()) / PAGE))
	pick_page = clampi(pick_page, 0, pages - 1)
	c.draw_rect(Rect2(0, 0, 720, 1280), Color(0, 0, 0, 0.35))
	var panel := Rect2(16, 110, 688, 990)
	c.draw_rect(panel, WHITE)
	c.draw_rect(panel, INK, false, 4.0)
	c.draw_string(_font, Vector2(32, 162), "불러오기  (%d/%d쪽, 내 방 %d개)" % [pick_page + 1, pages, saved.size()], HORIZONTAL_ALIGNMENT_LEFT, 656, 34, INK)
	for i in PAGE:
		var n := pick_page * PAGE + i
		if n >= items.size():
			break
		var at := _pick_rect(i)
		var room: Dictionary = items[n].room
		var b: Dictionary = BUNDLES[clampi(int(room.get("pal", 0)), 0, BUNDLES.size() - 1)]
		c.draw_rect(at, b.back)
		c.draw_rect(Rect2(at.position + Vector2(10, 18), Vector2(48, 48)), b.wall)
		c.draw_rect(Rect2(at.position + Vector2(10, 18), Vector2(48, 48)), INK, false, 2.0)
		c.draw_rect(at, INK, false, 3.0)
		c.draw_string(_font, at.position + Vector2(68, 52), String(items[n].label), HORIZONTAL_ALIGNMENT_LEFT, at.size.x - 76, 26, INK)
	_btn(c, PICK_PREV, "◀ 이전", false, WHITE, 32)
	_btn(c, PICK_NEXT, "다음 ▶", false, WHITE, 32)
	_btn(c, PICK_CLOSE, "닫기", false, SOFT, 32)
