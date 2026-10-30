extends Tofu
## v7: 무거운 저울·가벼운 상승풍·선두 차단문·낙하마루 + 바로 이어지는 응용 구간.
## 기본 / 밤 등불 / 과속 배달. 안전한 첫 10초 → 6코스 2승 → 마지막 배달 → 순위·짐·시간·코스 메달·로컬 기록.
## 짐=느림·목숨·화면 폭, 선두 카메라·왼쪽 탈락 유지. 아트는 _art_model / _build_backdrop 훅에서 교체한다.

const GRAV := 38.0
const JUMP_V := 15.0
const RUN_MAX := 11.0
const GROUND_ACC := 45.0
const AIR_ACC := 22.0
const OVER_G := 7.0  # 최고 속도보다 빠를 때 땅에서 줄어드는 정도
const OVER_A := 1.5
const FRICTION := 35.0
const MAX_FALL := 26.0
const PAD_V := 23.0
const DASH_V := 16.0
const DASH_T := 0.25
const HW := 0.4
const HH := 1.2
const STEP := 0.55
const RAMP_RUN := 1.8  # 경사로 길이 = 높이 × 이만큼
const RAMP_DRAG := 14.0  # 오르막에서 더 깎이는 속도 (경사·짐 무게에 비례)
const COYOTE := 0.1
const JBUF := 0.12
const CAM_D := 22.0
const BX0 := -60.0
const BK := 6.0
const WIDE := 12.5  # 짐이 다 있을 때 화면 반폭
const NARROW := 5.5  # 짐이 다 없어지면 이만큼
const LOAD0 := 3  # 출발 짐
const LOAD_MAX := 5
const LOAD_SLOW := 0.06  # 짐 하나당 최고 속도 감소
const LOAD_JUMP := 0.035  # 짐 하나당 점프 감소
const FLOW := 5.5  # 흐르는 바닥 속도 (뒤로)
const WINS := 2
const PARCEL := Color("e0a96d")
const NIGHT := Color("1b1f3b")
const PERKS := ["신발", "끈", "용수철", "바람", "가벼운 상자", "단단한 몸"]
const PERK_SAY := {"신발": "더 빨리", "끈": "짐 하나 더", "용수철": "높이 뛰기", "바람": "바람 두 배", "가벼운 상자": "짐 무게 40% 덜", "단단한 몸": "치여도 덜 밀림"}
# English: same keys -> [button name, effect]
const PERK_EN := {"신발": ["Shoes", "run faster"], "끈": ["Strap", "carry 1 more"], "용수철": ["Spring", "jump higher"],
	"바람": ["Draft", "double slipstream"], "가벼운 상자": ["Light Box", "boxes 40% lighter"], "단단한 몸": ["Tough", "less knockback"]}
const TRAIN_V := 21.0  # 기차 속도 (왼쪽으로)
const TRAIN_L := 7.0
const TRAIN_H := 2.0
const TRENCH := 3.2  # 선로 도랑 깊이
const BREAK_W := 3.0  # 이 무게 이상이면 다리 판이 무너진다
const BREAK_T := 0.42  # 금 간 판이 떨어지기까지
const BOARD := Color("c99a6e")
const CRACK := Color("f03e3e")
const GATE_MAX := 2  # 낮은 문: 짐 이만큼까지만 지나간다
const GATE_H := 1.6
const ICE := Color("d0ebff")
const WIND_C := Color("74c0fc")
const WIND_K := 0.45  # 맞바람에 깎이는 최고 속도 (가벼울 때)
# 판 변주: 구간 이름 -> [버튼 이름, 설명]
const TWISTS := {"gate": ["낮은 문", "짐 2개까지만 지나간다"], "slide": ["얼음 내리막", "못 멈춘다, 무거울수록 빠르다"],
	"wind": ["맞바람", "뒤에 붙으면 바람이 없다"]}
const TWISTS_EN := {"gate": ["Low Gate", "only 2 boxes or fewer fit"], "slide": ["Ice Slope", "no stopping, heavier is faster"],
	"wind": ["Headwind", "tuck in behind and it's calm"]}
# 밤 등불 모드
const NIGHT_SKY := Color("5b70d9")
const FOG := Color("e4e8f7")
const GLOW := Color("ffe066")
const LIGHT_R := 5.0
const LOST_T := 1.5  # 빛 밖에서 이만큼 있으면 짐 하나를 잃는다 (없으면 탈락)
const ZR := 2.2  # 등불 모드: 주자는 안개 앞에 그린다
const ZF := 1.5  # 안개 막
const FOG_N := 6
const EDGE_N := 8
const MODES := {"base": "기본", "lantern": "밤 등불", "over": "과속 배달"}
const MODE_RULES := {"base": "짐을 지키거나 버려서 앞서라", "lantern": "선두의 빛에 붙어라 · 빠르면 빛이 뒤로", "over": "짐 2개 이하: 천장 가속 / 벽 반동"}
const MODES_EN := {"base": "Classic", "lantern": "Lantern", "over": "Rush"}
const MODE_RULES_EN := {"base": "keep or drop boxes to get ahead", "lantern": "stay in the light · speed swings it back", "over": "≤2 boxes: ceiling boost / wall bounce"}
const RECORDS := "user://screenrace_v7.cfg"
const SEG_RULES := {
	"flat": "짐은 느림과 목숨 · 빈손 결승은 실격",
	"stairs": "언덕: 짐이 무거우면 오르막이 느리다",
	"wall": "빨간 벽: 점프로 넘어야 안 느려진다", "pit": "빨간 틈: 끝에서 점프",
	"awning": "노란 발판: 위 지름길 / 아래 상자",
	"crates": "상자 경사: 뛰어넘으면 빠르다",
	"river": "흐르는 바닥: 무거우면 덜 밀린다",
	"track": "위 승강장 / 아래는 기차가 온다",
	"bridge": "짐 3개 이상: 밟은 판이 무너진다",
	"gate": "낮은 문: 짐 2개 이하만 통과",
	"slide": "얼음: 무거울수록 빠르고 못 멈춘다",
	"wind": "맞바람: 앞사람 뒤에 붙어라",
	"roofgap": "지붕 틈: 점프를 끝까지 눌러라",
	"longgap": "먼 틈: 짐을 버리고 점프",
	"ballast": "저울: 짐 3개면 위로 / 가벼우면 아래",
	"updraft": "상승풍: 짐 2개 이하면 위로 뜬다",
	"shutter": "차단문: 선두가 닿으면 잠깐 뒤 열림",
	"dropfloor": "낙하마루: 짐 3개로 잠깐 밟아 아래로",
	"ballast_mix": "응용: 무거운 저울 위로 / 아래는 강물",
	"updraft_mix": "응용: 가볍게 떠서 낮은 문 통과",
	"shutter_mix": "응용: 맞바람 속 차단문은 뒤에 붙기",
	"dropfloor_mix": "응용: 무겁게 마루를 뚫고 얼음 질주"}
const SEG_RULES_EN := {
	"flat": "Boxes = weight + lives · no empty finish",
	"stairs": "Hills: heavy loads climb slowly",
	"wall": "Red wall: jump it to keep speed", "pit": "Red gap: jump at the edge",
	"awning": "Yellow ledge: shortcut up / boxes below",
	"crates": "Crate slope: jump over to stay fast",
	"river": "Moving floor: heavy loads drift less",
	"track": "Platform above / trains come below",
	"bridge": "3+ boxes: planks you step on fall",
	"gate": "Low gate: 2 boxes or fewer only",
	"slide": "Ice: heavier is faster, no stopping",
	"wind": "Headwind: tuck in behind someone",
	"roofgap": "Roof gap: hold jump all the way",
	"longgap": "Long gap: drop a box, then jump",
	"ballast": "Scale: 3 boxes go up / light goes down",
	"updraft": "Updraft: 2 boxes or fewer float up",
	"shutter": "Shutter: opens just after the leader",
	"dropfloor": "Trapdoor: stand on it with 3 boxes",
	"ballast_mix": "Combo: heavy up the scale / river below",
	"updraft_mix": "Combo: float light through the low gate",
	"shutter_mix": "Combo: headwind shutter, stay behind",
	"dropfloor_mix": "Combo: crash through heavy, then ice"}
# 순서는 도입 → 같은 규칙과 앞서 배운 지형의 결합. 이후 익숙한 조각을 새로 섞는다.
const LESSONS := [
	["wall", "river", "ballast", "ballast_mix"],
	["river", "gate", "updraft", "updraft_mix"],
	["wind", "shutter", "shutter_mix", "track"],
	["bridge", "slide", "dropfloor", "dropfloor_mix"],
	["ballast", "ballast_mix", "bridge", "shutter", "shutter_mix"],
	["updraft", "updraft_mix", "roofgap", "dropfloor", "dropfloor_mix"]]
const POOL_N := 140  # 코스 상자를 그리는 풀 (화면 근처만)
const BITS_N := 12
const COURSES := [
	{"name": "시장", "rule": "", "say": "벽을 넘어라",
		"sky": Color("d8eeff"), "far": Color("b2f2bb"),
		"gnd": Color("ffd8a8"), "top": Color("ff922b"), "wall": Color("e8590c"),
		"bld": [Color("ffc9c9"), Color("ffec99"), Color("d3f9d8")],
		"segs": ["flat", "stairs", "wall", "pit", "awning", "crates", "flat", "crates"]},
	{"name": "강변", "rule": "flow", "say": "바닥이 흐른다: 짐이 무거우면 덜 밀린다",
		"sky": Color("e7f5ff"), "far": Color("a5d8ff"),
		"gnd": Color("c5f6fa"), "top": Color("3bc9db"), "wall": Color("1098ad"),
		"bld": [Color("d0ebff"), Color("e3fafc"), Color("d3f9d8")],
		"segs": ["flat", "river", "river", "pit", "stairs", "river", "wall", "river"]},
	{"name": "건널목", "rule": "train", "say": "아래 선로는 빠르다. 기차는 앞에서 온다",
		"sky": Color("fff4e6"), "far": Color("ffd8a8"),
		"gnd": Color("fff3bf"), "top": Color("fab005"), "wall": Color("f08c00"),
		"bld": [Color("ffe8cc"), Color("e7f5ff"), Color("fff9db")],
		"segs": ["flat", "track", "stairs", "track", "crates", "track", "pit"]},
	{"name": "야시장", "rule": "dark", "say": "정전: 꺼지면 아무도 앞을 못 본다",
		"sky": Color("fff0f6"), "far": Color("fcc2d7"),
		"gnd": Color("ffe8cc"), "top": Color("f76707"), "wall": Color("d9480f"),
		"bld": [Color("ffdeeb"), Color("fff3bf"), Color("e5dbff")],
		"segs": ["flat", "wall", "pit", "crates", "stairs", "awning", "wall", "pit"]},
	{"name": "흔들다리", "rule": "bridge", "say": "짐 3개 이상이면 밟은 판이 무너진다",
		"sky": Color("ebfbee"), "far": Color("8ce99a"),
		"gnd": Color("d8f5a2"), "top": Color("74b816"), "wall": Color("5c940d"),
		"bld": [Color("c0eb75"), Color("e9fac8"), Color("d3f9d8")],
		"segs": ["flat", "bridge", "stairs", "bridge", "pit", "bridge", "crates"]},
	{"name": "지붕", "rule": "roof", "say": "벽이 없다: 먼 틈은 짐을 버려야 넘는다",
		"sky": Color("f3f0ff"), "far": Color("d0bfff"),
		"gnd": Color("e5dbff"), "top": Color("cc5de8"), "wall": Color("9775fa"),
		"bld": [Color("f3d9fa"), Color("dbe4ff"), Color("ffdeeb")],
		"segs": ["roofgap", "roofgap", "longgap", "stairs", "roofgap", "longgap"]},
]
# English course [name, say], same order as COURSES
const COURSES_EN := [
	["Market", "Hop over the walls"],
	["Riverside", "The floor flows: heavy loads drift less"],
	["Crossing", "Tracks below are fast. Trains come from ahead"],
	["Night Market", "Blackouts: when it's dark, nobody sees ahead"],
	["Rope Bridge", "3+ boxes and the planks you step on fall"],
	["Rooftops", "No walls: drop a box to clear long gaps"]]
const NICKS_EN := ["Me", "Orange", "Sky", "Pink"]
# Delivery stamps
const ST_INK := 0
const ST_GOOD := 1
const ST_BAD := 2
const ST_COL := [Color("2f4a8a"), Color("12907a"), Color("d8433a")]
const ST_PAPER := Color("fff8ec")
const ST_N := 3
const ST_REPEAT := 1.5


class Courier:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var grounded := false
	var sup := -1  # 밟은 것: 0 바닥 1 발판 3 흐르는 바닥
	var slope := 0.0  # 밟은 경사 (+ 오른쪽 오르막)
	var alive := true
	var ai := true
	var nick := ""
	var nick_en := ""
	var col := Color.WHITE
	var node: Node3D
	var fire: MeshInstance3D
	var poof: MeshInstance3D
	var packs: Array[MeshInstance3D] = []
	var streaks: Array[MeshInstance3D] = []
	var pips: Array[MeshInstance3D] = []
	var cargo := 0
	var stun := 0.0
	var dash := 0.0
	var drop_cd := 0.0
	var slip := false
	var coyote := 0.0
	var jbuf := 0.0
	var cut := true
	var skill := 1.0
	var err := 0.2
	var think := 0.0
	var poof_t := 0.0
	var immune := 0.0
	var face := 1.0
	var art: Node3D  # 그림 모델 (있으면 바라보는 쪽으로 돌린다)
	var wins := 0
	var sq := 0.0  # 찌그러짐 (+ 납작, - 길쭉)
	var dive := false  # 경쟁자: 건널목에서 선로로 내려갈지
	var lost := 0.0  # 등불 모드: 빛 밖에 있은 시간
	var bold := 0.5  # 등불 모드 경쟁자: 등불을 들고 얼마나 빨리 달리나
	# 이번 프레임 입력
	var mx := 0.0
	var i_jump := false
	var i_jheld := false
	var i_drop := false


