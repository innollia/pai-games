extends Tofu
## 핫팩 몰래 넣기: 누른 채 위아래로 빠르게 흔들면 핫팩이 뜨거워진다(빠를수록 빨리, 멈추면 식는다). 충분히 뜨거우면 앞사람 목덜미 틈으로 끌어 넣는다(뜨거울수록 점수). 고개가 씰룩하면 곧 뒤돈다 — 그때 흔들거나 가까이 있으면 들킨다. 3번 들키면 끝.

const PZ := 3.5  # 핫팩이 움직이는 깊이
const REST := Vector2(360, 1120)  # 놓았을 때 핫팩 자리(화면)
const LIFT := 70.0  # 손가락에 가리지 않게 위로 띄우는 정도

var man: Node3D
var hd: Node3D
var collar: MeshInstance3D
var pack: MeshInstance3D
var hearts: Array[MeshInstance3D] = []
var pp := REST  # 핫팩 화면 위치
var heat := 0.0
var shake := 0.0  # 흔드는 빠르기 (px/초, 부드럽게)
var moved := 0.0
var last_y := 0.0
var sdir := 0.0
var stroke := 0.0
var ready_on := false
var lost := false  # 들켰거나 넣은 뒤, 다시 누를 때까지 핫팩을 못 잡는다
var ph := 0  # 0 조용, 1 씰룩(곧 돈다), 2 뒤돌아봄
var pt := 0.0
var caught := false
var rnd := 1
var lives := 3
var hop := 0.0
var warned := 0.0


func _setup() -> void:
	howto = "누른 채 위아래로 빠르게 흔들면 핫팩이 뜨거워진다.\n뜨거워지면 앞사람 목덜미 틈으로 끌어 넣자.\n고개가 씰룩하면 곧 뒤돈다. 그때 흔들면 들킨다. 3번 들키면 끝."
	time_limit = 0.0


func _reset() -> void:
	cam.position = Vector3(0, 0, 7)
	cam.rotation = Vector3.ZERO
	man = Node3D.new()
	world.add_child(man)
	box(Vector3(0, -4.5, 0), Vector3(4.2, 11.0, 1.6), C, man)
	box(Vector3(0, 1.05, 0.55), Vector3(2.2, 0.35, 0.6), WHITE, man)
	collar = box(Vector3(0, 1.12, 0.87), Vector3(1.3, 0.22, 0.06), INK, man)
	box(Vector3(0, 1.4, 0), Vector3(1.1, 0.9, 0.9), D, man)
	hd = Node3D.new()
	hd.position = Vector3(0, 2.8, 0)
	man.add_child(hd)
	box(Vector3.ZERO, Vector3(2.2, 2.4, 2.0), D, hd)
	box(Vector3(0, 1.0, 0.15), Vector3(2.3, 0.6, 1.9), INK, hd)
	box(Vector3(0, 0.2, 1.02), Vector3(2.2, 1.6, 0.1), INK, hd)
	for s in [-1.0, 1.0]:
		box(Vector3(s * 0.5, 0.15, -1.03), Vector3(0.4, 0.4, 0.08), INK, hd)
	box(Vector3(0, -0.6, -1.03), Vector3(0.8, 0.15, 0.08), BAD, hd)
	pack = box(on_z(REST, PZ), Vector3(0.9, 1.2, 0.3), B)
	hearts.clear()
	for i in 3:
		hearts.append(box(Vector3(1.3 + i * 0.5, 4.2, PZ), Vector3(0.36, 0.36, 0.36), BAD))
	pp = REST
	heat = 0.0
	shake = 0.0
	moved = 0.0
	sdir = 0.0
	stroke = 0.0
	ready_on = false
	lost = false
	ph = 0
	caught = false
	rnd = 1
	lives = 3
	hop = 0.0
	warned = 0.0
	pt = _calm() + 1.0
	msg("흔들어!", 1.0)


func _calm() -> float:
	return maxf(0.8, randf_range(1.8, 3.8) / (1.0 + 0.12 * (rnd - 1)))


