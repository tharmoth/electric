class_name Microboss extends Enemy

const SHOT_DELAY : float = 3.0

var projectile : PackedScene = preload("res://src/boss_projectile.tscn")
var timeSinceLastShot : float = 0.0

func _ready() -> void:
	health = 150
	speed = 75

func _process(delta: float) -> void:
	var target = Character.instance.global_position
	global_position = global_position.move_toward(target, speed * delta)

	timeSinceLastShot += delta

	if timeSinceLastShot >= SHOT_DELAY:
		fire()
		timeSinceLastShot = 0

func fire() -> void:
	var offset = (%StaticBody2D/CollisionShape2D.shape.extents / 1.75)

	for i in 20:
		var bullet : Node2D = projectile.instantiate()
		var angle = ((-25 / 2) + (25 / (10 - 1)) * i)

		#bullet.get_node("Area2D").set_collision_mask_value(1, false)
		#bullet.get_node("Area2D").set_collision_mask_value(4, true)
		bullet.global_position = global_position + offset
		bullet.rotation = global_position.angle_to_point(Character.instance.global_position) + angle
		get_tree().get_root().add_child(bullet)

