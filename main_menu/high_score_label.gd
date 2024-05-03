extends Label

func _process(_delta: float) -> void:
	if Character.high_score > -1:
		visible = true
		text = str(Character.high_score + 1)
	else:
		visible = false
