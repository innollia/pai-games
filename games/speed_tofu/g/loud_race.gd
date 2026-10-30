extends Tofu
## 시끄러운 1등 (옆모습 밤 숲 4인 경주): 스틱 살짝 = 살금(조용·느림), 끝까지 = 뛰기(빠름·시끄러움), 점프. 화면은 1등을 따라가고 왼쪽 끝에 밀리면 탈락. 올빼미는 가장 시끄러운 주자를 노려 덮친다.
## 앞사람 바로 뒤에 붙어 뛰면 그 소리에 묻힌다. 1등으로 결승을 넘어야 다음 구역. 구역마다 소리 규칙: 마른 잎(살금도 바스락) · 개울(물속은 소리 0, 둑은 1.5배, 나온 직후 물방울) · 동굴(울림, 열기가 천천히 식음).
# 한 문장: 나는 밤 숲 경주에 나선 막내 들쥐로서 "화면은 1등만 따라가고 올빼미는 가장 시끄러운 주자를 덮친다"는 숲에서 살금과 질주를 오가며 1등으로 결승을 넘지만, 빨리 갈수록 발소리가 커져 사냥감 1순위가 되는 대가를 감수한다.
# 부모: screenrace(화면 밖 탈락, 앞사람 뒤 붙기) × rain_slow(한 스틱 살금/뛰기, 소리=포식자, 지역마다 소리 규칙). 갈고리·아이템 없음.

const GRAV := 34.0
const JUMP_V := 12.5
const RUN := 9.0
const SNEAK := 3.2
const ACC := 40.0
const FRICTION := 30.0
const MAX_FALL := 24.0
const HW := 0.35
const HH := 0.9
const STEP := 0.55
const COYOTE := 0.1
const JBUF := 0.12
const CAM_D := 22.0
const VIEW := 10.5  # 화면 반폭
const BX0 := -40.0
const BK := 6.0
const LOCK_MIN := 0.45  # 이 열기 넘는 가장 시끄러운 주자를 노린다
const CATCH := 0.35  # 덮칠 때 이보다 시끄러우면 잡힌다
const DIVE_T := 0.7
const SHADOW_K := 0.4  # 앞사람 뒤에 붙으면 내 소리 배율
const NIGHT := Color("6f86e0")  # 밝은 남색 하늘
const CAVE_SKY := Color("9b8cf0")
const LEAF := Color("ff922b")
const GRAVEL := Color("dee2e6")
const WOOD := Color("e0a96d")
const ZONES := [
	{"name": "마른 잎 숲", "say": "가장 시끄러운 자가 잡힌다", "pred": "올빼미",
		"gnd": Color("fff4e6"), "top": Color("ffd8a8"), "lock": 1.8, "echo": 1.0, "cool": 1.0, "cave": false,
		"segs": [["f", 10], ["leaf", 3], ["f", 8], ["log"], ["f", 6], ["leaf", 5], ["f", 7], ["pit", 2.8], ["f", 9],
			["leaf", 8], ["f", 6], ["log"], ["leaf", 3], ["f", 8], ["pit", 3.2], ["f", 6], ["leaf", 4], ["f", 5],
			["log"], ["f", 10], ["leaf", 9], ["f", 8], ["log"], ["f", 6], ["leaf", 3], ["f", 7], ["pit", 2.6],
			["leaf", 4], ["f", 6], ["leaf", 12], ["f", 5], ["log"], ["leaf", 3], ["f", 5], ["leaf", 3], ["f", 12]]},
	{"name": "개울", "say": "물속은 물소리가 덮는다. 둑은 시끄럽다", "pred": "올빼미",
		"gnd": Color("ebfbee"), "top": Color("b2f2bb"), "lock": 1.8, "echo": 1.0, "cool": 1.0, "cave": false,
		"segs": [["f", 8], ["creek", 9], ["bank", 5], ["creek", 7], ["log"], ["bank", 4], ["creek", 12], ["f", 5],
			["pit", 3.0], ["bank", 4], ["creek", 8], ["bank", 7], ["creek", 6], ["leaf", 4], ["creek", 10],
			["bank", 5], ["f", 6], ["creek", 9], ["bank", 3], ["creek", 4], ["bank", 3], ["creek", 4], ["log"],
			["bank", 8], ["pit", 2.8], ["creek", 14], ["bank", 4], ["f", 10]]},
	{"name": "동굴", "say": "울린다: 한번 낸 소리는 천천히 식는다", "pred": "박쥐떼",
		"gnd": Color("f3f0ff"), "top": Color("d0bfff"), "lock": 1.5, "echo": 1.4, "cool": 0.25, "cave": true,
		"segs": [["f", 10], ["log"], ["f", 14], ["pit", 3.0], ["f", 8], ["leaf", 3], ["f", 10], ["log"], ["f", 16]]},
]


