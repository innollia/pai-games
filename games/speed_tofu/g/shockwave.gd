extends Tofu
## 음속: 달리면 뒤에서 충격파 벽이 따라온다. 느려지면 삼켜진다. 왼손 조이스틱 좌우 = 방향, 위로 밀수록 질주(놓으면 서서히 느려지고 아래로 당기면 제동).
## 빠를수록 잘 못 돌고, 돌면 속도가 깎여 충격파가 가까워진다. 슬라이드 버튼 = 낮은 가로대 아래로(속도 조금 잃음).
## 기둥에 박히면 거의 멈추고, 길 밖·무너진 다리(충격파보다 먼저 무너진다)로 떨어지거나 충격파에 삼켜지면 죽음. 구간 3개(들판 → 협곡 → 다리), 구간마다 충격파가 빨라진다.

const ROCK := Color("e0c896")
const GREY := Color("dfe3e8")
const GRASS := Color("8ce99a")
const TOP := 22.0       # 최고 속도 (m/s)
const ACC := 7.0
const BRAKE := 14.0
const COAST := 0.8      # 스틱을 놓았을 때 줄어드는 속도
const TURN := 2.4       # 회전 속도(rad/s), 빠를수록 나뉜다
const TURN_COST := 0.12 # 돌 때 깎이는 속도 비율
const GAP0 := 18.0
const GAP_MAX := 20.0
const BREAK_AHEAD := 6.0  # 다리는 충격파보다 이만큼 먼저 무너진다
const SLIDE_T := 0.55
const VMIN: Array[float] = [10.0, 13.0, 16.0]  # 구간별 충격파 속도 (코너 속도 12~15와 맞먹어야 코너·기둥이 간격을 깎는다)
const SEC_AT: Array[int] = [0, 7, 12]         # 구간이 시작하는 길 조각 번호
const SEC_NAME := ["들판", "협곡", "다리"]
const ND := 16     # 먼지 상자 수
const TILES := 12  # 다리 한 조각의 판 수
# 길 조각: L 길이, b 끝에서 꺾는 각도(+ 왼쪽), w 반폭, k 종류, p 기둥 [[비율, 옆]], bar 낮은 가로대 [비율]
const SEGS := [
	{"L": 50.0, "b": 0.0, "w": 5.0, "k": "", "p": [], "bar": []},
	{"L": 40.0, "b": -40.0, "w": 5.0, "k": "", "p": [[0.5, 0.0]], "bar": []},
	{"L": 40.0, "b": 40.0, "w": 5.0, "k": "", "p": [[0.4, -2.2], [0.7, 2.2]], "bar": []},
	{"L": 50.0, "b": 0.0, "w": 5.0, "k": "", "p": [[0.3, 0.0], [0.6, -2.5], [0.85, 2.5]], "bar": []},
	{"L": 35.0, "b": 55.0, "w": 5.0, "k": "", "p": [], "bar": []},
	{"L": 35.0, "b": -55.0, "w": 5.0, "k": "", "p": [[0.5, 1.5]], "bar": []},
	{"L": 45.0, "b": 0.0, "w": 5.0, "k": "", "p": [], "bar": [0.5]},
	{"L": 45.0, "b": -30.0, "w": 2.8, "k": "canyon", "p": [], "bar": []},
	{"L": 40.0, "b": 35.0, "w": 2.8, "k": "canyon", "p": [], "bar": [0.45]},
	{"L": 50.0, "b": -45.0, "w": 2.8, "k": "canyon", "p": [[0.5, 0.0]], "bar": []},
	{"L": 45.0, "b": 45.0, "w": 2.8, "k": "canyon", "p": [], "bar": [0.3, 0.7]},
	{"L": 40.0, "b": 0.0, "w": 2.8, "k": "canyon", "p": [[0.4, -1.3], [0.7, 1.3]], "bar": []},
	{"L": 45.0, "b": -60.0, "w": 4.0, "k": "", "p": [], "bar": []},
	{"L": 30.0, "b": 0.0, "w": 4.0, "k": "", "p": [], "bar": []},
	{"L": 60.0, "b": 0.0, "w": 3.5, "k": "bridge", "p": [], "bar": []},
	{"L": 35.0, "b": 60.0, "w": 4.0, "k": "", "p": [[0.5, 0.0]], "bar": []},
	{"L": 35.0, "b": -60.0, "w": 4.0, "k": "", "p": [], "bar": [0.5]},
	{"L": 25.0, "b": 0.0, "w": 4.0, "k": "", "p": [], "bar": []},
	{"L": 60.0, "b": 0.0, "w": 3.0, "k": "bridge", "p": [], "bar": []},
	{"L": 45.0, "b": 0.0, "w": 5.0, "k": "", "p": [], "bar": []},
]


