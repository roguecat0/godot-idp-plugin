extends Node

func _ready() -> void:
	var my_kb: KnowlegdeBase = IDP.create_empty_kb()
	var even_letters: Array[String] = ["A","E","I"]
	var odd_letters: Array[String] = ["B","C","D"]
	var letters: Array[String] = even_letters + odd_letters
	
	my_kb.vocabulary.add_line("type Decimal := {0..9}")
	my_kb.vocabulary.add_line("A,B,C,I,D,E: () -> Decimal")
	my_kb.vocabulary.add_line("Even: (Decimal) -> Bool")
	my_kb.structure.add_line("Even := {0,2,4,6,8}.")
	print(my_kb.structure)
	for i: int in len(letters):
		var letter: String = letters[i]
		my_kb.theory.add_line("%s() ~= 0." % letter)
		for j: int in len(letters):
			if i <= j:
				break
			var letter2: String = letters[j]
			my_kb.theory.add_line("%s() ~= %s()." % [letter,letter2])
		if letter in even_letters:
			my_kb.theory.add_line("Even(%s())." % letter)
		else:
			my_kb.theory.add_line("~Even(%s())." % letter)
			
	my_kb.theory.add_line("I() + A() + 10*A() + 10*B() = E() + 10 * D() + 100 * C().")
	IDP.model_expand(my_kb)
	print(my_kb)
