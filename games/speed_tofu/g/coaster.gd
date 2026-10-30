extends Tofu
## 롤러코스터 정비공(3인칭 등뒤 위). 왼손 조이스틱으로 달리고, '고치기'를 잠깐 누르고 있으면 부서진 레일·떨어진 짐·갈림길 레버를 고친다.
## 멈출 수 없는 코스터가 뒤에서 달려온다. 고치기 전에 지나가면 탈선, 레일 위에서 닿으면 치인다.
## 숲 코스터 → 해변 루프(갈림길·루프) → 산꼭대기 낙하(체인 언덕·급강하). 공원 끝에서 도구 하나를 밟아 고른다.

const HALF := 3.6  # 길 반폭
const D0 := -24.0  # 길 시작 (코스터 뒤쪽)
const REVEAL := 46.0  # 코스터가 이만큼 다가오면 망가진다
const NEAR := 22.0  # 내가 이만큼 다가가도 보인다
const NCARS := 4
const CAR_GAP := 1.9
const LOOP_R := 4.2
const RUN := 8.6
const WOOD := Color("c8a27a")
const STONE := Color("ced4da")
const LEAF := Color("8ce99a")
const UPG := {
	"fast": ["빠른 손", GOOD],
	"dash": ["질주 신발", B],
	"rail": ["예비 레일", D],
	"reach": ["긴 팔", C],
}
const ZONES := [
	{"name": "숲 코스터", "len": 360.0, "base": 7.6, "ground": Color("b2f2bb"), "deco": "tree", "junk": "통나무",
		"xa": [5.0, 0.018, 2.0, 0.047, 1.0],
		"prof": [[-40.0, 2.0], [50.0, 2.0], [90.0, 5.0], [130.0, 1.5], [190.0, 4.0], [240.0, 1.0], [300.0, 2.5], [420.0, 2.0]],
		"loops": [], "lift": [],
		"haz": [[40, "gap"], [68, "junk"], [94, "gap"], [118, "gap"], [146, "junk"], [172, "gap"], [190, "junk"],
			[214, "gap"], [238, "gap"], [258, "junk"], [282, "gap"], [300, "junk"], [318, "gap"]]},
	{"name": "해변 루프", "len": 400.0, "base": 8.4, "ground": Color("ffec99"), "deco": "beach", "junk": "공",
		"xa": [6.0, 0.014, 1.5, 0.05, 0.5],
		"prof": [[-40.0, 1.5], [60.0, 1.5], [100.0, 4.0], [160.0, 4.0], [200.0, 1.0], [240.0, 3.0], [300.0, 3.0], [340.0, 1.0], [460.0, 1.5]],
		"loops": [130.0, 270.0], "lift": [],
		"haz": [[40, "gap"], [64, "switch", -1], [88, "junk"], [110, "gap"], [146, "gap"], [164, "switch", 1], [190, "junk"],
			[206, "gap"], [226, "switch", -1], [246, "gap"], [288, "gap"], [304, "junk"], [322, "switch", 1], [342, "gap"], [358, "gap"]]},
	{"name": "산꼭대기 낙하", "len": 440.0, "base": 9.0, "ground": Color("e9ecef"), "deco": "peak", "junk": "바위",
		"xa": [4.0, 0.02, 3.0, 0.035, 2.0],
		"prof": [[-40.0, 2.0], [8.0, 2.0], [60.0, 20.0], [70.0, 20.0], [112.0, 2.0], [140.0, 4.0], [178.0, 14.0], [192.0, 14.0],
			[222.0, 1.5], [258.0, 3.0], [296.0, 11.0], [306.0, 11.0], [340.0, 1.5], [380.0, 5.0], [420.0, 2.0], [500.0, 2.0]],
		"loops": [], "lift": [[8.0, 64.0], [140.0, 182.0]],
		"haz": [[30, "gap"], [46, "junk"], [76, "gap"], [90, "gap"], [102, "junk"], [124, "switch", 1], [160, "gap"], [186, "junk"],
			[204, "gap"], [214, "gap"], [240, "switch", -1], [270, "gap"], [290, "junk"], [316, "gap"], [328, "gap"],
			[352, "switch", 1], [376, "gap"], [394, "junk"], [410, "gap"]]},
]

