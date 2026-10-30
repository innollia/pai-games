extends Tofu
## 옆모습. 스틱 살짝 = 기기(조용·느림), 끝까지 = 뛰기(빠름·소리). 점프·던지기 버튼, 장대 옆에서 위 = 타기. 비 오기 전에 열매 2개 먹고 셸터로.
## 소리가 세계의 자원이다: 뛰는 소리는 도마뱀을 부르지만 나무 열매를 떨구고 새를 날린다(비가 빨라짐). 손으로 짠 지역 6개, 지역마다 소리 규칙이 바뀐다:
## 들판(뛰어야 열매) · 웅덩이(기어도 첨벙, 물에 던진 돌은 크게 꾄다) · 갈대숲(멈추면 안 보임) · 동굴(소리 2배 울림, 종유석 열매는 소리로) · 둥지(자는 놈은 귀만) · 비 속(빗소리가 덮어 뛰는 게 정답). 죽으면 그 지역부터.
# 한 문장: 나는 비 오기 전에 먹고 숨어야 하는 작은 짐승으로서 나보다 빠른 도마뱀의 지역 속에서 기거나 뛰어 열매를 얻고 셸터에 들지만, 뛰는 소리가 도마뱀을 부르고(대신 열매를 떨구고) 기면 비가 먼저 온다.

const CRAWL := 1.3
const RUN := 4.3
const LWALK := 1.6
const LRUN := 5.6
const JUMP := 7.5
const GRAV := 20.0
const NEED := 2
const NRAIN := 40
const WET_MAX := 1.6  # 비 속 지역: 지붕 밖에서 버티는 초
const NAMES := ["들판", "웅덩이", "갈대숲", "동굴", "둥지", "비 속"]
const RULES := ["뛰면 열매가 떨어짐", "물은 기어도 첨벙", "멈추면 안 보인다", "소리가 울린다", "자는 놈은 귀만", "빗소리가 덮는다"]


class Liz:
	var root: Node3D
	var body: MeshInstance3D
	var head: MeshInstance3D
	var x := 0.0
	var dir := 1.0
	var lo := 0.0
	var hi := 0.0
	var st := 0  # 0 어슬렁, 1 소리 듣고 감, 2 쫓음, 3 기절, 4 장대 밑 대기, 5 잠
	var tt := 0.0
	var tgt := 0.0
	var pause := 0.0
	var roar := 0.0
	var sp := 0.0
	var sleeper := false


var rng := RandomNumberGenerator.new()
var level: Node3D
var wd := 30.0
var cyc := 0
var reg := 0
var lap := 0
var echo := 1.0
var rain_base := 55.0
var rain_t := 60.0
var rain_max := 60.0
var warn := 99
var done_t := 0.0
var hint_t := 0.0
var eaten := 0
var has_rock := false
var hungry_t := 0.0
var px := 1.5
var py := 0.0
var vx := 0.0
var vy := 0.0
var face := 1.0
var grounded := true
var crawl := false
var running := false
var on_pole := false
var pole_top := 0.0
var step_t := 0.0
var splash_t := 0.0
var sway_t := 0.0
var wet := 0.0
var clock := 0.0
var cam_x := 0.0
var me_root: Node3D
var me_body: MeshInstance3D
var me_head: MeshInstance3D
var me_rock: MeshInstance3D
var door: MeshInstance3D
var lizards: Array[Liz] = []
var poles: Array[Dictionary] = []  # {x, top}
var puddles: Array[Vector2] = []  # x0, x1
var reed_spans: Array[Vector2] = []
var lows: Array[Vector2] = []  # 동굴 낮은 굴 (기어서만)
var roofs: Array[Vector2] = []  # 비 속 지붕
var fruits: Array[Dictionary] = []  # {n, x, y, st(0 달림, 1 떨어짐, 2 바닥, 3 먹음), trig, vy}
var rocks: Array[Dictionary] = []  # {n, x, y, st(0 바닥, 1 손, 2 날아감), vx, vy}
var trees: Array[Dictionary] = []  # {n, x, sh}
var birds: Array[Dictionary] = []  # {n, x, y, st}
var reeds: Array[Dictionary] = []  # {n, x, h, a}
var rain: Array[MeshInstance3D] = []


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 50.0
	howto = "스틱 살짝 = 기기(조용·느림), 끝까지 = 뛰기(빠르지만 소리). 소리는 도마뱀을 부르지만 나무 열매를 떨군다.\n비 오기 전에 노란 열매 2개를 먹고 오른쪽 셸터로. 장대 위는 안전, 돌을 던지면 기절·유인.\n지역마다 소리 규칙이 바뀐다. 물리거나 비 맞으면 그 지역부터 다시."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1080), 100.0, ME)
	kit_button("throw", "던지기", Vector2(600, 870), 70.0, A)


