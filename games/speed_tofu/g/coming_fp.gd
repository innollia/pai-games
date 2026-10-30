extends Tofu
## 그가 온다 1인칭 · 질주판. 지평선의 "그"가 낮 내내 천천히 "그의 길"(바닥의 띠)을 따라 캠프로 온다. 조이스틱 걷기, 오른쪽 끌기 둘러보기, 달려 버튼 = 질주(숨이 닳고 바닥나면 헐떡), 줍기 버튼 = 기둥/말뚝 재료 줍기·말뚝 박기.
## 기둥은 가만히 있지 않는다: 그의 길 위 기둥은 그가 지나가면 밟혀 사라진다(그에게 가까울수록 좋다, 달려갔다 와야 한다). 바람에 구르는 기둥은 쫓아야 하고, 깜빡이는 기둥은 몇 초 안에 닿아야 한다.
## 말뚝 재료도 그의 길 옆. 길에 말뚝을 박으면 그 구간에서 그가 느려지고 지친다. 해가 지면 그가 뛴다(나보다 빠르다). 닿으면 자동전투: 빠른 쪽이 먼저, 속도 차만큼 더 친다, 공격-방어 = 피해. 지면 죽음. 이기면 다음 날.

const FIELD := 48.0  # 내가 다닐 수 있는 반폭
const DAY := 36.0
const FAR := 50.0  # 그가 시작하는 거리
const STAKE_R := 3.0
const PICK_R := 2.0
const CRUSH_R := 1.7
const WALK := 3.1
const SPRINT := 2.8  # 걷기의 배수
const BREATH_T := 4.5  # 숨이 다 닳는 초
const GASP_T := 2.4
const GREY := Color("dfe3e8")
const KINDS := ["공격", "방어", "속도"]
const COLS := [A, B, D]

var field: Node3D
var me_p := Vector3.ZERO
var yaw := 0.0
var pitch := 0.0
var atk := 1
var dfn := 0
var spd := 1
var hp := 12
var day := 0
var day_t := 0.0
var night := false
var him: Node3D
var him_p := Vector3.ZERO
var path_u := Vector3.FORWARD  # 캠프 -> 그 시작점 방향
var h_atk := 0
var h_def := 0
var h_spd := 0
var h_hp := 0
var tired := 0.0
var in_stake := false
var items: Array[Dictionary] = []  # {n, kind, at, val, mode(0 길 1 바람 2 깜빡), vel, life}
var flash_pool: Array[MeshInstance3D] = []
var flash_t := 0.0
var wind := Vector3.ZERO
var logs: Array[MeshInstance3D] = []  # 바닥에 놓인 말뚝 재료
var stakes: Array[Vector3] = []
var carry := 0
var label := ""
# 질주·숨
var breath := 1.0
var gasp := 0.0
var gasp_t := 0.0
var sprinting := false
var step_t := 0.0
var thump := 0.0
var bob := 0.0
var bob_ph := 0.0
var bbar: MeshInstance3D
var bbg: MeshInstance3D
# 자동전투 (화면 가운데 상자 두 개가 부딪히는 연출)
var fight := false
var fseq: Array = []  # [누가(0 나, 1 그), 피해]
var fi := 0
var ft := 0.0
var fres := 0
var fhp_me := 0
var fhp_him := 0
var bme: MeshInstance3D
var bhim: MeshInstance3D


