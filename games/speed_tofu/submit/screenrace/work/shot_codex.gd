extends SceneTree
## 도감 화면 확인: 제목 → [도감] → 동네 탭, 길·기물 탭(위·아래로 넘김), 제목 버튼 줄.
## (games/speed_tofu 에서) godot --path . --resolution 720x1280 -s submit/screenrace/work/shot_codex.gd -- <저장 폴더> [en]

func _initialize() -> void:
	_run.call_deferred()


func _shot(dir: String, n: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(dir.path_join(n + ".png"))


func _run() -> void:
	var a := OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(a[0])
	var g: Tofu = load("res://g/screenrace.gd").new()
	g.id = "screenrace"
	root.add_child(g)
	for i in 40:
		await process_frame
	if a.size() > 1 and a[1] == "en" and g.lang != "en":
		g._set_lang("en")
		g.restart()
		for i in 30:
			await process_frame
	elif (a.size() < 2 or a[1] != "en") and g.lang != "ko":
		g._set_lang("ko")
		g.restart()
		for i in 30:
			await process_frame
	await _shot(a[0], "0_title")
	g.front._on_guide()
	for i in 30:
		await process_frame
	await _shot(a[0], "1_towns")
	var c = g.front._codex
	c.tab = 1
	c._fill()
	c.queue_redraw()
	await _shot(a[0], "2_things")
	c.scroll = c._max_scroll()
	c.queue_redraw()
	await _shot(a[0], "3_things_end")
	quit()
