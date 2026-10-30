extends Tofu
## 단속 경찰 1인칭: 갓길·육교에서 달려오는 차를 보고 과속차만 탭해서 세운다. '측정'을 누르고 있으면 가장 가까운 차 속도를 잰다(배터리).
## 정상 차·구급차를 세우거나 과속차를 놓치면 목숨 -1(3개). 근무지 국도→고속도로→비 오는 밤→터널→도심, 근무 사이 장비 하나.

const K := 0.6  # km/h -> 판 속도(m/s) 비율
const POOL := 24
const SPAWN_Z := -170.0
const PLACES := [
	{"name": "시골 국도", "limit": 80, "margin": 22, "lanes": [-1.8, 1.8], "cam": Vector3(5.2, 1.7, 0), "look": Vector3(-0.8, 0.6, -40), "side": 4.0, "every": 1.7, "count": 14},
	{"name": "고속도로", "limit": 110, "margin": 16, "lanes": [-3.6, 0.0, 3.6], "cam": Vector3(2.0, 7.5, 4.4), "look": Vector3(0, 0, -45), "side": 6.8, "every": 1.15, "count": 20},
	{"name": "비 오는 밤", "limit": 90, "margin": 15, "lanes": [-3.6, 0.0, 3.6], "cam": Vector3(8.0, 2.0, 0), "look": Vector3(0, 0.5, -40), "side": 6.4, "every": 1.2, "count": 20},
	{"name": "터널", "limit": 80, "margin": 13, "lanes": [-1.8, 1.8], "cam": Vector3(5.0, 1.8, 0), "look": Vector3(-0.8, 1.0, -40), "side": 4.0, "every": 1.1, "count": 20},
	{"name": "도심", "limit": 60, "margin": 12, "lanes": [-1.8, 1.8], "cam": Vector3(5.0, 1.7, 0), "look": Vector3(-0.8, 0.8, -35), "side": 4.0, "every": 1.1, "count": 22},
]
const UPS := {
	"gun": ["좋은 측정기", "더 빨리 재고 배터리가 오래 간다"],
	"partner": ["파트너", "놓친 과속차를 근무마다 1대 잡아 준다"],
	"slow": ["슬로모 카메라", "측정하는 동안 세상이 느려진다"],
	"life": ["서장님 칭찬", "목숨 +1"],
}
const CAR_COLS := [A, B, C, D, GOOD, ME, WHITE]


class Car:
	var n: Node3D
	var body: MeshInstance3D
	var cab: MeshInstance3D
	var stripe: MeshInstance3D
	var wheels: Array[MeshInstance3D] = []
	var lights: Array[MeshInstance3D] = []
	var sirens: Array[MeshInstance3D] = []
	var on := false
	var kind := "car"
	var lane := 0
	var x := 0.0
	var z := 0.0
	var spd := 0.0
	var target := 0.0
	var top := 1.5  # 지붕 높이 (측정 표시 자리)
	var stopped := false
	var passed := false
	var cued := false
	var braker := false
	var braking := false
	var park_t := 0.0
	var wob := 0.0


var cars: Array[Car] = []
var stage: Node3D
var rain: Array[MeshInstance3D] = []
var marker: MeshInstance3D
var school_paint: MeshInstance3D
var sign_l: Label3D
var info_l: Label
var pick_root: Control
var pick_rects: Array[ColorRect] = []
var pick_titles: Array[Label] = []
var pick_descs: Array[Label] = []
var pick_keys: Array[String] = []
var env_ref: Environment
var sun_ref: DirectionalLight3D
var day_bg := Color("d8eeff")
# 판 상태
var lives := 3
var ups := {}
var shift := 0
var mode := "shift"  # shift / done / pick
var done_t := 0.0
var place: Dictionary = {}
var lanes: Array = []
var limit := 80
var margin := 20
var loop_n := 0
var every := 1.5
var left_n := 0
var spawn_t := 0.0
var partner_left := 0
var school := false
var clock := 0.0
var cam_base := Vector3.ZERO
var shake := 0.0
var gun_bat := 1.0
var gun_tgt: Car = null
var gun_lock := 0.0
var gun_read := false
var siren_t := 0.0
var siren_hi := false


