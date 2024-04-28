extends Node2D

var _time : float = 0
@export var time_to_complete = 30
@export var time_offset : float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time += delta
	var t = (_time + time_offset) / time_to_complete 
	var r = clamp(cos(t * 2 * PI), 0, 1)
	var g = clamp(cos(t * 2 * PI + 2 * PI / 3), 0, 1)
	var b = clamp(cos(t * 2 * PI - 2 * PI / 3), 0, 1)
	self_modulate = Color(r, g, b)
