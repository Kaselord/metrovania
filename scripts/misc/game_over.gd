extends Node2D

func _physics_process(_delta):
	if Globals.player_is_dead:
		$interface_manager.modulate.a = 0.0
		$interface_manager.active = false
	else:
		$interface_manager.active = true
		$interface_manager.modulate.a = lerp($interface_manager.modulate.a, 1.0, 0.2)
