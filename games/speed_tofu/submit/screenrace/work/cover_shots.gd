extends SceneTree
## 16:9 표지 바탕: 제목 뒤 경주(넷이 알아서 달림)를 가로로 넓혀 찍고 UI는 숨긴다. 제목 그림은 make_cover16.py 가 얹는다.
## (games/off_screen 에서) godot --path . --resolution 1920x1080 -s <이 파일> -- <저장 폴더>

var g: Tofu
var out := ""


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0] if a.size() > 0 else OS.get_user_data_dir()
	DirAccess.make_dir_recursive_absolute(out)
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	g = load("res://g/screenrace.gd").new()
	g.id = "screenrace"
	root.add_child(g)
	_run.call_deferred()


func _hide_ui(n: Node) -> void:
	for c in n.get_children():
		if c is CanvasLayer:
			c.visible = false
		_hide_ui(c)


func _run() -> void:
	for k in 4:
		for i in 90:
			await process_frame
		_hide_ui(root)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join("bg16_%d.png" % k))
		print("shot ", k)
	quit()
