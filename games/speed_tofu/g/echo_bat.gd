extends Tofu
## 세로 동굴을 옆에서 본다. 스틱 살짝 = 천천히(초음파 자주), 끝까지 = 빠르게(초음파 드문드문). 외침 = 멀리 보임(기운 -12, 나방 흩어짐). 위쪽 둥지까지.
## 초음파가 닿은 곳만 잠깐 보이고 나머지는 연한 안개. 빠르게 벽에 닿으면 죽고, 느리게만 날면 기운이 바닥난다. 나방을 먹으면 기운.
## 구역마다 누가 소리를 내는지 바뀐다: 입구 굴(내 소리만) · 물방울 굴(물방울이 박자 맞춰 비춤) · 수정 굴(수정이 울림을 붙잡고 다시 울림, 맛보기). 죽으면 그 구역부터.
# 한 문장: 나는 박쥐로서 소리가 닿은 곳만 보이는 세로 동굴 속에서 초음파를 내며 날아 위쪽 둥지에 닿지만, 빠를수록 소리 간격이 벌어져 못 본 벽에 박는 대가를 감수한다.

const FAST := 9.0  # 최대 속도
const SLOWEST := 1.2
const ACC := 11.0
const CRASH := 4.5  # 이보다 빠르게 벽에 닿으면 죽음
const WAVE_SP := 18.0
const PING_R := 6.5
const SHOUT_R := 14.0
const SHOUT_COST := 12.0
const FADE := 1.4  # 잔상 시간
const CRY_FADE := 5.0
const DRAIN := 3.5  # 기운 초당 소모
const MOTH_E := 18.0
const ROW := 2.0
const BAT_R := 0.3
const SEGS := 14
const FOG := Color("ece8f2")
const STONE := Color("d9a777")
const NAMES := ["입구 굴", "물방울 굴", "수정 굴"]
const RULES := ["소리가 닿은 곳만 보인다", "물방울 소리가 길을 비춘다", "수정이 울림을 붙잡는다"]
# 굴 모양: 줄마다(아래부터 2m) 왼쪽 벽 x, 오른쪽 벽 x
const ROWS := [
	[-4, 4, -4, 4, -4, 4, -3.5, 4, -3, 4.5, -2, 5, -1, 5, 0, 5.5, 0.5, 5, 1, 3.8, 1, 3.8, 0, 3.5, -1.5, 2.5, -3, 1.5, -4, 1, -5, 2, -5, 4, -5, 5, -5, 5, -4, 5,
		-2, 5, -1, 4, -1.5, 1.5, -1.5, 1.5, -1.5, 1.5, -2, 2, -3, 3, -4, 4, -4, 4, -3, 5, -1, 5, 1, 5.5, 1.5, 4.5, 1, 4, -1, 3, -3, 2, -4, 1.5, -4, 3, -4, 4, -4, 4],
	[-4, 4, -4, 4, -3, 3, -2, 3, -1, 3.5, 0, 4, 1, 4.5, 1, 4.5, 0, 3.5, -1, 2.5, -2.5, 1.5, -3.5, 0.5, -4, 0, -4, 0, -3.5, 1, -2, 2.5, -0.5, 4, 0.5, 5, 1, 5, 0, 4,
		-2, 3, -3, 2, -3, 1.5, -2, 2, -1, 3, 0, 4, 0, 4, -1, 3, -2.5, 1.5, -4, 0.5, -4, 0.5, -3, 1.5, -1, 3, 0, 4.5, -1, 4, -3, 3, -4, 3, -4, 4, -4, 4, -4, 4],
	[-4, 4, -3, 4, -2, 4, -1, 3.5, -1, 2.5, -2, 2, -3, 1.5, -3.5, 1, -3, 2, -1, 3.5, 0, 4.5, 0.5, 4.5, 0, 3.5, -1.5, 2, -3, 1, -3.5, 1, -3, 2.5, -2, 4, -4, 4, -4, 4],
]
# 튀어나온 바위·종유석: x, y, 너비, 높이
const LEDGES := [
	[-5, 34, 5.5, 0.5, 0, 38.5, 5, 0.5, -0.5, 54, 1, 2],
	[2, 30, 3, 0.5, -4, 47, 2.6, 0.5],
	[1.4, 24, 3, 0.5],
]
const MOTHS := [
	[0, 7, 3, 15, 2.4, 21, -3.5, 31, 3.5, 37, 0, 46, -2.5, 55, 3, 63, -2, 72],
	[2, 13, -3, 24, 3, 34, -2, 44, 2, 52, -3, 60, 2.5, 68],
	[0, 8, -2.5, 14, 3, 22, -2.5, 30, 0, 36],
]
const DRIPS := [2.5, 10, -2, 23, -3, 26, 3.5, 35, 1, 42, 2, 50, -2, 58, -1, 62, 1.5, 66, 0, 74]
const CRYSTALS := [3.6, 5, -1.7, 10, -3.2, 15, 1.0, 17, 4.2, 21, 4.2, 23, -1.2, 27, -3.2, 30, 2.2, 34]

