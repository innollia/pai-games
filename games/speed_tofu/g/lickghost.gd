extends Tofu
## 귀신 핥기(등뒤 3인칭): 조이스틱으로 걸으며 혀로 허공을 맛본다(위로 많이 밀수록 빠름, 옆은 돌기). 안 보이는 귀신이 떠다닌다. 빠르면 넓게 훑지만 맛 막대가 흔들리고 노랗게 흐려진다. 느리면 맛이 또렷하다(초록=수박, 빨강=고추). 그동안 귀신은 떠내려가고 시간은 샌다. 맛이 진할 때 핥기. 수박은 시간+, 고추는 물림. 시간이 다 되거나 세 번 물리면 끝. 수박밭 → 겁쟁이(빨리 다가가면 도망) → 가짜 냄새 → 섞인 맛(고추가 수박 곁을 돈다).

const RX := 11.0  # 방 반 너비
const MAXS := 8.0
const TURN := 2.6
const SENSE_R := 6.5
const REACH := 2.8
const CATCH_R := 1.5
const LICK_T := 0.25
const NW := 4  # 수박 귀신 칸
const NS := 3  # 고추 귀신 칸
const ND := 3  # 가짜 냄새 칸
const STAGE_NAME := ["수박밭", "겁쟁이 귀신", "가짜 냄새", "섞인 맛"]
const NEED := [3, 3, 4, 4]
const PILLARS := [Vector2(-5, -5), Vector2(5, -5), Vector2(-5, 5), Vector2(5, 5)]

var stage := 0
var got := 0  # 이번 방에서 잡은 수박
var hp := 3
var clock := 0.0
var rng := RandomNumberGenerator.new()
# 나
var me: Node3D
var tongue: MeshInstance3D
var hearts: Array[MeshInstance3D] = []
var me_p := Vector2.ZERO
var yaw := 0.0
var spd := 0.0
var lick_t := 0.0
var cool := 0.0
var sig := 0.0  # 보이는 맛 세기
var flav := 0.5  # 0 수박 .. 1 고추, 0.5 모름
var tone_t := 0.0
var step_d := 0.0
var cam_p := Vector3.ZERO
var tg_col := ""
# 귀신: kind 0 수박, 1 고추, 2 가짜 냄새
var gk := PackedInt32Array()
var gon: Array[bool] = []
var gp := PackedVector2Array()
var gv := PackedVector2Array()
var gfast := PackedFloat32Array()
var gflee := PackedFloat32Array()
var gpar := PackedInt32Array()  # 섞인 맛: 곁을 도는 수박 번호
var gang := PackedFloat32Array()
var gshow := PackedFloat32Array()  # 드러난 채 남은 시간
var gmesh: Array[Node3D] = []


func _setup() -> void:
	time_limit = 45.0
	howto = "왼쪽 조이스틱: 위로 밀면 걷기(많이 밀수록 빠름), 옆으로 돌기.\n안 보이는 귀신을 혀로 맛봐 찾는다. 빠르면 맛이 흐리고, 느리면 또렷하지만 시간이 샌다.\n막대가 초록(수박)으로 차오를 때 핥기! 빨강(고추)을 핥으면 물린다.\n시간이 다 되거나 세 번 물리면 끝."
	kit_stick()
	kit_button("lick", "핥기", Vector2(560, 1060), 115.0, BAD)


