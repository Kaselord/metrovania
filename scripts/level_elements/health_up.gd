extends Area2D

var initialized : bool = false


func _process(_delta):
	if !initialized:
		if Globals.level_reference != null:
			initialized = true
			if SaveManager.get_permanent_deletion(Globals.level_reference.get_path_to(self), name):
				call_deferred("free")


func _on_body_entered(body):
	if body.is_in_group("player"):
		SaveManager.set_powerup("max_hp", SaveManager.get_powerup("max_hp") + 5)
		if Globals.player_reference != null:
			Globals.player_reference.refresh_health()
		if Globals.level_reference != null:
			SaveManager.set_permanent_deletion(Globals.level_reference.get_path_to(self), name)
		call_deferred("free")
