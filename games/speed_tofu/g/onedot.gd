extends Tofu
## 점 하나: 공이 세운 판을 빠르게 지나간다. 공마다 점(못) 하나를 탭해 찍어 공을 같은 색 구멍으로 튕긴다. 점은 다음 점까지 남아 다음 공도 맞는다. 틀린 구멍·바닥·밖 = 목숨 하나(3개). 5점마다 판이 바뀐다(튕기는 벽, 공 둘에 점 하나, 움직이는 구멍, 맞으면 빨라지는 공).

const TOP := 6.4
const FLOOR := -8.0
const HALF := 5.0
const SPACING := 3.2
const HW := 0.95  # 구멍 반폭
const BR := 0.36  # 공 반지름
const DR := 0.32  # 점 반지름
const GRAV := 13.0
const KICK := 4.5  # 점이 공을 밀어내는 힘
const COLS := [A, B, C]
const TRAIL := 7
const STAGE_MSG := ["", "", "튕기는 벽", "공 둘, 점 하나", "구멍이 움직인다", "가속 공"]

var lives := 3
var stage := 1
var spd := 1.0
var el := 0.0  # 빨라진 시간
var charge := 0  # 지금 찍을 수 있는 점 수 (0 또는 1)
var gap := 0.0  # 다음 공까지
var off := 0.0  # 구멍 줄 밀림
var hx := PackedFloat32Array([-SPACING, 0.0, SPACING])
var dot: MeshInstance3D
var dot_on := false
var dot_p := Vector2.ZERO
var balls: Array[MeshInstance3D] = []
var b_on: Array[bool] = []
var b_p: Array[Vector2] = []
var b_v: Array[Vector2] = []
var b_col := PackedInt32Array()
var b_hot: Array[bool] = []
var b_hold := PackedFloat32Array()  # 출발 전 깜빡이는 시간
var trails: Array[MeshInstance3D] = []
var tr_i := PackedInt32Array()
var tr_t := 0.0
var walls: Array[MeshInstance3D] = []
var floors: Array[MeshInstance3D] = []
var bins: Array[MeshInstance3D] = []
var bin_t := PackedFloat32Array()


func _setup() -> void:
	howto = "공이 빠르게 떨어진다. 공 하나마다 점 하나를 탭해 찍을 수 있다.\n점에 튕긴 공을 같은 색 구멍에 넣으면 1점.\n점은 다음 공 때까지 남는다(초록 점 = 다시 찍을 수 있음).\n틀린 구멍·바닥·밖으로 나가면 목숨 하나, 3번이면 끝."
	time_limit = 0.0
	cam.fov = 48.0
	cam.position = Vector3(0, 2.6, 15)
	cam.look_at(Vector3(0, -0.4, 0))


func _reset() -> void:
	box(Vector3(0, (TOP + FLOOR) * 0.5, -0.7), Vector3(HALF * 2.0 + 0.6, TOP - FLOOR + 1.2, 0.4), SOFT)
	box(Vector3(0, TOP + 0.75, 0), Vector3(HALF * 2.0 + 0.6, 0.3, 0.8), D)
	walls.clear()
	for s in [-1.0, 1.0]:
		var w := box(Vector3(s * (HALF + 0.15), (TOP + FLOOR) * 0.5, 0), Vector3(0.3, TOP - FLOOR + 1.2, 0.8), D)
		w.visible = false
		walls.append(w)
	floors.clear()
	for k in 4:
		floors.append(box(Vector3.ZERO, Vector3.ONE, WHITE))
	bins.clear()
	bin_t.resize(3)
	for i in 3:
		bins.append(box(Vector3.ZERO, Vector3(HW * 2.0 - 0.1, 1.0, 0.8), COLS[i]))
		bin_t[i] = 0.0
	dot = box(Vector3.ZERO, Vector3(0.6, 0.6, 0.6), INK)
	dot.visible = false
	dot_on = false
	balls.clear()
	b_on.clear()
	b_p.clear()
	b_v.clear()
	b_hot.clear()
	b_col.resize(2)
	b_hold.resize(2)
	trails.clear()
	tr_i.resize(2)
	for i in 2:
		var m := box(Vector3.ZERO, Vector3.ONE * BR * 2.0, A)
		m.visible = false
		balls.append(m)
		b_on.append(false)
		b_p.append(Vector2.ZERO)
		b_v.append(Vector2.ZERO)
		b_hot.append(false)
		b_col[i] = 0
		b_hold[i] = 0.0
		tr_i[i] = 0
		for k in TRAIL:
			var tm := box(Vector3.ZERO, Vector3.ONE * 0.22, A)
			tm.visible = false
			trails.append(tm)
	lives = 3
	stage = 1
	spd = 1.0
	el = 0.0
	charge = 0
	gap = 0.8
	off = 0.0
	tr_t = 0.0
	_layout()


