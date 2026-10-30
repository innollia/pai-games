extends Tofu
## 아이스크림: 손에 든 콘을 내려다보며 녹는 덩이를 탭(문지르면 연달아)해 한 입씩 먹는다. 녹아 떨어진 방울이 접시를 넘치면 끝, 너무 빨리 먹으면 머리가 띵(잠깐 못 먹음)·꽉 차면 기절, 탑이 기울어 넘어가도 끝. 다 먹으면 다음 날(더 덥고, 탑이 높아지고, 스프링클·벌).

const CS := 0.5  # 덩이 조각 한 칸
const TABLE_Y := -2.6
const PLATE := 1.7  # 접시 반폭: 웅덩이가 이걸 넘으면 끝
const ND := 14  # 방울 풀
const SIDES := [Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]
const UP := Vector3i(0, 1, 0)
const DOWN := Vector3i(0, -1, 0)

var tower: Node3D
var c_node: Array[MeshInstance3D] = []
var c_key: Array[Vector3i] = []
var c_melt: Array[float] = []
var c_col: Array[Color] = []
var c_lvl: Array[int] = []
var c_spr: Array = []  # 스프링클 묶음 또는 null
var grid := {}  # 칸 -> 조각 번호 (남은 것만)
var left := 0
var drips: Array[MeshInstance3D] = []
var dvel: Array[float] = []
var puddle: MeshInstance3D
var pool := 0.0  # 웅덩이 반폭
var frost: Array[MeshInstance3D] = []
var fw := 0.0  # 카메라 앞 0.5 거리의 화면 반폭
var chill := 0.0  # 머리 띵 0..1
var lock := 0.0
var armed := true
var last_bite := 10.0
var rub_cool := 0.0
var lean := 0.0
var warned := false
var day := 0
var heat := 0.08
var tiers := 1
var sprinkles := false
var wasps := false
var wasp: MeshInstance3D
var wasp_on := -1
var wasp_t := 0.0
var buzz := 0.0
var clock := 0.0


func _setup() -> void:
	howto = "덩이를 탭하거나 문질러 한 입씩 먹자.\n녹아 떨어진 방울이 접시를 넘치면 끝.\n빨리 먹을수록 머리가 띵! 꽉 차면 기절.\n탑이 기울면 무거운 쪽을 먹어 세우고, 벌은 건드리지 마."
	time_limit = 0.0
	# 화면 가장자리 성에 (카메라에 붙여 판이 바뀌어도 남는다)
	fw = 0.5 * tan(deg_to_rad(cam.fov * 0.5))
	for i in 4:
		var f := box(Vector3.ZERO, Vector3.ONE * 0.01, B.lightened(0.65), cam)
		f.visible = false
		frost.append(f)


func _reset() -> void:
	box(Vector3(0, TABLE_Y - 0.2, 0), Vector3(16, 0.4, 16), SOFT)
	box(Vector3(0, TABLE_Y + 0.03, 0), Vector3(PLATE * 2.0 + 0.2, 0.06, PLATE * 2.0 + 0.2), WHITE)
	puddle = box(Vector3(0, TABLE_Y + 0.08, 0), Vector3(0.1, 0.04, 0.1), C.lightened(0.5))
	puddle.visible = false
	pool = 0.0
	# 콘과 그걸 쥔 손
	for i in 4:
		var w := 1.3 - i * 0.28
		box(Vector3(0, -0.2 - i * 0.4, 0), Vector3(w, 0.4, w), A)
	var skin := SOFT.darkened(0.12)
	box(Vector3(0.0, -0.8, 0.5), Vector3(1.0, 0.32, 0.22), skin)
	box(Vector3(0.62, -0.85, 0.2), Vector3(0.35, 0.7, 0.6), skin)
	box(Vector3(0.75, -1.3, 1.3), Vector3(0.5, 0.5, 2.0), skin)
	drips.clear()
	dvel.clear()
	for i in ND:
		var d := box(Vector3.ZERO, Vector3(0.2, 0.26, 0.2), WHITE)
		d.visible = false
		drips.append(d)
		dvel.append(0.0)
	wasp = box(Vector3.ZERO, Vector3(0.34, 0.22, 0.44), D)
	box(Vector3(0, 0, 0.05), Vector3(1.05, 1.05, 0.25), INK, wasp)
	box(Vector3(0, 0.75, 0), Vector3(1.6, 0.15, 0.5), WHITE, wasp)
	wasp.visible = false
	wasp_on = -1
	wasp_t = 3.0
	tower = null
	chill = 0.0
	lock = 0.0
	armed = true
	last_bite = 10.0
	rub_cool = 0.0
	clock = 0.0
	day = 0
	_next_day()


