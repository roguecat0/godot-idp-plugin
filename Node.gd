extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var kb: KnowlegdeBase = IDP.create_empty_kb() # Replace with function body.
	print(kb.do_something())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
