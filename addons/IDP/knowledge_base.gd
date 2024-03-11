class_name KnowlegdeBase
extends Node

# TODO: figure out if and where to implement a parser class

var vocabulary: Vocabulary = Vocabulary.new()
var structure: Structure = Structure.new()
var theory: Theory = Theory.new()
var solutions: Array[Structure]
var types: Dictionary: 
	get: return vocabulary.types
	set(val): vocabulary.types = val
var functions: Dictionary = {}
var solved_functions: Dictionary
var solvable: bool = true
var solved: bool = false

func _init() -> void:
	vocabulary.functions = functions
	structure.functions = functions

func add_type(named: String, enumeration: Array, base_type: int=IDP.IDP_UNKNOWN) -> CustomType:
	var t = CustomType.new(named,enumeration,base_type)
	vocabulary.types[named] = t
	return t
	
func add_function(n: String, in_types: Variant, out_type: Variant, enumerations: Dictionary = {}) -> Function:
	var f = Function.new(n,in_types,out_type,enumerations)
	functions[n] = f
	return f
	
func add_predicate(n: String, in_types: Variant, enumerations: Array = []) -> Predicate:
	var p = Predicate.new(n,in_types,enumerations)
	functions[n] = p
	return p
	
func add_constant(n: String, out_type: Variant, val: Variant = null) -> Constant:
	var c = Constant.new(n,out_type,val)
	functions[n] = c
	return c

func add_proposition(n: String, val: Variant = null) -> Proposition:
	var p = Proposition.new(n,val)
	functions[n] = p
	return p
	
func view_solutions():
	solved_functions.keys().map(func(k): print(k," : ",solved_functions[k]))
	
func parse_solutions(out_lines: Array) -> Array:
	#TODO: fix bug, adds an empty string to predicates when nothing to add
	if out_lines.front() == "No models.":
		solvable = false
		print("model not solvable")
		return []
	var models : Array = []
	out_lines = out_lines.filter(func(x): return ":=" in x and not x.begins_with("//"))
	models.append(out_lines)
	var model_solutions = models.map(func(x): return parse_model_functions(x))
	return model_solutions
	
func update_knowledge_base(solution: Dictionary,append=false):
	solved_functions = {}
	functions.keys().map(func(k): solved_functions[k] = functions[k].copy())
	solution.keys().map(func(k): solved_functions[k].update(solution[k],append))
	solved = true
	
func parse_model_functions(model: Array) -> Dictionary:
	var solutions = {}
	for line in model:
		var res = parse_function_line(line)
		solutions[res[0]] = res[1]
	return solutions
	
func parse_function_line(line: String) -> Array:
	var parts = line.replace(" ","").split(":=")
	var named = parts[0]
	var content = parts[1]
	return [named,parse_enumeration(content)]
	
	
func parse_enumeration(content: String) -> Variant:
	content = content.substr(0,len(content)-1)
	if content.ends_with("}"):
		content = content.substr(1,len(content)-2)
		if "->" in content:
			if content.begins_with("("):
				var enums : Dictionary = {}
				content = content.substr(1)
				var tmp = Array(content.split(",(")).map(func(x):return x.split(")->"))
				tmp.map(func(x): enums[decode_string_values(x[0])] = decode_value(x[1]))
				return enums
			else:
				var enums : Dictionary = {}
				var tmp = Array(content.split(",")).map(func(x):return x.split("->"))
				tmp.map(func(x): enums[decode_value(x[0])] = decode_value(x[1]))
				return enums
		else:
			if content.begins_with("("):
				var enums : Dictionary = {}
				Array(content.split("),")).map(func(x): enums[decode_string_values(x)] = true)
				return enums
			else:
				var enums : Dictionary = {}
				Array(content.split(",")).map(func(x): enums[decode_value(x)] = true)
				return enums
	return decode_value(content)
	
func decode_string_values(val: String) -> Array:
	val = val.replace("(","").replace(")","")
	return Array(val.split(",")).map(func(x):return decode_value(x))
	
func decode_value(val: String) -> Variant:
	if val == "true":
		return true
	if val == "false":
		return false
	if val.is_valid_int():
		return int(val)
	if val.is_valid_float():
		return float(val)
	return val
#func clean_idp_line(line: String) -> String:
	#line = line.strip_edges()
	#line = line.get_slice("//",0)
	#line = line if line.find("[") == -1 else ""
	#line = line if line.find("#!") != 0 else ""
	#return line.strip_edges()
	#
#func clean_idp_str(idp_str: String) -> Array[String]:
	#var idp_lines: Array = Array(idp_str.split("\n"))
	#return Array(idp_lines.map(clean_idp_line).filter(func(x: String)-> bool: return x!=""),TYPE_STRING,"",null)
	#
#func create_from_string(kb_str: String) -> void:
	#var lines: Array[String] = clean_idp_str(kb_str)
	#print(lines)
	#var i: int = 0
	#var j: int = 0
	#while i < len(lines):
		#if lines[i].to_lower().begins_with("vocabulary"):
			#j = search_block_end(lines,i)
			#vocabulary.create_from_string("\n".join(lines.slice(i,j+1)))
			#i=j
		#elif lines[i].to_lower().begins_with("structure"):
			#j = search_block_end(lines,i)
			#structure.create_from_string("\n".join(lines.slice(i,j+1)))
			#i=j
		#elif lines[i].to_lower().begins_with("theory"):
			#j = search_block_end(lines,i)
			#theory.create_from_string("\n".join(lines.slice(i,j+1)))
			#i=j
		#i+=1
			#
#func search_block_end(lines: Array[String],idx: int) -> int:
	#for j: int in range(idx,len(lines)):
		#if lines[j].begins_with("}"):
			#return j
	#return idx
			#
func parse_to_idp() -> String:
	return "\n".join([vocabulary.parse_to_idp(),theory.parse_to_idp(),structure.parse_to_idp()])
	
#func add_line_to_vocabulary(line: String) -> int:
	#return vocabulary.add_line(line)
	#
#func add_line_to_theory(line: String) -> int:
	#return theory.add_line(line)
	#
#func add_line_to_structure(line: String) -> int:
	#return structure.add_line(line)
	#
#func _to_string() -> String:
	#return ("Vocabulary:\n" + str(vocabulary) 
		#+ "Theory:\n" + str(theory) 
		#+ "Structure:\n" + str(structure)
		#+ "Solution:\n" + str(solutions.front()))
