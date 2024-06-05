extends Area2D

@export var entity : NodePath
@export var ignore_tag : String = ""
var current_damager : Area2D
var immunity : int = 0
@export var max_immunity : int = 12
@export var is_player_hitbox : bool = false
signal hit


func _ready():
	add_to_group("hitbox")


func _physics_process(_delta):
	if immunity > 0:
		immunity -= 1
	elif current_damager != null && get_node_or_null(entity) != null:
		if ignore_tag != "":
			if !current_damager.ignore_in_detection.has(ignore_tag):
				trigger_internal_hit()
		else:
			trigger_internal_hit()
		if is_player_hitbox && current_damager.void_out:
			print_rich("[color=#ffeb00]voidout[/color]")
			Globals.emit_signal("level_switch")


func trigger_internal_hit():
	immunity = max_immunity
	var entity_node = get_node_or_null(entity)
	if entity_node != null:
		entity_node.hp -= current_damager.damage
		emit_signal("hit")
		current_damager.emit_signal("has_hit")
		entity_node.hit()
		var debug_damager : String = "[color=#c00016]" + current_damager.get_parent().name + "[/color]"
		var debug_victim : String = "[color=#0092e0]" + get_node(entity).name + "[/color]"
		var debug_damage_number : String = "[color=#68e086]" + str(current_damager.damage) + " dmg" + "[/color]"
		print_rich("hit from " + debug_damager + " to " + debug_victim + " - " + debug_damage_number)


func _on_area_entered(area):
	if area.is_in_group("hurtbox"):
		current_damager = area


func _on_area_exited(area):
	if area == current_damager:
		current_damager = null
