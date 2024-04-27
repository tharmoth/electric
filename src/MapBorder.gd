extends StaticBody2D
	
func test(area : Area2D):
	Character.instance.on_damage()
	WorldTimer.instance.seek(-30)
	Character.instance.recoil_knockback(Character.instance.global_position.direction_to(Vector2.ZERO) * 1250)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Area: " + area.name)
	test(area)