class_name Microboss extends Enemy

const SHOT_DELAY : float = 3.0

var projectile : PackedScene = load("res://src/shotgun_particle.tscn")
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

	for i in 10:
		var bullet : Bullet = projectile.instantiate()
		var angle = ((-25 / 2) + (25 / (10 - 1)) * i)

		bullet.set_collision_mask_value(1, false)
		bullet.set_collision_mask_value(4, true)
		bullet.global_position = global_position + offset
		bullet.rotation = global_position.angle_to_point(Character.instance.global_position) + angle
		bullet.maxDistance = 800
		bullet.minDamage = 12
		bullet.maxDamage = 20
		get_tree().get_root().add_child(bullet)

