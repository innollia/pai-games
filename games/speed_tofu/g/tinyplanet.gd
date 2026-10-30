extends Tofu
## 작은 행성(등뒤 3인칭, 구면 중력): 왼쪽 스틱으로 달린다. 중력이 약해서 빨리 달리면 원심력에 발이 뜨고(조종 불가), 이륙 근처에서 점프를 보태면 궤도 에너지가 탈출선을 넘어 하늘로 날아가 죽는다.
## 나는 [약한 중력의 작은 행성 등대지기]로서 [빨리 달리면 발이 뜨는 몸] 속에서 [불씨를 모아 등대에 나르]지만 [뜨면 조종을 잃고 더 빠르면 영영 떠나는 것]을 감수한다.
## 루프: 운석 그림자가 나를 겨냥해 찍힌다 → 땅을 붙들고 비키거나 떠서 넘는다 → 크레이터에 불씨가 생긴다 → 주워(머리 위 3개) 꼭대기 등대에 넣는다 → 등대가 켜지면 다음(더 작은) 행성.
## 히든: 별자리 표식 위에서 떠나면 죽지 않고 별길로 다음 행성에 간다. 목숨 3.

const TOP := 12.5  # 땅에서 낼 수 있는 최고 속도
const ACC := 7.0
const GRIP := 1.19  # 발이 땅을 붙드는 힘 (g 에 더해진다). R=12 에서 이륙 속도 ≈ 10.5
const JUMP := 5.0
const AIRJUMP := 4.5
const LAND_K := 0.55  # 착지 때 남는 접선 속도 비율
const GREY := Color("c9ccd1")
const SKY := Color("dcd6ff")
const NE := 6  # 불씨 칸
const NM := 4  # 운석 칸
const PLANETS := [
	{"r": 12.0, "n": 5, "need": 5, "gap": 4.0, "mark": Vector3(-1.0, -0.35, 0.6)},
	{"r": 8.0, "n": 4, "need": 6, "gap": 3.0, "mark": Vector3(0.7, -0.5, -0.8)},
]
const G := 8.0
const MR := 3.2  # 별자리 표식 반경: 이 안에서 이륙 속도로 점프하면 별길로 떠난다
const TOWER := Vector3(0.45, 0.85, 0.3)  # 등대 옆 높은 탑 (방향)
const TOWER_H := 5.0
const DRAG := 0.12  # 공중 공기 저항 (뜬 시간이 길수록 세진다)
const ICE_GRIP := -0.8  # 얼음 바닥: 발이 덜 붙어 쉽게 뜬다

var pi_ := 0  # 행성 번호
var R := 12.0
var mu := 0.0
var need := 5
var gap := 4.0
var mark := Vector3.ZERO  # 별자리 표식 (표면 점)
var pl: Node3D  # 행성 노드 (바꿀 때 통째로 버린다)
var tiles: Array[MeshInstance3D] = []
var tdir: PackedVector3Array = PackedVector3Array()
var crater: Array[bool] = []
# 나
var me: Node3D
var hearts: Array[MeshInstance3D] = []
var carry_b: Array[MeshInstance3D] = []
var p := Vector3.ZERO
var vel := Vector3.ZERO
var fwd := Vector3.FORWARD  # 몸이 보는 접선 방향
var cfwd := Vector3.FORWARD  # 카메라가 따르는 접선 방향
var grounded := true
var airjump := false
var launch := Vector3.ZERO  # 이륙한 표면 점
var carry := 0
var lives := 3
var delivered := 0
var die_t := 0.0
var clear_t := 0.0
var gone := false  # 탈출선을 넘어 떠나는 중
var step_d := 0.0
var air_t := 0.0
var warn_t := 0.0
var shake := 0.0
var mark_told := false
var clock := 0.0
var rng := RandomNumberGenerator.new()
# 등대·표식·멀리 보이는 다음 행성
var lamp: MeshInstance3D
var far_b: MeshInstance3D
var far_moon: MeshInstance3D
var mstars: Array[MeshInstance3D] = []
var beacon: MeshInstance3D
var fly_t := 0.0  # 이번에 뜬 뒤 지난 시간
var tower_cd := 0.0
var zone_now := -1
var ready_told := false
# 불씨
var eon: Array[bool] = []
var edir: PackedVector3Array = PackedVector3Array()
var eb: Array[MeshInstance3D] = []
# 운석: phase 0 없음, 1 경고, 2 낙하
var mph: PackedInt32Array = PackedInt32Array()
var mdir: PackedVector3Array = PackedVector3Array()
var mt: PackedFloat32Array = PackedFloat32Array()
var mb: Array[MeshInstance3D] = []
var msh: Array[MeshInstance3D] = []
var spawn_t := 0.0