var rng := RandomNumberGenerator.new()
var env: Environment
var level: Node3D
var cyc := 0  # 지금까지 넘은 구역 수 (죽어도 그대로)
var zone := 0
var lap := 0
var rows: Array = []
var top_y := 80.0
var clock := 0.0
var hint_t := 0.0
var done_t := 0.0
var energy := 100.0
var moths_eaten := 0
var bp := Vector2.ZERO  # 박쥐 위치 (x 옆, y 위)
var bv := Vector2.ZERO
var ping_t := 0.0
var bump_t := 0.0
var flap_ph := 0.0
var flap_s := 0.0
var cam_x := 0.0
var cam_y := 4.0
var bat: Node3D
var wing_l: Node3D
var wing_r: Node3D
var walls: Array[Dictionary] = []  # {n, rc(보이는 상자 영역), col, lit, lv, fade, cry, cd, p}
var solids: Array[Rect2] = []
var moths: Array[Dictionary] = []  # {n, base, p, lit, ph, on}
var drips: Array[Dictionary] = []  # {p, t, drop}
var rings: Array[Dictionary] = []  # {segs, x, y, r, pr, max, on, col}
var ring_i := 0
var echo_q: Array[Dictionary] = []  # {t, f}
var pend: Array[Vector2] = []  # 수정이 다시 울릴 자리
var streaks: Array[MeshInstance3D] = []
var bits: Array[Dictionary] = []
var bit_i := 0
var _fm := {}


func _setup() -> void:
	time_limit = 0.0
	cam.fov = 52.0
	howto = "박쥐다. 초음파가 닿은 곳만 잠깐 보인다.\n스틱 살짝 = 천천히, 소리를 자주 내 잘 보인다. 끝까지 = 빠르지만 소리 간격이 벌어져 앞이 안 보인다.\n빠르게 벽에 박으면 죽고, 천천히만 날면 기운이 바닥난다. 나방(노랑)을 먹고 위쪽 둥지까지.\n외침 버튼 = 멀리까지 보이지만 기운이 들고 나방이 흩어진다."
	kit_stick(Rect2(0, 560, 470, 720))
	kit_button("shout", "외침", Vector2(600, 1090), 95.0, C)
	for c in get_children():
		if c is WorldEnvironment:
			env = (c as WorldEnvironment).environment
	if env:
		env.background_color = FOG


func _reset() -> void:
	rng.randomize()
	_zone()


