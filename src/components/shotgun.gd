extends Node2D

signal shake
signal knockback(recoil: Vector2)

const KNOCKBACK_FORCE : float = 1250
const MAX_AMMO : int = 5
const RELOAD_DELAY : float = 1.00
const SHOT_DELAY : float = 1.00
const SHOTS : int = 5

@onready var particle : PackedScene = preload("res://src/shotgun_particle.tscn")

var ammo: int = SHOTS
var isReloading: bool = false
# Upgrading shotgun upgrades damage
var minDamage: int = 5
var maxDamage: int = 8

func _ready() -> void:
	%ReloadTimer.connect("timeout", _handle_reload)
	%AmmoCapacity.min_value = 0
	%AmmoCapacity.max_value = MAX_AMMO
	%AmmoCapacity.value = MAX_AMMO

func _process(delta: float) -> void:
	self._point_at_mouse()

func fire() -> void:
	if !self.can_fire():
		return

	ammo -= 1
	%AmmoCapacity.value -= 1

	for shot in _create_shots():
		get_tree().get_root().add_child(shot)

	var v : Vector2 = $ParticleOrigin.global_position - global_position.direction_to(get_global_mouse_position()) * KNOCKBACK_FORCE
	emit_signal("shake")
	emit_signal("knockback", v)
	%ShootTimer.start(SHOT_DELAY)
	%ShootAudio.play(0)

	if ammo == 0:
		self._reload()

func can_fire() -> bool:
	if isReloading:
		return false

	if %ShootTimer.time_left != 0:
		return false

	return ammo > 0

func _reload() -> void:
	isReloading = true
	%AnimationPlayer.play("reload")
	%ReloadTimer.start(RELOAD_DELAY)
	%AmmoCapacity.value = MAX_AMMO
	%ReloadAudio.play(0)
	await get_tree().create_timer(RELOAD_DELAY).timeout
	%ReloadAudio.stop()
	#await get_tree().create_timer(RELOAD_DELAY).timeout
	#%AnimationPlayer.stop()

func _handle_reload() -> void:
	ammo = MAX_AMMO
	isReloading = false

func _point_at_mouse() -> void:
	var m = get_global_mouse_position()
	global_rotation = global_position.angle_to_point(m)

	if m.x < 0:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false

func _create_shots() -> Array:
	var shots := []

	for i in SHOTS:
		var shot = particle.instantiate()
		var angle = ((-1.125 / 2) + (1.125 / (SHOTS - 1)) * i)
		shot.global_position = $ParticleOrigin.global_position
		shot.starting_position = shot.global_position
		shot.minDamage = minDamage
		shot.maxDamage = maxDamage
		shot.rotation = global_position.angle_to_point(get_global_mouse_position()) + angle
		shots.push_back(shot)

	return shots
