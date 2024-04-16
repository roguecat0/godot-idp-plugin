extends TileMap

const main_layer = 0
const main_atlas_id = 0

const tile_atlas_mapper = {
	"hills":Vector2i(5,1), "forest":Vector2i(2,0), "mountains":Vector2i(5,0), "fields":Vector2i(0,0), "pasture":Vector2i(1,2),"desert":Vector2i(1,3), "none":Vector2i(-1,-1)
}
const man_map_cords = {
[2,-2]:Vector2i(2,-1),[2,-1]:Vector2i(2,0),[2,0]:Vector2i(2,1),
[1,-2]:Vector2i(1,-2),[1,-1]:Vector2i(1,-1),[1,0]:Vector2i(1,0),[1,1]:Vector2i(1,1),
[0,-2]:Vector2i(0,-2),[0,-1]:Vector2i(0,-1),[0,0]:Vector2i(0,0),[0,1]:Vector2i(0,1),[0,2]:Vector2i(0,2),
[-1,-1]:Vector2i(-1,-2),[-1,0]:Vector2i(-1,-1),[-1,1]:Vector2i(-1,0),[-1,2]:Vector2i(-1,1),
[-2,0]:Vector2i(-2,-1),[-2,1]:Vector2i(-2,0),[-2,2]:Vector2i(-2,1),
}

@export var token_scene: PackedScene

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = event.position
			var pos_clicked = local_to_map(to_local(global_clicked))
			print("position: ",pos_clicked, ", translated: ", convert_to_axial(pos_clicked))
			var current_atlas_coords = get_cell_atlas_coords(main_layer, pos_clicked)
			# print(current_atlas_coords)
				# var current_atlas_coords = get_cell_atlas_coords(main_layer, pos_clicked)
				# var current_tile_alt = get_cell_alternative_tile(main_layer, pos_clicked)
				# if current_tile_alt > -1:
				# 	var number_of_alts_for_clicked = tile_set.get_source(main_atlas_id)\
				# 			.get_alternative_tiles_count(current_atlas_coords)
				# 	set_cell(main_layer, pos_clicked, main_atlas_id, current_atlas_coords, 
				# 			(current_tile_alt + 1) %  number_of_alts_for_clicked)

func set_tiles(tiles):
	for coord in tiles.keys():
		var tile = tiles[coord]
		if man_map_cords.get(coord) != null:
			set_cell(main_layer, man_map_cords[coord],main_atlas_id,tile_atlas_mapper[tile])

func set_tokens(tokens):
	get_tree().call_group("token_group","queue_free")
	for coord in tokens.keys():
		var token = tokens[coord]
		if man_map_cords.get(coord) != null:
			var token_gui = token_scene.instantiate()
			token_gui.setup(token)
			var local_coords = map_to_local(man_map_cords[coord])
			token_gui.position = local_coords
			add_child(token_gui)
			
			# set_cell(main_layer, man_map_cords[coord],main_atlas_id,tile_atlas_mapper[tile])
	

func convert_to_axial(coord: Vector2i) -> Vector2i:
	var c: int = absi(coord.y) % 2
	var q: int = coord.x - ((coord.y - c) / 2.0)
	var r: int = coord.y
	return Vector2i(q,r)

func convert_to_doubled(coord: Vector2i) -> Vector2i:
	var row: int = coord.x*2
	var col: int = coord.y
	if (row+col) % 2 != 0:
		if row > 0:
			row -= 1
		else:
			row += 1
	return Vector2i(row,col)
