class_name WorldTimer extends Node2D

static var instance : WorldTimer

var max_spin = 415.0

func _enter_tree() -> void:
	instance = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var music_length_seconds = %Music.stream.get_length()
	rotation_degrees += max_spin / music_length_seconds * delta

	if (rotation_degrees > max_spin):
		print("game over")
		get_tree().paused = true
		%GameOver.visible = true

func seek(degrees : float):
	var music_length := 104 #seconds
	var rotation = %Timer.rotation_degrees
	var percent_complete = max(rotation / (max_spin - 10), 0)

	var timerTween = create_tween()
	timerTween.tween_property(%Timer, "rotation_degrees", %Timer.rotation_degrees - degrees, 1)
	
	%RecordScratch.play()
	if (percent_complete > 1):
		return
	%Music.seek(music_length * percent_complete)
