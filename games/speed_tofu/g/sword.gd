extends Tofu
## 칼싸움: 빨간 표시 쪽으로 밀어서 막고(칭!), 막으면 뜨는 초록 쪽으로 밀어서 벤다. 틀리거나 늦으면 맞는다(3번). 갈수록 빨라지고 속임·연타가 섞인다.

const SWIPE := 60.0
const OFF := [Vector3(-1.5, 0, 0.7), Vector3(1.5, 0, 0.7), Vector3(0, 1.75, 0.7), Vector3(0, -1.75, 0.7)]
const LEAN := [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, -1, 0)]
## 내 칼 자세: 위치, z 회전 (왼·오·위·아래)
const POSE := [Vector3(-0.8, -0.1, 2.5), Vector3(0.8, -0.1, 2.5), Vector3(0, 0.55, 2.5), Vector3(0, -0.85, 2.5)]
const TURN := [0.25, -0.25, PI / 2, PI / 2]
const REST_P := Vector3(0.55, -1.25, 2.5)
const REST_R := -0.6
const CAM_P := Vector3(0, 0.3, 5)

var pivot: Node3D
var body: MeshInstance3D
var sword: MeshInstance3D
var ind: Array[MeshInstance3D] = []
var st := 0  # 0 쉼, 1 공격 예고, 2 빈틈, 3 맞고 휘청
var st_t := 0.0
var win := 0.0
var gap := 0.5
var dir := 0
var show_dir := 0
var feint_at := -1.0
var chain := 0
var hp := 3
var sw_t := 0.0
var flash_t := 0.0
var shake_t := 0.0
var start := Vector2.ZERO
var armed := false


func _reset() -> void:
	cam.position = CAM_P
	cam.look_at(Vector3(0, 0, 0))
	box(Vector3(0, -1.9, -1), Vector3(8, 0.3, 8), SOFT)
	pivot = Node3D.new()
	world.add_child(pivot)
	body = box(Vector3.ZERO, Vector3(1.8, 2.6, 1), C, pivot)
	box(Vector3(-0.4, 0.6, 0.52), Vector3(0.25, 0.25, 0.06), INK, pivot)
	box(Vector3(0.4, 0.6, 0.52), Vector3(0.25, 0.25, 0.06), INK, pivot)
	ind.clear()
	for i in 4:
		var m := box(OFF[i], Vector3(0.6, 0.6, 0.6), BAD, pivot)
		m.visible = false
		ind.append(m)
	sword = box(REST_P, Vector3(0.12, 1.7, 0.12), WHITE)
	sword.rotation.z = REST_R
	hp = 3
	st = 0
	st_t = 0.0
	gap = 0.8
	chain = 0
	sw_t = 0.0
	flash_t = 0.0
	shake_t = 0.0
	armed = false


func _show(d: int, color: Color) -> void:
	for i in 4:
		ind[i].visible = i == d
	if d >= 0:
		ind[d].material_override = mat(color)


func _attack() -> void:
	if gap > 0.11 and score >= 6 and randf() < minf(0.4, score * 0.025):
		chain = 1 + randi() % 2  # 연타: 막아도 빈틈 없이 바로 다음 공격
	st = 1
	st_t = 0.0
	win = maxf(0.32, 0.85 - 0.035 * score)
	dir = randi() % 4
	show_dir = dir
	feint_at = -1.0
	if score >= 4 and randf() < minf(0.45, score * 0.03):
		show_dir = (dir + 1 + randi() % 3) % 4
		feint_at = win * 0.45
		win *= 1.45
	_show(show_dir, BAD)
	beep(330.0, 0.05, 0.0, 0.15)