func _setup() -> void:
	time_limit = 0.0
	howto = "왼쪽 스틱으로 달린다(많이 밀수록 빠름). 빨리 달리면 발이 뜬다. 뜬 동안은 공기 저항으로 서서히 내려오고, 스틱을 뒤로 당기면 더 빨리 내려온다.\n뜬 채로 점프를 더 보태면 하늘로 날아가 버린다(죽음).\n구역: 갈색 = 운석 지대(그림자 빨강 피하기, 불씨가 생김), 하늘색 = 얼음(미끄럽고 쉽게 뜸), 등대 옆 탑 = 들어가면 꼭대기에서 뛰어내린다.\n불씨를 주워 꼭대기 등대에 넣는다. 목숨 3.\n비밀: 빛기둥이 선 별자리 표식 위에서 빨리 달리다 점프하면… 하늘의 파란 행성으로."
	kit_stick()
	kit_button("jump", "점프", Vector2(580, 1070), 110.0, A)
	for ch in get_children():
		if ch is WorldEnvironment:
			(ch as WorldEnvironment).environment.background_color = SKY


func _reset() -> void:
	rng.randomize()
	pi_ = 0
	lives = 3
	# 별(먼 흰 상자)과 해
	for i in 24:
		var d := Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
		box(d * 110.0, Vector3.ONE * rng.randf_range(0.8, 2.0), WHITE)
	box(Vector3(60, 80, -70), Vector3(8, 8, 8), D)
	far_b = box(Vector3.ZERO, Vector3(6, 6, 6), B)
	far_moon = box(Vector3.ZERO, Vector3(1.6, 1.6, 1.6), WHITE)
	# 나: 몸, 머리, 눈, 목숨 3, 들고 있는 불씨 3
	me = Node3D.new()
	world.add_child(me)
	box(Vector3(0, 0.5, 0), Vector3(0.8, 1.0, 0.6), ME, me)
	box(Vector3(0, 1.3, 0), Vector3(0.7, 0.6, 0.6), ME, me)
	box(Vector3(-0.17, 1.4, -0.31), Vector3(0.14, 0.14, 0.04), WHITE, me)
	box(Vector3(0.17, 1.4, -0.31), Vector3(0.14, 0.14, 0.04), WHITE, me)
	hearts.clear()
	for i in 3:
		hearts.append(box(Vector3(-0.3 + 0.3 * i, 1.85, 0), Vector3(0.18, 0.18, 0.18), BAD, me))
	carry_b.clear()
	for i in 3:
		var cb := box(Vector3(0, 2.3 + 0.45 * i, 0), Vector3(0.35, 0.35, 0.35), D, me)
		cb.visible = false
		carry_b.append(cb)
	# 불씨·운석 칸
	eon.clear()
	eb.clear()
	edir.resize(NE)
	for i in NE:
		eon.append(false)
		var e := box(Vector3.ZERO, Vector3(0.5, 0.5, 0.5), D)
		e.visible = false
		eb.append(e)
	mph.resize(NM)
	mdir.resize(NM)
	mt.resize(NM)
	mb.clear()
	msh.clear()
	for i in NM:
		mph[i] = 0
		var m := box(Vector3.ZERO, Vector3(1.2, 1.2, 1.2), INK)
		m.visible = false
		mb.append(m)
		var s := box(Vector3.ZERO, Vector3(4.4, 0.3, 4.4), BAD)
		s.visible = false
		msh.append(s)
	pl = null
	_planet(0)


