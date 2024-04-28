extends Node

class_name TargetingUtils

static func getEnemyInRange(originNode: Node2D, range: int, excludeLightning: Array[Node2D]) -> Node2D:
	var enemies = Character.instance.get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		var origin = originNode.global_position
		var target = enemy.global_position
		if origin.distance_to(target) < range && !excludeLightning.has(enemy):
			return enemy
	return null # no enemies in range!

static func drawLightning(origin: Vector2, end: Vector2) -> void:
	var line = Line2D.new()
	line.points = [origin, end]
	line.width = 0
	line.default_color = Color('aqua')
	Character.instance.get_tree().root.add_child(line)
	
	var laser_tween = Character.instance.get_parent().get_tree().create_tween()
	laser_tween.tween_property(line, "width", 6, .05)
	laser_tween.tween_property(line, "width", 0, .3)
	laser_tween.tween_callback(func(): line.queue_free())
