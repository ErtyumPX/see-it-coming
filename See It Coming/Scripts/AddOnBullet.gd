extends KinematicBody2D

class AddOns:
	const shield:String = "Shield"
	const shield_chance:float = 100.0
	const invincibility:String = "Invincibility"
	const invincibility_chance:float = 100.0
	const other:String = "Other"

var add_on_type:String = ""

export(float) var speed = 2500

func _physics_process(delta):
	var hit:KinematicCollision2D = move_and_collide(speed * delta * Vector2.UP.rotated(rotation)) as KinematicCollision2D
	if hit:
		if hit.collider.is_in_group("Character"):
			hit.collider.add_force(Vector2.UP.rotated(rotation))
			match add_on_type:
				AddOns.shield:
					hit.collider.add_shield()
				AddOns.invincibility:
					hit.collider.make_invincible()
					pass
				AddOns.other:
					pass
				"":
					assert(false, "Add-on not initiated.")
			queue_free()


func initiate(add_on_type:String = ""):
	if add_on_type:
		self.add_on_type = add_on_type
	else:
		var i = rand_range(0, 100)
		if i < AddOns.shield_chance:
			self.add_on_type = AddOns.shield
			$Sprite.modulate = Color(255, 255, 255, 255)
		elif i < AddOns.invincibility_chance:
			self.add_on_type = AddOns.invincibility
			$Sprite.modulate = Color(195, 21, 230, 255)





