extends Area2D

func slash():
	$ColorRect.visible = true
	$CollisionShape2D.disabled = false
	await get_tree().create_timer(.3).timeout
	$CollisionShape2D.disabled = true
	$ColorRect.visible = false
	


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
