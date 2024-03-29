extends Term
class_name ForEach

func get_type():
	return ForEach

func _neq(_other: Variant) -> Bool:
	assert(false,"_neq not implemented for ForEach")
	return Bool.new_base("")

func _eq(_other: Variant) -> Bool:
	assert(false,"_eq not implemented for ForEach")
	return Bool.new_base("")

func _parenth():
	assert(false,"_parenth not implemented for ForEach")

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

static func create(variable: Variant, type: Variant, term: Term) -> ForEach:
	var t = _convert_input_type(type)
	var v = _convert_input_variable(variable)
	if len(t) != len(v):
		assert(false, "variable:%s len(%d) and type:%s len(%d) aren't matching inputs" % [
			v,len(v),t,len(t)])
	if not term is Bool and not term is ForEach:
		assert(false,"only boolean and foreach terms are allowed")
	print(v,", ",t)
	return ForEach.new("",[v,t,term],IDP.EACH)
	# list [", ".join()], list [" types"], Term (Bool, Foreach)

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

func _all() -> Bool:
	return Bool.new("",[self],IDP.ALL)

func _any() -> Bool:
	return Bool.new("",[self],IDP.ANY)

func _count() -> Integer:
	return Integer.new("",[self],IDP.COUNT)

func _sum(val: ArithTerm) -> ArithTerm:
	return ArithTerm.new("",[val,self],IDP.SUM)

func _min(val: ArithTerm) -> ArithTerm:
	return ArithTerm.new("",[val,self],IDP.MIN)

func _max(val: ArithTerm) -> ArithTerm:
	return ArithTerm.new("",[val,self],IDP.MAX)

func get_expr():
	return children[2]

func get_inner_expr():
	if children[2].operator in [IDP.ALL,IDP.ANY,IDP.EACH,IDP.COUNT]:
		return children[2].get_inner_expr()
	return children[2]

func set_inner_expr(term: Term):
	if not term is Bool and not term is ForEach:
		assert(false,"only boolean and foreach terms are allowed")
	if children[2].operator in [IDP.ALL,IDP.ANY,IDP.EACH]:
		children[2].set_inner_expr(term)
		return self
	children[2] = term
	return self

func set_expr(term: Term):
	if not term is Bool and not term is ForEach:
		assert(false,"only boolean and foreach terms are allowed")
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