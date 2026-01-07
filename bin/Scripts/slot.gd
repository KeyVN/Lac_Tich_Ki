# Slot.gd
extends PanelContainer

# Tín hiệu báo cho InventoryUI biết ô này bị click
signal slot_clicked(index: int, item: ItemData)

@onready var icon_node = $Icon # Đảm bảo đúng tên node icon của bạn
@onready var amount_node = $AmountLabel     # Đảm bảo đúng tên node số lượng

var my_index: int = -1
var my_item: ItemData = null

# --- [SỬA] Hàm nhận 3 tham số (thêm index) ---
func set_slot_data(item: ItemData, quantity: int, index: int):
	my_item = item
	my_index = index
	
	if item != null:
		print("Đang vẽ item: ", item.name)
		print("Dữ liệu ảnh: ", item.icon) # Dòng này phải nằm trong if
		if icon_node: icon_node.texture = item.icon
		if amount_node: amount_node.text = str(quantity)
	else:
		# Nếu là ô trống (null)
		if icon_node: icon_node.texture = null
		if amount_node: amount_node.text = ""

# --- [MỚI] Hàm bắt sự kiện click chuột ---
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(my_index, my_item)
