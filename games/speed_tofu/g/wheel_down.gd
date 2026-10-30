extends Tofu
## 산동네를 굴러 내려가는 바퀴. 아무 데나 끌어 좌우로 기울이면 기운 쪽으로 돈다. 오른쪽 아래는 브레이크. 빠를수록 곧게 서고 느리면 비틀거리다 넘어진다(넘어지거나 떨어지면 끝). 구역마다 하는 법이 바뀐다: 계단 골목(등뒤, 계단 끝 모퉁이 전에 줄이기) → 빨랫줄(비스듬히, 줄 위에선 못 꺾고 바람만 버틴다, 줄 끝에서 줄여야 지붕에서 꺾는다) → 시장 지붕(위에서, 차양에서 튕겨 건너고 찢어진 쪽을 피한다, 맛보기). 죽으면 그 구역 처음부터.
# 한 문장: 나는 수레에서 빠진 바퀴 하나로서 "넘어지면 끝" 속에서 기울여 산동네를 굴러 내려가 강 다리까지 가지만, 빨라야 곧게 서고 빠르면 모퉁이를 못 도는 대가를 감수한다.

const R := 0.7          # 바퀴 반지름
const GRV := 22.0       # 비탈에서 끄는 힘
const ROLL := 0.35
const ROLL_W := 0.1     # 줄 위 구름 저항
const DRAG := 0.011
const BRK := 15.0
const FALL := 20.0
const FALLK := 14.0     # 기울면 더 기울려는 힘 (중력)
const GY := 1.6         # 자이로: 속도 x 이것 만큼 곧게 세우는 힘
const CTRL := 5.4       # 끌어서 기울이는 힘
const WOB := 5.0        # 비틀거림 (느릴수록 큼)
const STEP_K := 0.7     # 계단 한 칸 덜컹
const TILT_DIE := 1.1   # 이만큼 기울면 넘어짐
const GUSTF := 4.5
const VMAX := 28.0
const VSTAND := FALLK / GY  # 이 속도 위에선 스스로 선다
const ROOF := Color("ff8787")
const WOOD := Color("e0b07a")
const HOUSE := [Color("ffd8a8"), Color("a5d8ff"), Color("ffec99"), Color("d0bfff"), Color("b2f2bb"), Color("ffc9c9"), Color("ffffff")]
const CAM := {"back": Vector3(0, 3.0, 7.0), "line": Vector3(4.5, 4.8, 8.5), "high": Vector3(0, 9.5, 7.0)}
const LOOK := {"back": 6.0, "line": 8.0, "high": 7.0}

var Z: Array = []
# 길 표본: 1m 마다 (표본 i 는 거리 i, 구간 [i-1, i] 의 종류는 i 에)
var PX := PackedFloat32Array()
var PZ := PackedFloat32Array()
var PY := PackedFloat32Array()
var YW := PackedFloat32Array()
var HW := PackedFloat32Array()
var TG: Array = []
var ZK: Array = []
var zst: Array = []
var zen: Array = []
var holes: Array = []   # [거리0, 거리1, 옆0, 옆1]
var says: Array = []    # [거리, 글]
var gusts: Array = []   # [거리, 방향, 알림함]
var pot_def: Array = [] # [거리, 옆]
var goal_d := -1.0
# 판
var built := {}
var pots: Array = []    # {d, x, n, hit}
var sheets: Array = []  # {d, pv, k}
var wroot: Node3D
var wtilt: Node3D
var wroll: Node3D
var dist := 0.0
var lx := 0.0
var latv := 0.0
var v := 0.0
var tilt := 0.0
var tilt_v := 0.0
var lean_in := 0.0
var lean := 0.0
var drag_x0 := 0.0
var by := 0.0
var vy := 0.0
var on_ground := true
var fallen := false
var fall_kind := ""
var fall_t := 0.0
var won := false
var won_t := 0.0
var bonus := 0
var clock := 0.0
var cur_k := -1
var say_i := 0
var step_i := 0
var rev_d := 0.0
var warn_t := 0.0
var brk_t := 0.0
var hurt := 0.0
var shake := 0.0
var cam_off := Vector3.ZERO
var cam_yaw := 0.0
var cam_h := 0.0
var cp_k := 0
var cp_bonus := 0
var needle: ColorRect
var sky_env: Environment
var sky_to := Color("fff4e0")


