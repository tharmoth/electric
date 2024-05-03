extends StaticBody2D

var damaging = false
	
func test(area : Area2D):
	if damaging:
		Character.instance.on_damage()
		WorldTimer.instance.seek(-30)
	Character.instance.recoil_knockback(Character.instance.global_position.direction_to(Vector2.ZERO) * 3000)
	$borderNoise.play()

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Area: " + area.name)
	test(area)
