extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func execute():
	pass
	
func create_kb_from_file():
	pass
	
func create_kb_from_string():
	pass
	
func create_empty_kb() -> KnowlegdeBase: 
	return KnowlegdeBase.new()
