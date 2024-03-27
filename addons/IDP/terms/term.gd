class_name Term
extends Node

var operator: int
var children: Array
var base: String
var num_children: int:
	get: return len(children)


func _init(base_a,children_a,operator_a):
	base = base_a
	children = children_a
	operator = operator_a

static func new_base(base_a) -> Term:
	return Term.new(
		str(base_a),[],IDP.BASE
	)

# static func create(base_a) -> Term:
# 	return Term.new(
# 		str(base_a),[],IDP.BASE
# 	)

func _parenth():
	return self.get_type().new("",[self],IDP.PARENTH)

func parse_to_idp()-> String:
	match operator:
		# Arith
		IDP.ADD:
			return " + ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.SUB:
			return " - ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.MUL:
			return " * ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.DIV:
			return " / ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.NEG:
			return "-" + children[0].parse_to_idp()

		# Comp
		IDP.GT:
			return " > ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.GTE:
			return " >= ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.LT:
			return " < ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.LTE:
			return " =< ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.EQ:
			return " = ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.NEQ:
			return " ~= ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.GT:
			return " > ".join(children.map(func(child): return child.parse_to_idp()))
		# Connectives
		IDP.AND:
			return " & ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.OR:
			return " | ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.IMPL:
			return " => ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.RIMPL:
			return " <= ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.EQV:
			return " <=> ".join(children.map(func(child): return child.parse_to_idp()))
		IDP.DFN:
			return " <- ".join(children.map(func(child): return child.parse_to_idp()))
		# others
		IDP.NOT:
			return "~" + children[0].parse_to_idp()
		IDP.PARENTH:
			return "( " + children[0].parse_to_idp() + " )"
		IDP.BASE:
			return base
		IDP.CALL:
			return "%s(%s)" % [base,", ".join(children.map(func(child): return child.parse_to_idp()))]

		# foreach
		IDP.EACH:
			return "%s in %s: %s" % [children[0],children[1],children[2].parse_to_idp()]
		IDP.COUNT:
			return "#{ %s }" % children[0].parse_to_idp()
		IDP.SUM:
			return "sum{{ %s | %s }}" % [children[0].parse_to_idp(),children[1].parse_to_idp()]
		IDP.MIN:
			return "min{ %s | %s }" % [children[0].parse_to_idp(),children[1].parse_to_idp()]
		IDP.MAX:
			return "max{ %s | %s }" % [children[0].parse_to_idp(),children[1].parse_to_idp()]
		IDP.ALL:
			return "!%s" % children[0].parse_to_idp()
		IDP.ANY:
			return "?%s" % children[0].parse_to_idp()

	assert(false,"unimplemented")
	return ""

func _eq(other: Variant) -> Bool:
	if other is int:
		other = Integer.new_base(other)
	if other is float:
		other = Real.new_base(other)
	if other is bool:
		other = Bool.new_base(other)
	if other is String:
		other = get_type().new_base(other)
	if is_matching_type(other):
		print("doesnt break")
		return Bool.new("",[self,other],IDP.EQ)
	assert(false,"types did not match")
	return Bool.new_base("not matching arguments whre not matching types")

func _neq(other: Variant) -> Bool:
	if other is int:
		other = Integer.new_base(other)
	if other is float:
		other = Real.new_base(other)
	if other is bool:
		other = Bool.new_base(other)
	if other is String:
		other = get_type().new_base(other)
	if is_matching_type(other):
		return Bool.new("",[self,other],IDP.NEQ)
	assert(false,"types did not match")
	return Bool.new_base("not matching arguments whre not matching types")

		

func is_matching_type(other) -> bool:
	if self is ArithTerm and not other is ArithTerm:
		return false
	if other is ArithTerm and not self is ArithTerm:
		return false
	if self is Bool and not other is Bool:
		return false
	if other is Bool and not self is Bool:
		return false
	return true
	

func get_type():
	if self is Integer:
		return Integer
	if self is Real:
		return Real
	if self is Bool:
		return Bool
	if self is ArithTerm:
		return ArithTerm
	return Term
