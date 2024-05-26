extends Area2D

var extinguished : bool = false
var anim_cooldown : int = 0
@export var heart_scene : PackedScene


func _physics_process(_delta):
	if extinguished:
		$sprite.frame = 2
	else:
		if anim_cooldown > 0:
			anim_cooldown -= 1
		else:
			if $sprite.frame == 0:
				$sprite.frame = 1
			else:
				$sprite.frame = 0
			anim_cooldown = 4


func _on_area_entered(area):
	if area.is_in_group("whip"):
		if !extinguished:
			if Globals.level_reference != null:
				var heart = heart_scene.instantiate()
				heart.position = position
				Globals.level_reference.get_node("interactive").call_deferred("add_child", heart)
			extinguished = true
