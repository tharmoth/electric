extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_reload_timeout() -> void:
	var enemyHitBoxes : Array[Node2D] = $Area2D.get_overlapping_bodies()
	print("Reloaded!")
	print(enemyHitBoxes)
	for enemyHitBox in enemyHitBoxes:
		var enemy := enemyHitBox.get_parent()
		print(enemy.name)
		if enemy.is_in_group("Enemy"):
			print(enemy.name)
			enemy.damage(100)
