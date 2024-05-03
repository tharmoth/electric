class_name MainMenu extends Control


const main_game = preload("res://src/main.tscn") as PackedScene
static var instance : MainMenu

func _enter_tree() -> void:
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready():
	%mainMenuMusic.play()
	preload("res://src/shotgun_particle.tscn")

func _on_kitchen_timer_turned_knob():
	get_tree().change_scene_to_packed(main_game)
	hide()
