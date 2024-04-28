extends Node2D

func _on_reload_timeout() -> void:
	$Reload.set_wait_time(8.0 / Character.instance.stats.shoulder_lasers)
	var enemies = get_tree().get_nodes_in_group("Enemy")
	print("boom! " + str($Reload.get_wait_time()))
	for enemy in enemies:
		var origin = global_position
		var target = enemy.global_position
		if origin.distance_to(target) < 1000:
			var line = Line2D.new()
			line.points = [origin, target]
			print(str(origin) + " " + str(target))
			line.width = 0
			line.default_color = Color(10, 0, 0, 1)
			get_parent().get_tree().root.add_child(line)
			
			var laser_tween = get_parent().get_tree().create_tween()
			laser_tween.tween_property(line, "width", 6, .05)
			laser_tween.tween_property(line, "width", 0, .3)
			laser_tween.tween_callback(func(): line.queue_free())
			enemy.damage(5)
			break