func _next_day() -> void:
	day += 1
	tiers = 1 if day == 1 else (2 if day < 5 else 3)
	heat = [0.08, 0.085, 0.095, 0.105][mini(day, 4) - 1] + 0.01 * maxi(day - 4, 0)
	sprinkles = day >= 3
	wasps = day >= 4
	pool = maxf(pool - 0.4, 0.0)  # 냅킨으로 조금 닦는다
	_puddle_show()
	_wasp_leave()
	var says := ["더운 날", "두 덩이!", "스프링클", "벌 조심", "세 덩이!"]
	msg("%d일째 %s" % [day, says[mini(day, 5) - 1] if day <= 5 else "더 더움"], 1.2)
	# 탑 높이에 맞춰 내려다보는 자리
	var aim := Vector3(0, tiers * CS * 0.9, 0)
	cam.position = aim + Vector3(0, 0.78, 0.62).normalized() * (2.4 + 0.7 * (tiers - 1))
	cam.look_at(aim)
	_build()


func _build() -> void:
	if tower:
		tower.queue_free()
	tower = Node3D.new()
	world.add_child(tower)
	c_node.clear()
	c_key.clear()
	c_melt.clear()
	c_col.clear()
	c_lvl.clear()
	c_spr.clear()
	grid.clear()
	lean = randf_range(-0.05, 0.05) if tiers > 1 else 0.0
	warned = false
	var flav := [C.lightened(0.5), B.lightened(0.45), GOOD.lightened(0.5), D.lightened(0.45)]
	for tr in tiers:
		var col: Color = flav[(day + tr) % flav.size()]
		for row in 2:
			for ix in 3:
				for iz in 3:
					var k := Vector3i(ix - 1, tr * 2 + row, iz - 1)
					var n := box(_home(k), Vector3.ONE * CS * 0.96, col, tower)
					var s: Variant = null
					if sprinkles and tr == tiers - 1 and row == 1 and randf() < 0.45:
						var h := Node3D.new()
						n.add_child(h)
						box(Vector3(-0.25, 0.56, 0.1), Vector3(0.3, 0.12, 0.12), BAD, h)
						box(Vector3(0.2, 0.56, -0.2), Vector3(0.12, 0.12, 0.3), ME, h)
						box(Vector3(0.15, 0.56, 0.25), Vector3(0.3, 0.12, 0.12), D, h)
						s = h
					grid[k] = c_node.size()
					c_node.append(n)
					c_key.append(k)
					c_melt.append(0.0)
					c_col.append(col)
					c_lvl.append(0)
					c_spr.append(s)
	left = c_node.size()


func _home(k: Vector3i) -> Vector3:
	return Vector3(k.x * CS, (k.y + 0.5) * CS, k.z * CS)


func _alive(i: int) -> bool:
	return grid.get(c_key[i], -1) == i


## 비어 있는 이웃 면 수 (아래는 콘이 막는다)
func _exposed(k: Vector3i) -> int:
	var n := 0
	for d in SIDES:
		if not grid.has(k + d):
			n += 1
	if not grid.has(k + UP):
		n += 1
	if k.y > 0 and not grid.has(k + DOWN):
		n += 1
	return n