func _setup() -> void:
	howto = "멀리 보이는 \"그\"가 낮 동안 바닥의 띠(그의 길)를 따라 천천히 온다. 해가 지면 뛴다.\n왼손 조이스틱 걷기, 오른쪽 끌기 둘러보기. 달려 버튼을 누르면 질주 — 숨이 닳고 바닥나면 헐떡인다.\n기둥(공격·방어·속도)은 그가 밟으면 사라지고(그에게 가까울수록 좋다), 바람에 구르고, 깜빡이다 꺼진다. 달려가서 줍고 돌아와라. 길 옆 재료를 주워 길에 말뚝을 박으면 그가 느려지고 지친다.\n그가 닿으면 자동전투: 빠른 쪽이 먼저, 속도 차만큼 더 친다. 지면 죽는다."
	time_limit = 0.0
	cam.fov = 75.0
	kit_stick()
	kit_lookpad()
	kit_button("run", "달려", Vector2(590, 1090), 105.0, GOOD)
	_button("줍기")
	bme = box(Vector3(-0.7, -0.15, -2.4), Vector3(0.6, 0.9, 0.6), ME, cam)
	bhim = box(Vector3(0.7, 0.0, -2.4), Vector3(0.7, 1.3, 0.7), INK, cam)
	bme.visible = false
	bhim.visible = false
	bbg = box(Vector3(0, 1.9, -2.4), Vector3(1.4, 0.12, 0.05), WHITE, cam)
	bbar = box(Vector3(0, 1.9, -2.39), Vector3(1.3, 0.09, 0.05), GOOD, cam)


func _button(s: String) -> void:
	if s == label:
		return
	label = s
	kit_button("act", s, Vector2(590, 860), 85.0, A)


func _reset() -> void:
	box(Vector3(0, -0.1, 0), Vector3(400, 0.2, 400), WHITE)
	# 바닥 줄무늬: 지나가면 속도가 보인다
	var n := int(FIELD * 2.0 / 4.0)
	for i in n + 1:
		var c := -FIELD + 4.0 * i
		box(Vector3(c, 0.02, 0), Vector3(0.14, 0.04, FIELD * 2.0), GREY)
		box(Vector3(0, 0.02, c), Vector3(FIELD * 2.0, 0.04, 0.14), GREY)
	for i in 50:
		var s := randf_range(0.25, 0.45)
		box(Vector3(randf_range(-FIELD, FIELD), s * 0.5, randf_range(-FIELD, FIELD)), Vector3(s, s, s), GOOD.lightened(0.35))
	for i in 24:
		var a := randf() * TAU
		var d := randf_range(FIELD + 4.0, 120.0)
		var s := randf_range(0.8, 2.4)
		box(Vector3(cos(a) * d, s * 0.5, sin(a) * d), Vector3(s, s, s), GREY)
	him = Node3D.new()
	world.add_child(him)
	box(Vector3(0, 1.4, 0), Vector3(1.2, 2.8, 1.2), INK, him)
	box(Vector3(0, 3.1, 0), Vector3(0.7, 0.6, 0.7), BAD, him)
	box(Vector3(0.5, 1.4, -0.7), Vector3(0.25, 0.25, 1.4), INK, him)
	atk = 1
	dfn = 0
	spd = 1
	day = 0
	stakes.clear()
	carry = 0
	fight = false
	field = null
	_button("줍기")
	_new_day()


func _new_day() -> void:
	day += 1
	if field:
		field.queue_free()
	field = Node3D.new()
	world.add_child(field)
	items.clear()
	logs.clear()
	flash_pool.clear()
	me_p = Vector3.ZERO  # 캠프로 돌아와 아침을 맞는다
	var a := randf() * TAU
	path_u = Vector3(cos(a), 0, sin(a))
	him_p = path_u * FAR
	him.position = him_p
	# 그의 길 (바닥의 띠)
	var road := box(path_u * FAR * 0.5 + Vector3(0, 0.03, 0), Vector3(1.6, 0.05, FAR), SOFT.darkened(0.12), field)
	road.rotation.y = atan2(path_u.x, path_u.z)
	var side := Vector3(-path_u.z, 0, path_u.x)
	# (a) 길 위 기둥: 그에게 가까울수록 좋다. 그가 지나가면 밟힌다
	for d in [10.0, 19.0, 27.0, 34.0, 40.0, 45.0]:
		var val := 3 if d >= 34.0 else (2 if d >= 19.0 else 1)
		_item(path_u * d + side * randf_range(-0.6, 0.6), randi() % 3, val, 0)
	# (b) 바람에 구르는 기둥
	var wa := randf() * TAU
	wind = Vector3(cos(wa), 0, sin(wa)) * 2.6
	for i in 3:
		var at := _spot(8.0, 28.0)
		var it := _item(at, randi() % 3, 2, 1)
		it.vel = wind
	# (c) 깜빡이는 기둥 (돌려 쓰는 상자 3개)
	for i in 3:
		var fn := box(Vector3.ZERO, Vector3(0.5, 1.6, 0.5), WHITE, field)
		fn.visible = false
		flash_pool.append(fn)
	flash_t = 3.0
	# 말뚝 재료: 길 옆
	for i in maxi(1, 5 - (day - 1)):
		var at := path_u * randf_range(14.0, 36.0) + side * (randf_range(2.5, 5.0) * (1.0 if randf() < 0.5 else -1.0))
		var n := box(at + Vector3(0, 0.15, 0), Vector3(1.4, 0.3, 0.3), SOFT.darkened(0.25), field)
		n.rotation.y = randf() * TAU
		logs.append(n)
	h_atk = 2 + day * 2
	h_def = day
	h_spd = 2 + day
	h_hp = 6 + day * 5
	hp = 12
	tired = 0.0
	in_stake = false
	night = false
	day_t = DAY
	breath = 1.0
	gasp = 0.0
	yaw = atan2(-(him_p.x - me_p.x), -(him_p.z - me_p.z))
	pitch = 0.0
	msg("%d일째" % day, 1.2)
	beep(440.0, 0.2, 660.0, 0.25)


