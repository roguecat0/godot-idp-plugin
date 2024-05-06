extends CharacterBody2D

@onready var player = get_node("/root/SurvivorGame/Player") # %Player
var health = 3
const MAX_HP = 3.0


const SPEED = 25.0
var aggro := true

var knockback_dir
var knockback = false

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	$Health.scale.x = max(0, health/MAX_HP)
	velocity = direction * SPEED
	velocity *= 1 if aggro else -1
	
	if knockback:
		velocity = 800 * knockback_dir
		knockback = false
	move_and_slide()

func take_damage():
	health -= 1
	
	if health <= MAX_HP/2:
		aggro = false
	
	var direction = global_position.direction_to(player.global_position)
	knockback_dir = - global_position.direction_to(player.global_position)
	knockback = true
	
	if health <= 0:
		die()
	else:
		play_hurt()
		
func play_hurt():
	$Greeny.play("hurt")
	await $Greeny.animation_looped
	$Greeny.play("run")
	
func die():
	$Greeny.play("death")
	await $Greeny.animation_looped
	queue_free()