var ci := 0  # 코스
var rnd := 0  # 이 코스에서 몇 번째 라운드
var phase := "count"
var pt := 0.0
var rt := 0.0  # 라운드 시간
var cdef: Dictionary
var stage: Node3D
var rects: Array[Rect2] = []
var kinds := PackedInt32Array()  # 0 바닥 1 점프대 3 흐름 4 판 5 얼음 6 짐 문 7 차단문 8 경사로
var ramp_of := {}  # 경사로 상자 번호 -> 1 오른쪽 오르막 / -1 오른쪽 내리막
var ramp_hit_y := 0.0
var decor_n := 0
var sfx_pool: Array = []
var sfx_bank := {}
var sfx_i := 0
var sfx_vol := 0.8
var buckets: Array = []
var spots: Array[Vector2] = []  # 코스에 놓인 짐 자리
var parcels: Array = []  # 땅에 있는 짐 (돌려 쓴다)
var flows: Array = []  # 흐르는 바닥 눈금
var goal_x := 0.0
var kill_y := -20.0
var gx := 0.0
var fy := 0.0
var min_fy := 0.0
var gen := RandomNumberGenerator.new()
var game_seed := 0
var runners: Array[Courier] = []
var pl: Courier
var camx := 0.0
var camy := 0.0
var hwv := WIDE
var vhv := WIDE
var shk := 0.0
var lean := 0.0  # 1등인 내 속도 비율 (클수록 화면이 앞으로 쏠려 앞이 안 보인다)
var twist := ""  # 이번 판 변주 구간 ("" = 코스 규칙만)
var route_offer: Array = []
var gates: Array = []  # 낮은 문 x
var gusts: Array[Vector2] = []  # 맞바람 구역 (x0, x1)
var grid: Array = []  # 지난 판 순위 (다음 판 출발 줄)
var fresh := true  # 새 코스 첫 판이면 짐을 새로 받는다
var wind_in := false
var was_ice := false
var gate_said := 0.0
var edge_strip: MeshInstance3D
var curtain: MeshInstance3D
var marker: MeshInstance3D
var danger := false
var tick := 0.0
var was_slip := false
var spd_mul := 1.0
var jump_mul := 1.0
var slip_mul := 1.0
var load_bonus := 0
var load_w := 1.0
var perk_offer: Array = []
var taken: Array = []
var lead_t := 0.0
var radar_t := 0.0
var dark_t := 0.0
var dark_on := false
var dark_warn := false
var knock_mul := 1.0
# 코스 상자는 명세만 들고, 화면 근처 것만 풀 상자로 그린다
var vspecs: Array = []
var vslot := PackedInt32Array()
var vpool: Array[MeshInstance3D] = []
var vfree: Array[int] = []
var v_last := Vector3(1e9, 0, 0)
var trains: Array = []  # 건널목 선로마다 기차 하나
var boards: Array = []  # 흔들다리 판
var board_of := {}  # 상자 번호 -> 판
var bridge_said := false
var bits: Array = []  # 파편 (돌려 쓴다)
var bit_i := 0
var clouds: Array = []
var winds: Array[MeshInstance3D] = []
var wind_x := 0.0
# 모드
var mode := "base"
var mode_l: Label
var bearer: Courier
var lantern: Node3D
var lamp_lean := 0.0  # 등불 든 사람의 속도 비율 (클수록 뒤로 젖고 크게 흔들린다)
var swing_t := 0.0
var swing_sign := 1.0
var light_c := 0.0
var lit: Array[Vector2] = []
var fogs: Array[MeshInstance3D] = []
var edges: Array[MeshInstance3D] = []
var hold_acc := 0.0
var was_bearer := false
var mechanisms: Array = []
var shutter_of := {}
var signs: Array = []
var seen_rules := {}
var journey_time := 0.0
var course_time := 0.0
var delivered := 0
var course_results: Array = []
var records := ConfigFile.new()
var finale := false
var result_l: Label
var route_l: Label
var backdrop: Sprite3D
var lang := "en"  # "en" (default) or "ko", saved in RECORDS [opt] lang
var tell_s := ""  # calm rule line shown on route_l for tell_t seconds
var tell_t := 0.0
var stamps: Array = []  # pooled paper stamps {panel, label, age, life, base}
var stamp_last := {}  # text -> msec shown (no repeats within ST_REPEAT)
var stamp_box: Array[StyleBoxFlat] = []
var stamp_set: Array[LabelSettings] = []


func L(ko: String, en: String) -> String:
	return ko if lang == "ko" else en


func _nk(r: Courier) -> String:
	return L(r.nick, r.nick_en)


func _cname(i: int) -> String:
	return L(COURSES[i].name, COURSES_EN[i][0])


func _mode_name(m: String) -> String:
	return L(MODES[m], MODES_EN[m])


func _mode_rule(m: String) -> String:
	return L(MODE_RULES[m], MODE_RULES_EN[m])


func _tw(k: String, i: int) -> String:
	return L(TWISTS[k][i], TWISTS_EN[k][i])


func _perk(k: String) -> String:
	return L(k, PERK_EN[k][0])


func _perk_say(k: String) -> String:
	return L(PERK_SAY[k], PERK_EN[k][1])


## Rules and teaching go to the top signpost line, not the stamp.
func _tell(ko: String, en: String, dur := 2.2) -> void:
	tell_s = L(ko, en)
	tell_t = dur


## Same rule line only once per journey (seen_rules is cleared on reset).
func _tell_once(key: String, ko: String, en: String, dur := 2.2) -> void:
	if seen_rules.has("tell_" + key):
		return
	seen_rules["tell_" + key] = true
	_tell(ko, en, dur)


## Anything still calling msg() becomes a neutral stamp.
func msg(s: String, dur := 0.6) -> void:
	_stamp_show(s, ST_INK, null, dur)


func _stamp(ko: String, en: String, kind := ST_INK, who: Courier = null, dur := 0.8) -> void:
	_stamp_show(L(ko, en), kind, who, dur)
	_sfx("stamp", null, -8.0)


## 효과음 (nkido로 구운 art/screenrace/sfx/*.wav). r이 있으면 내 배달부는 크게, 화면 안 상대는 작게, 화면 밖은 안 난다
func _sfx(name: String, r: Courier = null, db := 0.0) -> void:
	if r != null and r != pl:
		if not r.alive or absf(r.p.x - camx) >= hwv:
			return
		db -= 7.0
	if sfx_pool.is_empty():
		for k in 8:
			var a := AudioStreamPlayer.new()
			add_child(a)
			sfx_pool.append(a)
	if not sfx_bank.has(name):
		var path := "res://art/screenrace/sfx/%s.wav" % name
		sfx_bank[name] = load(path) if ResourceLoader.exists(path) else null
	if sfx_bank[name] == null:
		return
	var a: AudioStreamPlayer = sfx_pool[sfx_i]
	sfx_i = (sfx_i + 1) % sfx_pool.size()
	a.stream = sfx_bank[name]
	a.volume_db = db + linear_to_db(maxf(sfx_vol, 0.01))
	a.pitch_scale = randf_range(0.95, 1.05)
	a.play()


## tofu.gd 의 기본 삑 소리 대신 같은 이름의 종이 소리
func play(name: String) -> void:
	_sfx({"win": "delivered", "good": "pickup", "bad": "lost", "tap": "stamp"}.get(name, name))


func _stamp_setup() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 3
	add_child(layer)
	for k in 3:
		var sb := StyleBoxFlat.new()
		sb.bg_color = ST_PAPER
		sb.border_color = ST_COL[k]
		sb.set_border_width_all(4)
		sb.set_corner_radius_all(6)
		sb.shadow_color = Color(0.15, 0.1, 0.05, 0.28)
		sb.shadow_size = 3
		sb.shadow_offset = Vector2(3, 4)
		stamp_box.append(sb)
		var ls := LabelSettings.new()
		ls.font = _font
		ls.font_size = 38
		ls.font_color = ST_COL[k]
		stamp_set.append(ls)
	for i in ST_N:
		var p := Panel.new()
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.visible = false
		layer.add_child(p)
		var l := Label.new()
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.set_anchors_preset(Control.PRESET_FULL_RECT)
		p.add_child(l)
		stamps.append({"panel": p, "label": l, "age": 0.0, "life": 0.0, "base": Vector2.ZERO})


func _stamp_show(s: String, kind: int, who: Courier, dur: float) -> void:
	if stamps.is_empty() or s == "":
		return
	var now := Time.get_ticks_msec()
	if stamp_last.has(s) and now - int(stamp_last[s]) < int(ST_REPEAT * 1000.0):
		return
	stamp_last[s] = now
	# a free slot, or recycle the oldest
	var st: Dictionary = {}
	var oldest: Dictionary = stamps[0]
	var holding := 0
	for e in stamps:
		if not (e.panel as Control).visible:
			if st.is_empty():
				st = e
			continue
		if e.age < 0.6:
			holding += 1
		if e.age > oldest.age or not (oldest.panel as Control).visible:
			oldest = e
	if st.is_empty():
		st = oldest
		holding = maxi(holding - (1 if oldest.age < 0.6 else 0), 0)
	var p: Panel = st.panel
	var l: Label = st.label
	kind = clampi(kind, 0, 2)
	p.add_theme_stylebox_override("panel", stamp_box[kind])
	l.label_settings = stamp_set[kind]
	l.text = s
	var sz := _font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 38) + Vector2(44, 22)
	p.size = sz
	p.pivot_offset = sz * 0.5
	# above the courier on screen (player by default), clamped inside the screen
	var r: Courier = who if who != null and who.alive else pl
	var at := Vector2(360, 560)
	var c := get_viewport().get_camera_3d()
	if c == null:
		c = cam
	if r != null and c != null:
		var wp := Vector3(r.p.x, r.p.y + HH * 2.0 + 1.2, 0.0)
		if not c.is_position_behind(wp):
			at = c.unproject_position(wp)
	at.y -= 50.0 + holding * 66.0
	at.x = clampf(at.x, 16.0 + sz.x * 0.5, 704.0 - sz.x * 0.5)
	at.y = clampf(at.y, 440.0, 1000.0)
	st.base = at - sz * 0.5
	st.age = 0.0
	st.life = clampf(dur, 0.5, 1.4) + 0.4
	p.position = st.base
	p.rotation = deg_to_rad(randf_range(-8.0, 8.0))
	p.scale = Vector2.ONE * 1.35
	p.modulate.a = 1.0
	p.visible = true


func _stamp_tick(dt: float) -> void:
	var gone := over or _rating
	for st in stamps:
		var p: Panel = st.panel
		if not p.visible:
			continue
		st.age += dt
		if gone or st.age >= st.life:
			p.visible = false
			continue
		var a: float = st.age
		p.scale = Vector2.ONE * (lerpf(1.35, 1.0, a / 0.1) if a < 0.1 else 1.0)
		var fade: float = clampf((a - (st.life - 0.4)) / 0.4, 0.0, 1.0)
		p.modulate.a = 1.0 - fade
		p.position = st.base + Vector2(0.0, -40.0 * fade)


func _set_lang(l: String) -> void:
	lang = l
	records.set_value("opt", "lang", lang)
	records.save(RECORDS)
	howto = _howto_text()
	for signpost in signs:
		(signpost.node as Label3D).text = L(signpost.ko, signpost.en)
	_mode_buttons()


func _howto_text() -> String:
	return L("왼쪽 스틱으로 달리고 [점프]로 넘는다.\n짐은 느리지만 목숨이다. [짐]은 하나 버리고 가속.\n여섯 동네를 지나 마지막 배달까지!",
		"Left stick to run, [Jump] to hop.\nBoxes slow you down but are your lives.\n[Box] drops one for a dash.\nCross six towns to the final delivery!")


func _mode_buttons() -> void:
	_btns["jump"].label = _mode_name("base")
	_btns["drop"].label = _mode_name("lantern")
	_btns["mode_over"].label = L("과속", "Rush")
	_btns["mode_over"].r = 80.0
	_btns["lang"].label = L("English", "한국어")
	_btns["lang"].r = 54.0


func _opening() -> bool:
	return ci == 0 and rnd == 1 and not finale and rt < 10.0


func _overpowered(r: Courier) -> bool:
	return mode == "over" and r == pl and r.cargo <= 2 and not _opening()


func _sign(x: float, y: float, ko: String, en: String, rule := "") -> void:
	var label := Label3D.new()
	label.font = _font
	label.text = L(ko, en)
	label.font_size = 48
	label.pixel_size = 0.012
	label.outline_size = 10
	label.modulate = WHITE
	label.outline_modulate = INK
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(x + 3.0, y, 0.2)
	stage.add_child(label)
	signs.append({"x": x, "ko": ko, "en": en, "rule": rule, "node": label})


func _mechanisms(dt: float) -> void:
	for m in mechanisms:
		if m.type == "shutter":
			if m.t >= 0.0:
				m.t += dt
				(m.node as Node3D).visible = m.t < 0.75
			else:
				for r in runners:
					if r.alive and r.p.x > m.x0 and r.p.x < m.x1 + 0.6 and absf(r.p.y - m.y) < 3.6:
						m.t = 0.0
						_sfx("gate", r)
						break
			continue
		for r in runners:
			if not r.alive or r.p.x < m.x0 or r.p.x > m.x1:
				continue
			if m.type == "ballast" and r.grounded and r.cargo >= 3 and absf(r.p.y - m.y) < 0.6:
				r.v.y = 24.0
				r.v.x = maxf(r.v.x, 8.5)
				r.grounded = false
				r.cut = true
				_sfx("spring", r)
			elif m.type == "updraft" and r.cargo <= 2 and r.p.y >= m.y - 0.1 and r.p.y < m.y + 4.8:
				r.v.y = 18.0
				r.grounded = false
				r.cut = true


func _update_content_hud() -> void:
	route_l.visible = not over and not _rating
	route_l.label_settings.font_size = 25 if phase == "mode" else 30  # 모드 화면은 네 줄이라 작게 (안 겹치게)
	if phase == "mode":
		var best_l := L("최다 배달: 기본 %d / 등불 %d / 과속 %d", "Best: Classic %d · Lantern %d · Rush %d")
		route_l.text = "%s: %s\n%s: %s\n%s: %s\n%s" % [_mode_name("base"), _mode_rule("base"), L("밤 등불", "Lantern"), _mode_rule("lantern"), L("과속", "Rush"), _mode_rule("over"), best_l % [int(records.get_value("base", "delivered", 0)), int(records.get_value("lantern", "delivered", 0)), int(records.get_value("over", "delivered", 0))]]
		return
	if phase == "perk":
		route_l.text = "%s\n%s: %s\n%s: %s" % [L("특전 고르기", "Pick a perk"), _perk(perk_offer[0]), _perk_say(perk_offer[0]), _perk(perk_offer[1]), _perk_say(perk_offer[1])]
		return
	if phase == "route":
		route_l.text = "%s\n%s: %s\n%s: %s" % [L("다음 길? 내 짐 %d", "Next road? You carry %d") % maxi(pl.cargo, 1), _tw(route_offer[0], 0), _tw(route_offer[0], 1), _tw(route_offer[1], 0), _tw(route_offer[1], 1)]
		return
	if _opening():
		var lesson := mini(int(rt / 3.3), 2)
		route_l.text = [L("← 빨간 끝 밖: 짐 하나 / 빈손 탈락", "← Red edge: lose a box, out if empty"),
			L("짐 = 느림 + 목숨 · 함께 든 짐이 화면 폭", "Boxes = slow + lives · all boxes set the view"),
			L("[짐] 하나 버려 가속. 마지막 하나는 남겨라", "[Box] drops one for speed. Keep the last")][lesson]
		return
	route_l.text = ""
	var telling := tell_t > 0.0 and phase != "roundend"
	if telling:
		route_l.text = tell_s
	if phase != "race":
		return
	# World signs are repeated at the next encounter until actually approached.
	for signpost in signs:
		(signpost.node as Node3D).visible = absf(signpost.x - camx) < hwv + 8.0
		if pl.p.x > signpost.x - 7.0 and pl.p.x < signpost.x + 6.0:
			if not telling:
				route_l.text = L(signpost.ko, signpost.en)
			if signpost.rule != "" and not seen_rules.has(signpost.rule):
				seen_rules[signpost.rule] = true
				beep(740.0, 0.06, 990.0, 0.12)
			break


func _record_course() -> void:
	var medal := 3 if rnd <= 2 and pl.cargo >= 3 else (2 if rnd <= 3 else 1)
	var row := {"ci": ci, "medal": medal, "time": course_time, "cargo": pl.cargo}
	course_results.append(row)
	var key := "%s_%d" % [mode, ci]
	records.set_value(key, "medal", maxi(medal, int(records.get_value(key, "medal", 0))))
	records.set_value(key, "time", minf(course_time, float(records.get_value(key, "time", 1.0e9))))
	records.set_value(key, "cargo", maxi(pl.cargo, int(records.get_value(key, "cargo", 0))))
	records.save(RECORDS)


func _start_finale() -> void:
	finale = true
	rnd = 0
	fresh = false
	twist = ""
	_build_course()
	_start_round()
	_tell("마지막 배달. 배운 길을 모두 써라", "Final delivery. Use every road you learned", 2.6)
	_stamp("최종 배달", "FINAL DELIVERY", ST_INK, null, 1.2)
	# Keep the last round's parcels, grid and upgrades for the final delivery.


