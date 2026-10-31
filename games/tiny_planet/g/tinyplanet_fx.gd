extends Node
## 어린 배달부 v8 연출 (처음 v5에 만듦) — 속도감·연출 (submit/tinyplanet/MODULES.md 약속).
## 본체는 setup(game) 한 번, set_bodies(...) 한 번, 매 프레임 tick(dt, s), 일이 생기면 event(name, d)만 부른다.
## 화면 겹 그림(속도선·번쩍·테두리 빛·비네트)은 CanvasLayer 0(HUD 아래), 3D 효과는 이 노드 밑 FxRoot(본체 world 밖 = restart 에도 안 지워짐).
## 카메라는 fov 와 h_offset/v_offset 만 쓴다(본체 위치 계산과 안 싸움). time_scale 은 escape 때만 바꾸고 반드시 1로 되돌린다.

# ---- 디자인 시스템 (tinyplanet_ui.gd DS 와 같은 값) ----
const CREAM := Color("fff6e6")
const INK2 := Color("2b2d42")
const SKY := Color("9fd3ff")
const MINT := Color("8fe3c2")
const LAV := Color("b9a7f2")
const YEL := Color("ffd166")
const RED := Color("e8453c")

const N_LINES := 40
const N_TRAIL := 20
const N_STARS := 40
const STAR_BOX := 42.0  # 별 줄무늬가 나를 감싸는 상자 반쪽 크기
const FOV_LIFT := 18.0
const FOV_MAX := 112.0
const ESC_REAL := 0.9  # 대표 장면 길이(실제 초)
const ESC_SCALE := 0.35
const ESC_FOV := 34.0
const FLASH_DUR := 0.08  # v7: 흰 번쩍임은 없앴다 (값만 남김)
const SHAKE_DUR := 0.45  # v7: 짧고 덜컹이던 흔들림 → 조금 길고 작고 부드럽게 (사인 두 개, 끝으로 갈수록 잦아듦)

## 본체가 바꿀 수 있는 것
var base_fov := 60.0
var own_fov := true  # false면 fov 를 안 건드림 (escape 당김도 꺼짐)
## 폰 웹이면 가볍게: 속도선·조각·구름·꼬리·별 줄무늬를 반으로 (setup 전에 바꾸면 그 값으로)
## (웹 폰은 "mobile" 대신 web_android/web_ios 만 켜지는 판도 있어 셋 다 본다)
var low: bool = OS.has_feature("web") and (OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"))

var game: Node
var cam: Camera3D
var _root: Node3D
var _layer: CanvasLayer
var _ov: Control
var _rng := RandomNumberGenerator.new()

# ---- tick 으로 받은 지금 상태 ----
var _have := false
var _speed := 0.0
var _top := 12.5
var _lift := 0.0
var _grounded := true
var _flying := false
var _paused := false
var _pos := Vector3.ZERO
var _vel := Vector3.ZERO
var _up := Vector3.UP
var _fwd := Vector3.FORWARD
var _sky := SKY

# ---- 화면 겹 그림 ----
var _ln_a := PackedFloat32Array()
var _ln_t := PackedFloat32Array()
var _ln_v := PackedFloat32Array()
var _ln_w := PackedFloat32Array()
var _lines_k := 0.0
var _burst_k := 0.0
var _flash := 0.0
var _flash_a := 0.8
var _shake := 0.0
var _shake_amp := 0.0
var _shake_ph := 0.0
var _shake_seed := 0.0
var _atmo_t := 0.0
var _atmo_c := SKY
var _gold_t := 0.0
var _red_t := 0.0
var _dusk := 0.0  # 우주 미아: 화면 가장자리가 천천히 어둑해진다 (0~1)
var _dusk_hold := 0.0
var _vig := 0.0
var _q0 := PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
var _q1 := PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
var _q2 := PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
var _q3 := PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
var _qc := PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE])
var _no_uv := PackedVector2Array()
var _drew := false
# 품질에 따라 정해지는 개수 (setup 에서)
var _n_lines := N_LINES
var _n_trail := N_TRAIL
var _n_stars := N_STARS
var _tr_gap := 0.03  # 꼬리 점 사이 시간 (점이 반이면 두 배 → 꼬리 길이 같음)
var _aa := true  # 속도선 안티에일리어스: 웹에선 선마다 폴리곤 버퍼를 새로 만들어 끈다

# ---- 대표 장면 (escape) ----
var _esc_t := -1.0
var _esc_fov := 0.0
var _esc_hold := 0.0
var _esc_burst := false
var _fov_cur := 60.0

