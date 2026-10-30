extends SceneTree
## 두부게임을 화면 없이 40초씩 무작위 탭·드래그로 돌려 본다 (재미 확인 아님, 스크립트 오류만).
## godot --headless --path . --fixed-fps 60 -s tools/smoke.gd -- bigball sword   (이름을 안 주면 전부)
## 출력에 SCRIPT ERROR 가 없고 마지막 줄이 "smoke done" 이면 통과.

const ALL := ["quicksilver", "synapse", "boulder", "hot", "hot_side", "quicksilver_tp", "boulder_fp", "coil_side", "speedcop", "speedthief", "trafficwizard", "screenrace", "kitchen", "coaster", "pitcrew", "overpower", "overpower_3d", "piton", "predict", "onedot", "icecream", "lickghost", "wombat_fast", "wombat_dial", "rain_slow", "rain_flee", "coming_top", "coming_fp", "deepsword", "deepsword_3d", "shockwave", "glider", "ice_courier", "runaway_train", "molten", "quicksilver_fp", "rain_fp", "deepsword_fp", "boulder_race", "screenrace_over", "rain_coming", "overpower_rain", "coming_boulder", "snapshot", "fallcards", "tooslow", "puzzlerace", "taiji_speed", "tinyplanet", "bombcrawl", "scale_prison", "compress", "magnet", "stretch_roll", "loud_race", "tooslow_rpg", "wheel_down", "bounce_race", "phase_runner", "echo_bat", "counterweight", "lantern_race", "speed_snake", "overpower_map", "bigball", "sword", "nerve", "superhot", "onlyfast", "hotpack", "timedebt", "runaway", "slowbike", "matchspeed"]


func _initialize() -> void:
	Engine.max_fps = 0
	_run.call_deferred()


func _run() -> void:
	var ids: Array = OS.get_cmdline_user_args()
	if ids.is_empty():
		ids = ALL
	for id in ids:
		var g: Tofu = load("res://g/%s.gd" % id).new()
		g.id = id
		root.add_child(g)
		var ends := 0
		var restarts := 0
		var top := 0
		var was_over := false
		var hold := 0
		var pos := Vector2.ZERO
		var vel := Vector2.ZERO
		for i in 60 * 40:
			await process_frame
			top = maxi(top, g.score)
			if g.over and not was_over:
				ends += 1
			if was_over and not g.over:
				restarts += 1
			was_over = g.over
			if hold > 0:
				hold -= 1
				pos += vel
				_mouse_move(g, pos)
				if hold == 0:
					_mouse(g, pos, false)
			elif randf() < 0.12:
				pos = Vector2(randf_range(40, 680), randf_range(160, 1240))
				vel = Vector2(randf_range(-25, 25), randf_range(-25, 25))
				hold = randi_range(1, 12)
				_mouse(g, pos, true)
		print("%-9s 끝남 %d  다시 %d  무작위최고 %d" % [id, ends, restarts, top])
		g.queue_free()
		await process_frame
	print("smoke done")
	quit()


func _mouse(g: Tofu, p: Vector2, down: bool) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = down
	e.position = p
	g._unhandled_input(e)


func _mouse_move(g: Tofu, p: Vector2) -> void:
	var e := InputEventMouseMotion.new()
	e.position = p
	g._unhandled_input(e)
