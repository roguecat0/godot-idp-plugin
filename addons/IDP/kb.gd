class_name KnowlegdeBase
extends Node

var vocabulary:= Vocabulary.new()
var structure:= Structure.new()
var theory:= Theory.new()
# TODO: figure out whether to add functionality for adding multiple of the same block type in a kb


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func do_something() -> String:
	return "lol"
	
func create_from_string(kb_str: String) -> void:
	var lines = kb_str.split("\n")
	var i = 0
	while i < len(lines):
		if lines[i].to_lower().begins_with("vocabulary"):
			var j = search_block_end(lines,i)
			vocabulary.create_from_string("\n".join(lines.slice(i,j+1)))
			i=j
		elif lines[i].to_lower().begins_with("structure"):
			var j = search_block_end(lines,i)
			structure.create_from_string("\n".join(lines.slice(i,j+1)))
			i=j
		elif lines[i].to_lower().begins_with("theory"):
			var j = search_block_end(lines,i)
			theory.create_from_string("\n".join(lines.slice(i,j+1)))
			i=j
		i+=1
	print(vocabulary.functions)
			
func search_block_end(lines: Array[String],idx: int):
	for j in range(idx,len(lines)):
		if lines[j].begins_with("}"):
			return j
			
func parse_to_idp() -> String:
	return "\n".join([vocabulary.parse_to_idp(),theory.parse_to_idp(),structure.parse_to_idp()])
	
