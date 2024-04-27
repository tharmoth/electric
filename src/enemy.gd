class_name Enemy extends Node2D

var maxHealth : int = 5
var speed := 100.0
var dead : bool = false
static var pickup = preload("res://src/pickup.tscn")

func _ready() -> void:
	add_to_group("Enemy")
	%Hurtbox.area_entered.connect(test)
	
func test(area : Area2D):
	Character.instance.on_damage()
	WorldTimer.instance.seek(-30)
	death_animation.kill(%Sprite2D)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target = Character.instance.global_position
	global_position = global_position.move_toward(target, speed * delta)


func on_death():
	if dead:
		return
	dead = true
	
	if (randf() > .75):
		var battery = pickup.instantiate()
		WorldTimer.instance.add_child(battery)
		battery.global_position = global_position
	
	%StaticBody2D.queue_free()
	death_animation.kill(%Sprite2D)
	%tv.kill()
	queue_free()

func on_gameover():
	if dead:
		return
	dead = true
	
	%StaticBody2D.queue_free()
	death_animation.kill(%Sprite2D)
	%tv.kill()
	queue_free()

func damage(damage: int) -> void:
	if maxHealth - damage <= 0:
		self.on_death()

	print("Damage taken: %s" % str(damage))
