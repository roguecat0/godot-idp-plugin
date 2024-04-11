extends Node

func _ready() -> void:
	var t1 := ArithTerm.base_(3)
	print(t1.parse_to_str())
	var x := ArithTerm.base_('x')
	var t3 : ArithTerm = x.add(1).parenth()
	var t4 : ArithTerm = t1.div(t3)
	var y := ArithTerm.base_('y')
	var equ = y.lt(t4.parenth())
	print(equ.parse_to_idp())
	
	var a : Bool= Bool.base_('a')
	var b : Bool= Bool.base_('b')
	equ = (IDP._p_neg(
			IDP.parenth(
				(x.add(t1)))
			.div(y)
		).eq(t1)
		.implies(
			IDP.parenth(
				a.rev_implies(b)
			)))
	print(equ.parse_to_idp())



