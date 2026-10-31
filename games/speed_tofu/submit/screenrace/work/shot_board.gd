extends SceneTree
## 판 끝 결과판 그림 확인: 경주를 시작하고 숫자를 넣어 결과판을 띄워 찍는다.
## (games/speed_tofu 에서) godot --path . --resolution 720x1280 -s submit/screenrace/work/shot_board.gd -- <png> [win|lose]

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var a := OS.get_cmdline_user_args()
	var g: Tofu = load("res://g/screenrace.gd").new()
	g.id = "screenrace"
	root.add_child(g)
	for i in 30:
		await process_frame
	g.records.set_value("opt", "tutorial_done", true)
	g.front.hide_title()
	g._open_mode_select()
	while g.phase != "race":
		await process_frame
	for i in 200:
		await process_frame
	var got := [5, 3, 7, 1]
	var wins := [1, 0, 1, 0]
	for i in g.runners.size():
		g.runners[i].got = got[i]
		g.runners[i].wins = wins[i]
	# 진짜 판 끝으로: 이길 사람을 결승 뒤에 놓으면 LAST CALL 3초 뒤 판이 끝나고 결과판이 뜬다
	var w = g.runners[0] if a.size() > 1 and a[1] == "win" else g.runners[2]
	w.got += 3
	w.p = Vector2(g.goal_x + 0.5, g._floor_top(g.goal_x + 0.5, 60.0) + 0.05)
	while g.phase != "roundend":
		await process_frame
	for i in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(a[0])
	quit()
