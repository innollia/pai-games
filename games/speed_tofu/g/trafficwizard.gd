extends Tofu
## 늙은 마법사가 차를 늦춰 길을 건넌다 (높은 위 시점). 왼쪽 아래 조이스틱 = 천천히 걷기, 차를 탭 = 느리게(기어감), 차를 진행 방향으로 쓸기 = 빠르게(휙 지나감).
## 변형(느림의 미학·속도를 조절함): 주문은 시간을 빌려 온다. 차를 늦추면 그 동안 내 걸음도 기어가고, 차를 빠르게 하면 나도 그만큼 빨라진다. 얼음은 나도 잠깐 얼린다.
## 주문은 마나를 쓴다. 차·기차에 닿으면 그 건널목 처음부터. 마을 길 → 4차선 → 교차로 → 고속도로 → 기찻길, 구역 사이에 받침대로 걸어가 강화 하나를 고른다.

const LW := 2.6  # 차선 폭
const WALK := 1.7  # 늙은 걸음
const HALF := 24.0  # 차가 나타나고 사라지는 거리
const RAIL_HALF := 40.0
const SLOW_COST := 30.0
const HASTE_COST := 25.0
const ICE := Color("e7f5ff")
const CRAWL := Color("a5d8ff")
const ROAD := Color("ced4da")
const GRASS := Color("b2f2bb")
const RAIL_BED := Color("e3d5b8")
const GLASS := Color("d0ebff")
const SKIN := Color("ffd8a8")
const UPS := [["frz", C, "얼음"], ["area", B, "넓게"], ["mana", GOOD, "마나"]]

var towns: Array = []
var dist_i := 0
var cross_i := 0
var mode := "cross"  # cross / dead / pick
var stage: Node3D
var lanes: Array = []
var cars: Array = []
var z_end := 0.0
var wiz: Node3D
var wpos := Vector3.ZERO
var kid: Node3D
var kpos := Vector3.ZERO
var has_kid := false
var mana := 100.0
var up := {}
var dead_t := 0.0
var step_t := 0.0
var step_snd := 0.0
var shake := 0.0
var cam_at := Vector3.ZERO
var pick_from := Vector2.ZERO
var pick_car: Dictionary = {}
var cast_done := false
var pedestals: Array = []
var blink_t := 0.0
var tries := 0
var me_slow_t := 0.0  # 내가 느린 시간 (차를 늦춘 만큼)
var me_fast_t := 0.0  # 내가 빠른 시간 (차를 빠르게 한 만큼)
var me_frz_t := 0.0  # 내가 언 시간
var robe: MeshInstance3D


