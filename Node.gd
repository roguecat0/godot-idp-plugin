extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var kb: KnowlegdeBase = IDP.create_kb_from_file("res://test-idp.idp")
	IDP.model_expand(kb)
	print(kb)