var zi := 0
var lap := 0
var mul := 1.0
var phase := "run"  # run / crash / shop / next
var level: Node3D
var Z: Dictionary = {}
var loops: Array = []
var cars: Array[Node3D] = []
var arms: Array[Node3D] = []
var car_v: Array[Vector3] = []
var car_s: Array[Vector3] = []
var ca := 0.0  # 코스터 앞머리의 레일 길이 (루프 포함)
var cv := 0.0
var go_t := 0.0
var crash_t := 0.0
var crash_hit := false
var me: Node3D
var me_body: Node3D
var warn: MeshInstance3D
var mp := Vector3.ZERO
var me_v := Vector3.ZERO
var dash_t := 0.0
var dash_cd := 0.0
var rails_left := 0
var owned := {}
var haz: Array[Dictionary] = []
var pads: Array[Node3D] = []
var pad_kind: Array = []
var pad_t := 0.0
var next_t := 0.0
var clock := 0.0
var roar_t := 0.0
var step_t := 0.0
var tick_t := 0.0
var clack_t := 0.0
var prev_front := 0.0
var cam_base := Vector3.ZERO
var cam_ready := false
var near_k := 0.0


func _setup() -> void:
	howto = "코스터 정비공. 멈출 수 없는 롤러코스터가 뒤에서 달려온다.\n왼손 조이스틱으로 앞질러 달리고, 빨간 레일·떨어진 짐·갈림길 레버 앞에서 '고치기'를 잠깐 누르고 있으면 고친다.\n고치기 전에 코스터가 지나가면 탈선, 레일 위에서 코스터에 닿으면 치인다.\n공원 끝에서 도구 하나를 밟아 고른다."
	time_limit = 0.0
	cam.fov = 72.0
	cam.far = 130.0
	kit_stick()
	kit_button("fix", "고치기", Vector2(580, 1090), 110.0, GOOD)


func _reset() -> void:
	owned = {"fast": 0, "dash": 0, "rail": 0, "reach": 0}
	zi = 0
	lap = 0
	mul = 1.0
	level = null
	_build()


func _buttons() -> void:
	_btns.erase("dash")
	_btns.erase("rail")
	if owned["dash"] > 0:
		kit_button("dash", "질주", Vector2(612, 872), 72.0, B)
	if owned["rail"] > 0:
		kit_button("rail", "레일 %d" % rails_left, Vector2(440, 900), 66.0, D)


# ---- 길 ----
func tx(d: float) -> float:
	var a: Array = Z["xa"]
	return a[0] * sin(d * a[1]) + a[2] * sin(d * a[3] + a[4])


func ty(d: float) -> float:
	var P: Array = Z["prof"]
	if d <= P[0][0]:
		return P[0][1]
	for i in P.size() - 1:
		if d <= P[i + 1][0]:
			var k: float = (d - P[i][0]) / (P[i + 1][0] - P[i][0])
			k = 0.5 - 0.5 * cos(k * PI)
			return lerpf(P[i][1], P[i + 1][1], k)
	return P[P.size() - 1][1]


func tp(d: float) -> Vector3:
	return Vector3(tx(d), ty(d), -d)


func tdir(d: float) -> Vector3:
	return (tp(d + 0.5) - tp(d - 0.5)).normalized()


func _sd(d: float) -> Vector3:
	return tdir(d).cross(Vector3.UP).normalized()


func _in_lift(d: float) -> bool:
	for r in Z["lift"]:
		if d >= r[0] and d <= r[1]:
			return true
	return false


func _stop_a() -> float:
	return Z["len"] - 3.0 + TAU * LOOP_R * loops.size()


## 레일 길이 a 의 [위치, 앞, 옆, 땅 거리 d, 루프 안]
func _pose(a: float) -> Array:
	var r := a
	for d0 in loops:
		var dd: float = d0
		if r < dd:
			break
		if r < dd + TAU * LOOP_R:
			var th := (r - dd) / LOOP_R
			var f0 := tdir(dd)
			f0.y = 0.0
			f0 = f0.normalized()
			var sd := f0.cross(Vector3.UP).normalized()
			var pos := tp(dd) + f0 * LOOP_R * sin(th) + Vector3.UP * LOOP_R * (1.0 - cos(th))
			var fw := (f0 * cos(th) + Vector3.UP * sin(th)).normalized()
			return [pos, fw, sd, dd + LOOP_R * sin(th), true]
		r -= TAU * LOOP_R
	var fw2 := tdir(r)
	return [tp(r), fw2, fw2.cross(Vector3.UP).normalized(), r, false]


func _front_d() -> float:
	return _pose(ca)[3]


## p0→p1 을 잇는 긴 상자 (sd 옆, off 옆으로, yoff 위로)
func _seg(p0: Vector3, p1: Vector3, sd: Vector3, off: float, yoff: float, w: float, h: float, col: Color, ext := 0.04) -> MeshInstance3D:
	var dv := p1 - p0
	var ln := dv.length()
	var fw := dv / ln
	var up := (-fw).cross(sd)
	var m := box(Vector3.ZERO, Vector3.ONE, col, level)
	m.transform = Transform3D(Basis(sd, up, -fw) * Basis.from_scale(Vector3(w, h, ln + ext)), (p0 + p1) * 0.5 + sd * off + up * yoff)
	return m