# ---- 3D ----
var _dust: CPUParticles3D
var _puff: CPUParticles3D
var _bursts: Array[CPUParticles3D] = []
var _burst_i := 0
var _grad_good: Gradient
var _grad_hit: Gradient
var _trail: MultiMeshInstance3D
var _tr := PackedVector3Array()
var _tr_head := 0
var _tr_clock := 0.0
var _trail_k := 0.0
var _stars: MultiMeshInstance3D
var _st_p := PackedVector3Array()
var _streak_k := 0.0
var _clouds: MultiMeshInstance3D
var _bc := PackedVector3Array()
var _br := PackedFloat32Array()
var _cl_b := PackedInt32Array()
var _cl_ax := PackedVector3Array()
var _cl_ref := PackedVector3Array()
var _cl_r := PackedFloat32Array()
var _cl_w := PackedFloat32Array()
var _cl_ang := PackedFloat32Array()
var _pf_c := PackedInt32Array()
var _pf_o := PackedVector3Array()
var _pf_s := PackedFloat32Array()
var _pf_v := PackedFloat32Array()
var _cl_p0 := PackedInt32Array()  # 구름마다 첫 조각 번호
var _cl_pn := PackedInt32Array()  # 구름마다 조각 수
var _cl_s := PackedFloat32Array()  # 구름마다 큰 조각 크기 (통째 가림 검사용)
var _cl_groups := 2  # 구름을 몇 무리로 나눠 한 프레임에 한 무리만 고치나
var _cl_frame := 0
var _cl_clock := 0.0
var _cl_last := PackedFloat32Array()
## ?debug=1 성능 표: 본체가 켜면 _process 안 구름·겹 그림 시간(usec)을 남긴다
var dbg := false
var dbg_cl := 0
var dbg_ov := 0


func setup(g: Node) -> void:
	game = g
	cam = g.get("cam") as Camera3D
	_fov_cur = base_fov
	_rng.seed = 51207
	_aa = not OS.has_feature("web")
	if low:
		_n_lines = int(N_LINES * 0.5)
		_n_trail = int(N_TRAIL * 0.5)
		_n_stars = int(N_STARS * 0.5)
		_tr_gap = 0.06
		_cl_groups = 3
	_root = Node3D.new()
	_root.name = "FxRoot"
	add_child(_root)
	_layer = CanvasLayer.new()
	_layer.layer = 0  # HUD(1)·UI 카드 아래, 3D 위
	add_child(_layer)
	_ov = Control.new()
	_ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(_ov)
	_ov.draw.connect(_on_draw)
	_ln_a.resize(N_LINES)
	_ln_t.resize(N_LINES)
	_ln_v.resize(N_LINES)
	_ln_w.resize(N_LINES)
	for i in N_LINES:
		_ln_a[i] = _rng.randf() * TAU
		_ln_t[i] = _rng.randf()
		_ln_v[i] = _rng.randf_range(0.7, 1.4)
		_ln_w[i] = _rng.randf_range(2.0, 5.0)
	_make_particles()
	_make_trail()
	_make_stars()


## 별 가운데·반지름을 한 번 받는다 (구름 자리, 별 줄무늬 판정). 반지름 <= 0 인 별은 구름 없음(불 별 등).
func set_bodies(centers: PackedVector3Array, radii: PackedFloat32Array) -> void:
	_bc = centers.duplicate()
	_br = radii.duplicate()
	_cl_b.clear()
	_cl_ax.clear()
	_cl_ref.clear()
	_cl_r.clear()
	_cl_w.clear()
	_cl_ang.clear()
	_pf_c.clear()
	_pf_o.clear()
	_pf_s.clear()
	_pf_v.clear()
	_cl_p0.clear()
	_cl_pn.clear()
	_cl_s.clear()
	var n := mini(_bc.size(), _br.size())
	for b in n:
		var r: float = _br[b]
		if r <= 0.0:
			continue
		var nc := 3 if r < 5.0 else (4 if r < 9.0 else 5)
		if low:
			nc = 2 if r < 9.0 else 3
		var sgn := 1.0 if _rng.randf() < 0.5 else -1.0
		for k in nc:
			var ax := _rand_unit()
			var ref := ax.cross(_rand_unit())
			if ref.length() < 0.05:
				ref = ax.cross(Vector3.RIGHT if absf(ax.x) < 0.9 else Vector3.UP)
			ref = ref.normalized()
			var ci := _cl_b.size()
			_cl_b.append(b)
			_cl_ax.append(ax)
			_cl_ref.append(ref)
			_cl_r.append(r + maxf(2.4, r * 0.5) + _rng.randf() * r * 0.25)
			_cl_w.append(sgn * _rng.randf_range(0.04, 0.09))
			_cl_ang.append(_rng.randf() * TAU)
			var s := clampf(r * 0.2, 0.8, 2.6)
			_cl_p0.append(_pf_c.size())
			_cl_s.append(s)
			_add_puff(ci, Vector3.ZERO, s)
			_add_puff(ci, Vector3(s * 1.05, -s * 0.18, _rng.randf_range(-0.3, 0.3) * s), s * 0.74)
			_add_puff(ci, Vector3(-s * 0.95, -s * 0.22, _rng.randf_range(-0.3, 0.3) * s), s * 0.68)
			if r >= 6.0 and not low:
				_add_puff(ci, Vector3(s * 0.35, s * 0.5, 0.0), s * 0.62)
			_cl_pn.append(_pf_c.size() - _cl_p0[ci])
	if _clouds:
		_clouds.queue_free()
		_clouds = null
	if _pf_c.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _lowpoly(7, 4, 1.0) if low else _lowpoly(9, 5, 1.0)
	mm.instance_count = _pf_c.size()
	_clouds = MultiMeshInstance3D.new()
	_clouds.multimesh = mm
	var m := _toon(CREAM)
	m.emission_enabled = true
	m.emission = SKY * 0.22
	if low:
		m.disable_receive_shadows = true
	# 외곽선은 뺀다: 멀티메시 + 늘린 기저에서 외곽선 껍질이 부풀어 웹에서 검은 덩어리로 보였다
	_clouds.material_override = m
	_clouds.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_root.add_child(_clouds)
	_cl_last.resize(_cl_groups)
	_cl_last.fill(_cl_clock)
	_clouds_update(0, 1, 0.0)  # 처음엔 전부 한 번