func _setup() -> void:
	howto = "늙은 마법사가 마을 끝까지 길을 건넌다.\n왼쪽 아래 조이스틱 = 걷기. 차를 탭 = 느리게, 차를 가는 쪽으로 쓸기 = 빠르게. 둘 다 마나를 쓴다.\n주문은 시간을 빌려 온다: 차를 늦추면 그 동안 내 걸음도 기어가고, 차를 빠르게 하면 나도 그만큼 빨라진다(얼음은 나도 잠깐 언다).\n차·기차에 닿으면 그 길 처음부터. 구역 사이 받침대(보라 얼음·파랑 넓게·초록 마나)에서 하나 고른다."
	cam.fov = 42.0
	kit_stick(Rect2(0, 960, 330, 320))
	var car := ["car"]
	var trk := ["car", "car", "truck"]
	var trn := ["car", "turn"]
	towns = [
		{"name": "마을 길", "cross": [
			{"say": "탭=느리게", "lanes": [_ln(1, 5, 2.4, 3.6, car), _ln(-1, 5, 2.4, 3.6, car)]},
			{"say": "쓸기=빠르게", "lanes": [_ln(1, 8, 1.2, 2.0, car), _ln(-1, 8, 1.2, 2.0, car)]},
			{"say": "아이를 데려가", "kid": true, "lanes": [_ln(1, 7, 1.4, 2.4, car), _ln(-1, 7, 1.4, 2.4, car)]},
		]},
		{"name": "4차선", "cross": [
			{"say": "4차선", "lanes": [_ln(1, 8, 1.5, 2.6, car), _ln(1, 10, 1.7, 2.8, car), _ln(-1, 10, 1.7, 2.8, car), _ln(-1, 8, 1.5, 2.6, car)]},
			{"say": "트럭은 버틴다", "lanes": [_ln(1, 8, 1.6, 2.6, trk), _ln(1, 9, 1.8, 2.8, ["truck"]), _ln(-1, 9, 1.8, 2.8, ["truck"]), _ln(-1, 8, 1.6, 2.6, trk)]},
			{"say": "줄줄이 연쇄", "lanes": [_ln(1, 9, 0.7, 1.0, car), _ln(1, 9, 0.7, 1.0, car), _ln(-1, 9, 0.7, 1.0, car), _ln(-1, 9, 0.7, 1.0, car)]},
		]},
		{"name": "교차로", "cross": [
			{"say": "끼어드는 차", "lanes": [_ln(1, 8, 1.3, 2.2, trn), _ln(1, 8, 1.5, 2.4, car), _ln(-1, 8, 1.5, 2.4, car), _ln(-1, 8, 1.3, 2.2, trn)]},
			{"say": "아이와 교차로", "kid": true, "lanes": [_ln(1, 8, 1.3, 2.2, trn), _ln(1, 9, 1.5, 2.4, trk), _ln(-1, 9, 1.5, 2.4, trk), _ln(-1, 8, 1.3, 2.2, trn)]},
		]},
		{"name": "고속도로", "cross": [
			{"say": "쌩쌩", "lanes": [_ln(1, 14, 1.2, 2.0, car), _ln(1, 16, 1.3, 2.2, trk), _ln(1, 18, 1.4, 2.4, car), _ln(-1, 18, 1.4, 2.4, car), _ln(-1, 16, 1.3, 2.2, trk), _ln(-1, 14, 1.2, 2.0, car)]},
			{"say": "더 빽빽", "lanes": [_ln(1, 15, 0.8, 1.4, trk), _ln(1, 17, 0.9, 1.5, car), _ln(1, 19, 1.0, 1.6, trn), _ln(-1, 19, 1.0, 1.6, trn), _ln(-1, 17, 0.9, 1.5, car), _ln(-1, 15, 0.8, 1.4, trk)]},
		]},
		{"name": "기찻길", "cross": [
			{"say": "기차는 안 느려진다", "lanes": [_ln(1, 8, 1.4, 2.4, car), _ln(-1, 8, 1.4, 2.4, car), _rail(), _ln(1, 9, 1.4, 2.4, trk), _ln(-1, 9, 1.4, 2.4, trk)]},
			{"say": "아이와 기찻길", "kid": true, "lanes": [_ln(1, 9, 1.2, 2.0, trk), _ln(-1, 9, 1.2, 2.0, car), _rail(), _ln(1, 10, 1.2, 2.0, trn), _ln(1, 10, 1.2, 2.0, car), _ln(-1, 12, 1.2, 2.0, trk)]},
		]},
	]


func _ln(d: int, v: float, g0: float, g1: float, kinds: Array) -> Dictionary:
	return {"d": d, "v": v, "g0": g0, "g1": g1, "kinds": kinds, "rail": false}


func _rail() -> Dictionary:
	return {"d": 1, "v": 24.0, "g0": 6.0, "g1": 9.0, "kinds": ["train"], "rail": true}


func _reset() -> void:
	stage = null
	dist_i = 0
	cross_i = 0
	tries = 0
	up = {"frz": 0, "area": 0, "mana": 0}
	wiz = _make_wizard()
	kid = _make_kid()
	_build_cross()


func _mana_max() -> float:
	return 100.0 + 30.0 * float(up.mana)


# ---- 판 만들기 ----
func _new_stage() -> void:
	if stage and is_instance_valid(stage):
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	lanes.clear()
	cars.clear()
	pedestals.clear()
	pick_car = {}
	box(Vector3(0, -0.2, -20), Vector3(140, 0.1, 140), GRASS, stage)


