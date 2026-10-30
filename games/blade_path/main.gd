extends Node
## 일격의 길 단독 실행. 메뉴 없이 바로 blade 를 연다(켜면 튜토리얼부터). "< 처음부터" 를 누르면 다시.

const GAME := "blade"

var game: Tofu


func _ready() -> void:
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_open()


func _open() -> void:
	game = load("res://g/%s.gd" % GAME).new()
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	game.id = GAME
	game.back.connect(_close)
	add_child(game)


func _close() -> void:
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
