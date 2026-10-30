extends Tofu
## 다이얼 웜뱃 (위에서 본 3D 방). 오른쪽 세로 다이얼을 끌면 세상 전체 속도가 0.2x~3x: 나, 함정(톱날·진자), 놓은 물건이 다 같이 느려지고 빨라진다.
## 그런데 출구 문은 진짜 시간으로 닫힌다(위 막대). 왼손 조이스틱으로 움직여 노란 열매를 다 먹고 위쪽 문으로.
## 도구 3개는 무작위(밀대·튕김벽·끈·폭탄·경사판·무거운 상자). 버튼을 누르고 방을 탭해 쓴다. 함정·폭발·문 닫힘 = 목숨 -1(셋). 방을 깰수록 문 시간이 줄고 함정이 는다.

const X0 := -5.5
const X1 := 3.5
const Z0 := -5.0
const Z1 := 5.0
const VMAX := 4.0
const ACC := 18.0
const HALF := 0.4  # 내 반폭
const TH := 0.45  # 함정 반폭
const AIR_T := 0.8
const LANES: Array[float] = [-3.0, -1.0, 1.0, 3.0]
const TOOL_NAMES := ["밀대", "튕김벽", "끈", "폭탄", "경사판", "무거움"]
const GREY := Color("adb5bd")
const TOOL_COL := [A, B, C, BAD, D, GREY]
const DIAL_X := 600.0
const DIAL_TOP := 280.0
const DIAL_H := 620.0
const RMIN := 0.2
const RMAX := 3.0


class Blk:
	var n: MeshInstance3D
	var pos := Vector3.ZERO
	var vel := Vector3.ZERO
	var hx := 0.5
	var hz := 0.5
	var kind := 0  # 0 튕김벽, 1 무거운 상자, 2 폭탄, 3 경사판, -1 없어짐
	var fuse := 0.0


class Trap:
	var n: MeshInstance3D
	var kind := 0  # 0 톱날(등속 왕복), 1 진자(가운데 빠르고 끝 느림)
	var z := 0.0
	var cx := 0.0
	var amp := 3.0
	var s := 0.0  # 톱날: 가운데서 벗어난 거리, 진자: 위상
	var dir := 1.0
	var spd := 2.0
	var alive := true


class Fruit:
	var n: MeshInstance3D
	var pos := Vector3.ZERO
	var alive := true
	var pull := false


var room: Node3D
var rng := RandomNumberGenerator.new()
var seed_v := 0
var stage := 0
var lives := 3
var rate := 1.0
var dialing := false
var dial_tick := 0
var me: MeshInstance3D
var me_pos := Vector3.ZERO
var me_vel := Vector3.ZERO
var air := 0.0
var fruits: Array[Fruit] = []
var traps: Array[Trap] = []
var blocks: Array[Blk] = []
var tools: Array[int] = [-1, -1, -1]  # 슬롯 3개, -1 = 쓴 것
var sel := -1
var door := 1.0
var door_max := 1.0
var exit_x := 0.0
var exit_n: MeshInstance3D
var exit_open := false
var pause_t := 0.0
var next_room := false
var hum := 0.0
var knob: ColorRect
var life_n: Array[MeshInstance3D] = []
var flash: MeshInstance3D
var flash_t := 0.0


