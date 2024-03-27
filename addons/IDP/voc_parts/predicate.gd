class_name Predicate
extends Function

# TODO: decent lookup function
	
func _parse_enum(key: Variant, _val: Variant) -> String:
	return _parse_enum_input(key)
	
func copy() -> Variant:
	return Predicate.new(named,input_types.duplicate(true),output_type,interpretation.copy())

func _to_string() -> String:
	return "Predicate(name: %s, input: %s, output: %s, interpr: %s)" % [
		named,input_types,output_type,interpretation.inter_keys()
	]
func get_interpretation():
	if interpretation.interpretation == {null:null}:
		return []
	return interpretation.interpretation.keys()
	
