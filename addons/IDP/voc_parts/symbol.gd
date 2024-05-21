class_name Symbol
extends Node

var named: String
var domain: Variant
var range_: Variant
var interpretation: SymbolInterpretation
var range_base: int = -1

var domain_size: int

func _init(named: String, domain_: Variant, range_: Variant, interpretation: SymbolInterpretation) -> void:
	self.named = named
	if domain_ is Array:
		self.domain = domain_.map(func(x): return _parse_custom_type(x))
	else:
		self.domain = [_parse_custom_type(domain_)]
	self.range_ = _parse_custom_type(range_)
	self.interpretation = interpretation
	
func unset():
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
	return "\t%s : (%s) -> %s" % [named," * ".join(domain),range_]
	
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
	#packed arrays (domain) aren't accounted for
	if not input_enum is Array:
		return str(input_enum)

	if len(domain) > 1:
		return "(%s)" % ", ".join(Array(input_enum).map(func(x): return str(x)))
	else:
		return str(input_enum[0])
	
func copy() -> Variant:
	return Symbol.new(named,domain.duplicate(true),range_,interpretation.copy())
		
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

func get_value(key):
	if interpretation.interpretation == {null:null}:
		return null
	return interpretation.interpretation.get(key)

func has_value(key):
	return interpretation.interpretation.has(key)

func _to_string() -> String:
	return "Symbol(name: %s, input: %s, output: %s, interpretation: %s)" % [
		named,domain,range_,interpretation.interpretation
	]

func apply(inputs: Variant=[]):
	if inputs is String:
		inputs = [inputs]
	if not self is Constant and len(inputs) == 0:
		assert(false,"converion of non constant function to term without argumenst")
		return
	if len(inputs) != len(domain):
		assert(false,"number of arguments of function: %s (%d) does not match number of input types (%d) being: %s" % [named,len(inputs),len(domain)])
		return
	if range_base == -1:
		assert(false,"function has no range_base assigned, default of 'Real' assumend")
		range_base = IDP.REAL
	var terms = []
	for term in inputs:
		if term is int or term is float:
			terms.append(ArithTerm.base_(term))
		elif term is bool:
			terms.append(Bool.base_(term))
		elif term is Term:
			terms.append(term)
		else:
			terms.append(Term.base_(term))

	match range_base:
		IDP.REAL:
			return Real.new(named,terms,IDP.CALL)
		IDP.INT:
			return Integer.new(named,terms,IDP.CALL)
		IDP.BOOL:
			return Bool.new(named,terms,IDP.CALL)
		_:
			return Term.new(named,terms,IDP.CALL)






