extends Entity


func _physics_process(_delta):
	if Globals.active && hp > 0:
		pass
	elif hp <= 0:
		$fire_emitter.active = true
		$hitbox/CollisionShape2D.disabled = true
