extends Node2D

var COOLDOWN := 3.0
var timer := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TickTick.finished.connect(restart)

func restart():
	%TickTick.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if (timer < COOLDOWN):
		return
	timer = 0
	
	for i in range(3):
		var enemy = preload("res://src/enemy.tscn").instantiate()
		%Timer.add_child(enemy)
		enemy.global_position = %Character.global_position + random_point_on_circle(500)


func random_point_on_circle(radius : float) -> Vector2:
	var angle = randf() * PI * 2
	return Vector2(cos(angle), sin(angle)) * radius
