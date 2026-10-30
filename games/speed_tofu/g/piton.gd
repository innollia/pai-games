extends Tofu
## 옆에서 본 절벽 오르기. 위로 끌수록 빨리 오른다(빠를수록 잘 미끄러짐), 톡 = 못 박기(잠깐 멈춤). 미끄러지면 줄이 위 못부터 줄줄이 뽑힌다:
## 못이 빨갛게 흔들릴 때 톡 = 다시 박아 버티기(헛손질은 잠깐 손이 안 감). 다 뽑혀 바닥에 닿거나 폭풍(막대)이 오면 끝. 피치마다 바위가 바뀐다.

const PH := 32  # 피치 높이(칸)
const SLACK := 0.9  # 못 아래로 이만큼 떨어지면 줄이 당긴다
const GRAV := 22.0
const VMAX := 5.0
const ROCK := [Color("c9ced6"), Color("e8b47c"), Color("aebbd0")]  # 단단, 푸석, 오버행
const PITON := Color("8a929e")
const NAMES := ["화강암", "푸석바위", "오버행", "돌풍", "전부"]
const NROPE := 32
const NSTREAK := 10
const NCLOUD := 7

var rng := RandomNumberGenerator.new()
var rock_t := PackedInt32Array()
var rock_x := PackedFloat32Array()
var pitch_i := 0
var base_y := 0.0
var top_y := 0.0
var pitch_nodes: Array[Node3D] = []
var anchor: MeshInstance3D
var climber: Node3D
var torso: MeshInstance3D
var arms: Array[MeshInstance3D] = []
var legs: Array[MeshInstance3D] = []
var cy := 0.75  # 사람 몸 가운데 높이
var vy := 0.0
var spd := 0.0
var mode := "climb"  # climb, hammer, fall, hang
var mode_t := 0.0
var ham_hit := false
var risk := 0.0
var pitons: Array[Dictionary] = []  # y 오름차순: {y, x, h, m, crumb, load, lt, lw}
var flying: Array[Dictionary] = []
var chain := 0
var rope: Array[MeshInstance3D] = []
var streaks: Array[MeshInstance3D] = []
var clouds: Array[MeshInstance3D] = []
var press := Vector2.ZERO
var press0 := Vector2.ZERO
var press_dur := 0.0
var moved := 0.0
var throttle := 0.0
var tap_in_fall := false
var lock_t := 0.0
var storm := 0.0
var storm_max := 1.0
var warn_s := 0
var wind_on := false
var gust := 0  # 0 잠잠, 1 예고, 2 돌풍
var gust_t := 0.0
var pump := 0.0
var tick := 0.0
var phase := 0.0
var max_y := 0.0
var cam_y := 0.0
var shake := 0.0
var clock := 0.0


func _setup() -> void:
	howto = "위로 끌수록 빨리 오른다. 빠를수록 잘 미끄러진다.\n톡 = 못 박기(잠깐 멈춤).\n미끄러지면 위 못부터 줄줄이 뽑힌다. 못이 빨개질 때 톡!\n바닥에 닿거나 폭풍(막대)이 다 되면 끝."
	time_limit = 0.0
	cam.fov = 40.0