func _add_puff(ci: int, o: Vector3, s: float) -> void:
	_pf_c.append(ci)
	_pf_o.append(o)
	_pf_s.append(s)
	_pf_v.append(1.0)


func _rand_unit() -> Vector3:
	var v := Vector3(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1), _rng.randf_range(-1, 1))
	if v.length() < 0.05:
		return Vector3.UP
	return v.normalized()


# ---- 재료·모양 ----
## 각진 공 (면마다 평평한 노멀 = 로우폴리)
func _lowpoly(radial: int, rings: int, r: float) -> ArrayMesh:
	var sm := SphereMesh.new()
	sm.radial_segments = radial
	sm.rings = rings
	sm.radius = r
	sm.height = r * 2.0
	var arr := sm.get_mesh_arrays()
	var vs: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var ix: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var i := 0
	while i + 2 < ix.size():
		var a: Vector3 = vs[ix[i]]
		var b: Vector3 = vs[ix[i + 1]]
		var c: Vector3 = vs[ix[i + 2]]
		i += 3
		var nrm := (b - a).cross(c - a)
		if nrm.length() < 0.000001:
			continue
		nrm = nrm.normalized()
		if nrm.dot(a + b + c) < 0.0:
			nrm = -nrm
		st.set_normal(nrm)
		st.add_vertex(a)
		st.set_normal(nrm)
		st.add_vertex(b)
		st.set_normal(nrm)
		st.add_vertex(c)
	return st.commit()


