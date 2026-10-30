extends Tofu
## 옆모습 동굴(Deepest Sword). 화면을 몸 둘레로 끌어 칼을 돌린다(다이얼). 칼끝이 땅에 박히면 그 점을 축으로 몸이 넘어간다(장대 넘기).
## 빨리 돌릴수록 멀리 날지만, 몸이 15 넘게 박히면 아프고(멍) 멍든 채 또 박히거나 21 넘게 박히면 죽는다(목숨 3). 용암도 죽음.
## 게이지 = 지금 박히면 받을 속도/15. 그냥 떨어지는 건 안 죽는다(종단속도 12). 바닥에 서면 그 자리가 체크포인트.
# 한 문장: 나는 긴 칼을 든 작은 기사로서 좁아지는 동굴 속에서 칼을 돌려 박고 넘어가 바닥의 심장을 찌르지만, 빨리 돌릴수록 박힐 때 아프고 죽는 대가를 감수한다.
## 바닥의 빨간 심장에 칼끝이 닿으면 칼이 1.5배 길어지고 다음 동굴은 더 좁다. 끝없이.

const G := 18.0
const L0 := 1.6
const HALF := Vector2(0.35, 0.45)  # 몸 반쪽 크기
const DEADV := 15.0  # 이보다 빠르게 박히면 죽음
const WMAX := 16.0  # 칼 각속도 한계(rad/s)
const KICKW := 3.5  # 이보다 빨리 돌리다 벽에 걸리면 튕긴다
const NTRAIL := 5
const FALLV := 12.0  # 그냥 떨어질 때의 종단속도(노랑). 죽음은 손가락이 만든 속도에서만
const KILLX := 1.4  # 멍 없이도 이 배수 넘게 박히면 바로 죽음
const HEAL := 5.0  # 멍이 낫는 시간
const ROCK := Color("b8c4d4")

var walls: Array[Rect2] = []
var lavas: Array[Rect2] = []
var heart := Rect2()
var stage_n: Node3D
var stg := 0
var lives := 3
var slen := L0  # 칼 길이
var hw := 4.5  # 동굴 반 너비
var rh := 6.0  # 방 높이
var bottom := 0.0
var start := Vector2.ZERO
var pos := Vector2.ZERO  # 몸 가운데
var vel := Vector2.ZERO
var th := -0.6  # 칼 각도(몸 기준, x축에서 반시계)
var w_in := 0.0  # 손가락이 준 각속도
var w_g := 0.0  # 중력·관성 각속도
var dth := 0.0  # 이번 프레임 손가락 회전량
var planted := false
var pivot := Vector2.ZERO
var pnorm := Vector2(0, 1)
var pd := 1.0  # 몸에서 축까지 거리(칼끝이면 slen, 칼 중간이 걸리면 더 짧다)
var plant_py := 0.0
var on_ground := false
var rest := false  # 바닥에 서 있는 상태(여기서 밀려 박히는 건 약하게)
var plant_t := 0.0
var die_t := 0.0
var clear_t := 0.0
var swing_t := 0.0
var shake := 0.0
var clock := 0.0
var cam_y := 0.0
var last_p := Vector2.ZERO
var trail_t := 0.0
var trail_k := 0
var me: Node3D
var torso: MeshInstance3D
var sword: Node3D
var blade: MeshInstance3D
var heart_m: MeshInstance3D
var trail: Array[MeshInstance3D] = []
var bruise_t := 0.0  # >0 이면 멍든 상태: 다음 과속 박힘은 죽음
var hit_kind := ""
var hit_pt := Vector2.ZERO
var ckpt := Vector2.ZERO
var stand_t := 0.0
var warn_t := 0.0
var mark: MeshInstance3D
var mark_t := 0.0
var flag: MeshInstance3D


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 50.0
	howto = "화면을 몸 둘레로 끌어 칼을 돌린다(다이얼처럼). 칼끝이 땅에 박히면 몸이 넘어간다.
빨리 돌릴수록 멀리 날지만 게이지(박힐 속도)가 빨강이면 박힐 때 아프다. 아픈 채 또 박히면 죽음.
바닥의 빨간 심장에 칼끝을 대면 칼이 길어진다. 서 있던 자리에서 다시 시작(목숨 3).
용암에 닿아도 죽는다."


