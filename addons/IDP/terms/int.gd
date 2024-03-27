class_name Integer
extends ArithTerm

static func new_base(base_a) -> Integer:
	return Integer.new(
		str(base_a),[],IDP.BASE
	)

static func create(base_a) -> Integer:
	return Integer.new(
		str(base_a),[],IDP.BASE
	)
