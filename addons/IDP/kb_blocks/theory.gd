class_name Theory
extends KnowledgeBaseBlock

var linked_voc: String = "V"
var definitions: Array
var formulas: Array

func _init() -> void:
	block_name = "T"

#func create_from_string(str_voc: String) -> void:
	#block_str = str_voc
	#var lines: Array = Array(block_str.split("\n")
		#).map(func(line:String) -> String: return line.strip_edges())
	#for line: String in lines:
		#add_line(line)
#
func add_line(line: String) -> int:
	formulas.append(line)
	return 0
#func formulas_as_str() -> String:
	#return "\n".join(formulas.map(func(x: String) -> String: 
		#return "\t"+x))
#
#func definitions_as_str() -> String:
	#return "\n\t{\n"+"\n".join(definitions.map(func(x: String) -> String: 
		#return "\t\t"+x)) + "\n\t}\n"
#
func parse_to_idp() -> String:
	var header: String = "theory %s:%s {" % [block_name,linked_voc]
	var footer: String = "}"
	return "\n".join([header,"\t"+"\n\t".join(formulas),footer])
	
#func _to_string() -> String:
	#return "\tformulas: " + str(formulas) + "\n\tdefinitions: " + str(definitions)+"\n"
