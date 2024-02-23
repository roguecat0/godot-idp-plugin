class_name Structure
extends KnowledgeBaseBlock

var linked_voc: String = "V"

func _init():
	block_name = "S" 


func create_from_string(str_voc: String) -> void:
	block_str = str_voc