func _reset() -> void:
	rng.randomize()
	level = null
	_region()  # cyc 는 그대로: 죽으면 그 지역부터 다시


# ---- 지역 ----
func _region() -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	lizards.clear()
	poles.clear()
	puddles.clear()
	reed_spans.clear()
	lows.clear()
	roofs.clear()
	fruits.clear()
	rocks.clear()
	trees.clear()
	birds.clear()
	reeds.clear()
	rain.clear()
	reg = cyc % NAMES.size()
	lap = cyc / NAMES.size()
	echo = 1.0
	rain_base = 55.0
	match reg:
		0: _r_field()
		1: _r_puddle()
		2: _r_reeds()
		3: _r_cave()
		4: _r_nest()
		5: _r_storm()
	# 땅·배경 기둥
	box(Vector3(wd * 0.5, -1.0, 0.0), Vector3(wd + 12.0, 2.0, 6.0), WHITE, level)
	box(Vector3(wd * 0.5, 0.02, 0.0), Vector3(wd + 12.0, 0.08, 4.0), GOOD, level)
	if reg != 3:
		var k := 0
		while k * 3.5 < wd:
			var h := rng.randf_range(2.5, 7.0)
			box(Vector3(k * 3.5 + rng.randf_range(0.0, 1.5), h * 0.5, -2.4 - rng.randf_range(0.0, 1.5)), Vector3(rng.randf_range(0.6, 1.4), h, 0.8), SOFT, level)
			k += 1
	# 셸터(오른쪽 끝)
	box(Vector3(wd - 0.6, 1.6, 0.0), Vector3(3.2, 3.2, 3.0), SOFT, level)
	door = box(Vector3(wd - 2.3, 0.9, 0.3), Vector3(0.3, 1.8, 1.4), GOOD, level)
	# 비
	for i in NRAIN:
		var r := box(Vector3(0.0, -50.0, 1.0), Vector3(0.07, 0.9, 0.07), B, level)
		r.visible = false
		rain.append(r)
	# 나
	me_root = Node3D.new()
	level.add_child(me_root)
	me_body = box(Vector3(0.0, 0.45, 0.0), Vector3(0.5, 0.9, 0.4), ME, me_root)
	me_head = box(Vector3(0.1, 1.1, 0.0), Vector3(0.4, 0.4, 0.4), WHITE, me_root)
	me_rock = box(Vector3(0.4, 0.7, 0.25), Vector3(0.3, 0.26, 0.26), INK, me_root)
	me_rock.visible = false
	px = 1.5
	py = 0.0
	vx = 0.0
	vy = 0.0
	face = 1.0
	grounded = true
	crawl = false
	running = false
	on_pole = false
	has_rock = false
	eaten = 0
	hungry_t = 0.0
	done_t = 0.0
	wet = 0.0
	rain_max = maxf(25.0, rain_base - lap * 8.0)
	rain_t = rain_max
	warn = 99
	cam_x = 7.0
	hint_t = 1.4
	msg("%d %s" % [cyc + 1, NAMES[reg]], 1.4)


## 1 들판: 열매는 나무에 달렸다. 뛰어 지나가야(진동) 떨어진다. 새 옆에서 뛰면 날아올라 비가 5초 빨라진다.
func _r_field() -> void:
	wd = 34.0
	_tree(12.0)
	_tree(25.0)
	_pole(14.6, 5.0)
	_pole(27.6, 5.5)
	_rock(5.0)
	_rock(17.0)
	_bird(19.5)
	_liz(8.0, 30.0, 20.0)


