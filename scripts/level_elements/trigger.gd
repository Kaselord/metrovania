@tool
extends Area2D

@export_enum("start_text", "save_game", "open_gate", "play_music") var function = "start_text"
@export var params : Array = []
@export var permanently_delete : bool = false
@export var size : Vector2 = Vector2(48, 48)
var initiated : bool = false


func _ready():
	if !Engine.is_editor_hint():
		$collider.shape.size = size
		$collider.position.y = -size.y * 0.5


func _process(_delta):
	if Engine.is_editor_hint():
		$collider.shape.size = size
		$collider.position.y = -size.y * 0.5
	else:
		if !initiated:
			if Globals.level_reference != null:
				initiated = true
				var path_to_self : String = String(Globals.level_reference.get_path_to(self))
				var level_file_path : String = Globals.level_reference.scene_file_path
				if SaveManager.get_permanent_deletion(path_to_self, level_file_path):
					$collider.disabled = true


func _on_body_entered(body):
	if body.is_in_group("player"):
		do_thing()
		if permanently_delete:
			if Globals.level_reference != null:
				var path_to_self : String = String(Globals.level_reference.get_path_to(self))
				var level_file_path : String = Globals.level_reference.scene_file_path
				SaveManager.set_permanent_deletion(path_to_self, level_file_path)
		call_deferred("free")


func do_thing():
	match function:
		"start_text":
			Interface.start_text(params[0], true)
		"save_game":
			SaveManager.permanent_savings["current_load_data"][0] = "wake_up"
			SaveManager.save_to_disk()
		"open_gate":
			var gate = get_node(params[0])
			gate.down = params[1]
			var path_to_gate : String = String(Globals.level_reference.get_path_to(gate))
			var level_file_path : String = Globals.level_reference.scene_file_path
			SaveManager.set_permanent_deletion(path_to_gate, level_file_path)
		"play_music":
			MusicManager.play_song(params[0])