func _setup() -> void:
	howto = "단속 경찰이다. 달려오는 차 중 과속차만 탭해서 세운다.\n속도는 눈과 소리로 판단. 아래 '측정'을 누르고 있으면 가장 가까운 차의 속도가 뜬다(배터리).\n정상 차나 구급차를 세우거나 과속차를 놓치면 목숨 -1, 3번이면 끝.\n근무가 끝나면 장비를 하나 고른다."
	time_limit = 0.0
	cam.fov = 75.0
	cam.far = 400.0
	kit_button("gun", "측정", Vector2(360, 1150), 95.0, B)
	for ch in get_children():
		if ch is WorldEnvironment:
			env_ref = ch.environment
			day_bg = env_ref.background_color
		elif ch is DirectionalLight3D:
			sun_ref = ch
	var hud := CanvasLayer.new()
	add_child(hud)
	info_l = _label(hud, 34, 240, 50)
	# 장비 고르기 (근무 사이)
	var top_layer := CanvasLayer.new()
	top_layer.layer = 6
	add_child(top_layer)
	pick_root = Control.new()
	pick_root.size = Vector2(720, 1280)
	pick_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_layer.add_child(pick_root)
	var head := _label(pick_root, 54, 290, 70)
	head.text = "장비 하나 고르기"
	for i in 3:
		var r := ColorRect.new()
		r.color = [A, B, C][i]
		r.position = Vector2(60, 380 + i * 230)
		r.size = Vector2(600, 200)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pick_root.add_child(r)
		var tl := _label(r, 50, 34, 70)
		tl.size.x = 600
		var dl := _label(r, 30, 112, 60)
		dl.size.x = 600
		pick_rects.append(r)
		pick_titles.append(tl)
		pick_descs.append(dl)
	pick_root.visible = false


func _reset() -> void:
	stage = null
	rain.clear()
	cars.clear()
	lives = 3
	ups = {"gun": 0, "partner": 0, "slow": 0}
	gun_bat = 1.0
	gun_tgt = null
	shake = 0.0
	pick_root.visible = false
	for i in POOL:
		cars.append(_make_car())
	marker = box(Vector3(0, -50, 0), Vector3(0.9, 0.9, 0.9), D)
	_start_shift(0)


func _make_car() -> Car:
	var c := Car.new()
	c.n = Node3D.new()
	world.add_child(c.n)
	c.body = box(Vector3.ZERO, Vector3.ONE, A, c.n)
	c.cab = box(Vector3.ZERO, Vector3.ONE, SOFT, c.n)
	c.stripe = box(Vector3.ZERO, Vector3.ONE, BAD, c.n)
	for i in 4:
		c.wheels.append(box(Vector3.ZERO, Vector3.ONE, INK, c.n))
	for i in 2:
		c.lights.append(box(Vector3.ZERO, Vector3.ONE, Color("fff3bf"), c.n))
	for i in 2:
		c.sirens.append(box(Vector3.ZERO, Vector3.ONE, BAD if i == 0 else B, c.n))
	c.n.visible = false
	return c


# ---- 근무 ----
func _start_shift(s: int) -> void:
	shift = s
	place = PLACES[s % PLACES.size()]
	loop_n = s / PLACES.size()
	lanes = place.lanes
	limit = place.limit
	margin = maxi(6, int(place.margin) - 4 * loop_n)
	every = float(place.every) * pow(0.85, loop_n)
	left_n = int(place.count) + 4 * loop_n
	spawn_t = 1.2
	partner_left = ups.partner
	school = false
	mode = "shift"
	for c in cars:
		_off(c)
	cam_base = place.cam
	cam.position = cam_base
	cam.look_at(place.look)
	_build_stage(s % PLACES.size())
	msg("근무 %d  %s" % [s + 1, place.name], 1.8)
	beep(660.0, 0.12, 990.0, 0.25)


