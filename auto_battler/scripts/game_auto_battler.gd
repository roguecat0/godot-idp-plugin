extends Node2D

var kb: KnowlegdeBase
var kb2: KnowlegdeBase
var player_configs
@export var villager_scene: PackedScene
@onready var label: Label = $UI/GameOver/Label

@onready var player_areas: Dictionary = {
	"Farm": $Farm1,
	"Fight": $Fight1,
	"Rest": $Rest1,
}
@onready var enemy_areas: Dictionary = {
	"Farm": $Farm2,
	"Fight": $Fight2,
	"Rest": $Rest2,
}
var player_data = {
	"villagers": [],
	"food": 10,
	"damage": 0,
	"fighters": [],
}
var enemy_data = {
	"villagers": [],
	"food": 10,
	"damage": 0,
	"fighters": [],
}
var time: int = 0
var game_running: bool = false

@onready var rule_maker: Control = $CanvasLayer/RuleMaker

const enemy_rules: String = "\
rule_0 : (Unit) -> Bool
rule_1 : (Unit) -> Bool
rule_2 : (Unit) -> Bool
"
const enemy_behavior: String = "\
	!u in Unit: rule_0(u) <=> true & unitColor(u) = Red.
	!u in Unit: rule_1(u) <=> true & unitColor(u) = Blue.
	!u in Unit: rule_2(u) <=> true & unitColor(u) = Green.
	!u in Unit: unitAction(u) = Fight <= rule_0(u).
	!u in Unit: unitAction(u) = Farm <= rule_1(u) & ~rule_0(u).
	!u in Unit: unitAction(u) = Rest <= rule_2(u) & ~rule_0(u) & ~rule_1(u).
"


func _ready() -> void:
	return
	kb = rule_maker.init_kb()
	Array(enemy_behavior.split("\n")).map(func(l): kb.add_undefined_line(l, IDP.THEORY))
	Array(enemy_rules.split("\n")).map(func(l): kb.add_undefined_line(l, IDP.VOCABULARY))
	print(kb.parse_to_idp())
	begin_battle()
	start_idp_loop()

func _process(delta: float) -> void:
	villagers_state_handler(player_data,player_areas, delta)
	villagers_state_handler(enemy_data,enemy_areas, delta)
	#print("player: ", player_data.villagers)
	#print("enemy: ", enemy_data.villagers)
	player_data.fighters.map(func(x): 
		x.take_damage(enemy_data.damage/len(player_data.fighters)))
	enemy_data.fighters.map(func(x): 
		x.take_damage(player_data.damage/len(enemy_data.fighters)))
	update_gui()
		
func update_gui():
	$UI/Panel/Food1.text = "%.1f" % player_data.food
	$UI/Panel2/Food2.text = "%.1f" % enemy_data.food
	$UI/Panel3/Villagers1.text = "%d" % len(player_data.villagers)
	$UI/Panel4/Villagers2.text = "%d" % len(enemy_data.villagers)
	$UI/Panel5/Time.text = "%d" % time
	
func villagers_state_handler(data, areas, delta):
	var villagers = data.villagers
	for villager in villagers:
		if not is_instance_valid(villager):
			continue
		var state = villager.curr_state
		villager.target_pos = get_area_center(areas[state])
		villager.in_area = false
		
	for state in areas.keys():
		var area = areas[state]
		var bodies = area.get_overlapping_bodies()
		bodies = bodies.filter(func(x): 
			return x.has_method("animation_handler") and state == x.curr_state)
		var area_rect = get_area_rect(area)
		var size = area_rect.size
		var n_bodies = len(bodies)
		
		#print("bodies in ", state, ": ", n_bodies)
		if n_bodies == 0:
			if state == "Fight":
				data.fighters = []
			continue
		var area_length = 1
		if state == "Rest":
			area_length = 4
		
		match state:
			"Farm": 
				data.food += bodies.reduce(func(acc, x): 
					return acc + x.farm(delta), 0)
			"Fight":
				data.damage = bodies.reduce(func(acc, x): 
					return acc + x.attack(delta), 0)
				data.fighters = bodies
			
		for i in n_bodies:
			var body = bodies[i]
			body.in_area = true
			
			body.target_pos = get_position_in_area(area_rect, 
				int(ceil(float(n_bodies)/area_length)),
				area_length,i)
				
			if state == "Rest":
				body.regenerate(delta)
	
