extends Tofu
## 그가 온다 1인칭. 지평선의 "그"가 낮 내내 아주 천천히 다가온다. 조이스틱 걷기, 오른쪽 끌기 둘러보기, 버튼 = 기둥(공·방·속) 줍기 / 말뚝 재료 줍기 / 말뚝 박기.
## 그의 길에 말뚝을 박으면 그 구간에서 느려지고 지친다(속도 스탯이 깎임). 해가 지면 그가 뛴다. 닿으면 자동전투: 빠른 쪽이 먼저 치고 속도 차만큼 더 친다, 공격-방어 = 피해.
## 지면 죽음. 이기면 다음 날(그가 세지고 말뚝 재료가 준다).

const FIELD := 34.0  # 내가 다닐 수 있는 반폭
const DAY := 40.0
const FAR := 70.0  # 그가 시작하는 거리
const STAKE_R := 3.0
const PICK_R := 1.9
const GREY := Color("dfe3e8")
const KINDS := ["공격", "방어", "속도"]

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
var h_atk := 0
var h_def := 0
var h_spd := 0
var h_hp := 0
var tired := 0.0
var in_stake := false
var items: Array[Dictionary] = []  # {n, kind, at}
var logs: Array[MeshInstance3D] = []  # 바닥에 놓인 말뚝 재료
var stakes: Array[Vector3] = []
var carry := 0
var label := ""
var step_t := 0.0
var thump := 0.0
var bob := 0.0
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
	howto = "멀리 보이는 \"그\"가 낮 동안 천천히 온다. 해가 지면 뛴다.\n왼손 조이스틱 걷기, 오른쪽 끌기 둘러보기. 버튼으로 기둥(공격·방어·속도)을 줍고, 말뚝 재료를 주워 그의 길에 박아라. 말뚝을 지나는 그는 느려지고 지친다.\n그가 닿으면 자동전투: 빠른 쪽이 먼저, 속도 차만큼 더 친다. 지면 죽는다."
	time_limit = 0.0
	cam.fov = 75.0
	kit_stick()
	kit_lookpad()
	_button("줍기")
	bme = box(Vector3(-0.7, -0.15, -2.4), Vector3(0.6, 0.9, 0.6), ME, cam)
	bhim = box(Vector3(0.7, 0.0, -2.4), Vector3(0.7, 1.3, 0.7), INK, cam)
	bme.visible = false
	bhim.visible = false


func _button(s: String) -> void:
	if s == label:
		return
	label = s
	kit_button("act", s, Vector2(590, 1080), 100.0, A)


func _reset() -> void:
	box(Vector3(0, -0.1, 0), Vector3(400, 0.2, 400), WHITE)
	for i in 24:
		var a := randf() * TAU
		var d := randf_range(10.0, 120.0)
		var s := randf_range(0.6, 2.2)
		box(Vector3(cos(a) * d, s * 0.5, sin(a) * d), Vector3(s, s, s), GREY)
	him = Node3D.new()
	world.add_child(him)
	box(Vector3(0, 1.4, 0), Vector3(1.2, 2.8, 1.2), INK, him)
	box(Vector3(0, 3.1, 0), Vector3(0.7, 0.6, 0.7), BAD, him)
	box(Vector3(0.5, 1.4, -0.7), Vector3(0.25, 0.25, 1.4), INK, him)
	me_p = Vector3.ZERO
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
	var cols := [A, B, D]
	for i in 7:
		var k := i % 3
		var at := _spot(5.0, 24.0)
		var h := 1.2 + 0.5 * k
		var n := box(at + Vector3(0, h * 0.5, 0), Vector3(0.6, h, 0.6), cols[k], field)
		items.append({"n": n, "kind": k, "at": at})
	for i in maxi(1, 6 - (day - 1)):
		var at := _spot(3.0, 16.0)
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
	var a := randf() * TAU
	him_p = me_p + Vector3(cos(a) * FAR, 0, sin(a) * FAR)
	him.position = him_p
	yaw = atan2(-(him_p.x - me_p.x), -(him_p.z - me_p.z))
	pitch = 0.0
	msg("%d일째" % day, 1.2)
	beep(440.0, 0.2, 660.0, 0.25)


func _spot(lo: float, hi: float) -> Vector3:
	var a := randf() * TAU
	var d := randf_range(lo, hi)
	var p := me_p + Vector3(cos(a) * d, 0, sin(a) * d)
	p.x = clampf(p.x, -FIELD + 2.0, FIELD - 2.0)
	p.z = clampf(p.z, -FIELD + 2.0, FIELD - 2.0)
	return p


func _step(dt: float) -> void:
	bob += dt
	if fight:
		_fight_step(dt)
		_cam()
		return
	# 낮 → 밤
	if not night:
		day_t -= dt
		if day_t <= 0.0:
			night = true
			msg("그가 뛴다!", 1.5)
			beep(200.0, 0.5, 80.0, 0.35)
	# 둘러보기·걷기 (속도 스탯이 걸음도 빠르게)
	yaw -= kit_look.x * 0.007
	pitch = clampf(pitch - kit_look.y * 0.004, -0.6, 0.4)
	var amt := kit_move.length()
	if amt > 0.05:
		var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
		var right := Vector3(cos(yaw), 0, -sin(yaw))
		me_p += (right * kit_move.x - fwd * kit_move.y) * (3.0 + 0.3 * spd) * dt
		me_p.x = clampf(me_p.x, -FIELD, FIELD)
		me_p.z = clampf(me_p.z, -FIELD, FIELD)
		step_t -= dt * amt
		if step_t <= 0.0:
			step_t = 0.4
			beep(110.0, 0.04, 0.0, 0.1)
	_cam()
	# 버튼 글자: 지금 누르면 뭘 하는지
	if _near_item() >= 0 or _near_log() >= 0:
		_button("줍기")
	elif carry > 0:
		_button("박기 %d" % carry)
	else:
		_button("빈손")
	if kit_just("act"):
		_act()
	# 그: 나를 향해 곧장. 말뚝 근처면 느려지고 지친다
	var to := me_p - him_p
	to.y = 0.0
	var dist := to.length()
	var v := 7.0 if night else 0.55
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
		him_p += to / dist * v * dt
	him.position = him_p + Vector3(0, absf(sin(bob * 14.0)) * 0.35 if night else 0.0, 0)
	him.look_at(Vector3(me_p.x, him.position.y, me_p.z), Vector3.UP)
	if night:
		thump -= dt
		if thump <= 0.0:
			thump = 0.32 if not near else 0.7
			beep(60.0, 0.1, 0.0, clampf(0.35 - dist * 0.004, 0.08, 0.35))
		gauge(clampf(1.0 - dist / FAR, 0.0, 1.0), BAD)
	else:
		gauge(day_t / DAY, D)
	if dist < 1.6:
		_start_fight()


func _cam() -> void:
	cam.position = me_p + Vector3(0, 1.6, 0)
	cam.rotation = Vector3(pitch, yaw, 0)


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
		var n: MeshInstance3D = items[i].n
		n.visible = false
		items.remove_at(i)
		match k:
			0: atk += 1
			1: dfn += 1
			_: spd += 1
		play("good")
		msg("%s +1" % KINDS[k], 0.8)
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