## 행성 하나를 짓는다: 정육면체-구 타일, 등대(+Y 극), 별자리 표식, 멀리 다음 행성
func _planet(i: int) -> void:
	if pl:
		pl.queue_free()
	pl = Node3D.new()
	world.add_child(pl)
	pi_ = i
	var P: Dictionary = PLANETS[i]
	R = P.r
	mu = G * R * R
	need = P.need
	gap = P.gap
	var n: int = P.n
	mark = (P.mark as Vector3).normalized() * R
	tiles.clear()
	tdir.clear()
	crater.clear()
	var w := 2.0 * R / n * 1.3
	var k := 0
	for ax: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK]:
		var tu: Vector3 = Vector3.UP if absf(ax.y) < 0.5 else Vector3.RIGHT
		var tv: Vector3 = ax.cross(tu)
		for a in n:
			for b in n:
				var u := (a + 0.5) / n * 2.0 - 1.0
				var v := (b + 0.5) / n * 2.0 - 1.0
				var d := (ax + tu * u + tv * v).normalized()
				var zc: Array = [[SOFT, WHITE], [Color("d9b48a"), Color("e8c9a0")], [Color("bfe3ff"), Color("e3f4ff")]]
				var tl := box(Vector3.ZERO, Vector3.ONE, zc[_zone(d)][k % 2], pl)
				_orient(tl, d * (R - 0.5), d, Vector3(w, 1.0, w))
				tiles.append(tl)
				tdir.append(d)
				crater.append(false)
				k += 1
	# 등대: 꼭대기(+Y)
	box(Vector3(0, R + 0.6, 0), Vector3(1.6, 1.2, 1.6), GREY, pl)
	box(Vector3(0, R + 2.4, 0), Vector3(0.9, 2.6, 0.9), WHITE, pl)
	lamp = box(Vector3(0, R + 4.0, 0), Vector3(1.3, 0.8, 1.3), INK, pl)
	# 등대 옆 높은 탑: 밑동에 들어가면 꼭대기로 올라가 뛰어내린다
	var tn := TOWER.normalized()
	var tw := box(Vector3.ZERO, Vector3.ONE, GREY, pl)
	_orient(tw, tn * (R + TOWER_H * 0.5 - 0.3), tn, Vector3(1.4, TOWER_H, 1.4))
	var tcap := box(Vector3.ZERO, Vector3.ONE, A, pl)
	_orient(tcap, tn * (R + TOWER_H), tn, Vector3(1.8, 0.4, 1.8))
	tower_cd = 0.0
	# 별자리 표식: 표면에 흰 점 다섯 + 멀리서도 보이는 빛기둥
	var mu_ := mark.normalized()
	var mx := mu_.cross(Vector3.UP if absf(mu_.y) < 0.9 else Vector3.RIGHT).normalized()
	var mz := mx.cross(mu_)
	mstars.clear()
	for j in 5:
		var off := mx * (j - 2) * 0.9 + mz * sin(j * 1.3) * 0.7
		var st := box(Vector3.ZERO, Vector3.ONE, WHITE, pl)
		_orient(st, mark + off + mu_ * 0.2, mu_, Vector3(0.45, 0.35, 0.45))
		mstars.append(st)
	beacon = box(Vector3.ZERO, Vector3.ONE, D, pl)
	_orient(beacon, mark + mu_ * 4.0, mu_, Vector3(0.25, 8.0, 0.25))
	ready_told = false
	zone_now = -1
	# 다음 행성은 표식이 가리키는 하늘에 떠 있다 (작은 달이 빠르게 돈다)
	far_b.position = mu_ * 50.0
	far_b.visible = i + 1 < PLANETS.size()
	far_moon.visible = far_b.visible
	# 나와 불씨·운석을 출발 상태로
	_respawn()
	for j in NE:
		eon[j] = false
		eb[j].visible = false
	for j in 3:
		_ember()
	for j in NM:
		mph[j] = 0
		mb[j].visible = false
		msh[j].visible = false
	spawn_t = 2.5
	delivered = 0
	lamp.material_override = mat(INK)
	if far_b.visible:
		msg("행성 %d — 하늘의 파란 별이 다음 행성(더 작고 빠름)" % (i + 1), 2.2)
	else:
		msg("행성 %d" % (i + 1), 1.4)