func _finish(won: bool) -> void:
	if over:
		return
	var placement := 1 if won else maxi(2, grid.find(pl) + 1)
	if won:
		delivered += pl.cargo
		score += 100 + pl.cargo * 20
	var previous := int(records.get_value(mode, "delivered", 0))
	var best_delivery := maxi(delivered, previous)
	records.set_value(mode, "delivered", best_delivery)
	if won:
		records.set_value(mode, "time", minf(journey_time, float(records.get_value(mode, "time", 1.0e9))))
	var saved := records.save(RECORDS) == OK
	var strongest := L("아직 없음", "none yet")
	var best_medal := 0
	var best_cargo := -1
	var rows := ""
	var row_count := 0
	for row in course_results:
		rows += "%s %s  " % [_cname(row.ci), [L("", ""), L("동", "Bronze"), L("은", "Silver"), L("금", "Gold")][row.medal]]
		row_count += 1
		if row_count == 3:
			rows += "\n"
		if row.medal > best_medal or (row.medal == best_medal and row.cargo > best_cargo):
			best_medal = row.medal
			best_cargo = row.cargo
			strongest = _cname(row.ci)
	var best_time := float(records.get_value(mode, "time", 0.0))
	var hint := L("다음엔 짐 3개로 저울 위 지름길!", "Next: take the scale shortcut with 3 boxes!")
	if mode == "base":
		hint = L("다음엔 과속 배달: 짐 2개로 천장 가속!", "Next: try Rush, ceiling boost with 2 boxes!")
	elif mode == "over":
		hint = L("다음엔 밤 등불: 선두의 빛에 붙어라!", "Next: try Lantern, stick to the leader's light!")
	var res_f := L("%s · %d위\n배달한 짐 %d개 · 달린 시간 %.1f초\n최고 코스: %s\n%s\n로컬 최다 배달 %d개%s\n완주 최고 %s\n%s\n금: 2판 안에 승리 + 남은 짐 3개\n은: 3판 안 / 동: 코스 완주\n별점 아래 빈 곳을 탭하면 다시 배달",
		"%s · #%d\nDelivered %d · Time %.1fs\nBest course: %s\n%s\nMost delivered here: %d%s\nBest finish: %s\n%s\nGold: win in 2 rounds + 3 boxes left\nSilver: in 3 rounds / Bronze: finish\nTap the empty space below the stars to go again")
	var best_s := (L("%.1f초", "%.1fs") % best_time) if best_time > 0.0 else L("도전 중", "not yet")
	result_l.text = res_f % [L("여섯 동네 배달 완료!", "All six towns delivered!") if won else L("오늘 배달은 여기까지", "That's it for today"), placement, delivered, journey_time, strongest, rows, best_delivery, L(" · 새 기록!", " · New record!") if delivered > previous else "", best_s, hint]
	if not saved:
		result_l.text += L("\n기록 저장 안 됨", "\nRecord not saved")
	result_l.visible = true
	phase = "results"
	end() # Tofu owns stars, feedback, score save and tap-to-restart.
	_sfx("champion" if won else "lost")


func _process(dt: float) -> void:
	super._process(dt)
	tell_t = maxf(tell_t - dt, 0.0)
	_stamp_tick(dt)
	if result_l:
		result_l.visible = over and not _rating
		if over:
			_over_l.visible = false
			route_l.visible = false


# Art contract: art/screenrace/{name}.glb or models/{name}.glb, Y-up, auto-height.
# A holder keeps visual scale separate from collision and courier animation.
func _art_model(asset: String, parent: Node3D, pos := Vector3.ZERO, height := 1.0) -> bool:
	for path in ["res://art/screenrace/%s.glb" % asset, "res://art/screenrace/models/%s.glb" % asset]:
		if not ResourceLoader.exists(path):
			continue
		var resource := load(path)
		if not resource is PackedScene:
			continue
		var model := (resource as PackedScene).instantiate()
		if not model is Node3D:
			model.free()
			continue
		var holder := Node3D.new()
		parent.add_child(holder)
		holder.add_child(model)
		var pending: Array = [[model, Transform3D.IDENTITY]]
		var bounds := AABB()
		var found := false
		while not pending.is_empty():
			var entry: Array = pending.pop_back()
			var node: Node3D = entry[0]
			var transform: Transform3D = entry[1] * node.transform
			if node is MeshInstance3D and (node as MeshInstance3D).mesh:
				var ab: AABB = transform * (node as MeshInstance3D).get_aabb()
				bounds = bounds.merge(ab) if found else ab
				found = true
			for child in node.get_children():
				if child is Node3D:
					pending.append([child, transform])
		if not found or bounds.size.y <= 0.001:
			holder.queue_free()
			return false
		var scale_factor := height / bounds.size.y
		holder.scale = Vector3.ONE * scale_factor
		holder.position = pos - Vector3(bounds.get_center().x, bounds.position.y, bounds.get_center().z) * scale_factor
		return true
	return false


func _build_backdrop() -> void:
	var names := ["market", "riverside", "crossing", "night_market", "bridge", "rooftops"]
	var keys: Array = ["night", "night_market"] if mode == "lantern" else [names[ci]]
	for path in keys.map(func(k): return "res://art/screenrace/bg_%s.webp" % k):
		if ResourceLoader.exists(path):
			var texture := load(path) as Texture2D
			if texture:
				backdrop = Sprite3D.new()
				backdrop.texture = texture
				backdrop.pixel_size = 65.0 / maxf(texture.get_width(), 1.0)
				backdrop.shaded = false
				stage.add_child(backdrop)
				return


func _swap_visual(asset: String, parent: Node3D, pos: Vector3, height: float) -> void:
	var fallback := parent.get_children()
	if _art_model(asset, parent, pos, height):
		for child in fallback:
			if child is Node3D:
				(child as Node3D).visible = false


func _setup() -> void:
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	var layer := CanvasLayer.new()
	add_child(layer)
	mode_l = _label(layer, 28, 130, 64)
	route_l = _label(layer, 30, 250, 160)
	result_l = _label(layer, 30, 240, 570)
	result_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_l.position.x = 30
	result_l.size.x = 660
	result_l.visible = false
	var opt := ConfigFile.new()
	if opt.load(RECORDS) == OK:
		lang = "ko" if str(opt.get_value("opt", "lang", "en")) == "ko" else "en"
	howto = _howto_text()
	_stamp_setup()
	kit_stick()
	kit_button("jump", L("점프", "Jump"), Vector2(600, 1120), 100.0, A)
	kit_button("drop", L("짐", "Box"), Vector2(600, 890), 82.0, PARCEL)
	kit_button("mode_over", L("과속", "Rush"), Vector2(420, 690), 80.0, BAD)
	_btns["mode_over"].r = 0.0
	kit_button("lang", L("English", "한국어"), Vector2(630, 520), 54.0, INK.lightened(0.3))
	_btns["lang"].r = 0.0


func _reset() -> void:
	ci = 0
	rnd = 0
	journey_time = 0.0
	course_time = 0.0
	delivered = 0
	course_results.clear()
	seen_rules.clear()
	finale = false
	result_l.visible = false
	records = ConfigFile.new()
	if FileAccess.file_exists(RECORDS):
		records.load(RECORDS)
	stage = null
	mode = "base"
	spd_mul = 1.0
	jump_mul = 1.0
	slip_mul = 1.0
	load_bonus = 0
	load_w = 1.0
	knock_mul = 1.0
	twist = ""
	grid = []
	fresh = true
	taken.clear()
	game_seed = randi()
	runners.clear()
	var cols := [ME, A, B, Color("f783ac")]
	var nicks := ["나", "주황", "하늘", "분홍"]
	for i in 4:
		var r := Courier.new()
		r.ai = i > 0
		r.col = cols[i]
		r.nick = nicks[i]
		r.nick_en = NICKS_EN[i]
		_make_body(r)
		runners.append(r)
	pl = runners[0]
	parcels.clear()
	for i in 18:
		var n := box(Vector3(0, -50, 0), Vector3(0.6, 0.5, 0.6), PARCEL)
		if _art_model("parcel", n, Vector3(0, -0.5, 0), 1.0):
			n.mesh = null
		n.visible = false
		parcels.append({"node": n, "on": false, "p": Vector2.ZERO, "owner": null, "cd": 0.0})
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	curtain = box(Vector3.ZERO, Vector3(1, 1, 0.2), NIGHT)
	curtain.visible = false
	marker = box(Vector3.ZERO, Vector3(0.36, 0.36, 0.36), ME)
	marker.rotation.z = PI * 0.25
	vpool.clear()
	for i in POOL_N:
		var m := box(Vector3(0, -80, 0), Vector3.ONE, WHITE)
		m.visible = false
		vpool.append(m)
	bits.clear()
	for i in BITS_N:
		var m := box(Vector3(0, -80, 0), Vector3(0.28, 0.28, 0.28), WHITE)
		m.visible = false
		bits.append({"node": m, "v": Vector3.ZERO, "life": 0.0})
	clouds.clear()
	for i in 4:
		var m := box(Vector3(0, 0, -22.0), Vector3(gen.randf_range(5.0, 9.0), 1.4, 1.0), WHITE)
		clouds.append({"node": m, "x": i * 17.0 + randf() * 6.0, "y": 13.0 + randf() * 7.0})
	winds.clear()
	for i in 5:
		var m := box(Vector3(0, -80, 4.0), Vector3(2.5, 0.06, 0.06), WHITE)
		m.visible = false
		winds.append(m)
	lantern = Node3D.new()
	world.add_child(lantern)
	box(Vector3(0, 0.45, 0), Vector3(0.08, 0.9, 0.08), INK, lantern)
	box(Vector3(0, 1.05, 0), Vector3(0.5, 0.55, 0.5), GLOW, lantern)
	box(Vector3(0, 1.05, 0.28), Vector3(0.24, 0.3, 0.05), WHITE, lantern)
	box(Vector3(0, 1.38, 0), Vector3(0.6, 0.1, 0.6), INK.lightened(0.2), lantern)
	_swap_visual("lantern", lantern, Vector3(0, 0.3, 0), 1.2)
	lantern.visible = false
	fogs.clear()
	for i in FOG_N:
		var m := box(Vector3(0, -80, ZF), Vector3.ONE, FOG)
		m.visible = false
		fogs.append(m)
	edges.clear()
	for i in EDGE_N:
		var m := box(Vector3(0, -80, ZF + 0.05), Vector3.ONE, GLOW)
		m.visible = false
		edges.append(m)
	lit.clear()
	bearer = null
	_restore_labels()
	_build_course()
	_start_round()
	# 모드 고르기: 버튼 셋
	phase = "mode"
	_mode_buttons()


func _pick_mode(n: String) -> void:
	mode = "base" if n == "jump" else ("lantern" if n == "drop" else "over")
	_btns["mode_over"].r = 0.0
	_btns["lang"].r = 0.0
	_btns["lang"].label = ""
	play("good")
	_restore_labels()
	_kit_clear()
	rnd = 0
	fresh = true
	_build_course()
	_start_round()


func _make_body(r: Courier) -> void:
	r.node = Node3D.new()
	world.add_child(r.node)
	var skins := ["courier_coral", "courier_blue", "courier_mint", "courier_gold"]
	if _art_model(skins[runners.size() % 4], r.node, Vector3(0, -0.45, 0), 1.5):
		r.art = r.node.get_child(r.node.get_child_count() - 1)
	else:
		box(Vector3.ZERO, Vector3(HW * 2.0, HH * 0.75, 0.8), r.col, r.node)
		box(Vector3(0, 0.63, 0), Vector3(0.42, 0.36, 0.5), SOFT, r.node)
		box(Vector3(0.05, 0.88, 0), Vector3(0.6, 0.14, 0.6), WHITE if not r.ai else r.col.darkened(0.2), r.node)
	for k in LOAD_MAX + 1:
		var q := box(Vector3(-0.5, -0.2 + k * 0.4, 0), Vector3(0.5, 0.38, 0.6), PARCEL, r.node)
		if _art_model("parcel", q, Vector3(0, -0.5, 0), 1.0):
			q.mesh = null
		q.visible = false
		r.packs.append(q)
	r.fire = box(Vector3(-0.9, 0, 0), Vector3(0.9, 0.35, 0.35), C, r.node)
	r.fire.visible = false
	r.poof = box(Vector3.ZERO, Vector3(1, 1, 1), WHITE)
	r.poof.visible = false
	for k in 3:
		var s := box(Vector3.ZERO, Vector3(1, 0.07, 0.07), WHITE)
		s.visible = false
		r.streaks.append(s)
	for k in WINS:
		var q := box(Vector3.ZERO, Vector3(0.24, 0.24, 0.24), r.col)
		q.visible = false
		r.pips.append(q)


