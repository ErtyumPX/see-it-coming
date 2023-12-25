extends Camera2D

export(Vector2) var center = Vector2(512, 300)

var increasing:bool = true
var noise = OpenSimplexNoise.new()
var noise_i = 0

var is_shaking:bool = false 
var current_strength = 0
var current_decay_rate = 0

export(float) var octaves = 4 
export(float) var period = 2
export(float) var persistence = 0.8
export(float) var noise_shake_speed = 30


var following_target:Node2D = null
var following_smoothness:float = 1
onready var animator:AnimationPlayer = $AnimationPlayer

func _ready():
	offset = center

	noise.seed = randi()
	#noise.octaves = octaves
	noise.period = period
	#noise.persistence = persistence

func _process(delta):
	
	if Input.is_action_just_pressed("ui_up"):
		apply_shake()
	
	if is_shaking:
		current_strength = lerp(current_strength, 0, delta * current_decay_rate)
		if current_strength < 0.0001:
			is_shaking = false
		noise_i += delta * noise_shake_speed
		offset = get_offset()
	
	if following_target:
		position = position.linear_interpolate(following_target.position, following_smoothness)



func apply_shake(strength:float = 20, decay_rate:float = 8):
	current_strength += strength
	current_decay_rate = decay_rate
	is_shaking = true

func get_offset():
	if not following_target:
		return center + Vector2( noise.get_noise_2d(1, noise_i) * current_strength, 
	noise.get_noise_2d(10, noise_i) * current_strength )
	else:
		return following_target.position + Vector2( noise.get_noise_2d(1, noise_i) * current_strength, 
	noise.get_noise_2d(10, noise_i) * current_strength )


func follow(target:Node2D, smoothness:float = 0.5):
	following_target = target

func unfollow():
	following_target = null


func zoom_in():
	animator.play("zoom_in")

func zoom_out():
	animator.play("zoom_out")

