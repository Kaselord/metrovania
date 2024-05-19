@tool
extends Hurtbox

@export var width : float = 16
@export var death_texture : Texture
var particle_cd : int = 4
@export var particle_height : float = 100


func _ready():
	if !Engine.is_editor_hint():
		super()
		$collider.shape.size.x = width


func _process(_delta):
	if Engine.is_editor_hint():
		$collider.shape.size.x = width


func _physics_process(_delta):
	if !Engine.is_editor_hint():
		if particle_cd > 0:
			particle_cd -= 1
		else:
			emit_particle()
			particle_cd = 6


func emit_particle():
	var particle = Preloads.texture_particle.instantiate()
	var width_adjusted : float = float(width) - 4.0
	var x_pos = randf_range(-width_adjusted * 0.5, width_adjusted * 0.5)
	particle.init["scale"] = Vector2(1.0, 1.0)
	particle.init["position"] = global_position + Vector2(x_pos, 0)
	particle.init["modulate"] = Color(1, 1, 1, 1.0)
	particle.final["scale"] = Vector2(1.0, 1.0)
	particle.final["position"] = global_position + Vector2(x_pos, -particle_height)
	particle.final["modulate"] = Color(1, 1, 1, 0.0)
	particle.texture = death_texture
	particle.lifetime = 80
	Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)
