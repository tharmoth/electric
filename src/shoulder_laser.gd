extends Node2D

func _ready() -> void:
	$Reload.set_wait_time(8.0 / Character.instance.stats.shoulder_lasers)
	$Reload.start()

func _on_reload_timeout() -> void:
	$Reload.set_wait_time(8.0 / Character.instance.stats.shoulder_lasers)
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		var origin = global_position
		var target = enemy.global_position
		if origin.distance_to(target) < 300:
			$laserNoise.play()
			var line = Line2D.new()
			line.points = [origin, target]
			line.width = 0
			line.default_color = Color(0, 0, 10, 1)
			get_parent().get_tree().root.add_child(line)
			
			var laser_tween = get_parent().get_tree().create_tween()
			laser_tween.tween_property(line, "width", 6, .05)
			laser_tween.tween_property(line, "width", 0, .3)
			laser_tween.tween_callback(func(): line.queue_free())
			enemy.damage(30)
			break


func _process(delta: float) -> void:
	%AmmoCapacity.value = 100 - ($Reload.time_left / (8.0 / Character.instance.stats.shoulder_lasers) * 100)
	var tree = get_tree()
	var nodes = tree.get_nodes_in_group("Enemy")
	var closest
	var closest_dist = INF
	for node in nodes:
		var dist = Character.instance.global_position.distance_to(node.global_position)
		if dist < closest_dist:
			closest = node
			closest_dist = dist
	var target = closest.global_position if is_instance_valid(closest) else Vector2.ZERO
	var target_angle = %Sprite2D.global_position.angle_to_point(target) - deg_to_rad(45)
	%Sprite2D.global_rotation = rotate_toward(%Sprite2D.global_rotation, target_angle, delta * deg_to_rad(360))

	#if target.x < 0:
		#%Sprite2D.flip_v = true
	#else:
		#%Sprite2D.flip_v = false
