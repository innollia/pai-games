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
const DASH_V := 32.0  # v13: 사용자가 실험판(대시 x2)에서 골랐다
const RUSH_DASH := 40.0  # 과속 모드 가벼울 때 대시 (기본 대시가 32가 돼 과속은 40으로 한 단계 위)
const DASH_T := 0.25
const HW := 0.4
const HH := 1.2
const BODY_H := 2.1  # courier model height on screen (visual only; collision stays HW/HH)
const VIS_K := 1.4  # carried parcels / ghosts scale with the bigger body (BODY_H / 1.5)
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
const LOAD0 := 8  # 판마다 출발 짐 (v13: 실험판 짐 x2를 사용자가 골랐다, 4 -> 8)
const LOAD_MAX := 10
const HEAVY_N := 6  # 무거운 쪽 규칙 (저울 위로): 짐 이만큼 이상 (v12 3 -> v13 6, 출발 짐 두 배)
const LIGHT_N := 4  # 가벼운 쪽 규칙 (상승풍·과속 가속): 짐 이만큼 이하 (v12 2 -> v13 4)
const PACK_K := 0.85  # 등 짐 더미 크기 (두 줄로 쌓는다, 최대 10개)
const MEDAL_GOT := 6  # 금메달: 2판 안에 이기고 이 코스에서 이만큼 배달 (v12 4 -> v13 6)
const LOAD_SLOW := 0.06  # 짐 하나당 최고 속도 감소
const LOAD_JUMP := 0.035  # 짐 하나당 점프 감소
const FLOW := 5.5  # 흐르는 바닥 속도 (뒤로)
const WINS := 2
const PARCEL := Color("D99B5B")
const NIGHT := Color("1B1F38")
const PERKS := ["신발", "끈", "용수철", "바람", "가벼운 상자", "단단한 몸"]
const PERK_SAY := {"신발": "더 빨리", "끈": "짐 하나 더", "용수철": "높이 뛰기", "바람": "바람 두 배", "가벼운 상자": "짐 무게 40% 덜", "단단한 몸": "치여도 덜 밀림"}
# English: same keys -> [button name, effect]
const PERK_EN := {"신발": ["Shoes", "run faster"], "끈": ["Strap", "carry 1 more"], "용수철": ["Spring", "jump higher"],
	"바람": ["Draft", "double slipstream"], "가벼운 상자": ["Light Box", "boxes 40% lighter"], "단단한 몸": ["Tough", "less knockback"]}
const TRAIN_V := 21.0  # 기차 속도 (왼쪽으로)
const TRAIN_L := 7.0
const TRAIN_H := 2.0
const TRENCH := 3.2  # 선로 도랑 깊이
const BREAK_W := 6.0  # 이 무게 이상이면 다리 판이 무너진다 (v13: 짐 두 배라 3 -> 6)
const BREAK_T := 0.42  # 금 간 판이 떨어지기까지
const BOARD := Color("E3BA88")
const CRACK := Color("E85244")
const GATE_MAX := 4  # 낮은 문: 짐 이만큼까지만 지나간다 (v13: 2 -> 4)
const GATE_H := 1.6
const ICE := Color("B1C9E1")  # BLUE lightened 0.6
const WIND_C := Color("77A0CB")  # BLUE lightened 0.3
const WIND_K := 0.45  # 맞바람에 깎이는 최고 속도 (가벼울 때)
# 판 변주: 구간 이름 -> [버튼 이름, 설명]
const TWISTS := {"gate": ["낮은 문", "짐 4개까지만 지나간다"], "slide": ["얼음 내리막", "못 멈춘다, 무거울수록 빠르다"],
	"wind": ["맞바람", "뒤에 붙으면 바람이 없다"]}
const TWISTS_EN := {"gate": ["Low Gate", "only 4 boxes or fewer fit"], "slide": ["Ice Slope", "no stopping, heavier is faster"],
	"wind": ["Headwind", "tuck in behind and it's calm"]}
# 밤 등불 모드
const NIGHT_SKY := Color("3D4156")  # NIGHT lightened 0.15
const FOG := Color("e4e8f7")
const GLOW := Color("FFD166")
const LIGHT_R := 5.0
const LOST_T := 1.5  # 빛 밖에서 이만큼 있으면 짐 하나를 잃는다 (없으면 탈락)
const ZR := 2.2  # 등불 모드: 주자는 안개 앞에 그린다
const ZF := 1.5  # 안개 막
const FOG_N := 6
const EDGE_N := 8
const MODES := {"base": "기본", "lantern": "밤 등불", "over": "과속 배달"}
const MODE_RULES := {"base": "우체통에 짐을 넣어라 · 1등은 앞이 안 보인다", "lantern": "빛 안의 우체통만 보인다 · 빛에 붙어라", "over": "짐 4개 이하: 천장 가속 / 벽 반동"}
const MODES_EN := {"base": "Classic", "lantern": "Lantern", "over": "Rush"}
const MODE_RULES_EN := {"base": "post boxes in mailboxes · the leader can't see ahead", "lantern": "mailboxes show only in the light", "over": "≤4 boxes: ceiling boost / wall bounce"}
const RECORDS := "user://screenrace_v12.cfg"  # v12: 배달 규칙이 바뀌어 기록·연습 완료를 새로 센다
const SrFront = preload("res://g/sr_front.gd")
const SrMenus = preload("res://g/sr_menus.gd")
const SR_HUD = preload("res://g/sr_hud.gd")
const MODE_KIT := {"base": "jump", "lantern": "drop", "over": "mode_over"}  # _pick_mode takes the old kit names
const KIT_PHASES := ["count", "race", "roundend", "tutorial"]  # the stick and buttons only work here
const BACK_ARM_PHASES := ["race", "count", "perk", "route", "roundend"]
const MARKER_PHASES := ["count", "tutorial"]  # the "you" pointer only finds you at the start; the blue courier does the rest
const SEG_RULES := {
	"flat": "우체통 앞에서 짐 버튼 = 배달",
	"stairs": "언덕: 짐이 무거우면 오르막이 느리다",
	"wall": "빨간 벽: 점프로 넘어야 안 느려진다", "pit": "빨간 틈: 끝에서 점프",
	"awning": "노란 발판: 위 지름길 / 아래 상자",
	"crates": "상자 경사: 뛰어넘으면 빠르다",
	"river": "흐르는 바닥: 무거우면 덜 밀린다",
	"track": "위 승강장 / 아래는 기차가 온다",
	"bridge": "짐 6개 이상: 밟은 판이 무너진다",
	"gate": "낮은 문: 짐 4개 이하만 통과",
	"slide": "얼음: 무거울수록 빠르고 못 멈춘다",
	"wind": "맞바람: 앞사람 뒤에 붙어라",
	"roofgap": "지붕 틈: 점프를 끝까지 눌러라",
	"longgap": "먼 틈: 짐을 버리고 점프",
	"ballast": "저울: 짐 6개 이상 위로 / 가벼우면 아래",
	"updraft": "상승풍: 짐 4개 이하면 위로 뜬다",
	"shutter": "차단문: 선두가 닿으면 잠깐 뒤 열림",
	"dropfloor": "낙하마루: 짐 6개로 잠깐 밟아 아래로",
	"ballast_mix": "응용: 무거운 저울 위로 / 아래는 강물",
	"updraft_mix": "응용: 가볍게 떠서 낮은 문 통과",
	"shutter_mix": "응용: 맞바람 속 차단문은 뒤에 붙기",
	"dropfloor_mix": "응용: 무겁게 마루를 뚫고 얼음 질주"}
const SEG_RULES_EN := {
	"flat": "Box at a mailbox = delivered",
	"stairs": "Hills: heavy loads climb slowly",
	"wall": "Red wall: jump it to keep speed", "pit": "Red gap: jump at the edge",
	"awning": "Yellow ledge: shortcut up / boxes below",
	"crates": "Crate slope: jump over to stay fast",
	"river": "Moving floor: heavy loads drift less",
	"track": "Platform above / trains come below",
	"bridge": "6+ boxes: planks you step on fall",
	"gate": "Low gate: 4 boxes or fewer only",
	"slide": "Ice: heavier is faster, no stopping",
	"wind": "Headwind: tuck in behind someone",
	"roofgap": "Roof gap: hold jump all the way",
	"longgap": "Long gap: drop a box, then jump",
	"ballast": "Scale: 6+ boxes go up / light goes down",
	"updraft": "Updraft: 4 boxes or fewer float up",
	"shutter": "Shutter: opens just after the leader",
	"dropfloor": "Trapdoor: stand on it with 6 boxes",
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
		"sky": Color("F7F5EE"), "far": Color("AAD4B6"),
		"gnd": Color("EDD2B2"), "top": Color("D99B5B"), "wall": Color("BA8E5C"),
		"bld": [Color("F4E3CF"), Color("ECCDAD"), Color("FBD99A")],
		"segs": ["flat", "stairs", "wall", "pit", "awning", "crates", "flat", "crates"]},
	{"name": "강변", "rule": "flow", "say": "바닥이 흐른다: 짐이 무거우면 덜 밀린다",
		"sky": Color("F7F5EE"), "far": Color("B1C9E1"),
		"gnd": Color("F0D9BE"), "top": Color("77A0CB"), "wall": Color("3D78B5"),
		"bld": [Color("FFFDF5"), Color("C5D6E9"), Color("F1DCC3")],
		"segs": ["flat", "river", "river", "pit", "stairs", "river", "wall", "river"]},
	{"name": "건널목", "rule": "train", "say": "아래 선로는 빠르다. 기차는 앞에서 온다",
		"sky": Color("F7F5EE"), "far": Color("FCE1AF"),
		"gnd": Color("EED6B8"), "top": Color("F7B336"), "wall": Color("BA8E5C"),
		"bld": [Color("FDE8C3"), Color("F4E3CF"), Color("C5D6E9")],
		"segs": ["flat", "track", "stairs", "track", "crates", "track", "pit"]},
	{"name": "야시장", "rule": "dark", "say": "정전: 꺼지면 아무도 앞을 못 본다",
		"sky": Color("F7F5EE"), "far": Color("F6BAB4"),
		"gnd": Color("EBCFAC"), "top": Color("E85244"), "wall": Color("BA8E5C"),
		"bld": [Color("F8CBC7"), Color("FDE8C3"), Color("F4E3CF")],
		"segs": ["flat", "wall", "pit", "crates", "stairs", "awning", "wall", "pit"]},
	{"name": "흔들다리", "rule": "bridge", "say": "짐 6개 이상이면 밟은 판이 무너진다",
		"sky": Color("F7F5EE"), "far": Color("AAD4B6"),
		"gnd": Color("F1DCC3"), "top": Color("6BB37F"), "wall": Color("2B9348"),
		"bld": [Color("BFDFC8"), Color("F4E3CF"), Color("FDE8C3")],
		"segs": ["flat", "bridge", "stairs", "bridge", "pit", "bridge", "crates"]},
	{"name": "지붕", "rule": "roof", "say": "벽이 없다: 먼 틈은 짐을 버려야 넘는다",
		"sky": Color("F7F5EE"), "far": Color("BFC0C7"),
		"gnd": Color("EED6B8"), "top": Color("7F808F"), "wall": Color("555669"),
		"bld": [Color("F4E3CF"), Color("BFC0C7"), Color("F8CBC7")],
		"segs": ["roofgap", "roofgap", "longgap", "stairs", "roofgap", "longgap"]},
]
# English course [name, say], same order as COURSES
const COURSES_EN := [
	["Market", "Hop over the walls"],
	["Riverside", "The floor flows: heavy loads drift less"],
	["Crossing", "Tracks below are fast. Trains come from ahead"],
	["Night Market", "Blackouts: when it's dark, nobody sees ahead"],
	["Rope Bridge", "6+ boxes and the planks you step on fall"],
	["Rooftops", "No walls: drop a box to clear long gaps"]]
const NICKS_EN := ["Me", "Red", "Mint", "Gold"]
# Delivery stamps
const ST_INK := 0
const ST_GOOD := 1
const ST_BAD := 2
const ST_COL := [Color("2A2C44"), Color("2B9348"), Color("E85244")]
const ST_PAPER := Color("FFFDF5")
const ST_N := 1  # one stamp on screen at a time: a new one replaces the old
const ST_REPEAT := 1.5
const ST_SLAM := 0.14
# Pocket Parcel Town palette (same values as sr_theme.gd, kept inline here)
const P_NAVY := Color("2A2C44")
const P_KRAFT := Color("E3BA88")
const P_KRAFT_SH := Color("BA8E5C")
const P_CREAM := Color("FFFDF5")
const P_RED := Color("E85244")
const P_GOLD := Color("F7B336")
const P_PARCEL := Color("D99B5B")
const P_GREEN := Color("2B9348")
const P_BLUE := Color("3D78B5")
# Screen layout (720x1280): thin rail 0..PF_TOP, playfield PF_TOP..PF_BOT (controls float over the ground).
const PF_TOP := 80.0
const PF_BOT := 1280.0
const FEET_Y := 790.0  # screen y where the leader's feet sit (ground/foreground below, controls float on it)
const FX_LINES := 22
const FX_POPS := 6
const DUST_N := 24
const TOSS_N := 5
const TEAR_N := 44
const SLOWMO := 0.35
const SLOWMO_MS := 400
# v12 배달 규칙: 우체통에 짐을 넣은 수로 이긴다 (살아남기 X)
const MB_R := 1.3  # 우체통에서 이만큼 안이면 짐 버튼 = 배달
const BACK_T := 0.6  # 왼쪽 끝 밖으로 밀리면 이만큼 뒤 왼쪽 끝에서 다시 들어온다
const BACK_IMM := 1.0  # 다시 들어온 뒤 무적 (깜빡임)
const LAST_CALL := 3.0  # 첫 도착 뒤 마감까지
const WALL_W := 56.0  # 화면 양옆 짐 벽 두께 (px). 벽 안쪽 면 = 진짜 떨어지는 끝 (v13: 34 -> 56, 폰에서 잘 안 보였다)
const BRICK_H := 60.0
const BRICK_GAP := 5.0
const WALL_POPS := 10
const MB_FREE := Color("E85244")
const MB_FULL := Color("6E7391")  # 찬 우체통: 잿빛 남색 (골판지 땅·건물과 섞이지 않게)
# v13 따라잡기 (뒤처지면 확정 패배 + 판이 안 끝나던 것)
const CATCH_MAX := 0.25  # 선두보다 반 화면(hwv) 넘게 뒤면 최고 속도 +25%, 가속은 +50% (붙어 있으면 0)
const CATCH_NEAR := 2.0  # 이만큼 안이면 보너스 없음
const GOLD_VAL := 3  # 결승 앞 금색 우체통 하나 = 배달 3개
const MB_GOLD := Color("F7B336")
const FAR_SCREENS := 2.0  # 선두보다 화면 이만큼 넘게 뒤에서
const FAR_T := 4.0  # 이만큼 있으면 왼쪽 끝으로 다시 들어온다
const DECIDE_T := 1.0  # 승부가 정해지면 이만큼 뒤 판 끝 (도장을 읽을 틈)
const ROUND_CAP := 120.0  # 안전 마감: 코스 길이 420 기준 이 초가 지나면 LAST CALL
# run_loop (courier_*.glb, 24fps 16프레임 0.042..0.708 s): 다리가 모이는 때 / 가장 벌어진 때
const ANIM_NEUTRAL := [0.042, 0.375]
const ANIM_STRIDE := [0.208, 0.542]


## One screen-space overlay for speed lines, the torn page edge and floating numbers.
class _FxPad extends Control:
	var draw_fn: Callable

	func _draw() -> void:
		if draw_fn.is_valid():
			draw_fn.call(self)