func get_area_rect(area: Area2D) -> Rect2:
	var colli = area.get_node("CollisionShape2D")
	var trans = colli.get_global_transform()
	var rect = colli.shape.get_rect()
	return Rect2(
		trans.basis_xform(rect.position) + trans.origin,
		trans.basis_xform(rect.size)
	)
	
func get_area_center(area: Area2D):
	var area_rect = get_area_rect(area)
	return area_rect.position + area_rect.size/2
	
func get_position_in_area(area_rect: Rect2, rows, cols, idx):
	var row = idx / cols
	var col = idx % cols
	return area_rect.position +\
	 Vector2(area_rect.size.x*((2.0*col+1.0)/(2*cols)), area_rect.size.y*((2.0*row+1.0)/(2*rows)))

func begin_battle():
	var colors = ["Red", "Green", "Blue"]
	for i in range(6):
		var color = colors[i % 3]
		spawn_villager(true, null, color)
		spawn_villager(false, null, color)
	$DayTimer.start()
	game_running = true
		
func random_shuffle_villager_state(player=true):
	var data = player_data if player else enemy_data
	var areas = player_areas if player else enemy_areas
	if len(data.villagers) == 0:
		return
	var v = data.villagers[randi() % len(data.villagers)]
	if not is_instance_valid(v):
		return
	var curr_state = areas.keys()[randi() % len(areas.keys())]
	v.curr_state = curr_state

func _on_rule_maker_player_config(kb_) -> void:
	#return
	kb = kb_
	$CanvasLayer.visible = false
	begin_battle()
	start_idp_loop()

func start_idp_loop():
	kb2 = rule_maker.init_kb()
	Array(enemy_behavior.split("\n")).map(func(l): kb2.add_undefined_line(l, IDP.THEORY))
	Array(enemy_rules.split("\n")).map(func(l): kb2.add_undefined_line(l, IDP.VOCABULARY))
	
	kb.finished_inference.connect(expand_loop)
	kb2.finished_inference.connect(expand_loop)
	
	update_kb_villagers(kb,true)
	print(kb.parse_to_idp())
	#print(player_data.villagers)
	#print(enemy_data.villagers)
	IDP.model_expand_async(kb,1)
	
	update_kb_villagers(kb2,false)
	IDP.model_expand_async(kb2,1)

func end_of_day():
	var datas = [player_data, enemy_data]
	
	print("\nteam 1 ( food: %d, villagers: %d, fighters: %d), team 2 ( food: %d, villagers: %d, fighters: %d), " % [
		player_data.food, len(player_data.villagers), len(player_data.fighters),
		enemy_data.food, len(enemy_data.villagers), len(enemy_data.fighters),
	])
	for i in len(datas):
		var data = datas[i]
		var other_data = datas[i-1]
		if len(other_data.fighters) == 0 and len(data.fighters) != 0:
			var stolen = min(len(data.fighters) * 2, other_data.food)
			print("team %d: stole %d food" % [i+1, stolen])
			data.food += stolen
			other_data.food -= stolen
	
	for i in len(datas):
		if not game_running:
			return
		var data = datas[i]
		var other_data = datas[i-1]
		data.food -= len(data.villagers)
		if data.food < 0:
			
			var damage = abs(data.food)*3
			print("team %d: takes %.2f damage" % [i+1, damage])
			var tmp: Array = data.villagers
			tmp.sort_custom(func(a,b): return a.age > b.age)
			var len_tmp = len(tmp)
			for j in range(len_tmp):
				
				if damage <= 0:
					break
				var v = tmp[j]
				var health = v.health
				print("villager%d: takes %.2f damage, %s" % [v.id, min(health,damage), 
				"lives" if health > damage else "dies"])
				v.take_damage(damage)
				damage -= health
				
		else:
			var new_spawns = min(int(data.food) / 4, 500)
			print("team %d: spawns %d" % [i+1, new_spawns])
			range(new_spawns).map(func(x): spawn_villager(data == player_data))
		data.food = 0
	
