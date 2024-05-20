extends Node2D

var activity : float = 0.0
var is_active : bool = false


func _physics_process(delta):
	if is_active:
		if activity < 1:
			activity += delta
	if Globals.active:
		if position.x > -380:
			position.x -= 6 * activity
		else:
			position.x = 100
		modulate = lerp(Color(1, 1, 1, 1), Color(0.5, 0.5, 0.75, 1.0), activity)