## A rubber postal stamp: perforated paper chip, thick + thin ink border, worn ink gaps.
class _StampCard extends Control:
	var ink := Color.BLACK
	var paper := Color.WHITE
	var shade := Color(0, 0, 0, 0.2)
	var seed_n := 1

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		var inner := r.grow(-5.0)
		draw_rect(Rect2(inner.position + Vector2(4, 5), inner.size), shade)
		draw_rect(inner, paper)
		var nx := maxi(int(inner.size.x / 15.0), 2)
		var ny := maxi(int(inner.size.y / 15.0), 2)
		for i in nx + 1:
			var x := inner.position.x + inner.size.x * float(i) / float(nx)
			draw_circle(Vector2(x, inner.position.y), 4.0, paper)
			draw_circle(Vector2(x, inner.end.y), 4.0, paper)
		for i in range(1, ny):
			var y := inner.position.y + inner.size.y * float(i) / float(ny)
			draw_circle(Vector2(inner.position.x, y), 4.0, paper)
			draw_circle(Vector2(inner.end.x, y), 4.0, paper)
		var ob := r.grow(-12.0)
		draw_rect(ob, ink, false, 5.0)
		draw_rect(r.grow(-20.0), ink, false, 2.0)
		var h := seed_n
		for k in 8:
			h = (h * 1103515245 + 12345) & 0x7fffffff
			var f := float(h % 997) / 997.0
			var pt := Vector2.ZERO
			match k % 4:
				0: pt = Vector2(ob.position.x + ob.size.x * f, ob.position.y)
				1: pt = Vector2(ob.end.x, ob.position.y + ob.size.y * f)
				2: pt = Vector2(ob.position.x + ob.size.x * f, ob.end.y)
				_: pt = Vector2(ob.position.x, ob.position.y + ob.size.y * f)
			var sz := Vector2(6, 6) if k % 2 == 0 else Vector2(9, 4)
			draw_rect(Rect2(pt - sz * 0.5, sz), paper)


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
	# animation / fx (visual only)
	var run_ph := 0.0  # run cycle phase
	var sway := 0.0  # parcel stack lag (world x), spring-damper
	var sway_v := 0.0
	var jig := 0.0  # parcel stack squash on landing
	var jig_v := 0.0
	var pvx := 0.0  # last frame v.x (for acceleration)
	var flash := 0.0  # hit flash time left
	var meshes: Array[GeometryInstance3D] = []  # body meshes that take the flash overlay
	var ghosts: Array[MeshInstance3D] = []  # dash afterimages
	var trail := 0.0  # afterimage time left
	var dust_t := 0.0
	var out_t := 0.0  # tumbling off the page after being knocked out
	var out_p := Vector3.ZERO
	var out_v := Vector3.ZERO
	var vis_dx := 0.0  # visual-only x offset that eases to 0 (edge shove)
	# 이번 프레임 입력
	var mx := 0.0
	var i_jump := false
	var i_jheld := false
	var i_drop := false
	# v12 배달
	var got := 0  # 이번 판 배달한 짐
	var back_t := 0.0  # > 0: 화면 밖에 반송돼 다시 들어오기를 기다린다
	var fin := -1  # 결승 도착 순서 (0 = 처음)
	var mb_seen := -1  # 경쟁자: 마지막으로 판단한 우체통
	var mb_go := false
	# v13 따라잡기·달리기 그림
	var catch := 0.0  # 선두와 멀수록 붙는 최고 속도 보너스 (0 .. CATCH_MAX x tn("catchup"))
	var gift := false  # 빈손으로 다시 들어와 돌려받은 짐 하나를 들고 있다 (반송되면 땅에 안 흘린다)
	var far_t := 0.0  # 선두보다 화면 둘 넘게 뒤에 있은 시간
	var anim: AnimationPlayer  # 모델의 run_loop (팔다리만 움직인다; 기울기·찌그러짐은 r.node 가 맡는다)
	var anim_t := 0.0  # run_loop 안의 시간 (손으로 돌린다)
	var anim_len := 0.0


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
var lead_said := false  # FIRST CLASS stamp: once per round
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
var sky_cache := {}  # backdrop path -> its top-row colour (the flat sky above it)
var _edge_mat: ShaderMaterial  # warm kraft paper edge instead of tofu's dark ink outline
var _flat_cols := {}  # colours drawn without an outline (deep ground fills)
var _paper_map := {}  # tofu's shared flat colours -> design palette
var lang := "en"  # "en" (default) or "ko", saved in RECORDS [opt] lang
var tell_s := ""  # calm rule line shown on route_l for tell_t seconds
var tell_t := 0.0
var tut_skipped := false  # left the practice with SKIP: the opening gets the one edge-rule line
var tut_step_max := -1  # furthest practice step seen (sr_front.step)
var skip_title := false  # PLAY AGAIN: restart without flashing the title
var stamps: Array = []  # pooled paper stamps {panel, label, age, life, base}
var stamp_last := {}  # text -> msec shown (no repeats within ST_REPEAT)
var stamp_set: Array[LabelSettings] = []
var stamp_font: FontVariation
# speed feel / framing / signature edge
var fx: _FxPad
var fx_lines: Array[Dictionary] = []  # {x, y, len, sp, w}
var pops: Array[Dictionary] = []  # floating numbers {on, r, at, text, col, age, w}
var fx_radial := 0.0  # EXPRESS radial burst time left
var fov_kick := 0.0  # + widens the view (decays)
var cam_nudge := 0.0  # world x offset of the camera only (visual; the kill line stays camx - hwv)
var spd_ratio := 0.0  # 0 slow .. 1 dashing (player), smoothed
var edge_warn := 0.0  # 0 far .. 1 player at the edge, smoothed
var back_arm_t := 0.0  # >0: the home icon is armed (first tap); a second tap in time quits. sr_hud may tint it red
var edge_flap := 0.0  # torn edge ripple after someone goes off the page
var edge_hit := 0.0  # red flash on the edge (player lost a box there)
var slowmo_end := 0  # msec; 0 = not slowed
var slowmo_last := -100000
var dust: Array[Dictionary] = []  # pooled paper scraps {node, v, life, max}
var dust_i := 0
var tosses: Array[Dictionary] = []  # pooled tumbling lost boxes {node, v, life}
var toss_i := 0
var last_put: Dictionary = {}
var tear_off := PackedFloat32Array()
var _tear := PackedVector2Array()
var _tear_sh := PackedVector2Array()
var _tear_ln := PackedVector2Array()
var _quad := PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
var _chev := PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
var _fx_mats := {}
var front  # sr_front.gd: title + tutorial (CanvasLayer 20)
var menus  # sr_menus.gd: mode / perk / route cards, countdown, receipt (CanvasLayer 15)
var sr_hud: CanvasLayer  # sr_hud.gd: race ribbon, control deck, hint chip (CanvasLayer 10)
var tut_crate_x := -1.0  # > 0: the opening flat gets one practice crate at this x (tutorial only)
var mailboxes: Array = []  # {x, y, full, owner, node, body, top, flag, parcel, t}
var last_call := -1.0  # >= 0: 마감 임박 남은 시간
var fin_n := 0
var course_got := 0  # 이번 코스에서 내가 배달한 짐 (메달)
var wall_lv := PackedFloat32Array([0, 0, 0, 0])  # 짐 벽: 주자별 벽돌 수 (부드럽게)
var wall_n := PackedInt32Array([0, 0, 0, 0])
var wall_add := PackedFloat32Array([0, 0, 0, 0])  # 새 벽돌 튀어 들어오기 남은 시간
var wall_pops: Array[Dictionary] = []  # 빠져나가는 벽돌 {on, p, v, rot, col, age}
var kit_live := true  # stick + jump/box answer touches (false on title and menus)
var end_t := -1.0  # >= 0: 모두 배달 / 승부 결정 도장 뒤 판 끝까지 남은 시간


## 경제 실험판(screenrace_t_*.gd)이 바꾸는 배수. 비어 있으면 원래 게임
var tune := {}


func tn(k: String) -> float:
	return float(tune.get(k, 1.0))


func _load0() -> int:
	return maxi(1, roundi(LOAD0 * tn("load")))


func _load_max() -> int:
	return maxi(1, roundi(LOAD_MAX * tn("load")))


func _wide() -> float:
	return WIDE * tn("view")


func _narrow() -> float:
	return NARROW * tn("view")


func _mb_r() -> float:
	return MB_R * tn("mb_r")


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
	if _stamp_show(L(ko, en), kind, who, dur):
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
	stamp_font = FontVariation.new()
	stamp_font.base_font = _font
	stamp_font.spacing_glyph = 3  # wide rubber-stamp lettering
	for k in 3:
		var ls := LabelSettings.new()
		ls.font = stamp_font
		ls.font_size = 36
		var ink: Color = ST_COL[k]
		ls.font_color = Color(ink, 0.92)
		stamp_set.append(ls)
	for i in ST_N:
		var p := _StampCard.new()
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.visible = false
		p.paper = Color(ST_PAPER, 0.93)
		p.shade = Color(P_NAVY, 0.22)
		layer.add_child(p)
		var l := Label.new()
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.set_anchors_preset(Control.PRESET_FULL_RECT)
		p.add_child(l)
		stamps.append({"panel": p, "label": l, "age": 0.0, "life": 0.0, "base": Vector2.ZERO, "landed": false, "kind": 0, "k": 1.0})


func _stamp_show(s: String, kind: int, who: Courier, dur: float) -> bool:
	if stamps.is_empty() or s == "":
		return false
	var now := Time.get_ticks_msec()
	if stamp_last.has(s) and now - int(stamp_last[s]) < int(ST_REPEAT * 1000.0):
		return false
	# a fresh bad-news stamp is never covered by good news
	for e in stamps:
		if (e.panel as Control).visible and e.age < 0.6 and int(e.kind) == ST_BAD and kind != ST_BAD:
			return false
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
	var p: _StampCard = st.panel
	var l: Label = st.label
	kind = clampi(kind, 0, 2)
	st.kind = kind
	st.k = 0.8 if phase == "race" else 1.0  # smaller over the running lane
	var ink: Color = ST_COL[kind]
	p.ink = Color(ink, 0.9)
	p.seed_n = randi() % 100000 + 1
	p.queue_redraw()
	l.label_settings = stamp_set[kind]
	l.text = s
	var sz := stamp_font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 36) + Vector2(70, 46)
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
	at.y -= 50.0 + holding * 80.0
	at.x = clampf(at.x, 16.0 + sz.x * 0.5, 704.0 - sz.x * 0.5)
	at.y = clampf(at.y, PF_TOP + 60.0, PF_BOT - 80.0)
	st.base = at - sz * 0.5
	st.age = 0.0
	st.landed = false
	st.life = clampf(dur, 0.5, 1.4) + 0.4
	p.position = st.base
	p.rotation = deg_to_rad(randf_range(3.0, 8.0) * (1.0 if randf() < 0.5 else -1.0))
	p.scale = Vector2.ONE * 1.7
	p.modulate.a = 0.2
	p.visible = true
	return true


func _stamp_tick(dt: float) -> void:
	var gone := over or _rating
	for st in stamps:
		var p: Control = st.panel
		if not p.visible:
			continue
		st.age += dt
		if gone or st.age >= st.life:
			p.visible = false
			continue
		var a: float = st.age
		var fade: float = clampf((a - (st.life - 0.4)) / 0.4, 0.0, 1.0)
		if a < ST_SLAM:  # slam: 1.7 -> 1.0, cubic ease-in, ink fades in
			var u := a / ST_SLAM
			p.scale = Vector2.ONE * lerpf(1.7, 1.0, u * u * u) * float(st.k)
			p.modulate.a = lerpf(0.2, 1.0, u)
		else:
			if not st.landed:
				st.landed = true
				shk = maxf(shk, 0.14)  # ~2 px thump
			p.scale = Vector2.ONE * float(st.k)
			p.modulate.a = 1.0 - fade
		p.position = st.base + Vector2(0.0, -40.0 * fade)


func _set_lang(l: String) -> void:
	lang = l
	records.set_value("opt", "lang", lang)
	records.save(RECORDS)
	for signpost in signs:
		(signpost.node as Label3D).text = L(signpost.ko, signpost.en)
	_restore_labels()
	if menus:
		menus.refresh()
	if front:
		front.refresh_text()


func _howto_text() -> String:
	return L("왼쪽 스틱으로 달리고 [점프]로 넘는다.\n우체통 앞에서 [짐] = 배달. 다른 곳에서 [짐] = 던지고 대시.\n왼쪽 끝에 밀리면 짐 하나를 잃는다. 배달 많이 한 사람이 이긴다!",
		"Left stick to run, [Jump] to hop.\n[Box] at a mailbox delivers. [Box] elsewhere throws one for a dash.\nFall off the left edge: lose a box. Most deliveries wins!")


## The stick and the two buttons only answer touches in KIT_PHASES; on the title and the
## paper menus every tap goes to _tap (the modules) instead, so the two never fight.
func _kit_live(on: bool) -> void:
	if on == kit_live:
		return
	kit_live = on
	_kit_clear()
	_stick_zone = SR_HUD.STICK_ZONE if on else Rect2()
	if _btns.has("jump"):
		_btns["jump"].r = SR_HUD.JUMP_R if on else 0.0
		_btns["drop"].r = SR_HUD.BOX_R if on else 0.0


func _open_mode_select() -> void:
	tut_crate_x = -1.0
	if front and front.state == "title":
		front.hide_title()
	menus.hide_countdown()
	phase = "mode"
	menus.show_modes()


func _open_title() -> void:
	menus.hide_all()
	menus.hide_countdown()
	phase = "title"
	tell_t = 0.0
	front.show_title()


## sr_front: course 1 opening flat as an empty practice yard (no rivals, one crate).
func tutorial_begin() -> void:
	menus.hide_all()
	ci = 0
	rnd = 0
	finale = false
	mode = "base"
	fresh = true
	twist = ""
	tut_crate_x = 16.0
	_build_course()
	_start_round()
	menus.hide_countdown()
	for r in runners:
		if r.ai:
			r.alive = false  # _start_round() of the next real race sets them back
			r.node.visible = false
	phase = "tutorial"
	tell_t = 0.0
	tut_step_max = -1
	_kit_live(true)


## tofu's corner touch zones stay live while sr_hud hides their icons: swallow those presses.
func _finger(id: int, p: Vector2, kind: int) -> void:
	if kind == 1 and not over and not _rating and not (_howto_box and _howto_box.visible):
		if SR_HUD.NO_RATE_PHASES.has(phase) and _RATE_BTN.has_point(p):
			return
		if p.x < 180.0 and p.y < 100.0 and SR_HUD.NO_BACK_PHASES.has(phase):
			return
		# mid-run the home corner needs two taps: a stray tap must not throw away the 6-course run
		if p.x < 180.0 and p.y < 100.0 and BACK_ARM_PHASES.has(phase) and back_arm_t <= 0.0:
			back_arm_t = 1.5
			beep(660.0, 0.06)
			_stamp("한 번 더 누르면 나감", "TAP AGAIN TO QUIT", ST_INK, null, 1.2)
			return
	super._finger(id, p, kind)


func _tap(p: Vector2) -> void:
	if front:
		front.tap(p)


func _kit_draw(c: Control) -> void:
	if not kit_live:
		return
	if sr_hud:
		sr_hud.draw_kit(c, self)
	else:
		super._kit_draw(c)


func _opening() -> bool:
	return ci == 0 and rnd == 1 and not finale and rt < 10.0


func _overpowered(r: Courier) -> bool:
	return mode == "over" and r == pl and r.cargo <= LIGHT_N and not _opening()


