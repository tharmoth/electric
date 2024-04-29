class_name Character extends CharacterBody2D

const SPEED : float = 300.0
const MAX_VELOCITY : float = 1200.0

static var high_score : int = -1
static var score : int  = -1
static var instance : Character
var knockbackTween : Tween = null
var knockback : Vector2 = Vector2.ZERO
var first_selection : bool = true

var gun = preload("res://src/gun.tscn")
var rifle = preload("res://src/weapons/rifle.tscn")
var shotgun = preload("res://src/components/shotgun.tscn")
var smg = preload("res://src/weapons/smg.tscn")
var tesla_gun = preload("res://src/weapons/tesla_gun.tscn")
var shoulder_laser = preload("res://src/shoulder_laser.tscn")
var currentGun;
@onready var charge_ammo : ProgressBar = %Charge
var xp = 0
@export var stats : CharacterStats

@onready var upgrade_audio : AudioStreamPlayer2D = %UpgradeAudio

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	score = -1
	%PickupBox.area_entered.connect(pickup)
	add_to_group("Character")
	equip_gun("shotgun")
	xp = 99
	currentGun.reload()
	
	var tween = create_tween()
	tween.tween_property(Character.instance.charge_ammo, "value", 100, 6 * .4)
	
func pickup(area : Area2D) -> void:
	area.get_parent().on_pickup()


func equip_gun(name : String):
	if currentGun:
		currentGun.queue_free()
		
	if (name == "pistol"):
		currentGun = gun.instantiate()
	if (name == "dual_pistol"):
		currentGun = gun.instantiate()
	elif name == "rifle":
		currentGun = rifle.instantiate()
	elif name == "shotgun":
		currentGun = shotgun.instantiate()
	elif name == "smg":
		currentGun = smg.instantiate()
	elif name == "dual_smg":
		currentGun = smg.instantiate()
	elif name == "tesla_gun":
		currentGun = tesla_gun.instantiate()
		
	currentGun.weapon_type = name
	
	currentGun.connect("shake", shake_camera)
	currentGun.connect("knockback", recoil_knockback)
	call_deferred("add_child", currentGun)
	
	%GunPickupAudio.play()
	
func on_level_up():
	for node in get_tree().get_nodes_in_group("LevelUpPickup"):
		node.free()
	
	var tween = create_tween()
	tween.tween_property(self, "xp", 0, 1)
	
	var direction = global_position.direction_to(Vector2.ZERO)
	var angle = global_position.angle_to_point(Vector2.ZERO) + PI / 2

	var pick : Node2D = preload("res://src/pickups/level_up_pickup.tscn").instantiate()
	if first_selection:
		first_selection = false
		pick.init("passive")
	else:
		pick.init("weapon")
	get_parent().call_deferred("add_child", pick)
	#pick.global_position = global_position + direction * 100
	#pick.position = Vector2(0, -310)
	pick.position = Vector2(0, -150)
	
	
	var pick2 : Node2D = preload("res://src/pickups/level_up_pickup.tscn").instantiate()
	pick2.init_ignore("passive", pick.item_name)
	get_parent().call_deferred("add_child", pick2)
	#pick2.global_position = global_position + direction * 100 + Vector2.LEFT.rotated(angle) * 100
	#pick2.position = Vector2(270, 160)
	pick2.position = Vector2(130, 77)
	
	var pick3 : Node2D = preload("res://src/pickups/level_up_pickup.tscn").instantiate()
	pick3.init_ignore2("passive", pick.item_name, pick2.item_name)
	get_parent().call_deferred("add_child", pick3)
	#pick3.global_position = global_position + direction * 100 + Vector2.RIGHT.rotated(angle) * 100
	#pick3.position = Vector2(-270, 160)
	pick3.position = Vector2(-130, 77)

func _process(delta: float) -> void:
	global_rotation = 0

func _physics_process(delta: float) -> void:
	if WorldTimer.instance.is_game_over:
		return
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var movement : Vector2
	%Fire.visible = direction.length()
	if direction.length() > 0:
		movement = direction * SPEED
	else:
		movement = Vector2.ZERO 
		

	velocity = movement + knockback
	var speed = velocity.length()
	velocity = velocity.normalized() * clamp(speed, 0, MAX_VELOCITY)

	move_and_slide()

	if Input.is_action_pressed("click"):
		currentGun.fire()

func damage_effect(time: float) -> void:
	var tween = create_tween()

	tween.tween_property(self, "modulate", Color(10, 0, 0, 1), time / 4.0)
	tween.tween_property(self, "modulate", Color.WHITE, 3 * time / 4.0)
	
	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_SINE)
	tween2.tween_property(%Sprites, "position", Vector2(randf_range(-10, 10), randf_range(-10, 10)) , time / 3.0)
	tween2.tween_property(%Sprites, "position", Vector2(randf_range(-10, 10), randf_range(-10, 10)) , time / 3.0)
	tween2.tween_property(%Sprites, "position", Vector2.ZERO, time / 3.0)
	
	var tween3 = create_tween()
	tween3.set_ease(Tween.EASE_IN_OUT)
	tween3.set_trans(Tween.TRANS_SINE)
	tween3.tween_property(%Sprites, "rotation_degrees", randf_range(-10, 10) , time / 3.0)
	tween3.tween_property(%Sprites, "rotation_degrees", randf_range(-10, 10) , time / 3.0)
	tween3.tween_property(%Sprites, "rotation_degrees", 0, time / 3.0)
	
	shake_camera()

func projectile_damage(dmg: int) -> void:
	self.damage_effect(0.3)
	WorldTimer.instance.seek(dmg * -1)

func on_damage() -> void:
	self.damage_effect(0.3)
	
	for node in get_tree().get_nodes_in_group("Enemy"):
		node.on_death()
	for node in get_tree().get_nodes_in_group("Pickup"):
		node.on_gameover()

func shake_camera() -> void:
	%Camera2D/AnimationPlayer.play("shake")

func recoil_knockback(recoil: Vector2) -> void:
	if knockbackTween:
		knockbackTween.kill()
	
	knockback = recoil
	knockbackTween = get_tree().create_tween()
	knockbackTween.set_ease(Tween.EASE_OUT)
	knockbackTween.set_trans(Tween.TRANS_CUBIC)
	knockbackTween.tween_property(self, "knockback", Vector2.ZERO, .25)

func on_gameover() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	currentGun.queue_free()
	%RingNoise.play()

func add_shoulder_laser() -> void:
	if stats.shoulder_lasers == 0:
		stats.shoulder_lasers += 1
		var shoulder_laser : Node2D = shoulder_laser.instantiate()
		call_deferred("add_child", shoulder_laser)
	else:
		stats.shoulder_lasers += 1
