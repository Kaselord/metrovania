extends Node2D
class_name Particle

@export var init = {
	"scale" : Vector2(1, 1),
	"position" : Vector2(0, 0),
	"modulate" : Color(1, 1, 1, 1)
}
@export var final = {
	"scale" : Vector2(0, 0),
	"position" : Vector2(0, 0),
	"modulate" : Color(1, 1, 1, 0)
}
var lifetime : int = 30
var time : int = 0
@export var snap_weight : float = 0.01


func _ready():
	hide()


func _physics_process(_delta):
	show()
	
	if time < lifetime:
		time += 1
	else:
		call_deferred("free")
	
	var weight : float = snapped(float(time) / float(lifetime), snap_weight)
	scale = lerp(init["scale"], final["scale"], weight)
	position = lerp(init["position"], final["position"], weight)
	modulate = lerp(init["modulate"], final["modulate"], weight)