## 2 웅덩이: 물속은 느리고 기어도 첨벙 소리. 돌을 물에 던지면 크게 울려 멀리서도 꾄다. 도마뱀도 물에선 느리고 첨벙거린다.
func _r_puddle() -> void:
	wd = 38.0
	_puddle(8.0, 12.0)
	_puddle(17.0, 23.0)
	_puddle(28.0, 32.5)
	_fruit(20.0)
	_fruit(30.5)
	_pole(15.0, 5.0)
	_pole(25.5, 5.0)
	_rock(3.0)
	_rock(5.0)
	_rock(14.0)
	_liz(12.0, 26.0, 19.0)
	_liz(26.0, 35.0, 31.0)


## 3 갈대숲: 갈대 속에선 눈이 안 통한다. 대신 움직이면 갈대가 흔들려 가까운 도마뱀이 온다. 멈추면 코앞이어도 안 보인다.
func _r_reeds() -> void:
	wd = 40.0
	_reeds(6.0, 16.0)
	_reeds(21.0, 33.0)
	_fruit(11.0)
	_fruit(28.0)
	_pole(18.5, 5.0)
	_pole(36.0, 5.0)
	_rock(3.0)
	_rock(19.5)
	_bird(17.5)
	_bird(34.5)
	_liz(9.0, 16.0, 12.0)
	_liz(21.0, 33.0, 25.0)


## 4 동굴: 소리가 울려 2.2배 멀리 간다. 낮은 굴은 기어서만. 종유석 열매는 소리(던진 돌)로 떨어뜨린다.
func _r_cave() -> void:
	wd = 40.0
	echo = 2.2
	box(Vector3(20.0, 3.8, -0.3), Vector3(34.0, 0.8, 2.4), SOFT, level)
	box(Vector3(20.0, 1.9, -2.6), Vector3(34.0, 3.8, 0.4), SOFT, level)
	_low(10.0, 15.0)
	_low(25.0, 29.0)
	_stal(19.5)
	_stal(33.0)
	_pole(22.0, 3.0)
	_rock(5.0)
	_rock(7.0)
	_rock(17.0)
	_liz(15.0, 25.0, 20.0)
	_liz(29.0, 36.0, 32.0)


## 5 둥지: 도마뱀이 잔다. 눈은 감았고 소리로만 깬다. 깨면 소리 난 곳을 보러 갔다가 거기서 다시 잔다.
func _r_nest() -> void:
	wd = 40.0
	rain_base = 50.0
	for x in [12.0, 17.5, 25.5, 31.5]:
		box(Vector3(x, 0.1, -0.3), Vector3(2.4, 0.2, 1.6), SOFT, level)
		_liz(x - 3.0, x + 3.0, x, true)
	_fruit(15.0)
	_fruit(28.8)
	_rock(4.0)
	_rock(6.0)
	_rock(21.5)
	_pole(21.5, 5.0)


## 6 비 속: 비가 이미 온다. 지붕 밖에서 1.6초면 죽는다. 빗소리가 발소리를 덮어 뛰어도 안 들린다 = 빠름이 정답.
func _r_storm() -> void:
	wd = 44.0
	rain_base = 32.0
	_roof(0.5, 9.0)
	_roof(13.0, 18.0)
	_roof(22.0, 27.0)
	_roof(31.0, 36.0)
	_roof(40.0, 44.0)
	_fruit(11.0)
	_fruit(29.0)
	_rock(6.0)
	_liz(13.0, 18.0, 15.5)
	_liz(31.0, 36.0, 33.0)


# ---- 지역 부품 ----
func _pole(x: float, top: float) -> void:
	box(Vector3(x, top * 0.5, -0.3), Vector3(0.25, top, 0.25), INK, level)
	poles.append({"x": x, "top": top})


