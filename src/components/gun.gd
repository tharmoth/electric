extends Sprite2D

var knockback_tween : Tween
var ammo : int = 6

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	move_to_position()
	if Input.is_action_just_pressed("click"):
		ammo -= 1
		if (ammo == 0):
			reload()
		else:
			fire()
		#var fire_tween = create_tween()
		#fire_tween.tween_callback(fire)
		#fire_tween.tween_interval(.2)
		#fire_tween.tween_callback(fire)
		#fire_tween.tween_interval(.2)
		#fire_tween.tween_callback(fire)


func move_to_position() -> void:
	var mouse = get_global_mouse_position()
	var direction = global_position.direction_to(mouse)
	var origin = get_parent().global_position
	var target = origin + direction * 20
	
	if global_position.distance_to(target) < 1:
		global_position = target
	else:
		global_position += global_position.direction_to(target)
		
	global_rotation = global_position.angle_to_point(mouse)

func reload() -> void:
	%g

func fire() -> void:
	var mouse = get_global_mouse_position()
	var direction = global_position.direction_to(mouse)
	var origin = get_parent().global_position
	var target = origin + direction * 20
	
	var space_state =  get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position + direction * 10,  direction * 2000)
	var result = space_state.intersect_ray(query)
	var end : Vector2
	if result:
		var node = result.collider.get_parent()
		if node is Enemy:
			node.on_death()
		end = result.position
	else:
		end = direction * 2000
	
	var line = Line2D.new()
	line.points = [global_position, end]
	line.width = 0
	line.default_color = Color.RED
	get_tree().root.add_child(line)
	
	var laser_tween = create_tween()
	laser_tween.tween_property(line, "width", 6, .05)
	laser_tween.tween_property(line, "width", 0, .3)
	laser_tween.tween_callback(func(): line.queue_free())

	%Camera2D/AnimationPlayer.play("shake")
	%GunAudio.play()
	
	if knockback_tween:
		knockback_tween.kill()

	knockback_tween = create_tween()
	get_parent().knockback = origin - direction * 250;
	knockback_tween.set_ease(Tween.EASE_OUT)
	knockback_tween.set_trans(Tween.TRANS_CUBIC)
	knockback_tween.tween_property(get_parent(), "knockback", Vector2.ZERO, .25)
	
	#var light = preload("res://src/laser_light.tscn").instantiate()
	#light.global_position = global_position
	#light.global_rotation = global_rotation + PI / 2.0
	#light.color = Color(Color.RED, 0)
	#line.add_child(light)
	#
	#var laser_tween2 = create_tween()
	#laser_tween2.tween_property(light, "color", Color.RED, .05)
	#laser_tween2.tween_property(light, "color", Color(Color.RED, 0), .3)