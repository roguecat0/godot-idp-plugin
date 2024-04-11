class_name Bool
extends Term

static func base_(base_a) -> Bool:
	return Bool.new(
		str(base_a),[],IDP.BASE
	)

static func create(base_a) -> Bool:
	return Bool.new(
		str(base_a),[],IDP.BASE
	)

func _generic_arith(other,op_type) -> Bool:
	if other is Bool:
		return Bool.new("",[self,other],op_type)
	if other is bool or other is String:
		var b = Bool.base_(other)
		return Bool.new("",[self,b],op_type)
	assert(false,"input %s is not correct type (Bool, bool, str(bool))" % str(other))
	return self

func and_(other: Variant) -> Bool:
	return _generic_arith(other,IDP.AND)

func or_(other: Variant) -> Bool:
	return _generic_arith(other,IDP.OR)

func not_() -> Bool:
	return Bool.new("",[self],IDP.NOT)

func implies(other: Variant) -> Bool:
	return _generic_arith(other,IDP.IMPL)

func rev_implies(other: Variant) -> Bool:
	return _generic_arith(other,IDP.RIMPL)

func equivalent(other: Variant) -> Bool:
	return _generic_arith(other,IDP.EQV)

func defines(other: Variant) -> Bool:
	return _generic_arith(other,IDP.DFN)

