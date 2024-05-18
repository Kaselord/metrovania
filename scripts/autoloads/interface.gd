extends CanvasLayer

var transition_value : int = 25
var max_transition : int = 25

func _physics_process(_delta):
	if transition_value < max_transition:
		transition_value += 1
	
	$transition_rect.modulate.a = float(max_transition - snapped(abs(transition_value), 5)) * 0.05
