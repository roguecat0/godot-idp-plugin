extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var kb: KnowlegdeBase = IDP.create_kb_from_file("res://test-idp.idp") # Replace with function body.
	var _idp_str: String = kb.parse_to_idp()
	IDP.model_expand(kb)
	print("functions: ", kb.solutions.front().functions)
	print("predicates: ", kb.solutions.front().predicates)
