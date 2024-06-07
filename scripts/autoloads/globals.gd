extends Node

var active : bool = true
var player_reference : Node = null
var level_reference : Node = null
signal level_switch
var time_until_switch : int = 0
var time_until_active : int = 0
var is_switching_level : bool = false
var level_switch_data = ["", "res://scenes/levels/000_entrance.tscn"]
var current_level_name : String = "res://scenes/levels/000_entrance.tscn"
var ongoing_event : String = ""
var time : float = 0.0
var player_damage_happened : bool = false


func _physics_process(delta):
	time += delta
	
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
			elif !Interface.text_active:
				active = true
	
	update_game_interface()


func set_player_value(id : String, new_value : Variant):
	if player_reference != null && player_reference.is_in_group("player"):
		match id:
			"position":
				player_reference.position = new_value
			"velocity":
				player_reference.velocity = new_value
			"input_dir":
				player_reference.input_dir = new_value
			"hp":
				player_reference.hp = new_value


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
			"hp":
				value = player_reference.hp
	return value


func _on_level_switch():
	if get_tree().current_scene.is_in_group("gameplay"):
		active = false
		# start the 50 frame screen transition
		Interface.transition_value = -25
		# 25 frames until the new level is loaded
		time_until_switch = 25
		# additional 25 frames until things start moving
		time_until_active = 25
		is_switching_level = true
		current_level_name = level_switch_data[1]
		print_rich("[color=#ff6700][b]" + "level switch - " + str(level_switch_data))


func update_game_interface():
	var gameplay_scene = get_tree().current_scene
	if gameplay_scene != null && gameplay_scene.is_in_group("gameplay"):
		# player health bar
		var healthbar_text = gameplay_scene.get_node("interface/healthbar/amount")
		if get_player_value("hp") != null:
			healthbar_text.label_settings.font_color = lerp(healthbar_text.label_settings.font_color, Color(1, 1, 1, 1), 0.1)
			if player_damage_happened:
				player_damage_happened = false
				healthbar_text.label_settings.font_color = Color(1, 0, 0, 1)
			healthbar_text.text = str(clamp(get_player_value("hp"), 0, 100))
