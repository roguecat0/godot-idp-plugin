extends Node

func _ready() -> void:
	var t1 := ArithTerm.new_base(3)
	print(t1.parse_to_str())
	var x := ArithTerm.new_base('x')
	var t3 : ArithTerm = x._add(1)._parenth()
	var t4 : ArithTerm = t1._div(t3)
	var y := ArithTerm.new_base('y')
	var equ = y._lt(t4._parenth())
	print(equ.parse_to_idp())
	
	var a : Bool= Bool.new_base('a')
	var b : Bool= Bool.new_base('b')
	equ = (IDP._p_neg(
			IDP._parenth(
				(x._add(t1)))
			._div(y)
		)._eq(t1)
		._implies(
			IDP._parenth(
				a._rev_implies(b)
			)))
	print(equ.parse_to_idp())



