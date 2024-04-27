extends Node2D

var COOLDOWN := 3.0
var timer := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TickTick.finished.connect(restart)
	death_animation.init()

func restart():
	%TickTick.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if WorldTimer.instance.is_game_over:
		return
	timer += delta
	if (timer < COOLDOWN):
		return
	timer = 0
	
	var amount_to_spawn = roundi(abs(%Timer.get_current_time()) / 10) + 1
	
	for i in range(amount_to_spawn):
		var enemy = preload("res://src/enemy.tscn").instantiate()
		%Timer.add_child(enemy)
		enemy.global_position = random_point_on_circle(512)

func random_point_on_circle(radius : float) -> Vector2:
	var angle = randf() * PI * 2
	return Vector2(cos(angle), sin(angle)) * radius
