extends CharacterBody2D

var walking_velocity : float = 0.0
var input_dir : Vector2 = Vector2(0, 0)
var base_walk_speed : float = 90.0
var base_accel : float = 0.35
var gravity : float = 500.0
var jump_power : float = 200.0
var is_floored : bool = false
var jump_buffer : int = 0
var coyote_buffer : int = 0
var jump_has_been_released : bool = false
var midair_speed_boost : float = 1.0


func _ready():
	add_to_group("player")
	Globals.player_reference = self


func _physics_process(delta):
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
	
	var debug_output = ""
	debug_output = debug_output + "SPD_X: " + str(int(velocity.x)) + "\n"
	debug_output = debug_output + "SPD_Y: " + str(int(velocity.y)) + "\n"
	debug_output = debug_output + "POS_X: " + str(int(position.x)) + "\n"
	debug_output = debug_output + "POS_Y: " + str(int(position.y))
	$debug.text = debug_output


func _process(_delta):
	input_dir = sign(Input.get_vector("left", "right", "up", "down"))
	if Input.is_action_just_pressed("jump"):
		if is_floored or coyote_buffer > 0:
			execute_jump()
		else:
			jump_buffer = 6
	
	if Input.is_action_just_released("jump"):
		if velocity.y < 0 && !jump_has_been_released:
			velocity.y *= 0.5


func execute_jump():
	velocity.y = -jump_power
	jump_has_been_released = false
	jump_buffer = 0
	coyote_buffer = 0
