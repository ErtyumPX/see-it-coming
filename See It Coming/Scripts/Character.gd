extends KinematicBody2D

#general control availibility
export(bool) var is_movement_true = true
export(bool) var is_teleport_true = true

#control
var previous_mouse_pos:Vector2
var is_moving:bool = false
onready var target_position = position
var smoothness:float = 0.4
var speed:float = 50

#teleport
var is_teleporting:bool = false
var is_teleport_available:bool = true
var teleporting_target:Vector2 = Vector2.ZERO
onready var teleport_cooldown_timer:Timer = $TeleportCooldown
export(float) var teleport_cooldown = 2

#transition between control types (move - teleport)
var time_elapsed_since_moving_pressed:float = -1
var max_time_for_teleport:float = 0.1

#invincibility
var is_invincible:bool = false
var time_elapsed_since_invincibility:float = -1
var invinicibility_time:float = 5

#conditions
var exploded:bool = false

#animation
onready var animator:AnimationPlayer = $AnimationPlayer
signal after_die

#main camera and camera effects -> apply_shake
onready var main_camera:Camera2D = get_parent().find_node("MainCamera")

#add_ons
var shield_amount:int = 0
onready var shield_breaking_particle = $ShieldBreakingParticle

#add force to character
var force_direction:Vector2 = Vector2.ZERO
var force_magnitude:float = 0
var force_damping:float = 2500

func _ready():
	teleport_cooldown_timer.wait_time = teleport_cooldown

func _process(delta):
	if time_elapsed_since_moving_pressed >= 0:
		time_elapsed_since_moving_pressed += delta
	if Input.is_action_just_pressed("toggle_moving"):
		time_elapsed_since_moving_pressed = 0
		previous_mouse_pos = get_global_mouse_position()
		if is_movement_true:
			is_moving = true
		
	elif Input.is_action_just_released("toggle_moving"):
		if time_elapsed_since_moving_pressed < max_time_for_teleport:
			if is_teleport_available and is_teleport_true:
				is_teleporting = true
				is_teleport_available = false
				teleporting_target = get_global_mouse_position()
				teleport_cooldown_timer.start()
				animator.play("shrink_down")
		time_elapsed_since_moving_pressed = -1
		is_moving = false
	if is_invincible:
		time_elapsed_since_invincibility += delta
		if time_elapsed_since_invincibility >= invinicibility_time:
			is_invincible = false
			time_elapsed_since_invincibility = -1
		


func _physics_process(delta):
	var current_mouse_pos = get_global_mouse_position()
	var difference:Vector2 = current_mouse_pos - previous_mouse_pos
	if is_moving and difference.length() > 0.01 and not exploded:
		#target_position += difference
		previous_mouse_pos = current_mouse_pos
		
		#main movement
		var next_pos = (position.linear_interpolate(position + difference, smoothness) - position) * speed 
		move_and_slide(next_pos)
	elif not is_moving and not exploded:
		move_and_slide(Vector2.ZERO)
	
	if force_magnitude > 0:
		move_and_slide(force_direction * force_magnitude)
		force_magnitude -= force_damping * delta
		if force_magnitude <= 0:
			force_magnitude = 0
			force_direction = Vector2.ZERO

### teleporting

func _on_TeleportCooldown_timeout():
	is_teleport_available = true

func after_shrinking():
	position = teleporting_target
	animator.play("grow_back")

func after_teleport():
	pass

### hit, explode and die

func bullet_explode(angle):
	exploded = true
	main_camera.apply_shake(50)
	rotation_degrees = angle - 90
	animator.play("bullet_explode")
	
func laser_explode():
	exploded = true
	main_camera.apply_shake(25)
	animator.play("laser_explode")

func after_die_func():
	emit_signal("after_die")

func add_shield():
	shield_amount += 1

func remove_shield():
	shield_amount -= 1
	main_camera.apply_shake(50)

func add_force(direction:Vector2, magnitude:float = 300, damping:float = -1):
	self.force_direction = direction
	self.force_magnitude = magnitude
	if damping != -1: self.force_damping = damping

func make_invincible():
	is_invincible = true
	time_elapsed_since_invincibility = 0
	