## 구역: 0 보통, 1 운석 지대(뒤쪽 반구), 2 얼음(앞쪽 아래)
func _zone(d: Vector3) -> int:
	var n := d.normalized()
	if n.z < -0.15:
		return 1
	if n.z > 0.15 and n.y < 0.6:
		return 2
	return 0


## 별길 도약: 탈출선을 넘는 위쪽 속도를 준다
func _star_boost(up: Vector3) -> void:
	var tan := vel - up * vel.dot(up)
	var vr := sqrt(maxf(1.0, 1.7 * G * R - tan.length_squared()))
	vel = tan + up * vr
	launch = up * R
	msg("별길로!", 1.0)
	beep(800.0, 0.5, 2400.0, 0.3)


func _orient(m: MeshInstance3D, at: Vector3, up: Vector3, sz: Vector3) -> void:
	var x := up.cross(Vector3.FORWARD if absf(up.z) < 0.9 else Vector3.RIGHT).normalized()
	var z := x.cross(up)
	m.transform = Transform3D(Basis(x * sz.x, up * sz.y, z * sz.z), at)


func _respawn() -> void:
	p = Vector3(R, 0, 0)
	vel = Vector3.ZERO
	fwd = Vector3.FORWARD
	cfwd = Vector3.FORWARD
	grounded = true
	airjump = false
	gone = false
	carry = 0
	for cb in carry_b:
		cb.visible = false
	for i in 3:
		hearts[i].visible = i < lives
	_place_me()


## 불씨 하나를 표면 d 에 놓는다 (d 가 없으면 아무 데나, 나와 멀리)
func _ember(d: Vector3 = Vector3.ZERO, slot := -1) -> void:
	var s := slot
	if s < 0:
		for i in NE:
			if not eon[i]:
				s = i
				break
	if s < 0:
		return
	var dd := d
	if dd.length() < 0.5:
		for tries in 20:
			dd = Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
			if dd.y < 0.8 and dd.angle_to(p.normalized()) > 0.8:
				break
	eon[s] = true
	edir[s] = dd
	eb[s].visible = true


