extends Control

const main_game = preload("res://src/main.tscn") as PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_kitchen_timer_turned_knob():
	get_tree().change_scene_to_packed(main_game)
	hide()
