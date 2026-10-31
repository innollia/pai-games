extends SceneTree
## overpower 방 확인 (headless). 스크립트로 정답 입력을 넣어 문에 닿는지, 그냥 밀기만 하면 못 닿는지 본다.
## godot --headless --path games/speed_tofu --fixed-fps 60 -s tools/room_check_overpower.gd -- [방번호...]  (방마다 단순 입력 4가지 + _plan() 정답)

const DT := 1.0 / 60.0
var g


func _initialize() -> void:
	Engine.max_fps = 0
	_run.call_deferred()


func _run() -> void:
	g = load("res://g/overpower.gd").new()
	g.id = "overpower"
	root.add_child(g)
	await process_frame
	await process_frame
	g.set_process(false)
	var only: Array = OS.get_cmdline_user_args()
	for i in g.ROOMS.size():
		if not only.is_empty() and not only.has(str(i)):
			continue
		var nm: String = "%d-%d %s" % [i / 3 + 1, i % 3 + 1, g.ROOMS[i].name]
		print("== ", nm)
		print("  오른쪽만 : ", _fmt(_play(i, [_s(1.0, func(_g): return false, 900)], 900)))
		print("  왼쪽만   : ", _fmt(_play(i, [_s(-1.0, func(_g): return false, 900)], 900)))
		print("  오른쪽+점프: ", _fmt(_play(i, [_s(1.0, func(_g): return false, 900, true, true)], 900, true)))
		print("  반만 오른쪽: ", _fmt(_play(i, [_s(0.5, func(_g): return false, 900)], 900)))
		var plan: Array = _plan(i)
		if plan.is_empty():
			print("  정답     : (계획 없음)")
		else:
			print("  정답     : ", _fmt(_play(i, plan, 1500)))
	print("check done")
	quit()


func _fmt(r: Dictionary) -> String:
	return "%s t=%.2f px=%.2f py=%.2f vx=%.1f%s" % [r.r, r.t, r.px, r.py, r.vx, (" (" + r.why + ")") if r.has("why") else ""]


func _s(mx: float, until: Callable, mx_frames := 600, jump := false, hold := false) -> Dictionary:
	return {"mx": mx, "until": until, "max": mx_frames, "jump": jump, "hold": hold}


func _frame(mx: float, press: bool, hold: bool) -> void:
	g.kit_move = Vector2(mx, 0.0)
	if press:
		g._justs["jump"] = true
	g._btns["jump"].down = hold
	g._step(DT)
	g._justs.clear()


## jump_each: 매 프레임 점프를 새로 누른다 (연타)
func _play(room: int, plan: Array, limit: int, jump_each := false) -> Dictionary:
	g.load_room_data(g.ROOMS[room])
	var i := 0
	var f := 0
	var sf := 0
	while f < limit:
		if i >= plan.size():
			return _res("끝(계획 소진)", f)
		var s: Dictionary = plan[i]
		var press: bool = (sf == 0 and s.jump) or (jump_each and f % 20 == 0)
		var mx: float = s.mxf.call(g) if s.has("mxf") else s.mx
		_frame(mx, press, s.hold or jump_each)
		f += 1
		sf += 1
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
	return {"r": r, "t": f * DT, "px": g.px, "py": g.py, "vx": g.vx}


func _stop() -> Dictionary:
	return _s(0.0, func(gg): return absf(gg.vx) < 0.05 and gg.on_floor, 300)


func _brake() -> Dictionary:
	return _s(-1.0, func(gg): return absf(gg.vx) < 1.0, 120)


## 느리게 걸어서 x 에 서기 (가까우면 _snap 이 가운데를 맞춘다)
func _goto(x: float) -> Dictionary:
	var st := _s(0.0, func(gg): return absf(gg.px - x) < 0.05 and absf(gg.vx) < 0.3 and gg.on_floor, 360)
	st.mxf = func(gg):
		var d: float = x - gg.px
		if absf(d) < 0.04:
			return 0.0
		return signf(d) * clampf(absf(d) * 0.8, 0.15, 0.35)
	return st


