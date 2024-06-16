extends Entity

var floor_y : float = 0.0
var prev_pos : Vector2
var dst_to_last_frame : Vector2 = Vector2(0, 0)
var leg_move_immunities : Array = [0, 0, 0, 0, 0, 0]
var max_leg_immunity_value : int = 20
var flee_amplify : float = 1.0
var attack_cd : int = 60
var start : bool = false
var rage : int = 0
var eyes_remaining : int = 1
var fire_cd : int = -1
@export var eye_projectile_scene : PackedScene
@export var fireball_scene : PackedScene
var is_attacking : int = 0


func _physics_process(_delta):
	if Globals.active && hp > 0 && start:
		prev_pos = position
		
		if $floor_check.is_colliding() && $floor_check.get_collider().name == "tiles":
			velocity.y = $floor_check.get_collision_point().y - position.y + sin(Globals.time * 5) * 8
			floor_y = to_local($floor_check.get_collision_point()).y
		
		$visuals/body.rotation_degrees = velocity.x * 0.1
		if Globals.player_reference != null && is_attacking <= 0:
			var player_pos : Vector2 = Globals.player_reference.position
			if abs(position.x - player_pos.x) < 96:
				flee_amplify = lerp(flee_amplify, 2.5, 0.1)
			else:
				flee_amplify = lerp(flee_amplify, 1.0, 0.1)
			var target_x : float = player_pos.x + sign(position.x - player_pos.x) * 96 * flee_amplify
			velocity.x = lerp(velocity.x, target_x - position.x, 0.2)
			$visuals/eye/iris.look_at(Globals.player_reference.position)
			move_and_slide()
		
		var body_rot_radians : float = deg_to_rad($visuals/body.rotation_degrees)
		$visuals/eye.position = $visuals/body.position + Vector2(sin(body_rot_radians), -cos(body_rot_radians)) * 48
		
		dst_to_last_frame = position - prev_pos
		leg_anim($visuals/leg_left_top, Vector2(-16, -32), 0)
		leg_anim($visuals/leg_right_up, Vector2(8, -48), 4)
		leg_anim($visuals/leg_right_top, Vector2(16, -32), 1)
		leg_anim($visuals/leg_left_up, Vector2(-8, -48), 5)
		leg_anim($visuals/leg_left_bottom, Vector2(-10, -24), 2)
		leg_anim($visuals/leg_right_bottom, Vector2(10, -24), 3)
		$visuals.modulate = lerp($visuals.modulate, Color(1, 1, 1, 1), 0.2)
		
		if attack_cd > 0:
			attack_cd -= 1
		else: 
			$visuals/eye.scale = Vector2(0, 0)
			attack_cd = choose_attack()
		
		if is_attacking > 0:
			is_attacking -= 1
		
		if fire_cd > 0:
			fire_cd -= 1
			$visuals/eye/iris/fire_emitter.active = true
		else:
			$visuals/fire_paragraph.modulate.a = lerp($visuals/fire_paragraph.modulate.a, 0.0, 0.2)
			$visuals/eye/iris/fire_emitter.active = false
			if fire_cd == 0:
				spawn_fireball()
				fire_cd = -1
		$visuals/fire_paragraph.points[0] = to_local($visuals/eye/iris.global_position)
		if Globals.player_reference != null:
			$visuals/fire_paragraph.points[1] = to_local(Globals.player_reference.position - Vector2(0, 24))
		
	elif hp <= 0:
		$visuals.modulate -= Color(0.01, 0.01, 0.01, 0.01)
		if $visuals.modulate.a <= 0:
			call_deferred("free")
	elif !start:
		if Globals.player_reference != null:
			if abs(Globals.player_reference.position.x - position.x) < 214:
				start = true
				for path in open_gates_on_death:
					var gate = get_node(path)
					gate.down = true
				MusicManager.play_song("it_doesnt_want_to_die")
	
	$visuals/eye.scale = lerp($visuals/eye.scale, Vector2(1.0, 1.0), 0.2)


func leg_anim(leg_node : Line2D, leg_origin : Vector2, assigned_index : int):
	var target_leg_point_distance : float = 24.0
	
	for i in leg_node.get_point_count():
		leg_node.points[i] -= dst_to_last_frame
	
	# end point adjust
	var leg_occupations : int = 0
	for i in len(leg_move_immunities):
		leg_occupations += leg_move_immunities[i]
	
	if leg_move_immunities[assigned_index] <= 0:
		if abs(leg_node.points[0].x - leg_node.points[2].x) > target_leg_point_distance:
			if leg_occupations <= 1 or abs(leg_node.points[0].x - leg_node.points[2].x) > target_leg_point_distance * 2:
				leg_move_immunities[assigned_index] = 20
	else:
		leg_move_immunities[assigned_index] -= 1
		var weight : float = float(20 - leg_move_immunities[assigned_index]) * 0.05
		var height : float = (abs(leg_move_immunities[assigned_index] - 10) - 10)
		leg_node.points[2] = lerp(leg_node.points[2], Vector2(0, floor_y + height), weight)
	
	# start point adjust
	leg_node.points[0] = leg_origin
	
	leg_node.points[1] = lerp(leg_node.points[0], leg_node.points[2], 0.5) + Vector2(sign(leg_origin.x) * 24, -8)


func choose_attack():
	var cooldown : int = 60
	if rage > 8:
		cooldown = 20
		eyes_remaining = 0
	if rage <= 0:
		cooldown = 80
	
	if eyes_remaining > 0:
		eyes_remaining -= 1
		spawn_eye()
	else:
		fire_cd = 30
		blink_laser()
		is_attacking = 30
		cooldown = 120
		if rage < 8:
			eyes_remaining = 2
		else:
			cooldown = 40
	
	if rage > 0:
		rage -= 1
	
	return cooldown


func spawn_eye():
	if Globals.level_reference != null:
		var eye_projectile = eye_projectile_scene.instantiate()
		eye_projectile.position = $visuals/eye.global_position
		Globals.level_reference.get_node("projectiles").call_deferred("add_child", eye_projectile)


func spawn_fireball():
	if Globals.level_reference != null:
		var fireball = fireball_scene.instantiate()
		fireball.position = $visuals/eye/iris/fire_emitter.global_position
		Globals.level_reference.get_node("projectiles").call_deferred("add_child", fireball)


func blink_laser():
	$visuals/fire_paragraph.points[0] = to_local($visuals/eye/iris.global_position)
	if Globals.player_reference != null:
		$visuals/fire_paragraph.points[1] = to_local(Globals.player_reference.position)
	$visuals/fire_paragraph.modulate.a = 1.0


func hit():
	super()
	flee_amplify = 8
	rage += 2
	$visuals/eye.scale = Vector2(1.4, 1.4)
	$visuals.modulate = Color(1, 0, 0, 1)
	if hp <= 0:
		MusicManager.play_song("none")
		$fire_emitter.active = true
		$fire_emitter2.active = true
		$hitbox/CollisionShape2D.disabled = true
