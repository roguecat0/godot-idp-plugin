extends Node2D

const ROT_SPEED = 3

func _physics_process(delta: float) -> void:
	#look_at(get_global_mouse_position())
	rotation = rotation + ROT_SPEED * delta
