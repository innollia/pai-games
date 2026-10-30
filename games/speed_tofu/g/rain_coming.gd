extends Tofu
## 레인월드 느림 × 그가 온다, 3인칭 등뒤. 스틱 살짝 = 기어감(조용해서 사냥감 옆까지 갈 수 있다), 끝까지 = 뜀(빠르지만 사냥감이 도망간다).
## 낮: 노란 열매를 줍고 기어서 주황 사냥감을 잡는다(먹은 수 = 속도 스탯). 그의 길 옆 재료를 주워 길에 말뚝을 박으면 그가 느려진다.
## 해 지면 그가 뛰어오고 비가 온다(바닥이 미끄러워 뛰면 멈추지 못한다). 셸터 문은 밤에만 열린다(먹은 게 2개 이상일 때). 먼저 들어가면 사이클 끝, 잡히면 자동전투(빠른 쪽이 먼저, 속도 차만큼 더 친다). 지면 죽음. 사이클마다 그가 빨라진다.

const FIELD := 30.0
const DAY := 34.0
const FAR := 46.0
const NEED := 2
const CRAWL := 1.6
const RUN := 5.6
const STAKE_R := 3.0
const PICK_R := 1.6
const NRAIN := 40
const GREY := Color("dfe3e8")


class Prey:
	var n: MeshInstance3D
	var p := Vector3.ZERO
	var dir := Vector3.FORWARD
	var flee := 0.0
	var turn_t := 0.0
	var got := false


var rng := RandomNumberGenerator.new()
var level: Node3D
var cyc := 0
var day_t := 0.0
var night := false
var done_t := 0.0
var eaten := 0
var carry := 0
var label := ""
var hungry_t := 0.0
# 나
var me_root: Node3D
var me_body: MeshInstance3D
var me_head: MeshInstance3D
var me_p := Vector3.ZERO
var vel := Vector3.ZERO
var heading := 0.0
var cam_yaw := 0.0
var running := false
var crawl := false
var step_t := 0.0
var bob := 0.0
# 그
var him: Node3D
var him_p := Vector3.ZERO
var path_u := Vector3.FORWARD
var tired := 0.0
var in_stake := false
var thump := 0.0
# 세계
var door_p := Vector3.ZERO
var door: MeshInstance3D
var fruits: Array[Dictionary] = []  # {n, p, got}
var preys: Array[Prey] = []
var logs: Array[MeshInstance3D] = []
var stakes: Array[Vector3] = []
var rain: Array[MeshInstance3D] = []
# 자동전투 (카메라 앞 상자 둘)
var fight := false
var fseq: Array = []
var fi := 0
var ft := 0.0
var fres := 0
var hp := 10
var h_hp := 0
var h_atk := 0
var h_spd := 0
var fhp_me := 0
var fhp_him := 0
var bme: MeshInstance3D
var bhim: MeshInstance3D


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 70.0
	howto = "스틱을 살짝 기울이면 기어간다. 끝까지 기울이면 뛴다(빠르지만 주황 사냥감이 도망간다).\n낮: 노란 열매를 줍고, 기어가서 사냥감을 잡아라. 먹은 수가 곧 내 속도다. 그의 길 옆 재료를 주워 길에 말뚝을 박으면 그가 느려진다.\n해 지면 그가 뛰어오고 비가 온다(미끄럽다). 셸터 문은 밤에만, 2개 이상 먹었을 때 열린다.\n잡히면 자동전투: 빠른 쪽이 먼저 친다. 지면 죽는다."
	kit_stick()
	kit_button("act", "줍기", Vector2(590, 1060), 100.0, A)
	bme = box(Vector3(-0.7, -0.15, -2.4), Vector3(0.6, 0.9, 0.6), ME, cam)
	bhim = box(Vector3(0.7, 0.0, -2.4), Vector3(0.7, 1.3, 0.7), INK, cam)
	bme.visible = false
	bhim.visible = false


func _button(s: String) -> void:
	if s == label:
		return
	label = s
	kit_button("act", s, Vector2(590, 1060), 100.0, A)


func _reset() -> void:
	rng.randomize()
	level = null
	cyc = 0
	fight = false
	bme.visible = false
	bhim.visible = false
	_region()


