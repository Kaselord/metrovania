extends Entity

@export var pos_left : Vector2
@export var pos_right : Vector2
@export var skull_scene : PackedScene
var rot_speed : float = 1.0
var particle_cd : int = 0
var state : String = "idle"
var time_until_attack : int = 60
var attack_time_remaining : int = 0


func _ready():
	super()


func _physics_process(_delta):
	if Globals.active && hp > 0:
		$bone_circle.modulate.a = lerp($bone_circle.modulate.a, 1.0, 0.2)
		$sprite.modulate.a = lerp($sprite.modulate.a, 1.0, 0.1)
		
		if state == "idle":
			position = lerp(position, pos_left + Vector2(0, sin(Globals.time * 3)) * 16, 0.1)
			if time_until_attack > 0:
				time_until_attack -= 1
			else:
				choose_attack()
		else:
			attack_mode()
		
		if particle_cd > 0:
			particle_cd -= 1
		else:
			particle_cd = 4
			spawn_trail_particle()
		
	elif hp < 1:
		if $bone_circle.modulate.a > 0:
			$bone_circle.modulate.a -= 0.02
	
	$sprite.rotation_degrees = lerp($sprite.rotation_degrees, 0.0, 0.2)
	$bone_circle.rotation_degrees += 5 * rot_speed
	$bone_circle.scale.x = 0.8 + (sin(Globals.time * 5.0) + 1)*0.2
	$bone_circle.scale.y = $bone_circle.scale.x
	rot_speed = lerp(rot_speed, 1.0, 0.1)


func spawn_trail_particle():
	if Globals.level_reference != null:
		var particle = Preloads.texture_particle.instantiate()
		particle.init["scale"] = Vector2(-1.0, 1.0)
		particle.init["position"] = global_position
		particle.init["modulate"] = Color(1.0, 0.8, 0.8, 0.8)
		particle.init["rotation"] = $sprite.rotation_degrees
		particle.final["scale"] = Vector2(-$sprite.scale.x, 1.0)
		particle.final["position"] = global_position
		particle.final["modulate"] = Color(1.0, 0.0, 0.0, 0.0)
		particle.final["rotation"] = $sprite.rotation_degrees
		particle.texture = $sprite.texture
		
		particle.lifetime = 32
		particle.snap_weight = 0.05
		Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)


func enter_idle():
	state = "idle"
	time_until_attack = 90


func choose_attack():
	state = "skull"
	attack_time_remaining = 80


func attack_mode():
	if state == "skull":
		if fmod(float(attack_time_remaining), 40) == 0.0:
			$sprite.rotation = -TAU
			summon_skull()
	
	if attack_time_remaining > 0:
		attack_time_remaining -= 1
	else:
		enter_idle()


func summon_skull():
	if Globals.level_reference != null:
		var skull = skull_scene.instantiate()
		skull.position = global_position
		if Globals.player_reference != null:
			skull.velocity = Vector2(sign(Globals.player_reference.position.x - position.x) * 100, 0.0)
		Globals.level_reference.get_node("projectiles").call_deferred("add_child", skull)


func hit():
	super()
	$sprite.rotation_degrees = 360
	rot_speed = -1.0
