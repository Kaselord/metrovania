extends Node2D

# do not use outside of loading levels
# 'Globals.set_player_value("value")' or 'Globals.get_player_value("value")' instead
var temporary_player_reference : Node = null
@export var player_packed_scene : PackedScene


func _ready():
	add_to_group("gameplay")
	unload_current_level()
	load_level("res://scenes/levels/000_entrance.tscn")


func _process(_delta):
	# check if a level is present
	if $active_level.get_child_count() > 0:
		if temporary_player_reference != null:
			# look for entity parent node
			var active_level = $active_level.get_child(0)
			var entity_parent_node = active_level.get_node_or_null("entities")
			# if found, add player to it
			if entity_parent_node != null:
				temporary_player_reference.reparent(entity_parent_node)
				temporary_player_reference.position = Vector2(160, 90)
				$camera.to_follow = temporary_player_reference.get_path()
				$camera.position = temporary_player_reference.position
				$camera.limit_left = active_level.top_left.x
				$camera.limit_top = active_level.top_left.y
				$camera.limit_right = active_level.bottom_right.x
				$camera.limit_bottom = active_level.bottom_right.y
				set_deferred("temporary_player_reference", null)


func unload_current_level():
	# get reference to player
	var entitity_parent_node : Node = null
	if $active_level.get_child_count() > 0:
		entitity_parent_node = $active_level.get_child(0).get_node_or_null("entities")
		temporary_player_reference = $active_level.get_child(0).get_node_or_null("entities/player")
	# create a new player if they can't be found
	if temporary_player_reference == null:
		instantiate_new_player()
	
	# temporarily add the player as child of this scene (to prevent deletion)
	if entitity_parent_node != null:
		entitity_parent_node.call_deferred("remove_child", temporary_player_reference)
	self.call_deferred("add_child", temporary_player_reference)
	temporary_player_reference.position = Vector2(0, 0)
	
	# delete level
	for child in $active_level.get_children():
		child.call_deferred("free")


func load_level(level_path : String):
	var new_level = load(level_path).instantiate()
	$active_level.call_deferred("add_child", new_level)


func instantiate_new_player():
	var new_player = player_packed_scene.instantiate()
	temporary_player_reference = new_player
