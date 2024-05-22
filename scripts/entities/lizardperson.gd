extends Entity

@export var from_x : float = 0.0
@export var to_x : float = 16.0
@export var walk_dir : float = 1.0
var speed : float = 50.0


func _physics_process(delta):
	if Globals.active:
		$anim.play("walk")
		velocity.x = walk_dir * speed
		velocity.y = clamp(velocity.y + 100 * delta, -100, 100)
		if position.x - from_x < 0:
			walk_dir = 1
		if position.x - to_x > 0:
			walk_dir = -1
		$sprite.scale.x = walk_dir
		move_and_slide()
	else:
		$anim.stop()
