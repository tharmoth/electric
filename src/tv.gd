extends Node2D

func kill():
	%static.queue_free()
	for node in get_children():
		if node is Node2D:
			death_animation.kill(node)

func set_static_color(color : Color):
	$static.self_modulate = color
