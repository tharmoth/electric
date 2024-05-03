class_name WorldTimer extends Node2D

static var instance : WorldTimer

var max_spin = 360.0
var is_game_over = false
var bonus_rotation : float = 0
var time_elapsed : float = 0

func _enter_tree() -> void:
	instance = self

func move_toward_angle(from : float, to: float, delta : float):
	var ans = fposmod(to - from, TAU)
	if ans > PI:
		ans -= TAU
	return from + ans * delta

func _process(delta: float) -> void:
	time_elapsed += delta
	if is_game_over:
		rotation_degrees = -360
		return
	var music_length_seconds = %Music.stream.get_length()
	
	if (abs(bonus_rotation) > 0):
		var amount_to_bonus_rotate = clamp(60 * delta, 0, abs(bonus_rotation))
		amount_to_bonus_rotate *= sign(bonus_rotation)
		bonus_rotation -= amount_to_bonus_rotate
		rotation_degrees += amount_to_bonus_rotate

	rotation_degrees -= max_spin / music_length_seconds * delta
	rotation_degrees = clamp(rotation_degrees, -361, 0)

	if (rotation_degrees < -max_spin):
		game_over()

func game_over():
	var audio : AudioStreamPlayer = %Music
	var stream : AudioStream = audio.stream
	if (audio.get_playback_position() < stream.get_length() - 5):
		%Music.seek(stream.get_length() - 5)

	is_game_over = true
	for node in get_tree().get_nodes_in_group("Enemy"):
		node.on_gameover()
		
	for node in get_tree().get_nodes_in_group("Character"):
		node.on_gameover()
		
	for node in get_tree().get_nodes_in_group("Pickup"):
		node.on_gameover()
		
	if Character.instance.score > Character.instance.high_score:
		Character.instance.high_score = Character.instance.score
		%HighScore.visible = true
	
	#get_tree().paused = true
	%GameOverGui.visible = true
	get_tree().create_timer(5, true).timeout.connect(return_to_menu)

func return_to_menu():
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
	#get_tree().paused = false

func get_minutes_elapsed() -> int:
	return floori(WorldTimer.instance.time_elapsed / 60)

func get_current_time() -> float:
	return to_timer(rotation_degrees)

func to_timer(degrees : float): 
	return 60 * degrees / 360

func seek(degrees : float):
	bonus_rotation += degrees
	
	var audio : AudioStreamPlayer = %Music
	var stream : AudioStream = audio.stream

	var music_length := stream.get_length() #seconds
	var rot = %Timer.rotation_degrees + bonus_rotation
	rot = -clamp(rot, -360, 0)
	var percent_complete = max(rot / max_spin, 0)
	if degrees > 0:
		%WindClock.play()
	else:
		%RecordScratch.play()
	
	if (percent_complete >= 1):
		return
	%Music.seek(music_length * percent_complete)
	
