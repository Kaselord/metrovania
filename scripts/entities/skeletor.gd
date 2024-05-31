extends Entity

@export var spear_scene : PackedScene
var throw_cd : int = 20


func _physics_process(delta):
	if Globals.active && hp > 0:
		velocity.y += 400 * delta
		move_and_slide()
		
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, 0.4)
		
		if Globals.player_reference != null:
			if abs(position.x - Globals.player_reference.position.x) < 240:
				var scaler : float = -sign(position.x - Globals.player_reference.position.x)
				if scaler != 0:
					$sprite.scale.x = scaler
				if throw_cd > 0:
					throw_cd -= 1
				else:
					throw_cd = 100
					$anim.play("attack")
	else:
		$anim.stop()
		if hp <= 0:
			$fire_emitter.active = true
			if $sprite.modulate.a > 0:
				$sprite.modulate -= Color(0.01, 0.01, 0.01, 0.01)
			else:
				call_deferred("free")


func throw_spear():
	if Globals.level_reference != null:
		var spear = spear_scene.instantiate()
		spear.position = global_position + Vector2(0, -24)
		if Globals.player_reference != null:
			spear.velocity.x = (Globals.player_reference.position.x - position.x) * 1.2
			spear.velocity.y = -200
		Globals.level_reference.get_node("projectiles").call_deferred("add_child", spear)


func hit():
	super()
	velocity.y = -80
	if Globals.player_reference != null:
		velocity.x = sign(position.x - Globals.player_reference.position.x) * 64
	throw_cd = 40