func _step(dt: float) -> void:
	clock += dt
	var up := p.normalized()
	var r := p.length()
	if die_t > 0.0:
		die_t -= dt
		if not grounded:
			vel += -up * G * dt
			p += vel * dt
			_place_me()
		_camera(dt)
		if die_t <= 0.0:
			if lives <= 0:
				end()
			else:
				_respawn()
		return
	if clear_t > 0.0:
		clear_t -= dt
		_camera(dt)
		if clear_t <= 0.0:
			if pi_ + 1 >= PLANETS.size():
				end()
			else:
				_planet(pi_ + 1)
		return
	# 달리기 / 떠 있기
	var spd := vel.length()
	tower_cd -= dt
	_far(dt)
	if grounded:
		var zone := _zone(up)
		if zone != zone_now:
			if zone_now >= 0:
				if zone == 1:
					msg("운석 지대 — 불씨가 떨어지는 곳", 1.0)
				elif zone == 2:
					msg("얼음 — 미끄럽고 쉽게 뜬다", 1.0)
			zone_now = zone
		var grip := ICE_GRIP if zone == 2 else GRIP
		var cright := cfwd.cross(up).normalized()
		var want := Vector3.ZERO
		if kit_move.length() > 0.05:
			want = (cright * kit_move.x - cfwd * kit_move.y) * TOP
		var acc := ACC
		if zone == 2:
			acc = ACC * 0.8 if want.length() > 0.1 else 0.5
		vel = vel.move_toward(want, acc * dt)
		vel -= up * vel.dot(up)
		p += vel * dt
		up = p.normalized()
		p = up * R
		vel -= up * vel.dot(up)
		spd = vel.length()
		step_d += spd * dt
		if spd > 0.5 and step_d > 1.4:
			step_d = 0.0
			beep(140.0 + 160.0 * spd / TOP, 0.03, 0.0, 0.12)
		# 이륙 경고음: 이륙선 가까우면 잦아진다
		var lift := sqrt((G + grip) * R)
		if spd > lift * 0.8:
			warn_t -= dt
			if warn_t <= 0.0:
				warn_t = lerpf(0.5, 0.12, clampf((spd - lift * 0.8) / (lift * 0.2), 0.0, 1.0))
				beep(900.0, 0.03, 0.0, 0.1)
		var on_mark := p.distance_to(mark) < MR
		var mark_ready := on_mark and spd > lift * 0.7
		_glow(on_mark, mark_ready)
		if mark_ready and not ready_told:
			ready_told = true
			msg("표식이 빛난다 — 지금 점프!", 1.0)
		if not on_mark:
			ready_told = false
		if tower_cd <= 0.0 and p.distance_to(TOWER.normalized() * R) < 1.5:
			# 탑에 들어가 꼭대기에서 뛰어내린다
			var tn := TOWER.normalized()
			var tf := fwd - tn * fwd.dot(tn)
			if tf.length() < 0.1:
				tf = Vector3.RIGHT - tn * tn.x
			_liftoff(tn)
			p = tn * (R + TOWER_H)
			vel = tf.normalized() * maxf(spd, 7.0)
			tower_cd = 2.5
			msg("탑에서 뛰어내린다!", 0.9)
			beep(500.0, 0.3, 1200.0, 0.25)
		elif kit_just("jump"):
			_liftoff(up)
			if mark_ready:
				_star_boost(up)
			else:
				vel += up * JUMP
				if on_mark:
					msg("더 빨리 달려와서 점프", 0.8)
				beep(400.0, 0.1, 700.0, 0.2)
		elif spd * spd / R > G + grip:
			_liftoff(up)
			msg("떴다", 0.6)
			beep(600.0, 0.25, 1400.0, 0.25)
	else:
		vel += -up * G * dt
		if not gone:
			# 공기 저항: 오래 뜰수록 세져서 궤도에 갇히지 않고 내려온다
			fly_t += dt
			var vr := vel.dot(up)
			var tanv := vel - up * vr
			var tl := tanv.length()
			tanv *= maxf(0.0, 1.0 - (DRAG + 0.1 * fly_t) * dt)
			# 스틱으로 조금 조종 (뒤로 당기면 브레이크). 빨라지지는 않는다
			if kit_move.length() > 0.05:
				var cright := cfwd.cross(up).normalized()
				var sd := cright * kit_move.x - cfwd * kit_move.y
				sd -= up * sd.dot(up)
				tanv += sd * 4.0 * dt
				if tanv.length() > tl:
					tanv = tanv.normalized() * tl
			vel = tanv + up * vr
			if fly_t > 2.0:
				vel += -up * G * 0.6 * dt  # 궤도가 서서히 낮아진다
		p += vel * dt
		up = p.normalized()
		r = p.length()
		air_t -= dt
		if air_t <= 0.0:
			air_t = 0.3
			beep(300.0 + (r - R) * 25.0, 0.08, 0.0, 0.08)
		var near_mark := (up * R).distance_to(mark) < MR + 0.8
		_glow(near_mark, near_mark and not airjump)
		if kit_just("jump") and not airjump:
			airjump = true
			if near_mark and r < R + 3.0:
				_star_boost(up)
			else:
				vel += up * AIRJUMP
				beep(500.0, 0.12, 900.0, 0.2)
		var en := 0.5 * vel.length_squared() - mu / r
		if not gone and en > -mu / (3.0 * R):
			gone = true
			msg("날아간다…", 1.5)
			beep(700.0, 0.6, 2000.0, 0.3)
		if r > 3.0 * R:
			_escaped()
			return
		if r <= R and vel.dot(up) <= 0.0:
			p = up * R
			var tan := vel - up * vel.dot(up)
			vel = tan * LAND_K
			grounded = true
			gone = false
			shake = maxf(shake, 0.15)
			beep(90.0, 0.12, 50.0, 0.3)
	# 몸 방향·카메라 방향
	var tv := vel - up * vel.dot(up)
	if tv.length() > 0.3:
		fwd = tv.normalized()
	fwd = (fwd - up * fwd.dot(up)).normalized()
	cfwd = (cfwd - up * cfwd.dot(up)).normalized()
	if grounded and tv.length() > 1.0:
		cfwd = cfwd.slerp(fwd, minf(1.0, dt * 2.5)).normalized()
	_place_me()
	# 궤도 에너지 막대: 0 땅에 서 있음, 1 탈출
	var e_now := 0.5 * vel.length_squared() - mu / r
	var frac := (e_now + mu / R) / (mu / R - mu / (3.0 * R))
	gauge(frac, BAD if gone else (D if not grounded else GOOD))
	# 불씨·등대·표식
	_embers(dt, up)
	_meteors(dt, up)
	_camera(dt)


