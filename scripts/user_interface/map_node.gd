extends Node2D

@export var associated_level : String = "res://scenes/levels/002_the_other_side.tscn"
@export var color : Color = Color(1, 1, 1, 1)
var blink : bool = false

func _ready():
	$square.modulate = color


func _physics_process(_delta):
	if blink:
		$square.modulate.a = (sin(Globals.time * 8.0) + 1.0) * 0.5
	else:
		$square.modulate.a = 1.0
