extends Tofu
## 그가 온다(위에서 본 작은 섬). 땅을 탭하면 그리로 걸어간다. 낮 게이지가 내려가는 동안 공격(주황)·방어(파랑)·속도(노랑) 상자를 줍고 빨간 잡몹과 자동전투.
## 해가 지면 보라색 "그"가 섬 가장자리에서 나한테 곧장 달려온다(나보다 빠름). 전투: 속도 높은 쪽이 먼저 치고 속도 차이만큼 더 때린다. 공격-방어=피해(최소 1).
## 그를 이기면 다음 날(그가 세지고 섬이 재배치, 내 스탯은 유지). 체력 0이면 끝. 속도 스탯은 걸음에도 전투에도 쓰인다.

const HW := 7.0  # 섬 반폭 (x)
const HH := 9.0  # 섬 반높이 (z)
const DAY := 20.0
const NITEM := 9
const NMOB := 4
const HP0 := 12
const STRIKE := 0.3  # 한 타격 연출 시간
const KINDS := ["atk", "def", "spd"]
const KCOL := {"atk": A, "def": B, "spd": D}
const KNAME := {"atk": "공격", "def": "방어", "spd": "속도"}
const WATER := Color("a5d8ff")

var mode := "day"  # day / night / fight
var back_mode := "day"  # 전투 끝나고 돌아갈 모드
var day := 1
var day_t := DAY
var warned := false
var me_n: Node3D
var me_p := Vector3.ZERO
var me_tgt := Vector3.ZERO
var me_st := {}
var hp_cubes: Array = []
var items: Array = []
var mobs: Array = []
var him: Dictionary = {}
var sun: MeshInstance3D
var foe: Dictionary = {}
var foe_him := false
var fseq: Array = []  # 미리 계산한 타격 순서 [{who, dmg, hp}]
var fi := 0
var ft := 0.0
var walk_t := 0.0
var step_snd := 0.0


func _setup() -> void:
	howto = "작은 섬. 땅을 탭하면 그리로 걸어간다.\n낮 동안 상자(주황=공격·파랑=방어·노랑=속도, 위 흰 칸 수=값)를 줍고 빨간 잡몹과 자동전투.\n전투는 속도 높은 쪽이 먼저, 속도 차이만큼 더 때린다. 공격-방어=피해.\n해가 지면 '그'가 가장자리에서 곧장 달려온다. 이기면 다음 날(그가 세진다). 체력 0이면 끝."
	time_limit = 0.0
	cam.fov = 48.0
	cam.position = Vector3(0, 25.0, 9.0)
	cam.look_at(Vector3(0, 0, -0.5))


func _reset() -> void:
	day = 1
	me_st = {"atk": 2, "def": 0, "spd": 1, "hp": HP0}
	box(Vector3(0, -0.35, 0), Vector3(60, 0.2, 70), WATER)
	box(Vector3(0, -0.1, 0), Vector3(HW * 2.0, 0.3, HH * 2.0), SOFT)
	for k in 7:
		var gp := Vector3(randf_range(-HW + 1.0, HW - 1.0), 0.05, randf_range(-HH + 1.0, HH - 1.0))
		box(gp, Vector3(randf_range(1.0, 2.2), 0.06, randf_range(1.0, 2.2)), GOOD.lightened(0.5))
	sun = box(Vector3(-HW - 1.0, 1.0, -HH - 2.0), Vector3(1.3, 1.3, 1.3), D)
	me_n = Node3D.new()
	world.add_child(me_n)
	box(Vector3(0, 0.45, 0), Vector3(0.8, 0.9, 0.8), ME, me_n)
	box(Vector3(0, 0.75, -0.42), Vector3(0.5, 0.18, 0.08), WHITE, me_n)
	hp_cubes.clear()
	for i in HP0:
		hp_cubes.append(box(Vector3(-1.1 + i * 0.2, 1.45, 0), Vector3(0.16, 0.16, 0.16), GOOD, me_n))
	items.clear()
	for i in NITEM:
		var r := Node3D.new()
		world.add_child(r)
		var body := box(Vector3(0, 0.35, 0), Vector3(0.7, 0.7, 0.7), A, r)
		var tops: Array = []
		for k in 3:
			tops.append(box(Vector3(-0.25 + k * 0.25, 0.82, 0), Vector3(0.18, 0.18, 0.18), WHITE, r))
		items.append({"n": r, "body": body, "tops": tops, "kind": "atk", "val": 1, "p": Vector3.ZERO, "on": false})
	mobs.clear()
	for i in NMOB:
		var r := Node3D.new()
		world.add_child(r)
		var body := box(Vector3(0, 0.4, 0), Vector3(0.8, 0.8, 0.8), BAD, r)
		box(Vector3(0, 0.2, -0.42), Vector3(0.5, 0.12, 0.08), WHITE, r)
		mobs.append({"n": r, "body": body, "p": Vector3.ZERO, "st": {}, "on": false, "dir": Vector3.ZERO, "wt": 0.0})
	var hr := Node3D.new()
	world.add_child(hr)
	var hb := box(Vector3(0, 1.1, 0), Vector3(1.4, 2.2, 1.4), C, hr)
	him = {"n": hr, "body": hb, "p": Vector3.ZERO, "st": {}, "on": false}
	hr.visible = false
	walk_t = 0.0
	_new_day()