func _p() -> int:
	return shift % PLACES.size() if loop_n == 0 else 9  # 두 바퀴째부터 변주 전부


func _build_stage(p: int) -> void:
	if stage:
		stage.queue_free()
	stage = Node3D.new()
	world.add_child(stage)
	rain.clear()
	school_paint = null
	var night := p == 2
	env_ref.background_color = Color("3a4680") if night else (Color("ffe3c4") if p == 4 else day_bg)
	sun_ref.light_energy = 0.4 if night else 0.9
	var side: float = place.side
	var x0: float = float(lanes[0]) - 2.3
	var x1: float = side + 1.4
	var road_col := Color("5f6680") if night else Color("8a919e")
	# 땅
	var grass := Color("2f6b45") if night else Color("8ce99a")
	if p != 3:
		box(Vector3(0, -0.12, -80), Vector3(260, 0.1, 300), SOFT if p == 4 else grass, stage)
	box(Vector3((x0 + x1) * 0.5, -0.05, -70), Vector3(x1 - x0, 0.1, 230), road_col, stage)
	# 차선
	for i in lanes.size() - 1:
		var bx: float = (float(lanes[i]) + float(lanes[i + 1])) * 0.5
		for zz in range(-176, 30, 12):
			box(Vector3(bx, 0.01, zz), Vector3(0.16, 0.02, 4.5), WHITE, stage)
	box(Vector3(float(lanes[0]) - 1.9, 0.01, -70), Vector3(0.2, 0.02, 230), D, stage)
	box(Vector3(float(lanes[-1]) + 1.9, 0.01, -70), Vector3(0.2, 0.02, 230), WHITE, stage)
	var sign_pos := Vector3(side + 1.6, 2.4, -24)
	var sign_s := 1.0
	match p:
		0:
			for i in 26:
				var left := i % 2 == 0
				var tx := randf_range(-40, x0 - 4) if left else randf_range(x1 + 3, 40)
				var tz := randf_range(-170, 10)
				box(Vector3(tx, 1.0, tz), Vector3(0.5, 2.0, 0.5), Color("a0522d"), stage)
				box(Vector3(tx, 3.0, tz), Vector3(2.6, 2.6, 2.6), Color("51cf66") if i % 3 else Color("40c057"), stage)
			for i in 5:
				box(Vector3(-90 + i * 45, 6, -230), Vector3(60, 22, 20), Color("b2f2bb"), stage)
		1:
			# 육교 위: 발밑 다리와 난간, 양쪽 가드레일
			box(Vector3(0, 6.6, cam_base.z + 2.1), Vector3(60, 0.8, 4), SOFT, stage)
			box(Vector3(0, 7.05, cam_base.z + 0.2), Vector3(60, 0.12, 0.12), BAD, stage)
			for gx in [x0 + 0.2, x1 - 0.2]:
				box(Vector3(gx, 0.5, -70), Vector3(0.2, 0.3, 230), WHITE, stage)
			for i in 6:
				box(Vector3(-70 + i * 28, 10, -220), Vector3(18, 24 + (i % 3) * 10, 14), [B, C, A][i % 3].lightened(0.4), stage)
			sign_pos = Vector3(x1 + 1.5, 4.0, -34)
			sign_s = 1.8
		2:
			for i in 9:
				var lz := -160.0 + i * 22.0
				box(Vector3(x1 + 0.8, 3.0, lz), Vector3(0.2, 6.0, 0.2), Color("adb5bd"), stage)
				box(Vector3(x1 - 0.4, 6.0, lz), Vector3(2.4, 0.3, 0.6), D, stage)
			for i in 50:
				var r := box(_rain_spot(randf_range(0, 9)), Vector3(0.04, 0.7, 0.04), Color("a5d8ff"), stage)
				rain.append(r)
		3:
			var wall := Color("f4e1c1")
			box(Vector3(x0 - 0.5, 3.0, -70), Vector3(1, 6.5, 230), wall, stage)
			box(Vector3(x1 + 1.6, 3.0, -70), Vector3(1, 6.5, 230), wall, stage)
			box(Vector3((x0 + x1) * 0.5 + 0.5, 6.4, -70), Vector3(x1 - x0 + 4, 0.6, 230), Color("d9c6a5"), stage)
			for i in 26:
				var lz2 := -176.0 + i * 8.0
				box(Vector3(x0 + 0.05, 4.2, lz2), Vector3(0.12, 0.25, 2.5), A, stage)
				box(Vector3(x1 + 1.05, 4.2, lz2), Vector3(0.12, 0.25, 2.5), A, stage)
			box(Vector3(0, 3, -186), Vector3(30, 8, 1), Color("ffd43b"), stage)  # 멀리 터널 끝 빛
		4:
			var cols := [A, B, C, D, Color("ff8787"), Color("63e6be")]
			for i in 14:
				var bz := -170.0 + i * 14.0
				box(Vector3(x0 - 7, 7, bz), Vector3(9, 14 + (i % 4) * 5, 11), cols[i % cols.size()], stage)
				box(Vector3(x1 + 8, 6, bz + 5), Vector3(9, 12 + (i % 3) * 6, 11), cols[(i + 2) % cols.size()], stage)
			box(Vector3(x1 + 1.8, 0.08, -70), Vector3(2.2, 0.16, 230), SOFT, stage)
			for i in 8:
				box(Vector3(x0 + 0.8 + i * (x1 - x0 - 1.6) / 7.0, 0.02, -70), Vector3(0.6, 0.03, 4), WHITE, stage)
			school_paint = box(Vector3((x0 + x1) * 0.5, 0.015, -45), Vector3(x1 - x0 - 0.4, 0.02, 60), Color("ff8787"), stage)
			school_paint.visible = false
	# 제한 속도 표지
	box(sign_pos - Vector3(0, sign_pos.y * 0.5 + 0.4 * sign_s, 0.1), Vector3(0.15, sign_pos.y, 0.15), Color("495057"), stage)
	box(sign_pos, Vector3(1.6, 1.6, 0.1) * sign_s, BAD, stage)
	box(sign_pos + Vector3(0, 0, 0.04), Vector3(1.25, 1.25, 0.1) * sign_s, WHITE, stage)
	sign_l = Label3D.new()
	sign_l.font = _font
	sign_l.font_size = 120
	sign_l.pixel_size = 0.0075 * sign_s
	sign_l.modulate = INK
	sign_l.outline_size = 0
	sign_l.position = sign_pos + Vector3(0, 0, 0.12)
	sign_l.text = str(limit)
	stage.add_child(sign_l)