func _rail(a: float, b: float, s: float) -> MeshInstance3D:
	var p0 := tp(a)
	var p1 := tp(b)
	return _seg(p0, p1, (p1 - p0).normalized().cross(Vector3.UP).normalized(), s * 0.6, 0.12, 0.13, 0.16, B)


# ---- 공원 하나 만들기 ----
func _build() -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	Z = ZONES[zi]
	loops = Z["loops"]
	var ln: float = Z["len"]
	var rng := RandomNumberGenerator.new()
	rng.seed = zi * 100 + 7
	box(Vector3(0, -1.5, -ln * 0.5), Vector3(160, 1.0, ln + 160.0), Z["ground"], level)
	# 걷는 길 + 줄무늬 연석 + 기둥
	var d := D0
	var k := 0
	while d < ln + 16.0:
		var p0 := tp(d)
		var p1 := tp(d + 6.0)
		var sd := (p1 - p0).normalized().cross(Vector3.UP).normalized()
		_seg(p0, p1, sd, 0.0, -0.18, HALF * 2.0 + 0.4, 0.3, SOFT, 0.3)
		for s in [-1.0, 1.0]:
			_seg(p0, p1, sd, s * (HALF + 0.15), -0.03, 0.3, 0.3, A if k % 2 == 0 else WHITE, 0.0)
		if k % 2 == 0 and p0.y > 0.3:
			var hh := p0.y + 0.7
			box(Vector3(p0.x, -1.0 + hh * 0.5, p0.z), Vector3(2.4, hh, 0.6), WHITE, level)
		d += 6.0
		k += 1
	# 레일 (부서질 자리는 2m 조각으로 따로)
	var gaps := {}
	for hz in Z["haz"]:
		if hz[1] == "gap":
			gaps[int(hz[0])] = true
	var gap_nodes := {}
	var end_d := ln + 2.0
	d = D0
	while d < end_d:
		var di := int(round(d))
		if gaps.has(di):
			gap_nodes[di] = [_rail(d, d + 2.0, -1.0), _rail(d, d + 2.0, 1.0)]
			d += 2.0
			continue
		var e := d + 2.0
		while e < d + 6.0 and e < end_d and not gaps.has(int(round(e))):
			e += 2.0
		_rail(d, e, -1.0)
		_rail(d, e, 1.0)
		d = e
	d = D0
	while d < end_d:
		_seg(tp(d - 0.17), tp(d + 0.17), _sd(d), 0.0, 0.03, 1.7, 0.08, WOOD, 0.0)
		d += 3.0
	box(tp(ln + 2.0) + Vector3(0, 0.5, 0), Vector3(2.0, 1.0, 0.5), BAD, level)  # 끝 범퍼
	box(tp(-4.0) + Vector3(0, 3.4, 0), Vector3(6.0, 0.3, 9.0), C, level)  # 출발 역 지붕
	box(tp(ln - 6.0) + Vector3(0, 3.4, 0), Vector3(6.0, 0.3, 9.0), GOOD, level)  # 도착 역 지붕
	# 루프
	for d0 in loops:
		var dd: float = d0
		var base := tp(dd)
		var f0 := tdir(dd)
		f0.y = 0.0
		f0 = f0.normalized()
		var lsd := f0.cross(Vector3.UP).normalized()
		var pts: Array[Vector3] = []
		for i in 29:
			var th := TAU * i / 28.0
			pts.append(base + f0 * LOOP_R * sin(th) + Vector3.UP * LOOP_R * (1.0 - cos(th)))
		for i in 28:
			_seg(pts[i], pts[i + 1], lsd, -0.6, 0.12, 0.13, 0.16, B)
			_seg(pts[i], pts[i + 1], lsd, 0.6, 0.12, 0.13, 0.16, B)
			_seg(pts[i], pts[i + 1], lsd, 0.0, 0.03, 1.5, 0.08, WOOD)
		for s in [-1.0, 1.0]:
			box(base + lsd * s * 1.7 + Vector3.UP * LOOP_R, Vector3(0.4, LOOP_R * 2.0 + 1.0, 0.4), WHITE, level)
		box(base + Vector3.UP * (LOOP_R * 2.0 + 0.6), Vector3(3.8, 0.3, 0.4), WHITE, level)
	# 망가질 것들
	haz.clear()
	for hz in Z["haz"]:
		var h := {"d": float(hz[0]), "kind": hz[1], "side": float(hz[2]) if hz.size() > 2 else 1.0,
			"st": 0, "prog": 0.0, "nodes": [], "fall": 0.0, "fly": 0.0, "fv": Vector3.ZERO}
		if hz[1] == "gap":
			var pr: Array = gap_nodes[int(hz[0])]
			var sd := _sd(h.d + 1.0)
			h.nodes = pr
			h.base = [pr[0].transform, pr[1].transform]
			var br := []
			for j in 2:
				var T: Transform3D = pr[j].transform
				var sg := -1.0 if j == 0 else 1.0
				T.basis = Basis(Vector3.UP, sg * 0.45) * Basis(sd, 0.35) * T.basis
				T.origin += Vector3.UP * 0.3 + sd * sg * 0.35
				br.append(T)
			h.broken = br
		elif hz[1] == "junk":
			_make_junk(h)
		else:
			_make_switch(h)
			h.st = 1
		haz.append(h)
	# 고르는 발판 (도착 뒤에만 보인다)
	pads.clear()
	var pe := ln + 8.0
	for i in 3:
		var pn := Node3D.new()
		pn.position = tp(pe) + _sd(pe) * (float(i) - 1.0) * 2.9
		level.add_child(pn)
		box(Vector3(0, 0.1, 0), Vector3(2.4, 0.25, 2.4), WHITE, pn)
		box(Vector3(0, 1.3, 0), Vector3(0.7, 0.7, 0.7), WHITE, pn)
		pn.visible = false
		pads.append(pn)
	_deco(rng)
	_make_me()
	_make_cars()
	# 시작 상태
	phase = "run"
	ca = 0.0
	cv = 0.0
	go_t = 2.0
	crash_t = 0.0
	crash_hit = false
	mp = tp(10.0) + _sd(10.0) * 2.2
	me.position = mp
	dash_t = 0.0
	dash_cd = 0.0
	rails_left = 2 * owned["rail"]
	pad_t = 0.0
	prev_front = 0.0
	cam_ready = false
	near_k = 0.0
	_buttons()
	_place_cars()
	msg(("%d바퀴 " % (lap + 1) if lap > 0 else "") + Z["name"], 1.8)