func _toon(col: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	m.roughness = 1.0
	return m


func _flat(col: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _scale_curve() -> Curve:
	var c := Curve.new()
	c.add_point(Vector2(0.0, 1.0))
	c.add_point(Vector2(0.6, 0.85))
	c.add_point(Vector2(1.0, 0.0))
	return c


func _ramp(c0: Color, c1: Color, c2: Color) -> Gradient:
	var g := Gradient.new()
	g.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	g.offsets = PackedFloat32Array([0.0, 0.45, 0.8])
	g.colors = PackedColorArray([c0, c1, c2])
	return g


func _parts(mesh: Mesh, m: Material, amount: int, life: float) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.mesh = mesh
	p.material_override = m
	p.amount = maxi(4, int(amount * 0.5)) if low else amount
	p.lifetime = life
	p.local_coords = false
	p.scale_amount_curve = _scale_curve()
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.emitting = false
	_root.add_child(p)
	return p


func _make_particles() -> void:
	var chunk := _lowpoly(4, 2, 0.5)
	var vm := _toon(Color.WHITE)
	vm.vertex_color_use_as_albedo = true
	vm.disable_receive_shadows = true  # 작은 조각엔 그림자 받기 필요 없음 (조각마다 그림자 샘플 아낌)
	# 발 먼지: 땅에서 빠를 때 발뒤로 크림색 조각
	_dust = _parts(chunk, vm, 26, 0.5)
	_dust.direction = Vector3(0.0, 0.7, 1.0)
	_dust.spread = 30.0
	_dust.initial_velocity_min = 1.6
	_dust.initial_velocity_max = 3.2
	_dust.damping_min = 2.0
	_dust.damping_max = 3.0
	_dust.scale_amount_min = 0.14
	_dust.scale_amount_max = 0.28
	_dust.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	_dust.emission_sphere_radius = 0.15
	_dust.color = CREAM
	# 발밑 고리 먼지 (뜨기·내려앉기)
	_puff = _parts(chunk, vm, 16, 0.55)
	_puff.one_shot = true
	_puff.explosiveness = 1.0
	_puff.direction = Vector3.UP
	_puff.spread = 85.0
	_puff.flatness = 0.85
	_puff.initial_velocity_min = 2.5
	_puff.initial_velocity_max = 4.5
	_puff.damping_min = 6.0
	_puff.damping_max = 8.0
	_puff.scale_amount_min = 0.18
	_puff.scale_amount_max = 0.34
	_puff.color = CREAM
	# 터짐 (성공 = 노랑·민트, 아픔 = 빨강·크림) 셋을 돌려 쓴다
	_grad_good = _ramp(YEL, MINT, CREAM)
	_grad_hit = _ramp(RED, CREAM, RED)
	for i in 3:
		var b := _parts(chunk, vm, 30, 0.9)
		b.one_shot = true
		b.explosiveness = 1.0
		b.direction = Vector3.UP
		b.spread = 180.0
		b.initial_velocity_min = 5.0
		b.initial_velocity_max = 9.0
		b.damping_min = 5.0
		b.damping_max = 7.0
		b.scale_amount_min = 0.25
		b.scale_amount_max = 0.45
		b.angular_velocity_min = -360.0
		b.angular_velocity_max = 360.0
		b.particle_flag_rotate_y = true
		b.color_initial_ramp = _grad_good
		_bursts.append(b)


func _make_trail() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = _lowpoly(6, 3, 1.0)
	mm.instance_count = _n_trail
	for i in _n_trail:
		mm.set_instance_color(i, YEL.lerp(CREAM, float(i) / float(_n_trail)))
	_trail = MultiMeshInstance3D.new()
	_trail.multimesh = mm
	var m := _flat(Color.WHITE)
	m.vertex_color_use_as_albedo = true
	_trail.material_override = m
	_trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_trail.visible = false
	_root.add_child(_trail)
	_tr.resize(_n_trail)


func _make_stars() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var bm := BoxMesh.new()
	bm.size = Vector3(0.12, 0.12, 1.0)
	mm.mesh = bm
	mm.instance_count = _n_stars
	for i in _n_stars:
		mm.set_instance_color(i, YEL if i % 3 == 0 else CREAM)
	_stars = MultiMeshInstance3D.new()
	_stars.multimesh = mm
	var m := _flat(Color.WHITE)
	m.vertex_color_use_as_albedo = true
	_stars.material_override = m
	_stars.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_stars.visible = false
	_root.add_child(_stars)
	_st_p.resize(_n_stars)


# ---- 매 프레임 ----
## 본체 _step 끝에서. s 키는 MODULES.md 참고
func tick(dt: float, s: Dictionary) -> void:
	_have = true
	_speed = float(s.get("speed", 0.0))
	_top = maxf(0.1, float(s.get("top", 12.5)))
	_lift = float(s.get("lift", 0.0))
	_grounded = bool(s.get("grounded", true))
	_flying = bool(s.get("flying", false))
	_paused = bool(s.get("paused", false))
	var p: Vector3 = s.get("pos", _pos)
	var v: Vector3 = s.get("vel", _vel)
	var u: Vector3 = s.get("up", _up)
	var f: Vector3 = s.get("fwd", _fwd)
	var sk: Color = s.get("sky", _sky)
	_pos = p
	_vel = v
	_up = u.normalized() if u.length() > 0.01 else Vector3.UP
	_fwd = f
	_sky = sk
	if _atmo_t > 0.0:
		_atmo_c = _sky
	_dust_step()
	_trail_step(dt)
	_stars_step(dt)


func _process(delta: float) -> void:
	if game == null:
		return
	var rdt := delta / maxf(Engine.time_scale, 0.05)  # 실제 시간 (느린 장면에서도)
	if _esc_t >= 0.0:
		var ov: Variant = game.get("over")
		if ov is bool and ov:
			_end_slowmo()
		else:
			_esc_step(rdt)
	var t0 := Time.get_ticks_usec() if dbg else 0
	_clouds_step(delta)
	if dbg:
		var t1 := Time.get_ticks_usec()
		dbg_cl += t1 - t0
		t0 = t1
	_overlay_step(rdt)
	if dbg:
		dbg_ov += Time.get_ticks_usec() - t0
	_cam_step(rdt)


func _cam_step(rdt: float) -> void:
	if cam == null or not is_instance_valid(cam):
		return
	if own_fov:
		var tgt := base_fov
		if _have and not _paused:
			tgt += FOV_LIFT * clampf(_lift, 0.0, 1.0)
		_fov_cur = lerpf(_fov_cur, tgt, minf(1.0, rdt * 3.0))
		var fv := minf(FOV_MAX, _fov_cur + _esc_fov)
		if absf(cam.fov - fv) > 0.005:  # 그대로면 투영 다시 계산 안 함
			cam.fov = fv
	if _shake > 0.0:
		_shake -= rdt
		_shake_ph += rdt
		var k := maxf(_shake, 0.0) / SHAKE_DUR
		var a := _shake_amp * k * k * (3.0 - 2.0 * k)  # 부드럽게 잦아듦 (덜컹임 없음)
		cam.h_offset = sin(_shake_ph * 34.0 + _shake_seed) * a
		cam.v_offset = sin(_shake_ph * 27.0 + _shake_seed * 1.7) * a * 0.8
		if _shake <= 0.0:
			cam.h_offset = 0.0
			cam.v_offset = 0.0
			_shake_amp = 0.0


func _basis_up(up: Vector3) -> Basis:
	var z := up.cross(Vector3.RIGHT)
	if z.length() < 0.1:
		z = up.cross(Vector3.FORWARD)
	z = z.normalized()
	return Basis(up.cross(z).normalized(), up, z)


func _dust_step() -> void:
	var r := _speed / _top
	var on: bool = _grounded and not _paused and r > 0.45
	if on:
		var z := -_fwd
		z = z - _up * z.dot(_up)
		if z.length() < 0.01:
			z = _up.cross(Vector3.RIGHT)
		z = z.normalized()
		var x := _up.cross(z).normalized()
		_dust.global_transform = Transform3D(Basis(x, _up, z), _pos + z * 0.3 + _up * 0.08)
		_dust.gravity = -_up * 7.0
		_dust.initial_velocity_max = 2.0 + 2.5 * clampf(r, 0.0, 1.3)
	if _dust.emitting != on:
		_dust.emitting = on


func _trail_fill() -> void:
	var hp := _pos + _up * 0.7
	for i in _n_trail:
		_tr[i] = hp


func _trail_step(dt: float) -> void:
	var want := 1.0 if (_flying and not _grounded) else 0.0
	_trail_k = move_toward(_trail_k, want, dt * (4.0 if want > 0.0 else 2.5))
	if _trail_k <= 0.01:
		if _trail.visible:
			_trail.visible = false
		return
	if not _trail.visible:
		_trail.visible = true
	_tr_clock += dt
	if want > 0.0 and _tr_clock >= _tr_gap:
		_tr_clock = 0.0
		_tr_head = (_tr_head + 1) % _n_trail
		_tr[_tr_head] = _pos + _up * 0.7
	var cp := cam.global_position if cam else Vector3(0, 9999, 0)
	var mm := _trail.multimesh
	var nt := _n_trail
	var inv := 1.0 / float(nt)
	var k0 := 0.24 * _trail_k
	for i in nt:
		var wp: Vector3 = _tr[(_tr_head - i + nt) % nt]
		var sz := k0 * (1.0 - float(i) * inv)
		if wp.distance_squared_to(cp) < 6.25:
			sz = 0.0
		mm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * maxf(sz, 0.001)), wp))


