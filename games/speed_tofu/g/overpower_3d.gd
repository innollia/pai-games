extends Tofu
## 힘이 너무 센 3인칭 플랫포머. 왼쪽 조이스틱 = 달리기(앞이 위), 점프 버튼, 얻은 제한 장치는 버튼으로 켜고 끈다.
## 점프하면 천장에 쾅, 달리면 턱에 걸려 튕겨 나간다. 방마다 제한 장치(감속 장치·무게추·낙하산)를 얻어 힘을 다스리고,
## 뒤 방은 장치를 잠깐 풀어야 넘는다. 용암·가시·구덩이 = 그 방 처음부터. 초록 발판 = 다음 방.
## 능력 목록은 AbilityPlatformer 카탈로그(달리기 공중 관성, 고정 높이 점프, 활공 낙하 속도 제한, 가시, 영구 능력만 남는 죽음)에서 빌렸다.

const HALF := Vector3(0.35, 0.5, 0.35)
const GRAV := 30.0
const JUMP_RAW := 22.0  # 맨몸 점프: 8칸 높이 (천장은 3칸)
const JUMP_W := 10.5  # 무게추: 1.8칸
const RUN_RAW := 22.0  # 맨몸: 살짝만 밀어도 이 속도
const RUN_B := 7.0  # 감속 장치
const CHUTE := 2.5  # 낙하산 낙하 속도
const LAVA := Color("ff7a1a")
const CEIL := Color("bcd7f0")
const NAMES := {"brake": "감속 장치", "weight": "무게추", "chute": "낙하산"}
const ROOMS := ["복도", "계단", "가시 천장", "용암 호수", "탑"]
const BONK_WORDS := ["쾅!", "꽝!", "아야!", "BONK"]

var lv := 0
var level: Node3D
var solids: Array[AABB] = []
var hazards: Array[AABB] = []
var goal_box := AABB()
var items: Array[Dictionary] = []  # {n, kind}
var start_p := Vector3.ZERO
var owned := {}  # 영구로 얻은 장치 (죽어도 남는다)
var lim_on := {}  # 장치 -> 켜짐
var pos := Vector3.ZERO
var vel := Vector3.ZERO
var on_floor := false
var coyote := 0.0
var jbuf := 0.0
var gliding := false
var die_t := 0.0
var clear_t := 0.0
var sq := 1.0
var sq_v := 0.0
var shake := 0.0
var step_t := 0.0
var bonks := 0
var cam_p := Vector3.ZERO
var face := 0.0
var last_s := AABB()
var hero: Node3D
var pk_weight: MeshInstance3D
var pk_brake: Array[MeshInstance3D] = []
var pk_chute: MeshInstance3D
var canopy: MeshInstance3D


func _setup() -> void:
	howto = "힘이 너무 세다! 점프하면 천장에 쾅, 달리면 날아간다.\n왼손 조이스틱 = 달리기, 점프 버튼 = 점프.\n방마다 감속 장치·무게추·낙하산을 얻어 힘을 누른다. 장치 버튼으로 잠깐 풀면 폭주·초점프.\n용암·가시·구덩이에 닿으면 그 방 처음부터. 초록 발판까지 가면 다음 방."
	time_limit = 0.0
	cam.fov = 70.0
	kit_stick()
	kit_button("jump", "점프", Vector2(590, 1100), 95.0, ME)


func _reset() -> void:
	level = null
	owned.clear()
	lim_on.clear()
	for k in NAMES:
		_btns.erase(k)
	bonks = 0
	hero = Node3D.new()
	world.add_child(hero)
	box(Vector3(0, 0.5, 0), Vector3(0.7, 1.0, 0.7), ME, hero)
	box(Vector3(0, 0.72, -0.36), Vector3(0.5, 0.18, 0.06), WHITE, hero)
	pk_weight = box(Vector3(0, 0.22, 0.45), Vector3(0.42, 0.42, 0.26), INK, hero)
	pk_brake.clear()
	for sd in [-1.0, 1.0]:
		pk_brake.append(box(Vector3(sd * 0.43, 0.16, 0), Vector3(0.14, 0.32, 0.55), D, hero))
	pk_chute = box(Vector3(0, 0.78, 0.42), Vector3(0.5, 0.34, 0.16), C, hero)
	canopy = box(Vector3(0, 2.0, 0.1), Vector3(2.2, 0.16, 1.5), C, hero)
	lv = 0
	_room(0)


