extends Tofu
## 그가 온다 × 굴러라 신전석. 3인칭 등뒤 밤 내리막. 돌 위에 올라타 굴러 내려간다: 조이스틱 좌우 = 방향(빠를수록·무거울수록 안 돈다), 위로 밀기 = 밀어 가속(느릴 때만), 세워 버튼 = 발로 버티기(느려진다). 그가 뒤에서 뛰어온다(보이지 않는다, 발소리와 막대로 안다).
## 길가 선반에 걸린 돌을 지나면 줄이 길에 깔린다. 줄 위에서 놓아 버튼: 걸린 돌이 떨어져 길을 따라 굴러 내려온다. 그가 그 돌 아래쪽에 있으면 맞고 비틀거린다(그가 돌 아래로 지나갈 때 "삑"). 돌은 계속 굴러와 나도 깔 수 있다 — 빠르거나 옆으로 피해야 한다.
## 항아리·집을 깔면 무거워진다(내리막에 빠르고, 덜 돌고, 덜 선다). 가장자리 밖 = 추락. 잡히면 자동전투: 빠른 쪽이 먼저, 속도 스탯 = 모은 무게. 지면 죽음. 구간 3개: 가파르고 좁아지고 그가 빨라진다.

const G := 40.0
const ROLL := 0.4
const DRAG := 0.004
const BRAKE := 16.0
const PUSH := 7.0
const FAR := 42.0
const ROPE := 32.0
const CATCH := 1.8
const VMAX := 40.0
const STONE := Color("efe1c4")
const ROCK := Color("e0c896")
const NIGHT := Color("b9c6e0")
const GATES := [300.0, 620.0, 960.0]
const HV := [15.0, 19.0, 24.0]  # 구간별 그의 속도
# 길: [거리, 높이, 반폭]
const K := [
	[0.0, 80.0, 8.0], [40.0, 80.0, 8.0], [140.0, 55.0, 7.0], [200.0, 50.0, 6.0], [300.0, 34.0, 7.0],
	[340.0, 34.0, 6.0], [430.0, 10.0, 5.0], [500.0, 8.0, 4.0], [620.0, -14.0, 6.0],
	[650.0, -14.0, 5.0], [720.0, -18.0, 5.0], [810.0, -48.0, 4.0], [870.0, -52.0, 3.5], [960.0, -78.0, 6.0], [1010.0, -78.0, 6.0],
]
# 깔 것: 크기, 깔 수 있는 무게, 점수, 느는 무게, 깔 때 속도가 줄어드는 정도
const KIND := {
	"pot": {"size": Vector3(1.4, 1.4, 1.4), "need": 0.0, "pts": 1, "grow": 0.12, "mass": 0.06, "col": [A, D]},
	"house": {"size": Vector3(4.0, 3.4, 4.0), "need": 1.8, "pts": 6, "grow": 0.5, "mass": 0.35, "col": [B, C]},
	"pillar": {"size": Vector3(2.0, 9.0, 2.0), "need": 99.0, "pts": 0, "grow": 0.0, "mass": 0.0, "col": [WHITE]},
}
# [종류, 거리, 가운데서 옆으로]
const PUT := [
	["pot", 60, -2.0], ["pot", 75, 2.5], ["pot", 95, 0.0], ["pillar", 110, 3.0], ["pot", 125, -3.0], ["pot", 150, 1.0],
	["pillar", 165, -2.5], ["pot", 185, 2.0], ["pot", 215, -1.5], ["pot", 235, 2.5], ["pillar", 260, 0.0], ["pot", 280, -3.0],
	["pot", 320, 0.0], ["pot", 355, -2.5], ["house", 380, 2.0], ["pillar", 400, -2.0], ["pot", 420, 1.5], ["house", 450, -2.0],
	["pot", 475, 2.0], ["pillar", 490, 0.0], ["pot", 520, -1.5], ["house", 545, 1.5], ["pot", 580, -2.0], ["pot", 600, 2.0],
	["pot", 640, 0.0], ["house", 670, -2.0], ["pillar", 700, 2.0], ["pot", 735, -2.0], ["house", 770, 1.5], ["pillar", 795, -1.5],
	["pot", 825, 1.5], ["house", 850, -1.5], ["pillar", 885, 0.0], ["pot", 915, -2.5], ["pot", 935, 2.5], ["house", 985, 0.0],
]
# 걸린 돌: [거리, 길 어느 쪽(-1 왼 1 오른)]
const LEDGE := [
	[70.0, -1.0], [120.0, 1.0], [175.0, -1.0], [250.0, 1.0],
	[360.0, -1.0], [410.0, 1.0], [470.0, -1.0], [560.0, 1.0],
	[680.0, 1.0], [760.0, -1.0], [830.0, 1.0], [900.0, -1.0],
]


