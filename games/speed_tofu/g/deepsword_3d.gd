extends Tofu
## 딥이스트 소드 3D(등뒤 3인칭): 긴 칼을 앞에 들고 동굴을 뛰어 내려간다. 멈출 수 없다. 조이스틱은 방향만.
## 칼이 벽에 닿으면 홱 돌며 밀려난다. 세우기 버튼을 누르는 동안 칼을 세우고 아주 느리게 간다(찌르기 불가).
## 바닥 끝 심장을 칼끝으로 찌르면 칼이 1.5배 길어지고 걸음이 더 빨라진다. 다음 동굴은 더 길고 좁다. 낭떠러지·용암이면 끝.

const T := 0.6  # 벽 두께
const DROP := 0.6  # 구간마다 내려가는 높이
const WALL_H := 2.2
const SEA := -7.0  # 마지막 바닥 아래 용암 바다
const RAD := 0.38  # 몸 반지름
const GROW := 1.2  # 칼이 자라는 연출 시간

var stage := 0
var rng := RandomNumberGenerator.new()
var level: Node3D
var floors: Array = []  # {r: Rect2(x, z), y}
var walls: Array = []  # {r: Rect2(x, z), y}
var lavas: Array[Rect2] = []
var heart: MeshInstance3D
var heart_r := Rect2()
var heart_s := Vector3.ONE
var sea_y := 0.0
var width := 4.2
# 나
var me: Node3D
var piv: Node3D
var blade: MeshInstance3D
var me_p := Vector2.ZERO
var me_y := 0.0
var yaw := 0.0
var cam_yaw := 0.0
var cam_p := Vector3.ZERO
var run := 3.5  # 걸음 속도(멈출 수 없다)
var slen := 2.0  # 칼 길이
var old_len := 2.0
var up_k := 0.0  # 칼을 세운 정도 0..1
var spin := 0.0  # 벽에 부딪혀 도는 각속도
var knock := Vector2.ZERO
var lock_t := 0.0
var hit_cool := 0.0
var falling := false
var vy := 0.0
var die_t := 0.0
var clear_t := 0.0
var step_d := 0.0
var clock := 0.0


func _setup() -> void:
	time_limit = 0.0
	howto = "왼쪽 조이스틱: 가는 방향만. 멈출 수 없다.\n긴 칼이 벽에 닿으면 홱 돌며 밀려난다. 세우기 버튼을 누르는 동안 칼을 세우고 아주 느리게 간다(찌르기 불가).\n동굴 끝 빨간 심장을 칼끝으로 찌르면 칼이 길어지고 더 빨라진다.\n낭떠러지로 떨어지거나 용암에 닿으면 끝."
	kit_stick()
	kit_button("up", "세우기", Vector2(560, 1060), 115.0, B)


func _reset() -> void:
	rng.randomize()
	stage = 0
	run = 3.5
	slen = 2.0
	old_len = slen
	die_t = 0.0
	clear_t = 0.0
	clock = 0.0
	level = null
	# 나: 몸, 머리, 눈, 칼 축(세우면 축이 돈다)
	me = Node3D.new()
	world.add_child(me)
	box(Vector3(0, 0.45, 0), Vector3(0.8, 0.9, 0.6), ME, me)
	box(Vector3(0, 1.15, 0), Vector3(0.6, 0.5, 0.6), ME, me)
	box(Vector3(-0.15, 1.2, -0.31), Vector3(0.12, 0.12, 0.04), WHITE, me)
	box(Vector3(0.15, 1.2, -0.31), Vector3(0.12, 0.12, 0.04), WHITE, me)
	piv = Node3D.new()
	piv.position = Vector3(0, 0.9, -0.35)
	me.add_child(piv)
	box(Vector3(0, 0, 0.1), Vector3(0.5, 0.12, 0.12), C, piv)
	blade = box(Vector3(0, 0, -1), Vector3(0.16, 0.08, 2.0), D, piv)
	_sword_len(slen)
	_cave()