func _build_cross() -> void:
	_new_stage()
	mode = "cross"
	var spec: Dictionary = towns[dist_i].cross[cross_i]
	var specs: Array = spec.lanes
	has_kid = spec.get("kid", false)
	var n := specs.size()
	z_end = -1.0 - LW * n
	box(Vector3(0, -0.05, 5.0), Vector3(90, 0.1, 12), SOFT, stage)
	box(Vector3(0, -0.06, (-1.0 + z_end) * 0.5), Vector3(90, 0.1, LW * n), ROAD, stage)
	box(Vector3(0, -0.05, z_end - 7.0), Vector3(90, 0.1, 14), SOFT, stage)
	box(Vector3(0, 0.06, -1.0), Vector3(90, 0.14, 0.25), WHITE, stage)
	box(Vector3(0, 0.06, z_end), Vector3(90, 0.14, 0.25), WHITE, stage)
	for k in 9:
		var h := randf_range(2.0, 6.0)
		var bc: Color = [A, B, C, GOOD, D].pick_random()
		box(Vector3(-18.0 + k * 4.5 + randf_range(-0.5, 0.5), h * 0.5, z_end - 9.5 - randf() * 2.0), Vector3(3.4, h, 3.0), bc.lightened(0.35), stage)
	for i in n:
		var sp: Dictionary = specs[i]
		var lz := -1.0 - LW * (i + 0.5)
		var ln := {"z": lz, "d": sp.d, "v": sp.v, "g0": sp.g0, "g1": sp.g1, "rail": sp.rail,
			"half": RAIL_HALF if sp.rail else HALF, "timer": 0.0, "lamps": [], "lamp_on": false}
		lanes.append(ln)
		if sp.rail:
			box(Vector3(0, -0.03, lz), Vector3(90, 0.1, LW), RAIL_BED, stage)
			for x in range(-24, 25, 2):
				box(Vector3(x, 0.02, lz), Vector3(0.4, 0.06, LW * 0.8), Color("c8b48a"), stage)
			for sz in [-0.55, 0.55]:
				box(Vector3(0, 0.08, lz + sz), Vector3(90, 0.12, 0.12), Color("868e96"), stage)
			for lx in [-2.6, 2.6]:
				box(Vector3(lx, 1.0, lz + LW * 0.5 + 0.3), Vector3(0.15, 2.0, 0.15), Color("868e96"), stage)
				ln.lamps.append(box(Vector3(lx, 2.1, lz + LW * 0.5 + 0.3), Vector3(0.5, 0.5, 0.3), WHITE, stage))
		else:
			for x in [-2.0, -1.0, 0.0, 1.0, 2.0]:
				box(Vector3(x, 0.0, lz), Vector3(0.5, 0.03, LW * 0.75), WHITE, stage)
			if i < n - 1 and not specs[i + 1].rail:
				var zb := lz - LW * 0.5
				if specs[i + 1].d != sp.d:
					box(Vector3(0, 0.01, zb), Vector3(90, 0.03, 0.2), D, stage)
				else:
					for x in range(-24, 25, 4):
						box(Vector3(x + 2, 0.01, zb), Vector3(1.8, 0.03, 0.14), WHITE, stage)
		var kinds: Array = sp.kinds
		for k in (1 if sp.rail else 8):
			cars.append(_make_car(i, kinds[k % kinds.size()] if k < kinds.size() else kinds.pick_random()))
	# 처음부터 길에 차가 있게
	for li in lanes.size():
		var ln: Dictionary = lanes[li]
		if ln.rail:
			ln.timer = randf_range(2.5, 4.0)
			continue
		var s: float = HALF - randf() * 4.0
		for c in cars:
			if c.home != li:
				continue
			if s < -HALF + 3.0:
				break
			_spawn(c, s)
			s -= c.len + c.base * randf_range(ln.g0, ln.g1)
		ln.timer = randf_range(ln.g0, ln.g1) * 0.5
	wpos = Vector3(0, 0, 1.5)
	kpos = wpos + Vector3(0.8, 0, 0.8)
	_reset_people()
	mana = _mana_max()
	if tries > 0:
		msg("다시!", 0.8)
	elif cross_i == 0:
		msg("%s\n%s" % [towns[dist_i].name, spec.say], 1.8)
	else:
		msg(spec.say, 1.4)