func _setup() -> void:
	howto = "오른쪽 세로 다이얼을 끌면 세상 전체 속도가 0.2배~3배. 나·함정·물건이 다 같이 느려지고 빨라진다.\n왼손 조이스틱으로 움직여 노란 열매를 다 먹고 위쪽 문으로. 문은 진짜 시간으로 닫힌다(위 막대).\n아래 도구 3개: 버튼을 누르고 방 안을 탭해서 쓴다.\n함정·폭발·문 닫힘이면 목숨 -1. 셋 잃으면 끝."
	time_limit = 0.0
	cam.fov = 60.0
	cam.position = Vector3(-0.7, 11.0, 0.0)
	cam.rotation_degrees = Vector3(-90, 0, 0)
	kit_stick(Rect2(0, 950, 400, 330))
	for i in 3:
		kit_button("t%d" % i, "-", Vector2(470 + i * 105, 1090), 50.0, SOFT)
	# 오른쪽 세로 다이얼 (세상 속도)
	var lay := CanvasLayer.new()
	lay.layer = 1
	add_child(lay)
	var track := ColorRect.new()
	track.color = WHITE
	track.position = Vector2(650, DIAL_TOP)
	track.size = Vector2(30, DIAL_H)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(track)
	var one := ColorRect.new()
	one.color = INK
	one.position = Vector2(635, _dial_y(1.0) - 3.0)
	one.size = Vector2(60, 6)
	one.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(one)
	knob = ColorRect.new()
	knob.color = ME
	knob.size = Vector2(90, 60)
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(knob)
	_knob()


func _reset() -> void:
	room = null
	lives = 3
	stage = 0
	rate = 1.0
	dialing = false
	pause_t = 0.0
	flash_t = 0.0
	_knob()
	seed_v = randi()
	_build()


## 방 하나 만들기 (seed_v 가 같으면 같은 방·같은 도구)
func _build() -> void:
	if room:
		room.queue_free()
	room = Node3D.new()
	world.add_child(room)
	rng.seed = seed_v
	var w := X1 - X0
	var h := Z1 - Z0
	var cx := (X0 + X1) * 0.5
	box(Vector3(cx, -0.1, 0), Vector3(w, 0.2, h), SOFT, room)
	box(Vector3(X0 - 0.15, 0.3, 0), Vector3(0.3, 0.6, h + 0.6), INK, room)
	box(Vector3(X1 + 0.15, 0.3, 0), Vector3(0.3, 0.6, h + 0.6), INK, room)
	box(Vector3(cx, 0.3, Z0 - 0.15), Vector3(w + 0.6, 0.6, 0.3), INK, room)
	box(Vector3(cx, 0.3, Z1 + 0.15), Vector3(w + 0.6, 0.6, 0.3), INK, room)
	exit_x = rng.randf_range(X0 + 1.5, X1 - 1.5)
	exit_n = box(Vector3(exit_x, 0.5, Z0 - 0.15), Vector3(1.8, 1.0, 0.5), BAD, room)
	exit_open = false
	# 나
	me_pos = Vector3(X0 + 1.0, 0, Z1 - 0.8)
	me_vel = Vector3.ZERO
	air = 0.0
	me = box(me_pos + Vector3(0, 0.4, 0), Vector3(0.8, 0.8, 0.8), ME, room)
	# 열매
	fruits.clear()
	var nf := mini(3 + stage / 2, 5)
	var tries := 0
	while fruits.size() < nf and tries < 200:
		tries += 1
		var p := Vector3(rng.randf_range(X0 + 0.8, X1 - 0.8), 0, rng.randf_range(Z0 + 1.0, Z1 - 2.0))
		if p.distance_to(me_pos) < 1.8:
			continue
		var ok := true
		for f in fruits:
			if f.pos.distance_to(p) < 1.3:
				ok = false
		if not ok:
			continue
		var f := Fruit.new()
		f.pos = p
		f.n = box(p + Vector3(0, 0.3, 0), Vector3(0.5, 0.5, 0.5), D, room)
		fruits.append(f)
	# 함정: 가로 선로마다 하나 (방이 넘어갈수록 선로가 늘고, 3방부터 둘씩)
	traps.clear()
	var nl := mini(1 + stage, LANES.size())
	var first := rng.randi_range(0, LANES.size() - 1)
	for k in nl:
		var z: float = LANES[(first + k) % LANES.size()]
		var kind := rng.randi_range(0, 1)
		var s0 := rng.randf_range(-3.0, 3.0) if kind == 0 else rng.randf() * TAU
		var d0 := 1.0 if rng.randf() < 0.5 else -1.0
		_add_trap(kind, z, s0, d0)
		if stage >= 3:
			_add_trap(kind, z, -s0 if kind == 0 else s0 + PI, d0)
	# 물건·도구
	blocks.clear()
	for i in 3:
		tools[i] = rng.randi_range(0, TOOL_NAMES.size() - 1)
	sel = -1
	_btn_refresh()
	door_max = maxf(7.0, 18.0 - stage * 1.6)
	door = door_max
	# 목숨 (방 아래 작은 파란 상자)
	life_n.clear()
	for i in 3:
		life_n.append(box(Vector3(X0 + 0.4 + i * 0.6, 0.15, Z1 + 0.75), Vector3(0.35, 0.3, 0.35), ME, room))
	flash = box(Vector3.ZERO, Vector3.ONE, D, room)
	flash.visible = false
	flash_t = 0.0
	hum = 0.0
	msg("방 %d" % (stage + 1), 1.0)