# ---- 구역 만들기 ----
func _zone() -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	walls.clear()
	solids.clear()
	moths.clear()
	drips.clear()
	rings.clear()
	echo_q.clear()
	pend.clear()
	streaks.clear()
	bits.clear()
	zone = cyc % 3
	lap = cyc / 3
	rows = ROWS[zone]
	var n := rows.size() / 2
	top_y = n * ROW
	for i in n:
		var l := float(rows[i * 2])
		var r := float(rows[i * 2 + 1])
		var y0 := i * ROW
		_wall(Rect2(l - 6.0, y0, 6.0, ROW), Rect2(l - 30.0, y0, 30.0, ROW))
		_wall(Rect2(r, y0, 6.0, ROW), Rect2(r, y0, 30.0, ROW))
	var lg: Array = LEDGES[zone]
	for i in lg.size() / 4:
		var rc := Rect2(float(lg[i * 4]), float(lg[i * 4 + 1]), float(lg[i * 4 + 2]), float(lg[i * 4 + 3]))
		_wall(rc, rc)
	# 바닥(늘 보임)과 위쪽 둥지(늘 보임)
	box(Vector3(0.0, -1.0, 0.0), Vector3(16.0, 2.0, 3.0), STONE, level)
	solids.append(Rect2(-30.0, -10.0, 60.0, 10.0))
	var tl := float(rows[rows.size() - 2])
	var tr := float(rows[rows.size() - 1])
	box(Vector3((tl + tr) * 0.5, top_y + 0.3, 0.0), Vector3(tr - tl, 0.25, 1.6), D, level)
	box(Vector3(tl - 0.4, top_y + 0.9, 0.0), Vector3(0.8, 1.6, 1.6), A, level)
	box(Vector3(tr + 0.4, top_y + 0.9, 0.0), Vector3(0.8, 1.6, 1.6), A, level)
	# 나방
	var mt: Array = MOTHS[zone]
	for i in mt.size() / 2:
		var p := Vector2(float(mt[i * 2]), float(mt[i * 2 + 1]))
		var m := box(Vector3(p.x, p.y, 0.3), Vector3(0.36, 0.26, 0.2), D, level)
		m.visible = false
		moths.append({"n": m, "base": p, "p": p, "lit": 0.0, "ph": rng.randf() * TAU, "on": true})
	# 물방울 굴
	if zone == 1:
		for i in DRIPS.size() / 2:
			var p := Vector2(float(DRIPS[i * 2]), float(DRIPS[i * 2 + 1]))
			var d := box(Vector3(p.x, p.y, 0.4), Vector3(0.14, 0.22, 0.14), B, level)
			drips.append({"p": p, "t": 0.6 + i * 0.37, "drop": d})
	# 수정 굴
	if zone == 2:
		for i in CRYSTALS.size() / 2:
			var p := Vector2(float(CRYSTALS[i * 2]), float(CRYSTALS[i * 2 + 1]))
			var c := box(Vector3(p.x, p.y, 0.3), Vector3(0.4, 0.55, 0.4), C, level)
			c.rotation.z = 0.6
			c.visible = false
			walls.append({"n": c, "rc": Rect2(p - Vector2(0.2, 0.2), Vector2(0.4, 0.4)), "col": C, "lit": 0.0, "lv": 4, "fade": CRY_FADE, "cry": true, "cd": 0.0, "p": p})
	# 소리 고리·지나가는 줄·파편 (미리 만들고 돌려 쓴다)
	for i in 6:
		var segs: Array[MeshInstance3D] = []
		for k in SEGS:
			var s := box(Vector3(0.0, -50.0, 0.9), Vector3(0.14, 0.14, 0.14), B, level)
			s.visible = false
			segs.append(s)
		rings.append({"segs": segs, "x": 0.0, "y": 0.0, "r": 0.0, "pr": 0.0, "max": 1.0, "on": false, "me": false})
	for i in 5:
		var s := box(Vector3(0.0, -50.0, -0.3), Vector3(0.05, 0.9, 0.05), WHITE, level)
		s.visible = false
		streaks.append(s)
	for i in 12:
		var b := box(Vector3(0.0, -50.0, 0.7), Vector3(0.13, 0.13, 0.13), WHITE, level)
		b.visible = false
		bits.append({"n": b, "v": Vector3.ZERO, "life": 0.0})
	# 박쥐
	bat = Node3D.new()
	level.add_child(bat)
	box(Vector3(0.0, 0.0, 0.0), Vector3(0.42, 0.5, 0.34), ME, bat)
	box(Vector3(0.0, 0.33, 0.0), Vector3(0.34, 0.26, 0.3), ME, bat)
	box(Vector3(-0.11, 0.52, 0.0), Vector3(0.08, 0.16, 0.08), ME, bat)
	box(Vector3(0.11, 0.52, 0.0), Vector3(0.08, 0.16, 0.08), ME, bat)
	box(Vector3(-0.08, 0.36, 0.17), Vector3(0.07, 0.07, 0.04), WHITE, bat)
	box(Vector3(0.08, 0.36, 0.17), Vector3(0.07, 0.07, 0.04), WHITE, bat)
	wing_l = Node3D.new()
	wing_l.position = Vector3(-0.2, 0.08, 0.0)
	bat.add_child(wing_l)
	box(Vector3(-0.45, 0.0, 0.0), Vector3(0.9, 0.08, 0.32), C, wing_l)
	wing_r = Node3D.new()
	wing_r.position = Vector3(0.2, 0.08, 0.0)
	bat.add_child(wing_r)
	box(Vector3(0.45, 0.0, 0.0), Vector3(0.9, 0.08, 0.32), C, wing_r)
	bp = Vector2(0.0, 0.8)
	bv = Vector2.ZERO
	ping_t = 0.15
	bump_t = 0.0
	energy = 100.0
	moths_eaten = 0
	done_t = 0.0
	cam_x = 0.0
	cam_y = bp.y + 3.0
	hint_t = 1.5
	msg("%d %s" % [cyc + 1, NAMES[zone]], 1.5)