func _build_pick() -> void:
	_new_stage()
	mode = "pick"
	has_kid = false
	box(Vector3(0, -0.05, -2.0), Vector3(30, 0.1, 22), SOFT, stage)
	for k in UPS.size():
		var x := -4.0 + 4.0 * k
		var u: Array = UPS[k]
		box(Vector3(x, 0.5, -4.5), Vector3(1.6, 1.0, 1.6), WHITE, stage)
		var orb := box(Vector3(x, 1.6, -4.5), Vector3(0.9, 0.9, 0.9), u[1], stage)
		pedestals.append({"x": x, "k": u[0], "name": u[2], "orb": orb})
	wpos = Vector3(0, 0, 1.5)
	_reset_people()
	msg("하나 골라", 1.5)


func _reset_people() -> void:
	wiz.rotation = Vector3.ZERO
	wiz.position = wpos
	me_slow_t = 0.0
	me_fast_t = 0.0
	me_frz_t = 0.0
	robe.material_override = mat(C)
	kid.visible = has_kid
	kid.rotation = Vector3.ZERO
	kid.position = kpos
	cam_at = Vector3(wpos.x * 0.4, 0, wpos.z - 4.5)


func _make_wizard() -> Node3D:
	var r := Node3D.new()
	world.add_child(r)
	robe = box(Vector3(0, 0.55, 0), Vector3(0.8, 1.1, 0.8), C, r)
	box(Vector3(0, 1.3, 0), Vector3(0.5, 0.45, 0.5), SKIN, r)
	box(Vector3(0, 1.1, -0.3), Vector3(0.42, 0.45, 0.14), WHITE, r)
	box(Vector3(0, 1.58, 0), Vector3(1.0, 0.1, 1.0), ME, r)
	box(Vector3(0, 1.82, 0), Vector3(0.55, 0.38, 0.55), ME, r)
	box(Vector3(0, 2.12, 0.05), Vector3(0.3, 0.3, 0.3), ME, r)
	box(Vector3(0, 2.32, 0.1), Vector3(0.14, 0.14, 0.14), D, r)
	box(Vector3(0.5, 0.95, -0.1), Vector3(0.1, 1.9, 0.1), A, r)
	box(Vector3(0.5, 1.95, -0.1), Vector3(0.26, 0.26, 0.26), D, r)
	return r


func _make_kid() -> Node3D:
	var r := Node3D.new()
	world.add_child(r)
	box(Vector3(0, 0.35, 0), Vector3(0.45, 0.7, 0.45), D, r)
	box(Vector3(0, 0.86, 0), Vector3(0.36, 0.32, 0.36), SKIN, r)
	box(Vector3(0, 1.06, -0.05), Vector3(0.42, 0.1, 0.5), GOOD, r)
	return r


func _make_car(li: int, kind: String) -> Dictionary:
	var root := Node3D.new()
	stage.add_child(root)
	root.visible = false
	var col: Color = [A, B, GOOD, C, ME, BAD].pick_random()
	var length := 2.4
	var wd := 1.4
	var body: MeshInstance3D
	var blink: MeshInstance3D = null
	match kind:
		"truck":
			length = 5.2
			wd = 1.7
			col = Color("f8f9fa")
			body = box(Vector3(-0.6, 1.15, 0), Vector3(length - 1.4, 1.9, wd), col, root)
			box(Vector3(length * 0.5 - 0.7, 0.85, 0), Vector3(1.3, 1.5, wd), A, root)
			box(Vector3(length * 0.5 - 0.4, 1.25, 0), Vector3(0.8, 0.45, wd * 1.04), GLASS, root)
		"train":
			length = 26.0
			wd = 2.0
			col = BAD
			body = box(Vector3(length * 0.5 - 2.5, 1.3, 0), Vector3(5.0, 2.4, wd), BAD, root)
			box(Vector3(length * 0.5 - 0.6, 1.8, 0), Vector3(0.5, 0.7, wd * 1.04), GLASS, root)
			for k in 3:
				var cx := length * 0.5 - 8.6 - 6.8 * k
				box(Vector3(cx, 1.2, 0), Vector3(6.4, 2.2, wd * 0.95), B, root)
				box(Vector3(cx, 1.6, 0), Vector3(5.0, 0.5, wd), GLASS, root)
		_:
			if kind == "turn":
				col = D
			body = box(Vector3(0, 0.55, 0), Vector3(length, 0.8, wd), col, root)
			box(Vector3(-0.15, 1.15, 0), Vector3(length * 0.5, 0.5, wd * 0.88), GLASS, root)
			if kind == "turn":
				blink = box(Vector3(length * 0.5 - 0.2, 0.8, 0), Vector3(0.35, 0.35, wd + 0.25), A, root)
	var trails: Array = []
	for side in [-1.0, 1.0]:
		var tr := box(Vector3(0, 0.75, side * wd * 0.35), Vector3(1, 0.1, 0.12), WHITE, root)
		tr.visible = false
		trails.append(tr)
	return {"n": root, "body": body, "trails": trails, "blink": blink, "kind": kind, "len": length, "w": wd,
		"col": col, "home": li, "lane": li, "active": false, "s": 0.0, "base": 0.0, "spd": 0.0,
		"slow_t": 0.0, "haste_t": 0.0, "frz_t": 0.0, "res": 0, "crash_t": 0.0, "cv": Vector3.ZERO,
		"spin": 0.0, "turn_s": 999.0, "lc_t": 0.0, "z_from": 0.0, "look": ""}


