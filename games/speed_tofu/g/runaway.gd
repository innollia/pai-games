extends Tofu
## 브레이크 고장: 수레는 멈추지 않고 계속 빨라진다. 화면 왼쪽/오른쪽을 탭(또는 밀기)해 다음 갈림길에서 갈 길을 고른다. 빨간 막힘·끊긴 레일은 쾅, 노란 상자는 +2와 더 빠르게.

const TS := 2.0  # 침목 간격
const NS := 36  # 침목 칸 수 (앞으로 약 70)
const JS0 := 40.0  # 첫 갈림길
const PER := 44.0  # 갈림길 간격
const JL := 26.0  # 갈림길 길이
const W := 2.6  # 갈래가 벌어지는 폭
const V0 := 14.0
const ACC := 1.1
const RING := 8

var cart: MeshInstance3D
var cart_top: MeshInstance3D
var dist := 0.0
var spd := 0.0
var bonus := 0.0
var el := 0.0
var sel := 1
var tap_x := 0.0
var clack_next := 6.0
var clack_k := 0
# 칸마다 갈래 두 개: 침목 + 레일 두 줄
var ties: Array[MeshInstance3D] = []
var rails: Array[MeshInstance3D] = []
var posts: Array[MeshInstance3D] = []
var floor_m: MeshInstance3D
# 갈림길 그림 (4벌을 돌려 쓴다)
var bar_m: Array[MeshInstance3D] = []
var gap_m: Array[MeshInstance3D] = []
var pick_m: Array[MeshInstance3D] = []
var flag_m: MeshInstance3D
# 갈림길 정보 (고리 버퍼)
var r_id := PackedInt32Array()
var r_bad := PackedInt32Array()  # -1 왼쪽, 1 오른쪽, 0 둘 다 안전
var r_kind := PackedInt32Array()  # 0 막힘, 1 끊긴 레일
var r_pick := PackedInt32Array()  # 노란 상자 쪽, 0 없음
var r_take := PackedInt32Array()
var r_st := PackedInt32Array()  # 0 아직, 1 들어감, 2 지나감
var m_tie: StandardMaterial3D
var m_sel: StandardMaterial3D
var m_rail: StandardMaterial3D
var m_post: Array[StandardMaterial3D] = []


func _setup() -> void:
	howto = "수레는 멈추지 않고 계속 빨라진다.\n화면 왼쪽/오른쪽을 탭해 다음 갈림길에서 갈 길을 고른다.\n빨간 막힘·끊긴 레일은 쾅. 노란 상자는 +2."
	time_limit = 0.0
	cam.fov = 62.0
	m_tie = mat(A)
	m_sel = mat(B)
	m_rail = mat(INK)
	m_post = [mat(C), mat(D), mat(GOOD), mat(B)]


func _reset() -> void:
	dist = 0.0
	spd = V0
	bonus = 0.0
	el = 0.0
	sel = 1
	clack_next = 6.0
	clack_k = 0
	floor_m = box(Vector3.ZERO, Vector3(60, 0.2, 200), SOFT)
	ties.clear()
	rails.clear()
	for i in NS * 2:
		ties.append(box(Vector3.ZERO, Vector3(1.8, 0.16, 0.45), A))
		rails.append(box(Vector3.ZERO, Vector3(0.14, 0.18, TS), INK))
		rails.append(box(Vector3.ZERO, Vector3(0.14, 0.18, TS), INK))
	posts.clear()
	for i in 28:
		posts.append(box(Vector3.ZERO, Vector3(0.6, 2.6, 0.6), C))
	bar_m.clear()
	gap_m.clear()
	pick_m.clear()
	for i in 4:
		bar_m.append(box(Vector3.ZERO, Vector3(2.4, 1.8, 0.8), BAD))
		gap_m.append(box(Vector3.ZERO, Vector3(1.8, 0.35, 0.35), BAD))
		gap_m.append(box(Vector3.ZERO, Vector3(1.8, 0.35, 0.35), BAD))
		pick_m.append(box(Vector3.ZERO, Vector3(0.9, 0.9, 0.9), D))
	flag_m = box(Vector3.ZERO, Vector3(1.0, 1.0, 1.0), ME)
	cart = box(Vector3.ZERO, Vector3(1.4, 0.9, 1.8), ME)
	cart_top = box(Vector3.ZERO, Vector3(1.5, 0.2, 1.9), D)
	r_id.resize(RING)
	r_bad.resize(RING)
	r_kind.resize(RING)
	r_pick.resize(RING)
	r_take.resize(RING)
	r_st.resize(RING)
	for i in RING:
		r_id[i] = -1
	_draw_all()


