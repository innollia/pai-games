extends SceneTree
## compress 방 확인 (headless). 정답 입력을 넣어 문에 닿는지, 단순 입력으로는 못 닿는지 본다.
## godot --headless --path games/speed_tofu --fixed-fps 60 -s tools/room_check_compress.gd -- [방번호...]

const DT := 1.0 / 60.0
var g
var trace := false


func _initialize() -> void:
	Engine.max_fps = 0
	_run.call_deferred()


func _run() -> void:
	g = load("res://g/compress.gd").new()
	g.id = "compress"
	root.add_child(g)
	await process_frame
	await process_frame
	g.set_process(false)
	var only: Array = OS.get_cmdline_user_args()
	for i in g.ROOMS.size():
		if not only.is_empty() and not only.has(str(i)):
			continue
		print("== %d %s" % [i, g.ROOMS[i].name])
		print("  오른쪽만    : ", _fmt(_play(i, [_s(Vector2(1, 0), _never, 900)], 900)))
		print("  왼쪽만      : ", _fmt(_play(i, [_s(Vector2(-1, 0), _never, 900)], 900)))
		print("  반만 오른쪽 : ", _fmt(_play(i, [_s(Vector2(0.5, 0), _never, 900)], 900)))
		print("  오른쪽+걸기 : ", _fmt(_play(i, [_s(Vector2(1, 0), _never, 900, true)], 900)))
		print("  아래 쥐고놓기: ", _fmt(_play(i, _pump(Vector2(0, 1), 12), 900)))
		print("  오른쪽 쥐고놓기: ", _fmt(_play(i, _pump(Vector2(1, 0), 12), 900)))
		var plan: Array = _plan(i)
		if plan.is_empty():
			print("  정답        : (계획 없음)")
		else:
			trace = only.has("trace")
			print("  정답        : ", _fmt(_play(i, plan, 1800)))
			trace = false
			if not g.ROOMS[i].get("slit", []).is_empty():
				print("  정답(틈 없이): ", _fmt(_play(i, plan, 1800, "slit")))
			if not g.ROOMS[i].get("press", []).is_empty():
				print("  정답(프레스 없이): ", _fmt(_play(i, plan, 1800, "press")))
			if g.ROOMS[i].get("catch", false):
				print("  정답(받기 없이): ", _fmt(_play(i, plan, 1800, "catch")))
	print("check done")
	quit()


func _never(_gg) -> bool:
	return false


func _fmt(r: Dictionary) -> String:
	return "%s t=%.2f px=%.2f py=%.2f v=(%.1f,%.1f) q=%.2f%s" % [r.r, r.t, r.px, r.py, r.vx, r.vy, r.q, (" (" + r.why + ")") if r.has("why") else ""]


## 스텝: mv = 스틱(아래가 +, 게임 좌표와 같음), hook = 걸기 쥠, until(g) 이면 다음, max 프레임 넘어도 다음
func _s(mv: Vector2, until: Callable, mx_frames := 600, hook := false) -> Dictionary:
	return {"mv": mv, "until": until, "max": mx_frames, "hook": hook}


## 한 방향으로 1초 누르고 0.3초 놓기를 n번 (연타 상당)
func _pump(mv: Vector2, n: int) -> Array:
	var out := []
	for k in n:
		out.append(_s(mv, _never, 60))
		out.append(_s(Vector2.ZERO, _never, 18))
	return out


## strip: "slit" 틈 없이 / "press" 프레스 멈춤(올라간 채) / "catch" 받기 꺼짐 — 기믹 없이도 풀리는지 본다
func _play(room: int, plan: Array, limit: int, strip := "") -> Dictionary:
	g.picking = false
	g.lv = room
	g._room(room)
	if strip == "slit":
		g.slits.clear()
	elif strip == "press":
		g.presses.clear()
	elif strip == "catch":
		g.catch_on = false
	var i := 0
	var f := 0
	var sf := 0
	while f < limit:
		if i >= plan.size():
			return _res("끝(계획 소진)", f)
		var s: Dictionary = plan[i]
		var mv: Vector2 = s.mvf.call(g) if s.has("mvf") else s.mv
		g.kit_move = mv
		g._btns["hook"].down = s.hook
		g._step(DT)
		g._justs.clear()
		f += 1
		sf += 1
		if trace and f % 6 == 0:
			print("    f=%d step=%d px=%.2f py=%.2f v=(%.1f,%.1f) q=%.2f mode=%d floor=%s sq=%s caught=%s" % [f, i, g.px, g.py, g.vel.x, g.vel.y, g.q, g.mode, g.on_floor, g.squashed, g.caught])
		if g.clear_t > 0.0:
			return _res("CLEAR", f)
		if g.die_t > 0.0:
			var r := _res("DIE", f)
			r.why = g._msg_l.text
			return r
		var u: Callable = s.until
		if u.call(g) or sf >= s.max:
			i += 1
			sf = 0
	return _res("timeout", f)


func _res(r: String, f: int) -> Dictionary:
	return {"r": r, "t": f * DT, "px": g.px, "py": g.py, "vx": g.vel.x, "vy": g.vel.y, "q": g.q}


func _wait(frames: int) -> Dictionary:
	return _s(Vector2.ZERO, _never, frames)


