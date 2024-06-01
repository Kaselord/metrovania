extends CanvasLayer

var transition_value : int = 25
var max_transition : int = 25
var text_active : bool = false
var current_text_identifier : String = ""
var text_table : Dictionary = {}
var current_text_index : int = 0
var length_of_current_text : int = 0
var current_paragraph_length : int = 0
var displayed_paragraph_characters : float = 0.0
var typewriter_effect_speed : float = 0.4
var name_of_speaker_length : int = 0
var display_save_prompt : bool = false
@export var sfx_text_continue : AudioStream
var text_sound_cd : int = 0
var max_text_sound_cd : int = 5
var text_sound_pitch = 1.2


func _ready():
	var text_file = FileAccess.open("res://data/text_interactions.json", FileAccess.READ)
	text_table = JSON.parse_string(text_file.get_as_text()) as Dictionary
	text_file.close()


func _physics_process(_delta):
	# -- dialogue system shenanigans --
	if transition_value < max_transition:
		transition_value += 1
	
	$transition_rect.modulate.a = float(max_transition - snapped(abs(transition_value), 5)) * 0.05
	
	if text_active:
		$text_box.modulate.a = clamp($text_box.modulate.a + 0.05, 0.0, 1.0)
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash"):
			if $text_box/display_dialogue.visible_ratio > 0.99:
				continue_active_text()
			else:
				typewriter_effect_speed = 1.5
				max_text_sound_cd = 3
				text_sound_pitch = 1.5
		if displayed_paragraph_characters < current_paragraph_length:
			if text_sound_cd > 0:
				text_sound_cd -= 1
			else:
				text_sound_cd = max_text_sound_cd
				SoundPlayer.new_sound(sfx_text_continue, 0.0, text_sound_pitch + randf_range(-0.1, 0.1))
			displayed_paragraph_characters += typewriter_effect_speed
			$text_box/display_dialogue.visible_characters = name_of_speaker_length + int(displayed_paragraph_characters)
	else:
		$text_box.modulate.a = clamp($text_box.modulate.a - 0.05, 0.0, 1.0)
	
	# -- save prompt stuffs --
	# make sure the value doesn't accidentally stay true when going to a menu
	if Globals.player_reference == null:
		display_save_prompt = false
	# actual input for this is handled in save_point.gd
	if display_save_prompt:
		$save_prompt.modulate.a = lerp($save_prompt.modulate.a, 1.0, 0.1)
	else:
		$save_prompt.modulate.a = lerp($save_prompt.modulate.a, 0.0, 0.15)


func start_text(text_identifier : String = "", pause_gameplay : bool = true):
	# check if text interaction exists
	if text_table.keys().has(text_identifier):
		text_active = true
		current_text_identifier = text_identifier
		Globals.ongoing_event = text_identifier
		if pause_gameplay:
			Globals.active = false
		current_text_index = 0
		length_of_current_text = len(text_table[current_text_identifier])
		continue_active_text()


func continue_active_text():
	# confirm that index hasn't surpassed amount of dialogues
	if current_text_index < length_of_current_text:
		typewriter_effect_speed = 0.4
		max_text_sound_cd = 5
		text_sound_pitch = 1.2
		var name_of_speaker : String = text_table[current_text_identifier][current_text_index][0]
		var paragraph : String = text_table[current_text_identifier][current_text_index][1]
		displayed_paragraph_characters = 0.0
		# get amount of characters in the speaker name
		if name_of_speaker != "none":
			name_of_speaker_length = len(name_of_speaker) + 2 # +2 because of the : and newline
		else:
			name_of_speaker_length = 0
		current_paragraph_length = len(paragraph)
		if name_of_speaker != "none":
			$text_box/display_dialogue.text = name_of_speaker + ":\n" + paragraph
		else:
			$text_box/display_dialogue.text = paragraph
		# Display "Name of speaker:" instantly
		$text_box/display_dialogue.visible_characters = len(name_of_speaker) + 1
		
		if len(text_table[current_text_identifier][current_text_index]) > 2:
			Globals.ongoing_event = text_table[current_text_identifier][current_text_index][2]
		
		current_text_index += 1
	else:
		abandon_text()


func abandon_text():
	Globals.time_until_active = 1
	text_active = false
