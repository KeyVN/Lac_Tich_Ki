# Inventory.gd
extends Node
class_name Inventory

signal inventory_changed
@export var items: Array = []
@export var size: int = 20

func _ready():
	items.resize(size)

# SỬA LẠI: Trả về bool để biết có thêm được không
func add_item(item_data: ItemData, quantity: int) -> bool:
	# 1. Cộng dồn (Stacking)
	for i in range(items.size()):
		if items[i] != null and items[i]["item"] == item_data:
			# Kiểm tra max stack nếu cần (bạn đã có max_stack_size trong ItemData)
			var new_quantity = items[i]["quantity"] + quantity
			if new_quantity <= item_data.max_stack_size:
				items[i]["quantity"] = new_quantity
				inventory_changed.emit()
				return true # Thành công
			
	# 2. Tìm ô trống
	for i in range(items.size()):
		if items[i] == null:
			items[i] = {"item": item_data, "quantity": quantity}
			inventory_changed.emit()
			return true # Thành công
	
	print("Túi đầy rồi!")
	return false # Thất bại

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
