extends Projectile

var speed : float = 200.0
var vector : Vector2 = Vector2(1, 0)


func _ready():
	explode_spectacularly()
	if Globals.player_reference != null:
		vector = (Globals.player_reference.position - position).normalized()


func _physics_process(delta):
	if Globals.active:
		velocity = vector * speed
		super(delta)


func explode_spectacularly():
	var dimensions = Vector2(64, -64)
	for i in range(28):
		$fire_emitter.create_fire_particle(dimensions.y, dimensions.x, Color("b90711"))


func _on_hurtbox_has_hit():
	explode_spectacularly()
	call_deferred("free")


func _on_area_entered(area):
	if area.is_in_group("kick"):
		explode_spectacularly()
		call_deferred("free")


func _on_body_entered(body):
	if body.get_class() == "TileMap":
		explode_spectacularly()
		call_deferred("free")
