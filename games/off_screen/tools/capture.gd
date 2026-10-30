extends SceneTree
## 화면 캡처: 제목 → 연습 → 모드 카드 → 카운트다운 → 경주 → 대시 → 화면 끝 → 특전 → 길 → 영수증 → 평가 → 한국어 제목을 PNG로 저장한다.
## godot --path . --resolution 720x1280 -s tools/capture.gd -- <저장 폴더>
## (창을 띄워 그려야 해서 --headless 로는 안 된다. 탭이 불확실한 곳은 모듈 함수를 바로 부른다.)

var g: Tofu
var out := ""
var had_tut := false


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	out = a[0] if a.size() > 0 else OS.get_user_data_dir()
	DirAccess.make_dir_recursive_absolute(out)
	g = load("res://g/screenrace.gd").new()
	g.id = "screenrace"
	root.add_child(g)
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(name + ".png"))
	print("shot ", name)


## 손가락 id 별로 tofu 조작 키트에 바로 넣는다 (1 누름, 0 끌기, -1 뗌)
func _finger(id: int, p: Vector2, kind: int) -> void:
	g._finger(id, p, kind)


func _until_phase(ph: String, max_frames := 300) -> void:
	for i in max_frames:
		if g.phase == ph:
			return
		await process_frame


func _run() -> void:
	had_tut = bool(g.records.get_value("opt", "tutorial_done", false))
	if g.lang != "en":
		g._set_lang("en")
		g.restart()
	await _wait(50)
	await _shot("01_title")
	# 연습 (첫 실행처럼)
	g.front.hide_title()
	g.tutorial_begin()
	g.front.start_tutorial(true)
	await _wait(10)
	_finger(1, Vector2(180, 1100), 1)
	for k in 8:
		_finger(1, Vector2(180 + k * 10, 1100), 0)
		await _wait(1)
	await _wait(25)
	await _shot("02_tutorial_step1")
	_finger(1, Vector2(250, 1100), -1)
	g.pl.p = Vector2(19.0, g.pl.p.y)  # 상자를 넘은 자리: 연습 우체통(25)이 보인다
	g.pl.v = Vector2.ZERO
	g._cam_snap()
	g.front._enter(2)
	await _wait(30)
	await _shot("03_tutorial_step3")
	g.front._on_skip()  # first run -> tutorial_done(true) -> straight into the Classic countdown (no mode cards)
	await _wait(10)
	# 모드 카드는 돌아온 사람이 '시작'을 누를 때 나온다: 그 길(_open_mode_select -> menus.show_modes)로 연다
	g._open_mode_select()
	await _until_phase("mode", 30)
	for i in 90:  # 카드가 다 튀어나올 때까지 (마지막 카드 0.19 s 지연 + 튀어나오기)
		if g.menus.screen == "mode" and g.menus._mode_root.visible:
			break
		await process_frame
	await _wait(45)
	print("mode shot phase ", g.phase, " screen ", g.menus.screen)
	await _shot("04_mode")
	g.menus._start_mode()  # 선택된 첫 카드 (Classic)
	await _wait(14)
	await _shot("05_countdown")
	await _until_phase("race")
	# 왼쪽 스틱을 오른쪽으로 밀고 달린다
	_finger(1, Vector2(170, 1100), 1)
	for k in 10:
		_finger(1, Vector2(170 + k * 10, 1100), 0)
		await _wait(1)
	await _wait(140)
	await _shot("06_race")
	# 짐 버리고 대시
	_finger(2, g._btns["drop"].pos, 1)
	await _wait(2)
	_finger(2, g._btns["drop"].pos, -1)
	await _wait(5)
	await _shot("07_dash")
	await _wait(40)
	# v12: 빈 우체통 앞에 세우고 짐 버튼 = 배달 (깃발이 서고 DELIVERED 도장)
	var mbi := -1
	for i in g.mailboxes.size():
		var mb: Dictionary = g.mailboxes[i]
		if not mb.full and float(mb.x) > g.pl.p.x + 2.0:
			mbi = i
			break
	if mbi >= 0:
		var mb: Dictionary = g.mailboxes[mbi]
		g.pl.p = Vector2(float(mb.x) - 0.4, float(mb.y))
		g.pl.v = Vector2.ZERO
		g.pl.immune = 0.0
		g._cam_snap()
		await _wait(3)
		_finger(2, g._btns["drop"].pos, 1)
		await _wait(2)
		_finger(2, g._btns["drop"].pos, -1)
		await _wait(12)
		print("deliver got ", g.pl.got, " cargo ", g.pl.cargo)
		await _shot("07b_deliver")
	await _wait(20)
	# 내 배달부를 왼쪽 끝 밖으로 (진짜 처리: 짐 하나 잃고 찢긴 끝이 번쩍, 슬로모션)
	g.pl.immune = 0.0
	g.rt = 11.0  # past the safe first 10 s of course 1
	g.ci = 1  # _opening() only shields course 1: borrow the course index for this one shot
	print("edge before ", g.phase, " cargo ", g.pl.cargo, " x ", g.pl.p.x, " left ", g.camx - g.hwv, " imm ", g.pl.immune, " alive ", g.pl.alive)
	g.pl.p = Vector2(g.camx - g.hwv - 0.4, g.pl.p.y)
	await _wait(4)
	print("edge after ", g.phase, " cargo ", g.pl.cargo, " x ", g.pl.p.x, " left ", g.camx - g.hwv)
	await _shot("08_edge_moment")
	g.ci = 0
	await _wait(50)
	print("reentered ", g.pl.alive, " cargo ", g.pl.cargo, " vis ", g.pl.node.visible, " pos ", g.pl.node.position, " scale ", g.pl.node.scale, " p ", g.pl.p, " cam ", g.camx, " hwv ", g.hwv, " imm ", g.pl.immune)
	await _shot("08a_reenter")
	# 첫 도착 -> 3초 마감 임박
	g.pl.p = Vector2(g.goal_x + 0.5, g._floor_top(g.goal_x + 0.5, 60.0) + 0.05)
	g._cam_snap()
	await _wait(20)
	g.pl.immune = 0.0  # 다시 들어온 뒤 깜빡임이 끝난 모습
	await _wait(1)
	print("last call ", g.last_call, " vis ", g.pl.node.visible, " pos ", g.pl.node.position, " scale ", g.pl.node.scale, " p ", g.pl.p, " cam ", g.camx)
	await _shot("08b_last_call")
	_finger(1, Vector2(270, 1100), -1)
	await _wait(30)
	g.pl.wins = 99  # 이긴 걸로 치고 진짜 판 끝 처리 -> 특전 고르기
	g._after_round()
	await _wait(40)
	await _shot("09_perk")
	g.menus.hide_all()
	g.pl.wins = 0
	for r in g.runners:
		r.wins = 0
	g.ci = 0
	g._after_round()  # 진 걸로 -> 다음 길 고르기
	await _wait(40)
	await _shot("10_route")
	g.menus.hide_all()
	g.course_results.append({"ci": 1, "medal": 3, "time": 41.0, "cargo": 3})
	g.course_results.append({"ci": 2, "medal": 2, "time": 55.0, "cargo": 2})
	g._finish(true)
	await _wait(90)
	await _shot("11_results")
	g._rate_open()
	await _wait(15)
	await _shot("12_rating")
	g._rate_close()
	g._set_lang("ko")
	g.restart()
	await _wait(50)
	await _shot("13_title_ko")
	# 원래대로: 영어, 연습 기록은 캡처 전 상태로
	g._set_lang("en")
	if not had_tut and g.records.has_section_key("opt", "tutorial_done"):
		g.records.erase_section_key("opt", "tutorial_done")
		g.records.save(g.RECORDS)
	print("capture done ", out)
	quit()
