extends Node

func _ready() -> void:
	var kb = IDP.create_empty_kb()
	var Y = kb.add_type("Y",range(3), IDP.INT)
	kb.add_predicate("y", Y,[2])
	var a: Function = kb.add_function("a", Y, Y, {null:null}, false)
	var f = kb.add_function("f", [Y,Y], Y)
	var c = kb.add_constant("c", IDP.INT)
	var b = kb.add_constant('b', Y)
	var d = kb.add_proposition('d')
	var bt = b.apply()
	var ct = c.apply()
	kb.add_formula(bt.eq(ct))

	a.add(2,2)
	f.add([2,2],2)
	f.add([0,2],1)
	# IDP.disable_forcefull_partial_interpretation()
	IDP.model_expand_async(kb)
	await kb.finished_inference

	# IDP.minimize_async(kb,ct.parse_to_idp())
	# await kb.finished_inference
	# print(kb.solutions)

	# kb.add_formula(bt.eq(1))
	# kb.add_formula(d.apply())
	# kb.add_formula(a.apply([0]).eq(0))
	# kb.add_formula(a.apply([2]).eq(1))
	# kb.add_formula(f.apply([2,1]).eq(1))
	# IDP.propagate_async(kb,true)
	# await kb.finished_inference
	# print(kb.positive_propagates)
