class_name Theory
extends KnowledgeBaseBlock

var linked_voc: String = "V"

func _init():
	block_name = "T"

func create_from_string(str_voc: String) -> void:
	block_str = str_voc
