extends Node

# permanent gets written to file on save, temporary gets emptied
var temporary_savings : Dictionary = {
	
}
var permanent_savings : Dictionary = {
	"player_powerups" : {
		"dash" : true,
		"double_jump" : true
	}
}


func set_powerup(tag : String, value : bool):
	permanent_savings["player_powerups"][tag] = value


func get_powerup(tag : String):
	return permanent_savings["player_powerups"][tag]
