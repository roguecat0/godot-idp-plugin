class_name KnowlegdeBase
extends Node

var types: Dictionary
var symbols: Dictionary = {}
var formulas: Array

var undefined_lines: Dictionary = {IDP.THEORY:[],IDP.VOCABULARY:[],IDP.STRUCTURE:[]}
# output respresentation
var solvable: bool = true
var solved: bool = false
var solutions: Array
var positive_propogate: Dictionary
var negative_propogate: Dictionary

func _init() -> void:
	pass

func add_type(named: String, enumeration: Array, base_type: int=IDP.UNKNOWN) -> CustomType:
	var t = CustomType.new(named,enumeration,base_type)
	types[named] = t
	return t

func _get_base_type(custom_type: Variant):
	if custom_type is int:
		return custom_type
	if custom_type is String:
		match custom_type:
			"Bool":
				return IDP.BOOL
			"Int":
				return IDP.INT
			"Real":
				return IDP.REAL
			"Date":
				return IDP.DATE
			_:
				custom_type = types.get(custom_type)
	return custom_type.base_type
	
	
func add_function(named: String, in_types: Variant, out_type: Variant, interpretation: Dictionary = {null:null},default=null) -> Symbol:
	var f = Symbol.new(named,in_types,out_type,SymbolInterpretation.new(named,interpretation,default))
	f.range_base = _get_base_type(out_type)
	symbols[named] = f
	return f
	
func add_predicate(named: String, in_types: Variant, interpretation: Array = [null]) -> Predicate:
	var v = {null:null}
	if interpretation != [null]:
		v = {}
		interpretation.map(func(k): v[k]=true)
	var p = Predicate.new(named,in_types,"Bool",SymbolInterpretation.new(named,v,null))
	p.range_base = IDP.BOOL
	symbols[named] = p
	return p
	
func add_constant(named: String, out_type: Variant, val: Variant = null) -> Constant:
	var c = Constant.new(named,[],out_type,SymbolInterpretation.new(named,{null:null},val))
	c.range_base = _get_base_type(out_type)
	symbols[named] = c
	return c

func add_proposition(named: String, val: Variant = null) -> Proposition:
	var c = Proposition.new(named,[],"Bool",SymbolInterpretation.new(named,{null:null},val))
	c.range_base = IDP.BOOL
	symbols[named] = c
	return c

func add_formula(term: Term):
	formulas.append(term)
	return term
	
func add_definition(terms: Array=[]):
	var d = Definition.new(terms)
	formulas.append(d)
	return d
	
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
	
func update_kb_with_solution(solution: Dictionary):
	solution.keys().map(func(k): symbols[k].interpretation = solution[k])
	
func parse_model_functions(model: Array) -> Dictionary:
	var model_solutions = {}
	for line in model:
		var res = parse_function_line(line)
		print(res, " ", res.named)
		model_solutions[res.named] = res
	return model_solutions
	
func add_undefined_line(line: String, block: int):
	undefined_lines[block].append(line)
	
func parse_function_line(line: String) -> SymbolInterpretation:
	var parts = line.replace(" ","").split(":=")
	var named = parts[0]
	var content = parts[1]
	content =  parse_interpretation(content)
	if content is Dictionary:
		return SymbolInterpretation.new(named,content,null)
	return SymbolInterpretation.new(named,{null:null},content)
	
	
func parse_interpretation(content: String) -> Variant:
	content = content.substr(0,len(content)-1)
	if content.ends_with("}"):
		content = content.substr(1,len(content)-2)
		if "->" in content:
			if content.begins_with("("):
				var d : Dictionary = {}
				content = content.substr(1)
				var tmp = Array(content.split(",(")).map(func(x):return x.split(")->"))
				tmp.map(func(x): d[decode_string_values(x[0])] = decode_value(x[1]))
				return d
			else:
				var d : Dictionary = {}
				var tmp = Array(content.split(",")).map(func(x):return x.split("->"))
				tmp.map(func(x): d[decode_value(x[0])] = decode_value(x[1]))
				return d
		else:
			if content.begins_with("("):
				var d : Dictionary = {}
				Array(content.split("),")).map(func(x): d[decode_string_values(x)] = true)
				return d
			else:
				var d : Dictionary = {}
				Array(content.split(",")).map(func(x): d[decode_value(x)] = true)
				return d
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
	
func parse_voc_to_idp() -> String:
	var header: String = "vocabulary V {"
	var footer: String = "}"
	return "\n".join([header,types_as_str(),functions_voc_as_str(),
		parse_undefined_lines(IDP.VOCABULARY),footer])

func parse_undefined_lines(block):
	return "\n".join(undefined_lines[block])

func types_as_str() -> String:
	return "\n".join(types.values().map(func(x): return x.to_vocabulary_line()))
	#
func functions_voc_as_str() -> String:
	return "\n".join(symbols.values().map(func(x): return x.to_vocabulary_line()))

func parse_the_to_idp() -> String:
	var header: String = "theory T:V {"
	var footer: String = "}"
	return "\n".join([header,
		parse_form_to_idp(),
		parse_undefined_lines(IDP.THEORY),footer])

func parse_form_to_idp() -> String:
	return "\t" + "\n\t".join(formulas.map(
		func(form): return form.parse_to_idp() + ("." if form is Term else "")
))

func parse_str_to_idp() -> String:
	var header: String = "structure S:V {"
	var footer: String = "}"
	return "\n".join([header,functions_str_as_str(),
		parse_undefined_lines(IDP.STRUCTURE),footer])

func functions_str_as_str() -> String:
	return "\n".join(symbols.values().map(func(x): 
		return x.to_structure_line()).filter(func(x): return x != ""))
func parse_to_idp() -> String:
	return "\n".join([parse_voc_to_idp(),parse_the_to_idp(),parse_str_to_idp()])