func _step(dt: float) -> void:
	el += dt
	spd = V0 + ACC * el + bonus
	dist += spd * dt
	# 레일 이음매 소리: 빨라질수록 촘촘해진다
	if dist >= clack_next:
		clack_next += 6.0
		clack_k += 1
		beep(150.0 if clack_k % 2 == 0 else 120.0, 0.035, 0.0, 0.14)
	if dist >= JS0:
		var j := int(floorf((dist - JS0) / PER))
		var s := dist - JS0 - j * PER
		if s < JL:
			var i := _j(j)
			if r_st[i] == 0:
				r_st[i] = 1
				r_take[i] = sel
				beep(420.0, 0.05, 260.0, 0.15)
			if r_st[i] == 1 and s >= JL * 0.5:
				r_st[i] = 2
				if r_take[i] == r_bad[i]:
					_crash()
					return
				score += 1
				if r_pick[i] == r_take[i]:
					score += 2
					bonus += 4.0
					msg("+2")
					play("good")
				else:
					beep(660.0, 0.06, 990.0, 0.15)
	_draw_all()
	gauge(spd / 80.0, A if spd < 50.0 else BAD)


func _tap(p: Vector2) -> void:
	tap_x = p.x
	_pick(-1 if p.x < 360.0 else 1)


func _drag(p: Vector2) -> void:
	if absf(p.x - tap_x) > 70.0:
		_pick(-1 if p.x < tap_x else 1)
		tap_x = p.x


func _pick(side: int) -> void:
	if side != sel:
		sel = side
		beep(900.0 if side > 0 else 700.0, 0.06, 0.0, 0.2)
		msg("<<" if side < 0 else ">>", 0.3)
	else:
		play("tap")


func _crash() -> void:
	cart.material_override = mat(BAD)
	cart.rotation = Vector3(0.5, 0.8, 0.6)
	cart.position.y += 0.8
	cart_top.rotation = Vector3(-0.6, -0.5, 0.9)
	cart_top.position += Vector3(0.6, 1.6, -1.0)
	msg("쾅", 1.0)
	beep(90.0, 0.4, 40.0, 0.35)
	end()


## 갈림길 j의 고리 칸 (처음 보면 만든다)
func _j(j: int) -> int:
	var i := j % RING
	if r_id[i] != j:
		r_id[i] = j
		r_st[i] = 0
		r_take[i] = 0
		r_kind[i] = randi() % 2
		if j > 0 and randf() < 0.22:
			r_bad[i] = 0
			r_pick[i] = -1 if randf() < 0.5 else 1
		else:
			r_bad[i] = -1 if randf() < 0.5 else 1
			r_pick[i] = -r_bad[i] if randf() < 0.3 else 0
	return i


func _shape(u: float) -> float:
	return smoothstep(0.0, 0.3, u) * (1.0 - smoothstep(0.7, 1.0, u))


## 거리 d에서 side 갈래의 x (갈림길 밖이면 0)
func _px(d: float, side: int) -> float:
	if d < JS0:
		return 0.0
	var s := fmod(d - JS0, PER)
	if s >= JL:
		return 0.0
	return side * W * _shape(s / JL)


