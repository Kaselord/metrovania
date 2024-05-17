extends CharacterBody2D

var walking_velocity : float = 0.0


func _physics_process(delta):
	velocity.x = walking_velocity


func _process(delta):
	pass
