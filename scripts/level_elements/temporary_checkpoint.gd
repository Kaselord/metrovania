extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		if Globals.level_reference != null:
			print("set respawn point to " + name + " in " + Globals.level_reference.scene_file_path)
			Globals.level_switch_data = [name, Globals.level_reference.scene_file_path]
