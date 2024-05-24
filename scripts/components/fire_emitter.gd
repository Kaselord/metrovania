extends Node2D

@export var fire_texture : Texture
@export var properties = {
	"emit_cd" : 1,
	"dimensions" : Vector2(32, -32)
}
@export var active : bool = false
var cooldown : int = 0


func _physics_process(_delta):
	if active:
		if cooldown < properties["emit_cd"]:
			cooldown += 1
		else:
			cooldown = 0
			var dimensions : Vector2 = properties["dimensions"]
			create_fire_particle(dimensions.y, dimensions.x, Color("291f1c"))
			create_fire_particle(dimensions.y, dimensions.x, Color("bd2909"))
			create_fire_particle(dimensions.y, dimensions.x, Color("f68e33"))
			create_fire_particle(dimensions.y, dimensions.x, Color("fadb76"))
			create_fire_particle(dimensions.y, dimensions.x, Color(1, 1, 1, 1))


func create_fire_particle(height : float = -32.0, width : float = 32, starting_color : Color = Color(1, 1, 1, 1)):
	if Globals.level_reference != null:
		var particle = Preloads.texture_particle.instantiate()
		var position_adder : float = randf_range(-width*0.25, width*0.25)
		var angle : float = randf_range(-1.0, 1.0)
		var vector_dir : Vector2 = Vector2(sin(angle), cos(angle))
		particle.init["position"] = global_position + Vector2(position_adder, 0)
		particle.init["rotation"] = randf_range(-180, 180)
		var scale_factor : float = randf_range(0.25, 1.5)
		particle.init["scale"] = Vector2(scale_factor, scale_factor)
		particle.init["modulate"] = starting_color
		
		var position_vector : Vector2 = Vector2(vector_dir.x * randf_range(0, width), vector_dir.y * height)
		particle.final["position"] = global_position + Vector2(position_adder, 0) + position_vector
		particle.final["rotation"] = randf_range(-180, 180)
		particle.final["scale"] = Vector2(scale_factor, scale_factor) * 0.5
		particle.final["modulate"] = Color(starting_color.r, starting_color.g, starting_color.b, 0.1)
		
		particle.lifetime = randi_range(10, 60)
		particle.texture = fire_texture
		
		Globals.level_reference.get_node("particles_front").call_deferred("add_child", particle)