## 영향권 밖을 날 때: 멀리 작은 별이 속도 반대로 길게 (나를 둘러싼 상자 안에서 감아 돈다)
func _stars_step(dt: float) -> void:
	var want := 0.0
	if _flying and not _grounded and not _paused:  # 별까지 거리는 날 때만 잰다
		var far := 99.0
		for b in mini(_bc.size(), _br.size()):
			var r: float = _br[b]
			if r > 0.0:
				far = minf(far, _pos.distance_to(_bc[b]) / r)
		want = clampf((far - 2.1) / 0.8, 0.0, 1.0) * clampf(_speed / _top, 0.3, 1.0)
	_streak_k = move_toward(_streak_k, want, dt * 2.0)
	if _streak_k <= 0.01:
		if _stars.visible:
			_stars.visible = false
		return
	if not _stars.visible:
		_stars.visible = true
		for i in _n_stars:
			_st_p[i] = _pos + Vector3(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1), _rng.randf_range(-1, 1)) * STAR_BOX
	var vd := _vel.normalized() if _speed > 0.5 else _fwd.normalized()
	if vd.length() < 0.5:
		vd = Vector3.FORWARD
	var upr := _up
	if absf(vd.dot(upr)) > 0.95:
		upr = Vector3.RIGHT if absf(vd.x) < 0.9 else Vector3.UP
	var bas := Basis.looking_at(vd, upr)
	var ln := (0.4 + _speed * 0.35) * _streak_k
	var w := _streak_k
	var cp := cam.global_position if cam else _pos
	var mm := _stars.multimesh
	var bx := STAR_BOX * 2.0
	# 보이는 별/숨긴 별 기저 두 개만 미리 만든다
	var b_on := Basis(bas.x * maxf(w, 0.001), bas.y * maxf(w, 0.001), bas.z * maxf(ln, 0.001))
	var b_off := Basis.from_scale(Vector3.ONE * 0.001)
	for i in _n_stars:
		var rel: Vector3 = _st_p[i] - _pos
		rel = Vector3(fposmod(rel.x + STAR_BOX, bx) - STAR_BOX, fposmod(rel.y + STAR_BOX, bx) - STAR_BOX, fposmod(rel.z + STAR_BOX, bx) - STAR_BOX)
		var wp := _pos + rel
		_st_p[i] = wp
		var off := rel.length_squared() < 144.0 or wp.distance_squared_to(cp) < 81.0
		mm.set_instance_transform(i, Transform3D(b_off if off else b_on, wp))


