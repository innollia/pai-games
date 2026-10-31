extends Node
## 전투 이펙트 (10/31 파이가 보낸 이펙트 표, 시험 적용). 안 어울리면 ON 을 false 로 바꾸거나 이 파일(+.uid)을 지우고 빌드하면 예전 불꽃으로 돌아간다.
## 채도 낮은 붓 그림 느낌으로 통일:
## 칼 휘두르기 = 회백색 붓 터치 잔상, 적중 = 탁한 붉은색 + 흰 충격선, 막기 = 작은 황동색 불꽃,
## 간파 = 밝은 아이보리 + 금색 원형 충격파, 찌르기 적중 = 곧은 속도선 + 작게 모인 충격파.
## 화면 멈춤(60FPS 기준): 막기 3프레임, 적중 4프레임, 찌르기 5프레임, 간파 8프레임.

const ON := true

const BRUSH := Color("ece6d6")  # 회백색 붓 터치
const BLOOD := Color("9e3a33")  # 탁한 붉은색
const LINE := Color("fbf8f1")  # 흰 충격선
const BRASS := [Color("c9a45c"), Color("b5893a"), Color("e3cf9a")]  # 황동색 불꽃
const IVORY := Color("fff6df")
const GOLD := Color("d9ad48")
const F := 1.0 / 60.0

var g: Node  # 게임 (blade.gd)
var parts: Array = []  # 조각: {m, mat, t, life, delay, v, s0, s1, a0, grav}
var last := Transform3D()
var has_last := false
var _ring := TorusMesh.new()


func _init() -> void:
	_ring.inner_radius = 0.9
	_ring.outer_radius = 1.0
	_ring.rings = 32
	_ring.ring_segments = 4


## 매 프레임 (화면 멈춤 중엔 불리지 않아서 이펙트도 그 자리에 멈춰 보인다)
func tick(dt: float) -> void:
	for i in range(parts.size() - 1, -1, -1):
		var p: Dictionary = parts[i]
		var m: MeshInstance3D = p.m
		p.t += dt
		if p.t < p.delay:
			m.visible = false
			continue
		var k: float = (p.t - p.delay) / p.life
		if k >= 1.0 or not is_instance_valid(m):
			if is_instance_valid(m):
				m.queue_free()
			parts.remove_at(i)
			continue
		m.visible = true
		var e := 1.0 - (1.0 - k) * (1.0 - k)  # 처음에 빠르고 끝에 느리게
		m.scale = (p.s0 as Vector3).lerp(p.s1, e)
		p.v.y -= p.grav * dt
		m.position += p.v * dt
		var c: Color = p.mat.albedo_color
		c.a = p.a0 * (1.0 - k * k)
		p.mat.albedo_color = c


func _piece(mesh: Mesh, at: Vector3, rot_z: float, s0: Vector3, s1: Vector3, col: Color, life: float, delay := 0.0, v := Vector3.ZERO, grav := 0.0) -> Dictionary:
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.cull_mode = BaseMaterial3D.CULL_DISABLED
	sm.no_depth_test = true  # 몸·칼에 가려지지 않고 늘 위에 그린다
	sm.albedo_color = col
	var m := MeshInstance3D.new()
	m.mesh = mesh
	m.material_override = sm
	m.position = at
	m.rotation.z = rot_z
	m.scale = s0
	m.visible = delay <= 0.0
	g.world.add_child(m)
	var p := {"m": m, "mat": sm, "t": 0.0, "life": life, "delay": delay, "v": v, "s0": s0, "s1": s1, "a0": col.a, "grav": grav}
	parts.append(p)
	return p


func _stop(frames: int) -> void:
	g.hitstop = maxf(g.hitstop, frames * F)


## 적 칼이 몰아쳐 올 때 지나간 자리에 반투명 회백색 잔상. 빠를수록 길게 남는다.
func trail(b: MeshInstance3D, on: bool) -> void:
	if not on or b == null or not is_instance_valid(b):
		has_last = false
		return
	var now := b.global_transform
	if has_last:
		var d := now.origin.distance_to(last.origin)
		if d > 0.035:
			var n := mini(6, int(ceil(d / 0.1)))
			for i in n:
				var tr := last.interpolate_with(now, float(i + 1) / float(n))
				var p := _piece(g._unit, tr.origin, 0.0, tr.basis.get_scale() * Vector3(0.7, 1.0, 0.4), tr.basis.get_scale() * Vector3(0.15, 0.85, 0.2), Color(BRUSH, 0.5), 0.1 + minf(0.08, d * 0.25))
				p.m.basis = tr.basis.orthonormalized()
				p.m.scale = p.s0
	last = now
	has_last = true