## 동굴 하나: 지그재그로 내려가는 구간들. 단계마다 더 길고 좁고, 용암과 낭떠러지가 는다.
func _cave() -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	floors.clear()
	walls.clear()
	lavas.clear()
	var n := 4 + stage
	width = maxf(2.4, 4.2 - 0.4 * stage)
	var hw := width * 0.5
	var seg := 10.0 + 2.0 * stage
	var pts: Array[Vector2] = [Vector2.ZERO]
	var side := 1.0 if rng.randf() < 0.5 else -1.0
	for i in n:
		var a := pts[i]
		if i % 2 == 0:
			pts.append(a + Vector2(0, -seg))
		else:
			pts.append(a + Vector2(side * seg * 0.7, 0))
			side = -side
	# 바닥(구간마다 한 칸 내려간다)
	for i in n:
		var a := pts[i]
		var b := pts[i + 1]
		var mn := Vector2(minf(a.x, b.x) - hw, minf(a.y, b.y) - hw)
		var mx := Vector2(maxf(a.x, b.x) + hw, maxf(a.y, b.y) + hw)
		var r := Rect2(mn, mx - mn)
		var y := -DROP * i
		floors.append({"r": r, "y": y})
		box(Vector3(r.get_center().x, y - 0.3, r.get_center().y), Vector3(r.size.x, 0.6, r.size.y), WHITE if i % 2 == 0 else SOFT, level)
	# 낭떠러지: 한쪽 벽이 없는 구간
	var opens := {}
	var n_open := mini(maxi(stage - 1, 0), n - 2)
	var tries := 0
	while opens.size() < n_open and tries < 60:
		tries += 1
		var k := rng.randi_range(1, n - 2)
		if not opens.has(k):
			opens[k] = rng.randi_range(0, 1)
	# 벽(바닥·먼저 만든 벽과 겹치는 부분은 잘라 낸다)
	for i in n:
		var r: Rect2 = floors[i].r
		var y: float = floors[i].y
		var skip: int = opens.get(i, -1)
		if i % 2 == 0:
			if skip != 0:
				_wall(Rect2(r.position.x - T, r.position.y - T, T, r.size.y + 2.0 * T), y)
			if skip != 1:
				_wall(Rect2(r.end.x, r.position.y - T, T, r.size.y + 2.0 * T), y)
			_wall(Rect2(r.position.x - T, r.position.y - T, r.size.x + 2.0 * T, T), y)
			_wall(Rect2(r.position.x - T, r.end.y, r.size.x + 2.0 * T, T), y)
		else:
			if skip != 0:
				_wall(Rect2(r.position.x - T, r.position.y - T, r.size.x + 2.0 * T, T), y)
			if skip != 1:
				_wall(Rect2(r.position.x - T, r.end.y, r.size.x + 2.0 * T, T), y)
			_wall(Rect2(r.position.x - T, r.position.y - T, T, r.size.y + 2.0 * T), y)
			_wall(Rect2(r.end.x, r.position.y - T, T, r.size.y + 2.0 * T), y)
	# 용암 웅덩이(길 한쪽을 막는다)
	var n_lava := stage + 1 if stage >= 1 else 0
	for j in n_lava:
		var i := rng.randi_range(1, n - 2)
		var a := pts[i]
		var b := pts[i + 1]
		var c := a.lerp(b, rng.randf_range(0.3, 0.7))
		c += (b - a).normalized().orthogonal() * hw * 0.45 * (1.0 if rng.randf() < 0.5 else -1.0)
		var s := width * 0.5
		lavas.append(Rect2(c - Vector2(s, s) * 0.5, Vector2(s, s)))
		box(Vector3(c.x, floors[i].y + 0.04, c.y), Vector3(s, 0.08, s), A, level)
	# 심장(마지막 구간 끝)
	var e := pts[n]
	var hy: float = floors[n - 1].y
	var hs := width * 0.45
	heart_r = Rect2(e - Vector2(hs, hs) * 0.5, Vector2(hs, hs))
	heart_s = Vector3(hs, 1.2, hs)
	heart = box(Vector3(e.x, hy + 0.6, e.y), heart_s, BAD, level)
	# 용암 바다
	sea_y = hy + SEA
	box(Vector3(e.x * 0.5, sea_y - 0.5, e.y * 0.5), Vector3(300, 1, 300), A, level)
	# 시작 자리
	me_p = pts[0]
	me_y = 0.0
	yaw = 0.0
	cam_yaw = 0.0
	spin = 0.0
	knock = Vector2.ZERO
	up_k = 0.0
	lock_t = 0.0
	hit_cool = 0.0
	falling = false
	vy = 0.0
	step_d = 0.0
	var dist := 4.5 + slen * 0.45
	cam_p = Vector3(me_p.x, me_y + 3.0 + slen * 0.25, me_p.y + dist)
	msg("%d층" % (stage + 1), 1.2)


