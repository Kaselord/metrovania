extends Node2D

var warning_cd : int = 0
var active : bool = false
var nuke_impact_pos : Vector2 = Vector2(0, 0)
var nuke_launch_cd : int = 60
var cooldown_table : Array = [
	240,
	100,
	80,
	160,
	65,
]
var cooldown_index : int = 0
@export var warning_scene : PackedScene
@export var nuke_scene : PackedScene


func _physics_process(_delta):
	if active && Globals.active:
		if warning_cd > 0:
			warning_cd -= 1
		else:
			warning_cd = cooldown_table[cooldown_index]
			cooldown_index += 1
			if cooldown_index >= len(cooldown_table):
				cooldown_index = 0
			
			var dst : float = clamp(cooldown_table[cooldown_index], 0.0, 128.0)
			
			if Globals.player_reference != null:
				nuke_impact_pos = Globals.player_reference.position + Vector2(Globals.player_reference.look_dir * dst, -8)
				spawn_warning()
		
		if nuke_launch_cd > 0:
			nuke_launch_cd -= 1
		if nuke_launch_cd == 1:
			spawn_nuke()


func spawn_warning():
	nuke_launch_cd = 60
	if Globals.level_reference != null:
		var warning = warning_scene.instantiate()
		warning.position = nuke_impact_pos
		Globals.level_reference.get_node("projectiles").call_deferred("add_child", warning)


func spawn_nuke():
	if Globals.level_reference != null && Globals.player_reference != null:
		var nuke = nuke_scene.instantiate()
		nuke.position = Vector2(nuke_impact_pos.x + randf_range(-48, 48), Globals.player_reference.position.y - 200)
		nuke.override_dir = true
		nuke.target_pos = nuke_impact_pos
		Globals.level_reference.get_node("behind_tiles").call_deferred("add_child", nuke)
