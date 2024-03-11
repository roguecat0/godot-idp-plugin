extends Node

func _ready() -> void:
	var kb: KnowlegdeBase = IDP.create_empty_kb()
	
	var even_letters: Array[String] = ["A","E","I"]
	var odd_letters: Array[String] = ["B","C","D"]
	var letters: Array[String] = even_letters + odd_letters
	
	var Decimal: CustomType = kb.add_type("Decimal",Array(range(0,9)),IDP.INT)
	var even_functions: Array = even_letters.map(func(letter):
		return kb.add_constant(letter,Decimal))
	var odd_functions: Array = odd_letters.map(func(letter):
		return kb.add_constant(letter,Decimal))
	var even: Predicate = kb.add_predicate("even",Decimal,[0,2,4,6,8])
	
	# from here no new implemenations
	for i: int in len(letters):
		var letter: String = letters[i]
		kb.theory.add_line("%s() ~= 0." % letter)
		for j: int in len(letters):
			if i <= j:
				break
			var letter2: String = letters[j]
			kb.theory.add_line("%s() ~= %s()." % [letter,letter2])
		if letter in even_letters:
			kb.theory.add_line("even(%s())." % letter)
		else:
			kb.theory.add_line("~even(%s())." % letter)
	kb.theory.add_line("I() + A() + 10*A() + 10*B() = E() + 10 * D() + 100 * C().")
	print(kb.parse_to_idp())
	
	
	# current possible inferences
	
	#print("Simple model expansion:")
	#IDP.model_expand(kb)
	#kb.view_solutions()
	
	#print("Parial solution with propogated values:")
	#IDP.propagate(kb)
	#kb.view_solutions()
	
	#print("Minimizion of A():")
	#kb.add_constant("min","Real")
	#kb.theory.add_line("A() = min().")
	#IDP.minimize(kb,"min()")
	#kb.view_solutions()
	
	#print("Maximization of D():")
	#kb.add_constant("max","Real")
	#kb.theory.add_line("D() = max().")
	#IDP.maximize(kb,"max()")
	#kb.view_solutions()
