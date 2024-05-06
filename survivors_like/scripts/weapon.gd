extends Node2D

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
func attack():
	$Attack.slash()


func _on_timer_timeout() -> void:
	attack()