func _spawn(c: Dictionary, s: float) -> void:
	var ln: Dictionary = lanes[c.home]
	c.active = true
	c.lane = c.home
	c.s = s
	c.base = ln.v if c.kind == "train" else ln.v * randf_range(0.9, 1.1) * (0.8 if c.kind == "truck" else 1.0)
	c.spd = c.base
	c.slow_t = 0.0
	c.haste_t = 0.0
	c.frz_t = 0.0
	c.crash_t = 0.0
	c.lc_t = 0.0
	c.res = 1 if c.kind == "truck" else 0
	c.turn_s = 999.0
	if c.kind == "turn":
		c.turn_s = float(ln.d) * wpos.x + randf_range(-6.0, -2.0)
	var nd: Node3D = c.n
	nd.visible = true
	nd.rotation = Vector3(0, 0.0 if ln.d > 0 else PI, 0)
	_place(c)
	_look(c)


func _place(c: Dictionary) -> void:
	var ln: Dictionary = lanes[c.lane]
	var z: float = ln.z
	if c.lc_t > 0.0:
		z = lerpf(ln.z, c.z_from, c.lc_t / 0.5)
	c.n.position = Vector3(c.s * float(ln.d), 0.0, z)


func _off(c: Dictionary) -> void:
	c.active = false
	c.n.visible = false


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	shake = maxf(0.0, shake - dt)
	match mode:
		"dead":
			dead_t -= dt
			_cars(dt)
			if dead_t <= 0.0:
				tries += 1
				_build_cross()
		"cross":
			_walk(dt, z_end - 3.0)
			_cars(dt)
			mana = minf(_mana_max(), mana + (9.0 + 7.0 * float(up.mana)) * dt)
			if _hit(wpos, 0.38):
				_die("쾅!")
			elif has_kid and _hit(kpos, 0.28):
				_die("아이가!")
			elif wpos.z < z_end - 0.6 and (not has_kid or kpos.z < z_end - 0.2):
				_clear()
		"pick":
			_walk(dt, -7.0)
			for pd in pedestals:
				pd.orb.rotation.y += dt * 2.0
				var dd := Vector2(wpos.x - pd.x, wpos.z + 4.5).length()
				if dd < 1.3:
					up[pd.k] += 1
					play("win")
					dist_i += 1
					cross_i = 0
					tries = 0
					_build_cross()
					break
				elif dd < 3.5:
					msg(pd.name, 0.15)
	if mode != "dead":
		gauge(mana / _mana_max(), B if mana >= HASTE_COST else BAD)
	_camera(dt)


## 주문에 빌려 준 시간만큼 내 걸음이 바뀐다: 얼음 0, 느리게 0.3배, 빠르게 2배
func _pace() -> float:
	if me_frz_t > 0.0:
		return 0.0
	if me_slow_t > 0.0:
		return 0.3
	if me_fast_t > 0.0:
		return 2.0
	return 1.0