func _wall(r: Rect2, y: float) -> void:
	var pieces: Array[Rect2] = [r]
	for f in floors:
		pieces = _cut_all(pieces, f.r)
	for w in walls:
		pieces = _cut_all(pieces, w.r)
	for p in pieces:
		if p.size.x < 0.05 or p.size.y < 0.05:
			continue
		walls.append({"r": p, "y": y})
		box(Vector3(p.get_center().x, y + 0.5, p.get_center().y), Vector3(p.size.x, WALL_H + 1.2, p.size.y), B, level)


func _cut_all(pieces: Array[Rect2], c: Rect2) -> Array[Rect2]:
	var out: Array[Rect2] = []
	for p in pieces:
		out.append_array(_cut(p, c))
	return out


## 사각형 r 에서 c 와 겹치는 부분을 뺀 나머지(최대 4조각)
func _cut(r: Rect2, c: Rect2) -> Array[Rect2]:
	var i := r.intersection(c)
	if not i.has_area():
		return [r]
	var out: Array[Rect2] = []
	if i.position.x > r.position.x:
		out.append(Rect2(r.position, Vector2(i.position.x - r.position.x, r.size.y)))
	if i.end.x < r.end.x:
		out.append(Rect2(Vector2(i.end.x, r.position.y), Vector2(r.end.x - i.end.x, r.size.y)))
	if i.position.y > r.position.y:
		out.append(Rect2(Vector2(i.position.x, r.position.y), Vector2(i.size.x, i.position.y - r.position.y)))
	if i.end.y < r.end.y:
		out.append(Rect2(Vector2(i.position.x, i.end.y), Vector2(i.size.x, r.end.y - i.end.y)))
	return out


func _sword_len(l: float) -> void:
	blade.scale.z = l
	blade.position.z = -l * 0.5


## 점 아래 바닥 높이. 없으면 -1e9
func _floor_y(p: Vector2) -> float:
	var best := -1e9
	for f in floors:
		if f.r.has_point(p):
			best = maxf(best, f.y)
	return best


func _step(dt: float) -> void:
	clock += dt
	heart.scale = heart_s * (1.0 + 0.08 * sin(clock * 6.0))
	if die_t > 0.0:
		die_t -= dt
		me_y -= 4.0 * dt
		me.rotation.z += 5.0 * dt
		_place(dt)
		if die_t <= 0.0:
			end()
		return
	if clear_t > 0.0:
		clear_t -= dt
		_sword_len(lerpf(old_len, slen, clampf(1.0 - clear_t / GROW, 0.0, 1.0)))
		msg("칼이 자란다", 0.2)
		_place(dt)
		if clear_t <= 0.0:
			_cave()
		return
	# 칼 세우기: 세운 동안 아주 느리다
	if kit_just("up"):
		beep(500.0, 0.1, 900.0, 0.2)
	up_k = move_toward(up_k, 1.0 if kit_held("up") else 0.0, 6.0 * dt)
	# 방향: 스틱은 카메라 기준 가고 싶은 쪽. 긴 칼일수록 둔하다
	lock_t -= dt
	hit_cool -= dt
	var mv := kit_move
	var turn := 3.2 / (1.0 + 0.06 * slen)
	if lock_t <= 0.0 and mv.length() > 0.25:
		var target := cam_yaw + atan2(mv.x, -mv.y)
		var diff := wrapf(target - yaw, -PI, PI)
		yaw += clampf(diff, -turn * dt, turn * dt)
	yaw += spin * dt
	spin = move_toward(spin, 0.0, 8.0 * dt)
	var fwd := Vector2(sin(yaw), -cos(yaw))
	var fac := lerpf(1.0, 0.22, up_k)
	var sp := run * fac
	me_p += fwd * sp * dt + knock * dt
	knock = knock.move_toward(Vector2.ZERO, run * 2.5 * dt)
	if not falling:
		_body_out()
		if up_k < 0.5 and hit_cool <= 0.0:
			_sword_hit(fwd)
		var fy := _floor_y(me_p)
		if fy < -1e8:
			falling = true
			vy = 0.0
			msg("낭떠러지!", 1.0)
			beep(400.0, 0.5, 60.0, 0.3)
		else:
			me_y = maxf(fy, me_y - 9.0 * dt)
			if fy > me_y:
				me_y = fy
		for lr in lavas:
			if lr.grow(-0.15).has_point(me_p):
				_die("용암!")
				return
	if falling:
		vy -= 20.0 * dt
		me_y += vy * dt
		if me_y < sea_y + 0.3:
			_die("용암!")
			return
	# 심장 찌르기(칼이 누워 있을 때만)
	if up_k < 0.3 and not falling:
		var tip := me_p + fwd * slen
		if heart_r.grow(0.25).has_point(tip):
			_stab()
			return
	# 발소리: 빠를수록 높고 잦다
	step_d += sp * dt
	if step_d > 1.1:
		step_d = 0.0
		beep(120.0 + 25.0 * run, 0.03, 0.0, 0.14)
	gauge(sp / 14.0, B.lerp(BAD, clampf(sp / 12.0, 0.0, 1.0)))
	_place(dt)


