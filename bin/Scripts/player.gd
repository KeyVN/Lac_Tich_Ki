extends CharacterBody2D

# =========================
# ⚙️ CẤU HÌNH
# =========================
const SPEED := 50.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tools_node: Node2D = $Tools
@onready var inventory = $Inventory
@onready var inventory_ui = %InventoryUI


#=============================
#  MULTIPLAYER
#===============================
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

# =========================
# 🛠 TOOL SETUP
# =========================
@onready var tool_holder = $ToolHolder
var current_tool: Node = null

@export var hoe_scene: PackedScene
@export var shovel_scene: PackedScene
@export var collectable_item_scene: PackedScene

# =========================
# 🌐 MULTIPLAYER SETUP
# =========================
@onready var id_label: Label = $id_label

func _ready():
	# Chỉ setup UI nếu là nhân vật của chính mình
	if is_multiplayer_authority():
		$Camera2D.make_current() # Đảm bảo Camera đi theo đúng người
		
	id_label.text = "ID: %d" % get_multiplayer_authority()

	#❗ chỉ spawn tool cho player của mình
	if is_multiplayer_authority():
		spawn_tools()

	if name.to_int() == 1:
		id_label.text = "[HOST] " + name
	else:
		id_label.text = "Player: " + name

	# Kiểm tra chắc chắn UI đã tìm thấy chưa (để debug)
	if inventory_ui:
		inventory_ui.set_inventory(inventory)
		print("Đã kết nối Inventory UI thành công!")
	else:
		print("Vẫn chưa tìm thấy UI! Hãy kiểm tra lại Bước 1.")
		
	var item_ca_rot = load("res://bin/Items/carrot.tres")
	var item_onion = load("res://bin/Items/onion.tres")
	
	if item_ca_rot:
		# Thêm 5 củ cà rốt vào túi
		inventory.add_item(item_ca_rot, 5)
		inventory.add_item(item_onion, 7)
		print("Đã thêm cà rốt vào túi!")
	else:
		print("Lỗi: Không tìm thấy file ItemData! Kiểm tra lại đường dẫn.")
	
	spawn_tools()
	
	if is_multiplayer_authority():
		$Camera2D.make_current()
		
		# SỬA ĐOẠN NÀY:
		if has_node("CanvasLayer"):
			$CanvasLayer.show() # Lệnh này cực kỳ quan trọng để hiện UI
			print("Đã thực thi lệnh hiện UI cho: ", name)
		
		if inventory_ui:
			inventory_ui.show()
	else:
		# Ẩn UI của người khác trên máy mình
		if has_node("CanvasLayer"):
			$CanvasLayer.hide()
	
# =========================
# 📡 SERVER SYNC
# =========================
# Hàm này chạy trên Server (ID 1) khi Client gửi vị trí lên
@rpc("any_peer", "call_local", "unreliable") 
func server_update_position(new_pos: Vector2):
	# Chỉ Server mới được quyền cập nhật vị trí cho các bản sao khác
	if multiplayer.is_server():
		global_position = new_pos

# Hàm Update Animation tách riêng cho gọn
func update_animation(input_vector: Vector2):
	if input_vector.length() == 0:
		sprite.play("idle")
		return

	if abs(input_vector.y) >= abs(input_vector.x):
		sprite.play("upwalk" if input_vector.y < 0 else "downwalk")
	else:
		sprite.play("sidewalk")
		sprite.flip_h = input_vector.x > 0

# =========================
# 🛠 INVENTORY - HOTBAR SETUP
# =========================
var selected_slot: int = 1
@onready var hotbar = $CanvasLayer/Hotbar # Trỏ đúng đường dẫn node

func _input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			selected_slot = (selected_slot + 8) % 9
			update_selection()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			selected_slot = (selected_slot + 1) % 9
			update_selection()
	# Thêm phần xử lý phím số bên dưới:
	if event is InputEventKey and event.pressed:
		for i in range(1, 10):
			if event.is_action_pressed("slot_" + str(i)):
				selected_slot = i - 1  # Vì slot_1 tương ứng với index 0
				update_selection()
				break

