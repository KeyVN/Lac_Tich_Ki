extends CanvasLayer

@onready var label = $NoticeLabel

func _ready():
	label.text = "" # Mới vào thì để trống

# Hàm để hiển thị tin nhắn
func show_message(text: String):
	label.text = text
	# Tạo hiệu ứng biến mất sau 3 giây
	await get_tree().create_timer(3.0).timeout
	if label.text == text: # Kiểm tra nếu chưa bị tin nhắn mới đè lên
		label.text = ""
