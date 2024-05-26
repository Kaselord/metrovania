extends Entity

var orig_pos : Vector2
var dir : float = 0.0
var speed : float = 70.0
var attacking : int = 0
var attack_cd : int = 32
var hit_cd : int = 0
@export var start_facing : float = 1.0


func _ready():
	super()
	orig_pos = position
	$visuals.scale.x = start_facing


func _physics_process(delta):
	if Globals.active && hp > 0 && Globals.player_reference != null:
		# walk towards player and attack
		if abs(position.y - Globals.player_reference.position.y) < 64:
			if abs(position.x - Globals.player_reference.position.x) > 112 && attacking <= 0:
				dir = lerp(dir, sign(Globals.player_reference.position.x - position.x), 0.05)
			else:
				if attack_cd <= 0:
					if Globals.player_reference.position.x - position.x != 0:
						dir = sign(Globals.player_reference.position.x - position.x) * 0.2
						$visuals.scale.x = sign(velocity.x)
					attacking = 54
					attack_cd = 124
					$anim.play("slash")
				else:
					attack_cd -= 1
				dir = lerp(dir, 0.0, 0.1)
		else: # stand in place
			dir = lerp(dir, 0.0, 0.1)
		velocity.x = dir * speed
		if attacking <= 0 && hit_cd <= 0:
			if abs(velocity.x) > 4:
				$anim.play("walk")
			else:
				$anim.play("idle")
		else:
			attacking -= 1
		
		if hit_cd > 0:
			hit_cd -= 1
		
		if velocity.x != 0:
			$visuals.scale.x = sign(velocity.x)
		
		$hurtbox.scale.x = $visuals.scale.x
		
		velocity.y += 350.0 * delta
		
		move_and_slide()
	elif hp <= 0:
		$fire_emitter.active = true
		$fire_emitter2.active = true
		$hurtbox/CollisionShape2D.disabled = true
		$hitbox/CollisionShape2D.disabled = true
		$anim.play("hurt")
		if modulate.a > 0:
			modulate.a -= 0.01
		else:
			call_deferred("free")
	
	$visuals.scale.y = lerp($visuals.scale.y, 1.0, 0.1)


func _on_hitbox_hit():
	$visuals.scale.y = 0.8
	if Globals.player_reference != null && Globals.player_reference.position.x - position.x != 0:
		dir = sign(Globals.player_reference.position.x - position.x) * 0.2
	$visuals.scale.x = dir * 5
	if attacking <= 0:
		hit_cd = 12
		$anim.play("hurt")