func _add_trap(kind: int, z: float, s0: float, d0: float) -> void:
	var tr := Trap.new()
	tr.kind = kind
	tr.z = z
	tr.cx = (X0 + X1) * 0.5
	tr.amp = (X1 - X0) * 0.5 - 0.8
	tr.s = s0
	tr.dir = d0
	tr.spd = (2.4 + 0.3 * stage) if kind == 0 else (1.5 + 0.15 * stage)
	if kind == 0:
		tr.n = box(Vector3(tr.cx, 0.15, z), Vector3(0.9, 0.3, 0.9), BAD, room)
	else:
		tr.n = box(Vector3(tr.cx, 0.7, z), Vector3(0.6, 1.4, 0.6), BAD, room)
	traps.append(tr)


func _btn_refresh() -> void:
	for i in 3:
		var k := tools[i]
		var b: Dictionary = _btns["t%d" % i]
		if k < 0:
			b.label = "-"
			b.color = SOFT
		else:
			b.label = TOOL_NAMES[k]
			var col: Color = TOOL_COL[k]
			b.color = col if sel == i else col.lightened(0.45)


func _step(dt: float) -> void:
	if flash_t > 0.0:
		flash_t -= dt
		flash.scale = Vector3.ONE * (1.0 + (0.3 - flash_t) * 12.0)
		if flash_t <= 0.0:
			flash.visible = false
	for i in 3:
		life_n[i].visible = i < lives
	if pause_t > 0.0:
		pause_t -= dt
		if pause_t <= 0.0:
			if next_room:
				seed_v = randi()
			_build()
		return
	# 도구 버튼 고르기
	for i in 3:
		if kit_just("t%d" % i) and tools[i] >= 0:
			sel = i if sel != i else -1
			play("tap")
			_btn_refresh()
	# 문은 진짜 시간으로 닫힌다
	door -= dt
	gauge(door / door_max, GOOD if exit_open else BAD)
	exit_n.scale.x = 1.8 * maxf(0.08, door / door_max)
	if door <= 0.0:
		_fail("문 닫힘", true)
		return
	# 세상 시간 = 진짜 시간 × 다이얼. 빠를수록 잘게 쪼개 계산한다.
	var wdt := dt * rate
	hum += wdt
	if hum > 0.5:
		hum = 0.0
		beep(60.0 + 70.0 * rate, 0.05, 0.0, 0.1)
	var left := wdt
	while left > 0.0 and pause_t <= 0.0 and not over:
		var hh := minf(left, 0.02)
		left -= hh
		_phys(hh)
	var keep: Array[Blk] = []
	for b in blocks:
		if b.kind >= 0:
			keep.append(b)
	blocks = keep
	var lift := sin(PI * clampf(air / AIR_T, 0.0, 1.0)) * 1.5 if air > 0.0 else 0.0
	me.position = me_pos + Vector3(0, 0.4 + lift, 0)
	var spd := me_vel.length()
	me.scale = Vector3(0.8 + spd * 0.015, 0.8 - spd * 0.02, 0.8 + spd * 0.015)


