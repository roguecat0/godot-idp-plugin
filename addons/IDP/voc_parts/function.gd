class_name Function
extends Node

var named: String
var input_types: Variant
var output_type: Variant
var enums: Dictionary

func _init(n: String, in_types: Variant, 
		out_type: Variant, enumerations: Dictionary = {}) -> void:
	#TODO: find a way to handel empty enumeration vs uninitialized enumeration
	"""\
enums should account for:
initialValue := {(1, 0), (1, 1), (1, 2)}.
lolValue := {0 -> 0, 1 -> 0, 2 -> 0}.
lol := true.
"""
	named = n
	if in_types is Array:
		input_types = in_types.map(func(x): return _parse_custom_type(x))
	else:
		input_types = [_parse_custom_type(in_types)]
	output_type = _parse_custom_type(out_type)
	enums = enumerations
	
func add(key: Variant,val: Variant=true) -> void:
	#TODO: check if same size
	enums[key] = val
	
func remove(key: Variant) -> bool:
	return enums.erase(key)

func _parse_custom_type(val: Variant) -> String:
	if val is String:
		return val
	elif val is CustomType:
		return val.named
	elif val is int:
		match val:
			IDP.INT:
				return "Int"
			IDP.REAL:
				return "Real"
			IDP.BOOL:
				return "Bool"
			IDP.DATE:
				return "Date"
			_:
				push_error("%d doens't have a valid connected to it. 'Real' type chosen")
				return "Real"
			
	else:
		push_error("value is not a String or CustomType")
		return ""

func to_vocabulary_line() -> String:
	return "\t%s : (%s) -> %s" % [named," * ".join(input_types),output_type]
	
func to_structure_line() -> String:
	if len(enums.keys()) != 0:
		return "\t%s := {%s}." % [named,", ".join(enums.keys().map(func(x): return _parse_enum(x,enums[x])))]
	return ""
	
func _parse_enum(key: Variant, val: Variant) -> String:
	return "%s -> %s" % [_parse_enum_input(key),str(val)]
	
func _parse_enum_input(input_enum: Variant) -> String:
	#packed arrays (input_types) aren't accounted for
	if len(input_types) > 1:
		return "(%s)" % ", ".join(Array(input_enum).map(func(x): return str(x)))
	else:
		return str(input_enum)
	
func copy() -> Variant:
	if self is Predicate:
		return Predicate.new(named,input_types.duplicate(true) if input_types is Array else input_types,enums.keys().duplicate(true))
	else:
		return Function.new(named,input_types.duplicate(true) if input_types is Array else input_types,output_type,enums.duplicate(true))
		
func update(val: Variant,append: bool=false):
	if not append:
		self.enums = val
		return
	val.keys().map(func(k): self.enums[k] = val[k])

func _to_string() -> String:
	return "Function(name: %s, input: %s, output: %s, enums: %s)" % [
		named,input_types,output_type,enums
	]
