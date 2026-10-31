extends Node
## 개발 도구 (출시 때 이 파일 하나만 지운다. blade.gd 는 이 파일이 없으면 그냥 넘어간다).
## 오른쪽 위 [개발] → UI 편집 · 대사 편집 · 상대 고르기(보스로 건너뛰기) · 내보내기 · 처음대로. 여는 동안 게임은 멈춘다.
## 고친 것은 이 브라우저에 저장된다(user://blade_dev.json). [내보내기]로 복사해 디스코드에 붙이면
## blade.gd 의 BAKED_TEXT(한국어) / BAKED_TEXT_EN(영어) / BAKED_UI 에 넣어 출시판에도 남긴다.

const FILE := "user://blade_dev.json"
const OPEN_R := Rect2(600, 0, 120, 100)
const ROWS := 8  # 대사 편집 한 쪽에 보이는 줄
const UI_NAMES := {
	"info": "위 정보 줄", "stance": "방향 안내 글", "score": "큰 숫자", "bar": "체력 막대", "msg": "가운데 글",
	"tut": "튜토리얼 안내 띠", "skip": "건너뛰기", "top": "로비 기록 띠", "set": "설정 버튼", "title": "로비 제목",
	"home": "지난 판 카드", "play": "전투 버튼", "tut_again": "튜토리얼 다시 보기", "guard": "막기 버튼", "cut": "베기 버튼",
}
const TEXT_NAMES := {
	"title": "게임 제목", "tut_look": "튜토리얼 시작", "tut0": "튜토리얼 1 (막기)", "tut1": "튜토리얼 2 (베기)",
	"tut2": "튜토리얼 3 (간파)", "tut3": "튜토리얼 4 (간파 뒤 베기)", "tut_wait": "튜토리얼: 간파 기다리기",
	"tut_good": "튜토리얼: 잘했어요", "tut_end": "튜토리얼 끝 카드", "skip": "건너뛰기 글자", "play": "전투 버튼 글자",
	"tut_again": "튜토리얼 다시 보기 글자", "parry": "전투: 간파", "parry_go": "전투: 간파 뒤 베라", "parry_twice": "전투: 베기 첫 칼 간파",
	"block": "전투: 막기", "cut": "전투: 베기", "x2": "전투: 간파 일격", "link": "전투: 연격", "whiff": "전투: 헛공격",
	"whiff_steady": "전투: 헛공격(흔들림 없는 손)", "eguard": "전투: 헛막기", "lose": "전투: 간파 놓침", "win": "전투: 승리",
	"dead": "전투: 쓰러짐",
	"foe_intro": "전투: 상대 등장 (%d·%s = 숫자 자리)", "hurt": "전투: 내가 맞음", "rank": "끝판왕: 단 오름",
	"tut_dir": "튜토리얼: 방향 틀림", "tut_btn": "튜토리얼: 버튼 틀림", "pick_head": "능력 고르기 제목",
	"info": "전투 위 글 (체력·상대)", "info_boss": "전투 위 글 (끝판왕)", "stance_none": "방향 안내 (아직 안 잡음)",
	"stance": "방향 안내 (잡은 방향)", "btn_guard": "막기 버튼 글자", "btn_cut": "베기 버튼 글자",
	"best": "로비 위 최고 기록", "home": "로비 첫 안내", "home_dmg": "로비: 끝판왕 최고 피해", "last_dmg": "로비: 지난 판(끝판왕)",
	"last_dead": "로비: 지난 판", "no_perk": "로비: 고른 능력 없음", "perks": "로비: 능력 앞 글",
	"char_head": "캐릭터 탭 제목", "char_row": "캐릭터 탭 한 줄 (이름·쓰러뜨림·죽음)", "char_boss": "캐릭터 탭 끝판왕 줄",
	"char_unknown": "캐릭터 탭 못 만난 검객", "dex_none": "도감: 못 만남", "dex_rec": "도감: 기록", "dex_rec_boss": "도감: 끝판왕 기록",
	"set": "설정 글자", "set_vol": "설정: 소리 크기", "set_vib": "설정: 진동 세기", "close": "설정: 닫기", "off": "설정: 끔",
	"vib_note": "설정: 진동 안내", "tab0": "탭: 전투", "tab1": "탭: 캐릭터", "tab2": "탭: 도감",
	"dex0": "도감 칩 1", "dex1": "도감 칩 2", "dex2": "도감 칩 3", "dex3": "도감 칩 4", "dex4": "도감 칩 5",
}