func _rain_spot(y: float) -> Vector3:
	return cam_base + Vector3(randf_range(-9, 7), y - cam_base.y, randf_range(-28, -2))


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	clock += dt
	_gun(dt)
	var slow := 1.0
	if gun_tgt != null and ups.slow > 0:
		slow = 0.4 if ups.slow == 1 else 0.25
	var wdt := dt * slow
	# 흔들림
	shake = move_toward(shake, 0.0, 1.6 * dt)
	cam.position = cam_base + Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * shake * 0.25
	info_l.text = "근무 %d · %s   제한 %d   목숨 %d" % [shift + 1, place.name, limit, lives]
	for r in rain:
		r.position.y -= 22.0 * wdt
		if r.position.y < 0.0:
			r.position = _rain_spot(9.0)
	if mode == "pick":
		return
	if mode == "done":
		done_t -= dt
		if done_t <= 0.0:
			_open_pick()
		return
	# 생성
	spawn_t -= wdt
	if left_n > 0 and spawn_t <= 0.0:
		spawn_t = every * randf_range(0.7, 1.3)
		_spawn()
	# 도심: 중간에 스쿨존으로 제한이 바뀐다
	if _p() >= 4 and not school and left_n <= int(place.count) / 2:
		school = true
		limit = maxi(30, limit / 2)
		margin = maxi(6, margin - 2)
		sign_l.text = str(limit)
		if school_paint:
			school_paint.visible = true
		msg("제한 %d로 바뀜!" % limit, 1.6)
		beep(990.0, 0.3, 660.0, 0.3)
		for c in cars:
			# 원래 지키던 차들은 새 제한에 맞춰 줄인다
			if c.on and not c.stopped and c.kind != "amb" and c.target <= place.limit:
				c.target = limit - randf_range(2, 10)
	# 차 움직임
	var any := false
	var near_amb := 999.0
	for c in cars:
		if not c.on:
			continue
		any = true
		_move(c, wdt)
		if c.on and c.kind == "amb":
			near_amb = minf(near_amb, cam_base.z - c.z)
			var blink := int(clock * 8.0) % 2 == 0
			c.sirens[0].visible = blink
			c.sirens[1].visible = not blink
	if near_amb < 120.0 and near_amb > -10.0:
		siren_t -= dt
		if siren_t <= 0.0:
			siren_t = 0.3
			siren_hi = not siren_hi
			beep(1020.0 if siren_hi else 760.0, 0.26, 0.0, 0.16)
	if left_n <= 0 and not any:
		mode = "done"
		done_t = 1.3
		score += 20 * (1 + loop_n)
		msg("근무 끝!", 1.3)
		play("win")


