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
	%AmmoCapacity.min_value = 0
	%AmmoCapacity.max_value = MAX_AMMO
	%AmmoCapacity.value = MAX_AMMO
	%GunAnimationPlayer.animation_finished.connect(_reload_complete)
	ammo = MAX_AMMO + Character.instance.stats.clip_bonus

func _process(delta: float) -> void:
	self._point_at_mouse()
	self._move_to_position()

func _move_to_position() -> void:
	var mouse = get_global_mouse_position()
	var direction = global_position.direction_to(mouse)
	var origin = get_parent().global_position
	var target = origin + direction * 40
	
	if global_position.distance_to(target) < 1:
		global_position = target
	else:
		global_position += global_position.direction_to(target)

func fire() -> void:
	if !self.can_fire():
		return

	ammo -= 1
	%AmmoCapacity.value = ammo

	print(%AmmoCapacity.value)

	for shot in _create_shots():
		get_tree().get_root().add_child(shot)

	var v : Vector2 = $ParticleOrigin.global_position - global_position.direction_to(get_global_mouse_position()) * KNOCKBACK_FORCE
	emit_signal("shake")
	emit_signal("knockback", v)
	%ShootTimer.start(SHOT_DELAY)
	%ShootAudio.play(0)

	if ammo == 0:
		spin_to_win = Character.instance.stats.reload_time
		self.reload()

func can_fire() -> bool:
	if isReloading:
		return false

	if %ShootTimer.time_left != 0:
		return false

	return ammo > 0

func reload() -> void:
	isReloading = true
	%GunAnimationPlayer.play("reload")
	
var spin_to_win = 5	
	
func _reload_complete(something):
	isReloading = false
	if spin_to_win > 0:
		spin_to_win -= 1
		reload()
	ammo = MAX_AMMO + Character.instance.stats.clip_bonus

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