class Seg:
	var a: Vector3
	var dir: Vector3
	var right: Vector3
	var ln := 0.0
	var s0 := 0.0
	var w := 0.0
	var kind := ""
	var tiles: Array[MeshInstance3D] = []
	var ty: Array[float] = []  # 판이 떨어진 높이
	var vy: Array[float] = []  # 0이면 아직 멀쩡


var segs: Array[Seg] = []
var pillars: Array[Vector3] = []
var bars: Array[float] = []  # 가로대의 길 위 거리
var total := 0.0
var me: Node3D
var body: Node3D
var legs: Array[MeshInstance3D] = []
var arms: Array[MeshInstance3D] = []
var wave: MeshInstance3D
var wave_mat: StandardMaterial3D
var dust: Array[MeshInstance3D] = []
var dust_o: Array[Vector3] = []  # x 옆, y 높이, z 벽보다 앞
var pos := Vector3.ZERO
var yaw := 0.0
var v := 0.0
var si := 0
var s_me := 0.0
var s_w := 0.0
var gap := GAP0
var vmin := 8.0
var sec := 0
var bonus := 0
var won := false
var slide_t := 0.0
var hurt := 0.0
var dead_t := 0.0
var dvel := Vector3.ZERO
var falling := false
var fall_t := 0.0
var fvy := 0.0
var phase := 0.0
var step_t := 0.0
var warn_t := 0.0
var skid_t := 0.0
var rumble := 0.0
var clock := 0.0
var cam_pos := Vector3.ZERO


func _setup() -> void:
	howto = "달리면 뒤에서 충격파 벽이 따라온다. 느려지면 삼켜진다.\n왼손 조이스틱: 좌우로 방향, 위로 밀수록 질주(놓으면 느려지고, 아래로 당기면 제동). 빠를수록 잘 못 돌고, 돌면 속도가 깎여 충격파가 가까워진다.\n슬라이드 버튼으로 낮은 가로대 아래를 지난다. 기둥·추락·충격파면 죽음. 구간마다 충격파가 빨라진다."
	time_limit = 0.0
	kit_stick()
	kit_button("slide", "슬라이드", Vector2(590, 1080), 100.0, A)
	wave_mat = StandardMaterial3D.new()
	wave_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wave_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wave_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	wave_mat.albedo_color = Color(C.r, C.g, C.b, 0.5)