func _region() -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	fruits.clear()
	preys.clear()
	logs.clear()
	stakes.clear()
	rain.clear()
	# 땅·풀·바위
	box(Vector3(0, -0.1, 0), Vector3(FIELD * 2.0 + 20.0, 0.2, FIELD * 2.0 + 20.0), WHITE, level)
	box(Vector3(0, 0.01, 0), Vector3(FIELD * 2.0, 0.04, FIELD * 2.0), GOOD.lightened(0.55), level)
	for i in 30:
		var s := rng.randf_range(0.3, 0.6)
		box(Vector3(rng.randf_range(-FIELD, FIELD), s * 0.5, rng.randf_range(-FIELD, FIELD)), Vector3(s, s, s), GOOD.lightened(0.2), level)
	for i in 10:
		var s := rng.randf_range(1.0, 2.4)
		var a := rng.randf() * TAU
		var d := rng.randf_range(FIELD + 3.0, FIELD + 14.0)
		box(Vector3(cos(a) * d, s * 0.5, sin(a) * d), Vector3(s, s, s), GREY, level)
	# 그의 길: 먼 데서 캠프(가운데)로
	var a0 := rng.randf() * TAU
	path_u = Vector3(cos(a0), 0, sin(a0))
	var road := box(path_u * FAR * 0.5 + Vector3(0, 0.03, 0), Vector3(1.8, 0.05, FAR), SOFT.darkened(0.12), level)
	road.rotation.y = atan2(path_u.x, path_u.z)
	var side := Vector3(-path_u.z, 0, path_u.x)
	# 셸터: 길의 반대쪽
	var sa := a0 + PI + rng.randf_range(-0.9, 0.9)
	var sd := 14.0 + cyc * 2.0
	var sp := Vector3(cos(sa) * sd, 0, sin(sa) * sd)
	box(sp + Vector3(0, 1.6, 0), Vector3(4.0, 3.2, 4.0), SOFT, level)
	var to_c := -sp.normalized()
	door_p = sp + to_c * 2.1
	door = box(door_p + Vector3(0, 0.9, 0), Vector3(1.4, 1.8, 0.3), BAD, level)
	door.rotation.y = atan2(to_c.x, to_c.z)
	# 열매
	for i in 3:
		var p := _spot(6.0, FIELD - 3.0)
		var m := box(p + Vector3(0, 0.45, 0), Vector3(0.6, 0.6, 0.6), D, level)
		fruits.append({"n": m, "p": p, "got": false})
	# 사냥감
	for i in 3 + cyc / 2:
		var pr := Prey.new()
		pr.p = _spot(8.0, FIELD - 3.0)
		pr.n = box(pr.p + Vector3(0, 0.3, 0), Vector3(0.7, 0.5, 0.45), A, level)
		var pa := rng.randf() * TAU
		pr.dir = Vector3(cos(pa), 0, sin(pa))
		preys.append(pr)
	# 말뚝 재료: 길 옆
	for i in maxi(1, 4 - cyc / 2):
		var at := path_u * rng.randf_range(10.0, 34.0) + side * rng.randf_range(2.5, 5.0) * (1.0 if rng.randf() < 0.5 else -1.0)
		var m := box(at + Vector3(0, 0.15, 0), Vector3(1.4, 0.3, 0.3), SOFT.darkened(0.25), level)
		m.rotation.y = rng.randf() * TAU
		logs.append(m)
	# 비
	for i in NRAIN:
		var r := box(Vector3(0, -50, 0), Vector3(0.07, 1.0, 0.07), B, level)
		r.visible = false
		rain.append(r)
	# 그
	him = Node3D.new()
	level.add_child(him)
	box(Vector3(0, 1.4, 0), Vector3(1.2, 2.8, 1.2), INK, him)
	box(Vector3(0, 3.1, 0), Vector3(0.7, 0.6, 0.7), BAD, him)
	box(Vector3(0.5, 1.4, -0.7), Vector3(0.25, 0.25, 1.4), INK, him)
	him_p = path_u * FAR
	him.position = him_p
	# 나
	me_root = Node3D.new()
	level.add_child(me_root)
	me_body = box(Vector3(0, 0.45, 0), Vector3(0.5, 0.9, 0.4), ME, me_root)
	me_head = box(Vector3(0, 1.1, -0.1), Vector3(0.4, 0.4, 0.4), WHITE, me_root)
	me_p = Vector3.ZERO
	vel = Vector3.ZERO
	heading = atan2(-path_u.x, -path_u.z)
	cam_yaw = heading
	running = false
	crawl = false
	eaten = 0
	carry = 0
	tired = 0.0
	in_stake = false
	night = false
	done_t = 0.0
	hungry_t = 0.0
	day_t = DAY
	hp = 10
	h_atk = 2 + cyc
	h_spd = 1 + cyc
	h_hp = 5 + cyc * 3
	_button("줍기")
	msg("사이클 %d" % (cyc + 1), 1.2)
	beep(440.0, 0.2, 660.0, 0.25)


func _spot(lo: float, hi: float) -> Vector3:
	var a := rng.randf() * TAU
	var d := rng.randf_range(lo, hi)
	var p := Vector3(cos(a) * d, 0, sin(a) * d)
	p.x = clampf(p.x, -FIELD + 2.0, FIELD - 2.0)
	p.z = clampf(p.z, -FIELD + 2.0, FIELD - 2.0)
	return p