# ---- 방 ----
func _room(i: int) -> void:
	if level:
		level.queue_free()
	level = Node3D.new()
	world.add_child(level)
	solids.clear()
	hazards.clear()
	items.clear()
	goal_box = AABB()
	match i:
		0: _r0()
		1: _r1()
		2: _r2()
		3: _r3()
		_: _r4()
	pos = start_p
	vel = Vector3.ZERO
	on_floor = false
	coyote = 0.0
	jbuf = 0.0
	gliding = false
	die_t = 0.0
	clear_t = 0.0
	sq = 1.0
	sq_v = 0.0
	face = 0.0
	for k in owned:
		lim_on[k] = true
	_labels()
	cam_p = Vector3(pos.x * 0.7, pos.y + 2.2, pos.z + 5.5)
	msg("%d. %s" % [i + 1, ROOMS[i]], 1.4)


## 1. 복도: 맨몸. 천장 3칸, 용암 구덩이 셋. 턱에 걸리면 튕겨 날아간다. 끝에 감속 장치.
func _r0() -> void:
	start_p = Vector3(0, 0.501, 3)
	_hall(9, -62.5, -4, 3.0)
	_w(Vector3(-3, -4, 9), Vector3(3, 8, 9.5))
	_s(Vector3(-3, -1, 9), Vector3(3, 0, -10))
	_lava(Vector3(-3, -3, -10), Vector3(3, -0.3, -13))
	_s(Vector3(-3, -1, -13), Vector3(3, 0, -24))
	_lava(Vector3(-3, -3, -24), Vector3(3, -0.3, -28))
	_s(Vector3(-3, -1, -28), Vector3(3, 0, -38))
	_s(Vector3(-3, 0, -36), Vector3(3, 0.4, -37), A)  # 튕김 턱
	_lava(Vector3(-3, -3, -38), Vector3(3, -0.3, -42.5))
	_s(Vector3(-3, -1, -42.5), Vector3(3, 0, -62))
	_s(Vector3(-3, -1, -62), Vector3(3, 3, -62.5), SOFT)
	_item(Vector3(0, 1, -48), "brake")
	_goal(Vector3(-2.5, 0, -54), Vector3(2.5, 0.08, -58))


## 2. 계단: 감속 장치, 점프는 맨몸. 천장이 한 칸씩 올라가는 틈에서 뛰어야 다음 계단에 닿는다. 끝에 무게추.
func _r1() -> void:
	start_p = Vector3(0, 0.501, 3)
	_hall(9, -36.5, -4, 10.0, false)
	_w(Vector3(-3, -4, 9), Vector3(3, 12, 9.5))
	_lava(Vector3(-3, -4, 9), Vector3(3, -2, -36))
	_s(Vector3(-3, -2, 9), Vector3(3, 0, -4))
	_ceil(9, -2.5, 3.0)
	for k in range(1, 6):
		var zs := -5.5 - (k - 1) * 5.0
		var top := 1.2 * k
		var ze := zs - 3.5 if k < 5 else -36.0
		_s(Vector3(-3, -2, zs), Vector3(3, top, ze))
		var cz0 := zs + 3.0
		var cz1 := zs - 2.0 if k < 5 else -36.0
		_ceil(cz0, cz1, top + 3.0)
		_s(Vector3(-3, top + 2.2, cz0 + 0.2), Vector3(3, top + 3.0, cz0 - 0.2), CEIL)
	_s(Vector3(-3, 0, -36), Vector3(3, 10, -36.5), SOFT)
	_item(Vector3(0, 7, -28), "weight")
	_goal(Vector3(-2.5, 6, -31), Vector3(2.5, 6.08, -34))


