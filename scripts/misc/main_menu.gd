extends Node2D

var initialized : bool = false

func _process(_delta):
	if !initialized:
		initialized = true
		MusicManager.play_song("darkness_is_approaching")