func _reset() -> void:
	stg = 0
	lives = 3
	stage_n = null
	trail.clear()
	me = Node3D.new()
	world.add_child(me)
	torso = box(Vector3.ZERO, Vector3(HALF.x * 2.0, HALF.y * 2.0, 0.7), ME, me)
	box(Vector3(0, HALF.y + 0.2, 0), Vector3(0.4, 0.4, 0.4), SOFT, me)
	sword = Node3D.new()
	me.add_child(sword)
	blade = box(Vector3.ZERO, Vector3.ONE, WHITE, sword)
	box(Vector3(0.3, 0, 0), Vector3(0.1, 0.6, 0.12), D, sword)
	for k in NTRAIL:
		var tb := box(Vector3.ZERO, Vector3(HALF.x * 2.0, HALF.y * 2.0, 0.4), B)
		tb.visible = false
		trail.append(tb)
	mark = box(Vector3.ZERO, Vector3(0.7, 0.7, 2.4), BAD)
	mark.visible = false
	flag = box(Vector3.ZERO, Vector3(0.12, 1.4, 0.3), GOOD)
	_build(0)


# ---- 동굴 ----
func _build(s: int) -> void:
	if stage_n:
		stage_n.queue_free()
	stage_n = Node3D.new()
	world.add_child(stage_n)
	walls.clear()
	lavas.clear()
	slen = L0 * pow(1.5, s)
	hw = maxf(slen * 0.55 + 0.9, 4.5 - s * 0.8)
	rh = maxf(6.0, slen * 1.5 + 2.5)
	var n := mini(4 + s, 8)
	var gapw := maxf(2.2, 3.6 - s * 0.4)
	bottom = -n * rh
	box(Vector3(0, bottom * 0.5, -1.6), Vector3(hw * 2.0, -bottom, 0.2), SOFT, stage_n)
	_wall(Rect2(-hw - 3.0, bottom - 3.0, 3.0, 4.0 - bottom))
	_wall(Rect2(hw, bottom - 3.0, 3.0, 4.0 - bottom))
	_wall(Rect2(-hw - 3.0, 0.0, hw * 2.0 + 6.0, 1.0))
	for i in n:
		var fy := -(i + 1) * rh  # 이 방 바닥 상자의 아래 y (두께 1)
		var right := i % 2 == 0  # 구멍이 오른쪽
		if i == n - 1:
			_wall(Rect2(-hw, fy - 3.0, hw * 2.0, 4.0))
			heart = Rect2(-0.6, fy + 1.0, 1.2, 1.2)
			heart_m = box(Vector3(0, fy + 1.6, 0), Vector3(1.2, 1.2, 1.4), BAD, stage_n)
			if s >= 1:
				var far_x := -hw * 0.5 if right else hw * 0.5
				_lava(Rect2(far_x - 0.8, fy + 1.0, 1.6, 0.35))
		else:
			_wall(Rect2(-hw if right else -hw + gapw, fy, hw * 2.0 - gapw, 1.0))
			if s >= 1 and i > 0:
				_lava(Rect2(-0.8, fy + 1.0, 1.6, 0.35))
		if s >= 2 and i > 0:
			_wall(Rect2(-0.5, fy + rh * 0.6, 1.0, rh * 0.4))  # 천장 종유석
	start = Vector2(-hw + 1.2, -rh + 1.0 + HALF.y)
	ckpt = start
	msg("동굴 %d" % (s + 1), 1.2)
	blade.position = Vector3(slen * 0.5, 0, 0)
	blade.scale = Vector3(slen, 0.14, 0.14)
	_spawn()


func _wall(r: Rect2) -> void:
	walls.append(r)
	box(Vector3(r.get_center().x, r.get_center().y, 0), Vector3(r.size.x, r.size.y, 2.0), ROCK, stage_n)


func _lava(r: Rect2) -> void:
	lavas.append(r)
	box(Vector3(r.get_center().x, r.get_center().y, 0), Vector3(r.size.x, r.size.y, 1.6), A, stage_n)


func _spawn() -> void:
	pos = ckpt
	bruise_t = 0.0
	stand_t = 0.0
	flag.position = Vector3(ckpt.x - 0.5, ckpt.y + 0.25, -0.5)
	vel = Vector2.ZERO
	th = -0.6
	w_in = 0.0
	w_g = 0.0
	dth = 0.0
	planted = false
	on_ground = true
	rest = true
	die_t = 0.0
	clear_t = 0.0
	shake = 0.0
	cam_y = pos.y
	torso.material_override = mat(ME)
	for tb in trail:
		tb.visible = false


