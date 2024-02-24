class_name Theory
extends KnowledgeBaseBlock

var linked_voc: String = "V"
var definitions: Array[String]
var formulas: Array[String]

func _init() -> void:
	block_name = "T"

func create_from_string(str_voc: String) -> void:
	block_str = str_voc
	var lines: Array = Array(block_str.split("\n")
		).map(func(line:String) -> String: return line.strip_edges())
	for line: String in lines:
		add_line(line)
	formulas.map(func(x): print("'"+x+"'"))
	print()
	definitions.map(func(x): print(x))

func add_line(line: String) -> int:
	var line_stripped: String = line.strip_edges()
	if (line_stripped.begins_with("//") or line_stripped == "" 
			or line_stripped.begins_with("{") or line_stripped.begins_with("}")
			or line_stripped.begins_with("theory")):
		return -1
	elif "<-" in line:
		definitions.append(line_stripped)
		return 0
	else:
		formulas.append(line_stripped)
		return 1
		
func formulas_as_str() -> String:
	return "\n".join(formulas.map(func(x: String) -> String: 
		return "\t"+x))

func definitions_as_str() -> String:
	return "\n\t{\n"+"\n".join(definitions.map(func(x: String) -> String: 
		return "\t\t"+x)) + "\n\t}\n"

func parse_to_idp() -> String:
	var header: String = "theory %s:%s {" % [block_name,linked_voc]
	var footer: String = "}"
	return "\n".join([header,definitions_as_str(),formulas_as_str(),footer])