# ---- 코스 만들기 ----
func _build_course() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	cdef = COURSES[ci]
	rects.clear()
	kinds = PackedInt32Array()
	ramp_of.clear()
	decor_n = 0
	spots.clear()
	flows.clear()
	trains.clear()
	boards.clear()
	board_of.clear()
	gates.clear()
	gusts.clear()
	mechanisms.clear()
	shutter_of.clear()
	signs.clear()
	backdrop = null
	vspecs.clear()
	vslot.clear()
	vfree.clear()
	for k in vpool.size():
		vpool[k].visible = false
		vfree.append(k)
	v_last = Vector3(1e9, 0, 0)
	for e in get_children():
		if e is WorldEnvironment:
			(e as WorldEnvironment).environment.background_color = NIGHT_SKY if mode == "lantern" else cdef.sky
	gen.seed = game_seed + ci * 7919 + rnd * 131  # 판마다 새 지도
	fy = 0.0
	min_fy = 0.0
	gx = -40.0
	_floor(gx, 44.0)
	gx = 4.0
	if ci == 0 and rnd == 0 and not finale:
		_floor(gx, 90.0)
		_sign(1.0, fy + 3.6, "왼쪽 밖: 짐 하나 · 빈손이면 탈락", "Off the left: lose a box · out if empty")
		_sign(26.0, fy + 3.6, "짐이 많으면 느리지만 안전하다", "More boxes: slower but safer")
		_sign(52.0, fy + 3.6, "[짐] 하나 버리면 앞으로 튀어나간다", "Drop one [Box] to burst forward")
		gx = 94.0
	if finale:
		for part in ["ballast", "ballast_mix", "updraft", "updraft_mix", "shutter", "shutter_mix", "dropfloor", "dropfloor_mix"]:
			_seg(part)
	else:
		for part in LESSONS[ci]:
			_seg(part)
	var goal := 380.0 + mini(ci, 3) * 45.0
	var segs: Array = cdef.segs
	var last := ""
	var n_river := 0
	var n_bridge := 0
	var n_tw := 0
	var since := 0
	while gx < goal and not finale:
		var s: String = segs[gen.randi() % segs.size()]
		if s == last and s != "flat" and s != "roofgap" and s != "river":
			s = "flat" if cdef.rule != "roof" else "roofgap"
		# 움직이는 상자가 많은 구간은 코스마다 몇 개까지만
		if (s == "river" and n_river >= 4) or (s == "track" and trains.size() >= 4) or (s == "bridge" and n_bridge >= 3):
			s = "flat"
		if gx < 30.0 and (s == "track" or s == "bridge"):
			s = "flat"  # 출발 직후는 몸 풀기
		# 판 변주 구간: 코스 규칙 구간 두세 개마다 하나씩 섞는다 (판에 3번)
		if twist != "" and n_tw < 3 and gx > 30.0 and since >= 2 + n_tw % 2:
			s = twist
		if s == twist:
			n_tw += 1
			since = 0
		else:
			since += 1
		n_river += 1 if s == "river" else 0
		n_bridge += 1 if s == "bridge" else 0
		last = s
		_seg(s)
	goal_x = gx + (24.0 if finale else 2.0)
	if finale:
		_sign(gx + 7.0, fy + 3.0, "마지막 집. 짐 하나는 남겨라", "Last house. Keep at least one box")
		_vbox(Vector3(goal_x + 6.0, fy + 3.0, -3.0), Vector3(7, 6, 3), SOFT)
		_vbox(Vector3(goal_x + 6.0, fy + 6.3, -3.0), Vector3(8, 0.6, 4), cdef.top)
		_vbox(Vector3(goal_x + 4.0, fy + 1.4, -1.4), Vector3(1.6, 2.8, 0.2), GOOD)
	_floor(gx, 60.0)
	for z in [-1.4, 1.4]:
		_vbox(Vector3(goal_x, fy + 2.6, z), Vector3(0.3, 5.2, 0.3), GOOD)
	for k in 6:
		_vbox(Vector3(goal_x, fy + 5.2, -1.25 + k * 0.5), Vector3(0.32, 0.4, 0.5), WHITE if k % 2 == 0 else INK)
	kill_y = min_fy - 6.0
	# 칸 나누기 (가까운 상자만 검사)
	buckets.clear()
	var nb := int((gx + 100.0 - BX0) / BK) + 1
	for b in nb:
		buckets.append([])
	for i in rects.size():
		var rc := rects[i]
		for b in range(_bi(rc.position.x), _bi(rc.end.x) + 1):
			buckets[b].append(i)
	_build_backdrop()
	# 뒤 건물 (원근 때문에 느리게 지나간다)
	var bx := -40.0
	var bld: Array = cdef.bld
	while bx < gx + 60.0:
		var w := gen.randf_range(4.0, 8.0)
		var h := gen.randf_range(8.0, 26.0)
		var c: Color = bld[gen.randi() % bld.size()]
		_vbox(Vector3(bx + w * 0.5, h * 0.5 - 14.0, -12.0 - gen.randf() * 3.0), Vector3(w, h, 3.0), c)
		bx += w + gen.randf_range(0.5, 2.5)
	# 먼 산·건물 실루엣 (아주 느리게 지나간다)
	var fx := -60.0
	var farc: Color = cdef.far
	while fx < gx + 120.0:
		var w := gen.randf_range(10.0, 22.0)
		var h := gen.randf_range(14.0, 34.0)
		var c2 := farc.lightened(gen.randf() * 0.25)
		if cdef.rule == "roof" or cdef.rule == "train" or cdef.rule == "dark":
			_vbox(Vector3(fx + w * 0.5, h * 0.5 - 12.0, -34.0), Vector3(w, h, 2.0), c2)  # 먼 빌딩
		else:
			# 계단꼴 산: 넓은 아래 + 좁은 위
			_vbox(Vector3(fx + w * 0.5, h * 0.3 - 12.0, -34.0), Vector3(w, h * 0.6, 2.0), c2)
			_vbox(Vector3(fx + w * 0.5, h * 0.75 - 12.0, -34.5), Vector3(w * 0.45, h * 0.3, 2.0), c2.lightened(0.15))
		fx += w * 0.8
	# 앞 가로등 (빨리 지나가서 속도가 보인다)
	var px := 0.0
	while px < goal_x:
		var y := _floor_top(px, 60.0)
		if y > -100.0:
			_vbox(Vector3(px, y + 2.0, 3.2), Vector3(0.22, 4.0, 0.22), WHITE)
			_vbox(Vector3(px + 0.35, y + 4.0, 3.2), Vector3(0.9, 0.22, 0.3), cdef.top)
		px += 9.0


func _seg(s: String) -> void:
	var wallc: Color = BAD
	if SEG_RULES.has(s):
		_sign(gx + 1.0, fy + 4.2, SEG_RULES[s], SEG_RULES_EN[s], s)
	match s:
		"ballast", "ballast_mix":
			# 무거운 짐이 열쇠. 낮은 길도 열려 있지만 장애물/강물 때문에 늦다.
			_floor(gx, 26.0)
			_solid(Rect2(gx + 4.0, fy, 2.0, 0.25), D, 0)
			mechanisms.append({"type": "ballast", "x0": gx + 3.5, "x1": gx + 6.5, "y": fy + 0.25})
			_plat(gx + 8.0, fy + 5.0, 12.0, GOOD)
			spots.append(Vector2(gx + 14.0, fy + 5.0))
			if s == "ballast_mix":
				_solid(Rect2(gx + 7.0, fy - 0.3, 16.0, 0.3), B, 3)
			else:
				_bump(gx + 11.0, fy, 1.2, 1.5, BAD, 4.0, 2.6)
				_bump(gx + 18.0, fy, 1.2, 1.5, BAD, 3.0, 4.0)
			gx += 26.0
		"updraft", "updraft_mix":
			_floor(gx, 28.0)
			mechanisms.append({"type": "updraft", "x0": gx + 3.0, "x1": gx + 8.0, "y": fy})
			for k in 4:
				_vbox(Vector3(gx + 3.5 + k, fy + 2.0, -0.8), Vector3(0.12, 4.0, 0.12), WIND_C)
			_plat(gx + 9.0, fy + 5.0, 12.0, GOOD)
			_bump(gx + 12.0, fy, 1.2, 1.8, BAD, 3.5, 2.5)
			_bump(gx + 19.0, fy, 1.2, 1.8, BAD, 3.2, 2.5)
			if s == "updraft_mix":
				# 위층의 낮은 문은 상승풍 입구에서 떨어뜨려 둔다.
				_solid(Rect2(gx + 15.0, fy + 6.6, 5.0, 2.0), BAD, 0)
				spots.append(Vector2(gx + 23.0, fy))
			gx += 28.0
		"shutter", "shutter_mix":
			_floor(gx, 26.0)
			if s == "shutter_mix":
				gusts.append(Vector2(gx, gx + 26.0))
			var dx := gx + 10.0
			rects.append(Rect2(dx, fy, 0.5, 3.5))
			kinds.append(7)
			shutter_of[rects.size() - 1] = mechanisms.size()
			var door := box(Vector3(dx + 0.25, fy + 1.75, 0), Vector3(0.5, 3.5, 2.5), BAD, stage)
			mechanisms.append({"type": "shutter", "x0": dx - 2.5, "x1": dx, "y": fy, "t": -1.0, "node": door})
			_solid(Rect2(dx - 1.0, fy + 3.5, 3.0, 2.0), BAD, 0)
			gx += 26.0
		"dropfloor", "dropfloor_mix":
			_floor(gx, 4.0)
			var low := fy - 4.5
			_solid(Rect2(gx + 4.0, low - 10.0, 24.0, 10.0), cdef.gnd, 0)
			# 위는 장애물 길, 무거운 선두가 아래를 열면 뒤도 같은 구멍을 쓴다.
			for k in 4:
				var rc := Rect2(gx + 4.0 + k * 1.5, fy - 0.3, 1.5, 0.3)
				rects.append(rc)
				kinds.append(4)
				var bn := box(Vector3(rc.get_center().x, rc.get_center().y, 0), Vector3(1.5, 0.3, 2.4), BOARD, stage)
				var bd := {"i": rects.size() - 1, "node": bn, "home": bn.position, "t": -1.0, "gone": false, "vy": 0.0}
				boards.append(bd)
				board_of[rects.size() - 1] = bd
			_plat(gx + 10.0, fy, 14.0, cdef.top)
			_bump(gx + 13.0, fy, 1.0, 1.8, BAD, 2.8, 2.4)
			_bump(gx + 19.0, fy, 1.0, 1.8, BAD, 2.6, 3.0)
			if s == "dropfloor_mix":
				_solid(Rect2(gx + 4.0, low - 0.2, 20.0, 0.2), ICE, 5)
			# lower route becomes the next segment's floor; no invisible fatal pit.
			fy = low
			_floor(gx + 28.0, 5.0)
			gx += 33.0
		"flat":
			var w := gen.randf_range(6.0, 12.0)
			_floor(gx, w)
			if gen.randf() < 0.4:
				spots.append(Vector2(gx + w * 0.5, fy))
			if (cdef.rule == "" or cdef.rule == "dark") and w > 8.0 and int(gx) % 3 == 0:
				_decor("market_stall", Vector3(gx + w * 0.5, fy, -3.4), 3.0)
			gx += w
		"stairs":  # 긴 언덕 하나: 오르막은 짐이 무거울수록 느리고, 내리막은 빨라진다
			var up := fy < -1.0 or (fy < 4.0 and gen.randf() < 0.55)
			var rise := 2.5
			var ln := 6.5
			if up:
				_floor(gx, ln)
				_ramp(gx, fy, ln, rise, 1, cdef.top, cdef.gnd.darkened(0.06))
				fy += rise
			else:
				fy -= rise
				_floor(gx, ln)
				_ramp(gx, fy, ln, rise, -1, cdef.top, cdef.gnd.darkened(0.06))
			gx += ln
			_floor(gx, 3.0)
			gx += 3.0
		"wall":
			_floor(gx, 9.0)
			# 앞 경사로: 걸어 오르면 느려지고 점프로 넘으면 속도를 지킨다. 과속 모드는 맞부딪혀 튕기는 벽 그대로.
			_bump(gx + 4.0, fy, 0.9, gen.randf_range(1.3, 2.2), wallc, 0.0 if mode == "over" else 4.0, 4.1)
			gx += 9.0
		"pit":
			_floor(gx, 2.0)
			_danger_edge(gx + 1.7, fy)
			gx += 2.0 + gen.randf_range(3.0, 5.0)
			fy = clampf(fy + gen.randf_range(-1.0, 1.0), -3.0, 6.0)
			_floor(gx, 5.0)
			gx += 5.0
		"awning":  # 노란 발판 → 위쪽 지름길(짐 하나), 아래는 상자벽
			_floor(gx, 4.0)
			_solid(Rect2(gx + 2.2, fy, 1.6, 0.4), D, 1, 2.5)
			_plat(gx + 5.0, fy + 6.5, 17.0, wallc)
			spots.append(Vector2(gx + 12.0, fy + 6.5))
			_floor(gx + 4.0, 18.0)
			_bump(gx + 9.0, fy, 1.2, 1.1, wallc, 3.0, 1.8)
			_bump(gx + 15.0, fy, 1.2, 1.6, wallc, 2.9, 2.6)
			gx += 22.0
		"crates":
			_floor(gx, 12.0)
			_bump(gx + 3.0, fy, 1.2, 1.0, wallc, 2.8, 0.0)
			_bump(gx + 8.0, fy, 1.2, 1.7, wallc, 2.6, 2.8)
			if gen.randf() < 0.5:
				spots.append(Vector2(gx + 4.9, fy))
			if int(gx) % 2 == 0:
				_decor("crate", Vector3(gx + 10.6, fy, -1.9), 1.1)
			gx += 12.0
		"river":  # 뒤로 흐르는 바닥 조각들, 사이는 물
			for k in 3:
				var w := gen.randf_range(7.0, 10.0)
				_solid(Rect2(gx, fy - 14.0, w, 14.0), cdef.gnd, 3)
				_vbox(Vector3(gx + w * 0.5, fy - 0.1, 0), Vector3(w, 0.2, 2.5), cdef.top)
				var marks: Array = []
				for m in 3:
					marks.append(box(Vector3(gx, fy + 0.05, 0.9), Vector3(0.7, 0.12, 0.4), WHITE, stage))
				flows.append({"x0": gx, "w": w, "y": fy, "marks": marks})
				gx += w
				if k < 2:
					var g := gen.randf_range(2.5, 3.5)
					_danger_edge(gx - 0.3, fy)
					_vbox(Vector3(gx + g * 0.5, fy - 2.5, 0), Vector3(g, 0.3, 2.5), B)
					gx += g
			_floor(gx, 3.0)
			gx += 3.0
		"track":  # 위 승강장(틈·상자) / 아래 도랑 선로(벽 없이 빠름, 앞에서 기차)
			_floor(gx, 3.0)
			gx += 3.0
			var x0 := gx
			var ln := gen.randf_range(26.0, 32.0)
			var yb := fy - TRENCH
			_solid(Rect2(x0, yb - 14.0, ln, 14.0), cdef.gnd, 0)
			_vbox(Vector3(x0 + ln * 0.5, yb + 0.02, 0), Vector3(ln, 0.06, 1.6), Color("e9ecef"))
			for z in [-0.55, 0.55]:
				_vbox(Vector3(x0 + ln * 0.5, yb + 0.1, z), Vector3(ln, 0.12, 0.14), Color("868e96"))
			var sx := x0 + 1.0
			while sx < x0 + ln:
				_vbox(Vector3(sx, yb + 0.05, 0), Vector3(0.3, 0.08, 1.5), Color("ced4da"))
				sx += 2.0
			# 승강장 조각: 틈에 빠지면 선로로 떨어진다 (다시는 못 올라온다)
			var x := x0
			var first := true
			var end_x := x0 + ln - 4.5  # 마지막 틈은 4.5 (넘을 수 있다)
			while x < end_x - 1.5:
				var w := gen.randf_range(4.5, 7.0)
				if x + w > end_x - 3.5:
					w = end_x - x
				_solid(Rect2(x, fy - 0.8, w, 0.8), cdef.gnd.darkened(0.04), 0)
				_vbox(Vector3(x + w * 0.5, fy - 0.08, 0), Vector3(w, 0.16, 2.5), cdef.top)
				if not first and w > 5.0 and gen.randf() < 0.6:
					_bump(x + w * 0.5, fy, 1.1, gen.randf_range(1.0, 1.6), BAD, w * 0.5 - 0.2, w * 0.5 - 1.3)
				elif gen.randf() < 0.4:
					spots.append(Vector2(x + w * 0.5, fy))
				first = false
				x += w + gen.randf_range(2.2, 3.0)
			# 끝: 마지막 틈 밑 용수철이 선로에서 위로 올려 준다
			_solid(Rect2(x0 + ln - 2.6, yb, 1.8, 0.4), D, 1, 2.0)
			gx = x0 + ln
			var tn := Node3D.new()
			stage.add_child(tn)
			box(Vector3(TRAIN_L * 0.5, TRAIN_H * 0.5, 0), Vector3(TRAIN_L, TRAIN_H, 1.8), B, tn)
			box(Vector3(TRAIN_L * 0.5, TRAIN_H + 0.08, 0), Vector3(TRAIN_L - 0.3, 0.16, 1.6), WHITE, tn)
			for k in 3:
				box(Vector3(1.6 + k * 2.0, TRAIN_H * 0.62, 0.92), Vector3(1.1, 0.6, 0.05), WHITE, tn)
			box(Vector3(-0.05, TRAIN_H * 0.35, 0), Vector3(0.12, 0.35, 1.0), D, tn)
			_swap_visual("train", tn, Vector3(TRAIN_L * 0.5, 0, 0), TRAIN_H)
			tn.position = Vector3(x0 + ln + 2.0, yb, 0)
			var lamp := box(Vector3(x0 + ln + 0.6, fy + 1.6, 1.3), Vector3(0.5, 0.5, 0.3), WHITE, stage)
			box(Vector3(x0 + ln + 0.6, fy + 0.7, 1.3), Vector3(0.14, 1.4, 0.14), INK, stage)
			trains.append({"x0": x0, "x1": x0 + ln, "y": yb, "x": x0 + ln + 2.0, "node": tn, "lamp": lamp,
				"st": "wait", "t": gen.randf_range(1.0, 3.0), "lit": false})
			min_fy = minf(min_fy, yb)
		"bridge":  # 짐 3개 이상으로 밟은 판은 곧 떨어진다
			_floor(gx, 3.0)
			gx += 3.0
			var n := gen.randi_range(8, 10)
			for k in n:
				var rc := Rect2(gx + k * 1.5, fy - 0.35, 1.45, 0.35)
				rects.append(rc)
				kinds.append(4)
				var bn := box(Vector3(rc.get_center().x, rc.get_center().y, 0), Vector3(1.45, 0.35, 2.2), BOARD, stage)
				var bd := {"i": rects.size() - 1, "node": bn, "home": bn.position, "t": -1.0, "gone": false, "vy": 0.0}
				boards.append(bd)
				board_of[rects.size() - 1] = bd
			var bw := n * 1.5
			for z in [-1.15, 1.15]:
				_vbox(Vector3(gx + bw * 0.5, fy + 1.0, z), Vector3(bw, 0.09, 0.09), INK.lightened(0.3))
				_vbox(Vector3(gx - 0.1, fy + 0.6, z), Vector3(0.22, 1.4, 0.22), cdef.wall)
				_vbox(Vector3(gx + bw + 0.1, fy + 0.6, z), Vector3(0.22, 1.4, 0.22), cdef.wall)
			_vbox(Vector3(gx + bw * 0.5, fy - 11.0, -1.0), Vector3(bw + 2.0, 0.4, 5.0), B.lightened(0.3))  # 아래 계곡물
			gx += bw
			_floor(gx, 3.0)
			gx += 3.0
		"gate":  # 낮은 문: 짐 GATE_MAX개 이하만 문틀 밑으로 지나간다. 문 앞에서 뛰면 지붕에 찧는다
			_floor(gx, 15.0)
			var dx := gx + 6.0
			_solid(Rect2(dx, fy + GATE_H, 5.0, 7.0), BAD, 0)
			rects.append(Rect2(dx, fy, 0.4, GATE_H))  # 짐이 많으면 걸리는 문틀 (안 보인다)
			kinds.append(6)
			gates.append(dx)
			for z in [-1.3, 1.3]:
				_vbox(Vector3(dx, fy + GATE_H * 0.5, z), Vector3(0.3, GATE_H, 0.3), INK)
			for k in GATE_MAX:  # 간판: 짐 두 개 그림
				_vbox(Vector3(dx + 0.9 + k * 0.75, fy + GATE_H + 0.55, 1.35), Vector3(0.55, 0.45, 0.2), PARCEL)
			spots.append(Vector2(gx + 13.0, fy))  # 문 뒤 짐 하나: 다시 주울지
			gx += 15.0
		"slide":  # 얼음 내리막: 못 멈추고, 무거울수록 빨리 미끄러진다. 끝은 구덩이
			_floor(gx, 2.0)
			gx += 2.0
			for k in 5:
				_solid(Rect2(gx, fy - 14.0, 3.4, 14.0), ICE, 5)
				_vbox(Vector3(gx + 1.7, fy - 0.08, 0), Vector3(3.4, 0.16, 2.5), WHITE)
				gx += 3.4
				if k < 4:
					fy -= 0.45
					min_fy = minf(min_fy, fy)
			_danger_edge(gx - 0.3, fy)
			gx += gen.randf_range(3.5, 4.5)
			fy = minf(fy + 1.0, 6.0)
			_floor(gx, 5.0)
			gx += 5.0
		"wind":  # 맞바람: 최고 속도가 깎인다. 앞사람 바로 뒤는 바람이 없다
			var ln := gen.randf_range(18.0, 24.0)
			_floor(gx, ln)
			gusts.append(Vector2(gx, gx + ln))
			_bump(gx + ln * 0.5, fy, 1.2, 1.1, BAD)
			var wx := gx + 1.5
			while wx < gx + ln:
				_vbox(Vector3(wx, fy + 1.6, -1.5), Vector3(0.14, 3.2, 0.14), INK)
				_vbox(Vector3(wx - 0.7, fy + 3.0, -1.5), Vector3(1.4, 0.35, 0.08), WIND_C)  # 왼쪽으로 날리는 깃발
				wx += 4.0
			gx += ln
		"roofgap", "longgap":
			_floor(gx, gen.randf_range(6.0, 10.0))
			gx = rects[rects.size() - 1].end.x
			if gen.randf() < 0.35:
				spots.append(Vector2(gx - 3.0, fy))
			var g := gen.randf_range(4.5, 6.2) if s == "roofgap" else gen.randf_range(6.8, 7.4)
			var ny := clampf(fy + gen.randf_range(-2.0, 1.0), -3.0, 6.0)
			if s == "longgap":
				ny = minf(ny, fy - 0.5)
			elif ny > fy + 0.5:
				g = minf(g, 5.0)
			_danger_edge(gx - 0.3, fy)
			gx += g
			fy = ny
			_floor(gx, 4.0)
			gx += 4.0
	min_fy = minf(min_fy, fy)


