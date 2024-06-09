extends Projectile

var direction_vector : Vector2 = Vector2(1, 0)
var target_pos : Vector2 = Vector2(0, 0)
var override_dir : bool = false
var stationary : bool = false
var init : bool = false
var time_until_explosion : int = 50
var time : int = 0
var begone : bool = false


func _physics_process(delta):
	if !init:
		init = true
		if !override_dir:
			if Globals.player_reference != null:
				direction_vector = ((Globals.player_reference.position - Vector2(0, 24)) - position).normalized()
		else:
			direction_vector = (target_pos - position).normalized()
		$sprite.look_at(position + direction_vector * 16)
	
	if Globals.active:
		if begone:
			call_deferred("free")
		if !stationary:
			velocity = direction_vector * 700
		else:
			velocity = Vector2(0, 0)
			time_until_explosion -= 1
		
		$sprite.modulate = lerp(Color(1, 1, 1, 1), Color(1, 0, 0, 1), 1 - float(time_until_explosion) / 50.0)
		$sprite.scale = lerp(Vector2(1, 1), Vector2(1.2, 1.4), 1 - float(time_until_explosion) / 50.0)
		
		if time_until_explosion <= 0:
			SoundPlayer.new_sound(Preloads.sfx_kaboom, 0.0, randf_range(0.9, 1.1))
			$hurtbox/CollisionShape2D.disabled = false
			Interface.flash = 1.0
			for i in range(25):
				$sprite/fire_emitter.position = Vector2(0, 0)
				$sprite/fire_emitter.create_fire_particle(-80, 64, Color("b90711"))
			begone = true
		
		super(delta)
	time += 1
	if time > 1000:
		call_deferred("free")


func _on_body_entered(body):
	if body.get_class() == "TileMap":
		stationary = true
	if body.is_in_group("player"):
		stationary = true
		time_until_explosion = 0
