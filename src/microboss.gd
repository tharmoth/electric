class_name Microboss extends Enemy

func _ready() -> void:
	maxHealth = 150
	add_to_group("Enemy")
	print("in boss")
