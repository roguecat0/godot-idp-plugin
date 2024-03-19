class_name Function
extends Node

var named: String
var input_types: Variant
var output_type: Variant
var interpretation: FunctionInterpretation

func _init(named: String, input_types: Variant, 
		output_type: Variant, interpretation: FunctionInterpretation) -> void:
	#TODO: find a way to handel empty enumeration vs uninitialized enumeration
	"""\
interpretation should account for:
initialValue := {(1, 0), (1, 1), (1, 2)}.
lolValue := {0 -> 0, 1 -> 0, 2 -> 0}.
lol := true.
"""
	self.named = named
	if input_types is Array:
		self.input_types = input_types.map(func(x): return _parse_custom_type(x))
	else:
		self.input_types = [_parse_custom_type(input_types)]
	self.output_type = _parse_custom_type(output_type)
	self.interpretation = interpretation
	
func set_default(val):
	interpretation.setd(val)
	
func unset_default():
	interpretation.unset()
	
func add(key: Variant,val: Variant=true) -> void:
	#TODO: check if same size
	interpretation.add(key,val)
	
func remove(key: Variant) -> bool:
	return interpretation.remove(key)

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
	if interpretation.interpreted:
		return "\t%s := {%s}." % [named,", ".join(interpretation.inter_keys().map(func(x): return _parse_enum(x,interpretation.geti(x))))]
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
	return Function.new(named,input_types.duplicate(true),output_type,interpretation.copy())
		
func update(val: Variant,append: bool=false):
	if not append:
		interpretation = val
		return
	interpretation.mergei(val)
	
func get_interpretation():
	if interpretation.interpretation == {null:null}:
		return {}
	return interpretation.interpretation

func _to_string() -> String:
	return "Function(name: %s, input: %s, output: %s, interpretation: %s)" % [
		named,input_types,output_type,interpretation.interpretation
	]