class Thing:
	var n: MeshInstance3D
	var kd: Dictionary
	var d := 0.0
	var x := 0.0
	var base := 0.0
	var flat := false


class Rock:
	var n: MeshInstance3D
	var d := 0.0
	var x := 0.0
	var v := 0.0
	var side := 1.0
	var state := 0  # 0 선반에 걸림, 1 굴러감, 2 사라짐
	var passed := false  # 그가 이 돌 아래로 지나갔다
	var hit := false


var ball: MeshInstance3D
var rider: MeshInstance3D
var him: Node3D
var things: Array[Thing] = []
var rocks: Array[Rock] = []
var dist := 0.0
var v := 0.0
var xpos := 0.0
var by := 0.0
var mass := 1.0
var crushed := 0
var hd := 0.0  # 그의 거리
var hx := 0.0
var stagger := 0.0
var sec := 0
var won := false
var bonus := 0
var fallen := false
var fall_t := 0.0
var hurt := 0.0
var ang := 0.0
var quarter := 0
var roll_t := 0.0
var brake_t := 0.0
var thump := 0.0
var bob := 0.0
var cam_y := 0.0
# 자동전투
var fight := false
var fseq: Array = []
var fi := 0
var ft := 0.0
var fres := 0
var hp := 10
var h_hp := 0
var fhp_me := 0
var fhp_him := 0
var bme: MeshInstance3D
var bhim: MeshInstance3D


func _setup() -> void:
	howto = "밤 내리막. 돌 위에 올라타 굴러 내려간다. 조이스틱 좌우로 방향(빠르고 무거울수록 안 돈다), 위로 밀면 밀어 가속, 세워 버튼은 발로 버티기.\n그가 뒤에서 뛰어온다. 길가에 걸린 돌을 지나면 줄이 깔린다 — 줄 위에서 놓아 버튼을 누르면 그 돌이 길로 굴러 내려온다. 그가 맞으면 비틀거리고, 내가 맞으면 깔려 죽는다.\n항아리·집을 깔면 무거워진다. 가장자리 밖은 추락. 잡히면 자동전투(속도 = 모은 무게). 바닥 문까지 구간 3개."
	time_limit = 0.0
	kit_stick()
	kit_button("brake", "세워", Vector2(590, 1090), 105.0, GOOD)
	kit_button("drop", "놓아", Vector2(590, 860), 85.0, A)
	bme = box(Vector3(-0.7, -0.15, -2.4), Vector3(0.6, 0.9, 0.6), ME, cam)
	bhim = box(Vector3(0.7, 0.0, -2.4), Vector3(0.7, 1.3, 0.7), INK, cam)
	bme.visible = false
	bhim.visible = false


func _reset() -> void:
	dist = 0.0
	v = 0.0
	xpos = 0.0
	by = _h(0.0)
	mass = 1.0
	crushed = 0
	hd = -FAR
	hx = 0.0
	stagger = 0.0
	sec = 0
	won = false
	bonus = 0
	fallen = false
	fall_t = 0.0
	hurt = 0.0
	ang = 0.0
	quarter = 0
	brake_t = 0.0
	thump = 0.0
	bob = 0.0
	fight = false
	cam_y = by
	ball = box(Vector3(0, by + 0.8, 0), Vector3.ONE * 1.6, STONE)
	box(Vector3.ZERO, Vector3(1.04, 1.04, 0.2), ROCK, ball)
	rider = box(Vector3(0, by + 2.1, 0), Vector3(0.5, 0.9, 0.5), ME)
	him = Node3D.new()
	world.add_child(him)
	box(Vector3(0, 1.4, 0), Vector3(1.2, 2.8, 1.2), INK, him)
	box(Vector3(0, 3.1, 0), Vector3(0.7, 0.6, 0.7), BAD, him)
	_build()
	cam.position = Vector3(0, by + 6.0, 10.0)
	cam.fov = 60.0
	msg("밀어라", 1.5)


