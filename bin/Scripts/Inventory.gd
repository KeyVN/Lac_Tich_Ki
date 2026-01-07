extends Node
class_name Inventory # Đăng ký tên class để các file khác hiểu

signal inventory_changed

# Khai báo mảng chứa items
# Mỗi phần tử sẽ là null hoặc Dictionary {item, quantity}
@export var items: Array = []
@export var size: int = 20 # Mặc định túi có 20 ô

func _ready():
	# QUAN TRỌNG: Tạo sẵn 20 ô trống (null) khi game bắt đầu
	items.resize(size) 

# Hàm thêm đồ
func add_item(item_data: ItemData, quantity: int):
	# 1. Tìm đồ trùng để cộng dồn (Stacking)
	for i in range(items.size()):
		if items[i] != null and items[i]["item"] == item_data:
			items[i]["quantity"] += quantity
			inventory_changed.emit() # Báo UI vẽ lại
			return
			
	# 2. Nếu là đồ mới, tìm ô trống đầu tiên
	for i in range(items.size()):
		if items[i] == null:
			items[i] = {"item": item_data, "quantity": quantity}
			inventory_changed.emit() # Báo UI vẽ lại
			return
	
	print("Túi đầy rồi, không thêm được!")
