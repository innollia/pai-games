extends Tofu
## 모사 리나 × 주체할 수 없는 속도. 옆모습. 걷기는 느리고 점프가 없다. 판마다 레벨 1 + 속도 도구 3이 무작위(중복 가능), 전부 너무 세다.
## 왼쪽 스틱 걷기. 아래 도구 칸을 탭해 고르고 화면을 탭하면 쓴다(대포·돌풍·패드는 끌어서 방향). 열매를 다 먹고 포털.
## 벽·천장에 세게 박거나 세게 떨어지면 터짐, 가시, 추락 = 죽음(목숨 3, 같은 판 다시). 넘김 3번. 3판 깰 때마다 좁은 레벨이 풀에 들어오고 도구가 세진다.

const HALF := 0.4  # 사람 반폭
const GRAV := 30.0
const WALK := 3.2
const HIT := 12.0  # 벽·천장에 이 속도 이상이면 터짐
const LAND := 24.0  # 바닥에 이 속도 이상으로 떨어지면 터짐
const GREY := Color("c8ccd2")
const STONE := Color("8a929e")
const TOOLS := ["로켓", "용수철", "기름", "대포", "돌풍", "패드"]
const TCOL := [BAD, D, C, STONE, B, A]
const NBOOM := 6
const NGUST := 9
# 세계: x -8.5..8.5, 바닥 y 0, 천장 y 14.5. plats/spikes = [x, y, w, h](가운데 기준)
const LEVELS := [
	{"start": Vector2(-2, 1), "portal": Vector2(-7, 1), "fruits": [Vector2(6, 1)],
		"plats": [[-4.5, -0.5, 7, 1], [5.5, -0.5, 5, 1]], "spikes": []},
	{"start": Vector2(-6, 1), "portal": Vector2(6, 1), "fruits": [Vector2(0, 6)],
		"plats": [[0, -0.5, 16, 1], [0, 5, 4, 0.6]], "spikes": []},
	{"start": Vector2(-4, 1), "portal": Vector2(-7, 1), "fruits": [Vector2(6, 1), Vector2(1, 8)],
		"plats": [[0, -0.5, 16, 1], [1, 4.6, 10, 0.6]], "spikes": [[1, 4.05, 10, 0.5]]},
	{"start": Vector2(-6, 1), "portal": Vector2(6.5, 1), "fruits": [Vector2(-5, 4), Vector2(5, 7), Vector2(-5, 10)],
		"plats": [[0, -0.5, 16, 1], [-5, 3, 3, 0.6], [5, 6, 3, 0.6], [-5, 9, 3, 0.6]], "spikes": [[0, 0.25, 4, 0.5]]},
	{"start": Vector2(-5, 1), "portal": Vector2(-7, 1), "fruits": [Vector2(5, 1)],
		"plats": [[0, -0.5, 16, 1], [0, 3, 1, 6]], "spikes": [[0, 6.25, 1, 0.5]]},
	{"start": Vector2(-6, 1), "portal": Vector2(6.5, 1), "fruits": [Vector2(0, -3.5)],
		"plats": [[-5.25, -0.5, 5.5, 1], [5.25, -0.5, 5.5, 1], [0, -4.5, 5, 1], [-3, -2.5, 1, 4], [3, -2.5, 1, 4]], "spikes": []},
	# 여기부터 좁은 레벨 (1단계 뒤 풀에 들어온다)
	{"start": Vector2(-5, 1), "portal": Vector2(-7, 1), "fruits": [Vector2(6.5, 1)],
		"plats": [[-4.5, -0.5, 7, 1], [5.5, -0.5, 5, 1], [0, 3.3, 16, 0.6]], "spikes": [[0, 2.75, 16, 0.5]]},
	{"start": Vector2(-6, 1), "portal": Vector2(-6, 11), "fruits": [Vector2(6.5, 1), Vector2(6.5, 8)],
		"plats": [[0, -0.5, 16, 1], [-2, 4, 1, 8], [3, 9.5, 1, 5], [5.5, 7, 5, 0.6], [-5, 10, 6, 0.6]], "spikes": [[-2, 8.25, 1, 0.5]]},
]