func _rock(x: float) -> void:
	var m := box(Vector3(x, 0.15, 0.3), Vector3(0.35, 0.3, 0.3), INK, level)
	rocks.append({"n": m, "x": x, "y": 0.15, "st": 0, "vx": 0.0, "vy": 0.0})


## trig > 0 이면 달려 있다가 그 거리 안에서 소리가 나면 떨어진다
func _fruit(x: float, y := 0.4, trig := 0.0) -> void:
	var m := box(Vector3(x, y, 0.0), Vector3(0.55, 0.55, 0.55), D, level)
	fruits.append({"n": m, "x": x, "y": y, "st": 0 if trig > 0.0 else 2, "trig": trig, "vy": 0.0})


func _tree(x: float) -> void:
	box(Vector3(x, 1.5, -0.5), Vector3(0.45, 3.0, 0.45), INK, level)
	var c := box(Vector3(x, 3.5, -0.5), Vector3(2.6, 1.5, 1.2), GOOD, level)
	trees.append({"n": c, "x": x, "sh": 0.0})
	_fruit(x + 0.4, 2.6, 1.8)


func _stal(x: float) -> void:
	box(Vector3(x, 3.1, 0.0), Vector3(0.3, 0.6, 0.3), SOFT, level)
	_fruit(x, 2.6, 3.0)


func _bird(x: float) -> void:
	var m := box(Vector3(x, 0.2, 0.5), Vector3(0.35, 0.3, 0.3), C, level)
	birds.append({"n": m, "x": x, "y": 0.2, "st": 0})


func _puddle(a: float, b: float) -> void:
	box(Vector3((a + b) * 0.5, 0.08, 0.6), Vector3(b - a, 0.12, 2.6), B, level)
	puddles.append(Vector2(a, b))


func _reeds(a: float, b: float) -> void:
	reed_spans.append(Vector2(a, b))
	var x := a + 0.2
	while x < b:
		var h := rng.randf_range(2.0, 2.6)
		var m := box(Vector3(x, h * 0.5, 1.0), Vector3(0.12, h, 0.12), GOOD, level)
		reeds.append({"n": m, "x": x, "h": h, "a": 0.0})
		x += 0.6


func _low(a: float, b: float) -> void:
	box(Vector3((a + b) * 0.5, 2.25, -0.3), Vector3(b - a, 2.5, 2.4), SOFT, level)
	lows.append(Vector2(a, b))


func _roof(a: float, b: float) -> void:
	box(Vector3((a + b) * 0.5, 2.7, 0.0), Vector3(b - a, 0.25, 2.4), SOFT, level)
	box(Vector3(a + 0.2, 1.3, -1.0), Vector3(0.2, 2.6, 0.2), INK, level)
	box(Vector3(b - 0.2, 1.3, -1.0), Vector3(0.2, 2.6, 0.2), INK, level)
	roofs.append(Vector2(a, b))


func _liz(lo: float, hi: float, x: float, sleeper := false) -> void:
	var lz := Liz.new()
	lz.lo = lo
	lz.hi = minf(hi, wd - 4.0)
	lz.x = x
	lz.dir = -1.0 if rng.randf() < 0.5 else 1.0
	lz.sleeper = sleeper
	if sleeper:
		lz.st = 5
	lz.root = Node3D.new()
	level.add_child(lz.root)
	lz.body = box(Vector3(0.0, 0.3, 0.0), Vector3(1.3, 0.5, 0.5), BAD, lz.root)
	lz.head = box(Vector3(0.8, 0.45, 0.0), Vector3(0.5, 0.4, 0.45), BAD, lz.root)
	lizards.append(lz)