func _step(dt: float) -> void:
	# 흔드는 빠르기 -> 열
	var inst := moved / maxf(dt, 0.001)
	moved = 0.0
	shake = lerpf(shake, inst if held else 0.0, 1.0 - exp(-10.0 * dt))
	var need := minf(0.45 + 0.06 * (rnd - 1), 0.9)
	heat += clampf((shake - 500.0) / 3000.0, 0.0, 1.0) * 0.55 * dt
	heat -= (0.08 if held else 0.3) * dt
	heat = clampf(heat, 0.0, 1.0)
	if heat >= need and not ready_on:
		ready_on = true
		beep(1320.0, 0.1, 1760.0, 0.25)
		msg("지금!", 0.5)
	elif heat < need - 0.05:
		ready_on = false
	var hq := snappedf(heat, 0.05)
	var col := B.lerp(A, hq * 2.0) if hq < 0.5 else A.lerp(BAD, (hq - 0.5) * 2.0)
	pack.material_override = mat(col)
	gauge(heat, col)
	# 핫팩 위치
	if not held or lost:
		pp = pp.lerp(REST, 1.0 - exp(-12.0 * dt))
	pack.position = on_z(pp, PZ)
	pack.rotation.z = sdir * minf(shake / 8000.0, 0.35)
	# 앞사람: 조용 -> 씰룩 -> 뒤돌아봄
	hop = maxf(0.0, hop - dt * 3.0)
	man.position.y = sin(hop * PI) * 0.6
	pt -= dt
	match ph:
		0:
			hd.rotation.z = 0.0
			if pt <= 0.0:
				ph = 1
				pt = maxf(0.35, 0.8 - 0.05 * (rnd - 1))
				beep(170.0, 0.15, 120.0, 0.3)
				msg("흠?", 0.5)
		1:
			hd.rotation.z = sin(pt * 45.0) * 0.12
			if pt <= 0.0:
				ph = 2
				pt = randf_range(0.9, 1.5)
				caught = false
				beep(500.0, 0.08, 300.0, 0.2)
		2:
			hd.rotation.z = 0.0
			if pt <= 0.0:
				ph = 0
				pt = _calm()
				beep(300.0, 0.06, 0.0, 0.1)
	man.rotation.y = move_toward(man.rotation.y, PI if ph == 2 else 0.0, dt * 14.0)
	var cs := cam.unproject_position(collar.global_position)
	var near := held and not lost and pp.distance_to(cs) < 300.0
	if ph == 2 and man.rotation.y > 2.6 and not caught and (shake > 700.0 or near):
		caught = true
		lives -= 1
		hearts[lives].visible = false
		play("bad")
		msg("들켰다!", 0.8)
		heat *= 0.3
		lost = true
		if lives <= 0:
			end()
		return
	# 목덜미에 넣기 (씰룩하는 동안에도 된다)
	warned -= dt
	if ph != 2 and man.rotation.y < 0.5 and held and not lost and pp.distance_to(cs) < 110.0:
		if heat >= need:
			var pts := int(round(heat * 10.0))
			score += pts
			play("good")
			beep(1500.0, 0.25, 600.0, 0.25)
			msg("앗뜨! +%d" % pts, 0.8)
			hop = 1.0
			heat = 0.0
			ready_on = false
			lost = true
			rnd += 1
			ph = 0
			pt = _calm() + 0.5
		elif warned <= 0.0:
			msg("더 뜨겁게", 0.5)
			beep(260.0, 0.08, 0.0, 0.15)
			warned = 0.8


func _tap(p: Vector2) -> void:
	lost = false
	pp = Vector2(p.x, clampf(p.y - LIFT, 250.0, 1240.0))
	last_y = p.y
	sdir = 0.0
	stroke = 0.0
	play("tap")


func _drag(p: Vector2) -> void:
	if lost:
		return
	pp = Vector2(p.x, clampf(p.y - LIFT, 250.0, 1240.0))
	var dy := p.y - last_y
	last_y = p.y
	moved += absf(dy)
	if dy == 0.0:
		return
	var s := signf(dy)
	if s != sdir:
		if stroke > 30.0:
			# 방향이 바뀔 때마다 찰칵, 빠를수록 높은 소리
			beep(260.0 + snappedf(minf(shake, 5000.0) * 0.22, 40.0), 0.04, 0.0, 0.15)
		sdir = s
		stroke = 0.0
	stroke += absf(dy)


func _lift(_p: Vector2) -> void:
	beep(300.0, 0.05, 0.0, 0.08)
