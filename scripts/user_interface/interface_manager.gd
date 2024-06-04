extends Node

var selection_index : int = 0
@onready var max_selection_index : int = 0


func _ready():
	max_selection_index = get_child_count() - 1


func _process(_delta):
	pass
