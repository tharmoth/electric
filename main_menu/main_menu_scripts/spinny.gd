extends Node2D

signal turnedKnob

var following := false
const MAX_DIST := 14000
const MAX_TURN := 6.28

func _physics_process(delta: float) -> void:
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
		var finalAng : float = remap(a, -PI, PI, 0, 100)
		var fang : float = lerp_angle(knob_rot, ang, 0.05)
		$knob.rotation = clamp(fang, 0, 2*PI)
		
		if knob_rot >= MAX_TURN:
			get_tree().create_timer(.5).timeout.connect(func(): emit_signal("turnedKnob"))
			
		if knob_rot > 0:
			$AudioStreamPlayer2D.play()
		
	else:
		rotate_back()
		if knob_rot == 0:
			$AudioStreamPlayer2D.stop()
		
func rotate_back():
	$knob.rotation = clamp($knob.rotation-0.005, 0, 2*PI)
