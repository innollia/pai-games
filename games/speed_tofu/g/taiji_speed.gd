extends Tofu
## 강물 석판: 뗏목이 강을 내려가고 석판이 위에서 흘러온다. 석판이 손에 닿는 동안(강둑 초록 막대 사이)만 칸을 탭해 켜고 끈다. 규칙: 켜진 칸끼리·꺼진 칸끼리 이어진 영역 안의 점은 모두 같은 색. 잡기 버튼으로 석판을 붙잡아 멈추면 물살이 쌓여 놓는 순간 떠밀린다(끝까지 잡으면 손이 미끄러짐). 못 풀고 보낸 석판 3개면 끝. 구역: 여울(3×3) → 급류(4×4, 어질러짐, 빨라짐) → 두 갈래(차선 고르기).
## 나는 뗏목에 실려 강을 내려가는 사람으로서 손이 닿는 동안만 석판의 칸을 켤 수 있는 제약 속에서 칸을 켜고 꺼 석판의 규칙을 맞추지만, 석판을 붙잡아 시간을 벌면 물살이 뒤에 쌓여 놓는 순간 더 빠르게 떠밀린다.

const CS := 1.05  # 칸 한 변
const NMAX := 4
const REACH := 3.2  # 손이 닿는 구간 (뗏목 앞뒤)
const SPAWN_Z := -17.0
const GONE_Z := 8.0
const BANK := 4.5
const LANE_X := 2.0
const NSLAB := 4
const NPOST := 9
const NFOAM := 12
const COLS := [A, B, C]
const ZONE_MSG := ["", "여울", "급류", "두 갈래"]

var lives := 3
var made := 0  # 지금까지 내보낸 석판 수
var zone := 1
var flow := 2.0  # 물살
var boost := 1.0  # 떠밀림 배율
var surge := 0.0  # 잡는 동안 쌓인 물살 0..1
var grabbing := false
var slipped := false  # 미끄러진 뒤 버튼을 뗄 때까지
var since := 99.0  # 마지막 석판 뒤로 흘러간 거리
var lane := 0
var raft_x := 0.0
var tick_z := 0.0
var raft: MeshInstance3D
var rider: MeshInstance3D
var life_m: Array[MeshInstance3D] = []
var reach_m: Array[MeshInstance3D] = []
var posts: Array[MeshInstance3D] = []
var foams: Array[MeshInstance3D] = []
var rock: MeshInstance3D
var slabs: Array[Dictionary] = []


func _setup() -> void:
	howto = "뗏목이 강을 내려간다. 석판이 손에 닿는 동안(초록 막대 사이)만 칸을 탭해 켜고 끌 수 있다.\n규칙: 이어진 영역 하나 안의 점은 모두 같은 색이어야 한다. 맞추면 1점.\n잡기 버튼으로 석판을 붙잡으면 멈추지만 물살이 쌓여 놓는 순간 떠밀린다.\n못 풀고 보낸 석판 3개면 끝."
	time_limit = 0.0
	cam.fov = 48.0
	cam.position = Vector3(0, 10.5, 4.6)
	cam.look_at(Vector3(0, 0, -3.0))
	kit_button("grab", "잡기", Vector2(610, 1140), 90.0, B)


func _reset() -> void:
	box(Vector3(0, -0.3, -6), Vector3(BANK * 2.0, 0.4, 40), B)  # 물
	for s in [-1.0, 1.0]:
		box(Vector3(s * (BANK + 1.2), 0.2, -6), Vector3(2.4, 0.8, 40), SOFT)  # 강둑
	reach_m.clear()
	for s in [-1.0, 1.0]:
		var m := box(Vector3(s * (BANK + 0.3), 0.75, 0), Vector3(0.5, 0.25, REACH * 2.0), GOOD)
		reach_m.append(m)
	posts.clear()
	for i in NPOST:
		var z := SPAWN_Z + i * 3.0
		posts.append(box(Vector3(-BANK - 0.9, 1.1, z), Vector3(0.3, 1.2, 0.3), INK))
		posts.append(box(Vector3(BANK + 0.9, 1.1, z), Vector3(0.3, 1.2, 0.3), INK))
	foams.clear()
	for i in NFOAM:
		var f := box(Vector3(randf_range(-BANK + 0.3, BANK - 0.3), -0.05, randf_range(SPAWN_Z, GONE_Z)), Vector3(0.3, 0.1, 0.5), WHITE)
		foams.append(f)
	rock = box(Vector3(0, 0.3, -6), Vector3(0.9, 0.8, 40), INK)  # 두 갈래의 가운데 바위
	rock.visible = false
	raft = box(Vector3(0, 0.1, 0), Vector3(1.7, 0.25, 2.2), D)
	rider = box(Vector3(0, 0.5, 0.2), Vector3(0.55, 0.55, 0.55), ME)
	life_m.clear()
	for i in 3:
		life_m.append(box(Vector3((i - 1) * 0.45, 0.35, -0.8), Vector3(0.3, 0.3, 0.3), GOOD))
	slabs.clear()
	for i in NSLAB:
		slabs.append(_new_slab())
	lives = 3
	made = 0
	zone = 1
	flow = 2.0
	boost = 1.0
	surge = 0.0
	grabbing = false
	slipped = false
	since = 99.0
	lane = 0
	raft_x = 0.0
	tick_z = 0.0