func _reset() -> void:
	rng.randomize()
	stage = 0
	got = 0
	hp = 3
	clock = 0.0
	me_p = Vector2(0, 8)
	yaw = 0.0
	spd = 0.0
	lick_t = 0.0
	cool = 0.0
	sig = 0.0
	flav = 0.5
	tone_t = 0.0
	step_d = 0.0
	tg_col = ""
	# 바둑판 바닥(속도가 보이게), 벽, 기둥
	var n := 8
	var w := RX * 2.0 / n
	for i in n:
		for j in n:
			box(Vector3(-RX + w * (i + 0.5), -0.1, -RX + w * (j + 0.5)), Vector3(w, 0.2, w), SOFT if (i + j) % 2 == 0 else WHITE)
	box(Vector3(0, 0.6, -RX - 0.3), Vector3(RX * 2.0 + 1.2, 1.2, 0.6), B)
	box(Vector3(0, 0.6, RX + 0.3), Vector3(RX * 2.0 + 1.2, 1.2, 0.6), B)
	box(Vector3(-RX - 0.3, 0.6, 0), Vector3(0.6, 1.2, RX * 2.0), B)
	box(Vector3(RX + 0.3, 0.6, 0), Vector3(0.6, 1.2, RX * 2.0), B)
	for p: Vector2 in PILLARS:
		box(Vector3(p.x, 1.2, p.y), Vector3(1.4, 2.4, 1.4), D)
	# 나: 몸, 머리, 눈, 긴 혀, 머리 위 목숨 3
	me = Node3D.new()
	world.add_child(me)
	box(Vector3(0, 0.45, 0), Vector3(0.9, 0.9, 0.7), ME, me)
	box(Vector3(0, 1.2, 0), Vector3(0.75, 0.6, 0.7), ME, me)
	box(Vector3(-0.18, 1.32, -0.36), Vector3(0.14, 0.14, 0.04), WHITE, me)
	box(Vector3(0.18, 1.32, -0.36), Vector3(0.14, 0.14, 0.04), WHITE, me)
	tongue = box(Vector3(0, 1.05, -0.6), Vector3(0.26, 0.08, 0.5), A, me)
	hearts.clear()
	for i in 3:
		hearts.append(box(Vector3(-0.32 + 0.32 * i, 1.75, 0), Vector3(0.2, 0.2, 0.2), BAD, me))
	# 귀신 칸(판 시작 때 만들고 돌려 쓴다). 보일 때는 잡히거나 물거나 끝났을 때뿐.
	var total := NW + NS + ND
	gk.resize(total)
	gon.resize(total)
	gp.resize(total)
	gv.resize(total)
	gfast.resize(total)
	gflee.resize(total)
	gpar.resize(total)
	gang.resize(total)
	gshow.resize(total)
	gmesh.clear()
	for i in total:
		var k := 0 if i < NW else (1 if i < NW + NS else 2)
		gk[i] = k
		gon[i] = false
		var piv := Node3D.new()
		world.add_child(piv)
		if k == 0:
			box(Vector3.ZERO, Vector3(1.0, 0.9, 1.0), GOOD, piv)
			box(Vector3(0, 0.45, 0), Vector3(0.9, 0.12, 0.9), BAD, piv)
			box(Vector3(-0.2, 0.1, -0.51), Vector3(0.14, 0.18, 0.04), WHITE, piv)
			box(Vector3(0.2, 0.1, -0.51), Vector3(0.14, 0.18, 0.04), WHITE, piv)
		elif k == 1:
			box(Vector3.ZERO, Vector3(0.6, 1.2, 0.6), BAD, piv)
			box(Vector3(0, 0.7, 0), Vector3(0.2, 0.25, 0.2), GOOD, piv)
			box(Vector3(-0.13, 0.25, -0.31), Vector3(0.12, 0.08, 0.04), INK, piv)
			box(Vector3(0.13, 0.25, -0.31), Vector3(0.12, 0.08, 0.04), INK, piv)
		else:
			box(Vector3(0, 0.05, 0), Vector3(1.4, 0.1, 1.4), A, piv)
		piv.visible = false
		gmesh.append(piv)
	_room()
	var fwd := Vector2(sin(yaw), -cos(yaw))
	cam_p = Vector3(me_p.x - fwd.x * 5.0, 4.0, me_p.y - fwd.y * 5.0)


## 방 하나 시작: 단계마다 귀신 구성과 규칙이 바뀐다
func _room() -> void:
	var s := mini(stage, 3)
	var extra := 1.0 + 0.12 * maxi(stage - 3, 0)
	var nw: int = [2, 2, 2, 3][s]
	var ns: int = [1, 2, 2, 3][s]
	var nd: int = [0, 0, 3, 1][s]
	for i in gk.size():
		gon[i] = false
		gshow[i] = 0.0
		gmesh[i].visible = false
	for i in nw:
		_spawn(i)
		gfast[i] = (2.3 if s == 2 else 0.8) * extra
	for j in ns:
		var i := NW + j
		_spawn(i)
		gfast[i] = 0.9 * extra
		gpar[i] = (j % nw) if s == 3 else -1
	for j in nd:
		var i := NW + NS + j
		_spawn(i)
		gfast[i] = 0.0
	got = 0
	msg("%d %s" % [stage + 1, STAGE_NAME[s]], 1.6)


