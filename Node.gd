extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	var kb: KnowlegdeBase = IDP.create_kb_from_file("res://test-idp.idp") # Replace with function body.
	var idp_str: String = kb.parse_to_idp()
	print(idp_str,"\n\n")
	print(IDP.model_expand(kb))