## 별마다 큰 흰 로우폴리 구름이 천천히 돈다. 카메라와 나 사이를 막거나 카메라에 너무 가까우면 쏙 줄어든다
## 구름은 아주 천천히 돌아서(초당 0.04~0.09 rad) 매 프레임 다 고칠 필요가 없다:
## _cl_groups 무리로 나눠 한 프레임에 한 무리만, 그 무리가 쉰 시간만큼 한꺼번에 돌린다 (튀는 프레임 없이 고르게)
func _clouds_step(dt: float) -> void:
	if _clouds == null:
		return
	_cl_clock += dt
	var g := _cl_frame % _cl_groups
	_cl_frame += 1
	var gdt: float = _cl_clock - _cl_last[g]
	_cl_last[g] = _cl_clock
	_clouds_update(g, _cl_groups, gdt)


func _clouds_update(first: int, stride: int, dt: float) -> void:
	var has_cam := cam != null and is_instance_valid(cam)
	var cp := cam.global_position if has_cam else Vector3(0, 9999, 0)
	var seg := _pos - cp
	var sl2 := maxf(seg.length_squared(), 0.0001)
	var test_seg := has_cam and _have
	var fade := dt * 3.0
	var mm := _clouds.multimesh
	var nc := _cl_ang.size()
	var ci := first
	while ci < nc:
		var ang: float = _cl_ang[ci] + _cl_w[ci] * dt
		_cl_ang[ci] = ang
		var ax: Vector3 = _cl_ax[ci]
		var dir: Vector3 = _cl_ref[ci].rotated(ax, ang)
		var tg := ax.cross(dir)
		var ctr: Vector3 = _bc[_cl_b[ci]]
		var cc := ctr + dir * _cl_r[ci]
		# 구름 통째로 카메라·시선에서 멀면 조각마다 가림 검사를 안 한다
		# (조각은 구름 가운데서 1.12s 안, 조각 크기 <= s 라 2.2s 여유면 안전)
		var near := false
		if has_cam:
			var s0: float = _cl_s[ci]
			var rb := s0 * 2.2
			if cc.distance_to(cp) < rb + s0 + 3.5:
				near = true
			elif test_seg:
				var t0 := clampf((cc - cp).dot(seg) / sl2, 0.0, 1.0)
				near = cc.distance_to(cp + seg * t0) < rb + s0 * 1.3 + 1.8
		var p0: int = _cl_p0[ci]
		for pi in range(p0, p0 + _cl_pn[ci]):
			var o: Vector3 = _pf_o[pi]
			var wp := cc + tg * o.x + dir * o.y + ax * o.z
			var sz: float = _pf_s[pi]
			var want := 1.0
			if near:
				if wp.distance_to(cp) < sz + 3.5:
					want = 0.0
				elif test_seg:
					var tt := clampf((wp - cp).dot(seg) / sl2, 0.0, 1.0)
					if wp.distance_to(cp + seg * tt) < sz * 1.3 + 1.8:
						want = 0.0
			var v0: float = _pf_v[pi]
			var vv := move_toward(v0, want, fade)
			if vv == 0.0 and v0 == 0.0:
				continue  # 이미 숨겨 둔 조각은 그대로 (버퍼도 안 건드림)
			_pf_v[pi] = vv
			var e := vv * vv * (3.0 - 2.0 * vv)
			if e < 0.02:
				mm.set_instance_transform(pi, Transform3D(Basis.from_scale(Vector3.ONE * 0.001), ctr))
				continue
			var sc := sz * e
			mm.set_instance_transform(pi, Transform3D(Basis(tg * sc * 1.3, dir * sc * 0.82, ax * sc * 1.1), wp))
		ci += stride


# ---- 화면 겹 그림 ----
func _overlay_step(rdt: float) -> void:
	var r := _speed / _top
	var k := 0.0
	if _have and not _paused:
		if _flying and not _grounded:
			k = clampf((r - 0.3) / 0.9, 0.0, 1.0)
		else:
			k = clampf((r - 0.45) / 0.55, 0.0, 1.0)
	k *= 1.0 - _esc_hold  # 대표 장면 동안은 조용히 (하늘을 보라고)
	_lines_k = lerpf(_lines_k, k, minf(1.0, rdt * 5.0))
	_burst_k = maxf(0.0, _burst_k - rdt * 1.6)
	var kk := maxf(_lines_k, _burst_k)
	if kk > 0.01:
		var adv := rdt * (0.9 + 2.4 * kk)
		for i in _n_lines:
			var tt: float = _ln_t[i] + adv * _ln_v[i]
			if tt >= 1.0:
				tt -= 1.0
				_ln_a[i] = _rng.randf() * TAU
			_ln_t[i] = tt
	_flash = maxf(0.0, _flash - rdt)
	_atmo_t = maxf(0.0, _atmo_t - rdt)
	_gold_t = maxf(0.0, _gold_t - rdt)
	_red_t = maxf(0.0, _red_t - rdt)
	_dusk_hold = maxf(0.0, _dusk_hold - rdt)
	# 들어갈 때 1.4초, 나올 때 1.2초에 걸쳐 (갑자기 어두워지면 부자연스럽다)
	_dusk = move_toward(_dusk, 1.0 if _dusk_hold > 0.0 else 0.0, rdt / (1.4 if _dusk_hold > 0.0 else 1.2))
	var any: bool = kk > 0.01 or _flash > 0.0 or _atmo_t > 0.0 or _gold_t > 0.0 or _red_t > 0.0 or _vig > 0.01 or _dusk > 0.001
	if any or _drew:
		_ov.queue_redraw()
	_drew = any