var rng := RandomNumberGenerator.new()
var plats: Array = []
var spikes: Array = []
var fruits: Array[Dictionary] = []  # {p, n, got}
var left := 0
var portal_n: MeshInstance3D
var portal_p := Vector2.ZERO
var lv_i := 0
var lv_node: Node3D
var item_node: Node3D
var items: Array[Dictionary] = []  # {kind, p, d, n, cool}
var tools: Array[int] = []
var used: Array[bool] = []
var sel := -1
var cleared := 0
var stage := 0
var power := 1.0
var lives := 3
var skips := 3
var hero: Node3D
var hero_m: MeshInstance3D
var eye: MeshInstance3D
var hp := Vector2.ZERO
var hv := Vector2.ZERO
var face := 1.0
var grounded := false
var on_oil := false
var in_can := -1
var can_t := 0.0
var boom: Array[MeshInstance3D] = []
var boom_v: Array[Vector2] = []
var gusts: Array[MeshInstance3D] = []
var ghost: MeshInstance3D
var arrow: MeshInstance3D
var aiming := false
var aim0 := Vector2.ZERO
var aim1 := Vector2.ZERO
var dead_t := 0.0
var clear_t := 0.0
var pulse := 0.0
var step_t := 0.0
var whoosh_t := 0.0


func _setup() -> void:
	howto = "걷기는 느리고 점프가 없다. 속도 도구 3개가 무작위로 온다. 전부 너무 세다.\n왼쪽 스틱 걷기. 아래 도구 칸을 탭해 고르고 화면을 탭하면 쓴다(대포·돌풍·패드는 끌어서 방향).\n열매를 다 먹고 포털로. 세게 부딪히거나 가시·추락이면 터진다(목숨 3). 넘김 3번."
	time_limit = 0.0
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 17.0
	cam.position = Vector3(0, 6.75 + 65.0 / (720.0 / 17.0), 20)
	kit_stick(Rect2(0, 960, 300, 320))


func _reset() -> void:
	rng.randomize()
	cleared = 0
	stage = 0
	power = 1.0
	lives = 3
	skips = 3
	lv_i = -1
	lv_node = null
	item_node = null
	boom.clear()
	boom_v.clear()
	gusts.clear()
	hero = Node3D.new()
	world.add_child(hero)
	hero_m = box(Vector3.ZERO, Vector3(0.8, 0.8, 0.8), ME, hero)
	eye = box(Vector3(0.22, 0.15, 0.41), Vector3(0.2, 0.2, 0.2), SOFT, hero)
	for i in NBOOM:
		var b := box(Vector3.ZERO, Vector3(0.3, 0.3, 0.3), ME)
		b.visible = false
		boom.append(b)
		boom_v.append(Vector2.ZERO)
	for i in NGUST:
		var g := box(Vector3.ZERO, Vector3(1.2, 0.08, 0.08), WHITE)
		g.visible = false
		gusts.append(g)
	ghost = box(Vector3.ZERO, Vector3(0.6, 0.6, 0.6), WHITE)
	ghost.visible = false
	arrow = box(Vector3.ZERO, Vector3(1.4, 0.22, 0.22), INK)
	arrow.visible = false
	_new_round()


# ---- 판 ----
func _new_round() -> void:
	var pool := 6 if stage < 1 else LEVELS.size()
	var n := rng.randi_range(0, pool - 1)
	if n == lv_i:
		n = (n + 1 + rng.randi_range(0, pool - 2)) % pool
	lv_i = n
	tools.clear()
	for i in 3:
		tools.append(rng.randi_range(0, 5))
	_build()
	_attempt()
	var names := PackedStringArray()
	for ti in tools:
		names.append(TOOLS[ti])
	msg("·".join(names), 1.4)


