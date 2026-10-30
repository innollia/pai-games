extends Tofu
## 예측 피하기(위에서 본 판). 왼손 조이스틱으로 파란 상자를 몬다. 기계가 내 움직임을 읽고 몇 초 뒤 내가 있을 자리에 표시를 찍고, 정확히 그때 터뜨린다.
## 뻔하게 움직이면 죽는다. 12초마다 새 예측(직진→회전→반전→멈춤·습관)이 붙고 예측 시간이 짧아지며, 잘 맞힌 예측일수록 더 자주 쏜다.

const AW := 5.0  # 판 반폭 (x)
const AH := 5.5  # 판 반높이 (z)
const VMAX := 6.5
const ACC := 28.0
const BLAST := 0.95  # 터지는 네모 반폭
const NEAR := 1.9  # 이 안에서 살아남으면 아슬
const STAGE_LEN := 12.0
const NPOOL := 12
const NHIST := 20  # 0.1초마다 위치 기록
const GX := 5
const GZ := 5
const MODEL_COL := [A, C, B, D, BAD]  # 직진, 회전, 반전, 멈춤, 습관
const STAGE_MSG := ["직진 예측", "회전 예측", "반전 예측", "멈춤·습관", "더 짧게", "더 짧게"]
const HORIZON := [2.0, 1.7, 1.45, 1.25, 1.05, 0.9]
const GAP := [1.15, 1.0, 1.0, 0.9, 0.8, 0.7]

var me: MeshInstance3D
var me_pos := Vector3.ZERO
var me_vel := Vector3.ZERO
var hist: Array[Vector3] = []  # 앞이 최신
var hist_t := 0.0
var omega := 0.0  # 도는 빠르기 (라디안/초)
var alive := 0.0
var nears := 0
var stage := 0
var shot_t := 0.0
var stop_cool := 0.0
var errs: Array[float] = []  # 예측마다 최근 빗나간 거리
var heat: Array[float] = []
var sp: Array[Vector3] = []
var st: Array[float] = []  # 남은 도화선 (<=0 꺼짐)
var sf: Array[float] = []
var sm: Array[int] = []
var sflash: Array[float] = []
var plate: Array[MeshInstance3D] = []
var fill: Array[MeshInstance3D] = []
var ghost: Array[MeshInstance3D] = []
var pillar: Array[MeshInstance3D] = []


func _setup() -> void:
	howto = "왼손 조이스틱으로 파란 상자를 몬다.\n기계가 내 움직임을 읽고 몇 초 뒤 내 자리에 표시를 찍고, 그때 정확히 터뜨린다.\n가만히·곧게·뻔하게 움직이면 맞는다. 맞으면 끝.\n버틴 초 + 아슬아슬 피한 수가 점수."
	time_limit = 0.0
	cam.fov = 60.0
	cam.position = Vector3(0, 10.7, 1.0)
	cam.rotation_degrees = Vector3(-90, 0, 0)
	kit_stick(Rect2(0, 930, 720, 350))


func _reset() -> void:
	box(Vector3(0, -0.1, 0), Vector3(AW * 2.0, 0.2, AH * 2.0), SOFT)
	for s in [-1.0, 1.0]:
		box(Vector3(s * (AW + 0.15), 0.2, 0), Vector3(0.3, 0.4, AH * 2.0 + 0.6), INK)
		box(Vector3(0, 0.2, s * (AH + 0.15)), Vector3(AW * 2.0 + 0.6, 0.4, 0.3), INK)
	plate.clear()
	fill.clear()
	ghost.clear()
	pillar.clear()
	sp.clear()
	st.clear()
	sf.clear()
	sm.clear()
	sflash.clear()
	for i in NPOOL:
		plate.append(box(Vector3.ZERO, Vector3(BLAST * 2.0, 0.04, BLAST * 2.0), WHITE))
		fill.append(box(Vector3.ZERO, Vector3(0.1, 0.06, 0.1), A))
		ghost.append(box(Vector3.ZERO, Vector3(0.5, 0.5, 0.5), ME.lightened(0.55)))
		pillar.append(box(Vector3.ZERO, Vector3(BLAST * 2.0, 2.0, BLAST * 2.0), BAD))
		plate[i].visible = false
		fill[i].visible = false
		ghost[i].visible = false
		pillar[i].visible = false
		sp.append(Vector3.ZERO)
		st.append(0.0)
		sf.append(1.0)
		sm.append(0)
		sflash.append(0.0)
	me_pos = Vector3.ZERO
	me_vel = Vector3.ZERO
	me = box(Vector3(0, 0.4, 0), Vector3(0.8, 0.8, 0.8), ME)
	hist.clear()
	for i in NHIST:
		hist.append(Vector3.ZERO)
	hist_t = 0.1
	omega = 0.0
	alive = 0.0
	nears = 0
	stage = 0
	shot_t = 1.5
	stop_cool = 0.0
	errs.clear()
	for i in 5:
		errs.append(3.0)
	heat.clear()
	for i in GX * GZ:
		heat.append(0.0)
	msg(STAGE_MSG[0], 1.2)