func _make_junk(h: Dictionary) -> void:
	var dd: float = h.d
	var fw := tdir(dd)
	var sd := _sd(dd)
	var up := (-fw).cross(sd)
	var sz := Vector3(2.6, 0.55, 0.55)
	var col := A
	if Z["junk"] == "공":
		sz = Vector3(1.0, 1.0, 1.0)
		col = C
	elif Z["junk"] == "바위":
		sz = Vector3(1.5, 1.1, 1.3)
		col = STONE
	var m := box(Vector3.ZERO, Vector3.ONE, col, level)
	var T := Transform3D(Basis(sd, up, -fw) * Basis.from_scale(sz), tp(dd) + up * (sz.y * 0.5 + 0.1))
	m.transform = T
	m.visible = false
	h.nodes = [m]
	h.rest = T


func _make_switch(h: Dictionary) -> void:
	var d0: float = h.d
	var s: float = h.side
	var prev := tp(d0)
	for i in range(1, 8):
		var dd := d0 + i * 2.0
		var p := tp(dd) + _sd(dd) * s * 0.045 * pow(i * 2.0, 2.0)
		var sd := (p - prev).normalized().cross(Vector3.UP).normalized()
		_seg(prev, p, sd, -0.6, 0.12, 0.13, 0.16, B)
		_seg(prev, p, sd, 0.6, 0.12, 0.13, 0.16, B)
		_seg(prev, p, sd, 0.0, 0.03, 1.7, 0.08, WOOD)
		prev = p
	box(prev + Vector3(0, 0.6, 0), Vector3(1.8, 1.2, 0.5), BAD, level)  # 막다른 끝
	var block := _seg(tp(d0 + 2.5), tp(d0 + 2.9), _sd(d0 + 2.7), 0.0, 0.35, 1.9, 0.3, BAD, 0.0)  # 본선이 막혀 있다
	var lp := tp(d0 - 3.0) + _sd(d0 - 3.0) * s * 2.6
	box(lp + Vector3(0, 0.5, 0), Vector3(0.3, 1.0, 0.3), INK, level)
	var pivot := Node3D.new()
	pivot.position = lp + Vector3(0, 1.0, 0)
	level.add_child(pivot)
	box(Vector3(0, 0.45, 0), Vector3(0.16, 0.9, 0.16), BAD, pivot)
	pivot.rotation.z = -0.7 * s
	var lamp := box(lp + Vector3(0, 2.1, 0), Vector3(0.4, 0.4, 0.4), BAD, level)
	h.nodes = [block, pivot, lamp]
	h.lever = lp


