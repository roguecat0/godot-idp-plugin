extends Control


var kb: KnowlegdeBase

func _ready() -> void:
	init_kb()
	$Constraint.setup(kb)

func init_kb():
	kb = IDP.create_empty_kb()
	var Unit: CustomType = kb.add_type("Unit", [], IDP.INT)
	var Color: CustomType = kb.add_type("Color", ["Red", "Blue", "Green"], IDP.STRING)
	# var Status: CustomType = kb.add_type("Status", ["Normal", "Sick"], IDP.STRING)
	var Action: CustomType = kb.add_type("Action", ["Farm", "Rest", "Fight"], IDP.STRING)

	var unitHealth: Function = kb.add_function("unitHealth", Unit,IDP.INT)
	var unitAge: Function = kb.add_function("unitAge", Unit,IDP.INT)
	var unitColor: Function = kb.add_function("unitColor", Unit, Color)
	# var unitStatus: Function = kb.add_function("unitStatus", Unit, Status)
	var unitAction: Function = kb.add_function("unitAction", Unit, Action)

	var food: Constant = kb.add_constant("food", IDP.INT)
	var units: Constant = kb.add_constant("units", IDP.INT)
	var time: Constant = kb.add_constant("time", IDP.INT)

	var rule1: Predicate = kb.add_predicate("rule1", Unit)
	var rule2: Predicate = kb.add_predicate("rule2", Unit)
	var rule3: Predicate = kb.add_predicate("rule3", Unit)

	var test_term = unitHealth.apply("u").lt(5).equivalent(rule1.apply("u"))
	var test_term2 = unitColor.apply("u").eq("Green").equivalent(rule2.apply("u"))
	var test_term3 = unitColor.apply("u").eq("Red").equivalent(rule3.apply("u"))

	var assignemnt_term = Quantifier.create("u", Unit, test_term).all()
	var assignemnt_term2 = Quantifier.create("u", Unit, test_term2).all()
	var assignemnt_term3 = Quantifier.create("u", Unit, test_term3).all()
	kb.add_formula(assignemnt_term)
	kb.add_formula(assignemnt_term2)
	kb.add_formula(assignemnt_term3)

	kb.add_formula(Quantifier.create("u", Unit, rule1.apply("u").equivalent(unitAction.apply("u").eq("Rest"))))
	kb.add_formula(Quantifier.create("u", Unit, rule1.apply("u").not_().and_(rule2.apply("u")).equivalent(unitAction.apply("u").eq("Farm"))))
	kb.add_formula(Quantifier.create("u", Unit, rule1.apply("u").not_().and_(rule2.apply("u").not_()).and_(rule3.apply("u")).equivalent(unitAction.apply("u").eq("Fight"))))

	print(kb.parse_to_idp())
