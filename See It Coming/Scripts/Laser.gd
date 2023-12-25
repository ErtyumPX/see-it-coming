extends KinematicBody2D

var velocity:Vector2 = Vector2.ZERO
var is_free:bool = true
var last_starting_point:Vector2
var dying_distance:float

onready var collider:CollisionShape2D = $CollisionShape2D

func _physics_process(delta):
	if visible:
		var hit:KinematicCollision2D = move_and_collide(velocity * delta) as KinematicCollision2D
		if hit:
			print(hit.collider.name)
			if hit.collider.is_in_group("Character"):
				hit.collider.laser_explode()
		elif last_starting_point.distance_to(position) > dying_distance:
			reset()


func initiate(_position:Vector2 = Vector2.ZERO, velocity:Vector2 = Vector2.RIGHT, dying_distance:float = 3000):
	last_starting_point = _position
	self.position = _position
	self.velocity = velocity
	self.dying_distance = dying_distance
	collider.disabled = false
	visible = true

func reset():
	print(name + " reseted")
	position = Vector2(-100, -100)
	collider.disabled = true
	visible = false
	is_free = true
