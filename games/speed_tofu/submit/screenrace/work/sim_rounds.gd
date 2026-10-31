extends SceneTree
## 판 끝 배달 수 확인 (머리 없이): 나는 (a) 가만히, (b) 대시만 하고 금 우체통에만 넣기. 첫 동네 첫 판을 여러 번.
## (games/speed_tofu 에서) godot --headless --path . --fixed-fps 60 -s submit/screenrace/work/sim_rounds.gd -- idle|dash [판 수]

var g: Tofu


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var a := OS.get_cmdline_user_args()
	var how: String = a[0] if a.size() > 0 else "idle"
	var n: int = int(a[1]) if a.size() > 1 else 4
	for k in n:
		g = load("res://g/screenrace.gd").new()
		g.id = "screenrace"
		root.add_child(g)
		for i in 30:
			await process_frame
		g.records.set_value("opt", "tutorial_done", true)
		g.front.hide_title()
		g._open_mode_select()
		var f := 0
		while g.phase != "race" and f < 900:
			f += 1
			await process_frame
		var held := false
		var seen := {}
		var gos := {}
		var last := {}
		f = 0
		while g.phase == "race" and f < 60 * 120:
			f += 1
			if how == "dash":
				if not held:
					g._finger(1, Vector2(170, 1100), 1)
					g._finger(1, Vector2(280, 1100), 0)
					held = true
				var mi: int = g._mb_near_pl(g.pl)
				var gold: bool = mi >= 0 and int(g.mailboxes[mi].val) > 1
				if (mi < 0 or gold) and g.pl.cargo > 0 and (gold or g.pl.dash_cd <= 0.0) and f % 6 == 0:
					g._finger(2, g._btns["drop"].pos, 1)
				elif f % 6 == 3:
					g._finger(2, g._btns["drop"].pos, -1)
			await process_frame
			for r in g.runners:
				if r.ai and r.mb_seen != int(last.get(r.nick, -9)):
					last[r.nick] = r.mb_seen
					if r.mb_seen >= 0:
						seen[r.nick] = int(seen.get(r.nick, 0)) + 1
						gos[r.nick] = int(gos.get(r.nick, 0)) + (1 if r.mb_go else 0)
		print("  본 우체통 ", seen, " 넣기로 ", gos, " mb ", g.mailboxes.size())
		print("%s #%d ci %d 1등 %s  " % [how, k, g.ci, g._deliv_order()[0].nick], g.runners.map(func(r): return "%s %d(짐%d,넣%d,도착%d)" % [r.nick, r.got, r.cargo, r.posts, r.fin]))
		g.queue_free()
		await process_frame
	quit()