## 몸, 칼 축, 카메라 자리
func _place(dt: float) -> void:
	var bob := 0.0 if falling or die_t > 0.0 else absf(sin(clock * 10.0)) * 0.08 * lerpf(1.0, 0.22, up_k)
	me.position = Vector3(me_p.x, me_y + bob, me_p.y)
	me.rotation.y = -yaw
	piv.rotation.x = up_k * 1.5
	cam_yaw = lerp_angle(cam_yaw, yaw, minf(1.0, dt * 4.0))
	var cf := Vector2(sin(cam_yaw), -cos(cam_yaw))
	var dist := 4.5 + slen * 0.45
	var want := Vector3(me_p.x - cf.x * dist, me_y + 3.0 + slen * 0.25, me_p.y - cf.y * dist)
	cam_p = cam_p.lerp(want, minf(1.0, dt * 6.0))
	cam.position = cam_p
	cam.look_at(Vector3(me_p.x + cf.x * 2.0, me_y + 0.8, me_p.y + cf.y * 2.0))
	cam.fov = minf(90.0, 62.0 + run * 1.5)


## 몸이 벽 안이면 가장 얕은 면으로 밀어낸다
func _body_out() -> void:
	for w in walls:
		var r: Rect2 = w.r.grow(RAD)
		if not r.has_point(me_p):
			continue
		var dl := me_p.x - r.position.x
		var dr := r.end.x - me_p.x
		var dn := me_p.y - r.position.y
		var ds := r.end.y - me_p.y
		var m := minf(minf(dl, dr), minf(dn, ds))
		if m == dl:
			me_p.x = r.position.x
		elif m == dr:
			me_p.x = r.end.x
		elif m == dn:
			me_p.y = r.position.y
		else:
			me_p.y = r.end.y


## 칼날 위 점이 벽에 들어가면 그 벽에서 먼 쪽으로 홱 돌고 밀려난다(잠깐 조종 불가)
func _sword_hit(fwd: Vector2) -> void:
	for k in range(1, 7):
		var q := me_p + fwd * slen * (float(k) / 6.0)
		for w in walls:
			var r: Rect2 = w.r
			if not r.has_point(q):
				continue
			var dl := q.x - r.position.x
			var dr := r.end.x - q.x
			var dn := q.y - r.position.y
			var ds := r.end.y - q.y
			var m := minf(minf(dl, dr), minf(dn, ds))
			var nrm := Vector2.ZERO
			if m == dl:
				nrm = Vector2(-1, 0)
			elif m == dr:
				nrm = Vector2(1, 0)
			elif m == dn:
				nrm = Vector2(0, -1)
			else:
				nrm = Vector2(0, 1)
			var crs := fwd.x * nrm.y - fwd.y * nrm.x
			var sgn := signf(crs) if absf(crs) > 0.08 else (1.0 if rng.randf() < 0.5 else -1.0)
			spin = sgn * (2.5 + run * 0.35 + slen * 0.25)
			knock = nrm * (run * 0.9 + slen * 0.3)
			me_p += nrm * 0.3
			lock_t = 0.45
			hit_cool = 0.3
			beep(1000.0, 0.12, 250.0, 0.3)
			msg("쾅!", 0.5)
			return


func _stab() -> void:
	play("win")
	msg("심장!", 1.0)
	stage += 1
	score = stage
	old_len = slen
	slen *= 1.5
	run *= 1.22
	spin = 0.0
	knock = Vector2.ZERO
	clear_t = GROW


func _die(s: String) -> void:
	if die_t > 0.0:
		return
	die_t = 1.0
	play("bad")
	msg(s, 1.0)
