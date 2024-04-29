extends Node2D

var item_name : String
var items : Array[String] = ["pistol", "rifle", "smg", "shotgun", "reload", "clip_size"]
var weapons : Array[String] = ["pistol", "rifle", "smg", "shotgun", "tesla_gun"]
var passives : Array[String] = ["reload", "clip_size", "piercing", "fire_speed", "shoulder_laser"]

func init(item_name : String):
	init_ignore(item_name, "")
	
func init_ignore(item_name : String, exclude : String):
	init_ignore2(item_name, exclude, "")

func init_ignore2(item_name : String, exclude : String, exclude2 : String):
	
	var valid_items : Array[String]
	if item_name == "weapon":
		valid_items = weapons
		
		var current = Character.instance.currentGun.weapon_type
		if current in weapons:
			valid_items.erase(current)
		if current == "pistol":
			valid_items.append("dual_pistol")
		if current == "smg":
			valid_items.append("dual_smg")
	else:
		valid_items = passives
	
	if exclude in passives:
		valid_items.erase(exclude)
	if exclude2 in passives:
		valid_items.erase(exclude2)
		
	self.item_name = valid_items[randi_range(0, valid_items.size() - 1)]

func _ready() -> void:
	add_to_group("LevelUpPickup")
	
	var texture : Texture2D
	if item_name == "pistol" || item_name == "dual_pistol":
		texture = load("res://data/sprites/gun.png")
	if item_name == "smg" || item_name == "dual_smg":
		texture = load("res://data/sprites/smg.png")
	elif item_name == "rifle":
		texture = load("res://data/sprites/rifle.png")
	elif item_name == "shotgun":
		texture = load("res://data/sprites/shotgun.png")
		texture = load("res://data/sprites/shotgun.png")
	elif item_name == "tesla_gun":
		texture = load("res://data/sprites/tesla_gun.png")
	elif item_name == "reload":
		texture = load("res://data/sprites/reload_up.png")
		%Outline.self_modulate = Color("ff8000")
	elif item_name == "clip_size":
		texture = load("res://data/sprites/capactior.png")
		%Outline.self_modulate = Color("9d9d9d")
	elif item_name == "shoulder_laser":
		texture = load("res://data/sprites/shoulder_laser.png")
	elif item_name == "piercing":
		texture = load("res://data/sprites/resistor.png")
		%Outline.self_modulate = Color("e6cc80")
	elif item_name == "fire_speed":
		texture = load("res://data/sprites/inductor.png")
		%Outline.self_modulate = Color("1eff00")
	
	if item_name.contains("dual"):
		%Outline.self_modulate = Color("a335ee")
	
	%LeftWeaponSprite.texture = texture
	%RightWeaponSprite.texture = texture
	%RightWeaponSprite.visible = item_name.contains("dual")
	
	var color = %Outline.self_modulate
	%Outline.modulate = color * 4
	
	add_to_group("LevelUpPickup")
	modulate = Color.TRANSPARENT
	var tween = create_tween()
	var area = %Area2D
	call_deferred("remove_child", area)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, .5)
	tween.tween_callback(func():
		area.monitoring = true
		area.monitorable = true
		add_child(area))
	

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
		var message = "Reload Speed UP!"
		FloatingLabel.show(message, global_position, Color.WHITE)
		Character.instance.upgrade_audio.play()
		return
	elif item_name == "clip_size":
		Character.instance.stats.clip_bonus += 1
		Character.instance.stats.clip_bonus = max(Character.instance.stats.clip_bonus, 0)
		var message = "Clip Size UP!"
		FloatingLabel.show(message, global_position, Color.WHITE)
		Character.instance.upgrade_audio.play()
		return
	elif item_name == "piercing":
		Character.instance.stats.piercing += 1
		Character.instance.stats.piercing = max(Character.instance.stats.piercing, 0)
		var message = "piercing UP!"
		FloatingLabel.show(message, global_position, Color.WHITE)
		Character.instance.upgrade_audio.play()
		return
	elif item_name == "fire_speed":
		Character.instance.stats.fire_speed_mult -= .15
		Character.instance.stats.fire_speed_mult = clamp(Character.instance.stats.fire_speed_mult, .25, 2)
		var message = "Fire Rate UP!"
		FloatingLabel.show(message, global_position, Color.WHITE)
		Character.instance.upgrade_audio.play()
		return
	elif item_name == "shoulder_laser":
		# Adds shoulder laser to stats inside this method instead
		Character.instance.add_shoulder_laser()
		var message = "+1 Shoulder Lasers!"
		FloatingLabel.show(message, global_position, Color.WHITE)
		Character.instance.upgrade_audio.play()
		return
	
	Character.instance.equip_gun(item_name)