func _step(dt: float) -> void:
	alive += dt
	score = int(alive) + nears * 3
	# 이동 (관성이 있어 꺾는 데 시간이 든다)
	var want := Vector3(kit_move.x, 0, kit_move.y) * VMAX
	me_vel = me_vel.move_toward(want, ACC * dt)
	me_pos += me_vel * dt
	if absf(me_pos.x) > AW - 0.4:
		me_pos.x = clampf(me_pos.x, -AW + 0.4, AW - 0.4)
		me_vel.x = 0.0
	if absf(me_pos.z) > AH - 0.4:
		me_pos.z = clampf(me_pos.z, -AH + 0.4, AH - 0.4)
		me_vel.z = 0.0
	me.position = me_pos + Vector3(0, 0.4, 0)
	var spd := me_vel.length()
	var lean := spd / VMAX
	me.scale = Vector3(0.8 + lean * 0.15, 0.8 - lean * 0.2, 0.8 + lean * 0.15)
	# 기록: 위치, 도는 빠르기, 오래 머문 칸
	hist_t -= dt
	if hist_t <= 0.0:
		hist_t += 0.1
		hist.pop_back()
		hist.push_front(me_pos)
		var v1 := (hist[0] - hist[3]) / 0.3
		var v0 := (hist[3] - hist[6]) / 0.3
		if v1.length() > 0.8 and v0.length() > 0.8:
			omega = lerpf(omega, v0.signed_angle_to(v1, Vector3.UP) / 0.3, 0.5)
		else:
			omega = lerpf(omega, 0.0, 0.5)
	for i in heat.size():
		heat[i] -= heat[i] * 0.12 * dt
	heat[_cell(me_pos)] += dt
	# 단계
	var ns := mini(int(alive / STAGE_LEN), HORIZON.size() - 1)
	if ns != stage:
		stage = ns
		msg(STAGE_MSG[stage], 1.2)
		beep(440.0, 0.25, 880.0, 0.25)
	# 쏘기
	shot_t -= dt
	if shot_t <= 0.0:
		shot_t = GAP[stage]
		var pool: Array[int] = [0]
		if stage >= 1:
			pool.append(1)
		if stage >= 2:
			pool.append(2)
		if stage >= 3:
			pool.append(4)
		var first := _pick(pool, -1)
		_shoot(first)
		if stage >= 2:
			_shoot(_pick(pool, first))
	# 멈춤 예측: 느려지는 순간 지금 자리에 짧은 도화선
	if stage >= 3:
		stop_cool -= dt
		if spd < 1.2 and stop_cool <= 0.0:
			_spawn(me_pos, 0.75, 3)
			stop_cool = 1.6
	# 표시와 터짐
	for i in NPOOL:
		if st[i] > 0.0:
			st[i] -= dt
			var k := 1.0 - st[i] / sf[i]
			fill[i].scale = Vector3(BLAST * 2.0 * k + 0.05, 0.06, BLAST * 2.0 * k + 0.05)
			ghost[i].position = sp[i] + Vector3(0, 0.35 + sin(k * 18.0) * 0.08, 0)
			if st[i] <= 0.0:
				_boom(i)
				if over:
					return
		if sflash[i] > 0.0:
			sflash[i] -= dt
			if sflash[i] <= 0.0:
				pillar[i].visible = false
	# 막대 = 기계가 나를 얼마나 잘 읽고 있나
	var best_err := 99.0
	for m in 5:
		if _unlocked(m):
			best_err = minf(best_err, errs[m])
	gauge(1.0 - best_err / 3.5, BAD)