func _move(c: Car, dt: float) -> void:
	if c.stopped:
		c.spd = move_toward(c.spd, 0.0, 110.0 * dt)
		c.x = move_toward(c.x, place.side, 6.0 * dt)
		c.n.rotation.x = 0.06 if c.spd > 0.0 else 0.0
		if c.spd <= 0.0:
			c.park_t += dt
			if c.park_t > 1.3:
				_off(c)
				return
	else:
		if c.braker and not c.braking and c.z > cam_base.z - 55.0:
			c.braking = true
			c.target = limit - randf_range(8, 16)
			beep(300.0, 0.2, 200.0, 0.2)
		c.spd = move_toward(c.spd, c.target, (75.0 if c.braking else 30.0) * dt)
		c.n.rotation.x = 0.07 if c.braking and c.spd > c.target + 2.0 else 0.0
		if c.kind == "bike":
			c.wob += dt * 2.4
			var mid: float = (float(lanes[0]) + float(lanes[-1])) * 0.5
			var half: float = (float(lanes[-1]) - float(lanes[0])) * 0.5 + 1.0
			c.x = clampf(float(lanes[c.lane]) + sin(c.wob) * 2.0, mid - half, mid + half)
			c.n.rotation.z = -cos(c.wob) * 0.25
		else:
			_avoid(c)
			c.x = move_toward(c.x, float(lanes[c.lane]), 4.0 * dt)
	var mv := c.spd / 3.6 * K * dt
	c.z += mv
	for w in c.wheels:
		w.rotation.x += mv / 0.3
	c.n.position = Vector3(c.x, 0, c.z)
	# 소리: 다가올 때 엔진(높을수록 빠름), 지나갈 때 휙
	if not c.cued and c.z > cam_base.z - 75.0:
		c.cued = true
		beep(_q(110.0 + c.spd * 2.6), 0.14, 0.0, 0.12)
	if not c.passed and c.z > cam_base.z - 1.0:
		c.passed = true
		if not c.stopped:
			_whoosh(c)
			if c.kind != "amb" and c.spd > limit:
				_missed(c)
	if c.z > cam_base.z + 25.0:
		_off(c)


func _whoosh(c: Car) -> void:
	var fast := c.spd > limit
	match c.kind:
		"truck":
			beep(110.0, 0.45, 45.0, 0.4)
			shake = maxf(shake, 0.5)
		"bike":
			beep(_q(520.0 + c.spd * 3.0), 0.18, 260.0, 0.28)
		_:
			beep(_q(180.0 + c.spd * 3.0), 0.28, _q(80.0 + c.spd), 0.3)
	if fast:
		shake = maxf(shake, 0.2)


