extends Tofu
## 주방 막내 1인칭(패스 앞). 미끄러져 오는 접시를 노란 칸에서 탭해 받아 쌓고, 아래 접시탑을 쓸어 개수대로. 불붙은 팬은 위로 밀어 돌려보낸다.
## 깨지고 쏟고 데이면 주방장 인내심이 줄고 바닥나면 해고. 근무(점심 러시 → 저녁 러시 → 단체 예약 → 회식 → 마감)마다 점점 빨라지고 새 것이 오며, 사이에 강화 하나.

const LANES: Array[float] = [-1.0, 0.0, 1.0]
const TOP := 1.0  # 카운터 윗면
const FAR := -6.0  # 요리사 쪽 끝
const EDGE := 1.8  # 내 쪽 끝 (넘으면 떨어진다)
const ZONE := 0.3  # 여기부터 받을 수 있다 (노란 칸)
const NPOOL := 22
const NSTACK := 12
const SHIFT_LEN := 32.0
const NAMES := ["점심 러시", "저녁 러시", "단체 예약", "회식", "마감"]
const TIPS := ["접시를 받아라", "국그릇은 살살", "불판은 위로!", "옆에서도 온다", "끝까지 버텨"]
const PLATE := 0
const BOWL := 1
const PAN := 2
const BENCH_Y := 790.0  # 이보다 아래를 쓸면 개수대로


class Dish:
	var n: Node3D
	var groups: Array[Node3D] = []
	var mains: Array[MeshInstance3D] = []
	var flame: MeshInstance3D
	var on := false
	var k := 0
	var v := Vector3.ZERO
	var fall := -1.0
	var away := false


var dishes: Array[Dish] = []
var pile: Array[int] = []  # 내 접시탑 (종류)
var pile_m: Array[MeshInstance3D] = []
var pile_root: Node3D
var stripes: Array[MeshInstance3D] = []
var cooks: Array[MeshInstance3D] = []
var cook_bob: Array[float] = [0.0, 0.0, 0.0, 0.0]
var chef_head: MeshInstance3D
var chef_body: MeshInstance3D
var side_cook: MeshInstance3D
var helper: MeshInstance3D
var water: MeshInstance3D
var fires: Array[MeshInstance3D] = []
var picks: Array[MeshInstance3D] = []

var clock := 0.0
var shift_i := 0
var shift_tt := 0.0
var phase := "work"  # work / lull / pick
var lull_t := 0.0
var spawn_t := 0.0
var side_t := 0.0
var beat_t := 0.0
var beat_hi := false
var growl_t := 0.0
var rushed := false
var pat := 1.0  # 주방장 인내심
var cap := 5
var slow := 1.0
var helper_lv := 0
var helper_cd := 0.0
var helper_bob := 0.0
var wash_flash := 0.0
var g0 := Vector2.ZERO
var g0_ms := 0
var gmode := ""
var pan_d: Dish


func _setup() -> void:
	howto = "탭: 노란 칸에 온 접시를 받아 쌓는다.\n아래 접시탑을 쓸면 개수대로. 많이 쌓을수록 큰 점수, 넘치면 와르르.\n불붙은 팬은 위로 밀어 돌려보낸다.\n깨지고 쏟고 데이면 주방장 인내심이 줄고, 바닥나면 해고."
	time_limit = 0.0


