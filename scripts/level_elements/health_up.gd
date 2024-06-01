extends Area2D

var initialized : bool = false


func _process(_delta):
	if !initialized:
		if Globals.level_reference != null:
			initialized = true
			var path_to_self : String = String(Globals.level_reference.get_path_to(self))
			var level_file_path : String = Globals.level_reference.scene_file_path
			if SaveManager.get_permanent_deletion(path_to_self, level_file_path):
				call_deferred("free")


func _on_body_entered(body):
	if body.is_in_group("player"):
		SaveManager.set_powerup("max_hp", SaveManager.get_powerup("max_hp") + 5)
		Interface.start_text("health_up")
		if Globals.player_reference != null:
			Globals.player_reference.refresh_health()
		if Globals.level_reference != null:
			var path_to_self : String = String(Globals.level_reference.get_path_to(self))
			var level_file_path : String = Globals.level_reference.scene_file_path
			SaveManager.set_permanent_deletion(path_to_self, level_file_path)
		call_deferred("free")
