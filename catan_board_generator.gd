extends Control

var desert_center: bool = false
var distinct_neighbor_tile: bool = false
var distinct_neighbor_token: bool = false
var balance_probability: bool = false
var intersection_limit: bool = false
var kb: KnowlegdeBase
func _ready() -> void:
	setup()
	print(kb.parse_to_idp())
	# IDP.propagate(kb,false)
	# kb.update_kb_with_propagate()
	# IDP.model_expand(kb)

func setup() -> void: 
	kb = create_kb()
	# print(kb.parse_to_idp())

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
	# for q1 in Q.enums:
	# 	for r1 in R.enums:
	# 		for q2 in Q.enums:
	# 			for r2 in R.enums:
	# 				if q1 == q2 and r1 == r2:
	# 					continue
	# 				if abs(q1+r1)>2 or abs(q2+r2)>2:
	# 					continue
	# 				if abs((q1+r1)-(q2+r2))<2:
	# 					neighbour.add([q1,r1,q2,r2])
	var _token_pips = kb.add_function("token_pips",Token,Pips,
	{
		1:0, 2:1, 3:2, 4:3, 5:4, 6:5,
		7:0, 8:5, 9:4, 10:3, 11:2, 12:1,	
	})
	return kb

func fill_theory(kb: KnowlegdeBase) -> KnowlegdeBase:
	kb.formulas = []
	var Tile = kb.types.Tile
	var tile_type = kb.symbols.tile_type
	var tile_token = kb.symbols.tile_token
	var relevant_term = kb.symbols.relevant.apply(["q","r"])
	var relevant = kb.symbols.relevant
	var neighbour = kb.symbols.neighbour
	var token_pips = kb.symbols.token_pips
	var Q = kb.types.Q
	var R = kb.types.R
	var base_each1 = ForEach.create([["q"],["r"]],[Q,R],Bool.base_(true))
	var base_each2 = ForEach.create([["q1","q2"],["r1","r2"]],[Q,R],Bool.base_(true))
	# desert always has zero tokens
	var inner_rule = tile_token.apply(["q","r"]).eq(7).equivalent(
		tile_type.apply(["q","r"]).eq("desert")
	)
	# kb.add_formula(ForEach.create("q",Q,ForEach.create("r",R,inner_rule).any()).any())
	kb.add_formula(base_each1.copy().set_inner_expr(inner_rule).any())
	# set legal number of occurrence per tile type
	var tile_occurences = {"hills":3,"forest":4,"mountains":3,"fields":4,"pasture":4,"desert":1}
	for tile in tile_occurences.keys():
		var occurence = tile_occurences[tile]
		var occcount = base_each1.copy().set_inner_expr(tile_type.apply(["q","r"]).eq(tile)).count()
		kb.add_formula(occcount.eq(occurence))
	# set legal number of  occurance of tokens
	var token_oc = {
		2:1,3:2,4:2,5:2,6:2,7:1,
		8:2,9:2,10:2,11:2,12:1,
	}
	for tk in token_oc:
		var occ = token_oc[tk]
		var occcount = base_each1.copy().set_inner_expr(tile_token.apply(["q","r"]).eq(tk)).count()
		kb.add_formula(occcount.eq(occ))
	# filter out invalid coordinates
	var irrelevant_type = IDP.not_(relevant_term).equivalent(tile_type.apply(["q","r"]).eq("none"))
	var irrelevant_token = IDP.not_(relevant_term).equivalent(tile_token.apply(["q","r"]).eq(1))
	kb.add_formula(base_each1.copy().set_inner_expr(irrelevant_type).all())
	kb.add_formula(base_each1.copy().set_inner_expr(irrelevant_token).all())
	# define neighbors
	# var definition = []
	var neighbour_t = neighbour.apply(['q1','r1','q2','r2'])
	# var not_same = IDP.p_not(Integer.base_("q1").eq("q2").and_(Integer.base_("r1").eq("r2")))
	# var distance = IDP.parenth(Integer.base_('q1').sub('q2').add('r1').sub('r2'))
	# var relevant_cords = relevant.apply(['q1','r1']).and_(relevant.apply(['q2','r2']))
	# definition.append(base_each2.copy().set_inner_expr(neighbour_t.defines(not_same)).all())
	# definition.append(base_each2.copy().set_inner_expr(neighbour_t.defines(distance.between(-1,1,IDP.LTE,IDP.LTE))).all())
	# definition.append(base_each2.copy().set_inner_expr(neighbour_t.defines(relevant_cords)).all())
	var define_neighbors = " !q1, q2 in Q, r1, r2 in R: neighbour(q1, r1, q2, r2) <=> ~(q1 = q2 & r1 = r2) & -1 =< (q1 - q2) =< 1 & -1 =< (r1 - r2) =< 1 & relevant(q1, r1) & relevant(q2, r2)."
	kb.add_undefined_line(define_neighbors,IDP.THEORY)
	# kb.add_definition(definition)
	# neighbors not same type option
	if distinct_neighbor_tile:
		var different_tile_type = tile_type.apply(['q1','r1']).neq(tile_type.apply(['q2','r2']))
		kb.add_formula(base_each2.copy().set_inner_expr(neighbour_t.implies(different_tile_type)).all())
	# neighbors not same token option
	if distinct_neighbor_token:
		var different_token_type = tile_token.apply(['q1','r1']).neq(tile_token.apply(['q2','r2']))
		kb.add_formula(base_each2.copy().set_inner_expr(neighbour_t.implies(different_token_type)).all())
	# desert center option
	if desert_center:
		kb.add_formula(tile_type.apply([0,0]).eq("desert"))
	# limits intersection pips
	if intersection_limit:
		print("inter")
		var base_each3 = ForEach.create([['q1','q2','q3'],['r1','r2','r3']],[Q,R],Bool.base_(true)).all()
		var neighours3 = neighbour_t.and_(neighbour.apply(['q1','r1','q3','r3'])).and_(neighbour.apply(['q2','r2','q3','r3']))
		var tokencount = (token_pips.apply([tile_token.apply(['q1','r1'])])
			.add(token_pips.apply([tile_token.apply(['q2','r2'])]))
			.add(token_pips.apply([tile_token.apply(['q3','r3'])]))
			.lte(11)
		)
		kb.add_formula(base_each3.set_inner_expr(neighours3.implies(tokencount)))
	# create balanced board
	if balance_probability:
		print("balance")
		var tile_balance = {"hills":2,"forest":3,"mountains":2,"fields":3,"pasture":3}
		for tile in tile_balance.keys():
			var occ = tile_balance[tile]
			var inner_for = tile_type.apply(['q','r']).eq(tile).and_(token_pips.apply([tile_token.apply(['q','r'])]).lte(2))
			kb.add_formula(base_each1.copy().set_inner_expr(inner_for).count().lt(occ))
	return kb

func update_screen() -> void:
	pass


func _input(event: InputEvent) -> void:
	pass # Replace with function body.


func _on_generate() -> void:
	fill_theory(kb)
	IDP.model_expand(kb)
	$HexMap.set_tiles(kb.solutions[0].tile_type.interpretation)
	$HexMap.set_tokens(kb.solutions[0].tile_token.interpretation)


func _on_desert_center() -> void:
	desert_center =  !desert_center

func _on_neigbour_resource() -> void:
	distinct_neighbor_tile =  !distinct_neighbor_tile

func _on_neighbour_token() -> void:
	distinct_neighbor_token = !distinct_neighbor_token


func _on_balance_prob() -> void:
	balance_probability = !balance_probability


func _on_max_pips() -> void:
	intersection_limit = !intersection_limit
