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

static func create(variable: Variant, type: Variant, term: Bool) -> ForEach:
	if variable is Array:
		variable = ", ".join(variable)
	if not variable is String:
		assert(false, "variable was not a string or array of strings")
	if type is CustomType:
		type = type.named
	return ForEach.new("",[variable,type,term],IDP.EACH)

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
