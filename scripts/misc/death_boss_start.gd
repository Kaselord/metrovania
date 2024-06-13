extends Sprite2D

@export var collider : NodePath


func _on_death_trigger_body_entered(body):
	if body.is_in_group("player"):
		if get_tree().current_scene.is_in_group("gameplay"):
			var top_left : Vector2i = Vector2i(-344, 0)
			var bottom_right : Vector2i = Vector2i(-24, 180)
			get_tree().current_scene.get_node("camera").set_borders(top_left, bottom_right)
		get_node(collider).call_deferred("free")
