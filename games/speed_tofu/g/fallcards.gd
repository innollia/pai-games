extends Tofu
## 낙하 카드 (등뒤 3인칭, 아래로): 멈출 수 없이 갱도를 떨어지며 아래서 올라오는 방해물에 맞는 카드를 탭해 낸다(대상은 가장 가까운 것 자동, 마나 소모·초당 1 회복).
## 카드를 위로 끌면 버리고 1장 뽑는다. 팔 벌리기를 누르는 동안 느려져 마나·읽을 시간을 벌지만 위에서 낙석이 따라온다.
## 철망은 22 이상이면 몸으로 뚫린다. 맞으면 체력 -1(26 이상이면 -2), 속도가 꺾이고 "먼지" 카드가 덱에 섞여 셔플 뒤 손패로 돌아온다.
## 한 문장: 나는 [카드 한 벌만 든 도굴꾼]으로서 [멈출 수 없는 낙하와 따라오는 낙석] 속에서 [방해물에 맞는 카드를 낸다]하여 [바닥에 산 채로 닿는다]하지만 [빠를수록 카드를 못 읽고 낸 카드가 덱에 쌓여 돌아오는 대가]를 감수한다.

const HW := 4.0  # 갱도 반폭
const G := 12.0  # 중력
const V_FREE := 30.0  # 자유 낙하 상한
const V_ARMS := 10.0  # 팔 벌린 상한
const V_BODY := 22.0  # 이 속도 이상이면 철망을 몸으로 뚫는다
const V_HARD := 26.0  # 이 속도 이상으로 맞으면 피해 2
const CHASE := 16.0  # 낙석 속도
const GAP := 25.0  # 구역 시작 때 낙석과의 간격
const NOB := 12  # 방해물 슬롯
const NPART := 6  # 슬롯당 상자
const NRING := 14  # 벽 눈금 (8 단위마다)
const NDEB := 8
const HAND := 5
const CARD_Y := 1040.0
const ZONE_END: Array[float] = [-220.0, -480.0, -640.0]


class _Cards extends Control:
	var g

	func _draw() -> void:
		g._cards_draw(self)


var CARD := {}
var pad: Control
var deck: Array[String] = []
var hand: Array[String] = []
var disc: Array[String] = []
var mana := 5.0
var hp := 3
var shuffle_t := 0.0
var sel := -1
var sel_p := Vector2.ZERO
var ppos := Vector3.ZERO
var spd := 0.0
var ch_y := 0.0
var zone := 0
var plan: Array[Dictionary] = []
var next_i := 0
var ob: Array[Dictionary] = []  # {root, parts, kind, y, need, alive}
var walls: Array[MeshInstance3D] = []
var rings: Array[MeshInstance3D] = []
var deb: Array[MeshInstance3D] = []
var debv: Array[Vector3] = []
var deb_t := 0.0
var body: MeshInstance3D
var arm_l: MeshInstance3D
var arm_r: MeshInstance3D
var chaser: MeshInstance3D
var shield_n: MeshInstance3D
var shield_t := 0.0
var shake := 0.0
var hum_t := 0.0
var last_ring := 0
var bonus := 0
var done := false


func _setup() -> void:
	howto = "멈출 수 없이 갱도를 떨어진다. 아래서 올라오는 방해물에 맞는 카드를 탭해 낸다(철망=자르기, 불=얼리기, 벽=폭파, 새떼=방패). 마나는 초당 1 회복.\n카드를 위로 끌면 버리고 새로 뽑는다. 팔 벌리기를 누르면 느려져 시간을 벌지만 위에서 낙석이 따라온다.\n빠르면 철망은 몸으로 뚫린다. 맞으면 체력이 줄고 먼지 카드가 덱에 섞인다. 체력 0이나 낙석에 깔리면 끝."
	time_limit = 0.0
	CARD = {
		"cut": {"name": "자르기", "cost": 1, "col": B},
		"ice": {"name": "얼리기", "cost": 1, "col": WHITE},
		"shield": {"name": "방패", "cost": 2, "col": GOOD},
		"bomb": {"name": "폭파", "cost": 3, "col": A},
		"dust": {"name": "먼지", "cost": 0, "col": SOFT},
	}
	kit_button("arms", "팔 벌리기", Vector2(620, 880), 70.0, GOOD)
	var layer := CanvasLayer.new()
	layer.layer = 1
	add_child(layer)
	var c := _Cards.new()
	c.g = self
	c.size = Vector2(720, 1280)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(c)
	pad = c