func _reset() -> void:
	cam.position = Vector3(0, 2.6, 3.0)
	cam.rotation_degrees = Vector3(-45, 0, 0)
	# 주방
	box(Vector3(0, -0.05, -2), Vector3(8, 0.1, 14), WHITE)
	box(Vector3(0, 2.5, -8.2), Vector3(8, 5, 0.3), B)
	box(Vector3(0, 1.4, -8.0), Vector3(8, 0.3, 0.1), WHITE)
	for s in [-1.0, 1.0]:
		box(Vector3(s * 2.7, 2.0, -2.5), Vector3(0.2, 4, 12), WHITE)
		box(Vector3(s * 2.6, 1.2, -2.5), Vector3(0.05, 0.2, 12), B)
	box(Vector3(0, 3.4, -7.4), Vector3(5, 0.6, 1.4), D)  # 후드
	for i in 4:
		box(Vector3(-1.5 + i, 3.0, -1.0 - i * 1.5), Vector3(0.3, 0.12, 0.3), D)  # 등
	# 화구와 불
	fires.clear()
	for x in [-1.6, -0.5, 0.5, 1.6]:
		box(Vector3(x, 1.1, -7.6), Vector3(0.7, 0.2, 0.6), WHITE)
		fires.append(box(Vector3(x, 1.3, -7.6), Vector3(0.4, 0.2, 0.3), A))
	# 패스 카운터
	box(Vector3(0, TOP - 0.1, (FAR + EDGE) * 0.5), Vector3(3.2, 0.2, EDGE - FAR), SOFT)
	box(Vector3(0, TOP + 0.004, (ZONE + EDGE) * 0.5), Vector3(3.2, 0.01, EDGE - ZONE), D)
	box(Vector3(0, TOP + 0.01, ZONE), Vector3(3.2, 0.02, 0.06), A)
	for s in [-1.0, 1.0]:
		box(Vector3(s * 1.65, TOP + 0.06, (FAR + EDGE) * 0.5), Vector3(0.1, 0.12, EDGE - FAR), B)
	stripes.clear()
	for i in 10:
		stripes.append(box(Vector3(0, TOP + 0.008, FAR + i * 0.78), Vector3(3.1, 0.01, 0.05), WHITE))
	# 줄 요리사 셋 + 주방장
	cooks.clear()
	for i in 3:
		var c := box(Vector3(LANES[i] * 1.1, 1.35, -6.7), Vector3(0.6, 0.9, 0.4), WHITE)
		box(Vector3(0, 0.75, 0), Vector3(0.7, 0.5, 0.9), SOFT, c)
		box(Vector3(0, 1.25, 0), Vector3(0.75, 0.5, 0.9), WHITE, c)
		cooks.append(c)
	chef_body = box(Vector3(0, 1.9, -7.6), Vector3(1.1, 1.3, 0.5), WHITE)
	chef_head = box(Vector3(0, 2.85, -7.6), Vector3(0.7, 0.6, 0.6), SOFT)
	box(Vector3(0, 3.45, -7.6), Vector3(0.75, 0.8, 0.65), WHITE)
	side_cook = box(Vector3(-2.0, 1.4, 1.0), Vector3(0.5, 0.9, 0.5), WHITE)
	box(Vector3(0, 0.75, 0), Vector3(0.9, 0.55, 0.9), SOFT, side_cook)
	side_cook.visible = false
	cooks.append(side_cook)
	# 내 자리: 선반, 개수대, 접시탑, 조수
	box(Vector3(0, 0.7, 2.6), Vector3(3.6, 0.2, 1.6), SOFT)
	box(Vector3(-1.0, 0.82, 2.5), Vector3(1.1, 0.1, 0.9), WHITE)
	water = box(Vector3(-1.0, 0.86, 2.5), Vector3(0.9, 0.06, 0.7), B)
	box(Vector3(0.45, 0.81, 2.45), Vector3(0.75, 0.02, 0.75), A)
	pile_root = Node3D.new()
	pile_root.position = Vector3(0.45, 0.82, 2.45)
	world.add_child(pile_root)
	pile_m.clear()
	for i in NSTACK:
		var m := box(Vector3.ZERO, Vector3(0.55, 0.06, 0.55), WHITE, pile_root)
		m.visible = false
		pile_m.append(m)
	helper = box(Vector3(1.55, 1.1, 2.1), Vector3(0.4, 0.7, 0.4), ME)
	box(Vector3(0, 0.7, 0), Vector3(0.8, 0.6, 0.8), SOFT, helper)
	helper.visible = false
	# 강화 고르기 상자 (왼쪽 쟁반, 가운데 느림, 오른쪽 조수)
	picks.clear()
	picks.append(box(Vector3(-1.4, TOP + 0.35, -0.5), Vector3(0.5, 0.7, 0.5), WHITE))
	picks.append(box(Vector3(0, TOP + 0.1, -0.5), Vector3(0.8, 0.15, 0.8), B))
	picks.append(box(Vector3(1.4, TOP + 0.4, -0.5), Vector3(0.4, 0.8, 0.4), ME))
	for p in picks:
		p.visible = false
	# 접시 풀
	dishes.clear()
	for i in NPOOL:
		dishes.append(_make_dish())
	pile.clear()
	clock = 0.0
	shift_i = -1
	pat = 1.0
	cap = 5
	slow = 1.0
	helper_lv = 0
	helper_cd = 0.0
	wash_flash = 0.0
	gmode = ""
	pan_d = null
	_next_shift()


