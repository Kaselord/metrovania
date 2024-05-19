extends Area2D

@export var damage : float
@export var ignore_in_detection = []
@export var void_out : bool = false
signal has_hit


func _ready():
	add_to_group("hurtbox")


func ignore(tag_to_be_ignored : String):
	ignore_in_detection.append(tag_to_be_ignored)