func _new_slab() -> Dictionary:
	var root := Node3D.new()
	world.add_child(root)
	root.visible = false
	var base := box(Vector3(0, 0.2, 0), Vector3(1, 0.4, 1), SOFT, root)
	var cells: Array[MeshInstance3D] = []
	var dots: Array[MeshInstance3D] = []
	for i in NMAX * NMAX:
		cells.append(box(Vector3.ZERO, Vector3(CS - 0.1, 0.1, CS - 0.1), WHITE, root))
		dots.append(box(Vector3.ZERO, Vector3(0.32, 0.32, 0.32), A, root))
	return {"root": root, "base": base, "cells": cells, "dots": dots, "n": 3, "on": PackedInt32Array(), "dot": PackedInt32Array(),
		"live": false, "solved": false, "touched": false, "z": 0.0, "x": 0.0}


## 같은 상태로 이어진 영역마다 점 색이 하나뿐이면 true
func _valid(n: int, on: PackedInt32Array, dot: PackedInt32Array) -> bool:
	var seen := PackedInt32Array()
	seen.resize(n * n)
	seen.fill(0)
	for s in n * n:
		if seen[s] == 1:
			continue
		var col := -1
		var stack := [s]
		seen[s] = 1
		while not stack.is_empty():
			var c: int = stack.pop_back()
			if dot[c] >= 0:
				if col >= 0 and col != dot[c]:
					return false
				col = dot[c]
			var cx := c % n
			var cz := c / n
			for d in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
				var nx: int = cx + d[0]
				var nz: int = cz + d[1]
				if nx < 0 or nz < 0 or nx >= n or nz >= n:
					continue
				var k := nz * n + nx
				if seen[k] == 0 and on[k] == on[c]:
					seen[k] = 1
					stack.append(k)
	return true


## 답이 있는 석판 하나 만들기. scramble = 답에서 어질러 놓는 칸 수 (0이면 모두 꺼진 채 시작)
func _gen(sl: Dictionary, n: int, ncol: int, scramble: int) -> void:
	var sol := PackedInt32Array()
	var dot := PackedInt32Array()
	var start := PackedInt32Array()
	for tries in 60:
		sol.resize(n * n)
		dot.resize(n * n)
		dot.fill(-1)
		var ons := 0
		for i in n * n:
			sol[i] = 1 if randf() < 0.45 else 0
			ons += sol[i]
		if ons == 0 or ons == n * n:
			continue
		# 영역 나누기
		var rid := PackedInt32Array()
		rid.resize(n * n)
		rid.fill(-1)
		var regions: Array = []
		for s in n * n:
			if rid[s] >= 0:
				continue
			var cells := [s]
			var stack := [s]
			rid[s] = regions.size()
			while not stack.is_empty():
				var c: int = stack.pop_back()
				for d in [[1, 0], [-1, 0], [0, 1], [0, -1]]:
					var nx: int = c % n + d[0]
					var nz: int = c / n + d[1]
					if nx < 0 or nz < 0 or nx >= n or nz >= n:
						continue
					var k := nz * n + nx
					if rid[k] < 0 and sol[k] == sol[c]:
						rid[k] = regions.size()
						stack.append(k)
						cells.append(k)
			regions.append(cells)
		if regions.size() < 2 or regions.size() > (3 if n == 3 else 5):
			continue
		var used := {}
		for r in regions.size():
			var c := (r + randi() % ncol) % ncol if r > 0 else randi() % ncol
			used[c] = true
			var cells: Array = regions[r]
			cells.shuffle()
			var k := 1 + (1 if cells.size() >= 3 and randf() < 0.5 else 0)
			for j in mini(k, cells.size()):
				dot[cells[j]] = c
		if used.size() < 2:
			continue
		start = sol.duplicate()
		if scramble <= 0:
			start.fill(0)
		else:
			var idx := range(n * n)
			idx.shuffle()
			for j in scramble:
				start[idx[j]] = 1 - start[idx[j]]
		if _valid(n, start, dot):
			continue
		break
	if start.size() != n * n:  # 60번 다 실패(거의 없음): 점 둘을 가르는 가장 쉬운 판
		start.resize(n * n)
		start.fill(0)
		dot.resize(n * n)
		dot.fill(-1)
		dot[0] = 0
		dot[n * n - 1] = 1
	sl.n = n
	sl.on = start
	sl.dot = dot