func _make_dish() -> Dish:
	var d := Dish.new()
	d.n = Node3D.new()
	world.add_child(d.n)
	for j in 3:
		var g := Node3D.new()
		d.n.add_child(g)
		d.groups.append(g)
	# 접시: 흰 판에 남은 음식
	d.mains.append(box(Vector3(0, 0.04, 0), Vector3(0.6, 0.06, 0.6), WHITE, d.groups[0]))
	box(Vector3(0.08, 0.085, 0.05), Vector3(0.22, 0.03, 0.16), A, d.groups[0])
	# 국그릇: 파란 그릇에 국
	d.mains.append(box(Vector3(0, 0.1, 0), Vector3(0.45, 0.2, 0.45), B, d.groups[1]))
	box(Vector3(0, 0.205, 0), Vector3(0.35, 0.02, 0.35), D, d.groups[1])
	# 불붙은 팬
	d.mains.append(box(Vector3(0, 0.06, 0), Vector3(0.6, 0.1, 0.6), INK, d.groups[2]))
	box(Vector3(0, 0.06, 0.45), Vector3(0.12, 0.06, 0.4), INK, d.groups[2])
	d.flame = box(Vector3(0, 0.3, 0), Vector3(0.45, 0.4, 0.45), BAD, d.groups[2])
	box(Vector3(0, -0.05, 0), Vector3(0.7, 0.5, 0.7), A, d.flame)
	d.n.visible = false
	return d


func _next_shift() -> void:
	shift_i += 1
	shift_tt = 0.0
	spawn_t = 0.8
	side_t = 2.0
	rushed = false
	phase = "work"
	for p in picks:
		p.visible = false
	side_cook.visible = shift_i >= 3
	var nm: String = NAMES[mini(shift_i, 4)]
	if shift_i > 4:
		nm += " %d" % (shift_i - 3)
	msg("%s\n%s" % [nm, TIPS[mini(shift_i, 4)]], 1.6)
	beep(1568.0, 0.25, 0.0, 0.22)
	beep(2093.0, 0.3, 0.0, 0.15)


## 판의 빠르기: 근무가 지날수록, 근무 안에서도 점점, 러시 때 확
func _tempo() -> float:
	var prog := clampf(shift_tt / SHIFT_LEN, 0.0, 1.0)
	var r := 1.0 + 0.16 * shift_i + 0.6 * prog
	if prog > 0.72:
		r *= 1.3
	return r


func _speed() -> float:
	return 2.1 * _tempo() * slow


func _spawn(lane: int, k: int, side: bool) -> void:
	for d in dishes:
		if d.on:
			continue
		d.on = true
		d.k = k
		d.fall = -1.0
		d.away = false
		d.n.visible = true
		d.n.rotation = Vector3.ZERO
		for j in 3:
			d.groups[j].visible = j == k
		d.mains[0].material_override = mat(WHITE)
		d.mains[1].material_override = mat(B)
		d.mains[2].material_override = mat(INK)
		var spd := _speed()
		if side:
			d.n.position = Vector3(-1.7, TOP + 0.7, randf_range(0.7, 1.3))
			d.v = Vector3(spd * 0.75, 0, 0)
			cook_bob[3] = 0.2
			beep(400.0, 0.06, 700.0, 0.12)
		else:
			d.n.position = Vector3(LANES[lane], TOP, FAR + 0.3)
			d.v = Vector3(0, 0, spd * (1.25 if k == PAN else (0.85 if k == BOWL else 1.0)))
			cook_bob[lane] = 0.2
			beep(170.0 + lane * 45.0, 0.06, 110.0, 0.12)
			if k == PAN:
				beep(90.0, 0.2, 60.0, 0.12)
		return


func _alive() -> int:
	var c := 0
	for d in dishes:
		if d.on and d.fall < 0.0 and not d.away:
			c += 1
	return c