# ---- 길 ----
func _seg(d: float) -> int:
	for i in range(K.size() - 2, -1, -1):
		if d >= K[i][0]:
			return i
	return 0


func _h(d: float) -> float:
	var i := _seg(d)
	var a: Array = K[i]
	var b: Array = K[i + 1]
	return lerpf(a[1], b[1], clampf((d - a[0]) / (b[0] - a[0]), 0.0, 1.0))


func _slope(d: float) -> float:
	var i := _seg(d)
	return (K[i + 1][1] - K[i][1]) / (K[i + 1][0] - K[i][0])


func _hw(d: float) -> float:
	return K[_seg(d)][2]


## p0 -> p1 로 누운 상자
func _beam(p0: Vector3, p1: Vector3, w: float, th: float, col: Color) -> MeshInstance3D:
	var dir := p1 - p0
	var m := box(Vector3.ZERO, Vector3.ONE, col)
	m.basis = Basis.looking_at(dir.normalized(), Vector3.UP)
	m.scale = Vector3(w, th, dir.length() + 0.3)
	m.position = (p0 + p1) * 0.5
	return m


func _build() -> void:
	for i in K.size() - 1:
		var d0: float = K[i][0]
		var d1: float = K[i + 1][0]
		var half: float = K[i][2]
		var p0 := Vector3(0, K[i][1], -d0)
		var p1 := Vector3(0, K[i + 1][1], -d1)
		var up := Basis.looking_at((p1 - p0).normalized(), Vector3.UP).y
		var col := STONE if i < 4 else (ROCK if i < 8 else NIGHT)
		_beam(p0 - up * 2.5, p1 - up * 2.5, half * 2.0, 5.0, col)
		for sd: float in [-1.0, 1.0]:
			_beam(p0 + Vector3(sd * (half - 0.2), 0.04, 0), p1 + Vector3(sd * (half - 0.2), 0.04, 0), 0.4, 0.1, WHITE)
	# 아래 바닥
	box(Vector3(0, -110, -500), Vector3(600, 1, 1300), Color("5c7cfa"))
	# 옆 풍경 (같은 판이면 같은 모양)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var d := 10.0
	while d < 1000.0:
		for sd: float in [-1.0, 1.0]:
			var x := sd * (_hw(d) + rng.randf_range(8.0, 30.0))
			var sw := rng.randf_range(5.0, 12.0)
			var top := _h(d) + rng.randf_range(-10.0, 24.0)
			box(Vector3(x, (top - 110.0) * 0.5, -d), Vector3(sw, top + 110.0, sw), [ROCK, STONE, NIGHT].pick_random())
		d += rng.randf_range(24.0, 36.0)
	# 구간 문
	for g in GATES:
		var gh := _h(g)
		var col := GOOD if g == GATES[2] else D
		for sd: float in [-1.0, 1.0]:
			box(Vector3(sd * (_hw(g) + 1.5), gh + 5.0, -g), Vector3(1.4, 10, 1.4), col)
		box(Vector3(0, gh + 10.0, -g), Vector3(_hw(g) * 2.0 + 4.4, 1.6, 1.6), col)
	# 깔 것
	things.clear()
	for p in PUT:
		var th := Thing.new()
		th.kd = KIND[p[0]]
		th.d = float(p[1])
		th.x = float(p[2])
		th.base = _h(th.d)
		var sz: Vector3 = th.kd.size
		th.n = box(Vector3(th.x, th.base + sz.y * 0.5, -th.d), sz, (th.kd.col as Array).pick_random())
		if p[0] == "house":
			box(Vector3(0, 0.6, 0), Vector3(1.15, 0.25, 1.15), BAD, th.n)
		things.append(th)
	# 걸린 돌: 선반 + 돌 + 길에 깔린 줄
	rocks.clear()
	for l in LEDGE:
		var r := Rock.new()
		r.d = l[0]
		r.side = l[1]
		var h := _h(r.d)
		var sx: float = r.side * (_hw(r.d) + 2.4)
		box(Vector3(sx, h + 2.6, -r.d), Vector3(3.2, 0.5, 3.2), ROCK)
		r.n = box(Vector3(sx, h + 4.05, -r.d), Vector3.ONE * 2.4, STONE)
		_beam(Vector3(r.side * (_hw(r.d) - 0.9), h + 0.1, -r.d), Vector3(r.side * (_hw(r.d + ROPE) - 0.9), _h(r.d + ROPE) + 0.1, -(r.d + ROPE)), 0.25, 0.12, A)
		rocks.append(r)