func _new_day() -> void:
	mode = "day"
	back_mode = "day"
	day_t = DAY
	warned = false
	me_p = Vector3.ZERO
	me_tgt = me_p
	me_n.position = me_p
	me_n.rotation = Vector3.ZERO
	me_st.hp = HP0
	_hp_show()
	him.on = false
	him.n.visible = false
	him.st = {"atk": 3 + 2 * day, "def": day, "spd": 2 + day, "hp": 8 + 4 * day}
	sun.visible = true
	for it in items:
		it.p = _spot(2.0)
		it.kind = KINDS.pick_random()
		it.val = 1 + (randi() % 2) + (1 if day > 1 and randf() < 0.25 else 0)
		it.body.material_override = mat(KCOL[it.kind])
		for k in 3:
			it.tops[k].visible = k < it.val
		it.n.position = it.p
		it.n.visible = true
		it.on = true
	for mb in mobs:
		mb.p = _spot(3.5)
		mb.st = {"atk": 2 + day, "def": day / 2, "spd": 1 + day / 2, "hp": 4 + 2 * day}
		mb.dir = Vector3.ZERO
		mb.wt = randf_range(0.5, 1.5)
		mb.n.position = mb.p
		mb.n.visible = true
		mb.on = true
		_size(mb, 0.3)
	msg("%d일째" % day, 1.2)


func _spot(away: float) -> Vector3:
	for k in 20:
		var p := Vector3(randf_range(-HW + 0.8, HW - 0.8), 0, randf_range(-HH + 0.8, HH - 0.8))
		if p.length() >= away:
			return p
	return Vector3(HW - 1.0, 0, HH - 1.0)


func _clamp(p: Vector3) -> Vector3:
	return Vector3(clampf(p.x, -HW + 0.5, HW - 0.5), 0, clampf(p.z, -HH + 0.5, HH - 0.5))


func _speed() -> float:
	return 2.4 + 0.35 * float(me_st.spd)


func _hp_show() -> void:
	for i in hp_cubes.size():
		hp_cubes[i].visible = i < me_st.hp


## 잡몹·그의 키 = 남은 체력
func _size(who: Dictionary, base: float) -> void:
	var h: float = base + 0.1 * float(who.st.hp)
	who.body.scale.y = h
	who.body.position.y = h * 0.5


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	if mode == "fight":
		_fight(dt)
		return
	# 걷기
	var d := me_tgt - me_p
	if d.length() > 0.08:
		me_p += d.normalized() * minf(d.length(), _speed() * dt)
		me_n.rotation.y = atan2(-d.x, -d.z)
		walk_t += dt
		step_snd -= dt
		if step_snd <= 0.0:
			step_snd = 0.9 / _speed()
			beep(190.0, 0.03, 0.0, 0.1)
	me_n.position = me_p + Vector3(0, absf(sin(walk_t * 11.0)) * 0.08, 0)
	# 줍기
	for it in items:
		if it.on and it.p.distance_to(me_p) < 0.95:
			it.on = false
			it.n.visible = false
			me_st[it.kind] += it.val
			score += 1
			play("good")
			msg("%s+%d" % [KNAME[it.kind], it.val], 0.6)
	# 잡몹 어슬렁
	for mb in mobs:
		if not mb.on:
			continue
		mb.wt -= dt
		if mb.wt <= 0.0:
			mb.wt = randf_range(1.0, 2.5)
			mb.dir = Vector3.ZERO if randf() < 0.4 else Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		if mb.dir != Vector3.ZERO:
			mb.p = _clamp(mb.p + mb.dir * 1.1 * dt)
			mb.n.rotation.y = atan2(-mb.dir.x, -mb.dir.z)
		mb.n.position = mb.p
		if mb.p.distance_to(me_p) < 1.0:
			_begin_fight(mb, false)
			return
	if mode == "day":
		day_t -= dt
		var k := 1.0 - day_t / DAY
		sun.position = Vector3(-HW - 1.0 + k * (HW + 1.0) * 2.0, 0.6 + 6.0 * sin(k * PI), -HH - 2.0)
		if day_t < 5.0 and not warned:
			warned = true
			msg("해가 진다", 1.0)
			beep(330.0, 0.3, 180.0, 0.25)
		if day_t <= 0.0:
			_night()
		gauge(day_t / DAY, D)
	else:
		var hd: Vector3 = me_p - him.p
		var dist: float = hd.length()
		var hv := _speed() * 1.25 + 0.6
		if dist > 0.01:
			him.p += hd.normalized() * minf(dist, hv * dt)
			him.n.rotation.y = atan2(-hd.x, -hd.z)
		him.n.position = him.p + Vector3(0, absf(sin(day_t * 14.0)) * 0.15, 0)
		day_t -= dt  # 밤에는 흔들림 시계로 쓴다
		gauge(1.0 - clampf(dist / 20.0, 0.0, 1.0), BAD)
		if dist < 1.2:
			_begin_fight(him, true)


