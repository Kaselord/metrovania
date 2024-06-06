extends InterfaceElement

@export_enum("switch_scene", "quit", "do_nothing", "window_mode", "globals_activity", "delete_save") var on_action : String = "do_nothing"
@export var parameters : Array = []
@export var display_text : String = "BUTTON"
@export var has_param : bool = false
var color_hue : float = 0.0
var stored_transition_file : String = ""

func _ready():
	$label.text = display_text


func init():
	if has_param:
		$additional_param.show()
		update_param_display()


func _physics_process(_delta):
	if selected:
		if color_hue < 1.0:
			color_hue += 0.01
		else:
			color_hue = 0.0
		$label.modulate.h = color_hue
		$label.modulate.s = 1.0
		$label.modulate.v = 0.75
		if Interface.transition_value == 0:
			get_tree().change_scene_to_file(stored_transition_file)
		
		if on_action == "globals_activity":
			Globals.active = true
			Globals.time_until_active = 0
	else:
		Globals.active = false
		Globals.time_until_active = 1
		$label.modulate = Color(1, 1, 1, 1)
	if on_action == "globals_activity":
		update_param_display()


func action():
	match on_action:
		"switch_scene":
			Interface.transition_value = -25
			stored_transition_file = parameters[0]
		"quit":
			if OS.get_name() != "Web":
				SaveManager.save_to_disk()
				get_tree().quit()
		"do_nothing":
			print("this message should not be visible in the final product")
		"window_mode":
			var mode = DisplayServer.window_get_mode()
			if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			elif mode == DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			elif mode == DisplayServer.WINDOW_MODE_MAXIMIZED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			update_param_display()
			SaveManager.permanent_savings["default_settings"]["window_mode"] = DisplayServer.window_get_mode()
		"delete_save":
			SaveManager.reset_permanent()
			SaveManager.save_to_disk()
			Interface.transition_value = -25
			stored_transition_file = "res://scenes/main_menu.tscn"
			print_rich("[b][i][color=#ff0000]SAVE DATA HAS BEEN WIPED")


func update_param_display():
	match on_action:
		"window_mode":
			var current_window_mode = DisplayServer.window_get_mode()
			var mode_as_string : String = "WINDOWED"
			if current_window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
				mode_as_string = "FULLSCREEN"
			elif current_window_mode == DisplayServer.WINDOW_MODE_MAXIMIZED:
				mode_as_string = "MAXIMIZED"
			$additional_param.text = "(" + mode_as_string + ")"
		"globals_activity":
			if Globals.active:
				$additional_param.text = "(ACTIVE)"
			else:
				$additional_param.text = "(NOT ACTIVE)"
