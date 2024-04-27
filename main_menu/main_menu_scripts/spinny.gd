extends Node2D

signal turnedKnob

var following := false
const MAX_DIST := 14000

func _physics_process(delta: float) -> void:
	var mouseDist := get_global_mouse_position().distance_squared_to($knob.global_position)
	if mouseDist < MAX_DIST and Input.is_action_just_pressed("click"):
		following = true

	if Input.is_action_just_released("click"):
		following = false

	if following:
		var ang := get_global_mouse_position().angle_to_point($knob.global_position) - PI/2
		print("ang: " + String.num(ang))
		
		var d : Vector2 = ($knob/knobPoint.position.rotated($knob.rotation))
		var a = $middlePoint.position.angle_to(d)
		print("a: " + String.num(a))
		
		var finalAng : float = remap(a, -PI, PI, 0, 100)
		print("finalAng: " + String.num(finalAng))
		
		var fang : float = lerp_angle($knob.rotation, ang, 0.05)
		$knob.rotation = clamp(fang, 0, 2*PI)
		emit_signal("turnedKnob", finalAng)
		
