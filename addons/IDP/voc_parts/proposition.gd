class_name Proposition
extends Constant

func copy() -> Variant:
	return Proposition.new(named,[],domain,interpretation)
