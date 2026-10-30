extends Tofu
## 찰칵 레일 1인칭: 멈추지 않는 광산 카트 위에서 뷰파인더로 "순간"을 찍는다. 화면 끌기 = 조준, 셔터, 브레이크(누르는 동안 늦춤), 줌(구역 2부터).
## 나는 [카트에 탄 사진사]로서 [뒤차가 따라오고 커브마다 탈선 한계가 있는 레일] 위에서 [몇 프레임만 열리는 순간을 찍어] [별을 채우]지만
## [빠르면 창이 짧고 조준이 떨리며, 늦추면 뒤차가 붙는 간격 빚]을 감수한다.
## 순간: 두 기둥이 겹치는 레일 위치(빠를수록 짧다), 바위의 새가 날아오르는 1초, 멀리 폭포(망원 필요), 번개(구역 3). 커브는 한계 속도 초과면 탈선.
## 뒤차는 제 속도로 온다: 직선에서 간격을 벌고 커브·브레이크에서 쓴다.
## 구역 1 협곡(뒤차 6 m/s, 커브가 싸다) → 2 숲 내리막(산사태 9 m/s가 커브 한계 7보다 빨라 커브마다 빚, 망원, 먼 피사체) → 3 폭풍(번개, 젖은 레일 제동 절반) 맛보기.

const GREY := Color("dfe3e8")
const VIEW := Rect2(210, 490, 300, 300)  # 뷰파인더 (화면 좌표)
const TIE := 3.0  # 침목 간격
const GAP_MAX := 30.0
const V_MIN := 2.5
# track: [길이, 회전각(+오른쪽)]. 회전이 있으면 4m 조각으로 쪼개 커브가 된다.
# moments: pillar(s=시점 위치, a=방향각) / bird(s, side) / deer(s) / far(s, side) / bolt(번개, 하나면 된다)
const ZONES := [
	{"name": "협곡", "vnat": 8.0, "limit": 5.5, "brake": 6.0, "vf": 6.0, "slide": false, "quota": 8, "film": 7, "gap": 16.0, "zoom": false,
		"track": [[36, 0], [16, 60], [30, 0], [16, -75], [40, 0], [20, 90], [36, 0], [12, -45], [30, 0]],
		"moments": [["pillar", 22.0, 0.55], ["bird", 62.0, -5.0], ["pillar", 118.0, -0.5], ["bird", 158.0, 6.0], ["pillar", 204.0, 0.6], ["bird", 226.0, -5.0]]},
	{"name": "숲 내리막", "vnat": 12.0, "limit": 7.0, "brake": 6.0, "vf": 9.0, "slide": true, "quota": 10, "film": 7, "gap": 14.0, "zoom": true,
		"track": [[40, 0], [20, 50], [44, 0], [16, -60], [36, 0], [24, 100], [40, 0], [16, -40], [40, 0]],
		"moments": [["far", 30.0, 38.0], ["deer", 70.0, 0.0], ["pillar", 112.0, 0.5], ["bird", 150.0, -5.0], ["far", 186.0, -40.0], ["deer", 220.0, 0.0], ["pillar", 256.0, -0.55]]},
	{"name": "폭풍", "vnat": 9.0, "limit": 5.5, "brake": 3.0, "vf": 6.5, "slide": false, "quota": 4, "film": 6, "gap": 16.0, "zoom": true,
		"track": [[40, 0], [16, 70], [40, 0], [16, -80], [30, 0]],
		"moments": [["bolt", 0.0, 0.0], ["pillar", 95.0, 0.5]]},
]


class Piece:
	var s0 := 0.0
	var len := 0.0
	var p := Vector3.ZERO  # 시작점
	var d := Vector3.FORWARD  # 방향
	var curve := false


class Moment:
	var kind := ""
	var s := 0.0  # 레일 위 기준 위치
	var sub := Vector3.ZERO  # 피사체(찍을 점)
	var far := false
	var done := false
	var tt := -1.0  # 시작 전 -1
	var vis := 0.0  # 번개가 보이는 남은 시간
	var timer := 0.0
	var side := 0.0
	var n: MeshInstance3D  # 움직이는 상자(새·사슴·번개)
	var home := Vector3.ZERO
	var right := Vector3.RIGHT


