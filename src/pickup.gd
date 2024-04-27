class_name Pickup extends Node2D

func _ready() -> void:
	add_to_group("Pickup")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_rotation = 0

func on_gameover():
	death_animation.kill(%BatterySprite)
