extends Node2D

var item_name : String
var items : Array[String] = ["pistol", "rifle", "smg", "shotgun", "reload", "clip_size"]
var weapons : Array[String] = ["pistol", "rifle", "smg", "shotgun"]
var passives : Array[String] = ["reload", "clip_size"]

func init(item_name : String):
	if item_name == "weapon":
		self.item_name = weapons[randi_range(0, items.size() - 1)]
		if self.item_name == "pistol" && Character.instance.currentGun.weapon_type == "pistol":
			self.item_name = "dual_pistol"
		elif self.item_name == "smg" && Character.instance.currentGun.weapon_type == "smg":
			self.item_name = "dual_smg"
	else:
		self.item_name = passives[randi_range(0, items.size() - 1)]

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
	elif item_name == "clip_size":
		texture = load("res://data/sprites/inductor.png")
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
		var bonus = Character.instance.stats.clip_bonus
		var message = "Reload Speed UP! (" + str(abs(bonus-1)) + " -> " + str(abs(bonus)) + ")"
		FloatingLabel.show(message, global_position, Color.WHITE)
		return
	elif item_name == "clip_size":
		Character.instance.stats.clip_bonus += 1
		Character.instance.stats.clip_bonus = min(Character.instance.stats.clip_bonus, 0)
		var bonus = Character.instance.stats.clip_bonus
		var message = "Clip Size UP! (" + str(bonus-1) + " -> " + str(bonus) + ")"
		FloatingLabel.show(message, global_position, Color.WHITE)
		return
	
	Character.instance.equip_gun(item_name)