# ---- 입력: 몸을 중심으로 한 다이얼 ----
func _tap(p: Vector2) -> void:
	last_p = p


func _drag(p: Vector2) -> void:
	var bs := cam.unproject_position(me.position)
	var r0 := last_p - bs
	var r1 := p - bs
	if r0.length() > 30.0 and r1.length() > 30.0:
		var damp := clampf(minf(r0.length(), r1.length()) / 160.0, 0.15, 1.0)
		dth -= r0.angle_to(r1) * damp  # 화면은 y가 아래라 부호 반대
	last_p = p


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	var h := minf(dt, 1.0 / 30.0)
	clock += dt
	if die_t > 0.0:
		die_t -= dt
		_view(dt)
		if die_t <= 0.0:
			if lives <= 0:
				end()
			else:
				_spawn()
				msg("목숨 %d" % lives, 0.9)
		return
	if clear_t > 0.0:
		clear_t -= dt
		_view(dt)
		if clear_t <= 0.0:
			stg += 1
			_build(stg)
		return
	if held:
		w_in = lerpf(w_in, clampf(dth / h, -WMAX, WMAX), 0.6)
	else:
		w_in *= exp(-10.0 * h)
	dth = 0.0
	plant_t -= h
	var was_g := on_ground
	if planted:
		_planted(h)
	else:
		_free(h)
	if die_t > 0.0:
		_view(dt)
		return
	if on_ground and not was_g:
		beep(90.0, 0.06, 0.0, 0.2)
	var om := absf(w_in + w_g)
	# 게이지 = 지금 박히면 몸이 받을 속도 / 죽음 속도
	var dang := (om * pd if planted else maxf(vel.length(), om * slen * 0.5)) / DEADV
	gauge(minf(dang, 1.0), GOOD if dang < 0.6 else (D if dang < 1.0 else BAD))
	bruise_t = maxf(bruise_t - dt, 0.0)
	var flying := not (on_ground and rest)
	var col := ME if bruise_t <= 0.0 else A
	if flying and dang >= 0.8:
		col = D if dang < 1.0 else BAD
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = 0.12
			beep(1200.0 if dang >= 1.0 else 880.0, 0.04, 0.0, 0.15)
	torso.material_override = mat(col)
	_checkpoint(dt)
	swing_t -= dt
	if om > 3.0 and swing_t <= 0.0:
		swing_t = 0.1
		beep(250.0 + om * 35.0, 0.03, 0.0, 0.1)
	score = stg * 10 + clampi(int(-pos.y / rh), 0, 9)
	_hazards()
	_view(dt)


## 칼이 박힌 채: 축을 중심으로 몸이 돈다 (진자 + 손가락)
func _planted(h: float) -> void:
	on_ground = false
	var phi := th + PI
	w_g += -G * cos(phi) / pd * h
	w_g *= exp(-0.4 * h)
	var om := w_in + w_g
	var phi2 := phi + om * h
	var p2 := pivot + Vector2(cos(phi2), sin(phi2)) * pd
	var tang := Vector2(-sin(phi2), cos(phi2))
	var prect := _wall_at(pivot)
	if _body_hits(p2):
		planted = false
		vel = tang * om * pd * (0.25 if rest else 1.0)
		w_g = 0.0
		_free(h)
		return
	var hit := _sword_hit(p2, phi2 - PI, prect)
	if hit.x < INF:
		planted = false
		vel = tang * om * pd * 0.5 + (p2 - hit).normalized() * (minf(absf(om), WMAX) * slen * 0.5 + 2.0)
		w_in = 0.0
		w_g = 0.0
		_kick()
		return
	if (p2 - pivot).dot(pnorm) < 0.15 * pd:
		planted = false
		vel = tang * om * pd
		w_g = 0.0
		pos = p2
		th = phi2 - PI
		beep(400.0, 0.1, 900.0, 0.2)
		return
	pos = p2
	th = phi2 - PI
	if pos.y > plant_py + 0.4:
		rest = false


