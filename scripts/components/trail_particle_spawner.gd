extends Node2D
# this component was written rather late into the development period, please replace the old particle spawners sometime

@export var particle_cd : int = 0
@export var max_particle_cd : int = 5
# some values are omitted as they're derived from a target sprite
@export var init_modulate : Color = Color(1, 1, 1, 1)
@export var final_modulate : Color = Color(1, 1, 1, 1)
@export var sprite_to_base_on : NodePath
@export var lifetime : int = 30
@export var display_at_back : bool = true


func _physics_process(_delta):
	if particle_cd > 0:
		particle_cd -= 1
	else:
		particle_cd = max_particle_cd
		spawn_particle()


func spawn_particle():
	if Globals.level_reference != null:
		var sprite = get_node(sprite_to_base_on)
		var particle = Preloads.texture_particle.instantiate()
		
		particle.texture = sprite.texture
		
		particle.init["position"] = global_position
		particle.init["rotation"] = sprite.rotation_degrees
		particle.init["scale"] = sprite.scale
		particle.init["modulate"] = init_modulate
		
		particle.final["position"] = global_position
		particle.final["rotation"] = sprite.rotation_degrees
		particle.final["scale"] = sprite.scale
		particle.final["modulate"] = final_modulate
		
		particle.lifetime = lifetime
		
		if display_at_back:
			Globals.level_reference.get_node("particles_back").call_deferred("add_child", particle)
		else:
			Globals.level_reference.get_node("particles_front").call_deferred("add_child", particle)
