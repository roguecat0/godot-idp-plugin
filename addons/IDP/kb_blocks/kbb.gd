class_name KnowledgeBaseBlock
extends Node

var block_name: String = ""
var block_str: String

func create_from_string(_str_voc: String) -> void:
	push_error("unimplemented abstract function, create_from_string")
	
func parse_to_idp() -> String:
	return block_str

func add_line(_line: String) -> int:
	push_error("unimplemented abstract function, add_line")
	return -1

func _to_string() -> String:
	push_error("unimplemented abstract function, _to_string")
	return ""