func _in(spans: Array[Vector2], x: float) -> bool:
	for s in spans:
		if x > s.x and x < s.y:
			return true
	return false


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	if hint_t > 0.0:
		hint_t -= dt
		if hint_t <= 0.0:
			msg(RULES[reg], 2.2)
	if done_t > 0.0:
		done_t -= dt
		if done_t <= 0.0:
			cyc += 1
			_region()
		_view(dt)
		return
	rain_t -= dt
	var rf := rain_t / rain_max
	if wet > 0.0:
		gauge(1.0 - wet / WET_MAX, BAD)
	else:
		gauge(rf, B if rf > 0.25 else BAD)
	if rain_t < 10.0 and ceili(rain_t) != warn:
		warn = ceili(rain_t)
		beep(150.0, 0.15, 100.0, 0.25)
		if warn == 10:
			msg("비 온다!", 0.8)
	_rain(dt)
	if rain_t <= 0.0:
		_die("비")
		return
	# 비 속 지역: 지붕 밖이면 젖는다
	if reg == 5:
		if _in(roofs, px):
			wet = maxf(0.0, wet - dt * 2.0)
		else:
			wet += dt
			splash_t -= dt
			if splash_t <= 0.0:
				splash_t = 0.25
				beep(900.0, 0.03, 600.0, 0.12)
			if wet >= WET_MAX:
				_die("비 맞았다")
				return
	hungry_t -= dt
	sway_t -= dt
	_me(dt)
	if over:
		return
	_fruits(dt)
	_rocks(dt)
	_birds(dt)
	_lizards(dt)
	if over:
		return
	if done_t <= 0.0:
		score = cyc * 10 + eaten
	_view(dt)


func _me(dt: float) -> void:
	var mx := kit_move.x
	var amt := absf(mx)
	var low := _in(lows, px)
	var want := 0.0
	if amt > 0.12:
		want = signf(mx) * (RUN if amt >= 0.65 and not low else CRAWL)
		face = signf(mx)
	var wading := _in(puddles, px)
	if wading:
		want *= 0.45
	crawl = grounded and not on_pole and ((amt > 0.12 and amt < 0.65) or low)
	running = grounded and not on_pole and amt >= 0.65 and not low
	if on_pole:
		running = false
		py = clampf(py - kit_move.y * 2.6 * dt, 0.0, pole_top - 1.0)
		if kit_move.y > 0.5 and py <= 0.0:
			on_pole = false
		if amt > 0.8:
			on_pole = false
			vx = want
		if kit_just("jump"):
			on_pole = false
			vy = JUMP * 0.85
			vx = face * 2.0
			beep(400.0, 0.1, 700.0, 0.22)
		if on_pole and absf(kit_move.y) > 0.5:
			step_t -= dt
			if step_t <= 0.0:
				step_t = 0.3
				beep(330.0, 0.03, 0.0, 0.08)
		return
	vx = want
	var nx := clampf(px + vx * dt, 0.5, wd - 0.5)
	if not (_in(lows, nx) and py > 0.3):  # 공중에서 낮은 굴로는 못 들어간다
		px = nx
	vy -= GRAV * dt
	py += vy * dt
	if py <= 0.0:
		py = 0.0
		if not grounded:
			if vy < -7.0:
				_noise(px, 4.0)
			beep(90.0, 0.06, 0.0, 0.15)
		grounded = true
		vy = 0.0
	else:
		grounded = false
	if kit_just("jump") and grounded and not low:
		vy = JUMP
		grounded = false
		_noise(px, 5.0)
		beep(400.0, 0.1, 700.0, 0.22)
	if kit_move.y < -0.5:
		for p in poles:
			if absf(px - float(p.x)) < 0.5 and py < float(p.top) - 1.0:
				on_pole = true
				pole_top = float(p.top)
				px = float(p.x)
				vx = 0.0
				vy = 0.0
				grounded = false
				beep(500.0, 0.06, 0.0, 0.15)
				break
	# 뛰면 소리가 난다. 기면 조용하다.
	if running:
		_noise(px, 8.0)
		step_t -= dt
		if step_t <= 0.0:
			step_t = 0.22
			beep(110.0, 0.04, 0.0, 0.14)
	# 물속은 기어도 첨벙
	if wading and grounded and amt > 0.12:
		splash_t -= dt
		if splash_t <= 0.0:
			splash_t = 0.35
			beep(260.0, 0.07, 120.0, 0.22)
			_noise(px, 5.0)
	if not has_rock:
		for r in rocks:
			if r.st == 0 and absf(px - float(r.x)) < 0.6 and py < 0.8:
				has_rock = true
				r.st = 1
				(r.n as MeshInstance3D).visible = false
				beep(700.0, 0.06, 900.0, 0.18)
				msg("돌", 0.4)
				break
	if kit_just("throw") and has_rock:
		for r in rocks:
			if r.st == 1:
				r.st = 2
				r.x = px + face * 0.4
				r.y = py + 0.9
				r.vx = face * 9.0 + vx * 0.5
				r.vy = 4.5
				(r.n as MeshInstance3D).visible = true
				has_rock = false
				beep(600.0, 0.08, 300.0, 0.2)
				break
	# 셸터
	if px > wd - 2.8 and py < 0.5:
		if eaten >= NEED:
			done_t = 1.2
			score = (cyc + 1) * 10
			play("win")
			msg("셸터!", 1.2)
		else:
			px = wd - 2.8
			if hungry_t <= 0.0:
				hungry_t = 1.0
				msg("배고파", 0.6)
				beep(200.0, 0.1, 0.0, 0.2)


