extends "res://g/screenrace.gd"
## 경제 실험판: 따라잡기(뒤처진 주자 속도 보너스) x0.5 (나머지는 screenrace 그대로)


func _init() -> void:
	tune = {"catchup": 0.5}
