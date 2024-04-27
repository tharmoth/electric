class_name Character extends CharacterBody2D

const SPEED = 300.0

static var instance : Character
var knockback : Vector2 = Vector2.ZERO
var charge : int = 0

var gun = preload("res://src/gun.tscn")
var shotgun = preload("res://src/components/shotgun.tscn")
var currentGun;

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	add_to_group("Character")
	currentGun = gun.instantiate()
	currentGun.connect("shake", shake_camera)
	call_deferred("add_child", currentGun)
	%PickupBox.area_entered.connect(pickup)

func pickup(area : Area2D) -> void:
	area.get_parent().queue_free()
	%Timer.seek(10)
	if (%Charge.value < 100):
		%Charge.value += 10
	
func _process(delta: float) -> void:
	global_rotation = 0

func _physics_process(delta: float) -> void:
	if WorldTimer.instance.is_game_over:
		return
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var movement : Vector2
	%Fire.visible = direction.length()
	if direction.length() > 0:
		movement = direction * SPEED
	else:
		movement = Vector2.ZERO 
		

	velocity = movement + knockback

	move_and_slide()

	if Input.is_action_pressed("click"):
		currentGun.fire()

func shake_camera() -> void:
	%Camera2D/AnimationPlayer.play("shake")
	
func on_gameover() -> void:
	death_animation.kill(%Sprites)