var zone := 0
var level: Node3D
var pieces: Array[Piece] = []
var total := 0.0
var moments: Array[Moment] = []
var warns: Array = []  # [커브 시작 s, 경고했나]
var cart: Node3D
var rear: Node3D
var s := 0.0  # 레일 위 내 위치
var v := 0.0
var gap := 16.0
var film := 0
var zstars := 0
var yaw_l := 0.0
var pitch_l := 0.0
var zoomed := false
var tie_i := 0
var die_t := 0.0
var flash_t := 0.0
var screech := 0.0
var rumble := 0.0
var flash: ColorRect


func _setup() -> void:
	howto = "멈추지 않는 카트 위의 사진사. 화면을 끌어 조준하고, 피사체가 네모 안에 들어온 '순간'에 셔터(두 기둥이 겹칠 때, 새가 날아오를 때).\n브레이크를 누르면 느려져 순간이 길어지지만 뒤차가 다가온다(막대). 커브는 노란 표지 뒤에서 늦추지 않으면 탈선.\n구역마다 필름 7장. 별이 모자라면 그 구역 다시."
	time_limit = 0.0
	kit_lookpad(Rect2(0, 100, 720, 1180))
	kit_button("shutter", "셔터", Vector2(580, 1085), 105.0, BAD)
	kit_button("brake", "브레이크", Vector2(140, 1085), 95.0, B)
	# 뷰파인더 테두리와 셔터 섬광 (점수·글자보다 아래 층)
	var lay := CanvasLayer.new()
	lay.layer = 0
	add_child(lay)
	flash = ColorRect.new()
	flash.color = Color(1, 1, 1, 0)
	flash.size = Vector2(720, 1280)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lay.add_child(flash)
	var edges := [Rect2(VIEW.position, Vector2(VIEW.size.x, 6)), Rect2(VIEW.position + Vector2(0, VIEW.size.y - 6), Vector2(VIEW.size.x, 6)),
		Rect2(VIEW.position, Vector2(6, VIEW.size.y)), Rect2(VIEW.position + Vector2(VIEW.size.x - 6, 0), Vector2(6, VIEW.size.y)),
		Rect2(VIEW.get_center() - Vector2(4, 4), Vector2(8, 8))]
	for e in edges:
		var r := ColorRect.new()
		r.color = INK
		r.position = e.position
		r.size = e.size
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lay.add_child(r)


func _reset() -> void:
	level = null
	zone = 0
	_btns.erase("zoom")
	_zone(0)


## 구역을 (다시) 짓는다. 그 구역 별·필름은 처음부터
func _zone(i: int) -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	var Z: Dictionary = ZONES[i]
	if Z.zoom and not _btns.has("zoom"):
		kit_button("zoom", "줌", Vector2(600, 870), 65.0, C)
	# 레일
	pieces.clear()
	warns.clear()
	var at := Vector3.ZERO
	var d := Vector3.FORWARD
	var run := 0.0
	var prev_curve := false
	var cen := Vector3.ZERO
	for seg in Z.track:
		var L := float(seg[0])
		var turn := float(seg[1])
		var n := 1 if turn == 0.0 else ceili(L / 4.0)
		for k in n:
			var pc := Piece.new()
			if turn != 0.0:
				d = d.rotated(Vector3.UP, -deg_to_rad(turn / n))
			pc.s0 = run
			pc.len = L / n
			pc.p = at
			pc.d = d
			pc.curve = turn != 0.0
			pieces.append(pc)
			if pc.curve and not prev_curve:
				warns.append([run, false])
			prev_curve = pc.curve
			_rails(pc)
			at += d * pc.len
			run += pc.len
			cen += at
	total = run
	cen /= float(pieces.size())
	box(Vector3(cen.x, -0.15, cen.z), Vector3(900, 0.2, 900), WHITE, level)
	# 커브 표지 (20m 앞, 오른쪽)
	for w in warns:
		var sp := _at(w[0] - 20.0, 2.2)
		box(sp + Vector3(0, 1.5, 0), Vector3(0.3, 3.0, 0.3), D, level)
		box(sp + Vector3(0, 3.3, 0), Vector3(1.3, 1.0, 0.25), BAD, level)
	# 바위 (시차용)
	for k in 10:
		var ss := 15.0 + k * (total - 30.0) / 10.0
		var side := (7.0 + fmod(k * 3.7, 8.0)) * (1.0 if k % 2 == 0 else -1.0)
		var h := 1.0 + fmod(k * 1.3, 2.5)
		box(_at(ss, side) + Vector3(0, h * 0.5, 0), Vector3(2.0, h, 2.0), GREY, level)
	# 순간들
	moments.clear()
	for md in Z.moments:
		_moment(md[0], md[1], md[2])
	# 카트 둘
	cart = Node3D.new()
	level.add_child(cart)
	box(Vector3(0, 0.55, 0), Vector3(1.5, 0.9, 2.2), B, cart)
	box(Vector3(0, 1.05, -1.0), Vector3(1.5, 0.3, 0.2), INK, cart)
	rear = Node3D.new()
	level.add_child(rear)
	if Z.slide:
		box(Vector3(0, 1.6, 0), Vector3(3.4, 3.2, 3.4), GREY, rear)  # 산사태 바위
	else:
		box(Vector3(0, 0.55, 0), Vector3(1.5, 0.9, 2.2), A, rear)
		box(Vector3(0, 1.05, 1.0), Vector3(1.5, 0.3, 0.2), INK, rear)
	s = 0.0
	v = Z.vnat * 0.6
	gap = Z.gap
	film = Z.film
	zstars = 0
	yaw_l = 0.0
	pitch_l = 0.0
	zoomed = false
	tie_i = 0
	die_t = 0.0
	screech = 0.0
	rumble = 0.0
	msg("%d %s  필름 %d" % [i + 1, Z.name, film], 1.4)