func _sign(x: float, y: float, ko: String, en: String, rule := "") -> void:
	var label := Label3D.new()
	label.font = _font
	label.text = L(ko, en)
	label.font_size = 48
	label.pixel_size = 0.016
	label.outline_size = 12
	label.modulate = P_CREAM
	label.outline_modulate = P_NAVY
	label.visible = false  # only shown near the camera while racing (_update_content_hud)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(x + 3.0, y + 0.6, 0.2)
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
			if m.type == "ballast" and r.grounded and r.cargo >= HEAVY_N and absf(r.p.y - m.y) < 0.6:
				r.v.y = 24.0
				r.v.x = maxf(r.v.x, 8.5)
				r.grounded = false
				r.cut = true
				_sfx("spring", r)
			elif m.type == "updraft" and r.cargo <= LIGHT_N and r.p.y >= m.y - 0.1 and r.p.y < m.y + 4.8:
				r.v.y = 18.0
				r.grounded = false
				r.cut = true


func _update_content_hud() -> void:
	if phase != "race":
		for signpost in signs:
			(signpost.node as Node3D).visible = false
	route_l.visible = false  # sr_hud shows this text as the hint chip; the cards show menu text
	if not KIT_PHASES.has(phase) or phase == "tutorial":
		route_l.text = ""
		return
	if phase == "mode":
		var best_l := L("최다 배달: 기본 %d / 등불 %d / 과속 %d", "Best: Classic %d · Lantern %d · Rush %d")
		route_l.text = "%s: %s\n%s: %s\n%s: %s\n%s" % [_mode_name("base"), _mode_rule("base"), L("밤 등불", "Lantern"), _mode_rule("lantern"), L("과속", "Rush"), _mode_rule("over"), best_l % [int(records.get_value("base", "delivered", 0)), int(records.get_value("lantern", "delivered", 0)), int(records.get_value("over", "delivered", 0))]]
		return
	if phase == "perk":
		route_l.text = "%s\n%s: %s\n%s: %s" % [L("특전 고르기", "Pick a perk"), _perk(perk_offer[0]), _perk_say(perk_offer[0]), _perk(perk_offer[1]), _perk_say(perk_offer[1])]
		return
	if phase == "route":
		route_l.text = "%s\n%s: %s\n%s: %s" % [L("다음 길? 내 짐 %d", "Next road? You carry %d") % (_load0() + load_bonus), _tw(route_offer[0], 0), _tw(route_offer[0], 1), _tw(route_offer[1], 0), _tw(route_offer[1], 1)]
		return
	if _opening():
		# no text in the race: a skipper is taught by the torn edge itself (forced warning pulse, _fx_tick)
		route_l.text = ""
		return
	route_l.text = ""
	var telling := tell_t > 0.0 and phase != "roundend"
	if telling:
		route_l.text = tell_s
	if phase != "race":
		return
	# World signs speak for themselves (no duplicate HUD line); a new rule still gets a chime.
	for signpost in signs:
		(signpost.node as Node3D).visible = absf(signpost.x - camx) < hwv + 8.0
		if pl.p.x > signpost.x - 7.0 and pl.p.x < signpost.x + 6.0:
			if signpost.rule != "" and not seen_rules.has(signpost.rule):
				seen_rules[signpost.rule] = true
				beep(740.0, 0.06, 990.0, 0.12)
			break


func _record_course() -> void:
	# 메달 = 배달: 금 = 2판 안에 이기고 이 코스에서 MEDAL_GOT개 이상 배달, 은 = 3판 안, 동 = 코스 통과
	var medal := 3 if rnd <= 2 and course_got >= MEDAL_GOT else (2 if rnd <= 3 else 1)
	var row := {"ci": ci, "medal": medal, "time": course_time, "cargo": course_got}
	course_results.append(row)
	var key := "%s_%d" % [mode, ci]
	records.set_value(key, "medal", maxi(medal, int(records.get_value(key, "medal", 0))))
	records.set_value(key, "time", minf(course_time, float(records.get_value(key, "time", 1.0e9))))
	records.set_value(key, "delivered", maxi(course_got, int(records.get_value(key, "delivered", 0))))
	records.save(RECORDS)


func _start_finale() -> void:
	finale = true
	rnd = 0
	fresh = false
	twist = ""
	_build_course()
	_start_round()
	_tell("마지막 배달. 배운 길을 모두 써라", "Final delivery. Use every road you learned", 2.6)
	# Keep the last round's parcels, grid and upgrades for the final delivery.


func _finish(won: bool) -> void:
	if over:
		return
	var placement := 1 if won else maxi(2, grid.find(pl) + 1)
	if won:
		score += 100  # 배달 점수는 우체통마다 이미 더했다 (delivered = 진짜 넣은 짐 수)
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
	var hint := L("다음엔 짐 6개로 저울 위 지름길!", "Next: take the scale shortcut with 6 boxes!")
	if mode == "base":
		hint = L("다음엔 과속 배달: 짐 4개로 천장 가속!", "Next: try Rush, ceiling boost with 4 boxes!")
	elif mode == "over":
		hint = L("다음엔 밤 등불: 선두의 빛에 붙어라!", "Next: try Lantern, stick to the leader's light!")
	var medals := [0, 0, 0, 0, 0, 0]
	for row in course_results:
		medals[row.ci] = maxi(medals[row.ci], int(row.medal))  # 3 gold, 2 silver, 1 bronze, 0 not reached
	var names := []
	for i in COURSES.size():
		names.append(_cname(i))
	var res_f := L("%s · %d위\n배달한 짐 %d개 · 달린 시간 %.1f초\n최고 코스: %s\n%s\n로컬 최다 배달 %d개%s\n완주 최고 %s\n%s\n금: 2판 안에 승리 + 배달 %d개\n은: 3판 안 / 동: 코스 완주\n별점 아래 빈 곳을 탭하면 다시 배달",
		"%s · #%d\nDelivered %d · Time %.1fs\nBest course: %s\n%s\nMost delivered here: %d%s\nBest finish: %s\n%s\nGold: win in 2 rounds + %d delivered\nSilver: in 3 rounds / Bronze: finish\nTap the empty space below the stars to go again")
	var best_s := (L("%.1f초", "%.1fs") % best_time) if best_time > 0.0 else L("도전 중", "not yet")
	result_l.text = res_f % [L("여섯 동네 배달 완료!", "All six towns delivered!") if won else L("오늘 배달은 여기까지", "That's it for today"), placement, delivered, journey_time, strongest, rows, best_delivery, L(" · 새 기록!", " · New record!") if delivered > previous else "", best_s, MEDAL_GOT, hint]
	if not saved:
		result_l.text += L("\n기록 저장 안 됨", "\nRecord not saved")
	result_l.visible = false
	phase = "results"
	_kit_live(false)
	menus.show_results({
		"won": won,
		"placement": placement,
		"delivered": delivered,
		"time": journey_time,
		"best_course": strongest,
		"best_delivery": best_delivery,
		"new_record": delivered > previous,
		"best_time": best_time,
		"medals": medals,
		"courses": names,
		"hint": hint,
		"saved": saved,
		"mode": _mode_name(mode),
		"headline": L("여섯 동네 배달 완료!", "All six towns delivered!") if won else L("오늘 배달은 여기까지", "That's it for today"),
	})
	end() # Tofu owns stars, feedback, score save and tap-to-restart.
	_sfx("champion" if won else "lost")


func _process(dt: float) -> void:
	super._process(dt)
	tell_t = maxf(tell_t - dt, 0.0)
	back_arm_t = maxf(back_arm_t - dt, 0.0)
	_stamp_tick(dt)
	_fx_tick(dt)
	if phase == "tutorial" and front:
		tut_step_max = maxi(tut_step_max, int(front.step))
	_bar_bg.visible = false  # tofu's edge gauge: the HUD rail + torn red edge show this now
	if result_l:
		result_l.visible = false
		mode_l.visible = false
		route_l.visible = false
		if over:
			_over_l.visible = false
	_kit_live(KIT_PHASES.has(phase) and not over)
	if sr_hud:
		var racing := phase == "race"
		sr_hud.set_line(route_l.text if racing else "")


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
				_sky_from(path, texture)
				return


## The flat sky above the backdrop takes the backdrop's own top-row colour, so there is no seam.
func _sky_from(path: String, texture: Texture2D) -> void:
	if not sky_cache.has(path):
		var col := P_CREAM.darkened(0.03)
		var img := texture.get_image()
		if img and not img.is_empty() and not img.is_compressed():
			var acc := Color(0, 0, 0, 0)
			var w := img.get_width()
			for k in 8:
				acc += img.get_pixel(clampi(int(w * (k + 0.5) / 8.0), 0, w - 1), 1)
			col = acc * 0.125
			col.a = 1.0
		sky_cache[path] = col
	for e in get_children():
		if e is WorldEnvironment:
			(e as WorldEnvironment).environment.background_color = sky_cache[path]


## Paper-craft materials: palette colours and a soft kraft edge (tofu.gd stays untouched).
func mat(color: Color) -> StandardMaterial3D:
	var key := color.to_html()
	if not _mats.has(key):
		if _paper_map.is_empty():
			_paper_map = {BAD.to_html(): P_RED, GOOD.to_html(): P_GREEN, D.to_html(): P_GOLD,
				B.to_html(): WIND_C, A.to_html(): P_PARCEL, ME.to_html(): P_BLUE, INK.to_html(): P_NAVY,
				WHITE.to_html(): P_CREAM, SOFT.to_html(): P_KRAFT.lightened(0.35)}
		if _edge_mat == null:
			_edge_mat = OUTLINE.duplicate() as ShaderMaterial
			_edge_mat.set_shader_parameter("ink", P_KRAFT_SH.darkened(0.3))
		var sm := StandardMaterial3D.new()
		sm.albedo_color = _paper_map.get(key, color)
		if not _flat_cols.has(key):
			sm.next_pass = _edge_mat
		_mats[key] = sm
	return _mats[key]


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
	if not tune.is_empty():  # 경제 실험판 표시 (오른쪽 아래 작게, 모든 화면 위)
		var tl := CanvasLayer.new()
		tl.layer = 40
		add_child(tl)
		var t := _label(tl, 22, 1240, 36)
		t.text = "TEST " + ", ".join(tune.keys().map(func(k): return "%s x%s" % [k, str(tune[k])]))
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		t.size.x = 700
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
	howto = ""  # no tofu how-to card: the title + interactive tutorial (sr_front) teach instead
	_fx_setup()
	_stamp_setup()
	kit_stick(SR_HUD.STICK_ZONE)  # Rect2(0,920,360,380) -> home (180,1100)
	kit_button("jump", L("점프", "Jump"), SR_HUD.JUMP_POS, SR_HUD.JUMP_R, SR_HUD.JUMP_FACE)
	kit_button("drop", L("짐", "Box"), SR_HUD.BOX_POS, SR_HUD.BOX_R, PARCEL)
	sr_hud = SR_HUD.new()
	add_child(sr_hud)
	sr_hud.setup(self)
	menus = SrMenus.new()
	add_child(menus)
	menus.setup(self)
	menus.mode_chosen.connect(func(id: String) -> void: _pick_mode(MODE_KIT[id]))
	menus.perk_chosen.connect(func(i: int) -> void: _pick_perk("jump" if i == 0 else "drop"))
	menus.route_chosen.connect(func(i: int) -> void: _pick_route("jump" if i == 0 else "drop"))
	menus.lang_pressed.connect(func() -> void: _set_lang("en" if lang == "ko" else "ko"))
	menus.back_pressed.connect(func() -> void: _open_title())
	menus.again_pressed.connect(func() -> void:
		var m := mode
		skip_title = true
		restart()
		_pick_mode(MODE_KIT[m]))
	menus.title_pressed.connect(func() -> void: restart())
	front = SrFront.new()
	add_child(front)
	front.setup(self)
	front.play_pressed.connect(func() -> void: _open_mode_select())
	front.tutorial_pressed.connect(func(first: bool) -> void:
		tutorial_begin()
		front.start_tutorial(first))
	front.lang_pressed.connect(func() -> void: _set_lang("en" if lang == "ko" else "ko"))
	front.tutorial_done.connect(func(first: bool) -> void:
		tut_skipped = tut_step_max < SrFront.STEP_N
		if first:
			# first run: straight into the basic race, no mode choice they cannot judge yet
			menus.hide_all()
			_pick_mode(MODE_KIT["base"])
		else:
			_open_mode_select())


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
	tut_crate_x = -1.0
	if menus:
		menus.hide_all()
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
	# colour = the courier model's cap colour (blue = you), so rail pins, ghosts and bursts match the bodies
	var cols := [P_BLUE, P_RED, P_GREEN, P_GOLD]
	var nicks := ["나", "빨강", "민트", "노랑"]
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
	for i in 28:  # v13: 짐이 두 배라 땅에 떨어진 짐도 많다
		var n := box(Vector3(0, -50, 0), Vector3(0.6, 0.5, 0.6), PARCEL)
		if _art_model("parcel", n, Vector3(0, -0.5, 0), 1.0):
			n.mesh = null
		n.visible = false
		parcels.append({"node": n, "on": false, "p": Vector2.ZERO, "owner": null, "cd": 0.0, "fly": 0.0, "from": Vector3.ZERO})
	Engine.time_scale = 1.0
	slowmo_end = 0
	dust.clear()
	for i in DUST_N:
		var m := box(Vector3(0, -80, 0), Vector3(0.22, 0.14, 0.04), WHITE)
		m.visible = false
		dust.append({"node": m, "v": Vector3.ZERO, "life": 0.0, "max": 0.4})
	tosses.clear()
	for i in TOSS_N:
		var n := box(Vector3(0, -80, 0), Vector3(0.5, 0.38, 0.6) * VIS_K, PARCEL)
		if _art_model("parcel", n, Vector3(0, -0.5, 0), 1.0):
			n.mesh = null
		n.visible = false
		tosses.append({"node": n, "v": Vector3.ZERO, "life": 0.0})
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	curtain = box(Vector3.ZERO, Vector3(1, 1, 0.2), NIGHT)
	curtain.visible = false
	# "you" pointer: a small flat blue paper diamond on a white paper edge (scale set per frame)
	marker = box(Vector3.ZERO, Vector3(0.36, 0.36, 0.05), WHITE)
	marker.rotation.z = PI * 0.25
	box(Vector3(0, 0, 0.6), Vector3(0.72, 0.72, 1.0), ME, marker)
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
	clouds.clear()  # no slab clouds: the watercolor backdrop has its own (slabs read as stray UI tabs)
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
	# Title over the live course-1 diorama (PLAY -> mode cards, first run -> tutorial)
	if skip_title:
		skip_title = false
		menus.hide_all()
		phase = "title"
	else:
		_open_title()
	_kit_live(false)
	# Frame the start grid from the very first frame (the how-to card freezes _step).
	_cam_snap()
	_draw_all()