func _build() -> void:
	if lv_node:
		lv_node.queue_free()
	lv_node = Node3D.new()
	world.add_child(lv_node)
	var L: Dictionary = LEVELS[lv_i]
	plats.clear()
	spikes.clear()
	fruits.clear()
	plats.append([-8.75, 4.0, 0.5, 23.0])
	plats.append([8.75, 4.0, 0.5, 23.0])
	plats.append([0.0, 14.75, 18.0, 0.5])
	for pl in plats:
		box(Vector3(pl[0], pl[1], 0), Vector3(pl[2], pl[3], 1.5), WHITE, lv_node)
	for pl in L.plats:
		plats.append(pl)
		box(Vector3(pl[0], pl[1], 0), Vector3(pl[2], pl[3], 1.5), SOFT, lv_node)
	for sp in L.spikes:
		spikes.append(sp)
		var cnt := maxi(1, int(float(sp[2]) / 0.5))
		for k in cnt:
			var x := float(sp[0]) - float(sp[2]) * 0.5 + (k + 0.5) * float(sp[2]) / cnt
			var m := box(Vector3(x, sp[1], 0), Vector3(0.3, float(sp[3]) * 0.9, 0.3), BAD, lv_node)
			m.rotation.z = PI / 4.0
	for f in L.fruits:
		var m := box(Vector3(f.x, f.y, 0), Vector3(0.5, 0.5, 0.5), GOOD, lv_node)
		m.rotation.z = PI / 4.0
		fruits.append({"p": f, "n": m, "got": false})
	portal_p = L.portal
	portal_n = box(Vector3(portal_p.x, portal_p.y, -0.3), Vector3(1.0, 1.6, 0.3), B, lv_node)


## 같은 레벨·같은 도구로 다시 (죽었을 때도 이걸 부른다)
func _attempt() -> void:
	if item_node:
		item_node.queue_free()
	item_node = Node3D.new()
	world.add_child(item_node)
	items.clear()
	used.clear()
	for i in 3:
		used.append(false)
	sel = -1
	aiming = false
	var L: Dictionary = LEVELS[lv_i]
	hp = L.start
	hv = Vector2.ZERO
	face = 1.0
	grounded = false
	in_can = -1
	dead_t = 0.0
	clear_t = 0.0
	left = 0
	for f in fruits:
		f["got"] = false
		(f["n"] as MeshInstance3D).visible = true
		left += 1
	portal_n.material_override = mat(B)
	hero.visible = true
	hero.scale = Vector3.ONE
	hero.rotation.z = 0.0
	for b in boom:
		b.visible = false
	_buttons()


func _buttons() -> void:
	for i in 3:
		var k: int = tools[i]
		kit_button("t%d" % i, "×" if used[i] else TOOLS[k], Vector2(400 + 120 * i, 1190), 62.0 if sel == i else 50.0, GREY if used[i] else TCOL[k])
	kit_button("skip", "넘김 %d" % skips, Vector2(650, 70), 46.0, C if skips > 0 else GREY)


# ---- 입력 ----
func _w(p: Vector2) -> Vector2:
	var v := on_z(p, 0.0)
	return Vector2(v.x, v.y)


func _tap(p: Vector2) -> void:
	if dead_t > 0.0 or clear_t > 0.0 or in_can >= 0:
		return
	if sel < 0 or used[sel]:
		msg("도구를 골라", 0.6)
		beep(160.0, 0.08, 0.0, 0.15)
		return
	aiming = true
	aim0 = _w(p)
	aim1 = aim0


func _drag(p: Vector2) -> void:
	if aiming:
		aim1 = _w(p)


func _lift(p: Vector2) -> void:
	if not aiming:
		return
	aiming = false
	aim1 = _w(p)
	if sel < 0 or used[sel]:
		return
	_use(sel, aim0, aim1)
	used[sel] = true
	sel = -1
	_buttons()