func _step(dt: float) -> void:
	st_t += dt
	var k := 0.0
	match st:
		0:
			pivot.position = pivot.position.lerp(Vector3.ZERO, minf(1.0, dt * 10.0))
			pivot.rotation.z = lerpf(pivot.rotation.z, 0.0, minf(1.0, dt * 10.0))
			if st_t >= gap:
				_attack()
		1:
			if feint_at >= 0.0 and st_t >= feint_at and show_dir != dir:
				show_dir = dir
				_show(dir, BAD)
				beep(470.0, 0.05, 0.0, 0.15)
			k = clampf(st_t / win, 0.0, 1.0)
			var l: Vector3 = LEAN[show_dir]
			pivot.position = Vector3(l.x * 0.35 * k, l.y * 0.25 * k, 1.8 * k * k)
			pivot.rotation.z = -l.x * 0.25 * k
			ind[show_dir].scale = Vector3.ONE * (0.75 - 0.45 * k)
			if st_t >= win:
				_hurt()
		2:
			k = clampf(st_t / win, 0.0, 1.0)
			pivot.position = pivot.position.lerp(Vector3(0, 0, -0.7), minf(1.0, dt * 14.0))
			ind[dir].scale = Vector3.ONE * (0.75 - 0.45 * k)
			if st_t >= win:
				beep(260.0, 0.1, 200.0, 0.15)
				_idle(maxf(0.15, 0.5 - 0.025 * score))
		3:
			if st_t >= 0.45:
				_idle(0.35)
	if sw_t > 0.0:
		sw_t -= dt
	else:
		sword.position = sword.position.lerp(REST_P, minf(1.0, dt * 12.0))
		sword.rotation.z = lerpf(sword.rotation.z, REST_R, minf(1.0, dt * 12.0))
	if flash_t > 0.0:
		flash_t -= dt
		if flash_t <= 0.0:
			body.material_override = mat(C)
	if shake_t > 0.0:
		shake_t -= dt
		cam.position = CAM_P + Vector3(randf_range(-0.12, 0.12), randf_range(-0.12, 0.12), 0)
		if shake_t <= 0.0:
			cam.position = CAM_P
	gauge(hp / 3.0, GOOD if hp > 1 else BAD)


func _idle(g: float) -> void:
	st = 0
	st_t = 0.0
	gap = g
	_show(-1, BAD)


func _flash(color: Color, dur: float) -> void:
	body.material_override = mat(color)
	flash_t = dur


func _hurt() -> void:
	hp -= 1
	play("bad")
	msg("맞음", 0.4)
	_flash(BAD, 0.25)
	shake_t = 0.2
	chain = 0
	st = 3
	st_t = 0.0
	_show(-1, BAD)
	if hp <= 0:
		end()


func _swing(d: int) -> void:
	sword.position = POSE[d]
	sword.rotation.z = TURN[d]
	sw_t = 0.16
	match st:
		1:
			var fooled := feint_at >= 0.0 and st_t < feint_at
			if d == dir and not fooled:
				_parry()
			else:
				_hurt()
		2:
			if d == dir:
				score += 1
				play("good")
				msg("베기!", 0.35)
				_flash(GOOD, 0.15)
				pivot.position = Vector3(0, 0, -1.2)
				_idle(maxf(0.15, 0.5 - 0.025 * score))
			else:
				beep(260.0, 0.1, 200.0, 0.15)
				_idle(maxf(0.15, 0.5 - 0.025 * score))
		_:
			beep(300.0, 0.05, 150.0, 0.1)


func _parry() -> void:
	beep(1500.0, 0.05, 0.0, 0.25)
	beep(2100.0, 0.09, 1600.0, 0.15)
	_flash(WHITE, 0.1)
	pivot.position = Vector3(0, 0, -0.4)
	if chain > 0:
		chain -= 1
		_idle(0.1)
		return
	st = 2
	st_t = 0.0
	win = maxf(0.35, 0.8 - 0.03 * score)
	dir = randi() % 4
	_show(dir, GOOD)


func _tap(p: Vector2) -> void:
	start = p
	armed = true


func _drag(p: Vector2) -> void:
	if not armed:
		return
	var v := p - start
	if v.length() < SWIPE:
		return
	armed = false
	if absf(v.x) > absf(v.y):
		_swing(0 if v.x < 0.0 else 1)
	else:
		_swing(2 if v.y < 0.0 else 3)


func _lift(_p: Vector2) -> void:
	armed = false