func _walk(dt: float, zmin: float) -> void:
	me_slow_t = maxf(0.0, me_slow_t - dt)
	me_fast_t = maxf(0.0, me_fast_t - dt)
	me_frz_t = maxf(0.0, me_frz_t - dt)
	var pace := _pace()
	robe.material_override = mat(ICE if pace == 0.0 else (CRAWL if pace < 1.0 else (D if pace > 1.0 else C)))
	var m := kit_move
	if m.length() > 0.12 and pace > 0.0:
		wpos += Vector3(m.x, 0, m.y) * WALK * pace * dt
		wpos.x = clampf(wpos.x, -8.0, 8.0)
		wpos.z = clampf(wpos.z, zmin, 3.5)
		wiz.rotation.y = atan2(-m.x, -m.y)
		step_t += dt * pace
		step_snd -= dt * pace
		if step_snd <= 0.0:
			step_snd = 0.42
			beep(170.0 * (0.7 if pace < 1.0 else (1.4 if pace > 1.0 else 1.0)), 0.04, 0.0, 0.12)
	wiz.position = wpos + Vector3(0, absf(sin(step_t * 9.0)) * 0.12, 0)
	if has_kid:
		var tgt := wpos + Vector3(0.7, 0, 0.9)
		var dv := tgt - kpos
		if dv.length() > 0.15 and pace > 0.0:
			kpos += dv.normalized() * minf(dv.length(), WALK * 1.3 * pace * dt)
			kid.rotation.y = atan2(-dv.x, -dv.z)
		kid.position = kpos + Vector3(0, absf(sin(step_t * 12.0)) * 0.1, 0)


func _camera(dt: float) -> void:
	cam_at = cam_at.lerp(Vector3(wpos.x * 0.4, 0, wpos.z - 4.5), minf(1.0, dt * 5.0))
	var o := Vector3(4.0, 19.0, 9.5)
	if shake > 0.0:
		o += Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * shake * 0.7
	cam.position = cam_at + o
	cam.look_at(cam_at)


func _cars(dt: float) -> void:
	blink_t += dt
	# 나타나기 + 기찻길 신호
	for li in lanes.size():
		var ln: Dictionary = lanes[li]
		ln.timer -= dt
		if ln.timer <= 0.0:
			var back_s := 999.0
			var idle: Dictionary = {}
			for c in cars:
				if c.active and c.crash_t <= 0.0 and c.lane == li:
					back_s = minf(back_s, c.s)
				if not c.active and c.home == li and idle.is_empty():
					idle = c
			if not idle.is_empty() and back_s > -ln.half + idle.len + 1.5:
				_spawn(idle, -ln.half)
				ln.timer = randf_range(ln.g0, ln.g1)
		if ln.rail:
			var near := false
			for c in cars:
				if c.active and c.lane == li and absf(c.s) < 18.0:
					near = true
			var warn: bool = ln.timer < 2.6 or near
			var on := warn and fmod(blink_t, 0.4) < 0.2
			if on != ln.lamp_on:
				ln.lamp_on = on
				for lp in ln.lamps:
					lp.material_override = mat(BAD if on else WHITE)
				if on:
					beep(990.0, 0.07, 0.0, 0.16)
	# 주문에 따른 속도
	for c in cars:
		if not c.active or c.crash_t > 0.0:
			continue
		c.slow_t = maxf(0.0, c.slow_t - dt)
		c.haste_t = maxf(0.0, c.haste_t - dt)
		c.frz_t = maxf(0.0, c.frz_t - dt)
		var tgt: float = c.base
		if c.kind != "train":
			if c.frz_t > 0.0:
				tgt = 0.0
				c.spd = 0.0
			elif c.slow_t > 0.0:
				tgt = c.base * 0.12
			elif c.haste_t > 0.0:
				tgt = c.base * 3.0 + 14.0
		c.spd = move_toward(c.spd, tgt, (60.0 if c.haste_t > 0.0 else 30.0) * dt)
	# 같은 차선: 앞차가 느리면 뒤차도 줄을 선다. 빠르게 한 차가 앞차를 들이받으면 쾅
	for li in lanes.size():
		var row: Array = []
		for c in cars:
			if c.active and c.crash_t <= 0.0 and c.lane == li:
				row.append(c)
		row.sort_custom(func(a, b): return a.s > b.s)
		for i in range(1, row.size()):
			var c: Dictionary = row[i]
			var ah: Dictionary = row[i - 1]
			if c.crash_t > 0.0 or ah.crash_t > 0.0:
				continue
			var gap: float = (ah.s - ah.len * 0.5) - (c.s + c.len * 0.5)
			if gap < 0.7:
				if c.haste_t > 0.0 and c.spd > ah.spd + 5.0:
					_crash(c, ah)
				else:
					c.spd = minf(c.spd, ah.spd)
					if gap < 0.15:
						c.s = ah.s - ah.len * 0.5 - c.len * 0.5 - 0.15
	# 움직이기
	for c in cars:
		if not c.active:
			continue
		if c.crash_t > 0.0:
			c.crash_t -= dt
			c.n.position += c.cv * dt
			c.cv *= maxf(0.0, 1.0 - 1.4 * dt)
			c.n.rotation.y += c.spin * dt
			if c.crash_t <= 0.0:
				_off(c)
			continue
		var prev: float = c.s
		c.s += c.spd * dt
		if prev < c.turn_s and c.s >= c.turn_s:
			_lane_change(c)
		if c.lc_t > 0.0:
			c.lc_t = maxf(0.0, c.lc_t - dt)
		_place(c)
		if absf(c.s) > lanes[c.lane].half + 3.0:
			_off(c)
			continue
		_look(c)
	# 미끄러지는 사고 차가 다른 차를 치면 연쇄
	for c in cars:
		if not c.active or c.crash_t <= 0.0:
			continue
		var cp: Vector3 = c.n.position
		for o in cars:
			if not o.active or o.crash_t > 0.0 or o.kind == "train":
				continue
			var op: Vector3 = o.n.position
			if Vector2(cp.x - op.x, cp.z - op.z).length() < (c.len + o.len) * 0.3 + 0.4:
				_crash1(o, c.cv * 0.8)
				msg("연쇄!", 0.6)
				beep(110.0, 0.25, 60.0, 0.32)
				shake = maxf(shake, 0.3)


