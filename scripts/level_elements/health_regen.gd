extends Area2D

var velocity : Vector2 = Vector2(0, 0)
var sit : bool = false


func _ready():
	velocity = Vector2(randf_range(-50, 50), -100)


func _physics_process(delta):
	position += velocity * delta
	if !sit:
		velocity.y += 300 * delta


func _on_body_entered(body):
	if body.is_in_group("player"):
		if Globals.player_reference != null:
			Globals.player_reference.hp += 5
			Globals.player_damage_happened = true
		call_deferred("free")
	velocity = Vector2(0, 0)
	sit = true