## 도구 쓰기. a = 누른 자리, b = 뗀 자리
func _use(i: int, a: Vector2, b: Vector2) -> void:
	var k: int = tools[i]
	var d := b - a
	d = Vector2(face, 0.0) if d.length() < 0.6 else d.normalized()
	var fy := _floor_y(a)
	match k:
		0:
			var dir := b - hp
			if dir.length() < 0.5:
				dir = Vector2(face, 1.0)
			hv = dir.normalized() * 22.0 * power
			grounded = false
			hp.y += 0.05
			beep(600.0, 0.3, 150.0, 0.35)
			msg("로켓!", 0.5)
		1:
			var n := box(Vector3(a.x, fy + 0.15, 0), Vector3(1.6, 0.3, 0.9), D, item_node)
			items.append({"kind": 1, "p": Vector2(a.x, fy), "d": Vector2.UP, "n": n, "cool": 0.0})
			beep(900.0, 0.06, 0.0, 0.2)
		2:
			var n := box(Vector3(a.x, fy + 0.05, 0.1), Vector3(3.2, 0.1, 0.9), C, item_node)
			items.append({"kind": 2, "p": Vector2(a.x, fy), "d": Vector2.RIGHT, "n": n, "cool": 0.0})
			beep(700.0, 0.12, 300.0, 0.2)
		3:
			var n := box(Vector3(a.x, fy + 0.6, 0), Vector3(1.2, 1.2, 1.0), STONE, item_node)
			var barrel := box(Vector3(a.x + d.x * 0.6, fy + 0.6 + d.y * 0.6, 0.2), Vector3(1.6, 0.45, 0.45), INK, item_node)
			barrel.rotation.z = d.angle()
			items.append({"kind": 3, "p": Vector2(a.x, fy + 0.6), "d": d, "n": n, "cool": 0.0})
			beep(300.0, 0.1, 0.0, 0.25)
		4:
			var n := box(Vector3(a.x, a.y, 0), Vector3(0.9, 0.9, 0.9), B, item_node)
			var nose := box(Vector3(a.x + d.x * 0.6, a.y + d.y * 0.6, 0), Vector3(0.5, 1.4, 0.5), B, item_node)
			nose.rotation.z = d.angle()
			items.append({"kind": 4, "p": a, "d": d, "n": n, "cool": 0.0})
			beep(200.0, 0.4, 400.0, 0.2)
		5:
			var dx := face if absf(d.x) < 0.01 else signf(d.x)
			var n := box(Vector3(a.x, fy + 0.1, 0), Vector3(2.4, 0.2, 0.9), A, item_node)
			box(Vector3(a.x + dx * 0.7, fy + 0.3, 0), Vector3(0.6, 0.2, 0.6), WHITE, item_node)
			items.append({"kind": 5, "p": Vector2(a.x, fy), "d": Vector2(dx, 0.0), "n": n, "cool": 0.0})
			beep(800.0, 0.06, 1200.0, 0.2)


## 점 a 아래 가장 높은 발판 윗면 (없으면 a 높이 그대로)
func _floor_y(a: Vector2) -> float:
	var best := -99.0
	for pl in plats:
		var top := float(pl[1]) + float(pl[3]) * 0.5
		if absf(a.x - float(pl[0])) < float(pl[2]) * 0.5 and top <= a.y + 0.5 and top > best:
			best = top
	return a.y if best < -50.0 else best


