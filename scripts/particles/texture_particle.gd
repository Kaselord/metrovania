extends Particle

@export var texture : Texture
@export var frame_amount : int = 1
@export var frame_index : int = 0
@export var sprite_scale : Vector2 = Vector2(1, 1)


func _ready():
	super()
	$sprite.texture = texture
	$sprite.hframes = frame_amount
	$sprite.frame = frame_index
	$sprite.scale = sprite_scale


func _physics_process(delta):
	super(delta)
