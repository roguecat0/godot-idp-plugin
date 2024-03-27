extends Node

func _ready() -> void:
	var kb : KnowlegdeBase= IDP.create_empty_kb()
	var t1 = kb.add_type("t1",[2,3],IDP.BOOL)
	var p1: = kb.add_predicate("p1",IDP.INT)
	var f1: = kb.add_function("f1",[IDP.BOOL,IDP.REAL],IDP.INT)
	var f2: = kb.add_function("f2",[IDP.BOOL,IDP.INT],"Int")
	var c1: = kb.add_constant("c1",t1)
	var pp1: = kb.add_proposition("pp1")
	var term1 = p1.to_term([2])
	var term2 = f1.to_term([true,3.0])
	var term3 = IDP._p_not(term2._neq(term2))._defines(term1)
	var term4 = IDP._p_not(term1._defines(term1))
	var term5 = Integer.new_base(1)._lt(Real.new_base(3.5))._defines(Bool.new_base(true))
	var term6 = f2.to_term([false,7])
	var term7 = term1._equivalent(term4)
	var term8 = c1.to_term()
	var term9 = term2._sub(term6)
	var term10 = pp1.to_term()._and(term8)
	var d1 = kb.add_definition()
	d1.add_term(term3)
	d1.add_term(term4)
	d1.add_term(term5)
	kb.add_term(term7)
	kb.add_term(term9)
	kb.add_term(term10) 
	print(kb.parse_to_idp())
