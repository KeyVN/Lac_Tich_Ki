# CollectableItem.gd
extends Area2D

@onready var sprite = $Sprite2D

# --- [THÊM] Biến Export để kéo thả file .tres trong Editor ---
@export var initial_item: ItemData 
@export var initial_quantity: int = 1

var item_data: ItemData
var quantity: int = 1

func init(_item: ItemData, _qty: int):
	item_data = _item
	quantity = _qty
	
func _ready():
	# Nếu item_data chưa có (do không gọi init), thử lấy từ biến export
	if item_data == null and initial_item != null:
		item_data = initial_item
		quantity = initial_quantity

	if item_data:
		sprite.texture = item_data.icon
	
	# Kết nối tín hiệu
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Kiểm tra xem body có phải là Player và có Inventory không
	if body.has_method("collect_item"):
		# Gọi hàm nhặt đồ bên Player [cite: 11]
		var success = body.collect_item(item_data, quantity)
		if success:
			queue_free()