## 세상 시간 h 만큼 물리 한 걸음
func _phys(h: float) -> void:
	# 나
	var want := Vector3(kit_move.x, 0, kit_move.y) * VMAX
	me_vel = me_vel.move_toward(want, ACC * h)
	me_pos += me_vel * h
	if air > 0.0:
		air -= h
	_bounce_walls()
	# 물건
	for b in blocks:
		if b.kind < 0:
			continue
		if b.kind == 1 or b.kind == 2:
			b.pos += b.vel * h
			b.vel = b.vel.move_toward(Vector3.ZERO, 6.0 * h)
			if b.pos.x < X0 + b.hx or b.pos.x > X1 - b.hx:
				b.pos.x = clampf(b.pos.x, X0 + b.hx, X1 - b.hx)
				b.vel.x = -b.vel.x * 0.5
			if b.pos.z < Z0 + b.hz or b.pos.z > Z1 - b.hz:
				b.pos.z = clampf(b.pos.z, Z0 + b.hz, Z1 - b.hz)
				b.vel.z = -b.vel.z * 0.5
			b.n.position.x = b.pos.x
			b.n.position.z = b.pos.z
		if b.kind == 2:
			b.fuse -= h
			b.n.scale = Vector3(0.7, 0.7, 0.7) * (1.0 + 0.15 * sin(b.fuse * 25.0))
			if b.fuse <= 0.0:
				_explode(b)
				if pause_t > 0.0 or over:
					return
				continue
		_me_vs_block(b)
	# 함정
	for tr in traps:
		if not tr.alive:
			continue
		_move_trap(tr, h)
		for b in blocks:
			if (b.kind == 0 or b.kind == 1) and _overlap(tr.n.position.x, tr.z, TH, TH, b.pos.x, b.pos.z, b.hx, b.hz):
				tr.dir = -tr.dir
				_move_trap(tr, h * 2.0)
				break
		if air <= 0.0 and _overlap(me_pos.x, me_pos.z, HALF, HALF, tr.n.position.x, tr.z, TH, TH):
			_fail("함정", false)
			return
	# 열매
	var left_f := 0
	for f in fruits:
		if not f.alive:
			continue
		if f.pull:
			f.pos = f.pos.move_toward(Vector3(me_pos.x, 0, me_pos.z), 3.0 * h)
			f.n.position = f.pos + Vector3(0, 0.3, 0)
		if Vector2(f.pos.x - me_pos.x, f.pos.z - me_pos.z).length() < 0.75:
			f.alive = false
			f.n.visible = false
			play("good")
			msg("냠", 0.3)
		else:
			left_f += 1
	if left_f == 0 and not exit_open:
		exit_open = true
		exit_n.material_override = mat(GOOD)
		beep(500.0, 0.2, 1000.0, 0.3)
		msg("문 열림", 0.8)
	# 출구
	if exit_open and absf(me_pos.x - exit_x) < 0.9 and me_pos.z < Z0 + 0.75:
		stage += 1
		score = stage
		play("win")
		msg("통과!", 1.0)
		pause_t = 1.0
		next_room = true


func _move_trap(tr: Trap, h: float) -> void:
	tr.s += tr.dir * tr.spd * h
	if tr.kind == 0:
		if absf(tr.s) > tr.amp:
			tr.s = signf(tr.s) * tr.amp
			tr.dir = -tr.dir
		tr.n.position.x = tr.cx + tr.s
	else:
		tr.n.position.x = tr.cx + tr.amp * sin(tr.s)


func _overlap(ax: float, az: float, ahx: float, ahz: float, bx: float, bz: float, bhx: float, bhz: float) -> bool:
	return absf(ax - bx) < ahx + bhx and absf(az - bz) < ahz + bhz