func _step(dt: float) -> void:
	clock += dt
	last_bite += dt
	rub_cool -= dt
	# 머리 띵: 천천히 풀린다. 띵 걸린 동안은 못 먹는다.
	if lock > 0.0:
		lock -= dt
		chill = maxf(chill - 0.08 * dt, 0.0)
	else:
		chill = maxf(chill - 0.3 * dt, 0.0)
	if chill < 0.45:
		armed = true
	gauge(chill, BAD if chill >= 0.7 else B)
	_frost_show(maxf(chill, 0.95) if lock > 0.0 else chill)
	# 녹기: 드러난 면이 많을수록 빨리
	var dripped := false
	for i in c_node.size():
		if not _alive(i):
			continue
		c_melt[i] += heat * (0.3 + 0.35 * _exposed(c_key[i])) * dt
		var m := minf(c_melt[i], 1.0)
		var lv := mini(int(m * 3.0), 2)
		if lv != c_lvl[i]:
			c_lvl[i] = lv
			c_node[i].material_override = mat(c_col[i].lightened(0.15 * lv))
		var sq := 1.0 - 0.35 * m
		var wide := 1.0 + 0.18 * m
		c_node[i].scale = Vector3(wide, sq, wide) * CS * 0.96
		c_node[i].position = _home(c_key[i]) - Vector3(0, CS * (1.0 - sq) * 0.5, 0)
		if c_melt[i] >= 1.0:
			_drip(i)
			dripped = true
	if dripped:
		_settle()
	if over:
		return
	# 방울이 떨어져 웅덩이가 된다
	for j in ND:
		var d := drips[j]
		if not d.visible:
			continue
		dvel[j] += 14.0 * dt
		d.position.y -= dvel[j] * dt
		if d.position.y <= TABLE_Y + 0.15:
			d.visible = false
			_splash(d.material_override as StandardMaterial3D)
			if over:
				return
	# 기울기: 무게중심이 바깥으로 나가면 점점 더 기운다
	if tiers > 1:
		var sx := 0.0
		var cl := cos(lean)
		var sl := sin(lean)
		for i in c_node.size():
			if _alive(i):
				var h := _home(c_key[i])
				sx += h.x * cl - h.y * sl
		lean += -0.008 * sx * dt
		tower.rotation.z = lean
		if absf(lean) > 0.25 and not warned:
			warned = true
			msg("기운다!", 0.8)
			beep(300.0, 0.25, 200.0, 0.25)
		elif absf(lean) < 0.15:
			warned = false
		if absf(lean) > 0.5:
			tower.rotation.z = signf(lean) * 1.3
			msg("와르르", 1.5)
			end()
			return
	_wasp_step(dt)
	if left == 0 and not over:
		score += 5 * day
		play("win")
		_next_day()


func _wasp_step(dt: float) -> void:
	if not wasps:
		return
	if wasp_on < 0:
		wasp_t -= dt
		if wasp_t > 0.0:
			return
		var tops: Array[int] = []
		for i in c_node.size():
			if _alive(i) and not grid.has(c_key[i] + UP):
				tops.append(i)
		if tops.is_empty():
			return
		wasp_on = tops[randi() % tops.size()]
		wasp_t = randf_range(3.0, 4.5)
		wasp.visible = true
		msg("벌!", 0.6)
		beep(160.0, 0.3, 200.0, 0.22)
		return
	wasp_t -= dt
	var g := c_node[wasp_on].global_position
	wasp.global_position = g + Vector3(sin(clock * 40.0) * 0.03, CS * 0.5 + 0.12, 0)
	buzz -= dt
	if buzz <= 0.0:
		buzz = 0.22
		beep(140.0 + randf() * 40.0, 0.14, 0.0, 0.08)
	if wasp_t <= 0.0:
		_wasp_leave()


func _wasp_leave() -> void:
	wasp_on = -1
	if wasp:
		wasp.visible = false
	wasp_t = randf_range(2.5, 5.0)


