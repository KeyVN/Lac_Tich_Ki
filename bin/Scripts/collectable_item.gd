# CollectableItem.gd
extends Area2D

@onready var sprite = $Sprite2D

# --- [THÊM] Biến Export để kéo thả file .tres trong Editor ---
@export var initial_item: ItemData 
@export var initial_quantity: int = 1

@export var sync_item_path: String = "" 
@export var quantity: int = 1

var item_data: ItemData

func init(_item: ItemData, _qty: int):
	item_data = _item
	quantity = _qty
	if _item:
		sync_item_path = _item.resource_path
	
func _ready():
	# TRƯỜNG HỢP 1: Đồ đặt sẵn trong Editor (Host/Server sẽ chạy dòng này)
	if item_data == null and initial_item != null:
		item_data = initial_item
		quantity = initial_quantity
		# Quan trọng: Cập nhật đường dẫn để lát nữa Spawner gửi cho Client khác
		sync_item_path = initial_item.resource_path
	
	# TRƯỜNG HỢP 2: Client vào game và nhận được đường dẫn từ Server
	if item_data == null and sync_item_path != "":
		item_data = load(sync_item_path)

	# --- HIỂN THỊ ---
	if item_data:
		sprite.texture = item_data.icon
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not item_data: return
	
	# Chỉ Authority (người điều khiển nhân vật đó) mới xử lý nhặt
	if body.is_multiplayer_authority() and body.has_method("collect_item"):
		var success = body.collect_item(item_data, quantity)
		if success:
			rpc("request_queue_free")

@rpc("any_peer", "call_local", "reliable")
func request_queue_free():
	if multiplayer.is_server():
		queue_free()