class Runner:
	var p := Vector2.ZERO  # 발 가운데
	var v := Vector2.ZERO
	var grounded := false
	var alive := true
	var ai := true
	var nick := ""
	var col := Color.WHITE
	var kind := 0  # 0 나, 1 겁없음, 2 꾀돌이, 3 소심
	var wit := 0.5  # 노려질 때 알아채고 조용해질 확률
	var skill := 1.0
	var think := 0.0
	var hush := 0.0
	var node: Node3D
	var bar: MeshInstance3D
	var poof: MeshInstance3D
	var poof_t := 0.0
	var heat := 0.0  # 머리 위 막대: 지금까지 낸 소리 (올빼미가 듣는 값)
	var noise := 0.0
	var wet := 0.0
	var shadow := false
	var coyote := 0.0
	var jbuf := 0.0
	var step_t := 0.0
	var face := 1.0
	var mx := 0.0
	var i_jump := false


var zi := 0  # 구역 (죽어도 그대로: 그 구역부터 다시)
var zdef: Dictionary
var phase := "count"
var pt := 0.0
var rects: Array[Rect2] = []
var buckets: Array = []
var leaves: Array[Vector2] = []
var creeks: Array[Vector2] = []
var banks: Array[Vector2] = []
var gx := 0.0
var goal_x := 0.0
var runners: Array[Runner] = []
var pl: Runner
var camx := 0.0
var camy := 3.0
var vhv := 18.0
var shk := 0.0
var edge_strip: MeshInstance3D
var marker: MeshInstance3D
# 올빼미
var owl: Node3D
var owl_body: MeshInstance3D
var wings: Array[MeshInstance3D] = []
var owl_shadow: MeshInstance3D
var ow_x := 0.0
var ow_y := 14.0
var ow_st := 0  # 0 맴돎·노림, 1 덮침, 2 올라감
var ow_tgt: Runner
var ow_lock := 0.0
var ow_t := 0.0
var ow_cd := 0.0
var ow_beep := 0.0
var edge_tick := 0.0
var land_dust := 0.0


func _setup() -> void:
	time_limit = 0.0
	cam.keep_aspect = Camera3D.KEEP_WIDTH
	howto = "밤 숲 4인 경주. 스틱 살짝 = 살금(조용·느림), 끝까지 = 뛰기(빠름·시끄러움). 점프 버튼.\n올빼미는 머리 위 막대가 가장 긴(가장 시끄러운) 주자를 노리다 덮친다. 덮칠 때 조용해지면 놓친다. 앞사람 바로 뒤에 붙어 뛰면 그 소리에 묻힌다.\n화면은 1등을 따라간다. 왼쪽 끝에 밀리거나 잡히면 탈락. 1등으로 결승을 넘어야 다음 구역(마른 잎 → 개울 → 동굴)."
	kit_stick()
	kit_button("jump", "점프", Vector2(600, 1110), 100.0, A)


func _reset() -> void:
	zdef = ZONES[zi]
	_sky(CAVE_SKY if zdef.cave else NIGHT)
	runners.clear()
	var cols := [ME, A, B, Color("f783ac")]
	var nicks := ["나", "주황", "하늘", "분홍"]
	var wits := [0.0, 0.35, 0.85, 0.9]
	for i in 4:
		var r := Runner.new()
		r.ai = i > 0
		r.kind = i
		r.col = cols[i]
		r.nick = nicks[i]
		r.wit = wits[i]
		r.skill = 1.0 if i == 0 else 0.95 + 0.012 * zi + (0.01 if i == 1 else 0.0)
		_make_body(r)
		runners.append(r)
	pl = runners[0]
	_build()
	_make_owl()
	edge_strip = box(Vector3.ZERO, Vector3(0.35, 1, 0.2), BAD)
	marker = box(Vector3.ZERO, Vector3(0.3, 0.3, 0.3), ME)
	marker.rotation.z = PI * 0.25
	var xs := [-2.0, -0.8, -3.2, -4.4]
	for i in 4:
		var r := runners[i]
		r.p = Vector2(xs[i], 0.0)
		_probe(r)
	camx = 2.0
	camy = 3.0
	phase = "count"
	pt = 1.6
	msg("%d %s: %s" % [zi + 1, zdef.name, zdef.say], 2.4)
	beep(440.0, 0.12)


