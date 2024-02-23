extends Node

func _save(path,content) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)

func _load(path) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	return content

func execute(file_path: String) -> Array[String]:
	var std_out: Array[String]
	var std_err: Array[String]
	print(OS.get_name())
	OS.execute("./.venv/Scripts/idp-engine.exe",[file_path],std_out)
	return std_out
	
func create_kb_from_file(path) -> KnowlegdeBase:
	var idp_str: String = _load(path)
	return create_kb_from_string(idp_str)
	
func create_kb_from_string(kb_str: String) -> KnowlegdeBase:
	var kb := KnowlegdeBase.new()
	kb.create_from_string(kb_str)
	return kb 
	
func create_empty_kb() -> KnowlegdeBase: 
	return KnowlegdeBase.new()
	
func model_expand(kb: KnowlegdeBase):
	var expand_block = """
procedure main() {
	pretty_print(model_expand(T,S,max=1))
}
"""
	var kb_str: String = kb.parse_to_idp()+expand_block
	print(kb_str)
	var expand_path : String = ".expand_input.idp"
	_save(expand_path,kb_str)
	return execute(expand_path)
	