func _ov(px: float, py: float, hw: float, hh: float, pl: Array) -> bool:
	return absf(px - float(pl[0])) < hw + float(pl[2]) * 0.5 and absf(py - float(pl[1])) < hh + float(pl[3]) * 0.5


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	pulse += dt
	gauge(lives / 3.0, BAD)
	if dead_t > 0.0:
		dead_t -= dt
		for i in NBOOM:
			boom_v[i].y -= GRAV * dt
			boom[i].position += Vector3(boom_v[i].x, boom_v[i].y, 0) * dt
			boom[i].rotation.z += 9.0 * dt
		if dead_t <= 0.0:
			if lives <= 0:
				end()
			else:
				_attempt()
		return
	if clear_t > 0.0:
		clear_t -= dt
		hero.scale = Vector3.ONE * maxf(clear_t / 0.8, 0.01)
		hero.rotation.z += 12.0 * dt
		if clear_t <= 0.0:
			_new_round()
		return
	for i in 3:
		if kit_just("t%d" % i):
			if used[i]:
				beep(160.0, 0.08, 0.0, 0.2)
			else:
				sel = -1 if sel == i else i
				play("tap")
				_buttons()
	if kit_just("skip"):
		if skips > 0:
			skips -= 1
			beep(400.0, 0.15, 200.0, 0.25)
			msg("넘김", 0.8)
			_new_round()
			return
		beep(160.0, 0.08, 0.0, 0.2)
	for it in items:
		it["cool"] = float(it["cool"]) - dt
	if in_can >= 0:
		can_t -= dt
		var it: Dictionary = items[in_can]
		if can_t <= 0.0:
			var d: Vector2 = it["d"]
			var cp: Vector2 = it["p"]
			hp = cp + d * 0.9
			hv = d * 26.0 * power
			grounded = false
			hero.visible = true
			it["cool"] = 1.0
			in_can = -1
			beep(120.0, 0.25, 40.0, 0.35)
			msg("발사!", 0.5)
		else:
			_draw()
			return
	_physics(dt)
	if dead_t > 0.0 or clear_t > 0.0:
		return
	_draw()


func _physics(dt: float) -> void:
	var inp := kit_move.x if absf(kit_move.x) > 0.2 else 0.0
	if inp != 0.0:
		face = signf(inp)
	on_oil = false
	if grounded:
		for it in items:
			if int(it["kind"]) == 2:
				var op: Vector2 = it["p"]
				if absf(hp.x - op.x) < 1.6 and absf(hp.y - HALF - op.y) < 0.35:
					on_oil = true
	if grounded and not on_oil:
		hv.x = move_toward(hv.x, inp * WALK, 40.0 * dt)
		if inp != 0.0:
			step_t -= dt
			if step_t <= 0.0:
				step_t = 0.28
				beep(140.0, 0.04, 0.0, 0.12)
	elif not grounded:
		hv.x += inp * 4.0 * dt
		hv.x *= exp(-0.5 * dt)
	hv.y -= GRAV * dt
	for it in items:
		if int(it["kind"]) == 4:
			var fp: Vector2 = it["p"]
			var d: Vector2 = it["d"]
			var rel := hp - fp
			var along := rel.dot(d)
			if along > 0.0 and along < 7.0 and absf(rel.cross(d)) < 1.2:
				hv += d * 40.0 * power * dt
	# 가로 이동·충돌
	hp.x += hv.x * dt
	for pl in plats:
		if _ov(hp.x, hp.y, HALF, HALF - 0.02, pl):
			var vx := hv.x
			hp.x = float(pl[0]) - float(pl[2]) * 0.5 - HALF if vx > 0.0 else float(pl[0]) + float(pl[2]) * 0.5 + HALF
			hv.x = 0.0
			if absf(vx) > HIT:
				_die("쾅!")
				return
	# 세로 이동·충돌
	hp.y += hv.y * dt
	grounded = false
	for pl in plats:
		if _ov(hp.x, hp.y, HALF - 0.02, HALF, pl):
			var vy := hv.y
			if vy <= 0.0:
				hp.y = float(pl[1]) + float(pl[3]) * 0.5 + HALF
				grounded = true
			else:
				hp.y = float(pl[1]) - float(pl[3]) * 0.5 - HALF
			hv.y = 0.0
			if vy < -LAND or vy > HIT:
				_die("쾅!")
				return
	# 놓은 도구
	for i in items.size():
		var it: Dictionary = items[i]
		var k: int = it["kind"]
		var ip: Vector2 = it["p"]
		if k == 1 and hv.y <= 0.5 and absf(hp.x - ip.x) < 0.9 and absf(hp.y - HALF - ip.y) < 0.4:
			hv.y = 22.0 * power
			grounded = false
			hp.y += 0.05
			beep(300.0, 0.15, 900.0, 0.3)
			msg("튕!", 0.4)
		elif k == 5 and grounded and absf(hp.x - ip.x) < 1.2 and absf(hp.y - HALF - ip.y) < 0.4:
			var d: Vector2 = it["d"]
			if hv.x * d.x < 16.0 * power:
				hv.x = d.x * 18.0 * power
				beep(500.0, 0.1, 1000.0, 0.25)
		elif k == 3 and in_can < 0 and float(it["cool"]) <= 0.0 and absf(hp.x - ip.x) < 0.8 and absf(hp.y - ip.y) < 0.8:
			in_can = i
			can_t = 0.6
			hv = Vector2.ZERO
			hero.visible = false
			beep(200.0, 0.3, 500.0, 0.25)
			msg("대포", 0.5)
	for sp in spikes:
		if _ov(hp.x, hp.y, HALF - 0.1, HALF - 0.1, sp):
			_die("가시")
			return
	if hp.y < -9.0:
		_die("추락")
		return
	for f in fruits:
		if not f["got"] and (f["p"] as Vector2).distance_to(hp) < 0.8:
			f["got"] = true
			(f["n"] as MeshInstance3D).visible = false
			left -= 1
			play("good")
			if left == 0:
				portal_n.material_override = mat(D)
				msg("포털!", 0.8)
				beep(660.0, 0.2, 990.0, 0.25)
	if left == 0 and absf(hp.x - portal_p.x) < 0.7 and absf(hp.y - portal_p.y) < 1.0:
		clear_t = 0.8
		score += 1
		cleared += 1
		var ns := cleared / 3
		if ns != stage:
			stage = ns
			power = 1.0 + 0.25 * stage
			msg("%d단계" % (stage + 1), 1.2)
		play("win")
		return
	# 빠를 때 바람 소리
	var spd := hv.length()
	if spd > 9.0:
		whoosh_t -= dt * spd
		if whoosh_t <= 0.0:
			whoosh_t = 3.0
			beep(90.0 + spd * 12.0, 0.05, 0.0, 0.12)


