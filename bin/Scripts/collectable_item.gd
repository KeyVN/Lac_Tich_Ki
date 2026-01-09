# CollectableItem.gd
extends Area2D

@onready var sprite = $Sprite2D

# --- CẤU HÌNH ---
@export var initial_item: ItemData 
@export var initial_quantity: int = 1

# Biến mạng (Nhớ Add vào Replication tab và tích SPAWN)
@export var sync_item_path: String = "" :
	set(value):
		sync_item_path = value
		_update_visual()

@export var quantity: int = 1
var item_data: ItemData

func init(_item: ItemData, _qty: int):
	item_data = _item
	quantity = _qty
	if _item: sync_item_path = _item.resource_path 

func _ready():
	print("Item sinh ra tại: ", get_parent().name)
	# Load item đặt sẵn (Host)
	if sync_item_path == "" and initial_item != null:
		init(initial_item, initial_quantity)
	
	_update_visual()
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _update_visual():
	if not is_inside_tree(): return
	if item_data == null and sync_item_path != "":
		item_data = load(sync_item_path)
	if item_data and sprite:
		sprite.texture = item_data.icon

func _on_body_entered(body):
	# Chỉ người điều khiển mới được nhặt
	if body.is_multiplayer_authority() and body.has_method("collect_item"):
		var success = body.collect_item(item_data, quantity)
		if success:
			# Gửi lệnh xóa cho TẤT CẢ mọi người
			rpc("sync_destroy_item")

# --- HÀM XÓA QUAN TRỌNG ---
# "call_local": Chạy trên cả máy mình
# "any_peer": Client được phép gọi
@rpc("any_peer", "call_local", "reliable")
func sync_destroy_item():
	# Cách 1: Nếu là đồ do Spawner quản lý -> Chỉ Server xóa là đủ
	if multiplayer.is_server():
		queue_free()
	
	# Cách 2 (Dự phòng): Nếu là đồ đặt sẵn (Editor), Spawner có thể không xóa giùm Client
	# -> Ép xóa luôn nếu node vẫn còn tồn tại
	if not multiplayer.is_server() and is_instance_valid(self):
		queue_free()