func _pick_mode(n: String) -> void:
	mode = "base" if n == "jump" else ("lantern" if n == "drop" else "over")
	tut_crate_x = -1.0
	if front and front.state == "title":
		front.hide_title()
	menus.hide_all()
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
	var skins := ["courier_blue", "courier_coral", "courier_mint", "courier_gold"]  # runner 0 = you = blue
	if _art_model(skins[runners.size() % 4], r.node, Vector3(0, -0.45, 0), BODY_H):
		r.art = r.node.get_child(r.node.get_child_count() - 1)
		var pending: Array[Node] = [r.art]
		while not pending.is_empty():
			var nd: Node = pending.pop_back()
			if nd is GeometryInstance3D:
				r.meshes.append(nd as GeometryInstance3D)
			elif nd is AnimationPlayer and r.anim == null:
				r.anim = nd as AnimationPlayer
			pending.append_array(nd.get_children())
		# 달리기: run_loop 을 반복으로 두고 시간은 _anim_tick 이 손으로 돌린다 (주자마다 박자를 어긋나게)
		# Godot 가져오기(이름 접미사 켬)는 "run_loop" 을 반복 애니메이션 "run" 으로 바꿔 둔다: 둘 다 찾는다
		var an_name := "run_loop" if r.anim and r.anim.has_animation("run_loop") else "run"
		if r.anim and r.anim.has_animation(an_name):
			var an := r.anim.get_animation(an_name)
			an.loop_mode = Animation.LOOP_LINEAR
			r.anim_len = an.length
			r.anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
			r.anim.play(an_name)
			r.anim_t = fposmod(0.19 * runners.size() + 0.05, r.anim_len)
			r.anim.seek(r.anim_t, true)
		else:
			r.anim = null
	else:
		r.meshes.append(box(Vector3.ZERO, Vector3(HW * 2.0, HH * 0.75, 0.8), r.col, r.node))
		r.meshes.append(box(Vector3(0, 0.63, 0), Vector3(0.42, 0.36, 0.5), SOFT, r.node))
		r.meshes.append(box(Vector3(0.05, 0.88, 0), Vector3(0.6, 0.14, 0.6), WHITE if not r.ai else r.col.darkened(0.2), r.node))
	for k in 3:
		var g := box(Vector3(0, -80, 0), Vector3(0.75, 1.3, 0.05), r.col)
		g.material_override = _fx_mat(r.col.lightened(0.15), 0.4 - k * 0.11)
		g.visible = false
		r.ghosts.append(g)
	for k in _load_max() + 1:
		var q := box(Vector3(-0.5, -0.2 + k * 0.4, 0), Vector3(0.5, 0.38, 0.6) * VIS_K, PARCEL, r.node)
		if _art_model("parcel", q, Vector3(0, -0.5, 0), 1.0):
			q.mesh = null
		q.scale *= PACK_K  # 짐이 8~10개: 두 줄 더미라 조금 작게
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
	_flat_cols[(cdef.gnd as Color).to_html()] = true  # deep ground: no outline seams down the control deck
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
	mailboxes.clear()  # 우체통 노드는 stage 와 함께 사라진다
	if rnd == 0:
		course_got = 0
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
		if tut_crate_x > 0.0:
			_bump(tut_crate_x, fy, 1.0, 1.0, cdef.wall, 0.0, 0.0)  # tutorial: a 1 m crate to jump
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
		_sign(gx + 7.0, fy + 3.0, "마지막 집. 첫 도착 뒤 3초면 마감", "Last house. 3 s after the first arrival, post closes")
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
	_place_mailboxes()
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
				_solid(Rect2(gx, fy - 26.0, w, 26.0), cdef.gnd, 3)
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
			for k in GATE_MAX:  # 간판: 짐 GATE_MAX개 그림 (두 줄, 문 지붕 앞면 안에)
				_vbox(Vector3(dx + 1.0 + (k % 2) * 0.7, fy + GATE_H + 0.45 + (k / 2) * 0.5, 1.35), Vector3(0.55, 0.4, 0.2), PARCEL)
			spots.append(Vector2(gx + 13.0, fy))  # 문 뒤 짐 하나: 다시 주울지
			gx += 15.0
		"slide":  # 얼음 내리막: 못 멈추고, 무거울수록 빨리 미끄러진다. 끝은 구덩이
			_floor(gx, 2.0)
			gx += 2.0
			for k in 5:
				_solid(Rect2(gx, fy - 26.0, 3.4, 26.0), ICE, 5)
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
	_solid(Rect2(x, fy - 26.0, w, 26.0), cdef.gnd, 0)  # deep: the ground fills the bottom of the screen
	_vbox(Vector3(x + w * 0.5, fy - 0.1, 0), Vector3(w, 0.2, 2.5), cdef.top)
	_vbox(Vector3(x + w * 0.5, fy - 1.6, 1.26), Vector3(w, 0.16, 0.04), cdef.gnd.darkened(0.12))  # cut-paper layer line


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


# ---- 우체통 (v12 배달 규칙) ----
## 코스를 다 지은 뒤 평평한 땅(위험 구간 밖)에 우체통 7~9개를 고르게 놓는다. 연습 마당은 연습용 하나만.
func _place_mailboxes() -> void:
	if tut_crate_x > 0.0:
		var ty := _floor_top(tut_crate_x + 9.0, 60.0)
		_add_mailbox(tut_crate_x + 9.0, ty)
		return
	var x0 := 24.0
	var x1 := goal_x - 8.0
	# v13: 결승 조금 앞 금색 우체통 하나 = 배달 GOLD_VAL개 (뒤처진 사람의 마지막 기회). 먼저 자리를 잡는다
	for k in 50:
		var gxx := goal_x - 7.0 - float(k)
		var gy := _mb_spot(gxx)
		if gy > -1.0e8:
			_add_mailbox(gxx, gy, true)
			break
	var want := maxi(1, roundi(gen.randi_range(7, 9) * tn("mail")))
	var step := (x1 - x0) / float(want)
	var offs := [0.0, 2.0, -2.0, 4.0, -4.0, 6.0, -6.0, 8.0, -8.0, 11.0, -11.0, 14.0]
	for k in want:
		var cx := x0 + step * (float(k) + 0.5) + gen.randf_range(-0.2, 0.2) * step
		for o in offs:
			var x: float = cx + o
			var y := _mb_spot(x)
			if y > -1.0e8:
				_add_mailbox(x, y)
				break
	# 평평한 곳이 모자란 코스: 앞에서부터 더 찾아 6개는 채운다
	var sx := x0
	while mailboxes.size() < mini(6, want) and sx < x1:
		var sy := _mb_spot(sx)
		if sy > -1.0e8:
			_add_mailbox(sx, sy)
		sx += 3.0
	mailboxes.sort_custom(func(a, b): return a.x < b.x)


## 우체통을 놓을 수 있으면 땅 높이, 아니면 아주 낮은 수. 평평한 맨 바닥(종류 0)이고 머리 위가 비어 있어야 한다.
func _mb_spot(x: float) -> float:
	var no := -1.0e9
	if x < 20.0 or x > goal_x - 6.0:
		return no
	var y := _floor_top(x, 60.0)
	if y < -50.0 or _floor_top(x, y - 0.3) > -50.0:
		return no  # 구덩이, 또는 땅 위에 뜬 발판 (지름길 위에는 안 놓는다)
	for dx in [-1.6, -0.8, 0.8, 1.6]:
		if absf(_floor_top(x + dx, y + 0.3) - y) > 0.05:
			return no
	var plain := false
	for i in buckets[_bi(x)]:
		var q: Rect2 = rects[i]
		if x > q.position.x - 1.6 and x < q.end.x + 1.6 and absf(q.end.y - y) < 0.05:
			if kinds[i] != 0:
				return no  # 점프대·흐르는 바닥·다리 판·얼음·문 옆
			plain = true
	if not plain or _solid_in(Rect2(x - 0.7, y + 0.05, 1.4, 2.4)):
		return no
	if not _track_at(x).is_empty():
		return no
	for gp in gates:
		if absf(float(gp) - x) < 4.0:
			return no
	for m in mechanisms:
		if x > float(m.x0) - 3.0 and x < float(m.x1) + 3.0:
			return no
	for mb in mailboxes:
		if absf(float(mb.x) - x) < 12.0:
			return no
	return y


## 종이 우체통: 남색 기둥 + 빨간 몸통 + 둥근 지붕 띠 + 투입구 + 옆 깃발 (배달되면 깃발이 서고 몸통이 골판지색).
func _add_mailbox(x: float, y: float, gold := false) -> void:
	if y < -50.0:
		return
	var n := Node3D.new()
	stage.add_child(n)
	n.position = Vector3(x, y, -0.75)
	n.scale = Vector3.ONE * (1.4 if gold else 1.25)  # 폰 화면에서 배달부만큼 크게 (금색은 조금 더)
	var col := MB_GOLD if gold else MB_FREE
	box(Vector3(0, 0.5, 0), Vector3(0.16, 1.0, 0.16), P_NAVY, n)
	var body := box(Vector3(0, 1.42, 0), Vector3(1.1, 0.86, 0.7), col, n)
	var top := box(Vector3(0, 1.9, 0), Vector3(1.18, 0.16, 0.76), col.lightened(0.3), n)
	if gold:
		# 작은 "x3" 표: 지붕 위 막대에 꽂힌 크림 종이 (배달되면 짐이 그 아래 지붕에 꽂힌다)
		box(Vector3(-0.45, 2.35, 0), Vector3(0.06, 0.9, 0.06), P_NAVY, n)
		box(Vector3(-0.45, 2.62, 0.02), Vector3(0.62, 0.42, 0.05), P_CREAM, n)
		var tag := Label3D.new()
		tag.font = _font
		tag.text = L("x%d" % GOLD_VAL, "x%d" % GOLD_VAL)
		tag.font_size = 64
		tag.pixel_size = 0.0055
		tag.outline_size = 0
		tag.modulate = P_NAVY
		tag.position = Vector3(-0.45, 2.62, 0.06)
		n.add_child(tag)
	box(Vector3(0, 1.6, 0.36), Vector3(0.62, 0.1, 0.02), P_NAVY, n)
	box(Vector3(0, 1.28, 0.36), Vector3(0.5, 0.26, 0.02), P_CREAM, n)  # 흰 주소 딱지
	var flag := Node3D.new()
	n.add_child(flag)
	flag.position = Vector3(0.6, 1.2, 0.15)
	box(Vector3(0, 0.32, 0), Vector3(0.07, 0.64, 0.07), P_NAVY, flag)
	var cloth := box(Vector3(0.15, 0.55, 0), Vector3(0.3, 0.2, 0.05), P_GOLD, flag)
	flag.rotation.z = -PI * 0.5  # 내려 있음 = 빈 우체통
	var pc := box(Vector3(0, 2.18, 0), Vector3(0.5, 0.4, 0.5), PARCEL, n)  # 배달되면 지붕 위에 꽂히는 짐
	if _art_model("parcel", pc, Vector3(0, -0.5, 0), 1.0):
		pc.mesh = null
	pc.visible = false
	mailboxes.append({"x": x, "y": y, "full": false, "owner": null, "node": n, "body": body, "top": top,
		"flag": flag, "cloth": cloth, "parcel": pc, "t": 0.0, "val": GOLD_VAL if gold else 1, "col": col})


func _mb_reset() -> void:
	for mb in mailboxes:
		mb.full = false
		mb.owner = null
		mb.t = 0.0
		var col: Color = mb.col
		(mb.body as MeshInstance3D).material_override = mat(col)
		(mb.top as MeshInstance3D).material_override = mat(col.lightened(0.3))
		(mb.cloth as MeshInstance3D).material_override = mat(P_GOLD)
		(mb.flag as Node3D).rotation.z = -PI * 0.5
		(mb.parcel as Node3D).visible = false


## 빈 우체통 번호 (r 바로 옆, MB_R 안). 없으면 -1.
func _mb_at(r: Courier) -> int:
	for i in mailboxes.size():
		var mb: Dictionary = mailboxes[i]
		if not mb.full and absf(float(mb.x) - r.p.x) < _mb_r() and r.p.y - float(mb.y) > -0.6 and r.p.y - float(mb.y) < 2.2:
			return i
	return -1


## 짐 버튼: 빈 우체통 옆이면 배달 (대시 없음). 아니면 false (던지고 대시로 넘어간다).
func _deliver(r: Courier) -> bool:
	var i := _mb_at(r)
	if i < 0:
		return false
	var mb: Dictionary = mailboxes[i]
	var val: int = mb.val
	r.cargo -= 1
	r.got += val
	r.drop_cd = 0.35
	mb.full = true
	mb.owner = r
	mb.t = 0.45  # 깃발이 서는 시간
	(mb.body as MeshInstance3D).material_override = mat(MB_FULL)
	(mb.top as MeshInstance3D).material_override = mat(MB_FULL.lightened(0.2))
	(mb.cloth as MeshInstance3D).material_override = mat(r.col)
	var pc: Node3D = mb.parcel
	pc.visible = true
	pc.scale = Vector3.ONE * 0.2
	_burst(Vector3(float(mb.x), float(mb.y) + 2.0, 0.4), 4, P_GREEN)
	r.sq = 0.25
	if val > 1:
		_burst(Vector3(float(mb.x), float(mb.y) + 2.4, 0.4), 4, P_GOLD)
	var plus := "+%d" % val
	if r == pl:
		delivered += val
		course_got += val
		score += 20 * val
		if val > 1:
			_stamp("배달 완료 x%d" % val, "DELIVERED x%d" % val, ST_GOOD, pl)
		else:
			_stamp("배달 완료", "DELIVERED", ST_GOOD, pl)
		pop_num(r, plus, P_GREEN)
		_sfx("delivered", null, -4.0)
		_sfx("stamp", null, -6.0)
	elif absf(r.p.x - camx) < hwv:
		pop_num(r, plus, P_GREEN)
		if val > 1:
			_stamp("%s 배달 x%d" % [r.nick, val], "%s DELIVERED x%d" % [r.nick_en.to_upper(), val], ST_INK, r, 0.6)
		else:
			_stamp("%s 배달" % r.nick, "%s DELIVERED" % r.nick_en.to_upper(), ST_INK, r, 0.6)
		_sfx("stamp", r, -4.0)
	return true


## 우체통 깃발·짐 꽂기 애니메이션 (배달된 순간만)
func _mb_tick(dt: float) -> void:
	for mb in mailboxes:
		var t: float = mb.t
		if t <= 0.0:
			continue
		t = maxf(t - dt, 0.0)
		mb.t = t
		var u := 1.0 - t / 0.45
		var ov := 1.0 + sin(u * PI) * 0.35  # 지나쳐 서고 돌아온다
		(mb.flag as Node3D).rotation.z = lerpf(-PI * 0.5, 0.0, minf(u * ov, 1.2))
		var pc: Node3D = mb.parcel
		pc.scale = Vector3.ONE * lerpf(0.2, 1.0, minf(u * 1.6, 1.0))
		if t <= 0.0:
			(mb.flag as Node3D).rotation.z = 0.0
			pc.scale = Vector3.ONE


## HUD 막대용: 우체통 위치 (0..1 진행) 와 찼는지. sr_hud 가 읽는다.
func mailbox_marks() -> Array:
	var out := []
	var x0 := -2.0
	var span := maxf(goal_x - x0, 1.0)
	for mb in mailboxes:
		out.append(Vector2(clampf((float(mb.x) - x0) / span, 0.0, 1.0), 1.0 if mb.full else (-1.0 if int(mb.val) > 1 else 0.0)))
	return out


## 배달 순위 (이번 판 배달 수, 같으면 도착 순서, 그다음 앞선 쪽)
func _deliv_order() -> Array:
	var o: Array = runners.duplicate()
	o.sort_custom(func(a, b):
		if a.got != b.got:
			return a.got > b.got
		var fa: int = a.fin if a.fin >= 0 else 99
		var fb: int = b.fin if b.fin >= 0 else 99
		if fa != fb:
			return fa < fb
		return a.p.x > b.p.x)
	return o


