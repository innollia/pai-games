extends Tofu
## 1인칭 깊은 검(deepsword 돌연변이). 긴 칼이 화면 앞에 있다. 오른쪽을 위아래로 끌면 칼이 들리고 내려가고, 왼쪽 조이스틱으로 걷는다.
## 칼을 빠르게 내리꽂으면 바닥·턱에 박히고 그 점을 축으로 몸이 넘어가며 시야도 같이 돈다(장대 넘기). 빨리 돌릴수록 멀리 난다.
## 긴 칼을 빨리 돌리다 천장·벽에 걸리면 튕기고, 너무 빠르게 박히면 죽는다(목숨 3). 용암 구덩이도 죽음.
## 통로 끝 빨간 심장에 칼끝을 대면 칼이 1.5배 길어지고 다음 통로는 상대적으로 좁다. 끝없이.

const G := 18.0
const L0 := 1.6
const HALF := Vector2(0.35, 0.5)  # 몸 반쪽 크기 (x 앞뒤, y 위아래)
const EYE := 0.3  # 몸 가운데에서 눈까지
const DEADV := 15.0  # 이보다 빠르게 박히면 죽음
const WMAX := 16.0  # 칼 각속도 한계(rad/s)
const KICKW := 3.5  # 이보다 빨리 돌리다 벽에 걸리면 튕긴다
const PLANTW := 1.2  # 서 있을 때 이보다 빨리 내리꽂아야 바닥에 박힌다
const WALK := 3.0
const SEG := 9.0  # 한 구간 길이
const TW := 4.4  # 통로 너비(좌우)
const LOOK_K := 0.015  # 룩패드 1픽셀 = 라디안
const ROCK := Color("b8c4d4")

var walls: Array[Rect2] = []
var lavas: Array[Rect2] = []
var heart := Rect2()
var stage_n: Node3D
var stg := 0
var lives := 3
var slen := L0  # 칼 길이
var ch := 5.0  # 천장 높이
var seglen := 0.0  # 통로 길이
var start := Vector2.ZERO
var pos := Vector2.ZERO  # 몸 가운데 (x 앞, y 위)
var vel := Vector2.ZERO
var th := -0.3  # 칼 각도(x축에서 반시계, 위가 +)
var w_in := 0.0  # 손가락이 준 각속도
var w_g := 0.0  # 중력·관성 각속도
var dth := 0.0  # 이번 프레임 손가락 회전량
var planted := false
var pivot := Vector2.ZERO
var pnorm := Vector2(0, 1)
var pd := 1.0  # 몸에서 축까지 거리
var plant_py := 0.0
var on_ground := false
var rest := false  # 바닥에 서 있는 상태(여기서 밀려 박히는 건 약하게)
var body_rot := 0.0  # 축을 돌며 쌓인 몸의 기울기(시야 피치)
var plant_t := 0.0
var free_t := 0.0  # 넘기로 빠진 직후 다시 안 박히는 시간
var die_t := 0.0
var clear_t := 0.0
var swing_t := 0.0
var step_t := 0.0
var shake := 0.0
var clock := 0.0
var sword: Node3D
var blade: MeshInstance3D
var heart_m: MeshInstance3D
# 용암 밀물: 통로 전체 바닥 아래에서 차오른다. 서 있기만 하면 죽는다. 턱 위가 잠깐의 피난처
const TIDE0 := -2.6
var tide_y := TIDE0
var tide_rate := 0.1  # m/s, 통로 길이에 맞춰 _build 에서 정한다(평균 2 m/s 로 가야 심장에 닿음)
var tide_m: MeshInstance3D
var tide_beep_t := 0.0


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 72.0
	kit_stick()
	kit_lookpad()
	howto = "오른쪽을 위아래로 끌어 칼을 들고 내린다. 왼쪽 조이스틱으로 걷는다.\n칼을 빠르게 내리꽂으면 바닥·턱에 박히고 그 점을 축으로 몸이 넘어간다. 빨리 돌릴수록 멀리 난다.\n통로 끝 빨간 심장에 칼끝을 대면 칼이 1.5배 길어지고 다음 통로는 더 좁다.\n용암에 빠지거나 너무 빠르게 벽·바닥에 박히면 죽는다(목숨 3).\n바닥 밑에서 용암이 차오른다. 서 있으면 죽는다. 턱 위는 잠깐 안전."


func _reset() -> void:
	stg = 0
	lives = 3
	stage_n = null
	sword = Node3D.new()
	world.add_child(sword)
	blade = box(Vector3.ZERO, Vector3.ONE, WHITE, sword)
	box(Vector3(0, 0, 0.1), Vector3(0.12, 0.6, 0.1), D, sword)  # 날밑
	box(Vector3(0, 0, 0.35), Vector3(0.14, 0.14, 0.5), INK, sword)  # 손잡이
	_build(0)