func _sky(c: Color) -> void:
	for n in get_children():
		if n is WorldEnvironment:
			(n as WorldEnvironment).environment.background_color = c


func _make_body(r: Runner) -> void:
	r.node = Node3D.new()
	world.add_child(r.node)
	box(Vector3(0, 0, 0), Vector3(HW * 2.0, HH * 0.7, 0.7), r.col, r.node)
	box(Vector3(0.2, 0.42, 0), Vector3(0.42, 0.34, 0.5), SOFT, r.node)
	box(Vector3(0.05, 0.66, 0), Vector3(0.18, 0.2, 0.18), WHITE if not r.ai else r.col.lightened(0.3), r.node)
	r.bar = box(Vector3(0, 1.3, 0), Vector3(1, 0.16, 0.16), GOOD, r.node)
	r.poof = box(Vector3.ZERO, Vector3(1, 1, 1), WHITE)
	r.poof.visible = false


func _make_owl() -> void:
	wings.clear()
	owl = Node3D.new()
	world.add_child(owl)
	var bc: Color = C if zdef.cave else Color("b197fc")
	owl_body = box(Vector3.ZERO, Vector3(1.0, 1.2, 0.8), bc, owl)
	box(Vector3(-0.22, 0.25, 0.42), Vector3(0.26, 0.26, 0.1), D, owl)
	box(Vector3(0.22, 0.25, 0.42), Vector3(0.26, 0.26, 0.1), D, owl)
	for s in [-1.0, 1.0]:
		var w := box(Vector3(s * 1.1, 0.1, 0), Vector3(1.4, 0.2, 0.6), bc.darkened(0.15), owl)
		wings.append(w)
	owl_shadow = box(Vector3.ZERO, Vector3(1, 0.08, 1.2), INK)
	owl_shadow.visible = false
	ow_x = camx
	ow_y = 14.0
	ow_st = 0
	ow_tgt = null
	ow_lock = 0.0
	ow_cd = 1.5


# ---- 코스 ----
func _build() -> void:
	rects.clear()
	leaves.clear()
	creeks.clear()
	banks.clear()
	_floor(-30.0, 34.0, 0.0)
	gx = 4.0
	for sg in zdef.segs:
		_seg(sg)
	goal_x = gx + 1.0
	_floor(gx, 40.0, 0.0)
	for z in [-1.3, 1.3]:
		box(Vector3(goal_x, 2.4, z), Vector3(0.3, 4.8, 0.3), GOOD)
	for k in 6:
		box(Vector3(goal_x, 4.8, -1.25 + k * 0.5), Vector3(0.32, 0.4, 0.5), WHITE if k % 2 == 0 else INK)
	buckets.clear()
	var nb := int((gx + 60.0 - BX0) / BK) + 1
	for b in nb:
		buckets.append([])
	for i in rects.size():
		var rc := rects[i]
		for b in range(_bi(rc.position.x), _bi(rc.end.x) + 1):
			buckets[b].append(i)
	# 배경: 달, 먼 나무(느리게), 앞 울타리 말뚝(빠르게)
	var g := RandomNumberGenerator.new()
	g.seed = 77 + zi
	box(Vector3(gx * 0.5, 20.0, -40.0), Vector3(5, 5, 1), D)
	if zdef.cave:
		var cx := -20.0
		while cx < gx + 30.0:
			var h := g.randf_range(1.0, 3.0)
			box(Vector3(cx, 7.5 - h * 0.5, -0.5), Vector3(g.randf_range(2.0, 5.0), h, 3.0), zdef.top)
			cx += g.randf_range(5.0, 8.0)
		box(Vector3(gx * 0.5, 9.0, -1.0), Vector3(gx + 80.0, 2.5, 4.0), Color("e5dbff"))
	else:
		var tcols := [Color("dbe4ff"), Color("c5f6fa"), Color("e5dbff")]
		var tx := -20.0
		while tx < gx + 30.0:
			var h := g.randf_range(6.0, 11.0)
			var z := -9.0 - g.randf() * 4.0
			box(Vector3(tx, h * 0.5 - 1.0, z), Vector3(0.7, h, 0.7), Color("fff4e6"))
			box(Vector3(tx, h - 1.0, z), Vector3(g.randf_range(3.0, 4.5), g.randf_range(2.5, 3.5), 2.0), tcols[g.randi() % 3])
			tx += g.randf_range(7.0, 10.0)
	var px := 0.0
	while px < goal_x:
		box(Vector3(px, 0.8, 2.8), Vector3(0.2, 1.6, 0.2), WHITE)
		px += 10.0


