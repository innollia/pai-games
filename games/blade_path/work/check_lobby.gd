extends SceneTree
## 캐릭터 탭·대사 서식·등장 페이드 한 번 돌려 보기: Godot --headless --path . --script work/check_lobby.gd
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var game = scene.game
	game._to_lobby(1)
	print(game.char_l.text)
	print(game._f("info", [1, 2]))
	game._start_run()
	for i in 90:
		await process_frame
	print("mode=", game.mode, " fade ok")
	quit()
