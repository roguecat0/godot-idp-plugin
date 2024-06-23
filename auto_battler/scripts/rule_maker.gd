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
	kb = init_kb()

func init_kb():
	var kb = IDP.create_empty_kb()
	var Unit: CustomType = kb.add_type("Unit", [], IDP.INT)
	var Color: CustomType = kb.add_type("Color", ["Red", "Blue", "Green"], IDP.STRING)

	var Action: CustomType = kb.add_type("Action", ["Farm", "Rest", "Fight"], IDP.STRING)

	var unitHealth: Function = kb.add_function("unitHealth", Unit,IDP.INT)
	var unitAge: Function = kb.add_function("unitAge", Unit,IDP.INT)
	var unitColor: Function = kb.add_function("unitColor", Unit, Color)
	# var unitStatus: Function = kb.add_function("unitStatus", Unit, Status)
	var unitAction: Function = kb.add_function("unitAction", Unit, Action)

	var food: Constant = kb.add_constant("food", IDP.INT)
	var units: Constant = kb.add_constant("units", IDP.INT)
	var time: Constant = kb.add_constant("time", IDP.INT)
	return kb

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
	
	print(exports)
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
		var build_action_assign = unitAction.apply("u").eq(rule_ex.action).rev_implies(rule_apply)
		for prev_rule in rules_apply:
			build_action_assign = build_action_assign.and_(prev_rule.not_())
		order_formulas.append(Quantifier.create("u", Unit, build_action_assign).all())
		rules_apply.append(rule_apply)
		print("did this ones")

	constraint_formulas.map(func(x): kb.add_formula(x))
	order_formulas.map(func(x): kb.add_formula(x))
	
func reset_ui():
	%Rules.get_children().map(func(x): x.queue_free())
		
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
	
