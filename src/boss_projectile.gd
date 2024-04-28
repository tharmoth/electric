extends Node2D

const SPEED : float = 500.00

var maxDistance : float = 800.00
var minDamage : int = 12
var maxDamage : int = 20
var startingPosition : Vector2 = Vector2.ZERO

func _ready() -> void:
	%VisibleOnScreenEnabler2D.connect("screen_exited", func() -> void: queue_free())
	%Area2D.connect("area_entered", _on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += Vector2.from_angle(rotation) * SPEED * delta

	if startingPosition.distance_to(global_position) > maxDistance:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Character:
		var dmg: int = floor(randf_range(minDamage, maxDamage))
		area.get_parent().projectile_damage(dmg)