func _item(at: Vector3, kind: int, val: int, mode: int) -> Dictionary:
	at.x = clampf(at.x, -FIELD + 2.0, FIELD - 2.0)
	at.z = clampf(at.z, -FIELD + 2.0, FIELD - 2.0)
	var n: MeshInstance3D
	if mode == 1:
		n = box(at + Vector3(0, 0.45, 0), Vector3(0.9, 0.9, 0.9), COLS[kind], field)
	else:
		var h := 0.8 + 0.6 * val
		n = box(at + Vector3(0, h * 0.5, 0), Vector3(0.6, h, 0.6), COLS[kind], field)
	var it := {"n": n, "kind": kind, "at": at, "val": val, "mode": mode, "vel": Vector3.ZERO, "life": 0.0}
	items.append(it)
	return it


func _spot(lo: float, hi: float) -> Vector3:
	var a := randf() * TAU
	var d := randf_range(lo, hi)
	var p := me_p + Vector3(cos(a) * d, 0, sin(a) * d)
	p.x = clampf(p.x, -FIELD + 2.0, FIELD - 2.0)
	p.z = clampf(p.z, -FIELD + 2.0, FIELD - 2.0)
	return p


## 깜빡이는 기둥 하나를 길 근처에 띄운다 (빈 상자가 없으면 건너뜀)
func _flash() -> void:
	for fn in flash_pool:
		if fn.visible:
			continue
		var side := Vector3(-path_u.z, 0, path_u.x)
		var at := path_u * randf_range(6.0, 32.0) + side * randf_range(-7.0, 7.0)
		at.x = clampf(at.x, -FIELD + 2.0, FIELD - 2.0)
		at.z = clampf(at.z, -FIELD + 2.0, FIELD - 2.0)
		var kind := randi() % 3
		fn.material_override = mat(COLS[kind])
		fn.position = at + Vector3(0, 0.8, 0)
		fn.visible = true
		items.append({"n": fn, "kind": kind, "at": at, "val": 2, "mode": 2, "vel": Vector3.ZERO, "life": 4.5})
		beep(1200.0, 0.1, 1600.0, 0.2)
		msg("반짝!", 0.5)
		return


