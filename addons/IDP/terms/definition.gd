extends Node
class_name Definition

var terms: Array

func _init(terms_a = []) -> void:
	terms = terms_a

func add_formula(term: Term):
	terms.append(term)
	return term

func parse_to_idp() -> String:
	return "\n\t{\n\t\t%s\n\t}\n" % "\n\t\t".join(terms.map(func(term): return term.parse_to_idp()+"."))
