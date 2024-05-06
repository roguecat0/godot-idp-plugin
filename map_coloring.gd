extends Node

func _ready() -> void:
	var kb = IDP.create_empty_kb()

	# initialize types
	# var countries = [
	# 	"Albania", "Austria", "Belarus", "Belgium", "Bosnia_and_Herzegovina", "Bulgaria", "Croatia", "Czechia", 
	# 	"Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Italy", 
	# 	"Kosovo", "Latvia", "Lithuania", "Luxembourg", "Netherlands", "Norway", "Macedonia", "Montenegro", "Moldova", 
	# 	"Poland", "Portugal", "Romania", "Russia", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Ukraine", "UK"
	# ]
	var countries = ["Belgium", "Germany", "France"]
	var country = kb.add_type("country", countries, IDP.STRING)
	var color = kb.add_type("color", ["Red", "Blue", "Green", "Yellow"], IDP.STRING)

	# add symbols
	var Bordering = kb.add_predicate("Bordering", [country, "country"])
	var ColourOf = kb.add_function("ColourOf", country, color)

	# fill in interpretation
	# var border_data = [["Albania", "Greece"], ["Albania", "Macedonia"], ["Albania", "Montenegro"], ["Albania", "Kosovo"], ["Austria", "Slovenia"], ["Austria", "Italy"], ["Austria", "Switzerland"], ["Austria", "Germany"], ["Austria", "Czechia"], ["Austria", "Slovakia"], ["Austria", "Hungary"], ["Belarus", "Ukraine"], ["Belarus", "Poland"], ["Belarus", "Lithuania"], ["Belarus", "Latvia"], ["Belarus", "Russia"], ["Belgium", "Netherlands"], ["Belgium", "Germany"], ["Belgium", "Luxembourg"], ["Belgium", "France"], ["Bosnia_and_Herzegovina", "Croatia"], ["Bosnia_and_Herzegovina", "Serbia"], ["Bosnia_and_Herzegovina", "Montenegro"], ["Bulgaria", "Romania"], ["Bulgaria", "Greece"], ["Bulgaria", "Macedonia"], ["Bulgaria", "Serbia"], ["Croatia", "Slovenia"], ["Croatia", "Hungary"], ["Croatia", "Serbia"], ["Croatia", "Bosnia_and_Herzegovina"], ["Czechia", "Poland"], ["Czechia", "Slovakia"], ["Czechia", "Austria"], ["Czechia", "Germany"], ["Denmark", "Germany"], ["Estonia", "Russia"], ["Estonia", "Latvia"], ["Finland", "Norway"], ["Finland", "Sweden"], ["Finland", "Russia"], ["France", "Belgium"], ["France", "Luxembourg"], ["France", "Germany"], ["France", "Switzerland"], ["France", "Italy"], ["France", "Spain"], ["Germany", "Denmark"], ["Germany", "Poland"], ["Germany", "Czechia"], ["Germany", "Austria"], ["Germany", "Switzerland"], ["Germany", "France"], ["Germany", "Luxembourg"], ["Germany", "Belgium"], ["Germany", "Netherlands"], ["Greece", "Albania"], ["Greece", "Macedonia"], ["Greece", "Bulgaria"], ["Hungary", "Slovakia"], ["Hungary", "Ukraine"], ["Hungary", "Romania"], ["Hungary", "Serbia"], ["Hungary", "Croatia"], ["Hungary", "Slovenia"], ["Hungary", "Austria"], ["Ireland", "UK"], ["Italy", "France"], ["Italy", "Switzerland"], ["Italy", "Austria"], ["Italy", "Slovenia"], ["Kosovo", "Serbia"], ["Kosovo", "Macedonia"], ["Kosovo", "Albania"], ["Kosovo", "Montenegro"], ["Latvia", "Estonia"], ["Latvia", "Russia"], ["Latvia", "Belarus"], ["Latvia", "Lithuania"], ["Lithuania", "Latvia"], ["Lithuania", "Belarus"], ["Lithuania", "Poland"], ["Lithuania", "Russia"], ["Luxembourg", "Belgium"], ["Luxembourg", "Germany"], ["Luxembourg", "France"], ["Netherlands", "Germany"], ["Netherlands", "Belgium"], ["Norway", "Sweden"], ["Norway", "Finland"], ["Macedonia", "Kosovo"], ["Macedonia", "Serbia"], ["Macedonia", "Bulgaria"], ["Macedonia", "Greece"], ["Macedonia", "Albania"], ["Montenegro", "Croatia"], ["Montenegro", "Bosnia_and_Herzegovina"], ["Montenegro", "Serbia"], ["Montenegro", "Kosovo"], ["Montenegro", "Albania"], ["Poland", "Russia"], ["Poland", "Lithuania"], ["Poland", "Belarus"], ["Poland", "Ukraine"], ["Poland", "Slovakia"], ["Poland", "Czechia"], ["Poland", "Germany"], ["Portugal", "Spain"], ["Romania", "Ukraine"], ["Romania", "Moldova"], ["Romania", "Bulgaria"], ["Romania", "Serbia"], ["Romania", "Hungary"], ["Russia", "Norway"], ["Russia", "Finland"], ["Russia", "Estonia"], ["Russia", "Latvia"], ["Russia", "Belarus"], ["Russia", "Ukraine"], ["Serbia", "Hungary"], ["Serbia", "Romania"], ["Serbia", "Bulgaria"], ["Serbia", "Macedonia"], ["Serbia", "Kosovo"], ["Serbia", "Montenegro"], ["Serbia", "Bosnia_and_Herzegovina"], ["Serbia", "Croatia"], ["Slovakia", "Poland"], ["Slovakia", "Ukraine"], ["Slovakia", "Hungary"], ["Slovakia", "Austria"], ["Slovakia", "Czechia"], ["Slovenia", "Austria"], ["Slovenia", "Hungary"], ["Slovenia", "Croatia"], ["Slovenia", "Italy"], ["Spain", "Portugal"], ["Spain", "France"], ["Sweden", "Norway"], ["Sweden", "Finland"], ["Switzerland", "Germany"], ["Switzerland", "Austria"], ["Switzerland", "Italy"], ["Switzerland", "France"], ["Ukraine", "Belarus"], ["Ukraine", "Moldova"], ["Ukraine", "Russia"], ["Ukraine", "Hungary"], ["Ukraine", "Slovakia"], ["Ukraine", "Poland"], ["UK", "Ireland"]]
	var border_data = [["Belgium", "France"], ["Belgium", "Germany"], ["Germany", "France"]]
	for border in border_data:
		Bordering.add(border)

	# add formulas
	
	# Belguim is red
	var belgium_colour = ColourOf.apply("Belgium")
	var belgium_eq_red = belgium_colour.eq("Red")
	kb.add_formula(belgium_eq_red)

	# # France and belguim have different colors
	# var belgium_colour = ColourOf.apply("Belgium")
	# var luxembourg_colour = ColourOf.apply("Luxembourg")
	# kb.add_formula(belgium_colour.neq(luxembourg_colour))

	# # every country bordering Germany is Green
	# var country_bordering_germany = Bordering.apply(["c", "Germany"])
	# var counrty_color_is_green = ColourOf.apply("c").eq("Green")
	# var if_bordering_then_green = country_bordering_germany.implies(counrty_color_is_green)
	# var each_bordering_germany = ForEach.create("c", country, counrty_bordering_germany_is_green)
	# kb.add_formula(each_bordering_germany.all())

	# # bordering countries have different colors
	# var bordering_countries = Bordering.apply(["c1", "c2"])
	# var different_colors = ColourOf.apply("c1").neq(ColourOf.apply("c2"))
	# var each_country_pair = ForEach.create(["c1","c2"],country, bordering_countries.implies(different_colors))
	# kb.add_formula(each_country_pair.all())


	# IDP.model_expand(kb,1)
	# for sol in kb.solutions[0]:
	# 	print(sol)

	# IDP.propagate(kb,true)
	# print(kb.positive_propagates)
	# print(kb.negative_propagates)

	var countries_red = kb.add_constant("countries_red", IDP.INT)
	kb.add_formula(ForEach.create("c", country, ColourOf.apply("c").eq("Red")).count().eq(countries_red.apply()))
	IDP.maximize(kb, "countries_red()")
	for sol in kb.solutions[0]:
		print(sol)
	
	
	