## 3. 가시 천장: 무게추를 끄면 가시에 머리를 박는다. 가운데 높은 턱만은 무게추를 풀고 초점프, 올라가면 다시 켠다. 끝에 낙하산.
func _r2() -> void:
	start_p = Vector3(0, 0.501, 3)
	_hall(9, -46.5, -4, 12.0)
	_w(Vector3(-3, -4, 9), Vector3(3, 12, 9.5))
	_s(Vector3(-3, -1, 9), Vector3(3, 0, -12))
	_s(Vector3(-3, 0, -6), Vector3(3, 1.0, -7), A)  # 허들
	_lava(Vector3(-3, -3, -12), Vector3(3, -0.3, -15))
	_s(Vector3(-3, -1, -15), Vector3(3, 0, -24))
	_spike_ceil(9, -20, 3.1)
	_s(Vector3(-3, -1, -24), Vector3(3, 5, -34))  # 높은 턱 (5칸)
	_lava(Vector3(-3, -1, -34), Vector3(3, 4.7, -37))
	_s(Vector3(-3, -1, -37), Vector3(3, 5, -46))
	_spike_ceil(-31, -46, 8.1)
	_s(Vector3(-3, 5, -46), Vector3(3, 12, -46.5), SOFT)
	_item(Vector3(0, 6, -39.5), "chute")
	_goal(Vector3(-2.5, 5, -41), Vector3(2.5, 5.08, -44))


## 4. 용암 호수: 높은 곳에서 낙하산으로 섬에 내려앉고, 낮은 천장 아래 긴 호수는 감속을 풀고 무게추 점프 + 낙하산.
func _r3() -> void:
	start_p = Vector3(0, 6.501, 3)
	_hall(9, -56.5, -4, 12.0, false)
	_w(Vector3(-3, -4, 9), Vector3(3, 14, 9.5))
	_lava(Vector3(-3, -4, 9), Vector3(3, -0.3, -56))
	_s(Vector3(-3, -1, 9), Vector3(3, 6, -2))
	_s(Vector3(-3, -1, -10), Vector3(3, 0, -18))
	_ceil(9, -16, 12.0)
	_ceil(-16, -56, 3.2)
	_s(Vector3(-3, 3.6, -15.8), Vector3(3, 12, -16.2), CEIL)
	_s(Vector3(-3, -1, -38), Vector3(3, 0, -56))
	_spikes(Vector3(-3, 0, -55.7), Vector3(3, 3.2, -56))
	_s(Vector3(-3, -1, -56), Vector3(3, 3.2, -56.5), SOFT)
	_goal(Vector3(-2.5, 0, -46), Vector3(2.5, 0.08, -50))


## 5. 탑: 초점프로 6칸 턱에, 무게추를 켜고 폭주 점프로 용암 틈을, 낙하산으로 가시 바닥 너머 초록 발판에.
func _r4() -> void:
	start_p = Vector3(0, 0.501, 3)
	_hall(9, -52.5, -4, 14.0, false)
	_w(Vector3(-3, -4, 9), Vector3(3, 16, 9.5))
	_lava(Vector3(-3, -4, 9), Vector3(3, -0.3, -52))
	_s(Vector3(-3, -1, 9), Vector3(3, 0, -6))
	_ceil(9, -12, 14.0)
	_s(Vector3(-3, -1, -6), Vector3(3, 6, -14))
	_s(Vector3(-3, -1, -24), Vector3(3, 6, -30))
	_ceil(-12, -52, 9.0)
	_s(Vector3(-3, 9.4, -11.8), Vector3(3, 14, -12.2), CEIL)
	_s(Vector3(-3, -1, -30), Vector3(3, 0, -52))
	_spikes(Vector3(-3, 0, -30), Vector3(3, 0.3, -44))
	_goal(Vector3(-2.5, 0, -44.5), Vector3(2.5, 0.08, -51.5))
	_spikes(Vector3(-3, 0, -51.7), Vector3(3, 9, -52))
	_s(Vector3(-3, -1, -52), Vector3(3, 9, -52.5), SOFT)


# ---- 방 짓는 도구 (모서리 두 점) ----
func _ab(a: Vector3, b: Vector3) -> AABB:
	var lo := a.min(b)
	return AABB(lo, a.max(b) - lo)


func _s(a: Vector3, b: Vector3, col := WHITE) -> void:
	var bb := _ab(a, b)
	solids.append(bb)
	box(bb.get_center(), bb.size, col, level)


## 안 보이는 벽 (카메라가 지나가는 방 입구)
func _w(a: Vector3, b: Vector3) -> void:
	solids.append(_ab(a, b))


func _lava(a: Vector3, b: Vector3) -> void:
	var bb := _ab(a, b)
	hazards.append(bb)
	box(bb.get_center(), bb.size, LAVA, level)


