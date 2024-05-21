extends Term
class_name Quantifier

func get_type():
	return Quantifier

func neq(_other: Variant) -> Bool:
	assert(false,"neq not implemented for Quantifier")
	return Bool.base_("")

func eq(_other: Variant) -> Bool:
	assert(false,"eq not implemented for Quantifier")
	return Bool.base_("")

func parenth():
	assert(false,"parenth not implemented for Quantifier")

static func _parse_custom_type(val: Variant) -> String:
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

static func create(variable: Variant, type: Variant, term: Term) -> Quantifier:
	var t = _convert_input_type(type)
	var v = _convert_input_variable(variable)
	if len(t) != len(v):
		assert(false, "variable:%s len(%d) and type:%s len(%d) aren't matching inputs" % [
			v,len(v),t,len(t)])
	if not term is Bool and not term is Quantifier:
		assert(false,"only boolean and Quantifier terms are allowed")
	print(v,", ",t)
	return Quantifier.new("",[v,t,term],IDP.EACH)
	# list [", ".join()], list [" types"], Term (Bool, Quantifier)

static func _convert_input_variable(variable) -> Array:
	if variable is String:
		return [variable]
	if variable is Array:
		if variable[0] is String:
			return [", ".join(variable)]
		elif variable[0][0] is String:
			return variable.map(func(x): return ", ".join(x))
	assert(false, "%s: is not a valid variable input" % variable)
	return []


static func _convert_input_type(type) -> Array:
	if type is CustomType or type is String or type is int:
		return [_parse_custom_type(type)]
	if type is Array:
		return type.map(func(x): return _parse_custom_type(x))
	assert(false, "%s: is not a valid type input" % type)
	return []

func all() -> Bool:
	return Bool.new("",[self],IDP.ALL)

func any() -> Bool:
	return Bool.new("",[self],IDP.ANY)

func count() -> Integer:
	return Integer.new("",[self],IDP.COUNT)

func sum(val: ArithTerm) -> ArithTerm:
	return ArithTerm.new("",[val,self],IDP.SUM)

func min(val: ArithTerm) -> ArithTerm:
	return ArithTerm.new("",[val,self],IDP.MIN)

func max(val: ArithTerm) -> ArithTerm:
	return ArithTerm.new("",[val,self],IDP.MAX)

func get_expr():
	return children[2]

func get_inner_expr():
	if children[2].operator in [IDP.ALL,IDP.ANY,IDP.EACH,IDP.COUNT]:
		return children[2].get_inner_expr()
	return children[2]

func set_inner_expr(term: Term):
	if not term is Bool and not term is Quantifier:
		assert(false,"only boolean and Quantifier terms are allowed")
	if children[2].operator in [IDP.ALL,IDP.ANY,IDP.EACH]:
		children[2].set_inner_expr(term)
		return self
	children[2] = term
	return self

func set_expr(term: Term):
	if not term is Bool and not term is Quantifier:
		assert(false,"only boolean and Quantifier terms are allowed")
	children[2] = term
	return self

func copy():
	return get_type().new(
		base,
		[
			children[0].duplicate(),
			children[1].duplicate(),
			children[2].copy(),
		],
		operator
	)
