extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		if Globals.level_reference != null:
			var point_name : String = "[color=#0dcdae]" + name + "[/color]"
			var level_file_path : String = "[color=#100dcd]" + Globals.level_reference.scene_file_path
			print_rich("set respawn point to " + point_name + " in " + level_file_path)
			Globals.level_switch_data = [name, Globals.level_reference.scene_file_path]
