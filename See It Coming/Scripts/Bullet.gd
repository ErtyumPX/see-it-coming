extends KinematicBody2D

export(float) var speed = 2500
onready var animator:AnimationPlayer = $AnimationPlayer
var not_hit_yet:bool = true


func _physics_process(delta):
	var hit:KinematicCollision2D = move_and_collide(speed * delta * Vector2.UP.rotated(rotation)) as KinematicCollision2D
	if hit:
		if hit.collider.is_in_group("Character"):
			if hit.collider.is_invincible:
				animator.play("explode")
			elif hit.collider.shield_amount > 0:
				animator.play("explode_by_shield")
				print("exploded by shield")
				hit.collider.remove_shield()
				hit.collider.add_force(Vector2.UP.rotated(rotation))
			else:
				hit.collider.bullet_explode(rotation_degrees)
func vanish():
	print("vanished")
	queue_free()