## 가시: 얇은 빨간 판 + 45도 돌린 상자 이빨
func _spikes(a: Vector3, b: Vector3) -> void:
	var bb := _ab(a, b)
	hazards.append(bb)
	var thin := 0
	for k in 3:
		if bb.size[k] < bb.size[thin]:
			thin = k
	var u := (thin + 1) % 3
	var w := (thin + 2) % 3
	var flat := bb.size
	flat[thin] *= 0.3
	box(bb.get_center(), flat, BAD.lightened(0.3), level)
	var nu := maxi(1, int(bb.size[u] / 1.5))
	var nw := maxi(1, int(bb.size[w] / 1.5))
	var tsz := maxf(bb.size[thin] * 1.6, 0.45)
	for i in nu:
		for j in nw:
			var c := bb.get_center()
			c[u] = bb.position[u] + (i + 0.5) * bb.size[u] / nu
			c[w] = bb.position[w] + (j + 0.5) * bb.size[w] / nw
			var m := box(c, Vector3.ONE * tsz, BAD, level)
			m.rotation = Vector3(0.785, 0.785, 0)


func _goal(a: Vector3, b: Vector3) -> void:
	goal_box = _ab(a, b)
	box(goal_box.get_center(), goal_box.size, GOOD, level)
	var c := goal_box.get_center()
	box(Vector3(c.x + 2.0, goal_box.end.y + 1.0, c.z), Vector3(0.1, 2.0, 0.1), INK, level)
	box(Vector3(c.x + 1.6, goal_box.end.y + 1.75, c.z), Vector3(0.7, 0.45, 0.06), GOOD, level)


func _item(p: Vector3, kind: String) -> void:
	if owned.has(kind):
		return
	var m := box(p, Vector3(0.6, 0.6, 0.6), D, level)
	items.append({"n": m, "kind": kind})


## 양옆 벽 (+ 천장)
func _hall(z0: float, z1: float, y0: float, y1: float, roof := true) -> void:
	_s(Vector3(-3.4, y0, z0), Vector3(-3, y1 + 0.4, z1), SOFT)
	_s(Vector3(3, y0, z0), Vector3(3.4, y1 + 0.4, z1), SOFT)
	if roof:
		_ceil(z0, z1, y1)


func _ceil(z0: float, z1: float, y: float) -> void:
	_s(Vector3(-3, y, z0), Vector3(3, y + 0.4, z1), CEIL)


func _spike_ceil(z0: float, z1: float, y: float) -> void:
	_s(Vector3(-3, y + 0.3, z0), Vector3(3, y + 0.7, z1), CEIL)
	_spikes(Vector3(-3, y, z0), Vector3(3, y + 0.3, z1))


# ---- 장치 ----
func _grant(kind: String) -> void:
	owned[kind] = true
	lim_on[kind] = true
	match kind:
		"brake": kit_button("brake", "감속", Vector2(620, 890), 60.0, GOOD)
		"weight": kit_button("weight", "무게", Vector2(450, 930), 60.0, GOOD)
		"chute": kit_button("chute", "낙하산", Vector2(400, 1130), 65.0, C)
	_labels()
	play("good")
	beep(1320.0, 0.2, 1760.0, 0.2)
	msg(NAMES[kind] + "!", 1.6)


## 켜짐 = 초록 이름, 꺼짐 = 빨간 폭주·초점프
func _labels() -> void:
	if _btns.has("brake"):
		_btns.brake.label = "감속" if lim_on.brake else "폭주"
		_btns.brake.color = GOOD if lim_on.brake else BAD
	if _btns.has("weight"):
		_btns.weight.label = "무게" if lim_on.weight else "초점프"
		_btns.weight.color = GOOD if lim_on.weight else BAD


func _on(kind: String) -> bool:
	return lim_on.get(kind, false)


