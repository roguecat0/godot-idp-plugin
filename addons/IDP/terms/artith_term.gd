class_name ArithTerm
extends Term

static func new_base(base_a) -> ArithTerm:
	return ArithTerm.new(
		str(base_a),[],IDP.BASE
	)

### arithmatic ###
func _generic_arith(other,op_type) -> ArithTerm:
	if other is ArithTerm:
		return ArithTerm.new("",[self,other],op_type)
	if other is int or other is float:
		var b = ArithTerm.new_base(other)
		return ArithTerm.new("",[self,b],op_type)
	assert(false,"input %s is not correct type (ArithTerm, int, float)" % str(other))
	return self

func _add(other: Variant) -> ArithTerm:
	return _generic_arith(other,IDP.ADD)

func _sub(other) -> ArithTerm:
	return _generic_arith(other,IDP.SUB)
 
func _mul(other) -> ArithTerm:
	return _generic_arith(other,IDP.MUL)

func _div(other) -> ArithTerm:
	return _generic_arith(other,IDP.DIV)

### comparison ###
func _generic_comp(other,op_type) -> Bool:
	if other is ArithTerm:
		return Bool.new("",[self,other],op_type)
	if other is int or other is float:
		var b = ArithTerm.new_base(other)
		return Bool.new("",[self,b],op_type)
	assert(false,"input %s is not correct type (ArithTerm, int, float)" % str(other))
	return Bool.new_base("comparison operation with %s failed" % str(other))

func _gt(other) -> Bool:
	return _generic_comp(other,IDP.GT)

func _gte(other) -> Bool:
	return _generic_comp(other,IDP.GTE)

func _lt(other) -> Bool:
	return _generic_comp(other,IDP.LT)

func _lte(other) -> Bool:
	return _generic_comp(other,IDP.LTE)

func _neg() -> ArithTerm:
	return get_type().new("",[self],IDP.NEG)