## 자유 낙하·미끄럼. 칼을 돌리다 벽에 걸리면 튕기고, 칼끝(또는 칼 중간)이 벽에 닿으면 박힌다
func _free(h: float) -> void:
	w_g *= exp(-8.0 * h)
	var om := w_in + w_g
	var th2 := th + om * h
	var tip2 := pos + Vector2(cos(th2), sin(th2)) * slen
	var hit := _sword_hit(pos, th2, _wall_at(tip2))
	if hit.x < INF:
		if absf(om) > KICKW:
			vel += (pos - hit).normalized() * (minf(absf(om), WMAX) * slen * 0.45 + 1.5)
			_kick()
		w_in = 0.0
		w_g = 0.0
	else:
		th = th2
	vel.y -= G * h
	if vel.y < -FALLV:  # 공기 저항: 그냥 떨어지는 건 종단속도에서 멈추고, 내던져진 속도는 천천히 준다
		vel.y = lerpf(vel.y, -FALLV, 1.0 - exp(-1.5 * h))
	if on_ground:
		vel.x *= exp(-5.0 * h)
	var imp := _move(h)
	if imp > DEADV:
		if _pain(imp):
			return
	if on_ground:
		rest = true
	var tip := pos + Vector2(cos(th), sin(th)) * slen
	var r := _wall_at(tip)
	if r.size.x > 0.0:
		_plant(tip, r)
	else:
		var mh := _sword_hit(pos, th, Rect2())
		if mh.x < INF:
			_plant(mh, _wall_at(mh))


func _plant(at: Vector2, r: Rect2) -> void:
	planted = true
	pivot = at
	pd = maxf(pos.distance_to(at), 0.5)
	pnorm = _normal(r, at)
	plant_py = pos.y
	var phi := th + PI
	w_g = vel.dot(Vector2(-sin(phi), cos(phi))) / pd
	vel = Vector2.ZERO
	if plant_t <= 0.0:
		plant_t = 0.3
		beep(1500.0, 0.05, 0.0, 0.2)


## 몸을 축마다 옮기고 벽에서 밀어낸다. 돌려주는 값은 가장 세게 박힌 속도
func _move(h: float) -> float:
	var imp := 0.0
	pos.x += vel.x * h
	var r := _body_rect()
	for w in walls:
		if w.intersects(r):
			if absf(vel.x) > imp:
				imp = absf(vel.x)
				hit_kind = "벽"
				hit_pt = pos + Vector2(signf(vel.x) * HALF.x, 0)
			pos.x = w.position.x - HALF.x - 0.001 if vel.x > 0.0 else w.end.x + HALF.x + 0.001
			vel.x = 0.0
			r = _body_rect()
	pos.y += vel.y * h
	r = _body_rect()
	on_ground = false
	for w in walls:
		if w.intersects(r):
			if absf(vel.y) > imp:
				imp = absf(vel.y)
				hit_kind = "천장" if vel.y > 0.0 else "바닥"
				hit_pt = pos + Vector2(0, signf(vel.y) * HALF.y)
			if vel.y > 0.0:
				pos.y = w.position.y - HALF.y - 0.001
			else:
				pos.y = w.end.y + HALF.y + 0.001
				on_ground = true
			vel.y = 0.0
			r = _body_rect()
	return imp


func _body_rect() -> Rect2:
	return Rect2(pos - HALF, HALF * 2.0)


func _body_hits(p: Vector2) -> bool:
	var r := Rect2(p - HALF, HALF * 2.0)
	for w in walls:
		if w.intersects(r):
			return true
	return false


func _wall_at(pt: Vector2) -> Rect2:
	for w in walls:
		if w.has_point(pt):
			return w
	return Rect2()


## 칼 중간(몸에서 0.6 ~ 끝에서 0.5 전까지)이 벽 안에 있으면 그 점, 아니면 INF
func _sword_hit(p: Vector2, ang: float, skip: Rect2) -> Vector2:
	var d := Vector2(cos(ang), sin(ang))
	var far := slen - 0.5
	for k in 6:
		var pt := p + d * lerpf(0.6, far, k / 5.0)
		for w in walls:
			if w != skip and w.has_point(pt):
				return pt
	return Vector2(INF, INF)


