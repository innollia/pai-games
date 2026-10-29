extends Tofu
## 슈퍼핫: 끌면 내 상자가 따라 움직이고, 내가 움직일 때만 시간이 흐른다. 빨간 적에 몸통박치기로 부수고, 총알에 닿으면 끝. 적을 다 부수면 다음 웨이브.

const W := 4.0  # 판 가로 반폭
const H := 6.0  # 판 세로 반폭
const NB := 40  # 총알 풀 크기

var me: MeshInstance3D
var foes: Array[MeshInstance3D] = []
var cool: Array[float] = []
var shots: Array[MeshInstance3D] = []
var vels: Array[Vector3] = []
var last := Vector3.ZERO
var pend := Vector3.ZERO
var flow := 0.05
var wave := 0
var tick := 0.0


func _setup() -> void:
	time_limit = 0.0


func _reset() -> void:
	cam.position = Vector3(0, 6.5, 0.3)
	cam.rotation_degrees = Vector3(-84, 0, 0)
	box(Vector3(0, -0.1, 0), Vector3(W * 2.0, 0.2, H * 2.0), SOFT)
	for s in [-1.0, 1.0]:
		box(Vector3(s * (W + 0.15), 0.1, 0), Vector3(0.3, 0.4, H * 2.0 + 0.6), D)
		box(Vector3(0, 0.1, s * (H + 0.15)), Vector3(W * 2.0, 0.4, 0.3), D)
	me = box(Vector3(0, 0.4, 3.0), Vector3(0.8, 0.8, 0.8), ME)
	foes.clear()
	cool.clear()
	shots.clear()
	vels.clear()
	for i in NB:
		var b := box(Vector3.ZERO, Vector3(0.3, 0.3, 0.3), A)
		b.visible = false
		shots.append(b)
		vels.append(Vector3.ZERO)
	pend = Vector3.ZERO
	flow = 0.05
	wave = 0
	tick = 0.0
	_next_wave()


func _next_wave() -> void:
	wave += 1
	for f in foes:
		f.queue_free()
	foes.clear()
	cool.clear()
	for i in wave + 1:
		var p := Vector3(randf_range(-W + 0.6, W - 0.6), 0.45, randf_range(-H + 0.6, -1.0))
		if i % 3 == 2:
			p.z = randf_range(H - 1.5, H - 0.6)
		foes.append(box(p, Vector3(0.9, 0.9, 0.9), BAD))
		cool.append(randf_range(1.2, 2.5))
	msg("웨이브 %d" % wave, 0.9)


func _step(dt: float) -> void:
	# 내 이동 (한 프레임에 너무 멀리 가지 않게)
	var mv := pend.limit_length(0.5)
	pend = Vector3.ZERO
	me.position.x = clampf(me.position.x + mv.x, -W + 0.4, W - 0.4)
	me.position.z = clampf(me.position.z + mv.z, -H + 0.4, H - 0.4)
	# 시간 흐름: 내가 빠를수록 1에 가깝고, 멈추면 0.05
	var aim := 0.05
	if held and dt > 0.0:
		aim = clampf(mv.length() / dt / 4.0, 0.05, 1.0)
	flow = move_toward(flow, aim, dt * 5.0)
	gauge(flow, B if flow < 0.5 else A)
	var gd := dt * flow
	tick += gd
	if tick > 0.5:
		tick = 0.0
		beep(1200.0, 0.02, 0.0, 0.06)
	# 적: 천천히 다가오고, 때가 되면 나를 향해 쏜다
	for i in range(foes.size() - 1, -1, -1):
		var f := foes[i]
		var to := me.position - f.position
		to.y = 0.0
		if to.length() < 0.85:
			f.queue_free()
			foes.remove_at(i)
			cool.remove_at(i)
			score += 1
			play("good")
			continue
		f.position += to.normalized() * 0.9 * gd
		cool[i] -= gd
		var k := 1.0 + maxf(0.0, 0.6 - cool[i]) * 0.5
		f.scale = Vector3(0.9 * k, 0.9, 0.9 * k)
		if cool[i] <= 0.0:
			cool[i] = randf_range(2.0, 3.2)
			_fire(f.position, to.normalized())
	# 총알
	for j in NB:
		var b := shots[j]
		if not b.visible:
			continue
		b.position += vels[j] * gd
		var d := b.position - me.position
		d.y = 0.0
		if d.length() < 0.5:
			b.material_override = mat(BAD)
			me.material_override = mat(BAD)
			msg("맞았다", 1.0)
			end()
			return
		if absf(b.position.x) > W + 0.5 or absf(b.position.z) > H + 0.5:
			b.visible = false
	if foes.is_empty():
		play("win")
		_next_wave()


func _fire(from: Vector3, dir: Vector3) -> void:
	for j in NB:
		if not shots[j].visible:
			shots[j].visible = true
			shots[j].material_override = mat(A)
			shots[j].position = Vector3(from.x, 0.45, from.z) + dir * 0.6
			vels[j] = dir * 3.0
			beep(330.0, 0.06, 220.0, 0.15)
			return


func _tap(p: Vector2) -> void:
	last = ground(p)
	play("tap")


func _drag(p: Vector2) -> void:
	var g := ground(p)
	pend += g - last
	last = g


func _lift(_p: Vector2) -> void:
	beep(300.0, 0.06, 0.0, 0.1)