func _deco(rng: RandomNumberGenerator) -> void:
	var ln: float = Z["len"]
	var kind: String = Z["deco"]
	if kind == "beach":
		box(Vector3(-78, -1.1, -ln * 0.5), Vector3(110, 1.0, ln + 160.0), B, level)
	var d := -20.0
	while d < ln + 40.0:
		for s in [-1.0, 1.0]:
			if kind == "beach" and s < 0.0:
				continue
			var x: float = tx(d) + s * (HALF + 3.0 + rng.randf() * 14.0)
			var z := -d - rng.randf() * 4.0
			if kind == "tree":
				var hg := rng.randf_range(1.5, 3.0)
				box(Vector3(x, -1.0 + hg * 0.5, z), Vector3(0.5, hg, 0.5), WOOD, level)
				var cs := rng.randf_range(1.8, 3.0)
				box(Vector3(x, -1.0 + hg + cs * 0.5, z), Vector3(cs, cs, cs), GOOD if rng.randf() < 0.6 else LEAF, level)
			elif kind == "beach":
				box(Vector3(x, 0.0, z), Vector3(0.15, 2.0, 0.15), WHITE, level)
				box(Vector3(x, 1.0, z), Vector3(2.4, 0.2, 2.4), [A, C, BAD, D][rng.randi() % 4], level)
			else:
				var rs := rng.randf_range(1.5, 4.0)
				box(Vector3(x, -1.0 + rs * 0.4, z), Vector3(rs, rs * 0.8, rs * 1.1), STONE, level)
		d += 7.0
	if kind == "peak":
		for i in 12:
			var s := -1.0 if i % 2 == 0 else 1.0
			var w := rng.randf_range(10.0, 18.0)
			var hg := rng.randf_range(18.0, 36.0)
			var p := Vector3(s * rng.randf_range(34.0, 60.0), -1.0 + hg * 0.5, -rng.randf_range(-20.0, ln + 40.0))
			box(p, Vector3(w, hg, w), STONE, level)
			box(p + Vector3(0, hg * 0.5, 0), Vector3(w * 0.7, 2.0, w * 0.7), WHITE, level)


func _make_me() -> void:
	me = Node3D.new()
	level.add_child(me)
	me_body = Node3D.new()
	me.add_child(me_body)
	box(Vector3(0, 0.4, 0), Vector3(0.5, 0.6, 0.34), ME, me_body)
	box(Vector3(0, 0.98, 0), Vector3(0.62, 0.6, 0.4), A, me_body)
	box(Vector3(0, 1.48, 0), Vector3(0.38, 0.38, 0.38), SOFT, me_body)
	box(Vector3(0, 1.72, 0), Vector3(0.5, 0.14, 0.5), D, me_body)
	box(Vector3(0.4, 0.95, -0.15), Vector3(0.12, 0.12, 0.55), WHITE, me_body)  # 렌치
	warn = box(Vector3(0, 2.5, 0), Vector3(0.4, 0.4, 0.4), BAD, me)
	warn.visible = false


func _make_cars() -> void:
	cars.clear()
	arms.clear()
	car_v.clear()
	car_s.clear()
	var cols := [BAD, D, C, GOOD]
	for i in NCARS:
		var c := Node3D.new()
		level.add_child(c)
		box(Vector3(0, 0.12, 0), Vector3(1.3, 0.2, 1.3), INK, c)
		box(Vector3(0, 0.48, 0), Vector3(1.5, 0.6, 1.7), cols[i], c)
		box(Vector3(0, 0.95, 0.72), Vector3(1.5, 0.5, 0.25), cols[i], c)
		if i == 0:
			box(Vector3(0, 0.6, -1.0), Vector3(1.3, 0.5, 0.4), WHITE, c)
		for sx in [-0.38, 0.38]:
			box(Vector3(sx, 1.05, 0.1), Vector3(0.34, 0.34, 0.34), SOFT, c)
			for ax in [-0.17, 0.17]:
				var arm := Node3D.new()
				arm.position = Vector3(sx + ax, 1.0, 0.1)
				c.add_child(arm)
				box(Vector3(0, 0.33, 0), Vector3(0.09, 0.6, 0.09), SOFT, arm)
				arm.rotation.z = ax * 2.2
				arms.append(arm)
		cars.append(c)
		car_v.append(Vector3.ZERO)
		car_s.append(Vector3.ZERO)


func _place_cars() -> void:
	for i in NCARS:
		var P := _pose(ca - i * CAR_GAP)
		var fw: Vector3 = P[1]
		var sd: Vector3 = P[2]
		cars[i].transform = Transform3D(Basis(sd, (-fw).cross(sd), -fw), P[0])


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	clock += dt
	if phase == "run":
		_run_coaster(dt)
		_move_me(dt)
		if phase == "run":
			_hazards(dt)
		if phase == "run":
			_checks()
		gauge(near_k, GOOD.lerp(BAD, near_k))
	elif phase == "crash":
		_crash(dt)
	elif phase == "shop":
		_move_me(dt)
		_shop(dt)
	elif phase == "next":
		next_t -= dt
		if next_t <= 0.0:
			_build()
			return
	_anim(dt)
	_camera(dt)
	_sound(dt)