func _reset() -> void:
	rng.randomize()
	rock_t = PackedInt32Array()
	rock_x = PackedFloat32Array()
	pitch_nodes.clear()
	pitons.clear()
	flying.clear()
	rope.clear()
	streaks.clear()
	clouds.clear()
	arms.clear()
	legs.clear()
	pitch_i = 0
	cy = 0.75
	vy = 0.0
	spd = 0.0
	mode = "climb"
	mode_t = 0.0
	throttle = 0.0
	lock_t = 0.0
	pump = 0.0
	chain = 0
	max_y = cy
	shake = 0.0
	box(Vector3(5, -1, -1), Vector3(40, 2, 10), GOOD)
	_build_pitch(0)
	anchor = box(Vector3.ZERO, Vector3(0.35, 0.3, 0.35), D)
	for i in NCLOUD:
		clouds.append(box(Vector3(rng.randf_range(4, 20), rng.randf_range(-20, 40), -30), Vector3(rng.randf_range(4, 8), 1.4, 2), WHITE))
	climber = Node3D.new()
	world.add_child(climber)
	torso = box(Vector3.ZERO, Vector3(0.45, 0.8, 0.4), ME, climber)
	box(Vector3(0, 0.62, 0), Vector3(0.38, 0.38, 0.38), SOFT, climber)
	for z in [-0.26, 0.26]:
		arms.append(box(Vector3(-0.15, 0.5, z), Vector3(0.14, 0.6, 0.14), B, climber))
		legs.append(box(Vector3(-0.1, -0.65, z * 0.6), Vector3(0.18, 0.6, 0.18), INK, climber))
	for i in NROPE:
		rope.append(box(Vector3.ZERO, Vector3.ONE, A))
	for i in NSTREAK:
		var s := box(Vector3(0, -100, 1.5), Vector3(2.5, 0.06, 0.06), WHITE)
		s.visible = false
		streaks.append(s)
	_start_pitch()
	cam_y = cy + 3.5


# ---- 절벽 ----
func _build_pitch(p: int) -> void:
	var holder := Node3D.new()
	world.add_child(holder)
	pitch_nodes.append(holder)
	var b := float(p * PH)
	var types: Array[int] = []
	types.resize(PH)
	types.fill(0)
	if p == 1:
		_bands(types, [1], 3, 6, 3, 5)
	elif p == 2:
		_bands(types, [2, 1], 5, 7, 3, 5)
	elif p >= 3:
		_bands(types, [1, 2, 0], 3, 6, 2, 4)
	var off := 0.0
	for k in PH:
		var ty: int = types[k]
		off = minf(off + 0.45, 2.7) if ty == 2 else 0.0
		rock_t.append(ty)
		rock_x.append(off)
		box(Vector3(off - 5.0, b + k + 0.5, -1.2), Vector3(10.0, 1.0, 3.6), ROCK[ty], holder)
	if p > 0:
		box(Vector3(-3.6, b - 0.3, -1.0), Vector3(10.0, 0.6, 4.0), GOOD, holder)


## 피치 안에 띠를 깐다 (처음·끝 3칸은 단단)
func _bands(types: Array[int], kinds: Array, l0: int, l1: int, g0: int, g1: int) -> void:
	var i := 3 + rng.randi_range(0, 2)
	var n := 0
	while i < PH - 3:
		var ln := rng.randi_range(l0, l1)
		var ty: int = kinds[n % kinds.size()] if kinds.size() < 3 else kinds[rng.randi() % kinds.size()]
		for k in ln:
			if i + k < PH - 3:
				types[i + k] = ty
		i += ln + rng.randi_range(g0, g1)
		n += 1


func _start_pitch() -> void:
	base_y = float(pitch_i * PH)
	top_y = base_y + PH
	_build_pitch(pitch_i + 1)
	if pitch_nodes.size() > 3:
		pitch_nodes.pop_front().queue_free()
	anchor.position = Vector3(0.35, base_y + 0.15, 0)
	storm_max = 24.0 if pitch_i < 4 else maxf(15.0, 26.0 - pitch_i * 1.5)
	storm = storm_max
	warn_s = 99
	wind_on = pitch_i >= 3
	gust = 0
	gust_t = 3.0
	msg(NAMES[mini(pitch_i, 4)], 1.2)


func _next_pitch() -> void:
	pitch_i += 1
	for pt in pitons:
		pt["h"].queue_free()
	pitons.clear()
	cy = float(pitch_i * PH) + 0.75
	spd = 0.0
	pump = 0.0
	mode = "hang"
	mode_t = 0.8
	play("win")
	_start_pitch()


