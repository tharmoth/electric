extends Node2D

func on_pickup():
	queue_free()
	Character.instance.equip_gun("rifle")
