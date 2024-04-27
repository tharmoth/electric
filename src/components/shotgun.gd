extends Node2D

signal shake

const MAX_AMMO : int = 5
# Should be in the particle
const MAX_DISTANCE : int = 300
const RELOAD_DELAY : float = 0.75
const SHOT_DELAY : float = 0.5
const SHOTS : int = 5

@onready var particle : PackedScene = preload("res://src/shotgun_particle.tscn")

var ammo: int = SHOTS
var isReloading: bool = false
var shotsFired: Array = []

func _ready() -> void:
	%ReloadTimer.connect("timeout", _handle_reload)

func _process(delta: float) -> void:
	self._point_at_mouse()
	
	for i in shotsFired.size():
		var shot = shotsFired[i]
		# I believe since the shot is a child of a rotating object
		# when you aim your mouse the projectile moves with it
		shot.global_position += (Vector2.RIGHT * 300).rotated(shot.rotation) * delta

func fire() -> void:
	print('attempting to fire', %ShootTimer.time_left)
	if !self.can_fire():
		return

	# Do something
	print('bang!')
	ammo -= 1

	var mouse = get_global_mouse_position()
	var shot = particle.instantiate()
	shot.global_position = $ParticleOrigin.global_position
	shot.rotation = $ParticleOrigin.rotation

	get_tree().get_root().add_child(shot)
	shotsFired.push_back(shot)
	emit_signal("shake")
	%ShootTimer.start(SHOT_DELAY)

	if ammo == 0:
		self._reload()

func can_fire() -> bool:
	if isReloading:
		print(1)
		return false

	if %ShootTimer.time_left != 0:
		print(2)
		return false

	return ammo > 0

func _reload() -> void:
	print('reloading')
	isReloading = true
	%ReloadTimer.start(RELOAD_DELAY)

func _handle_reload() -> void:
	ammo = MAX_AMMO
	isReloading = false

func _point_at_mouse() -> void:
	var m = get_global_mouse_position()
	global_rotation = global_position.angle_to_point(m)
	$ParticleOrigin.look_at(m)
	
	if m.x < 0:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false
