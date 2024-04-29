extends Sprite2D

@export var max : Color
@export var min : Color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var percent = Character.instance.xp / 100
	modulate = lerp(min, max, easeInCubic(percent))

func easeInCubic(percent : float) -> float:
	return percent * percent * percent
