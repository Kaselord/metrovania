extends Area2D

var its_over : bool = false


func _physics_process(_delta):
	if its_over:
		Globals.active = false
		Globals.time_until_active = 2


func _process(_delta):
	if Input.is_action_just_pressed("pause") && its_over:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_body_entered(body):
	if body.is_in_group("player"):
		its_over = true
		MusicManager.play_song("closing_the_book")
		if get_tree().current_scene.is_in_group("gameplay"):
			get_tree().current_scene.show_ui = false
		$anim.play("end")
