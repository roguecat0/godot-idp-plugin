class_name Bool
extends Term

static func new_base(base_a) -> Bool:
	return Bool.new(
		str(base_a),[],IDP.BASE
	)

func _generic_arith(other,op_type) -> Bool:
	if other is Bool:
		return Bool.new("",[self,other],op_type)
	if other is bool or (other is String and (other == "true" or other == "false")):
		var b = Bool.new_base(other)
		return Bool.new("",[self,b],op_type)
	assert(false,"input %s is not correct type (Bool, bool, str(bool))" % str(other))
	return self

func _and(other: Variant) -> Bool:
	return _generic_arith(other,IDP.AND)

func _or(other: Variant) -> Bool:
	return _generic_arith(other,IDP.OR)

func _not() -> Bool:
	return Bool.new("",[self],IDP.NOT)

func _implies(other: Variant) -> Bool:
	return _generic_arith(other,IDP.IMPL)

func _rev_implies(other: Variant) -> Bool:
	return _generic_arith(other,IDP.RIMPL)

func _equivalent(other: Variant) -> Bool:
	return _generic_arith(other,IDP.EQV)
func _defines(other: Variant) -> Bool:
	return _generic_arith(other,IDP.DFN)