func _draw_all() -> void:
	var jn := 0 if dist < JS0 else int(floorf((dist - JS0) / PER)) + 1
	# 침목과 레일
	var base := floorf(dist / TS) * TS - 2.0 * TS
	for k in NS:
		var d := base + k * TS
		var inj := false
		var j := -1
		var s := 0.0
		if d >= JS0:
			j = int(floorf((d - JS0) / PER))
			s = d - JS0 - j * PER
			inj = s < JL
		for p in 2:
			var n := k * 2 + p
			var side := 0
			var show := true
			var m := m_tie
			if inj:
				side = -1 if p == 0 else 1
				var i := _j(j)
				var chosen := sel if j == jn else r_take[i]
				if j >= jn - 1 and side == chosen:
					m = m_sel
				if side == r_bad[i]:
					if r_kind[i] == 1 and s > JL * 0.4 and s < JL * 0.6:
						show = false
					elif r_kind[i] == 0 and s > JL * 0.5 + 1.0:
						show = false
			elif p == 1:
				show = false
			ties[n].visible = show
			rails[n * 2].visible = show
			rails[n * 2 + 1].visible = show
			if not show:
				continue
			var x0 := _px(d, side)
			var x1 := _px(d + TS, side)
			var a := -atan2(x1 - x0, TS)
			ties[n].position = Vector3(x0, 0.08, -d)
			ties[n].rotation.y = a
			ties[n].material_override = m
			var mx := (x0 + x1) * 0.5
			for r in 2:
				var rl := rails[n * 2 + r]
				rl.position = Vector3(mx + (r * 2 - 1) * 0.55, 0.22, -d - TS * 0.5)
				rl.rotation.y = a
	# 옆 기둥: 속도가 보이도록
	var pb := floorf(dist / 10.0) * 10.0 - 10.0
	for k in 14:
		var d := pb + k * 10.0
		var par := int(d / 10.0) % 2
		posts[k * 2].position = Vector3(-5.8, 1.3, -d)
		posts[k * 2].material_override = m_post[par]
		posts[k * 2 + 1].position = Vector3(5.8, 1.3, -d - 5.0)
		posts[k * 2 + 1].material_override = m_post[2 + par]
	floor_m.position = Vector3(0, -0.1, -dist - 80.0)
	# 갈림길 그림
	var j0 := 0 if dist < JS0 else int(floorf((dist - JS0) / PER))
	for k in 4:
		var j := j0 + k
		var vi := j % 4
		var i := _j(j)
		var js := JS0 + j * PER
		var near := js - dist < 75.0 and js + JL > dist - 6.0
		var mid := js + JL * 0.5
		var bad := r_bad[i]
		bar_m[vi].visible = near and bad != 0 and r_kind[i] == 0
		bar_m[vi].position = Vector3(bad * W, 0.9, -mid - 0.5)
		for g in 2:
			var gm := gap_m[vi * 2 + g]
			gm.visible = near and bad != 0 and r_kind[i] == 1
			gm.position = Vector3(bad * W, 0.25, -(js + JL * (0.4 if g == 0 else 0.6)))
		var pm := pick_m[vi]
		pm.visible = near and r_pick[i] != 0 and r_st[i] < 2
		pm.position = Vector3(r_pick[i] * W, 1.2, -mid)
		pm.rotation.y = el * 3.0
		pm.rotation.x = el * 2.0
		if j == jn:
			flag_m.visible = near
			flag_m.position = Vector3(sel * W * _shape(0.25), 2.4, -(js + JL * 0.25))
	# 수레
	var take := 0
	if dist >= JS0 and fmod(dist - JS0, PER) < JL:
		take = r_take[_j(int(floorf((dist - JS0) / PER)))]
	var cx := _px(dist, take)
	var cx2 := _px(dist + 1.0, take)
	cart.position = Vector3(cx, 0.75, -dist)
	cart.rotation = Vector3(0, -atan2(cx2 - cx, 1.0), 0)
	cart_top.position = Vector3(cx, 1.3, -dist)
	cart_top.rotation = cart.rotation
	# 카메라: 빠를수록 넓게, 흔들리게
	var sh := clampf(spd / 80.0, 0.0, 1.0)
	cam.fov = lerpf(62.0, 100.0, sh)
	var jit := Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * 0.06 * sh
	cam.position = Vector3(cx * 0.6, 2.6, -dist + 5.0) + jit
	cam.look_at(Vector3(cx * 0.8, 0.6, -dist - 18.0))
