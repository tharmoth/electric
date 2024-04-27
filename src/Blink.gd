extends Sprite2D


var timer : float = 0
var blink_time : float = 3.0 # seconds

func blink():
	timer = 0
	blink_time = .2
	visible = false

func open():
	timer = 0
	blink_time = randf_range(2, 5) 
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if (timer < blink_time):
		return
	timer = 0
	
	blink() if visible else open()