func _off(tt: float) -> float:
	return sin(tt * 1.1) * 0.8 if stage >= 4 else 0.0


## 구멍·통·바닥 조각을 지금 밀림(off)에 맞춘다
func _layout() -> void:
	for i in 3:
		hx[i] = (i - 1) * SPACING + off
		bins[i].position = Vector3(hx[i], FLOOR - 0.7, 0)
		bins[i].scale.y = 1.0 + bin_t[i] * 3.0
	var e := [-HALF - 0.3, hx[0] - HW, hx[0] + HW, hx[1] - HW, hx[1] + HW, hx[2] - HW, hx[2] + HW, HALF + 0.3]
	for k in 4:
		var a: float = e[k * 2]
		var b: float = e[k * 2 + 1]
		floors[k].position = Vector3((a + b) * 0.5, FLOOR - 0.25, 0)
		floors[k].scale = Vector3(maxf(b - a, 0.02), 0.5, 0.8)


## 한 걸음 (점은 빼고). 돌려줌 [p, v, 일]: 0 없음, 1 벽·천장, 10+i 구멍 i, -1 바닥, -2 밖
func _phys(p: Vector2, v: Vector2, h: float, ox: float) -> Array:
	v.y -= GRAV * h
	p += v * h
	var ev := 0
	if p.y + BR > TOP + 0.6 and v.y > 0.0:
		v.y = -v.y * 0.9
		ev = 1
	if stage >= 2:
		if absf(p.x) + BR > HALF and p.x * v.x > 0.0:
			v.x = -v.x * 0.95
			ev = 1
	elif absf(p.x) > HALF + 0.8:
		return [p, v, -2]
	if p.y - BR <= FLOOR:
		for i in 3:
			if absf(p.x - ((i - 1) * SPACING + ox)) <= HW - BR * 0.3:
				return [p, v, 10 + i]
		return [p, v, -1]
	return [p, v, ev]


## 점 없이 그냥 두면 어느 구멍으로 가는지 (-1 = 구멍 아님)
func _sim(p: Vector2, v: Vector2, t0: float) -> int:
	var h := 1.0 / 60.0
	for k in 400:
		var r := _phys(p, v, h, _off(t0 + k * h))
		p = r[0]
		v = r[1]
		var ev: int = r[2]
		if ev >= 10:
			return ev - 10
		if ev < 0:
			return -1
	return -1


func _launch(i: int, n: int) -> void:
	var p: Vector2
	var v: Vector2
	if stage >= 2 and randf() < 0.4:
		var s := -1.0 if randf() < 0.5 else 1.0
		p = Vector2(s * (HALF - 0.6), randf_range(1.0, 5.0))
		v = Vector2(-s * randf_range(3.0, 6.5), randf_range(-1.0, 4.0))
	else:
		p = Vector2(randf_range(-4.0, 4.0), TOP - 0.2)
		v = Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 0.5))
	if n == 2 and i == 1 and p.distance_to(b_p[0]) < 2.5:
		p.x = -p.x if absf(p.x) > 1.3 else p.x + 3.0
	b_p[i] = p
	b_v[i] = v
	b_on[i] = true
	b_hold[i] = 0.4
	b_hot[i] = stage >= 5 and randf() < 0.5
	var hold_el := 0.4 * spd
	var land := _sim(p, v, el + hold_el)
	var c := randi() % 3
	if land >= 0:
		c = (land + 1 + randi() % 2) % 3  # 그냥 두면 틀리게
	b_col[i] = c
	balls[i].material_override = mat(COLS[c])
	balls[i].scale = Vector3.ONE * BR * (2.4 if b_hot[i] else 2.0)
	balls[i].position = Vector3(p.x, p.y, 0)
	balls[i].visible = true