func _spawn(sl: Dictionary, x: float, n: int, ncol: int, scramble: int) -> void:
	_gen(sl, n, ncol, scramble)
	sl.live = true
	sl.solved = false
	sl.touched = false
	sl.z = SPAWN_Z
	sl.x = x
	var w := n * CS + 0.4
	var base: MeshInstance3D = sl.base
	base.scale = Vector3(w, 0.4, w)
	base.material_override = mat(SOFT)
	for i in NMAX * NMAX:
		var cm: MeshInstance3D = sl.cells[i]
		var dm: MeshInstance3D = sl.dots[i]
		if i >= n * n:
			cm.visible = false
			dm.visible = false
			continue
		cm.visible = true
		cm.position = Vector3((i % n - (n - 1) * 0.5) * CS, 0.45, (i / n - (n - 1) * 0.5) * CS)
		dm.visible = sl.dot[i] >= 0
		if sl.dot[i] >= 0:
			dm.material_override = mat(COLS[sl.dot[i]])
	_paint(sl)
	var root: Node3D = sl.root
	root.position = Vector3(x, 0, SPAWN_Z)
	root.visible = true
	made += 1
	since = 0.0


func _paint(sl: Dictionary) -> void:
	var n: int = sl.n
	for i in n * n:
		var cm: MeshInstance3D = sl.cells[i]
		var h := 0.55 if sl.on[i] == 1 else 0.1
		cm.scale.y = h
		cm.position.y = 0.4 + h * 0.5
		cm.material_override = mat(D if sl.on[i] == 1 else WHITE)
		var dm: MeshInstance3D = sl.dots[i]
		dm.position = Vector3(cm.position.x, 0.4 + h + 0.18, cm.position.z)


func _free_slab() -> Dictionary:
	for sl in slabs:
		if not sl.live:
			return sl
	return {}


