extends Area2D

@export var tag : String = ""
var orig_pos : Vector2
var angle : float = 0.0
@export var texture : Texture
var particle_cd = 4
@export var unlock_text : String


func _ready():
	orig_pos = position
	$sprite.texture = texture


func _physics_process(_delta):
	if Globals.level_reference != null: # delete if already collected
		var path_to_self : String = String(Globals.level_reference.get_path_to(self))
		var level_file_path : String = Globals.level_reference.scene_file_path
		if SaveManager.get_permanent_deletion(path_to_self, level_file_path):
			call_deferred("free")
	
	angle += 0.05
	position = orig_pos + Vector2(sin(angle), cos(angle)) * 8
	if particle_cd > 0:
		particle_cd -= 1
	else:
		particle_cd = 4
		emit_trail_particle()


func emit_trail_particle():
	if Globals.level_reference != null:
		var particle = Preloads.texture_particle.instantiate()
		particle.init["position"] = global_position
		particle.init["modulate"] = Color(1, 1, 1, 1)
		particle.init["scale"] = Vector2(1, 1)
		particle.final["scale"] = Vector2(0.5, 0.5)
		particle.final["position"] = global_position
		particle.final["modulate"] = Color(1, 1, 1, 0)
		particle.texture = $sprite.texture
		particle.lifetime = 40
		Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)


func _on_body_entered(body):
	if body.is_in_group("player"):
		SaveManager.set_powerup(tag, true)
		Interface.start_text(unlock_text)
		if Globals.level_reference != null:
			var path_to_self : String = String(Globals.level_reference.get_path_to(self))
			var level_file_path : String = Globals.level_reference.scene_file_path
			SaveManager.set_permanent_deletion(path_to_self, level_file_path)
		call_deferred("free")