func _step(dt: float) -> void:
	bob += dt
	if fight:
		_fight_step(dt)
		_cam(dt)
		return
	# 낮 → 밤
	if not night:
		day_t -= dt
		if day_t <= 0.0:
			night = true
			msg("그가 뛴다!", 1.5)
			beep(200.0, 0.5, 80.0, 0.35)
	# 둘러보기
	yaw -= kit_look.x * 0.007
	pitch = clampf(pitch - kit_look.y * 0.004, -0.6, 0.4)
	# 질주·숨
	var amt := kit_move.length()
	var want_run := kit_held("run") and amt > 0.05
	if gasp > 0.0:
		gasp -= dt
		gasp_t -= dt
		if gasp_t <= 0.0:
			gasp_t = 0.4
			beep(180.0, 0.1, 150.0, 0.15)
		sprinting = false
	elif want_run and breath > 0.0:
		if not sprinting:
			beep(300.0, 0.15, 600.0, 0.15)
		sprinting = true
		breath -= dt / BREATH_T
		if breath <= 0.0:
			breath = 0.0
			sprinting = false
			gasp = GASP_T
			gasp_t = 0.0
			msg("헐떡", 1.0)
			beep(200.0, 0.3, 120.0, 0.3)
	else:
		sprinting = false
		breath = minf(1.0, breath + dt / 3.0)
	# 걷기 (속도 스탯이 걸음도 빠르게)
	var walk := WALK + 0.25 * spd
	var v_me := walk * (SPRINT if sprinting else (0.5 if gasp > 0.0 else 1.0))
	if amt > 0.05:
		var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
		var right := Vector3(cos(yaw), 0, -sin(yaw))
		me_p += (right * kit_move.x - fwd * kit_move.y) * v_me * dt
		me_p.x = clampf(me_p.x, -FIELD, FIELD)
		me_p.z = clampf(me_p.z, -FIELD, FIELD)
		bob_ph += dt * v_me * 2.2 * amt
		step_t -= dt * amt
		if step_t <= 0.0:
			step_t = 1.55 / v_me
			beep(150.0 if sprinting else 110.0, 0.04, 0.0, 0.16 if sprinting else 0.1)
	_cam(dt)
	# 숨 막대
	bbar.scale.x = 1.3 * maxf(0.02, breath)
	bbar.position.x = -0.65 * (1.0 - maxf(0.02, breath))
	bbar.material_override = mat(BAD if gasp > 0.0 else (D if breath < 0.3 else GOOD))
	# 버튼 글자: 지금 누르면 뭘 하는지
	if _near_item() >= 0 or _near_log() >= 0:
		_button("줍기")
	elif carry > 0:
		_button("박기 %d" % carry)
	else:
		_button("빈손")
	if kit_just("act"):
		_act()
	# 기둥: 바람에 구르고, 깜빡이다 꺼진다
	flash_t -= dt
	if flash_t <= 0.0:
		flash_t = 5.0
		_flash()
	for i in range(items.size() - 1, -1, -1):
		var it := items[i]
		var n: MeshInstance3D = it.n
		if it.mode == 1:
			var vel: Vector3 = it.vel
			var at: Vector3 = it.at + vel * dt
			if absf(at.x) > FIELD - 2.0:
				vel.x = -vel.x
			if absf(at.z) > FIELD - 2.0:
				vel.z = -vel.z
			at.x = clampf(at.x, -FIELD + 2.0, FIELD - 2.0)
			at.z = clampf(at.z, -FIELD + 2.0, FIELD - 2.0)
			it.vel = vel
			it.at = at
			n.position = at + Vector3(0, 0.45, 0)
			if vel.length() > 0.01:
				n.rotate(Vector3(vel.z, 0, -vel.x).normalized(), vel.length() * dt / 0.45)
		elif it.mode == 2:
			it.life -= dt
			if it.life <= 0.0:
				n.visible = false
				items.remove_at(i)
				beep(500.0, 0.08, 200.0, 0.12)
				continue
			n.visible = it.life > 1.8 or fmod(it.life, 0.2) < 0.1
	# 그: 낮엔 길을 따라 캠프로, 밤엔 나를 향해 곧장. 말뚝 근처면 느려지고 지친다
	var to := (Vector3.ZERO if not night else me_p) - him_p
	to.y = 0.0
	var dist := to.length()
	var v := (7.5 + 0.5 * day) if night else 0.8
	var near := false
	for s in stakes:
		if Vector2(s.x - him_p.x, s.z - him_p.z).length() < STAKE_R:
			near = true
			break
	if near:
		v *= 0.22
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
	if Vector2(me_p.x - him_p.x, me_p.z - him_p.z).length() > 0.05:
		him.look_at(Vector3(me_p.x, him.position.y, me_p.z), Vector3.UP)
	# 밟힌 기둥
	for i in range(items.size() - 1, -1, -1):
		var at: Vector3 = items[i].at
		if Vector2(at.x - him_p.x, at.z - him_p.z).length() < CRUSH_R:
			(items[i].n as MeshInstance3D).visible = false
			items.remove_at(i)
			beep(90.0, 0.15, 40.0, 0.3)
			msg("밟혔다", 0.6)
	var me_d := Vector2(me_p.x - him_p.x, me_p.z - him_p.z).length()
	if night:
		thump -= dt
		if thump <= 0.0:
			thump = 0.32 if not near else 0.7
			beep(60.0, 0.1, 0.0, clampf(0.35 - me_d * 0.004, 0.08, 0.35))
		gauge(clampf(1.0 - me_d / FAR, 0.0, 1.0), BAD)
	else:
		gauge(day_t / DAY, D)
	if me_d < 1.6:
		_start_fight()


