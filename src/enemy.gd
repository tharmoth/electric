class_name Enemy extends Node2D

var speed := 100.0
var dead : bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target = Character.instance.global_position
	global_position = global_position.move_toward(target, speed * delta)
	
	if global_position.distance_to(target) < 24:
		WorldTimer.instance.seek(-10)
		death_animation.kill(%Sprite2D)
		queue_free()

func on_death():
	if dead:
		return
	dead = true
	
	if (randf() > .75):
		var battery = preload("res://src/pickup.tscn").instantiate()
		WorldTimer.instance.add_child(battery)
		battery.global_position = global_position
	
	%StaticBody2D.queue_free()
	death_animation.kill(%Sprite2D)
	queue_free()
