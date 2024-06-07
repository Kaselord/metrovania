extends Node2D

var selection_index : int = 0
@export var active : bool = true
@onready var max_selection_index : int = 0


func _ready():
	max_selection_index = get_child_count() - 1


func _process(_delta):
	if active:
		var change : int = 0
		if Input.is_action_just_pressed("up"):
			change = -1
		if Input.is_action_just_pressed("down"):
			change = 1
		if change != 0:
			# neglect old selection
			get_child(selection_index).selected = false
		selection_index = clamp(selection_index + change, 0, max_selection_index)
		# activate current selection
		get_child(selection_index).selected = true
		
		if Input.is_action_just_pressed("jump"):
			get_child(selection_index).action()
	else:
		get_child(selection_index).selected = false
