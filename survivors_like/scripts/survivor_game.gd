extends Node2D

const GREEN_SLIME = preload("res://survivors_like/scenes/green_slime.tscn")
func _ready() -> void:
	pass
	
func spawn_mob():
	var new_mob = GREEN_SLIME.instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)


func _on_spawn_timer_timeout() -> void:
	spawn_mob()


func _on_player_health_depleted() -> void:
	get_tree().reload_current_scene() # Replace with function body.
