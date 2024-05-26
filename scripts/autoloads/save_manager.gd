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
		"current_hp" : 100,
		"max_hp" : 100
	},
	"permanent_deletion" : [] # same as temporary
}


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