func _normal(r: Rect2, pt: Vector2) -> Vector2:
	var dl := pt.x - r.position.x
	var dr := r.end.x - pt.x
	var db := pt.y - r.position.y
	var du := r.end.y - pt.y
	var m := minf(minf(dl, dr), minf(db, du))
	if m == du:
		return Vector2(0, 1)
	if m == db:
		return Vector2(0, -1)
	if m == dl:
		return Vector2(-1, 0)
	return Vector2(1, 0)


## 과속 박힘: 처음은 멍(경고), 멍든 채이거나 너무 빠르면 죽음. 죽었으면 true
func _pain(imp: float) -> bool:
	var spd := "%s 쾅 %d" % [hit_kind, roundi(imp)]
	mark.position = Vector3(hit_pt.x, hit_pt.y, 0.2)
	mark.visible = true
	mark_t = 1.6
	if bruise_t > 0.0 or imp > DEADV * KILLX:
		_die(spd + (" 멍든 채!" if bruise_t > 0.0 else " 너무 빠름!"))
		return true
	bruise_t = HEAL
	vel = Vector2(0, 4.0)
	shake = maxf(shake, 0.35)
	beep(160.0, 0.15, 80.0, 0.3)
	msg(spd + ">15 아픔!", 1.3)
	return false


## 용암에서 떨어진 바닥에 잠깐 서 있으면 그 자리가 다시 시작점
func _checkpoint(dt: float) -> void:
	if not (on_ground and rest and not planted and vel.length() < 1.0):
		stand_t = 0.0
		return
	stand_t += dt
	if stand_t < 0.6 or pos.distance_to(ckpt) < 1.0:
		return
	var r := _body_rect().grow(1.2)
	for l in lavas:
		if l.intersects(r):
			return
	var deeper := pos.y < ckpt.y - rh * 0.5
	ckpt = pos
	flag.position = Vector3(ckpt.x - 0.5, ckpt.y + 0.25, -0.5)
	if deeper:
		msg("여기서 다시", 0.8)
		beep(700.0, 0.06, 1000.0, 0.15)


func _kick() -> void:
	shake = maxf(shake, 0.3)
	msg("걸림!", 0.4)
	beep(180.0, 0.12, 0.0, 0.3)
	beep(900.0, 0.04, 0.0, 0.15)


func _hazards() -> void:
	var r := _body_rect()
	for l in lavas:
		if l.intersects(r):
			_die("용암!")
			return
	if pos.y < bottom - 6.0:
		_die("추락")
		return
	var tip := pos + Vector2(cos(th), sin(th)) * slen
	if heart.grow(0.2).has_point(tip):
		_clear()


func _die(why: String) -> void:
	die_t = 1.4
	lives -= 1
	planted = false
	vel = Vector2.ZERO
	w_in = 0.0
	w_g = 0.0
	torso.material_override = mat(BAD)
	shake = maxf(shake, 0.5)
	play("bad")
	msg(why, 1.4)


func _clear() -> void:
	clear_t = 1.4
	planted = false
	vel = Vector2.ZERO
	w_in = 0.0
	w_g = 0.0
	heart_m.material_override = mat(D)
	play("win")
	msg("심장! 칼이 길어진다", 1.3)


# ---- 그리기 ----
func _view(dt: float) -> void:
	me.position = Vector3(pos.x, pos.y, 0)
	sword.rotation.z = th
	var pulse := 1.2 + sin(clock * 6.0) * 0.1
	heart_m.scale = Vector3(pulse, pulse, 1.4)
	var sp := absf(w_in + w_g) * pd if planted else vel.length()
	trail_t -= dt
	if trail_t <= 0.0:
		trail_t = 0.04
		var tb := trail[trail_k]
		trail_k = (trail_k + 1) % trail.size()
		tb.visible = sp > 8.0 and die_t <= 0.0
		tb.position = Vector3(pos.x, pos.y, -0.3)
		tb.scale = Vector3(HALF.x * 2.0, HALF.y * 2.0, 0.4)
	for tb in trail:
		tb.scale = tb.scale * maxf(0.0, 1.0 - 5.0 * dt)
	mark_t -= dt
	mark.visible = mark_t > 0.0
	cam_y = lerpf(cam_y, pos.y + 0.5, 1.0 - exp(-6.0 * dt))
	shake = maxf(shake - dt * 1.5, 0.0)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.6
	cam.position = Vector3(off.x, cam_y + off.y, 17.0 + slen * 1.2)
	cam.rotation = Vector3.ZERO