# ---- 통로: 2D(x 앞, y 위) 사각형을 좌우로 늘인 상자로 세운다 ----
func _build(s: int) -> void:
	if stage_n:
		stage_n.queue_free()
	stage_n = Node3D.new()
	world.add_child(stage_n)
	walls.clear()
	lavas.clear()
	slen = L0 * pow(1.5, s)
	ch = maxf(5.0, slen * 1.3 + 2.0)
	var n := mini(3 + s, 8)
	seglen = n * SEG + 8.0
	tide_rate = (0.0 - TIDE0) / (seglen / 2.0)  # 바닥까지 차는 데 통로길이/2 초
	tide_m = box(Vector3(0, -3.0, -(seglen - 3.0) * 0.5), Vector3(TW - 0.1, 0.01, seglen + 4.0), A, stage_n)
	var pw := 2.0 + 0.4 * s  # 구덩이 너비
	var hang := ch * 0.3
	# 옆벽(그림만)
	for sd in [-1.0, 1.0]:
		box(Vector3(sd * (TW * 0.5 + 0.2), ch * 0.5, -(seglen - 3.0) * 0.5), Vector3(0.4, ch + 2.0, seglen + 4.0), SOFT, stage_n)
	_wall(Rect2(-4.0, -3.0, 1.0, ch + 4.0))  # 뒷벽
	_wall(Rect2(seglen, -3.0, 1.0, ch + 4.0))  # 끝벽
	_wall(Rect2(-4.0, ch, seglen + 5.0, 1.0))  # 천장
	var fx := -4.0  # 바닥 조각이 시작하는 x
	for i in n:
		var x0 := i * SEG + 3.0
		var ledge_h := 1.6 + 0.3 * mini(i, 3) + 0.4 * s
		_wall(Rect2(x0 + 2.0, 0.0, 2.0, ledge_h))  # 넘어야 하는 턱
		var px := x0 + 5.5
		_wall(Rect2(fx, -1.0, px - fx, 1.0))  # 구덩이 앞까지 바닥
		_lava(Rect2(px, -1.4, pw, 0.5))
		_wall(Rect2(px - 0.5, -2.5, pw + 1.0, 1.1))  # 구덩이 밑
		fx = px + pw
		if s >= 1:
			_wall(Rect2(x0 + 8.0, ch - hang, 1.0, hang))  # 종유석
		if s >= 2:
			_wall(Rect2(px + pw * 0.5 - 0.5, ch - hang * 1.3, 1.0, hang * 1.3))  # 구덩이 위 종유석
	_wall(Rect2(fx, -1.0, seglen - fx, 1.0))
	var hx := seglen - 2.5
	heart = Rect2(hx - 0.6, 0.0, 1.2, 1.2)
	heart_m = box(Vector3(0, 0.6, -hx), Vector3(1.4, 1.2, 1.2), BAD, stage_n)
	start = Vector2(-1.5, HALF.y)
	msg("통로 %d" % (s + 1), 1.2)
	blade.position = Vector3(0, 0, -slen * 0.5)
	blade.scale = Vector3(0.14, 0.14, slen)
	_spawn()


func _wall(r: Rect2) -> void:
	walls.append(r)
	box(Vector3(0, r.get_center().y, -r.get_center().x), Vector3(TW, r.size.y, r.size.x), ROCK, stage_n)


func _lava(r: Rect2) -> void:
	lavas.append(r)
	box(Vector3(0, r.get_center().y, -r.get_center().x), Vector3(TW, r.size.y, r.size.x), A, stage_n)


func _spawn() -> void:
	pos = start
	vel = Vector2.ZERO
	th = -0.3
	w_in = 0.0
	w_g = 0.0
	dth = 0.0
	planted = false
	on_ground = true
	rest = true
	body_rot = 0.0
	die_t = 0.0
	clear_t = 0.0
	shake = 0.0
	tide_y = TIDE0
	tide_beep_t = 0.0
	_view(0.0)


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
	# 룩패드 위아래 = 칼 다이얼 (아래로 끌면 칼이 내려간다)
	dth = -kit_look.y * LOOK_K
	if absf(dth) > 0.0001:
		w_in = lerpf(w_in, clampf(dth / h, -WMAX, WMAX), 0.6)
	else:
		w_in *= exp(-10.0 * h)
	dth = 0.0
	plant_t -= h
	free_t -= h
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
	var tipv := om * (pd if planted else slen) / DEADV
	gauge(tipv, GOOD if tipv < 0.5 else (D if tipv < 1.0 else BAD))
	swing_t -= dt
	if om > 3.0 and swing_t <= 0.0:
		swing_t = 0.1
		beep(250.0 + om * 35.0, 0.03, 0.0, 0.1)
	score = stg * 10 + clampi(int((pos.x - 3.0) / SEG) + 1, 0, 9)
	# 용암 밀물: 발밑 1m 안으로 오면 박자가 빨라지는 경고음
	tide_y += tide_rate * dt
	var gap := pos.y - HALF.y - tide_y
	if gap < 1.0:
		tide_beep_t -= dt
		if tide_beep_t <= 0.0:
			tide_beep_t = clampf(gap * 0.5, 0.12, 0.5)
			beep(140.0, 0.08, 60.0, 0.25)
	_hazards()
	_view(dt)


