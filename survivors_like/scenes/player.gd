extends CharacterBody2D

const SPEED = 100
const DAMAGE_RATE = 50.0

var health = 100.0

signal health_depleted

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left","right","up","down")
	velocity =  direction * SPEED
	move_and_slide()
	
	# handel animations
	if velocity.length() > 0.0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false
		
	var num_overlapping_mobs = $Hurtbox.get_overlapping_bodies().size() - 1
	
	if num_overlapping_mobs > 0:
		health -= num_overlapping_mobs * DAMAGE_RATE * delta
		$Health.scale.x = health/100.0
		if health <= 0.0:
			health_depleted.emit()
	

