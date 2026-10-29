extends Tofu
## 시간 빚: 아무 데나 누르고 끌면 그쪽으로 움직인다. 손을 떼면 시간이 0.2배로 느려지고(빚), 그때 빨간 적을 탭하면 번개로 없앤다(노란 상자 주워 충전). 다시 잡으면 느려졌던 만큼 세상이 2.5배로 빨리 돈다. 적에 닿으면 끝.

const W := 4.0  # 판 가로 반폭
const H := 6.0  # 판 세로 반폭
const NF := 30  # 적 풀 크기
const NI := 3  # 번개 아이템 풀
const MAXC := 5  # 번개 최대 충전
const SLOW := 0.2
const FAST := 2.5
const CAP := 5.0  # 빚 최대 (초)
const STICK := 110.0  # 조이스틱 반경 (px)

var me: MeshInstance3D
var floor_b: MeshInstance3D
var knob: MeshInstance3D
var base_b: MeshInstance3D
var beam: MeshInstance3D
var foes: Array[MeshInstance3D] = []
var items: Array[MeshInstance3D] = []
var pips: Array[MeshInstance3D] = []
var anchor := Vector2.ZERO
var stick := Vector2.ZERO
var grab := false
var zapping := false
var started := false
var flow := SLOW
var debt := 0.0
var charges := 1
var kills := 0
var gtime := 0.0
var spawn_t := 0.0
var item_t := 0.0
var tick := 0.0
var beam_t := 0.0
var wave := 1
var mode := 0  # 0 보통, 1 느림, 2 빠름 (바닥 색 바꿀 때만)


func _setup() -> void:
	time_limit = 0.0


func _reset() -> void:
	cam.position = Vector3(0, 7.5, 0.6)
	cam.rotation_degrees = Vector3(-82, 0, 0)
	cam.fov = 70.0
	floor_b = box(Vector3(0, -0.1, 0), Vector3(W * 2.0, 0.2, H * 2.0), SOFT)
	for s in [-1.0, 1.0]:
		box(Vector3(s * (W + 0.15), 0.1, 0), Vector3(0.3, 0.4, H * 2.0 + 0.6), INK)
		box(Vector3(0, 0.1, s * (H + 0.15)), Vector3(W * 2.0, 0.4, 0.3), INK)
	me = box(Vector3(0, 0.4, 2.0), Vector3(0.7, 0.7, 0.7), ME)
	base_b = box(Vector3.ZERO, Vector3(1.4, 0.05, 1.4), WHITE)
	knob = box(Vector3.ZERO, Vector3(0.5, 0.15, 0.5), B)
	base_b.visible = false
	knob.visible = false
	beam = box(Vector3.ZERO, Vector3(0.15, 0.15, 1.0), D)
	beam.visible = false
	foes.clear()
	items.clear()
	pips.clear()
	for i in NF:
		var f := box(Vector3.ZERO, Vector3(0.8, 0.8, 0.8), BAD)
		f.visible = false
		foes.append(f)
	for i in NI:
		var it := box(Vector3.ZERO, Vector3(0.5, 0.5, 0.5), D)
		it.visible = false
		items.append(it)
	for i in MAXC:
		var p := box(Vector3(0, 0, 0), Vector3(0.18, 0.18, 0.18), D, me)
		p.position = Vector3((i - 2) * 0.28, 0.85, 0) / 0.7
		p.scale = Vector3(0.18, 0.18, 0.18) / 0.7
		pips.append(p)
	grab = false
	zapping = false
	started = false
	flow = SLOW
	debt = 0.0
	charges = 1
	kills = 0
	gtime = 0.0
	spawn_t = 1.0
	item_t = 3.0
	tick = 0.0
	beam_t = 0.0
	wave = 1
	mode = -1
	for i in 3:
		_spawn()
	msg("누르고 끌기", 2.0)


func _spawn() -> void:
	for f in foes:
		if f.visible:
			continue
		var p := Vector3.ZERO
		for k in 8:
			if randf() < 0.5:
				p = Vector3(randf_range(-W, W) * 0.9, 0.4, (H - 0.5) * (1.0 if randf() < 0.5 else -1.0))
			else:
				p = Vector3((W - 0.5) * (1.0 if randf() < 0.5 else -1.0), 0.4, randf_range(-H, H) * 0.9)
			if p.distance_to(me.position) > 3.5:
				break
		f.position = p
		f.material_override = mat(BAD)
		f.visible = true
		beep(160.0, 0.05, 0.0, 0.08)
		return