func _danger_edge(x: float, y: float) -> void:
	_vbox(Vector3(x, y + 0.08, 0), Vector3(0.6, 0.16, 2.6), BAD)
	_vbox(Vector3(x - 0.8, y + 0.05, 0), Vector3(0.35, 0.1, 2.6), BAD)


func _floor(x: float, w: float) -> void:
	_solid(Rect2(x, fy - 14.0, w, 14.0), cdef.gnd, 0)
	_vbox(Vector3(x + w * 0.5, fy - 0.1, 0), Vector3(w, 0.2, 2.5), cdef.top)


func _plat(x: float, top: float, w: float, c: Color) -> void:
	_solid(Rect2(x, top - 0.5, w, 0.5), c, 0, 2.0)
	_vbox(Vector3(x + w * 0.5, top - 0.05, 0), Vector3(w + 0.06, 0.1, 2.08), c.lightened(0.4))


## 장애물 상자 (윗면 밝은 테 + 앞면 어두운 판으로 덩어리처럼 안 보이게)
func _block(rc: Rect2, c: Color, depth := 2.4) -> void:
	_solid(rc, c, 0, depth)
	var m := rc.get_center()
	_vbox(Vector3(m.x, rc.end.y - 0.07, 0), Vector3(rc.size.x + 0.1, 0.14, depth + 0.1), c.lightened(0.45))
	if rc.size.x > 0.5 and rc.size.y > 0.6:
		_vbox(Vector3(m.x, m.y - 0.05, depth * 0.5), Vector3(rc.size.x - 0.3, rc.size.y - 0.4, 0.06), c.darkened(0.2))


## 장애물 + 앞뒤 경사로. 걸어 오르면 느려지고(가파를수록·짐이 많을수록) 뛰어넘으면 속도를 지킨다.
## front/back = 경사로를 놓을 수 있는 길이 (0이면 그쪽은 맞부딪히는 벽)
func _bump(x: float, y: float, w: float, h: float, c: Color, front := 9.0, back := 9.0) -> void:
	var rl := h * RAMP_RUN
	if front >= 1.0:
		var fl := minf(rl, front)
		_ramp(x - fl, y, fl, h, 1, BOARD, BOARD.darkened(0.3))
	if back >= 1.2:
		var bl := minf(rl, back)
		_ramp(x + w, y, bl, h, -1, BOARD, BOARD.darkened(0.3))
	_block(Rect2(x, y, w, h), c)


## 경사로: 바닥 y에서 x0..x0+w 동안 h만큼. dir 1 = 오른쪽으로 오르막, -1 = 오른쪽으로 내리막
## 보이는 것: 기울어진 판 하나 + 판 밑을 채우는 받침 1~2개
func _ramp(x0: float, y: float, w: float, h: float, dir: int, c: Color, fill: Color) -> void:
	rects.append(Rect2(x0, y, w, h))
	kinds.append(8)
	ramp_of[rects.size() - 1] = dir
	var a := atan2(h, w) * dir
	var t := 0.24
	var mid := Vector2(x0 + w * 0.5, y + h * 0.5) - Vector2(-sin(a), cos(a)) * t * 0.5
	_vbox(Vector3(mid.x, mid.y, 0), Vector3(sqrt(w * w + h * h) + 0.06, t, 2.3), c, a)
	var n := 3 if w > 3.0 else 2
	var cw := w / n
	for k in range(1, n):
		var cx := x0 + cw * (k + 0.5) if dir > 0 else x0 + w - cw * (k + 0.5)
		var ch := h * k / n - 0.06
		_vbox(Vector3(cx, y + ch * 0.5, -0.1), Vector3(cw, ch, 2.1), fill)


## 그림 장식 (충돌 없음). 코스마다 몇 개까지만
func _decor(asset: String, pos: Vector3, height: float) -> void:
	if decor_n >= 6:
		return
	if _art_model(asset, stage, pos, height):
		decor_n += 1


func _solid(rc: Rect2, c: Color, kind: int, depth := 2.4) -> void:
	rects.append(rc)
	kinds.append(kind)
	var m := rc.get_center()
	_vbox(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, depth), c)


## 코스 상자 명세 하나 (실제 상자는 화면 근처일 때만 풀에서 빌린다)
func _vbox(pos: Vector3, size: Vector3, c: Color, rot := 0.0) -> void:
	vspecs.append([pos, size, c, rot])
	vslot.resize(vspecs.size())
	vslot[vspecs.size() - 1] = -1


func _vis() -> void:
	if absf(camx - v_last.x) < 0.4 and absf(camy - v_last.y) < 0.4 and absf(hwv - v_last.z) < 0.15:
		return
	v_last = Vector3(camx, camy, hwv)
	for i in vspecs.size():
		var sp: Array = vspecs[i]
		var p: Vector3 = sp[0]
		var s: Vector3 = sp[1]
		var f := (CAM_D - p.z) / CAM_D
		var inside := absf(p.x - camx) - s.x * 0.5 < hwv * f + 4.0 and absf(p.y - camy) - s.y * 0.5 < vhv * f + 4.0
		var k := vslot[i]
		if inside and k < 0 and not vfree.is_empty():
			k = vfree.pop_back()
			vslot[i] = k
			var m := vpool[k]
			m.position = p
			m.rotation.z = sp[3]
			m.scale = s
			m.material_override = mat(sp[2])
			m.visible = true
		elif not inside and k >= 0:
			vpool[k].visible = false
			vfree.append(k)
			vslot[i] = -1


func _bi(x: float) -> int:
	return clampi(int(floor((x - BX0) / BK)), 0, buckets.size() - 1)


# ---- 라운드 ----
func _start_round() -> void:
	rnd += 1
	# 출발 줄: 새 코스면 기본, 아니면 지난 판 순위대로 (이긴 사람이 맨 앞 = 1등이라 앞이 안 보인다)
	var order: Array = runners.duplicate()
	var xs := [-2.2, -1.0, -3.4, -4.6]
	if not fresh and grid.size() == 4:
		order = grid
		xs = [-1.0, -2.2, -3.4, -4.6]
	for i in 4:
		var r: Courier = order[i]
		r.p = Vector2(xs[i], 0.0)
		r.v = Vector2.ZERO
		r.alive = true
		var cap := LOAD_MAX + (0 if r.ai else load_bonus)
		if fresh:
			r.cargo = LOAD0 + (0 if r.ai else load_bonus)
		else:
			r.cargo = clampi(r.cargo, 1, cap)  # 지난 판 끝의 짐을 그대로 들고 출발
		r.stun = 0.0
		r.dash = 0.0
		r.drop_cd = 0.0
		r.immune = 0.0
		r.cut = true
		r.face = 1.0
		r.poof_t = 0.0
		r.node.visible = true
		r.node.rotation = Vector3.ZERO
		r.poof.visible = false
		r.sq = 0.0
		r.node.scale = Vector3.ONE
		if r.ai:
			var lv := ci * 0.6  # 코스 6개를 예전 4개 난이도 폭에 맞춘다
			r.skill = 0.93 + 0.025 * lv + (runners.find(r) - 2) * 0.02
			r.err = 0.2 - 0.03 * lv
			r.dive = randf() < 0.45
			r.bold = randf()
		r.lost = 0.0
		_probe(r)
	for bd in boards:
		bd.t = -1.0
		bd.gone = false
		bd.vy = 0.0
		kinds[bd.i] = 4
		var bn: MeshInstance3D = bd.node
		bn.position = bd.home
		bn.rotation = Vector3.ZERO
		bn.visible = true
		bn.material_override = mat(BOARD)
	for tr in trains:
		tr.st = "wait"
		tr.t = randf_range(1.5, 3.5)
		tr.x = tr.x1 + 2.0
		(tr.node as Node3D).position.x = tr.x
	bridge_said = false
	for b in bits:
		b.life = 0.0
		(b.node as Node3D).visible = false
	for pc in parcels:
		pc.on = false
		(pc.node as Node3D).visible = false
	for i in mini(spots.size(), parcels.size() - 6):
		_put_parcel(spots[i], null)
	rt = 0.0
	lead_t = 0.0
	lean = 0.0
	dark_t = 0.0
	dark_on = false
	dark_warn = false
	curtain.visible = false
	fresh = false
	hwv = _want_w()
	camx = 0.0
	camy = 2.0
	phase = "count"
	pt = 1.4
	danger = false
	bearer = null
	hold_acc = 0.0
	was_bearer = false
	if twist != "":
		_tell("%s %d판: %s" % [TWISTS[twist][0], rnd, TWISTS[twist][1]], "%s, round %d: %s" % [TWISTS_EN[twist][0], rnd, TWISTS_EN[twist][1]], 2.4)
	else:
		_tell("%s: %s" % [cdef.name, cdef.say], "%s: %s" % [COURSES_EN[ci][0], COURSES_EN[ci][1]], 2.4)
	beep(440.0, 0.12)


func _put_parcel(at: Vector2, who: Courier) -> void:
	for pc in parcels:
		if not pc.on:
			pc.on = true
			pc.p = at
			pc.owner = who
			pc.cd = 0.8 if who else 0.0
			var n: Node3D = pc.node
			n.visible = true
			n.position = Vector3(at.x, at.y + 0.25, 0)
			return


func _step(dt: float) -> void:
	shk = maxf(shk - dt * 2.5, 0.0)
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.7 and pt <= 0.7:
				_sfx("go")
			if pt <= 0.0:
				phase = "race"
				_stamp("배송 출발", "OUT FOR DELIVERY", ST_INK, null, 0.6)
				play("good")
		"race":
			rt += dt
			journey_time += dt
			course_time += dt
			_race(dt)
		"roundend":
			pt -= dt
			if pt <= 0.0:
				_after_round()
		"perk":
			for n in ["jump", "drop"]:
				if kit_just(n):
					_pick_perk(n)
					break
		"mode":
			if kit_just("lang"):
				_set_lang("en" if lang == "ko" else "ko")
				play("good")
			for n in ["jump", "drop", "mode_over"]:
				if kit_just(n):
					_pick_mode(n)
					break
		"route":
			for n in ["jump", "drop"]:
				if kit_just(n):
					_pick_route(n)
					break
	_update_parcels(dt)
	if mode == "lantern" and phase != "mode":
		_pass_lantern()
		_lantern(dt)
		_lights()
	_camera(dt)
	_draw_all()
	if mode_l:
		mode_l.text = L("세 가지 배달 · 버튼을 눌러 선택", "Three deliveries · tap one") if phase == "mode" else L("%s · %s %d판 · 짐 %d", "%s · %s · R%d · Box %d") % [_mode_name(mode), L("마지막 배달", "Final Delivery") if finale else _cname(ci), rnd, pl.cargo]
	_update_content_hud()
	if phase != "perk" and phase != "route" and phase != "mode" and _btns.has("drop"):
		_btns["drop"].label = L("짐 %d", "Box %d") % pl.cargo