func _on_draw() -> void:
	var sz := _ov.size
	if sz.x < 2.0 or sz.y < 2.0:
		sz = _ov.get_viewport_rect().size
	if _atmo_t > 0.0:
		_edge(sz, _atmo_c.lightened(0.1), 0.6 * _atmo_t / 0.5, 190.0)
	if _gold_t > 0.0:
		_edge(sz, YEL, 0.65 * clampf(_gold_t / 0.3, 0.0, 1.0), 160.0)
	if _red_t > 0.0:
		_edge(sz, RED, 0.5 * clampf(_red_t / 0.3, 0.0, 1.0), 140.0)
	if _dusk > 0.001:
		var dk := _dusk * _dusk * (3.0 - 2.0 * _dusk)
		_edge(sz, INK2, 0.4 * dk, 320.0)
	if _vig > 0.01:
		_edge(sz, INK2, 0.55 * _vig, 300.0)
		_edge(sz, INK2, 0.35 * _vig, 90.0)
	_draw_lines(sz)
	if _flash > 0.0:
		_ov.draw_rect(Rect2(Vector2.ZERO, sz), Color(1.0, 1.0, 1.0, _flash_a * _flash / FLASH_DUR))


## 화면 가장자리에서 안쪽으로 옅어지는 빛 테 (사다리꼴 넷)
func _edge(sz: Vector2, col: Color, a: float, w0: float) -> void:
	if a <= 0.01:
		return
	var w := minf(w0, minf(sz.x, sz.y) * 0.45)
	var co := Color(col, clampf(a, 0.0, 1.0))
	var cin := Color(col, 0.0)
	_qc[0] = co
	_qc[1] = co
	_qc[2] = cin
	_qc[3] = cin
	var W := sz.x
	var H := sz.y
	_q0[0] = Vector2(0, 0)
	_q0[1] = Vector2(W, 0)
	_q0[2] = Vector2(W - w, w)
	_q0[3] = Vector2(w, w)
	_q1[0] = Vector2(W, 0)
	_q1[1] = Vector2(W, H)
	_q1[2] = Vector2(W - w, H - w)
	_q1[3] = Vector2(W - w, w)
	_q2[0] = Vector2(W, H)
	_q2[1] = Vector2(0, H)
	_q2[2] = Vector2(w, H - w)
	_q2[3] = Vector2(W - w, H - w)
	_q3[0] = Vector2(0, H)
	_q3[1] = Vector2(0, 0)
	_q3[2] = Vector2(w, w)
	_q3[3] = Vector2(w, H - w)
	# draw_polygon 은 그릴 때마다 GL 버퍼를 새로 만든다(호환 렌더러) → 4점 primitive 는 배치로 묶여 싸다
	_ov.draw_primitive(_q0, _qc, _no_uv)
	_ov.draw_primitive(_q1, _qc, _no_uv)
	_ov.draw_primitive(_q2, _qc, _no_uv)
	_ov.draw_primitive(_q3, _qc, _no_uv)


## 속도선: 화면 가장자리에서 가운데로 모이지만 가운데 타원(점선·나)은 늘 비워 둔다
func _draw_lines(sz: Vector2) -> void:
	var k := maxf(_lines_k, _burst_k)
	if k <= 0.01:
		return
	var c := sz * 0.5
	var inner := lerpf(0.8, 0.6, k)
	var lenk := (0.1 + 0.22 * k) * (1.35 if _flying else 1.0)
	var wk := 0.6 + 0.7 * k
	var ak := k * 0.6
	for i in _n_lines:
		var tt: float = _ln_t[i]
		var ro := 1.3 - tt * (1.3 - inner)
		var ri := maxf(inner, ro - lenk)
		if ro - ri < 0.01:
			continue
		var a := sin(tt * PI) * ak
		if a < 0.02:
			continue  # 안 보일 만큼 옅은 선은 건너뜀
		var ang: float = _ln_a[i]
		var d := Vector2(cos(ang) * c.x, sin(ang) * c.y)
		# 안티에일리어스 선은 선마다 폴리곤(GL 버퍼)을 만든다 → 웹에선 끄고 배치되는 사각형으로
		_ov.draw_line(c + d * ro, c + d * ri, Color(CREAM, a), _ln_w[i] * wk, _aa)