func _setup() -> void:
	howto = "산동네를 굴러 내려가는 바퀴.\n아무 데나 끌어 좌우로 기울이면 기운 쪽으로 돈다. 오른쪽 아래는 브레이크.\n빠를수록 곧게 서고, 느리면 비틀거린다. 빠르면 모퉁이를 못 돈다.\n넘어지거나 떨어지면 끝. 다시 하면 그 구역 처음부터."
	time_limit = 0.0
	for c in get_children():
		if c is WorldEnvironment:
			sky_env = (c as WorldEnvironment).environment
	var tick := ColorRect.new()
	tick.color = INK
	tick.position = Vector2(600.0 * VSTAND / VMAX - 3.0, -10.0)
	tick.size = Vector2(6, 48)
	tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_bg.add_child(tick)
	# 수평계: 바늘이 바퀴 기울기, 빨간 선이 넘어지는 한계
	var hud := CanvasLayer.new()
	add_child(hud)
	for a in [-TILT_DIE, TILT_DIE]:
		var r := ColorRect.new()
		r.color = Color(BAD, 0.5)
		r.size = Vector2(8, 80)
		r.pivot_offset = Vector2(4, 80)
		r.position = Vector2(356, 250)
		r.rotation = a
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hud.add_child(r)
	needle = ColorRect.new()
	needle.size = Vector2(12, 86)
	needle.pivot_offset = Vector2(6, 86)
	needle.position = Vector2(354, 244)
	needle.color = GOOD
	needle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(needle)
	var dot := ColorRect.new()
	dot.color = INK
	dot.position = Vector2(344, 322)
	dot.size = Vector2(32, 16)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(dot)
	kit_button("brake", "브레이크", Vector2(600, 1150), 90.0, BAD)
	Z = _zones()
	_path_build()


func _zones() -> Array:
	return [
		# 계단 골목: 계단에서 빨라지고(덜컹), 계단 끝 모퉁이는 줄여야 돈다. 언덕 앞에선 줄이지 않기.
		{"name": "계단 골목", "cam": "back", "walls": true, "sky": Color("fff4e0"),
			"legs": [[16, -0.5, 2.6, 0, "land"], [28, -11, 2.2, 0, "st"], [18, -0.5, 2.8, 90, "land"], [30, -12, 2.2, 0, "st"],
				[22, 1.2, 2.4, 0, "land"], [14, -0.3, 2.8, -70, "land"], [34, -13, 2.0, 0, "st"], [20, -0.5, 3.0, -100, "view"],
				[30, -11, 2.2, 0, "st"], [16, -0.5, 2.6, 0, "land"]],
			"pots": [[104, 1.2], [134, -1.0], [142, 1.0], [150, -0.4], [156, 1.1]],
			"say": [[5, "끌어서 기울이면\n기운 쪽으로 돈다"], [32, "모퉁이!\n브레이크로 줄여"], [88, "언덕! 빠르게"], [126, "화분 조심"],
				[170, "난간 없음!"], [216, "지붕으로"]]},
		# 빨랫줄: 줄 위에선 못 꺾고 균형만. 빠르면 바람을 버티지만 줄 끝 지붕 모퉁이를 못 돈다.
		{"name": "빨랫줄", "cam": "line", "walls": false, "sky": Color("d8eeff"),
			"legs": [[10, -0.3, 3.0, 0, "roof"], [40, -8, 0.15, 0, "wire", 2.5], [8, -0.2, 3.0, 90, "roof"], [8, -0.2, 3.0, 0, "roof"],
				[50, -11, 0.15, 0, "wire", 3.0], [8, -0.2, 3.0, -90, "roof"], [8, -0.2, 3.0, 0, "roof"],
				[60, -13, 0.15, 0, "wire", 3.5], [12, -0.3, 3.0, 0, "roof"]],
			"gusts": [[26, 1], [84, -1], [100, 1], [146, -1], [162, 1], [178, -1]],
			"say": [[3, "줄 위에선 못 꺾는다\n노란 줄에 맞춰"], [14, "빨래가 휘날리면 바람\n반대로 끌어 버텨"], [36, "줄 끝에서 줄여!\n지붕에서 꺾는다"],
				[104, "줄 끝에서 줄여!"], [182, "이번엔 줄이지 마"]]},
		# 시장 지붕(맛보기): 차양은 튕기고, 공중에선 못 고친다. 찢어진 쪽은 뚫린다.
		{"name": "시장 지붕", "cam": "high", "walls": false, "sky": Color("ffe8f0"),
			"legs": [[8, -0.3, 3.0, 0, "roof"], [3, -3, 3.0, 0, "gap"], [14, -2.0, 3.5, 0, "awn"], [3, -1.5, 3.5, 0, "gap"],
				[14, -2.0, 3.5, 0, "awn"], [3, -1.5, 3.5, 0, "gap"], [14, -2.0, 3.5, 0, "awn"], [3, -1.5, 3.0, 0, "gap"],
				[60, -1, 4.0, 0, "land"]],
			"holes": [[29, 42, -3.6, 0.0], [46, 59, 0.0, 3.6]],
			"goal": 92,
			"say": [[2, "차양은 튕긴다\n공중에선 못 고친다"], [24, "찢어진 쪽 피해!"], [72, "강 다리가 보인다"]]},
	]


