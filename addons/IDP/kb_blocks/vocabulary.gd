class_name Vocabulary
extends KnowledgeBaseBlock

var types: Dictionary
var functions: Dictionary

func _init() -> void:
	block_name = "V"
	
#func create_from_string(str_voc: String) -> void:
	#block_str = str_voc
	#
	#var lines: Array = Array(block_str.split("\n")
		#).map(func(line:String) -> String: return line.strip_edges())
	#for line: String in lines:
		#add_line(line)
			#
#func add_line(line: String) -> int:
	#var line_stripped: String = line.strip_edges()
	#if (line_stripped.begins_with("//") or line_stripped == "" 
			#or line_stripped.begins_with("{") or line_stripped.begins_with("}")
			#or line_stripped.begins_with("theory")):
		#return -1
	#elif line.begins_with("type "):
		#var res: Dictionary = parse_type(line)
		#types[res.type] = res.content
		#return 0
	#elif "->" in line:
		#parse_function(line).map(func(res: Dictionary) -> void:
			#functions[res.function]=res.content)
		#return 1
	#return -1
			#
#func parse_type(line: String) -> Dictionary:
	#var type: String = line
	#var content: String = ""
	#if ":=" in line:
		#var parts : PackedStringArray = line.split(":=")
		#type = parts[0].substr(4).strip_edges()
		#content = parts[1].strip_edges()
	#return {
		#"type":type,
		#"content":content,
	#}
	#
#func parse_function(line: String) -> Array[Dictionary]:
	#var parts : PackedStringArray = line.split(":")
	#var content: String = parts[1].strip_edges()
	#var funcs: Array = Array(parts[0].split(","))
	#return Array(funcs.map(func(x: String) -> Dictionary: 
		#return {"function":x.strip_edges(),"content":content}),TYPE_DICTIONARY,"",null)
#
func parse_to_idp() -> String:
	var header: String = "vocabulary %s {" % block_name
	var footer: String = "}"
	return "\n".join([header,types_as_str(),functions_as_str(),footer])

func types_as_str() -> String:
	return "\n".join(types.values().map(func(x): return x.to_vocabulary_line()))
	#
func functions_as_str() -> String:
	return "\n".join(functions.values().map(func(x): return x.to_vocabulary_line()))
		
#func _to_string() -> String:
	#return "\ttypes: " + str(types) + "\n\tfunctions: " + str(functions)+"\n"