func _run_coaster(dt: float) -> void:
	var fd := _front_d()
	if go_t > 0.0:
		go_t -= dt
		if go_t <= 0.0:
			msg("출발!", 0.8)
			beep(300.0, 0.4, 700.0, 0.3)
	else:
		var slope := (ty(fd + 1.0) - ty(fd - 1.0)) * 0.5
		var target: float = Z["base"] * mul - slope * 15.0
		if _in_lift(fd):
			target = 4.0
		if _pose(ca)[4]:
			target = Z["base"] * mul * 0.85
		target = clampf(target, 3.5, 26.0)
		var stop := _stop_a()
		if ca > stop - 30.0:
			target = minf(target, maxf(0.8, (stop - ca) * 0.4))
		cv = move_toward(cv, target, (9.0 if target < cv else 5.0) * dt)
		ca += cv * dt
		if ca >= stop:
			ca = stop
			cv = 0.0
			_place_cars()
			_arrive()
			return
	_place_cars()


func _move_me(dt: float) -> void:
	var mv := kit_move
	var fixing := kit_held("fix") and phase == "run"
	var sp := RUN * (1.7 if dash_t > 0.0 else 1.0) * (0.3 if fixing else 1.0)
	mp.x += mv.x * sp * dt
	mp.z += mv.y * sp * dt
	var dp := clampf(-mp.z, D0 + 10.0, Z["len"] + 12.0)
	mp.z = -dp
	var cx := tx(dp)
	mp.x = clampf(mp.x, cx - HALF, cx + HALF)
	mp.y = ty(dp)
	me.position = mp
	if mv.length() > 0.15:
		me.rotation.y = lerp_angle(me.rotation.y, atan2(-mv.x, -mv.y), minf(1.0, dt * 14.0))
		me_body.position.y = absf(sin(clock * 16.0)) * 0.14
		step_t -= dt * sp / RUN
		if step_t <= 0.0:
			step_t = 0.27
			beep(240.0, 0.03, 0.0, 0.1)
	else:
		me_body.position.y = 0.0
	dash_t -= dt
	dash_cd -= dt
	if _btns.has("dash"):
		if kit_just("dash") and dash_cd <= 0.0:
			dash_t = 1.3
			dash_cd = 4.0 * pow(0.7, owned["dash"] - 1)
			beep(400.0, 0.2, 900.0, 0.25)
			msg("질주!", 0.4)
		_btns["dash"].label = "질주" if dash_cd <= 0.0 else str(ceili(dash_cd))
	if _btns.has("rail"):
		_btns["rail"].label = "레일 %d" % rails_left