func _spawn(i: int) -> void:
	gon[i] = true
	gflee[i] = 0.0
	gpar[i] = gpar[i] if gk[i] == 1 else -1
	gang[i] = rng.randf() * TAU
	var p := Vector2.ZERO
	for tries in 20:
		p = Vector2(rng.randf_range(-RX + 1.5, RX - 1.5), rng.randf_range(-RX + 1.5, RX - 1.5))
		if p.distance_to(me_p) > 7.0:
			break
	gp[i] = p
	gv[i] = Vector2.from_angle(rng.randf() * TAU)


func _step(dt: float) -> void:
	clock += dt
	cool -= dt
	var s := mini(stage, 3)
	var extra := 1.0 + 0.12 * maxi(stage - 3, 0)
	# 걷기: 옆은 돌기, 위는 빠르기
	var mv := kit_move
	yaw += mv.x * TURN * dt
	var want := clampf(-mv.y, -0.35, 1.0) * MAXS
	spd = move_toward(spd, want, 30.0 * dt)
	var fwd := Vector2(sin(yaw), -cos(yaw))
	me_p += fwd * spd * dt
	me_p = me_p.clamp(Vector2(-RX + 0.6, -RX + 0.6), Vector2(RX - 0.6, RX - 0.6))
	for p: Vector2 in PILLARS:
		var d := me_p - p
		if d.length() < 1.25:
			me_p = p + (d.normalized() if d.length() > 0.01 else Vector2.RIGHT) * 1.25
	var sf := absf(spd) / MAXS
	step_d += absf(spd) * dt
	if step_d > 1.3:
		step_d = 0.0
		beep(160.0 + 120.0 * sf, 0.03, 0.0, 0.12)
	# 귀신 떠다니기
	for i in gk.size():
		if not gon[i] or gk[i] == 2:
			continue
		if gk[i] == 1 and gpar[i] >= 0:
			gang[i] += 1.6 * extra * dt
			gp[i] = gp[gpar[i]] + Vector2.from_angle(gang[i]) * 1.7
			continue
		if gk[i] == 0 and (s == 1 or s == 3) and gflee[i] <= 0.0 and sf > 0.55 and gp[i].distance_to(me_p) < 5.0:
			gflee[i] = 1.2
			gv[i] = (gp[i] - me_p).normalized()
			beep(1000.0, 0.18, 400.0, 0.2)
			msg("도망!", 0.5)
		var v := gv[i].rotated(rng.randf_range(-1.5, 1.5) * dt)
		var sp := gfast[i]
		if gflee[i] > 0.0:
			gflee[i] -= dt
			sp = 6.0
		var p := gp[i] + v * sp * dt
		var lim := RX - 1.0
		if absf(p.x) > lim:
			v.x = -v.x
			p.x = clampf(p.x, -lim, lim)
		if absf(p.y) > lim:
			v.y = -v.y
			p.y = clampf(p.y, -lim, lim)
		gv[i] = v
		gp[i] = p
	# 드러난 귀신은 잠깐 떠오르다 사라진다
	for i in gk.size():
		if gshow[i] > 0.0:
			gshow[i] -= dt
			gmesh[i].position.y += dt * 1.5
			gmesh[i].rotation.y += dt * 4.0
			if gshow[i] <= 0.0:
				gmesh[i].visible = false
	# 맛보기: 혀끝 근처 맛. 빠를수록 약하고 흔들리고 무슨 맛인지 흐려진다
	var tip := me_p + fwd * 1.2
	var w_sum := 0.0
	var s_sum := 0.0
	for i in gk.size():
		if not gon[i]:
			continue
		var r := SENSE_R if gk[i] != 2 else 4.5
		var k := clampf(1.0 - tip.distance_to(gp[i]) / r, 0.0, 1.0)
		k *= k
		if gk[i] == 1:
			s_sum += k
		else:
			w_sum += k
	var raw := clampf(w_sum + s_sum, 0.0, 1.0)
	var aim := raw * (1.0 - 0.6 * sf) + rng.randf_range(-0.4, 0.4) * sf
	sig = lerpf(sig, clampf(aim, 0.0, 1.0), minf(1.0, dt * 8.0))
	var f_true := s_sum / (w_sum + s_sum) if w_sum + s_sum > 0.001 else 0.5
	var clear := clampf(1.0 - sf * 1.6, 0.0, 1.0)
	flav = lerpf(flav, lerpf(0.5, f_true, clear), minf(1.0, dt * 6.0))
	var side := GOOD if flav < 0.5 else BAD
	gauge(sig, D.lerp(side, absf(flav - 0.5) * 2.0))
	var want_col := A
	if sig > 0.3 and absf(flav - 0.5) > 0.3:
		want_col = side
	if want_col.to_html() != tg_col:
		tg_col = want_col.to_html()
		tongue.material_override = mat(want_col)
	# 맛 소리: 진할수록 높고 잦다, 빠르면 음이 흔들린다
	tone_t -= dt
	if sig > 0.06 and tone_t <= 0.0:
		tone_t = lerpf(0.55, 0.07, sig)
		beep(snappedf(300.0 + 1000.0 * sig + rng.randf_range(-250.0, 250.0) * sf, 40.0), 0.05, 0.0, 0.14)
	# 핥기
	if kit_just("lick") and cool <= 0.0:
		_lick(fwd)
		if over:
			return
	lick_t = maxf(lick_t - dt, 0.0)
	var idle := 0.35 + sig * 0.4 + sin(clock * 9.0) * 0.05
	var ext := sin(PI * (1.0 - lick_t / LICK_T)) if lick_t > 0.0 else 0.0
	var tl := lerpf(idle, REACH, ext)
	tongue.scale.z = tl
	tongue.position.z = -0.35 - tl * 0.5
	# 내 몸, 카메라
	me.position = Vector3(me_p.x, absf(sin(clock * 12.0)) * 0.12 * sf, me_p.y)
	me.rotation.y = -yaw
	var want_c := Vector3(me_p.x - fwd.x * (5.0 + sf * 1.5), 4.0, me_p.y - fwd.y * (5.0 + sf * 1.5))
	cam_p = cam_p.lerp(want_c, minf(1.0, dt * 6.0))
	cam.position = cam_p
	cam.look_at(Vector3(me_p.x + fwd.x * 3.0, 0.8, me_p.y + fwd.y * 3.0))
	cam.fov = 62.0 + 16.0 * sf
	# 시간이 거의 끝나면 숨어 있던 귀신을 다 보여 준다
	if t < dt * 2.0:
		_reveal_all()
		play("bad")