func _step(dt: float) -> void:
	clock += dt
	var spd := _speed() * (1.0 if phase == "work" else 0.25)
	for s in stripes:
		s.position.z += spd * dt
		if s.position.z > EDGE:
			s.position.z -= EDGE - FAR
	if phase == "work":
		shift_tt += dt
		var r := _tempo()
		var iv := maxf(0.24, 1.35 / pow(r, 1.25))
		spawn_t -= dt
		if spawn_t <= 0.0:
			spawn_t = iv * randf_range(0.7, 1.3)
			var k := PLATE
			var roll := randf()
			if shift_i >= 2 and roll < 0.18:
				k = PAN
			elif shift_i >= 1 and roll < 0.48:
				k = BOWL
			_spawn(randi() % 3, k, false)
		if shift_i >= 3:
			side_t -= dt
			if side_t <= 0.0:
				side_t = iv * randf_range(2.0, 3.2)
				_spawn(0, BOWL if randf() < 0.3 else PLATE, true)
		beat_t -= dt
		if beat_t <= 0.0:
			beat_t = clampf(iv * 0.5, 0.11, 0.5)
			beat_hi = not beat_hi
			beep(1150.0 if beat_hi else 860.0, 0.02, 0.0, 0.05)
		if not rushed and shift_tt > SHIFT_LEN * 0.72:
			rushed = true
			msg("러시!", 1.0)
			beep(880.0, 0.18, 1760.0, 0.25)
			beep(660.0, 0.3, 1320.0, 0.2)
		pat = minf(1.0, pat + 0.012 * dt)
		if shift_tt >= SHIFT_LEN:
			phase = "lull"
			lull_t = 0.0
			msg("한숨 돌림", 1.6)
			beep(784.0, 0.3, 0.0, 0.18)
			beep(523.0, 0.5, 0.0, 0.12)
	elif phase == "lull":
		lull_t += dt
		if lull_t > 2.5 and _alive() == 0:
			phase = "pick"
			pat = minf(1.0, pat + 0.25)
			for p in picks:
				p.visible = true
			play("good")
	else:
		msg("쟁반   느림   조수", 0.2)
		for i in 3:
			picks[i].position.y = TOP + picks[i].scale.y * 0.5 + absf(sin(clock * 4.0 + i)) * 0.15
	_move_dishes(dt)
	_animate(dt)
	gauge(pat, GOOD if pat > 0.5 else (D if pat > 0.25 else BAD))
	if pat < 0.25:
		growl_t -= dt
		if growl_t <= 0.0:
			growl_t = 1.1
			beep(110.0, 0.14, 80.0, 0.18)
	if pat <= 0.0:
		pat = 0.0
		msg("해고!", 2.0)
		chef_head.material_override = mat(BAD)
		end()


func _move_dishes(dt: float) -> void:
	helper_cd -= dt
	for d in dishes:
		if not d.on:
			continue
		var n := d.n
		if d.fall >= 0.0:
			d.fall += dt
			n.position.y -= dt * 4.0
			n.rotation.x += dt * 9.0
			if d.fall > 0.4:
				_off(d)
			continue
		if d.away:
			n.position += d.v * dt
			n.position.y += dt * 2.5
			n.rotation.y += dt * 12.0
			if n.position.z < FAR - 1.0:
				_off(d)
			continue
		n.position += d.v * dt
		if n.position.y > TOP:
			n.position.y = maxf(TOP, n.position.y - dt * 1.4)
		if d.k == PAN:
			d.flame.scale = Vector3(0.45, 0.3 + 0.15 * absf(sin(clock * 25.0 + n.position.x)), 0.45)
		if n.position.z > EDGE or n.position.x > 1.8:
			if d.k == PAN:
				_burn()
				d.fall = 0.0
			elif helper_lv > 0 and helper_cd <= 0.0:
				helper_cd = 5.0 / helper_lv
				helper_bob = 0.3
				score += 1
				beep(1000.0, 0.06, 1500.0, 0.18)
				msg("조수!", 0.5)
				_off(d)
			else:
				_break(d)


func _off(d: Dish) -> void:
	d.on = false
	d.n.visible = false


func _break(d: Dish) -> void:
	d.fall = 0.0
	d.mains[d.k].material_override = mat(BAD)
	pat -= 0.12
	beep(1900.0, 0.07, 500.0, 0.2)
	play("bad")
	msg("쨍그랑", 0.6)


func _burn() -> void:
	pat -= 0.2
	beep(140.0, 0.3, 50.0, 0.28)
	beep(2400.0, 0.2, 1800.0, 0.06)
	msg("앗 뜨거", 0.8)