func _reset() -> void:
	_build()
	pos = segs[0].a + segs[0].dir * 2.0
	yaw = 0.0
	v = 12.0
	si = 0
	s_me = 2.0
	s_w = s_me - GAP0
	gap = GAP0
	vmin = VMIN[0]
	sec = 0
	bonus = 0
	won = false
	slide_t = 0.0
	hurt = 0.0
	dead_t = 0.0
	falling = false
	fall_t = 0.0
	fvy = 0.0
	phase = 0.0
	step_t = 0.0
	warn_t = 0.0
	skid_t = 0.0
	rumble = 0.0
	clock = 0.0
	# 나
	me = Node3D.new()
	world.add_child(me)
	body = Node3D.new()
	me.add_child(body)
	box(Vector3(0, 1.0, 0), Vector3(0.5, 0.7, 0.3), ME, body)
	box(Vector3(0, 1.55, 0), Vector3(0.32, 0.32, 0.32), ME, body)
	legs.clear()
	arms.clear()
	for sd: float in [-1.0, 1.0]:
		var lg := box(Vector3(sd * 0.14, 0.65, 0), Vector3(0.2, 0.7, 0.2), ME, body)
		legs.append(lg)
		var ar := box(Vector3(sd * 0.36, 1.3, 0), Vector3(0.14, 0.5, 0.14), ME, body)
		arms.append(ar)
	# 충격파 벽과 먼지
	wave = box(Vector3.ZERO, Vector3(60.0, 14.0, 1.6), C)
	wave.material_override = wave_mat
	dust.clear()
	dust_o.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for j in ND:
		var sz := rng.randf_range(0.4, 1.6)
		dust.append(box(Vector3.ZERO, Vector3.ONE * sz, [D, WHITE, C][j % 3]))
		dust_o.append(Vector3(rng.randf_range(-9.0, 9.0), rng.randf_range(0.3, 6.0), rng.randf_range(0.5, 10.0)))
	me.position = pos
	cam_pos = pos + Vector3(0, 3.0, 7.0)
	cam.position = cam_pos
	cam.fov = 70.0
	_camera(0.016, 0.0)
	msg("뒤에 충격파!", 1.5)


func _sec_of(i: int) -> int:
	var k := 0
	for n in SEC_AT.size():
		if i >= SEC_AT[n]:
			k = n
	return k


func _build() -> void:
	segs.clear()
	pillars.clear()
	bars.clear()
	var a := Vector3.ZERO
	var dir := Vector3(0, 0, -1)
	var s_acc := 0.0
	for i in SEGS.size():
		var D_: Dictionary = SEGS[i]
		var sg := Seg.new()
		sg.a = a
		sg.dir = dir
		sg.right = dir.cross(Vector3.UP)
		sg.ln = float(D_.L)
		sg.s0 = s_acc
		sg.w = float(D_.w)
		sg.kind = D_.k
		var k := _sec_of(i)
		var bs := Basis.looking_at(dir, Vector3.UP)
		var mid := a + dir * sg.ln * 0.5
		if sg.kind == "bridge":
			var tl := sg.ln / TILES
			for n in TILES:
				var m := box(Vector3.ZERO, Vector3.ONE, A if n % 2 == 0 else D)
				m.basis = bs
				m.scale = Vector3(sg.w * 2.0, 0.6, tl - 0.3)
				m.position = a + dir * (tl * (n + 0.5)) - Vector3(0, 0.3, 0)
				sg.tiles.append(m)
				sg.ty.append(0.0)
				sg.vy.append(0.0)
		else:
			var fl := box(Vector3.ZERO, Vector3.ONE, [SOFT, GREY, WHITE][k])
			fl.basis = bs
			fl.scale = Vector3(sg.w * 2.0, 1.0, sg.ln + sg.w * 2.0)
			fl.position = mid - Vector3(0, 0.5, 0)
			if sg.kind == "canyon":
				for sd: float in [-1.0, 1.0]:
					var wl := box(Vector3.ZERO, Vector3.ONE, ROCK)
					wl.basis = bs
					wl.scale = Vector3(6.4, 18.0, sg.ln + 6.0)
					wl.position = mid + sg.right * sd * (sg.w + 3.2) + Vector3(0, 8.0, 0)
			else:
				for sd: float in [-1.0, 1.0]:
					var e := box(Vector3.ZERO, Vector3.ONE, B if k == 0 else D)
					e.basis = bs
					e.scale = Vector3(0.3, 0.12, sg.ln + sg.w * 2.0)
					e.position = mid + sg.right * sd * (sg.w - 0.15) + Vector3(0, 0.05, 0)
		for p in D_.p:
			var pp: Vector3 = a + dir * (float(p[0]) * sg.ln) + sg.right * float(p[1])
			box(pp + Vector3(0, 1.6, 0), Vector3(1.2, 3.2, 1.2), GREY if sg.kind != "canyon" else WHITE)
			pillars.append(pp)
		for fr in D_.bar:
			var bp: Vector3 = a + dir * (float(fr) * sg.ln)
			var br := box(Vector3.ZERO, Vector3.ONE, BAD)
			br.basis = bs
			br.scale = Vector3(sg.w * 2.0 + 0.6, 0.35, 0.35)
			br.position = bp + Vector3(0, 1.25, 0)
			for sd: float in [-1.0, 1.0]:
				box(bp + sg.right * sd * sg.w + Vector3(0, 0.62, 0), Vector3(0.3, 1.25, 0.3), BAD)
			bars.append(sg.s0 + float(fr) * sg.ln)
		s_acc += sg.ln
		a = a + dir * sg.ln
		dir = dir.rotated(Vector3.UP, deg_to_rad(float(D_.b)))
		segs.append(sg)
	total = s_acc
	# 끝 문
	var last := segs[segs.size() - 1]
	var ga := last.a + last.dir * (last.ln - 1.0)
	for sd: float in [-1.0, 1.0]:
		box(ga + last.right * sd * (last.w + 0.7), Vector3(1.2, 9.0, 1.2), GOOD)
	var top := box(Vector3.ZERO, Vector3.ONE, GOOD)
	top.basis = Basis.looking_at(last.dir, Vector3.UP)
	top.scale = Vector3(last.w * 2.0 + 2.6, 1.4, 1.4)
	top.position = ga + Vector3(0, 9.0, 0)
	# 아래 땅과 옆 풍경 (같은 판이면 같은 모양)
	var mp := _path(total * 0.5)
	box(Vector3(mp[0].x, -40.0, mp[0].z), Vector3(1400, 1, 1400), GRASS)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var sv := 10.0
	var side := 1.0
	while sv < total:
		var q := _path(sv)
		var sg := _seg_at(sv)
		if sg.kind != "canyon":
			var k := _sec_of(segs.find(sg))
			var sw := rng.randf_range(4.0, 10.0)
			var h := rng.randf_range(3.0, 12.0)
			var c: Vector3 = q[0] + q[2] * side * (sg.w + rng.randf_range(8.0, 22.0))
			var cols: Array = [GRASS, B, WHITE] if k == 0 else [ROCK, WHITE, A]
			box(Vector3(c.x, h * 0.5 - 1.0, c.z), Vector3(sw, h, sw), cols[rng.randi_range(0, 2)])
		side = -side
		sv += 30.0