# ---- 판 ----
func _step(dt: float) -> void:
	bob += dt
	hurt -= dt
	if fight:
		_fight_step(dt)
		_place(dt)
		return
	if fallen:
		fall_t += dt
		by -= 30.0 * fall_t * dt
		if fall_t > 1.0:
			end()
		_place(dt)
		return
	# 속도: 비탈·무게·버티기·밀기
	var sl := _slope(dist)
	var rt := sqrt(mass)
	var acc := -sl * G * (0.55 + 0.45 * rt) - ROLL - DRAG * v * v / mass
	if kit_held("brake") and v > 0.0:
		acc -= BRAKE / rt
		brake_t -= dt
		if brake_t <= 0.0:
			brake_t = 0.18
			beep(clampf(200.0 + v * 6.0, 200.0, 500.0), 0.1, 120.0, 0.18)
	if kit_move.y < -0.4 and v < 10.0:
		acc += PUSH
	v = clampf(v + acc * dt, 0.0, VMAX)
	dist += v * dt
	# 방향: 빠를수록·무거울수록 안 돈다
	xpos += kit_move.x * 10.0 / (1.0 + v / 14.0) / rt * dt
	if absf(xpos) > _hw(dist) + 0.4:
		_die("떨어졌다")
		return
	var g := _h(dist)
	by = g
	# 깔기 / 부딪힘
	var bs := _bs()
	for th in things:
		if th.flat or absf(th.d - dist) > 10.0:
			continue
		var sz: Vector3 = th.kd.size
		if absf(th.d - dist) < (bs + sz.z) * 0.5 and absf(th.x - xpos) < (bs + sz.x) * 0.45:
			if mass >= float(th.kd.need):
				_crush(th)
			elif hurt <= 0.0:
				v *= 0.3
				dist = minf(dist, th.d - (bs + sz.z) * 0.5 - 0.2)
				hurt = 0.5
				play("bad")
				msg("쿵!", 0.6)
	# 그: 길을 따라 나를 쫓는다
	if stagger > 0.0:
		stagger -= dt
	else:
		# 그는 내 속도에 맞춰 달린다: 멀면 더 빨리, 가까우면 내 속도 근처. 내가 느려지는 순간(세우기·쿵·평지)만 가까워진다
		hd += maxf(HV[sec], v + (dist - hd - 20.0) * 0.15) * dt
	hx = move_toward(hx, xpos, 6.0 * dt)
	var gap := dist - hd
	thump -= dt
	if thump <= 0.0:
		thump = 0.7 if stagger > 0.0 else clampf(0.2 + gap * 0.012, 0.2, 0.7)
		beep(60.0, 0.1, 0.0, clampf(0.36 - gap * 0.007, 0.06, 0.36))
	# 걸린 돌: 그가 아래로 지나가면 삑, 놓으면 굴러 내려온다
	for r in rocks:
		if r.state == 0:
			if not r.passed and hd > r.d:
				r.passed = true
				if dist - r.d < ROPE:
					beep(1100.0, 0.1, 1500.0, 0.25)
					msg("돌 아래!", 0.6)
		elif r.state == 1:
			r.v += (-_slope(r.d) * G * 0.95 - ROLL - DRAG * r.v * r.v / 2.0) * dt
			r.d += r.v * dt
			r.n.position = Vector3(r.x, _h(r.d) + 1.2, -r.d)
			r.n.rotation.x -= r.v * dt / 1.2
			if not r.hit and absf(r.d - hd) < 2.2 and absf(r.x - hx) < 2.2:
				r.hit = true
				stagger = 2.5
				hd -= 3.0
				beep(120.0, 0.3, 50.0, 0.4)
				msg("맞았다!", 1.0)
				bonus += 30
			if absf(r.d - dist) < (bs + 2.4) * 0.5 and absf(r.x - xpos) < (bs + 2.4) * 0.45:
				_die("깔렸다")
				return
			if r.d > dist + 60.0 or r.d > K[K.size() - 1][0]:
				r.state = 2
				r.n.visible = false
	if kit_just("drop"):
		_drop()
	# 구간 문
	if dist >= GATES[sec]:
		sec += 1
		if sec >= GATES.size():
			won = true
			bonus += 500
			msg("바닥 도착!", 2.0)
			end()
			return
		bonus += 100
		hd = dist - FAR * 0.8
		stagger = 0.0
		msg("구간 %d" % (sec + 1), 1.5)
		play("good")
	if gap < CATCH:
		_start_fight()
		return
	score = int(dist) + bonus
	gauge(clampf(1.0 - gap / FAR, 0.0, 1.0), BAD if gap < 12.0 else D)
	_place(dt)


