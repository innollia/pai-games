extends "res://g/screenrace.gd"
## 경제 실험판: 상대 배달 확률 x0.5 (나머지는 screenrace 그대로)


func _init() -> void:
	tune = {"ai": 0.5}
