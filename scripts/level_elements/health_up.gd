extends Area2D

var initialized : bool = false
@export var secret : bool = false


func _process(_delta):
	if !initialized:
		if Globals.level_reference != null:
			initialized = true
			var path_to_self : String = String(Globals.level_reference.get_path_to(self))
			var level_file_path : String = Globals.level_reference.scene_file_path
			if SaveManager.get_permanent_deletion(path_to_self, level_file_path):
				call_deferred("free")


func _on_body_entered(body):
	if body.is_in_group("player"):
		SaveManager.set_powerup("max_hp", SaveManager.get_powerup("max_hp") + 5)
		if !secret:
			Interface.start_text("health_up")
		else:
			Interface.start_text("super_secret_health_up")
		if Globals.player_reference != null:
			Globals.player_reference.refresh_health()
		if Globals.level_reference != null:
			var path_to_self : String = String(Globals.level_reference.get_path_to(self))
			var level_file_path : String = Globals.level_reference.scene_file_path
			SaveManager.set_permanent_deletion(path_to_self, level_file_path)
		explode()
		call_deferred("free")


func explode():
	if Globals.level_reference != null:
		for i in range(12.0):
			var angle : float = (TAU / 12.0) * i
			var vector : Vector2 = Vector2(sin(angle), cos(angle))
			var particle = Preloads.texture_particle.instantiate()
			particle.init["scale"] = Vector2(0.2, 0.2)
			particle.init["position"] = global_position
			particle.init["modulate"] = Color(1, 1, 1, 0.8)
			particle.final["position"] = global_position + vector * 24
			particle.final["modulate"] = Color(1, 1, 1, 0.0)
			particle.texture = $sprite.texture
			particle.lifetime = randi_range(15, 30)
			particle.final["scale"] = Vector2(1.1, 1.1)
			Globals.level_reference.get_node("particles_front").call_deferred("add_child", particle)
