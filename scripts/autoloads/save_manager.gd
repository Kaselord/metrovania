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
		"max_hp" : 100
	},
	"permanent_deletion" : [], # same as temporary
	"current_load_data" : ["start", "res://scenes/levels/000_entrance.tscn"]
}
var savestates : Array = []
var max_savestate_amount : int = 64


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


func create_savestate():
	var savestate : Dictionary = permanent_savings
	savestates.append(savestate)
	if len(savestates) > max_savestate_amount:
		savestates.remove_at(0)
	save_to_disk()
	print("savestate created at index " + str(len(savestates) - 1))


func load_from_savestate(target_index : int = 0):
	load_from_disk()
	
	if len(savestates) > target_index:
		permanent_savings = savestates[target_index]
		print("loaded savestate at index " + str(target_index))
	else:
		print("failed to load savestate at index " + str(target_index))


func save_to_disk():
	var file = FileAccess.open(OS.get_executable_path().get_base_dir() + "/" + "save_file.json", FileAccess.WRITE)
	print("saved to " + OS.get_executable_path().get_base_dir() + "/" + "save_file.json")
	file.store_string(JSON.stringify(savestates))
	file.close()


func load_from_disk():
	if FileAccess.file_exists(OS.get_executable_path().get_base_dir() + "/" + "save_file.json"):
		var file = FileAccess.open(OS.get_executable_path().get_base_dir() + "/" + "save_file.json", FileAccess.READ)
		print("loaded from " + OS.get_executable_path().get_base_dir() + "/" + "save_file.json")
		if file.get_as_text() != "":
			savestates = JSON.parse_string(file.get_as_text())
		file.close()