func _hazards(dt: float) -> void:
	var fd := _front_d()
	var dp := -mp.z
	var dx := mp.x - tx(dp)
	var reach: float = 0.8 * owned["reach"]
	var target: Dictionary = {}
	var best_dist := 999.0
	for h in haz:
		if h.st == 0 and (h.d - fd < REVEAL or absf(h.d - dp) < NEAR):
			_reveal(h)
		if h.st == 1:
			var dist := 999.0
			var lim := 0.0
			if h.kind == "gap":
				if absf(dx) < 1.3 + reach * 0.5:
					dist = absf(dp - (h.d + 1.0))
				lim = 1.6 + reach
				var n0: MeshInstance3D = h.nodes[0]
				var n1: MeshInstance3D = h.nodes[1]
				var b0: Transform3D = h.broken[0]
				var b1: Transform3D = h.broken[1]
				n0.transform = b0.interpolate_with(h.base[0], h.prog)
				n1.transform = b1.interpolate_with(h.base[1], h.prog)
				var col := D if h.prog > 0.0 else (BAD if fmod(clock * 5.0, 1.0) < 0.5 else WHITE)
				n0.material_override = mat(col)
				n1.material_override = mat(col)
			elif h.kind == "junk":
				if absf(dx) < 2.4 + reach:
					dist = absf(dp - h.d)
				lim = 2.0 + reach
				if h.fall > 0.0:
					h.fall = maxf(0.0, h.fall - dt)
					var T: Transform3D = h.rest
					T.origin.y += h.fall / 0.4 * 7.0
					(h.nodes[0] as MeshInstance3D).transform = T
					if h.fall <= 0.0:
						beep(120.0, 0.12, 60.0, 0.3)
			else:
				var lv: Vector3 = h.lever
				dist = Vector2(mp.x - lv.x, mp.z - lv.z).length()
				lim = 1.9 + reach
				(h.nodes[2] as MeshInstance3D).visible = fmod(clock * 4.0, 1.0) < 0.6
			if dist < lim and dist < best_dist:
				best_dist = dist
				target = h
		if h.fly > 0.0:
			h.fly -= dt
			var n: MeshInstance3D = h.nodes[0]
			n.position += h.fv * dt
			h.fv += Vector3.DOWN * 20.0 * dt
			n.rotate_object_local(Vector3.RIGHT, dt * 9.0)
			if h.fly <= 0.0:
				n.visible = false
	if kit_held("fix") and not target.is_empty():
		var need := 0.8 if target.kind == "gap" else (0.25 if target.kind == "junk" else 0.35)
		need *= pow(0.6, owned["fast"])
		target.prog = minf(1.0, target.prog + dt / need)
		tick_t -= dt
		if tick_t <= 0.0:
			tick_t = 0.08
			beep(500.0 + snappedf(target.prog * 600.0, 100.0), 0.04, 0.0, 0.15)
		if target.prog >= 1.0:
			_fixed(target)
	elif kit_just("fix"):
		beep(200.0, 0.05, 0.0, 0.12)
	if kit_just("rail") and rails_left > 0:
		var pick: Dictionary = {}
		var pd := 14.0
		for h in haz:
			if h.st == 1 and h.kind == "gap" and absf(h.d + 1.0 - dp) < pd:
				pd = absf(h.d + 1.0 - dp)
				pick = h
		if pick.is_empty():
			beep(200.0, 0.05, 0.0, 0.12)
		else:
			rails_left -= 1
			_fixed(pick)
	# 고치지 못한 곳을 코스터가 지나가면 탈선
	for h in haz:
		if h.st != 2 and fd >= h.d:
			_derail(h)
			return


func _reveal(h: Dictionary) -> void:
	h.st = 1
	beep(1000.0, 0.12, 300.0, 0.25)
	if h.kind == "gap":
		msg("레일!", 0.6)
	elif h.kind == "junk":
		msg(Z["junk"] + "!", 0.6)
		h.fall = 0.4
		var n: MeshInstance3D = h.nodes[0]
		n.visible = true
		var T: Transform3D = h.rest
		T.origin.y += 7.0
		n.transform = T


func _fixed(h: Dictionary) -> void:
	h.st = 2
	h.prog = 1.0
	score += 10
	play("good")
	if h.kind == "gap":
		for j in 2:
			var n: MeshInstance3D = h.nodes[j]
			n.transform = h.base[j]
			n.material_override = mat(B)
	elif h.kind == "junk":
		var n: MeshInstance3D = h.nodes[0]
		n.transform = h.rest
		var dx := mp.x - tx(-mp.z)
		var sg := -1.0 if dx > 0.0 else 1.0
		h.fv = _sd(h.d) * sg * 9.0 + Vector3.UP * 6.0
		h.fly = 1.0
		beep(180.0, 0.15, 90.0, 0.3)
	else:
		(h.nodes[0] as MeshInstance3D).visible = false
		var pivot: Node3D = h.nodes[1]
		pivot.rotation.z = 0.7 * h.side
		(pivot.get_child(0) as MeshInstance3D).material_override = mat(GOOD)
		var lamp: MeshInstance3D = h.nodes[2]
		lamp.visible = true
		lamp.material_override = mat(GOOD)
		beep(700.0, 0.08, 1000.0, 0.25)


func _derail(h: Dictionary) -> void:
	phase = "crash"
	crash_hit = false
	crash_t = 0.0
	var P := _pose(ca)
	var fw: Vector3 = P[1]
	var sd: Vector3 = P[2]
	var sg: float = h.side if h.kind == "switch" else (-1.0 if randf() < 0.5 else 1.0)
	for i in NCARS:
		car_v[i] = fw * cv * 0.8 + sd * sg * randf_range(3.0, 7.0) + Vector3.UP * randf_range(4.0, 8.0)
		car_s[i] = Vector3(randf_range(-6, 6), randf_range(-6, 6), randf_range(-6, 6))
	msg("탈선!", 2.0)
	play("bad")
	beep(1300.0, 0.4, 1800.0, 0.2)


func _checks() -> void:
	var dp := -mp.z
	var fd := _front_d()
	var dx := absf(mp.x - tx(dp))
	if cv > 1.0:
		for c in cars:
			var o := mp - c.position
			var bs := c.transform.basis
			if absf(o.dot(bs.x)) < 1.0 and absf(o.dot(bs.z)) < 1.05 and absf(o.dot(bs.y)) < 1.4:
				_hit()
				return
		if prev_front < dp and fd >= dp and dx >= 1.0 and dx < 2.6:
			score += 2
			msg("휙!", 0.5)
			beep(1400.0, 0.25, 300.0, 0.25)
	prev_front = fd


