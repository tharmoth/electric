class_name Bullet extends Area2D

const SPEED : float = 500.00

var maxDistance : float = 200.00
var starting_position : Vector2 = Vector2.ZERO
var minDamage : int = 5
var maxDamage : int = 8
var piercing : int = Character.instance.stats.piercing

func _ready() -> void:
	self.connect("body_shape_entered", _on_body_entered)
	self.connect("area_entered", _on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += Vector2.from_angle(rotation) * SPEED * delta

	if starting_position.distance_to(global_position) > maxDistance:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Character:
		var dmg: int = floor(randf_range(minDamage, maxDamage))
		area.get_parent().projectile_damage(dmg)

func _on_body_entered(body_rid, body, body_shape_index, local_shape_index) -> void:
	var parent = body.get_parent()
	var isEnemy : bool = parent is Enemy || parent.is_in_group("Enemy")

	if isEnemy && parent.has_method("damage"):
		var dmg: int = floor(randf_range(minDamage, maxDamage))
		var rngVec: Vector2 = Vector2(randf_range(25, 75), randf_range(25, 75))
		parent.damage(dmg)
		piercing -= 1

		if piercing <= 0:
			queue_free()
