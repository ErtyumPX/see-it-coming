extends Node2D

class AddOns:
	const shield:String = "Shield"
	const invincibility:String = "Invincibility"
	const other:String = "Other"

###level settings
var time:float = 0
#space
export(float) var space_angular_speed
export(Curve) var space_rotation_curve
export(float) var space_angular_period = 1
var space_current_angular_speed:float
export(float) var space_margin_speed
export(Curve) var space_margin_curve
export(float) var space_margin_period = 1
var space_current_margin_speed:float
#bullet
export(float) var bullet_timer_min
export(float) var bullet_timer_max
export(float) var bullet_amount_min
export(float) var bullet_amount_max
export(float, 0, 100) var add_on_bullet_chance
#laser
export(float) var laser_timer_min
export(float) var laser_timer_max

#space
var space:Node2D
var walls:Array #0 - left, 1 - up, 2 - right, 3 - bottom wall 
var space_margin_x:float = 400
var space_margin_y:float = 400
const distance_between_walls = 140.8

#bullet phase variables
onready var bullet_timer = $BulletTimer
export(Vector2) var center_point = Vector2(512, 300)
var space_size:float = 150
var screen_size = Vector2(1024, 600)
var instantiate_offset = 1000
var bullet_holder:Node2D
const bullet_scene = preload("res://Scenes/Bullet.tscn")
const bullet_trail_scene = preload("res://Scenes/BulletTrail.tscn")
#add-on bullets
const add_on_bullet_scene = preload("res://Scenes/AddOnBullet.tscn")


#laser variables
onready var laser_timer = $LaserTimer
const laser_scene = preload("res://Scenes/Laser.tscn")
var laser_holder:Node2D
#laser pooling
var laser_pool:Array


onready var phase_timer:Timer = $PhaseTimer
var current_phase:String = ""
class Phases:
	const bullet_phase:String = "BulletPhase"
	const laser_phase:String = "LaserPhase"


#scene transitions
onready var fade_transition_canvas = $FadeTransitionCanvas
var current_after_fade_function = null


#main camera and camera effects -> apply_shake
onready var main_camera:Camera2D = get_parent().find_node("MainCamera")


#testing
var increasing:bool = true
var testing_space_margin_increase_rate:float = 10
var testing_space_margin_angular_speed:float = 5
var testing_speed = 0


func _ready():
	space = get_parent().find_node("Space")
	space_current_angular_speed = space_angular_speed
	space_current_margin_speed = space_margin_speed
	for i in range(4):
		walls.append(space.get_child(i))
	bullet_holder = get_parent().find_node("BulletHolder")
	laser_holder = get_parent().find_node("LaserHolder")
	
	#bullet timer
	bullet_timer.wait_time = rand_range(bullet_timer_min, bullet_timer_max)
	#laser timer
	laser_timer.wait_time =rand_range(laser_timer_min, laser_timer_max)
	
	#laser prep
	for i in range(4):
		var laser_i = laser_scene.instance()
		laser_holder.add_child(laser_i)
		laser_i.visible = false
		laser_pool.append(laser_i)
	
	#testing
	
	#at last
	fade_in()

func _process(delta):
	time += delta
	update_space_scale()

	var current_angular_state = space_rotation_curve.interpolate_baked(fmod(time / space_angular_period, 1))
	space_current_angular_speed = space_angular_speed * current_angular_state
	space.rotation_degrees += space_current_angular_speed * delta
	
	var current_marging_state = space_margin_curve.interpolate_baked(fmod(time / space_margin_period, 1))
	space_current_margin_speed = space_margin_speed * current_marging_state

	space_margin_x += space_current_margin_speed * delta
	space_margin_y += space_current_margin_speed * delta
	#testing
#	if increasing:
#		if space_margin_x > 550:
#			increasing = false
#		else:
#			space_margin_x += testing_space_margin_increase_rate * delta
#			space_margin_y += testing_space_margin_increase_rate * delta
#	else:
#		if space_margin_x <= 520:
#			increasing = true
#		else:
#			space_margin_x -= testing_space_margin_increase_rate * delta
#			space_margin_y -= testing_space_margin_increase_rate * delta
	
	#testing laser
	#if Input.is_action_just_pressed("testing_send_laser"):
	#	_on_LaserTimer_timeout()

