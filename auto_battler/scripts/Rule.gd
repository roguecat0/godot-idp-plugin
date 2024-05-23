extends Control

var kb: KnowlegdeBase
var complete: bool = false
var action
@export var constraint_scene: PackedScene


func setup(kb_):
	kb = kb_
	%Action.clear()
	for symbol in kb.types["Action"].enums:
		%Action.add_item(symbol)
	%Action.select(-1)

func _on_add_pressed():
	var constraint = constraint_scene.instantiate()
	constraint.setup(kb)
	%Constraints.add_child(constraint)