func _push(p: Vector3, y: float, yw: float, hw: float, tg: String, k: int) -> void:
	PX.append(p.x)
	PZ.append(p.z)
	PY.append(y)
	YW.append(yw)
	HW.append(hw)
	TG.append(tg)
	ZK.append(k)


func _path_build() -> void:
	var p := Vector3.ZERO
	var yw := 0.0
	var y := 0.0
	var first: Array = Z[0].legs[0]
	_push(p, y, yw, float(first[2]), String(first[4]), 0)
	for k in Z.size():
		var z: Dictionary = Z[k]
		var a := float(PX.size() - 1)
		zst.append(a)
		for leg: Array in z.legs:
			var n := int(leg[0])
			var turn := deg_to_rad(float(leg[3]))
			var sag: float = float(leg[5]) if leg.size() > 5 else 0.0
			var y0 := y
			for j in n:
				var u := float(j + 1) / n
				yw -= turn / n  # 오른쪽(+)으로 돌면 yaw 가 줄어든다
				p += Vector3(-sin(yw), 0, -cos(yw))
				y = y0 + float(leg[1]) * u
				_push(p, y - sag * sin(PI * u), yw, float(leg[2]), String(leg[4]), k)
		zen.append(float(PX.size() - 1))
		for hl: Array in z.get("holes", []):
			holes.append([a + hl[0], a + hl[1], hl[2], hl[3]])
		for sy: Array in z.get("say", []):
			says.append([a + sy[0], sy[1]])
		for g: Array in z.get("gusts", []):
			gusts.append([a + g[0], float(g[1]), false])
		for pt: Array in z.get("pots", []):
			pot_def.append([a + pt[0], float(pt[1]), k])
		if z.has("goal"):
			goal_d = a + float(z.goal)
	says.sort_custom(func(x, w): return x[0] < w[0])


# ---- 길 읽기 ----
func _seg(d: float) -> int:
	return clampi(int(floor(d)) + 1, 1, PX.size() - 1)


func _fi(d: float) -> int:
	return clampi(int(floor(d)), 0, PX.size() - 2)


func _h(d: float) -> float:
	var i := _fi(d)
	return lerpf(PY[i], PY[i + 1], clampf(d - i, 0.0, 1.0))


func _yaw(d: float) -> float:
	var i := _fi(d)
	return lerp_angle(YW[i], YW[i + 1], clampf(d - i, 0.0, 1.0))


func _pos(d: float, x: float, y: float) -> Vector3:
	var i := _fi(d)
	var f := clampf(d - i, 0.0, 1.0)
	var yw := _yaw(d)
	return Vector3(lerpf(PX[i], PX[i + 1], f), y, lerpf(PZ[i], PZ[i + 1], f)) + Vector3(cos(yw), 0, -sin(yw)) * x


func _slope(d: float) -> float:
	return _h(d + 0.5) - _h(d - 0.5)


## + 이면 오른쪽으로 도는 길
func _curv(d: float) -> float:
	return -angle_difference(_yaw(d - 1.0), _yaw(d + 1.0)) * 0.5


func _tag(d: float) -> String:
	return TG[_seg(d)]


func _hwd(d: float) -> float:
	return HW[_seg(d)]


func _ground(d: float, x: float) -> float:
	var i := _seg(d)
	if TG[i] == "gap" or absf(x) > HW[i] + 0.35:
		return NAN
	for hl: Array in holes:
		if d >= hl[0] and d <= hl[1] and x > hl[2] and x < hl[3]:
			return NAN
	return _h(d)


func _run_end(d: float, maxlen: float, lim: float) -> float:
	var tg := _tag(d + 0.5)
	var e := d
	while e < lim - 0.01 and e - d < maxlen and _tag(e + 0.5) == tg:
		e += 1.0
	return maxf(e, d + 1.0)


