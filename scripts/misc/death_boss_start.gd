extends Sprite2D

@export var collider : NodePath
@export var entities : NodePath
@export var boss_path : NodePath
var particle_cooldown : int = 0
var actual_pos : Vector2
var its_over : bool = false


func _ready():
	actual_pos = position


func _physics_process(_delta):
	if !its_over:
		if particle_cooldown > 0:
			particle_cooldown -= 1
		else:
			particle_cooldown = 5
			spawn_trail_particle()
		position = actual_pos + Vector2(sin(Globals.time * 2), -cos(Globals.time * 2)) * 10 * modulate.a
		show()
	else:
		hide()
	
	if Globals.ongoing_event == "start_death_fight":
		Globals.ongoing_event = ""
		its_over = true
		MusicManager.trigger_special_thing("death_fight")
		get_node(boss_path).start = true


func _on_death_trigger_body_entered(body):
	if body.is_in_group("player"):
		if get_tree().current_scene.is_in_group("gameplay"):
			var top_left : Vector2i = Vector2i(-344, 0)
			var bottom_right : Vector2i = Vector2i(-24, 180)
			get_tree().current_scene.get_node("camera").set_borders(top_left, bottom_right)
		get_node(collider).set_deferred("disabled", true)
		Interface.start_text("death_boss")


func spawn_trail_particle():
	if Globals.level_reference != null:
		var particle = Preloads.texture_particle.instantiate()
		particle.init["scale"] = Vector2(-1.0, 1.0)
		particle.init["position"] = global_position
		particle.init["modulate"] = Color(1.0, 0.8, 0.8, 0.8)
		particle.final["scale"] = Vector2(-1.0, 1.0)
		particle.final["position"] = global_position
		particle.final["modulate"] = Color(1.0, 0.0, 0.0, 0.0)
		particle.texture = texture
		
		particle.lifetime = 32
		particle.snap_weight = 0.05
		Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)
