extends Sprite2D


var timer : float = 0
var blink_time : float = 3.0 # seconds


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if (timer < blink_time):
		return
	timer = 0
	
	if visible:
		blink_time = .2
	else:
		blink_time = randf_range(2, 5) 
	visible = !visible
	