func _wall(vis: Rect2, solid: Rect2) -> void:
	var n := box(Vector3(vis.get_center().x, vis.get_center().y, 0.0), Vector3(vis.size.x, vis.size.y, 2.4), STONE, level)
	n.visible = false
	walls.append({"n": n, "rc": vis, "col": STONE, "lit": 0.0, "lv": 4, "fade": FADE, "cry": false, "cd": 0.0, "p": vis.get_center()})
	solids.append(solid)


## 높이 y 의 굴 폭 (왼쪽, 오른쪽)
func _gap(y: float) -> Vector2:
	var i := clampi(int(y / ROW), 0, rows.size() / 2 - 1)
	return Vector2(float(rows[i * 2]), float(rows[i * 2 + 1]))


# ---- 매 프레임 ----
func _step(dt: float) -> void:
	clock += dt
	if hint_t > 0.0:
		hint_t -= dt
		if hint_t <= 0.0:
			msg(RULES[zone], 2.2)
	_fx(dt)
	_rings(dt)
	_fade(dt)
	if done_t > 0.0:
		done_t -= dt
		if done_t <= 0.0:
			cyc += 1
			_zone()
		else:
			_view(dt)
		return
	energy -= (DRAIN + lap * 0.8) * dt
	gauge(energy / 100.0, GOOD if energy > 30.0 else BAD)
	_bat(dt)
	if over:
		return
	_drips(dt)
	_moths(dt)
	# 메아리: 가까운 벽일수록 빨리, 높게 돌아온다
	for i in range(echo_q.size() - 1, -1, -1):
		echo_q[i].t = float(echo_q[i].t) - dt
		if float(echo_q[i].t) <= 0.0:
			beep(float(echo_q[i].f), 0.035, 0.0, 0.09)
			echo_q.remove_at(i)
	if done_t <= 0.0:
		score = cyc * 10 + moths_eaten
	_view(dt)


func _bat(dt: float) -> void:
	var mv := kit_move
	var amt := minf(mv.length(), 1.0)
	var want := Vector2(0.0, -1.1)  # 손을 놓으면 천천히 가라앉는다
	if amt > 0.12:
		var spd := maxf(SLOWEST, FAST * clampf((amt - 0.12) / 0.83, 0.0, 1.0))
		want = Vector2(mv.x, -mv.y).normalized() * spd
	bv = bv.move_toward(want, ACC * dt)
	var sp := bv.length()
	var s := clampf(sp / FAST, 0.0, 1.0)
	var prev := bp
	bp += bv * dt
	bump_t -= dt
	if _hit(bp):
		bp = prev
		if sp > CRASH:
			_burst(Vector3(bp.x, bp.y, 0.5), ME, 10, 6.0)
			_die("쾅!")
			return
		bv = -bv * 0.4
		if bump_t <= 0.0:
			bump_t = 0.4
			energy -= 8.0
			beep(160.0, 0.08, 90.0, 0.2)
			_burst(Vector3(bp.x, bp.y, 0.5), STONE.lerp(WHITE, 0.3), 3, 2.5)
			msg("툭", 0.3)
	# 자동 초음파: 빠를수록 간격이 넓다
	ping_t -= dt
	if ping_t <= 0.0:
		ping_t = 0.35 + 1.25 * s
		_ping(bp, PING_R, true)
		beep(3000.0, 0.03, 3600.0, 0.08)
	# 외침
	if kit_just("shout"):
		if energy > SHOUT_COST:
			energy -= SHOUT_COST
			_ping(bp, SHOUT_R, true)
			beep(1500.0, 0.2, 3200.0, 0.22)
			for m in moths:
				if m.on and (m.p as Vector2).distance_to(bp) < 7.0:
					var g := _gap(float(m.base.y))
					var nb: Vector2 = m.base + Vector2(rng.randf_range(-3.0, 3.0), rng.randf_range(-3.0, 3.0))
					nb.y = clampf(nb.y, 1.0, top_y - 1.0)
					g = _gap(nb.y)
					nb.x = clampf(nb.x, g.x + 0.5, g.y - 0.5)
					m.base = nb
		else:
			msg("기운 부족", 0.5)
			beep(200.0, 0.08, 0.0, 0.15)
	# 날갯짓: 빠를수록 잦다
	flap_s = s
	var before := sin(flap_ph)
	flap_ph += dt * (3.0 + 7.0 * s) * TAU
	if before < 0.0 and sin(flap_ph) >= 0.0:
		beep(110.0 + 60.0 * s, 0.04, 0.0, 0.05 + 0.07 * s)
	if energy <= 0.0:
		_die("기운이 없다")
		return
	if bp.y > top_y + 0.4:
		done_t = 1.4
		energy = maxf(energy, 1.0)
		score = (cyc + 1) * 10 + moths_eaten
		play("win")
		msg("둥지!" if zone < 2 else "다음 굴은 준비 중", 1.4)
		_burst(Vector3(bp.x, bp.y, 0.5), D, 10, 4.0)


