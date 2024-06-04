extends InterfaceElement

@export_enum("switch_scene", "delete_save", "quit") var on_action : String = "start_game"
@export var parameters : Array = []


func action():
	match on_action:
		"switch_scene":
			get_tree().change_scene_to_file(parameters[0])
