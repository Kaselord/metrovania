extends Projectile

var dir : float = 1.0


func _ready():
	$sprite.scale = Vector2(0, 0)


func _physics_process(delta):
	if Globals.active:
		if abs($sprite.scale.x) < 1.0:
			$sprite.scale += Vector2(-dir * 0.02, 0.02)
		else:
			velocity = lerp(velocity, Vector2(dir * 120, 0.0), 0.2)
	
	$sprite.rotation_degrees += 20.0 * dir
	
	super(delta)


func _on_body_entered(body):
	if body.get_class() == "TileMap":
		call_deferred("free")
