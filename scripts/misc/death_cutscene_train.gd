extends Sprite2D

var pos_target : Vector2 = Vector2(0, 0)
var alpha_target : float = 0.0
var particle_cooldown : int = 0
var do_things : bool = false
var actual_pos : Vector2 = Vector2(0, 0)
var max_particle_cd : int = 4
var interpolation : float = 0.08
var item_steal_cd : int = 0
var item_steal_textures : Array = []
var end : bool = false


func _ready():
	pos_target = position - Vector2(0, 90)
	actual_pos = pos_target


func _physics_process(_delta):
	if Globals.ongoing_event == "death_train":
		Globals.ongoing_event = ""
		pos_target = pos_target + Vector2(0, 90)
		alpha_target = 1.0
		do_things = true
	
	modulate.a = lerp(modulate.a, alpha_target, 0.2)
	actual_pos = lerp(actual_pos, pos_target, interpolation)
	position = actual_pos + Vector2(sin(Globals.time * 1.8), cos(Globals.time * 1.8)) * 10 * modulate.a
	
	if do_things:
		if particle_cooldown > 0:
			particle_cooldown -= 1
		else:
			particle_cooldown = max_particle_cd
			spawn_trail_particle()
		if !Interface.text_active:
			interpolation = 0.01
			max_particle_cd = 1
			pos_target = pos_target - Vector2(0, 70)
			alpha_target = 0.0
			if !end:
				end = true
				Globals.level_switch_data = ["wake_up", "res://scenes/levels/002_the_other_side.tscn"]
				Globals.emit_signal("level_switch")
				if Globals.player_reference != null:
					Globals.player_reference.velocity = Vector2(0, 0)
		else:
			max_particle_cd = 4
			interpolation = 0.08
		
		if Globals.ongoing_event == "powerup_stealing":
			Globals.ongoing_event = ""
			item_steal_textures = [
				load("res://textures/powerups/double_jump.png"),
				load("res://textures/powerups/dash.png")
			]
			if Globals.player_reference != null:
				Globals.player_reference.get_node("anim").play("fall")
		
		if len(item_steal_textures) > 0:
			if item_steal_cd > 0:
				item_steal_cd -= 1
			else:
				item_steal_cd = 20
				spawn_powerup_particle(item_steal_textures[0])
				item_steal_textures.remove_at(0)


func spawn_trail_particle():
	var particle = Preloads.texture_particle.instantiate()
	particle.init["scale"] = Vector2(1.0, 1.0)
	particle.init["position"] = global_position
	particle.init["modulate"] = Color(1.0, 0.8, 0.8, 0.8)
	particle.final["scale"] = Vector2(1.0, 1.0)
	particle.final["position"] = global_position
	particle.final["modulate"] = Color(1.0, 0.0, 0.0, 0.0)
	particle.texture = texture
	particle.lifetime = 32
	particle.snap_weight = 0.05
	if Globals.level_reference != null:
		Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)


func spawn_powerup_particle(texture_to_use : Texture):
	if Globals.player_reference != null:
		Globals.player_reference.spawn_dash_particles()
		var particle = Preloads.texture_particle.instantiate()
		particle.init["scale"] = Vector2(1, 1)
		particle.init["position"] = Globals.player_reference.global_position - Vector2(0, 22)
		particle.init["modulate"] = Color(1, 1, 1, 1)
		particle.final["scale"] = Vector2(1, 1)
		particle.final["position"] = global_position
		particle.final["modulate"] = Color(1, 1, 1, 0)
		particle.texture = texture_to_use
		if Globals.level_reference != null:
			Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)
