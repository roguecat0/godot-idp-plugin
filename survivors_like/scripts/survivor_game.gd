extends Node2D

const GREEN_SLIME = preload("res://survivors_like/scenes/green_slime.tscn")

var kb

func init_kb():
	kb = IDP.create_empty_kb()
	var GreenSlime = kb.add_type("GreenSlime", [], IDP.INT)
	var green_slime_hp = kb.add_function("green_slime_hp", GreenSlime, IDP.INT)
	var green_slime_aggro = kb.add_predicate("green_slime_aggro", GreenSlime)
	var health_threshold = kb.add_constant("health_threshold", IDP.INT, 2)
	
	var is_slime_agro = green_slime_hp.apply("slime")\
		.lte(health_threshold.apply())\
		.equivalent(
			green_slime_aggro.apply("slime").not_()
		)
	kb.add_formula(
		ForEach.create("slime",GreenSlime, is_slime_agro).all()
	)
	kb.finished_inference.connect(expand_loop)
		

func _ready() -> void:
	init_kb()
	spawn_mob()
	update_kb_from_gameworld()
	print(kb.parse_to_idp())
	call_expand()
	
func spawn_mob():
	var new_mob = GREEN_SLIME.instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func _on_spawn_timer_timeout() -> void:
	spawn_mob()

func _on_player_health_depleted() -> void:
	get_tree().reload_current_scene()
	
func update_kb_from_gameworld() -> void:
	var green_slimes = get_tree().get_nodes_in_group("green_slime")
	var GreenSlime: CustomType = kb.types.GreenSlime
	GreenSlime.clear_enumeration()
	for green_slime in green_slimes:
		GreenSlime.add_enum(green_slime.id)
		kb.symbols.green_slime_hp.add(green_slime.id,green_slime.health)
		
func process_expand() -> void:
	var green_slimes = get_tree().get_nodes_in_group("green_slime")
	var green_slime_aggro_list = kb.solutions[0].green_slime_aggro.inter_keys()
	for green_slime in green_slimes:
		if green_slime.id in green_slime_aggro_list:
			green_slime.aggro = true
		else:
			green_slime.aggro = false
		
func call_expand() -> void:
	IDP.model_expand_async(kb,1)
	
func expand_loop(_kb, _inference_type) -> void:
	print("looping... active inferences: ", IDP.active_inferences)
	process_expand()
	update_kb_from_gameworld()
	call_expand()
	