func _seg(sg: Array) -> void:
	var k: String = sg[0]
	var w: float = sg[1] if sg.size() > 1 else 6.0
	match k:
		"f":
			_floor(gx, w, 0.0)
		"leaf":
			_floor(gx, w, 0.0)
			box(Vector3(gx + w * 0.5, 0.06, 0), Vector3(w, 0.14, 2.2), LEAF)
			leaves.append(Vector2(gx, gx + w))
		"log":
			_floor(gx, w, 0.0)
			_solid(Rect2(gx + 3.0, 0.0, 0.9, 1.0), WOOD, 1.6)
		"pit":
			_floor(gx, 2.0, 0.0)
			gx += 2.0
		"creek":  # 0.5 낮은 물길, 물이 발목까지
			_floor(gx, w, -0.5)
			box(Vector3(gx + w * 0.5, -0.32, 0), Vector3(w, 0.36, 2.6), B)
			creeks.append(Vector2(gx, gx + w))
		"bank":  # 자갈 둑
			_floor(gx, w, 0.0)
			box(Vector3(gx + w * 0.5, 0.05, 0), Vector3(w, 0.12, 2.2), GRAVEL)
			banks.append(Vector2(gx, gx + w))
	gx += w


func _floor(x: float, w: float, y: float) -> void:
	_solid(Rect2(x, y - 10.0, w, 10.0), zdef.gnd, 2.4)
	box(Vector3(x + w * 0.5, y - 0.08, 0), Vector3(w, 0.16, 2.5), zdef.top)


func _solid(rc: Rect2, c: Color, depth: float) -> void:
	rects.append(rc)
	var m := rc.get_center()
	box(Vector3(m.x, m.y, 0), Vector3(rc.size.x, rc.size.y, depth), c)


func _bi(x: float) -> int:
	return clampi(int(floor((x - BX0) / BK)), 0, buckets.size() - 1)


func _in(spans: Array[Vector2], x: float) -> bool:
	for s in spans:
		if x > s.x and x < s.y:
			return true
	return false


# ---- 판 ----
func _step(dt: float) -> void:
	shk = maxf(shk - dt * 2.5, 0.0)
	match phase:
		"count":
			var before := pt
			pt -= dt
			if before > 0.8 and pt <= 0.8:
				beep(440.0, 0.12)
			if pt <= 0.0:
				phase = "race"
				msg("출발!", 0.6)
				play("good")
		"race":
			_race(dt)
		"won":
			pt -= dt
			if pt <= 0.0:
				zi += 1
				if zi >= ZONES.size():
					zi = 0
					msg("동굴 너머는 다음 판에", 2.5)
					end()
					return
				restart()
				return
	_camera(dt)
	_draw_all(dt)


func _race(dt: float) -> void:
	pl.mx = kit_move.x
	pl.i_jump = kit_just("jump")
	for r in runners:
		if r.alive and r.ai:
			_ai(r, dt)
	for r in runners:
		if r.alive:
			_runner(r, dt)
	_noises(dt)
	_owl(dt)
	if over:
		return
	var left := camx - VIEW
	for r in runners:
		if not r.alive:
			continue
		if r.p.y < -8.0:
			_out(r, "떨어졌다!")
		elif r.p.x + HW < left + 0.1:
			_out(r, "밀려났다!")
	if over:
		return
	for r in runners:
		if r.alive and r.p.x > goal_x:
			if r == pl:
				score += 100 + 20 * zi
				phase = "won"
				pt = 1.8
				play("win")
				msg("1등 통과!", 1.8)
			else:
				_lose("%s 1등" % r.nick)
			return
	score = maxi(score, zi * 120 + int(pl.p.x / 4.0))
	# 화면 왼쪽 끝 압박
	var ed := pl.p.x - left
	edge_tick -= dt
	if ed < 3.5 and edge_tick <= 0.0:
		edge_tick = 0.08 + ed * 0.07
		beep(1200.0 - ed * 150.0, 0.04, 0.0, 0.12)
	gauge(pl.heat, GOOD if pl.heat < LOCK_MIN else (A if pl.heat < 0.8 else BAD))


