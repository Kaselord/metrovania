extends CharacterBody2D

var walking_velocity : float = 0.0
var input_dir : Vector2 = Vector2(0, 0)
var base_walk_speed : float = 90.0
var base_accel : float = 0.35
var gravity : float = 400.0
var jump_power : float = 220.0
var is_floored : bool = false
var jump_buffer : int = 0
var jump_has_been_released : bool = false

func _physics_process(delta):
	walking_velocity = lerp(walking_velocity, input_dir.x * base_walk_speed, base_accel)
	
	velocity.x = walking_velocity
	velocity.y = clamp(velocity.y + gravity * delta, -1000, gravity)
	
	move_and_slide()
	is_floored = is_on_floor()
	
	if jump_buffer > 0:
		jump_buffer -= 1
		if is_floored:
			execute_jump()

func _process(_delta):
	input_dir = sign(Input.get_vector("left", "right", "up", "down"))
	if Input.is_action_just_pressed("jump"):
		if is_floored:
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
