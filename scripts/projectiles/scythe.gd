extends Projectile

var bounces_remaining : int = 2


func _physics_process(delta):
	velocity.y += 500 * delta
	
	$sprite.rotation_degrees += sign(velocity.x) * 10
	if velocity.x != null:
		$sprite.scale.x = sign(velocity.x)
	
	super(delta)
	
	if bounces_remaining < 0:
		call_deferred("free")


func _on_body_entered(body):
	if body.get_class() == "TileMap":
		velocity.y = -250
		bounces_remaining -= 1