func _step(dt: float) -> void:
	# 구역
	var nz := 1 if made < 4 else (2 if made < 9 else 3)
	if nz != zone:
		zone = nz
		msg(ZONE_MSG[zone], 1.2)
		play("win")
		if zone == 3 and lane == 0:
			lane = -1
	rock.visible = zone == 3
	flow = 2.0 if zone == 1 else (2.6 + (made - 4) * 0.22 if zone == 2 else 3.4)
	# 잡기
	var want := kit_held("grab")
	if not want:
		slipped = false
	var can_grab := false
	for sl in slabs:
		if sl.live and _reachable(sl):
			can_grab = true
	if want and can_grab and not slipped:
		if not grabbing:
			grabbing = true
			beep(180.0, 0.1, 0.0, 0.2)
		surge += dt / (3.0 if zone == 1 else 2.2)
		if surge >= 1.0:
			slipped = true
			grabbing = false
			boost = 3.5
			surge = 0.0
			msg("미끄러짐")
			beep(900.0, 0.3, 200.0, 0.3)
	elif grabbing:
		grabbing = false
		boost = maxf(boost, 1.0 + surge * 2.2)
		surge = 0.0
		if boost > 1.3:
			beep(300.0, 0.25, 700.0, 0.25)
	boost = move_toward(boost, 1.0, dt * 0.7)
	var lane_mul := 1.0
	if zone == 3 and lane > 0:
		lane_mul = 1.6  # 오른쪽 차선이 빠른 물
	var v := flow * lane_mul * boost * (0.1 if grabbing else 1.0)
	rider.material_override = mat(GOOD if grabbing else ME)
	gauge(surge if grabbing else (boost - 1.0) / 2.5, BAD if grabbing else A)
	cam.fov = 48.0 + (boost - 1.0) * 5.0
	# 뗏목 차선
	raft_x = move_toward(raft_x, lane * LANE_X, dt * 6.0)
	raft.position.x = raft_x
	rider.position.x = raft_x
	for i in 3:
		life_m[i].position.x = raft_x + (i - 1) * 0.45
		life_m[i].visible = i < lives
	# 흐르는 것들
	var dz := v * dt
	for p in posts:
		p.position.z += dz
		if p.position.z > GONE_Z:
			p.position.z -= NPOST * 3.0
	for f in foams:
		f.position.z += dz * 1.15
		if f.position.z > GONE_Z:
			f.position.z = SPAWN_Z
			f.position.x = randf_range(-BANK + 0.3, BANK - 0.3)
	tick_z += dz
	if tick_z >= 3.0:
		tick_z -= 3.0
		beep(240.0, 0.03, 0.0, 0.1)
	# 석판
	var any_reach := false
	for sl in slabs:
		if not sl.live:
			continue
		sl.z += dz
		var root: Node3D = sl.root
		root.position.z = sl.z
		var r := _reachable(sl)
		if r:
			any_reach = true
			sl.touched = true
		if not sl.solved:
			sl.base.material_override = mat(WHITE if r else SOFT)
		if sl.z > REACH + 0.2 and sl.touched and not sl.solved:
			sl.touched = false
			_lose()
			if over:
				return
		if sl.z > GONE_Z:
			sl.live = false
			root.visible = false
	for m in reach_m:
		m.material_override = mat(GOOD if any_reach else SOFT)
	# 다음 석판
	since += dz
	var gap := 11.0 if zone == 1 else (maxf(8.0, 11.0 - (made - 4) * 0.5) if zone == 2 else 12.0)
	if since >= gap:
		if zone == 1:
			var sl := _free_slab()
			if not sl.is_empty():
				_spawn(sl, 0.0, 3, 2, 0)
		elif zone == 2:
			var sl := _free_slab()
			if not sl.is_empty():
				_spawn(sl, 0.0, 4, 2, 2 + randi() % 2)
		else:
			var a := _free_slab()
			if not a.is_empty():
				_spawn(a, -LANE_X, 3, 2, 0)  # 느린 차선: 새 석판
				var b := _free_slab()
				if not b.is_empty():
					_spawn(b, LANE_X, 3, 2, 1)  # 빠른 차선: 한 칸만 고치면 됨
					made -= 1


func _reachable(sl: Dictionary) -> bool:
	return absf(sl.z) < REACH and absf(sl.x - raft_x) < 1.2


func _lose() -> void:
	lives -= 1
	play("bad")
	msg("놓침")
	if lives <= 0:
		end()


func _tap(p: Vector2) -> void:
	var w := ground(p, 0.45)
	for sl in slabs:
		if not sl.live or sl.solved or not _reachable(sl):
			continue
		var n: int = sl.n
		var half := n * CS * 0.5
		var lx: float = w.x - sl.x + half
		var lz: float = w.z - sl.z + half
		if lx < -0.2 or lz < -0.2 or lx >= n * CS + 0.2 or lz >= n * CS + 0.2:
			continue
		var i := clampi(int(lx / CS), 0, n - 1) + clampi(int(lz / CS), 0, n - 1) * n
		sl.on[i] = 1 - sl.on[i]
		_paint(sl)
		if _valid(n, sl.on, sl.dot):
			sl.solved = true
			sl.base.material_override = mat(GOOD)
			score += 1
			play("good")
		else:
			beep(620.0 if sl.on[i] == 1 else 470.0, 0.05, 0.0, 0.18)
		return
	if zone == 3 and p.y > 640.0:
		var nl := -1 if p.x < 360.0 else 1
		if nl != lane:
			lane = nl
			beep(400.0, 0.06, 500.0, 0.15)
		return
	beep(160.0, 0.05, 0.0, 0.1)
