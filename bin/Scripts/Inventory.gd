# Inventory.gd
extends Node
class_name Inventory

signal inventory_changed
@export var items: Array = []
@export var size: int = 36

func _ready():
	items.resize(size)

func add_item(item_data: ItemData, quantity: int) -> bool:
	# GIAI ĐOẠN 1: TÌM ĐỂ CỘNG DỒN (STACKING) - Ưu tiên cộng vào ô đang có sẵn
	for i in range(items.size()):
		if items[i] != null and items[i]["item"] == item_data:
			var new_quantity = items[i]["quantity"] + quantity
			if new_quantity <= item_data.max_stack_size:
				items[i]["quantity"] = new_quantity
				inventory_changed.emit()
				return true
	
	# GIAI ĐOẠN 2: TÌM Ô TRỐNG TRONG HOTBAR (0 -> 9)
	# Đây là đoạn giúp ưu tiên nhặt vào tay trước
	var hotbar_size = 10 # Giả sử hotbar có 10 ô
	for i in range(hotbar_size):
		if i < items.size() and items[i] == null:
			items[i] = {"item": item_data, "quantity": quantity}
			inventory_changed.emit()
			return true
			
	# GIAI ĐOẠN 3: TÌM Ô TRỐNG TRONG BALO (Từ 10 trở đi)
	for i in range(hotbar_size, items.size()):
		if items[i] == null:
			items[i] = {"item": item_data, "quantity": quantity}
			inventory_changed.emit()
			return true

	print("Túi đầy rồi!")
	return false

# THÊM MỚI: Hàm xóa đồ khỏi túi (dùng để vứt)
# Trả về dữ liệu item đã xóa để ném ra đất
func remove_item_at_index(index: int, quantity_to_remove: int) -> Dictionary:
	if index < 0 or index >= items.size() or items[index] == null:
		return {}
	
	var slot = items[index]
	
	# Nếu số lượng muốn bỏ >= số lượng đang có -> Xóa sạch ô
	if quantity_to_remove >= slot["quantity"]:
		var removed_item = slot.duplicate() # Copy dữ liệu để trả về
		items[index] = null
		inventory_changed.emit()
		return removed_item
	else:
		# Chỉ trừ bớt số lượng
		slot["quantity"] -= quantity_to_remove
		inventory_changed.emit()
		return {"item": slot["item"], "quantity": quantity_to_remove}
