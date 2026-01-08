extends Node2D
class_name ToolBase

var owner_player: CharacterBody2D
var world: Node
var tilemap: TileMap

func setup(player: CharacterBody2D):
	owner_player = player
	world = get_tree().current_scene
	tilemap = world.get_node("TileMap") # đúng tên node TileMap trong World

func _unhandled_input(event):
	# Kiểm tra nếu owner_player chưa được gán (vẫn là null) thì thoát sớm
	if owner_player == null:
		return

	# ❗ chỉ tool của player mình mới được dùng
	if not owner_player.is_multiplayer_authority():
		return

	if event.is_action_pressed("use_tool"):
		use_tool()

func use_tool():
	pass # override ở Hoe / Shovel