# ---- 짓기 ----
## 거리 d0..d1, 옆 x0..x1 의 판 (비탈을 따라 기운다)
func _slab(nd: Node3D, d0: float, d1: float, x0: float, x1: float, th: float, col: Color, lift := 0.0) -> MeshInstance3D:
	var xm := (x0 + x1) * 0.5
	var pa := _pos(d0, xm, _h(d0) + lift)
	var pb := _pos(d1, xm, _h(d1) + lift)
	var dv := pb - pa
	var m := box((pa + pb) * 0.5 - Vector3(0, th * 0.5, 0), Vector3.ONE, col, nd)
	m.basis = Basis.looking_at(dv.normalized(), Vector3.UP) * Basis.from_scale(Vector3(absf(x1 - x0), th, dv.length() + 0.15))
	return m


## 길 방향으로 돌린 상자, 바닥 높이 yb
func _block(nd: Node3D, d: float, x: float, yb: float, sz: Vector3, col: Color) -> MeshInstance3D:
	var m := box(_pos(d, x, yb + sz.y * 0.5), sz, col, nd)
	m.rotation.y = _yaw(d)
	return m


func _zone_build(k: int) -> void:
	if built.has(k) or k < 0 or k >= Z.size():
		return
	var nd := Node3D.new()
	world.add_child(nd)
	built[k] = nd
	var z: Dictionary = Z[k]
	var a: float = zst[k]
	var b: float = zen[k]
	var d := a
	var hi := 0
	var awn_i := 0
	while d < b - 0.01:
		var tg := _tag(d + 0.5)
		var hw := _hwd(d + 0.5)
		var d1 := d
		if tg == "st":
			d1 = _run_end(d, 2.0, b)
			var top := _h((d + d1) * 0.5)
			_block(nd, (d + d1) * 0.5, 0.0, top - 1.2, Vector3(hw * 2.0, 1.2, d1 - d + 0.02), SOFT if hi % 2 == 0 else WHITE)
		elif tg == "wire":
			d1 = _run_end(d, 5.0, b)
			_slab(nd, d, d1, -0.05, 0.05, 0.1, INK)
		elif tg == "gap":
			d1 = _run_end(d, 999.0, b)
		elif tg == "awn":
			d1 = _run_end(d, 999.0, b)
			var cols := [[A, WHITE], [B, WHITE], [GOOD, WHITE]]
			var cc: Array = cols[awn_i % cols.size()]
			awn_i += 1
			var mid := (d + d1) * 0.5
			for sd in [-1.0, 1.0]:
				var x0: float = -hw if sd < 0.0 else 0.0
				var x1: float = 0.0 if sd < 0.0 else hw
				var torn := false
				for hl: Array in holes:
					if mid > hl[0] and mid < hl[1] and (x0 + x1) * 0.5 > hl[2] and (x0 + x1) * 0.5 < hl[3]:
						torn = true
				if torn:
					# 찢어진 차양: 바깥 테만 남는다
					_slab(nd, d, d1, sd * hw - 0.2, sd * hw + 0.2, 0.25, WOOD)
				else:
					_slab(nd, d, d1, x0, x1, 0.25, cc[0] if sd < 0.0 else cc[1])
			_block(nd, mid, 0.0, _h(mid) - 4.2, Vector3(hw * 1.6, 1.0, (d1 - d) * 0.7), WOOD)
		else:
			var turning := absf(_curv(d + 0.5)) > 0.01
			d1 = _run_end(d, 2.0 if turning else 6.0, b)
			var col: Color = ROOF if tg == "roof" else SOFT
			_slab(nd, d, d1, -hw, hw, 0.4, col)
			if tg == "roof":
				var mid := (d + d1) * 0.5
				_block(nd, mid, 0.0, _h(mid) - 14.4, Vector3(hw * 2.0 + 0.2, 14.0, d1 - d + 0.1), HOUSE[k + hi % 3])
				if _tag(d1 + 0.5) == "wire" or (d1 - d < 3.0 and _tag(d1 + 6.5) == "wire"):
					_slab(nd, d, d1, -0.15, 0.15, 0.42, D)  # 노란 줄: 줄에 맞추는 자리
		d = d1
		hi += 1
	# 골목 집 벽 (난간 없는 꺾임은 안쪽만, 바깥은 아래 동네 지붕)
	var hd := a + 3.0
	while hd < b:
		var tg := _tag(hd)
		var hw := _hwd(hd)
		var walled: bool = z.walls and (tg == "st" or tg == "land")
		if walled or tg == "view":
			var inner := signf(_curv(hd))
			for sd in [-1.0, 1.0]:
				var ht := 3.5 + fmod(hd * 1.37 + sd, 3.0)
				var col: Color = HOUSE[(int(hd / 8.0) * 2 + (1 if sd > 0.0 else 0)) % HOUSE.size()]
				if walled or sd == inner:
					_block(nd, hd, sd * (hw + 1.6), _h(hd) - 1.5, Vector3(3.0, ht + 1.5, 6.5), col)
				elif inner != 0.0:
					_block(nd, hd, sd * (hw + 6.0), _h(hd) - 12.0, Vector3(6.0, 6.0, 6.5), col)
		hd += 8.0
	# 빨랫줄: 양옆 빨래 줄과 빨래 (바람이 오기 전에 그쪽으로 휘날린다)
	if k == 1 or z.cam == "line":
		var wd := a
		while wd < b:
			if _tag(wd + 0.5) != "wire":
				wd += 1.0
				continue
			var we := _run_end(wd, 999.0, b)
			var sd2 := wd
			while sd2 < we - 0.01:
				var se := minf(sd2 + 15.0, we)
				for sd in [-1.6, 1.6]:
					_slab(nd, sd2, se, sd - 0.03, sd + 0.03, 0.06, INK, 1.7)
				sd2 = se
			var sh_d := wd + 4.0
			var n := 0
			while sh_d < we - 3.0:
				var sd: float = 1.6 if n % 2 == 0 else -1.6
				var pv := Node3D.new()
				nd.add_child(pv)
				pv.position = _pos(sh_d, sd, _h(sh_d) + 1.7)
				pv.rotation.y = _yaw(sh_d)
				box(Vector3(0, -0.6, 0), Vector3(0.06, 1.1, 1.3), HOUSE[n % HOUSE.size()] if n % 3 != 2 else A, pv)
				sheets.append({"d": sh_d, "pv": pv, "k": k})
				sh_d += 7.0
				n += 1
			wd = we
		# 아래 동네
		var mid_d := (a + b) * 0.5
		var low := _h(b) - 18.0
		box(_pos(mid_d, 0.0, low - 1.0), Vector3(150, 2, 150), GRASS_C, nd)
		for i in 10:
			var dd := a + 10.0 + i * (b - a - 20.0) / 9.0
			var sx := (1.0 if i % 2 == 0 else -1.0) * (7.0 + fmod(i * 3.7, 6.0))
			_block(nd, dd, sx, low, Vector3(5.0, _h(dd) - low - 9.0, 6.0), HOUSE[i % HOUSE.size()])
	# 시장: 길가 좌판, 끝의 강과 다리 입구
	if z.has("goal"):
		var sd3 := a + 66.0
		var i := 0
		while sd3 < b - 4.0:
			for sd in [-1.0, 1.0]:
				_block(nd, sd3, sd * 5.2, _h(sd3) - 0.3, Vector3(2.0, 1.4, 3.0), [A, B, C, D][(i + (1 if sd > 0.0 else 0)) % 4])
			sd3 += 7.0
			i += 1
		var hw := _hwd(goal_d)
		for sd in [-1.0, 1.0]:
			_block(nd, goal_d, sd * (hw + 0.4), _h(goal_d), Vector3(0.6, 4.5, 0.6), D)
		_block(nd, goal_d, 0.0, _h(goal_d) + 4.5, Vector3(hw * 2.0 + 1.4, 0.7, 0.7), D)
		box(_pos(b, 0.0, _h(b) - 3.0), Vector3(120, 1, 40), WATER_C, nd)
		for i2 in 4:
			_block(nd, b - 6.0 + i2 * 1.6, 0.0, _h(b) - 0.6, Vector3(3.0, 0.3, 1.2), WOOD)
	# 화분
	for pt: Array in pot_def:
		if int(pt[2]) != k:
			continue
		var pn := Node3D.new()
		nd.add_child(pn)
		pn.position = _pos(pt[0], pt[1], _h(pt[0]))
		pn.rotation.y = _yaw(pt[0])
		box(Vector3(0, 0.3, 0), Vector3(0.8, 0.6, 0.8), A, pn)
		box(Vector3(0, 0.85, 0), Vector3(0.6, 0.6, 0.6), GOOD, pn)
		pots.append({"d": float(pt[0]), "x": float(pt[1]), "n": pn, "hit": false, "k": k})