func _animate(dt: float) -> void:
	# 요리사가 던질 때 들썩
	for i in cooks.size():
		cook_bob[i] = maxf(0.0, cook_bob[i] - dt)
		var base := 1.4 if i == 3 else 1.35
		cooks[i].position.y = base + cook_bob[i] * 1.2
	# 주방장: 인내심이 줄수록 빨개지고 떤다
	var anger := int((1.0 - pat) * 5.0)
	chef_head.material_override = mat(SOFT.lerp(BAD, anger / 5.0))
	var shake := (1.0 - pat) * 0.08
	chef_body.position.x = sin(clock * 40.0) * shake
	chef_head.position.x = chef_body.position.x
	for i in fires.size():
		fires[i].scale.y = 0.15 + 0.12 * absf(sin(clock * (11.0 + i * 3.0)))
	helper.visible = helper_lv > 0
	helper_bob = maxf(0.0, helper_bob - dt)
	helper.position.y = 1.1 + helper_bob
	wash_flash = maxf(0.0, wash_flash - dt)
	water.material_override = mat(WHITE if wash_flash > 0.0 else B)
	# 접시탑: 높을수록 흔들린다
	var h := 0.0
	for i in NSTACK:
		var m := pile_m[i]
		m.visible = i < pile.size()
		if not m.visible:
			continue
		var bowl := pile[i] == BOWL
		var th := 0.18 if bowl else 0.07
		m.scale = Vector3(0.42, 0.16, 0.42) if bowl else Vector3(0.55, 0.06, 0.55)
		m.position = Vector3(0, h + th * 0.5, 0)
		var full := pile.size() >= cap and i == pile.size() - 1 and int(clock * 6.0) % 2 == 0
		m.material_override = mat(BAD if full else (B if bowl else WHITE))
		h += th
	var f := float(pile.size()) / float(cap)
	pile_root.rotation.z = sin(clock * 7.0) * 0.16 * f * f


func _catch(d: Dish) -> void:
	_off(d)
	if pile.size() >= cap:
		var lost := pile.size() + 1
		pile.clear()
		pat -= 0.06 + 0.06 * lost
		msg("와르르", 0.9)
		play("bad")
		for i in 3:
			beep(2200.0 - i * 500.0, 0.08, 400.0, 0.18)
		return
	pile.append(d.k)
	beep(1250.0 + pile.size() * 110.0, 0.05, 0.0, 0.2)
	if pile.size() >= cap:
		msg("가득!", 0.5)


func _wash(spd: float) -> void:
	if pile.is_empty():
		return
	var plates := 0
	var bowls := 0
	for k in pile:
		if k == BOWL:
			bowls += 1
		else:
			plates += 1
	var n := pile.size()
	var pts := n * (n + 1) / 2
	if bowls > 0 and spd > 2000.0:
		pat -= 0.12
		pts = plates * (plates + 1) / 2
		msg("쏟았다", 0.8)
		beep(300.0, 0.25, 120.0, 0.2)
	else:
		msg("+%d" % pts, 0.6)
	score += pts
	pile.clear()
	wash_flash = 0.3
	beep(700.0, 0.12, 300.0, 0.2)
	beep(500.0, 0.18, 200.0, 0.15)
	if n >= 5:
		play("good")


func _tap(p: Vector2) -> void:
	g0 = p
	g0_ms = Time.get_ticks_msec()
	gmode = ""
	if phase == "pick":
		if p.y < 250.0 or p.y > 1100.0:
			return
		var c := 0 if p.x < 240.0 else (1 if p.x < 480.0 else 2)
		if c == 0:
			cap = mini(NSTACK, cap + 2)
		elif c == 1:
			slow *= 0.85
		else:
			helper_lv += 1
		play("win")
		_next_shift()
		return
	if p.y > BENCH_Y:
		gmode = "bench"
		return
	var near: Dish = null
	var nd := 140.0
	for d in dishes:
		if not d.on or d.fall >= 0.0 or d.away:
			continue
		var sp := cam.unproject_position(d.n.global_position)
		var dd := sp.distance_to(p)
		if dd < nd:
			nd = dd
			near = d
	if near == null:
		beep(300.0, 0.03, 0.0, 0.08)
		return
	if near.k == PAN:
		gmode = "pan"
		pan_d = near
		return
	if near.n.position.z >= ZONE:
		_catch(near)
	else:
		beep(260.0, 0.04, 0.0, 0.1)
		msg("아직", 0.3)


func _drag(p: Vector2) -> void:
	if gmode == "bench":
		var dist := p.distance_to(g0)
		if dist > 110.0:
			var sec := maxf(0.016, (Time.get_ticks_msec() - g0_ms) / 1000.0)
			_wash(dist / sec)
			gmode = "done"
	elif gmode == "pan":
		if g0.y - p.y > 80.0:
			if pan_d.on and pan_d.fall < 0.0 and not pan_d.away:
				pan_d.away = true
				pan_d.v = Vector3(0, 0, -_speed() * 3.0)
				score += 1
				beep(500.0, 0.12, 1400.0, 0.22)
				msg("돌려보냄", 0.5)
			gmode = "done"


func _lift(_p: Vector2) -> void:
	if gmode == "pan" and pan_d.on and pan_d.fall < 0.0 and not pan_d.away:
		# 불붙은 팬을 손으로 잡았다
		_burn()
		pan_d.fall = 0.0
	gmode = ""
