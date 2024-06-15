extends Node

var loop_start : float = 0.0
var loop_end : float = 1.0
var current_song_name : String = "none"
var mute_music : bool = false


var song_table = {
	 # [file, start loop, end loop]
	"losing_my_train_of_thought" : [load("res://audio/music/losing_my_train_of_thought.ogg"), 13.74, 82.29],
	"ride_of_death" : [load("res://audio/music/ride_of_death.ogg"), 2.0, 5.0],
	"it_doesnt_want_to_die" : [load("res://audio/music/it_doesnt_want_to_die.ogg"), 3.428, 82.29],
	"darkness_is_approaching" : [load("res://audio/music/darkness_is_approaching.ogg"), 5.333, 37.33],
	"the_sound_of_peace" : [load("res://audio/music/the_sound_of_peace.ogg"), 0.0, 152.37],
	"the_sound_of_war" : [load("res://audio/music/the_sound_of_war.ogg"), 0.0, 54.86],
	"rain_of_skulls_light" : [load("res://audio/music/rain_of_skulls_light.ogg"), 0.0, 48.0],
	"rain_of_skulls_heavy" : [load("res://audio/music/rain_of_skulls_heavy.ogg"), 0.0, 48.0],
	"closing_the_book" : [load("res://audio/music/closing_the_book.ogg"), 0.0, 92.36],
	"howling_winds" : [load("res://audio/music/howling_winds.ogg"), 0.0, 22.34]
}


func play_song(tag : String, start_pos : float = 0.0):
	if current_song_name != tag && tag != "none" && !mute_music:
		loop_start = song_table[tag][1]
		loop_end = song_table[tag][2]
		if current_song_name == "none":
			current_song_name = tag
			$player.volume_db = -6
			trigger_song_play(start_pos)
		else:
			$anim.play("transition")
			current_song_name = tag
		print_rich("[i][color=#ff80fd]" + "~ now playing " + "\'" + tag + "\'" + "[/color][/i]")
	elif tag == "none":
		current_song_name = "none"
		$anim.play("transition")


func _process(_delta):
	if $player.get_playback_position() >= loop_end or !$player.playing:
		 # don't loop if there is no song or it's transitioning
		if current_song_name != "none" && !mute_music && !$anim.is_playing():
			$player.play(loop_start)
			print_rich("[color=#9400af]music loop[/color]")


func trigger_song_play(start_pos : float = 0.0):
	if current_song_name != "none":
		$player.stream = song_table[current_song_name][0]
		$player.play(start_pos)
	else:
		$player.stream = null
		$player.stop()


func get_playback():
	return $player.get_playback_position()


func trigger_special_thing(tag : String = ""):
	match tag:
		"train_start":
			$player.play(8.5)
			loop_start = 17.142
			loop_end = 51.43
		"death_fight":
			current_song_name = "rain_of_skulls_heavy"
			trigger_song_play(get_playback())