func _race(dt: float) -> void:
	pl.mx = kit_move.x
	pl.i_jump = kit_just("jump")
	pl.i_jheld = kit_held("jump")
	pl.i_drop = kit_just("drop")
	if cdef.rule == "dark" and mode != "lantern":
		_dark(dt)
	for r in runners:
		if r.alive and r.ai:
			_ai(r, dt)
	_slipstream()
	_mechanisms(dt)
	for r in runners:
		if r.alive:
			_runner(r, dt)
	_pickups()
	if not trains.is_empty():
		_trains(dt)
	if not boards.is_empty():
		_boards(dt)
	if phase != "race":
		return
	# 화면 왼쪽 끝: 짐이 있으면 하나 내주고 버틴다, 없으면 탈락
	var left := camx - hwv
	for r in runners:
		if not r.alive:
			continue
		if r.p.y < kill_y or r.p.y < camy - vhv - 1.0:
			_out(r, "분실", "MISSING")
		elif _opening() and r.p.x + HW < left + 0.15:
			r.p.x = left + 1.0
		elif r.p.x + HW < left + 0.15:
			if r.immune > 0.0 and r.p.x + HW > left - 2.0:
				pass
			elif r.cargo > 0 and r.immune <= 0.0:
				_shove(r, left)
			else:
				_out(r, "반송", "RETURN TO SENDER")
	if mode == "lantern":
		_fog_check(dt)
	if phase != "race":
		return
	for r in runners:
		if r.alive and r.p.x > goal_x:
			if r.cargo > 0:
				_round_over(r)
				return
			_out(r, "빈손 실격", "EMPTY HANDED")
	if not pl.alive:
		var w: Courier = null
		for r in runners:
			if r.alive and (w == null or r.p.x > w.p.x):
				w = r
		_round_over(w)
		return
	# 마지막 생존자도 짐을 들고 결승까지 배달해야 한다. 응용 구간을 건너뛰지 않는다.
	# 1등이면 빠를수록 화면이 쏠린다: 앞이 안 보이니 벽·구덩이는 소리로만
	radar_t -= dt
	if mode == "lantern":
		_lantern_hud(dt)
	elif _leader() == pl:
		if lead_t == 0.0:
			_stamp("1등석", "FIRST CLASS", ST_GOOD)
			_tell_once("lead", "선두는 빠를수록 앞 시야가 짧다", "In the lead, speed shortens your view")
			beep(900.0, 0.1, 1400.0, 0.2)
		lead_t += dt
		if lean > 0.35 and pl.grounded:
			var ax := pl.p.x + HW + 2.2
			var pit := _floor_top(ax, pl.p.y + 0.6) < pl.p.y - 2.0
			var wall := _solid_in(Rect2(pl.p.x + HW + 0.6, pl.p.y + STEP + 0.05, 3.5, 0.9), pl)
			if (pit or wall) and radar_t <= 0.0:
				radar_t = 0.22
				beep(240.0 if pit else 420.0, 0.05, 0.0, 0.18)
	else:
		lead_t = 0.0
	# 화면 끝 압박 (등불 모드에서 빛 밖이면 길 잃기 압박)
	var ed := pl.p.x - left
	if mode == "lantern" and pl.lost > 0.0:
		var safe := 1.0 - pl.lost / LOST_T
		gauge(safe, A if safe > 0.4 else BAD)
	else:
		gauge(ed / (hwv * 2.0), GOOD if ed > hwv * 0.6 else (A if ed > 2.5 else BAD))
	if ed < 1.6:
		danger = true
	elif danger and ed > 4.0:
		danger = false
		_close(pl)
	tick -= dt
	if ed < 3.5 and tick <= 0.0:
		tick = 0.08 + ed * 0.07
		beep(1200.0 - ed * 150.0, 0.04, 0.0, 0.14)
	gate_said = maxf(gate_said - dt, 0.0)
	var wi := pl.alive and _in_wind(pl)
	if wi and not wind_in:
		beep(320.0, 0.4, 160.0, 0.2)
		_stamp("맞바람", "HEADWIND", ST_INK)
		_tell_once("wind", "맞바람. 앞사람 뒤에 붙으면 바람이 없다", "Headwind. Tuck in behind someone")
	wind_in = wi
	var on_ice := pl.grounded and pl.sup == 5
	if on_ice and not was_ice:
		beep(1500.0, 0.18, 700.0, 0.16)
		_stamp("취급 주의", "HANDLE WITH CARE", ST_INK)
	was_ice = on_ice
	if pl.slip and not was_slip:
		beep(700.0, 0.12, 1000.0, 0.12)
		_stamp("바람막이", "SLIPSTREAM", ST_GOOD)
	was_slip = pl.slip


## 야시장: 6초마다 1.6초 정전. 꺼지면 1등 앞이 모두에게 가려진다
func _dark(dt: float) -> void:
	dark_t += dt
	var cyc := fmod(dark_t, 6.0)
	var warn := cyc > 3.6 and cyc < 4.4
	var now := cyc >= 4.4
	if warn and not dark_warn:
		beep(520.0, 0.08, 0.0, 0.16)
	if warn and fmod(cyc, 0.2) < dt:
		beep(520.0, 0.04, 0.0, 0.1)
	if now and not dark_on:
		beep(180.0, 0.35, 90.0, 0.25)
		_stamp("정전", "BLACKOUT", ST_INK)
	elif dark_on and not now:
		beep(660.0, 0.1, 990.0, 0.18)
	dark_warn = warn
	dark_on = now


## 건널목: 기차는 선로 오른쪽 끝(벽 속)에서 나와 왼쪽으로 달린다. 종이 울리고 1초 뒤 출발.
## 2등은 화면 오른쪽에서 오는 기차가 보이지만, 빨리 달리는 1등은 화면이 쏠려 종소리만 듣는다.
func _trains(dt: float) -> void:
	var tm := Time.get_ticks_msec() * 0.001
	for tr in trains:
		var near: bool = pl.alive and pl.p.x > tr.x0 - 14.0 and pl.p.x < tr.x1 + 4.0
		match tr.st:
			"wait":
				tr.t -= dt
				if tr.t <= 1.1:
					tr.st = "warn"
					if near:
						_stamp("건널목", "CROSSING", ST_BAD)
			"warn":
				tr.t -= dt
				if near and fmod(tm, 0.3) < dt:
					if fmod(tm, 0.6) < dt:
						_sfx("bell", null, -4.0)
				if tr.t <= 0.0:
					tr.st = "run"
					tr.x = tr.x1 + 2.0
					if near:
						_sfx("train")
			"run":
				tr.x -= TRAIN_V * dt
				if tr.x + TRAIN_L < tr.x0 - 1.0:
					tr.st = "wait"
					tr.t = randf_range(2.2, 4.5)
					tr.x = tr.x1 + 2.0
				else:
					var hit := Rect2(tr.x, tr.y, TRAIN_L, TRAIN_H)
					for r in runners:
						if r.alive and r.immune <= 0.0 and hit.intersects(_box(r)):
							_train_hit(r)
		(tr.node as Node3D).position.x = tr.x
		var lit: bool = tr.st != "wait" and fmod(tm, 0.3) < 0.15
		if lit != tr.lit:
			tr.lit = lit
			(tr.lamp as MeshInstance3D).material_override = mat(BAD if lit else WHITE)


func _train_hit(r: Courier) -> void:
	var k := knock_mul if r == pl else 1.0
	r.v = Vector2(-17.0 * k, 7.0)
	r.stun = 0.55 * k
	r.immune = 0.9
	r.grounded = false
	r.sq = -0.4
	_burst(Vector3(r.p.x, r.p.y + 0.8, 0.6), 6, PARCEL if r.cargo > 0 else r.col)
	_sfx("damaged", r)
	if r == pl:
		shk = 0.6
	if r.cargo > 0:
		r.cargo -= 1
		if r == pl:
			_stamp("운송 사고", "LOST IN TRANSIT", ST_BAD)
	else:
		_out(r, "운송 사고", "LOST IN TRANSIT")


## 흔들다리: 무게 BREAK_W 이상으로 밟은 판은 금이 가고 BREAK_T 뒤 떨어진다
func _crack(i: int, r: Courier) -> void:
	var bd: Dictionary = board_of.get(i, {})
	if bd.is_empty() or bd.t >= 0.0:
		return
	bd.t = 0.0
	(bd.node as MeshInstance3D).material_override = mat(CRACK)
	_snd(r, 330.0, 0.06, 200.0, 0.14)
	if r == pl and not bridge_said:
		bridge_said = true
		_stamp("중량 초과", "OVERWEIGHT", ST_BAD)
		_tell_once("bridge", "무거우면 밟은 판이 무너진다", "Too heavy: planks give way under you")


func _boards(dt: float) -> void:
	for bd in boards:
		if bd.t < 0.0:
			continue
		var bn: MeshInstance3D = bd.node
		var home: Vector3 = bd.home
		if not bd.gone:
			bd.t += dt
			bn.position.x = home.x + sin(bd.t * 70.0) * 0.06
			if bd.t >= BREAK_T:
				bd.gone = true
				kinds[bd.i] = -1
				bd.vy = 0.0
				if absf(home.x - camx) < hwv + 2.0:
					_sfx("crack", null, -3.0)
					_burst(home, 2, BOARD)
		elif bn.visible:
			bd.vy -= GRAV * dt
			bn.position.y += bd.vy * dt
			bn.rotation.z += dt * 2.5
			if bn.position.y < home.y - 14.0:
				bn.visible = false


## 작은 상자 파편 (미리 만든 것을 돌려 쓴다)
func _burst(at: Vector3, n: int, c: Color) -> void:
	for k in n:
		var b: Dictionary = bits[bit_i]
		bit_i = (bit_i + 1) % bits.size()
		var m: MeshInstance3D = b.node
		m.visible = true
		m.position = at
		m.material_override = mat(c)
		b.v = Vector3(randf_range(-5.0, 5.0), randf_range(3.0, 9.0), randf_range(-1.0, 2.0))
		b.life = randf_range(0.4, 0.7)


func _shove(r: Courier, left: float) -> void:
	r.cargo -= 1
	r.immune = 0.7
	_mx(r, left + HW + 0.6 - r.p.x)
	r.v.x = maxf(r.v.x, 8.0)
	_sfx("damaged", r)
	_burst(Vector3(r.p.x - 0.5, r.p.y + 1.0, 0.6), 3, PARCEL)
	r.sq = -0.35
	if r == pl:
		shk = maxf(shk, 0.35)
		if r.cargo > 0:
			_stamp("파손", "DAMAGED", ST_BAD)
		else:
			_stamp("마지막 짐", "LAST PARCEL", ST_BAD)


func _out(r: Courier, ko: String, en: String) -> void:
	r.alive = false
	r.node.visible = false
	r.poof.visible = true
	r.poof_t = 0.5
	r.poof.position = Vector3(clampf(r.p.x, camx - hwv + 0.6, camx + hwv), maxf(r.p.y, camy - vhv + 2.0), 0.5)
	_burst(r.poof.position, 5, r.col)
	if r == pl:
		_sfx("returned")
		shk = 0.6
		_stamp(ko, en, ST_BAD, null, 1.2)
	else:
		_sfx("returned", r)
		shk = maxf(shk, 0.25)
		_stamp("%s 배송 취소" % r.nick, "%s CANCELLED" % r.nick_en.to_upper(), ST_INK, r)


func _round_over(w: Courier) -> void:
	phase = "roundend"
	pt = 1.8
	curtain.visible = false
	# 순위를 기억해 다음 판 출발 줄로 쓴다 (살아남은 쪽, 앞선 쪽이 앞)
	grid = runners.duplicate()
	grid.sort_custom(func(a, b): return (a.alive and not b.alive) or (a.alive == b.alive and a.p.x > b.p.x))
	if w != null:
		grid.erase(w)
		grid.push_front(w)
	if finale:
		_finish(w == pl)
		return
	if w == null:
		_stamp("미배달", "UNDELIVERED", ST_INK, null, 1.4)
		return
	w.wins += 1
	if w == pl:
		delivered += pl.cargo
		score += 10 + 5 * pl.cargo
		play("win")
		_stamp("배달 완료 · %d" % pl.cargo, "DELIVERED · %d" % pl.cargo, ST_GOOD, null, 1.4)
	else:
		_sfx("lost")
		_stamp("%s 먼저 도착" % w.nick, "%s ARRIVED FIRST" % w.nick_en.to_upper(), ST_BAD, w, 1.4)


func _after_round() -> void:
	if pl.wins >= WINS:
		score += 50
		_record_course()
		if ci >= COURSES.size() - 1:
			_start_finale()
			return
		play("win")
		var pool := []
		for k in PERKS:
			if not taken.has(k):
				pool.append(k)
		pool.shuffle()
		perk_offer = pool.slice(0, 2)
		_btns["jump"].label = _perk(perk_offer[0])
		_btns["drop"].label = _perk(perk_offer[1])
		phase = "perk"
		return
	for r in runners:
		if r.ai and r.wins >= WINS:
			_stamp("%s 노선 차지" % r.nick, "%s TOOK THE ROUTE" % r.nick_en.to_upper(), ST_BAD, r, 1.4)
			_finish(false)
			return
	# 다음 판 길 고르기: 방금 달린 변주 말고 둘 중 하나 (내 짐 수가 답을 바꾼다)
	var routes := []
	for k in TWISTS:
		if k != twist:
			routes.append(k)
	routes.shuffle()
	route_offer = routes.slice(0, 2)
	_btns["jump"].label = _tw(route_offer[0], 0)
	_btns["drop"].label = _tw(route_offer[1], 0)
	phase = "route"


func _pick_route(n: String) -> void:
	twist = route_offer[0 if n == "jump" else 1]
	play("good")
	_restore_labels()
	_kit_clear()
	_build_course()
	_start_round()


func _pick_perk(n: String) -> void:
	var k: String = perk_offer[0 if n == "jump" else 1]
	taken.append(k)
	match k:
		"신발": spd_mul += 0.08
		"끈": load_bonus += 1
		"용수철": jump_mul += 0.12
		"바람": slip_mul = 2.0
		"가벼운 상자": load_w = 0.6
		"단단한 몸": knock_mul = 0.5
	play("good")
	_stamp("특전 받음", "UPGRADED", ST_GOOD, null, 1.0)
	_tell("%s: %s" % [k, PERK_SAY[k]], "%s: %s" % [PERK_EN[k][0], PERK_EN[k][1]], 2.0)
	_restore_labels()
	_kit_clear()
	ci += 1
	course_time = 0.0
	rnd = 0
	twist = ""
	fresh = true
	for r in runners:
		r.wins = 0
	_build_course()
	_start_round()


func _restore_labels() -> void:
	if _btns.has("jump"):
		_btns["jump"].label = L("점프", "Jump")
		_btns["drop"].label = L("짐", "Box")


# ---- 달리기 한 명 ----
func _weight(r: Courier) -> float:
	return r.cargo * (1.0 if r.ai else load_w)


func _top(r: Courier) -> float:
	var top := RUN_MAX * (r.skill if r.ai else spd_mul) * (1.0 - LOAD_SLOW * _weight(r))
	if r.slip:
		top *= 1.0 + 0.12 * (1.0 if r.ai else slip_mul)
	elif _in_wind(r):  # 맞바람: 무거우면 덜 밀린다, 앞사람 뒤(바람 타기)면 바람이 없다
		top *= 1.0 - WIND_K * clampf(1.0 - 0.13 * _weight(r), 0.0, 1.0)
	return top


func _in_wind(r: Courier) -> bool:
	for g in gusts:
		if r.p.x > g.x and r.p.x < g.y:
			return true
	return false


func _jump_v(r: Courier) -> float:
	return (24.0 if _overpowered(r) else JUMP_V) * (1.0 if r.ai else jump_mul) * (1.0 - LOAD_JUMP * _weight(r))