### bullet phase

func _on_BulletTimer_timeout():
	bullet_timer.wait_time = rand_range(bullet_timer_min, bullet_timer_max)
	for i in range(rand_range(bullet_amount_min, bullet_amount_max) as int):
		instantiane_random_bullet()
	pass


func instantiane_random_bullet():
	var bullet_trail = bullet_trail_scene.instance()
	bullet_holder.add_child(bullet_trail)
	
	#for chance of x, bullet will be a add-on bullet
	var bullet
	if rand_range(0, 100) > add_on_bullet_chance:
		bullet = add_on_bullet_scene.instance()
		bullet.initiate()
		match bullet.add_on_type:
			AddOns.shield:
				bullet_trail.find_node("Sprite").modulate = Color(225, 250, 0, 255)
			AddOns.invincibility:
				bullet_trail.find_node("Sprite").modulate = Color(30, 225, 10, 255)
				
	else:
		bullet = bullet_scene.instance()
	
	bullet_holder.add_child(bullet)
	
	var target_and_inst_pos = get_random_target_and_inst_pos_vector()
	var random_target_position = target_and_inst_pos[0]
	var instantiation_position = target_and_inst_pos[1]

	bullet.position = instantiation_position
	bullet.look_at(random_target_position)
	bullet.rotation_degrees += 90
	
	bullet_trail.position = instantiation_position
	bullet_trail.look_at(random_target_position)
	bullet_trail.rotation_degrees += 90
	bullet_trail.get_node("AnimationPlayer").play("thin_out")

func get_random_target_and_inst_pos_vector():
	var random_target_position = center_point + Vector2(rand_range(-space_size, space_size) as int, rand_range(-space_size, space_size) as int)
	var phase = rand_range(0, 4) as int # 0 left, 1 up, 2 right, 3 bottom
	var instantiation_position = Vector2.ZERO
	match phase:
		0:
			instantiation_position = Vector2(-instantiate_offset, rand_range(-instantiate_offset, screen_size[1]+instantiate_offset) as int)
		1:
			instantiation_position = Vector2(rand_range(-instantiate_offset, screen_size[0]+instantiate_offset) as int, -instantiate_offset)
		2:
			instantiation_position = Vector2(screen_size[0]+instantiate_offset, rand_range(-instantiate_offset, screen_size[1]+instantiate_offset) as int)
		3:
			instantiation_position = Vector2(rand_range(-instantiate_offset, screen_size[0]+instantiate_offset) as int, screen_size[1]+instantiate_offset)
	return [random_target_position, instantiation_position]

### space

func update_space_scale():
	if space_margin_x != walls[2].position.x and space_margin_y != walls[2].position.y:
		walls[0].position.x = -space_margin_x
		walls[1].position.y = -space_margin_y
		walls[2].position.x = space_margin_x
		walls[3].position.y = space_margin_y

### laser

func _on_LaserTimer_timeout():
	laser_timer.wait_time = rand_range(laser_timer_min, laser_timer_max)
	var target_and_inst_pos = get_random_target_and_inst_pos_vector()
	var target_position = target_and_inst_pos[0]
	var inst_position = target_and_inst_pos[1]
	
	var current_laser = get_free_laser()
	var velocity = (target_position - inst_position).normalized() * 200
	current_laser.initiate(inst_position, velocity)
	current_laser.look_at(target_position)
	current_laser.rotation += PI

func get_free_laser():
	for i in range(laser_pool.size()):
		if laser_pool[i].is_free:
			laser_pool[i].is_free = false
			return laser_pool[i]
	assert(false, "No Available Laser!")


### scene transitions

func _on_Character_after_die():
	current_after_fade_function = funcref(self, "reload_main_scene")
	fade_out()

func fade_out():
	fade_transition_canvas.find_node("AnimationPlayer").play("fade_out")


func fade_in():
	fade_transition_canvas.find_node("AnimationPlayer").play("fade_in")


func after_fade_transition():
	if current_after_fade_function != null:
		current_after_fade_function.call_func()
		current_after_fade_function = null

func reload_main_scene():
	print("reloading")
	get_tree().reload_current_scene()