var g: Node  # blade.gd (부모)
var edits := {"text": {}, "ui": {}, "text_en": {}}  # text = 한국어판 글, text_en = 영어판 글
var base_en := {}  # 고치기 전 영어판 글 (BAKED_TEXT_EN)
var base_text := {}  # 고치기 전 글 (처음대로)
var base_ui := {}  # 고치기 전 자리 (처음대로)
var mode := ""  # "" 닫힘, menu, ui, text, jump
var page := 0
var sel := ""  # UI 편집: 고른 것
var grab := Vector2.ZERO
var finger := -999  # UI 편집: 끄는 손가락
var bar_top := false  # UI 편집 도구 줄을 위로
var note := ""
var view: Control


class _View extends Control:
	var d: Node

	func _draw() -> void:
		d._paint(self)


func _ready() -> void:
	g = get_parent()
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	view = _View.new()
	view.d = self
	view.size = Vector2(720, 1280)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(view)
	base_text = g.say.duplicate()
	for k in UI_NAMES:
		base_ui[k] = _ui_get(k)
	_load()
	base_en = g.say_en.duplicate()
	g.say.merge(edits.text, true)
	g.say_en.merge(edits.text_en, true)
	g._apply_ui(edits.ui)
	g._apply_text()


func _process(_dt: float) -> void:
	# 브라우저 입력 창이 닫히며 게임이 다시 돌기 시작해도 개발 도구가 열려 있으면 멈춰 둔다
	if mode != "" and not get_tree().paused:
		get_tree().paused = true
	view.queue_redraw()