func _lose(why: String) -> void:
	msg(why, 1.6)
	end()


func _out(r: Runner, why: String) -> void:
	r.alive = false
	r.node.visible = false
	r.poof.visible = true
	r.poof_t = 0.5
	r.poof.position = Vector3(clampf(r.p.x, camx - VIEW + 0.6, camx + VIEW), maxf(r.p.y, camy - vhv + 2.0), 0.5)
	if ow_tgt == r:
		ow_tgt = null
	if r == pl:
		shk = 0.6
		_lose(why)
	else:
		beep(300.0, 0.2, 120.0, 0.25)
		shk = maxf(shk, 0.25)
		msg("%s %s" % [r.nick, "잡혔다" if why == "잡혔다!" else "탈락"], 0.7)


# ---- 주자 한 명 ----
func _runner(r: Runner, dt: float) -> void:
	var amt := absf(r.mx)
	var top := 0.0
	if amt > 0.12:
		top = (RUN * r.skill if amt >= 0.65 else SNEAK)
		if _in(creeks, r.p.x):
			top *= 0.85
		r.face = signf(r.mx)
		var want := signf(r.mx) * top
		r.v.x = move_toward(r.v.x, want, (ACC if r.grounded else ACC * 0.5) * dt)
	else:
		r.v.x = move_toward(r.v.x, 0.0, (FRICTION if r.grounded else 4.0) * dt)
	r.coyote = COYOTE if r.grounded else maxf(r.coyote - dt, 0.0)
	r.jbuf = JBUF if r.i_jump else maxf(r.jbuf - dt, 0.0)
	if r.jbuf > 0.0 and r.coyote > 0.0:
		r.v.y = JUMP_V
		r.coyote = 0.0
		r.jbuf = 0.0
		r.grounded = false
		_snd(r, 520.0, 0.06, 760.0, 0.14)
	var was := r.grounded
	var fall := r.v.y
	r.v.y = maxf(r.v.y - GRAV * dt, -MAX_FALL)
	for s in 2:
		_mx(r, r.v.x * dt * 0.5)
		_my(r, r.v.y * dt * 0.5)
	_probe(r)
	# 착지: 높이 떨어질수록 쿵 소리가 열기에 바로 붙는다
	if r.grounded and not was:
		var hit := clampf(-fall / 16.0, 0.0, 1.0)
		var mul := 0.0 if _in(creeks, r.p.x) else (1.5 if _in(banks, r.p.x) or _in(leaves, r.p.x) else 1.0)
		r.heat = maxf(r.heat, hit * 0.45 * mul * float(zdef.echo))
		_snd(r, 120.0 if mul > 0.0 else 300.0, 0.07, 0.0 if mul > 0.0 else 150.0, 0.16)


## 소리 → 열기. 살금 0.12, 뛰기 1.0, 마른 잎은 살금도 0.65, 물속 0, 자갈 1.5배, 앞사람 뒤 0.4배
func _noises(dt: float) -> void:
	for r in runners:
		if not r.alive:
			continue
		var spd := absf(r.v.x)
		var n := 0.0
		if r.grounded and spd > 0.4:
			n = 0.12 + 0.88 * clampf((spd - SNEAK) / (RUN - SNEAK), 0.0, 1.0)
			if _in(leaves, r.p.x):
				n = maxf(n * 1.2, 0.65)
			elif _in(banks, r.p.x):
				n *= 1.5
			if r.wet > 0.0 and spd > SNEAK + 1.0:
				n += 0.4
			if _in(creeks, r.p.x):
				n = 0.0
		if _in(creeks, r.p.x) and r.grounded:
			r.wet = 1.2
		else:
			r.wet = maxf(r.wet - dt, 0.0)
		n *= float(zdef.echo)
		# 소리 그림자: 앞사람 0.8~3.5m 뒤
		r.shadow = false
		for o in runners:
			if o != r and o.alive:
				var dx := o.p.x - r.p.x
				if dx > 0.8 and dx < 3.5 and absf(o.p.y - r.p.y) < 1.5:
					r.shadow = true
					break
		if r.shadow:
			n *= SHADOW_K
		r.noise = n
		if n > r.heat:
			r.heat = move_toward(r.heat, n, 3.0 * dt)
		else:
			r.heat = move_toward(r.heat, n, float(zdef.cool) * dt)
		# 발소리 (나만 크게, 남은 화면 안에서 작게)
		r.step_t -= dt
		if r.grounded and spd > 0.4 and r.step_t <= 0.0:
			if _in(creeks, r.p.x):
				r.step_t = 0.3
				_snd(r, 300.0, 0.06, 150.0, 0.1)
			elif _in(leaves, r.p.x):
				r.step_t = 0.14
				_snd(r, 1700.0, 0.03, 900.0, 0.12)
			elif spd > SNEAK + 1.0:
				r.step_t = 0.2
				_snd(r, 110.0 if not _in(banks, r.p.x) else 900.0, 0.04, 0.0, 0.08 + 0.1 * clampf(r.heat, 0.0, 1.0))
			else:
				r.step_t = 0.45
				_snd(r, 700.0, 0.02, 0.0, 0.05)