func _reset() -> void:
	# 갱도: 벽 4 + 눈금 (플레이어를 따라다니며 자리만 바꾼다)
	walls.clear()
	walls.append(box(Vector3(-HW - 0.3, 0, 0), Vector3(0.6, 170, HW * 2.0 + 1.2), SOFT))
	walls.append(box(Vector3(HW + 0.3, 0, 0), Vector3(0.6, 170, HW * 2.0 + 1.2), SOFT))
	walls.append(box(Vector3(0, 0, -HW - 0.3), Vector3(HW * 2.0 + 1.2, 170, 0.6), SOFT))
	walls.append(box(Vector3(0, 0, HW + 0.3), Vector3(HW * 2.0 + 1.2, 170, 0.6), SOFT))
	rings.clear()
	for i in NRING:
		rings.append(box(Vector3.ZERO, Vector3(0.2, 0.3, HW * 2.0), INK))
		rings.append(box(Vector3.ZERO, Vector3(0.2, 0.3, HW * 2.0), INK))
		rings.append(box(Vector3.ZERO, Vector3(HW * 2.0, 0.3, 0.2), INK))
	ob.clear()
	for i in NOB:
		var root := Node3D.new()
		root.visible = false
		world.add_child(root)
		var parts: Array[MeshInstance3D] = []
		for j in NPART:
			parts.append(box(Vector3.ZERO, Vector3.ONE, INK, root))
		ob.append({"root": root, "parts": parts, "kind": "", "y": 1.0, "need": [], "alive": false})
	deb.clear()
	debv.clear()
	for j in NDEB:
		var d := box(Vector3.ZERO, Vector3(0.4, 0.4, 0.4), D)
		d.visible = false
		deb.append(d)
		debv.append(Vector3.ZERO)
	body = box(Vector3.ZERO, Vector3(0.8, 1.6, 0.5), ME)
	arm_l = box(Vector3.ZERO, Vector3(0.6, 0.25, 0.25), ME)
	arm_r = box(Vector3.ZERO, Vector3(0.6, 0.25, 0.25), ME)
	chaser = box(Vector3.ZERO, Vector3(HW * 2.0 - 0.2, 3.0, HW * 2.0 - 0.2), BAD)
	shield_n = box(Vector3.ZERO, Vector3(2.4, 0.3, 2.4), GOOD)
	shield_n.visible = false
	# 상태
	ppos = Vector3.ZERO
	spd = 0.0
	ch_y = GAP
	zone = 0
	hp = 3
	mana = 5.0
	shuffle_t = 0.0
	shield_t = 0.0
	shake = 0.0
	deb_t = 0.0
	bonus = 0
	done = false
	sel = -1
	last_ring = 0
	hand.clear()
	disc.clear()
	deck.clear()
	for k in ["cut", "cut", "cut", "cut", "cut", "cut", "cut", "ice", "ice", "ice", "ice", "ice", "ice", "ice", "shield", "shield", "shield", "bomb", "bomb", "bomb"]:
		deck.append(k)
	deck.shuffle()
	_fill()
	_make_plan()
	next_i = 0
	cam.fov = 58.0
	_place()


## 구역 3개의 방해물 자리와 종류 (위에서 아래로)
func _make_plan() -> void:
	plan.clear()
	var y := -40.0
	while y > ZONE_END[0] + 10.0:  # 구역 1: 철망·불
		var k := "mesh" if int(-y / 24.0) % 2 == 0 else "fire"
		if randf() < 0.25:
			k = "fire" if k == "mesh" else "mesh"
		plan.append({"y": y, "kind": k})
		y -= 24.0
	y = ZONE_END[0] - 30.0
	var pool := ["mesh", "fire", "wall", "birds"]
	while y > ZONE_END[1] + 10.0:  # 구역 2: 벽·새떼, 둘씩 붙어 온다
		var a: String = pool[randi() % pool.size()]
		var b: String = pool[randi() % 3] if a == "wall" else pool[randi() % pool.size()]
		plan.append({"y": y, "kind": a})
		plan.append({"y": y - 7.0, "kind": b})
		y -= 34.0
	y = ZONE_END[1] - 30.0
	var n := 0
	while y > ZONE_END[2] + 6.0:  # 구역 3 맛보기: 불붙은 철망 (얼리기 -> 자르기)
		plan.append({"y": y, "kind": "firemesh" if n % 2 == 0 else pool[randi() % pool.size()]})
		y -= 28.0
		n += 1