func _rails(pc: Piece) -> void:
	var n := Node3D.new()
	n.transform = Transform3D(Basis.looking_at(pc.d, Vector3.UP), pc.p + pc.d * pc.len * 0.5)
	level.add_child(n)
	for sd in [-0.7, 0.7]:
		box(Vector3(sd, 0.12, 0), Vector3(0.14, 0.2, pc.len), GREY, n)
	var k := maxi(1, int(pc.len / TIE))
	for j in k:
		var z := -pc.len * 0.5 + (j + 0.5) * pc.len / k
		box(Vector3(0, 0.04, z), Vector3(2.0, 0.1, 0.4), BAD if pc.curve else SOFT, n)


func _moment(kind: String, at_s: float, arg: float) -> void:
	var m := Moment.new()
	m.kind = kind
	m.s = at_s
	m.side = arg
	var p := _point(at_s)
	var d := _dir(at_s)
	m.right = d.cross(Vector3.UP)
	match kind:
		"pillar":
			# 시점 at_s 에서 방향 arg 로 7m·15m 떨어진 기둥 둘: 거기서만 겹쳐 보인다
			var dd := d.rotated(Vector3.UP, -arg)
			var a := p + dd * 7.0
			var b := p + dd * 15.0
			box(a + Vector3(0, 1.75, 0), Vector3(0.7, 3.5, 0.7), GOOD, level)
			box(b + Vector3(0, 2.75, 0), Vector3(0.9, 5.5, 0.9), C, level)
			m.sub = a + Vector3(0, 2.6, 0)
		"bird":
			var r := p + m.right * arg
			box(r + Vector3(0, 0.5, 0), Vector3(1.2, 1.0, 1.2), GREY, level)
			m.home = r + Vector3(0, 1.25, 0)
			m.n = box(m.home, Vector3(0.5, 0.35, 0.5), D, level)
			m.sub = m.home
		"deer":
			m.home = p + m.right * -9.0 + Vector3(0, 0.6, 0)
			m.n = box(m.home, Vector3(0.6, 1.2, 1.4), A, level)
			m.sub = m.home
		"far":
			var r := p + m.right * arg
			box(r + Vector3(0, 7.0, 0), Vector3(2.2, 14.0, 2.2), WHITE, level)
			box(r + Vector3(0, 13.0, 0), Vector3(7.0, 1.0, 1.0), C, level)
			m.sub = r + Vector3(0, 12.0, 0)
			m.far = true
		"bolt":
			m.n = box(Vector3.ZERO, Vector3(1.4, 26.0, 1.4), WHITE, level)
			m.n.visible = false
			m.timer = 2.5
	moments.append(m)


