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


func _ready():
	add_to_group("player")
	Globals.player_reference = self
	super()


func _physics_process(delta):
	if Input.is_action_pressed("test"):
		position = lerp(position, get_global_mouse_position(), 0.1)
	
	if is_floored:
		midair_speed_boost = lerp(midair_speed_boost, 1.0, 0.25)
	else:
		midair_speed_boost = 1.2
	walking_velocity = lerp(walking_velocity, input_dir.x * base_walk_speed, base_accel)
	
	velocity.x = walking_velocity * midair_speed_boost
	velocity.y = clamp(velocity.y + gravity * delta, -jump_power * 2, gravity)
	
	if Globals.active:
		move_and_slide()
	
	is_floored = is_on_floor()
	if is_floored:
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
		trail_particle_spawn_cooldown = 4
		if abs(velocity.x) + abs(velocity.y) > 2:
			spawn_trail_particle()
	
	var debug_output = ""
	debug_output = debug_output + "SPD_X: " + str(int(velocity.x)) + "\n"
	debug_output = debug_output + "SPD_Y: " + str(int(velocity.y)) + "\n"
	debug_output = debug_output + "POS_X: " + str(int(position.x)) + "\n"
	debug_output = debug_output + "POS_Y: " + str(int(position.y))
	$debug.text = debug_output


func _process(_delta):
	input_dir = Input.get_vector("left", "right", "up", "down")
	input_dir.x = sign(snapped(input_dir.x, 1.0))
	input_dir.y = sign(snapped(input_dir.y, 1.0))
	
	if Input.is_action_just_pressed("jump"):
		if is_floored or coyote_buffer > 0:
			execute_jump()
		else:
			jump_buffer = 6
	
	if Input.is_action_just_released("jump"):
		if velocity.y < 0 && !jump_has_been_released:
			velocity.y *= 0.5
	
	if Globals.active:
		if abs(velocity.x) > 0:
			$visuals.scale.x = sign(velocity.x)
		
		if abs(velocity.x) > base_walk_speed * 0.05:
			$anim.play("walk")
		else:
			$anim.play("idle")
	else:
		$anim.stop()


func execute_jump():
	velocity.y = -jump_power
	jump_has_been_released = false
	jump_buffer = 0
	coyote_buffer = 0


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
