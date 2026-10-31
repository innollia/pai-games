extends SceneTree
## 16:9 표지 바탕: 제목 뒤 경주(넷이 알아서 달림)를 가로로 넓혀 찍고 UI는 숨긴다. 제목 그림은 make_cover16.py 가 얹는다.
## 게임 카메라는 화면 폭을 맞추므로(KEEP_WIDTH) 가로 화면에서는 위아래가 잘린다: 그리기 직전에 카메라를 넓게(HW) 다시 놓는다.
## 넷이 겹쳐 한 덩어리로 보이지 않게, 찍기 조금 전에 넷을 GAP 간격으로 벌려 놓는다.
## (games/off_screen 에서) godot --path . --resolution 1920x1080 -s <이 파일> -- <저장 폴더>

const HW := 10.0  # 화면 반폭(m): 벌린 넷과 짐 탑 꼭대기까지
const FEET := 0.62  # 넷의 발이 화면 가운데에서 아래로 반높이의 몇 배에 오나
const GAP := 3.4  # 배달부 사이 간격(m)

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
	RenderingServer.frame_pre_draw.connect(_wide_cam)
	process_frame.connect(_spread)
	_run.call_deferred()


var cam2: Camera3D


## 게임 카메라와 따로 선 표지용 카메라 (게임 카메라는 매 프레임 1등을 따라 다시 놓인다)
func _wide_cam() -> void:
	if g.cam == null or g.runners.is_empty():
		return
	if cam2 == null:
		cam2 = Camera3D.new()
		cam2.keep_aspect = Camera3D.KEEP_WIDTH
		g.cam.get_parent().add_child(cam2)
	cam2.current = true
	var lo: float = g.runners[0].p.x
	var hi: float = lo
	var low: float = g.runners[0].p.y
	for r in g.runners:
		lo = minf(lo, r.p.x)
		hi = maxf(hi, r.p.x)
		low = minf(low, r.p.y)
	var hh := HW * 9.0 / 16.0
	cam2.fov = rad_to_deg(2.0 * atan(HW / g.CAM_D))
	cam2.position = Vector3((lo + hi) * 0.5 + HW * 0.12, low + hh * FEET, g.CAM_D)


## 찍기 전 몇십 프레임 동안 매 프레임 뒤 셋을 1등에서 GAP 씩 뒤에 붙여 둔다 (한 번에 옮기면 바람 줄이 남고, 놔두면 다시 뭉친다).
var order: Array = []


func _spread() -> void:
	g.hwv = 16.0  # 게임 속 화면 폭(왼쪽 끝)도 넓혀서 맨 뒤 배달부가 반송되지 않게
	if order.is_empty():
		return
	var lead = order[0]
	for i in range(1, order.size()):
		var r = order[i]
		r.p.x = lead.p.x - i * GAP
		r.v.x = lead.v.x


func _hide_ui(n: Node) -> void:
	for c in n.get_children():
		if c is CanvasLayer:
			c.visible = false
		_hide_ui(c)


func _run() -> void:
	for i in 120:
		await process_frame
	for k in 24:
		for i in 14:
			await process_frame
		order = g.runners.duplicate()
		order.sort_custom(func(a, b): return a.p.x > b.p.x)
		for i in 40:
			_spread()
			await process_frame
		order = []
		_hide_ui(root)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join("bg16_%02d.png" % k))
		print("shot ", k)
	quit()