func _lick(fwd: Vector2) -> void:
	lick_t = LICK_T
	cool = 0.55
	beep(700.0, 0.06, 1100.0, 0.18)
	var a := me_p + fwd * 0.4
	var b := me_p + fwd * REACH
	var hit := -1
	var near := CATCH_R
	for i in gk.size():
		if not gon[i]:
			continue
		var d := _seg(gp[i], a, b)
		if d < near:
			near = d
			hit = i
	if hit < 0:
		msg("허공", 0.4)
		beep(200.0, 0.08, 0.0, 0.15)
		return
	var old := gp[hit]
	match gk[hit]:
		0:
			score += 1
			got += 1
			t += 5.0
			play("good")
			msg("수박맛!", 0.6)
			_spawn(hit)
			if got >= NEED[mini(stage, 3)]:
				stage += 1
				t += 12.0
				play("win")
				_room()
			_reveal(hit, old, 1.0)
		1:
			hp -= 1
			hearts[hp].visible = false
			play("bad")
			msg("물렸다!", 0.7)
			_spawn(hit)
			_reveal(hit, old, 1.0)
			me_p -= fwd * 1.5
			spd = 0.0
			if hp <= 0:
				_reveal_all()
				end()
		2:
			msg("냄새만", 0.6)
			beep(330.0, 0.15, 250.0, 0.2)
			gon[hit] = false
			_reveal(hit, old, 0.8)


func _reveal(i: int, p: Vector2, dur: float) -> void:
	gmesh[i].position = Vector3(p.x, 0.0 if gk[i] == 2 else 1.2, p.y)
	gmesh[i].visible = true
	gshow[i] = dur


func _reveal_all() -> void:
	for i in gk.size():
		if gon[i]:
			_reveal(i, gp[i], 99.0)


func _seg(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var k := clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	return p.distance_to(a + ab * k)