func _step(dt: float) -> void:
	# 시간 빚: 떼면 쌓이고, 잡으면 빠르게 갚는다
	var aim := 1.0
	if not started:
		aim = SLOW
	elif not grab:
		aim = SLOW
		debt = minf(debt + dt, CAP)
	elif debt > 0.0:
		aim = FAST
		debt -= dt
		if debt <= 0.0:
			debt = 0.0
			msg("정상", 0.5)
			beep(660.0, 0.1, 0.0, 0.15)
	flow = move_toward(flow, aim, dt * 10.0)
	var m := 1 if aim == SLOW else (2 if aim == FAST else 0)
	if m != mode:
		mode = m
		floor_b.material_override = mat([SOFT, Color("cfe8ff"), Color("ffd8b0")][m])
	cam.fov = lerpf(cam.fov, [70.0, 64.0, 80.0][m], dt * 6.0)
	if debt > 0.0:
		gauge(debt / CAP, B if not grab else BAD)
	var gd := dt * flow
	gtime += gd
	score = int(gtime) + kills * 3
	# 똑딱: 게임 시간 0.25초마다, 빠를수록 높게
	tick += gd
	if tick > 0.25:
		tick = 0.0
		beep(900.0 if flow < 0.5 else (1700.0 if flow > 1.5 else 1200.0), 0.02, 0.0, 0.07)
	# 내 이동 (진짜 시간, 잡고 있을 때만)
	if grab:
		var v := stick / STICK
		me.position.x = clampf(me.position.x + v.x * 4.0 * dt, -W + 0.4, W - 0.4)
		me.position.z = clampf(me.position.z + v.y * 4.0 * dt, -H + 0.4, H - 0.4)
		base_b.position = Vector3(me.position.x, 0.03, me.position.z)
		knob.position = base_b.position + Vector3(v.x, 0.05, v.y) * 0.9
	for i in pips.size():
		pips[i].visible = i < charges
	# 웨이브: 게임 시간 12초마다 더 빠르고 더 많이
	if gtime > wave * 12.0:
		wave += 1
		msg("웨이브 %d" % wave, 0.8)
		play("win")
	spawn_t -= gd
	if spawn_t <= 0.0:
		spawn_t = maxf(0.5, 2.0 - wave * 0.2)
		_spawn()
	# 번개 아이템
	item_t -= gd
	if item_t <= 0.0:
		item_t = 6.0
		for it in items:
			if not it.visible:
				it.position = Vector3(randf_range(-W + 0.6, W - 0.6), 0.3, randf_range(-H + 0.8, H - 0.8))
				it.visible = true
				break
	for it in items:
		if not it.visible:
			continue
		it.rotation.y += gd * 3.0
		var d := it.position - me.position
		d.y = 0.0
		if d.length() < 0.7:
			it.visible = false
			if charges < MAXC:
				charges += 1
			msg("번개 +1", 0.5)
			play("good")
	# 적: 게임 시간으로 쫓아온다
	var sp := 1.0 + wave * 0.12
	for f in foes:
		if not f.visible:
			continue
		var to := me.position - f.position
		to.y = 0.0
		if to.length() < 0.7:
			f.material_override = mat(WHITE)
			me.material_override = mat(BAD)
			knob.visible = false
			base_b.visible = false
			msg("잡혔다", 1.0)
			end()
			return
		f.position += to.normalized() * sp * gd
		f.rotation.y += gd * 2.0
	# 번개 줄기
	if beam_t > 0.0:
		beam_t -= dt
		beam.visible = beam_t > 0.0


func _tap(p: Vector2) -> void:
	# 느린 시간에 적을 탭하면 번개
	if started and not grab and charges > 0:
		var hit: MeshInstance3D = null
		var bd := 110.0
		for f in foes:
			if not f.visible:
				continue
			var d := cam.unproject_position(f.position).distance_to(p)
			if d < bd:
				bd = d
				hit = f
		if hit:
			_zap(hit)
			zapping = true
			return
	if not started:
		started = true
		msg("떼면 느려짐", 1.2)
	grab = true
	anchor = p
	stick = Vector2.ZERO
	base_b.visible = true
	knob.visible = true
	if debt > 0.0:
		msg("빚 갚기!", 0.8)
		beep(300.0, 0.18, 1200.0, 0.25)
	else:
		play("tap")


func _zap(f: MeshInstance3D) -> void:
	charges -= 1
	kills += 1
	var a := Vector3(me.position.x, 0.5, me.position.z)
	var b := Vector3(f.position.x, 0.5, f.position.z)
	beam.position = (a + b) * 0.5
	beam.scale = Vector3(0.15, 0.15, maxf(a.distance_to(b), 0.1))
	beam.rotation = Vector3(0, atan2(a.x - b.x, a.z - b.z), 0)
	beam.visible = true
	beam_t = 0.15
	f.visible = false
	msg("번개", 0.4)
	beep(1400.0, 0.15, 300.0, 0.25)


func _drag(p: Vector2) -> void:
	if grab:
		stick = (p - anchor).limit_length(STICK)


func _lift(_p: Vector2) -> void:
	if zapping:
		zapping = false
		return
	grab = false
	stick = Vector2.ZERO
	base_b.visible = false
	knob.visible = false
	msg("슬로우", 0.5)
	beep(600.0, 0.2, 200.0, 0.2)
