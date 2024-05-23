extends Control

var kb: KnowlegdeBase
var complete: bool = false
var action = null
static var max_id = 0
var id
@export var constraint_scene: PackedScene

signal move(id, dir)

func next_id():
	max_id += 1
	return max_id

func setup(kb_):
	kb = kb_
	id = next_id()
	%Action.clear()
	for symbol in kb.types["Action"].enums:
		%Action.add_item(symbol)
	%Action.select(-1)

	var constraint = constraint_scene.instantiate()
	constraint.setup(kb)
	%Constraints.add_child(constraint)

func _on_add_pressed():
	var constraint = constraint_scene.instantiate()
	constraint.setup(kb)
	%Constraints.add_child(constraint)



func _on_down_pressed() -> void:
	move.emit(get_index(),1)

func _on_up_pressed() -> void:
	move.emit(get_index(),-1)


func _on_del_pressed() -> void:
	queue_free()



func _on_action_item_selected(index:int) -> void:
	action = %Action.get_item_text(index)

func export() -> Dictionary:
	var constraints = %Constraints.get_children().filter(func(x): return x.complete)
	return {
		"action": action,
		"constraints": constraints.map(func(x): return x.export()),
		"complete": len(constraints) > 0 and action != null,
	}

