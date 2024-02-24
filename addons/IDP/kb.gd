class_name KnowlegdeBase
extends Node

var vocabulary: Vocabulary = Vocabulary.new()
var structure: Structure = Structure.new()
var theory: Theory = Theory.new()
# TODO: figure out whether to add functionality for adding multiple of the same block type in a kb
# TODO: figure out if and where to implement a parser class
# TODO: add general preparser to clean text beforehand

func do_something() -> String:
	return "lol"
	
func create_from_string(kb_str: String) -> void:
	var lines: PackedStringArray = kb_str.split("\n")
	var i: int = 0
	var j: int = 0
	while i < len(lines):
		if lines[i].to_lower().begins_with("vocabulary"):
			j = search_block_end(lines,i)
			vocabulary.create_from_string("\n".join(lines.slice(i,j+1)))
			i=j
		elif lines[i].to_lower().begins_with("structure"):
			j = search_block_end(lines,i)
			structure.create_from_string("\n".join(lines.slice(i,j+1)))
			i=j
		elif lines[i].to_lower().begins_with("theory"):
			j = search_block_end(lines,i)
			theory.create_from_string("\n".join(lines.slice(i,j+1)))
			i=j
		i+=1
			
func search_block_end(lines: Array[String],idx: int) -> int:
	for j: int in range(idx,len(lines)):
		if lines[j].begins_with("}"):
			return j
	return idx
			
func parse_to_idp() -> String:
	return "\n".join([vocabulary.parse_to_idp(),theory.parse_to_idp(),structure.parse_to_idp()])
	
func add_line_to_vocabulary(line: String) -> int:
	return vocabulary.add_line(line)
	
func add_line_to_theory(line: String) -> int:
	return theory.add_line(line)
	
func add_line_to_structure(line: String) -> int:
	return structure.add_line(line)
