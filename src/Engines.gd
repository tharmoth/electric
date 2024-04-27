extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target = Character.instance.global_position
	var direction = global_position.direction_to(target).normalized()
	var target_degrees
	
	var axis = Input.get_axis("ui_left", "ui_right")
	if axis != 0:
		target_degrees = 10 if axis > 0 else -10
	else:
		target_degrees = 0

	if angle_difference(global_rotation, deg_to_rad(target_degrees)) > .01:
		global_rotation_degrees += 50 * delta
	elif angle_difference(global_rotation, deg_to_rad(target_degrees)) < .01:
		global_rotation_degrees -= 50 * delta
	else:
		global_rotation = 0
