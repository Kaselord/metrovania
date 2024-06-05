extends Node2D

@export var input_action_name : String = ""
@export var used_inputs : Array = []
@export var actual_input_actions : Array = []


func _ready():
	$input_name.text = input_action_name
	$input_list.text = ""
	for input_text in used_inputs:
		$input_list.text += input_text + "\n"


func _physics_process(_delta):
	var input_culmination : float = 0.0
	for action in actual_input_actions:
		if Input.is_action_pressed(action):
			input_culmination += 1
	if input_culmination > 0 && Globals.active:
		$input_name.modulate = Color(1, 0, 0, 1.0)
	else:
		$input_name.modulate = lerp($input_name.modulate, Color(1, 1, 1, 1.0), 0.1)