# ---- 레일 기하 ----
func _piece(at_s: float) -> Piece:
	var i := clampi(int(pieces.size() * at_s / maxf(total, 1.0)), 0, pieces.size() - 1)
	while i > 0 and pieces[i].s0 > at_s:
		i -= 1
	while i < pieces.size() - 1 and pieces[i + 1].s0 <= at_s:
		i += 1
	return pieces[i]


func _point(at_s: float) -> Vector3:
	var pc := _piece(at_s)
	return pc.p + pc.d * (at_s - pc.s0)


func _dir(at_s: float) -> Vector3:
	return _piece(at_s).d


## 레일 위 at_s 에서 오른쪽으로 side 만큼 떨어진 바닥 점
func _at(at_s: float, side: float) -> Vector3:
	return _point(at_s) + _dir(at_s).cross(Vector3.UP) * side


func _step(dt: float) -> void:
	var Z: Dictionary = ZONES[zone]
	flash_t = maxf(0.0, flash_t - dt * 5.0)
	flash.color.a = flash_t
	if die_t > 0.0:
		die_t -= dt
		_camera(1.0 - die_t / 1.3)
		if die_t <= 0.0:
			score -= zstars
			_zone(zone)
		return
	# 조준
	var sens := 0.006
	yaw_l = clampf(yaw_l - kit_look.x * sens, -2.9, 2.9)
	pitch_l = clampf(pitch_l - kit_look.y * sens * 0.7, -0.7, 0.9)
	if kit_just("zoom"):
		zoomed = not zoomed
		beep(700.0 if zoomed else 500.0, 0.06, 0.0, 0.2)
		msg("망원" if zoomed else "광각", 0.5)
	# 속도: 레일이 올리고 브레이크만 내린다
	var braking := kit_held("brake")
	if braking:
		v = maxf(v - Z.brake * dt, V_MIN)
		screech -= dt
		if screech <= 0.0:
			screech = 0.15
			beep(420.0, 0.12, 260.0, 0.14)
	else:
		v = move_toward(v, Z.vnat, 2.5 * dt)
	s += v * dt
	# 뒤차는 제 속도 vf 로 온다(커브를 모른다). 간격은 내 속도와의 차로 변한다: 직선에서 벌고 커브·브레이크에서 쓴다
	gap = clampf(gap + (v - Z.vf) * dt, 0.0, GAP_MAX)
	gauge(gap / GAP_MAX, BAD if gap < 6.0 else (A if gap < 12.0 else GOOD))
	if gap < 7.0:
		rumble -= dt
		if rumble <= 0.0:
			rumble = 0.5
			beep(60.0, 0.15, 0.0, 0.25)
	if gap <= 1.2:
		_die("추돌!")
		return
	# 침목 통과음 = 속도 박자
	var ti := int(s / TIE)
	if ti != tie_i:
		tie_i = ti
		beep(95.0, 0.03, 0.0, 0.12)
	# 커브: 경고와 탈선
	var pc := _piece(s)
	for w in warns:
		if not w[1] and s < w[0] and w[0] - s < v * 2.5:
			w[1] = true
			msg("커브!", 0.8)
			beep(1200.0, 0.1, 0.0, 0.22)
	if pc.curve and v > Z.limit + 0.3:
		_die("탈선!")
		return
	_moments(dt)
	if kit_just("shutter"):
		_shoot()
	_camera(0.0)
	# 구역 끝: 편집장 심사
	if s >= total:
		if zstars >= int(Z.quota):
			play("win")
			zone += 1
			if zone >= ZONES.size():
				msg("완성!", 1.5)
				end()
			else:
				_zone(zone)
		else:
			play("bad")
			msg("부족 %d/%d★" % [zstars, int(Z.quota)], 1.4)
			score -= zstars
			_zone(zone)


