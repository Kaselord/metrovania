extends Area2D

@export var scroll : NodePath
@export var leftmost_collider : NodePath


func _on_body_entered(body):
	if body.is_in_group("player"):
		get_node(scroll).is_active = true
		get_node(leftmost_collider).set_deferred("disabled", false)
