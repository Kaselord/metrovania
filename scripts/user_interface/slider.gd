extends InterfaceElement

@export var value : float = 0.5
@export var slider_label_text : String = "SLIDER:"
var color_hue : float = 1.0


func _ready():
	$label.text = slider_label_text


func _physics_process(_delta):
	if selected:
		value = clamp(value + Input.get_axis("left", "right") * 0.02, 0.0, 1.0)
		if color_hue < 1.0:
			color_hue += 0.02
		else:
			color_hue = 0.0
		$label.modulate.h = color_hue
		$label.modulate.s = 1.0
		$label.modulate.v = 0.75
	else:
		$label.modulate = Color(1, 1, 1, 1)
	
	$knob.position.x = (value - 0.5) * 60