func _liftoff(up: Vector3) -> void:
	grounded = false
	airjump = false
	fly_t = 0.0
	launch = up * R


## 표식 빛: 근처면 밝게 출렁이고, 떠날 준비가 되면 노랗게 크게
func _glow(near: bool, go: bool) -> void:
	if mstars.is_empty():
		return
	var pulse := 0.5 + 0.5 * sin(clock * (10.0 if go else 3.0))
	var c := D if go else (WHITE.lerp(D, 0.55 if pulse > 0.5 else 0.25) if near else WHITE)
	var s := (1.6 + 0.5 * pulse) if go else (1.0 + 0.2 * pulse)
	var mu_ := mark.normalized()
	for st in mstars:
		st.material_override = mat(c)
		var o := st.transform.origin
		_orient(st, o, mu_, Vector3(0.45 * s, 0.35 * s, 0.45 * s))
	_orient(beacon, mark + mu_ * 4.0, mu_, Vector3(0.25 + (0.5 if go else 0.1 * pulse), 8.0, 0.25 + (0.5 if go else 0.1 * pulse)))


## 하늘의 다음 행성: 천천히 돌고 작은 달이 빠르게 돈다
func _far(dt: float) -> void:
	if not far_b.visible:
		return
	far_b.rotate_y(dt * 1.5)
	var c := far_b.position
	var ax := c.normalized()
	var bx := ax.cross(Vector3.UP if absf(ax.y) < 0.9 else Vector3.RIGHT).normalized()
	var by := ax.cross(bx)
	far_moon.position = c + (bx * cos(clock * 2.5) + by * sin(clock * 2.5)) * 6.0


func _escaped() -> void:
	if launch.distance_to(mark) < MR + 1.0:
		score += 5
		play("win")
		msg("별길!", 1.6)
		if pi_ + 1 >= PLANETS.size():
			clear_t = 0.5
		else:
			_planet(pi_ + 1)
		return
	_die("날아갔다")


func _die(why: String) -> void:
	if die_t > 0.0:
		return
	lives -= 1
	for i in 3:
		hearts[i].visible = i < lives
	die_t = 1.3
	carry = 0
	for cb in carry_b:
		cb.visible = false
	shake = 0.4
	play("bad")
	msg(why, 1.2)


func _embers(dt: float, up: Vector3) -> void:
	for i in NE:
		if not eon[i]:
			continue
		var d := edir[i]
		var at := d * (R + 0.6 + sin(clock * 3.0 + i) * 0.15)
		_orient(eb[i], at, d, Vector3(0.5, 0.5, 0.5))
		eb[i].rotate(d, clock * 2.0 + i)
		if carry < 3 and p.distance_to(d * R) < 1.3:
			eon[i] = false
			eb[i].visible = false
			carry_b[carry].visible = true
			carry += 1
			beep(800.0, 0.08, 1200.0, 0.2)
			msg("불씨 %d" % carry, 0.5)
	# 등대에 넣기
	if grounded and carry > 0 and p.distance_to(Vector3(0, R, 0)) < 2.2:
		delivered += carry
		score += carry
		carry = 0
		for cb in carry_b:
			cb.visible = false
		play("good")
		msg("%d / %d" % [delivered, need], 0.8)
		lamp.material_override = mat(D.lerp(A, 0.5))
		if delivered >= need:
			clear_t = 1.6
			lamp.scale = Vector3(2.0, 1.4, 2.0)
			play("win")
			msg("등대 켜짐", 1.5)
	# 표식 위에 서면 한 번 알려 준다
	if grounded and not mark_told and p.distance_to(mark) < 2.0:
		mark_told = true
		msg("별자리…", 1.2)
		beep(1200.0, 0.2, 1600.0, 0.15)
	# 아무 불씨도 없으면 하나 더
	var any := false
	for i in NE:
		if eon[i]:
			any = true
	if not any:
		_ember()