func _face(y: float) -> float:
	var f := clampf(y - 0.5, 0.0, rock_x.size() - 1.001)
	var i := int(f)
	return lerpf(rock_x[i], rock_x[i + 1], f - i)


func _rock(y: float) -> int:
	return rock_t[clampi(int(y), 0, rock_t.size() - 1)]


# ---- 입력 ----
func _tap(p: Vector2) -> void:
	press = p
	press0 = p
	press_dur = 0.0
	moved = 0.0
	throttle = 0.0
	tap_in_fall = mode == "fall"
	if tap_in_fall:
		_jam()


func _drag(p: Vector2) -> void:
	moved = maxf(moved, p.distance_to(press0))
	press.y = maxf(press.y, p.y)  # 아래로 내리면 기준점이 따라 내려온다
	throttle = clampf((press.y - p.y) / 240.0, 0.0, 1.0)


func _lift(_p: Vector2) -> void:
	throttle = 0.0
	if tap_in_fall or mode != "climb" or press_dur > 0.22 or moved > 30.0:
		return
	mode = "hammer"
	mode_t = 0.5 if _rock(cy) == 2 else 0.3
	ham_hit = false
	spd = 0.0
	beep(1300.0, 0.04, 0.0, 0.2)


# ---- 판 ----
func _step(dt: float) -> void:
	clock += dt
	if held:
		press_dur += dt
	lock_t -= dt
	mode_t -= dt
	if mode != "hang":
		storm -= dt
	var sf := storm / storm_max
	gauge(sf, GOOD if sf > 0.35 else (D if sf > 0.2 else BAD))
	if storm < 5.0 and ceili(storm) != warn_s:
		warn_s = ceili(storm)
		beep(200.0, 0.12, 160.0, 0.25)
	if storm <= 0.0:
		msg("폭풍", 1.5)
		end()
		return
	_wind(dt)
	match mode:
		"climb":
			_climb(dt)
		"hammer":
			if not ham_hit and mode_t < 0.15:
				ham_hit = true
				beep(1500.0, 0.05, 0.0, 0.22)
			if mode_t <= 0.0:
				_place()
				mode = "climb"
			elif randf() < _hazard(dt, 0.0) * dt:
				_slip()
		"fall":
			_fall(dt)
		"hang":
			if mode_t <= 0.0:
				mode = "climb"
	if over:
		return
	max_y = maxf(max_y, cy)
	score = int(max_y - 0.75) + pitch_i * 10
	_pitons_frame(dt)
	_climber_frame(dt)
	_rope_frame()
	_view_frame(dt)


func _climb(dt: float) -> void:
	var ty := _rock(cy)
	var vm := VMAX * (0.8 if ty == 2 else 1.0)
	spd = move_toward(spd, throttle * vm if held else 0.0, 12.0 * dt)
	cy += spd * dt
	phase += spd * dt * 3.0
	tick += spd * dt
	if tick > 0.8:
		tick = 0.0
		beep(260.0 + spd * 80.0, 0.03, 0.0, 0.1)
	var s := spd / VMAX
	var rate := 1.1 * pow(maxf(s - 0.3, 0.0) / 0.7, 2.0)
	if ty == 1:
		rate *= 2.4
	rate += _hazard(dt, s)
	if cy < base_y + 3.0:
		rate = 0.0  # 출발 바로 위는 안 미끄러진다
	risk = clampf(rate / 1.5, 0.0, 1.0)
	if randf() < rate * dt:
		_slip()
		return
	if cy >= top_y - 1.4:
		_next_pitch()


## 오버행에서 멈춰 있으면 팔이 풀리고, 돌풍 중에 움직이면 날린다
func _hazard(dt: float, s: float) -> float:
	var rate := 0.0
	if _rock(cy) == 2 and s < 0.15:
		var was := pump
		pump += dt
		if was < 0.5 and pump >= 0.5:
			beep(150.0, 0.2, 110.0, 0.25)
		if pump > 0.8:
			rate += 2.5
	else:
		pump = maxf(pump - dt * 2.0, 0.0)
	if gust == 2 and s > 0.15:
		rate += 3.0
	return rate


