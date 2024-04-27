class_name FloatingLabel

static func show(text : String, position : Vector2, color : Color):
	var label : Label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	label.text = text
	label.global_position = position
	label.z_index = 100
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.scale = Vector2.ZERO
	label.add_theme_constant_override("outline_size", 10)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	var tree = Character.instance.get_tree()
	tree.root.add_child(label)
	
	var position_tween = tree.create_tween()
	position_tween.tween_property(label, "scale", Vector2.ONE * 2, .1)
	position_tween.tween_property(label, "scale", Vector2.ONE, .5)
	position_tween.tween_property(label, "scale", Vector2.ONE * .4, .4)
	position_tween.tween_callback(func(): label.queue_free())
	
	var color_tween = tree.create_tween()
	color_tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 1.0)
	
	var wiggle_tween = tree.create_tween()
	wiggle_tween.tween_property(label, "rotation_degrees", randf_range(-10, 10), .1)
	wiggle_tween.tween_property(label, "rotation_degrees", randf_range(-10, 10), .1)
	wiggle_tween.tween_property(label, "rotation_degrees", 0, .1)
