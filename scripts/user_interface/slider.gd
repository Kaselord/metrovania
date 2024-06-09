extends InterfaceElement

@export var value : float = 0.5
@export var slider_label_text : String = "SLIDER:"
@export_enum("none", "volume_sfx", "volume_music") var affected_property : String = "none"
var color_hue : float = 1.0


func _ready():
	$label.text = slider_label_text


func init():
	load_display_value()


func _physics_process(_delta):
	if selected:
		value = clamp(value + Input.get_axis("left", "right") * 0.02, 0.0, 1.0)
		update_property()
		if color_hue < 1.0:
			color_hue += 0.01
		else:
			color_hue = 0.0
		$label.modulate.h = color_hue
		$label.modulate.s = 1.0
		$label.modulate.v = 0.75
	else:
		$label.modulate = Color(1, 1, 1, 1)
	
	$knob.position.x = (value - 0.5) * 60


func update_property():
	match affected_property:
		 # 0 is master, 1 is SFX, 2 is music
		"volume_sfx":
			AudioServer.set_bus_volume_db(1, lerp(-32, 16, value))
			SaveManager.permanent_savings["default_settings"]["volume_sfx"] = value
			if value <= 0.0:
				AudioServer.set_bus_volume_db(1, -80.0)
		"volume_music":
			AudioServer.set_bus_volume_db(2, lerp(-32, 16, value))
			if value <= 0.0:
				AudioServer.set_bus_volume_db(2, -80.0)
			SaveManager.permanent_savings["default_settings"]["volume_music"] = value


func load_display_value():
	match affected_property:
		"volume_sfx":
			value = SaveManager.permanent_savings["default_settings"]["volume_sfx"]
		"volume_music":
			value = SaveManager.permanent_savings["default_settings"]["volume_music"]
