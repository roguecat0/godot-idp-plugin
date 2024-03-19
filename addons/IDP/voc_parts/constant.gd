class_name Constant
extends Function

func add(key: Variant,val: Variant=true) -> void:
	push_error("can't add to constant/proposition, use set() to change value")
	
func set_val(val: Variant):
	interpretation.setd(val)
	
func unset_val():
	interpretation.unsetd()

func to_structure_line() -> String:
	if interpretation.is_constant:
		return "\t%s := %s." % [named,interpretation.getd()]
	return ""

func copy() -> Variant:
	return Constant.new(named,[],output_type,interpretation)
		
func update(interpretation: Variant,append=false):
	self.interpretation = interpretation

func _to_string() -> String:
	return "Constant(name: %s, input: %s, output: %s, val: %s)" % [
		named,input_types,output_type,interpretation.getd()
	]
