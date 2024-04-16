extends Node

enum {INT,BOOL,REAL,DATE, UNKNOWN,STRING}
enum {THEORY,VOCABULARY,STRUCTURE}
enum {ADD,SUB,MUL,DIV,NEG,
	LT,LTE,GT,GTE,EQ,NEQ,
	AND,OR,NOT,IMPL,RIMPL,EQV,DFN,
	EACH,COUNT,SUM,MIN,MAX,ALL,ANY,
	BASE,PARENTH,CALL
} 
enum {EXPAND,PROPAGATE, MINIMIZE, MAXIMIZE}

signal inference_done(std_out, kb, inference_type)

const IDP_PATH = ".expand_input.idp" 

var force_partial_interpretation = true

func _ready():
	inference_done.connect(_receive_inference_output)
func disable_forcefull_partial_interpretation() -> void:
	force_partial_interpretation = false

func enable_forcefull_partial_interpretation() -> void:
	force_partial_interpretation = true

func _get_new_id():
	return KnowlegdeBase.get_max_id()

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
	var kb : KnowlegdeBase = create_empty_kb()
	kb.create_from_string(kb_str)
	return kb 
	
func create_empty_kb() -> KnowlegdeBase: 
	return KnowlegdeBase.new(_get_new_id())
	
func _setup_inference_file(kb: KnowlegdeBase,main_block:String) -> void:
	var kb_str: String = kb.parse_to_idp()+main_block
	print(kb_str)
	print("inf is set up")
	_save(IDP_PATH,kb_str)
	
func get_inference_output() -> Array:
	var std_out: Array = execute(IDP_PATH)
	print(std_out[0].replace("\r",""))
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

func call_async_inference(kb: KnowlegdeBase, inference_type: int) -> void:
	print("calling..")
	var std_out = get_inference_output()
	print("sending..")
	call_deferred("emit_signal", "inference_done", std_out,kb,inference_type)

func _receive_inference_output(std_out, kb, inference_type) -> void:
	print(std_out)
	kb.parse_solutions(std_out,inference_type)

func model_expand_async(kb: KnowlegdeBase) -> void:
	_setup_model_expand(kb)
	var thread = Thread.new()
	thread.start(call_async_inference.bind(kb, EXPAND))

	
func model_expand(kb: KnowlegdeBase) -> KnowlegdeBase:
	_setup_model_expand(kb)
	var std_out: Array = get_inference_output()
	print(std_out)
	kb.parse_solutions(std_out,EXPAND)
	return kb

func _setup_model_expand(kb: KnowlegdeBase):
	var main_block: String = """
procedure main() {
	pretty_print(model_expand(T,S,max=1))
}
"""
	_setup_inference_file(kb, main_block)
	
	




func minimize(kb: KnowlegdeBase,term) -> KnowlegdeBase:
	_setup_minimize(kb, term)
	var std_out: Array = get_inference_output()
	kb.parse_solutions(std_out,MAXIMIZE)
	return kb

func minimize_async(kb: KnowlegdeBase,term) -> void:
	_setup_minimize(kb, term)
	var thread = Thread.new()
	thread.start(call_async_inference.bind(kb, MINIMIZE))

func _setup_minimize(kb: KnowlegdeBase, term) -> void:
	var main_block: String = """
procedure main() {
	pretty_print(minimize(T,S,term="%s"))
}
""" % term
	_setup_inference_file(kb,main_block)
	

func maximize(kb: KnowlegdeBase,term) -> KnowlegdeBase:
	_setup_maximize(kb, term)
	var std_out: Array = get_inference_output()
	kb.parse_solutions(std_out,MAXIMIZE)
	return kb

func maximize_async(kb: KnowlegdeBase,term) -> void:
	_setup_maximize(kb, term)
	var thread = Thread.new()
	thread.start(call_async_inference.bind(kb, MAXIMIZE))

func _setup_maximize(kb: KnowlegdeBase, term) -> void:
	var main_block: String = """
procedure main() {
	pretty_print(maximize(T,S,term="%s"))
}
""" % term
	_setup_inference_file(kb,main_block)

func propagate(kb: KnowlegdeBase, complete: bool) -> KnowlegdeBase:
	_setup_propagate(kb,complete)
	var std_out: Array = get_inference_output()
	kb.parse_solutions(std_out,PROPAGATE)
	return kb

func propagate_async(kb: KnowlegdeBase, complete: bool) -> void:
	_setup_propagate(kb,complete)
	var thread = Thread.new()
	thread.start(call_async_inference.bind(kb, PROPAGATE))

func _setup_propagate(kb: KnowlegdeBase, complete: bool) -> void:
	var main_block: String = """
procedure main() {
	pretty_print(model_propagate(T,complete=%s))
}
""" % ["True" if complete else "False"]
	_setup_inference_file(kb,main_block)


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
