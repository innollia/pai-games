class_name Look
## 파이 설정화(10/30) 모양의 검객 넷: 찌르기 = 주황 삿갓·주황 망토·청록 옷, 속임수 = 검은 챙 넓은 모자·붉은 목도리 끈,
## 베기 = 쇠 투구·털 목깃·갈색 망토, 거합 = 옅은 삿갓·흰 겉옷·붉은 목도리. 바탕은 누런 종이색.
## 안 어울리면 ON 을 false 로 바꾸고 다시 빌드하면 예전 상자 검객으로 돌아간다(이 파일 말고는 손댈 곳 없음).
const ON := false

const PAPER := Color("e9dcc4")
const LEG := Color("2a2730")
const FACE := Color("3b2a20")


## piv 아래에 검객 몸을 만든다. tint = 뒤 바퀴일수록 어두워지는 정도(0~0.6).
## 돌려주는 것: body(번쩍일 몸통 상자), eye_y, eye_z, top(금장식 높이), hp_y
static func dress(g: Tofu, ftype: int, tint: float, piv: Node3D) -> Dictionary:
	var t := func(c: String) -> Color: return Color(c).lerp(Tofu.INK, tint)
	var out := {}
	for s in [-1.0, 1.0]:
		g.box(Vector3(s * 0.32, -1.45, 0), Vector3(0.38, 0.6, 0.45), LEG, piv)
	match ftype:
		0:
			# 찌르기: 청록 옷 + 주황 망토 + 주황 삿갓
			g.box(Vector3(0, -0.3, -0.42), Vector3(1.7, 2.1, 0.22), t.call("c46a2b"), piv)
			out.body = g.box(Vector3(0, -0.4, 0), Vector3(1.25, 1.9, 0.8), t.call("2e5b57"), piv)
			g.box(Vector3(0, -0.55, 0.03), Vector3(1.3, 0.16, 0.82), t.call("8a5a2b"), piv)
			for s in [-1.0, 1.0]:
				g.box(Vector3(s * 0.75, 0.35, 0), Vector3(0.45, 0.4, 0.95), t.call("c46a2b"), piv)
			g.box(Vector3(0, 0.95, 0), Vector3(0.72, 0.62, 0.66), FACE, piv)
			_cone(g, Vector3(0, 1.48, 0), 1.15, 0.6, t.call("d98c3c"), piv)
			out.eye_y = 0.9
			out.top = 1.95
		1:
			# 속임수: 검은 망토 + 붉은 띠·목도리 끈 + 챙 넓은 검은 모자
			out.body = g.box(Vector3(0, -0.4, 0), Vector3(1.7, 1.95, 0.9), t.call("2b2a33"), piv)
			g.box(Vector3(0, -0.5, 0.03), Vector3(1.75, 0.18, 0.92), Color("b3322e"), piv)
			g.box(Vector3(0, 0.55, 0.05), Vector3(1.2, 0.3, 0.85), Color("b3322e"), piv)
			for s in [-1.0, 1.0]:
				var rb := g.box(Vector3(s * 1.05, 0.25, -0.2), Vector3(1.1, 0.14, 0.1), Color("b3322e"), piv)
				rb.rotation.z = s * -0.5
			g.box(Vector3(0, 0.98, 0), Vector3(0.7, 0.6, 0.64), Color("16141a"), piv)
			_disc(g, Vector3(0, 1.32, 0), 1.3, 0.1, t.call("24222a"), piv)
			_disc(g, Vector3(0, 1.62, 0), 0.5, 0.55, t.call("24222a"), piv)
			_disc(g, Vector3(0, 1.45, 0), 0.52, 0.12, Color("b3322e"), piv)
			out.eye_y = 0.92
			out.top = 2.05
		2:
			# 베기: 갈색 망토 + 푸른 옷 + 털 목깃 + 쇠 투구
			g.box(Vector3(0, -0.3, -0.48), Vector3(1.9, 2.1, 0.22), t.call("6b4a2e"), piv)
			out.body = g.box(Vector3(0, -0.4, 0), Vector3(1.55, 1.95, 1.0), t.call("34506b"), piv)
			g.box(Vector3(0, -0.55, 0.03), Vector3(1.6, 0.18, 1.02), t.call("5a3b22"), piv)
			g.box(Vector3(0, 0.62, 0), Vector3(2.2, 0.55, 1.25), t.call("d8c3a0"), piv)
			for s in [-1.0, 1.0]:
				g.box(Vector3(s * 1.05, 0.45, 0.1), Vector3(0.5, 0.5, 0.9), t.call("cdb592"), piv)
			_disc(g, Vector3(0, 1.22, 0), 0.46, 0.75, t.call("5b6168"), piv)
			_cone(g, Vector3(0, 1.75, 0), 0.47, 0.35, t.call("5b6168"), piv)
			g.box(Vector3(0, 1.62, 0), Vector3(0.12, 0.3, 0.12), t.call("5b6168"), piv)
			g.box(Vector3(0, 1.2, 0.42), Vector3(0.7, 0.2, 0.06), Color("16141a"), piv)
			out.eye_y = 1.2
			out.eye_z = 0.47
			out.top = 2.1
		3:
			# 거합: 흰 겉옷 + 검은 하카마 + 붉은 목도리 + 옅은 삿갓
			g.box(Vector3(0, -1.0, 0), Vector3(1.25, 0.8, 0.75), t.call("2a2730"), piv)
			out.body = g.box(Vector3(0, -0.15, 0), Vector3(1.15, 1.55, 0.78), t.call("e6ddc9"), piv)
			g.box(Vector3(0, -0.15, 0.4), Vector3(0.3, 1.5, 0.04), t.call("2a2730"), piv)
			g.box(Vector3(0, 0.62, 0.02), Vector3(0.95, 0.24, 0.8), Color("b02a2a"), piv)
			var tail := g.box(Vector3(-0.75, 0.45, -0.2), Vector3(0.9, 0.12, 0.08), Color("b02a2a"), piv)
			tail.rotation.z = 0.45
			g.box(Vector3(0, 0.98, 0), Vector3(0.66, 0.6, 0.62), FACE, piv)
			_cone(g, Vector3(0, 1.5, 0), 1.15, 0.62, t.call("d7b98a"), piv)
			# 허리춤 칼집 (칼은 이 안에 눕혀 둔다)
			g.box(Vector3(0.7, -0.55, 0.15), Vector3(0.18, 0.18, 1.3), Tofu.INK, piv)
			out.eye_y = 0.92
			out.top = 1.95
	out.eye_z = out.get("eye_z", 0.36)
	out.hp_y = out.top + 0.35
	return out


## 바탕을 설정화의 누런 종이색으로
static func stage(g: Node) -> void:
	for we in g.find_children("*", "WorldEnvironment", true, false):
		(we as WorldEnvironment).environment.background_color = PAPER


## 낮은 다각형 원뿔(삿갓, 투구 끝)
static func _cone(g: Tofu, pos: Vector3, r: float, h: float, col: Color, piv: Node3D) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = 0.02
	cm.bottom_radius = r
	cm.height = h
	cm.radial_segments = 10
	cm.rings = 1
	return _put(g, cm, pos, col, piv)


## 납작한 원기둥(모자 챙, 투구 몸통)
static func _disc(g: Tofu, pos: Vector3, r: float, h: float, col: Color, piv: Node3D) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = r
	cm.bottom_radius = r
	cm.height = h
	cm.radial_segments = 12
	cm.rings = 1
	return _put(g, cm, pos, col, piv)


static func _put(g: Tofu, mesh: Mesh, pos: Vector3, col: Color, piv: Node3D) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.mesh = mesh
	m.material_override = g.mat(col)
	m.position = pos
	piv.add_child(m)
	return m
