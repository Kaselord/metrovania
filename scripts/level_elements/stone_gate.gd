extends StaticBody2D

@export var down : bool = true
var initialized : bool = false


func _ready():
	if down:
		$sprite.position.y = 0
		$collider.disabled = false
	else:
		$sprite.position.y = -42
		$collider.disabled = true


func _process(_delta):
	if !initialized:
		if Globals.level_reference != null:
			initialized = true
			var path_to_self : String = String(Globals.level_reference.get_path_to(self))
			var level_file_path : String = Globals.level_reference.scene_file_path
			if SaveManager.get_permanent_deletion(path_to_self, level_file_path):
				down = false


func _physics_process(_delta):
	if down:
		$sprite.position.y = lerp($sprite.position.y, 0.0, 0.2)
		$collider.disabled = false
	else:
		$sprite.position.y = lerp($sprite.position.y, -42.0, 0.2)
		$collider.disabled = true