## 올빼미: 열기가 LOCK_MIN 넘는 가장 시끄러운 주자를 노리고, 다 차면 덮친다. 덮칠 때 조용하면 놓친다.
func _owl(dt: float) -> void:
	var top_y := camy + vhv * 0.55
	var loud: Runner = null
	for r in runners:
		if not r.alive or r.heat < LOCK_MIN:
			continue
		if loud == null or r.heat > loud.heat + 0.03 or (absf(r.heat - loud.heat) <= 0.03 and r.p.x > loud.p.x):
			loud = r
	match ow_st:
		0:
			ow_cd -= dt
			if loud != ow_tgt:
				ow_lock *= 0.5
				ow_tgt = loud
				if loud == pl and ow_cd <= 0.0:
					msg("%s가 나를 본다" % zdef.pred, 0.6)
			if ow_tgt and ow_cd <= 0.0:
				ow_lock += dt / float(zdef.lock)
			else:
				ow_lock = maxf(ow_lock - dt * 0.6, 0.0)
			var tx := ow_tgt.p.x if ow_tgt else camx + sin(Time.get_ticks_msec() * 0.0007) * VIEW * 0.5
			ow_x = lerpf(ow_x, tx, 1.0 - exp(-3.0 * dt))
			ow_y = lerpf(ow_y, top_y - ow_lock * 4.0, 1.0 - exp(-3.0 * dt))
			ow_beep -= dt
			if ow_tgt == pl and ow_beep <= 0.0:
				ow_beep = lerpf(0.4, 0.1, ow_lock)
				beep(380.0 + ow_lock * 700.0, 0.05, 0.0, 0.16)
			if ow_lock >= 1.0 and ow_tgt:
				ow_st = 1
				ow_t = DIVE_T
				beep(900.0, DIVE_T, 200.0, 0.25)
				if ow_tgt == pl:
					msg("덮친다! 조용히!", 0.7)
					shk = maxf(shk, 0.2)
		1:
			ow_t -= dt
			if ow_tgt == null or not ow_tgt.alive:
				ow_st = 2
			else:
				ow_x = lerpf(ow_x, ow_tgt.p.x, 1.0 - exp(-12.0 * dt))
				ow_y = lerpf(ow_y, ow_tgt.p.y + 1.0, 1.0 - exp(-6.0 * dt))
				if ow_t <= 0.0:
					if ow_tgt.heat >= CATCH:
						var who := ow_tgt
						ow_tgt = null
						_out(who, "잡혔다!")
					else:
						beep(500.0, 0.1, 900.0, 0.2)
						if ow_tgt == pl:
							play("good")
							msg("놓쳤다!", 0.6)
					ow_st = 2
					ow_cd = 1.4
					ow_lock = 0.0
		2:
			ow_y = lerpf(ow_y, top_y, 1.0 - exp(-4.0 * dt))
			ow_x = lerpf(ow_x, camx, 1.0 - exp(-1.0 * dt))
			ow_cd -= dt
			if absf(ow_y - top_y) < 1.0:
				ow_st = 0
				ow_tgt = null


