extends Control

var desert_center: bool = true
var distinct_neighbor_tile: bool = true
var distinct_neighbor_token: bool = true
var balance_probability: bool = true
var intersection_limit: bool = true
func _ready() -> void:
	setup()

func setup() -> void: 
	var kb = create_kb()
	kb = fill_theory(kb)
	print(kb.parse_to_idp())

func create_kb() -> KnowlegdeBase:
	var kb = IDP.create_empty_kb()
	# types
	var Q = kb.add_type("Q",range(-2,3),IDP.INT)
	var R = kb.add_type("R",range(-2,3),IDP.INT)
	var Tile = kb.add_type("Tile", ["hills","forest","mountains","fields","pasture","desert","none"])
	var Token = kb.add_type("Token",range(1,13),IDP.INT)
	var Pips = kb.add_type("Pips",range(0,6),IDP.INT)
	# functions	
	var _tile_type = kb.add_function("tile_type",[Q,R],Tile)
	var _tile_token = kb.add_function("tile_token",[Q,R],Token)
	var relevant = kb.add_predicate("relevant",[Q,R])
	for q in Q.enums:
		for r in R.enums:
			if abs(q+r)<3:
				relevant.add([q,r])

	var neighbour = kb.add_predicate("neighbour",[Q,R,Q,R])
	for q1 in Q.enums:
		for r1 in R.enums:
			for q2 in Q.enums:
				for r2 in R.enums:
					if q1 == q2 and r1 == r2:
						continue
					if abs(q1+r1)>2 or abs(q2+r2)>2:
						continue
					if abs((q1+r1)-(q2+r2))<2:
						neighbour.add([q1,r1,q2,r2])
	var _token_pips = kb.add_function("token_pips",Token,Pips,
	{
		1:0, 2:1, 3:2, 4:3, 5:4, 6:5,
		7:0, 8:5, 9:4, 10:3, 11:2, 12:1,	
	})
	return kb

func fill_theory(kb: KnowlegdeBase) -> KnowlegdeBase:
	kb.formulas = []
	var Tile = kb.types.Tile
	var tile_type = kb.functions.tile_type
	var tile_token = kb.functions.tile_token
	var relevant_term = kb.functions.relevant.to_term(["q","r"])
	var relevant = kb.functions.relevant
	var neighbour = kb.functions.neighbour
	var token_pips = kb.functions.token_pips
	var Q = kb.types.Q
	var R = kb.types.R
	var base_each1 = ForEach.create([["q"],["r"]],[Q,R],Bool.new_base(true))
	var base_each2 = ForEach.create([["q1","q2"],["r1","r2"]],[Q,R],Bool.new_base(true))
	# desert always has zero tokens
	var inner_rule = tile_token.to_term(["q","r"])._eq(7)._equivalent(
		tile_type.to_term(["q","r"])._eq("desert")
	)
	# kb.add_term(ForEach.create("q",Q,ForEach.create("r",R,inner_rule)._any())._any())
	kb.add_term(base_each1.copy().set_inner_expr(inner_rule)._any())
	# set legal number of occurrence per tile type
	var tile_occurences = {"hills":3,"forest":4,"mountains":3,"fields":4,"pasture":4,"desert":1}
	for tile in tile_occurences.keys():
		var occurence = tile_occurences[tile]
		var occ_count = base_each1.copy().set_inner_expr(tile_type.to_term(["q","r"])._eq(tile))._count()
		kb.add_term(occ_count._eq(occurence))
	# set legal number of  occurance of tokens
	var token_oc = {
		2:1,3:2,4:2,5:2,6:2,7:1,
		8:2,9:2,10:2,11:2,12:1,
	}
	for tk in token_oc:
		var occ = token_oc[tk]
		var occ_count = base_each1.copy().set_inner_expr(tile_token.to_term(["q","r"])._eq(tk))._count()
		kb.add_term(occ_count._eq(occ))
	# filter out invalid coordinates
	var irrelevant_type = IDP._not(relevant_term)._equivalent(tile_type.to_term(["q","r"])._eq("none"))
	var irrelevant_token = IDP._not(relevant_term)._equivalent(tile_token.to_term(["q","r"])._eq(1))
	kb.add_term(base_each1.copy().set_inner_expr(irrelevant_type)._all())
	kb.add_term(base_each1.copy().set_inner_expr(irrelevant_token)._all())
	# define neighbors
	var definition = []
	var neighbour_t = neighbour.to_term(['q1','r1','q2','r2'])
	var not_same = IDP._p_not(Integer.new_base("q1")._eq("q2")._and(Integer.new_base("r1")._eq("r2")))
	var distance = IDP._parenth(Integer.new_base('q1')._sub('q2')._add('r1')._sub('r2'))
	var relevant_cords = relevant.to_term(['q1','r1'])._and(relevant.to_term(['q2','r2']))
	definition.append(base_each2.copy().set_inner_expr(neighbour_t._defines(not_same))._all())
	definition.append(base_each2.copy().set_inner_expr(neighbour_t._defines(distance._between(-1,1,IDP.LTE,IDP.LTE)))._all())
	definition.append(base_each2.copy().set_inner_expr(neighbour_t._defines(relevant_cords))._all())
	kb.add_definition(definition)
	# neighbors not same type option
	if distinct_neighbor_tile:
		var different_tile_type = tile_type.to_term(['q1','r1'])._neq(tile_type.to_term(['q2','r2']))
		kb.add_term(base_each2.copy().set_inner_expr(neighbour_t._implies(different_tile_type))._all())
	if distinct_neighbor_tile:
		var different_token_type = tile_token.to_term(['q1','r1'])._neq(tile_token.to_term(['q2','r2']))
		kb.add_term(base_each2.copy().set_inner_expr(neighbour_t._implies(different_token_type))._all())
	# desert center option
	if desert_center:
		kb.add_term(tile_type.to_term([0,0])._eq("desert"))
	if intersection_limit:
		var base_each3 = ForEach.create([['q1','q2','q3'],['r1','r2','r3']],[Q,R],Bool.new_base(true))._all()
		var neighours3 = neighbour_t._and(neighbour.to_term(['q1','r1','q3','r3']))._and(neighbour.to_term(['q2','r2','q3','r3']))
		var token_count = (token_pips.to_term([tile_token.to_term(['q1','r1'])])
			._add(token_pips.to_term([tile_token.to_term(['q2','r2'])]))
			._add(token_pips.to_term([tile_token.to_term(['q3','r3'])]))
			._lte(11)
		)
		kb.add_term(base_each3.set_inner_expr(neighours3._implies(token_count)))
	if balance_probability:
		var tile_balance = {"hills":2,"forest":3,"mountains":2,"fields":3,"pasture":3}
		for tile in tile_balance.keys():
			var occ = tile_balance[tile]
			var inner_for = tile_type.to_term(['q','r'])._eq(tile)._and(token_pips.to_term([tile_token.to_term(['q','r'])])._lte(2))
			kb.add_term(base_each1.copy().set_inner_expr(inner_for)._count()._lt(occ))
	return kb

func update_screen() -> void:
	pass
