extends Node2D


func play_sound():
	SoundPlayer.new_sound(Preloads.sfx_beep, 0.0, 1.2)