func _bs() -> float:
	return 1.6 + 0.5 * (mass - 1.0)


func _crush(th: Thing) -> void:
	th.flat = true
	th.n.scale.y = 0.15
	th.n.position.y = th.base + 0.08
	v *= mass / (mass + float(th.kd.mass))
	var before := floori(mass)
	mass = minf(6.0, mass + float(th.kd.grow))
	crushed += 1
	bonus += int(th.kd.pts) * 5
	beep(maxf(120.0, 560.0 - float(th.kd.mass) * 900.0), 0.1, 110.0, 0.28)
	if floori(mass) > before:
		msg("무거워졌다", 0.7)
		play("good")


## 놓아: 내가 줄 위에 있는 걸린 돌 중 가장 가까운 것을 떨어뜨린다
func _drop() -> void:
	var pick: Rock = null
	for r in rocks:
		if r.state == 0 and r.d <= dist and dist - r.d < ROPE:
			if pick == null or r.d > pick.d:
				pick = r
	if pick == null:
		beep(300.0, 0.05, 0.0, 0.12)
		msg("줄 없음", 0.5)
		return
	pick.state = 1
	pick.v = maxf(16.0, v + 10.0)  # 떨어지며 속도가 붙는다: 내 뒤의 그를 따라잡고, 곧 나까지 따라잡는다
	pick.x = pick.side * _hw(pick.d) * 0.5
	beep(90.0, 0.35, 40.0, 0.4)
	msg("굴러온다!", 0.8)


func _die(text: String) -> void:
	fallen = true
	fall_t = 0.0
	msg(text, 2.0)
	beep(400.0, 0.6, 60.0, 0.3)