func _runner(r: Courier, dt: float) -> void:
	r.immune = maxf(r.immune - dt, 0.0)
	r.drop_cd = maxf(r.drop_cd - dt, 0.0)
	var top := _top(r)
	var up := r.slope * signf(r.v.x)  # + 오르막, - 내리막
	if r.grounded and up > 0.0:
		top *= maxf(1.0 - up * (0.5 + 0.1 * _weight(r)), 0.35)
	elif r.grounded and up < 0.0:
		top *= 1.0 - up * 0.3
	var mx := r.mx
	if r.stun > 0.0:
		r.stun -= dt
		mx = 0.0
		r.i_jump = false
		r.i_drop = false
	if r.i_drop and r.cargo > 0 and r.drop_cd <= 0.0:
		_drop(r)
	r.coyote = COYOTE if r.grounded else maxf(r.coyote - dt, 0.0)
	r.jbuf = JBUF if r.i_jump else maxf(r.jbuf - dt, 0.0)
	if r.jbuf > 0.0 and r.coyote > 0.0:
		r.v.y = _jump_v(r)
		r.coyote = 0.0
		r.jbuf = 0.0
		r.grounded = false
		r.cut = false
		r.sq = -0.3
		_sfx("jump", r, -2.0)
	if not r.cut and r.v.y > 0.0 and not r.i_jheld:
		r.v.y *= 0.5
		r.cut = true
	var ice := r.grounded and r.sup == 5
	var acc := (GROUND_ACC if r.grounded else AIR_ACC) * (1.3 if r.slip else 1.0) * (0.2 if ice else 1.0)
	if absf(mx) > 0.15:
		var want := mx * top
		if signf(r.v.x) != signf(mx) or absf(r.v.x) < absf(want):
			r.v.x = move_toward(r.v.x, want, acc * dt)
		elif not ice:
			r.v.x = move_toward(r.v.x, want, (OVER_G if r.grounded else OVER_A) * dt)
		r.face = signf(mx)
	elif not ice:
		r.v.x = move_toward(r.v.x, 0.0, (FRICTION if r.grounded else 4.0) * dt)
	if ice:  # 얼음 내리막: 저절로 앞으로 미끄러진다, 짐이 무거울수록 세고 빠르다
		var cap := RUN_MAX * (1.2 + 0.07 * _weight(r))
		if r.v.x < cap:
			r.v.x = minf(r.v.x + (4.0 + 1.8 * _weight(r)) * dt, cap)
	if r.dash > 0.0:
		r.dash -= dt
		r.v.x = maxf(r.v.x, 32.0 if _overpowered(r) else DASH_V)
	if r.grounded and up > 0.0:  # 오르막: 딱 멈추지 않고 경사·짐만큼 깎인다
		r.v.x = move_toward(r.v.x, 0.0, RAMP_DRAG * up * (1.0 + 0.2 * _weight(r)) * dt)
	r.v.y = maxf(r.v.y - GRAV * dt, -MAX_FALL)
	# 흐르는 바닥: 짐이 무거울수록 덜 밀린다
	if r.grounded and r.sup == 3:
		_mx(r, -FLOW * clampf(1.0 - 0.15 * _weight(r), 0.2, 1.0) * dt)
	var was_g := r.grounded
	var vy0 := r.v.y
	for s in 2:
		_mx(r, r.v.x * dt * 0.5)
		_my(r, r.v.y * dt * 0.5)
	_probe(r)
	_on_ramp(r, was_g)
	if r.grounded and not was_g and vy0 < -6.0:
		r.sq = clampf(-vy0 / 40.0, 0.15, 0.5)
		_sfx("land", r, -6.0 + clampf(-vy0 / 6.0, 0.0, 6.0))
		if vy0 < -15.0 and absf(r.p.x - camx) < hwv + 2.0:
			_burst(Vector3(r.p.x, r.p.y + 0.1, 0.6), 2, cdef.top)
	r.sq = move_toward(r.sq, 0.0, dt * 2.5)
	if r.grounded and r.sup == 1:
		r.v.y = PAD_V * (1.0 - LOAD_JUMP * _weight(r))
		r.grounded = false
		r.cut = true
		_sfx("spring", r)
		if r == pl:
			shk = maxf(shk, 0.2)


## 짐 하나를 뒤에 내려놓고 튀어나간다 (다른 사람이 주워 갈 수 있다)
func _drop(r: Courier) -> void:
	r.cargo -= 1
	r.drop_cd = 0.4
	r.dash = DASH_T
	r.v.x = maxf(r.v.x, 32.0 if _overpowered(r) else DASH_V)
	var x := r.p.x - r.face * 1.2
	var y := _floor_top(x, r.p.y + 0.5)
	if y > r.p.y - 6.0:
		_put_parcel(Vector2(x, y), r)
	_sfx("express", r)
	if r == pl:
		shk = maxf(shk, 0.15)
		_stamp("속달", "EXPRESS", ST_GOOD)


func _box(r: Courier) -> Rect2:
	return Rect2(r.p.x - HW, r.p.y, HW * 2.0, HH)


## 이 상자가 r을 막는가 (낮은 문틀은 짐이 많을 때만)
func _hard(i: int, r: Courier) -> bool:
	var k := kinds[i]
	if k < 0:
		return false
	if k == 7:
		return mechanisms[shutter_of[i]].t < 0.75
	if k == 6:
		return r != null and r.cargo > GATE_MAX
	return k != 8  # 경사로는 상자로 막지 않고 _on_ramp가 윗면에 올린다


## 경사로 i의 x 위 윗면 높이
func _ramp_y(i: int, x: float) -> float:
	var q: Rect2 = rects[i]
	var t := clampf((x - q.position.x) / q.size.x, 0.0, 1.0)
	if ramp_of[i] < 0:
		t = 1.0 - t
	return q.position.y + q.size.y * t


## 경사로 윗면에 발을 붙인다 (오르막은 밀려 올라가고, 내리막은 떨어지지 않고 따라 내려간다)
func _on_ramp(r: Courier, was_g: bool) -> void:
	r.slope = 0.0
	if r.v.y > 0.5:
		return
	var best := -1.0e9
	var bi := -1
	for i in buckets[_bi(r.p.x)]:
		if kinds[i] != 8:
			continue
		var q: Rect2 = rects[i]
		if r.p.x < q.position.x or r.p.x > q.end.x:
			continue
		var sy := _ramp_y(i, r.p.x)
		if r.p.y <= sy + (0.35 if was_g else 0.02) and r.p.y >= sy - 0.9 and sy > best:
			best = sy
			bi = i
	if bi < 0 or (r.grounded and best < r.p.y - 0.02):
		return
	r.p.y = best
	r.v.y = 0.0
	r.grounded = true
	r.sup = 0
	var q: Rect2 = rects[bi]
	r.slope = ramp_of[bi] * q.size.y / q.size.x


func _mx(r: Courier, dx: float) -> void:
	if dx == 0.0:
		return
	r.p.x += dx
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			if not _hard(i, r):
				continue
			var q: Rect2 = rects[i]
			if not q.intersects(a):
				continue
			if kinds[i] == 6 and r == pl and gate_said <= 0.0:
				gate_said = 1.2
				_stamp("규격 초과", "OVERSIZE", ST_BAD)
				_tell("낮은 문은 짐 %d개까지만 지나간다" % GATE_MAX, "Only %d boxes fit under the gate" % GATE_MAX)
				_sfx("gate")
			if r.grounded and q.end.y - r.p.y <= STEP:
				r.p.y = q.end.y
				a = _box(r)
				continue
			if dx > 0.0:
				r.p.x = q.position.x - HW - 0.001
			else:
				r.p.x = q.end.x + HW + 0.001
			if absf(r.v.x) > 12.0:
				_sfx("bump", r, -2.0)
				r.sq = -0.3
				if r == pl:
					_burst(Vector3(r.p.x + HW, r.p.y + 0.8, 0.6), 2, cdef.wall)
					shk = maxf(shk, 0.3)
			if _overpowered(r) and absf(r.v.x) > 20.0:
				r.v.x *= -0.25
				r.stun = 0.4
				r.dash = 0.0
				if r == pl:
					_stamp("반송됨", "RETURNED", ST_BAD)
					_tell_once("overwall", "벽 앞에서는 가속을 참아라", "Ease off the boost before walls")
			elif signf(r.v.x) == signf(dx):
				r.v.x = 0.0
			a = _box(r)


func _my(r: Courier, dy: float) -> void:
	if dy == 0.0:
		return
	r.p.y += dy
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			if not _hard(i, r):
				continue
			var q: Rect2 = rects[i]
			if q.intersects(a):
				if dy < 0.0:
					r.p.y = q.end.y
					r.v.y = 0.0
				else:
					r.p.y = q.position.y - HH - 0.001
					if _overpowered(r) and r.v.y > 3.0:
						r.v.x = minf(maxf(r.v.x, 8.0) * 1.3, 34.0)
						r.stun = 0.18
						_sfx("spring", r)
						if r == pl:
							_stamp("항공편", "AIR MAIL", ST_GOOD)
					r.v.y = minf(r.v.y, 0.0)
				a = _box(r)


func _probe(r: Courier) -> void:
	var f := Rect2(r.p.x - HW + 0.05, r.p.y - 0.06, HW * 2.0 - 0.1, 0.07)
	r.grounded = false
	r.sup = -1
	var pad := false
	var flow := false
	var ice := false
	for b in range(_bi(f.position.x), _bi(f.end.x) + 1):
		for i in buckets[b]:
			if kinds[i] < 0 or kinds[i] == 6 or kinds[i] == 7 or kinds[i] == 8:
				continue
			var q: Rect2 = rects[i]
			if q.intersects(f) and q.end.y <= r.p.y + 0.02:
				r.grounded = true
				pad = pad or kinds[i] == 1
				flow = flow or kinds[i] == 3
				ice = ice or kinds[i] == 5
				if kinds[i] == 4 and _weight(r) >= BREAK_W:
					_crack(i, r)
	if r.grounded:
		r.sup = 1 if pad else (3 if flow else (5 if ice else 0))


## x 위에서 높이 ymax 아래 가장 높은 바닥 윗면 (없으면 아주 낮은 수)
func _floor_top(x: float, ymax: float) -> float:
	var best_y := -1.0e9
	for i in buckets[_bi(x)]:
		if kinds[i] < 0 or kinds[i] == 6 or kinds[i] == 7:
			continue
		var q: Rect2 = rects[i]
		var top := _ramp_y(i, x) if kinds[i] == 8 else q.end.y
		if x > q.position.x and x < q.end.x and top <= ymax:
			best_y = maxf(best_y, top)
	return best_y


func _solid_in(a: Rect2, r: Courier = null) -> bool:
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			if not _hard(i, r):
				continue
			var q: Rect2 = rects[i]
			if q.intersects(a):
				return true
	return false


func _snd(r: Courier, f: float, d: float, to := 0.0, vol := 0.18) -> void:
	if r == pl:
		beep(f, d, to, vol)
	elif r.alive and absf(r.p.x - camx) < hwv:
		beep(f, d, to, vol * 0.45)


func _close(r: Courier) -> void:
	r.v.x += 3.0
	beep(1000.0, 0.1, 1600.0, 0.22)
	_stamp("지연 직전", "LATE?", ST_INK)
	shk = maxf(shk, 0.15)


func _slipstream() -> void:
	for r in runners:
		r.slip = false
		if not r.alive:
			continue
		for o in runners:
			if o == r or not o.alive:
				continue
			var dx := o.p.x - r.p.x
			if dx > 0.8 and dx < 4.5 and absf(o.p.y - r.p.y) < 1.5:
				r.slip = true
				break


func _pickups() -> void:
	for pc in parcels:
		if not pc.on:
			continue
		var cp: Vector2 = pc.p
		for r in runners:
			if not r.alive or (r == pc.owner and pc.cd > 0.0):
				continue
			if r.cargo >= LOAD_MAX + (0 if r.ai else load_bonus):
				continue
			if absf(r.p.x - cp.x) < 0.8 and r.p.y - cp.y > -0.6 and r.p.y - cp.y < HH:
				r.cargo += 1
				pc.on = false
				(pc.node as Node3D).visible = false
				_sfx("pickup", r)
				if r == pl:
					_stamp("수령", "RECEIVED", ST_GOOD)
				break


func _update_parcels(dt: float) -> void:
	for pc in parcels:
		if pc.on:
			pc.cd = maxf(pc.cd - dt, 0.0)
			(pc.node as Node3D).rotation.y += dt * 1.5


func _leader() -> Courier:
	var w: Courier = null
	for r in runners:
		if r.alive and (w == null or r.p.x > w.p.x):
			w = r
	return w


# ---- 경쟁자 ----
## 지금 짐으로 뛸 수 있는 거리
func _reach(r: Courier) -> float:
	return _top(r) * 2.0 * _jump_v(r) / GRAV


## 앞 구덩이 너비 (없으면 0)
func _gap_len(r: Courier) -> float:
	var x := r.p.x + HW
	var start := -1.0
	for k in 24:
		var gtop := _floor_top(x, r.p.y + 0.6)
		if gtop < r.p.y - 2.0:
			if start < 0.0:
				start = x
		elif start >= 0.0:
			return x - start
		x += 0.4
	return 0.0 if start < 0.0 else 9.0


func _track_at(x: float) -> Dictionary:
	for tr in trains:
		if x > tr.x0 - 1.0 and x < tr.x1:
			return tr
	return {}


func _ai(r: Courier, dt: float) -> void:
	r.mx = 1.0
	if _opening() and r.p.x > pl.p.x + 2.0:
		r.mx = 0.0
	if mode == "lantern" and r == bearer and goal_x - r.p.x > 40.0:
		r.mx = lerpf(0.5, 1.0, r.bold)  # 등불을 들면 대담한 만큼만 달린다
	r.i_jump = false
	r.i_drop = false
	r.i_jheld = true
	r.think -= dt
	if r.think > 0.0:
		return
	r.think = randf_range(0.04, 0.1) / r.skill
	var look := 0.8 + absf(r.v.x) * 0.12
	var ax := r.p.x + HW + 0.25 + absf(r.v.x) * 0.035
	var pit := _floor_top(ax, r.p.y + 0.6) < r.p.y - 2.0
	var wall := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, look, 0.9))
	# 경쟁자도 1등이면 빠를수록 못 보고, 정전이면 못 본다
	var miss := r.err
	if mode == "lantern":
		# 빛 안이면 잘 보고, 안개 속이면 거의 못 본다. 등불을 들면 대담한 만큼만 달린다
		if not _lit(ax + 1.0):
			miss = 0.7
	elif _leader() == r:
		miss += 0.4 * clampf((absf(r.v.x) - 4.0) / (RUN_MAX - 4.0), 0.0, 1.0)
	if dark_on:
		miss += 0.3
	# 건널목: 선로로 내려갈 경쟁자는 승강장 틈을 일부러 안 넘는다
	var tr := _track_at(r.p.x)
	if pit and r.dive and not tr.is_empty() and r.p.y > tr.y + 1.0 and ax < tr.x1 - 5.0:
		pit = false
	if r.grounded and (pit or wall) and randf() > miss:
		r.i_jump = true
	# 선로 위: 보이면 기차를 뛰어넘는다 (1등이면 잘 못 본다)
	if not tr.is_empty() and tr.st == "run" and r.grounded and r.p.y < tr.y + 0.5:
		var gap: float = tr.x - (r.p.x + HW)
		if gap > 0.5 and gap < 4.5 and randf() > miss + 0.15:
			r.i_jump = true
	# 흔들다리: 무거우면 다리 앞에서 짐 하나를 버리기도 한다
	if cdef.rule == "bridge" and r.grounded and _weight(r) >= BREAK_W and r.cargo >= 2 and r.drop_cd <= 0.0:
		var ahead := r.p.x + HW + 1.5
		for i in buckets[_bi(ahead)]:
			if kinds[i] == 4 and rects[i].position.x > r.p.x and rects[i].position.x < ahead + 1.0 and randf() < 0.5:
				r.i_drop = true
				break
	# 낮은 문: 짐이 많으면 문 앞에서 버린다 (1등이면 늦게 알아채고 걸린다)
	if r.cargo > GATE_MAX and r.drop_cd <= 0.0:
		for gp in gates:
			var d: float = gp - (r.p.x + HW)
			if d > -0.2 and d < 3.5 and (d < 0.4 or randf() > miss):
				r.i_drop = true
				break
	# 짐 버리기: 먼 틈 앞, 또는 화면 끝에 몰렸을 때
	if r.cargo >= 2 and r.drop_cd <= 0.0:
		var far: bool = r.grounded and _gap_len(r) > _reach(r) * 0.95
		var behind := r.p.x - (camx - hwv) < 3.0
		if far or (behind and randf() < 0.25):
			r.i_drop = true