func _in_play(r: Courier) -> bool:
	return r.alive or r.back_t > 0.0


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
		# v12: 판마다 짐을 새로 받는다 (배달할 짐이 넉넉해야 우체통 다툼이 생긴다)
		r.cargo = _load0() + (0 if r.ai else load_bonus)
		r.got = 0
		r.back_t = 0.0
		r.fin = -1
		r.mb_seen = -1
		r.mb_go = false
		r.catch = 0.0
		r.gift = false
		r.far_t = 0.0
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
		r.sway = 0.0
		r.sway_v = 0.0
		r.jig = 0.0
		r.jig_v = 0.0
		r.pvx = 0.0
		r.trail = 0.0
		r.out_t = 0.0
		if r.flash > 0.0:
			r.flash = 0.0
			for g in r.meshes:
				g.material_overlay = null
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
	_mb_reset()
	last_call = -1.0
	end_t = -1.0
	fin_n = 0
	for i in 4:
		wall_n[i] = runners[i].cargo if _in_play(runners[i]) else 0
		wall_lv[i] = float(wall_n[i])
		wall_add[i] = 0.0
	for wp in wall_pops:
		wp.on = false
	rt = 0.0
	lead_t = 0.0
	lead_said = false
	lean = 0.0
	dark_t = 0.0
	dark_on = false
	dark_warn = false
	curtain.visible = false
	fresh = false
	hwv = _want_w()
	_cam_snap()
	phase = "count"
	pt = 1.4
	if menus:
		menus.countdown_tick(0)
	danger = false
	bearer = null
	hold_acc = 0.0
	was_bearer = false
	# no round-start sentence: the route card and the world signs already explain the twist / course
	beep(440.0, 0.12)


func _put_parcel(at: Vector2, who: Courier) -> void:
	for pc in parcels:
		if not pc.on:
			pc.on = true
			pc.p = at
			pc.owner = who
			pc.cd = 0.8 if who else 0.0
			pc.fly = 0.0
			var n: Node3D = pc.node
			n.visible = true
			n.position = Vector3(at.x, at.y + 0.25, 0)
			n.rotation = Vector3.ZERO
			last_put = pc
			return
	last_put = {}


func _step(dt: float) -> void:
	shk = maxf(shk - dt * 2.5, 0.0)
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.7 and pt <= 0.7:
				menus.countdown_tick(1)  # SET: the stamp thud only
			if pt <= 0.0:
				phase = "race"
				menus.countdown_tick(2)
				_sfx("go")  # the whistle on the real start
		"race":
			rt += dt
			journey_time += dt
			course_time += dt
			_race(dt)
		"roundend":
			pt -= dt
			if pt <= 0.0:
				_after_round()
		"title":
			# couriers jog in place behind the logo
			var tj := Time.get_ticks_msec() * 0.012
			for r in runners:
				r.sq = 0.06 * sin(tj + r.col.r * 9.0)
		"tutorial":
			pl.mx = kit_move.x
			pl.i_jump = kit_just("jump")
			pl.i_jheld = kit_held("jump")
			pl.i_drop = kit_just("drop")
			_runner(pl, dt)
			pl.p.x = minf(pl.p.x, 80.0)  # stay on the opening flat
			if pl.p.y < kill_y:
				pl.p = Vector2(camx, 2.0)
				pl.v = Vector2.ZERO
		"perk", "mode", "route":
			pass  # the paper cards (sr_menus) emit the choice
	_update_parcels(dt)
	_mb_tick(dt)
	if mode == "lantern" and phase != "mode" and phase != "title" and phase != "tutorial":
		_pass_lantern()
		_lantern(dt)
		_lights()
	_camera(dt)
	_draw_all()
	if mode_l:
		mode_l.text = "" if phase == "mode" else L("%s · %s %d판 · 짐 %d", "%s · %s · R%d · Box %d") % [_mode_name(mode), L("마지막 배달", "Final Delivery") if finale else _cname(ci), rnd, pl.cargo]
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
	_catchup(dt)
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
	# 화면 왼쪽 끝 (v12): 탈락이 아니다. 짐 하나를 땅에 흘리고(남이 주울 수 있다) 0.6초 뒤 왼쪽 끝에서 다시 들어온다.
	var left := camx - hwv
	# fall-out line kept on the old framing (leader + 2 - vhv - 1), not the feet-at-FEET_Y camera
	var fall_y := camy - (vhv * _feet_k() - 2.0) - vhv - 1.0
	for r in runners:
		if not r.alive:
			if r.back_t > 0.0:
				r.back_t -= dt
				if r.back_t <= 0.0:
					_reenter(r)
			continue
		if r.p.y < kill_y or r.p.y < fall_y:
			_send_back(r, "분실", "MISSING", false)
		elif r.p.x + HW < left + 0.15 and (_opening() or r.immune > 0.0):
			r.p.x = left + 0.16 - HW  # soft wall: no teleport (opening, and the blink right after re-entry)
			r.v.x = maxf(r.v.x, 0.0)
			if r == pl:
				edge_flap = maxf(edge_flap, 0.3)
		elif r.p.x + HW < left + 0.15:
			_edge_moment(r, r == pl)  # 반송은 이제 자주 일어난다: 슬로모션은 내 차례만
			_send_back(r, "반송", "RETURNED", true)
	if mode == "lantern":
		_fog_check(dt)
	if phase != "race":
		return
	# 결승: 처음 도착하면 3초 마감 임박, 그 뒤 판 끝. 이긴 사람 = 이번 판 배달 최다 (같으면 먼저 도착)
	for r in runners:
		if r.alive and r.fin < 0 and r.p.x > goal_x:
			r.fin = fin_n
			fin_n += 1
			if r == pl:
				_sfx("bell", null, -4.0)
		if r.fin >= 0 and r.p.x > goal_x + 26.0:
			r.p.x = goal_x + 26.0  # 결승 뒤 마당 끝에서 멈춘다
			r.v.x = minf(r.v.x, 0.0)
	# v13: 우체통이 다 찼거나 승부가 정해지면 바로 판을 끝낸다 (뒤에서 못 이기는 판을 끝까지 달리지 않게)
	if end_t < 0.0:
		var why := _round_decided()
		if why > 0:
			end_t = DECIDE_T
			if why == 1:
				_stamp("모두 배달", "ALL DELIVERED", ST_INK, null, 1.0)
			else:
				_stamp("승부 결정", "ROUND DECIDED", ST_INK, null, 1.0)
			_sfx("bell", null, -4.0)
	else:
		end_t -= dt
		if end_t <= 0.0:
			_round_over(_deliv_order()[0])
			return
	if last_call < 0.0 and (fin_n > 0 or rt > _round_cap()):
		last_call = LAST_CALL * tn("last")
		_stamp("마감 임박", "LAST CALL", ST_BAD, null, 1.2)
		_sfx("bell")
	elif last_call >= 0.0:
		var before := last_call
		last_call -= dt
		if floorf(before) != floorf(maxf(last_call, 0.0)) and last_call > 0.0:
			beep(880.0, 0.06, 0.0, 0.16)  # 남은 초마다 똑
		if last_call <= 0.0:
			_round_over(_deliv_order()[0])
			return
	# 마지막 생존자도 짐을 들고 결승까지 배달해야 한다. 응용 구간을 건너뛰지 않는다.
	# 1등이면 빠를수록 화면이 쏠린다: 앞이 안 보이니 벽·구덩이는 소리로만
	radar_t -= dt
	if mode == "lantern":
		_lantern_hud(dt)
	elif _leader() == pl:
		if lead_t == 0.0:
			if not lead_said and not _opening():
				lead_said = true
				_stamp("1등석", "FIRST CLASS", ST_GOOD)
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
	if ed < 1.6 and pl.alive and pl.immune <= 0.0:
		danger = true
	elif danger and ed > 4.0:
		danger = false
		_close(pl)
	tick -= dt
	if ed < 3.5 and tick <= 0.0 and pl.alive:
		tick = 0.08 + ed * 0.07
		beep(1200.0 - ed * 150.0, 0.04, 0.0, 0.14)
	gate_said = maxf(gate_said - dt, 0.0)
	var wi := pl.alive and _in_wind(pl)
	if wi and not wind_in:
		beep(320.0, 0.4, 160.0, 0.2)
		_stamp("맞바람", "HEADWIND", ST_INK)
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
	_hit_flash(r, true)
	if r == pl:
		shk = 0.6
	if r.cargo > 0:
		_toss_box(r, Vector3(-6.0, 9.0, 2.0))
		r.cargo -= 1
		if r == pl:
			_stamp("운송 사고", "LOST IN TRANSIT", ST_BAD)
	# v12: 빈손이면 튕겨 나가기만 한다 (탈락 없음)


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
	_toss_box(r, Vector3(-7.0, 8.0, 2.5))
	r.cargo -= 1
	r.immune = 0.7
	var x0 := r.p.x
	_mx(r, left + HW + 0.6 - r.p.x)
	r.vis_dx -= r.p.x - x0  # the body slides back onto the page instead of popping forward
	r.v.x = maxf(r.v.x, 8.0)
	_sfx("damaged", r)
	_burst(Vector3(r.p.x - 0.5, r.p.y + 1.0, 0.6), 3, PARCEL)
	_hit_flash(r, true)
	r.sq = -0.35
	if r == pl:
		shk = maxf(shk, 0.35)
		if r.cargo > 0:
			_stamp("파손", "DAMAGED", ST_BAD)
		else:
			_stamp("마지막 짐", "LAST PARCEL", ST_BAD)


func _out(r: Courier, ko: String, en: String) -> void:
	r.alive = false
	# tumbles off "out of the page" for a moment instead of vanishing (see _draw_all)
	r.node.visible = r.p.y > camy - vhv
	r.out_t = 0.7
	r.out_p = Vector3(r.p.x, r.p.y + HH * 0.375, 0.0)
	r.out_v = Vector3(-5.0, 9.0, 4.0)
	r.trail = 0.0
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
		shk = maxf(shk, 0.25)  # poof + burst + sound say it; no rival stamp over the player's own


## 반송 (v12): 탈락 대신 짐 하나를 땅에 흘리고 (lose_box), 몸은 종이 밖으로 굴러 나갔다가 BACK_T 뒤 왼쪽 끝에서 다시 들어온다.
func _send_back(r: Courier, ko: String, en: String, edge: bool) -> void:
	var had := r.cargo > 0
	if had and r.gift and r.cargo == 1:
		r.cargo = 0  # 돌려받은 짐은 땅에 흘리지 않는다 (가만히 서서 짐을 계속 만들어 내지 못하게)
	elif had:
		r.cargo -= 1
		# 흘린 짐: 화면 왼쪽 끝 조금 안쪽 땅에 놓인다 (뒤따르던 사람이 주울 수 있다, 본인은 잠깐 못 줍는다)
		var px := camx - hwv + 2.6
		var py := _floor_top(px, camy + vhv)
		if py > kill_y:
			_put_parcel(Vector2(px, py), r)
			if not last_put.is_empty():
				last_put.cd = 2.5
				last_put.fly = 0.32
				last_put.from = Vector3(r.p.x, r.p.y + 1.0, 0.0)
				(last_put.node as Node3D).position = last_put.from
	_out(r, "%s -1" % ko if had else ko, "%s -1" % en if had else en)
	if edge:
		r.out_v = Vector3(-8.0, 8.0, 5.0)  # tumbles out of the page, past the edge
	r.back_t = BACK_T


## 왼쪽 끝(짐 벽 안쪽 면)에서 다시 들어온다: 바로 앞 땅을 찾아 세우고 BACK_IMM 동안 깜빡이며 무적.
func _reenter(r: Courier) -> void:
	var x := camx - hwv + 1.0
	var y := -1.0e9
	for k in 20:
		y = _floor_top(x, camy + vhv)
		if y > kill_y:
			break
		x += 0.7
	if y <= kill_y:
		var ld := _leader()
		if ld != null:
			x = ld.p.x - 2.0
			y = ld.p.y
		else:
			y = camy
	r.alive = true
	r.back_t = 0.0
	r.p = Vector2(x, y + 0.05)
	r.v = Vector2(7.0, 4.0)
	r.stun = 0.0
	r.dash = 0.0
	r.immune = BACK_IMM
	r.out_t = 0.0
	r.lost = 0.0
	r.node.visible = true
	r.node.rotation = Vector3.ZERO
	r.node.scale = Vector3.ONE
	r.vis_dx = -1.2  # slides in from behind the parcel wall
	r.mb_seen = -1
	# v13 반송은 하나를 돌려준다: 빈손으로 다시 들어오면 짐 하나 (늘 다시 배달할 수 있다)
	if r.cargo <= 0 and phase == "race":
		r.cargo = 1
		r.gift = true
		if r == pl:
			pop_num(r, "+1", P_GREEN)
	_probe(r)
	_dust_emit(Vector3(x - 0.4, y + 1.0, 0.6), Vector3(2.5, 2.0, 1.0), P_CREAM)
	_dust_emit(Vector3(x - 0.4, y + 0.4, 0.6), Vector3(3.0, 1.2, 1.0), P_PARCEL)
	if r == pl:
		edge_flap = maxf(edge_flap, 0.5)
		_sfx("land", null, -6.0)


## 안전 마감 (v13): 코스 길이에 맞춘 시간이 지나면 아무도 결승에 못 닿아도 LAST CALL (판이 안 끝나는 일이 없게)
func _round_cap() -> float:
	return ROUND_CAP * clampf(goal_x / 420.0, 1.0, 1.8)


## 0 = 아직, 1 = 우체통이 모두 찼다, 2 = 승부가 정해졌다: 배달 1등을 누구도 못 따라잡는다
## (남은 빈 우체통 값을 혼자 다 가져가도). 화면 왼쪽 끝 뒤 우체통은 다시 못 가니 남은 값에서 뺀다.
func _round_decided() -> int:
	if _opening():
		return 0
	var any_free := false
	var free_v := 0
	var left := camx - hwv
	for mb in mailboxes:
		if mb.full:
			continue
		any_free = true
		if float(mb.x) > left - 0.5:
			free_v += int(mb.val)
	if not any_free:
		return 1
	var o := _deliv_order()
	var top: int = o[0].got
	if top <= 0:
		return 0
	for k in range(1, o.size()):
		if int(o[k].got) + free_v >= top:
			return 0
	return 2


## 따라잡기 (v13): 선두보다 뒤일수록 최고 속도 보너스 (CATCH_NEAR 안이면 0, 반 화면 = hwv 뒤면 CATCH_MAX).
## 화면 둘 넘게 뒤에서 FAR_T 넘게 있으면 왼쪽 끝으로 다시 들어온다 (늘 화면 안에서 다툰다).
func _catchup(dt: float) -> void:
	var ld := _leader()
	for r in runners:
		r.catch = 0.0
		if not r.alive or ld == null or r == ld or r.fin >= 0 or _opening():
			r.far_t = 0.0
			continue
		var behind := ld.p.x - r.p.x
		r.catch = clampf((behind - CATCH_NEAR) / maxf(hwv - CATCH_NEAR, 1.0), 0.0, 1.0) * CATCH_MAX * tn("catchup")
		if behind > hwv * 2.0 * FAR_SCREENS:
			r.far_t += dt
			if r.far_t > FAR_T:
				r.far_t = 0.0
				r.poof.visible = true
				r.poof_t = 0.5
				r.poof.position = Vector3(r.p.x, r.p.y + 1.0, 0.5)
				_reenter(r)
		else:
			r.far_t = 0.0


func _round_over(w: Courier) -> void:
	phase = "roundend"
	pt = 1.8
	last_call = -1.0
	end_t = -1.0
	curtain.visible = false
	for r in runners:
		if not r.alive and r.back_t > 0.0:
			r.back_t = 0.0  # 판이 끝났다: 반송 중이던 사람은 다음 판에 다시 선다
	# 순위를 기억해 다음 판 출발 줄로 쓴다 (배달 많은 쪽, 같으면 먼저 도착한 쪽이 앞)
	grid = _deliv_order()
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
		score += 10
		play("win")
		_stamp("최다 배달 · %d" % pl.got, "MOST DELIVERED · %d" % pl.got, ST_GOOD, null, 1.4)
		_burst(Vector3(pl.p.x, pl.p.y + 1.2, 0.6), 8, P_GREEN)
		_burst(Vector3(pl.p.x, pl.p.y + 3.0, 0.6), 6, P_GOLD)
		shk = maxf(shk, 0.15)
	else:
		_sfx("lost")
		_stamp("%s 최다 배달 · %d" % [w.nick, w.got], "%s DELIVERED MOST · %d" % [w.nick_en.to_upper(), w.got], ST_BAD, w, 1.4)


