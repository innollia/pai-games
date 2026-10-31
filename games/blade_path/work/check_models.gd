extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var game = scene.game
	for k in [0,1,2,3,8]:
		game.n = k
		game.ci = 0
		game.mi = 0
		game._spawn(k)
		assert(game.rig_m.size() > 5)
		assert(game.eyes.size() >= 2)
		assert(game.blade_m.mesh is ArrayMesh)
		assert(game.blade_m.get_child_count() == 1)
		game.mode = "fight"
		game.tut = -1
		game._attack()
		for frame in 20:
			game._step(0.016)
		game._parry(true)
		game._cut()
		game.seen[game.ftype] = 0
		game.dex_pick = game.ftype
		game._set_tab(2)
		await process_frame
	print("PASS: five enemies, weapon meshes, attacks, parry, cut and codex")
	scene.queue_free()
	await process_frame
	var preview := SubViewport.new()
	preview.size = Vector2i(1600,620)
	preview.own_world_3d = true
	preview.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(preview)
	var stage := Node3D.new()
	preview.add_child(stage)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("c7dfeb")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.65
	stage.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35,-30,0)
	stage.add_child(sun)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 7.4
	camera.position = Vector3(6.8,3.2,17)
	stage.add_child(camera)
	camera.look_at(Vector3(6.8,0,0))
	camera.current = true
	for k in 5:
		var model = load("res://g/models.gd").new()
		stage.add_child(model)
		model.position.x = k*3.4
		model.build(k)
		var blade := MeshInstance3D.new()
		blade.mesh = BoxMesh.new()
		blade.material_override = load("res://g/models.gd").material(Color("f5f2e9"))
		model.add_child(blade)
		blade.position = Vector3(1.10,-0.10,0.65)
		blade.scale = Vector3(0.16,1.7,0.16)
		blade.rotation.z = -0.24
		load("res://g/models.gd").sword(blade)
	for frame in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	preview.get_texture().get_image().save_png("C:/Users/fixme/Documents/Codex/2026-10-31/new-chat-4/outputs/blade-path-models.png")
	print("PASS: model lineup rendered")
	quit()

