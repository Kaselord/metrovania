extends Node2D
class_name InterfaceElement

var selected : bool = false
var initialized : bool = false


func action():
	print(name + " action")


func _process(_delta):
	if !initialized:
		initialized = true
		init()


func init():
	pass