func _hit(p: Vector2) -> bool:
	for rc in solids:
		var q := Vector2(clampf(p.x, rc.position.x, rc.end.x), clampf(p.y, rc.position.y, rc.end.y))
		if q.distance_squared_to(p) < BAT_R * BAT_R:
			return true
	return false


func _rd(rc: Rect2, p: Vector2) -> float:
	var q := Vector2(clampf(p.x, rc.position.x, rc.end.x), clampf(p.y, rc.position.y, rc.end.y))
	return q.distance_to(p)


## 소리 고리 하나를 띄운다. me 면 메아리를 예약한다.
func _ping(p: Vector2, rad: float, me: bool, col := B) -> void:
	var rg: Dictionary = rings[ring_i]
	ring_i = (ring_i + 1) % rings.size()
	rg.x = p.x
	rg.y = p.y
	rg.r = 0.0
	rg.pr = -0.01
	rg.max = rad
	rg.on = true
	for sg in rg.segs:
		(sg as MeshInstance3D).material_override = mat(col)
	if me:
		var dmin := rad
		for w in walls:
			if not w.cry:
				dmin = minf(dmin, _rd(w.rc, p))
		if dmin < rad:
			echo_q.append({"t": 2.0 * dmin / WAVE_SP + 0.04, "f": lerpf(2600.0, 1300.0, dmin / rad)})


func _rings(dt: float) -> void:
	for rg in rings:
		if not rg.on:
			continue
		rg.pr = rg.r
		rg.r = minf(float(rg.r) + WAVE_SP * dt, float(rg.max))
		var c := Vector2(float(rg.x), float(rg.y))
		var r: float = rg.r
		var pr: float = rg.pr
		for w in walls:
			var d := _rd(w.rc, c)
			if d <= r and d > pr:
				w.lit = 1.0
				if w.cry and float(w.cd) <= 0.0:
					w.cd = 3.0
					pend.append(w.p)
		for m in moths:
			if m.on:
				var d := (m.p as Vector2).distance_to(c)
				if d <= r and d > pr:
					m.lit = 1.0
		var k := 0
		for sg in rg.segs:
			var a := TAU * k / SEGS
			(sg as MeshInstance3D).position = Vector3(c.x + cos(a) * r, c.y + sin(a) * r, 0.9)
			(sg as MeshInstance3D).visible = r < float(rg.max) - 0.01
			k += 1
		if r >= float(rg.max):
			rg.on = false
			for sg in rg.segs:
				(sg as MeshInstance3D).visible = false
	# 수정이 붙잡은 울림을 다시 낸다
	if not pend.is_empty():
		var ps := pend.duplicate()
		pend.clear()
		for p in ps:
			_ping(p, 5.0, false, C)
			if (p as Vector2).distance_to(bp) < 14.0:
				beep(1900.0, 0.18, 2400.0, 0.08)


## 잔상: 밝게 보였다가 안개 색으로 섞이며 사라진다
func _fade(dt: float) -> void:
	for w in walls:
		if w.cry:
			w.cd = float(w.cd) - dt
		if float(w.lit) <= 0.0 and int(w.lv) == 4:
			continue
		w.lit = maxf(0.0, float(w.lit) - dt / float(w.fade))
		var lv := _lv(float(w.lit))
		if lv != int(w.lv):
			w.lv = lv
			var n: MeshInstance3D = w.n
			n.visible = lv < 4
			if lv < 4:
				n.material_override = _fmat(w.col, lv)


func _lv(lit: float) -> int:
	if lit <= 0.0:
		return 4
	if lit > 0.7:
		return 0
	if lit > 0.45:
		return 1
	if lit > 0.2:
		return 2
	return 3


