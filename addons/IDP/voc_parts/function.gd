class_name Function
extends Node

var named: String
var input_types: Variant
var output_type: Variant
var interpretation: FunctionInterpretation
var output_base_type: int = -1

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
				assert(false,"%d doens't have a valid connected to it. 'Real' type chosen")
				return "Real"
			
	else:
		assert(false,"value is not a String, int or CustomType")
		return ""

func to_vocabulary_line() -> String:
	return "\t%s : (%s) -> %s" % [named," * ".join(input_types),output_type]
	
func to_structure_line() -> String:
	var s: = ""
	#print("named: %s, interpreded: %s, with defaults: %s" % [
		#named, str(interpretation.interpreted), str(interpretation.function_with_default)])
	if interpretation.function_with_default:
		s = " else " + str(interpretation.getd())
	if interpretation.interpreted:
		return "\t%s := {%s}%s." % [named,
			", ".join(interpretation.inter_keys().map(func(x): 
				return _parse_enum(x,interpretation.geti(x)))),s]
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
		var d = interpretation.getd()
		interpretation = val
		interpretation.setd(d)
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

func to_term(inputs: Array=[]):
	if not self is Constant and len(inputs) == 0:
		assert(false,"converion of non constant function to term without argumenst")
		return
	if len(inputs) != len(input_types):
		assert(false,"number of arguments of function does not match number of input types")
		return
	if output_base_type == -1:
		assert(false,"function has no output_base_type assigned, default of 'Real' assumend")
		output_base_type = IDP.REAL
	var terms = []
	for term in inputs:
		if term is int or term is float:
			terms.append(ArithTerm.new_base(term))
		elif term is bool:
			terms.append(Bool.new_base(term))
		elif term is Term:
			terms.append(term)
		else:
			terms.append(Term.new_base(term))

	match output_base_type:
		IDP.REAL:
			return Real.new(named,terms,IDP.CALL)
		IDP.INT:
			return Integer.new(named,terms,IDP.CALL)
		IDP.BOOL:
			return Bool.new(named,terms,IDP.CALL)
		_:
			return Term.new(named,terms,IDP.CALL)






