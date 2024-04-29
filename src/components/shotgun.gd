extends Node2D

signal shake
signal knockback(recoil: Vector2)

const KNOCKBACK_FORCE : float = 1250
const MAX_AMMO : int = 5
const RELOAD_DELAY : float = 1.00
const SHOT_DELAY : float = 1.00
const SHOTS : int = 5

# For pickup compatability, I wish we had interfaces
var weapon_type : String = "shotgun"

@onready var particle : PackedScene = preload("res://src/shotgun_particle.tscn")

var ammo: int = SHOTS
var isReloading: bool = false
# Upgrading shotgun upgrades damage
var minDamage: int = 10
var maxDamage: int = 20
var reloadSpinCount: int = 5

func _ready() -> void:
	%AmmoCapacity.min_value = 0
	%AmmoCapacity.max_value = MAX_AMMO
	%AmmoCapacity.value = MAX_AMMO
	Character.instance.charge_ammo.value = 100
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
	Character.instance.charge_ammo.value = float(ammo) / (MAX_AMMO + Character.instance.stats.clip_bonus)  * 100.0
	
	print(%AmmoCapacity.value)

	for shot in _create_shots():
		get_tree().get_root().add_child(shot)

	var v : Vector2 = $ParticleOrigin.global_position - global_position.direction_to(get_global_mouse_position()) * KNOCKBACK_FORCE
	emit_signal("shake")
	emit_signal("knockback", v)
	%ShootTimer.start(SHOT_DELAY * Character.instance.stats.fire_speed_mult)
	%ShootAudio.play(0)

	if ammo == 0:
		reloadSpinCount = Character.instance.stats.reload_time
		var tween = create_tween()
		tween.tween_property(Character.instance.charge_ammo, "value", 100, (1 + reloadSpinCount) * .4)
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

func _reload_complete(something):
	isReloading = false
	if reloadSpinCount > 0:
		reloadSpinCount -= 1
		self.reload()
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
