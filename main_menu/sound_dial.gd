extends Node2D

var following := false
const MAX_DIST := 42000
const MAX_TURN := 2 * PI

var last_angle = 0
var grab : float = 0
var started : bool = false
@export var audioBus : int

func _ready():
	var volume := AudioServer.get_bus_volume_db(audioBus)
	if volume < 0:
		volume = remap(volume, -24, 24, -PI, PI)
	else:
		volume = remap(volume, 0, 10, 0, PI)
	$knob.rotation = volume + PI

func _physics_process(_delta: float) -> void:
	var mouseDist := TargetingUtils.get_target().distance_squared_to($knob.global_position)
	var knob_rot = $knob.rotation
	
	if mouseDist < MAX_DIST and Input.is_action_just_pressed("click"):
		grab = TargetingUtils.get_target().angle_to_point($knob.global_position) + PI/2
		following = true
	
	if Input.is_action_just_released("click"):
		following = false
	
	if following:
		var ang := TargetingUtils.get_target().angle_to_point($knob.global_position) - PI/2 - grab
		var d : Vector2 = ($knob/knobPoint.position.rotated(knob_rot))
		var a = $middlePoint.position.angle_to(d)
		
		var musicVol : float
		if a < 0:
			musicVol = remap(a, -PI, PI, -24, 24)
		else:
			musicVol = remap(a, 0, PI, 0, 10)
			
		var fang : float = lerp_angle(knob_rot, ang, 0.05)
		$knob.rotation = clamp(fang, 0.1, 2*PI-0.1)
		if $knob.rotation < 0.11:
			musicVol = -80
		AudioServer.set_bus_volume_db(audioBus, musicVol)
		if audioBus != 1 && !%testNoise.playing:
			%testNoise.play()
