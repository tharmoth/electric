extends Node

class_name TargetingUtils

static var is_using_controller : bool = false
static var should_auto_aim : bool = false

static func get_target() -> Vector2:
	if is_instance_valid(Character.instance) and should_auto_aim:
		var tree = Character.instance.get_tree()
		var nodes = tree.get_nodes_in_group("Enemy")
		var closest
		var closest_dist = INF
		for node in nodes:
			var dist = Character.instance.global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest = node
				dist = closest_dist
		return closest.global_position if is_instance_valid(closest) else Vector2.ZERO
	if is_using_controller:
		return Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down") * 20000
	if is_instance_valid(MainMenu.instance):
		return MainMenu.instance.get_global_mouse_position()
	if is_instance_valid(Character.instance):
		return Character.instance.get_global_mouse_position()

	return Vector2.ZERO


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
