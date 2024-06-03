extends Area2D
class_name Projectile

var velocity : Vector2 = Vector2(0, 0)


func _physics_process(delta):
	if Globals.active:
		position += velocity * delta
