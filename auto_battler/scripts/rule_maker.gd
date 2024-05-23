extends Control


var kb: KnowlegdeBase

@export var rule_scene: PackedScene

var constraint_match = {
	"above":IDP.GTE,
	"below":IDP.LTE,
	"is":IDP.EQ,
	"is_not":IDP.NEQ,
}

signal player_config(kb_)

func _ready() -> void:
	init_kb()

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

	# var rule1: Predicate = kb.add_predicate("rule1", Unit)
	# var rule2: Predicate = kb.add_predicate("rule2", Unit)
	# var rule3: Predicate = kb.add_predicate("rule3", Unit)
	#
	# var test_term = unitHealth.apply("u").lt(5).equivalent(rule1.apply("u"))
	# var test_term2 = unitColor.apply("u").eq("Green").equivalent(rule2.apply("u"))
	# var test_term3 = unitColor.apply("u").eq("Red").equivalent(rule3.apply("u"))

	# var assignemnt_term = Quantifier.create("u", Unit, test_term).all()
	# var assignemnt_term2 = Quantifier.create("u", Unit, test_term2).all()
	# var assignemnt_term3 = Quantifier.create("u", Unit, test_term3).all()
	# kb.add_formula(assignemnt_term)
	# kb.add_formula(assignemnt_term2)
	# kb.add_formula(assignemnt_term3)
	#
	# kb.add_formula(Quantifier.create("u", Unit, rule1.apply("u").equivalent(unitAction.apply("u").eq("Rest"))))
	# kb.add_formula(Quantifier.create("u", Unit, rule1.apply("u").not_().and_(rule2.apply("u")).equivalent(unitAction.apply("u").eq("Farm"))))
	# kb.add_formula(Quantifier.create("u", Unit, rule1.apply("u").not_().and_(rule2.apply("u").not_()).and_(rule3.apply("u")).equivalent(unitAction.apply("u").eq("Fight"))))

	# print(kb.parse_to_idp())


func _on_add_rule_pressed() -> void:
	var rule = rule_scene.instantiate()
	rule.setup(kb)
	%Rules.add_child(rule)
	rule.move.connect(move_rule)

func move_rule(idx, dir):
	var node = %Rules.get_child(idx)
	var new_idx = clampi(idx+dir, 0,len(%Rules.get_children())-1)
	print("moving %d to %d" % [idx, new_idx])
	%Rules.move_child(node,new_idx)

func _on_game_pressed() -> void:
	var rules = %Rules.get_children()
	var exports = rules.map(func(x): return x.export())
	if len(exports.filter(func(x): return x.complete)) == 0:
		return
	fill_kb(exports)
	print(kb.parse_to_idp())
	player_config.emit(kb)

func fill_kb(exports):
	kb.formulas = []
	var Unit: CustomType = kb.types.Unit
	var unitAction: Function = kb.symbols.unitAction
	var rules_apply = []
	var constraint_formulas = []
	var order_formulas = []
	for r in len(exports):
		var rule_ex = exports[r]
		var rule = kb.add_predicate("rule_%d" % r,Unit)
		var rule_apply = rule.apply("u")
		var build_constraint = rule_apply.equivalent(true)
		print("rule_%d: " % r, rule_ex.constraints)
		for constraint in rule_ex.constraints:
			var category_apply = constraint.category
			if category_apply is Constant:
				category_apply = category_apply.apply()
			else:
				category_apply = category_apply.apply("u")
			build_constraint = build_constraint.and_(
				type_builder_match(category_apply,constraint.type,constraint.value)
			)
		constraint_formulas.append(Quantifier.create("u", Unit, build_constraint).all())
		var build_action_assign = unitAction.apply("u").eq(rule_ex.action).equivalent(rule_apply)
		for prev_rule in rules_apply:
			build_action_assign = build_action_assign.and_(prev_rule.not_())
		order_formulas.append(Quantifier.create("u", Unit, build_action_assign).all())
		rules_apply.append(rule_apply)
		print("did this ones")

	constraint_formulas.map(func(x): kb.add_formula(x))
	order_formulas.map(func(x): kb.add_formula(x))
		

			
			
			
func type_builder_match(term, type_name, other):
	match type_name:
		"is":
			return term.eq(other)
		"is_not":
			return term.neq(other)
		"above":
			return term.gte(other)
		"below":
			return term.lte(other)
		_:
			assert(false,type_name+ " is not a reconigize type name")
	
