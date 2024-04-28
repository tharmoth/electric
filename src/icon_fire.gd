extends Node2D

var _timer : float = 0
const COOLDOWN : float = 3
var time_between_salvos : float = .8
var time_between_shots : float  = .2
@export var disabled : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if disabled:
		return
	_timer += delta
	if (_timer < COOLDOWN):
		return
	_timer = 0
	
	var tween = create_tween()
	for i in range(3):
		tween.tween_callback(loose)
		tween.tween_interval(time_between_shots + .2)

func loose() -> void:
	var mouse = %RightHandMarker2.global_position + Vector2.RIGHT * 1000
	var direction = global_position.direction_to(mouse)
	var origin = %RightHandMarker2.global_position
	var target = origin + direction * 40
	
	var space_state = get_world_2d().direct_space_state
	
	var exclude : Array[RID] = []
	var end : Vector2

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

	%AnimationPlayer.play("shake")
	#%GunAudio.play()
	#emit_signal("shake")
