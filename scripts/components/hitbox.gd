extends Area2D

@export var entity : NodePath
@export var ignore_tag : String = ""
var current_damager : Area2D
var immunity : int = 0
@export var max_immunity : int = 12
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


func trigger_internal_hit():
	immunity = max_immunity
	var entity_node = get_node_or_null(entity)
	if entity_node != null:
		entity_node.hp -= current_damager.damage
		emit_signal("hit")
		current_damager.emit_signal("has_hit")
		entity_node.hit()
		print("hit from " + current_damager.get_parent().name + " to " + get_node(entity).name + " - " + str(current_damager.damage) + " dmg")


func _on_area_entered(area):
	if area.is_in_group("hurtbox"):
		current_damager = area


func _on_area_exited(area):
	if area == current_damager:
		current_damager = null