func _spawn(k: String, y: float) -> bool:
	for o in ob:
		if o.alive:
			continue
		var root: Node3D = o.root
		var parts: Array[MeshInstance3D] = o.parts
		for p in parts:
			p.visible = false
		match k:
			"mesh":
				for i in 3:
					_part(parts[i], Vector3(0, 0, -2.6 + 2.6 * i), Vector3(7.8, 0.22, 0.22), INK)
				_part(parts[3], Vector3(-2, 0, 0), Vector3(0.22, 0.22, 7.8), INK)
				_part(parts[4], Vector3(2, 0, 0), Vector3(0.22, 0.22, 7.8), INK)
				o.need = ["cut"]
			"fire":
				for i in 4:
					_part(parts[i], Vector3(-2.7 + 1.8 * i, 0, 0), Vector3(1.6, 1.4, 7.8), A if i % 2 == 0 else D)
				o.need = ["ice"]
			"wall":
				_part(parts[0], Vector3.ZERO, Vector3(7.8, 1.4, 7.8), C)
				o.need = ["bomb"]
			"birds":
				for i in NPART:
					_part(parts[i], Vector3(randf_range(-3.2, 3.2), randf_range(-0.6, 0.6), randf_range(-3.2, 3.2)), Vector3(0.7, 0.5, 0.7), C)
				o.need = ["shield"]
			"firemesh":
				_part(parts[0], Vector3(0, 0, -1.6), Vector3(7.8, 0.22, 0.22), INK)
				_part(parts[1], Vector3(0, 0, 1.6), Vector3(7.8, 0.22, 0.22), INK)
				_part(parts[2], Vector3(-1.8, 0, 0), Vector3(0.22, 0.22, 7.8), INK)
				_part(parts[3], Vector3(1.8, 0, 0), Vector3(0.22, 0.22, 7.8), INK)
				_part(parts[4], Vector3(0, 0.3, -3.0), Vector3(7.8, 1.2, 1.4), A)
				_part(parts[5], Vector3(0, 0.3, 3.0), Vector3(7.8, 1.2, 1.4), A)
				o.need = ["ice", "cut"]
		o.kind = k
		o.y = y
		o.alive = true
		root.position = Vector3(0, y, 0)
		root.visible = true
		return true
	return false


func _part(m: MeshInstance3D, pos: Vector3, size: Vector3, col: Color) -> void:
	m.position = pos
	m.scale = size
	m.material_override = mat(col)
	m.visible = true


## 손패를 5장까지 채운다. 덱이 비면 버린 더미를 섞는다 (1.2초 동안은 못 뽑는다)
func _fill() -> void:
	while hand.size() < HAND and shuffle_t <= 0.0:
		if deck.is_empty():
			if disc.is_empty():
				return
			deck.assign(disc)
			disc.clear()
			deck.shuffle()
			shuffle_t = 1.2
			msg("셔플", 0.8)
			beep(330.0, 0.12, 440.0, 0.2)
			return
		hand.append(deck.pop_back())


## 가장 가까운 아래 방해물 (없으면 빈 사전)
func _target() -> Dictionary:
	var tg := {}
	var bd := 1e9
	for o in ob:
		if o.alive and o.y < ppos.y:
			var d: float = ppos.y - o.y
			if d < bd:
				bd = d
				tg = o
	return tg


