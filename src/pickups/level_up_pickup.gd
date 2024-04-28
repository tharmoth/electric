extends Node2D

var item_name : String

func init(item_name : String):
	self.item_name = item_name

func _ready() -> void:
	var texture : Texture2D
	if item_name == "pistol" || item_name == "dual_pistol":
		texture = load("res://data/sprites/gun.png")
	if item_name == "smg" || item_name == "dual_smg":
		texture = load("res://data/sprites/smg.png")
	elif item_name == "rifle":
		texture = load("res://data/sprites/rifle.png")
	elif item_name == "shotgun":
		texture = load("res://data/shotgun.png")
	elif item_name == "reload":
		texture = load("res://data/sprites/resistor.png")
		%Outline.self_modulate = Color("1eff00")
	
	%LeftWeaponSprite.texture = texture
	%RightWeaponSprite.texture = texture
	%RightWeaponSprite.visible = item_name.contains("dual")
	
	var color = %Outline.self_modulate
	%Outline.modulate = color * 4
	
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
	for node in get_tree().get_nodes_in_group("LevelUpPickup"):
		node.destroy()
		
	if item_name == "reload":
		Character.instance.stats.reload_time -= 1
		Character.instance.stats.reload_time = max(Character.instance.stats.reload_time, 0)
		FloatingLabel.show("Reload UP!", global_position, Color.WHITE)
		return
	
	Character.instance.equip_gun(item_name)