const GRASS_C := Color("8ce99a")
const WATER_C := Color("a5d8ff")


func _zone_free(k: int) -> void:
	if not built.has(k):
		return
	(built[k] as Node3D).queue_free()
	built.erase(k)
	pots = pots.filter(func(p): return p.k != k)
	sheets = sheets.filter(func(s): return s.k != k)


# ---- 판 ----
func _reset() -> void:
	built = {}
	pots = []
	sheets = []
	cur_k = -1
	dist = zst[cp_k] + 1.0
	bonus = cp_bonus if cp_k > 0 else 0
	lx = 0.0
	latv = 0.0
	v = 9.0
	tilt = 0.0
	tilt_v = 0.0
	lean_in = 0.0
	lean = 0.0
	by = _h(dist)
	vy = 0.0
	on_ground = true
	fallen = false
	fall_t = 0.0
	won = false
	won_t = 0.0
	clock = 0.0
	warn_t = 0.0
	brk_t = 0.0
	hurt = 0.0
	shake = 0.0
	step_i = int(dist / 2.0)
	rev_d = 0.0
	for g: Array in gusts:
		g[2] = false
	say_i = 0
	while say_i < says.size() and says[say_i][0] < dist:
		say_i += 1
	wroot = Node3D.new()
	world.add_child(wroot)
	wtilt = Node3D.new()
	wroot.add_child(wtilt)
	wroll = Node3D.new()
	wroll.position.y = R
	wtilt.add_child(wroll)
	for i in 8:
		var an := TAU * i / 8.0
		var m := box(Vector3(0, R * cos(an), R * sin(an)), Vector3(0.26, 0.2, 2.0 * R * sin(PI / 8.0) + 0.06), ME, wroll)
		m.rotation.x = an
	box(Vector3.ZERO, Vector3(0.36, 0.3, 0.3), D, wroll)
	for i in 2:
		var sp := box(Vector3.ZERO, Vector3(0.1, 2.0 * R - 0.12, 0.12), WHITE, wroll)
		sp.rotation.x = i * PI * 0.5
	_zones_tick()
	var mode: String = Z[cur_k].cam
	cam_off = CAM[mode]
	cam_yaw = _yaw(dist)
	cam_h = by
	cam.fov = 66.0
	if cp_k == 0:
		msg("느리면 비틀\n빠르면 곧게", 2.0)
	_place(0.0)


