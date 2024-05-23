extends Entity

@export var from_x : float = 0.0
@export var to_x : float = 16.0
@export var walk_dir : float = 1.0
var speed : float = 50.0


func _physics_process(delta):
	if Globals.active:
		$anim.play("walk")
		velocity.x = walk_dir * speed
		velocity.y = clamp(velocity.y + 200 * delta, -200, 200)
		if position.x - from_x < 0:
			walk_dir = 1
		if position.x - to_x > 0:
			walk_dir = -1
		$sprite.scale.x = walk_dir
		$sprite.scale.y = lerp($sprite.scale.y, 1.0, 0.1)
		move_and_slide()
	else:
		$anim.stop()


func _on_hitbox_hit():
	walk_dir *= -1
	velocity.y = -50
	$sprite.scale.y = 0.6
