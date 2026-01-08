@tool # Dòng này cực kỳ quan trọng
extends StaticBody2D

# Sử dụng set để gọi hàm cập nhật mỗi khi giá trị thay đổi
@export var type: Global.SeedType = Global.SeedType.CARROT:
	set(value):
		type = value
		if Engine.is_editor_hint(): # Nếu đang ở trong Editor
			update_appearance()

@export var selected = false

func _ready():
	update_appearance()

func update_appearance():
	# Kiểm tra xem node AnimatedSprite2D đã sẵn sàng chưa để tránh lỗi null
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		match type:
			Global.SeedType.CARROT:
				sprite.play("carrot")
			Global.SeedType.ONION:
				sprite.play("onion")

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Global.toolselected = Global.Tool.SEED
		Global.plantselected = type # type lúc này là giá trị số (0, 1, 2) từ Global.SeedType
		selected = true
		print("Đã chọn hạt giống từ Global: ", Global.SeedType.keys()[type])

func _physics_process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
