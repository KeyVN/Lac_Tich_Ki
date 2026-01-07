# InventoryUI.gd
extends Control

# --- [MỚI] Tín hiệu gửi ra ngoài khi chọn đồ ---
signal item_selected(item: ItemData)

var slot_scene = preload("res://bin/Scenes/slot.tscn")
@onready var grid = $GridContainer

var inventory_ref: Inventory
var is_open = false # --- [MỚI] Biến theo dõi trạng thái đóng mở

func _ready():
	visible = false # Mặc định ẩn túi đồ đi
	is_open = false

# --- [MỚI] Xử lý phím tắt để bật/tắt ---
func _input(event):
	if event.is_action_pressed("toggle_inventory"): # Nhớ cài phím này trong Project Settings
		if is_open:
			close()
		else:
			open()

func open():
	visible = true
	is_open = true
	# get_tree().paused = true # Bỏ comment dòng này nếu muốn game dừng khi mở túi

func close():
	visible = false
	is_open = false
	# get_tree().paused = false

func set_inventory(inventory: Inventory):
	inventory_ref = inventory
	
	if not is_node_ready():
		await ready
		
	if not inventory_ref.inventory_changed.is_connected(update_grid):
		inventory_ref.inventory_changed.connect(update_grid)
		
	update_grid()

func update_grid():
	# Xóa sạch ô cũ
	for child in grid.get_children():
		child.queue_free()
	
	print("Số lượng item trong kho: ", inventory_ref.items.size())
	
	# --- [SỬA LẠI] Dùng vòng lặp có index (i) để biết ô số mấy ---
	for i in range(inventory_ref.items.size()):
		var item_info = inventory_ref.items[i]
		var slot_instance = slot_scene.instantiate()
		grid.add_child(slot_instance)
		
		# --- [MỚI] Kết nối tín hiệu click từ ô con ---
		slot_instance.slot_clicked.connect(_on_slot_clicked)
		
		if item_info != null:
			# Truyền thêm 'i' (số thứ tự) vào hàm set_slot_data
			slot_instance.set_slot_data(item_info["item"], item_info["quantity"], i)
		else:
			slot_instance.set_slot_data(null, 0, i)

# --- [MỚI] Hàm nhận tín hiệu khi click vào 1 ô ---
func _on_slot_clicked(index: int, item: ItemData):
	if item == null: return
	
	# Kiểm tra nếu nhấn chuột phải (Right Click) để VỨT ĐỒ
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		# 1. Xóa khỏi kho (xóa 1 cái)
		var removed_data = inventory_ref.remove_item_at_index(index, 1)
		
		# 2. Gọi Player spawn đồ ra đất
		if removed_data.has("item"):
			# Tìm node player để gọi hàm drop
			# Cách đơn giản: inventory_ref thường nằm trong player, ta lấy owner
			var player = inventory_ref.get_parent() # Giả sử Inventory là con của Player
			if player.has_method("drop_item"):
				player.drop_item(removed_data["item"], removed_data["quantity"])
				
	else:
		# Chuột trái thì giữ nguyên logic chọn đồ cũ
		print("Đã chọn: ", item.name)
		item_selected.emit(item)
