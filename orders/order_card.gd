extends Control

var id: int
signal remove(idx:int)

func setup(n:int,iron:int,wood:int,col: Color):
	id = n
	%ID.text = "Order: %d" % (n)
	%Iron.text = "Iron: %d" % iron
	%Wood.text = "Wood: %d" % wood
	$ColorRect.color = col


func _on_del_b_pressed() -> void:
	remove.emit(id) # Replace with function body.

func delivered() -> void:
	%Deliverd.visible = true
