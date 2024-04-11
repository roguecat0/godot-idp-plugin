class_name Constant
extends Symbol

func add(_key: Variant,_val: Variant=true) -> void:
	push_error("can't add to constant/proposition, use set() to change value")
	
func set_value(val: Variant):
	interpretation.setd(val)
	
func unset_value():
	interpretation.unsetd()

func get_value(_k=0):
	return interpretation.getd()

func to_structure_line() -> String:
	if interpretation.is_constant:
		return "\t%s := %s." % [named,interpretation.getd()]
	return ""

func copy() -> Variant:
	return Constant.new(named,[],domain,interpretation)
		
func update(interpretation: Variant,_append=false):
	self.interpretation = interpretation

func _to_string() -> String:
	return "Constant(name: %s, input: %s, output: %s, val: %s)" % [
		named,domain,domain,interpretation.getd()
	]