func _hit() -> void:
	phase = "crash"
	crash_hit = true
	crash_t = 0.0
	var P := _pose(ca)
	var fw: Vector3 = P[1]
	var sd: Vector3 = P[2]
	me_v = fw * cv + Vector3.UP * 8.0 + sd * randf_range(-2.0, 2.0)
	msg("치였다!", 2.0)
	play("bad")


func _crash(dt: float) -> void:
	crash_t += dt
	if crash_hit:
		ca = minf(ca + cv * dt, _stop_a())
		_place_cars()
		me.position += me_v * dt
		me_v += Vector3.DOWN * 22.0 * dt
		me.rotate_x(dt * 9.0)
	else:
		for i in NCARS:
			var c := cars[i]
			if c.position.y > -0.6:
				c.position += car_v[i] * dt
				car_v[i] += Vector3.DOWN * 18.0 * dt
				c.rotation += car_s[i] * dt
	if crash_t > 1.7:
		end()


func _arrive() -> void:
	phase = "shop"
	score += 50
	play("win")
	msg("도착!", 1.4)
	var ks: Array = UPG.keys()
	ks.shuffle()
	pad_kind = ks.slice(0, 3)
	for i in 3:
		var col: Color = UPG[pad_kind[i]][1]
		pads[i].visible = true
		(pads[i].get_child(0) as MeshInstance3D).material_override = mat(col)
		(pads[i].get_child(1) as MeshInstance3D).material_override = mat(col)
	warn.visible = false


func _shop(dt: float) -> void:
	var on := -1
	for i in pads.size():
		var o := pads[i].position - mp
		if Vector2(o.x, o.z).length() < 1.4:
			on = i
	if on < 0:
		pad_t = 0.0
		return
	var kd: String = pad_kind[on]
	msg(UPG[kd][0], 0.2)
	pad_t += dt
	gauge(pad_t / 0.7, UPG[kd][1])
	if pad_t >= 0.7:
		owned[kd] += 1
		play("win")
		msg(UPG[kd][0] + "!", 1.2)
		for p in pads:
			p.visible = false
		phase = "next"
		next_t = 1.1
		zi += 1
		if zi >= ZONES.size():
			zi = 0
			lap += 1
			mul += 0.15


func _anim(_dt: float) -> void:
	var wild := 0.3 + clampf(cv / 14.0, 0.0, 1.0) * 0.6
	for j in arms.size():
		arms[j].rotation.x = sin(clock * 15.0 + j * 1.7) * wild
	for p in pads:
		if p.visible:
			(p.get_child(1) as Node3D).rotation.y = clock * 2.0
	warn.visible = phase == "run" and near_k > 0.4 and fmod(clock * (2.0 + near_k * 8.0), 1.0) < 0.6


func _camera(dt: float) -> void:
	var gap := -mp.z - _front_d()
	var nk := clampf(1.0 - gap / 35.0, 0.0, 1.0) if phase == "run" or phase == "crash" else 0.0
	near_k = lerpf(near_k, nk, minf(1.0, dt * 6.0))
	var tgt := mp + Vector3(0, 8.0 + near_k * 2.0, 6.0 + near_k * 5.0)
	if not cam_ready:
		cam_base = tgt
		cam_ready = true
	else:
		cam_base = cam_base.lerp(tgt, minf(1.0, dt * 5.0))
	var shake := near_k * near_k * 0.18 + (0.25 if phase == "crash" and crash_t < 0.4 else 0.0)
	cam.position = cam_base + Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * shake
	cam.look_at(mp + Vector3(0, 0.5, -7.0 + near_k * 2.0))
	var fov := 72.0 + near_k * 12.0 + (6.0 if dash_t > 0.0 else 0.0)
	cam.fov = lerpf(cam.fov, fov, minf(1.0, dt * 4.0))


func _sound(dt: float) -> void:
	if phase != "run" and phase != "crash":
		return
	if cv > 0.5:
		roar_t -= dt
		if roar_t <= 0.0:
			roar_t = lerpf(0.45, 0.07, near_k)
			beep(60.0 + snappedf(cv * 4.0 + near_k * 60.0, 20.0), 0.09, 0.0, snappedf(0.06 + 0.24 * near_k, 0.02))
		if cv > 12.0 and near_k > 0.3 and randf() < dt * 2.5:
			beep(1300.0, 0.22, 1700.0, 0.08)
		if _in_lift(_front_d()):
			clack_t -= dt
			if clack_t <= 0.0:
				clack_t = 0.16
				beep(180.0, 0.03, 0.0, 0.14)