func _bounce_walls() -> void:
	var hit := false
	if me_pos.x < X0 + HALF or me_pos.x > X1 - HALF:
		me_pos.x = clampf(me_pos.x, X0 + HALF, X1 - HALF)
		hit = absf(me_vel.x) > 4.5
		me_vel.x = -me_vel.x * 0.5
	if me_pos.z < Z0 + HALF or me_pos.z > Z1 - HALF:
		me_pos.z = clampf(me_pos.z, Z0 + HALF, Z1 - HALF)
		hit = hit or absf(me_vel.z) > 4.5
		me_vel.z = -me_vel.z * 0.5
	if hit:
		beep(130.0, 0.06, 0.0, 0.2)


func _me_vs_block(b: Blk) -> void:
	var dx := me_pos.x - b.pos.x
	var dz := me_pos.z - b.pos.z
	var px := HALF + b.hx - absf(dx)
	var pz := HALF + b.hz - absf(dz)
	if px <= 0.0 or pz <= 0.0:
		return
	if b.kind == 3:
		# 경사판: 달려서 밟으면 날아오른다 (떠 있는 동안 함정을 넘는다)
		if air <= 0.0 and me_vel.length() > 1.5:
			air = AIR_T
			me_vel *= 1.6
			beep(400.0, 0.15, 900.0, 0.25)
			msg("점프", 0.4)
		return
	var sx := signf(dx) if dx != 0.0 else 1.0
	var sz := signf(dz) if dz != 0.0 else 1.0
	if b.kind == 0:
		# 튕김벽: 세게 튕겨 나간다
		if px < pz:
			me_pos.x += sx * px
			me_vel.x = sx * (absf(me_vel.x) * 1.3 + 2.0)
		else:
			me_pos.z += sz * pz
			me_vel.z = sz * (absf(me_vel.z) * 1.3 + 2.0)
		beep(700.0, 0.06, 300.0, 0.25)
		return
	# 무거운 상자(천천히 밀림) / 폭탄(쉽게 밀림)
	var share := 0.35 if b.kind == 1 else 0.9
	if px < pz:
		me_pos.x += sx * px * (1.0 - share)
		b.pos.x -= sx * px * share
		b.vel.x = me_vel.x * (0.6 if b.kind == 1 else 1.2)
	else:
		me_pos.z += sz * pz * (1.0 - share)
		b.pos.z -= sz * pz * share
		b.vel.z = me_vel.z * (0.6 if b.kind == 1 else 1.2)
	b.n.position.x = b.pos.x
	b.n.position.z = b.pos.z


func _explode(b: Blk) -> void:
	b.kind = -1
	b.n.visible = false
	flash.position = b.pos + Vector3(0, 0.5, 0)
	flash.scale = Vector3.ONE
	flash.visible = true
	flash_t = 0.3
	beep(80.0, 0.3, 30.0, 0.35)
	for tr in traps:
		if tr.alive and Vector2(tr.n.position.x - b.pos.x, tr.z - b.pos.z).length() < 2.2:
			tr.alive = false
			tr.n.visible = false
			beep(900.0, 0.1, 200.0, 0.25)
	for o in blocks:
		if o != b and (o.kind == 1 or o.kind == 2):
			var dv := o.pos - b.pos
			var dl := dv.length()
			if dl < 3.0 and dl > 0.01:
				o.vel += dv / dl * 12.0 * (1.0 - dl / 3.0)
	var d := me_pos - b.pos
	d.y = 0.0
	var dist := d.length()
	if dist < 0.9 and air <= 0.0:
		_fail("폭발", false)
	elif dist < 3.0:
		me_vel += (d / maxf(dist, 0.01)) * 14.0 * (1.0 - dist / 3.0)


func _fail(why: String, new_room: bool) -> void:
	if pause_t > 0.0 or over:
		return
	lives -= 1
	play("bad")
	msg(why, 1.0)
	me.material_override = mat(BAD)
	if lives <= 0:
		end()
		return
	pause_t = 1.2
	next_room = new_room


