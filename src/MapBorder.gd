extends StaticBody2D
	
func test(area : Area2D):
	Character.instance.on_damage()
	WorldTimer.instance.seek(-30)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Area: " + area.name)
	test(area)