func _step(dt: float) -> void:
	spd = minf(1.0 + score * 0.05, 2.4)
	var ns := mini(1 + score / 5, 5)
	if ns != stage:
		stage = ns
		msg(STAGE_MSG[stage], 1.2)
		play("win")
	for w in walls:
		w.visible = stage >= 2
	var dw := dt * spd
	el += dw
	off = _off(el)
	for i in 3:
		bin_t[i] = maxf(bin_t[i] - dt, 0.0)
	_layout()
	var any := false
	tr_t -= dt
	var drop_trail := tr_t <= 0.0
	if drop_trail:
		tr_t = 0.025
	for i in 2:
		if not b_on[i]:
			continue
		any = true
		_ball(i, dt, dw, drop_trail)
		if over:
			return
	if not any:
		gap -= dt
		if gap <= 0.0:
			var n := 2 if stage >= 3 and randf() < 0.6 else 1
			charge = 1
			for i in n:
				_launch(i, n)
			beep(300.0, 0.1, 700.0, 0.15)
	dot.material_override = mat(GOOD if charge > 0 else INK)
	gauge(lives / 3.0, BAD)


func _ball(i: int, dt: float, dw: float, drop_trail: bool) -> void:
	var m := balls[i]
	if b_hold[i] > 0.0:
		b_hold[i] -= dt
		m.visible = fmod(b_hold[i], 0.12) > 0.05
		return
	m.visible = true
	if b_hot[i]:
		m.material_override = mat(WHITE if fmod(el, 0.2) < 0.1 else COLS[b_col[i]])
	var p := b_p[i]
	var v := b_v[i]
	var sub := clampi(ceili(v.length() * dw / 0.2), 1, 10)
	var h := dw / sub
	var ev := 0
	for s in sub:
		var r := _phys(p, v, h, off)
		p = r[0]
		v = r[1]
		ev = r[2]
		if dot_on:
			var d := p - dot_p
			if d.length() < BR + DR:
				var nrm := d.normalized() if d.length() > 0.001 else Vector2.UP
				p = dot_p + nrm * (BR + DR)
				var vn := v.dot(nrm)
				if vn < 0.0:
					v -= 2.0 * vn * nrm
				v = v * 0.85 + nrm * KICK
				if b_hot[i]:
					v = (v * 1.45).limit_length(40.0)
					beep(1400.0, 0.08, 1900.0, 0.2)
				else:
					beep(990.0, 0.05, 0.0, 0.18)
		if ev != 0:
			break
	b_p[i] = p
	b_v[i] = v
	m.position = Vector3(p.x, p.y, 0)
	if drop_trail:
		var tm := trails[i * TRAIL + tr_i[i]]
		tr_i[i] = (tr_i[i] + 1) % TRAIL
		tm.material_override = m.material_override
		tm.position = Vector3(p.x, p.y, -0.1)
		tm.visible = true
	if ev == 1:
		beep(380.0, 0.04, 0.0, 0.12)
	elif ev >= 10:
		var k := ev - 10
		if k == b_col[i]:
			score += 1
			bin_t[k] = 0.25
			play("good")
		else:
			_lose("틀림")
		_done(i)
	elif ev < 0:
		_lose("놓침")
		_done(i)


func _lose(s: String) -> void:
	lives -= 1
	play("bad")
	msg(s)
	if lives <= 0:
		gauge(0.0, BAD)
		end()


func _done(i: int) -> void:
	b_on[i] = false
	balls[i].visible = false
	for k in TRAIL:
		trails[i * TRAIL + k].visible = false
	gap = 0.4


func _tap(p: Vector2) -> void:
	if charge <= 0:
		beep(160.0, 0.06, 0.0, 0.15)
		return
	var w := on_z(p, 0.0)
	dot_p = Vector2(clampf(w.x, -HALF + 0.4, HALF - 0.4), clampf(w.y, FLOOR + 0.7, TOP))
	dot_on = true
	charge -= 1
	dot.position = Vector3(dot_p.x, dot_p.y, 0)
	dot.visible = true
	beep(720.0, 0.06, 1000.0, 0.2)