func _zones_tick() -> void:
	var k: int = ZK[_seg(dist)]
	if k != cur_k:
		cur_k = k
		_zone_build(k)
		_zone_build(k + 1)
		cp_k = k
		cp_bonus = bonus
		sky_to = Z[k].sky
		msg(Z[k].name, 1.4)
		play("good")
	if built.has(k - 1) and dist > zst[k] + 15.0:
		_zone_free(k - 1)


func _step(dt: float) -> void:
	clock += dt
	hurt -= dt
	shake = maxf(0.0, shake - dt * 2.5)
	if sky_env:
		sky_env.background_color = sky_env.background_color.lerp(sky_to, minf(1.0, dt * 1.5))
	_zones_tick()
	if won:
		won_t += dt
		if won_t > 1.6:
			end()
			return
	if fallen:
		_fallen_step(dt)
		_place(dt)
		return
	lean = lerpf(lean, lean_in, minf(1.0, dt * 12.0))
	var braking := kit_held("brake")
	var i := _seg(dist)
	var tg: String = TG[i]
	var z: Dictionary = Z[ZK[i]]
	var wire := tg == "wire"
	# 속도: 비탈이 끌고, 브레이크가 줄인다
	if on_ground:
		var sl := _slope(dist)
		v += (-sl * GRV - (ROLL_W if wire else ROLL) - DRAG * v * v) * dt
		if braking:
			v -= BRK * dt
			brk_t -= dt
			if brk_t <= 0.0 and v > 2.0:
				brk_t = 0.14
				beep(900.0 + v * 20.0, 0.06, 700.0, 0.1)
		v = maxf(v, 0.0)
	else:
		v -= DRAG * 0.3 * v * v * dt
	# 바람 (빨래가 먼저 휘날린다)
	var gf := 0.0
	var flap := 0.0
	for g: Array in gusts:
		var dd: float = g[0] - dist
		if dd > 0.0 and dd < v * 1.4 + 6.0:
			flap = g[1]
			if not g[2]:
				g[2] = true
				msg("바람 →" if g[1] > 0.0 else "← 바람", 0.9)
				beep(200.0, 0.35, 520.0, 0.16)
		elif dd <= 0.0 and dd > -9.0:
			gf = g[1] * GUSTF
			flap = g[1]
	for sh: Dictionary in sheets:
		var pv: Node3D = sh.pv
		var tz := (flap * 0.8 if absf(sh.d - dist) < 40.0 else 0.0) + sin(clock * 3.0 + sh.d) * 0.12
		pv.rotation.z = lerpf(pv.rotation.z, tz, minf(1.0, dt * 5.0))
	# 기울기: 빠를수록 곧게(자이로), 느리면 저절로 더 기운다. 끌면 기울이는 힘.
	if on_ground:
		var acc := FALLK * sin(tilt) - GY * v * tilt + CTRL * lean - (2.5 + 0.15 * v) * tilt_v
		acc += WOB * (sin(clock * 5.3) + 0.6 * sin(clock * 8.7 + 1.3)) / maxf(v, 2.5)
		acc += gf
		if v < 1.2:
			acc += (signf(tilt) if absf(tilt) > 0.01 else 1.0) * 6.0
		tilt_v += acc * dt
	else:
		tilt_v *= exp(-1.5 * dt)
	tilt += tilt_v * dt
	# 돌기: 기운 쪽으로, 빠를수록 덜 돈다. 길이 꺾이면 바깥으로 밀린다.
	if on_ground:
		if wire:
			lx = lerpf(lx, 0.0, minf(1.0, dt * 8.0))
			latv = 0.0
		else:
			var turn := 9.8 * tan(clampf(tilt, -1.2, 1.2)) / maxf(v, 3.0)
			latv = (turn - _curv(dist) * v) * v * 0.5
	lx += latv * dt
	dist += v * dt
	# 벽: 골목은 튕긴다, 난간 없는 꺾임은 안쪽만 벽
	if on_ground and not won:
		var hw := _hwd(dist)
		var wall := 0.0
		if z.walls and (tg == "st" or tg == "land") and absf(lx) > hw - 0.45:
			wall = signf(lx)
		elif tg == "view":
			var inner := signf(_curv(dist))
			if inner != 0.0 and lx * inner > hw - 0.45:
				wall = inner
		if wall != 0.0:
			lx = wall * (hw - 0.45)
			latv = 0.0
			if hurt <= 0.0:
				hurt = 0.35
				v *= 0.65
				tilt_v -= wall * 2.2
				shake = 0.35
				beep(140.0, 0.12, 90.0, 0.3)
				msg("쿵!", 0.3)
	# 위아래
	vy -= FALL * dt
	by += vy * dt
	var gnd := _ground(dist, lx)
	if is_nan(gnd):
		if on_ground and not won:
			if tg == "gap" or _tag(dist) == "gap":
				msg("날아라!", 0.5)
				beep(330.0, 0.15, 660.0, 0.2)
		on_ground = false
		if by < _h(dist) - 4.0 and not won:
			_drop("줄에서 떨어졌다!" if wire else ("못 건넜다!" if _tag(dist) == "gap" else "떨어졌다!"))
	elif by <= gnd:
		if by < gnd - 1.2 and not won:
			_topple("쾅!")
		else:
			var bounced := false
			if not on_ground:
				bounced = _land(vy, _tag(dist))
			if bounced:
				by = gnd + 0.02
			else:
				by = gnd
				vy = v * _slope(dist)
				on_ground = true
	elif on_ground and by - gnd < 0.5:
		by = gnd  # 비탈이 꺾이는 곳에서 붙어 간다
		vy = v * _slope(dist)
	else:
		on_ground = false
	if fallen:
		_place(dt)
		return
	# 계단 칸마다 덜컹, 그 밖에선 한 바퀴마다 구르는 소리
	if on_ground and _tag(dist) == "st":
		var si := int(dist / 2.0)
		if si != step_i:
			step_i = si
			tilt_v += randf_range(-1.0, 1.0) * STEP_K
			beep(170.0 + v * 8.0, 0.04, 0.0, 0.14)
	elif on_ground:
		rev_d += v * dt
		if rev_d > PI * R:
			rev_d = 0.0
			if wire:
				beep(620.0 + v * 18.0, 0.03, 0.0, 0.06)
			else:
				beep(130.0 + v * 6.0, 0.03, 0.0, 0.09)
	# 화분
	for p: Dictionary in pots:
		if p.hit:
			continue
		if absf(p.d - dist) < 0.6 and absf(p.x - lx) < 0.75 and on_ground:
			p.hit = true
			(p.n as Node3D).scale = Vector3(1.4, 0.2, 1.4)
			v *= 0.55
			tilt_v += (signf(lx - p.x) if absf(lx - p.x) > 0.05 else 1.0) * 2.6
			shake = 0.4
			beep(260.0, 0.15, 120.0, 0.3)
			msg("와장창!", 0.4)
	# 넘어짐
	if absf(tilt) > TILT_DIE and not won:
		_topple("넘어졌다!")
		_place(dt)
		return
	if absf(tilt) > 0.65 and on_ground:
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = 0.25
			beep(300.0 + absf(tilt) * 200.0, 0.08, 220.0, 0.22)
			msg("비틀!", 0.3)
	else:
		warn_t = 0.0
	while say_i < says.size() and dist >= says[say_i][0]:
		msg(says[say_i][1], 1.8)
		say_i += 1
	if goal_d > 0.0 and dist >= goal_d and not won:
		won = true
		bonus += 500 + int(v * 10.0)
		cp_k = 0
		cp_bonus = 0
		msg("강 다리!\n(다음 구역은 다음에)", 2.0)
		play("win")
	score = int(dist) + bonus
	var col := GOOD
	if v < VSTAND:
		col = BAD
	elif v < VSTAND * 1.4:
		col = D
	gauge(v / VMAX, col)
	_place(dt)


