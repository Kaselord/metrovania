extends Entity

var floor_y : float = 0.0
var prev_pos : Vector2
var dst_to_last_frame : Vector2 = Vector2(0, 0)
var leg_move_immunities : Array = [0, 0, 0, 0, 0, 0]
var max_leg_immunity_value : int = 20
var flee_amplify : float = 1.0


func _physics_process(_delta):
	if Globals.active && hp > 0:
		prev_pos = position
		
		if $floor_check.is_colliding() && $floor_check.get_collider().name == "tiles":
			velocity.y = $floor_check.get_collision_point().y - position.y + sin(Globals.time * 5) * 8
			floor_y = to_local($floor_check.get_collision_point()).y
		
		$visuals/body.rotation_degrees = velocity.x * 0.1
		if Globals.player_reference != null:
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
	elif hp <= 0:
		$visuals.modulate -= Color(0.01, 0.01, 0.01, 0.01)
		if $visuals.modulate.a <= 0:
			call_deferred("free")
	
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


func hit():
	super()
	flee_amplify = 8
	$visuals/eye.scale = Vector2(1.4, 1.4)
	$visuals.modulate = Color(1, 0, 0, 1)
	if hp <= 0:
		$fire_emitter.active = true
		$fire_emitter2.active = true
		$hitbox/CollisionShape2D.disabled = true
