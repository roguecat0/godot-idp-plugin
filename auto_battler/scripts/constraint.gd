extends Control

var kb: KnowlegdeBase
var category
var value
var complete: bool = false

func _init() -> void:
	pass

func setup(kb_: KnowlegdeBase):
	kb = kb_
	%Categorie.clear()
	for symbol in kb.symbols:
		if symbol == "unitAction" or "rule" in symbol:
			continue
		%Categorie.add_item(symbol)
	complete = false
		


func _on_categorie_item_selected(index:int) -> void:
	if index == -1:
		return
	%Type.clear()
	%Values.clear()
	%Values.visible = true
	%SliderValue.visible = false
	var symbol_name = %Categorie.get_item_text(index)
	category = kb.symbols[symbol_name]
	print(category.range_base)
	match category.range_base:
		IDP.INT:
			%Type.add_item("above")
			%Type.add_item("below")
		IDP.STRING:
			%Type.add_item("is")
			%Type.add_item("is_not")
		_:
			assert(false, "(%d) is not in any implemented type" % category.range_base)
	%Type.select(-1)
	%Values.select(-1)
	complete = false
			

func _on_type_item_selected(index: int) -> void:
	if index == -1:
		return

	%Values.clear()
	var type_name = %Type.get_item_text(index)

	if "is" in type_name:
		%Values.visible = true
		%SliderValue.visible = false
		print(category.range_)
		for val in kb.types[category.range_].enums:
			print(val)
			%Values.add_item(val)
	else:
		%Values.visible = false
		%SliderValue.visible = true
	%Values.select(-1)
	complete = false



func _on_values_item_selected(index):
	if index == -1:
		return
	value = %Values.get_item_text(index)
	complete = true


func _on_slider_value_value_changed(value):
	print("hello you %d", value)
	self.value = value
	complete = true


func _on_delete_pressed():
	queue_free()
