extends CharacterBody2D
class_name Entity

var hp : int = 1
var has_loaded : bool = false
@export var starting_hp : int = 1
@export var temporarily_save_death : bool = true
@export var permanently_save_death : bool = false
@export var set_ablaze : bool = true
@export var open_gates_on_death : Array = []


func _ready():
	add_to_group("entity")
	hp = starting_hp


func _process(_delta):
	if !has_loaded:
		if Globals.level_reference != null:
			has_loaded = true
			if temporarily_save_death:
				var path_to_self : String = String(Globals.level_reference.get_path_to(self))
				var level_file_path : String = Globals.level_reference.scene_file_path
				if SaveManager.get_temporary_deletion(path_to_self, level_file_path):
					call_deferred("free")
			if permanently_save_death:
				var path_to_self : String = String(Globals.level_reference.get_path_to(self))
				var level_file_path : String = Globals.level_reference.scene_file_path
				if SaveManager.get_permanent_deletion(path_to_self, level_file_path):
					call_deferred("free")


func hit():
	SoundPlayer.new_sound(Preloads.sfx_entity_hit, 0.0, randf_range(0.9, 1.1))
	if hp <= 0:
		death()


func death():
	if set_ablaze:
		SoundPlayer.new_sound(Preloads.sfx_scream, 0.0, randf_range(0.9, 1.0))
		SoundPlayer.new_sound(Preloads.sfx_fire)
	if temporarily_save_death && Globals.level_reference != null:
		var path_to_self : String = String(Globals.level_reference.get_path_to(self))
		var level_file_path : String = Globals.level_reference.scene_file_path
		SaveManager.set_temporary_deletion(path_to_self, level_file_path)
	for path in open_gates_on_death:
		var gate = get_node_or_null(path)
		if gate != null:
			gate.down = false
	if permanently_save_death && Globals.level_reference != null:
		var path_to_self : String = String(Globals.level_reference.get_path_to(self))
		var level_file_path : String = Globals.level_reference.scene_file_path
		SaveManager.set_permanent_deletion(path_to_self, level_file_path)
