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

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		if plant_grown:
			Global.numofveget[plant] += 1
			plantgrowing = false
			plant_grown = false
			plant = -1
			$plant.play("none")
			$plant.frame = 0

func _on_growtimer_timeout() -> void:
	if $plant.frame == 0:
		$plant.frame = 1
		$growtimer.wait_time = Global.timeofveget[plant]
		$growtimer.start()
	elif $plant.frame == 1:
		$plant.frame = 2
		plant_grown = true
