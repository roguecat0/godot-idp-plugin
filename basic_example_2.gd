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
		kb.add_undefined_line("%s() ~= 0." % letter,IDP.THEORY)
		for j: int in len(letters):
			if i <= j:
				break
			var letter2: String = letters[j]
			kb.add_undefined_line("%s() ~= %s()." % [letter,letter2],IDP.THEORY)
		if letter in even_letters:
			kb.add_undefined_line("even(%s())." % letter,IDP.THEORY)
		else:
			kb.add_undefined_line("~even(%s())." % letter,IDP.THEORY)
	kb.add_undefined_line("I() + A() + 10*A() + 10*B() = E() + 10 * D() + 100 * C().",IDP.THEORY)
	print(kb.parse_to_idp())
	
	
	# current possible inferences
	
	#print("Simple model expansion:")
	#IDP.model_expand(kb)
	#kb.view_solutions()
	
	print("Parial solution with propogated values:")
	IDP.propagate(kb)
	kb.view_solutions()
	
	#print("Minimizion of A():")
	#kb.add_constant("min","Real")
	#kb.add_undefined_line("A() = min().",IDP.THEORY)
	#IDP.minimize(kb,"min()")
	#kb.view_solutions()
	
	#print("Maximization of D():")
	#kb.add_constant("max","Real")
	#kb.add_undefined_line("D() = max().",IDP.THEORY)
	#IDP.maximize(kb,"max()")
	#kb.view_solutions()