func _step(dt: float) -> void:
	if done:
		return
	# 낙하: 중력이 올리고 팔 벌리기가 느리게 내린다 (관성)
	var arms := kit_held("arms")
	if arms:
		spd = move_toward(spd, V_ARMS, 14.0 * dt)
	else:
		spd = minf(spd + G * dt, V_FREE)
	var prev := ppos.y
	ppos.y -= spd * dt
	if zone < ZONE_END.size() and ppos.y < ZONE_END[zone]:
		_next_zone()
		if done:
			return
	mana = minf(mana + dt, 5.0)
	shield_t = maxf(shield_t - dt, 0.0)
	# 낙석
	ch_y -= CHASE * dt
	var gap := ch_y - ppos.y
	gauge(gap / GAP, BAD if gap < 8.0 else B)
	if gap < 1.5:
		msg("깔렸다", 1.5)
		done = true
		end()
		return
	# 앞 80 안의 방해물을 꺼낸다
	while next_i < plan.size() and plan[next_i].y > ppos.y - 80.0:
		if not _spawn(plan[next_i].kind, plan[next_i].y):
			break
		next_i += 1
	# 이번 프레임에 지나친 방해물
	for o in ob:
		if o.alive and o.y <= prev and o.y >= ppos.y:
			_cross(o)
			if done:
				return
	if shuffle_t > 0.0:
		shuffle_t -= dt
	_fill()
	# 파편
	if deb_t > 0.0:
		deb_t -= dt
		for j in NDEB:
			debv[j].y -= 9.0 * dt
			deb[j].position += debv[j] * dt
			deb[j].rotation.x += 6.0 * dt
			if deb_t <= 0.0:
				deb[j].visible = false
	# 소리: 바람 음높이 = 속도, 눈금 지날 때 톡
	hum_t -= dt
	if hum_t <= 0.0:
		hum_t = 0.25
		beep(50.0 + spd * 3.0, 0.1, 0.0, 0.05 + spd / V_FREE * 0.07)
	var r: int = int(floor(ppos.y / 8.0))
	if r != last_ring:
		last_ring = r
		beep(420.0 + spd * 6.0, 0.03, 0.0, 0.07)
	shake = maxf(shake - dt, 0.0)
	score = int(-ppos.y) + bonus
	_place()
	pad.queue_redraw()


func _next_zone() -> void:
	zone += 1
	if zone >= ZONE_END.size():
		msg("맛보기 끝", 2.0)
		bonus += 100
		done = true
		end()
		return
	ch_y = ppos.y + GAP
	hp = mini(3, hp + 1)
	if zone == 1:
		deck.append("bomb")
		deck.append("bomb")
		deck.shuffle()
		msg("구역 2  폭파 +2", 1.5)
	else:
		msg("구역 %d" % (zone + 1), 1.5)
	play("good")


## 방해물을 지나치는 순간: 빠르면 철망은 몸으로, 방패가 켜져 있으면 막고, 아니면 맞는다
func _cross(o: Dictionary) -> void:
	o.alive = false
	if o.kind == "mesh" and spd > V_BODY:
		spd *= 0.85
		bonus += 8
		shake = 0.25
		msg("콰직!", 0.5)
		beep(90.0, 0.15, 40.0, 0.35)
		_burst(o)
		return
	if shield_t > 0.0:
		shield_t = 0.0
		bonus += 5
		msg("막음", 0.5)
		beep(700.0, 0.1, 900.0, 0.25)
		_burst(o)
		return
	var dmg := 2 if spd > V_HARD else 1
	hp -= dmg
	spd *= 0.4
	disc.append("dust")
	shake = 0.5
	play("bad")
	msg("-%d 먼지" % dmg, 0.8)
	o.root.visible = false
	if hp <= 0:
		msg("죽었다", 1.5)
		done = true
		end()


func _burst(o: Dictionary) -> void:
	o.alive = false
	o.root.visible = false
	deb_t = 0.7
	for j in NDEB:
		deb[j].visible = true
		deb[j].position = Vector3(randf_range(-3, 3), o.y, randf_range(-3, 3))
		debv[j] = Vector3(randf_range(-4, 4), randf_range(-2, 4), randf_range(-4, 4))


## 카메라·몸·벽·눈금 자리
func _place() -> void:
	body.position = ppos
	var arms := kit_held("arms")
	var w := 1.6 if arms else 0.6
	arm_l.scale.x = move_toward(arm_l.scale.x, w, 0.1)
	arm_r.scale.x = arm_l.scale.x
	arm_l.position = ppos + Vector3(-0.4 - arm_l.scale.x * 0.5, 0.4, 0)
	arm_r.position = ppos + Vector3(0.4 + arm_l.scale.x * 0.5, 0.4, 0)
	body.scale.y = 1.6 if arms else 1.6 + spd * 0.02
	var sh := Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * shake * 0.4
	cam.position = Vector3(0, ppos.y + 7.0, 3.2) + sh
	cam.look_at(Vector3(0, ppos.y - 8.0, 0))
	cam.fov = 58.0 + spd / V_FREE * 24.0
	for wl in walls:
		wl.position.y = ppos.y
	var base: float = floor(ppos.y / 8.0) * 8.0
	for i in NRING:
		var y: float = base + 8.0 * (3 - i)
		rings[i * 3].position = Vector3(-HW + 0.1, y, 0)
		rings[i * 3 + 1].position = Vector3(HW - 0.1, y, 0)
		rings[i * 3 + 2].position = Vector3(0, y, -HW + 0.1)
	chaser.position.y = ch_y
	shield_n.visible = shield_t > 0.0
	shield_n.position = ppos + Vector3(0, -1.2, 0)
	shield_n.rotation.y += 0.05


