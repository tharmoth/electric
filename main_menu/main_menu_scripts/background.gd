extends Sprite2D

var counter = 0
static var rng := RandomNumberGenerator.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	counter += 1
	if counter >= hframes * vframes:
		counter = 0
	frame = counter