func _place(dt: float) -> void:
	var bs := _bs()
	ball.scale = Vector3.ONE * bs
	ang += v * dt * PI / (2.0 * bs)
	var m := fposmod(ang, PI * 0.5)
	var top := by + bs * 0.5 * (cos(m) + sin(m))
	ball.position = Vector3(xpos, top, -dist)
	ball.rotation.x = -ang
	ball.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else STONE)
	rider.position = Vector3(xpos, top + bs * 0.5 + 0.45, -dist)
	rider.rotation.z = -kit_move.x * 0.3
	var q := floori(ang / (PI * 0.5))
	roll_t -= dt
	if q != quarter:
		quarter = q
		if roll_t <= 0.0 and not fallen:
			roll_t = 0.07
			beep(clampf(60.0 + v * 2.0 - mass * 6.0, 50.0, 200.0), 0.05, 45.0, 0.12)
	him.position = Vector3(hx, _h(hd) + (absf(sin(bob * 14.0)) * 0.35 if stagger <= 0.0 else -0.9), -hd)
	him.rotation.z = 0.9 if stagger > 0.0 else 0.0
	# 카메라: 뒤 위, 빠를수록 넓게
	if not fallen:
		cam_y = lerpf(cam_y, by, minf(1.0, dt * 6.0))
	var ahead := dist + 14.0 + v * 0.15
	var want := Vector3(xpos * 0.6, cam_y + 4.5 + bs * 0.8, -dist + 9.0 + bs)
	cam.position = cam.position.lerp(want, minf(1.0, dt * 6.0))
	cam.look_at(Vector3(xpos * 0.5, lerpf(cam_y, _h(ahead), 0.5) - 0.5, -ahead))
	cam.fov = lerpf(cam.fov, clampf(58.0 + v * 0.85, 58.0, 96.0), minf(1.0, dt * 2.5))


# ---- 자동전투: 빠른 쪽이 먼저, 속도 차만큼 더 친다. 공격-방어(최소 1)가 피해 ----
func _start_fight() -> void:
	fight = true
	v = 0.0
	var spd := int(mass)
	var atk := 2 + crushed / 2
	var dfn := int(mass) - 1
	var hs := 2 + sec * 2
	var h_atk := 3 + sec * 2
	var h_def := sec
	h_hp = 6 + sec * 4
	fhp_me = hp
	fhp_him = h_hp
	fseq.clear()
	var me_dmg := maxi(1, atk - h_def)
	var him_dmg := maxi(1, h_atk - dfn)
	var a := fhp_me
	var b := fhp_him
	while a > 0 and b > 0 and fseq.size() < 120:
		var order := [0, 1] if spd >= hs else [1, 0]
		var extra := mini(absi(spd - hs), 3)
		for who in order:
			var hits := 1 + (extra if who == order[0] else 0)
			for h in hits:
				if who == 0:
					b -= me_dmg
					fseq.append([0, me_dmg])
					if b <= 0:
						break
				else:
					a -= him_dmg
					fseq.append([1, him_dmg])
					if a <= 0:
						break
			if a <= 0 or b <= 0:
				break
	fres = 1 if b <= 0 else -1
	fi = 0
	ft = 0.8
	bme.visible = true
	bhim.visible = true
	bme.position = Vector3(-0.7, -0.15, -2.4)
	bhim.position = Vector3(0.7, 0.0, -2.4)
	_fight_show()
	msg("속도 %d : %d" % [spd, hs], 1.2)
	beep(220.0, 0.4, 440.0, 0.35)


func _fight_show() -> void:
	bme.scale = Vector3(0.6, 0.9 * maxf(0.15, float(fhp_me) / float(hp)), 0.6)
	bhim.scale = Vector3(0.7, 1.3 * maxf(0.15, float(fhp_him) / float(h_hp)), 0.7)


func _fight_step(dt: float) -> void:
	bme.position.x = move_toward(bme.position.x, -0.7, dt * 4.0)
	bhim.position.x = move_toward(bhim.position.x, 0.7, dt * 4.0)
	ft -= dt
	if ft > 0.0:
		return
	if fi >= fseq.size():
		fight = false
		bme.visible = false
		bhim.visible = false
		if fres > 0:
			bonus += 100
			play("win")
			msg("이겼다", 1.2)
			hd = dist - FAR * 0.6
			stagger = 3.0
		else:
			msg("죽었다", 1.5)
			end()
		return
	var e: Array = fseq[fi]
	fi += 1
	ft = 0.28
	if e[0] == 0:
		fhp_him -= e[1]
		bme.position.x = 0.2
		beep(700.0, 0.08, 300.0, 0.3)
	else:
		fhp_me -= e[1]
		bhim.position.x = -0.2
		beep(180.0, 0.12, 70.0, 0.35)
	_fight_show()
	msg("-%d" % e[1], 0.25)


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)
