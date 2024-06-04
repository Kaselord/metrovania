extends Projectile

var speed : float = 100.0


func _ready():
	explode_spectacularly()


func _physics_process(delta):
	if Globals.active:
		if Globals.player_reference != null:
			velocity = lerp(velocity, (Globals.player_reference.position - position).normalized() * speed, 0.1)
		super(delta)
		if speed > 10.0:
			speed -= 0.5
		else:
			explode_spectacularly()
			call_deferred("free")


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