# ---- 판 ----
func _step(dt: float) -> void:
	bob += dt
	if fight:
		_fight_step(dt)
		_view(dt)
		return
	if done_t > 0.0:
		done_t -= dt
		if done_t <= 0.0:
			cyc += 1
			_region()
		_view(dt)
		return
	if not night:
		day_t -= dt
		gauge(day_t / DAY, D)
		if day_t <= 0.0:
			night = true
			msg("그가 뛴다!", 1.5)
			beep(200.0, 0.5, 80.0, 0.35)
	_me(dt)
	_preys(dt)
	_him(dt)
	if fight or over:
		return
	_rain(dt)
	score = cyc * 10 + eaten
	_view(dt)


func _me(dt: float) -> void:
	var amt := kit_move.length()
	running = amt >= 0.65
	crawl = amt > 0.12 and not running
	var want := Vector3.ZERO
	if amt > 0.12:
		var fwd := Vector3(-sin(cam_yaw), 0, -cos(cam_yaw))
		var right := Vector3(cos(cam_yaw), 0, -sin(cam_yaw))
		var d := (right * kit_move.x - fwd * kit_move.y).normalized()
		want = d * (RUN if running else CRAWL)
		heading = lerp_angle(heading, atan2(-d.x, -d.z), minf(1.0, 10.0 * dt))
	# 비가 오면 미끄럽다: 뛰면 멈추지도 돌지도 못한다
	var acc := 4.0 if night else 16.0
	if want.length() < 0.01:
		acc = 2.5 if night else 20.0
	vel = vel.move_toward(want, acc * dt)
	me_p += vel * dt
	me_p.x = clampf(me_p.x, -FIELD, FIELD)
	me_p.z = clampf(me_p.z, -FIELD, FIELD)
	var sp := vel.length()
	if sp > 0.3:
		step_t -= dt
		if step_t <= 0.0:
			step_t = 1.3 / sp
			beep(140.0 if running else 100.0, 0.04, 0.0, 0.16 if running else 0.07)
	# 줍기
	for f in fruits:
		if not f.got and _flat(f.p) < 0.9:
			f.got = true
			(f.n as MeshInstance3D).visible = false
			_eat("열매")
	var ni := _near_log()
	if ni >= 0:
		_button("줍기")
	elif carry > 0:
		_button("박기 %d" % carry)
	else:
		_button("빈손")
	if kit_just("act"):
		if ni >= 0:
			logs[ni].visible = false
			logs.remove_at(ni)
			carry += 1
			beep(600.0, 0.08, 800.0, 0.2)
			msg("재료 %d" % carry, 0.6)
		elif carry > 0:
			carry -= 1
			var at := Vector3(me_p.x, 0, me_p.z)
			stakes.append(at)
			box(at + Vector3(0, 0.9, 0), Vector3(0.35, 1.8, 0.35), A, level)
			box(at + Vector3(0, 1.3, 0), Vector3(1.6, 0.25, 0.25), A, level).rotation.y = heading
			beep(150.0, 0.12, 60.0, 0.35)
			msg("박았다", 0.6)
		else:
			beep(300.0, 0.05, 0.0, 0.12)
			msg("빈손", 0.5)
	# 셸터 문
	if _flat(door_p) < 1.4:
		if not night:
			hungry_t -= dt
			if hungry_t <= 0.0:
				hungry_t = 1.2
				msg("아직 낮", 0.6)
				beep(260.0, 0.08, 0.0, 0.15)
		elif eaten < NEED:
			hungry_t -= dt
			if hungry_t <= 0.0:
				hungry_t = 1.0
				msg("배고파", 0.6)
				beep(200.0, 0.1, 0.0, 0.2)
		else:
			done_t = 1.3
			score = (cyc + 1) * 10 + eaten
			play("win")
			msg("셸터!", 1.2)


func _flat(p: Vector3) -> float:
	return Vector2(p.x - me_p.x, p.z - me_p.z).length()


func _near_log() -> int:
	var bi := -1
	var bd := PICK_R
	for i in logs.size():
		var d := _flat(logs[i].position)
		if d < bd:
			bd = d
			bi = i
	return bi


func _eat(what: String) -> void:
	eaten += 1
	play("good")
	msg("%s · 속도 %d" % [what, eaten], 0.8)
	door.material_override = mat(GOOD if eaten >= NEED else BAD)


