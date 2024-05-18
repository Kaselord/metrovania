@tool
extends Area2D

@export_enum("left", "right", "up", "down", "none") var direction = "left"
@export var send_to_travel_point : String
@export var new_room_path : String
@export var collider_size : Vector2 = Vector2(16, 16)
var spawn_protection : int = 15
var player_is_here : bool = false
var direction_table = {
	"left" : [-1, "x"],
	"right" : [1, "x"],
	"up" : [-1, "y"],
	"down" : [1, "y"],
	"none" : [0, "z"]
}


func _ready():
	if !Engine.is_editor_hint():
		update_collider()


func _physics_process(_delta):
	if player_is_here && !Engine.is_editor_hint() && Globals.active:
		# get the axis that this door is facing
		var axis : String = direction_table[direction][1]
		# get the player input
		var player_input = Globals.get_player_value("input_dir")
		var player_velocity = Globals.get_player_value("velocity")
		# get the direction that this door is facing
		var door_direction = direction_table[direction][0]
		if Globals.player_reference != null:
			if axis == "x":
				# check if x input is equal to door direction
				if door_direction == sign(player_input.x):
					request_level_change()
			if axis == "y":
				if door_direction == sign(player_velocity.y):
					request_level_change()
	elif Engine.is_editor_hint():
		update_collider()


func update_collider():
	$collider.shape.size = collider_size
	$collider.position.y = -collider_size.y * 0.5


func request_level_change():
	Globals.level_switch_data = [send_to_travel_point, new_room_path]
	Globals.emit_signal("level_switch")


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_is_here = true


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_is_here = false