func _seg_at(sv: float) -> Seg:
	var sg := segs[0]
	for g in segs:
		if sv >= g.s0:
			sg = g
		else:
			break
	return sg


## 길 위 거리 sv 의 [자리, 방향, 오른쪽]
func _path(sv: float) -> Array:
	var sg := _seg_at(sv)
	return [sg.a + sg.dir * (sv - sg.s0), sg.dir, sg.right]


func _fwd() -> Vector3:
	return Vector3(-sin(yaw), 0, -cos(yaw))


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	hurt -= dt
	s_w += vmin * dt
	if dead_t > 0.0:
		dead_t -= dt
		me.position += dvel * dt
		dvel.y -= 20.0 * dt
		me.rotation.x += 9.0 * dt
		gap = s_me - s_w
		_wave(dt)
		_camera(dt, 1.0)
		if dead_t <= 0.0:
			end()
		return
	if falling:
		fall_t += dt
		fvy -= 30.0 * dt
		pos.y += fvy * dt
		pos += _fwd() * v * dt
		me.position = pos
		gap = s_me - s_w
		_wave(dt)
		_camera(dt, 0.0)
		if fall_t > 0.9:
			end()
		return
	# 입력: 스틱 기울기 = 방향과 속도
	var push := -kit_move.y
	var turn := kit_move.x
	if slide_t > 0.0:
		slide_t -= dt
		v -= COAST * 2.0 * dt
	else:
		if kit_just("slide") and v > 3.0:
			slide_t = SLIDE_T
			v *= 0.9
			beep(500.0, 0.15, 200.0, 0.2)
		if absf(turn) > 0.08:
			var rate := TURN / (1.0 + v * 0.09) * turn
			yaw -= rate * dt
			v -= absf(rate) * v * TURN_COST * dt
			skid_t -= dt
			if absf(rate) > 0.7 and v > 9.0 and skid_t <= 0.0:
				skid_t = 0.25
				beep(700.0, 0.08, 400.0, 0.12)
		if push > 0.1:
			v += ACC * push * dt
		elif push < -0.3:
			v -= BRAKE * -push * dt
		else:
			v -= COAST * dt
	v = clampf(v, 0.0, TOP)
	pos += _fwd() * v * dt
	_pillars()
	var prev := s_me
	_progress()
	if s_me - s_w > GAP_MAX:
		s_w = s_me - GAP_MAX
	gap = s_me - s_w
	_bars(prev)
	_bridges(dt)
	if not _on_track():
		falling = true
		fall_t = 0.0
		fvy = 0.0
		msg("떨어졌다", 1.5)
		beep(400.0, 0.6, 60.0, 0.3)
	_sections()
	if over:
		return
	if gap <= 0.8:
		_die()
	# 느림 경고
	if v < vmin and slide_t <= 0.0:
		warn_t -= dt
		if warn_t <= 0.0:
			warn_t = 0.4
			msg("느려!", 0.3)
			beep(260.0, 0.1, 200.0, 0.2)
	else:
		warn_t = 0.0
	# 몸
	me.position = pos
	me.rotation = Vector3(0, yaw, 0)
	var sl := slide_t > 0.0
	body.rotation.x = lerpf(body.rotation.x, 1.2 if sl else 0.0, minf(1.0, dt * 14.0))
	body.position.y = lerpf(body.position.y, -0.2 if sl else 0.0, minf(1.0, dt * 14.0))
	phase += v * dt * 1.6
	var amp := 0.0 if sl else 0.9 * minf(1.0, v / 6.0)
	for k in 2:
		var sgn := 1.0 if k == 0 else -1.0
		legs[k].rotation.x = sin(phase) * amp * sgn
		arms[k].rotation.x = -sin(phase) * amp * sgn
	step_t -= dt * v / TOP
	if v > 1.0 and not sl and step_t <= 0.0:
		step_t = 0.28
		beep(110.0, 0.04, 0.0, 0.1)
	for lg in legs:
		lg.material_override = mat(BAD if hurt > 0.0 and fmod(hurt, 0.2) < 0.1 else ME)
	score = int(s_me) + bonus
	gauge(gap / GAP_MAX, GOOD if gap > 12.0 else (D if gap > 6.0 else BAD))
	_wave(dt)
	_camera(dt, 0.0)


