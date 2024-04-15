class_name Function
extends Symbol

var partially_interpreted: bool = false

func _init(named: String, domain_: Variant, range_: Variant, interpretation: SymbolInterpretation, partially_interpreted_) -> void:
	super(named,domain_,range_,interpretation)
	partially_interpreted = partially_interpreted_

func set_default(val):
	interpretation.setd(val)
	
func unset_default():
	interpretation.unset()

func to_structure_line() -> String:
	var tmp = super()
	print(tmp)
	if partially_interpreted:
		print("clean partial")
		return tmp.replace(":=", ">>")
	if not interpretation.function_with_default:
		print("no defaults")
	if interpretation.interpreted:
		print("interpreded")
		print(domain_size, ", domain :::: ", len(get_interpretation().keys()) )
	if interpretation.interpreted and not interpretation.function_with_default and domain_size > len(get_interpretation().keys()):
		print("error instance")
		var error_msg = """interpretation %s, does not cover full domain of function %s(%s)""" % [get_interpretation(),named,domain]
		if IDP.force_partial_interpretation:
			print("forced partial")
			var extra = "\nfunction will be forcefully partially interprated, stop this behavior disable_forcefull_partial_interpretation()"
			error_msg += extra
		push_warning(error_msg)
		if IDP.force_partial_interpretation:
			return tmp.replace(":=", ">>")
	return tmp
