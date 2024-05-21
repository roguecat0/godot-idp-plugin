extends Control

var kb: KnowlegdeBase
@export var order_card_scene: PackedScene
@export var order_block_scene: PackedScene
var colors: Dictionary

func _ready() -> void:
	#TODO: add remove method for functions
	#TODO: maybe try to create a popup window with the idp and error code because console debuggins sucks
	#TODO: add a solved and unsolved state implementation
	setup()
	kb.solved = false
	update_screen()
	
func setup():
	kb = IDP.create_empty_kb()
	get_color(3)
	var num_orderse = 3
	var Orders := kb.add_type("Orders",Array(range(num_orderse)),IDP.INT)
	var maxIron : Constant = kb.add_constant("maxIron",IDP.INT,5)
	var maxWood : Constant = kb.add_constant("maxWood",IDP.INT,5)

	var numDeliveries : Constant = kb.add_constant("numDeliveries",IDP.INT)
	var deliveries :Predicate = kb.add_predicate("deliveries",Orders)
	
	var ironOrder : Symbol= kb.add_function("ironOrder",Orders,IDP.INT)
	var woodOrder : Symbol= kb.add_function("woodOrder",Orders,IDP.INT)
	var req_iron := [4,1,1]
	var req_wood := [2,1,4]
	for i in range(num_orderse):
		ironOrder.add(i,req_iron[i])
		woodOrder.add(i,req_wood[i])
		
	# rules
	var each_deliveries = Quantifier.create("o",Orders,deliveries.apply("o"))
	kb.add_formula(numDeliveries.apply().eq(each_deliveries.count()))
	kb.add_formula(maxIron.apply().gte(each_deliveries.sum(ironOrder.apply("o"))))
	kb.add_formula(maxWood.apply().gte(each_deliveries.sum(woodOrder.apply("o"))))
	
	
func solve():
	IDP.maximize(kb,"numDeliveries()")


func _on_solve_b_pressed() -> void:
	solve() # Replace with function body.
	update_screen()
	
func update_screen() -> void:
	get_tree().call_group("order_card","queue_free")
	get_tree().call_group("order_blocks","queue_free")
	
	for order in kb.types.Orders.enums:
		var n_iron = kb.symbols.ironOrder.get_value(order)
		var n_wood = kb.symbols.woodOrder.get_value(order)
		var card = order_card_scene.instantiate()
		card.setup(order,n_iron,n_wood,get_color(order))
		card.remove.connect(remove_card)
		%OrderCards.add_child(card)
		if kb.solved and kb.solutions[0].deliveries.has(order):
			card.delivered()
		
	%LMaxIron.text = "max iron: %d" % kb.symbols.maxIron.get_value()
	%LMaxWood.text = "max wood: %d" % kb.symbols.maxWood.get_value()
	%CountDeliveries.text = "Deliveries"
	
	if kb.solved:
		%CountDeliveries.text = "Delivered: %d" % len(kb.solutions[0].deliveries.inter_keys())
		for order in kb.solutions[0].deliveries.inter_keys():
			var n_iron = kb.symbols.ironOrder.get_value(order)
			var n_wood = kb.symbols.woodOrder.get_value(order)
			
			for i in n_iron:
				var block = order_block_scene.instantiate()
				block.color = get_color(order)
				%IronBlocks.add_child(block)
			for i in n_wood:
				var block = order_block_scene.instantiate()
				block.color = get_color(order)
				%WoodBlocks.add_child(block)
			
	
		
func remove_card(id:int):
	print(id, " :removed")
	kb.types.Orders.enums.erase(id)
	kb.symbols.ironOrder.remove(id)
	kb.symbols.woodOrder.remove(id)
	kb.solved = false
	update_screen()


func _on_reset_b_pressed() -> void:
	setup() # Replace with function body.
	kb.solved = false
	update_screen()


func _on_set_max_iron_pressed() -> void:
	if not %InMaxIron.text.is_valid_int():
		print("not an integer")
		return
	kb.symbols.maxIron.set_value(int(%InMaxIron.text))
	kb.solved = false
	update_screen()


func _on_set_max_wood_pressed() -> void:
	if not %InMaxWood.text.is_valid_int():
		print("not an integer")
		return
	kb.symbols.maxWood.set_value(int(%InMaxWood.text))
	kb.solved = false
	update_screen()


func _onadd_card_pressed() -> void:
	if not %AddIron.text.is_valid_int():
		print("iron not an integer")
		return
	if not %AddWood.text.is_valid_int():
		print("wood not an integer")
		return
	var idx = kb.types.Orders.enums.max()+1
	kb.types.Orders.enums.append(idx)
	kb.symbols.ironOrder.add(idx,int(%AddIron.text))
	kb.symbols.woodOrder.add(idx,int(%AddWood.text))
	kb.solved = false
	update_screen()
	
func get_color(id:int):
	if colors.has(id):
		return colors[id]
	var rgb = randi() | 255
	var c = Color.hex(rgb).darkened(0.2)
	colors[id] = c
	return c
