class_name Real
extends ArithTerm

static func base_(base_a) -> Real:
	return Real.new(
		str(base_a),[],IDP.BASE
	)

static func create(base_a) -> Real:
	return Real.new(
		str(base_a),[],IDP.BASE
	)
