class_name HitscanGun extends Node2D

signal shake
signal knockback(recoil: Vector2)

# Weapon Stats
@export var weapon_type : String = "pistol"
var max_ammo : int = 24
var shots : int = 3
var time_between_salvos : float = .8
var time_between_shots : float  = .2
var reload_time : int = 0
var dual_wielding : bool = false
var always_shoot_on_click : bool = false
var damage : Vector2 = Vector2(5, 10)
var knockback_amount : float = 250

# State Data
var ammo : int = 0
var reloading : bool = false
var reload_started : bool = false
var ready_to_fire : bool = true
var reload_spin_count : int = 5	

# Tweens
var knockback_tween : Tween

func _ready() -> void:
	%GunAnimationPlayer.animation_finished.connect(reload_complete)
	if weapon_type == "rifle":
		max_ammo = 24
		shots = 3
		damage = Vector2(9, 20)
	elif weapon_type == "pistol" || weapon_type == "dual_pistol":
		max_ammo = 6
		shots = 1
		always_shoot_on_click = true
	elif weapon_type == "smg" || weapon_type == "dual_smg":
		max_ammo = 12
		shots = 1
		time_between_shots = .1
		time_between_salvos = 0
		reload_time = 3
	elif weapon_type == "tesla_gun":
		max_ammo = 8
		shots = 1
		time_between_shots = 1
		time_between_salvos = 0
		reload_time = 3
		damage = Vector2(20, 25)
		knockback_amount = 1100

	if weapon_type.contains("dual"):
		max_ammo *= 2
		dual_wielding = true

	%LeftHand.visible = dual_wielding
	reload_spin_count = reload_time + Character.instance.stats.reload_time
	ammo = max_ammo + Character.instance.stats.clip_bonus

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	move_to_position()
	if (reloading): 
		return
		
	point_at_mouse()

func can_fire() -> bool:
	return (ready_to_fire || (always_shoot_on_click && Input.is_action_just_pressed("click"))) and !reloading

func point_at_mouse() -> void:
	var mouse = TargetingUtils.get_target()
	global_rotation = global_position.angle_to_point(mouse)

	if mouse.x < 0:
		$RightHand.flip_v = true
		$LeftHand.flip_v = true
	else:
		$RightHand.flip_v = false
		$LeftHand.flip_v = false

func move_to_position() -> void:
	var mouse = TargetingUtils.get_target()
	var direction = global_position.direction_to(mouse)
	var origin = get_parent().global_position
	var target = origin + direction * 40
	
	if global_position.distance_to(target) < 1:
		global_position = target
	else:
		global_position += global_position.direction_to(target)

func _reload_spin() -> void:
	%GunAnimationPlayer.play("reload")
	# Only play sound once for tesla gun
	reloading = true
	if weapon_type == "tesla_gun" && reload_started:
		return
	else:
		%GunReload.play()
		reload_started = true

func reload_complete(_something):
	reloading = false
	if reload_spin_count > 0:
		reload_spin_count -= 1
		_reload_spin()
	else:
		reload_started = false
	ammo = max_ammo + Character.instance.stats.clip_bonus

func fire() -> void:
	if !can_fire():
		return
	ready_to_fire = false
	var tween = create_tween()
	var right_tween = create_tween()
	for i in range(shots + Character.instance.stats.burst_bonus):
		tween.tween_callback(loose)
		if dual_wielding:
			right_tween.tween_interval(.05 + randf_range(0, .05))
			right_tween.tween_callback(loose)
		tween.tween_interval(time_between_shots)
		right_tween.tween_interval(time_between_shots)
		
		
	var time_to_wait = time_between_salvos * Character.instance.stats.fire_speed_mult
	tween.tween_interval(time_to_wait)
	tween.tween_callback(func(): ready_to_fire = true)
	
func loose() -> void:
	ammo -= 1
	Character.instance.charge_ammo.value = ammo / float(max_ammo + Character.instance.stats.clip_bonus) * 100.0
	Character.instance.charge_ammo.value = ammo / float(max_ammo + Character.instance.stats.clip_bonus) * 100.0

	var shoot_right = ammo % 2 == 1 && dual_wielding

	var mouse = TargetingUtils.get_target()
	var direction = global_position.direction_to(mouse)
	var origin = %LeftHandMarker.global_position if shoot_right else %RightHandMarker.global_position
	
	var space_state = get_world_2d().direct_space_state
	
	var exclude : Array[RID] = []
	var end : Vector2
	var last : Vector2
	if weapon_type == "tesla_gun":
		var query = PhysicsRayQueryParameters2D.create(origin,  origin + direction * 2000, 0xFFFFFFFF, exclude)
		var result = space_state.intersect_ray(query)
		var lightning_damage = Vector2(damage.x * 0.8, damage.y * 0.8)
		if result:
			var node = result.collider.get_parent()
			end = result.position
			exclude.append(result.rid)
			if not end:
				end = mouse
			TargetingUtils.drawLightning(origin, end)
			last = end
			if node is Enemy:
				node.damage(randi_range(lightning_damage.x, lightning_damage.y))
				var excludeLightning : Array[Node2D] = [node]
				for n in range(Character.instance.stats.piercing + 2):
					# Gets a enemy node in range if exists
					#var previous_node_pos : Vector2 
					node = TargetingUtils.getEnemyInRange(node, 250, excludeLightning)
					if node != null:
						node.damage(randi_range(5, 10))
						excludeLightning.append(node)
						TargetingUtils.drawLightning(node.global_position, last)
					else:
						break
					
					last = node.global_position

	else:
		for i in range(Character.instance.stats.piercing + 1):
			var query = PhysicsRayQueryParameters2D.create(origin,  origin + direction * 2000, 0xFFFFFFFF, exclude)
			var result = space_state.intersect_ray(query)
			if result:
				var node = result.collider.get_parent()
				end = result.position
				exclude.append(result.rid)
				if node is Enemy:
					node.damage( randi_range(damage.x, damage.y))

		if not end:
			end = mouse
		
		var line = Line2D.new()
		line.points = [origin, end]
		line.width = 0
		line.default_color = Color(10, 0, 0, 1)
		get_parent().get_tree().root.add_child(line)

		var laser_tween = get_parent().get_tree().create_tween()
		laser_tween.tween_property(line, "width", 6, .05)
		laser_tween.tween_property(line, "width", 0, .3)
		laser_tween.tween_callback(func(): line.queue_free())

	%GunAudio.play()
	emit_signal("shake")
	emit_signal("knockback", origin - direction * knockback_amount)
		
	if ammo == 0:
		reload()
	

func reload():
	reload_spin_count = reload_time + Character.instance.stats.reload_time
	var tween = create_tween()
	tween.tween_property(Character.instance.charge_ammo, "value", 100, (reload_spin_count) * .4)
	_reload_spin()