func _on_day_timer_timeout() -> void:
	time += 1
	#random_shuffle_villager_state(false)
	#random_shuffle_villager_state(randi() % 2 == 0)
	
	player_data.villagers.map(func(v): v.age_up())
	enemy_data.villagers.map(func(v): v.age_up())
	if time % 5 == 0:
		end_of_day()
		
func spawn_villager(player=true, curr_state=null, color=null):
	color = ["Red", "Green", "Blue"][randi() % 3] if color == null else color
	
	if curr_state == null:
		curr_state = player_areas.keys()[randi() % len(player_areas.keys())]
	
	var villager = villager_scene.instantiate()
	villager.setup(color, curr_state, player)
	villager.died.connect(remove_villager)
	add_child(villager)
	
	villager.position = Vector2(450,400)
	if player:
		player_data.villagers.append(villager)
	else:
		enemy_data.villagers.append(villager)
		
func remove_villager(id: int):
	if not game_running:
		return
	player_data.villagers = player_data.villagers.filter(func(x): 
		return x.id != id)
	enemy_data.villagers = enemy_data.villagers.filter(func(x): 
		return x.id != id)
	if len(player_data.villagers) == 0 or len(enemy_data.villagers) == 0:
		end_game()
		
func end_game():
	game_running = false
	var player_won = len(player_data.villagers) != 0
	reset_map()
	label.text = "Game Over\n %s Wins" % ("player" if player_won else "enemy")
	$UI/GameOver.visible = true
	await get_tree().create_timer(2).timeout
	$UI/GameOver.visible = false
	rule_maker.reset_ui()
	$CanvasLayer.visible = true
	return
	
func reset_map():
	time = 0
	$DayTimer.stop()
	var tmp  = player_data.villagers
	player_data = {
		"villagers": [],
		"food": 10,
		"damage": 0,
		"fighters": [],
	}
	tmp.map(func(v): v.queue_free())
	tmp  = enemy_data.villagers
	enemy_data = {
		"villagers": [],
		"food": 10,
		"damage": 0,
		"fighters": [],
	}
	tmp.map(func(v): v.queue_free())
		
	
func update_villager_states(kb, player):
	var data = player_data if player else enemy_data
	if not kb.solutions[0].has("unitAction"):
		return
	var unitAction = kb.solutions[0].unitAction
	for villager in data.villagers:
		if not is_instance_valid(villager):
			continue
		if not unitAction.has(villager.id):
			continue
		villager.curr_state = unitAction.geti(villager.id)
	
func update_kb_villagers(kb,player):
	kb = clean_kb(kb)
	var data = player_data if player else enemy_data
	var Unit: CustomType = kb.types.Unit
	var unitHealth: Function = kb.symbols.unitHealth
	var unitAge: Function = kb.symbols.unitAge
	var unitColor: Function = kb.symbols.unitColor
	
	for villager in data.villagers:
		if not is_instance_valid(villager):
			continue
		Unit.add_enum(villager.id)
		unitHealth.add(villager.id, villager.health)
		unitAge.add(villager.id, villager.age)
		unitColor.add(villager.id, villager.color)
		
	kb.symbols.food.set_value(int(data.food))
	kb.symbols.units.set_value(len(data.villagers))
	kb.symbols.time.set_value(time)
	
	
func clean_kb(kb):
	kb.types.Unit.clear_enumeration()
	kb.symbols.unitHealth.unset()
	kb.symbols.unitAge.unset()
	kb.symbols.unitColor.unset()
	kb.symbols.unitAction.unset()
	return kb
	
func expand_loop(kb, _inference_type):
	if not game_running:
		return
	var player = kb != kb2
	update_villager_states(kb, player)
	update_kb_villagers(kb, player)
	IDP.model_expand_async(kb,1)
	
