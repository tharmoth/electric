extends Node2D

func init(name : String):
	pass

func _ready() -> void:
	add_to_group("LevelUpPickup")
	modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1)
	tween.tween_callback(func():
		%Area2D.monitoring = true
		%Area2D.monitorable = true)

func destroy():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, .5)
	tween.tween_callback(queue_free)

func on_pickup():
	queue_free()
	Character.instance.equip_gun("rifle")
	for node in get_tree().get_nodes_in_group("LevelUpPickup"):
		node.destroy()
