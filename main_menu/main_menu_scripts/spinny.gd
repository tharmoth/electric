extends Node2D

signal turnedKnob

var following := false
const MAX_DIST := 42000
const MAX_TURN := 2 * PI

var last_angle = 0
var grab : float = 0
var started : bool = false

func _physics_process(delta: float) -> void:
	var mouseDist := TargetingUtils.get_target().distance_squared_to($knob.global_position)
	var knob_rot = $knob.rotation

	%Glow.self_modulate = Color(1 + 10 * $knob.rotation_degrees / 360, 1 + 10 * $knob.rotation_degrees/ 360, 1 + 10 * $knob.rotation_degrees / 360)

	if (mouseDist < MAX_DIST || TargetingUtils.is_using_controller) and Input.is_action_just_pressed("click"):
		grab = TargetingUtils.get_target().angle_to_point($knob.global_position) - PI/2
		following = true
	
	if Input.is_action_just_released("click"):
		following = false
	
	if following:
		var ang := TargetingUtils.get_target().angle_to_point($knob.global_position) - PI/2 - grab
		var fang : float = lerp_angle(knob_rot, ang, 0.05)
		$knob.rotation = clamp(fang, 0, 2*PI)
		
		var mouse_pos := TargetingUtils.get_target()
		var knob_pos : Vector2 = $knob.global_position

		if knob_rot >= MAX_TURN:
			get_tree().create_timer(.5).timeout.connect(func(): emit_signal("turnedKnob"))
			%startNoise.play()
			%tickNoise.stop()
			following = false
			started = true
			
		if knob_rot > 0:
			%tickNoise.play()
		
	elif not started:
		%windingNoise.play()
		rotate_back()
		if knob_rot == 0:
			if %tickNoise.playing:
				%ringNoise.play()
			%tickNoise.stop()
		
func rotate_back():
	$knob.rotation = clamp($knob.rotation-0.005, 0, 2*PI)
	
func _notification(noteCode : int):
	if noteCode == NOTIFICATION_APPLICATION_FOCUS_OUT:
		AudioServer.set_bus_mute(1, true)
		AudioServer.set_bus_mute(2, true)
	elif noteCode == NOTIFICATION_APPLICATION_FOCUS_IN:
		AudioServer.set_bus_mute(1, false)
		AudioServer.set_bus_mute(2, false)