# ---- 카메라와 그리기 ----
## 화면 반폭 = 살아 있는 모두가 든 짐의 합 (출발 짐 12개 기준, 판 사이에 이어진다)
func _want_w() -> float:
	var all := 0
	for r in runners:
		if r.alive:
			all += r.cargo
	return lerpf(NARROW, WIDE, clampf(float(all) / float(LOAD0 * 4), 0.0, 1.0))


func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	var asp := vs.y / maxf(vs.x, 1.0)
	if phase == "race":
		# 화면 폭 = 모두가 든 짐의 합
		hwv = lerpf(hwv, _want_w(), 1.0 - exp(-1.5 * dt))
	vhv = hwv * asp
	var lead := _leader()
	if lead and phase != "perk":
		var k := 1.0 - exp(-9.0 * dt)
		# 내가 1등이면 내 속도만큼 화면이 앞으로 쏠려 나는 오른쪽 끝에 붙는다
		var f := 0.0
		if lead == pl and phase == "race" and mode != "lantern" and not _opening():
			f = clampf((absf(pl.v.x) - 4.0) / (RUN_MAX - 4.0), 0.0, 1.0)
		lean = lerpf(lean, f, 1.0 - exp(-3.0 * dt))
		var tx := lead.p.x
		if mode == "lantern" and bearer and bearer.alive:
			tx = lerpf(bearer.p.x, light_c, 0.3)  # 등불 모드: 화면은 등불 빛 쪽으로
		camx = lerpf(camx, tx - hwv * lerpf(-0.18, 0.32, lean), k)
		camy = lerpf(camy, lead.p.y + 2.0, 1.0 - exp(-4.0 * dt))
	cam.fov = rad_to_deg(2.0 * atan(hwv / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


func _draw_all() -> void:
	var tm := Time.get_ticks_msec() * 0.001
	for r in runners:
		r.poof.visible = r.poof_t > 0.0
		if r.poof_t > 0.0:
			r.poof_t -= get_process_delta_time()
			var s := 1.0 + (0.5 - r.poof_t) * 6.0
			r.poof.scale = Vector3(s, s, s)
		if not r.alive:
			for s2 in r.streaks:
				s2.visible = false
			for q in r.pips:
				q.visible = false
			continue
		var spd := absf(r.v.x)
		var bob := sin(tm * (8.0 + spd)) * 0.06 if r.grounded and spd > 1.0 else 0.0
		r.node.position = _fz(r.p.x, r.p.y + HH * 0.375 + bob)
		if mode == "lantern":
			r.node.scale = Vector3.ONE * ((CAM_D - ZR) / CAM_D)
		r.node.rotation.z = -clampf(r.v.x * 0.012, -0.2, 0.2)
		if r.art:
			r.art.rotation.y = 0.0 if r.face > 0.0 else PI
		r.node.visible = r.immune <= 0.0 or fmod(tm, 0.12) < 0.08
		if mode == "lantern" and r.lost > 0.3 and fmod(tm, 0.2) > 0.13:
			r.node.visible = false  # 길을 잃어 가면 깜빡인다
		for k in r.packs.size():
			var q := r.packs[k]
			q.visible = k < r.cargo
			q.position.x = -0.5 * r.face
		r.fire.visible = r.dash > 0.0
		r.fire.position.x = -0.9 * r.face
		r.fire.scale.x = 0.9 + sin(tm * 50.0) * 0.3
		var ln := clampf((spd - 10.0) * 0.6, 0.0, 4.0)
		for k in 3:
			var s3 := r.streaks[k]
			s3.visible = ln > 0.1
			if s3.visible:
				s3.material_override = mat(B if r.slip else WHITE)
				s3.scale = Vector3(ln * (1.0 - k * 0.2), 0.07, 0.07)
				s3.position = _fz(r.p.x - r.face * (HW + 0.3 + ln * 0.5 + k * 0.2), r.p.y + 0.25 + k * 0.35, 0.5)
		for k in r.pips.size():
			var q := r.pips[k]
			q.visible = k < r.wins
			q.position = _fz(r.p.x - 0.15 + k * 0.3, r.p.y + HH + 0.55)
	marker.visible = pl.alive
	marker.position = _fz(pl.p.x, pl.p.y + HH + 1.1 + sin(tm * 5.0) * 0.12)
	# 흐르는 바닥 눈금 (뒤로 흐른다)
	for fl in flows:
		var w: float = fl.w
		var x0: float = fl.x0
		var marks: Array = fl.marks
		if absf(x0 - camx) > hwv + w + 4.0:
			continue
		for m in marks.size():
			var mk: Node3D = marks[m]
			mk.position.x = x0 + 0.4 + fposmod(w * m / 3.0 - tm * FLOW, w - 0.8)
	var dt := get_process_delta_time()
	# 파편
	for b in bits:
		if b.life > 0.0:
			b.life -= dt
			var bv: Vector3 = b.v
			bv.y -= GRAV * 0.7 * dt
			b.v = bv
			var m: MeshInstance3D = b.node
			m.position += bv * dt
			m.rotation.z += dt * 9.0
			m.visible = b.life > 0.0
	# 구름 (천천히 흘러가며 원근으로 느리게 지나간다)
	var span := hwv * (CAM_D + 22.0) / CAM_D * 2.0 + 16.0
	for c in clouds:
		c.x -= dt * 0.7
		var m2: MeshInstance3D = c.node
		m2.position = Vector3(camx + fposmod(c.x - camx * 0.35, span) - span * 0.5, camy + c.y, -22.0)
	# 선두가 빠르면 화면을 가로지르는 바람 줄 (선두 속도만큼 빨리)
	var ld := _leader()
	var ls := absf(ld.v.x) if ld and phase == "race" else 0.0
	if wind_in and phase == "race":
		ls = maxf(ls, 15.0)  # 맞바람 구역: 바람 줄이 세게 지나간다
	wind_x += dt * ls * 2.2
	var wk := (CAM_D - 4.0) / CAM_D
	for k in winds.size():
		var w: MeshInstance3D = winds[k]
		w.visible = ls > 7.5
		if w.visible:
			var ww := hwv * wk * 2.0 + 6.0
			w.position = Vector3(camx + hwv * wk + 3.0 - fposmod(wind_x + k * 7.3, ww), camy + vhv * wk * (0.75 - k * 0.33), 4.0)
			w.scale = Vector3(1.0 + (ls - 7.5) * 0.6, 0.06, 0.06)
	_vis()
	_draw_lantern()
	if backdrop:
		backdrop.position = Vector3(camx * 0.94, camy * 0.94, -18.0)
	var k2 := (CAM_D - 1.6) / CAM_D
	# 정전: 1등 바로 앞부터 화면 오른쪽 끝까지 가린다
	var lead := _leader()
	curtain.visible = dark_on and phase == "race" and lead != null
	if curtain.visible:
		var l := camx + (lead.p.x + 1.2 - camx) * k2
		var rgt := camx + (hwv + 1.0) * k2
		if rgt > l:
			curtain.position = Vector3((l + rgt) * 0.5, camy, 1.6)
			curtain.scale = Vector3(rgt - l, vhv * 2.2, 0.2)
		else:
			curtain.visible = false
	# 왼쪽 화면 끝 경고 띠
	var ed := pl.p.x - (camx - hwv)
	edge_strip.visible = phase == "race" and pl.alive and (_opening() or (ed < 4.0 and (ed > 2.0 or fmod(tm, 0.16) < 0.1)))
	edge_strip.position = Vector3(camx - hwv * k2 + 0.18, camy, 1.6)
	edge_strip.scale = Vector3(0.35 + maxf(0.0, 4.0 - ed) * 0.1, vhv * 2.0, 0.2)


# ---- 밤 등불 모드 ----
## 등불 모드면 주자·표시를 안개 앞(ZR)에 같은 화면 자리로 옮겨 그린다
func _fz(x: float, y: float, z := 0.0) -> Vector3:
	if mode != "lantern":
		return Vector3(x, y, z)
	var k := (CAM_D - ZR) / CAM_D
	return Vector3(camx + (x - camx) * k, camy + (y - camy) * k, ZR)


## 맨 앞 주자가 0.5m 넘게 앞지르면 등불이 넘어간다. 든 사람이 탈락하면 다음 1등에게.
func _pass_lantern() -> void:
	var lead := _leader()
	if lead == null:
		return
	if bearer == null or not bearer.alive or (lead != bearer and lead.p.x > bearer.p.x + 0.5):
		var prev := bearer
		var had := bearer != null and bearer.alive
		bearer = lead
		if had and phase == "race":
			_snd(lead, 880.0, 0.08, 1320.0, 0.2)
			if lead != pl and prev != pl:
				_stamp("%s 가로챔" % lead.nick, "HIJACKED BY %s" % lead.nick_en.to_upper(), ST_INK, lead)


## 등불 든 사람이 빠를수록 빛이 뒤로 젖고 크게 흔들린다 (짐이 무거우면 느려서 덜 흔들린다)
func _lantern(dt: float) -> void:
	if bearer == null:
		return
	var f := 0.0
	if phase == "race" or phase == "roundend":
		f = clampf((absf(bearer.v.x) - 3.0) / (RUN_MAX - 3.0), 0.0, 1.0)
	lamp_lean = lerpf(lamp_lean, f, 1.0 - exp(-4.0 * dt))
	var amp := lerpf(0.4, 3.2, lamp_lean)
	swing_t += dt * lerpf(2.2, 8.0, lamp_lean)
	var sw := sin(swing_t) * amp
	light_c = bearer.p.x + lerpf(3.0, -4.0, lamp_lean) + sw
	# 흔들림 끝마다 삐걱 (빠를수록 박자가 빠르다)
	var sg := signf(cos(swing_t))
	if sg != swing_sign:
		swing_sign = sg
		if lamp_lean > 0.25 and phase == "race" and absf(bearer.p.x - camx) < hwv:
			beep(260.0 + lamp_lean * 260.0, 0.04, 0.0, 0.08 + lamp_lean * 0.06)


func _lights() -> void:
	lit.clear()
	if bearer and bearer.alive:
		lit.append(Vector2(light_c - LIGHT_R, light_c + LIGHT_R))


func _lit(x: float) -> bool:
	for iv in lit:
		if x >= iv.x and x <= iv.y:
			return true
	return false


## 빛 밖 안개에 LOST_T 있으면 짐 하나를 안개에 떨군다. 짐이 없으면 길을 잃고 탈락 (등불 든 사람은 빼고)
func _fog_check(dt: float) -> void:
	if rt < 2.0 or _opening():
		return  # 출발 직후는 줄이 길어 봐 준다
	for r in runners:
		if not r.alive:
			continue
		if r == bearer or _lit(r.p.x):
			r.lost = maxf(r.lost - dt * 1.5, 0.0)
			continue
		r.lost += dt
		if r.lost < LOST_T:
			continue
		r.lost = 0.0
		if r.cargo > 0:
			r.cargo -= 1
			_burst(Vector3(r.p.x - 0.5, r.p.y + 1.0, 0.6), 3, PARCEL)
			_sfx("damaged", r)
			if r == pl:
				shk = maxf(shk, 0.3)
				_stamp("분실", "MISPLACED", ST_BAD)
				_tell("안개에 짐 하나를 잃었다. 빛 안으로 돌아가라", "Lost a box in the fog. Back to the light", 1.6)
		else:
			_out(r, "주소 불명", "ADDRESS UNKNOWN")


func _lantern_hud(dt: float) -> void:
	if bearer == pl:
		hold_acc += dt
		if hold_acc >= 1.0:
			hold_acc -= 1.0
			score += 1
		if not was_bearer:
			_stamp("야간 배송", "NIGHT POST", ST_GOOD)
			_tell_once("lamp", "등불을 들고 빨리 달리면 앞이 안 보인다", "Run fast with the lantern, see less ahead")
			beep(990.0, 0.1, 1480.0, 0.24)
	elif was_bearer and pl.alive:
		_stamp("가로챔", "HIJACKED", ST_BAD)
		_tell("등불을 뺏겼다. 빛 안에 붙어라", "Lantern taken. Stay inside the light", 1.6)
		beep(500.0, 0.2, 260.0, 0.22)
	if pl.lost > 0.0 and radar_t <= 0.0:
		var safe := 1.0 - pl.lost / LOST_T
		radar_t = 0.08 + safe * 0.25
		beep(1100.0 - safe * 400.0, 0.04, 0.0, 0.15)
	was_bearer = bearer == pl


## 등불(든 사람 손에서 빛 쪽으로 기운다)과, 밝은 구간 사이를 덮는 안개 막 + 빛 끝 노란 선
func _draw_lantern() -> void:
	var on := mode == "lantern" and phase != "mode" and not _opening()
	lantern.visible = on and bearer != null and bearer.alive
	if lantern.visible:
		var lp := _fz(bearer.p.x + 0.3 * bearer.face, bearer.p.y + HH * 0.7)
		lp.z += 0.1
		lantern.position = lp
		lantern.scale = Vector3.ONE * ((CAM_D - ZR) / CAM_D)
		lantern.rotation.z = clampf(-(light_c - bearer.p.x) * 0.16, -1.1, 1.1)
	if not on:
		for m in fogs:
			m.visible = false
		for e in edges:
			e.visible = false
		return
	var kf := (CAM_D - ZF) / CAM_D
	var sl := camx - hwv - 2.0
	var sr := camx + hwv + 2.0
	var gaps: Array[Vector2] = []
	var x := sl
	var ei := 0
	for iv in lit:
		if iv.y < sl or iv.x > sr:
			continue
		if iv.x > x:
			gaps.append(Vector2(x, iv.x))
		x = maxf(x, iv.y)
		for ex in [iv.x, iv.y]:
			if ex > sl and ex < sr and ei < edges.size():
				var e := edges[ei]
				ei += 1
				e.visible = true
				e.position = Vector3(camx + (ex - camx) * kf, camy, ZF + 0.05)
				e.scale = Vector3(0.16, vhv * 2.6, 0.1)
	if x < sr:
		gaps.append(Vector2(x, sr))
	for k in range(ei, edges.size()):
		edges[k].visible = false
	for k in fogs.size():
		var m := fogs[k]
		m.visible = k < gaps.size()
		if m.visible:
			var l := camx + (gaps[k].x - camx) * kf
			var r := camx + (gaps[k].y - camx) * kf
			m.position = Vector3((l + r) * 0.5, camy, ZF)
			m.scale = Vector3(maxf(r - l, 0.01), vhv * 2.6, 0.1)
