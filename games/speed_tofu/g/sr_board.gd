extends Control
## v44: 판 끝 결과판 (누가 이겼는지). 예전엔 외곽선 글자 몇 줄이었다 ("누가 이겼는지 통계 나올 때 UI 입혀줘").
## 마닐라 종이 카드 + 이긴 사람 색 띠 + 금 도장, 아래로 배달 많은 순: 순위 · 색 모자 칩 · 이름 · 소포 x 수 · 이 동네 승 칸.
## 그림은 게임 디자인 시스템(SrTheme)과 UI 그림(seal_gold, 소포 아이콘)만 쓴다.

const T = preload("res://g/sr_theme.gd")

const W := 640.0
const HEAD_H := 92.0
const ROW_H := 78.0
const PAD := 18.0

var head := ""
var head_col := T.GREEN
var rows: Array = []  # {name, col, got, wins, me, top}
var wins_need := 2


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


## w_name: 맨 위 글, w_col: 띠 색, list: rows (배달 많은 순)
func show_board(w_text: String, w_col: Color, list: Array, need: int) -> void:
	head = w_text
	head_col = w_col
	rows = list
	wins_need = need
	size = Vector2(W, HEAD_H + PAD * 2.0 + ROW_H * rows.size() + 10.0)
	position = Vector2((720.0 - W) * 0.5, 150.0)
	modulate = Color.WHITE
	visible = true
	queue_redraw()
	T.pop_in(self)


func _draw() -> void:
	var card := Rect2(Vector2.ZERO, size)
	T.draw_paper_rect(self, card, T.CREAM, T.WHITE, 8.0, 18.0)
	T.draw_grain(self, card.grow(-4.0), 0.1)
	# 이긴 사람 색 띠 (위가 찢긴 종이 테이프처럼)
	var band := Rect2(14.0, 14.0, W - 28.0, HEAD_H - 14.0)
	draw_rect(band, head_col)
	T.draw_torn_edge(self, Vector2(band.position.x, band.end.y), Vector2(band.end.x, band.end.y), head_col, 8.0, 7)
	T.draw_text_center(self, head, band.get_center() + Vector2(-30.0, 0.0), 46, T.ink_on(head_col), band.size.x - 150.0, 0)
	var seal := T.tex("seal_gold")
	if seal:
		var s := 112.0
		draw_set_transform(Vector2(W - 70.0, 52.0), -0.18, Vector2.ONE)
		draw_texture_rect(seal, Rect2(-s * 0.5, -s * 0.5, s, s), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var y := HEAD_H + PAD
	for i in rows.size():
		var r: Dictionary = rows[i]
		var rr := Rect2(PAD, y, W - PAD * 2.0, ROW_H - 10.0)
		if r.top:
			T.draw_paper_rect(self, rr, T.GOLD.lightened(0.55), T.GOLD, 0.0, 12.0)
		elif r.me:
			T.draw_paper_rect(self, rr, T.BLUE.lightened(0.78), T.BLUE.lightened(0.4), 0.0, 12.0)
		var cy := rr.get_center().y
		# 순위
		T.draw_text_center(self, str(i + 1), Vector2(rr.position.x + 30.0, cy), 34, T.NAVY if r.top else T.MUTED)
		# 색 모자 칩
		var cx := rr.position.x + 82.0
		draw_circle(Vector2(cx, cy + 2.0), 22.0, T.SHADOW)
		draw_circle(Vector2(cx, cy), 22.0, T.WHITE)
		draw_circle(Vector2(cx, cy), 17.0, r.col)
		# 이름
		T.draw_text_block(self, r.name, Vector2(cx + 34.0, cy - 18.0), 170.0, 30, T.NAVY, HORIZONTAL_ALIGNMENT_LEFT, 1)
		# 소포 x 배달 수
		var px := rr.position.x + 330.0
		T.draw_parcel_icon(self, Vector2(px, cy), 40.0, true)
		T.draw_text_block(self, "x %d" % int(r.got), Vector2(px + 28.0, cy - 22.0), 90.0, 40, T.NAVY, HORIZONTAL_ALIGNMENT_LEFT, 1)
		# 이 동네 승 칸 (금 별 = 이긴 판)
		for k in wins_need:
			var c := Vector2(rr.end.x - 30.0 - (wins_need - 1 - k) * 46.0, cy)
			var on: bool = k < int(r.wins)
			draw_circle(c + Vector2(0, 2), 18.0, T.SHADOW)
			draw_circle(c, 18.0, T.GOLD if on else T.EMPTY_SLOT)
			draw_arc(c, 18.0, 0.0, TAU, 24, T.WHITE, 3.0)
			if on:
				T.draw_text_center(self, "★", c, 22, T.WHITE)
		y += ROW_H
