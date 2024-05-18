extends Camera2D

@export var to_follow : NodePath
var interpolation = 0.2


func _physics_process(_delta):
	var follow_object = get_node_or_null(to_follow)
	if follow_object != null:
		position = lerp(position, follow_object.position + follow_object.velocity * 0.1, interpolation)