func _progress() -> void:
	while si < segs.size() - 1 and (pos - segs[si].a).dot(segs[si].dir) > segs[si].ln:
		si += 1
	var sg := segs[si]
	s_me = sg.s0 + clampf((pos - sg.a).dot(sg.dir), 0.0, sg.ln)


func _on_track() -> bool:
	for i in range(maxi(0, si - 1), mini(segs.size(), si + 2)):
		var sg := segs[i]
		var rel := pos - sg.a
		var along := rel.dot(sg.dir)
		var lat := rel.dot(sg.right)
		var ext := 0.0 if sg.kind == "bridge" else sg.w
		if along >= -ext and along <= sg.ln + ext and absf(lat) <= sg.w + 0.25:
			if sg.kind == "bridge":
				var n := clampi(int(along / (sg.ln / TILES)), 0, TILES - 1)
				if sg.ty[n] < -0.5:
					continue
			return true
	return false


func _pillars() -> void:
	for pl in pillars:
		var d := pos - pl
		d.y = 0.0
		if d.length() < 1.05:
			if d.length() < 0.01:
				d = -_fwd()
			pos = pl + d.normalized() * 1.05
			if hurt <= 0.0:
				v *= 0.25
				hurt = 0.5
				msg("쾅!", 0.6)
				beep(90.0, 0.2, 40.0, 0.4)


