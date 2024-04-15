class_name CustomType
extends Node

var named: String
var base_type: int
var enums: Array

func _init(n: String, enumeration: Array, base_type: int=IDP.IDP_UNKNOWN) -> void:
	named = n
	self.base_type = base_type
	enums = enumeration

func to_vocabulary_line() -> String:
	return "\ttype %s := {%s}" % [named,", ".join(enums.map(func(x: Variant) -> String: return str(x)))]

func _to_string() -> String:
	return "Type: %s, range: %s" % [named, str(enums)]