func _wind(dt: float) -> void:
	if not wind_on:
		gust = 0
		return
	gust_t -= dt
	if gust_t <= 0.0:
		gust = (gust + 1) % 3
		gust_t = [rng.randf_range(3.0, 5.0), 1.0, 1.6][gust]
		if gust == 1:
			msg("바람!", 0.8)
			beep(180.0, 0.6, 420.0, 0.15)
		elif gust == 2:
			beep(320.0, 1.2, 200.0, 0.2)


func _place() -> void:
	var py := cy + 0.35
	var h := Node3D.new()
	world.add_child(h)
	var px := _face(py) + 0.2
	h.position = Vector3(px, py, 0.1)
	var m := box(Vector3.ZERO, Vector3(0.45, 0.12, 0.25), PITON, h)
	box(Vector3(0.22, -0.16, 0), Vector3(0.1, 0.3, 0.1), D, h)
	var pt := {"y": py, "x": px, "h": h, "m": m, "crumb": _rock(py) == 1, "load": false, "lt": 0.0, "lw": 0.3}
	var i := 0
	while i < pitons.size() and float(pitons[i]["y"]) <= py:
		i += 1
	pitons.insert(i, pt)
	beep(1700.0, 0.06, 0.0, 0.22)


func _slip() -> void:
	mode = "fall"
	vy = 0.0
	spd = 0.0
	pump = 0.0
	chain = 0
	lock_t = 0.0
	msg("미끄럼!", 0.5)
	beep(520.0, 0.25, 150.0, 0.3)


func _fall(dt: float) -> void:
	vy -= GRAV * dt
	if not pitons.is_empty():
		var top: Dictionary = pitons.back()
		if not top["load"] and cy < float(top["y"]) - SLACK:
			top["load"] = true
			top["lt"] = 0.0
			top["lw"] = clampf(0.6 - absf(vy) * 0.022, 0.16, 0.6) * (0.55 if top["crumb"] else 1.0)
			top["m"].material_override = mat(BAD)
			msg("지금!", top["lw"])
			beep(700.0 + chain * 120.0, 0.05, 0.0, 0.25)
		if top["load"]:
			vy *= exp(-2.5 * dt)
			top["lt"] += dt
			if top["lt"] >= top["lw"]:
				_pop(top)
	cy += vy * dt
	shake = maxf(shake, minf(absf(vy) * 0.02, 0.4))
	if cy - 0.75 <= base_y:
		cy = base_y + 0.75
		msg("바닥!", 1.5)
		end()


func _jam() -> void:
	if lock_t > 0.0:
		return
	if not pitons.is_empty() and pitons.back()["load"]:
		var top: Dictionary = pitons.back()
		top["load"] = false
		top["m"].material_override = mat(PITON)
		mode = "hang"
		mode_t = 0.45
		vy = 0.0
		cy = float(top["y"]) - SLACK + 0.02
		shake = 0.3
		msg("버텨!", 0.5)
		play("good")
	else:
		lock_t = 0.35
		msg("헛손", 0.4)
		beep(160.0, 0.08, 0.0, 0.2)


func _pop(pt: Dictionary) -> void:
	pitons.erase(pt)
	flying.append({"h": pt["h"], "v": Vector3(rng.randf_range(3, 6), rng.randf_range(2, 5), rng.randf_range(-1, 1)), "w": rng.randf_range(-14, 14)})
	beep(1200.0 + chain * 160.0, 0.06, 2400.0 + chain * 200.0, 0.25)
	chain += 1
	shake = 0.5


