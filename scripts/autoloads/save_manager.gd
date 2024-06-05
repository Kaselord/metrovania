extends Node

# permanent gets written to file on save, temporary gets emptied
var temporary_savings : Dictionary = {
	"temporary_deletion" : [] # [level name, path to thing relative to level]
}
var permanent_savings : Dictionary = {
	"player_powerups" : {
		"dash" : true,
		"double_jump" : true,
		"strength" : true,
		"spear" : false,
		"max_hp" : 100
	},
	"permanent_deletion" : [], # same as temporary
	"current_load_data" : ["start", "res://scenes/levels/000_entrance.tscn"],
	"default_settings" : {
		"window_mode" : DisplayServer.WINDOW_MODE_WINDOWED,
		"volume_sfx" : 0.5,
		"volume_music" : 0.5
	}
}
var max_savestate_amount : int = 64


func _ready():
	load_from_disk()
	AudioServer.set_bus_volume_db(1, lerp(-32, 16, permanent_savings["default_settings"]["volume_sfx"]))
	AudioServer.set_bus_volume_db(2, lerp(-32, 16, permanent_savings["default_settings"]["volume_music"]))
	DisplayServer.window_set_mode(permanent_savings["default_settings"]["window_mode"])
	get_window().grab_focus()


func set_powerup(tag : String, value : Variant):
	permanent_savings["player_powerups"][tag] = value


func get_powerup(tag : String):
	return permanent_savings["player_powerups"][tag]


func set_temporary_deletion(path_to_thing : String, level_scene_path : String):
	temporary_savings["temporary_deletion"].append([level_scene_path, path_to_thing])


func get_temporary_deletion(path_to_thing : String, level_scene_path : String):
	if temporary_savings["temporary_deletion"].has([level_scene_path, path_to_thing]):
		return true
	else:
		return false


func reset_temporary():
	temporary_savings["temporary_deletion"] = []


func set_permanent_deletion(path_to_thing : String, level_scene_path : String):
	permanent_savings["permanent_deletion"].append([level_scene_path, path_to_thing])


func get_permanent_deletion(path_to_thing : String, level_scene_path : String):
	if permanent_savings["permanent_deletion"].has([level_scene_path, path_to_thing]):
		return true
	else:
		return false


func save_to_disk():
	var file = FileAccess.open(OS.get_executable_path().get_base_dir() + "/" + "save_file.json", FileAccess.WRITE)
	print_rich("[color=#27ff00]" + "saved to " + OS.get_executable_path().get_base_dir() + "/" + "save_file.json" + "[/color]")
	file.store_string(JSON.stringify(permanent_savings))
	file.close()

 
func load_from_disk():
	if FileAccess.file_exists(OS.get_executable_path().get_base_dir() + "/" + "save_file.json"):
		var file = FileAccess.open(OS.get_executable_path().get_base_dir() + "/" + "save_file.json", FileAccess.READ)
		print_rich("[color=#27ff00]" + "loaded from " + OS.get_executable_path().get_base_dir() + "/" + "save_file.json" + "[/color]")
		if file.get_as_text() != "":
			permanent_savings = JSON.parse_string(file.get_as_text()) as Dictionary
		file.close()