func _unlocked(m: int) -> bool:
	match m:
		0: return true
		1: return stage >= 1
		2: return stage >= 2
	return stage >= 3


## 잘 맞히는 예측일수록 자주 뽑힌다
func _pick(pool: Array[int], skip: int) -> int:
	var total := 0.0
	for m in pool:
		if m != skip:
			total += 1.0 / (errs[m] + 0.4)
	var r := randf() * total
	for m in pool:
		if m == skip:
			continue
		r -= 1.0 / (errs[m] + 0.4)
		if r <= 0.0:
			return m
	return pool[0]


func _vel(span: float) -> Vector3:
	var k := int(span / 0.1)
	return (hist[0] - hist[k]) / (k * 0.1)


func _predict(m: int, h: float) -> Vector3:
	var v := _vel(0.5)
	var p := me_pos
	match m:
		0:  # 지금 빠르기 그대로 곧게
			p = me_pos + v * h
		1:  # 지금 도는 대로 계속 돈다
			var vv := v
			for k in 8:
				vv = vv.rotated(Vector3.UP, omega * h / 8.0)
				p += vv * (h / 8.0)
		2:  # 되돌아올 거라고 본다
			p = me_pos - v * h * 0.7
		4:  # 제일 오래 머문 칸
			var bi := 0
			for i in heat.size():
				if heat[i] > heat[bi]:
					bi = i
			p = Vector3(-AW + (bi % GX + 0.5) * AW * 2.0 / GX, 0, -AH + (bi / GX + 0.5) * AH * 2.0 / GZ)
	p.x = clampf(p.x, -AW + 0.5, AW - 0.5)
	p.z = clampf(p.z, -AH + 0.5, AH - 0.5)
	p.y = 0.0
	return p


func _cell(p: Vector3) -> int:
	var cx := clampi(int((p.x + AW) / (AW * 2.0) * GX), 0, GX - 1)
	var cz := clampi(int((p.z + AH) / (AH * 2.0) * GZ), 0, GZ - 1)
	return cz * GX + cx


func _shoot(m: int) -> void:
	var h: float = HORIZON[stage]
	_spawn(_predict(m, h), h, m)


func _spawn(p: Vector3, fuse: float, m: int) -> void:
	for i in NPOOL:
		if st[i] <= 0.0 and sflash[i] <= 0.0:
			sp[i] = p
			st[i] = fuse
			sf[i] = fuse
			sm[i] = m
			var col: Color = MODEL_COL[m]
			plate[i].material_override = mat(col.lightened(0.6))
			fill[i].material_override = mat(col)
			plate[i].position = p + Vector3(0, 0.02, 0)
			fill[i].position = p + Vector3(0, 0.05, 0)
			fill[i].scale = Vector3(0.05, 0.06, 0.05)
			plate[i].visible = true
			fill[i].visible = true
			ghost[i].visible = true
			beep(330.0 + m * 110.0, 0.06, 0.0, 0.14)
			return


func _boom(i: int) -> void:
	plate[i].visible = false
	fill[i].visible = false
	ghost[i].visible = false
	pillar[i].position = sp[i] + Vector3(0, 1.0, 0)
	pillar[i].visible = true
	sflash[i] = 0.18
	var dx := absf(sp[i].x - me_pos.x)
	var dz := absf(sp[i].z - me_pos.z)
	var d := maxf(dx, dz)
	errs[sm[i]] = lerpf(errs[sm[i]], Vector2(dx, dz).length(), 0.35)
	if d < BLAST + 0.15:
		me.material_override = mat(BAD)
		msg("읽혔다", 1.0)
		end()
	elif d < NEAR:
		nears += 1
		play("good")
		msg("아슬!", 0.4)
	else:
		beep(150.0, 0.1, 70.0, 0.2)