func _lane_change(c: Dictionary) -> void:
	var d: int = lanes[c.lane].d
	var pick := -1
	for j in [c.lane - 1, c.lane + 1]:
		if j < 0 or j >= lanes.size():
			continue
		var lj: Dictionary = lanes[j]
		if lj.rail or lj.d != d:
			continue
		if pick < 0 or absf(lj.z - wpos.z) < absf(lanes[pick].z - wpos.z):
			pick = j
	if pick < 0:
		return
	c.z_from = c.n.position.z
	c.lane = pick
	c.lc_t = 0.5
	beep(470.0, 0.12, 380.0, 0.2)


func _crash(c: Dictionary, ah: Dictionary) -> void:
	var d: float = lanes[c.lane].d
	var side := 1.0 if randf() < 0.5 else -1.0
	_crash1(c, Vector3(d * c.spd * 0.5, 0, side * 5.0))
	_crash1(ah, Vector3(d * (ah.spd + 10.0) * 0.6, 0, -side * 5.0))
	msg("쾅!", 0.6)
	beep(120.0, 0.3, 60.0, 0.35)
	shake = 0.4


func _crash1(o: Dictionary, v: Vector3) -> void:
	if o.kind == "train":
		return
	o.crash_t = 1.4
	o.cv = v + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	o.spin = randf_range(-10.0, 10.0)
	for tr in o.trails:
		tr.visible = false


## 느림 = 하늘색, 얼음 = 흰색, 빠름 = 뒤로 흰 줄이 길게
func _look(c: Dictionary) -> void:
	var lk := "n"
	if c.frz_t > 0.0:
		lk = "ice"
	elif c.slow_t > 0.0:
		lk = "slow"
	if lk != c.look and c.kind != "train":
		c.look = lk
		var col: Color = c.col
		c.body.material_override = mat(ICE if lk == "ice" else (col.lerp(CRAWL, 0.65) if lk == "slow" else col))
	var fast: bool = c.spd > c.base * 1.5 + 2.0
	var tl: float = (c.spd - c.base) * 0.3
	for tr in c.trails:
		tr.visible = fast
		if fast:
			tr.scale.x = tl
			tr.position.x = -c.len * 0.5 - tl * 0.5
	if c.blink:
		c.blink.visible = fmod(blink_t, 0.5) < 0.25