func _after_round() -> void:
	if pl.wins >= WINS:
		score += 50
		_record_course()
		if ci >= COURSES.size() - 1:
			_start_finale()
			return
		var pool := []
		for k in PERKS:
			if not taken.has(k):
				pool.append(k)
		pool.shuffle()
		perk_offer = pool.slice(0, 2)
		phase = "perk"
		menus.show_perks(perk_offer)
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
	phase = "route"
	menus.show_routes(route_offer, _load0() + load_bonus)  # v12: 다음 판은 짐을 새로 받는다


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
	var top := RUN_MAX * tn("speed") * (r.skill if r.ai else spd_mul) * (1.0 - LOAD_SLOW * tn("weight") * _weight(r))
	top *= 1.0 + r.catch  # v13 따라잡기: 뒤처질수록 빠르다
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
	return (24.0 if _overpowered(r) else JUMP_V) * (1.0 if r.ai else jump_mul) * (1.0 - LOAD_JUMP * tn("weight") * _weight(r))


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
		if not _deliver(r):  # 빈 우체통 옆이면 배달, 아니면 던지고 대시
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
	var acc := (GROUND_ACC if r.grounded else AIR_ACC) * (1.3 if r.slip else 1.0) * (0.2 if ice else 1.0) * (1.0 + 2.0 * r.catch)
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
		r.v.x = maxf(r.v.x, RUSH_DASH if _overpowered(r) else DASH_V * tn("dash"))
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
		_land_fx(r, vy0)
	r.sq = move_toward(r.sq, 0.0, dt * 2.5)
	if r.grounded and r.sup == 1:
		r.v.y = PAD_V * (1.0 - LOAD_JUMP * tn("weight") * _weight(r))
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
	r.v.x = maxf(r.v.x, RUSH_DASH if _overpowered(r) else DASH_V * tn("dash"))
	var x := r.p.x - r.face * 1.2
	var y := _floor_top(x, r.p.y + 0.5)
	var from := Vector3(r.p.x - r.face * 0.5, r.p.y + 0.6 + ceili(r.cargo / 2.0) * 0.4 * PACK_K, 0.0)
	if y > r.p.y - 6.0:
		_put_parcel(Vector2(x, y), r)
		if not last_put.is_empty():  # the dropped box flies back spinning to where it lands
			last_put.fly = 0.32
			last_put.from = from
			(last_put.node as Node3D).position = from
	r.trail = DASH_T + 0.3
	_sfx("express", r)
	if r == pl:
		shk = maxf(shk, 0.15)
		fov_kick = maxf(fov_kick, 0.08)
		fx_radial = 0.35


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
				_hit_flash(r, false)
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
			if r.cargo >= _load_max() + (0 if r.ai else load_bonus):
				continue
			if absf(r.p.x - cp.x) < 0.8 and r.p.y - cp.y > -0.6 and r.p.y - cp.y < HH:
				r.cargo += 1
				r.gift = false
				pc.on = false
				(pc.node as Node3D).visible = false
				_sfx("pickup", r)
				if r == pl:
					pop_num(r, "+1", P_GREEN)
				break


func _update_parcels(dt: float) -> void:
	for pc in parcels:
		if pc.on:
			pc.cd = maxf(pc.cd - dt, 0.0)
			var n: Node3D = pc.node
			var fly: float = pc.fly
			if fly > 0.0:  # dropped box arcs back, spinning, then settles where it can be picked up
				fly = maxf(fly - dt, 0.0)
				pc.fly = fly
				var u := 1.0 - fly / 0.32
				var pp: Vector2 = pc.p
				var to := Vector3(pp.x, pp.y + 0.25, 0.0)
				var from: Vector3 = pc.from
				n.position = from.lerp(to, u) + Vector3(0.0, sin(u * PI) * 1.3, 0.0)
				n.rotation.z = u * TAU * 1.25
				if fly <= 0.0:
					n.rotation.z = 0.0
			n.rotation.y += dt * 1.5


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
	# v12 배달: 앞에 빈 우체통이 보이면 한 번 정한다 (보면 속도를 줄여 맞추고 짐 버튼).
	# 같은 '앞이 안 보인다' 규칙: 빠른 1등·화면 가운데보다 한참 앞선 사람·안개 속은 자주 놓친다.
	var aim := false
	if r.cargo > 0 and r.fin < 0:
		var mi := -1
		for i in mailboxes.size():
			var mb: Dictionary = mailboxes[i]
			var d: float = float(mb.x) - r.p.x
			if not mb.full and d > -_mb_r() and d < 6.0:
				mi = i
				break
		if mi >= 0:
			var mb: Dictionary = mailboxes[mi]
			if r.mb_seen != mi:
				r.mb_seen = mi
				var p := minf((0.55 + 2.0 * (r.skill - 0.93)) * tn("ai"), 0.98)  # 기술만큼 (0.5 ~ 0.75), 실험판 배수
				var fast := clampf((absf(r.v.x) - RUN_MAX * 0.7) / (RUN_MAX * 0.4), 0.0, 1.0)
				if _leader() == r:
					p -= 0.35 * fast + 0.1
				if r.p.x - camx > hwv * 0.35:
					p -= 0.25  # 화면 오른쪽 끝: 우체통이 화면에 늦게 들어온다
				if mode == "lantern" and not _lit(float(mb.x)):
					p = 0.12  # 안개 속 우체통은 거의 못 본다
				if dark_on:
					p -= 0.25
				if int(mb.val) > 1:
					p += 0.35  # 금색 우체통 (x3): 경쟁자도 노린다
				r.mb_go = randf() < clampf(p, 0.05, 0.9)
			if r.mb_go:
				aim = true
				var dx: float = float(mb.x) - r.p.x
				if dx > 0.4:
					r.mx = minf(r.mx, clampf(dx / 4.5, 0.3, 1.0))  # 다가가며 늦춘다
				if absf(dx) < _mb_r() * 0.8 and r.drop_cd <= 0.0:
					r.i_drop = true  # 배달 (_runner -> _deliver)
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
	# 짐 버리기: 먼 틈 앞, 또는 화면 끝에 몰렸을 때 (v12: 짐은 배달할 몫이라 끝에 몰려도 덜 던진다)
	if r.cargo >= 2 and r.drop_cd <= 0.0 and not aim:
		var far: bool = r.grounded and _gap_len(r) > _reach(r) * 0.95
		var behind := r.p.x - (camx - hwv) < 3.0
		if far or (behind and randf() < 0.12):
			r.i_drop = true


# ---- 카메라와 그리기 ----
## 화면 반폭 = 경주 중인 모두가 든 짐의 합 (출발 짐 LOAD0 x 4 기준). 반송 중인 사람의 짐도 센다.
func _want_w() -> float:
	var all := 0
	for r in runners:
		if _in_play(r):
			all += r.cargo
	return lerpf(_narrow(), _wide(), clampf(float(all) / float(_load0() * 4), 0.0, 1.0))


func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	var asp := vs.y / maxf(vs.x, 1.0)
	if phase == "race":
		# 화면 폭 = 모두가 든 짐의 합
		hwv = lerpf(hwv, _want_w(), 1.0 - exp(-1.5 * dt))
	vhv = hwv * asp * _wall_k()
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
		# feet land at FEET_Y: more sky / shortcuts above, little dirt above the control deck
		camy = lerpf(camy, lead.p.y + vhv * _feet_k(), 1.0 - exp(-4.0 * dt))
	fov_kick = lerpf(fov_kick, 0.0, 1.0 - exp(-5.0 * dt))
	cam_nudge = lerpf(cam_nudge, 0.0, 1.0 - exp(-5.0 * dt))
	_cam_apply()


## 짐 벽 (v12 B): 화면 양옆 WALL_W px 는 짐 벽이 덮는다. 카메라는 그만큼 넓게 찍어
## 벽 안쪽 면이 정확히 camx -/+ hwv (떨어지는 끝) 에 오게 한다.
func _wall_k() -> float:
	return 720.0 / (720.0 - 2.0 * WALL_W)


## Camera vertical offset (in half-heights) that puts the leader's feet at FEET_Y.
func _feet_k() -> float:
	var h := get_viewport().get_visible_rect().size.y * 0.5
	return (FEET_Y - h) / maxf(h, 1.0)


