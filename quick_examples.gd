extends Node

func _ready() -> void:
	var kb = IDP.create_empty_kb()
	var T = kb.add_type("T",range(0,6),IDP.INT)
	var func1 = kb.add_function("func1",IDP.BOOL,T)
	var pred1 = kb.add_predicate("pred1",[IDP.BOOL,"T"],
			[[true,3],[false,4]])
	var const1 = kb.add_constant("const1",IDP.REAL)
	
	func1.add(true,0)
	pred1.remove([false,4])
	const1.set_value(4.6)
	print(kb.parse_to_idp())
	
	kb = IDP.create_empty_kb()
	T = kb.add_type("T",range(0,6),IDP.INT)
	pred1 = kb.add_predicate("pred1",["T"])
	
	var add_term = Real.new_base(3)._add(2)
	var lte_term = add_term._lte("x")
	var implies_term = IDP._p_not(
		pred1.to_term([2])._implies(lte_term))
		
	kb.add_formula(add_term)
	kb.add_formula(lte_term)
	kb.add_formula(implies_term)
	print(kb.parse_to_idp())