func _q(f: float) -> float:
	return roundf(f / 20.0) * 20.0


func _avoid(c: Car) -> void:
	var gap := 14.0 if c.kind == "truck" else 10.0
	var ahead: Car = null
	for o in cars:
		if o == c or not o.on or o.stopped or o.kind == "bike":
			continue
		if absf(o.x - c.x) < 1.6 and o.z > c.z and o.z - c.z < gap and o.spd < c.spd:
			ahead = o
			break
	if ahead == null:
		return
	var dirs := [-1, 1] if randf() < 0.5 else [1, -1]
	for dl in dirs:
		var nl: int = c.lane + dl
		if nl >= 0 and nl < lanes.size() and _lane_free(nl, c.z, gap, c):
			c.lane = nl
			return


func _lane_free(l: int, z: float, gap: float, me: Car) -> bool:
	for o in cars:
		if o != me and o.on and not o.stopped and o.lane == l and absf(o.z - z) < gap:
			return false
	return true


# ---- 차 만들기 ----
func _spawn() -> void:
	var free_lanes: Array[int] = []
	for l in lanes.size():
		if _lane_free(l, SPAWN_Z, 20.0, null):
			free_lanes.append(l)
	if free_lanes.is_empty():
		spawn_t = 0.3
		return
	var lane: int = free_lanes.pick_random()
	left_n -= 1
	var p := _p()
	var speeding := randf() < 0.38
	var kind := "car"
	var r := randf()
	if p >= 3 and r < 0.1:
		kind = "amb"
	elif p >= 1 and r < 0.25:
		kind = "bike"
	elif r < 0.42:
		kind = "truck"
		speeding = randf() < 0.2
	var kmh := _kmh(speeding)
	if kind == "amb":
		kmh = limit + randf_range(35, 55)
	if kind == "car" and p >= 1 and randf() < 0.15:
		# 줄지어 오는 차들: 같은 속도
		for i in 4:
			_place(_free_car(), "car", lane, SPAWN_Z - i * 11.0, kmh, false)
		return
	var braker := kind == "car" and speeding and p >= 2 and randf() < 0.45
	_place(_free_car(), kind, lane, SPAWN_Z, kmh, braker)


func _kmh(speeding: bool) -> float:
	if speeding:
		return limit + margin + randf() * limit * 0.4
	return limit - 2.0 - pow(randf(), 2.0) * limit * 0.35


func _free_car() -> Car:
	for c in cars:
		if not c.on:
			return c
	return null