func update_selection():
	# 1. Bảo UI di chuyển cái khung
	hotbar.move_selector(selected_slot)
	
	# 2. Cầm đồ lên tay (Hàm sync_held_item bạn đã làm trước đó)
	sync_held_item()

func change_selected_slot(dir: int):
	# Sử dụng posmod để đảm bảo giá trị luôn từ 0-9
	selected_slot = posmod(selected_slot + dir, 10)
	
	# Gọi UI di chuyển khung
	if hotbar:
		hotbar.move_selector(selected_slot)
	
	# Cập nhật món đồ trên tay
	sync_held_item()

func sync_held_item():
	# 1. Xóa đồ cũ
	for child in tool_holder.get_children():
		child.queue_free()
	
	# 2. Lấy dữ liệu từ Inventory
	# Lưu ý: Bạn cần đảm bảo đã bỏ cây Cuốc/Xẻng vào ô đầu tiên của túi đồ
	var slot_data = inventory.items[selected_slot]
	
	if slot_data != null and slot_data.has("item"):
		var item = slot_data["item"] as ItemData
		var item_name = item.name.to_lower()
		
		if "hoe" in item_name:
			spawn_tool_instance(hoe_scene, Global.Tool.HOE)
		elif "shovel" in item_name:
			spawn_tool_instance(shovel_scene, Global.Tool.SHOVEL)
		elif "seed" in item_name:
			Global.toolselected = Global.Tool.SEED
			Global.plantselected = item.id
		else:
			Global.toolselected = Global.Tool.NONE
	else:
		# Nếu ô trống, tay sẽ không cầm gì
		Global.toolselected = Global.Tool.NONE

func spawn_tool_instance(scene, type):
	var t = scene.instantiate()
	tool_holder.add_child(t)
	t.setup(self)
	Global.toolselected = type

func spawn_tools():
	var hoe: ToolBase = hoe_scene.instantiate()
	var shovel: ToolBase = shovel_scene.instantiate()

	tool_holder.add_child(hoe)
	tool_holder.add_child(shovel)

	hoe.setup(self)
	shovel.setup(self)

	hoe.visible = true
	shovel.visible = false
	current_tool = hoe

# =========================
# 🔁 ĐỔI TOOL
# =========================
func set_active_tool(tool: Node):
	if current_tool:
		current_tool.visible = false

	current_tool = tool
	current_tool.visible = true

# =========================
# 🎮 VÒNG LẶP VẬT LÝ
# =========================
func _physics_process(delta: float) -> void:
	# 1. Nếu là chủ nhân vật (Authority): Gửi input lên server
	if is_multiplayer_authority():
		var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# Di chuyển client-side prediction (cho mượt trên máy mình trước)
		velocity = input_vector * SPEED
		move_and_slide()
		
		# Cập nhật animation
		update_animation(input_vector)
		
		# Gửi vị trí lên server để server biết mình đang ở đâu
		rpc_id(1, "server_update_position", global_position)
	

# =========================
# 🛒 LOGIC SHOP / SELL
# =========================w
func player_sell_method():
	pass

func player_shop_method():
	pass
	
@rpc("authority")
func server_move(dir: Vector2):
	position += dir.normalized() * 200 * get_physics_process_delta_time()
	
# =========================
# 🎒 PICK UP & DROP
# =========================

# Hàm này được gọi bởi CollectableItem
func collect_item(item: ItemData, quantity: int) -> bool:
	if inventory:
		var success = inventory.add_item(item, quantity)
		if success:
			# Sau khi thêm đồ, làm mới Hotbar và Inventory UI
			if hotbar: hotbar.refresh_ui() 
			if inventory_ui: inventory_ui.update_grid()
		return success
	return false

# Hàm vứt đồ ra thế giới
func drop_item(item: ItemData, quantity: int):
	if collectable_item_scene == null:
		print("Chưa gán CollectableItem Scene cho Player!")
		return
		
	var world_item = collectable_item_scene.instantiate()
	
	# Spawn tại vị trí player + một chút ngẫu nhiên để không bị chồng chéo
	world_item.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	
	world_item.init(item, quantity)
	get_parent().add_child(world_item) # Thêm vào World (Node cha của Player)
