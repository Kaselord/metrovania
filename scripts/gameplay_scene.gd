extends Node2D

# do not use outside of loading levels
# 'Globals.set_player_value("value")' or 'Globals.get_player_value("value")' instead
var temporary_player_reference : Node = null
@export var player_packed_scene : PackedScene
# ["start", "res://scenes/levels/000_entrance.tscn"]
var level_switch_data = ["door_left", "res://scenes/levels/003_wandering_halls.tscn"]
# only disable for testing!
var load_from_save : bool = true
var pause_menu_active : bool = false
var show_ui : bool = true
var current_boss_hp : float = 0
var current_boss_max_hp : float = 1
var level_name : String = "res://scenes/levels/000_entrance.tscn"


func _ready():
	add_to_group("gameplay")
	SaveManager.load_from_disk()
	if load_from_save:
		level_switch_data = SaveManager.permanent_savings["current_load_data"]
	unload_current_level()
	load_level(level_switch_data)
	Globals.current_level_name = level_switch_data[1]


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
				temporary_player_reference.position = find_travel_point_position(active_level)
				temporary_player_reference.reset_movement()
				$camera.to_follow = temporary_player_reference.get_path()
				$camera.snap = true
				$camera.position = temporary_player_reference.position
				$camera.limit_left = active_level.top_left.x
				$camera.limit_top = active_level.top_left.y
				$camera.limit_right = active_level.bottom_right.x
				$camera.limit_bottom = active_level.bottom_right.y
				$camera.store_original_borders = [active_level.top_left, active_level.bottom_right]
				set_deferred("temporary_player_reference", null)
	
	if Input.is_action_just_pressed("pause") && !Globals.player_is_dead && show_ui:
		pause_menu_active = !pause_menu_active


func _physics_process(_delta):
	if pause_menu_active:
		$interface/pause_menu.modulate.a = lerp($interface/pause_menu.modulate.a, 1.0, 0.3)
		$interface/pause_menu/interface_manager.active = true
		Globals.active = false
		Globals.time_until_active = 1
	else:
		$interface/pause_menu.modulate.a = lerp($interface/pause_menu.modulate.a, 0.0, 0.3)
		$interface/pause_menu/interface_manager.active = false
	
	if show_ui:
		$interface/healthbar.modulate.a = lerp($interface/healthbar.modulate.a, 1.0, 0.1)
		boss_health_bar()
	else:
		$interface/healthbar.modulate.a = lerp($interface/healthbar.modulate.a, 0.0, 0.1)


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


func load_level(data = ["save_point", "res://scenes/levels/002_the_other_side.tscn"]):
	var new_level = load(data[1]).instantiate()
	$active_level.call_deferred("add_child", new_level)
	level_switch_data = data
	pause_menu_active = false
	
	if !SaveManager.permanent_savings["unlocked_rooms"].has(data[1]):
		SaveManager.permanent_savings["unlocked_rooms"].append(data[1])
	level_name = data[1]
	update_map()


func instantiate_new_player():
	var new_player = player_packed_scene.instantiate()
	temporary_player_reference = new_player


func boss_health_bar():
	if current_boss_max_hp != 0.0: # to avoid dividing by 0
		var health_pos : float = (clamp(current_boss_hp, 0.0, 9999.0) / current_boss_max_hp) * 120
		$interface/boss_bar/health.points[1].x = lerp($interface/boss_bar/health.points[1].x, health_pos, 0.2)
		if health_pos <= 0:
			$interface/boss_bar.modulate.a = lerp($interface/boss_bar.modulate.a, 0.0, 0.1)
		else:
			$interface/boss_bar.modulate.a = lerp($interface/boss_bar.modulate.a, 1.0, 0.1)


func update_map():
	for map_node in $interface/pause_menu/map.get_children():
		if SaveManager.permanent_savings["unlocked_rooms"].has(map_node.associated_level):
			map_node.show()
			if map_node.associated_level == level_name:
				map_node.blink = true
			else:
				map_node.blink = false
		else:
			map_node.hide()
			map_node.blink = false


func find_travel_point_position(active_level : Node = null):
	var travel_point_pos : Vector2 = Vector2(160, 90)
	if active_level != null:
		for point in active_level.get_node("travel_points").get_children():
			if point.name == level_switch_data[0]:
				travel_point_pos = point.position
				if point.is_in_group("save_point"):
					travel_point_pos.x -= 48
					travel_point_pos.y -= 1
	return travel_point_pos
