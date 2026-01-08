extends StaticBody2D

var plant
var plantgrowing = false
var plant_grown = false

func _ready():
	plantgrowing = false
	plant_grown = false
	plant = -1
	$plant.play("none")
	$plant.frame = 0

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if Global.toolselected != Global.Tool.SEED:
		return
	
	if plantgrowing:
		return

	if Global.plantselected == -1:
		return  # chưa chọn hạt giống

	plant = Global.plantselected
	plantgrowing = true

	$growtimer.wait_time = Global.timeofveget[plant]
	$growtimer.start()
	$plant.play(Global.nameofveget[plant])

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Global.toolselected == Global.Tool.SEED and not plantgrowing:
			# Trồng cây dựa trên ID hạt giống đang chọn trong Hotbar
			plant = Global.plantselected 
			start_growing()
			
			# (Tùy chọn) Trừ 1 hạt giống trong Inventory của Player
			# owner_player.inventory.remove_item_at_index(owner_player.selected_slot, 1)

func start_growing():
	plantgrowing = true
	$growtimer.start(Global.timeofveget[plant])
	$plant.play(Global.nameofveget[plant])
	$plant.show()
	
#THOI GIAN CAY LON
func _on_growtimer_timeout() -> void:
	if $plant.frame == 0:
		$plant.frame = 1
		$growtimer.wait_time = Global.timeofveget[plant]
		$growtimer.start()
	elif $plant.frame == 1:
		$plant.frame = 2
		plant_grown = true
#TUONG TAC VOI TOOL
func _on_input_event(_viewport, event, _idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Global.toolselected == Global.Tool.SEED and not plantgrowing:
			# Lấy thông tin từ Global mà Player vừa cập nhật khi lăn chuột
			plant = Global.plantselected 
			plantgrowing = true
			$growtimer.start(Global.timeofveget[plant])
			$plant.play(Global.nameofveget[plant])
			$plant.show()

func plant_seed():
	plant = Global.plantselected
	plantgrowing = true
	$growtimer.start(Global.timeofveget[plant])
	$plant.play(Global.nameofveget[plant])
	print("Đã trồng: ", Global.nameofveget[plant])
