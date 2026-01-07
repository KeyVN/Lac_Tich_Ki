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
	if multiplayer.has_multiplayer_peer():
		set_multiplayer_authority(multiplayer.get_unique_id())
		
	id_label.text = "ID: %d" % get_multiplayer_authority()

	#❗ chỉ spawn tool cho player của mình
	if is_multiplayer_authority():
		spawn_tools()


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
# =========================
# 🛠 SPAWN TOOL
# =========================
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
	if not is_multiplayer_authority():
		return

	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	rpc_id(1, "server_move", dir)

	var input_vector := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	# DEADZONE
	if input_vector.length() < 0.3:
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	input_vector = input_vector.normalized()
	velocity = input_vector * SPEED

	if abs(input_vector.y) >= abs(input_vector.x):
		sprite.play("upwalk" if input_vector.y < 0 else "downwalk")
	else:
		sprite.play("sidewalk")
		sprite.flip_h = input_vector.x > 0

	move_and_slide()
	

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
		return inventory.add_item(item, quantity)
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
