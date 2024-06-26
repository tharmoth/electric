class_name Level extends Node2D

var COOLDOWN := 3.0
var timer := 0.0
var edge_shock : bool = false
var boss_alive : bool = false
var boss_times : Array[int] = [60, 240, 580, 820]

static var instance : Level

func _enter_tree() -> void:
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TickTick.finished.connect(restart)
	death_animation.init()

func restart():
	%TickTick.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var worldTimer = WorldTimer.instance
	if worldTimer.is_game_over:
		return
	timer += delta
	if (timer < COOLDOWN):
		return
	timer = 0
	
	var amount_to_spawn = 1
	
	if worldTimer.time_elapsed > 20:
		amount_to_spawn += 1
	
	if worldTimer.time_elapsed > 60:
		amount_to_spawn += 1
	
	for i in range(floori(worldTimer.get_minutes_elapsed() / 5)):
		amount_to_spawn += 1
	
	if worldTimer.time_elapsed > 60 * 4 and not edge_shock:
		edge_shock = true
		%EdgeHurtbox.visible = true
		
		var tween = create_tween()
		tween.tween_property(%EdgeParticles, "amount_ratio", 1, 1)
	
	if boss_times.size() > 0 && worldTimer.time_elapsed >= boss_times[0]:
		var t = boss_times.pop_front()
		var boss = load("res://src/microboss.tscn").instantiate()
		boss.connect("boss_down", func() -> void: boss_alive = false)
		boss_alive = true
		boss.global_position = random_point_on_circle(512)
		boss.health = t / 2
		add_child(boss)

	print("Spawning: ", amount_to_spawn)
	if !boss_alive:
		for i in range(amount_to_spawn):
			var enemy = preload("res://src/enemy.tscn").instantiate()
			%Timer.add_child(enemy)
			enemy.global_position = random_point_on_circle(512)

func random_point_on_circle(radius : float) -> Vector2:
	var angle = randf() * PI * 2
	return Vector2(cos(angle), sin(angle)) * radius