func _hit(p: Vector3, r: float) -> bool:
	for c in cars:
		if not c.active:
			continue
		var cp: Vector3 = c.n.position
		if c.crash_t > 0.0:
			if Vector2(cp.x - p.x, cp.z - p.z).length() < c.len * 0.45 + r:
				return true
		elif absf(cp.x - p.x) < c.len * 0.5 + r and absf(cp.z - p.z) < c.w * 0.5 + r:
			return true
	return false


func _die(word: String) -> void:
	mode = "dead"
	dead_t = 1.1
	play("bad")
	msg(word, 1.0)
	shake = 0.5
	wiz.rotation.z = PI * 0.5
	pick_car = {}


func _clear() -> void:
	score += 1
	play("good")
	cross_i += 1
	tries = 0
	if cross_i >= towns[dist_i].cross.size():
		if dist_i >= towns.size() - 1:
			msg("마을 끝!", 2.0)
			play("win")
			end()
			return
		_build_pick()
		return
	_build_cross()


# ---- 주문 ----
func _car_at(p: Vector2) -> Dictionary:
	var g := ground(p, 0.6)
	var found: Dictionary = {}
	var bd := 1.5
	for c in cars:
		if not c.active or c.crash_t > 0.0:
			continue
		var cp: Vector3 = c.n.position
		var dx := maxf(0.0, absf(cp.x - g.x) - c.len * 0.5)
		var dz := maxf(0.0, absf(cp.z - g.z) - c.w * 0.5)
		if dx + dz < bd:
			bd = dx + dz
			found = c
	return found


func _tap(p: Vector2) -> void:
	pick_from = p
	cast_done = false
	pick_car = _car_at(p) if mode == "cross" else {}


func _drag(p: Vector2) -> void:
	if cast_done or pick_car.is_empty() or mode != "cross":
		return
	if p.distance_to(pick_from) > 70.0:
		var dw := ground(p, 0.6) - ground(pick_from, 0.6)
		var dd: float = lanes[pick_car.lane].d
		_cast(pick_car, dw.x * dd > 0.0)
		cast_done = true


func _lift(_p: Vector2) -> void:
	if not cast_done and not pick_car.is_empty() and mode == "cross":
		_cast(pick_car, false)
	pick_car = {}


func _cast(c: Dictionary, fast: bool) -> void:
	if not c.active or c.crash_t > 0.0:
		return
	if c.kind == "train":
		msg("안 돼!", 0.6)
		beep(150.0, 0.2, 120.0, 0.25)
		return
	var cost := HASTE_COST if fast else SLOW_COST
	if mana < cost:
		msg("마나 부족", 0.6)
		beep(200.0, 0.12, 150.0, 0.2)
		return
	mana -= cost
	if c.res > 0:
		c.res -= 1
		msg("버팀!", 0.6)
		beep(260.0, 0.14, 200.0, 0.3)
		return
	if fast:
		c.haste_t = 2.6
		c.slow_t = 0.0
		c.frz_t = 0.0
		me_fast_t = 2.6
		me_slow_t = 0.0
		me_frz_t = 0.0
		beep(300.0, 0.2, 1700.0, 0.28)
		shake = maxf(shake, 0.25)
		msg("휙! 나도", 0.5)
	else:
		_slow(c)
		me_slow_t = 4.0
		me_fast_t = 0.0
		if up.frz > 0:
			me_frz_t = 0.5 + 0.5 * float(up.frz)
		if up.area > 0:
			var cp: Vector3 = c.n.position
			for o in cars:
				if o.n == c.n or not o.active or o.crash_t > 0.0 or o.kind == "train":
					continue
				if cp.distance_to(o.n.position) < 2.5 + 2.0 * float(up.area):
					if o.res > 0:
						o.res -= 1
					else:
						_slow(o)
		beep(760.0, 0.4, 140.0, 0.26)
		msg("느리게… 나도", 0.5)


func _slow(c: Dictionary) -> void:
	c.slow_t = 4.0
	c.haste_t = 0.0
	if up.frz > 0:
		c.frz_t = 0.5 + 0.5 * float(up.frz)
	_look(c)
