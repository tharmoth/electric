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

# State Data
var ammo : int = 0
var reloading : bool = false
var ready_to_fire : bool = true
var spin_to_win : int = 5	

# Tweens
var knockback_tween : Tween

func _ready() -> void:
	%GunAnimationPlayer.animation_finished.connect(reload_complete)
	if weapon_type == "rifle":
		max_ammo = 24
		shots = 3
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

	if weapon_type.contains("dual"):
		max_ammo *= 2
		dual_wielding = true

	%LeftHand.visible = dual_wielding
	spin_to_win = reload_time + Character.instance.stats.reload_time
	ammo = max_ammo + Character.instance.stats.clip_bonus

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_to_position()
	if (reloading): 
		return
		
	point_at_mouse()

func can_fire() -> bool:
	return (ready_to_fire || (always_shoot_on_click && Input.is_action_just_pressed("click"))) and !reloading

func point_at_mouse() -> void:
	var mouse = get_global_mouse_position()
	global_rotation = global_position.angle_to_point(mouse)

	if mouse.x < 0:
		$RightHand.flip_v = true
		$LeftHand.flip_v = true
	else:
		$RightHand.flip_v = false
		$LeftHand.flip_v = false

func move_to_position() -> void:
	var mouse = get_global_mouse_position()
	var direction = global_position.direction_to(mouse)
	var origin = get_parent().global_position
	var target = origin + direction * 40
	
	if global_position.distance_to(target) < 1:
		global_position = target
	else:
		global_position += global_position.direction_to(target)

func reload() -> void:
	%GunAnimationPlayer.play("reload")
	reloading = true
	%GunReload.play()

func reload_complete(something):
	reloading = false
	if spin_to_win > 0:
		spin_to_win -= 1
		reload()
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
	tween.tween_interval(time_between_salvos)
	tween.tween_callback(func(): ready_to_fire = true)
	
func loose() -> void:
	ammo -= 1
	%RightHandProgressBar.value = ammo / float(max_ammo + Character.instance.stats.clip_bonus) * 100.0
	%LeftHandProgressBar.value = ammo / float(max_ammo + Character.instance.stats.clip_bonus) * 100.0

	var shoot_right = ammo % 2 == 1 && dual_wielding

	var mouse = get_global_mouse_position()
	var direction = global_position.direction_to(mouse)
	var origin = %LeftHandMarker.global_position if shoot_right else %RightHandMarker.global_position
	var target = origin + direction * 40
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin,  origin + direction * 2000)
	var result = space_state.intersect_ray(query)
	var end : Vector2
	if result:
		var node = result.collider.get_parent()
		end = result.position
		if node is Enemy:
			FloatingLabel.show(str(randi_range(5, 10)), end, Color.WHITE)
			node.on_death()
	else:
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
	emit_signal("knockback", origin - direction * 250)
	
	if ammo == 0:
		spin_to_win = reload_time + Character.instance.stats.reload_time
		reload()
	
	#var light = preload("res://src/laser_light.tscn").instantiate()
	#light.global_position = global_position
	#light.global_rotation = global_rotation + PI / 2.0
	#light.color = Color(Color.RED, 0)
	#line.add_child(light)
	#
	#var laser_tween2 = create_tween()
	#laser_tween2.tween_property(light, "color", Color.RED, .05)
	#laser_tween2.tween_property(light, "color", Color(Color.RED, 0), .3)