## 열매: 달린 것은 소리를 기다리고, 떨어진 것은 땅에 닿으면 먹을 수 있다
func _fruits(dt: float) -> void:
	for f in fruits:
		var n := f.n as MeshInstance3D
		if f.st == 1:
			f.vy = float(f.vy) - GRAV * dt
			f.y = float(f.y) + float(f.vy) * dt
			if float(f.y) <= 0.3:
				f.y = 0.3
				f.st = 2
				beep(300.0, 0.05, 0.0, 0.15)
			n.position.y = float(f.y)
		elif f.st == 2 and absf(px - float(f.x)) < 0.6 and py < 0.8:
			f.st = 3
			n.visible = false
			eaten += 1
			play("good")
			msg("%d / %d" % [eaten, NEED], 0.7)


## 소리: 세계가 먼저 답하고(열매·새), 그다음 반지름 안의 도마뱀이 그쪽으로 온다
func _noise(x: float, r: float) -> void:
	for f in fruits:
		if f.st == 0 and absf(float(f.x) - x) < float(f.trig):
			f.st = 1
			f.vy = 0.0
			beep(500.0, 0.08, 250.0, 0.2)
			msg("툭!", 0.4)
	for tr in trees:
		if absf(float(tr.x) - x) < 2.0:
			tr.sh = 0.3
	for b in birds:
		if b.st == 0 and absf(float(b.x) - x) < 3.0:
			b.st = 1
			rain_t = maxf(rain_t - 5.0, 1.0)
			beep(1200.0, 0.15, 1800.0, 0.22)
			msg("새! 비 -5초", 0.9)
	if reg == 5:
		return  # 빗소리가 다 덮는다
	var rr := r * echo
	for lz in lizards:
		var d := absf(lz.x - x)
		if lz.st in [0, 1, 4, 5] and d < rr:
			if lz.st == 5:
				beep(260.0, 0.2, 180.0, 0.25)
				msg("깼다!", 0.6)
			elif lz.st == 0:
				beep(240.0, 0.15, 160.0, 0.2)
				if d >= r:
					msg("울림!", 0.5)
			lz.st = 1
			lz.tgt = x
			lz.tt = 0.0


func _rocks(dt: float) -> void:
	for r in rocks:
		if r.st != 2:
			continue
		r.vy -= GRAV * dt
		r.x += r.vx * dt
		r.y += r.vy * dt
		var hit := false
		for lz in lizards:
			if lz.st != 3 and absf(float(r.x) - lz.x) < 0.9 and float(r.y) < 1.0:
				lz.st = 3
				lz.tt = 3.0
				lz.body.material_override = mat(SOFT)
				lz.head.material_override = mat(SOFT)
				beep(900.0, 0.12, 300.0, 0.3)
				msg("맞았다!", 0.5)
				hit = true
				break
		if hit or float(r.y) <= 0.15 or float(r.x) < 0.3 or float(r.x) > wd - 0.3:
			r.st = 0
			r.y = 0.15
			r.x = clampf(float(r.x), 0.5, wd - 3.5)
			if _in(puddles, float(r.x)):
				_noise(float(r.x), 10.0)  # 물에 떨어진 돌은 크게 울린다
				beep(200.0, 0.2, 80.0, 0.3)
				msg("첨벙!", 0.5)
			else:
				_noise(float(r.x), 4.5)
				beep(140.0, 0.06, 0.0, 0.18)
		(r.n as MeshInstance3D).position = Vector3(float(r.x), float(r.y), 0.3)