# ---- 저장 ----
func _load() -> void:
	if not FileAccess.file_exists(FILE):
		return
	var f := FileAccess.open(FILE, FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if d is Dictionary:
		for key in ["text", "ui", "text_en"]:
			if d.get(key) is Dictionary:
				edits[key] = d[key]


func _save() -> void:
	var f := FileAccess.open(FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(edits))


# ---- UI 자리 ----
## [x, y, 크기]
func _ui_get(k: String) -> Array:
	if g.btn_at.has(k):
		return [g.btn_at[k].x, g.btn_at[k].y, g.btn_r[k] / g.BTN_R]
	var c: Control = g.ui[k]
	return [c.position.x, c.position.y, c.scale.x]


func _ui_set(k: String, v: Array) -> void:
	g._apply_ui({k: v})
	if is_equal_approx(v[2], base_ui[k][2]) and Vector2(v[0], v[1]).distance_to(Vector2(base_ui[k][0], base_ui[k][1])) < 1.0:
		edits.ui.erase(k)
	else:
		edits.ui[k] = [roundf(v[0]), roundf(v[1]), snappedf(v[2], 0.01)]
	_save()
	g._pad.queue_redraw()


## 지금 화면에 보이는 고칠 수 있는 것 -> 화면 사각형
func _items() -> Dictionary:
	var out := {}
	for k in UI_NAMES:
		if g.btn_at.has(k):
			if g._btns.has(k):
				var r: float = g._btns[k].r
				out[k] = Rect2(g._btns[k].pos - Vector2(r, r), Vector2(r, r) * 2.0)
		elif (g.ui[k] as Control).is_visible_in_tree():
			out[k] = (g.ui[k] as Control).get_global_rect()
	return out


## 누른 자리의 것 (겹치면 가장 작은 것)
func _pick(p: Vector2) -> String:
	var best := ""
	var area := INF
	var it := _items()
	for k in it:
		var r: Rect2 = it[k]
		if r.grow(10).has_point(p) and r.get_area() < area:
			best = k
			area = r.get_area()
	return best


# ---- 화면 버튼 (모드마다) : [사각형, 글자, 할 일] ----
func _buttons() -> Array:
	match mode:
		"menu":
			return [
				[Rect2(110, 250, 500, 110), "UI 편집", "ui"],
				[Rect2(110, 390, 500, 110), "대사 편집", "text"],
				[Rect2(110, 530, 500, 110), "상대 고르기 (보스로)", "jump"],
				[Rect2(110, 670, 500, 110), "내보내기 (복사)", "export"],
				[Rect2(110, 810, 500, 110), "처음대로 (고친 것 지우기)", "reset"],
				[Rect2(210, 1000, 300, 100), "닫기", "close"],
			]
		"ui":
			var y := 0.0 if bar_top else 1180.0
			return [
				[Rect2(4, y, 140, 96), "작게", "smaller"],
				[Rect2(148, y, 140, 96), "크게", "bigger"],
				[Rect2(292, y, 140, 96), "원래대로", "undo"],
				[Rect2(436, y, 136, 96), "위/아래", "flip"],
				[Rect2(576, y, 140, 96), "완료", "menu"],
			]
		"text":
			var keys: Array = g.say.keys()
			var out: Array = []
			for i in ROWS:
				var j := page * ROWS + i
				if j < keys.size():
					out.append([Rect2(20, 200 + i * 112, 680, 104), keys[j], "edit"])
			out.append([Rect2(20, 1110, 200, 100), "< 이전", "prev"])
			out.append([Rect2(500, 1110, 200, 100), "다음 >", "next"])
			out.append([Rect2(240, 1110, 240, 100), "완료", "menu"])
			# 한영 바꾸기: 같은 줄이 다른 언어로 뭐였는지 바로 본다 (게임 언어도 같이 바뀜)
			out.append([Rect2(20, 10, 560, 100), "⇄ English 보기" if g.lang != "en" else "⇄ 한국어 보기", "lang"])
			return out
		"jump":
			var out: Array = []
			for k in g.BOSS_AT + 1:
				var t: int = 4 if k >= g.BOSS_AT else k % 4
				out.append([Rect2(30 + (k % 3) * 225, 260 + (k / 3) * 230, 210, 210), "%d번째\n%s" % [k + 1, g._s("name%d" % t)], "go%d" % k])
			out.append([Rect2(210, 1000, 300, 100), "뒤로", "menu"])
			return out
	return []


func _paint(c: Control) -> void:
	var f: Font = g._font
	if mode == "":
		c.draw_rect(OPEN_R.grow(-14), Color(0.1, 0.07, 0.04, 0.55))
		c.draw_string(f, Vector2(OPEN_R.position.x + 14, 64), "개발", HORIZONTAL_ALIGNMENT_CENTER, OPEN_R.size.x - 28, 30, Color.WHITE)
		return
	if mode == "ui":
		var it := _items()
		for k in it:
			c.draw_rect(it[k], Color(1, 0.3, 0.6) if k == sel else Color(1, 1, 1, 0.7), false, 6.0 if k == sel else 2.0)
		var y := 110.0 if bar_top else 1110.0
		c.draw_rect(Rect2(0, y, 720, 64), Color(0.1, 0.07, 0.04, 0.8))
		var hint: String = "끌어서 옮기기 · 테두리 = 옮길 수 있는 것" if sel == "" else "%s · 크기 %d%%" % [UI_NAMES[sel], roundi(_ui_get(sel)[2] * 100.0)]
		c.draw_string(f, Vector2(0, y + 44), hint, HORIZONTAL_ALIGNMENT_CENTER, 720, 30, Color.WHITE)
	else:
		c.draw_rect(Rect2(0, 0, 720, 1280), Color(0.06, 0.04, 0.02, 0.93))
		var head: String = {"menu": "개발 도구 (출시 때 빠져요)", "text": "대사 편집(%s) %d/%d · | = 줄 바꿈" % ["영어판" if g.lang == "en" else "한국어판", page + 1, _pages()], "jump": "상대 고르기"}[mode]
		c.draw_string(f, Vector2(0, 150), head, HORIZONTAL_ALIGNMENT_CENTER, 720, 40, Color.WHITE)
		if note != "" and mode == "menu":
			c.draw_multiline_string(f, Vector2(40, 960), note, HORIZONTAL_ALIGNMENT_CENTER, 640, 26, -1, Color("ffd43b"))
	for b: Array in _buttons():
		var r: Rect2 = b[0]
		var act: String = b[2]
		if act == "edit":
			var k: String = b[1]
			var changed: bool = _lang_edits().has(k)
			c.draw_rect(r, Color("5a4632") if not changed else Color("6b5a1e"))
			c.draw_string(f, r.position + Vector2(16, 38), _tname(k) + (" ✎" if changed else ""), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 32, 26, Color("ffd43b"))
			var pv: String = g._s(k).replace("\n", " | ")
			c.draw_string(f, r.position + Vector2(16, 82), pv, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 32, 28, Color.WHITE)
			continue
		c.draw_rect(r, Color("ffd43b") if act == "lang" else g.D if act != "close" and act != "menu" else Color("5a4632"))
		c.draw_rect(r, g.INK, false, 4.0)
		var lines: PackedStringArray = (b[1] as String).split("\n")
		var fs := 34
		var top := r.position.y + r.size.y * 0.5 - (lines.size() - 1) * fs * 0.6 + fs * 0.35
		for i in lines.size():
			c.draw_string(f, Vector2(r.position.x, top + i * fs * 1.2), lines[i], HORIZONTAL_ALIGNMENT_CENTER, r.size.x, fs, g.INK if act != "close" and act != "menu" else Color.WHITE)


func _tname(k: String) -> String:
	if TEXT_NAMES.has(k):
		return TEXT_NAMES[k]
	if k.begins_with("name"):
		return "검객 이름 %d" % (int(k.substr(4)) + 1)
	if k.begins_with("tip"):
		return "검객 설명 %d" % (int(k.substr(3)) + 1)
	if k.begins_with("pkd_"):
		return "능력 설명: " + g._s("pk_" + k.substr(4))
	if k.begins_with("pk_"):
		return "능력 이름: " + base_text.get(k, k)
	return k


func _pages() -> int:
	return ceili(g.say.size() / float(ROWS))


# ---- 입력 (열려 있으면 게임으로 안 보낸다) ----
func _input(event: InputEvent) -> void:
	var id := 0
	var p := Vector2.ZERO
	var kind := 0  # 1 누름, 0 끌기, -1 뗌
	if event is InputEventScreenTouch:
		id = event.index
		p = event.position
		kind = 1 if event.pressed else -1
	elif event is InputEventScreenDrag:
		id = event.index
		p = event.position
	elif event.device == InputEvent.DEVICE_ID_EMULATION:
		if mode != "":
			get_viewport().set_input_as_handled()
		return
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		id = -100
		p = event.position
		kind = 1 if event.pressed else -1
	elif event is InputEventMouseMotion:
		id = -100
		p = event.position
	else:
		return
	if mode == "":
		if kind == 1 and OPEN_R.has_point(p):
			get_viewport().set_input_as_handled()
			_open()
		return
	get_viewport().set_input_as_handled()
	if kind == 1:
		_press(id, p)
	elif kind == 0 and id == finger and sel != "":
		var v := _ui_get(sel)
		_ui_set(sel, [p.x + grab.x, p.y + grab.y, v[2]])
	elif kind == -1 and id == finger:
		finger = -999


func _press(id: int, p: Vector2) -> void:
	for b: Array in _buttons():
		if (b[0] as Rect2).has_point(p):
			_do(b[2], b[1])
			return
	if mode == "ui":
		sel = _pick(p)
		if sel != "":
			var v := _ui_get(sel)
			grab = Vector2(v[0], v[1]) - p
			finger = id


func _do(act: String, arg: String) -> void:
	note = ""
	match act:
		"close":
			_close()
		"menu":
			mode = "menu"
			sel = ""
			g._msg_t = 0.0
		"ui":
			mode = "ui"
			sel = ""
			# 가운데 글은 평소엔 잠깐만 떠서, 옮길 수 있게 보여 둔다
			if not g._msg_l.visible:
				g._msg_l.text = "가운데 글"
				g._msg_l.visible = true
		"text":
			mode = "text"
		"lang":
			g.lang = "ko" if g.lang == "en" else "en"
			g._set_lang()
			g._save()
			g._apply_text()
		"jump":
			mode = "jump"
		"export":
			_export()
		"reset":
			edits = {"text": {}, "ui": {}, "text_en": {}}
			_save()
			g.say = base_text.duplicate()
			g.say_en = base_en.duplicate()
			g._apply_ui(base_ui)
			g._apply_text()
			note = "고친 글·자리를 모두 처음대로 돌렸어요"
		"smaller", "bigger":
			if sel != "":
				var v := _ui_get(sel)
				v[2] = clampf(v[2] * (0.9 if act == "smaller" else 1.1), 0.4, 3.0)
				_ui_set(sel, v)
		"undo":
			if sel != "":
				_ui_set(sel, base_ui[sel].duplicate())
		"flip":
			bar_top = not bar_top
		"prev":
			page = (page - 1 + _pages()) % _pages()
		"next":
			page = (page + 1) % _pages()
		"edit":
			_edit(arg)
		_:
			if act.begins_with("go"):
				_jump(int(act.substr(2)))


func _open() -> void:
	mode = "menu"
	get_tree().paused = true
	g._own.clear()
	g.held = false
	g.pend.clear()


func _close() -> void:
	mode = ""
	sel = ""
	g._msg_t = 0.0
	get_tree().paused = false


## 브라우저 입력 창으로 글 하나 고치기 (| = 줄 바꿈)
func _edit(k: String) -> void:
	if not OS.has_feature("web"):
		note = "글 고치기는 웹(폰 브라우저)에서만 돼요"
		return
	var cur: String = g._s(k).replace("\n", "|")
	var r: Variant = JavaScriptBridge.eval("window.prompt(%s, %s)" % [JSON.stringify(_tname(k) + "  (| = 줄 바꿈)"), JSON.stringify(cur)], true)
	if r == null or not r is String:
		return  # 취소
	var t: String = (r as String).replace("|", "\n")  # 비워 두면 빈 글 그대로 (글이 안 뜬다)
	# 지금 언어판의 글만 고친다: 영어판이면 say_en, 한국어판이면 say
	var base: String = base_text[k]
	if g.lang == "en":
		base = base_en.get(k, tr(base_text[k]))
		if base_en.has(k) or t != base:
			g.say_en[k] = t
		else:
			g.say_en.erase(k)
	else:
		g.say[k] = t
	if t == base:
		_lang_edits().erase(k)
	else:
		_lang_edits()[k] = t
	_save()
	g._apply_text()


## 고친 것을 글로 복사 (디스코드에 붙이면 게임에 박아 넣는다)
func _export() -> void:
	var s := JSON.stringify(edits)
	if edits.text.is_empty() and edits.ui.is_empty() and edits.text_en.is_empty():
		note = "아직 고친 게 없어요"
		return
	if OS.has_feature("web"):
		JavaScriptBridge.eval("(function(s){try{navigator.clipboard.writeText(s)}catch(e){}window.prompt('복사해서 디스코드에 붙여 주세요', s)})(%s)" % JSON.stringify(s), true)
	else:
		DisplayServer.clipboard_set(s)
	note = "복사했어요. 디스코드에 붙여 주면\n출시판에도 남게 넣어 드려요"


## k번째 상대(0부터, BOSS_AT = 끝판왕)부터 바로 싸운다. 능력 없이 맨몸
func _jump(k: int) -> void:
	_close()
	g.pick_box.visible = false
	g.set_box.visible = false
	g._start_run()
	g.n = k
	g._spawn(k)
	g._clear()
	g.msg("%d번째 상대로 건너뜀" % (k + 1), 1.2)


## 지금 언어판에서 고친 글
func _lang_edits() -> Dictionary:
	return edits.text_en if g.lang == "en" else edits.text