# ---- 그리기 ----
func _pitons_frame(dt: float) -> void:
	for pt in pitons:
		var h: Node3D = pt["h"]
		h.position.x = float(pt["x"]) + (sin(clock * 90.0) * 0.07 if pt["load"] else 0.0)
	for i in range(flying.size() - 1, -1, -1):
		var f := flying[i]
		var h: Node3D = f["h"]
		f["v"] += Vector3(0, -20.0 * dt, 0)
		h.position += f["v"] * dt
		h.rotation.z += float(f["w"]) * dt
		if h.position.y < cam_y - 20.0:
			h.queue_free()
			flying.remove_at(i)


func _climber_frame(_dt: float) -> void:
	var jit := sin(clock * 70.0) * 0.05 if pump > 0.4 else 0.0
	climber.position = Vector3(_face(cy) + 0.45 + jit, cy, 0)
	torso.material_override = mat(ME.lerp(BAD, roundf(risk * 4.0) / 4.0) if mode == "climb" else ME)
	var sw := sin(phase)
	for k in 2:
		var sgn := 1.0 if k == 0 else -1.0
		if mode == "fall":
			arms[k].position.y = 0.75 + sin(clock * 30.0 + k * 2.0) * 0.15
			legs[k].position.y = -0.6 + sin(clock * 25.0 + k) * 0.1
		elif mode == "hammer" and k == 0:
			arms[k].position.y = 0.45 + absf(sin(clock * 40.0)) * 0.3
		else:
			arms[k].position.y = 0.5 + sw * sgn * 0.25
			legs[k].position.y = -0.65 - sw * sgn * 0.18


func _rope_frame() -> void:
	var pts: Array[Vector3] = [Vector3(0.35, base_y + 0.3, 0.1)]
	for pt in pitons:
		pts.append((pt["h"] as Node3D).position + Vector3(0.22, -0.25, 0))
	pts.append(climber.position + Vector3(0, -0.2, 0.1))
	var start := maxi(0, pts.size() - 1 - NROPE)
	for i in NROPE:
		var r := rope[i]
		var k := start + i
		if k + 1 >= pts.size():
			r.visible = false
			continue
		var a := pts[k]
		var d := pts[k + 1] - a
		r.visible = true
		r.position = a + d * 0.5
		r.rotation = Vector3(0, 0, atan2(-d.x, d.y))
		r.scale = Vector3(0.07, maxf(d.length(), 0.01), 0.07)


func _view_frame(dt: float) -> void:
	cam_y = lerpf(cam_y, cy + 3.5, 1.0 - exp(-(10.0 if mode == "fall" else 5.0) * dt))
	shake = maxf(shake - dt * 1.5, 0.0)
	cam.position = Vector3(2.0 + randf_range(-1, 1) * shake * 0.4, cam_y + randf_range(-1, 1) * shake * 0.4, 20.0)
	for c in clouds:
		if c.position.y < cam_y - 34.0:
			c.position = Vector3(rng.randf_range(4, 20), cam_y + rng.randf_range(30, 36), -30)
		elif c.position.y > cam_y + 40.0:
			c.position = Vector3(rng.randf_range(4, 20), cam_y - rng.randf_range(30, 34), -30)
	var falling := mode == "fall" and absf(vy) > 7.0
	for i in NSTREAK:
		var s := streaks[i]
		if gust > 0 and i < (4 if gust == 1 else NSTREAK):
			s.visible = true
			s.scale = Vector3(2.5, 0.06, 0.06)
			s.position.x += dt * 40.0
			if s.position.x > 14.0 or absf(s.position.y - cam_y) > 13.0:
				s.position = Vector3(rng.randf_range(-8, -4), cam_y + rng.randf_range(-12, 12), 1.5)
		elif falling:
			s.visible = true
			s.scale = Vector3(0.06, 2.5, 0.06)
			s.position.y += dt * 30.0
			if s.position.y > cam_y + 13.0 or s.position.y < cam_y - 14.0:
				s.position = Vector3(rng.randf_range(0, 8), cam_y - rng.randf_range(10, 13), 1.5)
		else:
			s.visible = false
