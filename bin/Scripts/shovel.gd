extends ToolBase

const TILE_SOURCE_ID := 0
const TILE_GRASS := Vector2i(1, 7)
const TILE_DIRT  := Vector2i(6, 7)

func use_tool():
	var cell := get_cell_under_player()
	var atlas := tilemap.get_cell_atlas_coords(0, cell)

	if atlas == TILE_GRASS:
		tilemap.set_cell(0, cell, TILE_SOURCE_ID, TILE_DIRT)
	elif atlas == TILE_DIRT:
		tilemap.set_cell(0, cell, TILE_SOURCE_ID, TILE_GRASS)

func get_cell_under_player() -> Vector2i:
	var local_pos = tilemap.to_local(owner_player.global_position)
	return tilemap.local_to_map(local_pos)
