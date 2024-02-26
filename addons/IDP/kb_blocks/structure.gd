class_name Structure
extends KnowledgeBaseBlock

var linked_voc: String = "V"
var functions: Dictionary
var predicates: Dictionary

func _init() -> void:
	block_name = "S" 


func create_from_string(str_voc: String) -> void:
	block_str = str_voc
	var lines: Array = Array(block_str.split("\n")
		).map(func(line:String) -> String: return line.strip_edges())
	for line: String in lines:
		add_line(line)
	print(functions.keys().map(func(key: String)-> String: return functions[key]))
	
func add_line(line: String) -> int:
	var line_stripped: String = line.strip_edges()
	if (line_stripped.begins_with("//") or line_stripped == "" 
			or line_stripped.begins_with("{") or line_stripped.begins_with("}")
			or line_stripped.begins_with("theory")):
		return -1
	elif ":=" in line:
		var res: Dictionary = split_result(line)
		functions[res.func_name] = res.content
		if "->" in res.content:
			functions[res.func_name] = res.content
		else:
			predicates[res.func_name] = res.content
		return 0
	return -1
			
func split_result(line: String) -> Dictionary:
	var parts: PackedStringArray = line.split(":=")
	return {
		"func_name":parts[0].strip_edges(),
		"content":parts[1].strip_edges().substr(0,len(parts[1])-2),
	}
	
func functions_as_str() -> String:
	return "\n".join(functions.keys().map(func(key: String) -> String: 
		return "\t"+key + " := " + functions[key] + "."))
		
func predicates_as_str() -> String:
	return "\n".join(predicates.keys().map(func(key: String) -> String: 
		return "\t"+key + " := " + predicates[key] + "."))

func parse_to_idp() -> String:
	var header: String = "structure %s:%s {" % [block_name,linked_voc]
	var footer: String = "}"
	return "\n".join([header,functions_as_str(),footer])