func _place(c: Car, kind: String, lane: int, z: float, kmh: float, braker: bool) -> void:
	if c == null:
		return
	c.on = true
	c.kind = kind
	c.lane = lane
	c.x = float(lanes[lane])
	c.z = z
	c.spd = kmh
	c.target = kmh
	c.stopped = false
	c.passed = false
	c.cued = false
	c.braker = braker
	c.braking = false
	c.park_t = 0.0
	c.wob = randf() * TAU
	c.n.rotation = Vector3.ZERO
	c.n.position = Vector3(c.x, 0, z)
	c.n.visible = true
	var col: Color = CAR_COLS.pick_random()
	c.stripe.visible = false
	for s in c.sirens:
		s.visible = false
	for w in c.wheels:
		w.visible = true
	c.lights[1].visible = true
	match kind:
		"truck":
			_part(c.body, Vector3(0, 1.9, -1.2), Vector3(2.5, 2.8, 7.0), [WHITE, D, B, GOOD].pick_random())
			_part(c.cab, Vector3(0, 1.3, 3.2), Vector3(2.4, 2.0, 1.8), col)
			var wp := [Vector3(-1.2, 0.45, 2.8), Vector3(1.2, 0.45, 2.8), Vector3(-1.2, 0.45, -3.0), Vector3(1.2, 0.45, -3.0)]
			for i in 4:
				_part(c.wheels[i], wp[i], Vector3(0.3, 0.9, 0.9), INK)
			_part(c.lights[0], Vector3(-0.9, 0.8, 4.12), Vector3(0.4, 0.22, 0.05), Color("fff3bf"))
			_part(c.lights[1], Vector3(0.9, 0.8, 4.12), Vector3(0.4, 0.22, 0.05), Color("fff3bf"))
			c.top = 3.4
		"bike":
			_part(c.body, Vector3(0, 0.6, 0), Vector3(0.35, 0.45, 1.7), col)
			_part(c.cab, Vector3(0, 1.35, -0.15), Vector3(0.5, 0.9, 0.45), INK)
			_part(c.wheels[0], Vector3(0, 0.35, 0.7), Vector3(0.15, 0.7, 0.7), INK)
			_part(c.wheels[1], Vector3(0, 0.35, -0.7), Vector3(0.15, 0.7, 0.7), INK)
			c.wheels[2].visible = false
			c.wheels[3].visible = false
			_part(c.lights[0], Vector3(0, 0.8, 0.87), Vector3(0.25, 0.2, 0.05), Color("fff3bf"))
			c.lights[1].visible = false
			c.top = 2.0
		"amb":
			_part(c.body, Vector3(0, 1.2, -0.4), Vector3(2.1, 2.0, 4.6), WHITE)
			_part(c.cab, Vector3(0, 0.85, 2.4), Vector3(2.0, 1.3, 1.0), WHITE)
			c.stripe.visible = true
			_part(c.stripe, Vector3(0, 1.2, -0.4), Vector3(2.16, 0.35, 4.66), BAD)
			_part(c.sirens[0], Vector3(-0.5, 2.3, 1.4), Vector3(0.6, 0.3, 0.4), BAD)
			_part(c.sirens[1], Vector3(0.5, 2.3, 1.4), Vector3(0.6, 0.3, 0.4), B)
			var ap := [Vector3(-1.0, 0.35, 1.9), Vector3(1.0, 0.35, 1.9), Vector3(-1.0, 0.35, -1.9), Vector3(1.0, 0.35, -1.9)]
			for i in 4:
				_part(c.wheels[i], ap[i], Vector3(0.25, 0.7, 0.7), INK)
			_part(c.lights[0], Vector3(-0.7, 0.7, 2.92), Vector3(0.4, 0.2, 0.05), Color("fff3bf"))
			_part(c.lights[1], Vector3(0.7, 0.7, 2.92), Vector3(0.4, 0.2, 0.05), Color("fff3bf"))
			c.top = 2.6
		_:
			_part(c.body, Vector3(0, 0.6, 0), Vector3(1.8, 0.7, 4.0), col)
			_part(c.cab, Vector3(0, 1.2, -0.3), Vector3(1.55, 0.55, 2.0), SOFT if col != SOFT else WHITE)
			var cp := [Vector3(-0.9, 0.32, 1.3), Vector3(0.9, 0.32, 1.3), Vector3(-0.9, 0.32, -1.3), Vector3(0.9, 0.32, -1.3)]
			for i in 4:
				_part(c.wheels[i], cp[i], Vector3(0.25, 0.64, 0.64), INK)
			_part(c.lights[0], Vector3(-0.6, 0.65, 2.02), Vector3(0.4, 0.18, 0.05), Color("fff3bf"))
			_part(c.lights[1], Vector3(0.6, 0.65, 2.02), Vector3(0.4, 0.18, 0.05), Color("fff3bf"))
			c.top = 1.6


func _part(m: MeshInstance3D, pos: Vector3, size: Vector3, col: Color) -> void:
	m.position = pos
	m.scale = size
	m.rotation = Vector3.ZERO
	m.material_override = mat(col)


func _off(c: Car) -> void:
	c.on = false
	c.n.visible = false
	if gun_tgt == c:
		gun_tgt = null


