class_name HitscanGun extends Node2D

signal shake
signal knockback(recoil: Vector2)

var knockback_tween : Tween
var max_ammo = 24
var shots = 3
var ammo : int = 0
var reloading : bool = false
var ready_to_fire : bool = true
const KNOCKBACK_FORCE : float = 250
@export var is_rifle : bool

func _ready() -> void:
	%GunAnimationPlayer.animation_finished.connect(reload_complete)
	if is_rifle:
		max_ammo = 24
		shots = 3
	else:
		max_ammo = 6
		shots = 1
	reload()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_to_position()
	if (reloading): 
		return
		
	point_at_mouse()

func can_fire() -> bool:
	return ready_to_fire and !reloading

func point_at_mouse() -> void:
	var mouse = get_global_mouse_position()
	global_rotation = global_position.angle_to_point(mouse)

	# Breaks progress bars	
	#if mouse.x < 0:
		#$Sprite2D.flip_v = true
	#else:
		#$Sprite2D.flip_v = false

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
	ammo = max_ammo

func fire() -> void:
	if !can_fire():
		return
	ready_to_fire = false
	var tween = create_tween()
	for i in range(shots):
		tween.tween_callback(loose)
		tween.tween_interval(.2)
	tween.tween_interval(.8)
	tween.tween_callback(func(): ready_to_fire = true)

	
	
func loose() -> void:
	ammo -= 1
	%ProgressBar.value = ammo / float(max_ammo) * 100.0
	print(%ProgressBar.value)

	var mouse = get_global_mouse_position()
	var direction = global_position.direction_to(mouse)
	var origin = $ParticleOrigin.global_position
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
	line.points = [global_position, end]
	line.width = 0
	line.default_color = Color(10, 0, 0, 1)
	get_parent().get_tree().root.add_child(line)
	
	var laser_tween = get_parent().get_tree().create_tween()
	laser_tween.tween_property(line, "width", 6, .05)
	laser_tween.tween_property(line, "width", 0, .3)
	laser_tween.tween_callback(func(): line.queue_free())

	%GunAudio.play()
	emit_signal("shake")
	
	var force : Vector2 = Character.instance.global_position - Character.instance.global_position.direction_to(get_global_mouse_position()).normalized() * KNOCKBACK_FORCE
	emit_signal("knockback", force)
	
	if ammo == 0:
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
