class_name Character extends CharacterBody2D

const SPEED = 300.0

static var instance : Character
var knockback : Vector2 = Vector2.ZERO

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	%PickupBox.area_entered.connect(pickup)

func pickup(area : Area2D) -> void:
	area.get_parent().queue_free()
	%Timer.seek(10)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var movement : Vector2
	if direction.length() > 0:
		movement = direction * SPEED
	else:
		movement = Vector2.ZERO 

	velocity = movement + knockback

	move_and_slide()


	
	
