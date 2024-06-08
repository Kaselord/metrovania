extends Area2D

var being_stomped_on : bool = false


func _physics_process(_delta):
	if !being_stomped_on:
		$sprite.skew = lerp_angle($sprite.skew, 0.0, 0.1)


func _on_body_entered(body):
	if body.is_in_group("entity"):
		being_stomped_on = true
		var skew_dir : float = sign(position.x - body.position.x)
		$sprite.skew = skew_dir * 45


func _on_body_exited(body):
	if body.is_in_group("entity"):
		being_stomped_on = false
