extends Node
## 화면 밖 경주(Off the Screen!) 단독 실행. 메뉴 없이 바로 screenrace 를 연다. "< 메뉴" 를 누르면 처음부터 다시.
## 강화는 speed_tofu 의 g/screenrace.gd 에서 하고 tools/sync.ps1 로 가져온다.

const GAME := "screenrace"
const GVER := 9  # speed_tofu main.gd GAME_VER["screenrace"] (tools/sync.ps1 이 맞춘다). 평가 ver = "v<GVER> <빌드>"

var game: Tofu
var from_tofu := false  # SPEED 두부 목록(?from=tofu)에서 왔으면 "<" 가 목록으로 돌아간다


func _ready() -> void:
	randomize()
	if OS.has_feature("web"):
		from_tofu = JavaScriptBridge.eval("location.search.indexOf('from=tofu') >= 0", true) == true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_open()


func _open() -> void:
	game = load("res://g/%s.gd" % GAME).new()
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	game.id = GAME
	game.gver = GVER
	game.back.connect(_close)
	add_child(game)
	if from_tofu:
		_relabel(game)


func _relabel(n: Node) -> void:
	for c in n.get_children():
		if c is Label and c.text == "< Restart":
			c.text = "< List"
		_relabel(c)


func _close() -> void:
	if from_tofu:
		JavaScriptBridge.eval("window.location.href = '../../speed_tofu/web/'", true)
		return
	game.queue_free()
	game = null
	_open.call_deferred()


func _notification(what: int) -> void:
	# 탭이 가려지면 멈추고 소리를 끈다
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		get_tree().paused = true
		AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		get_tree().paused = false
		AudioServer.set_bus_mute(0, false)