func _bars(prev: float) -> void:
	for bs in bars:
		if prev < bs and s_me >= bs:
			if slide_t > 0.0:
				bonus += 10
				msg("슬라이드!", 0.4)
				beep(900.0, 0.1, 1400.0, 0.2)
			else:
				v *= 0.3
				hurt = 0.5
				msg("쿵!", 0.6)
				beep(120.0, 0.2, 50.0, 0.35)


## 다리 판은 충격파가 닿기 전에 떨어진다
func _bridges(dt: float) -> void:
	for sg in segs:
		if sg.kind != "bridge":
			continue
		var tl := sg.ln / TILES
		for n in TILES:
			if sg.vy[n] == 0.0:
				if s_w + BREAK_AHEAD > sg.s0 + tl * (n + 0.5):
					sg.vy[n] = -0.5
					beep(80.0, 0.1, 30.0, 0.15)
			elif sg.ty[n] > -60.0:
				sg.vy[n] -= 20.0 * dt
				sg.ty[n] += sg.vy[n] * dt
				var m := sg.tiles[n]
				m.position.y = -0.3 + sg.ty[n]
				m.rotation.x += 1.5 * dt


func _sections() -> void:
	var k := sec
	while k + 1 < SEC_AT.size() and s_me >= segs[SEC_AT[k + 1]].s0:
		k += 1
	if k != sec:
		sec = k
		vmin = VMIN[sec]
		bonus += 200
		s_w = minf(s_w, s_me - minf(GAP_MAX, gap + 6.0))  # 숨 돌릴 틈
		gap = s_me - s_w
		msg("%s · 충격파 %d" % [SEC_NAME[sec], int(vmin)], 1.6)
		play("good")
	if s_me >= total - 1.5 and not won:
		won = true
		bonus += 500
		score = int(s_me) + bonus
		msg("음속 돌파!", 2.0)
		end()


func _die() -> void:
	if dead_t > 0.0:
		return
	dead_t = 1.2
	dvel = _fwd() * 9.0 + Vector3(0, 7.0, 0)
	msg("삼켜졌다", 1.5)
	beep(300.0, 0.5, 40.0, 0.4)


func _wave(dt: float) -> void:
	var pp := _path(s_w)
	var wd: Vector3 = pp[1]
	wave.position = pp[0] + Vector3(0, 7.0, 0)
	wave.basis = Basis.looking_at(wd, Vector3.UP)
	wave.scale = Vector3(60.0, 14.0, 1.6)
	for j in ND:
		var o := dust_o[j]
		var q := _path(s_w + o.z)
		var qp: Vector3 = q[0]
		var qr: Vector3 = q[2]
		dust[j].position = qp + qr * o.x + Vector3(0, o.y + sin(clock * 6.0 + j) * 0.6, 0)
		dust[j].rotation = Vector3(clock * 3.0 + j, clock * 2.0, float(j))
	var near := clampf(1.0 - gap / GAP_MAX, 0.0, 1.0)
	rumble -= dt
	if rumble <= 0.0:
		rumble = lerpf(0.7, 0.1, near)
		beep(50.0 + near * 20.0, 0.12, 0.0, 0.08 + 0.2 * near)


## 뒤 위에서 따라간다. 빠를수록 멀고 넓게, 충격파가 가까우면 흔들린다
func _camera(dt: float, shake: float) -> void:
	var f := _fwd()
	var want := pos + Vector3(0, 2.6 + v * 0.03, 0) - f * (5.5 + v * 0.1)
	cam_pos = cam_pos.lerp(want, minf(1.0, dt * 5.0))
	var near := clampf(1.0 - gap / 12.0, 0.0, 1.0)
	var sh := maxf(near, shake) * 0.25
	cam.position = cam_pos + Vector3(randf_range(-sh, sh), randf_range(-sh, sh), 0)
	cam.look_at(pos + f * 7.0 + Vector3(0, 1.0, 0))
	cam.fov = lerpf(cam.fov, 62.0 + v * 1.4, minf(1.0, dt * 3.0))


func play(nm: String) -> void:
	if nm == "bad" and won:
		nm = "win"
	super(nm)
