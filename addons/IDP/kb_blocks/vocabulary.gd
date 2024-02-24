class_name Vocabulary
extends KnowledgeBaseBlock

var types: Array[Dictionary] = []
var functions: Array[Dictionary] = []
const practice_str : String = """
vocabulary V {
	type T
	type T := {c1, c2, c3}
	
	type T := {1,2,3}
	type T := {1..3}
	// built-in types: 𝔹, ℤ, ℝ, Date, Concept Bool, Int, Real, Date, Concept

	p: () -> Bool
	p1, p2: T1*T2 -> Bool
	f: T -> T
	f1, f2: Concept[T1->T2] -> T

	[this is the intended meaning of p]
	p : () → Bool

	var x in T
	import W
}"""

func _init() -> void:
	block_name = "V"
	
func create_from_string(str_voc: String) -> void:
	block_str = str_voc
	
	var lines: Array = Array(block_str.split("\n")
		).map(func(line:String) -> String: return line.strip_edges())
	for line: String in lines:
		add_line(line)
			
func add_line(line: String) -> int:
	var line_stripped: String = line.strip_edges()
	if (line_stripped.begins_with("//") or line_stripped == "" 
			or line_stripped.begins_with("{") or line_stripped.begins_with("}")
			or line_stripped.begins_with("theory")):
		return -1
	elif line.begins_with("type "):
		types.append(parse_type(line))
		return 0
	elif "->" in line:
		functions += parse_function(line)
		return 1
	print(line)
	return -1
			
func parse_type(line: String) -> Dictionary:
	var type: String = line
	var content: String = ""
	if ":=" in line:
		var parts : PackedStringArray = line.split(":=")
		type = parts[0].substr(4).strip_edges()
		content = parts[1].strip_edges()
	return {
		"type":type,
		"content":content,
	}
	
func parse_function(line: String) -> Array[Dictionary]:
	var parts : PackedStringArray = line.split(":")
	var content: String = parts[1].strip_edges()
	var funcs: Array = Array(parts[0].split(","))
	return Array(funcs.map(func(x: String) -> Dictionary: 
		return {"function":x.strip_edges(),"content":content}),TYPE_DICTIONARY,"",null)

func parse_to_idp() -> String:
	var header: String = "vocabulary %s {" % block_name
	var footer: String = "}"
	return "\n".join([header,types_as_str(),functions_as_str(),footer])

func types_as_str() -> String:
	return "\n".join(types.map(func(x: Dictionary) -> String:
		var backend: String = " := " + x.content if x.content != "" else ""
		return "\ttype "+x.type + backend))
	
func functions_as_str() -> String:
	return "\n".join(functions.map(func(x: Dictionary) -> String:
		return "\t"+x.function + ": " + x.content))
