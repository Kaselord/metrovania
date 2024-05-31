extends Area2D

var velocity : Vector2 = Vector2(0, 0)


func _physics_process(delta):
	if Globals.active:
		position += velocity * delta
		velocity.y += 500 * delta
		if velocity.x != 0:
			$sprite.rotation_degrees += sign(velocity.x) * 15
		else:
			$sprite.rotation_degrees += 15
		
		$hurtbox.rotation_degrees = $sprite.rotation_degrees
		
		spawn_trail_particle()


func _on_body_entered(body):
	if body.get_class() == "TileMap":
		call_deferred("free")


func spawn_trail_particle():
	if Globals.level_reference != null:
		var particle = Preloads.texture_particle.instantiate()
		particle.init["rotation"] = $sprite.rotation_degrees
		particle.init["position"] = global_position
		particle.final["rotation"] = $sprite.rotation_degrees
		particle.final["position"] = global_position
		particle.final["modulate"] = Color(0, 1, 0, 0)
		particle.lifetime = 20
		particle.texture = $sprite.texture
		Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)