# ---- 경쟁자 ----
## 겁없음: 늘 뛴다. 꾀돌이: 1등이면 열기를 보고 살금, 노려지면 급정거. 소심: 화면 끝이 멀면 살금.
func _ai(r: Runner, dt: float) -> void:
	r.i_jump = false
	r.hush = maxf(r.hush - dt, 0.0)
	r.think -= dt
	if r.think > 0.0:
		return
	r.think = randf_range(0.06, 0.12)
	var room := r.p.x - (camx - VIEW)
	var togo := goal_x - r.p.x
	var lead := _leader() == r
	var want := 1.0
	match r.kind:
		2:
			if lead and r.heat > 0.5 and togo > 30.0:
				want = 0.5
		3:
			if room > 7.0 and togo > 25.0:
				want = 0.5
	if zdef.cave and r.kind != 1 and r.heat > 0.3 and room > 4.0 and togo > 15.0:
		want = 0.5
	if _in(creeks, r.p.x):
		want = 1.0
	elif r.wet > 0.0 and r.kind != 1 and room > 5.0:
		want = 0.5
	if ow_tgt == r and (ow_st == 1 or ow_lock > 0.6) and randf() < r.wit:
		r.hush = 0.9
	if r.hush > 0.0:
		want = 0.5 if r.kind == 1 else 0.0
	# 앞 구덩이는 살금으로 못 넘는다: 미리 뛴다
	var pit_far := _floor_top(r.p.x + HW + 3.5, r.p.y + 0.6) < r.p.y - 2.0
	if pit_far or room < 2.5:
		want = 1.0
	r.mx = want
	if r.grounded:
		var look := 0.5 + absf(r.v.x) * 0.1
		var wall := _solid_in(Rect2(r.p.x + HW, r.p.y + STEP + 0.05, look, 1.2))
		var pit := _floor_top(r.p.x + HW + 0.3 + absf(r.v.x) * 0.04, r.p.y + 0.6) < r.p.y - 2.0
		if (wall or pit) and randf() > 0.12:
			r.i_jump = true
		# 짧은 잎 더미는 뛰어 넘는다
		if r.kind != 1 and absf(r.v.x) > 6.0:
			for s in leaves:
				var d := s.x - r.p.x
				if d > 0.6 and d < 1.4 and s.y - s.x < 5.5:
					r.i_jump = true


func _leader() -> Runner:
	var w: Runner = null
	for r in runners:
		if r.alive and (w == null or r.p.x > w.p.x):
			w = r
	return w


# ---- 충돌 ----
func _box(r: Runner) -> Rect2:
	return Rect2(r.p.x - HW, r.p.y, HW * 2.0, HH)


func _mx(r: Runner, dx: float) -> void:
	if dx == 0.0:
		return
	r.p.x += dx
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if not q.intersects(a):
				continue
			if r.grounded and q.end.y - r.p.y <= STEP:
				r.p.y = q.end.y
				a = _box(r)
				continue
			if dx > 0.0:
				r.p.x = q.position.x - HW - 0.001
			else:
				r.p.x = q.end.x + HW + 0.001
			if absf(r.v.x) > 6.0:
				_snd(r, 160.0, 0.1, 80.0, 0.2)
				r.heat = maxf(r.heat, 0.7 * float(zdef.echo))  # 통나무에 박으면 쿵
				if r == pl:
					shk = maxf(shk, 0.3)
			if signf(r.v.x) == signf(dx):
				r.v.x = 0.0
			a = _box(r)


func _my(r: Runner, dy: float) -> void:
	if dy == 0.0:
		return
	r.p.y += dy
	var a := _box(r)
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if q.intersects(a):
				if dy < 0.0:
					r.p.y = q.end.y
					r.v.y = 0.0
				else:
					r.p.y = q.position.y - HH - 0.001
					r.v.y = minf(r.v.y, 0.0)
				a = _box(r)


func _probe(r: Runner) -> void:
	var f := Rect2(r.p.x - HW + 0.05, r.p.y - 0.06, HW * 2.0 - 0.1, 0.07)
	r.grounded = false
	for b in range(_bi(f.position.x), _bi(f.end.x) + 1):
		for i in buckets[b]:
			var q: Rect2 = rects[i]
			if q.intersects(f) and q.end.y <= r.p.y + 0.02:
				r.grounded = true
				return


func _floor_top(x: float, ymax: float) -> float:
	var best_y := -1.0e9
	for i in buckets[_bi(x)]:
		var q: Rect2 = rects[i]
		if x > q.position.x and x < q.end.x and q.end.y <= ymax:
			best_y = maxf(best_y, q.end.y)
	return best_y