func _birds(dt: float) -> void:
	for b in birds:
		if b.st != 1:
			continue
		b.y = float(b.y) + 6.0 * dt
		b.x = float(b.x) + 3.0 * dt
		var n := b.n as MeshInstance3D
		n.position = Vector3(float(b.x), float(b.y), 0.5)
		if float(b.y) > 14.0:
			b.st = 2
			n.visible = false


func _lizards(dt: float) -> void:
	var safe := on_pole and py >= 1.2  # 장대 위: 못 문다
	var moving := absf(kit_move.x) > 0.12
	var in_reeds := _in(reed_spans, px)
	for lz in lizards:
		var dx := px - lz.x
		var spd := 1.0
		var wading := _in(puddles, lz.x)
		if wading:
			spd = 0.6
		if reg == 5 and not _in(roofs, lz.x):
			spd = 0.5  # 비 맞는 도마뱀은 느리다
		var x0 := lz.x
		match lz.st:
			0:
				if lz.pause > 0.0:
					lz.pause -= dt
				else:
					lz.x += lz.dir * LWALK * spd * dt
					if lz.x > lz.hi:
						lz.x = lz.hi
						lz.dir = -1.0
						lz.pause = rng.randf_range(0.5, 1.6)
					elif lz.x < lz.lo:
						lz.x = lz.lo
						lz.dir = 1.0
						lz.pause = rng.randf_range(0.5, 1.6)
			1:
				if absf(lz.x - lz.tgt) > 0.3:
					lz.dir = signf(lz.tgt - lz.x)
					lz.x += lz.dir * LWALK * 1.6 * spd * dt
				else:
					lz.tt += dt
					lz.dir = 1.0 if fmod(lz.tt, 1.4) < 0.7 else -1.0  # 두리번
					if lz.tt > 2.2:
						lz.st = 5 if lz.sleeper else 0
			2:
				lz.dir = signf(dx) if dx != 0.0 else lz.dir
				lz.x += lz.dir * LRUN * spd * dt
				lz.roar -= dt
				if lz.roar <= 0.0:
					lz.roar = 0.45
					beep(180.0, 0.12, 120.0, 0.22)
				if absf(dx) < 0.75 and py < 1.1:
					_die("물렸다")
					return
				if safe and absf(dx) < 1.2:
					lz.st = 4
					lz.tt = 0.0
				elif absf(dx) > 14.0:
					lz.st = 1
					lz.tgt = lz.x
					lz.tt = 0.0
			3:
				lz.tt -= dt
				if lz.tt <= 0.0:
					lz.st = 1
					lz.tgt = px
					lz.tt = 0.0
					lz.body.material_override = mat(BAD)
					lz.head.material_override = mat(BAD)
			4:
				lz.dir = signf(dx) if dx != 0.0 else lz.dir
				lz.tt += dt
				if lz.tt > 5.0:
					lz.st = 5 if lz.sleeper else 0
					lz.pause = 0.0
		# 물속 도마뱀은 첨벙거린다(어디 있는지 들린다)
		if wading and absf(lz.x - x0) > 0.001:
			lz.sp -= dt
			if lz.sp <= 0.0:
				lz.sp = 0.5
				beep(220.0, 0.05, 110.0, 0.1)
		# 눈: 자는 놈은 없다. 갈대 속에선 흔들림만. 그 밖엔 앞쪽, 기면 가까이서만, 바로 옆은 어디든
		if lz.st in [0, 1, 4] and not safe:
			var see := false
			if in_reeds:
				if moving and absf(dx) < 1.2:
					see = true
				elif moving and absf(dx) < 5.0 and lz.st != 4:
					lz.st = 1
					lz.tgt = px
					lz.tt = 0.0
					if sway_t <= 0.0:
						sway_t = 0.6
						beep(1500.0, 0.04, 900.0, 0.1)
			else:
				var far := 3.5 if crawl else 9.0
				if reg == 5 and not _in(roofs, px):
					far *= 0.55
				see = absf(dx) < 1.2 or (dx * lz.dir > 0.0 and absf(dx) < far and py < 1.5)
			if see:
				lz.st = 2
				lz.roar = 0.0
				msg("들켰다!", 0.5)
				beep(320.0, 0.2, 200.0, 0.3)
		lz.x = clampf(lz.x, 0.5, wd - 3.5)
		lz.root.position = Vector3(lz.x, 0.0, 0.0)
		lz.root.visible = lz.st == 2 or not _in(reed_spans, lz.x)
		var asleep := lz.st == 5
		lz.head.position = Vector3(lz.dir * 0.8, 0.25 if asleep else (0.7 if lz.st in [1, 2, 4] else 0.45), 0.0)
		lz.body.scale = Vector3(1.6 if lz.st == 2 else 1.3, 0.3 if asleep else 0.5, 0.5)
		lz.body.position.y = 0.15 if asleep else 0.3


