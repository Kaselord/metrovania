extends Entity

var walking_velocity : float = 0.0
var input_dir : Vector2 = Vector2(0, 0)
var base_walk_speed : float = 80.0
var base_accel : float = 0.35
var gravity : float = 500.0
var jump_power : float = 200.0
var is_floored : bool = false
var jump_buffer : int = 0
var coyote_buffer : int = 0
var jump_has_been_released : bool = false
var midair_speed_boost : float = 1.0
var trail_particle_spawn_cooldown : int = 5
var look_dir : float = 1.0
var is_dashing : int = 0
var gravity_power : float = 1.0
var trail_color : Color = Color(0.0, 0.0, 1.0, 0.05)
var dash_power_x : float = 0.0
var is_allowed_to_dash : bool = true
@export var dash_sparkle_texture : Texture
@export var circle_texture : Texture
var double_jump_remains : bool = true
var hit_effect : float = 0.0
var is_attacking : int = 0


func _ready():
	add_to_group("player")
	Globals.player_reference = self
	$hurtbox.add_to_group("whip")
	super()


func _physics_process(delta):
	if Input.is_action_pressed("test"):
		position = lerp(position, get_global_mouse_position(), 0.1)
	
	if is_floored:
		midair_speed_boost = lerp(midair_speed_boost, 1.0, 0.25)
	else:
		midair_speed_boost = 1.2
	walking_velocity = lerp(walking_velocity, input_dir.x * base_walk_speed, base_accel)
	
	velocity.x = (walking_velocity * midair_speed_boost) * gravity_power + dash_power_x
	if Globals.active:
		velocity.y = clamp(velocity.y + gravity * delta * gravity_power, -jump_power * 2, gravity)
	
	if Globals.active:
		move_and_slide()
	
	is_floored = is_on_floor()
	if is_floored:
		double_jump_remains = true
		is_allowed_to_dash = true
		coyote_buffer = 8
	
	if jump_buffer > 0:
		jump_buffer -= 1
		if is_floored:
			execute_jump()
	
	if coyote_buffer > 0:
		coyote_buffer -= 1
	
	if trail_particle_spawn_cooldown > 0:
		trail_particle_spawn_cooldown -= 1
	else:
		if is_dashing <= 0:
			trail_particle_spawn_cooldown = 4
		else:
			trail_particle_spawn_cooldown = 2
		if abs(velocity.x) + abs(velocity.y) > 2:
			spawn_trail_particle(trail_color)
	
	if is_dashing > 0:
		gravity_power = 0
		is_dashing -= 1
		trail_color = Color(1, 0, 0, 0.05)
	else:
		trail_color = Color(0, 0, 1, 0.05)
		dash_power_x = 0.0
	
	if is_attacking > 0:
		spawn_whip_particle(dash_sparkle_texture)
		gravity_power = 0.5
		is_attacking -= 1
		is_allowed_to_dash = false
		if is_floored:
			gravity_power = 0.0
	
	if is_dashing <= 0 && is_attacking <= 0:
		gravity_power = 1.0
	
	hp = clamp(hp, 0, SaveManager.get_powerup("max_hp"))
	if hit_effect > 0:
		hit_effect -= 0.4
	hit_effect = clamp(hit_effect, 0, 50.0)
	var discoloration : float = (cos(hit_effect) + 1) * 0.5
	$visuals.modulate.a = discoloration
	$visuals.modulate.g = discoloration
	$visuals.modulate.b = discoloration
	$visuals.modulate.r = 1


func _process(_delta):
	if Globals.active:
		get_input()
	
	if Globals.active:
		if abs(velocity.x) > 0:
			$visuals.scale.x = sign(velocity.x)
		var normal_state : bool = is_dashing <= 0 && is_attacking <= 0
		if normal_state:
			$visuals/whip.hide()
			if is_floored:
				# walking
				if abs(walking_velocity) > base_walk_speed * 0.05:
					$anim.play("walk")
				else: # idling
					$anim.play("idle")
			else:
				# falling 
				if velocity.y > 0:
					$anim.play("fall")
				else: # jumping
					$anim.play("jump")
		elif is_dashing > 0:
			$anim.play("dash")
	else:
		$anim.stop()


func get_input():
	if is_attacking <= 0:
		input_dir = Input.get_vector("left", "right", "up", "down")
	input_dir.x = sign(snapped(input_dir.x, 1.0))
	input_dir.y = sign(snapped(input_dir.y, 1.0))
	if input_dir.x != 0:
		look_dir = input_dir.x
	
	if Input.is_action_just_pressed("jump"):
		if is_floored or coyote_buffer > 0:
			execute_jump()
		elif double_jump_remains && SaveManager.get_powerup("double_jump"): # double jump!
			double_jump_remains = false
			spawn_double_jump_particles()
			spawn_double_jump_particles(0.5)
			execute_jump(1.2)
		else:
			jump_buffer = 6
	
	if Input.is_action_just_released("jump"):
		if velocity.y < 0 && !jump_has_been_released:
			velocity.y *= 0.5
	
	if Input.is_action_just_pressed("dash") && is_dashing <= 0 && is_allowed_to_dash && SaveManager.get_powerup("dash"):
		if !is_floored:
			is_allowed_to_dash = false
		spawn_dash_particles()
		is_dashing = 16
		velocity.y = 0
		dash_power_x = look_dir * base_walk_speed * 5
		trail_color = Color(1, 0, 0, 0.05)
		gravity_power = 0
	
	if Input.is_action_just_pressed("attack") && is_dashing <= 0 && is_attacking <= 0:
		is_attacking = 30
		$hurtbox.scale.x = $visuals.scale.x
		$anim.stop()
		$anim.play("whip")
		gravity_power = 0.5


