extends Node2D

var _timer : float = 0
const COOLDOWN : float = 4
var should_shoot_right : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_timer += delta
	if (_timer < COOLDOWN):
		return
	_timer = 0
	fire()

func fire() -> void:
	var tween = create_tween()
	var right_tween = create_tween()
	for i in range(3):
		tween.tween_callback(loose)
		right_tween.tween_interval(.05 + randf_range(0, .05))
		right_tween.tween_callback(loose)
		tween.tween_interval(.1)
		right_tween.tween_interval(.1)
		
	tween.tween_interval(0)
	
func loose() -> void:
	var shoot_right = should_shoot_right
	should_shoot_right = ! should_shoot_right

	var mouse = Vector2.from_angle(rotation) * 20000
	var direction = global_position.direction_to(mouse)
	var origin = %LeftHandMarker.global_position if shoot_right else %RightHandMarker.global_position
	var target = origin + direction * 40
	
	var space_state = get_world_2d().direct_space_state
	
	var exclude : Array[RID] = []
	var end : Vector2
	var last : Vector2

	for i in range(1):
		var query = PhysicsRayQueryParameters2D.create(origin,  origin + direction * 2000, 0xFFFFFFFF, exclude)
		var result = space_state.intersect_ray(query)
		if result:
			var node = result.collider.get_parent()
			end = result.position
			exclude.append(result.rid)

		if not end:
			end = mouse
		
		var line = Line2D.new()
		line.points = [origin, end]
		line.width = 0
		line.default_color = Color(10, 0, 0, 1)
		get_parent().get_tree().root.add_child(line)

		var laser_tween = get_parent().get_tree().create_tween()
		laser_tween.tween_property(line, "width", 6*7.5, .05)
		laser_tween.tween_property(line, "width", 0, .3)
		laser_tween.tween_callback(func(): line.queue_free())