# ---- 한 프레임 ----
func _step(dt: float) -> void:
	if die_t > 0.0:
		die_t -= dt
		sq = 0.25
		_visual(dt)
		if die_t <= 0.0:
			_room(lv)
		return
	if clear_t > 0.0:
		clear_t -= dt
		face += dt * 14.0
		_visual(dt)
		if clear_t <= 0.0:
			lv += 1
			if lv >= ROOMS.size():
				end()
			else:
				_room(lv)
		return
	for k in ["brake", "weight"]:
		if owned.has(k) and kit_just(k):
			lim_on[k] = not lim_on[k]
			_labels()
			if lim_on[k]:
				beep(620.0, 0.07, 300.0, 0.25)
				msg("철컥", 0.5)
			else:
				beep(300.0, 0.25, 1500.0, 0.3)
				msg("폭주!" if k == "brake" else "초점프!", 0.6)
	# 달리기: 맨몸은 살짝만 밀어도 최고 속도, 손을 떼도 잘 안 멈춘다 (카탈로그 달리기 ③ 공중 관성)
	var braked := _on("brake")
	var dir := Vector3(kit_move.x, 0, kit_move.y)
	var amt := dir.length()
	var top := RUN_B if braked else RUN_RAW
	var want := Vector2.ZERO
	if amt > 0.15:
		var d2 := Vector2(dir.x, dir.z).normalized()
		want = d2 * top * (minf(amt * 1.25, 1.0) if braked else 1.0)
	var acc := 0.0
	if on_floor:
		if amt > 0.15:
			acc = 40.0 if braked else 90.0
		else:
			acc = 40.0 if braked else 7.0
	else:
		acc = 25.0 if braked else (30.0 if amt > 0.15 else 0.5)
	var hv := Vector2(vel.x, vel.z).move_toward(want, acc * dt)
	vel.x = hv.x
	vel.z = hv.y
	# 점프 (카탈로그 점프 ② 고정 높이)
	coyote = 0.1 if on_floor else coyote - dt
	jbuf = 0.12 if kit_just("jump") else jbuf - dt
	if jbuf > 0.0 and coyote > 0.0:
		jbuf = 0.0
		coyote = 0.0
		on_floor = false
		if _on("weight"):
			vel.y = JUMP_W
			beep(330.0, 0.1, 660.0, 0.2)
		else:
			vel.y = JUMP_RAW
			beep(200.0, 0.16, 1100.0, 0.3)
		sq = 1.4
		sq_v = 0.0
	vel.y -= GRAV * dt
	# 낙하산 (카탈로그 활공 ① 낙하 속도 제한)
	var glide := owned.has("chute") and kit_held("chute") and not on_floor and vel.y < 0.0
	if glide and not gliding:
		beep(700.0, 0.12, 450.0, 0.18)
	gliding = glide
	if gliding:
		vel.y = maxf(vel.y, -CHUTE)
	vel.y = clampf(vel.y, -28.0, 28.0)
	_move(dt)
	# 닿은 것
	var me := AABB(pos - HALF * 0.9, HALF * 1.8)
	for h in hazards:
		if me.intersects(h):
			_die()
			return
	if pos.y < -8.0:
		_die()
		return
	for it in items:
		var n: MeshInstance3D = it.n
		n.rotation.y += dt * 3.0
		if n.position.distance_to(pos) < 1.0:
			n.visible = false
			items.erase(it)
			_grant(it.kind)
			break
	if goal_box.has_volume() and me.grow(0.1).intersects(goal_box):
		clear_t = 1.4
		score = lv + 1
		play("win")
		msg("통과!", 1.2)
	# 발소리: 빠를수록 촘촘
	var hs := Vector2(vel.x, vel.z).length()
	if on_floor and hs > 1.0:
		step_t -= dt * hs / 2.5
		if step_t <= 0.0:
			step_t = 1.0
			beep(90.0 + hs * 8.0, 0.03, 0.0, 0.1)
	gauge(hs / RUN_RAW, BAD if hs > 12.0 else GOOD)
	_visual(dt)


func _move(dt: float) -> void:
	var was_floor := on_floor
	on_floor = false
	var hs := Vector2(vel.x, vel.z).length()
	for ax in [0, 2]:
		if _axis(ax, vel[ax] * dt) != 0:
			_side_hit(ax, hs, was_floor)
	var vy := vel.y
	var hy := _axis(1, vel.y * dt)
	if hy < 0:
		on_floor = true
		vel.y = 0.0
		if vy < -9.0:
			sq = 0.7
			beep(130.0, 0.06, 0.0, 0.18)
	elif hy > 0:
		_bonk(vy)