## FOV kick only widens the view and the nudge only moves the lens: the kill line is still
## camx - hwv, and the torn edge is drawn at its projected screen x (edge_screen_x), so it stays honest.
func _cam_apply() -> void:
	cam.fov = rad_to_deg(2.0 * atan(hwv * (1.0 + fov_kick) * _wall_k() / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + cam_nudge + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


## Put the camera on the start grid right away (no lerp): used at round start and on reset.
func _cam_snap() -> void:
	var vs := get_viewport().get_visible_rect().size
	vhv = hwv * vs.y / maxf(vs.x, 1.0) * _wall_k()
	fov_kick = 0.0
	cam_nudge = 0.0
	lean = 0.0
	var lead := _leader()
	if lead:
		camx = lead.p.x + hwv * 0.18
		camy = lead.p.y + vhv * _feet_k()
	_cam_apply()


func _draw_all() -> void:
	var tm := Time.get_ticks_msec() * 0.001
	var fdt := minf(get_process_delta_time(), 0.05)
	var base_s := (CAM_D - ZR) / CAM_D if mode == "lantern" else 1.0
	for r in runners:
		r.poof.visible = r.poof_t > 0.0
		if r.poof_t > 0.0:
			r.poof_t -= get_process_delta_time()
			var s := 1.0 + (0.5 - r.poof_t) * 6.0
			r.poof.scale = Vector3(s, s, s)
		if r.flash > 0.0:
			r.flash -= fdt
			if r.flash <= 0.0:
				for g in r.meshes:
					g.material_overlay = null
		if not r.alive:
			for s2 in r.streaks:
				s2.visible = false
			for q in r.pips:
				q.visible = false
			for g in r.ghosts:
				g.visible = false
			r.fire.visible = false
			# knocked out: spin and fall "out of the page" past the edge
			if r.out_t > 0.0:
				r.out_t -= fdt
				r.out_v.y -= GRAV * 0.8 * fdt
				r.out_p += r.out_v * fdt
				r.node.position = _fz(r.out_p.x, r.out_p.y, r.out_p.z)
				r.node.rotation.z += fdt * 13.0
				r.node.rotation.x += fdt * 5.0
				r.node.scale = Vector3.ONE * base_s * (1.0 + (0.7 - r.out_t) * 0.35)
				if r.out_t <= 0.0:
					r.node.visible = false
			continue
		var spd := absf(r.v.x)
		# run cycle bob + forward lean by speed; idle breathing when nearly stopped
		var run_k := clampf(spd / 8.0, 0.0, 1.0)
		if r.anim:
			_anim_tick(r, spd, fdt)
			r.run_ph = (r.anim_t - float(ANIM_NEUTRAL[0])) / maxf(r.anim_len, 0.01) * TAU  # bob/sway follow the steps
		elif r.grounded and spd > 1.0:
			r.run_ph += fdt * (6.0 + spd * 0.9)
		var bob := absf(sin(r.run_ph)) * 0.1 * run_k if r.grounded and spd > 1.0 else 0.0
		var sq := r.sq
		if not r.grounded:
			sq = minf(sq, -clampf(absf(r.v.y) / 70.0, 0.0, 0.14))  # stretch in flight
		var sy := 1.0 - sq * 0.45
		var sx := 1.0 + sq * 0.35
		if r.grounded and spd < 1.0:
			sy += sin(tm * 3.2 + r.col.r * 6.0) * 0.022
		r.vis_dx = lerpf(r.vis_dx, 0.0, 1.0 - exp(-18.0 * fdt))
		r.node.position = _fz(r.p.x + r.vis_dx, r.p.y + HH * 0.375 * sy + bob)
		r.node.scale = Vector3(sx, sy, sx) * base_s
		var lean_z := -clampf(r.v.x * (0.022 if r.grounded else 0.012), -0.3, 0.3)
		if r.grounded and spd > 1.0:
			lean_z += sin(r.run_ph * 2.0) * 0.035 * run_k
		r.node.rotation.z = lean_z
		if r.art:
			r.art.rotation.y = 0.0 if r.face > 0.0 else PI
		r.node.visible = r.immune <= 0.0 or fmod(tm, 0.12) < 0.08
		if mode == "lantern" and r.lost > 0.3 and fmod(tm, 0.2) > 0.13:
			r.node.visible = false  # 길을 잃어 가면 깜빡인다
		# parcel stack: spring-damper lag behind acceleration, squash-jiggle on landing
		if fdt > 0.0:
			var ax := clampf((r.v.x - r.pvx) / fdt, -250.0, 250.0)
			r.pvx = r.v.x
			r.sway_v += (-120.0 * r.sway - 9.0 * r.sway_v - ax * 0.035) * fdt
			r.sway = clampf(r.sway + r.sway_v * fdt, -0.22, 0.22)
			r.jig_v += (-160.0 * r.jig - 11.0 * r.jig_v) * fdt
			r.jig = clampf(r.jig + r.jig_v * fdt, -0.3, 0.3)
		# v13: 짐 최대 10개 = 두 줄 더미 (등 쪽 줄부터, 한 층에 둘). 줄이 바뀌지 않게 늘 같은 배치
		for k in r.packs.size():
			var q := r.packs[k]
			q.visible = k < r.cargo
			if q.visible:
				var row := k / 2
				var hk := float(row + 1)
				q.position.x = -(0.5 + 0.44 * float(k % 2)) * VIS_K * r.face + r.sway * hk * 0.45
				q.position.y = -0.12 + row * 0.4 * VIS_K * PACK_K * (1.0 + r.jig)
				q.position.z = -0.04 * float(k % 2)
				q.rotation.z = -r.sway * hk * 0.5
		# dash afterimages
		r.trail = maxf(r.trail - fdt, 0.0)
		for k in r.ghosts.size():
			var g := r.ghosts[k]
			g.visible = r.trail > 0.0 and r.node.visible
			if g.visible:
				var f := clampf(r.trail / 0.3, 0.0, 1.0)
				var gp := _fz(r.p.x - r.face * (0.6 + k * 0.65) * (0.5 + 0.5 * f), r.p.y + BODY_H * 0.5)
				gp.z -= 0.25 + k * 0.05
				g.position = gp
				g.rotation.z = lean_z
				g.scale = Vector3(0.75 * VIS_K, 1.3 * VIS_K, 0.05) * (0.55 + 0.45 * f) * (1.0 - k * 0.1) * base_s
		# running dust: paper scraps behind the feet, more with speed and when climbing ramps
		if r.grounded and spd > 4.0 and absf(r.p.x - camx) < hwv + 1.0 and fdt > 0.0:
			var climb := r.slope * signf(r.v.x) > 0.05
			r.dust_t -= fdt * (1.7 if climb else 1.0)
			if r.dust_t <= 0.0:
				var fk := clampf((spd - 4.0) / 12.0, 0.0, 1.0)
				r.dust_t = lerpf(0.2, 0.06, fk) * (1.0 if r == pl else 1.8)
				var back := -signf(r.v.x)
				_dust_emit(Vector3(r.p.x + back * 0.3, r.p.y + 0.08, 0.5),
					Vector3(back * randf_range(1.0, 2.5 + spd * 0.15), randf_range(1.2, 3.0), randf_range(-0.5, 1.0)),
					P_KRAFT if climb else WHITE)
		r.fire.visible = r.dash > 0.0
		r.fire.position.x = -1.1 * r.face
		r.fire.scale.x = 0.9 + sin(tm * 50.0) * 0.3
		var ln := clampf((spd - 10.0) * 0.6, 0.0, 4.0)
		# 따라잡기 바람: 뒤처진 주자 뒤에 짧은 금빛 줄 (보너스만큼 길게)
		var ck := clampf(r.catch / CATCH_MAX, 0.0, 1.5) if phase == "race" and spd > 3.0 else 0.0
		var catching := ck > 0.25 and ln < ck * 1.6
		if catching:
			ln = ck * 1.6
		for k in 3:
			var s3 := r.streaks[k]
			s3.visible = ln > 0.1
			if s3.visible:
				s3.material_override = mat(B if r.slip else (MB_GOLD if catching else WHITE))
				s3.scale = Vector3(ln * (1.0 - k * 0.2), 0.07, 0.07)
				s3.position = _fz(r.p.x - r.face * (HW + 0.3 + ln * 0.5 + k * 0.2), r.p.y + 0.25 + k * 0.35, 0.5)
		for k in r.pips.size():
			var q := r.pips[k]
			q.visible = k < r.wins
			q.position = _fz(r.p.x - 0.15 + k * 0.3, r.p.y + BODY_H + 0.35)
	marker.visible = pl.alive and MARKER_PHASES.has(phase)
	if marker.visible:
		# box() keeps the mesh size in scale: keep the 0.36 base so it stays ~30 px at any view width
		var mk := maxf(0.36 * (hwv / _narrow()) * 0.8, 0.6)
		marker.scale = Vector3(mk, mk, 0.05)
		# just above the head / top box of the stack (whichever is higher), never floating among posts
		var stack_top := 0.33 + 0.4 * VIS_K * PACK_K * ceili(pl.cargo / 2.0)
		marker.position = _fz(pl.p.x, pl.p.y + maxf(BODY_H, stack_top) + 0.3 + mk * 0.5 + sin(tm * 5.0) * 0.06)
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
	# running / landing dust scraps
	for d in dust:
		var life: float = d.life
		if life <= 0.0:
			continue
		life -= dt
		d.life = life
		var dm: MeshInstance3D = d.node
		if life <= 0.0:
			dm.visible = false
			continue
		var dv: Vector3 = d.v
		dv.y -= 9.0 * dt
		dv *= maxf(1.0 - 2.5 * dt, 0.0)
		d.v = dv
		dm.position += dv * dt
		dm.rotation.z += dt * 8.0
		dm.scale = Vector3(0.22, 0.14, 0.04) * (0.35 + 0.65 * life / float(d.max))
	# lost boxes tumbling away
	for tb in tosses:
		var tl: float = tb.life
		if tl <= 0.0:
			continue
		tl -= dt
		tb.life = tl
		var tn: Node3D = tb.node
		var tv: Vector3 = tb.v
		tv.y -= GRAV * 0.8 * dt
		tb.v = tv
		tn.position += tv * dt
		tn.rotation.z += dt * 11.0
		tn.rotation.x += dt * 4.0
		tn.visible = tl > 0.0
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
	# 왼쪽 화면 끝 경고: the torn paper edge is drawn in screen space by _fx_draw now
	edge_strip.visible = false


## 달리기 그림 (v13): run_loop 시간을 손으로 돌린다. 땅에서 달리면 속도만큼 빨리 (발이 땅을 따라가게),
## 거의 멈추면 다리가 모이는 때까지 걸어 가 서고, 공중에서는 가장 벌어진 보폭에서 멈춘다. 제목 화면은 제자리 뛰기.
func _anim_tick(r: Courier, spd: float, fdt: float) -> void:
	var t := r.anim_t
	var stops: Array = []
	if phase == "title":
		t += fdt
	elif not r.grounded:
		stops = ANIM_STRIDE
	elif spd < 0.8:
		stops = ANIM_NEUTRAL
	else:
		t += fdt * clampf(spd / RUN_MAX * 1.6, 0.4, 2.2)
	if not stops.is_empty():
		# 다음 멈춤 자리까지 앞으로만 간다 (되감지 않아 다리가 튀지 않는다)
		var nxt := 1.0e9
		for s0 in stops:
			var s := float(s0)
			if s < t - 0.0005:
				s += r.anim_len
			nxt = minf(nxt, s)
		t = minf(t + fdt * 2.5, nxt)
	t = fposmod(t, r.anim_len)
	if absf(t - r.anim_t) > 0.0001:
		r.anim_t = t
		r.anim.seek(t, true)


# ---- 밤 등불 모드 ----
## 등불 모드면 주자·표시를 안개 앞(ZR)에 같은 화면 자리로 옮겨 그린다
func _fz(x: float, y: float, z := 0.0) -> Vector3:
	if mode != "lantern":
		return Vector3(x, y, z)
	var k := (CAM_D - ZR) / CAM_D
	return Vector3(camx + (x - camx) * k, camy + (y - camy) * k, ZR)


## 맨 앞 주자가 0.5m 넘게 앞지르면 등불이 넘어간다. 든 사람이 반송되면 다음 1등에게.
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


## 빛 밖 안개에 LOST_T 있으면 짐 하나를 안개에 떨군다. 짐이 없으면 길을 잃고 왼쪽 끝으로 반송 (등불 든 사람은 빼고)
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
			_toss_box(r, Vector3(-3.0, 6.0, 1.0))
			r.cargo -= 1
			_burst(Vector3(r.p.x - 0.5, r.p.y + 1.0, 0.6), 3, PARCEL)
			_sfx("damaged", r)
			_hit_flash(r, true)
			if r == pl:
				shk = maxf(shk, 0.3)
				_stamp("분실", "MISPLACED", ST_BAD)
		else:
			_send_back(r, "주소 불명", "ADDRESS UNKNOWN", false)  # v12: 탈락 대신 왼쪽 끝에서 다시


func _lantern_hud(dt: float) -> void:
	if bearer == pl:
		hold_acc += dt
		if hold_acc >= 1.0:
			hold_acc -= 1.0
			score += 1
		if not was_bearer:
			_stamp("야간 배송", "NIGHT POST", ST_GOOD)
			beep(990.0, 0.1, 1480.0, 0.24)
	elif was_bearer and pl.alive:
		_stamp("가로챔", "HIJACKED", ST_BAD)
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


# ---- speed feel, framing helpers and the "off the screen" moment ----
# Public hooks for other UI code (HUD, deck): play_rect(), speed_ratio(), edge_danger(),
# edge_screen_x(), courier_screen(r, h), pop_num(r, text, col).

## The race playfield on screen (HUD above, control deck below).
func play_rect() -> Rect2:
	return Rect2(0.0, PF_TOP, 720.0, PF_BOT - PF_TOP)


## Player speed feel 0 (cruising) .. 1 (dashing / sliding fast), smoothed.
func speed_ratio() -> float:
	return spd_ratio


## How close the player is to the left kill edge, 0 far .. 1 at the edge, smoothed.
func edge_danger() -> float:
	return edge_warn


## Screen x of the kill line (camx - hwv). About 0 normally; moves right during FOV kick / nudge.
func edge_screen_x() -> float:
	if cam == null:
		return 0.0
	var wp := Vector3(camx - hwv, camy, 0.0)
	if cam.is_position_behind(wp):
		return 0.0
	return cam.unproject_position(wp).x


## Screen position of a courier at feet + h world units up (works in Lantern mode too).
func courier_screen(r: Courier, h := 0.0) -> Vector2:
	if r == null or cam == null:
		return Vector2(360, 640)
	var wp := _fz(r.p.x, r.p.y + h)
	if cam.is_position_behind(wp):
		return Vector2(360, 640)
	return cam.unproject_position(wp)


func _fx_mat(c: Color, a: float) -> StandardMaterial3D:
	var key := "%s_%.2f" % [c.to_html(), a]
	if not _fx_mats.has(key):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.albedo_color = Color(c, a)
		_fx_mats[key] = m
	return _fx_mats[key]


func _fx_setup() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 0  # over the 3D world, under the HUD / deck / stamps
	add_child(layer)
	fx = _FxPad.new()
	fx.draw_fn = _fx_draw
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.position = Vector2.ZERO
	fx.size = Vector2(720, 1280)
	layer.add_child(fx)
	fx_lines.clear()
	for i in FX_LINES:
		var ln := {"x": 0.0, "y": 0.0, "len": 0.0, "sp": 1.0, "w": 4.0}
		_fx_line_respawn(ln, randf_range(0.0, 900.0))
		fx_lines.append(ln)
	wall_pops.clear()
	for i in WALL_POPS:
		wall_pops.append({"on": false, "kind": 0, "p": Vector2.ZERO, "v": Vector2.ZERO, "from": Vector2.ZERO, "to": Vector2.ZERO, "rot": 0.0, "col": P_BLUE, "age": 0.0})
	pops.clear()
	for i in FX_POPS:
		pops.append({"on": false, "r": null, "at": Vector2.ZERO, "text": "", "col": Color.WHITE, "age": 0.0, "w": 0.0})
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	tear_off.resize(TEAR_N)
	for i in TEAR_N:
		tear_off[i] = rng.randf_range(-5.0, 7.0) + (6.0 if i % 5 == 0 else 0.0)
	_tear.resize(TEAR_N + 2)
	_tear_sh.resize(TEAR_N + 2)
	_tear_ln.resize(TEAR_N)


func _fx_line_respawn(ln: Dictionary, x: float) -> void:
	ln.x = x
	ln.y = randf_range(180.0, 900.0)  # playfield band only: never over the rail or the control deck
	ln.len = randf_range(80.0, 220.0)
	ln.sp = randf_range(0.8, 1.35)
	ln.w = randf_range(3.0, 6.0)


func _fx_tick(dt: float) -> void:
	# slow motion is timed in real milliseconds and always restored
	if slowmo_end > 0:
		var racing := phase == "race" or phase == "roundend"
		if Time.get_ticks_msec() >= slowmo_end or over or _rating or not racing:
			Engine.time_scale = 1.0
			slowmo_last = Time.get_ticks_msec()
			slowmo_end = 0
	if over:
		for r in runners:
			if not r.alive and r.out_t > 0.0:
				r.out_t = 0.0
				r.node.visible = false
	if fx == null:
		return
	var want := 0.0
	var warn := 0.0
	var paused := _howto_box != null and _howto_box.visible
	if pl != null and pl.alive and (phase == "race" or phase == "tutorial") and not paused:
		want = clampf((absf(pl.v.x) - 8.0) / 8.0, 0.0, 1.0)
		if pl.dash > 0.0:
			want = 1.0
		if wind_in:
			want = maxf(want, 0.4)
		var ed := pl.p.x - (camx - hwv)
		warn = clampf(1.0 - (ed - 0.6) / 4.4, 0.0, 1.0)
		if tut_skipped and _opening() and rt < 2.0:
			warn = maxf(warn, 0.85)  # skipped the practice: the torn edge itself shows the one rule
	spd_ratio = lerpf(spd_ratio, want, 1.0 - exp(-(14.0 if want > spd_ratio else 4.0) * dt))
	edge_warn = lerpf(edge_warn, warn, 1.0 - exp(-10.0 * dt))
	edge_flap = maxf(edge_flap - dt * 2.4, 0.0)
	edge_hit = maxf(edge_hit - dt * 2.8, 0.0)
	fx_radial = maxf(fx_radial - dt, 0.0)
	var move := (500.0 + 2200.0 * spd_ratio) * dt
	for ln in fx_lines:
		var x: float = ln.x
		x -= move * float(ln.sp)
		ln.x = x
		if x + float(ln.len) < -20.0:
			_fx_line_respawn(ln, 720.0 + randf_range(0.0, 260.0))
	for p in pops:
		if p.on:
			var age: float = p.age
			p.age = age + dt
			if age + dt >= 0.7:
				p.on = false
	_wall_tick(dt)
	fx.queue_redraw()


## "+1" / "-1" that pops above a courier, rises and fades (0.6 s). Pooled, drawn by _fx_draw.
func pop_num(r: Courier, text: String, col: Color) -> void:
	if pops.is_empty():
		return
	var slot: Dictionary = pops[0]
	for p in pops:
		if not p.on:
			slot = p
			break
		if float(p.age) > float(slot.age):
			slot = p
	slot.on = true
	slot.r = r
	slot.at = courier_screen(r, HH + 1.0)
	slot.text = text
	slot.col = col
	slot.age = 0.0
	slot.w = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 44).x


## Brief white (bump) or red (hurt) flash on the courier meshes + two paper scraps.
func _hit_flash(r: Courier, red: bool) -> void:
	if r != pl and absf(r.p.x - camx) > hwv + 1.0:
		return
	r.flash = 0.12
	var m := _fx_mat(P_RED, 0.6) if red else _fx_mat(WHITE, 0.75)
	for g in r.meshes:
		g.material_overlay = m
	_dust_emit(Vector3(r.p.x, r.p.y + 1.0, 0.6), Vector3(randf_range(-3.0, -1.0), randf_range(2.0, 4.0), 1.0), WHITE)
	_dust_emit(Vector3(r.p.x, r.p.y + 0.8, 0.6), Vector3(randf_range(1.0, 3.0), randf_range(2.0, 4.0), 1.0), P_CREAM)


## A lost box flies off the back of the stack, spinning (visual only; cargo is counted elsewhere).
func _toss_box(r: Courier, v: Vector3) -> void:
	if tosses.is_empty() or absf(r.p.x - camx) > hwv + 3.0:
		return
	var tb: Dictionary = tosses[toss_i]
	toss_i = (toss_i + 1) % tosses.size()
	var n: Node3D = tb.node
	n.position = _fz(r.p.x - r.face * 0.5 * VIS_K, r.p.y + 0.33 + mini(r.cargo, 4) * 0.4 * VIS_K, 0.3)
	n.rotation = Vector3.ZERO
	n.visible = true
	tb.v = v + Vector3(r.v.x * 0.3, 0.0, 0.0)
	tb.life = 0.9


func _dust_emit(at: Vector3, v: Vector3, c: Color) -> void:
	if dust.is_empty():
		return
	var d: Dictionary = dust[dust_i]
	dust_i = (dust_i + 1) % dust.size()
	var m: MeshInstance3D = d.node
	m.position = _fz(at.x, at.y, at.z)
	m.rotation = Vector3(0.0, 0.0, randf() * TAU)
	m.material_override = mat(c)
	m.visible = true
	d.v = v
	var life := randf_range(0.3, 0.45)
	d.max = life
	d.life = life


## Landing: paper puffs to both sides + the parcel stack squashes.
func _land_fx(r: Courier, vy0: float) -> void:
	r.jig_v -= clampf(-vy0, 0.0, 30.0) * 0.05
	if absf(r.p.x - camx) > hwv + 1.0:
		return
	var n := 2 if vy0 > -15.0 else 4
	for k in n:
		var side := -1.0 if k % 2 == 0 else 1.0
		_dust_emit(Vector3(r.p.x + side * 0.2, r.p.y + 0.05, 0.5), Vector3(side * randf_range(2.0, 4.0), randf_range(1.0, 2.5), 0.3), WHITE)


## THE SIGNATURE MOMENT: someone is pushed off the left edge of the page.
## strong = slow motion (0.35x for 0.4 real s, throttled) + bigger burst. Player = red edge flash.
func _edge_moment(r: Courier, strong: bool) -> void:
	edge_flap = 1.0
	cam_nudge = minf(cam_nudge, -0.5 if strong else -0.25)
	var at := Vector3(camx - hwv + 0.3, r.p.y + 1.0, 0.6)
	_burst(at, 4 if strong else 2, WHITE)
	for k in (4 if strong else 2):
		_dust_emit(at + Vector3(0.0, k * 0.3, 0.0), Vector3(randf_range(-4.0, -1.0), randf_range(1.0, 5.0), 1.5), P_CREAM if k % 2 == 0 else P_PARCEL)
	if r == pl:
		edge_hit = 1.0
		shk = maxf(shk, 0.35)
	var now := Time.get_ticks_msec()
	if strong and slowmo_end == 0 and now - slowmo_last > 900:
		slowmo_end = now + SLOWMO_MS
		Engine.time_scale = SLOWMO


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _fx_draw(c: Control) -> void:
	if pl == null or cam == null or over:
		return
	var tm := Time.get_ticks_msec() * 0.001
	var racing := phase == "race" or phase == "count" or phase == "roundend" or phase == "tutorial"
	# 1. speed lines: paper streaks across the playfield, tapering to the right
	var n := int(roundf(spd_ratio * FX_LINES))
	if n > 0:
		var a := 0.1 + 0.45 * spd_ratio
		var lc := P_BLUE if wind_in else P_NAVY  # ink streaks read on cream sky and kraft ground
		var py := courier_screen(pl, HH * 0.5).y if pl.alive else -999.0
		for i in n:
			var ln: Dictionary = fx_lines[i]
			var x: float = ln.x
			var y: float = ln.y
			var l: float = float(ln.len) * (0.6 + 0.7 * spd_ratio)
			var w: float = ln.w
			_quad[0] = Vector2(x, y - w * 0.5)
			_quad[1] = Vector2(x + l, y - 0.7)
			_quad[2] = Vector2(x + l, y + 0.7)
			_quad[3] = Vector2(x, y + w * 0.5)
			var la := a * (0.3 if absf(y - py) < 55.0 else 1.0)  # keep the player readable
			c.draw_colored_polygon(_quad, Color(lc, la * 0.35))
	# slipstream: short blue draft lines hugging the player
	if racing and pl.alive and pl.slip:
		var ps := courier_screen(pl, HH * 0.5)
		for k in 3:
			var ox := fposmod(tm * 420.0 + k * 37.0, 90.0)
			var yy := ps.y - 26.0 + k * 22.0
			c.draw_line(Vector2(ps.x - 30.0 - ox, yy), Vector2(ps.x - 70.0 - ox, yy), Color(P_BLUE, 0.7), 4.0)
	# 2. EXPRESS radial burst
	if fx_radial > 0.0 and pl.alive:
		var t := fx_radial / 0.35
		var ps2 := courier_screen(pl, HH * 0.5)
		# a backward cone of thrust lines (not a 360 burst): forward speed, not an explosion
		for i in 6:
			var ang := (PI if pl.face > 0.0 else 0.0) + lerpf(-0.45, 0.45, i / 5.0)
			var d := Vector2(cos(ang), sin(ang))
			var r0 := 50.0 + (1.0 - t) * 90.0
			var r1 := r0 + 30.0 + 60.0 * t
			c.draw_line(ps2 + d * r0, ps2 + d * r1, Color(WHITE, t * 0.9), 2.0 + 5.0 * t)
	# 3. the parcel walls (v12 B) + the torn page edge on the left wall's inner face = the kill line
	if racing:
		_fx_draw_walls(c)
		_fx_draw_edge(c, tm)
	# 4. floating numbers
	for p in pops:
		if not p.on:
			continue
		var age: float = p.age
		var at: Vector2 = p.at
		var who: Courier = p.r
		if who != null and who.alive:
			at = courier_screen(who, HH + 1.0)
			p.at = at
		var s := lerpf(1.45, 1.0, clampf(age / 0.1, 0.0, 1.0))
		var al := 1.0 - clampf((age - 0.45) / 0.25, 0.0, 1.0)
		var col: Color = p.col
		var txt: String = p.text
		var w: float = p.w
		c.draw_set_transform(at + Vector2(0.0, -70.0 * age / 0.7), 0.0, Vector2(s, s))
		c.draw_string_outline(_font, Vector2(-w * 0.5, 15.0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, 12, Color(WHITE, al))
		c.draw_string(_font, Vector2(-w * 0.5, 15.0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(col, al))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fx_draw_edge(c: Control, tm: float) -> void:
	var ex := edge_screen_x()
	var top := -10.0
	var bot := 1290.0
	# off the page: the parcel wall (_fx_draw_walls) fills 0..ex
	# danger tint + white chevrons pulse faster as the player nears the edge
	var warn := edge_warn
	if warn > 0.02 and pl.alive:
		var pulse := 0.5 + 0.5 * sin(tm * TAU * lerpf(1.5, 6.0, warn))
		var a := warn * (0.22 + 0.4 * pulse)
		for i in 6:
			c.draw_rect(Rect2(ex + i * 14.0, PF_TOP, 14.0, PF_BOT - PF_TOP), Color(P_RED, a * (1.0 - i / 6.0)))
		var slide := fposmod(tm * (24.0 + 60.0 * warn), 18.0)
		var ca := clampf(a * 1.8, 0.0, 0.95)
		for k in 7:
			var cy := PF_TOP + 60.0 + k * 105.0
			var cx := ex + 40.0 - slide
			_chev[0] = Vector2(cx + 11.0, cy - 15.0)
			_chev[1] = Vector2(cx - 5.0, cy)
			_chev[2] = Vector2(cx + 11.0, cy + 15.0)
			c.draw_polyline(_chev, Color(P_NAVY, ca * 0.8), 6.0)
	if edge_hit > 0.0:
		c.draw_rect(Rect2(ex, PF_TOP, 70.0, PF_BOT - PF_TOP), Color(P_RED, edge_hit * 0.5))
		c.draw_rect(Rect2(ex + 70.0, PF_TOP, 70.0, PF_BOT - PF_TOP), Color(P_RED, edge_hit * 0.22))
	# torn white paper strip with a soft offset shadow; ripples (flaps) after a knock-off
	var flap := edge_flap
	var left := ex - 6.0  # the torn strip sits on the parcel wall's inner face
	_tear[0] = Vector2(left, top)
	_tear_sh[0] = Vector2(left, top)
	for i in TEAR_N:
		var y := top + (bot - top) * float(i) / float(TEAR_N - 1)
		var x := ex + 11.0 + tear_off[i] + flap * 16.0 * sin(y * 0.03 - tm * 40.0)
		x = maxf(x, left + 6.0)
		_tear[i + 1] = Vector2(x, y)
		_tear_ln[i] = Vector2(x - 3.0, y)
		_tear_sh[i + 1] = Vector2(x + 6.0 + flap * 4.0, y + 3.0)
	_tear[TEAR_N + 1] = Vector2(left, bot)
	_tear_sh[TEAR_N + 1] = Vector2(left, bot)
	c.draw_colored_polygon(_tear_sh, Color(P_NAVY, 0.22))
	c.draw_colored_polygon(_tear, WHITE.lerp(P_RED, edge_hit * 0.5))
	# the torn edge is the danger line: always a thin red rule, stronger as the player nears it
	c.draw_polyline(_tear_ln, Color(P_RED, 0.6 + 0.35 * edge_warn), 4.0)


# ---- 짐 벽 (v12 B): 화면 테두리 = 지금 모두가 든 짐 ----
# 왼쪽 벽 = 나(파랑) 아래 + 빨강 위, 오른쪽 벽 = 민트 아래 + 노랑 위. 벽돌 하나 = 든 짐 하나, 테이프 색 = 주인.
# 짐이 줄면 벽돌이 튀어 나가고 (화면 폭도 함께 좁아진다), 주우면 날아 들어온다. Control 하나의 _draw, 노드 할당 없음.

## Screen x of the right edge of the playfield (camx + hwv). About 720 - WALL_W.
func right_screen_x() -> float:
	if cam == null:
		return 720.0
	var wp := Vector3(camx + hwv, camy, 0.0)
	if cam.is_position_behind(wp):
		return 720.0
	return cam.unproject_position(wp).x


func _wall_side(i: int) -> int:
	return -1 if i < 2 else 1  # -1 왼쪽 벽, 1 오른쪽 벽


## 벽돌 칸의 화면 사각형 (side 벽에서 아래부터 slot 번째)
func _brick_rect(side: int, slot: float, n_side: int) -> Rect2:
	var y0 := PF_BOT - 6.0
	var st := minf(BRICK_H + BRICK_GAP, (y0 - PF_TOP - 20.0) / float(maxi(n_side, 1)))
	var bh := st - BRICK_GAP
	var ex := edge_screen_x() if side < 0 else right_screen_x()
	var w := clampf((ex if side < 0 else 720.0 - ex) - 12.0, 20.0, WALL_W - 8.0)
	var x := 4.0 if side < 0 else 720.0 - 4.0 - w
	return Rect2(x, y0 - (slot + 1.0) * st, w, bh)


func _wall_tick(dt: float) -> void:
	if runners.size() < 4:
		return
	var live := phase == "race" or phase == "roundend" or phase == "tutorial"
	var beeped := false
	for i in 4:
		var r: Courier = runners[i]
		var want := r.cargo if _in_play(r) else 0
		var have := wall_n[i]
		if want != have and live and _in_play(r):
			var side := _wall_side(i)
			var below := 0.0
			var n_side := 0
			for k in 4:
				if _wall_side(k) == side:
					n_side += maxi(wall_n[k], 0)
					if k < i:
						below += wall_lv[k]
			if want < have:
				for d in have - want:  # 벽돌이 안쪽으로 톡 튀어 나가며 흐려진다
					var br := _brick_rect(side, below + float(have - 1 - d), n_side)
					_wall_pop(0, br.get_center(), Vector2(-side * randf_range(140.0, 240.0), -randf_range(260.0, 400.0)), r.col)
				if not beeped:
					beeped = true
					beep(640.0, 0.04, 380.0, 0.06)
			else:
				for d in want - have:  # 주운 짐: 배달부에게서 벽으로 날아 들어온다
					var br := _brick_rect(side, below + float(have + d), n_side + d + 1)
					var fe := _wall_pop(1, courier_screen(r, HH), Vector2.ZERO, r.col)
					if not fe.is_empty():
						fe.to = br.get_center()
				wall_add[i] = 0.32
		wall_n[i] = want
		if live and _in_play(r):
			wall_lv[i] = lerpf(wall_lv[i], float(want), 1.0 - exp(-12.0 * dt))
		else:
			wall_lv[i] = float(want)
		wall_add[i] = maxf(wall_add[i] - dt, 0.0)
	for e in wall_pops:
		if not e.on:
			continue
		e.age = float(e.age) + dt
		if int(e.kind) == 0:
			var v: Vector2 = e.v
			v.y += 1500.0 * dt
			e.v = v
			var pp: Vector2 = e.p
			e.p = pp + v * dt
			e.rot = float(e.rot) + dt * 9.0 * signf(v.x)
			if float(e.age) > 0.7:
				e.on = false
		elif float(e.age) > 0.3:
			e.on = false


func _wall_pop(kind: int, at: Vector2, v: Vector2, col: Color) -> Dictionary:
	var slot: Dictionary = {}
	for e in wall_pops:
		if not e.on:
			slot = e
			break
	if slot.is_empty():
		return {}
	slot.on = true
	slot.kind = kind
	slot.p = at
	slot.from = at
	slot.to = at
	slot.v = v
	slot.rot = 0.0
	slot.col = col
	slot.age = 0.0
	return slot


## 종이 소포 벽돌 하나 (v13: 폰에서 읽히게): 그림자 + 남색 테두리 + 밝은 골판지 몸 + 아래 그늘
## + 주인 색 굵은 테이프 가로띠(흰 테두리) + 세로 봉합 테이프
func _draw_brick(c: Control, br: Rect2, col: Color, a: float) -> void:
	c.draw_rect(Rect2(br.position + Vector2(3, 4), br.size), Color(P_NAVY, 0.35 * a))
	c.draw_rect(br.grow(2.0), Color(P_NAVY, a))
	c.draw_rect(br, Color(P_KRAFT, a))
	c.draw_rect(Rect2(br.position.x, br.end.y - 6.0, br.size.x, 6.0), Color(P_PARCEL, a))
	c.draw_rect(Rect2(br.position.x, br.position.y, br.size.x, 3.0), Color(P_CREAM, a * 0.7))
	c.draw_rect(Rect2(br.get_center().x - 2.0, br.position.y, 4.0, br.size.y), Color(P_KRAFT_SH, a))
	var th := clampf(br.size.y * 0.3, 7.0, 16.0)
	var tape := Rect2(br.position.x, br.get_center().y - th * 0.5, br.size.x, th)
	c.draw_rect(tape.grow_individual(0, 2, 0, 2), Color(P_CREAM, a))
	c.draw_rect(tape, Color(col, a))


func _fx_draw_walls(c: Control) -> void:
	if runners.size() < 4:
		return
	var ex := edge_screen_x()
	var rx := right_screen_x()
	# 벽 바탕 (v13): 크림 종이 띠 + 골판지 결 + 안쪽 남색 선. 배경 그림·하늘과 섞이지 않는다
	c.draw_rect(Rect2(-2.0, -10.0, ex + 2.0, 1300.0), P_CREAM)
	c.draw_rect(Rect2(rx, -10.0, 722.0 - rx, 1300.0), P_CREAM)
	for k in 3:
		var fx_l := 8.0 + k * 16.0
		if fx_l < ex - 4.0:
			c.draw_rect(Rect2(fx_l, -10.0, 3.0, 1300.0), Color(P_KRAFT, 0.55))
		var fx_r := 720.0 - 11.0 - k * 16.0
		if fx_r > rx + 4.0:
			c.draw_rect(Rect2(fx_r, -10.0, 3.0, 1300.0), Color(P_KRAFT, 0.55))
	c.draw_rect(Rect2(ex - 4.0, -10.0, 4.0, 1300.0), P_NAVY)
	c.draw_rect(Rect2(rx, -10.0, 4.0, 1300.0), P_NAVY)
	for side in [-1, 1]:
		var n_side := 0
		for k in 4:
			if _wall_side(k) == side:
				n_side += wall_n[k]
		var below := 0.0
		for i in 4:
			if _wall_side(i) != side:
				continue
			var col: Color = runners[i].col
			for k in wall_n[i]:
				var br := _brick_rect(side, below + float(k), n_side)
				if k == wall_n[i] - 1 and wall_add[i] > 0.0:  # 막 들어온 벽돌: 작게 시작해 톡 부푼다
					var u := 1.0 - wall_add[i] / 0.32
					var s := lerpf(0.3, 1.0, u) + sin(u * PI) * 0.18
					var ctr := br.get_center() + Vector2(0, -sin(u * PI) * 14.0)
					br = Rect2(ctr - br.size * s * 0.5, br.size * s)
				_draw_brick(c, br, col, 1.0)
			below += wall_lv[i]
	# 오른쪽 벽 안쪽 면: 그림자 (왼쪽은 찢긴 종이 끝이 덮는다)
	c.draw_rect(Rect2(rx - 7.0, -10.0, 7.0, 1300.0), Color(P_NAVY, 0.16))
	for e in wall_pops:
		if not e.on:
			continue
		var bw := WALL_W - 10.0
		var bh := BRICK_H * 0.8
		if int(e.kind) == 0:  # 빠지는 벽돌: 안쪽으로 톡 튀며 돌고 흐려진다
			var a := 1.0 - clampf((float(e.age) - 0.35) / 0.35, 0.0, 1.0)
			c.draw_set_transform(e.p, float(e.rot), Vector2.ONE)
			_draw_brick(c, Rect2(-bw * 0.5, -bh * 0.5, bw, bh), e.col, a)
		else:
			var u := clampf(float(e.age) / 0.3, 0.0, 1.0)
			var fr: Vector2 = e.from
			var to: Vector2 = e.to
			var at: Vector2 = fr.lerp(to, u) + Vector2(0, -sin(u * PI) * 80.0)
			var s := lerpf(0.6, 0.9, u)
			c.draw_set_transform(at, u * TAU * 0.5, Vector2(s, s))
			_draw_brick(c, Rect2(-bw * 0.5, -bh * 0.5, bw, bh), e.col, 1.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