## 착지: 차양이면 튕긴다(true). 기운 채 떨어지면 더 기운다.
func _land(vy0: float, tg: String) -> bool:
	var imp := -vy0
	var kick := signf(tilt) if absf(tilt) > 0.05 else randf_range(-0.5, 0.5)
	if tg == "awn" and imp > 4.0:
		vy = imp * 0.55
		on_ground = false
		tilt_v += kick * imp * 0.05
		beep(330.0, 0.12, 660.0, 0.25)
		msg("통!", 0.3)
		return true
	tilt_v += kick * imp * 0.09
	shake = minf(0.5, imp * 0.03)
	beep(160.0, 0.1, 80.0, clampf(imp * 0.02, 0.08, 0.3))
	return false


func _topple(text: String) -> void:
	fallen = true
	fall_kind = "tip"
	fall_t = 0.0
	if absf(tilt) < 0.05:
		tilt = 0.05
	shake = 0.4
	msg(text, 2.0)
	play("bad")


func _drop(text: String) -> void:
	fallen = true
	fall_kind = "drop"
	fall_t = 0.0
	msg(text, 2.0)
	play("bad")


func _fallen_step(dt: float) -> void:
	fall_t += dt
	if fall_kind == "tip":
		tilt_v += signf(tilt) * 9.0 * dt
		tilt = clampf(tilt + tilt_v * dt, -1.5, 1.5)
		v *= exp(-2.5 * dt)
		dist += v * dt
		var g := _ground(dist, lx)
		if not is_nan(g):
			by = lerpf(by, g, minf(1.0, dt * 10.0))
	else:
		vy -= FALL * dt
		by += vy * dt
		dist += v * dt * 0.6
		lx += latv * dt
	if fall_t > 1.3:
		end()


