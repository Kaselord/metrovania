extends Projectile

var bounces : int = 2


func _ready():
	if Globals.player_reference != null:
		velocity.x = -(position.x - Globals.player_reference.position.x)
		velocity.y = -100


func _physics_process(delta):
	if Globals.active:
		velocity.y += 500 * delta
		$circle.rotation_degrees += velocity.x * 0.1
		if bounces > 0:
			$circle.modulate.a = clamp($circle.modulate.a + 0.05, 0.0, 1.0)
		else:
			$circle.modulate.a = clamp($circle.modulate.a - 0.05, 0.0, 1.0)
			if modulate.a <= 0:
				call_deferred("free")
		
		if $circle.modulate.a < 0.9:
			$hurtbox/CollisionShape2D.disabled = true
		else:
			$hurtbox/CollisionShape2D.disabled = false
	super(delta)


func _on_body_entered(body):
	if body.get_class() == "TileMap" && velocity.y > 0:
		if bounces <= 0:
			call_deferred("free")
		else:
			velocity.y = -bounces * 100
			velocity.x *= 0.5
			bounces -= 1


func _on_area_entered(area):
	if area.is_in_group("kick"):
		$hurtbox.ignore_in_detection = ["player"]
		velocity.x = -velocity.x * 2
		velocity.y = -20