## 땅에 서서 멈출 때까지
func _settle() -> Dictionary:
	return _s(Vector2.ZERO, func(gg): return gg.on_floor and gg.vel.length() < 0.05 and gg.mode == 0, 400)


## 굴러서 x 까지 (ROLL 3.5, 가까우면 약하게)
func _goto(x: float) -> Dictionary:
	var st := _s(Vector2.ZERO, func(gg): return absf(gg.px - x) < 0.08 and absf(gg.vel.x) < 0.3 and gg.on_floor, 600)
	st.mvf = func(gg):
		var d: float = x - gg.px
		if absf(d) < 0.05:
			return Vector2.ZERO
		return Vector2(signf(d) * clampf(absf(d) * 0.6, 0.32, 0.5), 0.0)
	return st


func _plan(i: int) -> Array:
	match i:
		11:  # 7-1: 목 위에 서서 아래(끼익) → 바로 위로 되돌아 → 위로 25 → 공중 오른쪽 → 선반 → 문
			return [
				_goto(0.0), _settle(),
				_s(Vector2(0, 1), func(gg): return gg.mode == 1, 30),
				_s(Vector2(0, -1), func(gg): return gg.mode == 0, 120),
				_s(Vector2(1, 0), func(gg): return gg.on_floor and gg.py > 7.0, 300),
				_settle(),
				_goto(5.5), _settle(), _wait(60),
			]
		12:  # 7-2: 오른쪽 벽 틈에 들어가 바로 왼쪽으로 되돌아 → 왼쪽 25 → 미끄러져 문 지나 멈춤 → 돌아와 문
			return [
				_s(Vector2(1, 0), func(gg): return gg.mode == 1, 240),
				_s(Vector2(-1, 0), func(gg): return gg.mode == 0, 120),
				_s(Vector2.ZERO, func(gg): return gg.on_floor and gg.vel.length() < 0.05, 600),
				_goto(-19.0), _settle(), _wait(60),
			]
		13:  # 7-3: 프레스에 눌림 → 아래+오른쪽 쥐고 기어 나옴 → 살짝 기울여 1.0까지 → 아래+오른쪽 → 놓음
			return [
				_goto(3.5), _settle(),
				_s(Vector2.ZERO, func(gg): return gg.squashed, 400),
				_s(Vector2(0.6, 0.8), func(gg): return gg.px > 6.8, 400),
				_s(Vector2(0.4, 0.0), func(gg): return absf(gg.q) <= 1.0, 300),
				_s(Vector2(0.35, 0.94), func(gg): return absf(gg.q) >= 0.99, 60),
				_s(Vector2.ZERO, func(gg): return gg.on_floor and gg.py > 7.0, 300),
				_settle(), _goto(19.0), _settle(), _wait(60),
			]
		14:  # 7-4: 프레스에 눌림 → 아래+오른쪽 쥐고 기어 틈 건넘 → 천장 밑(x≥12.3)에서 살짝 기울여 펴기 → 굴러 문
			return [
				_goto(3.0), _settle(),
				_s(Vector2.ZERO, func(gg): return gg.squashed, 400),
				_s(Vector2(0.6, 0.8), func(gg): return gg.px > 12.6, 900),
				_s(Vector2(0.4, 0.0), func(gg): return gg.q == 0.0, 300),
				_goto(19.0), _settle(), _wait(60),
			]
		15:  # 7-5: 목 되돌아 위로 25 → 공중 걸기 쥠 → 천장 받기 → 스틱 오른쪽 → 놓음 → 선반 → 문
			return [
				_goto(0.0), _settle(),
				_s(Vector2(0, 1), func(gg): return gg.mode == 1, 30),
				_s(Vector2(0, -1), func(gg): return gg.mode == 0, 120),
				_s(Vector2.ZERO, func(gg): return gg.py > 2.0, 60),
				_s(Vector2.ZERO, func(gg): return gg.caught, 120, true),
				_s(Vector2(1, 0), _never, 10, true),
				_s(Vector2(1, 0), func(gg): return gg.on_floor and gg.py > 6.5, 300),
				_settle(), _goto(6.0), _settle(), _wait(60),
			]
		16:  # 7-6: 목 되돌아 → 2층 턱 → 프레스 밑 → 눌림 → 기어 4.5 틈 건너 3층 → 천장 2.5 밑 펴기 → 끝 틈 지나 마당으로 25 → 미끄러져 멈춤 → 문
			return [
				_goto(0.0), _settle(),
				_s(Vector2(0, 1), func(gg): return gg.mode == 1, 30),
				_s(Vector2(0, -1), func(gg): return gg.mode == 0, 120),
				_s(Vector2(1, 0), func(gg): return gg.on_floor and gg.py > 8.0, 300),
				_settle(),
				_goto(5.6), _settle(),
				_s(Vector2.ZERO, func(gg): return gg.squashed, 400),
				_s(Vector2(0.6, 0.8), func(gg): return gg.px > 13.9, 900),
				_s(Vector2(0.4, 0.0), func(gg): return gg.q == 0.0, 300),
				_s(Vector2(1, 0), func(gg): return gg.mode == 1, 400),
				_s(Vector2(1, 0), func(gg): return gg.mode == 0, 120),
				_s(Vector2.ZERO, func(gg): return gg.on_floor and gg.vel.length() < 0.05, 600),
				_goto(39.0), _settle(), _wait(60),
			]
	return []