## 칼이 박힌 채: 축을 중심으로 몸이 돈다 (진자 + 손가락). 시야도 같이 돈다
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
	# 축 바로 위를 넘어가면 칼이 빠진다(장대 넘기). 바닥에 박았을 때도 앞으로 날아가게 한다
	var a := wrapf(phi - PI * 0.5, -PI, PI)
	var b := wrapf(phi2 - PI * 0.5, -PI, PI)
	var over_top := pnorm.y > 0.5 and a * b <= 0.0 and absf(a - b) < 1.0
	if over_top or (p2 - pivot).dot(pnorm) < 0.15 * pd:
		planted = false
		free_t = 0.3
		vel = tang * om * pd
		w_g = 0.0
		pos = p2
		th = phi2 - PI
		body_rot += om * h
		beep(400.0, 0.1, 900.0, 0.2)
		return
	pos = p2
	th = phi2 - PI
	body_rot += om * h
	if pos.y > plant_py + 0.4:
		rest = false


## 자유 낙하·걷기. 칼을 돌리다 벽에 걸리면 튕기고, 칼끝이 벽에 닿으면 박힌다
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
	if on_ground:
		vel.x *= exp(-5.0 * h)
		# 걷기: 조이스틱 좌우 (앞이 +)
		if absf(kit_move.x) > 0.1:
			vel.x = move_toward(vel.x, kit_move.x * WALK, 20.0 * h)
			step_t -= h * absf(vel.x)
			if step_t <= 0.0:
				step_t = 1.4
				beep(110.0, 0.04, 0.0, 0.12)
	var imp := _move(h)
	if imp > DEADV:
		_die("머리부터!")
		return
	if on_ground:
		rest = true
	body_rot = lerpf(body_rot, 0.0, 1.0 - exp(-4.0 * h))
	var slow := on_ground and absf(om) < PLANTW
	if slow:
		# 서서 천천히 내리면 칼끝이 발 높이까지만 내려간다(바닥에 안 박힘)
		var lo := -asin(minf(HALF.y / slen, 1.0))
		if th < lo and th > -PI * 0.5:
			th = lo
	if free_t > 0.0:
		return  # 장대 넘기로 막 빠진 칼은 잠깐 다시 안 박힌다(바로 옆 바닥에 연쇄로 박히는 것 막기)
	var tip := pos + Vector2(cos(th), sin(th)) * slen
	var r := _wall_at(tip)
	if r.size.x > 0.0:
		if not slow or r.end.y > pos.y - HALF.y + 0.2:
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
			imp = maxf(imp, absf(vel.x))
			pos.x = w.position.x - HALF.x - 0.001 if vel.x > 0.0 else w.end.x + HALF.x + 0.001
			vel.x = 0.0
			r = _body_rect()
	pos.y += vel.y * h
	r = _body_rect()
	on_ground = false
	for w in walls:
		if w.intersects(r):
			imp = maxf(imp, absf(vel.y))
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
	if pos.y < -6.0:
		_die("추락")
		return
	if pos.y - HALF.y < tide_y:
		_die("용암이 차올랐다!")
		return
	var tip := pos + Vector2(cos(th), sin(th)) * slen
	if heart.grow(0.2).has_point(tip):
		_clear()


func _die(why: String) -> void:
	die_t = 1.0
	lives -= 1
	planted = false
	vel = Vector2.ZERO
	w_in = 0.0
	w_g = 0.0
	shake = maxf(shake, 0.5)
	play("bad")
	msg(why, 1.0)


func _clear() -> void:
	clear_t = 1.4
	planted = false
	vel = Vector2.ZERO
	w_in = 0.0
	w_g = 0.0
	heart_m.material_override = mat(D)
	play("win")
	msg("심장! 칼이 길어진다", 1.3)


# ---- 그리기: 2D(x 앞, y 위) -> 3D(z 뒤가 -x) ----
func _view(dt: float) -> void:
	var eye := Vector3(0, pos.y + EYE, -pos.x)
	sword.position = eye + Vector3(0.3, -0.25, 0)
	sword.rotation = Vector3(th, 0, 0)
	var pulse := 1.2 + sin(clock * 6.0) * 0.1
	heart_m.scale = Vector3(1.4, pulse, pulse)
	tide_m.position.y = (tide_y - 3.0) * 0.5
	tide_m.scale.y = maxf(tide_y + 3.0, 0.01)
	var sp := absf(w_in + w_g) * pd if planted else vel.length()
	shake = maxf(shake - dt * 1.5, 0.0)
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 0.06
	# 시야: 몸이 축을 돌며 기운 만큼 피치가 돌고, 칼 쪽을 조금 본다
	var pitch := clampf(body_rot, -1.3, 1.3) + clampf(th, -0.8, 0.8) * 0.25
	if die_t > 0.0:
		pitch = -0.9 + (1.0 - die_t) * 0.3
	cam.position = eye + Vector3(off.x, off.y, 0)
	cam.rotation = Vector3(pitch, 0, off.x * 2.0)
	cam.fov = 72.0 + clampf(sp, 0.0, 20.0) * 0.9
