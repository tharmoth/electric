extends Node

const DEADZONE : float = .01

func _input(event: InputEvent) -> void:
	
	if event is InputEventJoypadMotion:
		print(event.axis_value)
	
	if event is InputEventJoypadButton:
		TargetingUtils.is_using_controller = true;
	elif event is InputEventJoypadMotion and abs(event.axis_value) > DEADZONE:
		TargetingUtils.is_using_controller = true;
	elif event is InputEventKey or InputEventMouse:
		TargetingUtils.is_using_controller = false;