func _die(why: String) -> void:
	me_body.material_override = mat(BAD)
	me_head.material_override = mat(BAD)
	msg(why, 1.5)
	end()


# ---- 그리기 ----
func _rain(dt: float) -> void:
	var n := NRAIN if reg == 5 else (0 if rain_t > 10.0 else int(NRAIN * (1.0 - rain_t / 10.0)))
	for i in NRAIN:
		var r := rain[i]
		if i >= n:
			r.visible = false
			continue
		if not r.visible:
			r.visible = true
			r.position = Vector3(cam_x + rng.randf_range(-10.0, 10.0), rng.randf_range(2.0, 14.0), 1.0)
		r.position.y -= 16.0 * dt
		if r.position.y < 0.0 or (r.position.y < 2.8 and _in(roofs, r.position.x)):
			r.position = Vector3(cam_x + rng.randf_range(-10.0, 10.0), 12.0 + rng.randf_range(0.0, 4.0), 1.0)


func _view(dt: float) -> void:
	me_root.position = Vector3(px, py, 0.0)
	me_root.scale = Vector3(1.0, 0.5 if crawl else 1.0, 1.0)
	me_head.position.x = face * 0.1
	me_rock.visible = has_rock
	me_rock.position.x = face * 0.4
	door.material_override = mat(GOOD if eaten >= NEED else SOFT)
	var k := 1.0 - exp(-5.0 * dt)
	# 나무: 소리가 나면 흔들린다
	for tr in trees:
		var c := tr.n as MeshInstance3D
		tr.sh = maxf(0.0, float(tr.sh) - dt)
		c.position.x = float(tr.x) + (sin(clock * 50.0) * 0.12 if float(tr.sh) > 0.0 else 0.0)
	# 갈대: 움직이는 것 옆에서 기운다(밑동 기준)
	var moving := absf(kit_move.x) > 0.12 and not on_pole
	for rd in reeds:
		var x: float = rd.x
		var want := 0.0
		if moving and absf(x - px) < 0.9:
			want = 0.35 * face
		for lz in lizards:
			if lz.st in [1, 2] or (lz.st == 0 and lz.pause <= 0.0):
				if absf(x - lz.x) < 0.9:
					want = 0.35 * lz.dir
		if want != 0.0:
			want *= 0.75 + 0.25 * sin(clock * 22.0 + x)
		rd.a = lerpf(float(rd.a), want, 1.0 - exp(-10.0 * dt))
		var a: float = rd.a
		var h: float = rd.h
		var m := rd.n as MeshInstance3D
		m.rotation.z = -a
		m.position = Vector3(x + sin(a) * h * 0.5, cos(a) * h * 0.5, 1.0)
	cam_x = lerpf(cam_x, clampf(px, 7.0, wd - 7.0), k)
	cam.position = Vector3(cam_x, 3.0, 16.0)
	cam.rotation = Vector3(-0.08, 0.0, 0.0)