# ---- 입력: 다이얼과 도구 쓰기 ----
func _dial_y(r: float) -> float:
	var u := log(r / RMIN) / log(RMAX / RMIN)
	return DIAL_TOP + DIAL_H - u * DIAL_H


func _knob() -> void:
	knob.position = Vector2(620, _dial_y(rate) - 30.0)


func _dial(p: Vector2) -> void:
	var u := clampf((DIAL_TOP + DIAL_H - p.y) / DIAL_H, 0.0, 1.0)
	rate = RMIN * pow(RMAX / RMIN, u)
	_knob()
	msg("%.1fx" % rate, 0.5)
	var tick := int(rate * 4.0)
	if tick != dial_tick:
		dial_tick = tick
		beep(150.0 + rate * 150.0, 0.04, 0.0, 0.12)


func _tap(p: Vector2) -> void:
	if p.x >= DIAL_X:
		dialing = true
		_dial(p)
		return
	if pause_t > 0.0 or sel < 0:
		return
	var g := ground(p)
	if g.x < X0 or g.x > X1 or g.z < Z0 or g.z > Z1:
		return
	_use(tools[sel], g)
	tools[sel] = -1
	sel = -1
	_btn_refresh()


func _drag(p: Vector2) -> void:
	if dialing:
		_dial(p)


func _lift(_p: Vector2) -> void:
	dialing = false


func _use(k: int, g: Vector3) -> void:
	match k:
		0:  # 밀대: 탭한 쪽으로 몸을 확 민다
			var d := g - me_pos
			d.y = 0.0
			if d.length() < 0.3:
				d = Vector3(0, 0, -1)
			me_vel += d.normalized() * 11.0
			beep(200.0, 0.1, 420.0, 0.25)
		1:  # 튕김벽: 나와 탭한 점 사이를 가로막는 방향으로 선다
			var b := Blk.new()
			b.kind = 0
			if absf(g.x - me_pos.x) > absf(g.z - me_pos.z):
				b.hx = 0.25
				b.hz = 1.2
			else:
				b.hx = 1.2
				b.hz = 0.25
			_place(b, g, Vector3(b.hx * 2.0, 0.8, b.hz * 2.0), 0.4, B)
		2:  # 끈: 가장 가까운 열매를 나한테 끌어온다
			var best_f: Fruit = null
			var bd := 1e9
			for f in fruits:
				if f.alive and f.pos.distance_to(g) < bd:
					bd = f.pos.distance_to(g)
					best_f = f
			if best_f:
				best_f.pull = true
				best_f.n.material_override = mat(C)
			beep(600.0, 0.1, 300.0, 0.2)
		3:  # 폭탄: 2초(세상 시간) 뒤 터진다
			var b := Blk.new()
			b.kind = 2
			b.hx = 0.35
			b.hz = 0.35
			b.fuse = 2.0
			_place(b, g, Vector3(0.7, 0.7, 0.7), 0.35, BAD)
		4:  # 경사판
			var b := Blk.new()
			b.kind = 3
			b.hx = 0.6
			b.hz = 0.6
			_place(b, g, Vector3(1.2, 0.2, 1.2), 0.1, D)
		5:  # 무거운 상자: 톱날·진자를 막고 천천히 밀린다
			var b := Blk.new()
			b.kind = 1
			b.hx = 0.5
			b.hz = 0.5
			_place(b, g, Vector3(1.0, 1.0, 1.0), 0.5, GREY)


func _place(b: Blk, g: Vector3, size: Vector3, y: float, col: Color) -> void:
	b.pos = Vector3(clampf(g.x, X0 + b.hx, X1 - b.hx), 0, clampf(g.z, Z0 + b.hz, Z1 - b.hz))
	b.n = box(Vector3(b.pos.x, y, b.pos.z), size, col, room)
	blocks.append(b)
	beep(260.0, 0.08, 0.0, 0.2)