func _meteors(dt: float, up: Vector3) -> void:
	spawn_t -= dt
	if spawn_t <= 0.0:
		spawn_t = gap
		for i in NM:
			if mph[i] == 0:
				var d: Vector3
				if rng.randf() < 0.7 and _zone(up) == 1:
					# 나를 겨냥: 내 방향에서 조금 벗어난 곳 (달리는 중이면 앞쪽)
					var ahead := up + fwd * (0.12 + 0.25 * vel.length() / TOP)
					d = (ahead + Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(-0.2, 0.2), rng.randf_range(-0.2, 0.2))).normalized()
				else:
					# 운석 지대(뒤쪽 반구) 아무 데나
					d = Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), -rng.randf_range(0.3, 1.0)).normalized()
				if d.y > 0.9:
					d = (d + Vector3(0.5, 0, 0)).normalized()
				mph[i] = 1
				mdir[i] = d
				mt[i] = 2.2
				msh[i].visible = true
				beep(260.0, 0.1, 0.0, 0.15)
				break
	for i in NM:
		if mph[i] == 0:
			continue
		var d := mdir[i]
		mt[i] -= dt
		if mph[i] == 1:
			var pulse := 0.8 + 0.2 * sin(clock * 12.0)
			_orient(msh[i], d * (R + 0.15), d, Vector3(4.4 * pulse, 0.3, 4.4 * pulse))
			if fmod(mt[i], 0.4) < dt:
				beep(330.0, 0.04, 0.0, 0.1)
			if mt[i] <= 0.0:
				mph[i] = 2
				mt[i] = 1.1
				mb[i].visible = true
		else:
			var alt := maxf(mt[i], 0.0) / 1.1 * 22.0
			_orient(mb[i], d * (R + alt), d, Vector3(1.2, 1.2, 1.2))
			mb[i].rotate(d, clock * 5.0)
			if mt[i] <= 0.0:
				mph[i] = 0
				mb[i].visible = false
				msh[i].visible = false
				_impact(d)


## 운석이 떨어졌다: 가까우면 죽고, 가장 가까운 타일이 크레이터가 되며 불씨가 생긴다
func _impact(d: Vector3) -> void:
	shake = 0.3
	beep(60.0, 0.35, 30.0, 0.4)
	var best_i := -1
	var best_d := 1e9
	for i in tiles.size():
		var dd := tdir[i].distance_squared_to(d)
		if dd < best_d:
			best_d = dd
			best_i = i
	if best_i >= 0 and not crater[best_i]:
		crater[best_i] = true
		tiles[best_i].material_override = mat(GREY)
		tiles[best_i].position -= tdir[best_i] * 0.7
	_ember(d)
	if p.distance_to(d * R) < 2.2 and grounded:
		_die("맞았다")
	elif not grounded and (p - d * R).length() < 2.2:
		_die("맞았다")


func _place_me() -> void:
	var up := p.normalized()
	var f := (fwd - up * fwd.dot(up)).normalized()
	var x := up.cross(-f).normalized()
	me.transform = Transform3D(Basis(x, up, -f), p)


func _camera(dt: float) -> void:
	var up := p.normalized()
	var alt := maxf(p.length() - R, 0.0)
	var spd := vel.length()
	var dist := 7.0 + alt * 0.5 + spd / TOP * 1.5
	var want := p + up * (3.2 + alt * 0.3) - cfwd * dist
	if shake > 0.0:
		shake -= dt
		want += Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * shake * 1.2
	cam.position = cam.position.lerp(want, minf(1.0, dt * 5.0))
	cam.look_at(p + up * 1.0 + cfwd * 2.0, up)
	cam.fov = 60.0 + 22.0 * clampf(spd / TOP, 0.0, 1.0)