## 0 = 진한 색(외곽선), 1~3 = 안개와 섞인 색(외곽선 없음)
func _fmat(c: Color, lv: int) -> Material:
	if lv == 0:
		return mat(c)
	var k := "%s%d" % [c.to_html(), lv]
	if not _fm.has(k):
		var s := StandardMaterial3D.new()
		s.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		s.albedo_color = c.lerp(FOG, [0.0, 0.3, 0.55, 0.8][lv])
		_fm[k] = s
	return _fm[k]


func _drips(dt: float) -> void:
	for d in drips:
		d.t = float(d.t) - dt
		var p: Vector2 = d.p
		var drop: MeshInstance3D = d.drop
		# 떨어지기 0.4초 전부터 방울이 내려온다 (박자를 읽게)
		var k := clampf(1.0 - float(d.t) / 0.4, 0.0, 1.0)
		drop.position = Vector3(p.x, p.y + 1.2 - 1.2 * k * k, 0.4)
		if float(d.t) <= 0.0:
			d.t = 2.0
			_ping(p, 4.5, false)
			var dist := p.distance_to(bp)
			if dist < 12.0:
				beep(2200.0, 0.03, 1400.0, 0.1 * (1.0 - dist / 12.0) + 0.02)


func _moths(dt: float) -> void:
	for m in moths:
		if not m.on:
			continue
		m.ph = float(m.ph) + dt * 5.0
		var ph: float = m.ph
		var target: Vector2 = m.base + Vector2(sin(ph * 0.5) * 0.5, sin(ph) * 0.3)
		m.p = (m.p as Vector2).lerp(target, minf(1.0, dt * 4.0))
		m.lit = maxf(0.0, float(m.lit) - dt / 1.8)
		var n: MeshInstance3D = m.n
		n.visible = float(m.lit) > 0.0
		n.position = Vector3(m.p.x, m.p.y, 0.3)
		n.scale.x = 0.36 * (0.6 + 0.4 * absf(sin(ph * 2.0)))
		if (m.p as Vector2).distance_to(bp) < 0.6:
			m.on = false
			n.visible = false
			moths_eaten += 1
			energy = minf(100.0, energy + MOTH_E)
			play("good")
			msg("+기운", 0.4)
			_burst(Vector3(m.p.x, m.p.y, 0.5), D, 5, 3.0)


func _die(why: String) -> void:
	msg(why, 1.2)
	play("bad")
	end()


func _burst(pos: Vector3, col: Color, k: int, spd: float) -> void:
	for i in k:
		var b: Dictionary = bits[bit_i]
		bit_i = (bit_i + 1) % bits.size()
		var n: MeshInstance3D = b.n
		n.material_override = mat(col)
		n.position = pos
		n.visible = true
		b.v = Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-0.3, 1.0), 0.0).normalized() * spd
		b.life = 0.5


func _fx(dt: float) -> void:
	for b in bits:
		if float(b.life) <= 0.0:
			continue
		b.life = float(b.life) - dt
		var n: MeshInstance3D = b.n
		b.v = (b.v as Vector3) + Vector3(0.0, -9.0 * dt, 0.0)
		n.position += (b.v as Vector3) * dt
		if float(b.life) <= 0.0:
			n.visible = false


func _view(dt: float) -> void:
	var s := flap_s
	bat.position = Vector3(bp.x, bp.y, 0.0)
	bat.rotation.z = -bv.x * 0.05
	var fl := sin(flap_ph) * (0.5 + 0.4 * s)
	wing_l.rotation.z = -fl
	wing_r.rotation.z = fl
	# 빠르면 줄이 아래로 지나간다
	for i in streaks.size():
		var st := streaks[i]
		st.visible = s > 0.55 and not over
		if st.visible:
			var off := fmod(clock * 14.0 + i * 0.83, 4.0)
			st.position = Vector3(bp.x + (i - 2) * 0.55, bp.y - 0.8 - off, -0.3)
			st.scale.y = 0.5 + s
	cam_x = lerpf(cam_x, bp.x * 0.4, minf(1.0, dt * 3.0))
	cam_y = lerpf(cam_y, bp.y + 2.5 + bv.y * 0.35, minf(1.0, dt * 4.0))
	cam.position = Vector3(cam_x, cam_y, 15.0)
	cam.fov = lerpf(cam.fov, 50.0 + 14.0 * s, minf(1.0, dt * 3.0))