# ---- 일 ----
## 본체가 일이 생길 때. 이름·d 키는 MODULES.md 참고
func event(ev: String, d := {}) -> void:
	var p: Vector3 = d.get("pos", _pos + _up * 1.0)
	match ev:
		"liftoff":
			_puff_at(_pos, _up)
			_burst_k = maxf(_burst_k, 0.45)
			_trail_fill()
		"escape":
			_start_escape()
		"atmo":
			_atmo_t = 0.5
			_atmo_c = _sky
		"slingshot":
			_burst_k = 1.0
			_gold_t = 0.4
			_shake_on(0.05)
		"land":
			_puff_at(_pos, _up)
			if bool(d.get("hard", false)):
				_hit(0.1, 0.0)
			else:
				_shake_on(0.025)
		"orbit_land":
			_puff_at(_pos, _up)
		"sail":
			_burst_k = maxf(_burst_k, 0.7)
		"drift_warn":
			_dusk_hold = 2.6  # 빨간 번쩍 대신 천천히 어둑해졌다 돌아온다
		"die":
			_end_slowmo()
			_hit(0.16, 0.0)
			_red_t = 0.5
			_burst_at(_pos + _up * 0.8, false)
		"respawn":
			_end_slowmo()
			_reset_fx()
		"meteor_hit":
			_hit(0.14, 0.0)
			_burst_at(p, false)
		"crack":
			_shake_on(0.06)
			_red_t = 0.3
		"shatter":
			_hit(0.12, 0.0)
			_burst_at(p, false)
		"pickup":
			_gold_t = maxf(_gold_t, 0.25)
		"deliver":
			_burst_at(p, true)
			_gold_t = 0.4
		"job_start":
			_gold_t = maxf(_gold_t, 0.3)
		"job_done":
			_burst_at(_pos + _up * 1.2, true)
			_gold_t = 0.45
			_burst_k = maxf(_burst_k, 0.5)
		"windmill_wake":
			_gold_t = maxf(_gold_t, 0.35)
		"new_planet":
			_burst_at(_pos + _up * 1.2, true)
			_gold_t = 0.35
		"finish":
			_end_slowmo()
			_burst_at(_pos + _up * 1.2, true)
			_gold_t = 0.6
		_:
			pass  # step, drop, meteor_warn, score: 본체·ui 몫


## 부딪힘: v7 은 흰 번쩍임 없이 작고 부드러운 흔들림만 (fa 는 옛 약속 자리)
func _hit(amp: float, _fa: float) -> void:
	_shake_on(amp)


func _shake_on(amp: float) -> void:
	if _shake <= 0.0:
		_shake_ph = 0.0
		_shake_seed = _rng.randf() * TAU
	_shake_amp = maxf(_shake_amp if _shake > 0.0 else 0.0, amp)
	_shake = SHAKE_DUR


func _puff_at(pos: Vector3, up: Vector3) -> void:
	_puff.global_transform = Transform3D(_basis_up(up), pos + up * 0.05)
	_puff.gravity = -up * 4.0
	_puff.restart()


func _burst_at(pos: Vector3, good: bool) -> void:
	var b := _bursts[_burst_i % _bursts.size()]
	_burst_i += 1
	b.color_initial_ramp = _grad_good if good else _grad_hit
	b.global_position = pos
	b.gravity = -_up * 7.0
	b.restart()


func _reset_fx() -> void:
	_trail_k = 0.0
	_trail.visible = false
	_trail_fill()
	_streak_k = 0.0
	_stars.visible = false
	_burst_k = 0.0
	_lines_k = 0.0
	_flash = 0.0
	_shake = 0.0
	_shake_amp = 0.0
	if cam and is_instance_valid(cam):
		cam.h_offset = 0.0
		cam.v_offset = 0.0
	_dust.emitting = false


# ---- 대표 장면: 탈출 ----
## 0.9초(실제): 0.35배로 느려지며 fov 를 크게 넓히고 가장자리 비네트 → 하늘의 별들이 한눈에 → 속도선 폭발과 함께 원래로
func _start_escape() -> void:
	var ov: Variant = game.get("over") if game else null
	if ov is bool and ov:
		return
	_esc_t = 0.0
	_esc_burst = false


func _esc_step(rdt: float) -> void:
	_esc_t += rdt
	var u := _esc_t
	var e_in := smoothstep(0.0, 0.16, u)
	var e_out := smoothstep(ESC_REAL - 0.2, ESC_REAL, u)
	var e := e_in * (1.0 - e_out)
	Engine.time_scale = lerpf(1.0, ESC_SCALE, e)
	_esc_fov = ESC_FOV * e if own_fov else 0.0
	_vig = e
	_esc_hold = e
	if not _esc_burst and u >= ESC_REAL - 0.2:
		_esc_burst = true
		_burst_k = 1.0
	if u >= ESC_REAL:
		_end_slowmo()


func _end_slowmo() -> void:
	Engine.time_scale = 1.0
	_esc_t = -1.0
	_esc_fov = 0.0
	_esc_hold = 0.0
	_vig = 0.0


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	if cam and is_instance_valid(cam):
		cam.h_offset = 0.0
		cam.v_offset = 0.0


## 이 파일은 화면에 글자를 쓰지 않는다 (본체가 합치는 번역 사전 자리만)
const EN := {}