## 성에 막대 네 개가 화면 가장자리에서 안쪽으로 자란다
func _frost_show(f: float) -> void:
	var on := f > 0.15
	var hh := fw * 1280.0 / 720.0
	var wx := fw * 0.85 * f
	var wy := hh * 0.45 * f
	for i in 4:
		frost[i].visible = on
	if not on:
		return
	frost[0].position = Vector3(-fw + wx * 0.5, 0, -0.5)
	frost[0].scale = Vector3(wx, hh * 2.0, 0.01)
	frost[1].position = Vector3(fw - wx * 0.5, 0, -0.5)
	frost[1].scale = Vector3(wx, hh * 2.0, 0.01)
	frost[2].position = Vector3(0, hh - wy * 0.5, -0.5)
	frost[2].scale = Vector3(fw * 2.0, wy, 0.01)
	frost[3].position = Vector3(0, -hh + wy * 0.5, -0.5)
	frost[3].scale = Vector3(fw * 2.0, wy, 0.01)


func _remove(i: int) -> void:
	grid.erase(c_key[i])
	c_node[i].visible = false
	left -= 1
	if wasp_on == i:
		_wasp_leave()


## 녹거나 떨어진 조각이 방울이 되어 접시로 떨어진다
func _drip(i: int) -> void:
	var gp := c_node[i].global_position
	_remove(i)
	beep(900.0, 0.06, 400.0, 0.15)
	for j in ND:
		if not drips[j].visible:
			drips[j].visible = true
			drips[j].global_position = gp
			drips[j].material_override = mat(c_col[i])
			dvel[j] = 0.0
			return
	_splash(mat(c_col[i]))


## 아래도 옆도 붙은 데가 없는 조각은 떨어진다
func _settle() -> void:
	var moved := true
	while moved and not over:
		moved = false
		for i in c_node.size():
			if not _alive(i):
				continue
			var k := c_key[i]
			if k.y == 0 or grid.has(k + DOWN):
				continue
			var stuck := false
			for d in SIDES:
				if grid.has(k + d):
					stuck = true
			if not stuck:
				_drip(i)
				moved = true


func _splash(m: StandardMaterial3D) -> void:
	pool = maxf(pool, 0.25) + 0.12
	if m:
		puddle.material_override = m
	_puddle_show()
	beep(240.0, 0.1, 120.0, 0.2)
	if pool >= PLATE:
		msg("넘쳤다", 1.5)
		end()


func _puddle_show() -> void:
	if puddle == null:
		return
	puddle.visible = pool > 0.0
	puddle.scale = Vector3(pool * 2.0, 0.04, pool * 2.0)


func _pick(p: Vector2) -> int:
	var bv := 1e9
	var bi := -1
	var cp := cam.global_position
	for i in c_node.size():
		if not _alive(i):
			continue
		var gp := c_node[i].global_position
		var dd := cam.unproject_position(gp).distance_to(p)
		if dd > 80.0:
			continue
		var v := dd + cp.distance_to(gp) * 40.0
		if v < bv:
			bv = v
			bi = i
	return bi


func _try(p: Vector2) -> void:
	if lock > 0.0:
		return
	if wasp_on >= 0 and cam.unproject_position(wasp.global_position).distance_to(p) < 60.0:
		_sting()
		return
	var i := _pick(p)
	if i < 0:
		return
	if i == wasp_on:
		_sting()
		return
	_bite(i)


func _sting() -> void:
	msg("쏘였다", 1.5)
	beep(120.0, 0.4, 60.0, 0.3)
	end()


func _bite(i: int) -> void:
	var gap := last_bite
	last_bite = 0.0
	rub_cool = 0.13
	score += 1
	if c_spr[i] != null:
		chill = maxf(chill - 0.3, 0.0)
		play("good")
		msg("시원!", 0.5)
	else:
		chill += 0.09 + 0.2 * exp(-gap / 0.35)
		beep(240.0 + randf() * 90.0, 0.07, 140.0, 0.25)
	_remove(i)
	_settle()
	if over:
		return
	if chill >= 1.0:
		msg("기절", 1.5)
		end()
		return
	if chill >= 0.7 and armed:
		armed = false
		lock = 1.1
		msg("띵!", 1.0)
		beep(1700.0, 0.5, 500.0, 0.25)


func _tap(p: Vector2) -> void:
	if lock > 0.0:
		beep(200.0, 0.05, 0.0, 0.12)
		return
	_try(p)


func _drag(p: Vector2) -> void:
	if rub_cool <= 0.0:
		_try(p)
