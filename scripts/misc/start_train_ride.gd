extends Area2D

@export var scroll : NodePath
@export var leftmost_collider : NodePath


func _on_body_entered(body):
	if body.is_in_group("player"):
		$CollisionShape2D.set_deferred("disabled", true)
		get_node(scroll).is_active = true
		get_node(leftmost_collider).set_deferred("disabled", false)
		MusicManager.trigger_special_thing("train_start")
