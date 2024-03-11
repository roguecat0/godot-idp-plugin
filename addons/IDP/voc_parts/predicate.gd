class_name Predicate
extends Function

# TODO: decent lookup function
var en: 
	get: return enums.keys()

func _init(n: String, in_types: Variant, enumerations: Array = []) -> void:
	var dict_enum = {}
	enumerations.map(func(x): dict_enum[x] = true )
	super(n,in_types,"Bool",dict_enum)
	
func _parse_enum(key: Variant, val: Variant) -> String:
	return _parse_enum_input(key)
	
func _to_string() -> String:
	return "Predicate(name: %s, input: %s, output: %s, enums: %s)" % [
		named,input_types,output_type,enums.keys()
	]
