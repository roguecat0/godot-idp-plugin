class_name Predicate
extends Symbol

# TODO: decent lookup function
	
func _parse_enum(key: Variant, _val: Variant) -> String:
	return _parse_enum_input(key)
	
func copy() -> Variant:
	return Predicate.new(named,domain.duplicate(true),domain,interpretation.copy())

func _to_string() -> String:
	return "Predicate(name: %s, input: %s, output: %s, interpr: %s)" % [
		named,domain,domain,interpretation.inter_keys()
	]
func get_interpretation():
	if interpretation.interpretation == {null:null}:
		return []
	return interpretation.interpretation.keys()
	
