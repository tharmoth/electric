extends Label

func _process(delta: float) -> void:
	if Character.score > -1:
		visible = true
	else:
		visible = false
