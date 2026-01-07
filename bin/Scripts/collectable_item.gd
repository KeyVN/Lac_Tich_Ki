# CollectableItem.gd
extends Area2D

@onready var sprite = $Sprite2D

var item_data: ItemData
var quantity: int = 1

# Hàm khởi tạo khi spawn từ code
func init(_item: ItemData, _qty: int):
	item_data = _item
	quantity = _qty
	
func _ready():
	if item_data:
		sprite.texture = item_data.icon
	
	# Kết nối tín hiệu khi có người chạm vào
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Kiểm tra xem body có phải là Player và có Inventory không
	if body.has_method("collect_item"):
		var success = body.collect_item(item_data, quantity)
		if success:
			queue_free() # Xóa khỏi thế giới nếu nhặt thành công