## 카메라: 질주하면 시야가 넓어지고 머리가 더 들썩인다, 헐떡이면 좁고 무겁게
func _cam(dt: float) -> void:
	var fov_t := 96.0 if sprinting else (70.0 if gasp > 0.0 else 75.0)
	cam.fov = lerpf(cam.fov, fov_t, minf(1.0, 8.0 * dt))
	var amp := 0.16 if sprinting else (0.08 if gasp > 0.0 else 0.04)
	var ph := bob_ph if gasp <= 0.0 else bob * 5.0
	cam.position = me_p + Vector3(0, 1.6 + sin(ph) * amp, 0)
	cam.rotation = Vector3(pitch, yaw, sin(ph * 0.5) * (0.035 if sprinting else 0.0))


func _near_item() -> int:
	var bi := -1
	var bd := PICK_R
	for i in items.size():
		var at: Vector3 = items[i].at
		var d := Vector2(at.x - me_p.x, at.z - me_p.z).length()
		if d < bd:
			bd = d
			bi = i
	return bi


func _near_log() -> int:
	var bi := -1
	var bd := PICK_R
	for i in logs.size():
		var d := Vector2(logs[i].position.x - me_p.x, logs[i].position.z - me_p.z).length()
		if d < bd:
			bd = d
			bi = i
	return bi


## 버튼: 가까운 기둥 줍기 > 재료 줍기 > 말뚝 박기
func _act() -> void:
	var i := _near_item()
	if i >= 0:
		var k: int = items[i].kind
		var val: int = items[i].val
		var n: MeshInstance3D = items[i].n
		n.visible = false
		items.remove_at(i)
		match k:
			0: atk += val
			1: dfn += val
			_: spd += val
		play("good")
		msg("%s +%d" % [KINDS[k], val], 0.8)
		return
	var j := _near_log()
	if j >= 0:
		logs[j].visible = false
		logs.remove_at(j)
		carry += 1
		beep(600.0, 0.08, 800.0, 0.2)
		msg("재료 %d" % carry, 0.6)
		return
	if carry > 0:
		carry -= 1
		var at := Vector3(me_p.x, 0, me_p.z)
		stakes.append(at)
		box(at + Vector3(0, 0.9, 0), Vector3(0.35, 1.8, 0.35), A)
		box(at + Vector3(0, 1.3, 0), Vector3(1.6, 0.25, 0.25), A).rotation.y = yaw
		beep(150.0, 0.12, 60.0, 0.35)
		msg("박았다", 0.6)
		return
	beep(300.0, 0.05, 0.0, 0.12)
	msg("빈손", 0.5)


## 전투 순서를 미리 계산: 빠른 쪽이 먼저, 속도 차만큼 더 친다. 공격-방어(최소 1)가 피해.
func _start_fight() -> void:
	fight = true
	sprinting = false
	var hs := maxi(0, h_spd - int(tired / 2.0))
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
			score += 1
			play("win")
			msg("이겼다", 1.2)
			_new_day()
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
