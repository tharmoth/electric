extends Node2D

func _ready() -> void:
	add_to_group("LevelUpPickup")
	modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, .5)

func destroy():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, .5)
	tween.tween_callback(queue_free)

func on_pickup():
	queue_free()
	Character.instance.equip_gun("rifle")
	for node in get_tree().get_nodes_in_group("LevelUpPickup"):
		node.destroy()
