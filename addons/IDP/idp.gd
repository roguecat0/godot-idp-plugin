extends Node

func _save(path: String,content: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)

func _load(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var content: String = file.get_as_text()
	return content

func execute(file_path: String) -> Array[String]:
	var std_out: Array[String] = []
	OS.execute("./.venv/Scripts/idp-engine.exe",[file_path],std_out)
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
	
func model_expand(kb: KnowlegdeBase) -> KnowlegdeBase:
	var expand_block: String = """
procedure main() {
	pretty_print(model_expand(T,S,max=1))
}
"""
	var kb_str: String = kb.parse_to_idp()+expand_block
	var expand_path : String = ".expand_input.idp"
	_save(expand_path,kb_str)
	var std_out: Array[String] = execute(expand_path)
	var out: Structure = Structure.new()
	out.create_from_string("\n".join(std_out))
	kb.solutions = []
	kb.solutions.append(out)
	return kb
	

	
