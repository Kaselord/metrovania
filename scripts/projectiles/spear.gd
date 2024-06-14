extends Projectile

var tag_override : Array = ["evil"]
var final_color : Color = Color(0, 1, 0, 0)
var gravity_dir : float = 1.0
var damage : int = 3
var destroy_on_wall : bool = true
var lifetime : int = 0
var max_particle_cd : int = 1
var particle_cd : int = 0


func _ready():
	$hurtbox.ignore_in_detection = tag_override
	$hurtbox.damage = damage
	if SaveManager.permanent_savings["default_settings"]["reduce_fire"]:
		max_particle_cd = 4


func _physics_process(delta):
	if Globals.active:
		velocity.y += 500 * delta * gravity_dir
		if velocity.x != 0:
			$sprite.rotation_degrees += sign(velocity.x) * 15 * gravity_dir
		else:
			$sprite.rotation_degrees += 15 * gravity_dir
		
		$hurtbox.rotation_degrees = $sprite.rotation_degrees
		
		if particle_cd > 0:
			particle_cd -= 1
		else:
			particle_cd = max_particle_cd
			spawn_trail_particle()
	
	super(delta)
	
	if !destroy_on_wall:
		lifetime += 1
		if lifetime > 120:
			call_deferred("free")


func _on_body_entered(body):
	if body.get_class() == "TileMap" && destroy_on_wall:
		call_deferred("free")


func spawn_trail_particle():
	if Globals.level_reference != null:
		var particle = Preloads.texture_particle.instantiate()
		particle.init["rotation"] = $sprite.rotation_degrees
		particle.init["position"] = global_position
		particle.final["rotation"] = $sprite.rotation_degrees
		particle.final["position"] = global_position
		particle.final["modulate"] = final_color
		particle.lifetime = 20
		particle.texture = $sprite.texture
		Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)