func execute_jump(power_amplify : float = 1.0):
	velocity.y = -jump_power * power_amplify
	jump_has_been_released = false
	jump_buffer = 0
	coyote_buffer = 0
	if is_dashing > 0:
		is_dashing = 10
	is_allowed_to_dash = true


func spawn_trail_particle(final_color : Color = Color(0, 0, 1, 0.05)):
	var particle = Preloads.texture_particle.instantiate()
	particle.init["scale"] = Vector2(1.0, 1.0)
	particle.init["position"] = $visuals/sprite.global_position
	particle.init["modulate"] = Color(0.8, 0.8, 1, 0.8)
	particle.final["scale"] = Vector2(1.0, 1.0)
	particle.final["position"] = $visuals/sprite.global_position
	particle.final["modulate"] = final_color
	particle.texture = $visuals/sprite.texture
	particle.frame_amount = $visuals/sprite.hframes
	particle.frame_index = $visuals/sprite.frame
	particle.sprite_scale = $visuals.scale
	particle.lifetime = 20
	particle.snap_weight = 0.1
	if Globals.level_reference != null:
		Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)


func spawn_dash_particles(diameter : float = 1.0, is_whip_end : bool = false):
	if Globals.level_reference != null:
		for i in range(12.0):
			var angle : float = (TAU / 12.0) * i
			var vector : Vector2 = Vector2(sin(angle), cos(angle))
			var particle = Preloads.texture_particle.instantiate()
			var pos : Vector2 = $visuals/sprite.global_position
			if is_whip_end:
				pos = $visuals/whip/end_point.global_position
			particle.init["scale"] = Vector2(1.0, 1.0)
			particle.init["position"] = pos + vector * 16 * diameter
			particle.init["modulate"] = Color(1, 1, 1, 1)
			particle.init["rotation"] = randf_range(0.0, 180)
			particle.final["scale"] = Vector2(0.5, 0.5)
			particle.final["position"] = pos + vector * 24 * diameter
			particle.final["modulate"] = Color(1, 1, 1, 0)
			particle.final["rotation"] = randf_range(0.0, 180)
			particle.texture = dash_sparkle_texture
			particle.lifetime = randi_range(16, 24)
			Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)


func spawn_double_jump_particles(circle_size : float = 1.0):
	if Globals.level_reference != null:
		for i in range(24.0):
			var angle : float = (TAU / 24.0) * i
			var vector : Vector2 = Vector2(sin(angle) * 2, cos(angle) * 0.75)
			var particle = Preloads.texture_particle.instantiate()
			var color_weight = abs(vector.y + 0.6) / 1.2 # 1 is back, 0 is front
			var particle_color = lerp(Color("45a6d7"), Color("92fff0"), color_weight)
			particle.init["position"] = global_position - Vector2(0, 20) + vector * 6 * circle_size
			particle.init["modulate"] = particle_color
			particle.init["rotation"] = randf_range(0.0, 90)
			particle.final["scale"] = Vector2(0, 0)
			particle.final["position"] = global_position - Vector2(0, 10) + vector * 12 * circle_size
			particle.final["modulate"] = Color(particle_color.r, particle_color.g, particle_color.b, 0.0)
			particle.texture = circle_texture
			particle.lifetime = int(28 * clamp(1.0/circle_size, 0.75, 1.25)) + randi_range(-1, 1)
			if vector.y < 0:
				Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)
			else:
				Globals.level_reference.get_node("particles_front").call_deferred("add_child", particle)


func spawn_whip_particle(texture : Texture):
	if Globals.level_reference != null:
		var particle = Preloads.texture_particle.instantiate()
		particle.lifetime = 15
		particle.texture = texture
		particle.init["scale"] = Vector2(1, 1)
		particle.init["rotation"] = randf_range(0, 360)
		particle.init["modulate"] = Color(1, 1, 1, 1)
		var random_vector_add : Vector2 = Vector2(randf_range(-4, 4), randf_range(-4, 4))
		particle.init["position"] = $visuals/whip/end_point.global_position + random_vector_add
		
		particle.final["scale"] = Vector2(0.5, 0.5)
		particle.final["rotation"] = randf_range(0, 360)
		particle.final["modulate"] = Color(1, 1, 1, 0)
		particle.final["position"] = $visuals/whip/end_point.global_position + random_vector_add
		
		Globals.level_reference.get_node("particles_front").call_deferred("add_child", particle)


func reset_movement():
	velocity = Vector2(0, 0)
	is_dashing = 0


func _on_hitbox_hit():
	Globals.player_damage_happened = true
	Globals.active = false
	Globals.time_until_active = 5
	hit_effect = 20.0
	if is_dashing <= 0:
		velocity.y = -jump_power * 0.5


func _on_hurtbox_has_hit():
	spawn_dash_particles(0.5, true)
