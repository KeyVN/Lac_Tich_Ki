# hotbar.gd
extends Control

@onready var grid = $Grid
@onready var selector = $Selector
var slot_scene = preload("res://bin/Scenes/slot.tscn")
var inventory_ref: Inventory

func set_inventory(inv: Inventory):
	inventory_ref = inv
	inventory_ref.inventory_changed.connect(refresh_ui)
	refresh_ui()

func refresh_ui():
	# Xóa cũ tạo mới 10 ô đầu tiên
	for child in grid.get_children(): child.queue_free()
	for i in range(10):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		var data = inventory_ref.items[i]
		if data: slot.set_slot_data(data["item"], data["quantity"], i)
		else: slot.set_slot_data(null, 0, i)

func move_selector(index: int):
	# Đợi UI sắp xếp các ô đồ xong xuôi
	await get_tree().process_frame 
	
	$Selector.position = Vector2(index * (60), 0)
