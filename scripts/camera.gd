extends Camera2D

@export var to_follow : NodePath
var interpolation : float = 0.2
var snap : bool = false
var store_original_borders : Array = [Vector2(-1.0, -1.0), Vector2(1.0, 1.0)]


func _physics_process(_delta):
	var follow_object = get_node_or_null(to_follow)
	if snap:
		snap = false
		if follow_object != null:
			position = follow_object.global_position - Vector2(0, 20)
	if follow_object != null && Globals.active:
		var velocity_adder : Vector2 = Vector2(follow_object.velocity.x * 0.2, follow_object.velocity.y * 0.15)
		var target_pos : Vector2 = follow_object.position + Vector2(clamp(velocity_adder.x, -40, 40), clamp(velocity_adder.y, -40, 40))
		position = lerp(position, target_pos - Vector2(0, 20), interpolation)


func reset_borders():
	limit_left = store_original_borders[0].x
	limit_top = store_original_borders[0].y
	limit_right = store_original_borders[1].x
	limit_bottom = store_original_borders[1].y
