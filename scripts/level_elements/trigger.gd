@tool
extends Area2D

@export_enum("start_text") var function = "start_text"
@export var params : Array = []
@export var permanently_delete : bool = false
@export var size : Vector2 = Vector2(48, 48)


func _ready():
	if !Engine.is_editor_hint():
		$collider.shape.size = size
		$collider.position.y = -size.y * 0.5


func _process(_delta):
	if Engine.is_editor_hint():
		$collider.shape.size = size
		$collider.position.y = -size.y * 0.5


func _on_body_entered(body):
	if body.is_in_group("player"):
		do_thing()
		if permanently_delete:
			pass # append [filepath of current level, trigger name] to save file
		call_deferred("free")


func do_thing():
	match function:
		"start_text":
			Interface.start_text(params[0], true)
