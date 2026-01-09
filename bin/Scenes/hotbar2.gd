# hotbar.gd
extends Control

signal slot_selected(index: int) # Báo cho Player biết mình chọn ô nào

@onready var grid = $Grid
var slot_scene = preload("res://bin/Scenes/slot.tscn")
var inventory_ref: Inventory

func set_inventory(inv: Inventory):
	inventory_ref = inv
	inventory_ref.inventory_changed.connect(refresh_ui)
	refresh_ui()

func refresh_ui():
	# Chốt an toàn: Nếu chưa có kho thì không làm gì
	if inventory_ref == null: return

	# Xóa cũ
	for child in grid.get_children(): child.queue_free()
	
	# Tạo mới 10 ô (Hotbar)
	for i in range(9):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		
		# --- [QUAN TRỌNG] Kết nối tín hiệu click từ Slot ---
		if slot.has_signal("slot_clicked"):
			slot.slot_clicked.connect(_on_slot_clicked)
		
		if i < inventory_ref.items.size():
			var data = inventory_ref.items[i]
			if data: 
				slot.set_slot_data(data["item"], data["quantity"], i)
			else: 
				slot.set_slot_data(null, 0, i)
				
# Hàm xử lý khi người chơi click chuột vào ô trên Hotbar
func _on_slot_clicked(index: int, _item: ItemData):
	# Nếu click chuột phải: Vứt đồ (Giống InventoryUI)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var player = inventory_ref.get_parent() # Giả sử Inventory là con của Player
		if player and player.has_method("drop_item"):
			var removed_data = inventory_ref.remove_item_at_index(index, 1)
			if removed_data.has("item"):
				player.drop_item(removed_data["item"], removed_data["quantity"])
	
	# Nếu click chuột trái: Chọn ô đó (Cầm lên tay)
	else:
		slot_selected.emit(index) # Gửi tín hiệu ra cho Player
