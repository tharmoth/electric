class_name Pickup extends Node2D

const SPEED : float = 100

func _ready() -> void:
	add_to_group("Pickup")
	%Area2D.area_entered.connect(on_pickup)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_rotation = 0
	var distance = global_position.distance_to(Vector2.ZERO)
	if distance > 400:
		global_position = global_position.move_toward(Vector2.ZERO, SPEED * delta)

func on_pickup(area : Area2D):
	queue_free()
	Character.instance.score += 1
	WorldTimer.instance.seek(10)
	if Character.instance.xp < 100:
		Character.instance.xp += 12.5
	
	if Character.instance.xp >= 100:
		Character.instance.on_level_up()

func on_gameover():
	%BounceNode.queue_free()
	death_animation.kill(%BatterySprite)
	queue_free()