func _plan(i: int) -> Array:
	match i:
		0:  # 1-1: 물러나서 질주
			return [_s(-1.0, func(gg): return gg.px < 1.7), _stop(), _s(1.0, func(_gg): return false, 600)]
		1:  # 1-2: 아래 틈 → 오른쪽 방 제동 → 블록 위 → 점프, 왼쪽으로 흘러 위층 → 물러나 왼쪽 질주 → 위 틈 → 문
			return [
				_s(1.0, func(gg): return gg.px > 14.6), _brake(), _stop(),
				_goto(19.5),
				_s(0.0, func(gg): return gg.py > 3.2, 60, true, true),
				_s(0.5, func(gg): return gg.on_floor and gg.py > 2.9, 90), _stop(),
				_goto(20.5),
				_s(0.0, func(gg): return gg.py > 7.3, 90, true, true),
				_s(-0.4, func(gg): return gg.on_floor and gg.py > 6.9, 120), _stop(),
				_goto(19.3),
				_s(-1.0, func(_gg): return false, 600),
			]
		2:  # 1-3: 물러나서 끊지 않고 질주
			return [_s(-1.0, func(gg): return gg.px < 1.7), _stop(), _s(1.0, func(_gg): return false, 600)]
		3:  # 2-1: 질주로 구덩이 걸쳐 건넘
			return [_s(1.0, func(_gg): return false, 600)]
		4:  # 2-2: 지나친 뒤 돌아와 느리게 빠짐
			return [
				_s(1.0, func(gg): return gg.px > 17.5), _brake(), _stop(),
				_s(-0.3, func(gg): return not gg.on_floor or gg.px < 15.0, 240), _stop(),
				_s(0.0, func(gg): return gg.on_floor and gg.py < 1.5, 120),
				_s(1.0, func(_gg): return false, 600),
			]
		5:  # 2-3: 틈 나와 A 걸치고 제동 → B에 빠짐 (멈췄으면 걸어가 빠짐)
			return [
				_s(1.0, func(gg): return gg.px > 12.9),
				_s(-1.0, func(gg): return (not gg.on_floor) or absf(gg.vx) < 1.0, 120), _stop(),
				_s(0.4, func(gg): return not gg.on_floor, 240),
				_s(0.0, func(gg): return gg.on_floor and gg.py < 1.5, 120),
				_s(1.0, func(_gg): return false, 600),
			]
		6:  # 3-1: 굴뚝 밑에 서서 뛰고 손 뗀다
			return [
				_goto(10.5),
				_s(0.0, func(gg): return absf(gg.px - 10.5) < 0.03, 120),
				_s(0.0, func(gg): return gg.py > 6.05, 90, true, true),
				_s(1.0, func(gg): return gg.on_floor, 120),
				_s(1.0, func(_gg): return false, 600),
			]
		7:  # 3-2: 지나친 뒤 완전히 멈춰 1칸 구멍
			return [
				_s(1.0, func(gg): return gg.px > 17.5), _brake(), _stop(),
				_s(-0.3, func(gg): return gg.px < 16.9, 240), _stop(),
				_s(0.0, func(gg): return not gg.on_floor, 120),
				_s(0.0, func(gg): return gg.on_floor and gg.py < 1.5, 120),
				_s(1.0, func(_gg): return false, 600),
			]
		8:  # 3-3: 벽에 멈춰 구멍 낙하 → 물러나 질주 → 틈 → 끝 벽 → 굴뚝 밑에 서서 뛰기
			return [
				_goto(7.5),
				_s(0.0, func(gg): return not gg.on_floor, 120),
				_s(0.0, func(gg): return gg.on_floor and gg.py < 4.5, 120),
				_s(-1.0, func(gg): return gg.px < 1.7, 240), _stop(),
				_s(1.0, func(gg): return gg.px > 16.4, 240),
				_s(0.0, func(gg): return gg.on_floor and absf(gg.vx) < 0.3, 240),
				_s(0.0, func(gg): return gg.stun <= 0.0, 60),
				_goto(18.5),
				_s(0.0, func(gg): return absf(gg.px - 18.5) < 0.03, 120),
				_s(0.0, func(gg): return gg.py > 8.05, 90, true, true),
				_s(1.0, func(_gg): return false, 600),
			]
		9:  # 4-1: 질주하며 뛰어 쾅 → X
			return [_s(1.0, func(gg): return gg.vx > 20.0), _s(1.0, func(gg): return gg.px > 5.0, 1, true, true), _s(1.0, func(_gg): return false, 600, false, true)]
		10:  # 4-2: 낮은 구간으로 물러나 질주, 천장 밑에서 뛰어 쾅
			return [
				_s(-1.0, func(gg): return gg.px < 1.7), _stop(),
				_s(1.0, func(gg): return gg.vx > 22.0 and gg.px < 8.5), _s(1.0, func(_gg): return true, 1, true, true),
				_s(1.0, func(_gg): return false, 600, false, true),
			]
		11:  # 4-3: 위층 질주 → 구멍 지나 멈춤 → 돌아와 낙하 → 오른콝 끝 → 왼쪽 질주 → 쾅 → X → 문
			return [
				_s(1.0, func(gg): return gg.px > 17.5), _brake(), _stop(),
				_s(-0.3, func(gg): return gg.px < 15.9, 240), _stop(),
				_s(0.0, func(gg): return not gg.on_floor, 120),
				_s(0.0, func(gg): return gg.on_floor and gg.py < 1.5, 150),
				_s(1.0, func(gg): return gg.px > 19.3, 200), _stop(),
				_s(-1.0, func(gg): return gg.vx < -25.0, 120), _s(-1.0, func(_gg): return true, 1, true, true),
				_s(-1.0, func(_gg): return false, 600, false, true),
			]
	return []
