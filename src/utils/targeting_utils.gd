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
	line.width = 100
	line.default_color = Color("4763ff")
	line.modulate = Color(10, 10, 10)
	line.texture = preload("res://data/particles/spark_07.png")
	line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	line.self_modulate = Color.TRANSPARENT
	Character.instance.get_tree().root.add_child(line)
	
			#if weapon_type == "tesla_gun":
			#
			#
			#line.default_color = Color(10, 0, 0, 1)
			#line.width = 6
			#var laser_tween = get_parent().get_tree().create_tween()
			#laser_tween.tween_interval(.35)
			#laser_tween.tween_callback(func(): line.queue_free())
	
	var laser_tween = Character.instance.get_parent().get_tree().create_tween()
	laser_tween.tween_property(line, "self_modulate", Color.WHITE, .05)
	laser_tween.tween_property(line, "self_modulate", Color.TRANSPARENT, .3)
	laser_tween.tween_callback(func(): line.queue_free())
