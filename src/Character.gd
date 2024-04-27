class_name Character extends CharacterBody2D

const SPEED = 300.0

static var instance : Character
var knockback : Vector2 = Vector2.ZERO
var charge : int = 0

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	%PickupBox.area_entered.connect(pickup)

func pickup(area : Area2D) -> void:
	area.get_parent().queue_free()
	%Timer.seek(10)
	charge += 1
	var node_to_make_visible : Node2D
	if (charge == 1):
		node_to_make_visible = %Charge1
	elif (charge == 2):
		node_to_make_visible = %Charge2
	elif (charge == 3):
		node_to_make_visible = %Charge3
	else:
		return
	
	node_to_make_visible.visible = true
	node_to_make_visible.modulate = Color.TRANSPARENT
	var visible_tween = create_tween()
	visible_tween.tween_property(node_to_make_visible, "modulate", Color.WHITE, .5)

func _process(delta: float) -> void:
	global_rotation = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var movement : Vector2
	%Fire.visible = direction.length()
	if direction.length() > 0:
		movement = direction * SPEED
	else:
		movement = Vector2.ZERO 
		

	velocity = movement + knockback

	move_and_slide()


	
	
