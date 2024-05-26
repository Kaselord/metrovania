extends Node

# permanent gets written to file on save, temporary gets emptied
var temporary_savings : Dictionary = {
	
}
var permanent_savings : Dictionary = {
	"player_powerups" : {
		"dash" : false,
		"double_jump" : false,
		"strength" : false,
		"current_hp" : 100,
		"max_hp" : 100
	}
	
}


func set_powerup(tag : String, value : Variant):
	permanent_savings["player_powerups"][tag] = value


func get_powerup(tag : String):
	return permanent_savings["player_powerups"][tag]
