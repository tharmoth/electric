extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Character.score > -1:
		visible = true
		text = str(Character.score + 1)
	else:
		visible = false
