extends SceneTree
## 강화 탭(냥 주고 한 칸 찍기)·대사 서식·등장 페이드 한 번 돌려 보기: Godot --headless --path . --script work/check_lobby.gd
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var game = scene.game
	game.coin = 100
	game._to_lobby(1)
	game._lobby_tap(game.UP_BUY.get_center())
	print(game.up_head.text, " | ", game.up_card.text, " | ", game.up_buy_l.text, " | tree=", game.tree)
	game._lobby_tap(game._up_r(0, 1).get_center())
	print(game.up_buy_l.text, " | ", game.up_l[1].text)
	print(game._f("info", [1, 2]))
	game._start_run()
	for i in 90:
		await process_frame
	print("mode=", game.mode, " fade ok")
	quit()
