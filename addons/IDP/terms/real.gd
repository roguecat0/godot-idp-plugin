class_name Real
extends ArithTerm

static func new_base(base_a) -> Real:
	return Real.new(
		str(base_a),[],IDP.BASE
	)
