class_name ArithTerm
extends Term

static func base_(base_a) -> ArithTerm:
	return ArithTerm.new(
		str(base_a),[],IDP.BASE
	)
static func create(base_a) -> ArithTerm:
	return ArithTerm.new(
		str(base_a),[],IDP.BASE
	)

### arithmatic ###
func _generic_arith(other,op_type) -> ArithTerm:
	if other is ArithTerm:
		return ArithTerm.new("",[self,other],op_type)
	if other is int or other is float or other is String:
		var b = ArithTerm.base_(other)
		return ArithTerm.new("",[self,b],op_type)
	assert(false,"input %s is not correct type (ArithTerm, int, float)" % str(other))
	return self

func add(other: Variant) -> ArithTerm:
	return _generic_arith(other,IDP.ADD)

func sub(other) -> ArithTerm:
	return _generic_arith(other,IDP.SUB)
 
func mul(other) -> ArithTerm:
	return _generic_arith(other,IDP.MUL)

func div(other) -> ArithTerm:
	return _generic_arith(other,IDP.DIV)

### comparison ###
func _generic_comp(other,op_type) -> Bool:
	if other is ArithTerm:
		return Bool.new("",[self,other],op_type)
	if other is int or other is float or other is String:
		var b = ArithTerm.base_(other)
		return Bool.new("",[self,b],op_type)
	assert(false,"input %s is not correct type (ArithTerm, int, float)" % str(other))
	return Bool.base_("comparison operation with %s failed" % str(other))

func gt(other) -> Bool:
	return _generic_comp(other,IDP.GT)

func gte(other) -> Bool:
	return _generic_comp(other,IDP.GTE)

func lt(other) -> Bool:
	return _generic_comp(other,IDP.LT)

func lte(other) -> Bool:
	return _generic_comp(other,IDP.LTE)

# first comp has reversed meaning depending on how you look at it
func between(term1, term2, comp1: int, comp2: int) -> Bool:
	if term1 is int or term1 is float or term1 is String:
		term1 = ArithTerm.base_(term1)
	if term2 is int or term2 is float or term2 is String:
		term2 = ArithTerm.base_(term2)
	if comp1 not in [IDP.GT,IDP.GTE,IDP.LT,IDP.LTE]:
		assert(false, "comparators should be of greater than or less than type")
	if comp2 not in [IDP.GT,IDP.GTE,IDP.LT,IDP.LTE]:
		assert(false, "comparators should be of greater than or less than type")
	return Bool.new("",[term1,Bool.new("",[self,term2],comp2)],comp1)

func neg() -> ArithTerm:
	return get_type().new("",[self],IDP.NEG)