func _die(why: String) -> void:
	if dead_t > 0.0:
		return
	dead_t = 1.0
	lives -= 1
	aiming = false
	sel = -1
	in_can = -1
	hero.visible = false
	for i in NBOOM:
		boom[i].visible = true
		boom[i].position = Vector3(hp.x, hp.y, 0.2)
		boom_v[i] = Vector2(rng.randf_range(-8.0, 8.0), rng.randf_range(3.0, 12.0)) + hv * 0.3
	msg(why, 0.9)
	play("bad")
	_buttons()


func _draw() -> void:
	hero.position = Vector3(hp.x, hp.y, 0)
	hero.rotation.z = 0.0 if grounded else clampf(-hv.x * 0.015, -0.5, 0.5)
	eye.position.x = 0.22 * face
	portal_n.scale.y = 1.6 + (sin(pulse * 6.0) * 0.15 if left == 0 else 0.0)
	ghost.visible = aiming
	arrow.visible = false
	if aiming and sel >= 0:
		var a := aim0
		var d := aim1 - aim0
		if tools[sel] == 0:
			a = hp
			d = aim1 - hp
		ghost.position = Vector3(a.x, a.y, 0.5)
		if d.length() > 0.6:
			var n := d.normalized()
			arrow.visible = true
			arrow.position = Vector3(a.x + n.x * 1.2, a.y + n.y * 1.2, 0.5)
			arrow.rotation.z = n.angle()
	var gi := 0
	for it in items:
		if int(it["kind"]) == 4 and gi + 3 <= NGUST:
			var d: Vector2 = it["d"]
			var fp: Vector2 = it["p"]
			for j in 3:
				var g := gusts[gi]
				gi += 1
				var s := fmod(pulse * 6.0 + j * 2.3, 7.0)
				var q := fp + d * s + Vector2(-d.y, d.x) * (j - 1) * 0.6
				g.visible = true
				g.position = Vector3(q.x, q.y, 0.3)
				g.rotation.z = d.angle()
	for j in range(gi, NGUST):
		gusts[j].visible = false
