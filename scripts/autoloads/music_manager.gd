extends Node

var loop_start : float = 0.0
var loop_end : float = 1.0
var current_song_name : String = ""
var mute_music : bool = false


var song_table = {
	 # [file, start loop, end loop]
	"losing_my_train_of_thought" : [load("res://audio/music/losing_my_train_of_thought.ogg"), 13.74, 82.29]
}


func play_song(tag : String):
	if current_song_name != tag && tag != "none" && !mute_music:
		$player.volume_db = -16.0
		$player.stream = song_table[tag][0]
		loop_start = song_table[tag][1]
		loop_end = song_table[tag][2]
		current_song_name = tag
		$player.play(0.0)
		print("now playing " + tag)
	elif tag == "none":
		current_song_name = "none"
		$player.stream = null
		$player.stop()


func _process(_delta):
	if $player.get_playback_position() >= loop_end or !$player.playing:
		if current_song_name != "none" && !mute_music: # don't loop if there is no song
			$player.play(loop_start)
			print("music loop")
