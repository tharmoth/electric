extends Node


var _startingPosition : Vector2
var _tween : Tween
@export var offset : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_startingPosition = get_parent().position
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(get_parent(), "position:y", _startingPosition.y - 10, 1 - offset)
	_tween.tween_property(get_parent(), "position:y", _startingPosition.y, 1 - offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_tween != null && _tween.is_running()):
		return
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(get_parent(), "position:y", _startingPosition.y - 10, 1)
	_tween.tween_property(get_parent(), "position:y", _startingPosition.y, 1)
