extends Tofu
## 도약 전도: 틱 소리 박자에 맞춰 탭하면 전기 신호가 다음 마디로 번쩍 뛴다(딱 맞으면 두 칸, 엇박이면 한 칸 뒤로).
## 신경 끝(초록)에 시간 안에 닿으면 다음 신경은 더 길고 박자가 빠르다. 시간이 다 되면 끝.

const SEG := 3.0
const OK_WIN := 0.13
const PERFECT_WIN := 0.05
const NODE := Vector3(0.8, 0.8, 0.4)
const GOAL := Vector3(2.2, 2.2, 1.0)

var lv := 0
var period := 0.6
var beat_t := 0.0
var used_beat := -999
var pulse := 0.0
var count := 0
var idx := 0
var lit := -1
var base_z := 0.0
var nerve_t := 0.0
var nerve_max := 1.0
var nerve: Node3D
var old: Node3D
var nodes: Array[MeshInstance3D] = []
var sig: MeshInstance3D
var streak: MeshInstance3D
var flash: MeshInstance3D
var from_z := 0.0
var to_z := 0.0
var leap_k := 1.0
var fx := 0.0
var hurt := 0.0
var cam_z := 0.0


func _reset() -> void:
	lv = 0
	idx = 0
	base_z = 0.0
	from_z = 0.0
	to_z = 0.0
	leap_k = 1.0
	fx = 0.0
	hurt = 0.0
	cam_z = 0.0
	nerve = null
	old = null
	sig = box(Vector3.ZERO, Vector3.ONE * 0.7, ME)
	streak = box(Vector3.ZERO, Vector3.ONE, WHITE)
	flash = box(Vector3.ZERO, Vector3.ONE, D)
	streak.visible = false
	flash.visible = false
	_build()
	beat_t = -period * 2.0  # 두 박 쉬고 시작
	used_beat = -999


## 신경 하나: 가운데 축삭(주황), 수초 마디(크림), 그 사이 결절(파랑), 끝(초록)
func _build() -> void:
	if old:
		old.queue_free()
	old = nerve
	nerve = Node3D.new()
	world.add_child(nerve)
	nodes.clear()
	lit = -1
	count = 8 + lv * 4
	period = 60.0 / (100.0 + lv * 12.0)
	nerve_max = count * period * 1.35 + 1.0
	nerve_t = nerve_max
	box(Vector3(0, 0, base_z - count * SEG * 0.5), Vector3(0.3, 0.3, count * SEG), A, nerve)
	for i in count:
		box(Vector3(0, 0, base_z - (i + 0.5) * SEG), Vector3(1.2, 1.2, SEG - 0.7), SOFT, nerve)
	for i in count + 1:
		var last := i == count
		nodes.append(box(Vector3(0, 0, base_z - i * SEG), GOAL if last else NODE, GOOD if last else B, nerve))


func _step(dt: float) -> void:
	nerve_t -= dt
	if nerve_t <= 0.0:
		nerve_t = 0.0
		msg("늦었다", 1.0)
		end()
		return
	var before := floori(beat_t / period)
	beat_t += dt
	var n := floori(beat_t / period)
	if n > before:
		pulse = 1.0
		beep(1500.0 if n % 4 == 0 else 1000.0, 0.03, 0.0, 0.25)
	pulse = maxf(pulse - dt * 5.0, 0.0)
	hurt = maxf(hurt - dt, 0.0)
	fx = maxf(fx - dt * 4.0, 0.0)
	leap_k = minf(leap_k + dt / 0.09, 1.0)
	var z := lerpf(from_z, to_z, 1.0 - pow(1.0 - leap_k, 3.0))
	var shake := sin(beat_t * 90.0) * 0.5 * hurt
	sig.position = Vector3(shake, 0, z)
	sig.scale = Vector3.ONE * (0.7 + 0.5 * pulse)
	sig.material_override = mat(BAD if hurt > 0.0 else ME)
	# 다음 결절이 박자에 맞춰 깜빡인다
	var want := mini(idx + 1, count)
	if want != lit:
		if lit >= 0 and lit < count:
			nodes[lit].material_override = mat(B)
			nodes[lit].scale = NODE
		lit = want
	var base := GOAL if lit == count else NODE
	nodes[lit].scale = base * (1.0 + 0.6 * pulse)
	if lit < count:
		nodes[lit].material_override = mat(WHITE if pulse > 0.5 else D)
	# 번쩍
	flash.visible = fx > 0.0
	streak.visible = fx > 0.0
	if fx > 0.0:
		flash.position = Vector3(0, 0, to_z)
		flash.scale = Vector3.ONE * (3.2 * fx)
		flash.material_override = mat(WHITE if fx > 0.6 else D)
		streak.scale = Vector3(0.5 * fx, 0.5 * fx, maxf(absf(to_z - from_z), 0.01))
	cam_z = lerpf(cam_z, z, 1.0 - exp(-dt * 9.0))
	cam.position = Vector3(0, 3.2, cam_z + 5.5)
	cam.look_at(Vector3(0, 0, cam_z - 6.0))
	cam.fov = 70.0 + 18.0 * fx
	var frac := nerve_t / nerve_max
	gauge(frac, GOOD if frac > 0.3 else BAD)


func _tap(_p: Vector2) -> void:
	if beat_t < -OK_WIN:  # 시작 전 두 박은 듣기만
		play("tap")
		return
	var n := roundi(beat_t / period)
	var err := absf(beat_t - n * period)
	if err <= OK_WIN and n != used_beat and n >= 0:
		used_beat = n
		_leap(2 if err <= PERFECT_WIN else 1, err <= PERFECT_WIN)
		return
	hurt = 0.3
	play("bad")
	msg("엇박", 0.4)
	if idx > 0:
		_move(idx - 1)


func _leap(step: int, perfect: bool) -> void:
	var ni := mini(idx + step, count)
	score += ni - idx
	_move(ni)
	fx = 1.0
	streak.position = Vector3(0, 0, (from_z + to_z) * 0.5)
	var f := 440.0 * pow(2.0, float(ni) / float(count))
	beep(f, 0.1, f * 1.5, 0.28)
	if perfect:
		msg("번쩍!", 0.35)
	if ni == count:
		_clear()


func _move(ni: int) -> void:
	from_z = sig.position.z
	to_z = base_z - ni * SEG
	leap_k = 0.0
	idx = ni


## 도착: 남은 초만큼 덤, 박자 위치는 그대로 이어서 더 빠른 다음 신경
func _clear() -> void:
	score += ceili(nerve_t)
	play("win")
	msg("도착!", 0.8)
	var off := beat_t - used_beat * period
	base_z = to_z
	lv += 1
	idx = 0
	_build()
	beat_t = off * period / (60.0 / (100.0 + (lv - 1) * 12.0))
	used_beat = 0