func _solid_in(a: Rect2) -> bool:
	for b in range(_bi(a.position.x), _bi(a.end.x) + 1):
		for i in buckets[b]:
			if (rects[i] as Rect2).intersects(a):
				return true
	return false


func _snd(r: Runner, f: float, d: float, to := 0.0, vol := 0.18) -> void:
	if r == pl:
		beep(f, d, to, vol)
	elif r.alive and absf(r.p.x - camx) < VIEW:
		beep(f, d, to, vol * 0.4)


# ---- 카메라와 그리기 ----
func _camera(dt: float) -> void:
	var vs := get_viewport().get_visible_rect().size
	vhv = VIEW * vs.y / maxf(vs.x, 1.0)
	var lead := _leader()
	if lead and phase == "race":
		camx = lerpf(camx, lead.p.x - VIEW * 0.25, 1.0 - exp(-8.0 * dt))
		camy = lerpf(camy, lead.p.y + 4.0, 1.0 - exp(-4.0 * dt))
	cam.fov = rad_to_deg(2.0 * atan(VIEW / CAM_D))
	cam.rotation = Vector3.ZERO
	cam.position = Vector3(camx + randf_range(-1.0, 1.0) * shk * 0.4, camy + randf_range(-1.0, 1.0) * shk * 0.4, CAM_D)


func _draw_all(dt: float) -> void:
	var tm := Time.get_ticks_msec() * 0.001
	for r in runners:
		r.poof.visible = r.poof_t > 0.0
		if r.poof_t > 0.0:
			r.poof_t -= dt
			var s := 1.0 + (0.5 - r.poof_t) * 6.0
			r.poof.scale = Vector3(s, s, s)
		if not r.alive:
			continue
		var spd := absf(r.v.x)
		var sneaking := r.grounded and spd > 0.4 and spd < SNEAK + 0.5
		var bob := sin(tm * (8.0 + spd * 1.5)) * 0.05 if r.grounded and spd > 0.4 else 0.0
		r.node.position = Vector3(r.p.x, r.p.y + HH * 0.35 + bob, 0)
		r.node.scale = Vector3(r.face, 0.65 if sneaking else 1.0, 1.0)
		r.node.rotation.z = -clampf(r.v.x * 0.02, -0.25, 0.25)
		var hv := clampf(r.heat, 0.0, 1.5)
		r.bar.visible = hv > 0.03
		r.bar.scale = Vector3(maxf(hv * 1.6, 0.05), 0.16, 0.16)
		r.bar.material_override = mat(GOOD if hv < LOCK_MIN else (A if hv < 0.8 else BAD))
		r.bar.position.y = (1.3 if not sneaking else 1.9)
	marker.visible = pl.alive
	marker.position = Vector3(pl.p.x, pl.p.y + HH + 1.3 + sin(tm * 5.0) * 0.1, 0)
	# 올빼미
	owl.position = Vector3(ow_x, ow_y, 0.5)
	var flap := sin(tm * (10.0 if ow_st == 0 else 3.0)) * 0.5
	for k in 2:
		wings[k].rotation.z = flap * (1.0 if k == 0 else -1.0) if ow_st != 1 else (0.9 if k == 0 else -0.9)
	var hot := ow_lock if ow_st == 0 else (1.0 if ow_st == 1 else 0.0)
	owl_body.material_override = mat(BAD if hot > 0.7 else (C if zdef.cave else Color("b197fc")))
	owl_shadow.visible = ow_tgt != null and ow_tgt.alive and (ow_lock > 0.1 or ow_st == 1)
	if owl_shadow.visible:
		var sw := 0.4 + hot * 2.2
		owl_shadow.position = Vector3(ow_tgt.p.x, ow_tgt.p.y + 0.05, 0.4)
		owl_shadow.scale = Vector3(sw, 0.08, 1.2)
	# 왼쪽 화면 끝 경고 띠
	var k2 := (CAM_D - 1.6) / CAM_D
	var ed := pl.p.x - (camx - VIEW)
	edge_strip.visible = phase == "race" and pl.alive and ed < 4.0 and (ed > 2.0 or fmod(tm, 0.16) < 0.1)
	edge_strip.position = Vector3(camx - VIEW * k2 + 0.18, camy, 1.6)
	edge_strip.scale = Vector3(0.35 + maxf(0.0, 4.0 - ed) * 0.1, vhv * 2.0, 0.2)