func _tap(p: Vector2) -> void:
	if p.y < CARD_Y - 30.0 or p.x < 20.0 or p.x >= 700.0:
		return
	var i := int((p.x - 20.0) / 136.0)
	if i < hand.size():
		sel = i
		sel_p = p
		play("tap")


func _lift(p: Vector2) -> void:
	if sel < 0:
		return
	var i := sel
	sel = -1
	if i >= hand.size():
		return
	if p.y < sel_p.y - 110.0:
		disc.append(hand[i])
		hand.remove_at(i)
		msg("버림", 0.4)
		beep(420.0, 0.05, 0.0, 0.12)
	else:
		_play(i)


## 카드를 낸다: 마나를 쓰고 가장 가까운 방해물에 맞춰 본다. 틀리면 마나만 날린다
func _play(i: int) -> void:
	var k: String = hand[i]
	var cd: Dictionary = CARD[k]
	if k == "dust":
		hand.remove_at(i)
		disc.append(k)
		msg("먼지…", 0.5)
		beep(150.0, 0.1, 0.0, 0.15)
		return
	if mana < float(cd.cost):
		msg("마나 부족", 0.5)
		beep(200.0, 0.08, 0.0, 0.15)
		return
	mana -= float(cd.cost)
	hand.remove_at(i)
	disc.append(k)
	if k == "shield":
		shield_t = 2.5
		msg("방패", 0.4)
		beep(500.0, 0.12, 700.0, 0.25)
		return
	var o := _target()
	if o.is_empty():
		msg("허공", 0.5)
		beep(300.0, 0.1, 150.0, 0.2)
		return
	var need: Array = o.need
	if need[0] == k:
		need.pop_front()
		if need.is_empty():
			bonus += 5
			play("good")
			_burst(o)
		else:
			# 불붙은 철망: 불만 꺼지고 철망이 남는다
			var parts: Array[MeshInstance3D] = o.parts
			parts[4].visible = false
			parts[5].visible = false
			msg("꺼짐", 0.5)
			beep(600.0, 0.1, 300.0, 0.2)
	else:
		msg("엉뚱!", 0.6)
		beep(260.0, 0.15, 130.0, 0.25)


## 화면 아래 손패 5장 + 덱·버림·마나·체력
func _cards_draw(c: Control) -> void:
	c.draw_string(_font, Vector2(24, 1022), "덱 %d  버림 %d" % [deck.size(), disc.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 30, INK)
	for i in 5:
		var part := clampf(mana - float(i), 0.0, 1.0)
		var x := 268.0 + i * 38.0
		c.draw_rect(Rect2(x, 994, 30, 30), WHITE)
		c.draw_rect(Rect2(x, 994 + 30 - 30 * part, 30, 30 * part), B)
	c.draw_string(_font, Vector2(560, 1022), "체력 %d" % hp, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, BAD)
	for i in hand.size():
		var cd: Dictionary = CARD[hand[i]]
		var y := CARD_Y - (18.0 if i == sel else 0.0)
		var r := Rect2(20 + i * 136, y, 124, 210)
		var col: Color = cd.col
		if mana < float(cd.cost):
			col.a = 0.45
		c.draw_rect(r, col)
		c.draw_rect(r, INK, false, 4.0)
		c.draw_string(_font, Vector2(r.position.x + 10, y + 36), str(cd.cost), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, INK)
		c.draw_string(_font, Vector2(r.position.x, y + 125), cd.name, HORIZONTAL_ALIGNMENT_CENTER, 124, 34, INK)
	if shuffle_t > 0.0:
		c.draw_string(_font, Vector2(0, 1150), "셔플 중", HORIZONTAL_ALIGNMENT_CENTER, 720, 40, ME)
