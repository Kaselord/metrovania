extends Node

var name_index : int = 0


func new_sound(stream : AudioStream, volume_db : float = 0.0, pitch : float = 1.0):
	var streamplayer = AudioStreamPlayer.new()
	streamplayer.stream = stream
	streamplayer.volume_db = volume_db
	streamplayer.pitch_scale = pitch
	streamplayer.name = "sound" + str(name_index)
	streamplayer.autoplay = true
	if name_index < 255:
		name_index += 1
	else:
		name_index = 0
	call_deferred("add_child", streamplayer)


func _process(_delta):
	for streamplayer in get_children():
		if !streamplayer.playing:
			streamplayer.call_deferred("free")
