extends InterfaceElement

@export_enum("switch_scene", "delete_save", "quit", "do_nothing") var on_action : String = "do_nothing"
@export var parameters : Array = []
@export var display_text : String = "BUTTON"
var color_hue : float = 0.0
var stored_transition_file : String = ""

func _ready():
	$label.text = display_text


func _physics_process(_delta):
	if selected:
		if color_hue < 1.0:
			color_hue += 0.02
		else:
			color_hue = 0.0
		$label.modulate.h = color_hue
		$label.modulate.s = 1.0
		$label.modulate.v = 0.75
		if Interface.transition_value == 0:
			get_tree().change_scene_to_file(stored_transition_file)
	else:
		$label.modulate = Color(1, 1, 1, 1)


func action():
	match on_action:
		"switch_scene":
			Interface.transition_value = -25
			stored_transition_file = parameters[0]
		"delete_save":
			pass # are you sure????
		"quit":
			if OS.get_name() != "Web":
				get_tree().quit()
		"do_nothing":
			print("this message should not be visible in the final product")