func _place(dt: float) -> void:
	var yw := _yaw(dist)
	wroot.position = _pos(dist, lx, by)
	wroot.rotation = Vector3(0, yw - atan2(latv, maxf(v, 2.0)) * 0.6, 0)
	wtilt.rotation.z = -tilt
	wroll.rotation.x -= v * dt / R
	# 카메라: 구역마다 각이 다르다
	var mode: String = Z[cur_k].cam if cur_k >= 0 else "back"
	var k := minf(1.0, dt * 2.0) if dt > 0.0 else 1.0
	cam_off = cam_off.lerp(CAM[mode], k)
	cam_yaw = lerp_angle(cam_yaw, _yaw(dist + 3.0), minf(1.0, dt * 3.0) if dt > 0.0 else 1.0)
	if not (fallen and fall_kind == "drop"):
		cam_h = lerpf(cam_h, by, minf(1.0, dt * 4.0) if dt > 0.0 else 1.0)
	var f := Vector3(-sin(cam_yaw), 0, -cos(cam_yaw))
	var r := Vector3(cos(cam_yaw), 0, -sin(cam_yaw))
	var wp := _pos(dist, lx * 0.7, cam_h)
	var sh := Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * shake * 0.3
	cam.position = wp + r * cam_off.x + Vector3.UP * cam_off.y - f * cam_off.z + sh
	cam.look_at(wp + f * float(LOOK[mode]) + Vector3.UP * 0.8, Vector3.UP)
	if dt > 0.0:
		cam.fov = lerpf(cam.fov, 60.0 + clampf(v, 0.0, 30.0) * 0.7, minf(1.0, dt * 2.0))
	needle.rotation = tilt
	var at := absf(tilt)
	needle.color = GOOD if at < 0.4 else (D if at < 0.75 else BAD)


func _tap(p: Vector2) -> void:
	drag_x0 = p.x
	lean_in = 0.0


func _drag(p: Vector2) -> void:
	lean_in = clampf((p.x - drag_x0) / 150.0, -1.0, 1.0)


func _lift(_p: Vector2) -> void:
	lean_in = 0.0
