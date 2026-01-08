extends ToolBase

const TILE_SOURCE_ID := 0
const TILE_DIRT := Vector2i(6, 7)

@export var growingzone_scene: PackedScene

func use_tool():
	var cell := get_cell_under_player()
	if world.growing_zones.has(cell):
		return

	var atlas := tilemap.get_cell_atlas_coords(0, cell)
	if atlas == TILE_DIRT:
		spawn_growingzone(cell)

func spawn_growingzone(cell: Vector2i):
	var zone = growingzone_scene.instantiate()
	var pos = tilemap.map_to_local(cell)
	zone.global_position = tilemap.to_global(pos)
	zone.z_index = -1 # <--- Thêm dòng này: Đảm bảo đất nằm dưới chân Player
	world.add_child(zone)
	world.growing_zones[cell] = zone

func get_cell_under_player() -> Vector2i:
	var local_pos = tilemap.to_local(owner_player.global_position)
	return tilemap.local_to_map(local_pos)
