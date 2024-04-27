class_name death_animation extends Node

static var shatter_shader = preload("res://src/shaders/shatter.gdshader")
static var noise1 = NoiseTexture2D.new()
static var noise2 = NoiseTexture2D.new()

static func init():
	noise1.noise = FastNoiseLite.new()
	noise2.noise = FastNoiseLite.new()
	noise2.as_normal_map = true
	

# Called when the node enters the scene tree for the first time.
static func kill(sprite : Sprite2D) -> void:
	var material = ShaderMaterial.new()
	material.shader = shatter_shader
	material.set_shader_parameter("strength", 1.5)
	material.set_shader_parameter("noise_tex_normal", noise2)
	material.set_shader_parameter("noise_tex", noise1)
	sprite.material = material
	
	var tree = sprite.get_tree()
	var pos = sprite.global_position
	var character = Character.instance
	sprite.get_parent().remove_child(sprite)
	tree.root.add_child(sprite)
	sprite.global_position = pos
	
	var animation_time := 1.0
	var tween = tree.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(func(progress): material.set_shader_parameter("progress", progress), 0.0, 1.0, animation_time)
	tween.tween_callback(func(): 
		if (is_instance_valid(sprite)):
			sprite.queue_free()
			)

	var targetPos = pos - pos.direction_to(character.global_position) * 100;
	var knockback = tree.create_tween()
	knockback.tween_property(sprite, "global_position", targetPos, animation_time)
