extends Sprite2D

var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if counter == 1:
		var tex : NoiseTexture2D = texture
		var noise : FastNoiseLite = tex.noise
		var rng = RandomNumberGenerator.new()
		noise.offset = Vector3(rng.randf(), rng.randf(), rng.randf())
		counter = 0
	else:
		counter = 1