func _camera(fall: float) -> void:
	var d := _dir(s)
	var p := _point(s)
	cart.transform = Transform3D(Basis.looking_at(d, Vector3.UP), p)
	var rs := s - gap
	rear.transform = Transform3D(Basis.looking_at(_dir(rs), Vector3.UP), _point(rs))
	if ZONES[zone].slide:
		rear.rotate_object_local(Vector3.RIGHT, -s * 0.5)
	var amp := 0.004 * v * (2.0 if zoomed else 1.0)
	var tm := Time.get_ticks_msec() * 0.001
	var right := d.cross(Vector3.UP)
	cam.position = p + Vector3(0, 1.5, 0) + right * sin(tm * 37.0) * amp + Vector3(0, sin(tm * 53.0) * amp, 0)
	cam.rotation = Vector3(pitch_l - fall * 0.5, atan2(-d.x, -d.z) + yaw_l, fall * 0.9)
	cam.fov = (36.0 if zoomed else 70.0) + v * 1.2 * (0.3 if zoomed else 1.0)


## 순간들을 움직인다. open 은 셔터 때 다시 계산한다
func _moments(dt: float) -> void:
	for m in moments:
		match m.kind:
			"bird":
				if m.tt < 0.0 and s > m.s - 10.0:
					m.tt = 0.0
					beep(1500.0, 0.08, 1900.0, 0.15)
				if m.tt >= 0.0 and m.tt < 3.0:
					m.tt += dt
					m.n.position = m.home + Vector3(0, 5.0 * m.tt, 0) + m.right * signf(m.side) * 2.0 * m.tt
					m.sub = m.n.position
					m.n.visible = m.tt < 2.5
			"deer":
				if m.tt < 0.0 and s > m.s - 14.0:
					m.tt = 0.0
				if m.tt >= 0.0 and m.tt < 3.0:
					m.tt += dt
					m.n.position = m.home + m.right * 18.0 * minf(m.tt / 1.6, 1.0)
					m.sub = m.n.position
			"bolt":
				if m.vis > 0.0:
					m.vis -= dt
					if m.vis <= 0.0:
						m.n.visible = false
				else:
					m.timer -= dt
					if m.timer <= 0.0:
						m.timer = randf_range(3.0, 5.0)
						m.vis = 0.35
						var ang := randf_range(-1.6, 1.6)
						var dd := _dir(s).rotated(Vector3.UP, ang)
						m.n.position = _point(s) + dd * 70.0 + Vector3(0, 18.0, 0)
						m.n.visible = true
						m.sub = m.n.position
						m.done = false
						beep(1800.0, 0.2, 200.0, 0.3)


## 이 순간이 지금 "열려" 있나 (좋은 사진이 되는 몇 프레임)
func _open(m: Moment) -> bool:
	match m.kind:
		"pillar": return absf(s - m.s) < 1.2
		"bird": return m.tt >= 0.25 and m.tt < 0.95
		"deer": return m.tt >= 0.5 and m.tt < 1.1  # 레일 위를 지나는 동안
		"far": return absf(s - m.s) < 6.0
		"bolt": return m.vis > 0.0
	return false


## 셔터: 뷰파인더 안의 피사체 중 가장 좋은 것으로 별을 준다
func _shoot() -> void:
	if film <= 0:
		beep(900.0, 0.03, 0.0, 0.15)
		msg("필름 없음", 0.5)
		return
	film -= 1
	flash_t = 1.0
	beep(2400.0, 0.04, 600.0, 0.3)
	var best := 0
	var best_m: Moment = null
	var why := "허탕"
	for m in moments:
		if m.done:
			continue
		if m.kind == "bolt" and m.vis <= 0.0:
			continue
		if (m.kind == "bird" or m.kind == "deer") and m.n and not m.n.visible:
			continue
		if cam.is_position_behind(m.sub):
			continue
		var sp := cam.unproject_position(m.sub)
		if not VIEW.has_point(sp):
			continue
		var st := 0
		if m.far and not zoomed:
			why = "작다"
		elif _open(m):
			st = 3 if sp.distance_to(VIEW.get_center()) < 100.0 else 2
		else:
			st = 1
			why = "흐림"
		if st > best:
			best = st
			best_m = m
	if best > 0:
		best_m.done = true
		score += best
		zstars += best
		msg("%s  %d" % ["★".repeat(best), film], 0.8)
		if best >= 2:
			play("good")
	else:
		msg("%s  %d" % [why, film], 0.6)


func _die(what: String) -> void:
	if die_t > 0.0:
		return
	die_t = 1.3
	play("bad")
	beep(80.0, 0.4, 30.0, 0.4)
	msg(what, 1.2)
