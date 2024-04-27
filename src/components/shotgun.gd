extends Node

signal shake

const MAX_AMMO: int = 5
const RELOAD_DELAY: float = 0.75
const SHOT_DELAY : float = 0.5
const SHOTS: int = 5

var ammo: int = SHOTS
var isReloading: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ReloadTimer.connect("timeout", _handle_reload)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isReloading:
		return

func fire() -> void:
	print('attempting to fire', %ShootTimer.time_left)
	if !self.can_fire():
		return

	ammo -= 1
	emit_signal("shake")
	%ShootTimer.start(SHOT_DELAY)
	# Do something
	print('bang!')
	
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
