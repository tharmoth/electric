extends Node2D

var COOLDOWN := 3.0
var timer := 0.0
var edge_shock : bool = false
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
	
	var bonus 
	
	var amount_to_spawn = 1
	
	if WorldTimer.instance.time_elapsed > 20:
		amount_to_spawn += 1
		
	if WorldTimer.instance.time_elapsed > 60:
		amount_to_spawn += 1
		
	if WorldTimer.instance.time_elapsed > 90 and not edge_shock:
		edge_shock = true
		%EdgeHurtbox.visible = true
		%EdgeHurtbox.monitoring = true
		%EdgeHurtbox.monitorable = true
		var tween = create_tween()
		tween.tween_property(%EdgeParticles, "amount_ratio", 1, 3)
	
	for i in range(floori(WorldTimer.instance.get_minutes_elapsed() / 5)):
		amount_to_spawn += 1

	print("Spawning: ", amount_to_spawn)
	for i in range(amount_to_spawn):
		var enemy = preload("res://src/enemy.tscn").instantiate()
		%Timer.add_child(enemy)
		enemy.global_position = random_point_on_circle(512)

func random_point_on_circle(radius : float) -> Vector2:
	var angle = randf() * PI * 2
	return Vector2(cos(angle), sin(angle)) * radius
