extends Area2D

var anim_play_cd : int = 0
var frame_adder : int = 0
var actual_frame : int = 0


func _ready():
	add_to_group("save_point")


func _physics_process(_delta):
	if Globals.active:
		if anim_play_cd > 0:
			anim_play_cd -= 1
		else:
			anim_play_cd = 8
			update_frame()
	$sprite.rotation_degrees = lerp($sprite.rotation_degrees, 0.0, 0.1)


func _process(_delta):
	if Interface.display_save_prompt && frame_adder <= 0:
		if Input.is_action_just_pressed("down"): # do the actual saving
			Interface.display_save_prompt = false
			SaveManager.permanent_savings["current_load_data"] = [name, Globals.current_level_name]
			SaveManager.save_to_disk()
			SaveManager.reset_temporary()
			frame_adder = 3
			$sprite.rotation_degrees = -20
			update_frame()
			Interface.start_text("save")
			#SoundPlayer.new_sound(Preloads.sfx_save_point)
			if Globals.player_reference != null:
				Globals.player_reference.refresh_health()
				Globals.player_damage_happened = true


func _on_body_entered(body):
	if body.is_in_group("player") && frame_adder <= 0:
		Interface.display_save_prompt = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		Interface.display_save_prompt = false


func update_frame():
	if actual_frame < 2:
		actual_frame += 1
	else:
		actual_frame = 0
	
	$sprite.frame = actual_frame + frame_adder
