extends Node

func _ready() -> void:
	var kb: KnowlegdeBase = IDP.create_empty_kb()
	
	var even_letters: Array[String] = ["A","E","I"]
	var odd_letters: Array[String] = ["B","C","D"]
	var letters: Array[String] = even_letters + odd_letters
	
	var Decimal: CustomType = kb.add_type("Decimal",Array(range(0,10)),IDP.INT)
	var even_letter_const: Array = even_letters.map(func(letter):
		return kb.add_constant(letter,Decimal))
	var odd_letter_const: Array = odd_letters.map(func(letter):
		return kb.add_constant(letter,Decimal))
	var even: Predicate = kb.add_predicate("even",Decimal,[0,2,4,6,8])
	var all_letters = even_letter_const+odd_letter_const
	# from here no new implemenations
	# implemented with terms
	for i: int in len(all_letters):
		# var letter: String = letters[i]
		var letter: Constant = all_letters[i]
		# kb.add_undefined_line("%s() ~= 0." % letter,IDP.THEORY)
		var l_term = letter.to_term()
		kb.add_term(l_term._neq(0))
		for j: int in len(letters):
			if i <= j:
				break
			var letter2: Constant = all_letters[j]
			# var letter2: String = letters[j]
			# kb.add_undefined_line("%s() ~= %s()." % [letter,letter2],IDP.THEORY)
			kb.add_term(l_term._neq(letter2.to_term()))
		if letter in even_letter_const:
			# kb.add_undefined_line("even(%s())." % letter,IDP.THEORY)
			kb.add_term(even.to_term([l_term]))
		else:
			# kb.add_undefined_line("~even(%s())." % letter,IDP.THEORY)
			kb.add_term(IDP._not(even.to_term([l_term])))
	# kb.add_undefined_line("I() + A() + 10*A() + 10*B() = E() + 10 * D() + 100 * C().",IDP.THEORY)
	var first_half = (
		kb.functions.I.to_term()
		._add(kb.functions.A.to_term())
		._add(kb.functions.A.to_term()._mul(10))
		._add(kb.functions.B.to_term()._mul(10))
	)
	var second_half = (
		kb.functions.E.to_term()
		._add(kb.functions.D.to_term()._mul(10))
		._add(kb.functions.C.to_term()._mul(100))
	)
	kb.add_term(first_half._eq(second_half))
	
	
	# current possible inferences
	
	# print("Simple model expansion:")
	# IDP.model_expand(kb)
	# kb.view_solutions()
	
	# print("Parial solution with propogated values:")
	# IDP.propagate(kb)
	# kb.view_solutions()
	
	print("Minimizion of A():")
	var minus = kb.add_constant("min","Real")
	kb.add_undefined_line("A() = min().",IDP.THEORY)
	kb.add_term(kb.functions.A.to_term()._eq(minus.to_term()))
	IDP.minimize(kb,"min()")
	print("==== updated kb ====")
	kb.update_kb_with_solution(kb.solutions[0])
	print(kb.parse_to_idp())
	# kb.view_solutions()
	
	#print("Maximization of D():")
	#kb.add_constant("max","Real")
	#kb.add_undefined_line("D() = max().",IDP.THEORY)
	#IDP.maximize(kb,"max()")
	#kb.view_solutions()
