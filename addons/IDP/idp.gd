extends Node

enum {INT,BOOL,REAL,DATE, UNKNOWN,STRING}
enum {THEORY,VOCABULARY,STRUCTURE}
enum {ADD,SUB,MUL,DIV,NEG,
	LT,LTE,GT,GTE,EQ,NEQ,
	AND,OR,NOT,IMPL,RIMPL,EQV,DFN,
	EACH,COUNT,SUM,MIN,MAX,ALL,ANY,
	BASE,PARENTH,CALL
} 

func _save(path: String,content: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)

func _load(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var content: String = file.get_as_text()
	return content

func execute(file_path: String) -> Array[String]:
	var std_out: Array[String] = []
	OS.execute("./.venv/Scripts/idp-engine.exe",[file_path],std_out,true)
	return std_out
	
func create_kb_from_file(path: String) -> KnowlegdeBase:
	var idp_str: String = _load(path)
	return create_kb_from_string(idp_str)
	
func create_kb_from_string(kb_str: String) -> KnowlegdeBase:
	var kb : KnowlegdeBase = KnowlegdeBase.new()
	kb.create_from_string(kb_str)
	return kb 
	
func create_empty_kb() -> KnowlegdeBase: 
	return KnowlegdeBase.new()
	
func get_inference_output(kb: KnowlegdeBase,main_block:String) -> Array:
	var kb_str: String = kb.parse_to_idp()+main_block
	print(kb_str)
	var expand_path : String = ".expand_input.idp"
	_save(expand_path,kb_str)
	var std_out: Array = execute(expand_path)
	std_out = Array(std_out[0].replace("\r","").split("\n"))
	# TODO: add error output handeling
	if std_out[0].begins_with("Traceback"):
		print("\n".join(std_out.slice(max(0,len(std_out)-20))))
		push_error("IDP - Error")
		#count += 1
		#for line in Array(kb.parse_to_idp().split("\n")):
			#count += 1
			#if count in []
			#print("%d. %s" % [count,line])
	return std_out
	
func model_expand(kb: KnowlegdeBase) -> KnowlegdeBase:
	var main_block: String = """
procedure main() {
	pretty_print(model_expand(T,S,max=1))
}
"""
	var std_out: Array = get_inference_output(kb,main_block)
	var models: Array = kb.parse_solutions(std_out)
	kb.solutions = models
	kb.solved = true
	return kb
	
func propagate(kb: KnowlegdeBase) -> KnowlegdeBase:
	var main_block: String = """
procedure main() {
	pretty_print(Theory(T,S).propagate())
}
"""
	var std_out: Array = get_inference_output(kb,main_block)
	var models = kb.parse_solutions(std_out)
	kb.solutions = models
	kb.solved = true
	return kb

func optimize(kb: KnowlegdeBase,term:String,is_minimize: bool) -> KnowlegdeBase:
	var main_block: String = """
procedure main() {
	pretty_print(%s(T,S,term="%s"))
}
""" % ["minimize" if is_minimize else "maximize",term]
	var std_out: Array = get_inference_output(kb,main_block)
	var models = kb.parse_solutions(std_out)
	kb.solutions = models
	kb.solved = true
	return kb

func minimize(kb: KnowlegdeBase,term: String) -> KnowlegdeBase:
	return optimize(kb,term,true)

func maximize(kb: KnowlegdeBase,term: String) -> KnowlegdeBase:
	return optimize(kb,term,false)

func parenth(term: Term):
	return term.parenth()

func neg(term: Term):
	if term is ArithTerm:
		return term.neg()
	push_error("trying to negate a non-arithmatic term")
	return Term.base_("is not and ArithTerm")

func not_(term: Term):
	if term is Bool:
		return term.not_()
	push_error("trying to 'not' a non-boolean term")
	return Term.base_("is not and ArithTerm")

func p_neg(term: Term):
	return term.parenth().neg()

func p_not(term: Term):
	return term.parenth().not_()
