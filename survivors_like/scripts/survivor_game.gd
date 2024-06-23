extends Node2D

const GREEN_SLIME = preload("res://survivors_like/scenes/green_slime.tscn")
const RED_SLIME = preload("res://survivors_like/scenes/red_slime.tscn")

var kb_green_slimes
var kb_red_slimes


func init_kb_green_slimes():
	kb_green_slimes = IDP.create_empty_kb()
	var GreenSlime = kb_green_slimes.add_type("GreenSlime", [], IDP.INT)
	var green_slime_hp = kb_green_slimes.add_function("green_slime_hp", GreenSlime, IDP.INT)
	var green_slime_aggro = kb_green_slimes.add_predicate("green_slime_aggro", GreenSlime)
	var health_threshold = kb_green_slimes.add_constant("health_threshold", IDP.INT, 2)
	
	var is_slime_agro = green_slime_hp.apply("slime")\
		.lte(health_threshold.apply())\
		.equivalent(
			green_slime_aggro.apply("slime").not_()
		)
	kb_green_slimes.add_formula(
		Quantifier.create("slime",GreenSlime, is_slime_agro).all()
	)
	kb_green_slimes.finished_inference.connect(expand_loop_green)
		
func init_kb_red_slimes():
	kb_red_slimes = IDP.create_empty_kb()
	var redSlime = kb_red_slimes.add_type("redSlime", [], IDP.INT)
	var red_slime_hp = kb_red_slimes.add_function("red_slime_hp", redSlime, IDP.INT)
	var red_slime_aggro = kb_red_slimes.add_predicate("red_slime_aggro", redSlime)
	var health_threshold = kb_red_slimes.add_constant("health_threshold", IDP.INT, 2)
	
	var is_slime_agro = red_slime_hp.apply("slime")\
		.lte(health_threshold.apply())\
		.equivalent(
			red_slime_aggro.apply("slime").not_()
		)
	kb_red_slimes.add_formula(
		Quantifier.create("slime",redSlime, is_slime_agro).all()
	)
	kb_red_slimes.finished_inference.connect(expand_loop_red)

func _ready() -> void:
	init_kb_green_slimes()
	update_kb_green_from_gameworld()
	call_expand_green()

	init_kb_red_slimes()
	update_kb_red_from_gameworld()
	call_expand_red()
	
func spawn_mob_green():
	var new_mob = GREEN_SLIME.instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	
func spawn_mob_red():
	var new_mob = RED_SLIME.instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func _on_spawn_timer_timeout() -> void:
	spawn_mob_green()
	spawn_mob_red()

func _on_player_health_depleted() -> void:
	get_tree().reload_current_scene()
	
func update_kb_green_from_gameworld() -> void:
	var green_slimes = get_tree().get_nodes_in_group("green_slime")
	var GreenSlime: CustomType = kb_green_slimes.types.GreenSlime
	GreenSlime.clear_enumeration()
	kb_green_slimes.symbols.green_slime_hp.unset()
	
	for green_slime in green_slimes:
		GreenSlime.add_enum(green_slime.id)
		kb_green_slimes.symbols.green_slime_hp.add(green_slime.id,green_slime.health)

func update_kb_red_from_gameworld() -> void:
	var red_slimes = get_tree().get_nodes_in_group("red_slime")
	var redSlime: CustomType = kb_red_slimes.types.redSlime
	redSlime.clear_enumeration()
	kb_red_slimes.symbols.red_slime_hp.unset()
	for red_slime in red_slimes:
		redSlime.add_enum(red_slime.id)
		kb_red_slimes.symbols.red_slime_hp.add(red_slime.id,red_slime.health)
		
func process_expand_green() -> void:
	var green_slimes = get_tree().get_nodes_in_group("green_slime")
	if not kb_green_slimes.solutions[0].has("green_slime_aggro"):
		return
	var green_slime_aggro_list = kb_green_slimes.solutions[0].green_slime_aggro.inter_keys()
	for green_slime in green_slimes:
		if green_slime.id in green_slime_aggro_list:
			green_slime.aggro = true
		else:
			green_slime.aggro = false

func process_expand_red() -> void:
	var red_slimes = get_tree().get_nodes_in_group("red_slime")
	if not kb_red_slimes.solutions[0].has("red_slime_aggro"):
		return
	var red_slime_aggro_list = kb_red_slimes.solutions[0].red_slime_aggro.inter_keys()
	for red_slime in red_slimes:
		if red_slime.id in red_slime_aggro_list:
			red_slime.aggro = true
		else:
			red_slime.aggro = false
		
func call_expand_green() -> void:
	IDP.model_expand_async(kb_green_slimes,1)

func call_expand_red() -> void:
	IDP.model_expand_async(kb_red_slimes,1)
	
func expand_loop_green(_kb, _inference_type) -> void:
	print("looping (green) ... active inferences: ", IDP.active_inferences)
	process_expand_green()
	update_kb_green_from_gameworld()
	call_expand_green()
	
func expand_loop_red(_kb, _inference_type) -> void:
	print("looping (red) ... active inferences: ", IDP.active_inferences)
	process_expand_red()
	update_kb_red_from_gameworld()
	call_expand_red()