## 내 베기: 빈틈 쪽(d)으로 긋는 붓 한 획. 맞으면 hit 도 같이, 빗나가면 잔상만.
func swing(at: Vector3, d: int) -> void:
	if d < 0:
		return
	var u: Vector3 = [Vector3.LEFT, Vector3.RIGHT, Vector3.UP, Vector3.DOWN][d]
	var pp := Vector3(-u.y, u.x, 0)
	var c := at + Vector3(0, 0, 0.6)
	var n := 16
	var prev := c - u * 1.5 + pp * 0.75
	for i in range(1, n + 1):
		var s := float(i) / float(n)
		# 빈틈 반대쪽 위에서 빈틈 쪽으로 둥글게 휘어 긋는다
		var q := c + u * lerpf(-1.5, 1.1, s) + pp * lerpf(0.75, -0.6, s) + (u - pp).normalized() * sin(PI * s) * 0.35
		var mid := (prev + q) * 0.5
		var dir := q - prev
		var w := 0.03 + 0.15 * pow(sin(PI * clampf(s - 0.05, 0.0, 1.0)), 0.7)  # 붓: 가운데 굵고 끝은 가늘게
		var rz := atan2(dir.y, dir.x) - PI / 2
		_piece(g._unit, mid, rz, Vector3(w, dir.length() * 1.35, 0.02), Vector3(w * 0.2, dir.length() * 1.35, 0.02), Color(BRUSH, 0.85), 0.15, s * 0.05)
		prev = q


## 적중: 탁한 붉은 자국 + 흰 충격선. thrust 면 찌른 방향으로 곧은 속도선과 작게 모인 충격파.
func hit(at: Vector3, thrust := Vector3.ZERO) -> void:
	var z := Vector3(0, 0, 0.3)
	if thrust != Vector3.ZERO:
		var t2 := Vector3(thrust.x, thrust.y, 0)
		if t2.length() < 0.2:
			t2 = Vector3(0, 1, 0)  # 화면 쪽으로 곧게 찌르면 세로 선으로
		t2 = t2.normalized()
		var pp := Vector3(-t2.y, t2.x, 0)
		var rz := atan2(t2.y, t2.x) - PI / 2
		for i in 9:
			var off := pp * randf_range(-0.45, 0.45) - t2 * randf_range(0.2, 1.2)
			_piece(g._unit, at + z + off, rz, Vector3(0.025, 0.9, 0.02), Vector3(0.0, 1.6, 0.02), Color(LINE, 0.9), randf_range(0.1, 0.15), 0.0, t2 * 6.0)
		_piece(_ring, at + z, 0.0, Vector3.ONE * 0.08, Vector3.ONE * 0.45, Color(LINE, 0.9), 0.12).m.rotation.x = PI / 2
		_piece(g._unit, at + z, PI / 4, Vector3.ONE * 0.2, Vector3(0.5, 0.5, 0.02), Color(BLOOD, 0.85), 0.13)
		_stop(5)
		return
	# 붉은 자국: 작은 덩이 몇 개가 짧게 번진다
	for i in 5:
		var a := randf() * TAU
		var r := Vector3(cos(a), sin(a), 0)
		_piece(g._unit, at + z + r * 0.1, a, Vector3(0.18, 0.18, 0.02), Vector3(0.45, 0.12, 0.02), Color(BLOOD, 0.85), randf_range(0.12, 0.18), 0.0, r * 2.5)
	# 흰 충격선: 가운데에서 바깥으로 뻗고 가늘어진다
	for i in 8:
		var a := TAU * i / 8.0 + randf_range(-0.2, 0.2)
		var r := Vector3(cos(a), sin(a), 0)
		_piece(g._unit, at + z + r * 0.35, a - PI / 2, Vector3(0.05, 0.25, 0.02), Vector3(0.0, 0.8, 0.02), Color(LINE, 0.95), randf_range(0.12, 0.16), 0.0, r * 5.0)
	_stop(4)


## 그냥 막기: 작은 황동색 불꽃
func block(at: Vector3) -> void:
	var z := Vector3(0, 0, 0.3)
	for i in 9:
		var v := Vector3(randf_range(-1, 1), randf_range(-0.5, 1.0), 0).normalized() * randf_range(3.0, 5.0)
		_piece(g._unit, at + z, randf() * TAU, Vector3.ONE * 0.08, Vector3.ONE * 0.02, Color(BRASS[i % 3], 1.0), randf_range(0.08, 0.12), 0.0, v, 10.0)
	_stop(3)


## 간파: 밝은 아이보리 + 금색 큰 원형 충격파, 금빛 불꽃
func parry(at: Vector3) -> void:
	var z := Vector3(0, 0, 0.3)
	_piece(_ring, at + z, 0.0, Vector3.ONE * 0.2, Vector3.ONE * 1.7, Color(IVORY, 0.95), 0.25).m.rotation.x = PI / 2
	_piece(_ring, at + z, 0.0, Vector3.ONE * 0.15, Vector3.ONE * 1.15, Color(GOLD, 0.9), 0.22, 0.03).m.rotation.x = PI / 2
	_piece(g._unit, at + z, PI / 4, Vector3(0.5, 0.5, 0.02), Vector3(0.05, 0.05, 0.02), Color(IVORY, 1.0), 0.18)
	for i in 16:
		var a := TAU * i / 16.0 + randf_range(-0.15, 0.15)
		var v := Vector3(cos(a), sin(a), 0) * randf_range(4.0, 7.0)
		_piece(g._unit, at + z, a, Vector3(0.12, 0.05, 0.02), Vector3(0.03, 0.02, 0.02), Color(GOLD if i % 2 else IVORY, 1.0), randf_range(0.18, 0.25), 0.0, v, 6.0)
	_stop(8)
