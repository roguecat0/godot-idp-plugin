class_name Constant
extends Function

var val: Variant

func _init(n: String, out_type: Variant, val: Variant = null) -> void:
	super(n,[],out_type,{})
	self.val = val

func add(key: Variant,val: Variant=true) -> void:
	push_error("can't add to constant/proposition, use set() to change value")
	
func set_val(val: Variant):
	self.val = val
	
func unset_val():
	val = null

func to_structure_line() -> String:
	if val != null:
		return "\t%s := %s." % [named,str(val)]
	return ""

func copy() -> Variant:
	if self is Proposition:
		return Proposition.new(named,val)
	else:
		return Constant.new(named,output_type,val)
		
func update(val: Variant,append=false):
	set_val(val)

func _to_string() -> String:
	return "Constant(name: %s, input: %s, output: %s, val: %s)" % [
		named,input_types,output_type,val
	]
