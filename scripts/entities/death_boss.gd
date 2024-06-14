extends Entity

@export var pos_left : Vector2
@export var pos_right : Vector2
@export var floor_pos_y : float
@export var skull_scene : PackedScene
@export var spike_scene : PackedScene
var start : bool = false
var rot_speed : float = 1.0
var particle_cd : int = 0
var state : String = "idle"
var time_until_attack : int = 60
var attack_time_remaining : int = 0
var current_attack : int = 0
var is_left : bool = true
var target_pos : Vector2


func _ready():
	super()
	target_pos = pos_left


func _physics_process(_delta):
	if Globals.active && hp > 0 && start:
		
		if state == "idle":
			$bone_circle.modulate.a = lerp($bone_circle.modulate.a, 1.0, 0.2)
			$sprite.modulate.a = lerp($sprite.modulate.a, 1.0, 0.1)
			position = lerp(position, target_pos + Vector2(0, sin(Globals.time * 3)) * 16, 0.1)
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
		if $sprite.modulate.a > 0:
			$sprite.modulate -= Color(0.01, 0.01, 0.01, 0.01)
		else:
			call_deferred("free")
	
	$sprite.rotation_degrees = lerp($sprite.rotation_degrees, 0.0, 0.2)
	$bone_circle.rotation_degrees += 5 * rot_speed * $sprite.scale.x
	$bone_circle.scale.x = 0.8 + (sin(Globals.time * 5.0) + 1)*0.2
	$bone_circle.scale.y = $bone_circle.scale.x
	rot_speed = lerp(rot_speed, 1.0, 0.1)


func spawn_trail_particle():
	if Globals.level_reference != null && $sprite.modulate.a > 0.8:
		var particle = Preloads.texture_particle.instantiate()
		particle.init["scale"] = Vector2(-$sprite.scale.x, 1.0)
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
	time_until_attack = 110


func choose_attack():
	if current_attack == 0:
		state = "skull"
		attack_time_remaining = 80
	elif current_attack == 1:
		state = "spike"
		attack_time_remaining = 100
	elif current_attack == 2:
		state = "switch"
		attack_time_remaining = 60
	
	if current_attack < 2:
		current_attack += 1
	else:
		current_attack = 0


func attack_mode():
	if state == "skull":
		if fmod(float(attack_time_remaining), 40) == 0.0:
			$sprite.rotation = -TAU
			summon_skull()
	elif state == "spike":
		if fmod(float(attack_time_remaining), 20) == 0.0:
			summon_spike(5 - int(float(attack_time_remaining) / 20.0))
	elif state == "switch":
		var value : float = abs(float(attack_time_remaining - 30) / 30.0)
		$sprite.modulate = Color(value, value, value, value)
		$bone_circle.modulate = Color(value, value, value, value)
		if value == 0.0:
			switch_sides()
	
	if attack_time_remaining > 0:
		attack_time_remaining -= 1
	else:
		enter_idle()


func switch_sides():
	if is_left:
		target_pos = pos_right
		is_left = false
		$sprite.scale.x = -1
	else:
		target_pos = pos_left
		is_left = true
		$sprite.scale.x = 1
	position = target_pos + Vector2(0, sin(Globals.time * 3)) * 16


func summon_skull():
	if Globals.level_reference != null:
		var skull = skull_scene.instantiate()
		skull.position = global_position
		if Globals.player_reference != null:
			skull.velocity = Vector2(sign(Globals.player_reference.position.x - position.x) * 100, 0.0)
		Globals.level_reference.get_node("projectiles").call_deferred("add_child", skull)


func summon_spike(index : int = 0):
	if Globals.level_reference != null && Globals.player_reference != null:
		var spike = spike_scene.instantiate()
		var spike_pos_x : float = position.x + sign(Globals.player_reference.position.x - position.x) * (36*(index+1))
		spike.position = Vector2(spike_pos_x, floor_pos_y)
		Globals.level_reference.get_node("behind_tiles").call_deferred("add_child", spike)


func hit():
	super()
	$sprite.rotation_degrees = 360
	rot_speed = -1.0
	if hp < 0:
		if get_tree().current_scene.is_in_group("gameplay"):
			get_tree().current_scene.get_node("camera").reset_borders()
		$fire_emitter.active = true
		$hurtbox/CollisionShape2D.disabled = true
		$hitbox/CollisionShape2D.disabled = true
