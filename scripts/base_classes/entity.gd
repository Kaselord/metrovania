extends CharacterBody2D
class_name Entity

var hp : int = 1
@export var starting_hp : int = 1


func _ready():
	hp = starting_hp


func hit():
	pass
