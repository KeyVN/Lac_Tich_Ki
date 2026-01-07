extends StaticBody2D

var selected = false
var seed_type = 1

func _ready():
	$AnimatedSprite2D.play("default")

func _on_pressed():
	Global.toolselected = Global.Tool.SEED
	Global.plantselected = seed_type

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		Global.plantselected = seed_type
		selected = true
		
func _physics_process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25*delta)
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
