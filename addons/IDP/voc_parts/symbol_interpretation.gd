class_name SymbolInterpretation
extends Node

var named: String
var interpretation: Dictionary
var default: Variant
var value: Variant:
	get:
		if not interpreted:
			return null
		if is_constant:
			return default
		return interpretation

var interpreted: bool:
	get: return interpretation != {null:null} or default != null
var is_constant: bool:
	get: return interpretation == {null:null} and default != null
var function_with_default: bool:
	get: return interpretation != {null:null} and default != null
	
	
	
func _init(named,interpretation,default) -> void:
	self.named = named
	self.interpretation = interpretation
	self.default = default

func add(key: Variant,val: Variant=true) -> void:
	#TODO: check if same size
	if interpretation == {null:null}:
		interpretation = {key:val}
	interpretation[key] = val

func remove(key: Variant) -> bool:
	return interpretation.erase(key)

func geti(key):
	return interpretation[key]
	
func getd():
	return default
	
func has(key):
	return interpretation.has(key)

func seti(interpretation: Dictionary):
	self.interpretation = interpretation
	
func setd(default: Variant):
	self.default = default
	
func unseti():
	interpretation = {null:null}
	
func unsetd():
	default = null
	
func unset():
	interpretation = {null:null}
	default = null
	
func mergei(other: SymbolInterpretation):
	other.inter_keys().map(func(k): interpretation[k] = other.interpretation[k])
	
func copy():
	return SymbolInterpretation.new(
		named,interpretation.duplicate(),default
	)

func inter_keys():
	return interpretation.keys()

func _to_string() -> String:
	return "intr(name: %s, arr: %s, default: %s)" % [named,interpretation,default]