## 한 축으로 움직이고 상자에 박히면 밀어낸다 (부딪힌 쪽 부호)
func _axis(ax: int, d: float) -> int:
	if d == 0.0:
		return 0
	pos[ax] += d
	var hit := 0
	for s in solids:
		if AABB(pos - HALF, HALF * 2.0).intersects(s):
			if d > 0.0:
				pos[ax] = s.position[ax] - HALF[ax] - 0.001
			else:
				pos[ax] = s.end[ax] + HALF[ax] + 0.001
			hit = 1 if d > 0.0 else -1
			last_s = s
	return hit


## 옆으로 박힘: 낮은 턱은 넘는데 빠르면 튕겨 날아가고, 벽에 빠르게 박으면 쿵 하고 튕긴다
func _side_hit(ax: int, hs: float, was_floor: bool) -> void:
	var rise := last_s.end.y - (pos.y - HALF.y)
	if was_floor and rise > 0.0 and rise <= 0.45:
		pos.y = last_s.end.y + HALF.y + 0.01
		if hs > 12.0:
			vel.y = hs * 0.8
			sq = 1.5
			sq_v = 0.0
			beep(250.0, 0.2, 1300.0, 0.3)
			msg("붕!", 0.5)
		return
	var v: float = absf(vel[ax])
	if v > 12.0:
		vel[ax] = -signf(vel[ax]) * v * 0.3
		shake = 0.25
		sq = 0.65
		sq_v = 0.0
		beep(110.0, 0.18, 45.0, 0.4)
		msg("쿵!", 0.5)
	else:
		vel[ax] = 0.0


## 천장에 머리: 찌그러지고 화면이 흔들리고 쾅
func _bonk(v: float) -> void:
	vel.y = -2.0
	if v < 4.0:
		return
	bonks += 1
	shake = clampf(v * 0.02, 0.1, 0.45)
	sq = 0.45
	sq_v = 0.0
	beep(70.0, 0.25, 35.0, 0.45)
	beep(1500.0, 0.06, 500.0, 0.18)
	msg(BONK_WORDS[bonks % BONK_WORDS.size()], 0.5)


func _die() -> void:
	die_t = 1.0
	vel = Vector3.ZERO
	gliding = false
	shake = 0.3
	play("bad")
	msg("으악", 0.9)


func _visual(dt: float) -> void:
	sq_v += (1.0 - sq) * 260.0 * dt
	sq_v *= exp(-10.0 * dt)
	sq = clampf(sq + sq_v * dt, 0.25, 1.6)
	var k := 1.0 / sqrt(sq)
	hero.position = pos - Vector3(0, HALF.y, 0)
	hero.scale = Vector3(k, sq, k)
	if Vector2(vel.x, vel.z).length() > 1.0:
		face = lerp_angle(face, atan2(-vel.x, -vel.z), 1.0 - exp(-12.0 * dt))
	hero.rotation.y = face
	pk_weight.visible = owned.has("weight") and _on("weight")
	for m in pk_brake:
		m.visible = owned.has("brake") and _on("brake")
	pk_chute.visible = owned.has("chute")
	canopy.visible = gliding
	# 등 뒤 카메라: 천장 밑으로만, 빠를수록 넓게, 박으면 흔들림
	var target := Vector3(pos.x * 0.7, pos.y + 2.2, pos.z + 5.5)
	cam_p = cam_p.lerp(target, 1.0 - exp(-9.0 * dt))
	cam_p.y = minf(cam_p.y, _roof(cam_p.x, cam_p.z, pos.y + 0.6) - 0.45)
	var jig := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * shake
	shake = move_toward(shake, 0.0, dt * 1.2)
	cam.position = cam_p + jig
	cam.look_at(Vector3(pos.x * 0.85, pos.y + 0.4, pos.z - 4.0), Vector3.UP)
	var hs := Vector2(vel.x, vel.z).length()
	cam.fov = lerpf(cam.fov, 68.0 + hs * 0.9, 1.0 - exp(-5.0 * dt))


## (x, z) 위, 높이 y 보다 위에 있는 가장 낮은 상자 밑면
func _roof(x: float, z: float, y: float) -> float:
	var r := 1000.0
	for s in solids:
		if s.position.y > y and s.position.y < r and x > s.position.x and x < s.end.x and z > s.position.z and z < s.end.z:
			r = s.position.y
	return r
