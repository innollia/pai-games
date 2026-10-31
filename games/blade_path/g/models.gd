extends Node3D
## Reference order: helmet, twin head, straw, lightning, shield. No arms.
const GOLD := Color("ffbf28")
const DARK := Color("343535")
const STEEL := Color("686b70")
const STRAW := Color("d7ac62")

static func material(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.88
	return m

static func part(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	m.mesh = mesh
	m.material_override = material(color)
	m.position = pos
	parent.add_child(m)
	return m

static func cube(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return part(parent, mesh, pos, color)

static func ball(parent: Node3D, pos: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 12
	mesh.rings = 6
	return part(parent, mesh, pos, color)

static func cone(parent: Node3D, pos: Vector3, bottom: float, top: float, height: float, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = bottom
	mesh.top_radius = top
	mesh.height = height
	mesh.radial_segments = 8
	return part(parent, mesh, pos, color)

## Extruded silhouette, flat shaded front and edges.
static func prism(points: PackedVector2Array, depth: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var indices := Geometry2D.triangulate_polygon(points)
	for side in [-1.0, 1.0]:
		for i in range(0, indices.size(), 3):
			var order := [0, 1, 2] if side < 0 else [2, 1, 0]
			for j in order:
				var p := points[indices[i + j]]
				st.add_vertex(Vector3(p.x, p.y, side * depth / 2))
	for i in points.size():
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		for v in [Vector3(a.x,a.y,-depth/2),Vector3(a.x,a.y,depth/2),Vector3(b.x,b.y,depth/2),Vector3(a.x,a.y,-depth/2),Vector3(b.x,b.y,depth/2),Vector3(b.x,b.y,-depth/2)]:
			st.add_vertex(v)
	st.generate_normals()
	return st.commit()

func eye_pair(x: float, y: float, z: float, spacing := 0.27) -> void:
	for side in [-1, 1]:
		var eye := cube(self, Vector3(x + side * spacing,y,z),Vector3(0.16,0.22,0.045),Color("222420"))
		eye.set_meta("signal_eye", true)

func build(kind: int) -> void:
	var hand_color := DARK if kind != 1 and kind != 3 else Color("85602f")
	# Feet and floating hands; the sword hand is attached to the weapon.
	for side in [-1,1]:
		cube(self,Vector3(side * 0.38,-1.24,0.03),Vector3(0.24,0.48,0.27),DARK)
		cube(self,Vector3(side * 0.38,-1.48,0.16),Vector3(0.36,0.14,0.48),DARK)
	ball(self,Vector3(-1.0,-0.64,0.12),0.20,hand_color)
	match kind:
		0: # Low polygon iron helmet, black visor and red tunic.
			cube(self,Vector3(0,-0.61,0),Vector3(1.14,0.92,0.72),Color("ad3928"))
			cube(self,Vector3(0,-0.18,0),Vector3(1.46,0.17,0.86),Color("873124"))
			part(self,prism(PackedVector2Array([Vector2(-0.94,-0.12),Vector2(0.94,-0.12),Vector2(0.94,0.66),Vector2(0,1.65),Vector2(-0.94,0.66)]),0.95),Vector3.ZERO,STEEL)
			cone(self,Vector3(0,1.69,0),0.13,0.025,0.53,DARK)
			cube(self,Vector3(0,0.34,0.50),Vector3(1.36,0.30,0.035),DARK)
			for side in [-1,1]:
				var eye := cube(self,Vector3(side*0.38,0.34,0.53),Vector3(0.17,0.18,0.04),Color("eee8cf"))
				eye.set_meta("signal_eye", true)
		1: # Two unequal yellow heads on one broad body.
			cube(self,Vector3(0,-0.52,0),Vector3(1.85,1.37,0.80),GOLD)
			cube(self,Vector3(-0.53,0.80,0),Vector3(0.63,1.88,0.67),GOLD)
			cube(self,Vector3(0.56,0.48,0),Vector3(0.63,1.24,0.67),GOLD)
			eye_pair(-0.53,1.36,0.36,0.16)
			eye_pair(0.56,0.86,0.36,0.16)
		2: # Straw coat with three courses and broad woven hat.
			for row in 3:
				cube(self,Vector3(0,-0.91+row*0.40,0),Vector3(1.34,0.38,0.91),STRAW)
				for col in 7:
					cube(self,Vector3(-0.58+col*0.19,-0.91+row*0.40,0.468),Vector3(0.018,0.35,0.018),Color("b38948"))
			cube(self,Vector3(0,0.37,0),Vector3(1.31,0.57,0.83),STRAW)
			eye_pair(0,0.40,0.44,0.35)
			cone(self,Vector3(0,0.99,0),1.18,0.27,0.70,STRAW)
			cone(self,Vector3(0,0.65,0),1.20,1.20,0.07,Color("bb914c"))
			cone(self,Vector3(0,1.46,0),0.19,0.30,0.32,STRAW)
			cone(self,Vector3(0,1.31,0),0.23,0.23,0.09,DARK)
		3: # Angular lightning silhouette.
			part(self,prism(PackedVector2Array([Vector2(-0.70,1.22),Vector2(0.65,1.64),Vector2(1.08,0.48),Vector2(0.28,-0.08),Vector2(0.91,-0.79),Vector2(-0.67,-1.30),Vector2(-0.36,-0.61),Vector2(-1.04,-0.06),Vector2(-0.27,0.53)]),0.67),Vector3.ZERO,GOLD)
			eye_pair(0.38,0.61,0.36,0.24)
		4: # Broad shield face and iron body, sword hilt above shoulder.
			cube(self,Vector3(0,-0.24,-0.30),Vector3(1.67,2.15,0.93),STEEL)
			var shield := PackedVector2Array([Vector2(-1.04,1.28),Vector2(0.18,1.45),Vector2(0.91,1.23),Vector2(0.90,0.10),Vector2(0.65,-0.80),Vector2(-0.10,-1.35),Vector2(-0.76,-0.92),Vector2(-1.04,0.14)])
			part(self,prism(shield,0.22),Vector3(0,0,0.43),Color("d8d7d0"))
			eye_pair(-0.10,0.55,0.57,0.36)
			cube(self,Vector3(0.68,1.45,-0.30),Vector3(0.13,0.70,0.13),DARK)
			ball(self,Vector3(0.68,1.82,-0.30),0.13,DARK)

static func sword(blade: MeshInstance3D) -> void:
	# Keep the existing combat transform and tint on the actual blade.
	# Diamond cross-section: point, four shoulder vertices, four base vertices.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertices := [Vector3(0,0.5,0),Vector3(-0.83,0.30,0),Vector3(0,0.30,0.46),Vector3(0.83,0.30,0),Vector3(0,0.30,-0.46),Vector3(-0.83,-0.36,0),Vector3(0,-0.36,0.46),Vector3(0.83,-0.36,0),Vector3(0,-0.36,-0.46)]
	for tri in [[0,2,1],[0,3,2],[0,4,3],[0,1,4],[1,2,6],[1,6,5],[2,3,7],[2,7,6],[3,4,8],[3,8,7],[4,1,5],[4,5,8],[5,6,7],[5,7,8]]:
		for i in tri:
			st.add_vertex(vertices[i])
	st.generate_normals()
	blade.mesh = st.commit()
	var fittings := Node3D.new()
	blade.add_child(fittings)
	fittings.scale = Vector3.ONE / blade.scale
	var length := blade.scale.y
	cone(fittings,Vector3(0,-0.38*length,0),0.28,0.28,0.10,GOLD).scale.z = 0.55
	cube(fittings,Vector3(0,-0.38*length-0.20,0),Vector3(0.14,0.32,0.14),Color("815032"))
	cone(fittings,Vector3(0,-0.38*length-0.39,0),0.13,0.13,0.13,GOLD)
	ball(fittings,Vector3(0,-0.38*length-0.16,-0.06),0.18,DARK)