func _night() -> void:
	mode = "night"
	back_mode = "night"
	day_t = 0.0
	sun.visible = false
	var side := randi() % 4
	match side:
		0: him.p = Vector3(-HW + 0.5, 0, randf_range(-HH, HH))
		1: him.p = Vector3(HW - 0.5, 0, randf_range(-HH, HH))
		2: him.p = Vector3(randf_range(-HW, HW), 0, -HH + 0.5)
		_: him.p = Vector3(randf_range(-HW, HW), 0, HH - 0.5)
	him.on = true
	him.n.visible = true
	him.n.position = him.p
	_size(him, 0.8)
	msg("그가 온다", 1.5)
	beep(110.0, 0.5, 70.0, 0.35)


# ---- 자동전투 ----
func _begin_fight(f: Dictionary, is_him: bool) -> void:
	if mode != "fight":
		back_mode = mode
	mode = "fight"
	foe = f
	foe_him = is_him
	me_tgt = me_p
	me_n.position = me_p
	var a: Dictionary = me_st.duplicate()
	var b: Dictionary = f.st.duplicate()
	var me_first: bool = a.spd >= b.spd
	var extra: int = absi(int(a.spd) - int(b.spd))
	fseq.clear()
	var guard := 0
	while a.hp > 0 and b.hp > 0 and guard < 300:
		guard += 1
		var order: Array = [[0, 1 + extra], [1, 1]] if me_first else [[1, 1 + extra], [0, 1]]
		for o in order:
			for n in o[1]:
				if o[0] == 0:
					var dmg: int = maxi(1, int(a.atk) - int(b.def))
					b.hp -= dmg
					fseq.append({"who": 0, "dmg": dmg, "hp": b.hp})
					if b.hp <= 0:
						break
				else:
					var dmg: int = maxi(1, int(b.atk) - int(a.def))
					a.hp -= dmg
					fseq.append({"who": 1, "dmg": dmg, "hp": a.hp})
					if a.hp <= 0:
						break
			if a.hp <= 0 or b.hp <= 0:
				break
	fi = 0
	ft = 0.7
	msg("공%d 방%d 속%d" % [f.st.atk, f.st.def, f.st.spd], 0.7)
	beep(300.0, 0.15, 520.0, 0.25)


func _fight(dt: float) -> void:
	var fd: Vector3 = foe.p - me_p
	var dir: Vector3 = fd.normalized() if fd.length() > 0.01 else Vector3(0, 0, -1)
	if ft > 0.0:
		ft -= dt
		if fi > 0:
			var k := 1.0 - ft / STRIKE
			var lunge := sin(clampf(k, 0.0, 1.0) * PI) * 0.6
			var s: Dictionary = fseq[fi - 1]
			if s.who == 0:
				me_n.position = me_p + dir * lunge
				foe.n.position = foe.p
			else:
				foe.n.position = foe.p - dir * lunge
				me_n.position = me_p
		return
	me_n.position = me_p
	foe.n.position = foe.p
	if fi >= fseq.size():
		_end_fight()
		return
	var s: Dictionary = fseq[fi]
	fi += 1
	ft = STRIKE
	if s.who == 0:
		foe.st.hp = maxi(0, s.hp)
		_size(foe, 0.8 if foe_him else 0.3)
		beep(640.0, 0.07, 0.0, 0.25)
		msg("-%d" % s.dmg, 0.3)
	else:
		me_st.hp = maxi(0, s.hp)
		_hp_show()
		beep(170.0, 0.1, 0.0, 0.3)
		msg("나 -%d" % s.dmg, 0.3)


func _end_fight() -> void:
	if me_st.hp <= 0:
		me_n.rotation.z = PI * 0.5
		msg("죽었다", 1.5)
		end()
		return
	if foe_him:
		score += 5 * day
		day += 1
		play("win")
		_new_day()
		return
	foe.on = false
	foe.n.visible = false
	score += 2
	me_st.hp = mini(HP0, me_st.hp + 2)
	_hp_show()
	play("good")
	msg("이겼다", 0.6)
	mode = back_mode


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	if mode == "fight":
		return
	me_tgt = _clamp(ground(p))
	beep(520.0, 0.04, 0.0, 0.1)


func _drag(p: Vector2) -> void:
	if mode == "fight":
		return
	me_tgt = _clamp(ground(p))
