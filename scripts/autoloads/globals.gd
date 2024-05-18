extends Node

var active : bool = true
var player_reference : Node = null
signal level_switch
var time_until_switch : int = 0
var time_until_active : int = 0
var is_switching_level : bool = false
var level_switch_data = ["", "res://scenes/levels/000_entrance.tscn"]


func _physics_process(_delta):
	if !active && get_tree().current_scene != null && get_tree().current_scene.is_in_group("gameplay"):
		if time_until_switch > 0:
			time_until_switch -= 1
		else:
			if is_switching_level:
				is_switching_level = false
				# load the new level
				get_tree().current_scene.unload_current_level()
				get_tree().current_scene.load_level(level_switch_data)
			if time_until_active > 0:
				time_until_active -= 1
			else:
				active = true


func set_player_value(id : String, new_value : Variant):
	if player_reference != null && player_reference.is_in_group("player"):
		match id:
			"position":
				player_reference.position = new_value
			"velocity":
				player_reference.velocity = new_value
			"input_dir":
				player_reference.input_dir = new_value


func get_player_value(id : String):
	var value : Variant = null
	if player_reference != null && player_reference.is_in_group("player"):
		match id:
			"position":
				value = player_reference.position
			"velocity":
				value = player_reference.velocity
			"input_dir":
				value = player_reference.input_dir
	return value


func _on_level_switch():
	if get_tree().current_scene.is_in_group("gameplay"):
		active = false
		Interface.transition_value = -25
		time_until_switch = 25
		time_until_active = 25
		is_switching_level = true