# ---- 측정기 ----
func _gun(dt: float) -> void:
	var lv: int = ups.gun
	var lock_time := 0.45 / (1.0 + lv * 1.5)
	var drain := 0.4 / (1.0 + lv)
	if kit_just("gun") and gun_bat <= 0.02:
		msg("배터리 없음", 0.6)
		beep(200.0, 0.1, 0.0, 0.2)
	var using := kit_held("gun") and gun_bat > 0.0 and mode == "shift"
	if using:
		gun_bat = maxf(0.0, gun_bat - drain * dt)
		var tgt: Car = null
		for c in cars:
			if c.on and not c.stopped and not c.passed and c.z < cam_base.z - 4.0 and c.z > cam_base.z - 140.0:
				if tgt == null or c.z > tgt.z:
					tgt = c
		if tgt != gun_tgt:
			gun_tgt = tgt
			gun_lock = 0.0
			gun_read = false
		if gun_tgt != null:
			gun_lock += dt
			marker.position = gun_tgt.n.position + Vector3(0, gun_tgt.top + 1.2, 0)
			marker.rotation.y += dt * 5.0
			var col := D
			if gun_lock >= lock_time:
				if not gun_read:
					gun_read = true
					beep(1400.0, 0.06, 0.0, 0.18)
				col = BAD if gun_tgt.spd > limit else GOOD
				msg("%d km/h" % int(gun_tgt.spd), 0.15)
			marker.material_override = mat(col)
		else:
			marker.position.y = -50.0
	else:
		gun_bat = minf(1.0, gun_bat + 0.12 * dt)
		gun_tgt = null
		marker.position.y = -50.0
	gauge(gun_bat, B if gun_bat > 0.25 else BAD)


# ---- 판정 ----
func _tap(p: Vector2) -> void:
	if mode == "pick":
		for i in 3:
			if Rect2(pick_rects[i].position, pick_rects[i].size).has_point(p):
				_take(pick_keys[i])
				return
		return
	if mode != "shift":
		return
	var pick: Car = null
	var bestd := 99999.0
	for c in cars:
		if not c.on or c.stopped or c.passed:
			continue
		var wp := c.n.position + Vector3(0, c.top * 0.5, 0)
		if cam.is_position_behind(wp):
			continue
		var d := cam.unproject_position(wp).distance_to(p)
		var r := clampf(5000.0 / maxf(1.0, cam.position.distance_to(wp)), 75.0, 230.0)
		if d < r and d < bestd:
			bestd = d
			pick = c
	if pick == null:
		beep(320.0, 0.05, 0.0, 0.12)
		return
	if pick.kind == "amb":
		_lose("구급차는 보내야지!")
		return
	pick.stopped = true
	beep(980.0, 0.14, 700.0, 0.3)
	if pick.spd > limit:
		var pts := int(10.0 + (pick.spd - limit) / 2.0) * (1 + loop_n)
		score += pts
		play("good")
		msg("과속 %d! +%d" % [int(pick.spd), pts], 0.9)
	else:
		_lose("정상 %d km/h" % int(pick.spd))


func _missed(c: Car) -> void:
	if partner_left > 0:
		partner_left -= 1
		score += 5
		play("good")
		msg("파트너가 잡았다!", 1.0)
		return
	_lose("과속 %d 놓침!" % int(c.spd))


func _lose(why: String) -> void:
	lives -= 1
	shake = 0.6
	play("bad")
	msg(why, 1.1)
	if lives <= 0:
		end()


# ---- 장비 ----
func _open_pick() -> void:
	mode = "pick"
	var keys: Array = UPS.keys()
	keys.shuffle()
	pick_keys.clear()
	for i in 3:
		var k: String = keys[i]
		pick_keys.append(k)
		pick_titles[i].text = UPS[k][0]
		pick_descs[i].text = UPS[k][1]
	pick_root.visible = true
	beep(520.0, 0.1, 780.0, 0.25)


func _take(k: String) -> void:
	if k == "life":
		lives += 1
	else:
		ups[k] += 1
	pick_root.visible = false
	play("win")
	_start_shift(shift + 1)
