class_name Enemy extends Node2D

var health : int = 5
var speed := 100.0
var dead : bool = false
static var pickup = preload("res://src/pickup.tscn")

func _ready() -> void:
	add_to_group("Enemy")
	%Hurtbox.area_entered.connect(damage_player)
	
	if WorldTimer.instance.get_minutes_elapsed() >= 2 and randf() > .80:
		%tv.set_static_color(Color.RED)
		health = 20	
	elif WorldTimer.instance.get_minutes_elapsed() >= 3 and randf() > .90:
		%tv.set_static_color(Color.PURPLE)
		health = 40
	elif WorldTimer.instance.get_minutes_elapsed() >= 10 and randf() > .90:
		%tv.set_static_color(Color.GREEN)
		health = 40
	
func damage_player(area : Area2D):
	death_animation.kill(%Sprite2D)
	Character.instance.on_damage()
	WorldTimer.instance.seek(-30)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target = Character.instance.global_position
	global_position = global_position.move_toward(target, speed * delta)


func on_death():
	if dead:
		return
	dead = true
	
	if (randf() > .66):
		var battery = pickup.instantiate()
		WorldTimer.instance.add_child(battery)
		battery.global_position = global_position
	
	%StaticBody2D.free()
	if %Sprite2D:
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
	var color = Color.WHITE
	if damage > 10:
		color = Color.GOLD
	if damage > 20:
		color = Color.RED
	FloatingLabel.show(str(damage), global_position, color)
	health -= damage
	if health <= 0:
		self.on_death()