## 사냥감: 어슬렁거리다 내가 뛰며 다가오면 도망, 기어서 붙으면 잡힌다
func _preys(dt: float) -> void:
	for pr in preys:
		if pr.got:
			continue
		var d := _flat(pr.p)
		var away := Vector3(pr.p.x - me_p.x, 0, pr.p.z - me_p.z)
		if running and vel.length() > 3.0 and d < 7.0 and pr.flee <= 0.0:
			pr.flee = 2.5
			beep(900.0, 0.08, 1300.0, 0.15)
			msg("도망!", 0.5)
		if pr.flee > 0.0:
			pr.flee -= dt
			if away.length() > 0.01:
				pr.dir = away.normalized()
			pr.p += pr.dir * 7.5 * dt
		else:
			pr.turn_t -= dt
			if pr.turn_t <= 0.0:
				pr.turn_t = rng.randf_range(0.8, 2.0)
				var a := rng.randf() * TAU
				pr.dir = Vector3(cos(a), 0, sin(a))
			pr.p += pr.dir * 0.9 * dt
			if d < 0.9 and not running:
				pr.got = true
				pr.n.visible = false
				_eat("잡았다")
				continue
		pr.p.x = clampf(pr.p.x, -FIELD + 1.0, FIELD - 1.0)
		pr.p.z = clampf(pr.p.z, -FIELD + 1.0, FIELD - 1.0)
		pr.n.position = pr.p + Vector3(0, 0.3 + (absf(sin(bob * 20.0)) * 0.25 if pr.flee > 0.0 else 0.0), 0)
		pr.n.rotation.y = atan2(pr.dir.x, pr.dir.z)


## 그: 낮엔 길 따라 천천히 캠프로, 밤엔 나를 향해 뛴다. 말뚝 옆에선 느려지고 지친다
func _him(dt: float) -> void:
	var to := (Vector3.ZERO if not night else me_p) - him_p
	to.y = 0.0
	var dist := to.length()
	var v := (7.0 + 0.8 * cyc) if night else 0.7
	var near := false
	for s in stakes:
		if Vector2(s.x - him_p.x, s.z - him_p.z).length() < STAKE_R:
			near = true
			break
	if near:
		v *= 0.25
		tired += dt
		if not in_stake:
			in_stake = true
			msg("지친다", 0.8)
			beep(330.0, 0.15, 220.0, 0.25)
	else:
		in_stake = false
	if dist > 0.01:
		him_p += to / dist * minf(v * dt, dist)
	him.position = him_p + Vector3(0, absf(sin(bob * 14.0)) * 0.35 if night else 0.0, 0)
	if _flat(him_p) > 0.05:
		him.look_at(Vector3(me_p.x, him.position.y, me_p.z), Vector3.UP)
	var me_d := _flat(him_p)
	if night:
		thump -= dt
		if thump <= 0.0:
			thump = 0.7 if near else 0.32
			beep(60.0, 0.1, 0.0, clampf(0.35 - me_d * 0.005, 0.08, 0.35))
		gauge(clampf(1.0 - me_d / FAR, 0.0, 1.0), BAD)
	if me_d < 1.6:
		_start_fight()


# ---- 자동전투: 빠른 쪽이 먼저, 속도 차만큼 더 친다 ----
func _start_fight() -> void:
	fight = true
	var hs := maxi(0, h_spd - int(tired / 2.0))
	var spd := eaten
	fhp_me = hp
	fhp_him = h_hp
	fseq.clear()
	var me_dmg := 2
	var him_dmg := h_atk
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
	ft = 0.9
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
			play("win")
			msg("이겼다", 1.2)
			score = (cyc + 1) * 10 + eaten
			done_t = 1.0
		else:
			me_body.material_override = mat(BAD)
			me_head.material_override = mat(BAD)
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


# ---- 그리기 ----
func _rain(dt: float) -> void:
	for r in rain:
		if not night:
			r.visible = false
			continue
		if not r.visible:
			r.visible = true
			r.position = me_p + Vector3(rng.randf_range(-9.0, 9.0), rng.randf_range(2.0, 12.0), rng.randf_range(-9.0, 9.0))
		r.position.y -= 15.0 * dt
		if r.position.y < 0.0:
			r.position = me_p + Vector3(rng.randf_range(-9.0, 9.0), 10.0 + rng.randf_range(0.0, 4.0), rng.randf_range(-9.0, 9.0))


func _view(dt: float) -> void:
	me_root.position = me_p
	me_root.rotation.y = heading
	me_root.scale = Vector3(1.0, 0.5 if crawl else 1.0, 1.0)
	var k := minf(1.0, 4.0 * dt)
	cam_yaw = lerp_angle(cam_yaw, heading, k)
	var back_d := 7.5 if running else 6.0
	var fov_t := 86.0 if running else 70.0
	cam.fov = lerpf(cam.fov, fov_t, minf(1.0, 6.0 * dt))
	var eye := me_p + Vector3(sin(cam_yaw), 0, cos(cam_yaw)) * back_d + Vector3(0, 3.6 if not crawl else 2.4, 0)
	cam.position = cam.position.lerp(eye, minf(1.0, 8.0 * dt))
	cam.look_at(me_p + Vector3(0, 1.0, 0), Vector3.UP)
