extends Node2D

var following := false
const MAX_DIST := 32000
const MAX_TURN := 6.28
@export var audioBus : int

func _physics_process(_delta: float) -> void:
	var mouseDist := get_global_mouse_position().distance_squared_to($knob.global_position)
	var knob_rot = $knob.rotation
	
	if mouseDist < MAX_DIST and Input.is_action_just_pressed("click"):
		following = true
	
	if Input.is_action_just_released("click"):
		following = false
	
	if following:
		var ang := get_global_mouse_position().angle_to_point($knob.global_position) - PI/2
		var d : Vector2 = ($knob/knobPoint.position.rotated(knob_rot))
		var a = $middlePoint.position.angle_to(d)
		var finalAng : float = remap(a, -PI, PI, -40, 24)
		var fang : float = lerp_angle(knob_rot, ang, 0.05)
		$knob.rotation = clamp(fang, 0, 2*PI)
		AudioServer.set_bus_volume_db(1, finalAng)
