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

const IDP_AUX_PATH = ".inference_file_%s.idp"
const IDP_MAIN_PATH = ".inference_file_0.idp"

var force_partial_interpretation = true

var max_threads: int = 4
"""
[
	// inference
	{
		"code": //fodot code
		"kb": reff to KnowlegdeBase,
		"inference_type": inference enum
	}
]
"""
var inference_queue: Array = []

var active_inferences: int = 0
var inferences_counter: int = 0

func _get_inferences_file():
	return IDP_AUX_PATH % (inferences_counter % max_threads + 1)

func _add_active_inference():
	active_inferences = active_inferences + 1
	inferences_counter = inferences_counter + 1
	print("active: ", active_inferences, ", counter: ", inferences_counter)

	

func _handel_async_inference_request(kb, fodot_code, infr_type):
	if active_inferences >= max_threads:
		inference_queue.append({"code":fodot_code, "kb":kb, "type":infr_type})
		return 
	var inf_path = _get_inferences_file()
	_add_active_inference()
	_save(inf_path, fodot_code)
	var thread = Thread.new()
	thread.start(call_async_inference.bind(kb, infr_type, inf_path))
	
	

func _ready():
	inference_done.connect(_receive_inference_output)

func disable_forcefull_partial_interpretation() -> void:
	force_partial_interpretation = false

func enable_forcefull_partial_interpretation() -> void:
	force_partial_interpretation = true

func set_max_inference_threads(num_threads: int) -> void:
	max_threads = num_threads

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
	
func _setup_inference_str(kb: KnowlegdeBase,main_block:String) -> String:
	var kb_str: String = kb.parse_to_idp()+main_block
	return kb_str

	
func get_inference_output(file_path: String) -> Array:
	var std_out: Array = execute(file_path)
	print(std_out[0].replace("\r",""))
	std_out = Array(std_out[0].replace("\r","").split("\n"))
	# TODO: add error output handeling
	if std_out[0].begins_with("Traceback"):
		print("\n".join(std_out.slice(max(0,len(std_out)-20))))
		assert(false,"IDP - Error")
	return std_out

func call_async_inference(kb: KnowlegdeBase, inference_type: int, inf_path) -> void:
	print("called inf: ", inference_type, ", on kb: ", kb.id ,", with path: ", inf_path)
	var std_out = get_inference_output(inf_path)
	call_deferred("emit_signal", "inference_done", std_out,kb,inference_type)

func _receive_inference_output(std_out, kb, inference_type) -> void:
	print("inference finished.. ", inference_type, ", curr_inferences: ", active_inferences)
	active_inferences = active_inferences - 1
	print("after inferences: ", active_inferences)
	if len(inference_queue) > 0:
		var inference = inference_queue.pop_front()
		print("new inference started.. ", inference.type)
		var inf_path = _get_inferences_file()
		_add_active_inference()
		_save(inf_path,inference.code)
		var thread = Thread.new()
		thread.start(call_async_inference.bind(kb, inference.type, inf_path))

	kb.parse_solutions(std_out,inference_type)

func model_expand_async(kb: KnowlegdeBase, max_: int) -> void:
	var fodot_code = _setup_model_expand(kb, max_)
	_handel_async_inference_request(kb,fodot_code,EXPAND)
	
func model_expand(kb: KnowlegdeBase, max_: int=10) -> KnowlegdeBase:
	var fodot_code = _setup_model_expand(kb, max_)
	_save(IDP_MAIN_PATH,fodot_code)
	var std_out: Array = get_inference_output(IDP_MAIN_PATH)
	print(std_out)
	kb.parse_solutions(std_out,EXPAND)
	return kb

func _setup_model_expand(kb: KnowlegdeBase, max_: int) -> String:
	var main_block: String = """
procedure main() {
	pretty_print(model_expand(T,S,max=%d))
}
""" % max_
	var fodot_code = _setup_inference_str(kb, main_block)
	print(main_block)
	return fodot_code
	
func minimize(kb: KnowlegdeBase,term) -> KnowlegdeBase:
	var fodot_code = _setup_minimize(kb, term)
	_save(IDP_MAIN_PATH,fodot_code)
	var std_out: Array = get_inference_output(IDP_MAIN_PATH)
	kb.parse_solutions(std_out,MINIMIZE)
	return kb

func minimize_async(kb: KnowlegdeBase,term) -> void:
	var fodot_code = _setup_minimize(kb, term)
	_handel_async_inference_request(kb,fodot_code,MINIMIZE)

func _setup_minimize(kb: KnowlegdeBase, term) -> String:
	var main_block: String = """
procedure main() {
	pretty_print(minimize(T,S,term="%s"))
}
""" % term
	var fodot_code = _setup_inference_str(kb,main_block)
	return fodot_code
	

func maximize(kb: KnowlegdeBase,term) -> KnowlegdeBase:
	var fodot_code = _setup_maximize(kb, term)
	_save(IDP_MAIN_PATH,fodot_code)
	var std_out: Array = get_inference_output(IDP_MAIN_PATH)
	kb.parse_solutions(std_out,MAXIMIZE)
	return kb

func maximize_async(kb: KnowlegdeBase,term) -> void:
	var fodot_code = _setup_maximize(kb, term)
	_handel_async_inference_request(kb,fodot_code,MAXIMIZE)

func _setup_maximize(kb: KnowlegdeBase, term) -> String:
	var main_block: String = """
procedure main() {
	pretty_print(maximize(T,S,term="%s"))
}
""" % term
	var fodot_code = _setup_inference_str(kb,main_block)
	return fodot_code

func propagate(kb: KnowlegdeBase, complete: bool) -> KnowlegdeBase:
	var fodot_code = _setup_propagate(kb,complete)
	_save(IDP_MAIN_PATH,fodot_code)
	var std_out: Array = get_inference_output(IDP_MAIN_PATH)
	kb.parse_solutions(std_out,PROPAGATE)
	return kb

func propagate_async(kb: KnowlegdeBase, complete: bool) -> void:
	var fodot_code = _setup_propagate(kb,complete)
	_handel_async_inference_request(kb,fodot_code,PROPAGATE)

func _setup_propagate(kb: KnowlegdeBase, complete: bool) -> String:
	var main_block: String = """
procedure main() {
	pretty_print(model_propagate(T,complete=%s))
}
""" % ["True" if complete else "False"]
	var fodot_code = _setup_inference_str(kb,main_block)
	return fodot_code


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
