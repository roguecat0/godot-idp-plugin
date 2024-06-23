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
"""
pos:
{
	"symbol":{
		(applied domain): range
	}
}
"""
var positive_propagates: Dictionary
"""
neg:
{
	"symbol":{
		(applied domain): [range]
	}
}
"""
var negative_propagates: Dictionary
var id: int
static var max_id: int = 0

signal finished_inference(kb, inference_type)

func _init(id: int) -> void:
	self.id = id

static func get_max_id() -> int:
	max_id += 1
	return max_id

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

func get_domain_size(domain):
	var sum = 1
	for type in domain:
		if type is String:
			sum *= _get_type_size(type)
	return sum

func _get_type_size(type):
	if type is int:
		match type:
			IDP.BOOL:
				return 2
			_:
				return 999999
	if type is String:
		match type:
			"Bool":
				return IDP.BOOL
			"Int":
				return 99999
			"Real":
				return 99999
			"Date":
				return 99999
			_:
				type = types.get(type)

	if type is CustomType:
		return len(type.enums)
	assert(false, "domand(%s) has no valid type" % type)
	
		
func add_function(named: String, domain: Variant, range_: Variant, interpretation: Dictionary = {null:null}, partially_interpreted=false, default=null) -> Function:
	var f = Function.new(named,domain,range_,SymbolInterpretation.new(named,interpretation,default),partially_interpreted)
	f.range_base = _get_base_type(range_)
	symbols[named] = f
	f.domain_size = get_domain_size(f.domain)
	return f
	
func add_predicate(named: String, domain: Variant, interpretation: Array = [null]) -> Predicate:
	var v = {null:null}
	if interpretation != [null]:
		v = {}
		interpretation.map(func(k): v[k]=true)
	var p = Predicate.new(named,domain,"Bool",SymbolInterpretation.new(named,v,null))
	p.range_base = IDP.BOOL
	symbols[named] = p
	return p
	
func add_constant(named: String, range_: Variant, val: Variant = null) -> Constant:
	var c = Constant.new(named,[],range_,SymbolInterpretation.new(named,{null:null},val))
	c.range_base = _get_base_type(range_)
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
	
func parse_solutions(out_lines: Array, inference_type: int) -> void:
	#TODO: fix bug, adds an empty string to predicates when nothing to add
	# if out_lines[0].begins_with("Traceback"):
	# 	print("IDP error occured, exiting parse function")
	# 	return

	match inference_type:
		IDP.PROPAGATE:
			parse_propagation(out_lines)
		_:
			parse_expansion(out_lines, IDP.EXPAND == inference_type)
	# print(inference_type, ": inf type is ")
	# finished_inference.emit(self, inference_type)
	call_deferred("emit_signal", "finished_inference", self,inference_type)

func parse_propagation(outlines) -> void:
	negative_propagates = {}
	positive_propagates = {}
	symbols.keys().map(func(key):
		negative_propagates[key] = {}
		positive_propagates[key] = {}
	)
	var end = outlines.find("No more consequences.")
	var propagation_lines = outlines.slice(0,end)
	propagation_lines.map(func(x): parse_propagation_line(x))
	# print(negative_propagates)
	# print(positive_propagates)


func parse_propagation_line(line) -> void:
	var is_positive_propagation = true
	if line.begins_with("Not "):
		is_positive_propagation = false
		line = line.substr(4)
	line = line.replace(" ","").replace("->","=")
	var contents = line.split("=")
	var tmp = contents[0].split("(")
	var symbol = tmp[0]
	tmp = tmp[1].replace(")","")
	var domain = [] if tmp == "" else decode_string_values(tmp)
	var range_ = is_positive_propagation if len(contents) == 1 else decode_value(contents[1])
	if is_positive_propagation:
		positive_propagates[symbol][domain] = range_
	else:
		if negative_propagates[symbol].get(domain) == null:
			negative_propagates[symbol][domain] = [range_]
		else:
			negative_propagates[symbol][domain].append(range_)
	

func parse_expansion(out_lines, expansion) -> void:
	if out_lines.front() == "No models.":
		solvable = false
		print("model not solvable")
		return
	var new_lines = "\n".join(out_lines).split("==========")
	if expansion:
		new_lines = new_lines.slice(1)
	if len(new_lines) == 0:
		push_warning("no valid models")
		return
	new_lines = Array(new_lines)
	var models : Array = []
	new_lines.map(func(group): models.append(Array(group.split("\n")).filter(func(x): return ":=" in x and not x.begins_with("//"))))
	# models.append(out_lines)
	solutions = models.map(func(x): return parse_model_functions(x))
	solved = true

func update_kb_with_solution(solution: Dictionary):
	solution.keys().map(func(k): symbols[k].interpretation = solution[k])

func update_kb_with_propagate():
	for symbol in symbols.values():
		update_symbol_with_propagate(symbol)

func update_symbol_with_propagate(symbol):
	var updater = positive_propagates[symbol.named]
	if len(updater.keys()) == 0:
		return
	if updater.keys()[0] == []:
		symbol.interpretation.setd(updater[[]])
		return
	for key in updater.keys():
		var value = updater[key]
		symbol.add(key,value)
		
	
	
func parse_model_functions(model: Array) -> Dictionary:
	var model_solutions = {}
	for line in model:
		var res = parse_function_line(line)
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
